"use client";

import { useTranslations } from "next-intl";

import type { DailyStudy, ReviewTopic } from "./types";

// Doğru oranı bu sayıdan az soruda gösterilmez (BuHaftaOzeti ve SubjectSuccessChart ile aynı eşik).
const MIN_EVIDENCE = 6;
// Düzen kartındaki pencere (son 7 gün).
const PENCERE_GUN = 7;
// Dikkat şeridi: son bu kadar gün çalışma yoksa gösterilir.
const PASIF_GUN_ESIGI = 3;
// Dikkat şeridi: tekrar bekleyen konu sayısı bu değere ulaşınca gösterilir.
const TEKRAR_ESIGI = 10;
// Destek kartındaki birlikte tekrar süresi (dakika).
const DESTEK_DAKIKA = 10;

interface GenelDurumOzetiProps {
  haftalik: DailyStudy[];
  tekrarKonulari: ReviewTopic[];
}

// Sayısal alanı güvenle okur; ondalık metin (ör. "12.5") ve boş değerler için.
function sayi(deger: number | string | null | undefined): number {
  const n = typeof deger === "string" ? parseFloat(deger) : Number(deger ?? 0);
  return Number.isFinite(n) ? n : 0;
}

// Gün aktif sayılır: soru çözülmüş ya da süre kaydı varsa.
function aktifMi(gun: DailyStudy): boolean {
  return sayi(gun.soru_sayisi) > 0 || sayi(gun.sure_dk) > 0;
}

// K5 / §5: yalnızca mevcut haftalik ve tekrar_konulari alanlarından hesaplanır.
// Öğrenme, düzen ve destek ayrı katmanlardır; XP, seviye ve seri burada yer almaz.
export default function GenelDurumOzeti({ haftalik, tekrarKonulari }: GenelDurumOzetiProps) {
  const t = useTranslations("veliPaneli.genelDurum");

  const gunler = [...haftalik].sort((a, b) => (a.gun < b.gun ? -1 : a.gun > b.gun ? 1 : 0));
  const aktifGun = gunler.filter(aktifMi).length;
  const toplamDk = gunler.reduce((toplam, gun) => toplam + sayi(gun.sure_dk), 0);
  const toplamSoru = gunler.reduce((toplam, gun) => toplam + sayi(gun.soru_sayisi), 0);
  const toplamDogru = gunler.reduce((toplam, gun) => toplam + sayi(gun.dogru_sayisi), 0);
  const bosHafta = aktifGun === 0;

  const oranYeterli = toplamSoru >= MIN_EVIDENCE;
  const oran = oranYeterli ? Math.round((toplamDogru / toplamSoru) * 100) : null;

  const tekrarSayi = tekrarKonulari.length;
  // En çok tekrar bekleyen konu: önce bekleyen soru, eşitse yanlış sayısı.
  const enCokTekrar = [...tekrarKonulari].sort(
    (a, b) => sayi(b.bekleyen) - sayi(a.bekleyen) || sayi(b.yanlis) - sayi(a.yanlis),
  )[0];

  // Son günlerde çalışma yoksa (veri hiç yoksa da) dikkat şeridi görünür.
  const sonGunler = gunler.slice(-PASIF_GUN_ESIGI);
  const pasif = sonGunler.every((gun) => !aktifMi(gun));
  const dikkatGoster = pasif || tekrarSayi >= TEKRAR_ESIGI;

  return (
    <section
      aria-labelledby="genel-durum-baslik"
      className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3"
    >
      <h2 id="genel-durum-baslik" className="text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h2>
      <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">{t("kaynak")}</p>

      <p className="mt-4 text-sm font-medium text-gray-800 dark:text-white/90">
        {bosHafta ? (
          t("durumBos")
        ) : (
          <>
            {t("durumGun", { gun: aktifGun, soru: toplamSoru })}{" "}
            {tekrarSayi > 0 ? t("durumTekrar", { tekrar: tekrarSayi }) : t("durumTekrarYok")}
          </>
        )}
      </p>

      {dikkatGoster ? (
        <section
          aria-labelledby="genel-durum-dikkat-baslik"
          className="mt-4 rounded-xl border border-warning-200 bg-warning-50 p-4 text-warning-700 dark:border-warning-500/30 dark:bg-warning-900/20 dark:text-warning-300"
        >
          <h3 id="genel-durum-dikkat-baslik" className="text-sm font-semibold">
            {t("dikkat.baslik")}
          </h3>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-theme-sm">
            {pasif ? <li>{t("dikkat.pasif")}</li> : null}
            {tekrarSayi >= TEKRAR_ESIGI ? <li>{t("dikkat.tekrar", { sayi: tekrarSayi })}</li> : null}
          </ul>
          <p className="mt-2 text-theme-xs">{t("dikkat.not")}</p>
        </section>
      ) : null}

      <ul className="mt-4 grid grid-cols-1 gap-3 md:grid-cols-3 md:gap-4" role="list">
        {/* Öğrenme */}
        <li className="min-w-0 rounded-xl border border-gray-200 p-4 dark:border-gray-800">
          <h3 className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("ogrenme.baslik")}</h3>
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("ogrenme.desc")}</p>
          <p className="mt-3 text-title-sm font-bold wrap-break-word text-gray-800 dark:text-white/90">
            {oran === null ? t("ogrenme.yetersiz") : t("ogrenme.oranDeger", { oran })}
          </p>
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
            {oran === null ? t("ogrenme.yetersizNot", { min: MIN_EVIDENCE }) : t("ogrenme.oranNot")}
          </p>
          <p className="mt-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("ogrenme.uyari")}</p>
        </li>

        {/* Düzen */}
        <li className="min-w-0 rounded-xl border border-gray-200 p-4 dark:border-gray-800">
          <h3 className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("duzen.baslik")}</h3>
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("duzen.desc")}</p>
          <p className="mt-3 text-title-sm font-bold wrap-break-word text-gray-800 dark:text-white/90">
            {t("duzen.deger", { aktif: aktifGun, pencere: PENCERE_GUN })}
          </p>
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
            {toplamDk > 0
              ? t("duzen.sure", { dk: Math.max(1, Math.round(toplamDk)) })
              : t("duzen.sureYok")}
          </p>
          <p className="mt-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("duzen.uyari")}</p>
        </li>

        {/* Destek */}
        <li className="min-w-0 rounded-xl border border-gray-200 p-4 dark:border-gray-800">
          <h3 className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("destek.baslik")}</h3>
          <p className="mt-3 text-sm text-gray-800 dark:text-white/90">
            {enCokTekrar
              ? t("destek.oneri", { konu: enCokTekrar.konu })
              : t("destek.yokOneri")}
          </p>
          <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
            {t("destek.sure", { dk: DESTEK_DAKIKA })}
          </p>
          <p className="mt-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("destek.uyari")}</p>
        </li>
      </ul>
    </section>
  );
}
