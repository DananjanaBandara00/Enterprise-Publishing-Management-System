package com.epms.service;

import com.epms.contracts.AuthorDirectory;
import com.epms.contracts.BookCatalog;
import com.epms.contracts.dto.AuthorDto;
import com.epms.contracts.dto.BookDto;
import com.epms.entity.RoyaltyAgreement;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

/** The agreement PDF carries the parties, the terms and the signature state. */
@ExtendWith(MockitoExtension.class)
class RoyaltyAgreementDocumentServiceTest {

    @Mock AuthorDirectory authorDirectory;
    @Mock BookCatalog bookCatalog;
    @Mock SettingsService settingsService;

    @InjectMocks RoyaltyAgreementDocumentService service;

    @Test
    void draftAgreementPdfShowsTermsAndThatItIsNotYetSigned() throws Exception {
        RoyaltyAgreement a = new RoyaltyAgreement();
        a.setRoyaltyAgreementId(7L);
        a.setAgreementNumber("RA-TEST01");
        a.setAuthorId(101L);
        a.setBookId(1L);
        a.setRoyaltyPercentage(new BigDecimal("12.50"));
        a.setWholesaleRoyaltyPercentage(new BigDecimal("8.00"));
        a.setAdvanceAmount(new BigDecimal("25000.00"));
        a.setEffectiveDate(LocalDate.of(2026, 1, 1));
        when(authorDirectory.findAuthor(101L)).thenReturn(Optional.of(new AuthorDto(101L, "Nimal Perera", "n@x.lk", 1L, "ACTIVE")));
        when(bookCatalog.findBook(1L)).thenReturn(Optional.of(new BookDto(1L, "Monsoon Letters", "978-0-00-000000-1", 101L,
                null, null, new BigDecimal("1850.00"), null, "PUBLISHED")));
        when(settingsService.companyName()).thenReturn("Reading Planet");
        when(settingsService.currency()).thenReturn("LKR");
        when(settingsService.royaltyPaymentThreshold()).thenReturn(new BigDecimal("1000"));

        byte[] pdf = service.pdf(a);

        String text;
        try (PDDocument doc = Loader.loadPDF(pdf)) {
            text = new PDFTextStripper().getText(doc);
        }
        assertThat(text).contains("PUBLISHING & ROYALTY AGREEMENT", "RA-TEST01", "Nimal Perera", "Monsoon Letters",
                "12.5%", "8%", "25,000.00", "Not yet signed", "DRAFT");
        assertThat(service.fileName(a)).isEqualTo("royalty-agreement-RA-TEST01.pdf");
    }
}
