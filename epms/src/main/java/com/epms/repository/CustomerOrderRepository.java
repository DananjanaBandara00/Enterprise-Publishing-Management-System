package com.epms.repository;

import com.epms.entity.CustomerOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Long> {

    List<CustomerOrder> findByCustomerIdOrderByOrderDateDesc(Long customerId);

    List<CustomerOrder> findByOrderStatusInOrderByOrderDateAsc(Collection<String> statuses);

    List<CustomerOrder> findAllByOrderByOrderDateDesc();

    List<CustomerOrder> findByWholesaleFalseOrderByOrderDateDesc();

    List<CustomerOrder> findByWholesaleFalseAndOrderStatusInOrderByOrderDateAsc(Collection<String> statuses);

    List<CustomerOrder> findByWholesaleTrueAndOrderStatusInOrderByOrderDateAsc(Collection<String> statuses);


    List<CustomerOrder> findByWholesaleTrueOrderByOrderDateDesc();

    List<CustomerOrder> findByWholesaleTrueAndWholesaleStatusOrderByOrderDateDesc(String wholesaleStatus);

    /**
     * All orders that should appear on the sales wholesale queue:
     * explicit wholesale flag, pending-approval status, or legacy address tag.
     */
    @Query("SELECT o FROM CustomerOrder o WHERE o.wholesale = true "
            + "OR o.orderStatus = 'PENDING_APPROVAL' "
            + "OR o.shippingAddress LIKE '[WHOLESALE%' "
            + "ORDER BY o.orderDate DESC")
    List<CustomerOrder> findAllWholesaleCandidates();

    @Query("SELECT o FROM CustomerOrder o WHERE "
            + "(o.orderStatus = 'PENDING_APPROVAL' "
            + " OR o.wholesale = true OR o.shippingAddress LIKE '[WHOLESALE%' "
            + " OR (o.orderStatus IN ('CONFIRMED','PACKED','DISPATCHED','DELIVERED','CANCELLED') "
            + "     AND o.createdAt IS NOT NULL)) "
            + "AND ("
            + "  (:status = 'PENDING' AND o.orderStatus = 'PENDING_APPROVAL') "
            + "  OR (:status = 'APPROVED' AND o.orderStatus IN ('CONFIRMED','PACKED','DISPATCHED','DELIVERED') "
            + "       AND (o.wholesale = false OR o.wholesaleStatus = 'APPROVED')) "
            + "  OR (:status = 'REJECTED' AND o.orderStatus = 'CANCELLED') "
            + ") ORDER BY o.orderDate DESC")
    List<CustomerOrder> findWholesaleByFilterStatus(@Param("status") String status);

    long countByWholesaleTrueAndWholesaleStatus(String wholesaleStatus);

    long countByOrderStatus(String orderStatus);
}
