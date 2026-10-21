package com.epms.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * History of editor assignments for a manuscript (Chief Editor US11 / US15).
 * ACTIVE -> REASSIGNED or CANCELLED when the chief changes or cancels.
 */
@Entity
@Table(name = "manuscript_assignments")
@Data
public class ManuscriptAssignment {

    public static final String ACTIVE = "ACTIVE";
    public static final String REASSIGNED = "REASSIGNED";
    public static final String CANCELLED = "CANCELLED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "assignment_id")
    private Long assignmentId;

    @Column(name = "manuscript_id", nullable = false)
    private Long manuscriptId;

    @Column(name = "editor_id", nullable = false)
    private Long editorId;

    @Column(name = "assigned_by", nullable = false)
    private Long assignedBy;

    @Column(name = "assignment_status", nullable = false, length = 30)
    private String assignmentStatus = ACTIVE;

    @Column(name = "remarks", length = 500)
    private String remarks;

    @Column(name = "assigned_at", nullable = false)
    private LocalDateTime assignedAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        if (assignedAt == null) {
            assignedAt = createdAt;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}