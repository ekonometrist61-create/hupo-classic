"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { cardClass, inputClass } from "../panel/styles";
import RpcBoundary from "../ui/RpcBoundary";
import { useAdminRpc } from "../useAdminRpc";
import { DEMO_ANALYTICS } from "./demoData";
import type { AnalyticsSummary } from "./types";

function heat(p: number | null): string {
  if (p === null) return "bg-transparent text-gray-400";
  if (p > 75) return "bg-[#267e68] text-white";
  if (p > 60) return "bg-[#72bda3]";
  if (p > 45) return "bg-[#acd7c6]";
  return "bg-[#ddede6]";
}

export default function AnalyticsView() {
  const t = useTranslations("yonetim.merkez.analytics");
  const [days, setDays] = useState(30);
  const state = useAdminRpc<AnalyticsSummary>(
    "admin_analitik_ozet",
    { p_gun: days },
    { demo: { ...DEMO_ANALYTICS, gun: days } },
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-end gap-3">
        <label className="flex items-center gap-2 text-theme-sm">
          {t("window")}
          <select
            className={`${inputClass} h-10! w-auto!`}
            value={days}
            onChange={(e) => setDays(Number(e.target.value))}
            aria-label={t("window")}
          >
            <option value={7}>{t("days", { n: 7 })}</option>
            <option value={30}>{t("days", { n: 30 })}</option>
            <option value={90}>{t("days", { n: 90 })}</option>
          </select>
        </label>
      </div>

      <RpcBoundary state={state}>
        {(a) => {
          const base = Math.max(a.huni.kayit, 1);
          const steps: [string, number][] = [
            [t("funnel.signup"), a.huni.kayit],
            [t("funnel.child"), a.huni.cocuk_bagladi],
            [t("funnel.learn"), a.huni.ilk_ogrenme],
            [t("funnel.paid"), a.huni.ucretli],
          ];
          return (
            <>
              <div className="grid gap-6 xl:grid-cols-2">
                <section className={`${cardClass} p-5 sm:p-6`}>
                  <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("funnel.title")}</h2>
                  <p className="mb-4 text-theme-xs text-gray-500 dark:text-gray-400">
                    {t("funnel.desc", { n: a.huni.kayit.toLocaleString("tr-TR"), d: a.gun })}
                  </p>
                  {steps.map(([label, n]) => {
                    const pct = (n / base) * 100;
                    return (
                      <div key={label} className="my-4">
                        <div className="mb-2 flex justify-between text-theme-sm">
                          <span>{label}</span>
                          <b>
                            {n.toLocaleString("tr-TR")} · %{pct.toLocaleString("tr-TR", { maximumFractionDigits: 1 })}
                          </b>
                        </div>
                        <div className="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-white/10">
                          <div className="h-full rounded-full bg-brand-500" style={{ width: `${Math.min(pct, 100)}%` }} />
                        </div>
                      </div>
                    );
                  })}
                  <p className="mt-3 text-theme-xs text-gray-500">{t("funnel.note")}</p>
                </section>

                <section className={`${cardClass} p-5 sm:p-6`}>
                  <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("cohort.title")}</h2>
                  <p className="mb-4 text-theme-xs text-gray-500 dark:text-gray-400">{t("cohort.desc")}</p>
                  <div className="overflow-x-auto">
                    <table className="w-full min-w-96 border-separate border-spacing-1 text-theme-xs">
                      <thead>
                        <tr>
                          <th className="text-start font-semibold">{t("cohort.cohort")}</th>
                          {[0, 1, 2, 3, 4].map((w) => <th key={w} className="font-semibold">H{w}</th>)}
                        </tr>
                      </thead>
                      <tbody>
                        {a.kohort.map((k) => (
                          <tr key={k.hafta}>
                            <th scope="row" className="text-start font-semibold whitespace-nowrap">
                              {k.hafta} <span className="font-normal text-gray-400">(n={k.boyut})</span>
                            </th>
                            {k.tutma.map((p, i) => (
                              <td key={i} className={`rounded-md p-2.5 text-center ${heat(p)}`}>
                                {p === null ? "—" : `%${p}`}
                              </td>
                            ))}
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                  <p className="mt-3 text-theme-xs text-gray-500">{t("cohort.note")}</p>
                </section>
              </div>

              <section className={`${cardClass} p-5 sm:p-6`}>
                <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("learning.title")}</h2>
                <dl className="mt-2 divide-y divide-gray-100 text-theme-sm dark:divide-gray-800">
                  <div className="flex justify-between py-3">
                    <dt>{t("learning.active7")}</dt>
                    <dd className="font-semibold">
                      {a.ogrenme.aktif_7_gun.toLocaleString("tr-TR")} / {a.ogrenme.ogrenci.toLocaleString("tr-TR")}
                    </dd>
                  </div>
                  <div className="flex justify-between py-3">
                    <dt>{t("learning.accuracy")}</dt>
                    <dd className="font-semibold">
                      {a.ogrenme.dogruluk_yuzde === null ? "—" : `%${a.ogrenme.dogruluk_yuzde.toLocaleString("tr-TR")}`}
                    </dd>
                  </div>
                  <div className="flex justify-between py-3">
                    <dt>{t("learning.review")}</dt>
                    <dd className="font-semibold">{a.ogrenme.tekrar_zamani_gelen.toLocaleString("tr-TR")}</dd>
                  </div>
                  <div className="flex items-center justify-between py-3">
                    <dt>{t("learning.gain")}</dt>
                    <dd><Badge size="sm" color="warning">{t("learning.gainNeeds")}</Badge></dd>
                  </div>
                </dl>
                <p className="mt-3 rounded-xl bg-[#eef5f2] px-4 py-3 text-theme-xs text-[#3d6654] dark:bg-brand-500/10 dark:text-brand-300">
                  {t("learning.note")}
                </p>
              </section>
            </>
          );
        }}
      </RpcBoundary>
    </div>
  );
}
