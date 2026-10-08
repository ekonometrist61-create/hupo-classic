"use client";

import { useEffect, useState } from "react";

import { Link } from "@/i18n/navigation";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthProspect, GrowthProspectList } from "../types";
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

export default function PotansiyelAdaylarManager() {
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
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-60 flex-1">
            <label className={labelClass} htmlFor="pa-search">Ara</label>
            <input
              id="pa-search"
              type="search"
              className={inputClass}
              placeholder="Ad, e-posta veya telefon"
              value={search}
              onChange={(e) => { setSearch(e.target.value); resetPage(); }}
            />
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="pa-status">Durum</label>
            <select
              id="pa-status"
              className={inputClass}
              value={status}
              onChange={(e) => { setStatus(e.target.value); resetPage(); }}
            >
              <option value="">Tüm durumlar</option>
              {STATUS_OPTIONS.map((s) => (
                <option key={s} value={s}>{STATUS_LABEL[s]}</option>
              ))}
            </select>
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="pa-kind">Tür</label>
            <select
              id="pa-kind"
              className={inputClass}
              value={kind}
              onChange={(e) => { setKind(e.target.value); resetPage(); }}
            >
              <option value="">Tüm türler</option>
              {PROSPECT_KINDS.map((k) => (
                <option key={k} value={k}>{KIND_LABEL[k]}</option>
              ))}
            </select>
          </div>
          <div className="w-36">
            <label className={labelClass} htmlFor="pa-min">Minimum skor</label>
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
              Yeni aday ekle
            </button>
          </div>
        </div>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">Yükleniyor...</p>
        ) : error ? (
          <div className="py-8 text-center">
            <ErrorNote message={error} />
            <button type="button" className={`${primaryBtn} mt-3`} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
              Tekrar dene
            </button>
          </div>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">Kayıt bulunamadı.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>Ad Soyad</th>
                  <th className={thClass}>E-posta</th>
                  <th className={thClass}>Tür</th>
                  <th className={thClass}>Durum</th>
                  <th className={thClass}>Toplam Skor</th>
                  <th className={thClass}>Kaynak</th>
                  <th className={thClass}>Oluşturma Tarihi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((r) => (
                  <tr key={r.id}>
                    <td className={tdClass}>
                      <Link href={`/yonetim/potansiyel-adaylar/${r.id}`} className="font-medium text-brand-500 hover:text-brand-600 dark:text-brand-400">
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
        )}

        {!loading && !error && total > 0 && (
          <Pager
            page={page}
            pageSize={PAGE_SIZE}
            total={total}
            onPage={(p) => { setLoading(true); setPage(p); }}
            labels={{ prev: "Önceki", next: "Sonraki", summary: `${start}–${end} / ${total}` }}
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
