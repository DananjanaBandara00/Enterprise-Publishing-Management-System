package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * Phase 1 / Epic 2: store Chief Editor remarks when assigning an editor.
 * Shown in the Editor "My Review Queue" Remarks column.
 */
public class V203__Epic2_assignment_remarks extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("manuscripts");
        s.addColumn("manuscripts", "assignment_remarks", "VARCHAR(500) NULL");
    }
}
