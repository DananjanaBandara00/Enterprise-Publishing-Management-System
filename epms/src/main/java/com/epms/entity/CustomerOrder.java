package com.epms.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Epic 3: an online order. CONFIRMED (stock reserved) -> PACKED ->
 * DISPATCHED -> DELIVERED, or CANCELLED before dispatch.
 */
@Entity
@Table(name = "customer_orders")
@Data
public class CustomerOrder {

    public static final String CONFIRMED = "CONFIRMED";
    public static final String PACKED = "PACKED";
    public static final String DISPATCHED = "DISPATCHED";
    public static final String DELIVERED = "DELIVERED";
    public static final String CANCELLED = "CANCELLED";
    /** Wholesale checkout: waiting for sales staff to confirm or reject. */
    public static final String PENDING_APPROVAL = "PENDING_APPROVAL";

    /** Checkout payment options. */
    public static final String PAY_COD = "COD";
    public static final String PAY_CARD = "CARD";

    public static final String WHOLESALE_PENDING = "PENDING";
    public static final String WHOLESALE_APPROVED = "APPROVED";
    public static final String WHOLESALE_REJECTED = "REJECTED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_order_id")
    private Long customerOrderId;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "order_number", nullable = false, unique = true, length = 30)
    private String orderNumber;

    @Column(name = "order_date", nullable = false)
    private LocalDateTime orderDate;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "order_status", nullable = false, length = 30)
    private String orderStatus = CONFIRMED;

    @Column(name = "shipping_address", nullable = false)
    private String shippingAddress;

    // COD: PENDING until delivered, then PAID. CARD: PAID at checkout, REFUNDED if the order is cancelled.
    @Column(name = "payment_status", nullable = false, length = 30)
    private String paymentStatus = "PENDING";

    // COD (cash on delivery) or CARD (paid online at checkout)
    @Column(name = "payment_method", nullable = false, length = 20)
    private String paymentMethod = PAY_COD;

    @Column(name = "recipient_name", nullable = false, length = 150)
    private String recipientName;

    @Column(name = "recipient_phone", length = 20)
    private String recipientPhone;

    @Column(name = "cancel_reason")
    private String cancelReason;

    @Column(name = "packed_at")
    private LocalDateTime packedAt;

    @Column(name = "dispatched_at")
    private LocalDateTime dispatchedAt;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    /** True when the customer checked "This is a wholesale order" at checkout. */
    @Column(name = "is_wholesale", nullable = false)
    private boolean wholesale = false;

    @Column(name = "business_name", length = 150)
    private String businessName;

    /** PENDING / APPROVED / REJECTED when wholesale; null for retail orders. */
    @Column(name = "wholesale_status", length = 30)
    private String wholesaleStatus;

    @Column(name = "wholesale_reviewed_by")
    private Long wholesaleReviewedBy;

    @Column(name = "wholesale_reviewed_at")
    private LocalDateTime wholesaleReviewedAt;

    @Column(name = "wholesale_reject_reason", length = 255)
    private String wholesaleRejectReason;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (orderDate == null) {
            orderDate = createdAt;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
