package com.epms.repository;

import com.epms.entity.ManuscriptAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ManuscriptAssignmentRepository extends JpaRepository<ManuscriptAssignment, Long> {

    List<ManuscriptAssignment> findByManuscriptIdOrderByAssignedAtDesc(Long manuscriptId);

    Optional<ManuscriptAssignment> findFirstByManuscriptIdAndAssignmentStatusOrderByAssignedAtDesc(
            Long manuscriptId, String assignmentStatus);

    List<ManuscriptAssignment> findByEditorIdAndAssignmentStatusOrderByAssignedAtDesc(
            Long editorId, String assignmentStatus);
}