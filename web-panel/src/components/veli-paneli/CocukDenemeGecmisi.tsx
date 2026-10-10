"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

type TeslimTuru = "elle" | "sure_doldu" | "otomatik" | null;

interface GecmisSatiri {
  sinav_id: string;
  sinav_ad: string;
  tarih: string;
  puan: number;
  dogru: number;
  yanlis: number;
  sira: number;
  sinif_katilimci: number;
  teslim_turu: TeslimTuru;
}

interface Props {
  cocukId: string;
  cocukAd: string | null;
}

const TESLIM_RENK: Record<string, string> = {
  elle: "bg-green-50 text-green-700 dark:bg-green-900/20 dark:text-green-400",
  sure_doldu: "bg-yellow-50 text-yellow-700 dark:bg-yellow-900/20 dark:text-yellow-400",
  otomatik: "bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300",
};

export default function CocukDenemeGecmisi({ cocukId, cocukAd }: Props) {
  const t = useTranslations("veliPaneli.denemeGecmisi");
  const [satirlar, setSatirlar] = useState<GecmisSatiri[] | null>(null);
  const [hata, setHata] = useState(false);

  useEffect(() => {
    let cancelled = false;
    createClient()
      .rpc("get_child_exam_history", { p_cocuk_id: cocukId })
      .then(({ data, error }) => {
        if (cancelled) return;
        if (error || !Array.isArray(data)) {
          setHata(true);
          return;
        }
        setSatirlar(data as GecmisSatiri[]);
      });
    return () => {
      cancelled = true;
    };
  }, [cocukId]);

  return (
    <div className="mb-6 rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800">
      <h3 className="text-base font-bold text-gray-900 dark:text-white">{t("title")}</h3>
      {cocukAd && <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("desc", { ad: cocukAd })}</p>}

      {hata && <p className="text-sm text-red-600 dark:text-red-400">{t("error")}</p>}
      {!hata && satirlar === null && <p className="text-sm text-gray-400">{t("loading")}</p>}
      {!hata && satirlar !== null && satirlar.length === 0 && (
        <p className="text-sm text-gray-400">{t("empty")}</p>
      )}

      {!hata && satirlar !== null && satirlar.length > 0 && (
        <ul className="divide-y divide-gray-100 dark:divide-gray-700">
          {satirlar.map((s) => {
            const teslim = s.teslim_turu ?? "elle";
            return (
              <li key={s.sinav_id} className="flex flex-wrap items-center justify-between gap-3 py-3">
                <div className="min-w-0">
                  <p className="truncate font-semibold text-gray-900 dark:text-white">{s.sinav_ad}</p>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {new Date(s.tarih).toLocaleDateString(undefined, { day: "numeric", month: "long", year: "numeric" })}
                    {" · "}
                    {t("dogru", { dogru: s.dogru })}
                    {" · "}
                    {t("yanlis", { yanlis: s.yanlis })}
                  </p>
                  <span
                    className={`mt-1 inline-block rounded-md px-2 py-0.5 text-xs font-medium ${TESLIM_RENK[teslim] ?? TESLIM_RENK.elle}`}
                  >
                    {t(`teslim_${teslim}`)}
                  </span>
                </div>
                <div className="text-right">
                  <p className="text-xl font-extrabold text-brand-600 dark:text-brand-400">
                    {Number(s.puan).toFixed(1)}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {t("puan")} · {t("sira", { sira: s.sira, katilimci: s.sinif_katilimci })}
                  </p>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
