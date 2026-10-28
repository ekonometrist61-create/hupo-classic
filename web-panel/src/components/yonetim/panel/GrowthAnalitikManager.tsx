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

const FUNNEL_KEYS = ["kayit", "cocuk_bagli", "ilk_soru", "deneme_basladi", "ucretli"] as const;
const KNOWN_FUNNEL = new Set<string>(FUNNEL_KEYS);

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

// Tablo kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";

// admin_growth_funnel(p_gun) dönüşü. Null = 5'ten az (gizli).
type FunnelStep = {
  adim: string;
  sayi: number | null;
  onceki_yuzde: number | null;
  kayit_yuzde: number | null;
};
type GrowthFunnel = {
  gun: number;
  esik: number;
  adimlar: FunnelStep[];
  churn: { sayi: number | null; kayit_yuzde: number | null };
};

// admin_growth_utm_atif(p_gun) dönüşü.
type UtmSatir = {
  kanal: string;
  ortam: string | null;
  kampanya: string | null;
  diger: boolean;
  ziyaretci: number | null;
  kayit: number | null;
  ucretli: number | null;
  kayit_yuzde: number | null;
  ucretli_yuzde: number | null;
};
type GrowthUtm = {
  gun: number;
  esik: number;
  toplam: { ziyaretci: number | null; kayit: number | null; ucretli: number | null };
  satirlar: UtmSatir[];
};

// admin_growth_aktiflik(p_gun) dönüşü.
type GrowthAktiflik = {
  gun: number;
  bugun: string;
  dau: number;
  wau: number;
  mau: number;
  yapismazlik_yuzde: number | null;
  seri: { gun: string; aktif: number }[];
};

type Veri = {
  ozet: GrowthOzet;
  lifecycle: GrowthLifecycleDagilim[];
  kaynak: GrowthProspectKaynak[];
  huni: GrowthFunnel;
  utm: GrowthUtm;
  aktif: GrowthAktiflik;
};

const fmt = (n: number) => n.toLocaleString("tr-TR");
const fmtN = (n: number | null) => (n === null ? "—" : fmt(n));
const fmtP = (p: number | null) =>
  p === null ? "—" : `${p.toLocaleString("tr-TR", { maximumFractionDigits: 1 })}%`;
const pct = (a: number, b: number) => (b > 0 ? Math.round((a / b) * 100) : 0);

// Excel (TR) için noktalı virgül ayırıcı ve BOM. Hücre değerleri yalnızca toplulaştırılmış sayılardır.
function buildCsv(satirlar: (string | number | null)[][]): string {
  const hucre = (v: string | number | null) => {
    if (v === null) return "";
    const s = String(v);
    return /[;"\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  return "﻿" + satirlar.map((r) => r.map(hucre).join(";")).join("\r\n");
}

export default function GrowthAnalitikManager() {
  const t = useTranslations("yonetim.growthAnalitik");
  const [gun, setGun] = useState<Period>(30);
  const [reloadKey, setReloadKey] = useState(0);

  const [veri, setVeri] = useState<Veri | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const supabase = createClient();
      const [o, l, k, h, u, a] = await Promise.all([
        supabase.rpc("admin_growth_ozet", { p_gun: gun }),
        supabase.rpc("admin_lifecycle_dagilim"),
        supabase.rpc("admin_prospect_kaynaklar"),
        supabase.rpc("admin_growth_funnel", { p_gun: gun }),
        supabase.rpc("admin_growth_utm_atif", { p_gun: gun }),
        supabase.rpc("admin_growth_aktiflik", { p_gun: gun }),
      ]);
      if (cancelled) return;
      const hata = o.error ?? l.error ?? k.error ?? h.error ?? u.error ?? a.error;
      if (hata || !o.data || !h.data || !u.data || !a.data) {
        setError(hata?.message || t("error"));
        setVeri(null);
      } else {
        setError(null);
        setVeri({
          ozet: o.data as GrowthOzet,
          lifecycle: (l.data as GrowthLifecycleDagilim[] | null) ?? [],
          kaynak: (k.data as GrowthProspectKaynak[] | null) ?? [],
          huni: h.data as GrowthFunnel,
          utm: u.data as GrowthUtm,
          aktif: a.data as GrowthAktiflik,
        });
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [gun, reloadKey, t]);

  const changePeriod = (p: Period) => {
    if (p === gun) return;
    setLoading(true);
    setGun(p);
  };
  const retry = () => {
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const exportCsv = () => {
    if (!veri) return;
    const { huni, utm, aktif } = veri;
    const satirlar: (string | number | null)[][] = [
      [t("csv.funnel")],
      [t("funnel.colStep"), t("funnel.colCount"), t("funnel.colPrevious"), t("funnel.colSignup")],
      ...huni.adimlar.map((s) => [
        KNOWN_FUNNEL.has(s.adim) ? t(`funnel.steps.${s.adim}`) : s.adim,
        s.sayi,
        s.onceki_yuzde,
        s.kayit_yuzde,
      ]),
      [t("funnel.churn"), huni.churn.sayi, null, huni.churn.kayit_yuzde],
      [],
      [t("csv.utm")],
      [
        t("utm.cols.channel"),
        t("utm.cols.medium"),
        t("utm.cols.campaign"),
        t("utm.cols.visitors"),
        t("utm.cols.signups"),
        t("utm.cols.paid"),
        t("utm.cols.signupRate"),
        t("utm.cols.paidRate"),
      ],
      ...utm.satirlar.map((s) => [
        s.diger ? t("utm.other") : s.kanal,
        s.ortam,
        s.kampanya,
        s.ziyaretci,
        s.kayit,
        s.ucretli,
        s.kayit_yuzde,
        s.ucretli_yuzde,
      ]),
      [],
      [t("csv.activity")],
      [t("csv.metric"), t("csv.value")],
      [t("activity.dau"), aktif.dau],
      [t("activity.wau"), aktif.wau],
      [t("activity.mau"), aktif.mau],
      [t("activity.stickinessLabel"), aktif.yapismazlik_yuzde],
      [],
      [t("csv.note")],
    ];
    const blob = new Blob([buildCsv(satirlar)], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `growth-analitik-${gun}g-${aktif.bugun}.csv`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  };

  const maxLifecycle = Math.max(0, ...(veri?.lifecycle ?? []).map((x) => x.count));
  const maxSeri = Math.max(0, ...(veri?.aktif.seri ?? []).map((x) => x.aktif));
  const kayitSayi = veri?.huni.adimlar[0]?.sayi ?? null;

  return (
    <div className="space-y-6">
      <section className={`${cardClass} flex flex-wrap items-center justify-between gap-4 p-5`}>
        <div className="flex flex-wrap items-center gap-3">
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
        </div>
        <button type="button" className={outlineBtn} onClick={exportCsv} disabled={!veri || loading}>
          {t("csvButton")}
        </button>
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
      ) : veri ? (
        <>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <Kpi label={t("kpi.totalHouseholds")} value={fmt(veri.ozet.total_households)} />
            <Kpi
              label={t("kpi.activeHouseholds")}
              value={fmt(veri.ozet.active_households)}
              hint={t("kpiHint.activeShare", {
                pct: pct(veri.ozet.active_households, veri.ozet.total_households),
              })}
            />
            <Kpi
              label={t("kpi.prospectConversion")}
              value={`${pct(veri.ozet.converted_prospects, veri.ozet.total_prospects)}%`}
              hint={t("kpiHint.converted", {
                converted: fmt(veri.ozet.converted_prospects),
                total: fmt(veri.ozet.total_prospects),
              })}
            />
            <Kpi label={t("kpi.openLeads")} value={fmt(veri.ozet.open_leads)} />
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
            <Kpi label={t("kpi.openTickets")} value={fmt(veri.ozet.open_tickets)} />
            <Kpi label={t("kpi.recentEvents", { count: gun })} value={fmt(veri.ozet.recent_events)} />
            <Kpi
              label={t("kpi.messages")}
              value={fmt(veri.ozet.message_log_count)}
              hint={t("kpiHint.messages", { count: gun })}
            />
          </div>

          <section className="space-y-4">
            <div>
              <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("activity.title")}</h3>
              <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("activity.desc")}</p>
            </div>
            {veri.aktif.mau === 0 ? (
              <p className={`${cardClass} py-6 text-center text-sm text-gray-500 dark:text-gray-400`}>{t("empty")}</p>
            ) : (
              <>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                  <Kpi label={t("activity.dau")} value={fmt(veri.aktif.dau)} />
                  <Kpi label={t("activity.wau")} value={fmt(veri.aktif.wau)} />
                  <Kpi
                    label={t("activity.mau")}
                    value={fmt(veri.aktif.mau)}
                    hint={t("activity.stickiness", { pct: fmtP(veri.aktif.yapismazlik_yuzde) })}
                  />
                </div>
                <section className={`${cardClass} p-5 sm:p-6`}>
                  <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("activity.series")}</h4>
                  <p className="mb-4 text-theme-xs text-gray-500 dark:text-gray-400">{t("activity.seriesDesc")}</p>
                  <div
                    className="flex h-28 items-end gap-px"
                    role="img"
                    aria-label={t("activity.seriesAria", { count: veri.aktif.seri.length })}
                  >
                    {veri.aktif.seri.map((s) => (
                      <div
                        key={s.gun}
                        title={`${s.gun}: ${fmt(s.aktif)}`}
                        className="min-w-0 flex-1 rounded-t bg-brand-400 dark:bg-brand-600"
                        style={{
                          height: maxSeri > 0 && s.aktif > 0 ? `${Math.max(4, Math.round((s.aktif / maxSeri) * 100))}%` : "2px",
                          opacity: s.aktif > 0 ? 1 : 0.25,
                        }}
                      />
                    ))}
                  </div>
                  <div className="mt-2 flex justify-between text-theme-xs text-gray-500 dark:text-gray-400">
                    <span>{veri.aktif.seri[0]?.gun ?? ""}</span>
                    <span>{veri.aktif.seri[veri.aktif.seri.length - 1]?.gun ?? ""}</span>
                  </div>
                </section>
              </>
            )}
          </section>

          <section className={`${cardClass} p-5 sm:p-6`}>
            <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("funnel.title")}</h3>
            <p className="mb-1 text-theme-sm text-gray-500 dark:text-gray-400">{t("funnel.desc", { count: gun })}</p>
            <p className="mb-5 text-theme-xs text-gray-400 dark:text-gray-500">{t("hiddenNote")}</p>
            {kayitSayi === null ? (
              <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("lowData")}</p>
            ) : (
              <ol className="space-y-4">
                {veri.huni.adimlar.map((s) => {
                  const label = KNOWN_FUNNEL.has(s.adim) ? t(`funnel.steps.${s.adim}`) : s.adim;
                  const genislik =
                    s.sayi !== null && kayitSayi > 0 ? Math.max(2, Math.round((s.sayi / kayitSayi) * 100)) : 0;
                  return (
                    <li key={s.adim} className="space-y-2">
                      <div className="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                        <span className="text-theme-sm font-medium text-gray-700 dark:text-gray-300">{label}</span>
                        <span className="text-theme-sm tabular-nums text-gray-600 dark:text-gray-400">
                          <span className="font-semibold text-gray-800 dark:text-white/90">{fmtN(s.sayi)}</span>
                          <span className="ms-3">
                            {t("funnel.colSignup")}: {fmtP(s.kayit_yuzde)}
                          </span>
                          {s.adim !== "kayit" && (
                            <span className="ms-3">
                              {t("funnel.colPrevious")}: {fmtP(s.onceki_yuzde)}
                            </span>
                          )}
                        </span>
                      </div>
                      <div className="h-2.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800" aria-hidden="true">
                        <div className="h-full rounded-full bg-brand-500" style={{ width: `${genislik}%` }} />
                      </div>
                      {s.sayi === null && <p className="text-theme-xs text-gray-400 dark:text-gray-500">{t("suppressed")}</p>}
                    </li>
                  );
                })}
                <li className="space-y-1 border-t border-gray-100 pt-4 dark:border-gray-800">
                  <div className="flex flex-wrap items-baseline justify-between gap-2">
                    <span className="text-theme-sm font-medium text-gray-700 dark:text-gray-300">{t("funnel.churn")}</span>
                    <span className="text-theme-sm tabular-nums text-gray-600 dark:text-gray-400">
                      <span className="font-semibold text-gray-800 dark:text-white/90">{fmtN(veri.huni.churn.sayi)}</span>
                      <span className="ms-3">
                        {t("funnel.colSignup")}: {fmtP(veri.huni.churn.kayit_yuzde)}
                      </span>
                    </span>
                  </div>
                  {veri.huni.churn.sayi === null && (
                    <p className="text-theme-xs text-gray-400 dark:text-gray-500">{t("suppressed")}</p>
                  )}
                </li>
              </ol>
            )}
          </section>

          <section className={`${cardClass} p-5 sm:p-6`}>
            <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("utm.title")}</h3>
            <p className="mb-5 text-theme-sm text-gray-500 dark:text-gray-400">{t("utm.desc", { count: gun })}</p>
            {veri.utm.satirlar.length === 0 ? (
              <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
            ) : (
              <div className={`overflow-x-auto ${ILK_SUTUN_SABIT}`}>
                <table className="min-w-full">
                  <thead className="border-b border-gray-100 dark:border-gray-800">
                    <tr>
                      <th className={thClass}>{t("utm.cols.channel")}</th>
                      <th className={thClass}>{t("utm.cols.medium")}</th>
                      <th className={thClass}>{t("utm.cols.campaign")}</th>
                      <th className={`${thClass} text-end`}>{t("utm.cols.visitors")}</th>
                      <th className={`${thClass} text-end`}>{t("utm.cols.signups")}</th>
                      <th className={`${thClass} text-end`}>{t("utm.cols.signupRate")}</th>
                      <th className={`${thClass} text-end`}>{t("utm.cols.paid")}</th>
                      <th className={`${thClass} text-end`}>{t("utm.cols.paidRate")}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {veri.utm.satirlar.map((s, i) => (
                      <tr key={`${s.kanal}-${s.ortam ?? ""}-${s.kampanya ?? ""}-${i}`}>
                        <td className={`${tdClass} font-mono`}>{s.diger ? t("utm.other") : s.kanal}</td>
                        <td className={`${tdClass} font-mono`}>{s.ortam ?? "—"}</td>
                        <td className={`${tdClass} font-mono`}>{s.kampanya ?? "—"}</td>
                        <td className={`${tdClass} text-end tabular-nums`}>{fmtN(s.ziyaretci)}</td>
                        <td className={`${tdClass} text-end tabular-nums`}>{fmtN(s.kayit)}</td>
                        <td className={`${tdClass} text-end tabular-nums`}>{fmtP(s.kayit_yuzde)}</td>
                        <td className={`${tdClass} text-end tabular-nums`}>{fmtN(s.ucretli)}</td>
                        <td className={`${tdClass} text-end tabular-nums`}>{fmtP(s.ucretli_yuzde)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
            <p className="mt-3 text-theme-xs text-gray-400 dark:text-gray-500">{t("hiddenNote")}</p>
          </section>

          <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
            <section className={`${cardClass} p-5 sm:p-6`}>
              <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("sections.lifecycle")}</h3>
              <p className="mb-5 text-theme-sm text-gray-500 dark:text-gray-400">{t("sections.lifecycleDesc")}</p>
              {veri.lifecycle.length === 0 ? (
                <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
              ) : (
                <ul className="space-y-3">
                  {veri.lifecycle.map((row) => {
                    const width =
                      maxLifecycle > 0 && row.count > 0 ? Math.max(2, Math.round((row.count / maxLifecycle) * 100)) : 0;
                    const label = KNOWN_LIFECYCLE.has(row.lifecycle) ? t(`lifecycle.${row.lifecycle}`) : row.lifecycle;
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
              {veri.kaynak.length === 0 ? (
                <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
              ) : (
                <div className={`overflow-x-auto ${ILK_SUTUN_SABIT}`}>
                  <table className="min-w-full">
                    <thead className="border-b border-gray-100 dark:border-gray-800">
                      <tr>
                        <th className={thClass}>{t("cols.source")}</th>
                        <th className={`${thClass} text-end`}>{t("cols.count")}</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                      {veri.kaynak.map((k) => (
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
