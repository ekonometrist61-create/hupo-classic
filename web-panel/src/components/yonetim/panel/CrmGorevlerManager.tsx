"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { formatDateTime } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthTask, GrowthTaskList } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import {
  cardClass,
  inputClass,
  labelClass,
  outlineBtn,
  primaryBtn,
  tdClass,
  thClass,
} from "./styles";
import useDebounced from "./useDebounced";

const PAGE_SIZE = 25;
const TASK_TYPES = ["call", "email", "meeting", "follow_up", "demo", "proposal", "other"] as const;
const STATUSES = ["open", "in_progress", "done", "cancelled", "deferred"] as const;
const PRIORITIES = ["low", "normal", "high", "urgent"] as const;

const STATUS_CLASS: Record<string, string> = {
  open: "bg-blue-50 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400",
  in_progress: "bg-yellow-50 text-yellow-700 dark:bg-yellow-500/15 dark:text-yellow-400",
  done: "bg-success-50 text-success-600 dark:bg-success-500/15 dark:text-success-500",
  cancelled: "bg-gray-100 text-gray-600 dark:bg-white/5 dark:text-gray-400",
  deferred: "bg-orange-50 text-orange-700 dark:bg-orange-500/15 dark:text-orange-400",
};

const PRIORITY_CLASS: Record<string, string> = {
  low: "bg-gray-100 text-gray-600 dark:bg-white/5 dark:text-gray-400",
  normal: "bg-blue-50 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400",
  high: "bg-orange-50 text-orange-700 dark:bg-orange-500/15 dark:text-orange-400",
  urgent: "bg-error-50 text-error-600 dark:bg-error-500/15 dark:text-error-500",
};

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function Pill({ className, children }: { className: string; children: React.ReactNode }) {
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium whitespace-nowrap ${className}`}>
      {children}
    </span>
  );
}

export default function CrmGorevlerManager() {
  const t = useTranslations("yonetim.crmGorevler");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [status, setStatus] = useState("");
  const [priority, setPriority] = useState("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);
  const [creating, setCreating] = useState(false);

  const [list, setList] = useState<GrowthTaskList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_crm_gorev_listele", {
        p_household_id: null,
        p_lead_id: null,
        p_status: status || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthTaskList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [status, page, reloadKey]);

  // Arama ve öncelik filtresi RPC'de parametre olarak yok; yüklenen sayfa üzerinde uygulanır.
  const q = debounced.trim().toLowerCase();
  const rows = (list?.rows ?? []).filter(
    (r) =>
      (!priority || r.priority === priority) &&
      (!q || r.title.toLowerCase().includes(q) || (r.task_no ?? "").toLowerCase().includes(q)),
  );
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + (list?.rows.length ?? 0));

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-60 flex-1">
            <label className={labelClass} htmlFor="g-search">{t("search")}</label>
            <input
              id="g-search"
              type="search"
              className={inputClass}
              placeholder={t("searchPlaceholder")}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="g-status">{t("cols.status")}</label>
            <select
              id="g-status"
              className={inputClass}
              value={status}
              onChange={(e) => { setStatus(e.target.value); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allStatus")}</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{t(`statuses.${s}`)}</option>
              ))}
            </select>
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="g-priority">{t("cols.priority")}</label>
            <select
              id="g-priority"
              className={inputClass}
              value={priority}
              onChange={(e) => setPriority(e.target.value)}
            >
              <option value="">{t("allPriority")}</option>
              {PRIORITIES.map((p) => (
                <option key={p} value={p}>{t(`priorities.${p}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <button type="button" className={primaryBtn} onClick={() => setCreating(true)}>
              {t("newTask")}
            </button>
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
                  <th className={thClass}>{t("cols.taskNo")}</th>
                  <th className={thClass}>{t("cols.title")}</th>
                  <th className={thClass}>{t("cols.type")}</th>
                  <th className={thClass}>{t("cols.status")}</th>
                  <th className={thClass}>{t("cols.priority")}</th>
                  <th className={thClass}>{t("cols.dueAt")}</th>
                  <th className={thClass}>{t("cols.assignee")}</th>
                  <th className={thClass}>{t("cols.customer")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((r) => (
                  <TaskRow key={r.id} task={r} />
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

      {creating && (
        <TaskModal
          onClose={() => setCreating(false)}
          onSaved={() => { setCreating(false); reload(); }}
        />
      )}
    </div>
  );
}

function TaskRow({ task: r }: { task: GrowthTask }) {
  const t = useTranslations("yonetim.crmGorevler");
  const customer = r.household_id ?? r.lead_id;
  return (
    <tr>
      <td className={`${tdClass} whitespace-nowrap font-mono`}>{r.task_no ?? "-"}</td>
      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{r.title}</td>
      <td className={`${tdClass} whitespace-nowrap`}>{t(`types.${r.task_type}`)}</td>
      <td className={tdClass}>
        <Pill className={STATUS_CLASS[r.status] ?? "bg-gray-100 text-gray-600"}>
          {t(`statuses.${r.status}`)}
        </Pill>
      </td>
      <td className={tdClass}>
        <Pill className={PRIORITY_CLASS[r.priority] ?? "bg-gray-100 text-gray-600"}>
          {t(`priorities.${r.priority}`)}
        </Pill>
      </td>
      <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(r.due_at)}</td>
      <td className={`${tdClass} whitespace-nowrap`}>{r.assignee_name ?? "-"}</td>
      <td className={`${tdClass} whitespace-nowrap font-mono`} title={customer ?? undefined}>
        {customer ? customer.slice(0, 8) : "-"}
      </td>
    </tr>
  );
}

// ---------------------------------------------------------------------
// Yeni görev modalı — admin_crm_gorev_kaydet (upsert) ile kaydeder
// ---------------------------------------------------------------------
function TaskModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.crmGorevler");
  const [title, setTitle] = useState("");
  const [taskType, setTaskType] = useState<string>("follow_up");
  const [status, setStatus] = useState<string>("open");
  const [priority, setPriority] = useState<string>("normal");
  const [dueAt, setDueAt] = useState("");
  const [householdId, setHouseholdId] = useState("");
  const [leadId, setLeadId] = useState("");
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    const trimmed = title.trim();
    const hh = householdId.trim();
    const ld = leadId.trim();
    if (!trimmed || trimmed.length > 200) return setErr(t("form.errTitle"));
    if (!dueAt) return setErr(t("form.errDue"));
    if ((hh && !UUID_RE.test(hh)) || (ld && !UUID_RE.test(ld))) return setErr(t("form.errUuid"));

    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_crm_gorev_kaydet", {
      p_data: {
        title: trimmed,
        task_type: taskType,
        status,
        priority,
        due_at: new Date(dueAt).toISOString(),
        household_id: hh || null,
        lead_id: ld || null,
      },
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("form.title")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="g-f-title">{t("form.fieldTitle")}</label>
          <input
            id="g-f-title"
            type="text"
            className={inputClass}
            maxLength={200}
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <label className={labelClass} htmlFor="g-f-type">{t("form.type")}</label>
            <select id="g-f-type" className={inputClass} value={taskType} onChange={(e) => setTaskType(e.target.value)}>
              {TASK_TYPES.map((v) => (
                <option key={v} value={v}>{t(`types.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="g-f-status">{t("form.status")}</label>
            <select id="g-f-status" className={inputClass} value={status} onChange={(e) => setStatus(e.target.value)}>
              {STATUSES.map((v) => (
                <option key={v} value={v}>{t(`statuses.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="g-f-priority">{t("form.priority")}</label>
            <select id="g-f-priority" className={inputClass} value={priority} onChange={(e) => setPriority(e.target.value)}>
              {PRIORITIES.map((v) => (
                <option key={v} value={v}>{t(`priorities.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="g-f-due">{t("form.dueAt")}</label>
            <input
              id="g-f-due"
              type="datetime-local"
              className={inputClass}
              value={dueAt}
              onChange={(e) => setDueAt(e.target.value)}
            />
          </div>
        </div>
        <div>
          <label className={labelClass} htmlFor="g-f-hh">{t("form.householdId")}</label>
          <input
            id="g-f-hh"
            type="text"
            className={inputClass}
            placeholder="00000000-0000-0000-0000-000000000000"
            value={householdId}
            onChange={(e) => setHouseholdId(e.target.value)}
          />
        </div>
        <div>
          <label className={labelClass} htmlFor="g-f-lead">{t("form.leadId")}</label>
          <input
            id="g-f-lead"
            type="text"
            className={inputClass}
            placeholder="00000000-0000-0000-0000-000000000000"
            value={leadId}
            onChange={(e) => setLeadId(e.target.value)}
          />
        </div>
        <ErrorNote message={err} />
        <div className="flex justify-end gap-3">
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
