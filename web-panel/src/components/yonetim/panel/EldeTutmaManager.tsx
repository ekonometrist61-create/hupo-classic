"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";

const WINDOWS = [30, 90, 365] as const;

type OzetSatir = {
  gun: 1 | 7 | 30;
  uygun_hane: number | null;
  tutulan: number | null;
  oran: number | string | null;
};
type HaftaSatir = {
  hafta: string;
  boyut: number | null;
  d1_oran: number | string | null;
  d7_oran: number | string | null;
  d30_oran: number | string | null;
};
type KohortYanit = { gun: number; bugun: string; ozet: OzetSatir[]; haftalik: HaftaSatir[] };

// admin_growth_kohort: null = 5'in altında (gizli) ya da henüz olgunlaşmamış.
function yuzde(v: number | string | null): string {
  if (v === null || v === undefined) return "—";
  return `${Number(v).toLocaleString("tr-TR", { maximumFractionDigits: 1 })}%`;
}

export default function EldeTutmaManager() {
  const t = useTranslations("yonetim.eldeTutma");
  const [gun, setGun] = useState<number>(90);
  const [reloadKey, setReloadKey] = useState(0);
  const [veri, setVeri] = useState<KohortYanit | null>(null);
  const [loading, setLoading] = useState(true);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_growth_kohort", { p_gun: gun });
      if (cancelled) return;
      if (error) {
        setHata(error.message);
        setVeri(null);
      } else {
        setHata(null);
        setVeri(data as KohortYanit);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [gun, reloadKey]);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("title")}</h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("description")}</p>
          </div>
          <div className="w-full sm:w-48">
            <label className={labelClass} htmlFor="e-gun">{t("window.label")}</label>
            <select id="e-gun" className={inputClass} value={gun}
              onChange={(e) => { setLoading(true); setGun(Number(e.target.value)); }}>
              {WINDOWS.map((w) => (
                <option key={w} value={w}>{t("window.days", { count: w })}</option>
              ))}
            </select>
          </div>
        </div>

        {loading ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : hata ? (
          <div className="py-6 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{t("loadError")}</p>
            <p className="mb-3 text-xs text-gray-500 dark:text-gray-400">{hata}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
              {t("retry")}
            </button>
          </div>
        ) : veri ? (
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
            {veri.ozet.map((o) => (
              <div key={o.gun} className="rounded-xl border border-gray-100 p-4 dark:border-gray-800">
                <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t(`cards.d${o.gun}`)}</p>
                <p className="mt-1 text-2xl font-semibold text-gray-800 dark:text-white/90">{yuzde(o.oran)}</p>
                <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                  {t("eligible")}: {o.uygun_hane ?? t("hidden")} · {t("retained")}: {o.tutulan ?? t("hidden")}
                </p>
              </div>
            ))}
          </div>
        ) : null}

        <p className="mt-4 text-theme-xs text-gray-500 dark:text-gray-400">{t("note")}</p>
      </section>

      {veri && !loading && !hata && (
        <section className={`${cardClass} p-5 sm:p-6`}>
          <h2 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">{t("weekly.title")}</h2>
          {veri.haftalik.length === 0 ? (
            <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("weekly.empty")}</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <caption className="sr-only">{t("weekly.title")}</caption>
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th scope="col" className={thClass}>{t("weekly.cols.week")}</th>
                    <th scope="col" className={thClass}>{t("weekly.cols.size")}</th>
                    <th scope="col" className={thClass}>{t("cards.d1")}</th>
                    <th scope="col" className={thClass}>{t("cards.d7")}</th>
                    <th scope="col" className={thClass}>{t("cards.d30")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {veri.haftalik.map((h) => (
                    <tr key={h.hafta}>
                      <td className={`${tdClass} whitespace-nowrap`}>{h.hafta}</td>
                      <td className={tdClass}>{h.boyut ?? t("hidden")}</td>
                      <td className={tdClass}>{yuzde(h.d1_oran)}</td>
                      <td className={tdClass}>{yuzde(h.d7_oran)}</td>
                      <td className={tdClass}>{yuzde(h.d30_oran)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      )}
    </div>
  );
}
