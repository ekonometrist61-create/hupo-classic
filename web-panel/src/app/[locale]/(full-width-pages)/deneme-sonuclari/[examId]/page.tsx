import { createClient } from "@/utils/supabase/server";
import type { Metadata } from "next";
import { setRequestLocale } from "next-intl/server";
import { Link } from "@/i18n/navigation";
import KonuKirilimi from "@/components/deneme-sonuclari/KonuKirilimi";
import PaylasKarti from "@/components/deneme-sonuclari/PaylasKarti";

export async function generateMetadata(): Promise<Metadata> {
  return { title: "Deneme Sınavı Sonuçları | Hupolingo" };
}

// Puan dağılımı bantları (0-9, 10-19, …, 90-100)
interface PuanBandi { aralik_baslangic: number; aralik_bitis: number; sayi: number }
interface SinifSonuc {
  sinif: number;
  katilimci: number;
  ortalama: number;
  en_yuksek: number;
  en_dusuk: number;
  puan_dagilimi: PuanBandi[];
}
interface KendiSonuc {
  puan: number;
  dogru_sayisi: number;
  yanlis_sayisi: number;
  bos_sayisi: number;
  sinif: number;
  sinif_katilimci: number;
  sira: number;
  yuzdelik: number;
}
interface PublicResults {
  sinav: { id: string; ad: string; baslangic_zamani: string };
  siniflar: SinifSonuc[];
  kendi: KendiSonuc | null;
}

// Histogram: her band için bir çubuk — normalize edilmiş genişlikte
function PuanHistogram({ dagilim }: { dagilim: PuanBandi[] }) {
  if (!dagilim || dagilim.length === 0) return null;
  const maks = Math.max(...dagilim.map((b) => b.sayi), 1);
  return (
    <div className="mt-3 flex items-end gap-0.5" style={{ height: 56 }}>
      {Array.from({ length: 10 }, (_, i) => {
        const band = dagilim.find((b) => b.aralik_baslangic === i * 10);
        const sayi = band?.sayi ?? 0;
        const yukseklik = sayi === 0 ? 2 : Math.max(4, Math.round((sayi / maks) * 56));
        return (
          <div key={i} className="group relative flex flex-1 flex-col items-center justify-end">
            <div
              className="w-full rounded-t bg-brand-400 opacity-80 transition-opacity group-hover:opacity-100 dark:bg-brand-600"
              style={{ height: yukseklik }}
              title={`${i * 10}–${i * 10 + 9}: ${sayi} öğrenci`}
            />
            {i % 2 === 0 && (
              <span className="mt-0.5 text-[9px] text-gray-400">{i * 10}</span>
            )}
          </div>
        );
      })}
    </div>
  );
}

export default async function DenemesonuclariPage({
  params,
}: {
  params: Promise<{ locale: string; examId: string }>;
}) {
  const { locale, examId } = await params;
  setRequestLocale(locale);

  const supabase = await createClient();

  // Herkese açık: anon da çekebilir
  const { data: raw, error } = await supabase.rpc("get_exam_public_results", {
    p_exam_id: examId,
  });

  if (error || !raw) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <p className="text-sm text-gray-400">Sonuçlar yüklenemedi.</p>
      </div>
    );
  }

  const results = raw as PublicResults;
  const { sinav, siniflar, kendi } = results;

  // Premium konu kırılımı — auth + premium ise çek
  const {
    data: { user },
  } = await supabase.auth.getUser();

  let konuVerisi: unknown[] | null = null;
  if (user && kendi) {
    const { data: kd } = await supabase.rpc("get_exam_topic_breakdown", {
      p_exam_id: examId,
    });
    if (Array.isArray(kd)) konuVerisi = kd;
  }

  const baslangic = new Date(sinav.baslangic_zamani).toLocaleDateString("tr-TR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  return (
    <div className="min-h-dvh bg-gray-50 py-10 dark:bg-gray-950">
      <div className="mx-auto max-w-3xl px-4 sm:px-6">
        {/* Başlık */}
        <div className="mb-8 text-center">
          <p className="mb-1 text-xs font-medium uppercase tracking-wider text-brand-600 dark:text-brand-400">
            Deneme Sınavı Sonuçları
          </p>
          <h1 className="text-2xl font-extrabold text-gray-900 dark:text-white sm:text-3xl">
            {sinav.ad}
          </h1>
          <p className="mt-1 text-sm text-gray-500">{baslangic}</p>
        </div>

        {/* Kendi sonucu */}
        {kendi && (
          <div className="mb-6 rounded-2xl border-2 border-brand-300 bg-brand-50 p-5 dark:border-brand-700 dark:bg-brand-900/20">
            <p className="mb-3 text-xs font-semibold uppercase tracking-wider text-brand-700 dark:text-brand-400">
              Senin Sonucun — {kendi.sinif}. Sınıf
            </p>
            <div className="flex flex-wrap items-end gap-4">
              <div>
                <p className="text-4xl font-extrabold text-brand-600 dark:text-brand-400">
                  {Number(kendi.puan).toFixed(1)}
                </p>
                <p className="text-xs text-gray-500">puan</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-gray-800 dark:text-gray-200">
                  {kendi.sira}. / {kendi.sinif_katilimci}
                </p>
                <p className="text-xs text-gray-500">sınıf sırası</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-gray-800 dark:text-gray-200">
                  %{Number(kendi.yuzdelik).toFixed(0)}
                </p>
                <p className="text-xs text-gray-500">yüzdelik dilim</p>
              </div>
            </div>
            <div className="mt-3 flex gap-4 text-sm">
              <span className="text-green-600 dark:text-green-400">
                ✓ {kendi.dogru_sayisi} doğru
              </span>
              <span className="text-red-500 dark:text-red-400">
                ✗ {kendi.yanlis_sayisi} yanlış
              </span>
              <span className="text-gray-400">
                — {kendi.bos_sayisi} boş
              </span>
            </div>
          </div>
        )}

        {kendi && (
          <PaylasKarti
            sinavAd={sinav.ad}
            puan={Number(kendi.puan)}
            sinif={kendi.sinif}
            sira={kendi.sira}
            katilimci={kendi.sinif_katilimci}
            yuzdelik={Number(kendi.yuzdelik)}
          />
        )}

        {/* Giriş yapmamış CTA */}
        {!user && (
          <div className="mb-6 rounded-2xl border border-gray-200 bg-white p-5 text-center dark:border-gray-700 dark:bg-gray-800">
            <p className="text-sm text-gray-600 dark:text-gray-300">
              Kendi sonucunu görmek için giriş yap.
            </p>
            <Link
              href="/signin"
              className="mt-3 inline-block rounded-lg bg-brand-500 px-5 py-2 text-sm font-bold text-white hover:bg-brand-600"
            >
              Giriş Yap
            </Link>
          </div>
        )}

        {/* Sınıf bazlı istatistikler */}
        {siniflar.length === 0 ? (
          <div className="rounded-2xl border border-gray-200 bg-white p-8 text-center dark:border-gray-700 dark:bg-gray-800">
            <p className="text-sm text-gray-400">Henüz sonuç yok.</p>
          </div>
        ) : (
          <div className="space-y-4">
            <h2 className="text-lg font-bold text-gray-800 dark:text-white">
              Sınıf Bazlı Sonuçlar
            </h2>
            {siniflar.map((sinifSonuc) => (
              <div
                key={sinifSonuc.sinif}
                className="rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800"
              >
                <div className="flex items-center justify-between">
                  <h3 className="font-bold text-gray-900 dark:text-white">
                    {sinifSonuc.sinif}. Sınıf
                  </h3>
                  <span className="text-xs text-gray-400">
                    {sinifSonuc.katilimci} katılımcı
                  </span>
                </div>
                <div className="mt-3 grid grid-cols-3 gap-3 text-center text-sm">
                  <div>
                    <p className="text-xl font-bold text-gray-800 dark:text-gray-100">
                      {Number(sinifSonuc.ortalama).toFixed(1)}
                    </p>
                    <p className="text-xs text-gray-400">ortalama</p>
                  </div>
                  <div>
                    <p className="text-xl font-bold text-green-600 dark:text-green-400">
                      {Number(sinifSonuc.en_yuksek).toFixed(1)}
                    </p>
                    <p className="text-xs text-gray-400">en yüksek</p>
                  </div>
                  <div>
                    <p className="text-xl font-bold text-gray-500">
                      {Number(sinifSonuc.en_dusuk).toFixed(1)}
                    </p>
                    <p className="text-xs text-gray-400">en düşük</p>
                  </div>
                </div>

                {/* Puan dağılımı histogramı */}
                {sinifSonuc.puan_dagilimi && sinifSonuc.puan_dagilimi.length > 0 && (
                  <div className="mt-4">
                    <p className="mb-1 text-xs text-gray-400">Puan dağılımı (0–100)</p>
                    <PuanHistogram dagilim={sinifSonuc.puan_dagilimi} />
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Konu kırılımı — premium */}
        {user && kendi && (
          <div className="mt-6">
            <KonuKirilimi
              verisi={konuVerisi}
              isPremium={konuVerisi !== null}
              examId={examId}
            />
          </div>
        )}

        {/* Kayıt CTA — giriş yapmamış */}
        {!user && (
          <div className="mt-8 rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 p-6 text-center text-white">
            <p className="text-lg font-bold">Sonraki sınavda yerini al!</p>
            <p className="mt-1 text-sm opacity-90">
              Ücretsiz kaydol, çocuğunu bir sonraki denemeye kaydet.
            </p>
            <Link
              href="/signup"
              className="mt-4 inline-block rounded-xl bg-white px-6 py-2.5 text-sm font-bold text-brand-600 hover:bg-gray-100"
            >
              Ücretsiz Kaydol
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
