import { createClient } from "@/utils/supabase/server";

export const metadata = { title: "Rozetler" };

export default async function RozetlerPage() {
  const supabase = await createClient();
  const { data: rozetler, error } = await supabase
    .from("badge_definitions")
    .select("kod, ad, aciklama, ikon, kosul_turu, esik, ders, sira")
    .order("sira", { ascending: true });

  if (error) {
    return (
      <div className="p-8 text-red-600">
        Rozet verileri yüklenirken hata oluştu: {error.message}
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Rozetler</h1>
      <div className="overflow-x-auto rounded-lg border border-gray-200 dark:border-gray-700">
        <table className="w-full text-sm text-left">
          <thead className="bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-4 py-3">Kod</th>
              <th className="px-4 py-3">Ad</th>
              <th className="px-4 py-3">Açıklama</th>
              <th className="px-4 py-3">İkon</th>
              <th className="px-4 py-3">Koşul Türü</th>
              <th className="px-4 py-3">Eşik</th>
              <th className="px-4 py-3">Ders</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {rozetler && rozetler.length > 0 ? (
              rozetler.map((rozet) => (
                <tr
                  key={rozet.kod}
                  className="bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-4 py-3 font-medium">{rozet.kod}</td>
                  <td className="px-4 py-3">{rozet.ad}</td>
                  <td className="px-4 py-3 max-w-xs text-gray-600 dark:text-gray-400">
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
