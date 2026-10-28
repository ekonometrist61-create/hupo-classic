"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";

const WINDOWS = [30, 90, 365] as const;

type SinifSatir = { sinif: number; ogrenci: number; oturum: number; tamamlama_orani: number | string };
type HikayeSatir = { slug: string; ogrenci: number; oturum: number; tamamlama_orani: number | string };
type ToplamYanit = { gun: number; esik: number; siniflar: SinifSatir[]; hikayeler: HikayeSatir[] };

// admin_ogrenme_toplu: yalnız toplu sayılar. Doğruluk, beceri ve kişi bilgisi yoktur.
export default function OgrenmeToplamManager() {
  const t = useTranslations("yonetim.ogrenmeToplam");
  const [gun, setGun] = useState<number>(30);
  const [veri, setVeri] = useState<ToplamYanit | null>(null);
  const [loading, setLoading] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_ogrenme_toplu", { p_gun: gun });
      if (cancelled) return;
      if (error) {
        setHata(error.message);
        setVeri(null);
      } else {
        setHata(null);
        setVeri(data as ToplamYanit);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [gun, reloadKey]);

  const oran = (v: number | string) => `${Number(v).toLocaleString("tr-TR", { maximumFractionDigits: 1 })}%`;

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("title")}</h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("description")}</p>
          </div>
          <div className="w-full sm:w-48">
            <label className={labelClass} htmlFor="o-gun">{t("window.label")}</label>
            <select id="o-gun" className={inputClass} value={gun}
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
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
              {t("retry")}
            </button>
          </div>
        ) : veri ? (
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("threshold", { count: veri.esik })}</p>
        ) : null}
      </section>

      {veri && !loading && !hata && (
        <>
          <section className={`${cardClass} p-5 sm:p-6`}>
            <h3 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">{t("classes.title")}</h3>
            {veri.siniflar.length === 0 ? (
              <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("classes.empty")}</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <caption className="sr-only">{t("classes.title")}</caption>
                  <thead className="border-b border-gray-100 dark:border-gray-800">
                    <tr>
                      <th scope="col" className={thClass}>{t("classes.cols.grade")}</th>
                      <th scope="col" className={thClass}>{t("cols.students")}</th>
                      <th scope="col" className={thClass}>{t("cols.sessions")}</th>
                      <th scope="col" className={thClass}>{t("cols.completion")}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {veri.siniflar.map((s) => (
                      <tr key={s.sinif}>
                        <td className={tdClass}>{s.sinif}</td>
                        <td className={tdClass}>{s.ogrenci}</td>
                        <td className={tdClass}>{s.oturum}</td>
                        <td className={tdClass}>{oran(s.tamamlama_orani)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>

          <section className={`${cardClass} p-5 sm:p-6`}>
            <h3 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">{t("stories.title")}</h3>
            {veri.hikayeler.length === 0 ? (
              <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("stories.empty")}</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <caption className="sr-only">{t("stories.title")}</caption>
                  <thead className="border-b border-gray-100 dark:border-gray-800">
                    <tr>
                      <th scope="col" className={thClass}>{t("stories.cols.story")}</th>
                      <th scope="col" className={thClass}>{t("cols.students")}</th>
                      <th scope="col" className={thClass}>{t("cols.sessions")}</th>
                      <th scope="col" className={thClass}>{t("cols.completion")}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {veri.hikayeler.map((h) => (
                      <tr key={h.slug}>
                        <td className={`${tdClass} font-mono text-theme-xs`}>{h.slug}</td>
                        <td className={tdClass}>{h.ogrenci}</td>
                        <td className={tdClass}>{h.oturum}</td>
                        <td className={tdClass}>{oran(h.tamamlama_orani)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        </>
      )}
    </div>
  );
}
