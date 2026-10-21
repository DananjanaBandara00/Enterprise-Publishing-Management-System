package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * The author picks the book category when submitting a manuscript; it is
 * carried through to the book record at "ready for printing". Nullable so
 * manuscripts submitted before this change keep working.
 */
public class V102__Epic1_manuscript_category extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("manuscripts", "categories");
        s.addColumn("manuscripts", "category_id", "BIGINT NULL AFTER genre_id");
        s.addIndex("manuscripts", "idx_manuscripts_category", "category_id");
    }
}
