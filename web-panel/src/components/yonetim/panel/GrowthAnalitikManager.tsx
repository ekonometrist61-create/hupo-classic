"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import type { GrowthLifecycleDagilim, GrowthOzet, GrowthProspectKaynak } from "../types";
import ErrorNote from "./ErrorNote";
import { cardClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

const PERIODS = [7, 30, 90] as const;
type Period = (typeof PERIODS)[number];

const LIFECYCLE_KEYS = [
  "visitor",
  "lead",
  "registered",
  "trial",
  "activated",
  "engaged",
  "paid",
  "at_risk",
  "churned",
  "winback",
] as const;
const KNOWN_LIFECYCLE = new Set<string>(LIFECYCLE_KEYS);

const LIFECYCLE_BAR: Record<string, string> = {
  visitor: "bg-gray-300 dark:bg-gray-600",
  lead: "bg-gray-400 dark:bg-gray-500",
  registered: "bg-brand-200 dark:bg-brand-800",
  trial: "bg-warning-400",
  activated: "bg-brand-400",
  engaged: "bg-brand-500",
  paid: "bg-success-500",
  at_risk: "bg-warning-600",
  churned: "bg-error-400",
  winback: "bg-brand-700",
};
const FALLBACK_BAR = "bg-gray-300 dark:bg-gray-600";

const fmt = (n: number) => n.toLocaleString("tr-TR");
const pct = (a: number, b: number) => (b > 0 ? Math.round((a / b) * 100) : 0);

export default function GrowthAnalitikManager() {
  const t = useTranslations("yonetim.growthAnalitik");
  const [gun, setGun] = useState<Period>(30);
  const [reloadKey, setReloadKey] = useState(0);

  const [ozet, setOzet] = useState<GrowthOzet | null>(null);
  const [lifecycle, setLifecycle] = useState<GrowthLifecycleDagilim[]>([]);
  const [kaynak, setKaynak] = useState<GrowthProspectKaynak[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const supabase = createClient();
      const [o, l, k] = await Promise.all([
        supabase.rpc("admin_growth_ozet", { p_gun: gun }),
        supabase.rpc("admin_lifecycle_dagilim"),
        supabase.rpc("admin_prospect_kaynaklar"),
      ]);
      if (cancelled) return;
      const hata = o.error ?? l.error ?? k.error;
      if (hata) {
        setError(hata.message);
        setOzet(null);
      } else {
        setError(null);
        setOzet(o.data as GrowthOzet);
        setLifecycle((l.data as GrowthLifecycleDagilim[] | null) ?? []);
        setKaynak((k.data as GrowthProspectKaynak[] | null) ?? []);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [gun, reloadKey]);

  const changePeriod = (p: Period) => {
    if (p === gun) return;
    setLoading(true);
    setGun(p);
  };
  const retry = () => {
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const maxLifecycle = Math.max(0, ...lifecycle.map((x) => x.count));

  return (
    <div className="space-y-6">
      <section className={`${cardClass} flex flex-wrap items-center justify-between gap-4 p-5`}>
        <p className="text-theme-sm font-medium text-gray-700 dark:text-gray-300">{t("periodLabel")}</p>
        <div className="flex flex-wrap gap-2" role="group" aria-label={t("periodLabel")}>
          {PERIODS.map((p) => (
            <button
              key={p}
              type="button"
              aria-pressed={gun === p}
              className={gun === p ? primaryBtn : outlineBtn}
              onClick={() => changePeriod(p)}
            >
              {t("periodDays", { count: p })}
            </button>
          ))}
        </div>
      </section>

      {loading ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : error ? (
        <section className={`${cardClass} py-8 text-center`}>
          <div className="mx-auto max-w-md space-y-3">
            <ErrorNote message={error} />
            <button type="button" className={primaryBtn} onClick={retry}>
              {t("retry")}
            </button>
          </div>
        </section>
      ) : ozet ? (
        <>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <Kpi label={t("kpi.totalHouseholds")} value={fmt(ozet.total_households)} />
            <Kpi
              label={t("kpi.activeHouseholds")}
              value={fmt(ozet.active_households)}
              hint={t("kpiHint.activeShare", { pct: pct(ozet.active_households, ozet.total_households) })}
            />
            <Kpi
              label={t("kpi.prospectConversion")}
              value={`${pct(ozet.converted_prospects, ozet.total_prospects)}%`}
              hint={t("kpiHint.converted", {
                converted: fmt(ozet.converted_prospects),
                total: fmt(ozet.total_prospects),
              })}
            />
            <Kpi label={t("kpi.openLeads")} value={fmt(ozet.open_leads)} />
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
            <Kpi label={t("kpi.openTickets")} value={fmt(ozet.open_tickets)} />
            <Kpi label={t("kpi.recentEvents", { count: gun })} value={fmt(ozet.recent_events)} />
            <Kpi
              label={t("kpi.messages")}
              value={fmt(ozet.message_log_count)}
              hint={t("kpiHint.messages", { count: gun })}
            />
          </div>

          <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
            <section className={`${cardClass} p-5 sm:p-6`}>
              <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("sections.lifecycle")}</h3>
              <p className="mb-5 text-theme-sm text-gray-500 dark:text-gray-400">{t("sections.lifecycleDesc")}</p>
              {lifecycle.length === 0 ? (
                <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
              ) : (
                <ul className="space-y-3">
                  {lifecycle.map((row) => {
                    const width = maxLifecycle > 0 && row.count > 0
                      ? Math.max(2, Math.round((row.count / maxLifecycle) * 100))
                      : 0;
                    const label = KNOWN_LIFECYCLE.has(row.lifecycle)
                      ? t(`lifecycle.${row.lifecycle}`)
                      : row.lifecycle;
                    return (
                      <li key={row.lifecycle} className="grid grid-cols-[8rem_1fr_3.5rem] items-center gap-3">
                        <span className="truncate text-theme-sm text-gray-700 dark:text-gray-300">{label}</span>
                        <div className="h-3 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800" aria-hidden="true">
                          <div
                            className={`h-full rounded-full ${LIFECYCLE_BAR[row.lifecycle] ?? FALLBACK_BAR}`}
                            style={{ width: `${width}%` }}
                          />
                        </div>
                        <span className="text-end text-theme-sm font-medium tabular-nums text-gray-800 dark:text-white/90">
                          {fmt(row.count)}
                        </span>
                      </li>
                    );
                  })}
                </ul>
              )}
            </section>

            <section className={`${cardClass} p-5 sm:p-6`}>
              <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("sections.sources")}</h3>
              <p className="mb-5 text-theme-sm text-gray-500 dark:text-gray-400">{t("sections.sourcesDesc")}</p>
              {kaynak.length === 0 ? (
                <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="min-w-full">
                    <thead className="border-b border-gray-100 dark:border-gray-800">
                      <tr>
                        <th className={thClass}>{t("cols.source")}</th>
                        <th className={`${thClass} text-end`}>{t("cols.count")}</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                      {kaynak.map((k) => (
                        <tr key={k.source_channel}>
                          <td className={`${tdClass} font-mono`}>{k.source_channel}</td>
                          <td className={`${tdClass} text-end tabular-nums`}>{fmt(k.count)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </section>
          </div>
        </>
      ) : null}
    </div>
  );
}

function Kpi({ label, value, hint }: { label: string; value: string; hint?: string }) {
  return (
    <div className={`${cardClass} p-5`}>
      <p className="text-theme-sm text-gray-500 dark:text-gray-400">{label}</p>
      <p className="mt-2 text-title-sm font-semibold text-gray-800 dark:text-white/90">{value}</p>
      {hint && <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{hint}</p>}
    </div>
  );
}
