package com.epms.controller;

import com.epms.dto.request.EditorialDecisionRequest;
import com.epms.dto.response.ApiResponse;
import com.epms.security.service.CurrentUserService;
import com.epms.service.EditorialService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * Epic 2 (US11 - US15). The chief editor-only paths (overview, counts, editors,
 * ready, assign) are restricted in SecurityConfig.
 */
@RestController
@RequestMapping("/api/editorial")
@RequiredArgsConstructor
public class EditorialController {

    private final EditorialService service;
    private final CurrentUserService currentUserService;

    @GetMapping("/overview")
    public ApiResponse<?> overview(@RequestParam(required = false) String status) {
        return new ApiResponse<>(true, "Editorial overview", service.overview(status));
    }

    @GetMapping("/counts")
    public ApiResponse<?> counts() {
        return new ApiResponse<>(true, "Editorial counts", service.counts());
    }

    @GetMapping("/editors")
    public ApiResponse<?> editors() {
        return new ApiResponse<>(true, "Editors", service.editors());
    }

    /**
     * Phase 1: Chief Editor dropdown — manuscripts accepted by Super Admin
     * and not yet assigned to an editor.
     */

    /** Review History dropdown — every manuscript in every status. */
    @GetMapping("/manuscripts/for-history")
    public ApiResponse<?> forHistory() {
        return new ApiResponse<>(true, "All manuscripts", service.allForHistory());
    }

    @GetMapping("/manuscripts/ready")
    public ApiResponse<?> ready() {
        return new ApiResponse<>(true, "Manuscripts ready for assignment", service.readyForAssignment());
    }

    @PostMapping("/manuscripts/{id}/assign")
    public ApiResponse<?> assign(@PathVariable Long id,
                                 @RequestParam Long editorId,
                                 @RequestParam(required = false) String remarks,
                                 Authentication auth) {
        return new ApiResponse<>(true, "Editor assigned",
                service.assign(id, editorId, currentUserService.getCurrentUserId(auth), remarks));
    }


    /** Cancel editor assignment — manuscript returns to ready queue. Chief Editor only. */
    @DeleteMapping("/manuscripts/{id}/assignment")
    public ApiResponse<?> cancelAssignment(@PathVariable Long id, Authentication auth) {
        return new ApiResponse<>(true, "Assignment cancelled",
                service.cancelAssignment(id, currentUserService.getCurrentUserId(auth)));
    }

    @GetMapping("/my-manuscripts")
    public ApiResponse<?> mine(Authentication auth) {
        return new ApiResponse<>(true, "Assigned manuscripts",
                service.myAssigned(currentUserService.getCurrentUserId(auth)));
    }

    @GetMapping("/manuscripts/{id}")
    public ApiResponse<?> detail(@PathVariable Long id, Authentication auth) {
        return new ApiResponse<>(true, "Manuscript",
                service.detail(currentUserService.getCurrentUser(auth), id));
    }

    @PostMapping("/manuscripts/{id}/decision")
    public ApiResponse<?> decide(@PathVariable Long id,
                                 @Valid @RequestBody EditorialDecisionRequest request,
                                 Authentication auth) {
        return new ApiResponse<>(true, "Decision recorded",
                service.decide(currentUserService.getCurrentUser(auth), id, request));
    }
}
