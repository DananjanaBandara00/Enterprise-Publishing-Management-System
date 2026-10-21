(function () {
    "use strict";

    var root = document.getElementById("checkoutRoot");
    var state = {
        deliveryMethod: "SHIP",
        shippingOption: "KOOMBIYO",
        paymentMethod: "COD",
        billingSame: true
    };

    var DISTRICT_CITIES = {
        "Colombo": [
            "Colombo 1", "Colombo 2", "Colombo 3", "Colombo 4", "Colombo 5",
            "Colombo 6", "Colombo 7", "Colombo 8", "Colombo 9", "Colombo 10",
            "Colombo 11", "Colombo 12", "Colombo 13", "Colombo 14", "Colombo 15",
            "Dehiwala", "Mount Lavinia", "Moratuwa", "Kotte", "Maharagama",
            "Nugegoda", "Battaramulla", "Rajagiriya", "Homagama", "Piliyandala",
            "Kesbewa", "Boralesgamuwa"
        ],
        "Gampaha": [
            "Gampaha", "Negombo", "Kelaniya", "Kiribathgoda", "Ja-Ela",
            "Wattala", "Kandana", "Minuwangoda", "Divulapitiya", "Veyangoda",
            "Nittambuwa", "Ragama"
        ],
        "Kalutara": [
            "Kalutara", "Panadura", "Horana", "Beruwala", "Aluthgama",
            "Matugama", "Wadduwa", "Bandaragama"
        ],
        "Kandy": [
            "Kandy", "Peradeniya", "Katugastota", "Gampola", "Nawalapitiya",
            "Akurana", "Pilimatalawa", "Kadugannawa"
        ],
        "Galle": [
            "Galle", "Hikkaduwa", "Ambalangoda", "Elpitiya", "Baddegama", "Unawatuna"
        ],
        "Matara": [
            "Matara", "Weligama", "Dikwella", "Akuressa", "Kamburupitiya"
        ],
        "Kurunegala": [
            "Kurunegala", "Kuliyapitiya", "Pannala", "Narammala", "Polgahawela", "Mawathagama"
        ],
        "Other": ["Other"]
    };

    function token() {
        return localStorage.getItem("rp_customer_token") || sessionStorage.getItem("rp_customer_token");
    }

    function money(v) {
        return "Rs. " + Number(v || 0).toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function escapeHtml(s) {
        return String(s == null ? "" : s)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;");
    }

    function shippingFee() {
        return 0;
    }

    function onlyDigits(s) {
        return String(s || "").replace(/\D/g, "");
    }

    function formatCardNumber(value) {
        var d = onlyDigits(value).slice(0, 16);
        return d.replace(/(\d{4})(?=\d)/g, "$1 ").trim();
    }

    function formatExpiry(value) {
        var d = onlyDigits(value).slice(0, 4);
        if (d.length >= 3) return d.slice(0, 2) + "/" + d.slice(2);
        return d;
    }

    function isValidEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(email || "").trim());
    }

    function isValidPhone(phone) {
        var d = onlyDigits(phone);
        return d.length >= 9 && d.length <= 15;
    }

    function isValidCardNumber(num) {
        var s = onlyDigits(num);
        return s.length >= 13 && s.length <= 19;
    }

    function isValidExpiry(mmYy) {
        var m = String(mmYy || "").match(/^(\d{2})\/(\d{2})$/);
        if (!m) return false;
        var month = parseInt(m[1], 10);
        return month >= 1 && month <= 12;
    }

    function isValidCvv(cvv) {
        return /^\d{3,4}$/.test(String(cvv || "").trim());
    }

    function detectCardBrand(number) {
        var s = onlyDigits(number);
        if (/^4/.test(s)) return "VISA";
        if (/^5[1-5]/.test(s) || /^2[2-7]/.test(s)) return "MASTER";
        if (/^3[47]/.test(s)) return "AMEX";
        return "CARD";
    }

    function fillCities(selectId, district, selectedCity) {
        var citySelect = document.getElementById(selectId);
        if (!citySelect) return;
        var cities = DISTRICT_CITIES[district] || [];
        citySelect.innerHTML = '<option value="">Select a city</option>';
        cities.forEach(function (city) {
            var opt = document.createElement("option");
            opt.value = city;
            opt.textContent = city;
            if (selectedCity && selectedCity === city) opt.selected = true;
            citySelect.appendChild(opt);
        });
    }

    function setFieldError(id, msg) {
        var err = document.getElementById(id + "Err");
        var input = document.getElementById(id);
        if (err) {
            err.textContent = msg || "";
            err.style.display = msg ? "block" : "none";
        }
        if (input) {
            if (msg) input.classList.add("input-invalid");
            else input.classList.remove("input-invalid");
        }
    }

    function clearAllErrors() {
        document.querySelectorAll(".field-error").forEach(function (el) {
            el.textContent = "";
            el.style.display = "none";
        });
        document.querySelectorAll(".input-invalid").forEach(function (el) {
            el.classList.remove("input-invalid");
        });
        var box = document.getElementById("checkoutError");
        if (box) {
            box.style.display = "none";
            box.textContent = "";
        }
    }

    function val(id) {
        var el = document.getElementById(id);
        return el ? String(el.value || "").trim() : "";
    }

    function checked(id) {
        var el = document.getElementById(id);
        return !!(el && el.checked);
    }

    function addressFieldsHtml(prefix, title) {
        var districtOptions = Object.keys(DISTRICT_CITIES).map(function (d) {
            return '<option value="' + escapeHtml(d) + '">' + escapeHtml(d) + "</option>";
        }).join("");
        return (
            '<div class="checkout-section" id="' + prefix + 'Block">' +
            "<h2>" + title + "</h2>" +
            '<div class="form-group"><label>Country/Region</label>' +
            '<select id="' + prefix + 'Country"><option>Sri Lanka</option></select></div>' +
            '<div class="form-row">' +
            '<div class="form-group"><label>First name <span class="req">*</span></label>' +
            '<input type="text" id="' + prefix + 'First" autocomplete="given-name">' +
            '<div class="field-error" id="' + prefix + 'FirstErr"></div></div>' +
            '<div class="form-group"><label>Last name <span class="req">*</span></label>' +
            '<input type="text" id="' + prefix + 'Last" autocomplete="family-name">' +
            '<div class="field-error" id="' + prefix + 'LastErr"></div></div>' +
            "</div>" +
            '<div class="form-group"><label>Address <span class="req">*</span></label>' +
            '<input type="text" id="' + prefix + 'Address" placeholder="Street address" autocomplete="street-address">' +
            '<div class="field-error" id="' + prefix + 'AddressErr"></div></div>' +
            '<div class="form-group"><label>Apartment, suite, etc. (optional)</label>' +
            '<input type="text" id="' + prefix + 'Apt" placeholder="Apartment, suite, unit, etc."></div>' +
            '<div class="form-row">' +
            '<div class="form-group"><label>Postal code</label>' +
            '<input type="text" id="' + prefix + 'Postal" autocomplete="postal-code"></div>' +
            '<div class="form-group"><label>District <span class="req">*</span></label>' +
            '<select id="' + prefix + 'District">' +
            '<option value="">Select a district</option>' + districtOptions +
            "</select>" +
            '<div class="field-error" id="' + prefix + 'DistrictErr"></div></div>' +
            "</div>" +
            '<div class="form-row">' +
            '<div class="form-group"><label>City <span class="req">*</span></label>' +
            '<select id="' + prefix + 'City"><option value="">Select a city</option></select>' +
            '<div class="field-error" id="' + prefix + 'CityErr"></div></div>' +
            '<div class="form-group"><label>Phone <span class="req">*</span></label>' +
            '<input type="tel" id="' + prefix + 'Phone" placeholder="07X XXX XXXX" autocomplete="tel">' +
            '<div class="field-error" id="' + prefix + 'PhoneErr"></div></div>' +
            "</div></div>"
        );
    }

    function getFormSnapshot() {
        return {
            email: val("coEmail"),
            shipFirst: val("coFirst"),
            shipLast: val("coLast"),
            shipAddress: val("coAddress"),
            shipApt: val("coApt"),
            shipPostal: val("coPostal"),
            shipDistrict: val("coDistrict"),
            shipCity: val("coCity"),
            shipPhone: val("coPhone"),
            shipCountry: val("coCountry") || "Sri Lanka",
            billFirst: val("billFirst"),
            billLast: val("billLast"),
            billAddress: val("billAddress"),
            billApt: val("billApt"),
            billPostal: val("billPostal"),
            billDistrict: val("billDistrict"),
            billCity: val("billCity"),
            billPhone: val("billPhone"),
            billCountry: val("billCountry") || "Sri Lanka",
            note: val("coNote"),
            noteOn: checked("coNoteToggle"),
            terms: checked("coTerms"),
            wholesale: checked("coWholesale"),
            businessName: val("coBusinessName"),
            cardName: val("cardName"),
            cardNumber: val("cardNumber"),
            cardExpiry: val("cardExpiry"),
            cardCvv: val("cardCvv"),
            billingSame: state.billingSame
        };
    }

    function restoreFormSnapshot(snap) {
        if (!snap) return;
        var set = function (id, v) {
            var el = document.getElementById(id);
            if (el && v != null) el.value = v;
        };
        set("coEmail", snap.email);
        set("coFirst", snap.shipFirst);
        set("coLast", snap.shipLast);
        set("coAddress", snap.shipAddress);
        set("coApt", snap.shipApt);
        set("coPostal", snap.shipPostal);
        set("coCountry", snap.shipCountry || "Sri Lanka");
        set("coPhone", snap.shipPhone);

        var dEl = document.getElementById("coDistrict");
        if (dEl && snap.shipDistrict) {
            dEl.value = snap.shipDistrict;
            fillCities("coCity", snap.shipDistrict, snap.shipCity || "");
        }

        set("billFirst", snap.billFirst);
        set("billLast", snap.billLast);
        set("billAddress", snap.billAddress);
        set("billApt", snap.billApt);
        set("billPostal", snap.billPostal);
        set("billCountry", snap.billCountry || "Sri Lanka");
        set("billPhone", snap.billPhone);
        var bd = document.getElementById("billDistrict");
        if (bd && snap.billDistrict) {
            bd.value = snap.billDistrict;
            fillCities("billCity", snap.billDistrict, snap.billCity || "");
        }

        if (document.getElementById("coNoteToggle")) {
            document.getElementById("coNoteToggle").checked = !!snap.noteOn;
        }
        if (document.getElementById("coNote")) {
            document.getElementById("coNote").value = snap.note || "";
            document.getElementById("coNote").style.display = snap.noteOn ? "block" : "none";
        }
        if (document.getElementById("coTerms")) {
            document.getElementById("coTerms").checked = !!snap.terms;
        }
        if (document.getElementById("coWholesale")) {
            document.getElementById("coWholesale").checked = !!snap.wholesale;
        }
        if (document.getElementById("coBusinessName")) {
            document.getElementById("coBusinessName").value = snap.businessName || "";
            document.getElementById("wholesaleFields").style.display = snap.wholesale ? "block" : "none";
        }
        set("cardName", snap.cardName);
        set("cardNumber", snap.cardNumber);
        set("cardExpiry", snap.cardExpiry);
        set("cardCvv", snap.cardCvv);

        var sameEl = document.getElementById("coBillingSame");
        if (sameEl) sameEl.checked = snap.billingSame !== false;
        state.billingSame = snap.billingSame !== false;
        toggleBillingBlock();
    }

    function toggleBillingBlock() {
        var block = document.getElementById("billBlock");
        if (!block) return;
        block.style.display = state.billingSame ? "none" : "block";
    }

    function requireLogin() {
        if (!token()) {
            root.innerHTML =
                '<p class="checkout-msg">Please <a href="/account.html">log in</a> to checkout.<br>' +
                "Your cart items are saved in this browser.</p>";
            return false;
        }
        return true;
    }

    function validatePayment() {
        if (state.paymentMethod === "COD") {
            return { ok: true };
        }
        if (state.paymentMethod === "PAYHERE") {
            var name = val("cardName");
            var number = val("cardNumber");
            var expiry = val("cardExpiry");
            var cvv = val("cardCvv");
            var ok = true;
            if (!name || name.length < 3) {
                setFieldError("cardName", "Enter the name on the card.");
                ok = false;
            }
            if (!isValidCardNumber(number)) {
                setFieldError("cardNumber", "Enter a valid card number (13–19 digits).");
                ok = false;
            }
            if (!isValidExpiry(expiry)) {
                setFieldError("cardExpiry", "Enter expiry as MM/YY.");
                ok = false;
            }
            if (!isValidCvv(cvv)) {
                setFieldError("cardCvv", "Enter a 3 or 4 digit CVV.");
                ok = false;
            }
            if (!ok) return { ok: false, message: "Please fix the card details." };
        }
        return { ok: true };
    }

    function validateAddress(prefix, label) {
        var ok = true;
        if (!val(prefix + "First")) {
            setFieldError(prefix + "First", "First name is required.");
            ok = false;
        }
        if (!val(prefix + "Last")) {
            setFieldError(prefix + "Last", "Last name is required.");
            ok = false;
        }
        if (!val(prefix + "Address")) {
            setFieldError(prefix + "Address", label + " address is required.");
            ok = false;
        }
        if (!val(prefix + "District")) {
            setFieldError(prefix + "District", "Please select a district.");
            ok = false;
        }
        if (!val(prefix + "City")) {
            setFieldError(prefix + "City", "Please select a city.");
            ok = false;
        }
        if (!isValidPhone(val(prefix + "Phone"))) {
            setFieldError(prefix + "Phone", "Enter a valid phone number (9–15 digits).");
            ok = false;
        }
        return ok;
    }

    function render() {
        if (!requireLogin()) return;
        if (!window.RpCart) {
            root.innerHTML = '<p class="checkout-msg">Cart unavailable.</p>';
            return;
        }

        var cart = RpCart.read();
        if (!cart.length) {
            root.innerHTML =
                '<p class="checkout-msg">Your cart is empty. <a href="/store.html">Continue shopping</a></p>';
            return;
        }

        var sub = RpCart.subtotal(cart);
        var ship = shippingFee();
        var total = sub + ship;

        var summaryItems = cart.map(function (item) {
            var cover = item.coverImage
                ? '<img src="' + escapeHtml(item.coverImage) + '" alt="">'
                : '<div class="summary-ph"></div>';
            return (
                '<div class="summary-item">' + cover +
                '<div><div class="t">' + escapeHtml(item.title) + "</div>" +
                '<div class="q">Qty: ' + (parseInt(item.qty, 10) || 1) + "</div></div>" +
                "<div>" + money((Number(item.price) || 0) * (parseInt(item.qty, 10) || 1)) + "</div></div>"
            );
        }).join("");

        var shipBlock = state.deliveryMethod === "SHIP"
            ? addressFieldsHtml("co", "Shipping address")
            : ('<div class="checkout-section"><h2>Pickup contact</h2>' +
               '<div class="form-row">' +
               '<div class="form-group"><label>First name <span class="req">*</span></label>' +
               '<input type="text" id="coFirst" autocomplete="given-name">' +
               '<div class="field-error" id="coFirstErr"></div></div>' +
               '<div class="form-group"><label>Last name <span class="req">*</span></label>' +
               '<input type="text" id="coLast" autocomplete="family-name">' +
               '<div class="field-error" id="coLastErr"></div></div></div>' +
               '<div class="form-group"><label>Phone <span class="req">*</span></label>' +
               '<input type="tel" id="coPhone" placeholder="07X XXX XXXX" autocomplete="tel">' +
               '<div class="field-error" id="coPhoneErr"></div></div></div>');
        var billBlockHtml =
            '<div class="checkout-section">' +
            "<h2>Billing address</h2>" +
            '<label class="checkbox-row"><input type="checkbox" id="coBillingSame"' +
            (state.billingSame ? " checked" : "") +
            "> Same as shipping address</label>" +
            "</div>" +
            addressFieldsHtml("bill", "Billing address");

        root.innerHTML =
            '<div class="checkout-layout">' +
            '<div class="checkout-main">' +
            '<p class="checkout-note">Please fill in English</p>' +
            '<div id="checkoutError" class="checkout-error" style="display:none;"></div>' +

            '<div class="checkout-section"><h2>Contact information</h2>' +
            '<div class="form-group"><label>Email address <span class="req">*</span></label>' +
            '<input type="email" id="coEmail" autocomplete="email" placeholder="you@example.com">' +
            '<div class="field-error" id="coEmailErr"></div></div></div>' +

            '<div class="checkout-section"><h2>Delivery</h2>' +
            '<div class="delivery-tabs">' +
            '<button type="button" id="tabShip" class="' + (state.deliveryMethod === "SHIP" ? "active" : "") +
            '"><i class="fas fa-truck"></i> Ship</button>' +
            '<button type="button" id="tabPickup" class="' + (state.deliveryMethod === "PICKUP" ? "active" : "") +
            '"><i class="fas fa-store"></i> Store Pickup</button>' +
            "</div></div>" +

            shipBlock +

            (state.deliveryMethod === "SHIP" ? billBlockHtml : "") +

            (state.deliveryMethod === "SHIP"
                ? '<div class="checkout-section" id="shipOptionsBlock">' +
                  "<h2>Shipping options</h2>" +
                  '<div class="option-list">' +
                  '<label class="option-row"><input type="radio" name="shipOpt" value="KOOMBIYO"' +
                  (state.shippingOption === "KOOMBIYO" ? " checked" : "") +
                  '> Koombiyo Courier <span class="price">Free</span></label>' +
                  '<label class="option-row"><input type="radio" name="shipOpt" value="SL_POST"' +
                  (state.shippingOption === "SL_POST" ? " checked" : "") +
                  '> SL Post <span class="price">Free</span></label>' +
                  "</div></div>"
                : "") +

            '<div class="checkout-section"><h2>Payment options</h2>' +
            '<div class="option-list">' +
            '<label class="option-row payment-option' + (state.paymentMethod === "PAYHERE" ? " selected" : "") + '">' +
            '<input type="radio" name="payOpt" value="PAYHERE"' +
            (state.paymentMethod === "PAYHERE" ? " checked" : "") +
            '> <span class="pay-title">Credit / Debit card</span>' +
            '<span class="pay-brands"><i class="fab fa-cc-visa"></i> <i class="fab fa-cc-mastercard"></i> ' +
            '<i class="fab fa-cc-amex"></i></span></label>' +
            (state.paymentMethod === "PAYHERE"
                ? '<div class="card-box">' +
                  '<p class="pay-help"><strong>Test mode</strong>: no real charge is made. Your card is accepted straight away and the paid invoice is e-mailed to you.</p>' +
                  '<div class="form-group"><label>Name on card</label>' +
                  '<input type="text" id="cardName" placeholder="Name on card" autocomplete="cc-name">' +
                  '<div class="field-error" id="cardNameErr"></div></div>' +
                  '<div class="form-group"><label>Card number</label>' +
                  '<input type="text" id="cardNumber" placeholder="•••• •••• •••• ••••" inputmode="numeric" autocomplete="cc-number">' +
                  '<div class="field-error" id="cardNumberErr"></div></div>' +
                  '<div class="form-row">' +
                  '<div class="form-group"><label>Expiry (MM/YY)</label>' +
                  '<input type="text" id="cardExpiry" placeholder="MM/YY" inputmode="numeric" autocomplete="cc-exp">' +
                  '<div class="field-error" id="cardExpiryErr"></div></div>' +
                  '<div class="form-group"><label>CVV</label>' +
                  '<input type="text" id="cardCvv" placeholder="CVV" inputmode="numeric" autocomplete="cc-csc">' +
                  '<div class="field-error" id="cardCvvErr"></div></div>' +
                  "</div></div>"
                : "") +
            '<label class="option-row payment-option' + (state.paymentMethod === "COD" ? " selected" : "") + '">' +
            '<input type="radio" name="payOpt" value="COD"' +
            (state.paymentMethod === "COD" ? " checked" : "") +
            '> <span class="pay-title">Cash on Delivery</span></label>' +
            '<p class="pay-help">Pay the courier in cash when your books arrive.</p>' +
            "</div></div>" +

            '<div class="checkout-section">' +
            '<label class="checkbox-row"><input type="checkbox" id="coNoteToggle"> Add a note to your order</label>' +
            '<textarea id="coNote" rows="2" class="order-note" style="display:none;" placeholder="Delivery instructions, gift message, etc."></textarea>' +

            '<label class="checkbox-row wholesale-row">' +
            '<input type="checkbox" id="coWholesale"> ' +
            "<span><strong>This is a wholesale order</strong> — check this if you are a bookstore or bulk buyer.</span></label>" +
            '<div id="wholesaleFields" class="wholesale-fields" style="display:none;">' +
            '<div class="form-group"><label>Business / bookstore name <span class="req">*</span></label>' +
            '<input type="text" id="coBusinessName" placeholder="e.g. City Bookshop">' +
            '<div class="field-error" id="coBusinessNameErr"></div></div>' +
            '<p class="wholesale-hint">Wholesale orders require <strong>at least 10 books</strong> in total. They are flagged for our sales team. Standard retail pricing applies at checkout; bulk discounts are arranged offline.</p>' +
            "</div>" +

            '<label class="checkbox-row"><input type="checkbox" id="coTerms"> By proceeding you agree to our ' +
            '<a href="/terms.html" target="_blank" rel="noopener">Terms</a> and ' +
            '<a href="/privacy.html" target="_blank" rel="noopener">Privacy Policy</a>.</label>' +
            '<div class="field-error" id="coTermsErr"></div>' +

            '<button type="button" class="btn-place-order" id="placeOrderBtn">Place order</button>' +
            "</div></div>" +

            '<aside class="order-summary"><h2>Order summary</h2>' +
            summaryItems +
            '<div class="summary-row"><span>Subtotal</span><span>' + money(sub) + "</span></div>" +
            '<div class="summary-row"><span>Delivery</span><span>' + (ship === 0 ? "Free" : money(ship)) + "</span></div>" +
            '<div class="summary-row total"><span>Total</span><span>' + money(total) + "</span></div>" +
            "</aside></div>";

        // Fix payment radios: use COD as cash, PAYHERE as card path
        // Re-bind payment option labels properly after DOM insert
        var payLabels = root.querySelectorAll('input[name="payOpt"]');
        // First COD radio was incorrectly used twice in markup for PayHere visual — fix state binding in bind()

        bind();
        prefillProfile();
    }

    function bind() {
        var tabShip = document.getElementById("tabShip");
        var tabPickup = document.getElementById("tabPickup");

        if (tabShip) {
            tabShip.onclick = function () {
                var snap = getFormSnapshot();
                state.deliveryMethod = "SHIP";
                if (!state.shippingOption || state.shippingOption === "NONE") {
                    state.shippingOption = "KOOMBIYO";
                }
                render();
                restoreFormSnapshot(snap);
            };
        }
        if (tabPickup) {
            tabPickup.onclick = function () {
                var snap = getFormSnapshot();
                state.deliveryMethod = "PICKUP";
                state.shippingOption = "NONE";
                render();
                restoreFormSnapshot(snap);
            };
        }

        document.querySelectorAll('input[name="shipOpt"]').forEach(function (r) {
            r.onchange = function () {
                var snap = getFormSnapshot();
                state.shippingOption = this.value;
                render();
                restoreFormSnapshot(snap);
            };
        });

        document.querySelectorAll('input[name="payOpt"]').forEach(function (r) {
            r.onchange = function () {
                var snap = getFormSnapshot();
                state.paymentMethod = this.value;
                render();
                restoreFormSnapshot(snap);
            };
        });

        // Allow selecting PayHere card mode via a dedicated radio if present
        // We use value COD for cash; for demo card we treat first payment visual as COD default.

        var cardNumber = document.getElementById("cardNumber");
        if (cardNumber) {
            cardNumber.addEventListener("input", function () {
                this.value = formatCardNumber(this.value);
            });
        }
        var cardExpiry = document.getElementById("cardExpiry");
        if (cardExpiry) {
            cardExpiry.addEventListener("input", function () {
                this.value = formatExpiry(this.value);
            });
        }

        var districtEl = document.getElementById("coDistrict");
        if (districtEl) {
            districtEl.onchange = function () {
                fillCities("coCity", this.value, "");
            };
            if (districtEl.value) fillCities("coCity", districtEl.value, val("coCity"));
        }
        var billDistrict = document.getElementById("billDistrict");
        if (billDistrict) {
            billDistrict.onchange = function () {
                fillCities("billCity", this.value, "");
            };
            if (billDistrict.value) fillCities("billCity", billDistrict.value, val("billCity"));
        }

        var billingSame = document.getElementById("coBillingSame");
        if (billingSame) {
            billingSame.onchange = function () {
                state.billingSame = this.checked;
                toggleBillingBlock();
            };
            toggleBillingBlock();
        }

        var noteToggle = document.getElementById("coNoteToggle");
        if (noteToggle) {
            noteToggle.onchange = function () {
                var note = document.getElementById("coNote");
                if (note) note.style.display = this.checked ? "block" : "none";
            };
        }

        var wholesaleToggle = document.getElementById("coWholesale");
        var wholesaleFields = document.getElementById("wholesaleFields");
        if (wholesaleToggle && wholesaleFields) {
            wholesaleToggle.onchange = function () {
                wholesaleFields.style.display = this.checked ? "block" : "none";
                if (!this.checked) setFieldError("coBusinessName", "");
            };
        }

        var placeBtn = document.getElementById("placeOrderBtn");
        if (placeBtn) placeBtn.onclick = placeOrder;
    }

    function prefillProfile() {
        var t = token();
        if (!t) return;
        fetch("/api/customer/profile", {
            headers: { Authorization: "Bearer " + t }
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data || !data.success || !data.data) return;
                var p = data.data;
                var emailEl = document.getElementById("coEmail");
                var firstEl = document.getElementById("coFirst");
                var lastEl = document.getElementById("coLast");
                var phoneEl = document.getElementById("coPhone");
                if (emailEl && p.email && !emailEl.value) emailEl.value = p.email;
                if (firstEl && p.firstName && !firstEl.value) firstEl.value = p.firstName;
                if (lastEl && p.lastName && !lastEl.value) lastEl.value = p.lastName;
                if (phoneEl && p.phoneNumber && !phoneEl.value) phoneEl.value = p.phoneNumber;
            })
            .catch(function () {});
    }

    function showError(msg) {
        var el = document.getElementById("checkoutError");
        if (!el) return;
        el.style.display = "block";
        el.textContent = msg;
        el.scrollIntoView({ behavior: "smooth", block: "center" });
    }

    function placeOrder() {
        if (!token()) {
            window.location.href = "/account.html";
            return;
        }

        clearAllErrors();
        var ok = true;

        if (!isValidEmail(val("coEmail"))) {
            setFieldError("coEmail", "Enter a valid email address.");
            ok = false;
        }

        if (state.deliveryMethod === "SHIP") {
            if (!validateAddress("co", "Shipping")) ok = false;
            if (!state.billingSame) {
                if (!validateAddress("bill", "Billing")) ok = false;
            }
        } else {
            if (!val("coFirst")) {
                setFieldError("coFirst", "First name is required.");
                ok = false;
            }
            if (!val("coLast")) {
                setFieldError("coLast", "Last name is required.");
                ok = false;
            }
            if (!isValidPhone(val("coPhone"))) {
                setFieldError("coPhone", "Enter a valid phone number (9–15 digits).");
                ok = false;
            }
        }

        if (checked("coWholesale")) {
            if (!val("coBusinessName") || val("coBusinessName").length < 2) {
                setFieldError("coBusinessName", "Enter your business or bookstore name.");
                ok = false;
            }
            var wholesaleQty = 0;
            try {
                if (window.RpCart && typeof RpCart.totalItems === "function") {
                    wholesaleQty = RpCart.totalItems(RpCart.read ? RpCart.read() : undefined);
                }
            } catch (e) { /* ignore */ }
            if (wholesaleQty < 10) {
                showError("Wholesale orders require at least 10 books in total. Your cart has " + wholesaleQty + ".");
                ok = false;
            }
        }

        if (!checked("coTerms")) {
            setFieldError("coTerms", "You must agree to the Terms and Privacy Policy.");
            ok = false;
        }

        var payCheck = validatePayment();
        if (!payCheck.ok) ok = false;

        if (!ok) {
            showError(payCheck.message || "Please fix the highlighted fields.");
            return;
        }

        var firstName = val("coFirst");
        var lastName = val("coLast");
        var phone = val("coPhone");
        var addressLine = val("coAddress");
        var apt = val("coApt");
        var city = val("coCity");
        var district = val("coDistrict");
        var postalCode = val("coPostal");
        var country = val("coCountry") || "Sri Lanka";
        var note = checked("coNoteToggle") ? val("coNote") : "";
        var wholesale = checked("coWholesale");
        var businessName = val("coBusinessName");

        // Pickup: still need a name/phone from profile or force ship fields
        if (state.deliveryMethod === "PICKUP") {
            firstName = firstName || "Customer";
            lastName = lastName || "";
            phone = phone || "0000000000";
        }

        var recipient = (firstName + " " + lastName).trim();
        var shipVia = state.shippingOption === "SL_POST" ? "SL Post" : "Koombiyo Courier";
        var parts = [];
        if (state.deliveryMethod === "PICKUP") {
            parts.push("Store pickup, Reading Planet");
        } else {
            if (apt) parts.push(addressLine + ", " + apt);
            else parts.push(addressLine);
            parts.push(city, district, postalCode, country);
            parts.push("(" + shipVia + ")");
        }
        var address = parts.filter(Boolean).join(", ");
        if (note) address += ". Note: " + note;
        if (wholesale) {
            address = "[WHOLESALE" + (businessName ? ": " + businessName : "") + "] " + address;
        }
        address = address.slice(0, 255);

        var body = {
            recipientName: recipient.slice(0, 150),
            recipientPhone: phone,
            shippingAddress: address,
            wholesale: !!wholesale,
            businessName: wholesale ? (businessName || "").slice(0, 150) : null,
            paymentMethod: state.paymentMethod === "PAYHERE" ? "CARD" : "COD"
        };
        if (state.paymentMethod === "PAYHERE") {
            // Only the last 4 digits and brand leave the browser, never the full card number or CVV
            var digits = onlyDigits(val("cardNumber"));
            body.cardLast4 = digits.slice(-4);
            body.cardBrand = ({ VISA: "Visa", MASTER: "Mastercard", AMEX: "Amex" })[detectCardBrand(digits)] || "Card";
        }

        var btn = document.getElementById("placeOrderBtn");
        btn.disabled = true;
        btn.textContent = "Placing order...";

        var syncPromise = RpCart.syncToServer ? RpCart.syncToServer() : Promise.resolve();

        syncPromise
            .then(function () {
                return fetch("/api/customer/orders", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        Authorization: "Bearer " + token()
                    },
                    body: JSON.stringify(body)
                });
            })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success) {
                    showError(data.message || "Checkout failed");
                    btn.disabled = false;
                    btn.textContent = "Place order";
                    return;
                }

                RpCart.clear();
                var order = data.data.order || data.data;
                var payLabel = state.paymentMethod === "PAYHERE"
                    ? "Card (paid) – your invoice has been e-mailed to you"
                    : "Cash on Delivery – pay when your books arrive";
                root.innerHTML =
                    '<div class="checkout-success">' +
                    "<h2>Order placed successfully</h2>" +
                    "<p>Order number: <strong>" + escapeHtml(order.orderNumber) + "</strong></p>" +
                    "<p>Total: <strong>" + money(order.totalAmount) + "</strong></p>" +
                    "<p>Payment: <strong>" + payLabel + "</strong></p>" +
                    (wholesale
                        ? "<p>Type: <strong>Wholesale" +
                          (businessName ? " — " + escapeHtml(businessName) : "") +
                          "</strong></p>"
                        : "<p>Type: <strong>Retail</strong></p>") +
                    "<p class=\"wholesale-hint\">Your order has been sent to our sales team for confirmation. " +
                    "It will move to packing and delivery after an admin confirms it.</p>" +
                    "<p>Status: " + escapeHtml(order.orderStatus || "PENDING_APPROVAL") + "</p>" +
                    '<p style="margin-top:1.5rem;"><a href="/store.html">Continue shopping</a> · ' +
                    '<a href="/account.html">Track this order</a></p></div>';
            })
            .catch(function () {
                showError("Network error. Please try again.");
                btn.disabled = false;
                btn.textContent = "Place order";
            });
    }

    render();
})();
