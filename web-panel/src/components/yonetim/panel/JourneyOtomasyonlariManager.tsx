"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthJourney, GrowthJourneyList } from "../types";
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

const PAGE_SIZE = 25;
// Tablo kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";
const STATUSES = ["draft", "active", "paused"] as const;
type JourneyStatus = (typeof STATUSES)[number];
const STATUS_COLOR: Record<JourneyStatus, "light" | "success" | "warning"> = {
  draft: "light",
  active: "success",
  paused: "warning",
};

export default function JourneyOtomasyonlariManager() {
  const t = useTranslations("yonetim.journeyOtomasyonlari");
  const [durum, setDurum] = useState<"" | JourneyStatus>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthJourneyList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [stepsTarget, setStepsTarget] = useState<GrowthJourney | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_journey_listele", {
        p_status: durum || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthJourneyList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [durum, page, reloadKey]);

  const changeStatus = async (j: GrowthJourney, next: JourneyStatus) => {
    setBusyId(j.id);
    setActionError(null);
    setNotice(null);
    const { error: err } = await createClient().rpc("admin_journey_kaydet", {
      p_data: { id: j.id, status: next },
    });
    setBusyId(null);
    if (err) return setActionError(err.message);
    reload();
  };

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-col gap-4 sm:flex-row sm:flex-wrap sm:items-end">
          <div className="w-full sm:w-auto sm:min-w-40">
            <label className={labelClass} htmlFor="j-status">{t("filterStatus")}</label>
            <select
              id="j-status"
              className={inputClass}
              value={durum}
              onChange={(e) => { setDurum(e.target.value as "" | JourneyStatus); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allStatus")}</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{t(`statuses.${s}`)}</option>
              ))}
            </select>
          </div>
          <div className="sm:ms-auto">
            <button type="button" className={`${primaryBtn} w-full sm:w-auto`} onClick={() => setCreateOpen(true)}>
              {t("newJourney")}
            </button>
          </div>
        </div>

        <ErrorNote message={actionError} />
        {notice && (
          <p role="status" className="mb-4 rounded-lg bg-success-50 px-3 py-2 text-theme-sm text-success-700 dark:bg-success-500/15 dark:text-success-500">
            {notice}
          </p>
        )}

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
          <div className={`overflow-x-auto ${ILK_SUTUN_SABIT}`}>
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>{t("cols.name")}</th>
                  <th className={thClass}>{t("cols.status")}</th>
                  <th className={thClass}>{t("cols.trigger")}</th>
                  <th className={thClass}>{t("cols.segment")}</th>
                  <th className={thClass}>{t("cols.enrolled")}</th>
                  <th className={thClass}>{t("cols.created")}</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((j) => {
                  const status = (STATUSES as readonly string[]).includes(j.status)
                    ? (j.status as JourneyStatus)
                    : "draft";
                  const busy = busyId === j.id;
                  return (
                    <tr key={j.id}>
                      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{j.name}</td>
                      <td className={tdClass}>
                        <Badge size="sm" color={STATUS_COLOR[status]}>{t(`statuses.${status}`)}</Badge>
                      </td>
                      <td className={tdClass}>{j.trigger_type ?? "-"}</td>
                      <td className={tdClass}>{j.segment_id ? t("segmentLinked") : "-"}</td>
                      <td className={tdClass}>{j.enrolled_count}</td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        {j.created_at ? formatDate(new Date(j.created_at)) : "-"}
                      </td>
                      <td className={`${tdClass} whitespace-nowrap text-end`}>
                        <div className="flex flex-wrap justify-end gap-1">
                          {status === "active" ? (
                            <button type="button" className={`${linkBtn} inline-flex min-h-11 items-center`} disabled={busy} onClick={() => changeStatus(j, "paused")}>
                              {t("pause")}
                            </button>
                          ) : (
                            <button type="button" className={`${linkBtn} inline-flex min-h-11 items-center`} disabled={busy} onClick={() => changeStatus(j, "active")}>
                              {t("activate")}
                            </button>
                          )}
                          <button
                            type="button"
                            className={`${linkBtn} inline-flex min-h-11 items-center`}
                            onClick={() => { setNotice(null); setStepsTarget(j); }}
                          >
                            {t("stepsButton")}
                          </button>
                        </div>
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

      {createOpen && (
        <CreateJourneyModal
          onClose={() => setCreateOpen(false)}
          onSaved={() => { setCreateOpen(false); reload(); }}
        />
      )}

      {stepsTarget && (
        <JourneyStepsModal
          key={stepsTarget.id}
          journey={stepsTarget}
          onClose={() => setStepsTarget(null)}
          onSaved={() => { setStepsTarget(null); setNotice(t("steps.saved")); }}
        />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Yeni journey modalı
// ---------------------------------------------------------------------
function CreateJourneyModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.journeyOtomasyonlari");
  const [name, setName] = useState("");
  const [trigger, setTrigger] = useState("");
  const [status, setStatus] = useState<JourneyStatus>("draft");
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    const ad = name.trim();
    if (ad.length < 1 || ad.length > 120) return setErr(t("form.errName"));
    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_journey_kaydet", {
      p_data: { name: ad, trigger_type: trigger.trim() || null, status },
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("form.title")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="j-name">{t("form.name")}</label>
          <input id="j-name" type="text" className={inputClass} value={name} onChange={(e) => setName(e.target.value)} />
        </div>
        <div>
          <label className={labelClass} htmlFor="j-trigger">{t("form.trigger")}</label>
          <input id="j-trigger" type="text" className={inputClass} value={trigger} onChange={(e) => setTrigger(e.target.value)} />
        </div>
        <div>
          <label className={labelClass} htmlFor="j-new-status">{t("form.status")}</label>
          <select
            id="j-new-status"
            className={inputClass}
            value={status}
            onChange={(e) => setStatus(e.target.value as JourneyStatus)}
          >
            {STATUSES.map((s) => (
              <option key={s} value={s}>{t(`statuses.${s}`)}</option>
            ))}
          </select>
        </div>
        <ErrorNote message={err} />
        <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("form.cancel")}
          </button>
          <button type="button" className={primaryBtn} disabled={saving} onClick={save}>
            {saving ? t("form.saving") : t("form.save")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}

// ---------------------------------------------------------------------
// Journey adım editörü (P7)
// Sunucu sözleşmesi: admin_journey_adim_listele / admin_journey_adim_kaydet.
// Kaydetme tüm adımları değiştirir; aktif veya açık kaydı olan journey reddedilir.
// ---------------------------------------------------------------------
const STEP_TYPES = ["trigger", "delay", "email", "push", "in_app", "sms", "whatsapp"] as const;
// Motor bu kanalları henüz göndermiyor (pazarlama SMS/WhatsApp hukuk onayı bekliyor).
const CLOSED_CHANNELS: readonly string[] = ["sms", "whatsapp"];
const MAX_STEPS = 20;
const LABEL_MAX = 120;
const SAAT_MAX = 8760;
const LINK_TOUCH = `${linkBtn} inline-flex min-h-11 items-center px-2`;
const DANGER_TOUCH =
  "inline-flex min-h-11 items-center px-2 text-theme-sm font-medium text-error-600 hover:text-error-700 disabled:opacity-50 dark:text-error-500";
const WARN_NOTE =
  "rounded-lg bg-warning-50 px-3 py-2 text-theme-sm text-warning-700 dark:bg-warning-500/15 dark:text-warning-500";

/** admin_journey_adim_listele() satır şekli (growth_journey_steps). */
interface GrowthJourneyStep {
  id: string;
  journey_id: string;
  position: number;
  step_type: string;
  label: string;
  detail: string | null;
  config: Record<string, unknown> | null;
}

/** Modalda düzenlenen adım. key yalnızca React listesi içindir. */
interface StepDraft {
  key: number;
  step_type: string;
  label: string;
  detail: string | null;
  config: Record<string, unknown>;
  saat: string; // bekleme adımı için metin girdisi
}

function toDraft(s: GrowthJourneyStep, key: number): StepDraft {
  const config = s.config && typeof s.config === "object" ? s.config : {};
  return {
    key,
    step_type: s.step_type,
    label: s.label ?? "",
    detail: s.detail ?? null,
    config,
    saat: typeof config.saat === "number" ? String(config.saat) : "",
  };
}

function JourneyStepsModal({
  journey,
  onClose,
  onSaved,
}: {
  journey: GrowthJourney;
  onClose: () => void;
  onSaved: () => void;
}) {
  const t = useTranslations("yonetim.journeyOtomasyonlari");
  const readOnly = journey.status === "active";
  const seq = useRef(0);

  const [steps, setSteps] = useState<StepDraft[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: rpcError } = await createClient().rpc("admin_journey_adim_listele", {
        p_journey_id: journey.id,
      });
      if (cancelled) return;
      if (rpcError) {
        setLoadError(rpcError.message);
      } else {
        const rows = (Array.isArray(data) ? (data as GrowthJourneyStep[]) : [])
          .slice()
          .sort((a, b) => a.position - b.position);
        setSteps(rows.map((r) => toDraft(r, ++seq.current)));
        setLoadError(null);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [journey.id, reloadKey]);

  const update = (key: number, patch: Partial<StepDraft>) =>
    setSteps((prev) => prev.map((s) => (s.key === key ? { ...s, ...patch } : s)));

  const addStep = () => {
    const key = ++seq.current;
    setErr(null);
    setSteps((prev) => [
      ...prev,
      { key, step_type: "email", label: "", detail: null, config: {}, saat: "" },
    ]);
  };

  const removeStep = (key: number) => setSteps((prev) => prev.filter((s) => s.key !== key));

  const moveStep = (index: number, dir: -1 | 1) =>
    setSteps((prev) => {
      const target = index + dir;
      if (target < 0 || target >= prev.length) return prev;
      const next = prev.slice();
      const moved = next[index];
      next[index] = next[target];
      next[target] = moved;
      return next;
    });

  const save = async () => {
    const payload: Record<string, unknown>[] = [];
    for (const s of steps) {
      const label = s.label.trim();
      if ([...label].length < 1 || [...label].length > LABEL_MAX) return setErr(t("steps.errLabel"));
      const config: Record<string, unknown> = { ...s.config };
      if (s.step_type === "delay") {
        const saat = s.saat.trim();
        if (!/^\d+$/.test(saat) || Number(saat) > SAAT_MAX) return setErr(t("steps.errSaat"));
        config.saat = Number(saat);
      } else {
        delete config.saat;
      }
      payload.push({ step_type: s.step_type, label, detail: s.detail, config });
    }

    setSaving(true);
    setErr(null);
    const { error: rpcError } = await createClient().rpc("admin_journey_adim_kaydet", {
      p_journey_id: journey.id,
      p_adimlar: payload,
    });
    setSaving(false);
    if (rpcError) return setErr(rpcError.message);
    onSaved();
  };

  const editable = !readOnly && !loading && !loadError;

  return (
    <ModalShell isOpen onClose={onClose} title={t("steps.titleFor", { name: journey.name })}>
      <div className="space-y-4">
        {readOnly ? (
          <p role="note" className={WARN_NOTE}>{t("steps.activeNote")}</p>
        ) : (
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("steps.editHint")}</p>
        )}

        {loading ? (
          <p className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">{t("steps.loading")}</p>
        ) : loadError ? (
          <div className="py-6 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{loadError}</p>
            <button
              type="button"
              className={primaryBtn}
              onClick={() => { setLoading(true); setLoadError(null); setReloadKey((k) => k + 1); }}
            >
              {t("retry")}
            </button>
          </div>
        ) : steps.length === 0 ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("steps.empty")}</p>
        ) : (
          <ol className="space-y-3">
            {steps.map((s, i) => {
              const id = `st-${s.key}`;
              const known = (STEP_TYPES as readonly string[]).includes(s.step_type);
              const isDelay = s.step_type === "delay";
              const isClosed = CLOSED_CHANNELS.includes(s.step_type);
              return (
                <li key={s.key} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                  <p className="mb-3 text-sm font-semibold text-gray-800 dark:text-white/90">
                    {t("steps.stepNo", { no: i + 1 })}
                  </p>
                  <div className="grid gap-3 sm:grid-cols-2">
                    <div>
                      <label className={labelClass} htmlFor={`${id}-tur`}>{t("steps.type")}</label>
                      <select
                        id={`${id}-tur`}
                        className={inputClass}
                        value={s.step_type}
                        disabled={!editable}
                        onChange={(e) => update(s.key, { step_type: e.target.value })}
                      >
                        {STEP_TYPES.map((tp) => (
                          <option key={tp} value={tp}>{t(`steps.stepTypes.${tp}`)}</option>
                        ))}
                        {!known && <option value={s.step_type}>{s.step_type}</option>}
                      </select>
                    </div>
                    <div>
                      <label className={labelClass} htmlFor={`${id}-etiket`}>{t("steps.label")}</label>
                      <input
                        id={`${id}-etiket`}
                        type="text"
                        className={inputClass}
                        value={s.label}
                        maxLength={LABEL_MAX}
                        disabled={!editable}
                        onChange={(e) => update(s.key, { label: e.target.value })}
                      />
                    </div>
                    {isDelay && (
                      <div>
                        <label className={labelClass} htmlFor={`${id}-saat`}>{t("steps.hours")}</label>
                        <input
                          id={`${id}-saat`}
                          type="number"
                          inputMode="numeric"
                          min={0}
                          max={SAAT_MAX}
                          step={1}
                          className={inputClass}
                          value={s.saat}
                          disabled={!editable}
                          onChange={(e) => update(s.key, { saat: e.target.value })}
                        />
                      </div>
                    )}
                  </div>
                  {isClosed && <p className={`mt-3 ${WARN_NOTE}`}>{t("steps.channelClosed")}</p>}
                  {editable && (
                    <div className="mt-3 flex flex-wrap gap-1">
                      <button type="button" className={LINK_TOUCH} disabled={i === 0} onClick={() => moveStep(i, -1)}>
                        {t("steps.moveUp")}
                      </button>
                      <button type="button" className={LINK_TOUCH} disabled={i === steps.length - 1} onClick={() => moveStep(i, 1)}>
                        {t("steps.moveDown")}
                      </button>
                      <button type="button" className={DANGER_TOUCH} onClick={() => removeStep(s.key)}>
                        {t("steps.remove")}
                      </button>
                    </div>
                  )}
                </li>
              );
            })}
          </ol>
        )}

        {editable && (
          <div className="space-y-2">
            <button
              type="button"
              className={`${outlineBtn} w-full`}
              disabled={steps.length >= MAX_STEPS}
              onClick={addStep}
            >
              {t("steps.addStep")}
            </button>
            {steps.length >= MAX_STEPS && (
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("steps.maxReached")}</p>
            )}
          </div>
        )}

        <ErrorNote message={err} />
        <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {readOnly ? t("steps.close") : t("form.cancel")}
          </button>
          {editable && (
            <button type="button" className={primaryBtn} disabled={saving} onClick={save}>
              {saving ? t("form.saving") : t("form.save")}
            </button>
          )}
        </div>
      </div>
    </ModalShell>
  );
}
