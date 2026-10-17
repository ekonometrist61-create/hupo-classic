import { getTranslations, setRequestLocale } from "next-intl/server";

import { yapiskanBaslik, yapiskanHucre } from "@/components/yonetim/ui/responsive";
import { createClient } from "@/utils/supabase/server";

export async function generateMetadata() {
  const t = await getTranslations("yonetim.sayfalar.ligler");
  return { title: t("title") };
}

export default async function LiglerPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yonetim.sayfalar.ligler");

  const supabase = await createClient();
  const { data: ligler, error } = await supabase
    .from("leagues")
    .select("kod, ad, sira, yukselme_xp, renk, ikon")
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
              <th className="px-4 py-3">{t("cols.sira")}</th>
              <th className="px-4 py-3">{t("cols.yukselme")}</th>
              <th className="px-4 py-3">{t("cols.renk")}</th>
              <th className="px-4 py-3">{t("cols.ikon")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {ligler && ligler.length > 0 ? (
              ligler.map((lig) => (
                <tr
                  key={lig.kod}
                  className="bg-white hover:bg-gray-50 dark:bg-gray-900 dark:hover:bg-gray-800"
                >
                  <td className={`px-4 py-3 font-medium ${yapiskanHucre}`}>{lig.kod}</td>
                  <td className="px-4 py-3">{lig.ad}</td>
                  <td className="px-4 py-3">{lig.sira}</td>
                  <td className="px-4 py-3">
                    {lig.yukselme_xp != null ? lig.yukselme_xp : "—"}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className="inline-block h-4 w-4 rounded-full border border-gray-300"
                      style={{ backgroundColor: lig.renk ?? undefined }}
                      title={lig.renk ?? ""}
                    />
                    <span className="ms-2 text-xs text-gray-500">{lig.renk}</span>
                  </td>
                  <td className="px-4 py-3">{lig.ikon}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={6} className="px-4 py-6 text-center text-gray-500">
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
