"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { formatDate, formatTry } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthHousehold, GrowthHouseholdList } from "../types";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";
import useDebounced from "./useDebounced";

const PAGE_SIZE = 25;
const LIFECYCLE_STAGES = ["visitor", "lead", "registered", "trial", "activated", "engaged", "paid", "at_risk", "churned", "winback"] as const;
const PLANS = ["free", "trial", "premium", "family"] as const;

export type LifecycleStage = (typeof LIFECYCLE_STAGES)[number];
export type GrowthPlan = (typeof PLANS)[number];

const LIFECYCLE_CLASS: Record<LifecycleStage, string> = {
  visitor: "bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-white/80",
  lead: "bg-blue-light-50 text-blue-light-500 dark:bg-blue-light-500/15 dark:text-blue-light-500",
  registered: "bg-blue-light-50 text-blue-light-600 dark:bg-blue-light-500/15 dark:text-blue-light-400",
  trial: "bg-warning-50 text-warning-600 dark:bg-warning-500/15 dark:text-warning-500",
  activated: "bg-success-50 text-success-600 dark:bg-success-500/15 dark:text-success-500",
  engaged: "bg-success-50 text-success-700 dark:bg-success-500/20 dark:text-success-400",
  paid: "bg-success-50 text-success-800 dark:bg-success-500/25 dark:text-success-300",
  at_risk: "bg-warning-50 text-warning-700 dark:bg-warning-500/20 dark:text-warning-400",
  churned: "bg-error-50 text-error-600 dark:bg-error-500/15 dark:text-error-500",
  winback: "bg-blue-light-50 text-blue-light-700 dark:bg-blue-light-500/20 dark:text-blue-light-300",
};

export function asLifecycle(v: string | null | undefined): LifecycleStage | null {
  return (LIFECYCLE_STAGES as readonly string[]).includes(v ?? "") ? (v as LifecycleStage) : null;
}

export function asPlan(v: string | null | undefined): GrowthPlan | null {
  return (PLANS as readonly string[]).includes(v ?? "") ? (v as GrowthPlan) : null;
}

export function LifecycleBadge({ stage }: { stage: string }) {
  const t = useTranslations("yonetim.musteri360");
  const key = asLifecycle(stage);
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium ${
        key ? LIFECYCLE_CLASS[key] : LIFECYCLE_CLASS.visitor
      }`}
    >
      {key ? t(`stages.${key}`) : stage}
    </span>
  );
}

export function HealthBar({ score }: { score: number | null }) {
  if (score === null || score === undefined) {
    return <span className="text-theme-sm text-gray-400">-</span>;
  }
  const v = Math.max(0, Math.min(100, Math.round(score)));
  const color = v <= 30 ? "bg-error-500" : v <= 60 ? "bg-warning-500" : "bg-success-500";
  return (
    <div className="flex min-w-24 items-center gap-2">
      <div className="h-2 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-white/5">
        <div className={`h-full rounded-full ${color}`} style={{ width: `${v}%` }} />
      </div>
      <span className="w-8 text-end text-theme-xs font-medium text-gray-700 dark:text-gray-300">{v}</span>
    </div>
  );
}

export default function Musteri360Manager() {
  const t = useTranslations("yonetim.musteri360");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [lifecycle, setLifecycle] = useState<"" | LifecycleStage>("");
  const [plan, setPlan] = useState<"" | GrowthPlan>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthHouseholdList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_musteri_360_listele", {
        p_arama: debounced.trim() || null,
        p_lifecycle: lifecycle || null,
        p_plan: plan || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthHouseholdList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, lifecycle, plan, page, reloadKey]);

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="mb-4 flex flex-wrap items-end gap-4">
        <div className="min-w-60 flex-1">
          <label className={labelClass} htmlFor="m360-search">{t("search")}</label>
          <input
            id="m360-search"
            type="search"
            className={inputClass}
            placeholder={t("searchPlaceholder")}
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); setLoading(true); }}
          />
        </div>
        <div className="min-w-44">
          <label className={labelClass} htmlFor="m360-lifecycle">{t("filters.lifecycle")}</label>
          <select
            id="m360-lifecycle"
            className={inputClass}
            value={lifecycle}
            onChange={(e) => { setLifecycle(e.target.value as "" | LifecycleStage); setPage(0); setLoading(true); }}
          >
            <option value="">{t("filters.allLifecycle")}</option>
            {LIFECYCLE_STAGES.map((s) => (
              <option key={s} value={s}>{t(`stages.${s}`)}</option>
            ))}
          </select>
        </div>
        <div className="min-w-40">
          <label className={labelClass} htmlFor="m360-plan">{t("filters.plan")}</label>
          <select
            id="m360-plan"
            className={inputClass}
            value={plan}
            onChange={(e) => { setPlan(e.target.value as "" | GrowthPlan); setPage(0); setLoading(true); }}
          >
            <option value="">{t("filters.allPlans")}</option>
            {PLANS.map((p) => (
              <option key={p} value={p}>{t(`plans.${p}`)}</option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : error ? (
        <div className="py-8 text-center">
          <ErrorNote message={error} />
          <button
            type="button"
            className={`${primaryBtn} mt-3`}
            onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}
          >
            {t("retry")}
          </button>
        </div>
      ) : rows.length === 0 ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("noRecords")}</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th className={thClass}>{t("cols.customerNo")}</th>
                <th className={thClass}>{t("cols.name")}</th>
                <th className={thClass}>{t("cols.email")}</th>
                <th className={thClass}>{t("cols.lifecycle")}</th>
                <th className={thClass}>{t("cols.plan")}</th>
                <th className={thClass}>{t("cols.mrr")}</th>
                <th className={thClass}>{t("cols.health")}</th>
                <th className={thClass}>{t("cols.lastActivity")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {rows.map((h) => {
                const p = asPlan(h.plan);
                return (
                  <tr key={h.id}>
                    <td className={`${tdClass} whitespace-nowrap`}>{h.customer_no ?? "-"}</td>
                    <td className={tdClass}>
                      <Link
                        href={`/yonetim/musteri-360/${h.id}`}
                        className="font-medium text-gray-800 hover:text-brand-500 dark:text-white/90 dark:hover:text-brand-400"
                      >
                        {h.parent_name}
                      </Link>
                    </td>
                    <td className={tdClass}>{h.email ?? "-"}</td>
                    <td className={tdClass}>
                      <LifecycleBadge stage={h.lifecycle} />
                    </td>
                    <td className={tdClass}>{p ? t(`plans.${p}`) : (h.plan ?? "-")}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{formatTry(h.total_revenue_try ?? 0)}</td>
                    <td className={tdClass}>
                      <HealthBar score={h.lead_score} />
                    </td>
                    <td className={`${tdClass} whitespace-nowrap`}>
                      {h.last_seen_at ? formatDate(new Date(h.last_seen_at)) : "-"}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {!loading && !error && total > 0 && (
        <Pager
          page={page}
          pageSize={PAGE_SIZE}
          total={total}
          onPage={(p) => { setLoading(true); setPage(p); }}
          labels={{ prev: t("pager.prev"), next: t("pager.next"), summary: `${start}–${end} / ${total}` }}
        />
      )}
    </section>
  );
}
