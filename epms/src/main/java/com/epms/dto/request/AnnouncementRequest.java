package com.epms.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

/** A customer promotion shown in the homepage hero carousel. */
@Data
public class AnnouncementRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title must be 200 characters or fewer")
    private String title;

    @NotBlank(message = "Content is required")
    @Size(max = 600, message = "Message must be 600 characters or fewer")
    private String content;

    /** SALE, OFFER or AD; empty = OFFER. */
    @Pattern(regexp = "^(?i)(SALE|OFFER|AD)?$", message = "Type must be SALE, OFFER or AD")
    private String promoType;

    @Size(max = 40, message = "Badge must be 40 characters or fewer")
    private String badgeText;

    @Size(max = 40, message = "Button text must be 40 characters or fewer")
    private String ctaLabel;

    @Size(max = 500, message = "Button link must be 500 characters or fewer")
    @Pattern(regexp = "^$|^/(?!/).*|^https?://.+", message = "Button link must be a site path (/store.html) or an http(s) link")
    private String ctaUrl;

    /** First day it is shown; empty = from now. Ignored when draft is true. */
    private LocalDate publishFrom;

    /** Last day it is shown; empty = no end. */
    private LocalDate publishTo;

    /** Keep as an unpublished draft. */
    private boolean draft;
}
