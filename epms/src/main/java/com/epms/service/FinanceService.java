package com.epms.service;

import com.epms.dto.request.ExpenseRequest;
import com.epms.dto.request.InvoicePaymentRequest;
import com.epms.dto.request.InvoiceRequest;
import com.epms.dto.response.InvoiceDetail;
import com.epms.dto.response.RevenueSummaryResponse;
import com.epms.entity.Expense;
import com.epms.entity.FinancialInvoice;
import com.epms.entity.FinancialPayment;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;

public interface FinanceService {

    List<String> EXPENSE_CATEGORIES = List.of("PRINTING", "SALARIES", "MARKETING", "RENT", "UTILITIES", "ROYALTY", "OTHER");

    // --- Expenses (US36): RECORDED -> (REVIEWED ->) APPROVED -> POSTED, or REJECTED ---

    List<Expense> getExpenses(String status);

    Expense getExpense(Long id);

    Expense createExpense(ExpenseRequest request, Long createdBy);

    /** Only RECORDED (pending) expenses can be edited. */
    Expense updateExpense(Long id, ExpenseRequest request);

    /** Only RECORDED (pending) expenses can be deleted. */
    void deleteExpense(Long id);

    Expense reviewExpense(Long id, Long reviewedBy);

    Expense approveExpense(Long id, Long approvedBy);

    Expense rejectExpense(Long id, String reason, Long rejectedBy);

    Expense postExpense(Long id, Long userId);

    /** PDF, JPG or PNG up to 5 MB; replaces any earlier receipt. */
    Expense uploadReceipt(Long id, MultipartFile file);

    Path receiptPath(Long id);

    // --- Invoices (US37) and payments (US38) ---

    List<FinancialInvoice> getInvoices(String status);

    InvoiceDetail getInvoiceDetail(Long id);

    FinancialInvoice getInvoice(Long id);

    /** Creates a DRAFT invoice; the number and currency are fixed at creation. */
    InvoiceDetail createInvoice(InvoiceRequest request, Long createdBy);

    /** Only DRAFT invoices can be edited. */
    InvoiceDetail updateInvoice(Long id, InvoiceRequest request);

    InvoiceDetail issueInvoice(Long id, Long userId);

    /** DRAFT or ISSUED invoices with no payments can be cancelled; the number is never reused. */
    InvoiceDetail cancelInvoice(Long id, String reason, Long userId);

    /** Creates a DRAFT invoice from a reference; supported: SALE (a sales record). */
    InvoiceDetail generateInvoice(String referenceType, Long referenceId, Long createdBy);

    /**
     * Creates and immediately issues the invoice for an approved customer order
     * (reference type ORDER). Returns the existing non-cancelled invoice if the
     * order already has one, so approving twice never double-invoices.
     *
     * @param paymentOption CASH_ON_DELIVERY or CARD, shown on the invoice
     */
    InvoiceDetail createOrderInvoice(Long customerOrderId, String paymentOption, InvoiceRequest request, Long createdBy);

    /**
     * Cancels the order's invoice when the order is cancelled or rejected. A card-paid invoice is
     * refunded (its payments are marked REFUNDED); a cash payment already recorded blocks it.
     *
     * @return true when a card payment was refunded
     */
    boolean cancelOrderInvoice(Long customerOrderId, String orderNumber, String reason, Long userId);

    /**
     * Cash on delivery: records a CASH payment for whatever is still outstanding on the
     * order's invoice, so it becomes PAID. Does nothing if it is already fully paid.
     */
    void settleOrderInvoice(Long customerOrderId, String orderNumber, Long userId);

    /** Records a payment; cannot exceed the outstanding balance; reference must be unique. */
    InvoiceDetail recordPayment(Long invoiceId, InvoicePaymentRequest request, Long userId);

    List<FinancialPayment> getPayments();

    FinancialPayment getPayment(Long id);

    /**
     * Revenue monitoring (US35): aggregates COMPLETED sales received from
     * Epic 3 for the period, net of discounts. Null bounds default to the
     * trailing 12 months; channel / book / category filters are optional.
     */
    RevenueSummaryResponse getRevenue(LocalDate from, LocalDate to, String channel, Long bookId, Long categoryId);

    default RevenueSummaryResponse getRevenue(LocalDate from, LocalDate to) {
        return getRevenue(from, to, null, null, null);
    }
}
