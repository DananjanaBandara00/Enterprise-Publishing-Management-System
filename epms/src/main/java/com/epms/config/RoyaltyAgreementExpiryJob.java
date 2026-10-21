package com.epms.config;

import com.epms.service.RoyaltyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

/**
 * Expires ACTIVE royalty agreements once their expiry date has passed, at
 * startup and every night. Agreements whose final statements are still in
 * progress are skipped and picked up on a later run.
 */
@Slf4j
@Configuration
@EnableScheduling
@RequiredArgsConstructor
public class RoyaltyAgreementExpiryJob {

    private final RoyaltyService royaltyService;

    @EventListener(ApplicationReadyEvent.class)
    public void onStartup() {
        run();
    }

    @Scheduled(cron = "0 5 0 * * *")
    public void run() {
        try {
            int expired = royaltyService.expireLapsedAgreements();
            if (expired > 0) {
                log.info("Expired {} royalty agreement(s) past their expiry date", expired);
            }
        } catch (RuntimeException e) {
            log.warn("Royalty agreement expiry run failed: {}", e.getMessage());
        }
    }
}
