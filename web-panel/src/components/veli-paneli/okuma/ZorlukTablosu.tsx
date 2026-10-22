"use client";

// Haftalık zorluk seyri tablosu (1 kolay, 5 zor). Veli özeti, öğretmenin bireysel özeti ve sınıf toplamı ortak kullanır.
// Sınıf toplamında `ogrenci_sayisi` sütunu açılır; satırlar sunucuda zaten min-N süzgecinden geçmiştir.
import { useLocale, useTranslations } from "next-intl";

import type { ZorlukHaftasi } from "./okumaTipleri";

export default function ZorlukTablosu({ haftalar, ogrenciBasligi }: { haftalar: ZorlukHaftasi[]; ogrenciBasligi?: string }) {
  const t = useTranslations("veliPaneli.okuma.zorluk");
  const locale = useLocale();
  const bicim = new Intl.DateTimeFormat(locale === "en" ? "en-US" : "tr-TR", { day: "numeric", month: "short" });
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full text-left text-sm">
        <thead>
          <tr className="text-theme-xs text-gray-600 dark:text-gray-400">
            <th scope="col" className="py-1 pe-4 font-medium">{t("hafta")}</th>
            {ogrenciBasligi && <th scope="col" className="py-1 pe-4 font-medium">{ogrenciBasligi}</th>}
            <th scope="col" className="py-1 pe-4 font-medium">{t("hikaye")}</th>
            <th scope="col" className="py-1 pe-4 font-medium">{t("okuma")}</th>
            <th scope="col" className="py-1 font-medium">{t("kavram")}</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100 text-gray-700 dark:divide-gray-800 dark:text-gray-300">
          {haftalar.map((z) => (
            <tr key={z.hafta}>
              <td className="py-2 pe-4">{bicim.format(new Date(z.hafta))}</td>
              {ogrenciBasligi && <td className="py-2 pe-4">{z.ogrenci_sayisi ?? "-"}</td>}
              <td className="py-2 pe-4">{z.hikaye}</td>
              <td className="py-2 pe-4">{z.ort_okuma_zorlugu ?? "-"}</td>
              <td className="py-2">{z.ort_kavram_zorlugu ?? "-"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
