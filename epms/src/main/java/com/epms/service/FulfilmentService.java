package com.epms.service;

import com.epms.dto.request.BookstoreOrderRequest;
import com.epms.dto.request.BookstoreRequest;
import com.epms.entity.Bookstore;
import com.epms.entity.BookstoreOrder;
import com.epms.entity.BookstoreOrderItem;
import com.epms.entity.CustomerOrder;
import com.epms.entity.CustomerOrderItem;
import com.epms.entity.PublishedBook;
import com.epms.entity.Shipment;
import com.epms.exception.BusinessRuleException;
import com.epms.exception.InvalidRequestException;
import com.epms.exception.ResourceNotFoundException;
import com.epms.repository.BookstoreOrderItemRepository;
import com.epms.repository.BookstoreOrderRepository;
import com.epms.repository.BookstoreRepository;
import com.epms.repository.CustomerOrderItemRepository;
import com.epms.repository.CustomerOrderRepository;
import com.epms.repository.PublishedBookRepository;
import com.epms.repository.ShipmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Epic 3: warehouse fulfilment of customer orders (US28) and wholesale
 * bookstore orders with sales-manager approval (US30). Delivered lines are
 * passed to Epic 4 as completed sales.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class FulfilmentService {

    private static final BigDecimal TRADE_PRICE_FACTOR = new BigDecimal("0.75");

    /** Minimum total books required for a wholesale / bookstore order. */
    public static final int MIN_WHOLESALE_QUANTITY = 10;

    private final CustomerOrderRepository customerOrderRepository;
    private final CustomerOrderItemRepository customerItemRepository;
    private final ShipmentRepository shipmentRepository;
    private final BookstoreRepository bookstoreRepository;
    private final BookstoreOrderRepository bookstoreOrderRepository;
    private final BookstoreOrderItemRepository bookstoreItemRepository;
    private final PublishedBookRepository bookRepository;
    private final InventoryService inventoryService;
    private final StoreService storeService;
    private final SalesFeed salesFeed;
    private final DocumentNumberService numbers;
    private final UserNames names;
    private final AuditService auditService;
    private final EmailService emailService;
    private final OrderInvoicing orderInvoicing;

    // ===================== customer orders (US28) =====================

    @Transactional(readOnly = true)
    public List<Map<String, Object>> customerOrders(String status) {
        return customerOrders(status, "ALL");
    }

    /**
     * @param channel ALL | RETAIL | WHOLESALE — separates online retail vs wholesale checkout orders
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> customerOrders(String status, String channel) {
        String ch = channel == null || channel.isBlank() ? "ALL" : channel.trim().toUpperCase();
        boolean hasStatus = status != null && !status.isBlank();
        List<String> statuses = hasStatus ? List.of(status.trim().toUpperCase()) : List.of();
        List<CustomerOrder> orders;
        if ("RETAIL".equals(ch)) {
            orders = hasStatus
                    ? customerOrderRepository.findByWholesaleFalseAndOrderStatusInOrderByOrderDateAsc(statuses)
                    : customerOrderRepository.findByWholesaleFalseOrderByOrderDateDesc();
        } else if ("WHOLESALE".equals(ch)) {
            orders = hasStatus
                    ? customerOrderRepository.findByWholesaleTrueAndOrderStatusInOrderByOrderDateAsc(statuses)
                    : customerOrderRepository.findByWholesaleTrueOrderByOrderDateDesc();
        } else {
            orders = hasStatus
                    ? customerOrderRepository.findByOrderStatusInOrderByOrderDateAsc(statuses)
                    : customerOrderRepository.findAllByOrderByOrderDateDesc();
        }
        return orders.stream().map(storeService::orderView).toList();
    }

    public Map<String, Object> pack(Long orderId, Long userId) {
        CustomerOrder o = customerOrder(orderId);
        requireStatus(o.getOrderStatus(), CustomerOrder.CONFIRMED, "pack", o.getOrderNumber());
        // Wholesale checkout orders must be approved by sales before warehouse packs them
        if (o.isWholesale() || (o.getShippingAddress() != null && o.getShippingAddress().startsWith("[WHOLESALE"))) {
            if (!CustomerOrder.WHOLESALE_APPROVED.equals(o.getWholesaleStatus())) {
                throw new BusinessRuleException(
                        "Order " + o.getOrderNumber() + " is a wholesale request and must be confirmed by sales before packing");
            }
        }
        o.setOrderStatus(CustomerOrder.PACKED);
        o.setPackedAt(LocalDateTime.now());
        return storeService.orderView(customerOrderRepository.save(o));
    }

    public Map<String, Object> dispatch(Long orderId, String provider, String trackingNumber, BigDecimal cost, Long userId) {
        CustomerOrder o = customerOrder(orderId);
        requireStatus(o.getOrderStatus(), CustomerOrder.PACKED, "dispatch", o.getOrderNumber());
        // Courier, tracking number and cost are optional
        String providerVal = provider == null || provider.isBlank() ? null : provider.trim();
        String trackingVal = trackingNumber == null || trackingNumber.isBlank() ? null : trackingNumber.trim();
        if (trackingVal != null && shipmentRepository.existsByTrackingNumber(trackingVal)) {
            throw new BusinessRuleException("Tracking number " + trackingVal + " is already used by another shipment");
        }
        for (CustomerOrderItem i : customerItemRepository.findByCustomerOrderId(orderId)) {
            inventoryService.shipReserved(i.getBookId(), i.getQuantity(), "CUSTOMER_ORDER", orderId, userId);
        }
        Shipment s = new Shipment();
        s.setCustomerOrderId(orderId);
        s.setShippingProvider(providerVal);
        s.setTrackingNumber(trackingVal);
        s.setShippingCost(cost);
        s.setShippedDate(LocalDate.now());
        s.setShipmentStatus("IN_TRANSIT");
        shipmentRepository.save(s);
        o.setOrderStatus(CustomerOrder.DISPATCHED);
        o.setDispatchedAt(LocalDateTime.now());
        CustomerOrder saved = customerOrderRepository.save(o);
        try {
            emailService.sendOrderDispatched(saved, providerVal, trackingVal);
        } catch (RuntimeException ignored) {
            // Never fail dispatch because of e-mail problems
        }
        return storeService.orderView(saved);
    }

    public Map<String, Object> deliver(Long orderId, Long userId) {
        CustomerOrder o = customerOrder(orderId);
        requireStatus(o.getOrderStatus(), CustomerOrder.DISPATCHED, "mark delivered", o.getOrderNumber());
        Shipment s = shipmentRepository
                .findFirstByCustomerOrderIdOrderByShipmentIdDesc(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found for order: " + orderId));
        s.setShipmentStatus("DELIVERED");
        s.setDeliveredDate(LocalDate.now());
        shipmentRepository.save(s);
        o.setOrderStatus(CustomerOrder.DELIVERED);
        o.setDeliveredAt(LocalDateTime.now());
        o.setPaymentStatus("PAID");
        CustomerOrder saved = customerOrderRepository.save(o);
        // Cash collected on delivery settles the invoice (card orders are already paid, so nothing is added).
        orderInvoicing.collectCashOnDelivery(saved, userId);
        Map<Long, String> titles = titles();
        int line = 1;
        String channel = o.isWholesale() ? SalesFeed.WHOLESALE : SalesFeed.RETAIL;
        for (CustomerOrderItem i : customerItemRepository.findByCustomerOrderId(orderId)) {
            salesFeed.completedLine(channel, o.getOrderNumber(), line++, i.getBookId(),
                    titles.getOrDefault(i.getBookId(), "Book #" + i.getBookId()), i.getQuantity(), i.getUnitPrice(), BigDecimal.ZERO);
        }
        return storeService.orderView(saved);
    }

    private CustomerOrder customerOrder(Long id) {
        return customerOrderRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Order not found: " + id));
    }


    // ===================== customer checkout wholesale requests (sales approval) =====================

    @Transactional(readOnly = true)
    public Map<String, Object> wholesaleRequests(String status) {
        String filter = status == null || status.isBlank() ? "PENDING" : status.trim().toUpperCase();
        List<CustomerOrder> orders;
        if ("ALL".equals(filter)) {
            orders = customerOrderRepository.findAllWholesaleCandidates();
        } else if ("PENDING".equals(filter) || "APPROVED".equals(filter) || "REJECTED".equals(filter)) {
            orders = customerOrderRepository.findWholesaleByFilterStatus(filter);
        } else {
            orders = customerOrderRepository.findAllWholesaleCandidates();
            filter = "ALL";
        }
        // Back-fill legacy address-tagged orders so the UI has consistent fields
        for (CustomerOrder o : orders) {
            normalizeLegacyWholesale(o);
        }
        List<Map<String, Object>> rows = orders.stream().map(storeService::orderView).toList();

        long pending = customerOrderRepository.findWholesaleByFilterStatus("PENDING").size();
        long approved = customerOrderRepository.findWholesaleByFilterStatus("APPROVED").size();
        long rejected = customerOrderRepository.findWholesaleByFilterStatus("REJECTED").size();
        long all = customerOrderRepository.findAllWholesaleCandidates().size();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("filter", filter);
        result.put("counts", Map.of(
                "PENDING", pending,
                "APPROVED", approved,
                "REJECTED", rejected,
                "ALL", all
        ));
        result.put("requests", rows);
        return result;
    }

    /**
     * Ensure wholesale flag/status are consistent so sales can confirm/reject.
     * Unreviewed wholesale orders (including ones that landed as CONFIRMED) stay PENDING.
     */
    private void normalizeLegacyWholesale(CustomerOrder o) {
        String addr = o.getShippingAddress();
        boolean tagged = addr != null && addr.startsWith("[WHOLESALE");
        if (!o.isWholesale() && !tagged) {
            return;
        }
        boolean changed = false;
        if (!o.isWholesale()) {
            o.setWholesale(true);
            changed = true;
        }
        if (o.getWholesaleStatus() == null) {
            if (CustomerOrder.CANCELLED.equals(o.getOrderStatus())) {
                o.setWholesaleStatus(CustomerOrder.WHOLESALE_REJECTED);
            } else if (CustomerOrder.DISPATCHED.equals(o.getOrderStatus())
                    || CustomerOrder.DELIVERED.equals(o.getOrderStatus())
                    || CustomerOrder.PACKED.equals(o.getOrderStatus())) {
                // Already moved past sales gate in the warehouse pipeline
                o.setWholesaleStatus(CustomerOrder.WHOLESALE_APPROVED);
            } else {
                // PENDING_APPROVAL, CONFIRMED, or unknown — still needs sales decision
                o.setWholesaleStatus(CustomerOrder.WHOLESALE_PENDING);
            }
            changed = true;
        }
        if ((o.getBusinessName() == null || o.getBusinessName().isBlank()) && tagged) {
            int close = addr.indexOf(']');
            if (close > 0) {
                String tag = addr.substring(0, close);
                int colon = tag.indexOf(':');
                if (colon > 0 && colon + 1 < tag.length()) {
                    o.setBusinessName(tag.substring(colon + 1).trim());
                    changed = true;
                }
            }
        }
        if (changed) {
            customerOrderRepository.save(o);
        }
    }


    /**
     * Admin/sales confirms a customer checkout order (retail or wholesale).
     * Moves PENDING_APPROVAL → CONFIRMED so warehouse can pack and deliver.
     */
    public Map<String, Object> confirmWholesaleRequest(Long orderId, Long userId) {
        CustomerOrder o = customerOrder(orderId);
        normalizeLegacyWholesale(o);
        if (CustomerOrder.CANCELLED.equals(o.getOrderStatus())
                || CustomerOrder.DISPATCHED.equals(o.getOrderStatus())
                || CustomerOrder.DELIVERED.equals(o.getOrderStatus())
                || CustomerOrder.PACKED.equals(o.getOrderStatus())) {
            throw new BusinessRuleException("Order " + o.getOrderNumber() + " can no longer be confirmed (status: "
                    + o.getOrderStatus() + ")");
        }
        if (CustomerOrder.CONFIRMED.equals(o.getOrderStatus())
                && (!o.isWholesale() || CustomerOrder.WHOLESALE_APPROVED.equals(o.getWholesaleStatus()))) {
            throw new BusinessRuleException("Order " + o.getOrderNumber() + " is already confirmed");
        }
        if (o.isWholesale()) {
            if (CustomerOrder.WHOLESALE_REJECTED.equals(o.getWholesaleStatus())) {
                throw new BusinessRuleException("Wholesale request " + o.getOrderNumber() + " was rejected and cannot be confirmed");
            }
            o.setWholesaleStatus(CustomerOrder.WHOLESALE_APPROVED);
            o.setWholesaleReviewedBy(userId);
            o.setWholesaleReviewedAt(LocalDateTime.now());
            o.setWholesaleRejectReason(null);
        }
        o.setOrderStatus(CustomerOrder.CONFIRMED);
        CustomerOrder saved = customerOrderRepository.save(o);
        auditService.record(userId, "ORDER_CONFIRMED", "CustomerOrder", orderId, o.getOrderNumber());
        // Same transaction: if the invoice cannot be created, the approval is rolled back too.
        orderInvoicing.issue(saved, userId);
        try {
            emailService.sendOrderApproved(saved);
        } catch (RuntimeException ignored) {
            // Never fail approval because of e-mail problems
        }
        return storeService.orderView(saved);
    }

    /**
     * Admin/sales rejects a customer checkout order (retail or wholesale).
     * Cancels the order and releases reserved stock.
     */
    public Map<String, Object> rejectWholesaleRequest(Long orderId, String reason, Long userId) {
        CustomerOrder o = customerOrder(orderId);
        normalizeLegacyWholesale(o);
        if (CustomerOrder.CANCELLED.equals(o.getOrderStatus())) {
            throw new BusinessRuleException("Order " + o.getOrderNumber() + " is already cancelled");
        }
        if (CustomerOrder.DISPATCHED.equals(o.getOrderStatus()) || CustomerOrder.DELIVERED.equals(o.getOrderStatus())) {
            throw new BusinessRuleException("Order " + o.getOrderNumber() + " has already been shipped and cannot be rejected");
        }
        if (reason == null || reason.isBlank()) {
            throw new InvalidRequestException("A reason is required to reject an order");
        }
        orderInvoicing.cancel(o, reason.trim(), userId);
        // Release reserved stock if still held
        if (!CustomerOrder.CANCELLED.equals(o.getOrderStatus())) {
            for (CustomerOrderItem i : customerItemRepository.findByCustomerOrderId(orderId)) {
                try {
                    inventoryService.release(i.getBookId(), i.getQuantity(), "CUSTOMER_ORDER", orderId, userId);
                } catch (Exception ignored) {
                    // stock may already be released
                }
            }
        }
        if (o.isWholesale()) {
            o.setWholesaleStatus(CustomerOrder.WHOLESALE_REJECTED);
            o.setWholesaleReviewedBy(userId);
            o.setWholesaleReviewedAt(LocalDateTime.now());
            o.setWholesaleRejectReason(reason.trim());
            o.setCancelReason("Wholesale rejected: " + reason.trim());
        } else {
            o.setCancelReason("Rejected by sales: " + reason.trim());
        }
        o.setOrderStatus(CustomerOrder.CANCELLED);
        CustomerOrder saved = customerOrderRepository.save(o);
        auditService.record(userId, "ORDER_REJECTED", "CustomerOrder", orderId, reason.trim());
        try {
            emailService.sendOrderRejected(saved, reason.trim());
        } catch (RuntimeException ignored) {
            // Never fail rejection because of e-mail problems
        }
        return storeService.orderView(saved);
    }

    // ===================== bookstores and wholesale orders (US30) =====================

    @Transactional(readOnly = true)
    public List<Bookstore> bookstores() {
        return bookstoreRepository.findAllByOrderByBookstoreName();
    }

    public Bookstore saveBookstore(Long id, BookstoreRequest r) {
        Bookstore b = id == null ? new Bookstore() : bookstoreRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Bookstore not found: " + id));
        String email = r.getEmail() == null || r.getEmail().isBlank() ? null : r.getEmail().trim();
        if (email != null && !email.equalsIgnoreCase(b.getEmail()) && bookstoreRepository.existsByEmailIgnoreCase(email)) {
            throw new BusinessRuleException("Another bookstore already uses " + email);
        }
        b.setBookstoreName(r.getBookstoreName().trim());
        b.setContactPerson(blank(r.getContactPerson()));
        b.setEmail(email);
        b.setPhoneNumber(blank(r.getPhoneNumber()));
        b.setAddress(blank(r.getAddress()));
        b.setCity(blank(r.getCity()));
        b.setCountry(blank(r.getCountry()));
        return bookstoreRepository.save(b);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> sellableBooks() {
        return bookRepository.findByBookStatusInOrderByTitle(List.of(PublishedBook.PUBLISHED)).stream().map(b -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("bookId", b.getBookId());
            m.put("title", b.getTitle());
            m.put("isbn", b.getIsbn());
            m.put("listPrice", b.getPrice());
            m.put("tradePrice", b.getPrice().multiply(TRADE_PRICE_FACTOR).setScale(2, RoundingMode.HALF_UP));
            m.put("available", inventoryService.available(b.getBookId()));
            return m;
        }).toList();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> bookstoreOrders(String status) {
        List<BookstoreOrder> orders = status == null || status.isBlank()
                ? bookstoreOrderRepository.findAllByOrderByOrderDateDesc()
                : bookstoreOrderRepository.findByOrderStatusOrderByOrderDateAsc(status.toUpperCase());
        return orders.stream().map(this::bookstoreOrderView).toList();
    }

    public Map<String, Object> createBookstoreOrder(BookstoreOrderRequest r, Long userId) {
        Bookstore store = bookstoreRepository.findById(r.getBookstoreId())
                .orElseThrow(() -> new ResourceNotFoundException("Bookstore not found: " + r.getBookstoreId()));
        if (!"ACTIVE".equals(store.getStatus())) {
            throw new BusinessRuleException(store.getBookstoreName() + " is not an active bookstore");
        }
        if (r.getItems() == null || r.getItems().isEmpty()) {
            throw new InvalidRequestException("Add at least one book to the wholesale order");
        }
        int totalQty = r.getItems().stream().mapToInt(line -> line.getQuantity() == null ? 0 : line.getQuantity()).sum();
        if (totalQty < MIN_WHOLESALE_QUANTITY) {
            throw new InvalidRequestException(
                    "Wholesale orders require at least " + MIN_WHOLESALE_QUANTITY
                            + " books in total. This order has " + totalQty + ".");
        }
        BookstoreOrder o = new BookstoreOrder();
        o.setBookstoreId(store.getBookstoreId());
        o.setOrderNumber(numbers.next("BO-", "BOOKSTORE_ORDER", LocalDate.now().getYear()));
        o.setOrderStatus(BookstoreOrder.PENDING_APPROVAL);
        o.setCreatedBy(userId);
        o.setTotalAmount(BigDecimal.ZERO);
        BookstoreOrder saved = bookstoreOrderRepository.saveAndFlush(o);
        BigDecimal total = BigDecimal.ZERO;
        for (BookstoreOrderRequest.Line l : r.getItems()) {
            PublishedBook b = bookRepository.findById(l.getBookId())
                    .orElseThrow(() -> new ResourceNotFoundException("Book not found: " + l.getBookId()));
            if (!PublishedBook.PUBLISHED.equals(b.getBookStatus())) {
                throw new BusinessRuleException("\"" + b.getTitle() + "\" is not published yet");
            }
            BigDecimal unit = l.getUnitPrice() != null ? l.getUnitPrice()
                    : b.getPrice().multiply(TRADE_PRICE_FACTOR).setScale(2, RoundingMode.HALF_UP);
            BookstoreOrderItem item = new BookstoreOrderItem();
            item.setBookstoreOrderId(saved.getBookstoreOrderId());
            item.setBookId(b.getBookId());
            item.setQuantity(l.getQuantity());
            item.setUnitPrice(unit);
            item.setSubtotal(unit.multiply(BigDecimal.valueOf(l.getQuantity())));
            bookstoreItemRepository.save(item);
            total = total.add(item.getSubtotal());
        }
        saved.setTotalAmount(total);
        return bookstoreOrderView(bookstoreOrderRepository.save(saved));
    }

    /** US30: approval reserves the stock; an order that cannot be covered is refused. */
    public Map<String, Object> approve(Long orderId, Long userId) {
        BookstoreOrder o = bookstoreOrder(orderId);
        requireStatus(o.getOrderStatus(), BookstoreOrder.PENDING_APPROVAL, "approve", o.getOrderNumber());
        Map<Long, String> titles = titles();
        for (BookstoreOrderItem i : bookstoreItemRepository.findByBookstoreOrderId(orderId)) {
            inventoryService.reserve(i.getBookId(), i.getQuantity(), "BOOKSTORE_ORDER", orderId, userId,
                    titles.getOrDefault(i.getBookId(), "Book #" + i.getBookId()));
        }
        o.setOrderStatus(BookstoreOrder.APPROVED);
        o.setApprovedBy(userId);
        o.setApprovedAt(LocalDateTime.now());
        BookstoreOrder saved = bookstoreOrderRepository.save(o);
        auditService.record(userId, "WHOLESALE_APPROVED", "BookstoreOrder", orderId, o.getOrderNumber());
        return bookstoreOrderView(saved);
    }

    public Map<String, Object> reject(Long orderId, String reason, Long userId) {
        if (reason == null || reason.isBlank()) {
            throw new InvalidRequestException("A reason is required to reject a wholesale order");
        }
        BookstoreOrder o = bookstoreOrder(orderId);
        requireStatus(o.getOrderStatus(), BookstoreOrder.PENDING_APPROVAL, "reject", o.getOrderNumber());
        o.setOrderStatus(BookstoreOrder.REJECTED);
        o.setRejectionReason(reason.trim());
        o.setApprovedBy(userId);
        o.setApprovedAt(LocalDateTime.now());
        BookstoreOrder saved = bookstoreOrderRepository.save(o);
        auditService.record(userId, "WHOLESALE_REJECTED", "BookstoreOrder", orderId, reason.trim());
        return bookstoreOrderView(saved);
    }

    public Map<String, Object> dispatchBookstoreOrder(Long orderId, String provider, String tracking, Long userId) {
        BookstoreOrder o = bookstoreOrder(orderId);
        requireStatus(o.getOrderStatus(), BookstoreOrder.APPROVED, "dispatch", o.getOrderNumber());
        // Courier and tracking are optional
        for (BookstoreOrderItem i : bookstoreItemRepository.findByBookstoreOrderId(orderId)) {
            inventoryService.shipReserved(i.getBookId(), i.getQuantity(), "BOOKSTORE_ORDER", orderId, userId);
        }
        o.setShippingProvider(provider == null || provider.isBlank() ? null : provider.trim());
        o.setTrackingNumber(blank(tracking));
        o.setOrderStatus(BookstoreOrder.DISPATCHED);
        o.setDispatchedAt(LocalDateTime.now());
        return bookstoreOrderView(bookstoreOrderRepository.save(o));
    }

    public Map<String, Object> deliverBookstoreOrder(Long orderId, Long userId) {
        BookstoreOrder o = bookstoreOrder(orderId);
        requireStatus(o.getOrderStatus(), BookstoreOrder.DISPATCHED, "mark delivered", o.getOrderNumber());
        o.setOrderStatus(BookstoreOrder.DELIVERED);
        o.setDeliveredAt(LocalDateTime.now());
        BookstoreOrder saved = bookstoreOrderRepository.save(o);
        Map<Long, String> titles = titles();
        int line = 1;
        for (BookstoreOrderItem i : bookstoreItemRepository.findByBookstoreOrderId(orderId)) {
            salesFeed.completedLine(SalesFeed.WHOLESALE, o.getOrderNumber(), line++, i.getBookId(),
                    titles.getOrDefault(i.getBookId(), "Book #" + i.getBookId()), i.getQuantity(), i.getUnitPrice(), BigDecimal.ZERO);
        }
        return bookstoreOrderView(saved);
    }

    private Map<String, Object> bookstoreOrderView(BookstoreOrder o) {
        Map<Long, String> titles = titles();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("order", o);
        m.put("bookstoreName", bookstoreRepository.findById(o.getBookstoreId()).map(Bookstore::getBookstoreName).orElse(null));
        m.put("createdByName", names.user(o.getCreatedBy()));
        m.put("approvedByName", names.user(o.getApprovedBy()));
        m.put("items", bookstoreItemRepository.findByBookstoreOrderId(o.getBookstoreOrderId()).stream().map(i -> {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("bookId", i.getBookId());
            row.put("title", titles.getOrDefault(i.getBookId(), "Book #" + i.getBookId()));
            row.put("quantity", i.getQuantity());
            row.put("unitPrice", i.getUnitPrice());
            row.put("subtotal", i.getSubtotal());
            row.put("available", inventoryService.available(i.getBookId()));
            return row;
        }).toList());
        return m;
    }

    private BookstoreOrder bookstoreOrder(Long id) {
        return bookstoreOrderRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Wholesale order not found: " + id));
    }

    private Map<Long, String> titles() {
        return bookRepository.findAll().stream().collect(Collectors.toMap(PublishedBook::getBookId, PublishedBook::getTitle, (a, b) -> a));
    }

    private static void requireStatus(String actual, String required, String action, String number) {
        if (!required.equals(actual)) {
            throw new BusinessRuleException("Cannot " + action + " order " + number + ": it is " + actual.replace('_', ' ')
                    + " (must be " + required.replace('_', ' ') + ")");
        }
    }

    private static String blank(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
