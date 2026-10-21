package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * Announcements become customer promotions (sales, offers and ads) shown in
 * the homepage hero carousel. Each one gets a type, an optional badge, call to
 * action and image. Announcements addressed to everyone now go to customers;
 * ones addressed to a staff or author role are kept but no longer shown.
 */
public class V404__Customer_promotions extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("announcements");
        s.addColumn("announcements", "promo_type", "VARCHAR(20) NOT NULL DEFAULT 'OFFER'");
        s.addColumn("announcements", "badge_text", "VARCHAR(40) NULL");
        s.addColumn("announcements", "cta_label", "VARCHAR(40) NULL");
        s.addColumn("announcements", "cta_url", "VARCHAR(500) NULL");
        s.addColumn("announcements", "image_file", "VARCHAR(255) NULL");
        s.exec("UPDATE announcements SET audience = 'CUSTOMER' WHERE audience = 'ALL'");
    }
}
