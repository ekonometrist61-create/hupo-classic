import { getTranslations, setRequestLocale } from "next-intl/server";
import Image from "next/image";

import { yapiskanBaslik, yapiskanHucre } from "@/components/yonetim/ui/responsive";
import { createClient } from "@/utils/supabase/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sayfalar.karakterler");
  return { title: t("title") };
}

interface CharRow {
  kod: string;
  ad: string;
  sinif: string;
  sinif_sira: number;
  karakter_sira: number;
  kosul_turu: string;
  kosul_deger: number | null;
  kazanan_sayisi: number;
}

/** Bilinen koşul türleri; bilinmeyen tür veritabanındaki değeriyle gösterilir. */
const KOSUL_ANAHTARLARI = ["baslangic", "soru_sayisi", "seri", "ders_basarisi", "lig"];

export default async function KarakterlerPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.sayfalar.karakterler");

  const supabase = await createClient();
  const { data, error } = await supabase.rpc("admin_list_characters");

  if (error) {
    return (
      <div className="rounded-lg bg-red-50 p-4 text-red-700 sm:p-8 dark:bg-red-900/20 dark:text-red-400">
        {t("error", { message: error.message })}
      </div>
    );
  }

  const rows = (data as CharRow[]) ?? [];

  // Mobilde (768 px altı) tablo kendi kapsayıcısında kayar; ilk sütun (karakter) sabit kalır (R4).
  return (
    <div className="p-4 sm:p-8">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-2">
        <h1 className="text-2xl font-bold">{t("title")}</h1>
        <span className="text-sm text-gray-500">{t("count", { n: rows.length })}</span>
      </div>

      <div className="overflow-x-auto rounded-2xl border border-gray-200 dark:border-gray-700">
        <table className="w-full text-left text-sm">
          <thead className="bg-gray-50 text-xs text-gray-600 uppercase dark:bg-gray-800 dark:text-gray-300">
            <tr>
              <th className={`px-4 py-3 ${yapiskanBaslik}`}>{t("cols.karakter")}</th>
              <th className="px-4 py-3">{t("cols.kod")}</th>
              <th className="px-4 py-3">{t("cols.sinif")}</th>
              <th className="px-4 py-3">{t("cols.sira")}</th>
              <th className="px-4 py-3">{t("cols.kosul")}</th>
              <th className="px-4 py-3">{t("cols.kazanan")}</th>
              <th className="px-4 py-3">{t("cols.durum")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {rows.length > 0 ? (
              rows.map((row) => (
                <tr
                  key={row.kod}
                  className="bg-white hover:bg-gray-50 dark:bg-gray-900 dark:hover:bg-gray-800"
                >
                  <td className={`px-4 py-3 ${yapiskanHucre}`}>
                    <div className="flex items-center gap-3">
                      <div className="relative h-10 w-10 shrink-0 overflow-hidden rounded-lg bg-gray-100 dark:bg-gray-800">
                        <Image
                          src={`/characters/${row.sinif}/${row.kod}.webp`}
                          alt={row.ad}
                          fill
                          className="object-contain"
                          sizes="40px"
                        />
                      </div>
                      <span className="font-medium text-gray-900 dark:text-white">{row.ad}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 font-mono text-xs text-gray-500">{row.kod}</td>
                  <td className="px-4 py-3">{row.sinif}</td>
                  <td className="px-4 py-3 text-gray-500">{row.karakter_sira}/5</td>
                  <td className="px-4 py-3">
                    <span className="text-gray-700 dark:text-gray-300">
                      {KOSUL_ANAHTARLARI.includes(row.kosul_turu)
                        ? t(`kosul.${row.kosul_turu}`)
                        : row.kosul_turu}
                      {row.kosul_deger != null && (
                        <span className="ms-1 text-xs text-gray-400">({row.kosul_deger})</span>
                      )}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{row.kazanan_sayisi}</td>
                  <td className="px-4 py-3">
                    {row.kosul_turu === "baslangic" ? (
                      <span className="inline-flex rounded-full bg-green-100 px-2 py-0.5 text-xs font-semibold text-green-700 dark:bg-green-900/30 dark:text-green-400">
                        {t("active")}
                      </span>
                    ) : (
                      <span className="inline-flex rounded-full bg-gray-100 px-2 py-0.5 text-xs font-semibold text-gray-500 dark:bg-gray-800 dark:text-gray-400">
                        {t("locked")}
                      </span>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={7} className="px-4 py-8 text-center text-gray-500">
                  {t("empty")}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
