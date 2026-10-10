import { Link } from "@/i18n/navigation";

interface DenemeRow {
  id: string;
  ad: string;
  baslangic_zamani: string;
  sure_dakika: number;
  kayitli: boolean;
}

interface Props {
  denemeleri: DenemeRow[];
}

export default function YaklasanDenemeKarti({ denemeleri }: Props) {
  const kayitlilar = denemeleri.filter((d) => d.kayitli);
  if (kayitlilar.length === 0) return null;

  return (
    <div className="rounded-2xl border border-brand-200 bg-brand-50 p-5 dark:border-brand-900/30 dark:bg-brand-900/10">
      <h2 className="mb-3 text-base font-bold text-brand-700 dark:text-brand-400">
        📝 Yaklaşan Deneme Sınavların
      </h2>
      <div className="space-y-2">
        {kayitlilar.map((sinav) => {
          const baslangic = new Date(sinav.baslangic_zamani);
          const baslamadi = baslangic > new Date();
          return (
            <div
              key={sinav.id}
              className="flex flex-col gap-2 rounded-xl border border-brand-100 bg-white px-4 py-3 dark:border-brand-900/20 dark:bg-gray-800 sm:flex-row sm:items-center sm:justify-between"
            >
              <div>
                <p className="font-semibold text-gray-900 dark:text-white">{sinav.ad}</p>
                <p className="mt-0.5 text-xs text-gray-500">
                  {baslangic.toLocaleString("tr-TR", {
                    dateStyle: "medium",
                    timeStyle: "short",
                  })}{" "}
                  · {sinav.sure_dakika} dakika
                </p>
              </div>

              {baslamadi ? (
                <span className="inline-flex items-center rounded-full bg-gray-100 px-3 py-1 text-xs text-gray-500 dark:bg-gray-700 dark:text-gray-400">
                  Henüz başlamadı
                </span>
              ) : (
                <Link
                  href={`/ogrenci/deneme/${sinav.id}`}
                  className="shrink-0 rounded-lg bg-brand-500 px-4 py-2 text-sm font-bold text-white hover:bg-brand-600"
                >
                  Sınava Gir →
                </Link>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
