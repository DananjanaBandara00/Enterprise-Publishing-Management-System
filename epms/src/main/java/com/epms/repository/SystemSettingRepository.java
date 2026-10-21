package com.epms.repository;

import com.epms.entity.SystemSetting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SystemSettingRepository extends JpaRepository<SystemSetting, Long> {

    /** Safe if duplicate setting_key rows exist in the database. */
    Optional<SystemSetting> findFirstBySettingKeyOrderBySettingIdAsc(String settingKey);

    /** Kept for compatibility; prefer findFirst... above. */
    default Optional<SystemSetting> findBySettingKey(String settingKey) {
        return findFirstBySettingKeyOrderBySettingIdAsc(settingKey);
    }
}
