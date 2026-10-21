package com.epms.service;

import com.epms.contracts.AuthorDirectory;
import com.epms.contracts.BookCatalog;
import com.epms.contracts.dto.AuthorDto;
import com.epms.contracts.dto.BookDto;
import com.epms.entity.RoyaltyAgreement;
import lombok.RequiredArgsConstructor;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * The royalty agreement as a PDF document: the parties, the commercial
 * terms finance entered, the standard clauses that explain how royalties
 * are worked out and paid, and the signature record. Finance and the
 * author download the same document.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RoyaltyAgreementDocumentService {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("d MMMM yyyy");
    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("d MMMM yyyy, HH:mm");

    private static final float MARGIN = 56;
    private static final float WIDTH = PDRectangle.A4.getWidth() - 2 * MARGIN;

    private final AuthorDirectory authorDirectory;
    private final BookCatalog bookCatalog;
    private final SettingsService settingsService;

    public String fileName(RoyaltyAgreement a) {
        return "royalty-agreement-" + a.getAgreementNumber() + ".pdf";
    }

    public byte[] pdf(RoyaltyAgreement a) {
        Optional<AuthorDto> author = authorDirectory.findAuthor(a.getAuthorId());
        Optional<BookDto> book = bookCatalog.findBook(a.getBookId());
        String company = orDefault(settingsService.companyName(), "Reading Planet");
        String address = settingsService.companyAddress();
        String currency = orDefault(settingsService.currency(), "LKR");
        String authorName = author.map(AuthorDto::fullName).orElse("Author #" + a.getAuthorId());
        String bookTitle = book.map(BookDto::title).orElse("Book #" + a.getBookId());
        String standardRate = pct(a.getRoyaltyPercentage());
        String wholesaleRate = pct(a.getWholesaleRoyaltyPercentage() != null
                ? a.getWholesaleRoyaltyPercentage() : a.getRoyaltyPercentage());
        boolean listPrice = "LIST_PRICE".equals(a.getBasis());
        BigDecimal advance = a.getAdvanceAmount() == null ? BigDecimal.ZERO : a.getAdvanceAmount();

        try (Writer w = new Writer()) {
            w.text(w.bold, 18, company);
            if (address != null && !address.isBlank()) w.text(w.body, 10, address);
            w.gap(14);
            w.text(w.bold, 15, "PUBLISHING & ROYALTY AGREEMENT");
            w.text(w.body, 10, "Agreement No. " + a.getAgreementNumber() + "    Status: " + statusLine(a));
            if (a.getAuthorSignedAt() == null) {
                w.text(w.bold, 10, "DRAFT - not binding until signed by the author and activated by the publisher.");
            }
            w.gap(10);

            w.heading("1. Parties");
            w.para("This agreement is made between " + company + " (\"the Publisher\") and " + authorName
                    + author.map(x -> x.email() == null ? "" : " (" + x.email() + ")").orElse("")
                    + " (\"the Author\").");

            w.heading("2. The Work");
            w.para("The book \"" + bookTitle + "\""
                    + book.map(b -> b.isbn() == null ? "" : ", ISBN " + b.isbn()).orElse("")
                    + book.map(b -> b.listPrice() == null ? "" : ", list price " + currency + " " + money(b.listPrice())).orElse("")
                    + " (\"the Work\").");

            w.heading("3. Commercial terms");
            w.row("Royalty rate", standardRate + " of " + (listPrice ? "the list price" : "net sales"));
            w.row("Bookstore (wholesale) rate", wholesaleRate);
            w.row("Royalty basis", listPrice ? "List price x units sold" : "Net sales (sale amount less discount)");
            w.row("Advance", currency + " " + money(advance));
            w.row("Royalty statements", frequency(a.getPaymentFrequency()));
            w.row("Effective from", date(a.getEffectiveDate()));
            w.row("Expires", a.getExpiryDate() == null ? "No fixed end date" : date(a.getExpiryDate()));
            w.gap(4);

            w.heading("4. How royalties are calculated");
            w.para("4.1 Royalties are earned only on completed sales of the Work during the term of this agreement.");
            w.para("4.2 For each sale the royalty is the royalty basis multiplied by the applicable rate. Sales to bookstores"
                    + " use the bookstore (wholesale) rate; all other sales use the royalty rate.");
            w.para("4.3 Returned copies earn no royalty and are listed on the statement for the period.");
            w.para("4.4 Agreed deductions for a period reduce the royalty basis for that period.");

            w.heading("5. Advance");
            w.para(advance.signum() > 0
                    ? "5.1 The advance of " + currency + " " + money(advance) + " is recouped from royalties earned before any"
                    + " royalty is paid. The advance is not repayable by the Author if royalties never cover it."
                    : "5.1 No advance is payable under this agreement.");

            w.heading("6. Statements and payment");
            w.para("6.1 The Publisher issues a royalty statement " + frequencyAdverb(a.getPaymentFrequency())
                    + " showing every sale line, return, deduction and the amount payable.");
            BigDecimal threshold = settingsService.royaltyPaymentThreshold();
            w.para("6.2 Approved amounts are paid to the bank account the Author keeps in the author portal."
                    + (threshold != null && threshold.signum() > 0
                    ? " Amounts below " + currency + " " + money(threshold) + " are carried forward to the next statement."
                    : ""));
            w.para("6.3 The Author may raise any query on a statement with the Publisher's finance team.");

            w.heading("7. Term");
            w.para("7.1 This agreement takes effect when the Author has signed it and the Publisher has activated it, and"
                    + " covers sales from " + date(a.getEffectiveDate())
                    + (a.getExpiryDate() == null ? " until it is ended by the Publisher." : " to " + date(a.getExpiryDate()) + "."));
            w.para("7.2 Changes to these terms require a revised agreement signed by the Author.");

            w.gap(10);
            w.heading("Signatures");
            w.row("For the Author", authorName);
            w.row("Signed electronically", a.getAuthorSignedAt() == null ? "Not yet signed" : stamp(a.getAuthorSignedAt()));
            w.row("For the Publisher", company);
            w.row("Sent to the author", a.getSentToAuthorAt() == null ? "Not yet sent" : stamp(a.getSentToAuthorAt()));
            w.row("Status", statusLine(a));
            w.gap(14);
            w.text(w.body, 8, "Generated " + stamp(LocalDateTime.now()) + " from the " + company + " publishing system.");
            return w.finish();
        } catch (IOException e) {
            throw new IllegalStateException("Could not build the agreement PDF: " + e.getMessage(), e);
        }
    }

    private static String statusLine(RoyaltyAgreement a) {
        if ("ACTIVE".equals(a.getStatus())) return "Active";
        if ("EXPIRED".equals(a.getStatus())) return "Expired";
        if (a.getAuthorSignedAt() != null) return "Signed, awaiting activation";
        return a.getSentToAuthorAt() != null ? "Sent to the author for signature" : "Draft";
    }

    private static String frequency(String f) {
        if ("ANNUAL".equals(f)) return "Annually";
        if ("BIANNUAL".equals(f)) return "Twice a year";
        return "Quarterly";
    }

    private static String frequencyAdverb(String f) {
        if ("ANNUAL".equals(f)) return "once a year";
        if ("BIANNUAL".equals(f)) return "twice a year";
        return "every quarter";
    }

    private static String pct(BigDecimal v) {
        return v == null ? "-" : v.stripTrailingZeros().toPlainString() + "%";
    }

    private static String money(BigDecimal v) {
        return v == null ? "0.00" : String.format("%,.2f", v);
    }

    private static String date(LocalDate d) {
        return d == null ? "-" : d.format(DATE);
    }

    private static String stamp(LocalDateTime t) {
        return t.format(STAMP);
    }

    private static String orDefault(String s, String fallback) {
        return s == null || s.isBlank() ? fallback : s;
    }

    /** Writes wrapped lines top to bottom, starting a new A4 page when one is full. */
    private static final class Writer implements AutoCloseable {

        final PDType1Font bold = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
        final PDType1Font body = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
        private final PDDocument doc = new PDDocument();
        private PDPageContentStream cs;
        private float y;

        Writer() throws IOException {
            newPage();
        }

        private void newPage() throws IOException {
            if (cs != null) cs.close();
            PDPage page = new PDPage(PDRectangle.A4);
            doc.addPage(page);
            cs = new PDPageContentStream(doc, page);
            y = page.getMediaBox().getHeight() - MARGIN;
        }

        void gap(float h) {
            y -= h;
        }

        void heading(String s) throws IOException {
            gap(6);
            text(bold, 12, s);
            gap(2);
        }

        void para(String s) throws IOException {
            text(body, 10, s);
            gap(3);
        }

        /** A label on the left and its value, wrapped, on the right. */
        void row(String label, String value) throws IOException {
            float labelWidth = 170;
            List<String> lines = wrap(body, 10, sanitize(value), WIDTH - labelWidth);
            ensure(lines.size() * 14f);
            show(bold, 10, MARGIN, label);
            for (String line : lines) {
                show(body, 10, MARGIN + labelWidth, line);
                y -= 14;
            }
        }

        void text(PDType1Font font, float size, String s) throws IOException {
            for (String line : wrap(font, size, sanitize(s), WIDTH)) {
                ensure(size + 4);
                show(font, size, MARGIN, line);
                y -= size + 4;
            }
        }

        private void ensure(float h) throws IOException {
            if (y - h < MARGIN) newPage();
        }

        private void show(PDType1Font font, float size, float x, String line) throws IOException {
            cs.beginText();
            cs.setFont(font, size);
            cs.newLineAtOffset(x, y - size);
            cs.showText(line);
            cs.endText();
        }

        byte[] finish() throws IOException {
            cs.close();
            cs = null;
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            doc.save(out);
            return out.toByteArray();
        }

        @Override
        public void close() throws IOException {
            if (cs != null) cs.close();
            doc.close();
        }

        private static List<String> wrap(PDType1Font font, float size, String s, float width) throws IOException {
            List<String> lines = new ArrayList<>();
            StringBuilder line = new StringBuilder();
            for (String word : s.split(" ")) {
                String candidate = line.length() == 0 ? word : line + " " + word;
                if (font.getStringWidth(candidate) / 1000 * size > width && line.length() > 0) {
                    lines.add(line.toString());
                    line = new StringBuilder(word);
                } else {
                    line = new StringBuilder(candidate);
                }
            }
            lines.add(line.toString());
            return lines;
        }

        /** Type 1 fonts are WinAnsi only: replace what they cannot encode. */
        private static String sanitize(String s) {
            if (s == null) return "";
            StringBuilder b = new StringBuilder(s.length());
            for (char c : s.toCharArray()) {
                if (c >= 32 && c < 127) b.append(c);
                else if (c == '–' || c == '—') b.append('-');
                else if (c == '\n' || c == '\r' || c == '\t') b.append(' ');
                else b.append('?');
            }
            return b.toString();
        }
    }
}
