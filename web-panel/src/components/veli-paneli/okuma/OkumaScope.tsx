"use client";

// Okuma ve Dil veli sayfasının kabuğu: çocuk seçimi, beceri ve dil profili, kelime gelişimi,
// ayrıntılı okuma özeti ve değer önceliği. ChildScope kullanılmaz: değer önceliği rıza gerektirmez;
// okuma özetinin rıza kapısı sunucudadır.
import { useState } from "react";
import { useTranslations } from "next-intl";

import KelimeGelisimKarti from "../KelimeGelisimKarti";
import StudentSwitcher from "../StudentSwitcher";
import type { Student } from "../types";
import VeliMessage from "../VeliMessage";
import OkumaDegerleri from "./OkumaDegerleri";
import OkumaDilOzeti from "./OkumaDilOzeti";
import OkumaOzeti from "./OkumaOzeti";

export default function OkumaScope({ students }: { students: Student[] }) {
  const t = useTranslations("veliPaneli");
  const [secili, setSecili] = useState(students[0]?.id ?? "");

  if (students.length === 0) {
    return <VeliMessage title={t("noChildren.title")} text={t("noChildren.text")} />;
  }

  const ogrenci = students.find((s) => s.id === secili) ?? null;
  const cocukAd = ogrenci?.full_name ?? ogrenci?.username ?? null;

  return (
    <div className="space-y-4 md:space-y-6">
      <p className="text-sm text-gray-600 dark:text-gray-300">{t("okuma.giris")}</p>
      <StudentSwitcher students={students} selectedId={secili} onChange={setSecili} />
      <OkumaDilOzeti key={`dil-${secili}`} cocukId={secili} />
      <KelimeGelisimKarti key={`kelime-${secili}`} cocukId={secili} cocukAd={cocukAd} />
      <OkumaOzeti key={`o-${secili}`} cocukId={secili} />
      <OkumaDegerleri key={`d-${secili}`} cocukId={secili} />
    </div>
  );
}
