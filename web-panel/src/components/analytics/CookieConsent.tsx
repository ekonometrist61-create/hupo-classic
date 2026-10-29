"use client";

import { Link } from "@/i18n/navigation";
import {
  COOKIE_PREFERENCES_OPEN_EVENT,
  readAnalyticsConsent,
  writeAnalyticsConsent,
} from "@/lib/analytics/consent";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

// Çerez onay bandı. Kabul ve reddet aynı görsel ağırlıktadır; reddetmek kabul etmek kadar
// kolaydır. Zorunlu oturum çerezleri onaya bağlı değildir.
export default function CookieConsent() {
  const t = useTranslations("cookie");
  const [gorunur, setGorunur] = useState(false);

  useEffect(() => {
    // Karar yoksa veya metin sürümü değiştiyse banner gösterilir.
    if (readAnalyticsConsent() === null) setGorunur(true);

    const ac = () => setGorunur(true);
    window.addEventListener(COOKIE_PREFERENCES_OPEN_EVENT, ac);
    return () => window.removeEventListener(COOKIE_PREFERENCES_OPEN_EVENT, ac);
  }, []);

  if (!gorunur) return null;

  function karar(durum: "granted" | "denied") {
    writeAnalyticsConsent(durum);
    setGorunur(false);
  }

  // Tek satır: kısa metin, "Tercihler" (gizlilik sayfası) ve iki eşit ağırlıklı karar düğmesi.
  return (
    <section
      aria-labelledby="cookie-baslik"
      className="fixed inset-x-0 bottom-0 z-50 border-t border-navy/10 bg-white px-3 py-1.5 shadow-lg sm:px-4 sm:py-3"
    >
      <h2 id="cookie-baslik" className="sr-only">
        {t("title")}
      </h2>
      <div className="mx-auto flex max-w-5xl items-center gap-1 sm:gap-3">
        <p className="min-w-0 flex-1 truncate text-xs text-navy-muted sm:text-sm">{t("shortText")}</p>
        <Link
          href="/gizlilik"
          className="inline-flex h-11 shrink-0 items-center px-1.5 text-xs font-semibold sm:px-2 sm:text-sm text-brand-700 underline underline-offset-4 hover:text-brand-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("preferences")}
        </Link>
        <button
          type="button"
          onClick={() => karar("denied")}
          className="inline-flex h-11 shrink-0 items-center justify-center rounded-xl border border-navy/20 px-3 text-xs font-semibold sm:px-4 sm:text-sm text-navy hover:bg-navy/5 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("reject")}
        </button>
        <button
          type="button"
          onClick={() => karar("granted")}
          className="inline-flex h-11 shrink-0 items-center justify-center rounded-xl bg-brand-500 px-3 text-xs font-semibold sm:px-4 sm:text-sm text-white hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("accept")}
        </button>
      </div>
    </section>
  );
}
