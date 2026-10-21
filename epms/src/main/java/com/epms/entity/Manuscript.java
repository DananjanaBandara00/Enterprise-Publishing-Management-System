package com.epms.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * Epic 1/2: a manuscript and where it is in the workflow. See
 * {@link com.epms.enums.ManuscriptStatus} for the status flow.
 */
@Entity
@Table(name = "manuscripts")
@Data
public class Manuscript {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "manuscript_id")
    private Long manuscriptId;

    @Column(name = "author_id", nullable = false)
    private Long authorId;

    @Column(name = "genre_id", nullable = false)
    private Long genreId;

    /** Book category chosen by the author; null on manuscripts submitted before it was asked for. */
    @Column(name = "category_id")
    private Long categoryId;

    @Column(name = "manuscript_code", nullable = false, unique = true, length = 20)
    private String manuscriptCode;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "synopsis", columnDefinition = "TEXT")
    private String synopsis;

    @Column(name = "language", nullable = false, length = 50)
    private String language;

    @Column(name = "word_count")
    private Integer wordCount;

    @Column(name = "submitted_at", nullable = false)
    private LocalDateTime submittedAt;

    @Column(name = "status", nullable = false, length = 30)
    private String status;

    // Epic 2: the editor responsible for the review
    @Column(name = "assigned_editor_id")
    private Long assignedEditorId;

    @Column(name = "assigned_by")
    private Long assignedBy;

    @Column(name = "assigned_at")
    private LocalDateTime assignedAt;

    /** Optional note from the Chief Editor when assigning (shown in editor queue). */
    @Column(name = "assignment_remarks", length = 500)
    private String assignmentRemarks;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (submittedAt == null) {
            submittedAt = createdAt;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
