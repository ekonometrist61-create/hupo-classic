"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthProspectList } from "../types";
import ErrorNote from "./ErrorNote";
import {
  Chip,
  KIND_LABEL,
  PROSPECT_KINDS,
  ProspectFormModal,
  STATUS_CHIP,
  STATUS_LABEL,
  STATUS_OPTIONS,
  scoreTextClass,
} from "./prospectShared";
import { cardClass, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";
import useDebounced from "./useDebounced";

const PAGE_SIZE = 25;

// Tablo ilk sütunu yatay kaydırmada sabit kalır; kart bağlantısı tam genişlikte dokunma alanıdır (TASKS §20).
const TH_STICKY =
  "sticky start-0 z-10 bg-[#f8fafb] px-4 py-3 text-start text-[11px] font-semibold tracking-wide whitespace-nowrap text-gray-500 uppercase dark:bg-gray-900 dark:text-gray-400";
const TD_STICKY = `${tdClass} sticky start-0 z-10 bg-white dark:bg-gray-900`;
const CARD_LINK =
  "block min-h-11 rounded-xl border border-gray-200 p-4 transition hover:bg-gray-50 dark:border-gray-800 dark:hover:bg-white/5";

export default function PotansiyelAdaylarManager() {
  const t = useTranslations("yonetim.potansiyelAdaylar");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [status, setStatus] = useState("");
  const [kind, setKind] = useState("");
  const [minScore, setMinScore] = useState("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);
  const [creating, setCreating] = useState(false);

  const [list, setList] = useState<GrowthProspectList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const min = minScore.trim() === "" ? null : Math.min(100, Math.max(0, Number(minScore)));
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_prospect_listele", {
        p_arama: debounced.trim() || null,
        p_status: status || null,
        p_kind: kind || null,
        p_min_score: min,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthProspectList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, status, kind, minScore, page, reloadKey]);

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  const resetPage = () => {
    setPage(0);
    setLoading(true);
  };

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 grid grid-cols-1 items-end gap-4 md:grid-cols-2 xl:grid-cols-5">
          <div className="min-w-0">
            <label className={labelClass} htmlFor="pa-search">{t("search")}</label>
            <input
              id="pa-search"
              type="search"
              className={inputClass}
              placeholder={t("searchPlaceholder")}
              value={search}
              onChange={(e) => { setSearch(e.target.value); resetPage(); }}
            />
          </div>
          <div className="min-w-0">
            <label className={labelClass} htmlFor="pa-status">{t("status")}</label>
            <select
              id="pa-status"
              className={inputClass}
              value={status}
              onChange={(e) => { setStatus(e.target.value); resetPage(); }}
            >
              <option value="">{t("allStatuses")}</option>
              {STATUS_OPTIONS.map((s) => (
                <option key={s} value={s}>{STATUS_LABEL[s]}</option>
              ))}
            </select>
          </div>
          <div className="min-w-0">
            <label className={labelClass} htmlFor="pa-kind">{t("kind")}</label>
            <select
              id="pa-kind"
              className={inputClass}
              value={kind}
              onChange={(e) => { setKind(e.target.value); resetPage(); }}
            >
              <option value="">{t("allKinds")}</option>
              {PROSPECT_KINDS.map((k) => (
                <option key={k} value={k}>{KIND_LABEL[k]}</option>
              ))}
            </select>
          </div>
          <div className="min-w-0">
            <label className={labelClass} htmlFor="pa-min">{t("minScore")}</label>
            <input
              id="pa-min"
              type="number"
              min={0}
              max={100}
              className={inputClass}
              value={minScore}
              onChange={(e) => { setMinScore(e.target.value); resetPage(); }}
            />
          </div>
          <div>
            <button type="button" className={primaryBtn} onClick={() => setCreating(true)}>
              {t("newCandidate")}
            </button>
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
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
        ) : (
          <>
            {/* Telefon (md altı): kart görünümü; her kart aday ayrıntısına bağlanır. */}
            <ul className="space-y-3 md:hidden">
              {rows.map((r) => (
                <li key={r.id}>
                  <Link href={`/yonetim/potansiyel-adaylar/${r.id}`} className={CARD_LINK}>
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="wrap-break-word font-medium text-brand-500 dark:text-brand-400">{r.display_name}</p>
                        <p className="break-all text-theme-xs text-gray-500 dark:text-gray-400">{r.email ?? "-"}</p>
                      </div>
                      <span className={`shrink-0 text-base font-semibold ${scoreTextClass(r.total_score)}`}>
                        {r.total_score}
                      </span>
                    </div>
                    <div className="mt-3 flex flex-wrap items-center gap-2">
                      <Chip className={STATUS_CHIP[r.status] ?? STATUS_CHIP.suppressed}>
                        {STATUS_LABEL[r.status] ?? r.status}
                      </Chip>
                    </div>
                    <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm">
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.kind")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{KIND_LABEL[r.kind] ?? r.kind}</dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.source")}</dt>
                        <dd className="wrap-break-word text-gray-800 dark:text-white/90">{r.source_type ?? "-"}</dd>
                      </div>
                      <div className="col-span-2">
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.created")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">
                          {r.created_at ? formatDate(new Date(r.created_at)) : "-"}
                        </dd>
                      </div>
                    </dl>
                  </Link>
                </li>
              ))}
            </ul>

            {/* Tablet ve masaüstü: tablo; yatay kaydırma kapsayıcıda kalır. */}
            <div className="hidden overflow-x-auto md:block">
              <table className="min-w-full">
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th className={TH_STICKY}>{t("cols.name")}</th>
                    <th className={thClass}>{t("cols.email")}</th>
                    <th className={thClass}>{t("cols.kind")}</th>
                    <th className={thClass}>{t("cols.status")}</th>
                    <th className={thClass}>{t("cols.score")}</th>
                    <th className={thClass}>{t("cols.source")}</th>
                    <th className={thClass}>{t("cols.created")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {rows.map((r) => (
                    <tr key={r.id}>
                      <td className={TD_STICKY}>
                        <Link
                          href={`/yonetim/potansiyel-adaylar/${r.id}`}
                          className="inline-flex min-h-11 items-center font-medium text-brand-500 hover:text-brand-600 dark:text-brand-400"
                        >
                          {r.display_name}
                        </Link>
                      </td>
                      <td className={tdClass}>{r.email ?? "-"}</td>
                      <td className={`${tdClass} whitespace-nowrap`}>{KIND_LABEL[r.kind] ?? r.kind}</td>
                      <td className={tdClass}>
                        <Chip className={STATUS_CHIP[r.status] ?? STATUS_CHIP.suppressed}>
                          {STATUS_LABEL[r.status] ?? r.status}
                        </Chip>
                      </td>
                      <td className={tdClass}>
                        <span className={`text-base font-semibold ${scoreTextClass(r.total_score)}`}>{r.total_score}</span>
                      </td>
                      <td className={tdClass}>{r.source_type ?? "-"}</td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        {r.created_at ? formatDate(new Date(r.created_at)) : "-"}
                      </td>
                    </tr>
                  ))}
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

      {creating && (
        <ProspectFormModal
          onClose={() => setCreating(false)}
          onSaved={() => { setCreating(false); setLoading(true); setReloadKey((k) => k + 1); }}
        />
      )}
    </div>
  );
}
