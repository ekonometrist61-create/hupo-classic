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

  return (
    <section
      aria-labelledby="cookie-baslik"
      className="fixed inset-x-0 bottom-0 z-50 border-t border-navy/10 bg-white p-4 shadow-lg sm:p-5"
    >
      <div className="mx-auto flex max-w-5xl flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="max-w-2xl">
          <h2 id="cookie-baslik" className="text-base font-bold text-navy">
            {t("title")}
          </h2>
          <p className="mt-1 text-sm text-navy-muted">
            {t("text")}{" "}
            <Link
              href="/gizlilik"
              className="font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800"
            >
              {t("policy")}
            </Link>
          </p>
        </div>
        <div className="flex shrink-0 gap-3">
          <button
            type="button"
            onClick={() => karar("denied")}
            className="inline-flex h-11 min-w-28 items-center justify-center rounded-xl border border-navy/20 px-5 text-sm font-semibold text-navy hover:bg-navy/5 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("reject")}
          </button>
          <button
            type="button"
            onClick={() => karar("granted")}
            className="inline-flex h-11 min-w-28 items-center justify-center rounded-xl bg-brand-500 px-5 text-sm font-semibold text-white hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("accept")}
          </button>
        </div>
      </div>
    </section>
  );
}
