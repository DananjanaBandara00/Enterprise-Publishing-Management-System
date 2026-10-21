package com.epms.controller;

import com.epms.dto.request.AnnouncementRequest;
import com.epms.dto.response.ApiResponse;
import com.epms.security.service.CurrentUserService;
import com.epms.service.AnnouncementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/** Customer promotions (sales, offers, ads) shown in the homepage hero carousel. */
@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;
    private final CurrentUserService currentUserService;

    @GetMapping
    public ApiResponse<?> getAll() {
        return new ApiResponse<>(true, "Announcements retrieved", announcementService.getAll());
    }

    /** Live customer promotions for the homepage hero carousel; public, no login needed. */
    @GetMapping("/public")
    public ApiResponse<?> getPublic() {
        return new ApiResponse<>(true, "Active promotions retrieved", announcementService.getActiveForCustomers());
    }

    @PostMapping
    public ApiResponse<?> create(@Valid @RequestBody AnnouncementRequest request, Authentication authentication) {
        Long userId = currentUserService.getCurrentUserId(authentication);
        return new ApiResponse<>(true, "Announcement created", announcementService.create(request, userId));
    }

    @PutMapping("/{id}")
    public ApiResponse<?> update(@PathVariable Long id, @Valid @RequestBody AnnouncementRequest request) {
        return new ApiResponse<>(true, "Announcement updated", announcementService.update(id, request));
    }

    @PostMapping(value = "/{id}/image", consumes = "multipart/form-data")
    public ApiResponse<?> uploadImage(@PathVariable Long id, @RequestParam("file") MultipartFile file) {
        return new ApiResponse<>(true, "Image uploaded", announcementService.uploadImage(id, file));
    }

    @DeleteMapping("/{id}/image")
    public ApiResponse<?> removeImage(@PathVariable Long id) {
        return new ApiResponse<>(true, "Image removed", announcementService.removeImage(id));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<?> delete(@PathVariable Long id) {
        announcementService.delete(id);
        return new ApiResponse<>(true, "Announcement deleted", null);
    }
}
