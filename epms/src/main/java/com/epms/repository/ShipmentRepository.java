package com.epms.repository;

import com.epms.entity.Shipment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ShipmentRepository extends JpaRepository<Shipment, Long> {

    /**
     * Prefer this when an order might have more than one shipment row
     * (legacy data / double-dispatch). Newest shipment wins.
     */
    Optional<Shipment> findFirstByCustomerOrderIdOrderByShipmentIdDesc(Long customerOrderId);

    List<Shipment> findByCustomerOrderIdOrderByShipmentIdDesc(Long customerOrderId);

    boolean existsByTrackingNumber(String trackingNumber);
}
