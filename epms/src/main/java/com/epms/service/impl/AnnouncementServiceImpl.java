package com.epms.service.impl;

import com.epms.dto.request.AnnouncementRequest;
import com.epms.entity.Announcement;
import com.epms.exception.BusinessRuleException;
import com.epms.exception.InvalidRequestException;
import com.epms.exception.ResourceNotFoundException;
import com.epms.repository.AnnouncementRepository;
import com.epms.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnnouncementServiceImpl implements AnnouncementService {

    private static final long MAX_IMAGE_BYTES = 5L * 1024 * 1024;
    private static final Map<String, String> EXTENSION_BY_TYPE = Map.of(
            "image/jpeg", "jpg", "image/png", "png", "image/webp", "webp");

    private final AnnouncementRepository announcementRepository;

    @Value("${epms.uploads.dir:uploads}")
    private String uploadsDir;

    @Override
    public List<Announcement> getAll() {
        return announcementRepository.findAllByOrderByCreatedAtDesc();
    }

    @Override
    public List<Announcement> getActiveForCustomers() {
        return announcementRepository.findAllByOrderByCreatedAtDesc().stream()
                .filter(a -> "ACTIVE".equals(a.getStatus()))
                .filter(a -> Announcement.CUSTOMER.equals(a.getAudience()))
                .collect(Collectors.toList());
    }

    @Override
    public Announcement create(AnnouncementRequest request, Long createdBy) {

        Announcement announcement = new Announcement();
        announcement.setCreatedBy(createdBy);
        apply(announcement, request);

        return announcementRepository.save(announcement);
    }

    @Override
    public Announcement update(Long id, AnnouncementRequest request) {

        Announcement announcement = getById(id);
        apply(announcement, request);

        return announcementRepository.save(announcement);
    }

    @Override
    public Announcement uploadImage(Long id, MultipartFile file) {
        Announcement announcement = getById(id);

        if (file == null || file.isEmpty()) {
            throw new BusinessRuleException("Choose an image file to upload");
        }
        if (file.getSize() > MAX_IMAGE_BYTES) {
            throw new BusinessRuleException("Promotion images must be 5 MB or smaller");
        }
        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        String extension = EXTENSION_BY_TYPE.get(contentType);
        if (extension == null) {
            throw new BusinessRuleException("Image must be a JPEG, PNG or WebP file (got " + contentType + ")");
        }

        String fileName = "promo-" + id + "-" + UUID.randomUUID().toString().substring(0, 8) + "." + extension;
        try {
            Path dir = imagesDir();
            Files.createDirectories(dir);
            Files.copy(file.getInputStream(), dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new BusinessRuleException("Could not store the image: " + e.getMessage());
        }
        deleteImageFile(announcement);
        announcement.setImageFile(fileName);
        return announcementRepository.save(announcement);
    }

    @Override
    public Announcement removeImage(Long id) {
        Announcement announcement = getById(id);
        deleteImageFile(announcement);
        announcement.setImageFile(null);
        return announcementRepository.save(announcement);
    }

    @Override
    public void delete(Long id) {
        Announcement announcement = getById(id);
        deleteImageFile(announcement);
        announcementRepository.delete(announcement);
    }

    private static void apply(Announcement announcement, AnnouncementRequest request) {
        if (request.getPublishFrom() != null && request.getPublishTo() != null
                && request.getPublishTo().isBefore(request.getPublishFrom())) {
            throw new InvalidRequestException("The last day shown cannot be before the first day");
        }
        String ctaUrl = blank(request.getCtaUrl());
        String ctaLabel = blank(request.getCtaLabel());
        if (ctaLabel != null && ctaUrl == null) {
            throw new InvalidRequestException("Add a link for the button, or leave the button text empty");
        }

        announcement.setTitle(request.getTitle().trim());
        announcement.setContent(request.getContent().trim());
        // Promotions are for customers only; saving an old staff notice moves it to customers.
        announcement.setAudience(Announcement.CUSTOMER);
        announcement.setPromoType(request.getPromoType() == null || request.getPromoType().isBlank()
                ? "OFFER" : request.getPromoType().trim().toUpperCase(Locale.ROOT));
        announcement.setBadgeText(blank(request.getBadgeText()));
        announcement.setCtaUrl(ctaUrl);
        announcement.setCtaLabel(ctaUrl == null ? null : (ctaLabel == null ? "Shop now" : ctaLabel));
        if (request.isDraft()) {
            announcement.setPublishedAt(null);
        } else if (request.getPublishFrom() != null) {
            announcement.setPublishedAt(request.getPublishFrom().atStartOfDay());
        } else if (announcement.getPublishedAt() == null) {
            announcement.setPublishedAt(LocalDateTime.now());
        }
        announcement.setExpiresAt(request.getPublishTo() == null ? null : request.getPublishTo().atTime(LocalTime.of(23, 59, 59)));
    }

    private void deleteImageFile(Announcement announcement) {
        if (announcement.getImageFile() == null) return;
        try {
            Files.deleteIfExists(imagesDir().resolve(announcement.getImageFile()));
        } catch (IOException e) {
            log.warn("Could not delete promotion image {}: {}", announcement.getImageFile(), e.getMessage());
        }
    }

    private Path imagesDir() {
        return Paths.get(uploadsDir, "promotions").toAbsolutePath().normalize();
    }

    private static String blank(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private Announcement getById(Long id) {
        return announcementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found: " + id));
    }
}
