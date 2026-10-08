"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { formatDate, formatTry } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthLead, GrowthLeadList, GrowthLeadStage } from "../types";
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
const STAGES: GrowthLeadStage[] = ["new", "contacted", "qualified", "trial", "decision", "won", "lost"];

const BADGE_BASE = "inline-flex items-center whitespace-nowrap rounded-full px-2.5 py-0.5 text-theme-xs font-medium";
const STAGE_CLASS: Record<GrowthLeadStage, string> = {
  new: "bg-blue-50 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400",
  contacted: "bg-cyan-50 text-cyan-700 dark:bg-cyan-500/15 dark:text-cyan-400",
  qualified: "bg-green-50 text-green-700 dark:bg-green-500/15 dark:text-green-400",
  trial: "bg-yellow-50 text-yellow-800 dark:bg-yellow-500/15 dark:text-yellow-400",
  decision: "bg-orange-50 text-orange-700 dark:bg-orange-500/15 dark:text-orange-400",
  won: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-500",
  lost: "bg-red-50 text-red-700 dark:bg-red-500/15 dark:text-red-400",
};

const leadNo = (id: string) => `#${id.slice(0, 8).toUpperCase()}`;

export default function SatisHattiManager() {
  const t = useTranslations("yonetim.satisHatti");
  const tNav = useTranslations("yonetim.shell.nav");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [stage, setStage] = useState<"" | GrowthLeadStage>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthLeadList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [createOpen, setCreateOpen] = useState(false);
  const [stageTarget, setStageTarget] = useState<GrowthLead | null>(null);

  const reload = () => setReloadKey((k) => k + 1);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_lead_listele", {
        p_arama: debounced.trim() || null,
        p_stage: stage || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthLeadList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, stage, page, reloadKey]);

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end justify-between gap-4">
          <div className="flex flex-1 flex-wrap items-end gap-4">
            <div className="min-w-60 flex-1">
              <label className={labelClass} htmlFor="s-search">{t("search")}</label>
              <input
                id="s-search"
                type="search"
                className={inputClass}
                placeholder={t("searchPlaceholder")}
                value={search}
                onChange={(e) => { setSearch(e.target.value); setPage(0); setLoading(true); }}
              />
            </div>
            <div className="min-w-40">
              <label className={labelClass} htmlFor="s-stage">{t("stage")}</label>
              <select
                id="s-stage"
                className={inputClass}
                value={stage}
                onChange={(e) => { setStage(e.target.value as "" | GrowthLeadStage); setPage(0); setLoading(true); }}
              >
                <option value="">{t("allStages")}</option>
                {STAGES.map((s) => (
                  <option key={s} value={s}>{t(`stages.${s}`)}</option>
                ))}
              </select>
            </div>
          </div>
          <button type="button" className={primaryBtn} onClick={() => setCreateOpen(true)}>
            {t("newLead")}
          </button>
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
                  <th className={thClass}>{t("cols.leadNo")}</th>
                  <th className={thClass}>{t("cols.titleContact")}</th>
                  <th className={thClass}>{t("cols.stage")}</th>
                  <th className={thClass}>{t("cols.value")}</th>
                  <th className={thClass}>{t("cols.prob")}</th>
                  <th className={thClass}>{t("cols.owner")}</th>
                  <th className={thClass}>{t("cols.followUp")}</th>
                  <th className={thClass}>{t("cols.customer")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((l) => (
                  <tr key={l.id}>
                    <td className={`${tdClass} whitespace-nowrap font-mono text-theme-xs`}>{leadNo(l.id)}</td>
                    <td className={tdClass}>
                      <div className="font-medium text-gray-800 dark:text-white/90">{l.parent_name}</div>
                      <div className="text-theme-xs text-gray-500 dark:text-gray-400">{l.email}</div>
                    </td>
                    <td className={tdClass}>
                      <button
                        type="button"
                        className={`${BADGE_BASE} ${STAGE_CLASS[l.stage] ?? ""}`}
                        onClick={() => setStageTarget(l)}
                        title={t("stageModal.title")}
                      >
                        {t(`stages.${l.stage}`)}
                      </button>
                    </td>
                    <td className={`${tdClass} whitespace-nowrap`}>{formatTry(l.value_estimate)}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{l.score}%</td>
                    <td className={tdClass}>{l.owner_name ?? "-"}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>
                      {l.next_action_at ? formatDate(new Date(l.next_action_at)) : "-"}
                    </td>
                    <td className={tdClass}>
                      {l.household_id ? (
                        <Link href={`/yonetim/musteri-360/${l.household_id}`} className={linkBtn}>
                          {tNav("musteri360")}
                        </Link>
                      ) : (
                        "-"
                      )}
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

      {createOpen && (
        <CreateModal
          onClose={() => setCreateOpen(false)}
          onSaved={() => { setCreateOpen(false); setLoading(true); reload(); }}
        />
      )}

      {stageTarget && (
        <StageModal
          key={stageTarget.id}
          lead={stageTarget}
          onClose={() => setStageTarget(null)}
          onSaved={() => { setStageTarget(null); setLoading(true); reload(); }}
        />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Yeni lead modalı — admin_lead_kaydet(p_data jsonb)
// ---------------------------------------------------------------------
function CreateModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.satisHatti");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [stage, setStage] = useState<GrowthLeadStage>("new");
  const [source, setSource] = useState("");
  const [value, setValue] = useState("0");
  const [prob, setProb] = useState("0");
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setSaving(true);
    setErr(null);
    const p_data = {
      parent_name: name.trim(),
      email: email.trim(),
      stage,
      source: source.trim() || null,
      value_estimate: Number(value) || 0,
      score: Math.min(100, Math.max(0, Math.round(Number(prob) || 0))),
    };
    const { error } = await createClient().rpc("admin_lead_kaydet", { p_data });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("form.title")}>
      <form className="space-y-4" onSubmit={save}>
        <div>
          <label className={labelClass} htmlFor="s-name">{t("form.contactName")}</label>
          <input
            id="s-name"
            type="text"
            className={inputClass}
            required
            minLength={2}
            maxLength={120}
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
        </div>
        <div>
          <label className={labelClass} htmlFor="s-email">{t("form.contactEmail")}</label>
          <input
            id="s-email"
            type="email"
            className={inputClass}
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label className={labelClass} htmlFor="s-new-stage">{t("form.stage")}</label>
            <select
              id="s-new-stage"
              className={inputClass}
              value={stage}
              onChange={(e) => setStage(e.target.value as GrowthLeadStage)}
            >
              {STAGES.map((s) => (
                <option key={s} value={s}>{t(`stages.${s}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="s-source">{t("form.source")}</label>
            <input
              id="s-source"
              type="text"
              className={inputClass}
              value={source}
              onChange={(e) => setSource(e.target.value)}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="s-value">{t("form.value")}</label>
            <input
              id="s-value"
              type="number"
              className={inputClass}
              min={0}
              step="0.01"
              value={value}
              onChange={(e) => setValue(e.target.value)}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="s-prob">{t("form.prob")}</label>
            <input
              id="s-prob"
              type="number"
              className={inputClass}
              min={0}
              max={100}
              step={1}
              value={prob}
              onChange={(e) => setProb(e.target.value)}
            />
          </div>
        </div>
        <ErrorNote message={err} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("form.cancel")}
          </button>
          <button type="submit" className={primaryBtn} disabled={saving}>
            {saving ? t("form.saving") : t("form.save")}
          </button>
        </div>
      </form>
    </ModalShell>
  );
}

// ---------------------------------------------------------------------
// Aşama değiştirme modalı — admin_lead_asama(p_lead_id, p_stage)
// ---------------------------------------------------------------------
function StageModal({ lead, onClose, onSaved }: { lead: GrowthLead; onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.satisHatti");
  const [stage, setStage] = useState<GrowthLeadStage>(lead.stage);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_lead_asama", {
      p_lead_id: lead.id,
      p_stage: stage,
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("stageModal.title")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="s-stage-new">{t("stage")}</label>
          <select
            id="s-stage-new"
            className={inputClass}
            value={stage}
            onChange={(e) => setStage(e.target.value as GrowthLeadStage)}
          >
            {STAGES.map((s) => (
              <option key={s} value={s}>{t(`stages.${s}`)}</option>
            ))}
          </select>
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
