"use client";

import { useTranslations } from "next-intl";

import type { DailyStudy, ReviewTopic } from "./types";

// Doğru oranı bu sayıdan az soruda gösterilmez (SubjectSuccessChart ile aynı eşik).
const MIN_EVIDENCE = 6;

interface BuHaftaOzetiProps {
  haftalik: DailyStudy[];
  tekrarKonulari: ReviewTopic[];
}

// Sayısal alanı güvenle okur; ondalık metin (ör. "12.5") ve boş değerler için.
function sayi(deger: number | string | null | undefined): number {
  const n = typeof deger === "string" ? parseFloat(deger) : Number(deger ?? 0);
  return Number.isFinite(n) ? n : 0;
}

// K4: ana ekranın ilk bloğu. Yalnızca mevcut haftalik ve tekrar_konulari alanlarından hesaplanır.
// Süre ve soru sayısı çalışma düzenini gösterir; öğrenme düzeyinin tek ölçüsü değildir.
// XP ve seviye bu blokta yer almaz (Başarılar sayfasında).
export default function BuHaftaOzeti({ haftalik, tekrarKonulari }: BuHaftaOzetiProps) {
  const t = useTranslations("veliPaneli.buHafta");

  const toplamDk = haftalik.reduce((toplam, gun) => toplam + sayi(gun.sure_dk), 0);
  const toplamSoru = haftalik.reduce((toplam, gun) => toplam + sayi(gun.soru_sayisi), 0);
  const toplamDogru = haftalik.reduce((toplam, gun) => toplam + sayi(gun.dogru_sayisi), 0);
  const bosHafta = toplamDk <= 0 && toplamSoru <= 0;
  const oranYeterli = toplamSoru >= MIN_EVIDENCE;
  const oran = oranYeterli ? Math.round((toplamDogru / toplamSoru) * 100) : null;

  const metrikler = [
    {
      etiket: t("sure"),
      // Bir dakikadan kısa çalışmalar en az "1 dk" olarak gösterilir (0 dk yanıltıcı olur).
      deger: toplamDk > 0 ? t("sureDeger", { dk: Math.max(1, Math.round(toplamDk)) }) : "—",
      not: null,
    },
    {
      etiket: t("soru"),
      deger: String(toplamSoru),
      not: null,
    },
    {
      etiket: t("dogru"),
      deger: oran === null ? t("azVeri") : `%${oran}`,
      not: oran === null ? t("azVeriNot", { min: MIN_EVIDENCE }) : null,
    },
    {
      etiket: t("tekrar"),
      deger: String(tekrarKonulari.length),
      not: t("tekrarNot"),
    },
  ];

  return (
    <section
      aria-labelledby="bu-hafta-baslik"
      className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3"
    >
      <h2 id="bu-hafta-baslik" className="text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h2>
      <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">{t("kaynak")}</p>

      {bosHafta ? (
        <div className="mt-4 rounded-xl bg-gray-50 p-4 dark:bg-white/5">
          <p className="text-sm font-medium text-gray-800 dark:text-white/90">{t("bos")}</p>
          <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">{t("bosNot")}</p>
        </div>
      ) : null}

      <dl className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2 md:grid-cols-4 md:gap-4">
        {metrikler.map((m) => (
          <div
            key={m.etiket}
            className="min-w-0 rounded-xl border border-gray-200 p-4 dark:border-gray-800"
          >
            <dt className="text-sm text-gray-500 dark:text-gray-400">{m.etiket}</dt>
            <dd className="mt-1 text-title-sm font-bold wrap-break-word text-gray-800 dark:text-white/90">
              {m.deger}
            </dd>
            {m.not && (
              <dd className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{m.not}</dd>
            )}
          </div>
        ))}
      </dl>
    </section>
  );
}
