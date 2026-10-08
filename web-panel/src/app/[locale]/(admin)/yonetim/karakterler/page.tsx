import { createClient } from "@/utils/supabase/server";
import Image from "next/image";

export const metadata = { title: "Karakter Katalogu" };

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

const KOSUL_LABEL: Record<string, string> = {
  baslangic: "Başlangıç",
  soru_sayisi: "Soru sayısı",
  seri: "Günlük seri",
  ders_basarisi: "Ders başarısı",
  lig: "Lig sırası",
};

export default async function KarakterlerPage() {
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("admin_list_characters");

  if (error) {
    return (
      <div className="p-8 rounded-lg bg-red-50 text-red-700 dark:bg-red-900/20 dark:text-red-400">
        Karakter verileri yüklenemedi: {error.message}
      </div>
    );
  }

  const rows = (data as CharRow[]) ?? [];

  return (
    <div className="p-8">
      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Karakter Katalogu</h1>
        <span className="text-sm text-gray-500">{rows.length} karakter</span>
      </div>

      <div className="overflow-x-auto rounded-2xl border border-gray-200 dark:border-gray-700">
        <table className="w-full text-sm text-left">
          <thead className="bg-gray-50 dark:bg-gray-800 text-gray-600 dark:text-gray-300 uppercase text-xs">
            <tr>
              <th className="px-4 py-3">Karakter</th>
              <th className="px-4 py-3">Kod</th>
              <th className="px-4 py-3">Sınıf</th>
              <th className="px-4 py-3">Sıra</th>
              <th className="px-4 py-3">Koşul</th>
              <th className="px-4 py-3">Kazanan</th>
              <th className="px-4 py-3">Durum</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {rows.length > 0 ? (
              rows.map((row) => (
                <tr
                  key={row.kod}
                  className="bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <td className="px-4 py-3">
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
                      {KOSUL_LABEL[row.kosul_turu] ?? row.kosul_turu}
                      {row.kosul_deger != null && (
                        <span className="ml-1 text-xs text-gray-400">({row.kosul_deger})</span>
                      )}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{row.kazanan_sayisi}</td>
                  <td className="px-4 py-3">
                    {row.kosul_turu === "baslangic" ? (
                      <span className="inline-flex rounded-full bg-green-100 px-2 py-0.5 text-xs font-semibold text-green-700 dark:bg-green-900/30 dark:text-green-400">
                        Aktif
                      </span>
                    ) : (
                      <span className="inline-flex rounded-full bg-gray-100 px-2 py-0.5 text-xs font-semibold text-gray-500 dark:bg-gray-800 dark:text-gray-400">
                        Kilitli
                      </span>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={7} className="px-4 py-8 text-center text-gray-500">
                  Henüz karakter tanımı yok.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
