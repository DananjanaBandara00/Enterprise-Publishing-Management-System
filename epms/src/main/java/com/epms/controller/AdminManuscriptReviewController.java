package com.epms.controller;

import com.epms.dto.request.ReasonRequest;
import com.epms.dto.response.ApiResponse;
import com.epms.security.service.CurrentUserService;
import com.epms.service.AdminManuscriptReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * Super Admin (role ADMIN) manuscript gate before Chief Editor assignment.
 *
 * Author submit → PENDING_SUPER_ADMIN_REVIEW
 * GET  /pending  → Super Admin queue
 * POST /{id}/accept → SUBMITTED (Chief Editor sees it)
 * POST /{id}/reject → REJECTED_BY_ADMIN
 *
 * Secured by existing rule: /api/admin/** → hasRole(ADMIN)
 */
@RestController
@RequestMapping("/api/admin/manuscript-review")
@RequiredArgsConstructor
public class AdminManuscriptReviewController {

    private final AdminManuscriptReviewService service;
    private final CurrentUserService currentUserService;

    /** Super Admin queue: manuscripts waiting for accept/reject. */
    @GetMapping("/pending")
    public ApiResponse<?> pending() {
        return new ApiResponse<>(true, "Manuscripts pending Super Admin review", service.pendingReview());
    }

    /** Accept → status SUBMITTED → appears in Chief Editor manuscript dropdown. */
    @PostMapping("/{id}/accept")
    public ApiResponse<?> accept(@PathVariable Long id, Authentication auth) {
        return new ApiResponse<>(
                true,
                "Manuscript accepted and sent to Chief Editor",
                service.accept(id, currentUserService.getCurrentUserId(auth)));
    }

    /** Reject with reason → REJECTED_BY_ADMIN. Body: {"reason":"..."} */
    @PostMapping("/{id}/reject")
    public ApiResponse<?> reject(
            @PathVariable Long id,
            @Valid @RequestBody ReasonRequest body,
            Authentication auth) {
        return new ApiResponse<>(
                true,
                "Manuscript rejected by Super Admin",
                service.reject(id, currentUserService.getCurrentUserId(auth), body.getReason()));
    }
}
