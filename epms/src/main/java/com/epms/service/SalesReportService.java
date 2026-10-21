package com.epms.service;

import com.epms.entity.CustomerOrder;
import com.epms.entity.SalesRecord;
import com.epms.exception.InvalidRequestException;
import com.epms.repository.CustomerOrderRepository;
import com.epms.repository.SalesRecordRepository;
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
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Sales staff reports: retail (CUSTOMER channel) and wholesale (BOOKSTORE channel)
 * summaries, plus a simple PDF download.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SalesReportService {

    private static final DateTimeFormatter DAY = DateTimeFormatter.ISO_LOCAL_DATE;
    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final SalesRecordRepository salesRecordRepository;
    private final CustomerOrderRepository customerOrderRepository;

    public Map<String, Object> summary(LocalDate from, LocalDate to, String channel) {
        requireRange(from, to);
        String ch = normalizeChannel(channel);
        List<SalesRecord> all = salesRecordRepository
                .findByStatusAndSaleDateBetweenOrderBySaleDateDesc(SalesDataService.STATUS_COMPLETED, from, to);
        List<SalesRecord> filtered = all.stream()
                .filter(s -> ch == null || ch.equalsIgnoreCase(s.getChannel()))
                .toList();

        BigDecimal gross = BigDecimal.ZERO;
        BigDecimal discount = BigDecimal.ZERO;
        int units = 0;
        for (SalesRecord s : filtered) {
            gross = gross.add(nullSafe(s.getSaleAmount()));
            discount = discount.add(nullSafe(s.getDiscount()));
            units += s.getQuantity() == null ? 0 : s.getQuantity();
        }
        BigDecimal net = gross.subtract(discount);

        long pendingWholesale = customerOrderRepository.findByWholesaleTrueAndWholesaleStatusOrderByOrderDateDesc(
                CustomerOrder.WHOLESALE_PENDING).size();

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("from", from.toString());
        m.put("to", to.toString());
        m.put("channel", ch == null ? "ALL" : ch);
        m.put("lineCount", filtered.size());
        m.put("unitsSold", units);
        m.put("grossSales", money(gross));
        m.put("discount", money(discount));
        m.put("netRevenue", money(net));
        m.put("pendingWholesaleRequests", pendingWholesale);
        m.put("generatedAt", LocalDateTime.now().format(STAMP));

        Map<String, long[]> byChannel = new LinkedHashMap<>();
        for (SalesRecord s : all) {
            String key = s.getChannel() == null ? "UNKNOWN" : s.getChannel().toUpperCase(Locale.ROOT);
            long[] agg = byChannel.computeIfAbsent(key, k -> new long[2]);
            agg[0] += 1;
            agg[1] += s.getQuantity() == null ? 0 : s.getQuantity();
        }
        List<Map<String, Object>> channels = new ArrayList<>();
        for (Map.Entry<String, long[]> e : byChannel.entrySet()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("channel", e.getKey());
            row.put("lines", e.getValue()[0]);
            row.put("units", e.getValue()[1]);
            channels.add(row);
        }
        m.put("byChannel", channels);

        List<Map<String, Object>> lines = filtered.stream().limit(200).map(s -> {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("saleReference", s.getSaleReference());
            row.put("channel", s.getChannel());
            row.put("bookTitle", s.getBookTitle());
            row.put("quantity", s.getQuantity());
            row.put("unitPrice", money(s.getUnitPrice()));
            row.put("saleAmount", money(s.getSaleAmount()));
            row.put("discount", money(s.getDiscount()));
            row.put("net", money(s.getNetAmount()));
            row.put("saleDate", s.getSaleDate() == null ? null : s.getSaleDate().toString());
            return row;
        }).collect(Collectors.toList());
        m.put("lines", lines);
        return m;
    }

    public byte[] pdf(LocalDate from, LocalDate to, String channel) {
        Map<String, Object> data = summary(from, to, channel);
        try (PDDocument doc = new PDDocument(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            PDPage page = new PDPage(PDRectangle.A4);
            doc.addPage(page);
            PDType1Font titleFont = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
            PDType1Font bodyFont = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
            float margin = 40;
            float y = page.getMediaBox().getHeight() - margin;
            float leading = 14;

            try (PDPageContentStream cs = new PDPageContentStream(doc, page)) {
                y = write(cs, titleFont, 16, margin, y, "Reading Planet — Sales Report");
                y -= 6;
                y = write(cs, bodyFont, 11, margin, y,
                        "Period: " + data.get("from") + " to " + data.get("to")
                                + "   |   Channel: " + data.get("channel")
                                + "   |   Generated: " + data.get("generatedAt"));
                y -= 10;
                y = write(cs, titleFont, 12, margin, y, "Summary");
                y = write(cs, bodyFont, 11, margin, y, "Completed lines: " + data.get("lineCount"));
                y = write(cs, bodyFont, 11, margin, y, "Units sold: " + data.get("unitsSold"));
                y = write(cs, bodyFont, 11, margin, y, "Gross sales: LKR " + data.get("grossSales"));
                y = write(cs, bodyFont, 11, margin, y, "Discounts: LKR " + data.get("discount"));
                y = write(cs, bodyFont, 11, margin, y, "Net revenue: LKR " + data.get("netRevenue"));
                y = write(cs, bodyFont, 11, margin, y,
                        "Pending wholesale requests (checkout): " + data.get("pendingWholesaleRequests"));
                y -= 10;
                y = write(cs, titleFont, 12, margin, y, "By channel (completed sales in period)");
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> channels = (List<Map<String, Object>>) data.get("byChannel");
                if (channels == null || channels.isEmpty()) {
                    y = write(cs, bodyFont, 10, margin, y, "No completed sales in this period.");
                } else {
                    for (Map<String, Object> row : channels) {
                        String label = "CUSTOMER".equals(row.get("channel")) ? "Retail (CUSTOMER)"
                                : "BOOKSTORE".equals(row.get("channel")) ? "Wholesale (BOOKSTORE)"
                                : String.valueOf(row.get("channel"));
                        y = write(cs, bodyFont, 10, margin, y,
                                label + " — lines: " + row.get("lines") + ", units: " + row.get("units"));
                        if (y < 80) break;
                    }
                }
                y -= 10;
                y = write(cs, titleFont, 12, margin, y, "Sale lines (up to 40 shown)");
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> lines = (List<Map<String, Object>>) data.get("lines");
                int shown = 0;
                if (lines != null) {
                    for (Map<String, Object> line : lines) {
                        if (shown >= 40 || y < 60) break;
                        String row = String.valueOf(line.get("saleDate")) + "  "
                                + line.get("channel") + "  "
                                + truncate(String.valueOf(line.get("bookTitle")), 28) + "  x"
                                + line.get("quantity") + "  LKR " + line.get("net")
                                + "  (" + line.get("saleReference") + ")";
                        y = write(cs, bodyFont, 9, margin, y, row);
                        shown++;
                    }
                }
                if (shown == 0) {
                    write(cs, bodyFont, 10, margin, y, "No lines to display.");
                }
            }
            doc.save(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new IllegalStateException("Could not build sales PDF: " + e.getMessage(), e);
        }
    }

    private float write(PDPageContentStream cs, PDType1Font font, float size, float x, float y, String text)
            throws IOException {
        cs.beginText();
        cs.setFont(font, size);
        cs.newLineAtOffset(x, y);
        cs.showText(sanitize(text));
        cs.endText();
        return y - (size + 4);
    }

    private static String sanitize(String s) {
        if (s == null) return "";
        // WinAnsi-safe: drop characters PDF Type1 fonts cannot encode
        StringBuilder b = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c >= 32 && c < 127) b.append(c);
            else if (c == '\u2013' || c == '\u2014') b.append('-');
            else b.append('?');
        }
        return b.toString();
    }

    private static String truncate(String s, int max) {
        if (s == null) return "";
        return s.length() <= max ? s : s.substring(0, max - 1) + "…";
    }

    private static void requireRange(LocalDate from, LocalDate to) {
        if (from == null || to == null) {
            throw new InvalidRequestException("Both from and to dates are required");
        }
        if (to.isBefore(from)) {
            throw new InvalidRequestException("The end date cannot be before the start date");
        }
        if (from.plusYears(2).isBefore(to)) {
            throw new InvalidRequestException("Report range cannot exceed 2 years");
        }
    }

    /** null = all channels; CUSTOMER / BOOKSTORE otherwise. */
    private static String normalizeChannel(String channel) {
        if (channel == null || channel.isBlank() || "ALL".equalsIgnoreCase(channel)) return null;
        String u = channel.trim().toUpperCase(Locale.ROOT);
        if ("RETAIL".equals(u) || "CUSTOMER".equals(u)) return "CUSTOMER";
        if ("WHOLESALE".equals(u) || "BOOKSTORE".equals(u)) return "BOOKSTORE";
        throw new InvalidRequestException("Channel must be ALL, RETAIL/CUSTOMER, or WHOLESALE/BOOKSTORE");
    }

    private static BigDecimal nullSafe(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }

    private static String money(BigDecimal v) {
        return nullSafe(v).setScale(2, RoundingMode.HALF_UP).toPlainString();
    }
}
