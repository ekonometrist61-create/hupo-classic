import { createClient } from "@/utils/supabase/server";

export const metadata = { title: "Görevler" };

export default async function GorevlerPage() {
  const supabase = await createClient();
  const { data: gorevler, error } = await supabase
    .from("quest_definitions")
    .select("kod, baslik, aciklama, hedef_tipi, hedef_deger, odul_xp, aktif, sira")
    .order("sira", { ascending: true });

  if (error) {
    return (
      <div className="p-8 text-red-600">
        Görev verileri yüklenirken hata oluştu: {error.message}
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Görevler</h1>
      <div className="overflow-x-auto rounded-lg border border-gray-200 dark:border-gray-700">
        <table className="w-full text-sm text-left">
          <thead className="bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-4 py-3">Kod</th>
              <th className="px-4 py-3">Başlık</th>
              <th className="px-4 py-3">Açıklama</th>
              <th className="px-4 py-3">Hedef Tipi</th>
              <th className="px-4 py-3">Hedef Miktar</th>
              <th className="px-4 py-3">XP Ödülü</th>
              <th className="px-4 py-3">Aktif</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {gorevler && gorevler.length > 0 ? (
              gorevler.map((gorev) => (
                <tr
                  key={gorev.kod}
                  className="bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-4 py-3 font-medium">{gorev.kod}</td>
                  <td className="px-4 py-3">{gorev.baslik}</td>
                  <td className="px-4 py-3 max-w-xs text-gray-600 dark:text-gray-400">
                    {gorev.aciklama}
                  </td>
                  <td className="px-4 py-3">{gorev.hedef_tipi}</td>
                  <td className="px-4 py-3">{gorev.hedef_deger}</td>
                  <td className="px-4 py-3">{gorev.odul_xp}</td>
                  <td className="px-4 py-3">
                    {gorev.aktif ? (
                      <span className="text-green-600 font-medium">Evet</span>
                    ) : (
                      <span className="text-gray-400">Hayır</span>
                    )}
                  </td>
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
