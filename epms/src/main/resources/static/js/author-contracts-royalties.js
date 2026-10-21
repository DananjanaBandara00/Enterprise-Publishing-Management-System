(function () {
    "use strict";

    const token = localStorage.getItem("rp_token") || sessionStorage.getItem("rp_token");
    const userRaw = localStorage.getItem("rp_user") || sessionStorage.getItem("rp_user");

    if (!token || !userRaw) {
        window.location.replace("/author-login.html");
        return;
    }

    const headers = { "Authorization": "Bearer " + token, "Content-Type": "application/json" };
    const notice = document.getElementById("notice");

    function showNotice(message, type) {
        notice.textContent = message;
        notice.className = "notice " + type;
        window.scrollTo({ top: 0, behavior: "smooth" });
    }

    async function api(url, options) {
        const response = await fetch(url, Object.assign({ headers }, options || {}));
        if (response.status === 401) {
            localStorage.removeItem("rp_token");
            sessionStorage.removeItem("rp_token");
            window.location.replace("/author-login.html");
            throw new Error("Session expired");
        }
        const body = await response.json().catch(() => ({}));
        if (!response.ok || body.success === false) throw new Error(body.message || "Request failed");
        return body.data;
    }

    function escapeHtml(value) {
        return String(value == null ? "" : value)
            .replaceAll("&", "&amp;").replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;").replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    // DRAFT -> author signs -> finance activates -> EXPIRED
    const STAGES = {
        AWAITING_SIGNATURE: { label: "Awaiting your signature", icon: "fa-pen-nib",
            note: "Review the terms below and sign. Finance activates the agreement once you have signed it." },
        AWAITING_ACTIVATION: { label: "Signed, awaiting activation", cls: "signed", icon: "fa-hourglass-half",
            note: "You have signed this agreement. Finance will activate it; royalties are calculated once it is active." },
        ACTIVE: { label: "Active", cls: "signed", icon: "fa-circle-check",
            note: "This agreement is active. Royalties are calculated on completed sales and shown under royalty statements." },
        ACTIVE_UNSIGNED: { label: "Active, signature needed", icon: "fa-pen-nib",
            note: "This agreement is active but has not been signed yet. Please review and sign it." },
        EXPIRED: { label: "Expired", icon: "fa-ban", note: "This agreement has expired. No further royalties are calculated on it." }
    };

    function renderAgreements(contracts) {
        const root = document.getElementById("agreements");
        if (!contracts || !contracts.length) {
            root.innerHTML = '<div class="empty">No publisher-issued agreement is available yet.</div>';
            return;
        }

        root.innerHTML = contracts.map(function (c) {
            const stage = STAGES[c.stage] || { label: String(c.status || "").replaceAll("_", " "), note: "" };
            const canSign = !c.signed && c.stage !== "EXPIRED";
            const money = function (v) { return Number(v || 0).toLocaleString("en-US", { minimumFractionDigits: 2 }); };
            return `
                <article class="agreement" data-id="${c.contractId}" tabindex="0" role="link" aria-label="View agreement ${escapeHtml(c.agreementNumber)}" title="Click to view the agreement">
                    <div class="agreement-head">
                        <div>
                            <div class="agreement-title">${escapeHtml(c.agreementTitle)}</div>
                            <div class="agreement-meta">${escapeHtml(c.manuscriptTitle || "Publishing agreement")}</div>
                        </div>
                        <span class="badge ${stage.cls || ""}">${escapeHtml(stage.label)}</span>
                    </div>
                    <div class="terms">
                        <div class="term"><span>Royalty Rate</span><strong>${escapeHtml(c.royaltyRate)}% of ${c.basis === "LIST_PRICE" ? "list price" : "net sales"}</strong></div>
                        <div class="term"><span>Bookstore (Wholesale) Rate</span><strong>${escapeHtml(c.wholesaleRate != null ? c.wholesaleRate : c.royaltyRate)}%</strong></div>
                        <div class="term"><span>Advance</span><strong>Rs ${escapeHtml(money(c.advanceAmount))}</strong></div>
                        <div class="term"><span>Paid</span><strong>${escapeHtml(String(c.paymentFrequency || "").toLowerCase())}</strong></div>
                        <div class="term"><span>Effective</span><strong>${escapeHtml(c.effectiveDate || "—")} to ${escapeHtml(c.expiryDate || "open")}</strong></div>
                        <div class="term"><span>Signed</span><strong>${escapeHtml(c.signedAt ? new Date(c.signedAt).toLocaleString() : "Not signed")}</strong></div>
                    </div>
                    <div class="doc-actions">
                        <button type="button" class="btn btn-secondary doc-btn" data-id="${c.contractId}" data-download="false"><i class="fas fa-eye"></i> View Agreement</button>
                        <button type="button" class="btn btn-secondary doc-btn" data-id="${c.contractId}" data-download="true"><i class="fas fa-download"></i> Download PDF</button>
                    </div>
                    ${stage.note ? '<div class="finance-note"><i class="fas ' + stage.icon + '"></i> ' + stage.note + "</div>" : ""}
                    ${canSign ? `
                        <label class="sign-row"><input type="checkbox" class="agreement-check" data-id="${c.contractId}"> I have read and agree to this agreement.</label>
                        <button class="btn btn-primary sign-btn" data-id="${c.contractId}"><i class="fas fa-signature"></i> Accept &amp; Sign Agreement</button>
                    ` : ""}
                </article>`;
        }).join("");

        // Clicking anywhere on an agreement opens it, except its own buttons, links and the sign checkbox.
        root.querySelectorAll(".agreement").forEach(function (card) {
            function view(event) {
                if (event.target.closest("button, a, input, label")) return;
                const tab = window.open("", "_blank");
                openDocument(card.dataset.id, false, tab).catch(function (e) {
                    if (tab) tab.close();
                    showNotice(e.message, "error");
                });
            }
            card.addEventListener("click", view);
            card.addEventListener("keydown", function (event) {
                if (event.target === card && (event.key === "Enter" || event.key === " ")) {
                    event.preventDefault();
                    view(event);
                }
            });
        });

        root.querySelectorAll(".doc-btn").forEach(function (button) {
            button.addEventListener("click", async function () {
                const download = button.dataset.download === "true";
                // Open the tab now, inside the click, so the browser does not block it as a pop-up.
                const tab = download ? null : window.open("", "_blank");
                button.disabled = true;
                try {
                    await openDocument(button.dataset.id, download, tab);
                } catch (e) {
                    if (tab) tab.close();
                    showNotice(e.message, "error");
                } finally {
                    button.disabled = false;
                }
            });
        });

        root.querySelectorAll(".sign-btn").forEach(function (button) {
            button.addEventListener("click", async function () {
                const id = button.dataset.id;
                const checkbox = root.querySelector('.agreement-check[data-id="' + id + '"]');
                if (!checkbox.checked) {
                    showNotice("Please confirm that you have read and agree to the agreement.", "error");
                    return;
                }
                button.disabled = true;
                try {
                    await api("/api/authors/contracts-royalties/" + id + "/sign", { method: "POST" });
                    showNotice("Agreement accepted and signed successfully.", "success");
                    await load();
                } catch (e) {
                    button.disabled = false;
                    showNotice(e.message, "error");
                }
            });
        });
    }

    /** The agreement PDF needs the login token, so it is fetched here rather than linked. */
    async function openDocument(id, download, tab) {
        const response = await fetch("/api/author/contracts/" + id + "/document?download=" + download,
            { headers: { "Authorization": "Bearer " + token } });
        if (response.status === 401) {
            window.location.replace("/author-login.html");
            throw new Error("Session expired");
        }
        if (!response.ok) {
            const body = await response.json().catch(() => ({}));
            throw new Error(body.message || "Could not open the agreement");
        }
        const url = URL.createObjectURL(await response.blob());
        if (download) {
            const m = /filename="?([^";]+)"?/.exec(response.headers.get("Content-Disposition") || "");
            const a = document.createElement("a");
            a.href = url;
            a.download = m ? m[1] : "royalty-agreement.pdf";
            document.body.appendChild(a);
            a.click();
            a.remove();
        } else {
            tab.location.href = url;
        }
        setTimeout(function () { URL.revokeObjectURL(url); }, 60000);
    }

    function renderBank(details) {
        if (!details) return;
        document.getElementById("accountName").value = details.accountName || "";
        document.getElementById("bankName").value = details.bankName || "";
        document.getElementById("accountNumber").value = details.accountNumber || "";
        document.getElementById("branch").value = details.branch || "";
    }

    function renderNotifications(items) {
        const root = document.getElementById("notifications");
        if (!items || !items.length) {
            root.innerHTML = '<div class="empty">No finance notifications yet.</div>';
            return;
        }
        root.innerHTML = items.map(function (n) {
            return `<div class="notification"><strong>${escapeHtml(n.title)}</strong><p>${escapeHtml(n.message)}</p></div>`;
        }).join("");
    }

    async function load() {
        try {
            const data = await api("/api/authors/contracts-royalties");
            renderAgreements(data.contracts);
            renderBank(data.bankDetails);
            renderNotifications(data.notifications);
        } catch (e) {
            showNotice(e.message, "error");
        }
    }

    document.getElementById("bankForm").addEventListener("submit", async function (event) {
        event.preventDefault();
        const payload = {
            accountName: document.getElementById("accountName").value.trim(),
            bankName: document.getElementById("bankName").value.trim(),
            accountNumber: document.getElementById("accountNumber").value.trim(),
            branch: document.getElementById("branch").value.trim()
        };
        try {
            await api("/api/authors/contracts-royalties/bank-details", {
                method: "PUT",
                body: JSON.stringify(payload)
            });
            showNotice("Bank details updated. Finance has been notified.", "success");
            await load();
        } catch (e) {
            showNotice(e.message, "error");
        }
    });

    load();
})();
