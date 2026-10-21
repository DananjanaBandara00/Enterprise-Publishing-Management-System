/*
 * Homepage hero carousel.
 *
 * Shows the live customer promotions (sales, offers, ads) that admins manage
 * under Admin → Announcements (/api/announcements/public). With none live it
 * shows a single welcome slide so the hero is never empty. Autoplays, pauses
 * on hover / focus / hidden tab, supports arrows, dots, keyboard and swipe,
 * and stays still for visitors who prefer reduced motion.
 */
(function () {
    "use strict";

    var INTERVAL = 6500;
    var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    var TYPES = {
        SALE: { label: "Sale", icon: "fa-tags" },
        OFFER: { label: "Special offer", icon: "fa-gift" },
        AD: { label: "Featured", icon: "fa-star" }
    };

    var WELCOME = {
        promoType: "AD",
        title: "Stories that stay with you",
        content: "Discover new releases, local authors and timeless classics — delivered to your door.",
        ctaLabel: "Browse the store",
        ctaUrl: "/store.html"
    };

    function esc(s) {
        return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
        });
    }

    function safeUrl(url) {
        url = String(url || "").trim();
        return /^\/(?!\/)/.test(url) || /^https?:\/\//i.test(url) ? url : null;
    }

    /** Small animated illustrations used when a promotion has no image. */
    function art(type) {
        var sparkle = function (x, y, r) {
            return '<path class="twinkle" fill="#fff" d="M' + x + " " + (y - r) + " L" + (x + r * .3) + " " + (y - r * .3) + " L" + (x + r) + " " + y +
                " L" + (x + r * .3) + " " + (y + r * .3) + " L" + x + " " + (y + r) + " L" + (x - r * .3) + " " + (y + r * .3) + " L" + (x - r) + " " + y +
                " L" + (x - r * .3) + " " + (y - r * .3) + 'Z"/>';
        };
        var sparkles = sparkle(60, 70, 14) + sparkle(350, 60, 10) + sparkle(370, 300, 16) + sparkle(40, 290, 9);
        if (type === "SALE") {
            return '<svg class="rp-art" viewBox="0 0 420 380" aria-hidden="true">' + sparkles +
                '<g class="sway"><line x1="210" y1="20" x2="210" y2="80" stroke="rgba(255,255,255,.6)" stroke-width="3"/>' +
                '<path d="M120 90 h180 l40 60 v170 a20 20 0 0 1 -20 20 h-220 a20 20 0 0 1 -20 -20 v-170 Z" fill="#fff" opacity=".95"/>' +
                '<circle cx="210" cy="120" r="12" fill="var(--c2)"/>' +
                '<text x="210" y="240" text-anchor="middle" font-size="96" font-weight="800" fill="var(--c1)" font-family="Rethink Sans, sans-serif">%</text>' +
                '<rect x="150" y="270" width="120" height="12" rx="6" fill="var(--c1)" opacity=".35"/></g></svg>';
        }
        if (type === "OFFER") {
            return '<svg class="rp-art" viewBox="0 0 420 380" aria-hidden="true">' + sparkles +
                '<g><rect x="110" y="170" width="200" height="160" rx="16" fill="#fff" opacity=".95"/>' +
                '<rect x="196" y="170" width="28" height="160" fill="var(--c1)" opacity=".85"/></g>' +
                '<g class="float"><rect x="92" y="122" width="236" height="52" rx="14" fill="#fff"/>' +
                '<rect x="196" y="122" width="28" height="52" fill="var(--c1)"/>' +
                '<path d="M210 122 C 170 70, 130 100, 175 122 Z M210 122 C 250 70, 290 100, 245 122 Z" fill="var(--accent)"/></g></svg>';
        }
        return '<svg class="rp-art" viewBox="0 0 420 380" aria-hidden="true">' + sparkles +
            '<g class="float-2"><path d="M70 120 Q 140 95 210 120 V 320 Q 140 295 70 320 Z" fill="#fff" opacity=".95"/>' +
            '<path d="M350 120 Q 280 95 210 120 V 320 Q 280 295 350 320 Z" fill="#fff" opacity=".85"/>' +
            '<g stroke="var(--c1)" stroke-width="6" stroke-linecap="round" opacity=".35">' +
            '<line x1="100" y1="160" x2="180" y2="150"/><line x1="100" y1="190" x2="180" y2="180"/><line x1="100" y1="220" x2="165" y2="212"/>' +
            '<line x1="240" y1="150" x2="320" y2="160"/><line x1="240" y1="180" x2="320" y2="190"/><line x1="240" y1="210" x2="305" y2="218"/></g></g>' +
            '<g class="float"><circle cx="300" cy="80" r="26" fill="var(--accent)"/></g></svg>';
    }

    function slideHtml(p, index, total) {
        var type = TYPES[p.promoType] ? p.promoType : "OFFER";
        var url = safeUrl(p.ctaUrl);
        var external = url && /^https?:/i.test(url);
        var i = 0;
        var copy =
            '<span class="rp-slide__eyebrow" style="--i:' + (i++) + '"><i class="fas ' + TYPES[type].icon + '" aria-hidden="true"></i>' + TYPES[type].label + "</span>" +
            (p.badgeText ? '<span class="rp-slide__badge" style="--i:' + (i++) + '">' + esc(p.badgeText) + "</span>" : "") +
            '<h2 class="rp-slide__title" style="--i:' + (i++) + '">' + esc(p.title) + "</h2>" +
            '<p class="rp-slide__text" style="--i:' + (i++) + '">' + esc(p.content) + "</p>" +
            (url ? '<a class="rp-slide__cta" style="--i:' + (i++) + '" href="' + esc(url) + '"' +
                (external ? ' target="_blank" rel="noopener noreferrer"' : "") + ">" + esc(p.ctaLabel || "Shop now") +
                ' <i class="fas fa-arrow-right" aria-hidden="true"></i></a>' : "");
        var media = p.imageUrl
            ? '<div class="rp-slide__frame"><img src="' + esc(p.imageUrl) + '" alt="" loading="' + (index === 0 ? "eager" : "lazy") + '"></div>'
            : art(type);
        return '<article class="rp-slide rp-slide--' + type.toLowerCase() + '" role="group" aria-roledescription="slide" aria-label="' +
            (index + 1) + " of " + total + '">' +
            '<div class="rp-slide__bg" aria-hidden="true"><span class="rp-orb rp-orb--1"></span><span class="rp-orb rp-orb--2"></span><span class="rp-orb rp-orb--3"></span></div>' +
            '<div class="rp-slide__inner"><div class="rp-slide__copy">' + copy + '</div><div class="rp-slide__media">' + media + "</div></div></article>";
    }

    function mount(hero, promos) {
        var list = promos.length ? promos : [WELCOME];
        var total = list.length;

        hero.innerHTML = list.map(function (p, i) { return slideHtml(p, i, total); }).join("") +
            '<div class="rp-hero__controls">' +
            '<div class="rp-hero__dots" role="tablist" aria-label="Choose promotion">' +
            list.map(function (p, i) {
                return '<button type="button" class="rp-hero__dot" role="tab" aria-label="Show ' + esc(p.title) + '" data-index="' + i + '"></button>';
            }).join("") + "</div>" +
            '<button type="button" class="rp-hero__btn rp-hero__btn--pause" aria-label="Pause slideshow"><i class="fas fa-pause" aria-hidden="true"></i></button>' +
            '<button type="button" class="rp-hero__btn rp-hero__prev" aria-label="Previous promotion"><i class="fas fa-arrow-left" aria-hidden="true"></i></button>' +
            '<button type="button" class="rp-hero__btn rp-hero__next" aria-label="Next promotion"><i class="fas fa-arrow-right" aria-hidden="true"></i></button>' +
            "</div>";

        var slides = hero.querySelectorAll(".rp-slide");
        var dots = hero.querySelectorAll(".rp-hero__dot");
        var pauseBtn = hero.querySelector(".rp-hero__btn--pause");
        var current = -1;
        var timer = null;
        var userPaused = reduceMotion;
        var hovering = false;

        hero.style.setProperty("--hero-interval", INTERVAL + "ms");
        if (total === 1) hero.classList.add("rp-hero--single");

        function show(index) {
            index = (index + total) % total;
            if (index === current) return;
            slides.forEach(function (s, i) {
                var on = i === index;
                s.classList.toggle("is-active", on);
                s.setAttribute("aria-hidden", String(!on));
                // Keep links in hidden slides out of the tab order
                s.querySelectorAll("a").forEach(function (a) { a.tabIndex = on ? 0 : -1; });
            });
            dots.forEach(function (d, i) {
                d.classList.remove("is-active");
                d.setAttribute("aria-selected", String(i === index));
                if (i === index) {
                    void d.offsetWidth; // restart the progress animation
                    d.classList.add("is-active");
                }
            });
            current = index;
            schedule();
        }

        function schedule() {
            clearTimeout(timer);
            var paused = userPaused || hovering || document.hidden;
            hero.classList.toggle("is-paused", paused && !userPaused);
            hero.classList.toggle("is-static", userPaused);
            if (!paused && total > 1) timer = setTimeout(function () { show(current + 1); }, INTERVAL);
        }

        function restartProgress() {
            var d = dots[current];
            if (!d) return;
            d.classList.remove("is-active");
            void d.offsetWidth;
            d.classList.add("is-active");
        }

        function setUserPaused(p) {
            userPaused = p;
            pauseBtn.setAttribute("aria-label", p ? "Play slideshow" : "Pause slideshow");
            pauseBtn.innerHTML = '<i class="fas ' + (p ? "fa-play" : "fa-pause") + '" aria-hidden="true"></i>';
            if (!p) restartProgress();
            schedule();
        }

        hero.querySelector(".rp-hero__prev").addEventListener("click", function () { show(current - 1); });
        hero.querySelector(".rp-hero__next").addEventListener("click", function () { show(current + 1); });
        pauseBtn.addEventListener("click", function () { setUserPaused(!userPaused); });
        dots.forEach(function (d) {
            d.addEventListener("click", function () { show(Number(d.getAttribute("data-index"))); });
        });

        // Hover pauses (the progress bar freezes); leaving starts the slide's full time again
        hero.addEventListener("mouseenter", function () { hovering = true; clearTimeout(timer); hero.classList.add("is-paused"); });
        hero.addEventListener("mouseleave", function () { hovering = false; if (!userPaused) restartProgress(); schedule(); });
        hero.addEventListener("focusin", function () { hovering = true; schedule(); });
        hero.addEventListener("focusout", function (e) {
            if (!hero.contains(e.relatedTarget)) { hovering = false; schedule(); }
        });
        document.addEventListener("visibilitychange", function () { if (!document.hidden) restartProgress(); schedule(); });

        hero.addEventListener("keydown", function (e) {
            if (e.key === "ArrowLeft") { show(current - 1); e.preventDefault(); }
            else if (e.key === "ArrowRight") { show(current + 1); e.preventDefault(); }
        });

        // Swipe on touch screens
        var startX = null, startY = null;
        hero.addEventListener("touchstart", function (e) {
            startX = e.touches[0].clientX; startY = e.touches[0].clientY;
        }, { passive: true });
        hero.addEventListener("touchend", function (e) {
            if (startX == null) return;
            var dx = e.changedTouches[0].clientX - startX;
            var dy = e.changedTouches[0].clientY - startY;
            if (Math.abs(dx) > 50 && Math.abs(dx) > Math.abs(dy)) show(current + (dx < 0 ? 1 : -1));
            startX = null;
        });

        if (reduceMotion) setUserPaused(true);
        show(0);
    }

    function start() {
        var hero = document.getElementById("rp-hero");
        if (!hero) return;
        fetch("/api/announcements/public")
            .then(function (res) { return res.ok ? res.json() : null; })
            .then(function (body) { mount(hero, (body && Array.isArray(body.data)) ? body.data : []); })
            .catch(function () { mount(hero, []); });
    }

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start);
    else start();
})();
