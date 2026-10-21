package com.epms.service;

import com.epms.dto.request.QualityCheckRequest;
import com.epms.dto.response.ManuscriptSummary;
import com.epms.dto.request.ReadyForPrintingRequest;
import com.epms.entity.Author;
import com.epms.entity.AuthorApproval;
import com.epms.entity.BookDesign;
import com.epms.entity.Manuscript;
import com.epms.entity.PublishedBook;
import com.epms.entity.QualityCheck;
import com.epms.enums.ManuscriptStatus;
import com.epms.exception.BusinessRuleException;
import com.epms.exception.InvalidRequestException;
import com.epms.exception.ResourceNotFoundException;
import com.epms.repository.AuthorApprovalRepository;
import com.epms.repository.BookDesignRepository;
import com.epms.repository.CategoryRepository;
import com.epms.repository.ManuscriptRepository;
import com.epms.repository.PublishedBookRepository;
import com.epms.repository.QualityCheckRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Epic 2 (US16 - US20): design versions, the author's design approval,
 * the production quality check and handing the book over for printing.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class DesignProductionService {

    public static final long MAX_COVER_BYTES = 5L * 1024 * 1024;
    public static final long MAX_PDF_BYTES = 25L * 1024 * 1024;

    /** Production quality checklist (US19); every item must pass. */
    public static final Map<String, String> CHECKLIST = new LinkedHashMap<>();

    static {
        CHECKLIST.put("coverResolution", "Cover artwork is print resolution and matches the trim size");
        CHECKLIST.put("layoutMatchesManuscript", "Interior layout matches the accepted manuscript");
        CHECKLIST.put("printFileValid", "Print-ready PDF has bleed, crop marks and embedded fonts");
        CHECKLIST.put("metadataCorrect", "Title, author name and spine text are correct");
        CHECKLIST.put("proofread", "Final proofread completed");
    }

    private final ManuscriptRepository manuscriptRepository;
    private final BookDesignRepository designRepository;
    private final AuthorApprovalRepository approvalRepository;
    private final QualityCheckRepository qualityCheckRepository;
    private final PublishedBookRepository bookRepository;
    private final CategoryRepository categoryRepository;
    private final ManuscriptWorkflow workflow;
    private final ManuscriptQueryService queries;
    private final DocumentStorageService storage;
    private final AuthorPortalService authorPortal;
    private final AuditService auditService;
    private final ObjectMapper objectMapper;
    private final com.epms.repository.DesignAssignmentRepository assignmentRepository;
    private final com.epms.repository.UserRepository userRepository;
    private final UserNames names;

    // ---------- design queue ----------

    /** The designer's own work: manuscripts assigned to them (current and completed). */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> designQueue(Long designerId) {
        List<Long> ids = assignmentRepository.findByDesignerIdAndAssignmentStatusIn(designerId, List.of("ACTIVE", "COMPLETED"))
                .stream().map(com.epms.entity.DesignAssignment::getManuscriptId).distinct().toList();
        return queries.summaries(manuscriptRepository.findAllById(ids).stream()
                .sorted((a, b) -> b.getUpdatedAt().compareTo(a.getUpdatedAt())).toList());
    }

    // ---------- design assignments (production manager) ----------

    /** Accepted manuscripts still waiting for a designer. */
    @Transactional(readOnly = true)
    public List<ManuscriptSummary> awaitingDesigner() {
        // Only books that still need a first designer — not QC-fail rework (QC_FAILED) or in-progress design.
        return queries.summaries(manuscriptRepository.findByStatusInOrderByUpdatedAtDesc(List.of(
                        ManuscriptStatus.EDITORIALLY_ACCEPTED, ManuscriptStatus.ACCEPTED)).stream()
                .filter(m -> assignmentRepository.findFirstByManuscriptIdAndAssignmentStatus(m.getManuscriptId(), "ACTIVE").isEmpty())
                .filter(m -> assignmentRepository.findFirstByManuscriptIdAndAssignmentStatus(m.getManuscriptId(), "COMPLETED").isEmpty())
                .toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> designers() {
        return userRepository.findByRoleInOrderByFullName(List.of(com.epms.enums.Role.DESIGNER)).stream()
                .filter(u -> "ACTIVE".equals(u.getAccountStatus()))
                .map(u -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("userId", u.getUserId());
                    m.put("fullName", u.getFullName());
                    m.put("activeAssignments", assignmentRepository
                            .findByDesignerIdAndAssignmentStatusIn(u.getUserId(), List.of("ACTIVE")).size());
                    return m;
                }).toList();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> activeAssignments() {
        // Only first-time design work. After author approval / QC, assignment is COMPLETED
        // and must not reappear here (QC-fail rework uses COMPLETED + designer queue).
        java.util.Set<String> visible = java.util.Set.of(
                ManuscriptStatus.EDITORIALLY_ACCEPTED, ManuscriptStatus.ACCEPTED,
                ManuscriptStatus.IN_DESIGN, ManuscriptStatus.AWAITING_AUTHOR_APPROVAL);
        return assignmentRepository.findByAssignmentStatusOrderByAssignedAtDesc("ACTIVE").stream()
                .map(a -> {
                    Manuscript m = manuscriptRepository.findById(a.getManuscriptId()).orElse(null);
                    if (m == null || !visible.contains(m.getStatus())) {
                        return null;
                    }
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("assignment", a);
                    row.put("manuscriptCode", m.getManuscriptCode());
                    row.put("title", m.getTitle());
                    row.put("manuscriptStatus", m.getStatus());
                    row.put("designerName", names.user(a.getDesignerId()));
                    return row;
                })
                .filter(java.util.Objects::nonNull)
                .toList();
    }

    /** Assigns (or reassigns) the designer; the previous active assignment is cancelled. */
    public com.epms.entity.DesignAssignment assignDesigner(Long managerId, Long manuscriptId, Long designerId, String remarks) {
        Manuscript m = workflow.get(manuscriptId);
        workflow.requireStatus(m, "assign a designer to", ManuscriptStatus.EDITORIALLY_ACCEPTED, ManuscriptStatus.ACCEPTED, ManuscriptStatus.IN_DESIGN,
                ManuscriptStatus.AWAITING_AUTHOR_APPROVAL);
        com.epms.entity.User designer = userRepository.findById(designerId)
                .orElseThrow(() -> new ResourceNotFoundException("Designer not found: " + designerId));
        if (designer.getRole() != com.epms.enums.Role.DESIGNER || !"ACTIVE".equals(designer.getAccountStatus())) {
            throw new InvalidRequestException(designer.getFullName() + " is not an active designer");
        }
        assignmentRepository.findFirstByManuscriptIdAndAssignmentStatus(manuscriptId, "ACTIVE").ifPresent(prev -> {
            if (prev.getDesignerId().equals(designerId)) {
                throw new BusinessRuleException(designer.getFullName() + " is already the designer of this manuscript");
            }
            prev.setAssignmentStatus("CANCELLED");
            prev.setCompletedAt(LocalDateTime.now());
            assignmentRepository.saveAndFlush(prev);
        });
        com.epms.entity.DesignAssignment a = new com.epms.entity.DesignAssignment();
        a.setManuscriptId(manuscriptId);
        a.setDesignerId(designerId);
        a.setAssignedBy(managerId);
        a.setAssignmentStatus("ACTIVE");
        a.setRemarks(remarks == null || remarks.isBlank() ? null : remarks.trim());
        com.epms.entity.DesignAssignment saved = assignmentRepository.save(a);
        workflow.changeStatus(m, m.getStatus(), managerId, "Designer assigned: " + designer.getFullName());
        return saved;
    }

    public void cancelAssignment(Long managerId, Long assignmentId) {
        com.epms.entity.DesignAssignment a = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found: " + assignmentId));
        if (!"ACTIVE".equals(a.getAssignmentStatus())) {
            throw new BusinessRuleException("Only an active assignment can be cancelled");
        }
        a.setAssignmentStatus("CANCELLED");
        a.setCompletedAt(LocalDateTime.now());
        assignmentRepository.save(a);
    }

    private void requireAssignedDesigner(Long designerId, Long manuscriptId) {
        // ACTIVE = in progress; COMPLETED = author approved (designer may still rework after QC fail)
        boolean assigned =
                assignmentRepository.findFirstByManuscriptIdAndAssignmentStatus(manuscriptId, "ACTIVE")
                        .map(a -> a.getDesignerId().equals(designerId)).orElse(false)
                        || assignmentRepository.findFirstByManuscriptIdAndAssignmentStatus(manuscriptId, "COMPLETED")
                        .map(a -> a.getDesignerId().equals(designerId)).orElse(false);
        if (!assigned) {
            throw new AccessDeniedException("You are not the assigned designer for this manuscript");
        }
    }

    @Transactional(readOnly = true)
    public List<ManuscriptSummary> productionQueue() {
        return queries.summaries(manuscriptRepository.findByStatusInOrderByUpdatedAtDesc(List.of(
                ManuscriptStatus.DESIGN_APPROVED, ManuscriptStatus.QC_PASSED, ManuscriptStatus.READY_FOR_PRINTING,
                ManuscriptStatus.PUBLISHED)));
    }

    /**
     * US16 / US17: every upload creates a new design version. Files not
     * uploaded this time are carried over from the previous version, so
     * nothing earlier is overwritten.
     */
    public BookDesign uploadVersion(Long designerId, Long manuscriptId, MultipartFile cover, MultipartFile layout,
                                    MultipartFile printFile, String notes) {
        Manuscript m = workflow.get(manuscriptId);
        requireAssignedDesigner(designerId, manuscriptId);
        workflow.requireStatus(m, "add a design version to", ManuscriptStatus.EDITORIALLY_ACCEPTED, ManuscriptStatus.ACCEPTED, ManuscriptStatus.IN_DESIGN, ManuscriptStatus.QC_FAILED);
        boolean hasCover = cover != null && !cover.isEmpty();
        boolean hasLayout = layout != null && !layout.isEmpty();
        boolean hasPrint = printFile != null && !printFile.isEmpty();
        if (!hasCover && !hasLayout && !hasPrint) {
            throw new InvalidRequestException("Upload at least one file: cover image, interior layout or print-ready PDF");
        }

        BookDesign previous = designRepository.findFirstByManuscriptIdOrderByDesignVersionDesc(manuscriptId).orElse(null);
        String folder = "designs/" + manuscriptId;
        BookDesign d = new BookDesign();
        d.setManuscriptId(manuscriptId);
        d.setDesignerId(designerId);
        d.setDesignVersion(designRepository.maxVersion(manuscriptId) + 1);
        d.setCoverFilePath(hasCover ? storage.store(cover, folder, DocumentStorageService.IMAGE_TYPES, MAX_COVER_BYTES, "cover image")
                : previous == null ? null : previous.getCoverFilePath());
        d.setLayoutFilePath(hasLayout ? storage.store(layout, folder, DocumentStorageService.PDF_TYPES, MAX_PDF_BYTES, "interior layout")
                : previous == null ? null : previous.getLayoutFilePath());
        d.setPrintFilePath(hasPrint ? storage.store(printFile, folder, DocumentStorageService.PDF_TYPES, MAX_PDF_BYTES, "print-ready PDF")
                : previous == null ? null : previous.getPrintFilePath());
        d.setDesignNotes(notes == null || notes.isBlank() ? null : notes.trim());
        d.setDesignStatus(BookDesign.DRAFT);
        if (previous != null && BookDesign.DRAFT.equals(previous.getDesignStatus())) {
            previous.setDesignStatus(BookDesign.SUPERSEDED);
            designRepository.save(previous);
        }
        BookDesign saved = designRepository.save(d);
        // First-time design only. QC_FAILED stays QC_FAILED until designer resubmits to QC.
        if (ManuscriptStatus.EDITORIALLY_ACCEPTED.equals(m.getStatus()) || ManuscriptStatus.ACCEPTED.equals(m.getStatus())) {
            workflow.changeStatus(m, ManuscriptStatus.IN_DESIGN, designerId, "Design version 1 uploaded");
        }
        return saved;
    }

    /** Sends the latest complete version to the author for approval (US18). */
    public BookDesign submitForApproval(Long designerId, Long designId) {
        BookDesign d = design(designId);
        Manuscript m = workflow.get(d.getManuscriptId());
        requireAssignedDesigner(designerId, m.getManuscriptId());
        workflow.requireStatus(m, "send a design for approval on", ManuscriptStatus.IN_DESIGN, ManuscriptStatus.QC_FAILED);
        BookDesign latest = designRepository.findFirstByManuscriptIdOrderByDesignVersionDesc(m.getManuscriptId()).orElseThrow();
        if (!latest.getDesignId().equals(designId)) {
            throw new BusinessRuleException("Only the latest design version (v" + latest.getDesignVersion() + ") can be sent for approval");
        }
        if (d.getCoverFilePath() == null || d.getLayoutFilePath() == null || d.getPrintFilePath() == null) {
            throw new BusinessRuleException("A design needs a cover image, an interior layout and a print-ready PDF before the author can approve it");
        }
        // After a failed QC, fixes are technical — skip author and return to QC queue.
        // Normal first-time design (no failed QC) still goes to the author unchanged.
        boolean resubmitAfterQcFail = qualityCheckRepository
                .findByManuscriptIdOrderByCheckedAtDesc(m.getManuscriptId()).stream()
                .findFirst()
                .map(q -> "FAILED".equals(q.getResult()))
                .orElse(false);
        if (resubmitAfterQcFail) {
            // Supersede any previous APPROVED design so QC picks this version
            designRepository.findFirstByManuscriptIdAndDesignStatusOrderByDesignVersionDesc(
                    m.getManuscriptId(), BookDesign.APPROVED).ifPresent(prev -> {
                if (!prev.getDesignId().equals(d.getDesignId())) {
                    prev.setDesignStatus(BookDesign.SUPERSEDED);
                    designRepository.save(prev);
                }
            });
            d.setDesignStatus(BookDesign.APPROVED);
            d.setSubmittedAt(LocalDateTime.now());
            BookDesign saved = designRepository.save(d);
            workflow.changeStatus(m, ManuscriptStatus.DESIGN_APPROVED, designerId,
                    "Design v" + d.getDesignVersion() + " resubmitted for quality check after QC fail");
            return saved;
        }
        d.setDesignStatus(BookDesign.SUBMITTED);
        d.setSubmittedAt(LocalDateTime.now());
        BookDesign saved = designRepository.save(d);
        workflow.changeStatus(m, ManuscriptStatus.AWAITING_AUTHOR_APPROVAL, designerId,
                "Design v" + d.getDesignVersion() + " sent to the author");
        return saved;
    }

    /** US18: the author approves or rejects the submitted design, with comments. */
    public AuthorApproval authorDecision(Long authorUserId, Long designId, boolean approve, String comments) {
        BookDesign d = design(designId);
        Manuscript m = workflow.get(d.getManuscriptId());
        Author author = authorPortal.authorFor(authorUserId);
        if (!author.getAuthorId().equals(m.getAuthorId())) {
            throw new AccessDeniedException("You can only approve designs of your own books");
        }
        if (!BookDesign.SUBMITTED.equals(d.getDesignStatus())) {
            throw new BusinessRuleException("This design version is not waiting for your approval");
        }
        if (!approve && (comments == null || comments.isBlank())) {
            throw new InvalidRequestException("Tell the designer what to change when rejecting a design");
        }
        AuthorApproval a = new AuthorApproval();
        a.setDesignId(designId);
        a.setAuthorId(author.getAuthorId());
        a.setApprovalStatus(approve ? "APPROVED" : "REJECTED");
        a.setComments(comments == null || comments.isBlank() ? null : comments.trim());
        a.setReviewedAt(LocalDateTime.now());
        AuthorApproval saved = approvalRepository.save(a);
        d.setDesignStatus(approve ? BookDesign.APPROVED : BookDesign.REJECTED);
        designRepository.save(d);
        workflow.changeStatus(m, approve ? ManuscriptStatus.DESIGN_APPROVED : ManuscriptStatus.IN_DESIGN, authorUserId,
                "Author " + (approve ? "approved" : "rejected") + " design v" + d.getDesignVersion());
        if (approve) {
            assignmentRepository.findFirstByManuscriptIdAndAssignmentStatus(m.getManuscriptId(), "ACTIVE").ifPresent(x -> {
                x.setAssignmentStatus("COMPLETED");
                x.setCompletedAt(LocalDateTime.now());
                assignmentRepository.save(x);
            });
        }
        return saved;
    }

    /** Designs waiting for the logged-in author's decision. */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> pendingForAuthor(Long authorUserId) {
        Long authorId = authorPortal.authorFor(authorUserId).getAuthorId();
        return manuscriptRepository.findByAuthorIdOrderByUpdatedAtDesc(authorId).stream()
                .filter(m -> ManuscriptStatus.AWAITING_AUTHOR_APPROVAL.equals(m.getStatus()))
                .map(m -> {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("manuscript", m);
                    row.put("design", designRepository.findFirstByManuscriptIdAndDesignStatusOrderByDesignVersionDesc(
                            m.getManuscriptId(), BookDesign.SUBMITTED).orElse(null));
                    return row;
                }).toList();
    }

    /** US19: production quality check of the approved design. */
    public QualityCheck qualityCheck(Long managerId, Long manuscriptId, QualityCheckRequest r) {
        Manuscript m = workflow.get(manuscriptId);
        workflow.requireStatus(m, "quality check", ManuscriptStatus.DESIGN_APPROVED);
        for (String key : CHECKLIST.keySet()) {
            if (!r.getChecklist().containsKey(key)) {
                throw new InvalidRequestException("Answer every checklist item (missing: " + CHECKLIST.get(key) + ")");
            }
        }
        boolean passed = CHECKLIST.keySet().stream().allMatch(k -> Boolean.TRUE.equals(r.getChecklist().get(k)));
        if (!passed && (r.getNotes() == null || r.getNotes().isBlank())) {
            throw new InvalidRequestException("Add notes explaining what failed the quality check");
        }
        BookDesign approved = designRepository.findFirstByManuscriptIdAndDesignStatusOrderByDesignVersionDesc(
                manuscriptId, BookDesign.APPROVED).orElseThrow(() -> new BusinessRuleException("No approved design found"));
        QualityCheck qc = new QualityCheck();
        qc.setManuscriptId(manuscriptId);
        qc.setDesignId(approved.getDesignId());
        qc.setCheckedBy(managerId);
        qc.setResult(passed ? "PASSED" : "FAILED");
        try {
            qc.setChecklist(objectMapper.writeValueAsString(r.getChecklist()));
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
        qc.setNotes(r.getNotes() == null || r.getNotes().isBlank() ? null : r.getNotes().trim());
        qc.setCheckedAt(LocalDateTime.now());
        QualityCheck saved = qualityCheckRepository.save(qc);
        if (passed) {
            workflow.changeStatus(m, ManuscriptStatus.QC_PASSED, managerId,
                    "Quality check passed" + (qc.getNotes() == null ? "" : ": " + qc.getNotes()));
        } else {
            // QC fail only: QC_FAILED (not IN_DESIGN) so it does not appear under
            // "Accepted books waiting for a designer". Assignment stays COMPLETED; same designer
            // reworks via My Design Work. QC pass path unchanged.
            workflow.changeStatus(m, ManuscriptStatus.QC_FAILED, managerId,
                    "Quality check failed" + (qc.getNotes() == null ? "" : ": " + qc.getNotes())
                            + " — returned to designer for fixes, then resubmit to QC");
        }
        return saved;
    }

    /** US20: creates the book record and hands it over for printing. */
    public PublishedBook markReadyForPrinting(Long managerId, Long manuscriptId, ReadyForPrintingRequest r) {
        Manuscript m = workflow.get(manuscriptId);
        workflow.requireStatus(m, "mark ready for printing", ManuscriptStatus.QC_PASSED);
        if (bookRepository.findByManuscriptId(manuscriptId).isPresent()) {
            throw new BusinessRuleException("A book already exists for manuscript " + m.getManuscriptCode());
        }
        String isbn;
        if (r.getIsbn() != null && !r.getIsbn().isBlank()) {
            isbn = r.getIsbn().trim();
            if (bookRepository.existsByIsbn(isbn)) {
                throw new BusinessRuleException("ISBN " + isbn + " is already used by another book");
            }
        } else {
            isbn = generateUniqueIsbn();
        }
        Long categoryId = r.getCategoryId() != null ? r.getCategoryId() : m.getCategoryId();
        if (categoryId == null) {
            throw new InvalidRequestException("Category is required");
        }
        if (!categoryRepository.existsById(categoryId)) {
            throw new InvalidRequestException("Category #" + categoryId + " does not exist");
        }
        BookDesign approved = designRepository.findFirstByManuscriptIdAndDesignStatusOrderByDesignVersionDesc(
                manuscriptId, BookDesign.APPROVED).orElseThrow(() -> new BusinessRuleException("No approved design found"));

        PublishedBook b = new PublishedBook();
        b.setManuscriptId(manuscriptId);
        b.setCategoryId(categoryId);
        b.setGenreId(m.getGenreId());
        b.setIsbn(isbn);
        b.setTitle(m.getTitle());
        b.setEdition(r.getEdition());
        b.setCoverImage(approved.getCoverFilePath());
        b.setPublicationDate(r.getPublicationDate());
        b.setPrice(r.getPrice());
        Integer pages = r.getTotalPages();
        if (pages == null) {
            // Prefer page count from the approved print-ready PDF (cover + interior)
            pages = storage.countPdfPages(approved.getPrintFilePath());
            if (pages == null && m.getWordCount() != null && m.getWordCount() > 0) {
                // Fallback: ~250 words per printed page
                pages = Math.max(1, (int) Math.ceil(m.getWordCount() / 250.0));
            }
        }
        b.setTotalPages(pages);
        b.setLanguage(m.getLanguage());
        b.setBookStatus(PublishedBook.READY_FOR_PRINTING);
        PublishedBook saved = bookRepository.save(b);
        workflow.changeStatus(m, ManuscriptStatus.READY_FOR_PRINTING, managerId,
                "Ready for printing as book #" + saved.getBookId() + ", ISBN " + isbn);
        auditService.record(managerId, "BOOK_READY_FOR_PRINTING", "Book", saved.getBookId(), m.getManuscriptCode());
        return saved;
    }

    /**
     * Internal unique ISBN-13 for demo / local publishing (prefix 978-955).
     * Format: 978-955-XXXXXX-C where C is the ISBN-13 check digit.
     */
    private String generateUniqueIsbn() {
        long seq = bookRepository.count() + 1;
        for (int attempt = 0; attempt < 1000; attempt++) {
            String body = String.format("978955%06d", (seq + attempt) % 1_000_000);
            int check = isbn13CheckDigit(body);
            String isbn = body.substring(0, 3) + "-" + body.substring(3, 6) + "-"
                    + body.substring(6, 12) + "-" + check;
            if (!bookRepository.existsByIsbn(isbn) && !bookRepository.existsByIsbn(body + check)) {
                return isbn;
            }
        }
        throw new BusinessRuleException("Could not allocate a unique ISBN; try again");
    }

    /** ISBN-13 check digit for the first 12 digits (digits only). */
    private static int isbn13CheckDigit(String twelveDigits) {
        int sum = 0;
        for (int i = 0; i < 12; i++) {
            int d = twelveDigits.charAt(i) - '0';
            sum += (i % 2 == 0) ? d : 3 * d;
        }
        return (10 - (sum % 10)) % 10;
    }

    public BookDesign design(Long designId) {
        return designRepository.findById(designId)
                .orElseThrow(() -> new ResourceNotFoundException("Design not found: " + designId));
    }
}
