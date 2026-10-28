"use client";

import { useTranslations } from "next-intl";

import AbonelikKarti from "./AbonelikKarti";
import IletisimIzniCard from "./IletisimIzniCard";
import OdemeGecmisi from "./OdemeGecmisi";
import DenemeDurumuKarti from "./DenemeDurumuKarti";
import PlanKarti from "./PlanKarti";

// Üyelik & Hesap: abonelik, plan, ödeme geçmişi ve iletişim izni (çocuk verisi içermez).
// K4 gereği iletişim izni kartı ana ekrandan bu sayfaya taşındı.
// Deneme kartı yalnızca çocukların deneme durumunu (sınır ve bitiş) gösterir.
export default function MembershipView({
  students = [],
}: {
  students?: { id: string; full_name: string | null }[];
}) {
  const t = useTranslations("veliPaneli.membership");

  return (
    <div className="space-y-4 md:space-y-6">
      <p className="text-theme-sm text-gray-500 dark:text-gray-400">
        {t("desc")}
      </p>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-6">
        <AbonelikKarti />
        <PlanKarti />
        <DenemeDurumuKarti students={students} />
        <OdemeGecmisi />
        <IletisimIzniCard />
      </div>
    </div>
  );
}
