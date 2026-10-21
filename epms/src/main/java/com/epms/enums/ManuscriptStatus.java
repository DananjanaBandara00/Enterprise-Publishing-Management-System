package com.epms.enums;

import java.util.List;

/**
 * Manuscript workflow across Epics 1 and 2:
 *
 * <pre>
 * DRAFT -> PENDING_SUPER_ADMIN_REVIEW -> SUBMITTED -> UNDER_REVIEW -> EDITORIALLY_ACCEPTED -> IN_DESIGN -> ...
 *              | (reject)                    |   ^   \-> REJECTED
 *         REJECTED_BY_ADMIN     REVISION_REQUESTED -> RESUBMITTED
 *
 *                                   PUBLISHED <- READY_FOR_PRINTING <- QC_PASSED
 *                                                              QC failed -> QC_FAILED -> (designer fix) -> DESIGN_APPROVED
 * </pre>
 */
public final class ManuscriptStatus {

    public static final String DRAFT = "DRAFT";

    /** Author submitted; waiting for Super Admin (ADMIN) accept/reject. */
    public static final String PENDING_SUPER_ADMIN_REVIEW = "PENDING_SUPER_ADMIN_REVIEW";

    /** Super Admin rejected the submission. */
    public static final String REJECTED_BY_ADMIN = "REJECTED_BY_ADMIN";

    /** Super Admin accepted; visible to Chief Editor for assignment. */
    public static final String SUBMITTED = "SUBMITTED";

    public static final String UNDER_REVIEW = "UNDER_REVIEW";
    public static final String REVISION_REQUESTED = "REVISION_REQUESTED";
    public static final String RESUBMITTED = "RESUBMITTED";
    /** Editor accepted the manuscript; ready for design assignment. */
    public static final String EDITORIALLY_ACCEPTED = "EDITORIALLY_ACCEPTED";

    /** Legacy / production gate — prefer EDITORIALLY_ACCEPTED after editorial review. */
    public static final String ACCEPTED = "ACCEPTED";
    public static final String REJECTED = "REJECTED";
    public static final String IN_DESIGN = "IN_DESIGN";
    public static final String AWAITING_AUTHOR_APPROVAL = "AWAITING_AUTHOR_APPROVAL";
    public static final String DESIGN_APPROVED = "DESIGN_APPROVED";
    public static final String QC_PASSED = "QC_PASSED";
    public static final String QC_FAILED = "QC_FAILED";
    public static final String READY_FOR_PRINTING = "READY_FOR_PRINTING";
    public static final String PUBLISHED = "PUBLISHED";

    /**
     * Editorial pipeline after Super Admin acceptance (US11–US15).
     * Does NOT include PENDING_SUPER_ADMIN_REVIEW or REJECTED_BY_ADMIN.
     */
    public static final List<String> EDITORIAL = List.of(
            SUBMITTED, UNDER_REVIEW, REVISION_REQUESTED, RESUBMITTED);

    /** Accepted and moving through design / production (US16–US20). */
    public static final List<String> PRODUCTION = List.of(
            EDITORIALLY_ACCEPTED, ACCEPTED, IN_DESIGN, AWAITING_AUTHOR_APPROVAL,
            DESIGN_APPROVED, QC_FAILED, QC_PASSED, READY_FOR_PRINTING, PUBLISHED);

    /** Statuses the Chief Editor may see in the ready / dropdown queue. */
    public static final List<String> CHIEF_EDITOR_QUEUE = List.of(SUBMITTED);

    private ManuscriptStatus() {
    }
}
