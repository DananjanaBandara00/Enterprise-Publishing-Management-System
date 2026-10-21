package com.epms.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CheckoutRequest {

    @NotBlank(message = "Recipient name is required")
    @Size(max = 150)
    private String recipientName;

    @NotBlank(message = "Recipient phone number is required")
    @Pattern(regexp = "^[+0-9 ()-]{7,20}$", message = "Phone number is not valid")
    private String recipientPhone;

    @NotBlank(message = "Delivery address is required")
    @Size(max = 255, message = "Address must be 255 characters or fewer")
    private String shippingAddress;

    /** When true the order is held for sales staff approval (wholesale / bookstore). */
    private boolean wholesale;

    /** COD (cash on delivery, default) or CARD (paid at checkout through the test card gateway). */
    @Pattern(regexp = "COD|CARD", message = "Payment method must be COD or CARD")
    private String paymentMethod;

    /** Card checkout only: last 4 digits and brand for the receipt. The full card number is never sent. */
    @Pattern(regexp = "[0-9]{4}", message = "Card last 4 digits are not valid")
    private String cardLast4;

    @Size(max = 20)
    private String cardBrand;

    @Size(max = 150, message = "Business name must be 150 characters or fewer")
    private String businessName;
}
