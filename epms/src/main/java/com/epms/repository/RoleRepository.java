package com.epms.repository;

import com.epms.entity.RoleEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<RoleEntity, Long> {

    Optional<RoleEntity> findFirstByRoleNameOrderByRoleIdAsc(String roleName);

    default Optional<RoleEntity> findByRoleName(String roleName) {
        return findFirstByRoleNameOrderByRoleIdAsc(roleName);
    }

    boolean existsByRoleName(String roleName);
}
