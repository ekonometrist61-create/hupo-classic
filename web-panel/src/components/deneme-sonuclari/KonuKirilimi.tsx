import { Link } from "@/i18n/navigation";

interface KonuRow {
  ders: string;
  konu: string;
  dogru: number;
  yanlis: number;
  bos: number;
  toplam: number;
  oran: number;
}

interface Props {
  verisi: unknown[] | null;
  isPremium: boolean;
  examId: string;
}

// Ders bazında grupla
function groupByDers(rows: KonuRow[]): Record<string, KonuRow[]> {
  return rows.reduce<Record<string, KonuRow[]>>((acc, row) => {
    if (!acc[row.ders]) acc[row.ders] = [];
    acc[row.ders].push(row);
    return acc;
  }, {});
}

// Oran rengi
function oranRenk(oran: number): string {
  if (oran >= 70) return "bg-green-500";
  if (oran >= 40) return "bg-yellow-400";
  return "bg-red-400";
}

export default function KonuKirilimi({ verisi, isPremium, examId }: Props) {
  if (!isPremium) {
    return (
      <div className="rounded-2xl border border-dashed border-gray-300 bg-gray-50 p-6 text-center dark:border-gray-700 dark:bg-gray-800/50">
        <p className="text-base font-semibold text-gray-700 dark:text-gray-200">
          🔒 Konu Bazlı Analiz
        </p>
        <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
          Hangi konularda güçlü, hangilerinde gelişim alanın var? Bu analiz premium abonelere açıktır.
        </p>
        <Link
          href="/veli-paneli/uyelik"
          className="mt-4 inline-block rounded-xl bg-brand-500 px-5 py-2 text-sm font-bold text-white hover:bg-brand-600"
        >
          Premium&apos;a Geç
        </Link>
      </div>
    );
  }

  if (!verisi || verisi.length === 0) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-5 text-center dark:border-gray-700 dark:bg-gray-800">
        <p className="text-sm text-gray-400">Konu verisi bulunamadı.</p>
      </div>
    );
  }

  const rows = verisi as KonuRow[];
  const grouped = groupByDers(rows);

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-bold text-gray-800 dark:text-white">
        Konu Bazlı Analiz
      </h2>

      {Object.entries(grouped).map(([ders, konular]) => {
        const dersToplamDogru = konular.reduce((s, k) => s + k.dogru, 0);
        const dersToplam = konular.reduce((s, k) => s + k.toplam, 0);
        const dersOran = dersToplam > 0 ? Math.round((dersToplamDogru / dersToplam) * 100) : 0;

        return (
          <div
            key={ders}
            className="rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800"
          >
            <div className="mb-3 flex items-center justify-between">
              <h3 className="font-bold text-gray-900 dark:text-white">{ders}</h3>
              <span
                className={`rounded-full px-2.5 py-0.5 text-xs font-bold text-white ${oranRenk(dersOran)}`}
              >
                %{dersOran}
              </span>
            </div>

            <div className="space-y-2">
              {konular
                .sort((a, b) => a.oran - b.oran)
                .map((konu) => (
                  <div key={konu.konu} className="flex items-center gap-3">
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-xs text-gray-700 dark:text-gray-300">
                        {konu.konu}
                      </p>
                      <div className="mt-1 h-1.5 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-gray-700">
                        <div
                          className={`h-full rounded-full ${oranRenk(konu.oran)} transition-all`}
                          style={{ width: `${konu.oran}%` }}
                        />
                      </div>
                    </div>
                    <div className="shrink-0 text-right text-xs tabular-nums text-gray-500">
                      {konu.dogru}/{konu.toplam}
                    </div>
                  </div>
                ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}
