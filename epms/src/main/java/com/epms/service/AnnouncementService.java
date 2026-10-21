package com.epms.service;

import com.epms.dto.request.AnnouncementRequest;
import com.epms.entity.Announcement;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/** Customer promotions (sales, offers, ads) for the homepage hero carousel. */
public interface AnnouncementService {

    List<Announcement> getAll();

    /** Published, not expired customer promotions, newest first. */
    List<Announcement> getActiveForCustomers();

    Announcement create(AnnouncementRequest request, Long createdBy);

    Announcement update(Long id, AnnouncementRequest request);

    Announcement uploadImage(Long id, MultipartFile file);

    Announcement removeImage(Long id);

    void delete(Long id);
}
