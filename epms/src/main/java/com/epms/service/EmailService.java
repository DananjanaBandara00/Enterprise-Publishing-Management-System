package com.epms.service;

import com.epms.dto.response.InvoiceDetail;
import com.epms.entity.CustomerOrder;
import com.epms.entity.FinancialInvoice;
import com.epms.entity.FinancialInvoiceLine;
import com.epms.entity.FinancialPayment;
import com.epms.entity.User;
import com.epms.repository.UserRepository;
import jakarta.mail.internet.MimeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;

/**
 * Sends e-mails when a mail server is configured (SPRING_MAIL_HOST etc.);
 * otherwise writes the message to the log so links can still be used
 * during development. Sending never fails the calling action.
 */
@Slf4j
@Service
public class EmailService {

    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    private final ObjectProvider<JavaMailSender> mailSender;
    private final UserRepository userRepository;
    private final String from;
    private final String baseUrl;

    public EmailService(ObjectProvider<JavaMailSender> mailSender,
                        UserRepository userRepository,
                        @Value("${epms.mail.from:no-reply@readingplanet.lk}") String from,
                        @Value("${epms.app.base-url:http://localhost:8080}") String baseUrl) {
        this.mailSender = mailSender;
        this.userRepository = userRepository;
        this.from = from;
        this.baseUrl = baseUrl;
    }

    /** Plain-text e-mail (password reset and similar). */
    public boolean send(String to, String subject, String body) {
        if (to == null || to.isBlank()) {
            log.warn("E-mail skipped: no recipient for subject '{}'", subject);
            return false;
        }
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.info("E-mail not configured; would send to {}: {}\n{}", to, subject, body);
            return false;
        }
        try {
            SimpleMailMessage m = new SimpleMailMessage();
            m.setFrom(from);
            m.setTo(to.trim());
            m.setSubject(subject);
            m.setText(body);
            sender.send(m);
            log.info("E-mail sent to {} — {}", to, subject);
            return true;
        } catch (RuntimeException e) {
            log.warn("Could not send e-mail to {} ({}): {}", to, subject, e.getMessage());
            return false;
        }
    }

    /** HTML e-mail for order notifications. */
    public boolean sendHtml(String to, String subject, String htmlBody) {
        if (to == null || to.isBlank()) {
            log.warn("E-mail skipped: no recipient for subject '{}'", subject);
            return false;
        }
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.info("E-mail not configured; would send HTML to {}: {}\n{}", to, subject, htmlBody);
            return false;
        }
        try {
            MimeMessage message = sender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
            helper.setFrom(from);
            helper.setTo(to.trim());
            helper.setSubject(subject);
            helper.setText(htmlBody, true);
            sender.send(message);
            log.info("HTML e-mail sent to {} — {}", to, subject);
            return true;
        } catch (Exception e) {
            log.warn("Could not send HTML e-mail to {} ({}): {}", to, subject, e.getMessage());
            return false;
        }
    }

    // ===================== Customer order notifications =====================

    /** After the customer places an order (status PENDING_APPROVAL). */
    public void sendOrderPlaced(CustomerOrder order) {
        User customer = customerOf(order);
        if (customer == null) {
            return;
        }
        String subject = "Order " + order.getOrderNumber() + " received – Reading Planet";
        String html = buildOrderEmail(
                customer,
                "Order received",
                "#1a5f9e",
                "Thank you for shopping with Reading Planet. We have received your order and it is waiting for confirmation.",
                "Awaiting confirmation",
                order,
                null,
                null,
                "We will e-mail you again when your order is approved and when it is on its way."
        );
        sendHtml(customer.getEmail(), subject, html);
    }

    /** When admin/sales confirms the order (PENDING_APPROVAL → CONFIRMED). */
    public void sendOrderApproved(CustomerOrder order) {
        User customer = customerOf(order);
        if (customer == null) {
            return;
        }
        String subject = "Order " + order.getOrderNumber() + " approved – Reading Planet";
        String html = buildOrderEmail(
                customer,
                "Order approved",
                "#0f6b3c",
                "Good news — your order has been approved and is being prepared for dispatch.",
                "Confirmed · packing",
                order,
                null,
                null,
                "You will receive another e-mail when your order is dispatched."
        );
        sendHtml(customer.getEmail(), subject, html);
    }

    /** When warehouse marks the order as DISPATCHED. */
    public void sendOrderDispatched(CustomerOrder order, String provider, String trackingNumber) {
        User customer = customerOf(order);
        if (customer == null) {
            return;
        }
        String subject = "Order " + order.getOrderNumber() + " dispatched – Reading Planet";
        String html = buildOrderEmail(
                customer,
                "Order dispatched",
                "#7c3aed",
                "Your order is on its way to you.",
                "Dispatched · in transit",
                order,
                provider,
                trackingNumber,
                "Please keep the tracking details handy. If you have any questions, contact Reading Planet support."
        );
        sendHtml(customer.getEmail(), subject, html);
    }

    /** When admin/sales rejects the order. */
    public void sendOrderRejected(CustomerOrder order, String reason) {
        User customer = customerOf(order);
        if (customer == null) {
            return;
        }
        String subject = "Order " + order.getOrderNumber() + " not approved – Reading Planet";
        String note = "Unfortunately your order could not be approved.";
        if (reason != null && !reason.isBlank()) {
            note += " Reason: " + escape(reason.trim()) + ".";
        }
        String html = buildOrderEmail(
                customer,
                "Order not approved",
                "#9b1c1c",
                note,
                "Cancelled",
                order,
                null,
                null,
                "REFUNDED".equals(order.getPaymentStatus())
                        ? "Your card payment of LKR " + formatMoney(order.getTotalAmount()) + " has been refunded to your card."
                        : "Any reserved stock has been released. You are welcome to place a new order anytime."
        );
        sendHtml(customer.getEmail(), subject, html);
    }

    // ===================== Invoices =====================

    /** Sends the full invoice once it is fully paid (cash on delivery, card, or recorded by finance). */
    public boolean sendInvoicePaid(InvoiceDetail detail) {
        FinancialInvoice inv = detail.getInvoice();
        if (!notBlank(inv.getCustomerEmail())) {
            log.info("Invoice {} paid; no customer e-mail on it, so nothing sent", inv.getInvoiceNumber());
            return false;
        }
        String cur = escape(nullToDash(inv.getCurrency()));

        StringBuilder lines = new StringBuilder();
        for (FinancialInvoiceLine l : detail.getLines()) {
            lines.append("""
                    <tr>
                      <td style="padding:8px 8px 8px 0;border-bottom:1px solid #e2eef8;">%s</td>
                      <td style="padding:8px;border-bottom:1px solid #e2eef8;text-align:right;">%d</td>
                      <td style="padding:8px;border-bottom:1px solid #e2eef8;text-align:right;white-space:nowrap;">%s</td>
                      <td style="padding:8px 0 8px 8px;border-bottom:1px solid #e2eef8;text-align:right;white-space:nowrap;">%s</td>
                    </tr>
                    """.formatted(escape(l.getDescription()), l.getQuantity(),
                    formatMoney(l.getUnitPrice()), formatMoney(l.getLineTotal())));
        }

        FinancialPayment last = detail.getPayments().isEmpty() ? null
                : detail.getPayments().get(detail.getPayments().size() - 1);
        StringBuilder rows = new StringBuilder();
        rows.append(detailRow("Invoice number", "<strong>" + escape(inv.getInvoiceNumber()) + "</strong>"));
        rows.append(detailRow("Invoice date", escape(String.valueOf(inv.getInvoiceDate()))));
        if (paymentOptionLabel(inv.getPaymentOption()) != null) {
            rows.append(detailRow("Payment option", "<strong>" + escape(paymentOptionLabel(inv.getPaymentOption())) + "</strong>"));
        }
        if (last != null) {
            rows.append(detailRow("Paid on", escape(last.getPaymentDate().format(DateTimeFormatter.ofPattern("dd MMM yyyy")))));
            rows.append(detailRow("Payment method", escape(paymentMethodLabel(last.getPaymentMethod()))));
            rows.append(detailRow("Reference", escape(last.getReferenceNumber())));
        }
        rows.append(detailRow("Amount paid", "<strong style=\"color:#0f6b3c;\">" + cur + " "
                + formatMoney(inv.getAmountPaid()) + "</strong>"));

        String billTo = "<strong>" + escape(inv.getCustomerName()) + "</strong>"
                + (notBlank(inv.getCustomerAddress()) ? "<br>" + escape(inv.getCustomerAddress()) : "")
                + "<br>" + escape(inv.getCustomerEmail());
        String shopUrl = baseUrl.endsWith("/") ? baseUrl : baseUrl + "/";
        String subject = "Invoice " + inv.getInvoiceNumber() + " – payment received – Reading Planet";

        String html = """
                <!DOCTYPE html>
                <html lang="en">
                <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Invoice %s</title></head>
                <body style="margin:0;padding:0;background:#eef2f7;font-family:'Segoe UI',Helvetica,Arial,sans-serif;color:#1a2b3c;">
                  <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="background:#eef2f7;padding:28px 12px;">
                    <tr><td align="center">
                      <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                             style="max-width:600px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #d8e5f2;">
                        <tr><td style="background:#0f6b3c;padding:24px 28px;">
                          <p style="margin:0;font-size:12px;letter-spacing:0.12em;text-transform:uppercase;color:rgba(255,255,255,0.8);font-weight:600;">%s</p>
                          <h1 style="margin:8px 0 0;font-size:24px;line-height:1.25;color:#ffffff;font-weight:700;">Invoice %s · Paid</h1>
                        </td></tr>
                        <tr><td style="padding:28px;">
                          <p style="margin:0 0 20px;font-size:15px;line-height:1.6;color:#334e68;">
                            Thank you — we have received your payment. Your invoice is below for your records.
                          </p>
                          <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                                 style="background:#f7fafd;border:1px solid #d8e5f2;border-radius:10px;margin:0 0 16px;">
                            <tr><td style="padding:18px 20px;">
                              <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                                     style="font-size:14px;line-height:1.5;color:#274766;">%s</table>
                            </td></tr>
                          </table>
                          <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="margin:0 0 16px;font-size:14px;color:#274766;">
                            <tr>
                              <td style="vertical-align:top;padding-right:12px;">
                                <p style="margin:0 0 6px;font-size:12px;font-weight:700;color:#123d73;text-transform:uppercase;letter-spacing:0.05em;">Bill to</p>
                                <p style="margin:0;line-height:1.6;">%s</p>
                              </td>
                              <td style="vertical-align:top;text-align:right;">
                                <p style="margin:0 0 6px;font-size:12px;font-weight:700;color:#123d73;text-transform:uppercase;letter-spacing:0.05em;">From</p>
                                <p style="margin:0;line-height:1.6;"><strong>%s</strong><br>%s</p>
                              </td>
                            </tr>
                          </table>
                          <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="font-size:14px;color:#274766;margin:0 0 8px;">
                            <tr style="font-size:12px;color:#5a6f85;text-transform:uppercase;letter-spacing:0.04em;">
                              <th align="left" style="padding:8px 8px 8px 0;border-bottom:2px solid #d8e5f2;">Item</th>
                              <th align="right" style="padding:8px;border-bottom:2px solid #d8e5f2;">Qty</th>
                              <th align="right" style="padding:8px;border-bottom:2px solid #d8e5f2;">Unit price</th>
                              <th align="right" style="padding:8px 0 8px 8px;border-bottom:2px solid #d8e5f2;">Amount</th>
                            </tr>
                            %s
                            <tr>
                              <td colspan="3" style="padding:12px 8px 4px 0;text-align:right;font-weight:700;">Total</td>
                              <td style="padding:12px 0 4px 8px;text-align:right;font-weight:700;white-space:nowrap;">%s %s</td>
                            </tr>
                            <tr>
                              <td colspan="3" style="padding:4px 8px 4px 0;text-align:right;color:#5a6f85;">Balance due</td>
                              <td style="padding:4px 0 4px 8px;text-align:right;color:#5a6f85;white-space:nowrap;">%s %s</td>
                            </tr>
                          </table>
                          %s
                          <table role="presentation" cellpadding="0" cellspacing="0" style="margin-top:20px;">
                            <tr><td style="background:#1a5f9e;border-radius:8px;">
                              <a href="%s" style="display:inline-block;padding:12px 22px;font-size:14px;font-weight:600;color:#ffffff;text-decoration:none;">Visit Reading Planet</a>
                            </td></tr>
                          </table>
                        </td></tr>
                        <tr><td style="padding:16px 28px 22px;border-top:1px solid #e2eef8;background:#fbfdff;">
                          <p style="margin:0;font-size:12px;line-height:1.55;color:#8ca0b5;text-align:center;">
                            Automated message from <strong style="color:#5a6f85;">Reading Planet</strong>. Please keep this e-mail as your receipt.
                          </p>
                        </td></tr>
                      </table>
                    </td></tr>
                  </table>
                </body>
                </html>
                """.formatted(
                escape(inv.getInvoiceNumber()),
                escape(nullToDash(detail.getCompanyName())),
                escape(inv.getInvoiceNumber()),
                rows.toString(),
                billTo,
                escape(nullToDash(detail.getCompanyName())),
                escape(nullToDash(detail.getCompanyAddress())),
                lines.toString(),
                cur, formatMoney(inv.getTotalAmount()),
                cur, formatMoney(inv.getOutstanding()),
                notBlank(inv.getNotes())
                        ? "<p style=\"margin:12px 0 0;font-size:13px;color:#5a6f85;\">" + escape(inv.getNotes()) + "</p>" : "",
                shopUrl);
        return sendHtml(inv.getCustomerEmail(), subject, html);
    }

    private static String paymentLabel(CustomerOrder order) {
        boolean card = CustomerOrder.PAY_CARD.equals(order.getPaymentMethod());
        String status = order.getPaymentStatus() == null ? "" : order.getPaymentStatus();
        if (card) {
            return "REFUNDED".equals(status) ? "Card · refunded" : "Card · paid";
        }
        return "PAID".equals(status) ? "Cash on delivery · paid" : "Cash on delivery · pay when it arrives";
    }

    private static String paymentOptionLabel(String option) {
        if (FinancialInvoice.OPTION_CARD.equals(option)) {
            return "Card";
        }
        if (FinancialInvoice.OPTION_CASH_ON_DELIVERY.equals(option)) {
            return "Cash on delivery";
        }
        return null;
    }

    private static String paymentMethodLabel(String method) {
        if (method == null) {
            return "—";
        }
        return switch (method) {
            case "CASH" -> "Cash";
            case "CARD" -> "Card";
            case "BANK_TRANSFER" -> "Bank transfer";
            case "CHEQUE" -> "Cheque";
            default -> method;
        };
    }

    // ===================== HTML template =====================

    private String buildOrderEmail(User customer,
                                   String headline,
                                   String accentColor,
                                   String introHtml,
                                   String statusLabel,
                                   CustomerOrder order,
                                   String provider,
                                   String trackingNumber,
                                   String closing) {
        String name = firstName(customer);
        String total = formatMoney(order.getTotalAmount());
        String orderDate = order.getOrderDate() != null
                ? order.getOrderDate().format(DATE_FMT)
                : "—";

        StringBuilder rows = new StringBuilder();
        rows.append(detailRow("Order number", "<strong>" + escape(order.getOrderNumber()) + "</strong>"));
        rows.append(detailRow("Order date", escape(orderDate)));
        rows.append(detailRow("Total", "<strong style=\"color:#123d73;\">LKR " + total + "</strong>"));
        rows.append(detailRow("Payment", escape(paymentLabel(order))));
        if (order.isWholesale() && notBlank(order.getBusinessName())) {
            rows.append(detailRow("Business", escape(order.getBusinessName())));
        }
        if (notBlank(provider)) {
            rows.append(detailRow("Courier", escape(provider.trim())));
        }
        if (notBlank(trackingNumber)) {
            rows.append(detailRow("Tracking number",
                    "<strong style=\"letter-spacing:0.03em;\">" + escape(trackingNumber.trim()) + "</strong>"));
        }

        String phoneLine = notBlank(order.getRecipientPhone())
                ? "<br>Phone: " + escape(order.getRecipientPhone().trim())
                : "";
        String addressHtml = escape(nullToDash(order.getShippingAddress())).replace("\n", "<br>");
        String shopUrl = baseUrl.endsWith("/") ? baseUrl : baseUrl + "/";

        return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>%s</title>
                </head>
                <body style="margin:0;padding:0;background:#eef2f7;font-family:'Segoe UI',Helvetica,Arial,sans-serif;color:#1a2b3c;">
                  <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="background:#eef2f7;padding:28px 12px;">
                    <tr>
                      <td align="center">
                        <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                               style="max-width:560px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #d8e5f2;">

                          <!-- Brand bar -->
                          <tr>
                            <td style="background:%s;padding:24px 28px;">
                              <p style="margin:0;font-size:12px;letter-spacing:0.12em;text-transform:uppercase;color:rgba(255,255,255,0.8);font-weight:600;">
                                Reading Planet
                              </p>
                              <h1 style="margin:8px 0 0;font-size:24px;line-height:1.25;color:#ffffff;font-weight:700;">
                                %s
                              </h1>
                            </td>
                          </tr>

                          <!-- Content -->
                          <tr>
                            <td style="padding:28px;">
                              <p style="margin:0 0 6px;font-size:16px;font-weight:600;color:#123d73;">
                                Hello %s,
                              </p>
                              <p style="margin:0 0 20px;font-size:15px;line-height:1.6;color:#334e68;">
                                %s
                              </p>

                              <!-- Status -->
                              <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 24px;">
                                <tr>
                                  <td style="background:%s;color:#ffffff;font-size:11px;font-weight:700;
                                             letter-spacing:0.06em;text-transform:uppercase;padding:7px 14px;border-radius:999px;">
                                    %s
                                  </td>
                                </tr>
                              </table>

                              <!-- Order details -->
                              <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                                     style="background:#f7fafd;border:1px solid #d8e5f2;border-radius:10px;margin:0 0 16px;">
                                <tr>
                                  <td style="padding:18px 20px;">
                                    <p style="margin:0 0 12px;font-size:12px;font-weight:700;color:#123d73;
                                               text-transform:uppercase;letter-spacing:0.05em;">
                                      Order details
                                    </p>
                                    <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                                           style="font-size:14px;line-height:1.5;color:#274766;">
                                      %s
                                    </table>
                                  </td>
                                </tr>
                              </table>

                              <!-- Shipping -->
                              <table role="presentation" width="100%%" cellpadding="0" cellspacing="0"
                                     style="background:#f7fafd;border:1px solid #d8e5f2;border-radius:10px;margin:0 0 22px;">
                                <tr>
                                  <td style="padding:18px 20px;">
                                    <p style="margin:0 0 10px;font-size:12px;font-weight:700;color:#123d73;
                                               text-transform:uppercase;letter-spacing:0.05em;">
                                      Delivery address
                                    </p>
                                    <p style="margin:0;font-size:14px;line-height:1.6;color:#274766;">
                                      <strong>%s</strong><br>
                                      %s%s
                                    </p>
                                  </td>
                                </tr>
                              </table>

                              <p style="margin:0 0 24px;font-size:14px;line-height:1.6;color:#5a6f85;">
                                %s
                              </p>

                              <!-- Button -->
                              <table role="presentation" cellpadding="0" cellspacing="0">
                                <tr>
                                  <td style="background:#1a5f9e;border-radius:8px;">
                                    <a href="%s"
                                       style="display:inline-block;padding:12px 22px;font-size:14px;font-weight:600;
                                              color:#ffffff;text-decoration:none;">
                                      Visit Reading Planet
                                    </a>
                                  </td>
                                </tr>
                              </table>
                            </td>
                          </tr>

                          <!-- Footer -->
                          <tr>
                            <td style="padding:16px 28px 22px;border-top:1px solid #e2eef8;background:#fbfdff;">
                              <p style="margin:0;font-size:12px;line-height:1.55;color:#8ca0b5;text-align:center;">
                                Automated message from <strong style="color:#5a6f85;">Reading Planet</strong>.<br>
                                You received this because of activity on your account.
                              </p>
                            </td>
                          </tr>

                        </table>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """.formatted(
                escape(headline),
                accentColor,
                escape(headline),
                escape(name),
                introHtml,
                accentColor,
                escape(statusLabel),
                rows.toString(),
                escape(nullToDash(order.getRecipientName())),
                addressHtml,
                phoneLine,
                escape(closing),
                shopUrl
        );
    }

    private static String detailRow(String label, String valueHtml) {
        return """
                <tr>
                  <td style="padding:5px 12px 5px 0;width:36%%;color:#5a6f85;vertical-align:top;">%s</td>
                  <td style="padding:5px 0;vertical-align:top;">%s</td>
                </tr>
                """.formatted(escape(label), valueHtml);
    }

    private User customerOf(CustomerOrder order) {
        if (order == null || order.getCustomerId() == null) {
            return null;
        }
        return userRepository.findById(order.getCustomerId()).orElse(null);
    }

    private static String firstName(User customer) {
        if (customer.getFirstName() != null && !customer.getFirstName().isBlank()) {
            return customer.getFirstName().trim();
        }
        if (customer.getFullName() != null && !customer.getFullName().isBlank()) {
            return customer.getFullName().trim();
        }
        return "there";
    }

    private static String formatMoney(BigDecimal amount) {
        BigDecimal v = amount == null ? BigDecimal.ZERO : amount;
        return v.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private static String nullToDash(String v) {
        return v == null || v.isBlank() ? "—" : v.trim();
    }

    private static boolean notBlank(String v) {
        return v != null && !v.isBlank();
    }

    private static String escape(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
