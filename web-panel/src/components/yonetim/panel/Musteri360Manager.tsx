"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { formatDate, formatTry } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { CommercialConsent, GrowthHousehold, GrowthHouseholdList, Musteri360Ozet } from "../types";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";
import useDebounced from "./useDebounced";

const PAGE_SIZE = 25;
const LIFECYCLE_STAGES = ["visitor", "lead", "registered", "trial", "activated", "engaged", "paid", "at_risk", "churned", "winback"] as const;
const PLANS = ["free", "trial", "premium", "family"] as const;
const IZIN_KANALLARI = ["email", "sms", "phone", "push"] as const;
const KAYNAKLAR = ["deneme_on_kayit", "uygulama_kayit", "landing_erken_erisim", "web_form", "bilinmiyor"] as const;
const CONSENT_STATES = ["granted", "denied", "unknown"] as const;

export type LifecycleStage = (typeof LIFECYCLE_STAGES)[number];
export type GrowthPlan = (typeof PLANS)[number];
export type IzinKanali = (typeof IZIN_KANALLARI)[number];
export type KaynakAnahtari = (typeof KAYNAKLAR)[number];

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

const CONSENT_CLASS: Record<CommercialConsent, string> = {
  granted: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-400",
  denied: "bg-gray-100 text-gray-600 dark:bg-white/5 dark:text-gray-400",
  unknown: "bg-white text-gray-500 ring-1 ring-inset ring-gray-200 dark:bg-transparent dark:text-gray-400 dark:ring-gray-700",
};

const SOURCE_CLASS = "bg-blue-light-50 text-blue-light-600 dark:bg-blue-light-500/15 dark:text-blue-light-400";

// Tablo (md ve üzeri) kendi kapsayıcısında kayar; ilk sütun (müşteri adı) kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";

export function asLifecycle(v: string | null | undefined): LifecycleStage | null {
  return (LIFECYCLE_STAGES as readonly string[]).includes(v ?? "") ? (v as LifecycleStage) : null;
}

export function asPlan(v: string | null | undefined): GrowthPlan | null {
  return (PLANS as readonly string[]).includes(v ?? "") ? (v as GrowthPlan) : null;
}

function asConsent(v: string | null | undefined): CommercialConsent {
  return (CONSENT_STATES as readonly string[]).includes(v ?? "") ? (v as CommercialConsent) : "unknown";
}

function asKaynak(v: string | null | undefined): KaynakAnahtari | null {
  return (KAYNAKLAR as readonly string[]).includes(v ?? "") ? (v as KaynakAnahtari) : null;
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

/** Kaynak rozeti: bilinen kaynaklar çevrilir, tanınmayanlar ham değeriyle gösterilir. */
export function KaynakBadge({ kaynak }: { kaynak: string | null }) {
  const t = useTranslations("yonetim.musteri360");
  const key = asKaynak(kaynak ?? "bilinmiyor");
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium ${SOURCE_CLASS}`}>
      {key ? t(`sources.${key}`) : kaynak}
    </span>
  );
}

export function ConsentBadge({ durum }: { durum: string | null | undefined }) {
  const t = useTranslations("yonetim.musteri360");
  const key = asConsent(durum);
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium ${CONSENT_CLASS[key]}`}>
      {t(`consent.${key}`)}
    </span>
  );
}

/** Skor henüz yazılmıyorsa (null veya 0) "Veri yok" gösterilir; 0 bir skor gibi sunulmaz. */
export function HealthBar({ score }: { score: number | null }) {
  const t = useTranslations("yonetim.musteri360");
  if (score === null || score === undefined || score === 0) {
    return <span className="text-theme-sm text-gray-400">{t("health.noData")}</span>;
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

function OzetKarti({ baslik, deger }: { baslik: string; deger: number }) {
  return (
    <div className={`${cardClass} min-w-0 p-4`}>
      <p className="text-theme-xs font-medium text-gray-500 dark:text-gray-400">{baslik}</p>
      <p className="mt-1 text-xl font-semibold text-gray-800 dark:text-white/90">{deger.toLocaleString("tr-TR")}</p>
    </div>
  );
}

export default function Musteri360Manager() {
  const t = useTranslations("yonetim.musteri360");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [lifecycle, setLifecycle] = useState<"" | LifecycleStage>("");
  const [plan, setPlan] = useState<"" | GrowthPlan>("");
  const [source, setSource] = useState("");
  const [izinKanal, setIzinKanal] = useState<"" | IzinKanali>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthHouseholdList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Özet kartları: filtrelerden bağımsız; hata olursa kartlar gizlenir, liste etkilenmez.
  const [ozet, setOzet] = useState<Musteri360Ozet | null>(null);
  const [ozetDurum, setOzetDurum] = useState<"loading" | "ready" | "error">("loading");

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_musteri_360_ozet");
      if (cancelled) return;
      if (err || !data) {
        setOzet(null);
        setOzetDurum("error");
      } else {
        setOzet(data as Musteri360Ozet);
        setOzetDurum("ready");
      }
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_musteri_360_listele", {
        p_arama: debounced.trim() || null,
        p_lifecycle: lifecycle || null,
        p_plan: plan || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
        p_kaynak: source || null,
        p_izin_kanal: izinKanal || null,
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
  }, [debounced, lifecycle, plan, source, izinKanal, page, reloadKey]);

  // Bilinmiyor kaynağı filtre seçeneği olarak sunulmaz: RPC tam eşleşme yaptığı için
  // kaynağı boş olan kayıtları getirmez; bu kayıtlar "Tümü" ile listelenir.
  const kaynakSecenekleri = (ozet?.kaynaklar ?? []).filter((k) => k.kaynak !== "bilinmiyor");

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  const ozetKartlari: Array<{ baslik: string; deger: number }> = ozet
    ? [
        { baslik: t("summary.total"), deger: ozet.toplam },
        { baslik: t("summary.last7Days"), deger: ozet.son_7_gun },
        { baslik: t("summary.phone"), deger: ozet.telefonlu },
        { baslik: t("summary.children"), deger: ozet.cocuklu },
        { baslik: t("summary.consentCard", { kanal: t("channels.email") }), deger: ozet.izin_email },
        { baslik: t("summary.consentCard", { kanal: t("channels.sms") }), deger: ozet.izin_sms },
        { baslik: t("summary.consentCard", { kanal: t("channels.phone") }), deger: ozet.izin_phone },
        { baslik: t("summary.consentCard", { kanal: t("channels.push") }), deger: ozet.izin_push },
      ]
    : [];

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      {ozetDurum === "loading" && (
        <p className="mb-5 text-sm text-gray-500 dark:text-gray-400">{t("summary.loading")}</p>
      )}
      {ozetDurum === "ready" && ozet && ozet.toplam === 0 && (
        <p className="mb-5 text-sm text-gray-500 dark:text-gray-400">{t("summary.empty")}</p>
      )}
      {ozetDurum === "ready" && ozet && ozet.toplam > 0 && (
        <div className="mb-5 grid grid-cols-2 gap-3 md:grid-cols-4">
          {ozetKartlari.map((k) => (
            <OzetKarti key={k.baslik} baslik={k.baslik} deger={k.deger} />
          ))}
        </div>
      )}

      <div className="mb-4 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-5 xl:items-end">
        <div className="sm:col-span-2 xl:col-span-2">
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
        <div>
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
        <div>
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
        {kaynakSecenekleri.length > 0 && (
          <div>
            <label className={labelClass} htmlFor="m360-source">{t("filters.source")}</label>
            <select
              id="m360-source"
              className={inputClass}
              value={source}
              onChange={(e) => { setSource(e.target.value); setPage(0); setLoading(true); }}
            >
              <option value="">{t("filters.allSources")}</option>
              {kaynakSecenekleri.map((k) => {
                const key = asKaynak(k.kaynak);
                return (
                  <option key={k.kaynak} value={k.kaynak}>
                    {key ? t(`sources.${key}`) : k.kaynak}
                  </option>
                );
              })}
            </select>
          </div>
        )}
        <div>
          <label className={labelClass} htmlFor="m360-izin">{t("filters.consentChannel")}</label>
          <select
            id="m360-izin"
            className={inputClass}
            value={izinKanal}
            onChange={(e) => { setIzinKanal(e.target.value as "" | IzinKanali); setPage(0); setLoading(true); }}
          >
            <option value="">{t("filters.allChannels")}</option>
            {IZIN_KANALLARI.map((k) => (
              <option key={k} value={k}>{t(`channels.${k}`)}</option>
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
        <>
          {/* Telefon ve küçük tablet (md altı): kart görünümü */}
          <ul className="space-y-3 md:hidden">
            {rows.map((h: GrowthHousehold) => {
              const p = asPlan(h.plan);
              return (
                <li key={h.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <Link
                      href={`/yonetim/musteri-360/${h.id}`}
                      className="inline-flex min-h-11 min-w-0 items-center font-medium wrap-break-word text-gray-800 hover:text-brand-500 dark:text-white/90 dark:hover:text-brand-400"
                    >
                      {h.parent_name}
                    </Link>
                    <LifecycleBadge stage={h.lifecycle} />
                  </div>
                  <p className="text-theme-sm break-all text-gray-600 dark:text-gray-400">{h.email ?? "-"}</p>
                  <div className="mt-2 flex flex-wrap gap-2">
                    <KaynakBadge kaynak={h.source} />
                    <ConsentBadge durum={h.commercial_consent_overall} />
                  </div>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-3 text-theme-sm">
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.customerNo")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">{h.customer_no ?? "-"}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.children")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">{h.cocuk_sayisi ?? 0}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.plan")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">{p ? t(`plans.${p}`) : (h.plan ?? "-")}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.mrr")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">{formatTry(h.total_revenue_try ?? 0)}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.health")}</dt>
                      <dd><HealthBar score={h.lead_score} /></dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.lastActivity")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">
                        {h.last_seen_at ? formatDate(new Date(h.last_seen_at)) : "-"}
                      </dd>
                    </div>
                  </dl>
                </li>
              );
            })}
          </ul>

          {/* Tablet ve masaüstü (md ve üzeri): tablo; kapsayıcısı kayar */}
          <div className={`hidden overflow-x-auto md:block ${ILK_SUTUN_SABIT}`}>
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>{t("cols.customerNo")}</th>
                  <th className={thClass}>{t("cols.name")}</th>
                  <th className={thClass}>{t("cols.email")}</th>
                  <th className={thClass}>{t("cols.source")}</th>
                  <th className={thClass}>{t("cols.consent")}</th>
                  <th className={thClass}>{t("cols.children")}</th>
                  <th className={thClass}>{t("cols.lifecycle")}</th>
                  <th className={thClass}>{t("cols.plan")}</th>
                  <th className={thClass}>{t("cols.mrr")}</th>
                  <th className={thClass}>{t("cols.health")}</th>
                  <th className={thClass}>{t("cols.lastActivity")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((h: GrowthHousehold) => {
                  const p = asPlan(h.plan);
                  return (
                    <tr key={h.id}>
                      <td className={`${tdClass} whitespace-nowrap`}>{h.customer_no ?? "-"}</td>
                      <td className={tdClass}>
                        <Link
                          href={`/yonetim/musteri-360/${h.id}`}
                          className="inline-flex min-h-11 items-center font-medium text-gray-800 hover:text-brand-500 dark:text-white/90 dark:hover:text-brand-400"
                        >
                          {h.parent_name}
                        </Link>
                      </td>
                      <td className={tdClass}>{h.email ?? "-"}</td>
                      <td className={tdClass}>
                        <KaynakBadge kaynak={h.source} />
                      </td>
                      <td className={tdClass}>
                        <ConsentBadge durum={h.commercial_consent_overall} />
                      </td>
                      <td className={`${tdClass} text-center`}>{h.cocuk_sayisi ?? 0}</td>
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
        </>
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
