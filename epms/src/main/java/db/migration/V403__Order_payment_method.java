package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

/**
 * Checkout payment option (cash on delivery or card) on customer orders, copied
 * onto the order's invoice. Bank transfer and cheque are no longer accepted for
 * invoice payments; any old ones are kept as they were recorded.
 */
public class V403__Order_payment_method extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        SchemaSteps s = new SchemaSteps(context.getConnection());
        s.requireBaseSchema("customer_orders");
        // Every order before this change was cash on delivery
        s.addColumn("customer_orders", "payment_method", "VARCHAR(20) NOT NULL DEFAULT 'COD'");
        s.addColumn("financial_invoices", "payment_option", "VARCHAR(30) NULL");
        s.exec("UPDATE financial_invoices SET payment_option = 'CASH_ON_DELIVERY'"
                + " WHERE reference_type = 'ORDER' AND payment_option IS NULL");
    }
}
