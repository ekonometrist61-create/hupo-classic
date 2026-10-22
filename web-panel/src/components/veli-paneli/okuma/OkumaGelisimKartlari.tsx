"use client";

// Çocuğun okuma gelişimi kartları: okunan hikâyeler, tür dağılımı, kavramlar, atasözü/deyimler, sözcükler,
// soru türüne göre doğruluk. Veli özeti ve öğretmenin bireysel özeti aynı sözleşmeyi (OkumaOzet) kullanır.
import { useLocale, useTranslations } from "next-intl";

import { turEtiketi } from "@/lib/okuma/turler";
import { HEDEF_DURUMLARI, OLCME_TURLERI, type HedefSatiri, type OkumaOzet } from "./okumaTipleri";

function Kart({ baslik, aciklama, children }: { baslik: string; aciklama?: string; children: React.ReactNode }) {
  return (
    <div>
      <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{baslik}</h4>
      {aciklama && <p className="mt-0.5 text-theme-xs text-gray-600 dark:text-gray-400">{aciklama}</p>}
      <div className="mt-2">{children}</div>
    </div>
  );
}

function HedefListesi({ satirlar, bos }: { satirlar: HedefSatiri[] | undefined; bos: string }) {
  const t = useTranslations("veliPaneli.okuma");
  const liste = satirlar ?? [];
  if (liste.length === 0) return <p className="text-sm text-gray-600 dark:text-gray-300">{bos}</p>;
  return (
    <ul className="divide-y divide-gray-100 text-sm dark:divide-gray-800">
      {liste.map((h) => (
        <li key={h.hedef_id} className="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-0.5 py-2">
          <span className="min-w-0 wrap-break-word font-medium text-gray-800 dark:text-gray-100">{h.etiket}</span>
          <span className="text-theme-xs text-gray-600 dark:text-gray-400">
            {(HEDEF_DURUMLARI as readonly string[]).includes(h.durum) ? t(`hedefDurum.${h.durum}`) : h.durum}
            {h.hikaye ? ` · ${t("yeni.hikayeden", { baslik: h.hikaye })}` : ""}
          </span>
        </li>
      ))}
    </ul>
  );
}

export default function OkumaGelisimKartlari({ ozet }: { ozet: OkumaOzet }) {
  const t = useTranslations("veliPaneli.okuma");
  const locale = useLocale();
  const tarih = new Intl.DateTimeFormat(locale === "en" ? "en-US" : "tr-TR", { day: "numeric", month: "short" });
  const turler = ozet.tur_dagilimi ?? [];
  const enTur = Math.max(1, ...turler.map((x) => x.hikaye));
  const son = ozet.son_hikayeler ?? [];

  return (
    <div className="space-y-6">
      <Kart baslik={t("yeni.hikayelerBaslik")} aciklama={t("yeni.hikayelerAciklama")}>
        {son.length === 0 ? (
          <p className="text-sm text-gray-600 dark:text-gray-300">{t("yeni.hikayelerBos")}</p>
        ) : (
          <ul className="divide-y divide-gray-100 text-sm dark:divide-gray-800">
            {son.map((h, i) => (
              <li key={`${h.hikaye_id}-${h.tarih}-${i}`} className="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-0.5 py-2">
                <span className="min-w-0 wrap-break-word font-medium text-gray-800 dark:text-gray-100">
                  {h.baslik}
                  <span className="ms-2 text-theme-xs font-normal text-gray-600 dark:text-gray-400">{turEtiketi(h.tur)}</span>
                </span>
                <span className="text-theme-xs text-gray-600 dark:text-gray-400">
                  {tarih.format(new Date(h.tarih))} ·{" "}
                  {h.tamamlandi ? t("yeni.dogruSoru", { dogru: h.dogru, soru: h.soru }) : t("yeni.yarimKaldi")}
                </span>
              </li>
            ))}
          </ul>
        )}
      </Kart>

      <div className="grid gap-6 md:grid-cols-2">
        <Kart baslik={t("yeni.turBaslik")}>
          {turler.length === 0 ? (
            <p className="text-sm text-gray-600 dark:text-gray-300">{t("yeni.turBos")}</p>
          ) : (
            <ul className="space-y-2">
              {turler.map((x) => (
                <li key={x.tur}>
                  <div className="flex items-baseline justify-between gap-3 text-sm">
                    <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">{turEtiketi(x.tur)}</span>
                    <span className="shrink-0 text-gray-700 dark:text-gray-300">{t("hikayeAdedi", { sayi: x.hikaye })}</span>
                  </div>
                  <div className="mt-1 h-1.5 rounded-full bg-gray-100 dark:bg-white/10" aria-hidden="true">
                    <div className="h-1.5 rounded-full bg-brand-500" style={{ width: `${(x.hikaye / enTur) * 100}%` }} />
                  </div>
                </li>
              ))}
            </ul>
          )}
        </Kart>

        <Kart baslik={t("yeni.olcmeBaslik")} aciklama={t("yeni.olcmeAciklama")}>
          <ul className="space-y-2 text-sm">
            {OLCME_TURLERI.map((o) => {
              const d = ozet.olcme_turu_dogrulugu?.[o];
              const yeterli = !!d?.yeterli && d.oran !== undefined;
              return (
                <li key={o} className="flex flex-wrap items-baseline justify-between gap-x-3">
                  <span className="text-gray-800 dark:text-gray-100">{t(`yeni.olcme.${o}`)}</span>
                  <span className="text-gray-700 dark:text-gray-300">
                    {yeterli ? t("dogruluk.deger", { oran: d.oran ?? 0, dogru: d.dogru ?? 0, soru: d.soru ?? 0 }) : t("dogruluk.yetersiz")}
                  </span>
                </li>
              );
            })}
          </ul>
        </Kart>
      </div>

      <Kart baslik={t("yeni.kavramBaslik")} aciklama={t("yeni.kavramAciklama")}>
        <HedefListesi satirlar={ozet.kavramlar} bos={t("yeni.kavramBos")} />
      </Kart>
      <Kart baslik={t("yeni.atasozuBaslik")}>
        <HedefListesi satirlar={ozet.atasozleri} bos={t("yeni.atasozuBos")} />
      </Kart>
      <Kart baslik={t("yeni.kelimeBaslik")}>
        <HedefListesi satirlar={ozet.kelimeler} bos={t("yeni.kelimeBos")} />
      </Kart>
    </div>
  );
}
