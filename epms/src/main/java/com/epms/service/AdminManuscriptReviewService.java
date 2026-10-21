package com.epms.service;

import com.epms.dto.response.ManuscriptSummary;
import com.epms.entity.Manuscript;
import com.epms.enums.ManuscriptStatus;
import com.epms.exception.InvalidRequestException;
import com.epms.repository.ManuscriptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Phase 1 – Super Admin (ADMIN) gate:
 * Author submits → PENDING_SUPER_ADMIN_REVIEW →
 * Admin accept → SUBMITTED (Chief Editor queue) |
 * Admin reject → REJECTED_BY_ADMIN.
 */
@Service
@RequiredArgsConstructor
public class AdminManuscriptReviewService {

    private final ManuscriptRepository manuscriptRepository;
    private final ManuscriptWorkflow workflow;
    private final ManuscriptQueryService queries;
    private final AuditService auditService;

    /** Queue for Super Admin: manuscripts waiting for accept/reject. */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> pendingReview() {
        List<Manuscript> list = manuscriptRepository
                .findByStatusInOrderByUpdatedAtDesc(List.of(ManuscriptStatus.PENDING_SUPER_ADMIN_REVIEW));
        return queries.summaries(list);
    }

    /**
     * Super Admin accepts the manuscript.
     * Status becomes SUBMITTED so it appears in the Chief Editor dropdown / ready list.
     */
    @Transactional
    public Manuscript accept(Long manuscriptId, Long adminUserId) {
        Manuscript m = workflow.get(manuscriptId);
        workflow.requireStatus(m, "accept for editorial", ManuscriptStatus.PENDING_SUPER_ADMIN_REVIEW);

        Manuscript saved = workflow.changeStatus(
                m,
                ManuscriptStatus.SUBMITTED,
                adminUserId,
                "Accepted by Super Admin; released to Chief Editor");

        auditService.record(
                adminUserId,
                "SUPER_ADMIN_ACCEPT",
                "Manuscript",
                manuscriptId,
                m.getManuscriptCode() + " accepted → SUBMITTED");

        return saved;
    }

    /**
     * Super Admin rejects the manuscript with a required reason.
     */
    @Transactional
    public Manuscript reject(Long manuscriptId, Long adminUserId, String reason) {
        if (reason == null || reason.isBlank()) {
            throw new InvalidRequestException("A rejection reason is required");
        }
        String trimmed = reason.trim();
        if (trimmed.length() > 500) {
            throw new InvalidRequestException("Reason must be 500 characters or fewer");
        }

        Manuscript m = workflow.get(manuscriptId);
        workflow.requireStatus(m, "reject", ManuscriptStatus.PENDING_SUPER_ADMIN_REVIEW);

        Manuscript saved = workflow.changeStatus(
                m,
                ManuscriptStatus.REJECTED_BY_ADMIN,
                adminUserId,
                "Rejected by Super Admin: " + trimmed);

        auditService.record(
                adminUserId,
                "SUPER_ADMIN_REJECT",
                "Manuscript",
                manuscriptId,
                m.getManuscriptCode() + " rejected: " + trimmed);

        return saved;
    }
}
