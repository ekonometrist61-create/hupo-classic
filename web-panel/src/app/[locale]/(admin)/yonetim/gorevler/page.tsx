import { getTranslations, setRequestLocale } from "next-intl/server";

import { yapiskanBaslik, yapiskanHucre } from "@/components/yonetim/ui/responsive";
import { createClient } from "@/utils/supabase/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sayfalar.gorevler");
  return { title: t("title") };
}

export default async function GorevlerPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.sayfalar.gorevler");

  const supabase = await createClient();
  const { data: gorevler, error } = await supabase
    .from("quest_definitions")
    .select("kod, baslik, aciklama, hedef_tipi, hedef_deger, odul_xp, aktif, sira")
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
              <th className="px-4 py-3">{t("cols.baslik")}</th>
              <th className="px-4 py-3">{t("cols.aciklama")}</th>
              <th className="px-4 py-3">{t("cols.hedefTipi")}</th>
              <th className="px-4 py-3">{t("cols.hedefDeger")}</th>
              <th className="px-4 py-3">{t("cols.xp")}</th>
              <th className="px-4 py-3">{t("cols.aktif")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {gorevler && gorevler.length > 0 ? (
              gorevler.map((gorev) => (
                <tr
                  key={gorev.kod}
                  className="bg-white hover:bg-gray-50 dark:bg-gray-900 dark:hover:bg-gray-800"
                >
                  <td className={`px-4 py-3 font-medium ${yapiskanHucre}`}>{gorev.kod}</td>
                  <td className="px-4 py-3">{gorev.baslik}</td>
                  <td className="max-w-xs px-4 py-3 text-gray-600 dark:text-gray-400">
                    {gorev.aciklama}
                  </td>
                  <td className="px-4 py-3">{gorev.hedef_tipi}</td>
                  <td className="px-4 py-3">{gorev.hedef_deger}</td>
                  <td className="px-4 py-3">{gorev.odul_xp}</td>
                  <td className="px-4 py-3">
                    {gorev.aktif ? (
                      <span className="font-medium text-green-600">{t("yes")}</span>
                    ) : (
                      <span className="text-gray-400">{t("no")}</span>
                    )}
                  </td>
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
