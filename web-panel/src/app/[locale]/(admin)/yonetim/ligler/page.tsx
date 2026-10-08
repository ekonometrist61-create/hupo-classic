import { createClient } from "@/utils/supabase/server";

export const metadata = { title: "Lig Basamakları" };

export default async function LiglerPage() {
  const supabase = await createClient();
  const { data: ligler, error } = await supabase
    .from("leagues")
    .select("kod, ad, sira, yukselme_xp, renk, ikon")
    .order("sira", { ascending: true });

  if (error) {
    return (
      <div className="p-8 text-red-600">
        Lig verileri yüklenirken hata oluştu: {error.message}
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Lig Basamakları</h1>
      <div className="overflow-x-auto rounded-lg border border-gray-200 dark:border-gray-700">
        <table className="w-full text-sm text-left">
          <thead className="bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-4 py-3">Kod</th>
              <th className="px-4 py-3">Ad</th>
              <th className="px-4 py-3">Sıra</th>
              <th className="px-4 py-3">Yükselme XP</th>
              <th className="px-4 py-3">Renk</th>
              <th className="px-4 py-3">İkon</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {ligler && ligler.length > 0 ? (
              ligler.map((lig) => (
                <tr
                  key={lig.kod}
                  className="bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-4 py-3 font-medium">{lig.kod}</td>
                  <td className="px-4 py-3">{lig.ad}</td>
                  <td className="px-4 py-3">{lig.sira}</td>
                  <td className="px-4 py-3">
                    {lig.yukselme_xp != null ? lig.yukselme_xp : "—"}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className="inline-block w-4 h-4 rounded-full border border-gray-300"
                      style={{ backgroundColor: lig.renk ?? undefined }}
                      title={lig.renk ?? ""}
                    />
                    <span className="ml-2 text-xs text-gray-500">{lig.renk}</span>
                  </td>
                  <td className="px-4 py-3">{lig.ikon}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={6} className="px-4 py-6 text-center text-gray-500">
                  Kayıt bulunamadı.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
