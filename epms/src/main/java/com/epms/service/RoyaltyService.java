package com.epms.service;

import com.epms.contracts.dto.AuthorDto;
import com.epms.contracts.dto.BookDto;
import com.epms.dto.request.RoyaltyAgreementRequest;
import com.epms.dto.request.RoyaltyCalculationRequest;
import com.epms.dto.request.RoyaltyPayRequest;
import com.epms.dto.response.RoyaltyCalculationDetail;
import com.epms.dto.response.RoyaltyCalculationSummary;
import com.epms.dto.response.RoyaltyStatementResponse;
import com.epms.entity.RoyaltyAgreement;
import com.epms.entity.RoyaltyCalculation;
import com.epms.entity.RoyaltyPayment;

import java.util.List;

public interface RoyaltyService {

    // --- Agreements: DRAFT -> (author signs) -> ACTIVE -> EXPIRED (US41) ---

    List<RoyaltyAgreement> getAllAgreements();

    RoyaltyAgreement getAgreementById(Long id);

    List<RoyaltyAgreement> getAgreementsByAuthor(Long authorId);

    /** Author and book must exist (via the Epic 1/2 ports) and the book must belong to the author. */
    RoyaltyAgreement createAgreement(RoyaltyAgreementRequest request);

    /** Only DRAFT agreements can be edited; editing withdraws it from the author and clears the signature. */
    RoyaltyAgreement updateAgreement(Long id, RoyaltyAgreementRequest request);

    /** Makes an unsigned DRAFT visible to its author for signature and notifies them; sending again is a reminder. */
    RoyaltyAgreement sendToAuthor(Long id, Long userId);

    /**
     * Requires the author's signature; rejected if another ACTIVE agreement
     * for the same book overlaps these dates or the expiry date has passed.
     */
    RoyaltyAgreement activateAgreement(Long id);

    /** Rejected while a calculation is still CALCULATED, STATEMENT_ISSUED or APPROVED (unpaid). */
    RoyaltyAgreement expireAgreement(Long id);

    /** Expires ACTIVE agreements past their expiry date with nothing in progress; returns how many. */
    int expireLapsedAgreements();

    List<AuthorDto> getAuthors();

    List<BookDto> getBooks(Long authorId);

    // --- Calculations (US42, US43) ---

    List<RoyaltyCalculationSummary> getAll(String status);

    RoyaltyCalculation getById(Long id);

    RoyaltyCalculationDetail getDetail(Long id);

    List<RoyaltyCalculation> getByAuthor(Long authorId);

    /** Runs the full calculation and returns it without saving anything. */
    RoyaltyCalculationDetail preview(RoyaltyCalculationRequest request);

    /**
     * Validates the agreement is ACTIVE and covers the period (which must be
     * in the past), rejects any live calculation for the same agreement whose
     * period overlaps (service check + DB unique key backstop), then
     * calculates line by line from the COMPLETED sales of the agreement's
     * book, recoups the remaining advance and stores the header and lines.
     */
    RoyaltyCalculation calculate(RoyaltyCalculationRequest request, Long calculatedBy);

    /** Cancels a CALCULATED calculation (reason "Recalculated") and calculates the same period again. */
    RoyaltyCalculation recalculate(Long calculationId, Long userId);

    /** Only CALCULATED can be cancelled; frees the period and gives back the recouped advance. */
    RoyaltyCalculation cancel(Long calculationId, String reason, Long userId);

    // --- Statements, approval, payment (US44 - US46) ---

    RoyaltyCalculation issueStatement(Long calculationId, Long userId);

    RoyaltyStatementResponse getStatement(Long calculationId);

    /** STATEMENT_ISSUED -> APPROVED (creates the royalty payment), or CARRIED_FORWARD below the threshold. */
    RoyaltyCalculation approve(Long calculationId, Long userId);

    /**
     * CARRIED_FORWARD -> APPROVED (creates the royalty payment) for an amount below the
     * threshold that finance decides to pay now; rejected once it has been carried into
     * a later calculation. A reason is required.
     */
    RoyaltyCalculation releaseCarriedForward(Long calculationId, String reason, Long userId);

    /** STATEMENT_ISSUED -> CALCULATED (for correction) or CANCELLED. */
    RoyaltyCalculation reject(Long calculationId, String reason, boolean cancel, Long userId);

    /** APPROVED -> PAID; amount must equal the payable amount; posts a ROYALTY expense. */
    RoyaltyPayment pay(Long calculationId, RoyaltyPayRequest request, Long userId);

    // --- Author self-service (US47): always resolved from the logged-in user ---

    List<RoyaltyAgreement> getMyAgreements(Long userId);

    List<RoyaltyCalculationSummary> getMyStatements(Long userId);

    /** 403 if the statement belongs to another author. */
    RoyaltyStatementResponse getMyStatement(Long userId, Long calculationId);

    List<RoyaltyPayment> getMyPayments(Long userId);
}
