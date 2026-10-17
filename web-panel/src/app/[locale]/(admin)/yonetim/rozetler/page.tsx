import { getTranslations, setRequestLocale } from "next-intl/server";

import { yapiskanBaslik, yapiskanHucre } from "@/components/yonetim/ui/responsive";
import { createClient } from "@/utils/supabase/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sayfalar.rozetler");
  return { title: t("title") };
}

export default async function RozetlerPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.sayfalar.rozetler");

  const supabase = await createClient();
  const { data: rozetler, error } = await supabase
    .from("badge_definitions")
    .select("kod, ad, aciklama, ikon, kosul_turu, esik, ders, sira")
    .order("sira", { ascending: true });

  if (error) {
    return (
      <div className="p-4 text-red-600 sm:p-8">
        {t("error", { message: error.message })}
      </div>
    );
  }

  // Mobilde (768 px altı) tablo kendi kapsayıcısında kayar; ilk sütun sabit kalır (R4).
  return (
    <div className="p-4 sm:p-8">
      <h1 className="mb-6 text-2xl font-bold">{t("title")}</h1>
      <div className="overflow-x-auto rounded-lg border border-gray-200 dark:border-gray-700">
        <table className="w-full text-left text-sm">
          <thead className="bg-gray-50 text-xs text-gray-700 uppercase dark:bg-gray-800 dark:text-gray-300">
            <tr>
              <th className={`px-4 py-3 ${yapiskanBaslik}`}>{t("cols.kod")}</th>
              <th className="px-4 py-3">{t("cols.ad")}</th>
              <th className="px-4 py-3">{t("cols.aciklama")}</th>
              <th className="px-4 py-3">{t("cols.ikon")}</th>
              <th className="px-4 py-3">{t("cols.kosul")}</th>
              <th className="px-4 py-3">{t("cols.esik")}</th>
              <th className="px-4 py-3">{t("cols.ders")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {rozetler && rozetler.length > 0 ? (
              rozetler.map((rozet) => (
                <tr
                  key={rozet.kod}
                  className="bg-white hover:bg-gray-50 dark:bg-gray-900 dark:hover:bg-gray-800"
                >
                  <td className={`px-4 py-3 font-medium ${yapiskanHucre}`}>{rozet.kod}</td>
                  <td className="px-4 py-3">{rozet.ad}</td>
                  <td className="max-w-xs px-4 py-3 text-gray-600 dark:text-gray-400">
                    {rozet.aciklama}
                  </td>
                  <td className="px-4 py-3">{rozet.ikon}</td>
                  <td className="px-4 py-3">{rozet.kosul_turu}</td>
                  <td className="px-4 py-3">{rozet.esik}</td>
                  <td className="px-4 py-3">{rozet.ders ?? "—"}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={7} className="px-4 py-6 text-center text-gray-500">
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
