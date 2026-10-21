package com.epms.service;

import com.epms.dto.request.EditorialDecisionRequest;
import com.epms.dto.response.ManuscriptDetail;
import com.epms.dto.response.ManuscriptSummary;
import com.epms.entity.EditorialReview;
import com.epms.entity.Manuscript;
import com.epms.entity.ManuscriptRevision;
import com.epms.entity.User;
import com.epms.enums.ManuscriptStatus;
import com.epms.enums.Role;
import com.epms.exception.InvalidRequestException;
import com.epms.exception.ResourceNotFoundException;
import com.epms.repository.EditorialReviewRepository;
import com.epms.repository.ManuscriptRepository;
import com.epms.repository.ManuscriptRevisionRepository;
import com.epms.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/** Epic 2 (US11 - US15): assignment, editorial review and revision requests. */
@Service
@RequiredArgsConstructor
@Transactional
public class EditorialService {

    private final ManuscriptRepository manuscriptRepository;
    private final EditorialReviewRepository reviewRepository;
    private final ManuscriptRevisionRepository revisionRepository;
    private final UserRepository userRepository;
    private final ManuscriptWorkflow workflow;
    private final ManuscriptQueryService queries;
    private final AuditService auditService;

    /** Editors a manuscript can be assigned to. */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> editors() {
        List<Manuscript> active = manuscriptRepository.findByStatusInOrderByUpdatedAtDesc(ManuscriptStatus.EDITORIAL);
        Map<Long, Long> load = active.stream().filter(m -> m.getAssignedEditorId() != null)
                .collect(Collectors.groupingBy(Manuscript::getAssignedEditorId, Collectors.counting()));
        // Assignable editors only — Chief Editor is not listed as an editor
        return userRepository.findByRoleInOrderByFullName(List.of(Role.EDITOR)).stream()
                .filter(u -> "ACTIVE".equals(u.getAccountStatus()))
                .map(u -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("userId", u.getUserId());
                    m.put("fullName", u.getFullName());
                    m.put("role", u.getRole());
                    m.put("activeManuscripts", load.getOrDefault(u.getUserId(), 0L));
                    return m;
                }).collect(Collectors.toList());
    }

    /**
     * US15: manuscript lists for Chief Editor.
     * - No status filter → every manuscript (used by Review History dropdown).
     * - With status filter → only that status (Assigned Manuscripts filter).
     */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> overview(String status) {
        if (status == null || status.isBlank()) {
            // Review History needs every manuscript regardless of state
            return queries.summaries(manuscriptRepository.findAllByOrderByUpdatedAtDesc());
        }
        return queries.summaries(
                manuscriptRepository.findByStatusInOrderByUpdatedAtDesc(List.of(status.toUpperCase())));
    }

    /** Explicit list for Review History lookup — all manuscripts, all statuses. */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> allForHistory() {
        return queries.summaries(manuscriptRepository.findAllByOrderByUpdatedAtDesc());
    }

    /**
     * Phase 1: manuscripts accepted by Super Admin and not yet assigned.
     * Use this for the Chief Editor manuscript dropdown.
     */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> readyForAssignment() {
        return queries.summaries(
                manuscriptRepository.findByStatusInOrderByUpdatedAtDesc(ManuscriptStatus.CHIEF_EDITOR_QUEUE)
                        .stream()
                        .filter(m -> m.getAssignedEditorId() == null)
                        .toList());
    }

    /** US12: the editor's own queue — only manuscripts still in active review. */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> myAssigned(Long editorId) {
        List<Manuscript> all = manuscriptRepository.findByAssignedEditorIdOrderByUpdatedAtDesc(editorId);
        List<String> active = List.of(
                ManuscriptStatus.UNDER_REVIEW,
                ManuscriptStatus.REVISION_REQUESTED,
                ManuscriptStatus.RESUBMITTED);
        List<Manuscript> filtered = all.stream()
                .filter(m -> active.contains(m.getStatus()))
                .collect(Collectors.toList());
        return queries.summaries(filtered);
    }

    @Transactional(readOnly = true)
    public ManuscriptDetail detail(User viewer, Long manuscriptId) {
        Manuscript m = workflow.get(manuscriptId);
        workflow.requireReadable(viewer, m);
        return queries.detail(m);
    }

    /** US11: the chief editor assigns (or reassigns) the responsible editor. */
    public Manuscript assign(Long manuscriptId, Long editorId, Long chiefEditorId) {
        return assign(manuscriptId, editorId, chiefEditorId, null);
    }

    public Manuscript assign(Long manuscriptId, Long editorId, Long chiefEditorId, String remarks) {
        Manuscript m = workflow.get(manuscriptId);
        // Only post–Super-Admin statuses (SUBMITTED etc.). PENDING_SUPER_ADMIN_REVIEW is not allowed.
        workflow.requireStatus(m, "assign", ManuscriptStatus.SUBMITTED, ManuscriptStatus.UNDER_REVIEW,
                ManuscriptStatus.REVISION_REQUESTED, ManuscriptStatus.RESUBMITTED);
        User editor = userRepository.findById(editorId)
                .orElseThrow(() -> new ResourceNotFoundException("Editor not found: " + editorId));
        if (editor.getRole() != Role.EDITOR) {
            throw new InvalidRequestException(editor.getFullName() + " is not an editor (Chief Editor cannot be assigned as editor)");
        }
        if (!"ACTIVE".equals(editor.getAccountStatus())) {
            throw new InvalidRequestException(editor.getFullName() + "'s account is not active");
        }
        if (m.getAssignedEditorId() != null && m.getAssignedEditorId().equals(editorId)) {
            throw new InvalidRequestException(editor.getFullName() + " is already assigned to this manuscript");
        }
        boolean reassign = m.getAssignedEditorId() != null;
        m.setAssignedEditorId(editorId);
        m.setAssignedBy(chiefEditorId);
        m.setAssignedAt(LocalDateTime.now());
        String note = (remarks == null || remarks.isBlank()) ? null : remarks.trim();
        if (note != null && note.length() > 500) {
            throw new InvalidRequestException("Remarks must be 500 characters or fewer");
        }
        m.setAssignmentRemarks(note);
        String remark = (reassign ? "Reassigned to " : "Assigned to ") + editor.getFullName()
                + (note != null ? (": " + note) : "");
        Manuscript saved = ManuscriptStatus.SUBMITTED.equals(m.getStatus())
                ? workflow.changeStatus(m, ManuscriptStatus.UNDER_REVIEW, chiefEditorId, remark)
                : recordOnly(m, chiefEditorId, remark);
        auditService.record(chiefEditorId, "MANUSCRIPT_ASSIGNED", "Manuscript", manuscriptId, remark);
        return saved;
    }

    private Manuscript recordOnly(Manuscript m, Long userId, String remark) {
        return workflow.changeStatus(m, m.getStatus(), userId, remark);
    }

    /**
     * US13 / US14: records the review for this round and applies the
     * decision. A revision request needs a deadline and creates the next
     * revision round for the author to answer.
     */
    public EditorialReview decide(User reviewer, Long manuscriptId, EditorialDecisionRequest r) {
        Manuscript m = workflow.get(manuscriptId);
        boolean chief = reviewer.getRole() == Role.CHIEF_EDITOR;
        if (!chief && !reviewer.getUserId().equals(m.getAssignedEditorId())) {
            throw new AccessDeniedException("Only the assigned editor can review this manuscript");
        }
        workflow.requireStatus(m, "review", ManuscriptStatus.UNDER_REVIEW, ManuscriptStatus.RESUBMITTED);

        String decision = r.getDecision();
        if ("REVISION_REQUIRED".equals(decision) && r.getRevisionDeadline() == null) {
            throw new InvalidRequestException("Set a revision deadline when requesting a revision");
        }

        EditorialReview review = new EditorialReview();
        review.setManuscriptId(manuscriptId);
        review.setReviewerId(reviewer.getUserId());
        review.setReviewRound((int) reviewRepository.countByManuscriptId(manuscriptId) + 1);
        review.setReviewComments(r.getComments().trim());
        review.setDecision(decision);
        review.setReviewedAt(LocalDateTime.now());
        EditorialReview saved = reviewRepository.save(review);

        switch (decision) {
            case "ACCEPT" -> workflow.changeStatus(m, ManuscriptStatus.EDITORIALLY_ACCEPTED, reviewer.getUserId(),
                    "Editorially accepted in review round " + saved.getReviewRound());
            case "REJECT" -> workflow.changeStatus(m, ManuscriptStatus.REJECTED, reviewer.getUserId(),
                    "Rejected in review round " + saved.getReviewRound());
            default -> {
                ManuscriptRevision rev = new ManuscriptRevision();
                rev.setManuscriptId(manuscriptId);
                rev.setReviewerId(reviewer.getUserId());
                rev.setRevisionRound((int) revisionRepository.countByManuscriptId(manuscriptId) + 1);
                rev.setEditorComments(r.getComments().trim());
                rev.setResponseDeadline(r.getRevisionDeadline());
                rev.setStatus(ManuscriptRevision.PENDING);
                revisionRepository.save(rev);
                workflow.changeStatus(m, ManuscriptStatus.REVISION_REQUESTED, reviewer.getUserId(),
                        "Revision round " + rev.getRevisionRound() + " requested, due " + r.getRevisionDeadline());
            }
        }
        auditService.record(reviewer.getUserId(), "EDITORIAL_DECISION", "Manuscript", manuscriptId,
                decision + " (round " + saved.getReviewRound() + ")");
        return saved;
    }


    /**
     * Cancel the current editor assignment. Manuscript returns to the ready
     * queue (SUBMITTED, unassigned) so the Chief Editor can assign again.
     */
    public Manuscript cancelAssignment(Long manuscriptId, Long chiefEditorId) {
        Manuscript m = workflow.get(manuscriptId);
        if (m.getAssignedEditorId() == null) {
            throw new InvalidRequestException("This manuscript has no active editor assignment");
        }
        // Only while the first review is still open — not after revision requests or final decisions
        workflow.requireStatus(m, "cancel assignment", ManuscriptStatus.SUBMITTED, ManuscriptStatus.UNDER_REVIEW);
        Long previous = m.getAssignedEditorId();
        m.setAssignedEditorId(null);
        m.setAssignedBy(null);
        m.setAssignedAt(null);
        m.setAssignmentRemarks(null);
        String remark = "Assignment cancelled (previous editor userId=" + previous + ")";
        // Return to SUBMITTED so it appears in the ready dropdown again
        Manuscript saved = workflow.changeStatus(m, ManuscriptStatus.SUBMITTED, chiefEditorId, remark);
        auditService.record(chiefEditorId, "MANUSCRIPT_UNASSIGNED", "Manuscript", manuscriptId, remark);
        return saved;
    }

    /** Counts per status for the chief editor's dashboard. */
    @Transactional(readOnly = true)
    public Map<String, Long> counts() {
        Map<String, Long> out = new LinkedHashMap<>();
        for (String s : List.of(ManuscriptStatus.SUBMITTED, ManuscriptStatus.UNDER_REVIEW,
                ManuscriptStatus.REVISION_REQUESTED, ManuscriptStatus.RESUBMITTED,
                ManuscriptStatus.EDITORIALLY_ACCEPTED, ManuscriptStatus.REJECTED)) {
            out.put(s, manuscriptRepository.countByStatus(s));
        }
        return out;
    }
}
