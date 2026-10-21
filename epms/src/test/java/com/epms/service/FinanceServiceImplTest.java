package com.epms.service;

import com.epms.contracts.BookCatalog;
import com.epms.dto.request.ExpenseRequest;
import com.epms.dto.request.InvoicePaymentRequest;
import com.epms.dto.request.InvoiceRequest;
import com.epms.entity.Expense;
import com.epms.entity.FinancialInvoice;
import com.epms.exception.BusinessRuleException;
import com.epms.repository.ExpenseRepository;
import com.epms.repository.FinancialInvoiceLineRepository;
import com.epms.repository.FinancialInvoiceRepository;
import com.epms.repository.FinancialPaymentRepository;
import com.epms.repository.SalesRecordRepository;
import com.epms.service.impl.FinanceServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** US36 - US38: expenses, invoices and payments. */
@ExtendWith(MockitoExtension.class)
class FinanceServiceImplTest {

    @Mock ExpenseRepository expenseRepository;
    @Mock FinancialInvoiceRepository invoiceRepository;
    @Mock FinancialInvoiceLineRepository lineRepository;
    @Mock FinancialPaymentRepository paymentRepository;
    @Mock SalesRecordRepository salesRecordRepository;
    @Mock SalesDataService salesDataService;
    @Mock BookCatalog bookCatalog;
    @Mock SettingsService settingsService;
    @Mock DocumentNumberService documentNumberService;
    @Mock AuditService auditService;
    @Mock EmailService emailService;

    @InjectMocks FinanceServiceImpl service;

    @BeforeEach
    void setUp() {
        lenient().when(settingsService.invoicePrefix()).thenReturn("INV-");
        lenient().when(settingsService.currency()).thenReturn("LKR");
        lenient().when(invoiceRepository.save(any(FinancialInvoice.class))).thenAnswer(inv -> {
            FinancialInvoice i = inv.getArgument(0);
            if (i.getInvoiceId() == null) i.setInvoiceId(1L);
            return i;
        });
        lenient().when(lineRepository.findByInvoiceIdOrderByLineNo(any())).thenReturn(List.of());
        lenient().when(paymentRepository.findByInvoiceIdOrderByPaymentDateAsc(any())).thenReturn(List.of());
    }

    @Test
    void newInvoiceGetsGeneratedNumberAndNoTax() {
        when(documentNumberService.next("INV-", "INVOICE", LocalDate.now().getYear())).thenReturn("INV-2026-00042");

        FinancialInvoice inv = service.createInvoice(invoiceRequest(), 9L).getInvoice();

        assertThat(inv.getInvoiceNumber()).isEqualTo("INV-2026-00042");
        assertThat(inv.getStatus()).isEqualTo("DRAFT");
        // 2 x 1000 + 500 = 2500; no tax, so the total is the subtotal
        assertThat(inv.getAmount()).isEqualByComparingTo("2500.00");
        assertThat(inv.getTaxAmount()).isEqualByComparingTo("0");
        assertThat(inv.getTotalAmount()).isEqualByComparingTo("2500.00");
    }

    @Test
    void approvedOrderInvoiceIsIssuedImmediatelyAndLinkedToTheOrder() {
        when(invoiceRepository.findFirstByReferenceTypeAndReferenceIdAndStatusNot("ORDER", 7L, "CANCELLED"))
                .thenReturn(Optional.empty());
        when(documentNumberService.next("INV-", "INVOICE", LocalDate.now().getYear())).thenReturn("INV-2026-00043");

        FinancialInvoice inv = service.createOrderInvoice(7L, "CASH_ON_DELIVERY", invoiceRequest(), 9L).getInvoice();

        assertThat(inv.getStatus()).isEqualTo("ISSUED");
        assertThat(inv.getIssuedAt()).isNotNull();
        assertThat(inv.getReferenceType()).isEqualTo("ORDER");
        assertThat(inv.getReferenceId()).isEqualTo(7L);
        assertThat(inv.getTotalAmount()).isEqualByComparingTo("2500.00");
    }

    @Test
    void deliveringAnOrderRecordsCashForTheOutstandingBalance() {
        FinancialInvoice issued = invoice("ISSUED", "1000.00", "300.00");
        when(invoiceRepository.findFirstByReferenceTypeAndReferenceIdAndStatusNot("ORDER", 7L, "CANCELLED"))
                .thenReturn(Optional.of(issued));
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(issued));

        service.settleOrderInvoice(7L, "CO-2026-00007", 9L);

        assertThat(issued.getStatus()).isEqualTo("PAID");
        assertThat(issued.getAmountPaid()).isEqualByComparingTo("1000.00");
        verify(emailService).sendInvoicePaid(org.mockito.ArgumentMatchers.argThat(d -> d.getInvoice() == issued));
        verify(paymentRepository).saveAndFlush(org.mockito.ArgumentMatchers.argThat(p ->
                "COD-CO-2026-00007".equals(p.getReferenceNumber()) && "CASH".equals(p.getPaymentMethod())
                        && p.getAmount().compareTo(new BigDecimal("700.00")) == 0));
    }

    @Test
    void partialPaymentDoesNotEmailTheInvoice() {
        FinancialInvoice issued = invoice("ISSUED", "1000.00", "0");
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(issued));

        service.recordPayment(1L, payment("400.00", "R-9"), 9L);

        assertThat(issued.getStatus()).isEqualTo("PARTIALLY_PAID");
        verify(emailService, never()).sendInvoicePaid(any());
    }

    @Test
    void deliveringAFullyPaidOrderRecordsNothing() {
        when(invoiceRepository.findFirstByReferenceTypeAndReferenceIdAndStatusNot("ORDER", 7L, "CANCELLED"))
                .thenReturn(Optional.of(invoice("PAID", "1000.00", "1000.00")));

        service.settleOrderInvoice(7L, "CO-2026-00007", 9L);

        verify(paymentRepository, never()).saveAndFlush(any());
    }

    @Test
    void approvingAnOrderTwiceDoesNotCreateASecondInvoice() {
        FinancialInvoice existing = invoice("ISSUED", "1000.00", "0");
        when(invoiceRepository.findFirstByReferenceTypeAndReferenceIdAndStatusNot("ORDER", 7L, "CANCELLED"))
                .thenReturn(Optional.of(existing));

        assertThat(service.createOrderInvoice(7L, "CASH_ON_DELIVERY", invoiceRequest(), 9L).getInvoice()).isSameAs(existing);
        verify(documentNumberService, never()).next(any(), any(), org.mockito.ArgumentMatchers.anyInt());
    }

    @Test
    void cancellingACardPaidOrderRefundsTheCardPayment() {
        FinancialInvoice paid = invoice("PAID", "1000.00", "1000.00");
        paid.setPaymentOption("CARD");
        com.epms.entity.FinancialPayment card = new com.epms.entity.FinancialPayment();
        card.setStatus("COMPLETED");
        when(invoiceRepository.findFirstByReferenceTypeAndReferenceIdAndStatusNot("ORDER", 7L, "CANCELLED"))
                .thenReturn(Optional.of(paid));
        when(paymentRepository.findByInvoiceIdOrderByPaymentDateAsc(1L)).thenReturn(List.of(card));

        assertThat(service.cancelOrderInvoice(7L, "CO-2026-00007", "out of stock", 9L)).isTrue();

        assertThat(paid.getStatus()).isEqualTo("CANCELLED");
        assertThat(card.getStatus()).isEqualTo("REFUNDED");
        assertThat(paid.getCancelReason()).contains("refunded");
    }

    @Test
    void rejectingAnOrderWithPaymentsOnItsInvoiceIsRefused() {
        when(invoiceRepository.findFirstByReferenceTypeAndReferenceIdAndStatusNot("ORDER", 7L, "CANCELLED"))
                .thenReturn(Optional.of(invoice("PARTIALLY_PAID", "1000.00", "200.00")));

        assertThatThrownBy(() -> service.cancelOrderInvoice(7L, "CO-2026-00007", "out of stock", 9L))
                .isInstanceOf(BusinessRuleException.class)
                .hasMessageContaining("already has payments");
    }

    @Test
    void onlyDraftInvoicesCanBeEdited() {
        FinancialInvoice issued = invoice("ISSUED", "1000.00", "0");
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(issued));

        assertThatThrownBy(() -> service.updateInvoice(1L, invoiceRequest()))
                .isInstanceOf(BusinessRuleException.class)
                .hasMessageContaining("only DRAFT");
    }

    @Test
    void paymentCannotExceedTheOutstandingBalance() {
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(invoice("ISSUED", "1000.00", "600.00")));

        assertThatThrownBy(() -> service.recordPayment(1L, payment("400.01", "R-1"), 9L))
                .isInstanceOf(BusinessRuleException.class)
                .hasMessageContaining("exceeds the outstanding balance 400.00");
        verify(paymentRepository, never()).saveAndFlush(any());
    }

    @Test
    void duplicatePaymentReferenceIsRejected() {
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(invoice("ISSUED", "1000.00", "0")));
        when(paymentRepository.existsByReferenceNumber("R-1")).thenReturn(true);

        assertThatThrownBy(() -> service.recordPayment(1L, payment("100.00", "R-1"), 9L))
                .isInstanceOf(BusinessRuleException.class)
                .hasMessageContaining("already been used");
    }

    @Test
    void invoiceStatusFollowsPayments() {
        FinancialInvoice inv = invoice("ISSUED", "1000.00", "0");
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(inv));

        service.recordPayment(1L, payment("400.00", "R-1"), 9L);
        assertThat(inv.getStatus()).isEqualTo("PARTIALLY_PAID");

        service.recordPayment(1L, payment("600.00", "R-2"), 9L);
        assertThat(inv.getStatus()).isEqualTo("PAID");
        assertThat(inv.getOutstanding()).isEqualByComparingTo("0");
    }

    @Test
    void paymentsOnlyAgainstIssuedInvoices() {
        when(invoiceRepository.findById(1L)).thenReturn(Optional.of(invoice("DRAFT", "1000.00", "0")));
        assertThatThrownBy(() -> service.recordPayment(1L, payment("10.00", "R-1"), 9L))
                .isInstanceOf(BusinessRuleException.class);
    }

    @Test
    void onlyPendingExpensesCanBeEditedOrDeleted() {
        Expense approved = new Expense();
        approved.setExpenseId(5L);
        approved.setStatus("APPROVED");
        when(expenseRepository.findById(5L)).thenReturn(Optional.of(approved));

        ExpenseRequest r = new ExpenseRequest();
        r.setCategory("RENT");
        r.setAmount(new BigDecimal("10.00"));
        r.setExpenseDate(LocalDate.now());

        assertThatThrownBy(() -> service.updateExpense(5L, r)).isInstanceOf(BusinessRuleException.class);
        assertThatThrownBy(() -> service.deleteExpense(5L)).isInstanceOf(BusinessRuleException.class);
        verify(expenseRepository, never()).delete(any());
    }

    @Test
    void rejectedExpenseKeepsItsReason() {
        Expense e = new Expense();
        e.setExpenseId(5L);
        e.setStatus("RECORDED");
        when(expenseRepository.findById(5L)).thenReturn(Optional.of(e));
        when(expenseRepository.save(any(Expense.class))).thenAnswer(inv -> inv.getArgument(0));

        Expense rejected = service.rejectExpense(5L, "No receipt", 9L);

        assertThat(rejected.getStatus()).isEqualTo("REJECTED");
        assertThat(rejected.getRejectionReason()).isEqualTo("No receipt");
    }

    private static InvoiceRequest invoiceRequest() {
        InvoiceRequest.Line a = new InvoiceRequest.Line();
        a.setDescription("Books");
        a.setQuantity(2);
        a.setUnitPrice(new BigDecimal("1000.00"));
        InvoiceRequest.Line b = new InvoiceRequest.Line();
        b.setDescription("Delivery");
        b.setQuantity(1);
        b.setUnitPrice(new BigDecimal("500.00"));
        InvoiceRequest r = new InvoiceRequest();
        r.setCustomerName("Sarasavi");
        r.setLines(List.of(a, b));
        return r;
    }

    private static FinancialInvoice invoice(String status, String total, String paid) {
        FinancialInvoice i = new FinancialInvoice();
        i.setInvoiceId(1L);
        i.setInvoiceNumber("INV-2026-00001");
        i.setStatus(status);
        i.setTotalAmount(new BigDecimal(total));
        i.setAmountPaid(new BigDecimal(paid));
        return i;
    }

    private static InvoicePaymentRequest payment(String amount, String ref) {
        InvoicePaymentRequest p = new InvoicePaymentRequest();
        p.setAmount(new BigDecimal(amount));
        p.setPaymentDate(LocalDate.now());
        p.setPaymentMethod("CASH");
        p.setReference(ref);
        return p;
    }
}
