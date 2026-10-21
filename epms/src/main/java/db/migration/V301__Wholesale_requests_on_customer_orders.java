package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * Wholesale flag on customer checkout orders so sales staff can approve or
 * reject bulk / bookstore requests placed via the public store.
 */
public class V301__Wholesale_requests_on_customer_orders extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("customer_orders");
        s.addColumn("customer_orders", "is_wholesale", "TINYINT(1) NOT NULL DEFAULT 0");
        s.addColumn("customer_orders", "business_name", "VARCHAR(150) NULL");
        s.addColumn("customer_orders", "wholesale_status", "VARCHAR(30) NULL");
        s.addColumn("customer_orders", "wholesale_reviewed_by", "BIGINT NULL");
        s.addColumn("customer_orders", "wholesale_reviewed_at", "TIMESTAMP NULL");
        s.addColumn("customer_orders", "wholesale_reject_reason", "VARCHAR(255) NULL");
        s.addIndex("customer_orders", "idx_customer_orders_wholesale", "is_wholesale, wholesale_status");
    }
}
