"use client";

// Okuma Dünyası veli sayfasının kabuğu: çocuk seçimi, değer önceliği ve okuma özeti.
// ChildScope kullanılmaz: değer önceliği rıza gerektirmez; özetin rıza kapısı sunucudadır.
import { useState } from "react";
import { useTranslations } from "next-intl";

import StudentSwitcher from "../StudentSwitcher";
import type { Student } from "../types";
import VeliMessage from "../VeliMessage";
import OkumaDegerleri from "./OkumaDegerleri";
import OkumaOzeti from "./OkumaOzeti";

export default function OkumaScope({ students }: { students: Student[] }) {
  const t = useTranslations("veliPaneli");
  const [secili, setSecili] = useState(students[0]?.id ?? "");

  if (students.length === 0) {
    return <VeliMessage title={t("noChildren.title")} text={t("noChildren.text")} />;
  }

  return (
    <div className="space-y-4 md:space-y-6">
      <p className="text-sm text-gray-600 dark:text-gray-300">{t("okuma.giris")}</p>
      <StudentSwitcher students={students} selectedId={secili} onChange={setSecili} />
      <OkumaOzeti key={`o-${secili}`} cocukId={secili} />
      <OkumaDegerleri key={`d-${secili}`} cocukId={secili} />
    </div>
  );
}
