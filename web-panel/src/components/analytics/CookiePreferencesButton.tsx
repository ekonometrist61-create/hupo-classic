"use client";

import { openCookiePreferences } from "@/lib/analytics/consent";
import { useTranslations } from "next-intl";

// Çerez tercihini yeniden açar; onayı geri almak da vermek kadar kolaydır.
export default function CookiePreferencesButton() {
  const t = useTranslations("cookie");
  return (
    <button
      type="button"
      onClick={openCookiePreferences}
      className="mt-2 inline-flex min-h-11 items-center rounded-xl border border-navy/20 px-5 text-sm font-semibold text-navy hover:bg-navy/5 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
    >
      {t("openPreferences")}
    </button>
  );
}
