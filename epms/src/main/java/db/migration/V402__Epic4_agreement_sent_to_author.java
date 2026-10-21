package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * Epic 4: finance sends a draft royalty agreement to the author before the
 * author can see and sign it. Agreements the author could already see
 * (signed, active or expired) count as sent.
 */
public class V402__Epic4_agreement_sent_to_author extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("royalty_agreements");
        s.addColumn("royalty_agreements", "sent_to_author_at", "TIMESTAMP NULL");
        s.exec("UPDATE royalty_agreements SET sent_to_author_at = COALESCE(author_signed_at, created_at)"
                + " WHERE sent_to_author_at IS NULL AND (status <> 'DRAFT' OR author_signed_at IS NOT NULL)");
    }
}
