"use client";

// Okuma ve Dil: çocuğun son 30 günlük beceri profili, kavram/atasözü/sözcük basamakları, okuma hacmi
// ve kural tabanlı tek bir konuşma sorusu. Aynı RPC argümanı (gun=30) OkumaOzeti ile önbellekten paylaşılır.
// Tanı koymaz, kıyaslamaz, yüzde göstermez: çubuk + nitel durum kullanır.
import { useLocale, useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { BECERILER } from "@/lib/okuma/okuma";
import type { HedefSatiri, OkumaOzet, OkumaOzetYaniti, SoruDogrulugu } from "./okumaTipleri";

const DONEM_GUN = 30;
// Öneri eşikleri (öneri, pilot veriyle kalibre edilecek; kesin yeterlilik sonucu değildir).
const ESIK_GUCLU = 80;
const ESIK_PEKISIYOR = 60;

// Etiketler hedefDurum.* mesajlarından okunur (OkumaOzeti ile aynı metinler).
const BASAMAKLAR = ["introduced", "recognized", "retrieved", "transferred"] as const;

type Seviye = "guclu" | "pekisiyor" | "gelisiyor";

function seviyeBul(oran: number): Seviye {
  if (oran >= ESIK_GUCLU) return "guclu";
  if (oran >= ESIK_PEKISIYOR) return "pekisiyor";
  return "gelisiyor";
}

export default function OkumaDilOzeti({ cocukId }: { cocukId: string }) {
  const t = useTranslations("veliPaneli.okuma");
  const veri = useAdminRpc<OkumaOzetYaniti>("okuma_veli_ozeti", { p_cocuk_id: cocukId, p_gun: DONEM_GUN });

  return (
    <section aria-labelledby="okuma-dil-b" className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <div className="mb-5">
        <h3 id="okuma-dil-b" className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("dil.baslik")}</h3>
        <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("dil.aciklama")}</p>
      </div>

      {veri.loading && <p role="status" className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("dil.yukleniyor")}</p>}

      {!veri.loading && veri.missing && <p role="status" className="py-4 text-sm text-gray-600 dark:text-gray-300">{t("dil.kapali")}</p>}

      {!veri.loading && !veri.missing && veri.error && (
        <div className="py-2">
          <p role="alert" className="text-sm text-error-600 dark:text-error-500">{t("dil.hata")}</p>
          <button
            type="button"
            onClick={veri.reload}
            className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400"
          >
            {t("dil.tekrar")}
          </button>
        </div>
      )}

      {!veri.loading && !veri.missing && !veri.error && veri.data && !veri.data.riza && (
        <p role="status" className="rounded-xl border border-warning-200 bg-warning-50 p-4 text-sm text-warning-800 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-warning-300">
          {t("dil.kilitli")}
        </p>
      )}

      {!veri.loading && !veri.error && veri.data?.riza && veri.data.ozet && <Govde ozet={veri.data.ozet} />}
    </section>
  );
}

function Govde({ ozet }: { ozet: OkumaOzet }) {
  const t = useTranslations("veliPaneli.okuma");
  const enCokTema = ozet.tema_dagilimi?.find((k) => k.ad)?.ad ?? null;

  return (
    <div className="space-y-6">
      {ozet.okunan_hikaye === 0 && <p className="text-sm text-gray-600 dark:text-gray-300">{t("dil.bosDonem")}</p>}

      <Alt baslik={t("dil.profilBaslik")} aciklama={t("dil.profilAciklama")}>
        <ul className="space-y-3">
          {BECERILER.map((b) => (
            <BeceriSatiri key={b} ad={t(`beceri.${b}`)} d={ozet.soru_dogrulugu?.[b]} />
          ))}
        </ul>
        <p className="mt-3 text-theme-xs text-gray-600 dark:text-gray-400">{t("dil.seviyeNot")}</p>
      </Alt>

      <Alt baslik={t("dil.basamakBaslik")} aciklama={t("dil.basamakAciklama")}>
        <div className="grid gap-3 md:grid-cols-3">
          <BasamakKarti baslik={t("dil.kavram")} satirlar={ozet.kavramlar} />
          <BasamakKarti baslik={t("dil.atasozu")} satirlar={ozet.atasozleri} />
          <BasamakKarti baslik={t("dil.sozcuk")} satirlar={ozet.kelimeler} />
        </div>
      </Alt>

      <HacimKarti ozet={ozet} />

      {ozet.okunan_hikaye > 0 && (
        <Alt baslik={t("dil.konusmaBaslik")}>
          <div className="rounded-xl bg-gray-50 p-4 dark:bg-white/5">
            <p className="text-sm text-gray-800 dark:text-gray-100">
              {enCokTema ? t("dil.konusmaTema", { tema: enCokTema }) : t("dil.konusmaGenel")}
            </p>
            <p className="mt-2 text-sm font-medium text-gray-800 dark:text-white/90">{t("dil.konusmaSoru")}</p>
            <p className="mt-2 text-theme-xs text-gray-600 dark:text-gray-400">{t("dil.konusmaNot")}</p>
          </div>
        </Alt>
      )}
    </div>
  );
}

function BeceriSatiri({ ad, d }: { ad: string; d: SoruDogrulugu | undefined }) {
  const t = useTranslations("veliPaneli.okuma");
  const oran = d?.yeterli && typeof d.oran === "number" ? Math.min(100, Math.max(0, d.oran)) : null;
  const seviye = oran === null ? null : seviyeBul(oran);

  return (
    <li>
      <div className="flex flex-wrap items-baseline justify-between gap-x-3 text-sm">
        <span className="min-w-0 wrap-break-word font-medium text-gray-800 dark:text-gray-100">{ad}</span>
        <span className="text-gray-700 dark:text-gray-300">
          {seviye ? t(`dil.seviye.${seviye}`) : t("dil.yeterliDegil")}
        </span>
      </div>
      {oran !== null && (
        <div className="mt-1 h-2 rounded-full bg-gray-100 dark:bg-white/10" aria-hidden="true">
          <div className="h-2 rounded-full bg-brand-500" style={{ width: `${oran}%` }} />
        </div>
      )}
    </li>
  );
}

function BasamakKarti({ baslik, satirlar }: { baslik: string; satirlar: HedefSatiri[] | undefined }) {
  const t = useTranslations("veliPaneli.okuma");
  const liste = satirlar ?? [];
  const bekleyen = liste.filter((s) => s.durum === "refresh_due").length;

  return (
    <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
      <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{baslik}</h4>
      {liste.length === 0 ? (
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-300">{t("dil.bosBasamak")}</p>
      ) : (
        <>
          <dl className="mt-2 space-y-1.5 text-sm">
            {BASAMAKLAR.map((durum) => (
              <div key={durum} className="flex items-baseline justify-between gap-2">
                <dt className="text-gray-700 dark:text-gray-300">{t(`hedefDurum.${durum}`)}</dt>
                <dd className="font-semibold text-gray-800 dark:text-white/90">
                  {liste.filter((s) => s.durum === durum).length}
                </dd>
              </div>
            ))}
          </dl>
          {bekleyen > 0 && <p className="mt-2 text-theme-xs text-gray-600 dark:text-gray-400">{t("dil.bekleyen", { sayi: bekleyen })}</p>}
        </>
      )}
    </div>
  );
}

function HacimKarti({ ozet }: { ozet: OkumaOzet }) {
  const t = useTranslations("veliPaneli.okuma");
  const locale = useLocale();

  return (
    <Alt baslik={t("dil.hacimBaslik")} aciklama={t("dil.hacimAciklama")}>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
        <Olcu etiket={t("ozet.okunan")} deger={String(ozet.okunan_hikaye)} />
        <Olcu etiket={t("ozet.tamamlanan")} deger={String(ozet.tamamlanan_hikaye)} />
        {ozet.okunan_kelime !== undefined && (
          <Olcu etiket={t("yeni.kelimeSayisi")} deger={ozet.okunan_kelime.toLocaleString(locale === "en" ? "en-US" : "tr-TR")} />
        )}
      </div>
    </Alt>
  );
}

function Olcu({ etiket, deger }: { etiket: string; deger: string }) {
  return (
    <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
      <p className="text-xs text-gray-600 dark:text-gray-400">{etiket}</p>
      <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{deger}</p>
    </div>
  );
}

function Alt({ baslik, aciklama, children }: { baslik: string; aciklama?: string; children: React.ReactNode }) {
  return (
    <div>
      <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{baslik}</h4>
      {aciklama && <p className="mt-0.5 mb-2 text-theme-xs text-gray-600 dark:text-gray-400">{aciklama}</p>}
      <div className={aciklama ? "" : "mt-2"}>{children}</div>
    </div>
  );
}
