"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, primaryBtn, tdClass, thClass } from "./styles";

type KaliteSatir = { kod: "eposta_eksik" | "aktif_tarihsiz"; sayi: number | null };
type IzinSatir = { kanal: "eposta" | "push" | "sms" | "uygulama_ici"; acik: number | null; kapali: number | null; kayit_yok: number | null };
type KaliteYanit = { veli_toplam: number | null; kalite: KaliteSatir[]; izin: IzinSatir[] };

// admin_growth_veri_kalitesi: her sayı 5'in altındaysa null (gizli). Kişi listesi yoktur.
export default function VeriKalitesiManager() {
  const t = useTranslations("yonetim.veriKalitesi");
  const [veri, setVeri] = useState<KaliteYanit | null>(null);
  const [loading, setLoading] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_growth_veri_kalitesi");
      if (cancelled) return;
      if (error) {
        setHata(error.message);
        setVeri(null);
      } else {
        setHata(null);
        setVeri(data as KaliteYanit);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const gizli = (n: number | null) => (n === null ? t("hidden") : n);

  if (loading) {
    return <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>;
  }
  if (hata || !veri) {
    return (
      <div className="py-10 text-center">
        <p className="mb-3 text-sm text-error-600 dark:text-error-500">{t("loadError")}</p>
        {hata && <p className="mb-3 text-xs text-gray-500 dark:text-gray-400">{hata}</p>}
        <button type="button" className={primaryBtn} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
          {t("retry")}
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("quality.title")}</h2>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
          {t("quality.veliToplam")}: <span className="font-semibold text-gray-800 dark:text-white/90">{gizli(veri.veli_toplam)}</span>
        </p>
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
          {veri.kalite.map((k) => (
            <div key={k.kod} className="rounded-xl border border-gray-100 p-4 dark:border-gray-800">
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t(`quality.${k.kod}`)}</p>
              <p className="mt-1 text-2xl font-semibold text-gray-800 dark:text-white/90">{gizli(k.sayi)}</p>
              <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t(`quality.${k.kod}Desc`)}</p>
            </div>
          ))}
        </div>
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="mb-1 text-base font-semibold text-gray-800 dark:text-white/90">{t("consent.title")}</h2>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("consent.note")}</p>
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <caption className="sr-only">{t("consent.title")}</caption>
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th scope="col" className={thClass}>{t("consent.cols.channel")}</th>
                <th scope="col" className={thClass}>{t("consent.cols.on")}</th>
                <th scope="col" className={thClass}>{t("consent.cols.off")}</th>
                <th scope="col" className={thClass}>{t("consent.cols.none")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {veri.izin.map((i) => (
                <tr key={i.kanal}>
                  <td className={tdClass}>{t(`channels.${i.kanal}`)}</td>
                  <td className={tdClass}>{gizli(i.acik)}</td>
                  <td className={tdClass}>{gizli(i.kapali)}</td>
                  <td className={tdClass}>{gizli(i.kayit_yok)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
