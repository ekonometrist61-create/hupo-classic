"use client";

import { useTranslations } from "next-intl";

import AbonelikKarti from "./AbonelikKarti";
import OdemeGecmisi from "./OdemeGecmisi";
import PlanKarti from "./PlanKarti";

// Üyelik & Hesap: veli hesabının aboneliği, plan durumu ve ödeme geçmişi (çocuk verisi içermez).
export default function MembershipView() {
  const t = useTranslations("veliPaneli.membership");

  return (
    <div className="space-y-4 md:space-y-6">
      <p className="text-theme-sm text-gray-500 dark:text-gray-400">
        {t("desc")}
      </p>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-6">
        <AbonelikKarti />
        <PlanKarti />
        <OdemeGecmisi />
      </div>
    </div>
  );
}
