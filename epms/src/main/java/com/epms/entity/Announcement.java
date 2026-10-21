package com.epms.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "announcements")
@Data
public class Announcement {

    public static final String CUSTOMER = "CUSTOMER";
    public static final String IMAGE_URL_PREFIX = "/uploads/promotions/";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "announcement_id")
    private Long announcementId;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    /**
     * CUSTOMER for every promotion. Older announcements addressed to a staff
     * or author role keep that value and are no longer shown anywhere.
     */
    @Column(name = "audience", nullable = false, length = 30)
    private String audience = CUSTOMER;

    /** SALE, OFFER or AD — sets the look of the homepage hero slide. */
    @Column(name = "promo_type", nullable = false, length = 20)
    private String promoType = "OFFER";

    /** Short highlight on the slide, e.g. "30% OFF". */
    @Column(name = "badge_text", length = 40)
    private String badgeText;

    @Column(name = "cta_label", length = 40)
    private String ctaLabel;

    /** Site path (/store.html) or http(s) link the button opens. */
    @Column(name = "cta_url", length = 500)
    private String ctaUrl;

    /** File name under uploads/promotions, served at {@link #getImageUrl()}. */
    @Column(name = "image_file")
    private String imageFile;

    @Column(name = "created_by", nullable = false)
    private Long createdBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /** DRAFT (no publish date), SCHEDULED, ACTIVE or EXPIRED, derived from the publish window. */
    @Transient
    public String getStatus() {
        LocalDateTime now = LocalDateTime.now();
        if (publishedAt == null) return "DRAFT";
        if (publishedAt.isAfter(now)) return "SCHEDULED";
        if (expiresAt != null && !expiresAt.isAfter(now)) return "EXPIRED";
        return "ACTIVE";
    }

    @Transient
    public String getImageUrl() {
        return imageFile == null ? null : IMAGE_URL_PREFIX + imageFile;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
