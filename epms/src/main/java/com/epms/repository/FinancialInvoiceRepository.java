package com.epms.repository;

import com.epms.entity.FinancialInvoice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FinancialInvoiceRepository extends JpaRepository<FinancialInvoice, Long> {

    boolean existsByInvoiceNumber(String invoiceNumber);

    List<FinancialInvoice> findAllByOrderByInvoiceIdDesc();

    List<FinancialInvoice> findByStatusOrderByInvoiceIdDesc(String status);

    Optional<FinancialInvoice> findFirstByReferenceTypeAndReferenceIdAndStatusNot(String referenceType, Long referenceId,
                                                                                  String status);
}
