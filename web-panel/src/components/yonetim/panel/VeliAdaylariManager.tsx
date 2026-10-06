"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { LeadStage, Paged, VeliAday, VeliAdayDetay } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import {
  cardClass,
  inputClass,
  labelClass,
  linkBtn,
  outlineBtn,
  primaryBtn,
  tdClass,
  thClass,
} from "./styles";
import useDebounced from "./useDebounced";

const PAGE_SIZE = 25;
const STAGES: LeadStage[] = ["yeni", "iletisim", "deneme", "musteri", "kapandi"];
const STAGE_COLOR: Record<LeadStage, "primary" | "info" | "warning" | "success" | "light"> = {
  yeni: "primary",
  iletisim: "info",
  deneme: "warning",
  musteri: "success",
  kapandi: "light",
};

export default function VeliAdaylariManager() {
  const t = useTranslations("yonetim.veliAdaylari");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [asama, setAsama] = useState<"" | LeadStage>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<Paged<VeliAday> | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [stageTarget, setStageTarget] = useState<VeliAday | null>(null);
  const [detailTarget, setDetailTarget] = useState<VeliAday | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_list_veli_adaylari", {
        p_asama: asama || null,
        p_arama: debounced.trim() || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as Paged<VeliAday>);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, asama, page, reloadKey]);

  const rows = list?.satirlar ?? [];
  const total = list?.toplam ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-60 flex-1">
            <label className={labelClass} htmlFor="l-search">{t("search")}</label>
            <input
              id="l-search"
              type="search"
              className={inputClass}
              placeholder={t("searchPlaceholder")}
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(0); setLoading(true); }}
            />
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="l-stage">{t("stage")}</label>
            <select
              id="l-stage"
              className={inputClass}
              value={asama}
              onChange={(e) => { setAsama(e.target.value as "" | LeadStage); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allStages")}</option>
              {STAGES.map((s) => (
                <option key={s} value={s}>{t(`stages.${s}`)}</option>
              ))}
            </select>
          </div>
        </div>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{error}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); reload(); }}>
              {t("retry")}
            </button>
          </div>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>{t("cols.name")}</th>
                  <th className={thClass}>{t("cols.email")}</th>
                  <th className={thClass}>{t("cols.phone")}</th>
                  <th className={thClass}>{t("cols.source")}</th>
                  <th className={thClass}>{t("cols.stage")}</th>
                  <th className={thClass}>{t("cols.consent")}</th>
                  <th className={thClass}>{t("cols.created")}</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((a) => (
                  <tr key={a.id}>
                    <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{a.ad}</td>
                    <td className={tdClass}>{a.email}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{a.telefon ?? "-"}</td>
                    <td className={tdClass}>{a.kaynak}</td>
                    <td className={tdClass}>
                      <Badge size="sm" color={STAGE_COLOR[a.asama] ?? "light"}>{t(`stages.${a.asama}`)}</Badge>
                    </td>
                    <td className={tdClass}>
                      <Badge size="sm" color={a.pazarlama_izni ? "success" : "light"}>
                        {a.pazarlama_izni ? t("consentYes") : t("consentNo")}
                      </Badge>
                    </td>
                    <td className={`${tdClass} whitespace-nowrap`}>
                      {a.created_at ? formatDate(new Date(a.created_at)) : "-"}
                    </td>
                    <td className={`${tdClass} whitespace-nowrap text-end`}>
                      <span className="flex justify-end gap-3">
                        <button type="button" className={linkBtn} onClick={() => setDetailTarget(a)}>
                          {t("detail")}
                        </button>
                        <button type="button" className={linkBtn} onClick={() => setStageTarget(a)}>
                          {t("changeStage")}
                        </button>
                      </span>
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
            labels={{ prev: t("pager.prev"), next: t("pager.next"), summary: `${start}–${end} / ${total}` }}
          />
        )}
      </section>

      {stageTarget && (
        <StageModal
          key={stageTarget.id}
          lead={stageTarget}
          onClose={() => setStageTarget(null)}
          onSaved={() => { setStageTarget(null); reload(); }}
        />
      )}

      {detailTarget && (
        <DetailModal key={detailTarget.id} lead={detailTarget} onClose={() => setDetailTarget(null)} />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Aşama değiştirme modalı
// ---------------------------------------------------------------------
function StageModal({ lead, onClose, onSaved }: { lead: VeliAday; onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.veliAdaylari");
  const [asama, setAsama] = useState<LeadStage>(lead.asama);
  const [not, setNot] = useState("");
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_veli_adayi_asama", {
      p_id: lead.id,
      p_asama: asama,
      p_not: not.trim() || null,
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("stageModal.title")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="l-stage-new">{t("stageModal.stage")}</label>
          <select
            id="l-stage-new"
            className={inputClass}
            value={asama}
            onChange={(e) => setAsama(e.target.value as LeadStage)}
          >
            {STAGES.map((s) => (
              <option key={s} value={s}>{t(`stages.${s}`)}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="l-note">{t("stageModal.note")}</label>
          <input
            id="l-note"
            type="text"
            className={inputClass}
            placeholder={t("stageModal.notePlaceholder")}
            value={not}
            onChange={(e) => setNot(e.target.value)}
          />
        </div>
        <ErrorNote message={err} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("stageModal.cancel")}
          </button>
          <button type="button" className={primaryBtn} disabled={saving} onClick={save}>
            {saving ? t("stageModal.saving") : t("stageModal.save")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}

// ---------------------------------------------------------------------
// Ayrıntı modalı — aday alanları + olay zaman çizelgesi (outbox)
// ---------------------------------------------------------------------
function DetailModal({ lead, onClose }: { lead: VeliAday; onClose: () => void }) {
  const t = useTranslations("yonetim.veliAdaylari");
  const [detay, setDetay] = useState<VeliAdayDetay | null>(null);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_veli_adayi_detay", { p_id: lead.id });
      if (cancelled) return;
      if (error) setErr(error.message);
      else setDetay(data as VeliAdayDetay);
      setLoading(false);
    };
    void run();
    return () => { cancelled = true; };
  }, [lead.id]);

  return (
    <ModalShell isOpen onClose={onClose} title={t("detailModal.title")}>
      <div className="space-y-4">
        <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-2 text-theme-sm">
          <dt className="text-gray-500 dark:text-gray-400">{t("cols.name")}</dt>
          <dd className="text-gray-800 dark:text-white/90">{lead.ad}</dd>
          <dt className="text-gray-500 dark:text-gray-400">{t("cols.email")}</dt>
          <dd className="text-gray-800 dark:text-white/90">{lead.email}</dd>
          <dt className="text-gray-500 dark:text-gray-400">{t("cols.phone")}</dt>
          <dd className="text-gray-800 dark:text-white/90">{lead.telefon ?? "-"}</dd>
          <dt className="text-gray-500 dark:text-gray-400">{t("cols.source")}</dt>
          <dd className="text-gray-800 dark:text-white/90">{lead.kaynak}</dd>
          <dt className="text-gray-500 dark:text-gray-400">{t("cols.stage")}</dt>
          <dd><Badge size="sm" color={STAGE_COLOR[lead.asama] ?? "light"}>{t(`stages.${lead.asama}`)}</Badge></dd>
          <dt className="text-gray-500 dark:text-gray-400">{t("cols.consent")}</dt>
          <dd className="text-gray-800 dark:text-white/90">
            {lead.pazarlama_izni ? t("consentYes") : t("consentNo")}
            {lead.pazarlama_izni && lead.izin_at ? ` · ${t("detailModal.consentAt")}: ${formatDate(new Date(lead.izin_at))}` : ""}
          </dd>
        </dl>

        <div>
          <p className="mb-2 text-theme-sm font-medium text-gray-700 dark:text-gray-300">{t("detailModal.timeline")}</p>
          {loading ? (
            <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
          ) : err ? (
            <ErrorNote message={err} />
          ) : !detay || detay.olaylar.length === 0 ? (
            <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("detailModal.noEvents")}</p>
          ) : (
            <ul className="space-y-2">
              {detay.olaylar.map((o, i) => (
                <li key={i} className="flex items-center justify-between rounded-lg bg-gray-50 px-3 py-2 text-theme-xs dark:bg-white/5">
                  <span className="font-mono text-gray-700 dark:text-gray-300">{o.tur}</span>
                  <span className="text-gray-500 dark:text-gray-400">{formatDate(new Date(o.created_at))}</span>
                </li>
              ))}
            </ul>
          )}
        </div>

        <div className="flex justify-end">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("detailModal.close")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}
