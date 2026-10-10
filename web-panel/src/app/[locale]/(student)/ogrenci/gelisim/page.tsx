import { createClient } from "@/utils/supabase/server";
import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { setRequestLocale } from "next-intl/server";
import { Link } from "@/i18n/navigation";

export const metadata: Metadata = { title: "Gelişimim — Hupo" };

interface SinavOzet {
  sinav_id: string;
  sinav_ad: string;
  tarih: string;
  sinif: number;
  puan: number;
  dogru: number;
  yanlis: number;
  bos: number;
  sira: number;
  sinif_katilimci: number;
  yuzdelik: number;
  teslim_turu: "elle" | "sure_doldu" | "otomatik" | null;
}

interface KonuRow {
  ders: string;
  konu: string;
  dogru: number;
  yanlis: number;
  bos: number;
  toplam: number;
  oran: number;
}

// Mini trend çubuk grafiği — SVG tabanlı, çıktı yok
function TrendGrafik({ sinavlar }: { sinavlar: SinavOzet[] }) {
  if (sinavlar.length < 2) return null;
  const w = 280;
  const h = 80;
  const pad = 12;
  const maks = Math.max(...sinavlar.map((s) => s.puan), 1);
  const noktalar = sinavlar.map((s, i) => {
    const x = pad + (i / (sinavlar.length - 1)) * (w - pad * 2);
    const y = h - pad - ((s.puan / maks) * (h - pad * 2));
    return { x, y, puan: s.puan, ad: s.sinav_ad };
  });
  const path =
    "M " +
    noktalar.map((p) => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(" L ");

  return (
    <svg
      viewBox={`0 0 ${w} ${h}`}
      className="w-full overflow-visible"
      aria-hidden="true"
    >
      {/* Izgara çizgisi */}
      {[25, 50, 75].map((v) => {
        const y = h - pad - (v / maks) * (h - pad * 2);
        return (
          <line
            key={v}
            x1={pad}
            x2={w - pad}
            y1={y}
            y2={y}
            stroke="#e5e7eb"
            strokeWidth="1"
          />
        );
      })}
      {/* Eğri */}
      <path d={path} fill="none" stroke="#6366f1" strokeWidth="2.5" strokeLinejoin="round" />
      {/* Noktalar */}
      {noktalar.map((p, i) => (
        <g key={i}>
          <circle cx={p.x} cy={p.y} r={4} fill="#6366f1" />
          <title>{p.ad}: {p.puan}</title>
        </g>
      ))}
    </svg>
  );
}

// Konu ısı haritası
function KonuIsıHaritasi({ konular }: { konular: KonuRow[] }) {
  if (konular.length === 0) {
    return <p className="text-sm text-gray-400">Henüz konu verisi yok.</p>;
  }

  // Dersleri grupla
  const grouped = konular.reduce<Record<string, KonuRow[]>>((acc, row) => {
    if (!acc[row.ders]) acc[row.ders] = [];
    acc[row.ders].push(row);
    return acc;
  }, {});

  function renk(oran: number) {
    if (oran >= 80) return "bg-green-500";
    if (oran >= 60) return "bg-green-400";
    if (oran >= 40) return "bg-yellow-400";
    if (oran >= 20) return "bg-orange-400";
    return "bg-red-400";
  }

  return (
    <div className="space-y-5">
      {Object.entries(grouped).map(([ders, konuList]) => (
        <div key={ders}>
          <h4 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">
            {ders}
          </h4>
          <div className="flex flex-wrap gap-1.5">
            {konuList
              .sort((a, b) => a.oran - b.oran)
              .map((konu) => (
                <div
                  key={konu.konu}
                  className={`group relative flex items-center justify-center rounded-lg px-2.5 py-1.5 text-xs font-medium text-white ${renk(konu.oran)}`}
                  title={`${konu.konu}: ${konu.dogru}/${konu.toplam} doğru (%${konu.oran})`}
                >
                  <span className="max-w-[100px] truncate">{konu.konu}</span>
                  <span className="ml-1 opacity-80">%{konu.oran}</span>
                </div>
              ))}
          </div>
        </div>
      ))}
    </div>
  );
}

export default async function GelisimPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/signin");

  const { data: profil } = await supabase
    .from("profiles")
    .select("role, full_name")
    .eq("id", user.id)
    .maybeSingle();

  if (!profil || profil.role !== "ogrenci") redirect("/ogrenci");

  const [{ data: progressRaw }, { data: trendsRaw }] = await Promise.all([
    supabase.rpc("get_my_exam_progress"),
    supabase.rpc("get_my_topic_trends"),
  ]);

  const sinavlar: SinavOzet[] = Array.isArray(progressRaw) ? progressRaw : [];
  const konular: KonuRow[] = Array.isArray(trendsRaw) ? trendsRaw : [];

  const ad = profil.full_name ? profil.full_name.split(" ")[0] : "Öğrenci";

  // Genel istatistikler
  const toplamSinav = sinavlar.length;
  const sonPuan = sinavlar.length > 0 ? sinavlar[sinavlar.length - 1].puan : null;
  const ilkPuan = sinavlar.length > 1 ? sinavlar[0].puan : null;
  const pуanArtis = ilkPuan !== null && sonPuan !== null ? sonPuan - ilkPuan : null;

  // En iyi + en zayıf konular (≥5 soru olan)
  const yeterlıKonular = konular.filter((k) => k.toplam >= 3);
  const enIyiKonular = [...yeterlıKonular].sort((a, b) => b.oran - a.oran).slice(0, 3);
  const enZayifKonular = [...yeterlıKonular].sort((a, b) => a.oran - b.oran).slice(0, 3);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-900 dark:text-white">
          {ad}&apos;nın Gelişimi
        </h1>
        <Link
          href="/ogrenci"
          className="text-sm text-brand-600 hover:underline dark:text-brand-400"
        >
          ← Ana Sayfa
        </Link>
      </div>

      {toplamSinav === 0 ? (
        <div className="rounded-2xl border border-gray-200 bg-white p-10 text-center dark:border-gray-700 dark:bg-gray-800">
          <p className="text-sm text-gray-500">
            Henüz tamamlanmış deneme sınavın yok. Bir sınava katıl, gelişimini burada takip et!
          </p>
        </div>
      ) : (
        <>
          {/* Özet kartlar */}
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            <div className="rounded-xl border border-gray-200 bg-white p-4 text-center dark:border-gray-700 dark:bg-gray-800">
              <p className="text-2xl font-bold text-gray-800 dark:text-white">{toplamSinav}</p>
              <p className="text-xs text-gray-400">Sınav</p>
            </div>
            {sonPuan !== null && (
              <div className="rounded-xl border border-brand-200 bg-brand-50 p-4 text-center dark:border-brand-700 dark:bg-brand-900/20">
                <p className="text-2xl font-bold text-brand-600 dark:text-brand-400">
                  {Number(sonPuan).toFixed(1)}
                </p>
                <p className="text-xs text-gray-400">Son Puan</p>
              </div>
            )}
            {pуanArtis !== null && (
              <div className={`rounded-xl border p-4 text-center ${pуanArtis >= 0 ? "border-green-200 bg-green-50 dark:border-green-700 dark:bg-green-900/20" : "border-red-200 bg-red-50 dark:border-red-700 dark:bg-red-900/20"}`}>
                <p className={`text-2xl font-bold ${pуanArtis >= 0 ? "text-green-600" : "text-red-500"}`}>
                  {pуanArtis >= 0 ? "+" : ""}{Number(pуanArtis).toFixed(1)}
                </p>
                <p className="text-xs text-gray-400">İlk → Son</p>
              </div>
            )}
            <div className="rounded-xl border border-gray-200 bg-white p-4 text-center dark:border-gray-700 dark:bg-gray-800">
              <p className="text-2xl font-bold text-gray-800 dark:text-white">
                {konular.length}
              </p>
              <p className="text-xs text-gray-400">Konu</p>
            </div>
          </div>

          {/* Puan trendi */}
          {sinavlar.length >= 2 && (
            <div className="rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800">
              <h2 className="mb-4 text-base font-bold text-gray-800 dark:text-white">
                Puan Trendi
              </h2>
              <TrendGrafik sinavlar={sinavlar} />
              <div className="mt-3 space-y-1.5">
                {sinavlar.map((s) => (
                  <div key={s.sinav_id} className="flex items-center justify-between text-sm">
                    <Link
                      href={`/deneme-sonuclari/${s.sinav_id}`}
                      className="truncate text-gray-700 hover:text-brand-600 hover:underline dark:text-gray-300"
                    >
                      {s.sinav_ad}
                    </Link>
                    <div className="ml-4 flex shrink-0 items-center gap-3">
                      {s.teslim_turu && s.teslim_turu !== "elle" && (
                        <span className="rounded bg-gray-100 px-1.5 py-0.5 text-[10px] font-medium text-gray-500 dark:bg-gray-700 dark:text-gray-300">
                          {s.teslim_turu === "otomatik" ? "süre doldu · teslim edilmedi" : "süre doldu"}
                        </span>
                      )}
                      <span className="font-bold text-brand-600 dark:text-brand-400">
                        {Number(s.puan).toFixed(1)}
                      </span>
                      <span className="text-xs text-gray-400">
                        {s.sira}/{s.sinif_katilimci}. sıra
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Güçlü / Zayıf konular */}
          {(enIyiKonular.length > 0 || enZayifKonular.length > 0) && (
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              {enIyiKonular.length > 0 && (
                <div className="rounded-2xl border border-green-200 bg-green-50 p-4 dark:border-green-700 dark:bg-green-900/10">
                  <h3 className="mb-2 text-sm font-bold text-green-800 dark:text-green-400">
                    💪 En Güçlü Konuların
                  </h3>
                  <ul className="space-y-1">
                    {enIyiKonular.map((k) => (
                      <li key={`${k.ders}-${k.konu}`} className="text-sm text-green-700 dark:text-green-300">
                        {k.konu} <span className="font-bold">%{k.oran}</span>
                        <span className="ml-1 text-xs opacity-70">({k.ders})</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
              {enZayifKonular.length > 0 && (
                <div className="rounded-2xl border border-orange-200 bg-orange-50 p-4 dark:border-orange-700 dark:bg-orange-900/10">
                  <h3 className="mb-2 text-sm font-bold text-orange-800 dark:text-orange-400">
                    📚 Çalışman Gereken Konular
                  </h3>
                  <ul className="space-y-1">
                    {enZayifKonular.map((k) => (
                      <li key={`${k.ders}-${k.konu}`} className="text-sm text-orange-700 dark:text-orange-300">
                        {k.konu} <span className="font-bold">%{k.oran}</span>
                        <span className="ml-1 text-xs opacity-70">({k.ders})</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          )}

          {/* Konu ısı haritası */}
          {konular.length > 0 && (
            <div className="rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800">
              <h2 className="mb-4 text-base font-bold text-gray-800 dark:text-white">
                Konu Başarı Haritası
              </h2>
              <div className="mb-3 flex gap-3 text-xs text-gray-500">
                <span className="flex items-center gap-1">
                  <span className="inline-block h-3 w-3 rounded bg-green-500" /> ≥80%
                </span>
                <span className="flex items-center gap-1">
                  <span className="inline-block h-3 w-3 rounded bg-yellow-400" /> 40–79%
                </span>
                <span className="flex items-center gap-1">
                  <span className="inline-block h-3 w-3 rounded bg-red-400" /> &lt;40%
                </span>
              </div>
              <KonuIsıHaritasi konular={konular} />
            </div>
          )}
        </>
      )}
    </div>
  );
}
