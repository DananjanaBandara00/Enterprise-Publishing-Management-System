package com.epms.service;

import com.epms.dto.request.InvoicePaymentRequest;
import com.epms.dto.request.InvoiceRequest;
import com.epms.dto.response.InvoiceDetail;
import com.epms.entity.CustomerOrder;
import com.epms.entity.CustomerOrderItem;
import com.epms.entity.FinancialInvoice;
import com.epms.entity.PublishedBook;
import com.epms.entity.User;
import com.epms.exception.BusinessRuleException;
import com.epms.repository.CustomerOrderItemRepository;
import com.epms.repository.PublishedBookRepository;
import com.epms.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Invoices for checkout orders. Cash on delivery: issued when sales approves the
 * order and paid (CASH) on delivery. Card: issued and paid (CARD) at checkout.
 * Either way the customer is e-mailed the invoice once it is PAID.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class OrderInvoicing {

    private final FinanceService financeService;
    private final CustomerOrderItemRepository itemRepository;
    private final PublishedBookRepository bookRepository;
    private final UserRepository userRepository;

    /** Creates and issues the order's invoice; returns the existing one if it already has one. */
    public InvoiceDetail issue(CustomerOrder o, Long userId) {
        return financeService.createOrderInvoice(o.getCustomerOrderId(), paymentOption(o), request(o, null), userId);
    }

    /** Card checkout: invoice issued and paid in full straight away (test card gateway). */
    public InvoiceDetail payByCard(CustomerOrder o, String cardBrand, String cardLast4, Long userId) {
        InvoiceDetail inv = financeService.createOrderInvoice(o.getCustomerOrderId(), paymentOption(o),
                request(o, cardLast4 == null ? null : cardLabel(cardBrand, cardLast4)), userId);
        if (!FinancialInvoice.ISSUED.equals(inv.getInvoice().getStatus())) {
            return inv; // already paid, or a zero-total draft with nothing to charge
        }
        InvoicePaymentRequest p = new InvoicePaymentRequest();
        p.setAmount(inv.getInvoice().getOutstanding());
        p.setPaymentDate(LocalDate.now());
        p.setPaymentMethod("CARD");
        p.setReference("CARD-" + o.getOrderNumber());
        return financeService.recordPayment(inv.getInvoice().getInvoiceId(), p, userId);
    }

    /** Cash on delivery: the cash collected settles whatever is still owed. */
    public void collectCashOnDelivery(CustomerOrder o, Long userId) {
        issue(o, userId);
        financeService.settleOrderInvoice(o.getCustomerOrderId(), o.getOrderNumber(), userId);
    }

    /** Cancels the invoice; for a card-paid order the payment is refunded and the order marked REFUNDED. */
    public void cancel(CustomerOrder o, String reason, Long userId) {
        if (financeService.cancelOrderInvoice(o.getCustomerOrderId(), o.getOrderNumber(), reason, userId)) {
            o.setPaymentStatus("REFUNDED");
        }
    }

    private static String paymentOption(CustomerOrder o) {
        return CustomerOrder.PAY_CARD.equals(o.getPaymentMethod())
                ? FinancialInvoice.OPTION_CARD : FinancialInvoice.OPTION_CASH_ON_DELIVERY;
    }

    /** One line per item at the price captured at checkout. */
    private InvoiceRequest request(CustomerOrder o, String card) {
        User customer = o.getCustomerId() == null ? null : userRepository.findById(o.getCustomerId()).orElse(null);
        String name = o.isWholesale() && o.getBusinessName() != null && !o.getBusinessName().isBlank()
                ? o.getBusinessName()
                : customer != null && customer.getFullName() != null && !customer.getFullName().isBlank()
                        ? customer.getFullName()
                        : o.getRecipientName();
        Map<Long, String> titles = bookRepository.findAll().stream()
                .collect(Collectors.toMap(PublishedBook::getBookId, PublishedBook::getTitle, (a, b) -> a));
        List<InvoiceRequest.Line> lines = new ArrayList<>();
        for (CustomerOrderItem i : itemRepository.findByCustomerOrderId(o.getCustomerOrderId())) {
            InvoiceRequest.Line line = new InvoiceRequest.Line();
            line.setDescription(truncate(titles.getOrDefault(i.getBookId(), "Book #" + i.getBookId()), 255));
            line.setQuantity(i.getQuantity());
            line.setUnitPrice(i.getUnitPrice());
            lines.add(line);
        }
        if (lines.isEmpty()) {
            throw new BusinessRuleException("Order " + o.getOrderNumber() + " has no items to invoice");
        }
        InvoiceRequest r = new InvoiceRequest();
        r.setCustomerName(truncate(name == null || name.isBlank() ? "Customer " + o.getOrderNumber() : name.trim(), 150));
        r.setCustomerEmail(customer == null ? null : customer.getEmail());
        r.setCustomerAddress(truncate(o.getShippingAddress(), 255));
        r.setInvoiceDate(LocalDate.now());
        r.setNotes(CustomerOrder.PAY_CARD.equals(o.getPaymentMethod())
                ? "Order " + o.getOrderNumber() + ", paid by card at checkout" + (card == null ? "" : " (" + card + ")") + "."
                : "Order " + o.getOrderNumber() + ", cash on delivery.");
        r.setLines(lines);
        return r;
    }

    private static String cardLabel(String brand, String last4) {
        String b = brand == null || brand.isBlank() || "CARD".equalsIgnoreCase(brand) ? "Card" : brand.trim();
        return b + " ending " + last4;
    }

    private static String truncate(String s, int max) {
        return s == null || s.length() <= max ? s : s.substring(0, max);
    }
}
