package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * Epic 2: assignment history for Chief Editor (US11 / US15).
 * Tracks ACTIVE / REASSIGNED / CANCELLED editor assignments per manuscript.
 */
public class V202__Epic2_manuscript_assignments extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("manuscripts");

        s.exec("CREATE TABLE IF NOT EXISTS manuscript_assignments ("
                + " assignment_id BIGINT AUTO_INCREMENT PRIMARY KEY,"
                + " manuscript_id BIGINT NOT NULL,"
                + " editor_id BIGINT NOT NULL,"
                + " assigned_by BIGINT NOT NULL,"
                + " assignment_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',"
                + " remarks VARCHAR(500) NULL,"
                + " assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                + " ended_at TIMESTAMP NULL,"
                + " created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                + " updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                + " INDEX idx_ma_manuscript (manuscript_id),"
                + " INDEX idx_ma_editor (editor_id),"
                + " INDEX idx_ma_status (assignment_status),"
                + " CONSTRAINT fk_ma_manuscript FOREIGN KEY (manuscript_id)"
                + "   REFERENCES manuscripts(manuscript_id) ON UPDATE CASCADE ON DELETE CASCADE"
                + ") ENGINE=InnoDB");
    }
}