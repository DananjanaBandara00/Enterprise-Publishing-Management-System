package com.epms.repository;

import com.epms.entity.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface InventoryRepository extends JpaRepository<Inventory, Long> {

    Optional<Inventory> findFirstByBookIdOrderByInventoryIdAsc(Long bookId);

    default Optional<Inventory> findByBookId(Long bookId) {
        return findFirstByBookIdOrderByInventoryIdAsc(bookId);
    }

    /** Row lock so two orders cannot reserve the same last copies. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT i FROM Inventory i WHERE i.bookId = :bookId ORDER BY i.inventoryId ASC")
    java.util.List<Inventory> lockAllByBookId(@Param("bookId") Long bookId);

    default Optional<Inventory> lockByBookId(Long bookId) {
        java.util.List<Inventory> rows = lockAllByBookId(bookId);
        return rows.isEmpty() ? Optional.empty() : Optional.of(rows.get(0));
    }
}
