"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { Link } from "@/i18n/navigation";
import { formatDateTime } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type {
  GrowthTicket,
  GrowthTicketCategory,
  GrowthTicketList,
  GrowthTicketPriority,
  GrowthTicketStatus,
} from "../types";
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
// Veritabanı enum'larıyla birebir (growth_ticket_status / growth_ticket_priority).
const STATUSES: GrowthTicketStatus[] = ["new", "open", "waiting", "resolved"];
const PRIORITIES: GrowthTicketPriority[] = ["low", "normal", "high", "critical"];
// growth_support_tickets.category check kısıtıyla birebir.
const CATEGORIES: GrowthTicketCategory[] = ["billing", "technical", "account", "content", "subscription", "other"];

type BadgeTone = "primary" | "info" | "warning" | "success" | "error" | "light";
const STATUS_COLOR: Record<GrowthTicketStatus, BadgeTone> = {
  new: "primary",
  open: "info",
  waiting: "warning",
  resolved: "success",
};
const PRIORITY_COLOR: Record<GrowthTicketPriority, BadgeTone> = {
  low: "light",
  normal: "info",
  high: "warning",
  critical: "error",
};

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export default function DestekMasasiManager() {
  const t = useTranslations("yonetim.destekMasasi");
  const [status, setStatus] = useState<"" | GrowthTicketStatus>("");
  const [priority, setPriority] = useState<"" | GrowthTicketPriority>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthTicketList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [newOpen, setNewOpen] = useState(false);
  const [statusTarget, setStatusTarget] = useState<GrowthTicket | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_destek_listele", {
        p_household_id: null,
        p_status: status || null,
        p_priority: priority || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthTicketList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [status, priority, page, reloadKey]);

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-40">
            <label className={labelClass} htmlFor="d-status">{t("cols.status")}</label>
            <select
              id="d-status"
              className={inputClass}
              value={status}
              onChange={(e) => { setStatus(e.target.value as "" | GrowthTicketStatus); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allStatus")}</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{t(`statuses.${s}`)}</option>
              ))}
            </select>
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="d-priority">{t("cols.priority")}</label>
            <select
              id="d-priority"
              className={inputClass}
              value={priority}
              onChange={(e) => { setPriority(e.target.value as "" | GrowthTicketPriority); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allPriority")}</option>
              {PRIORITIES.map((p) => (
                <option key={p} value={p}>{t(`priorities.${p}`)}</option>
              ))}
            </select>
          </div>
          <div className="ms-auto">
            <button type="button" className={primaryBtn} onClick={() => setNewOpen(true)}>
              {t("newTicket")}
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
                  <th className={thClass}>{t("cols.ticketNo")}</th>
                  <th className={thClass}>{t("cols.subject")}</th>
                  <th className={thClass}>{t("cols.category")}</th>
                  <th className={thClass}>{t("cols.status")}</th>
                  <th className={thClass}>{t("cols.priority")}</th>
                  <th className={thClass}>{t("cols.assignee")}</th>
                  <th className={thClass}>{t("cols.created")}</th>
                  <th className={thClass}>{t("cols.customer")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((k) => (
                  <tr key={k.id}>
                    <td className={`${tdClass} whitespace-nowrap font-mono text-theme-xs`}>{k.id}</td>
                    <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{k.subject}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{t(`categories.${k.category}`)}</td>
                    <td className={tdClass}>
                      <button
                        type="button"
                        className="rounded-full focus:outline-hidden focus:ring-3 focus:ring-brand-500/20"
                        aria-label={t("statusModal.title")}
                        onClick={() => setStatusTarget(k)}
                      >
                        <Badge size="sm" color={STATUS_COLOR[k.status] ?? "light"}>{t(`statuses.${k.status}`)}</Badge>
                      </button>
                    </td>
                    <td className={tdClass}>
                      <Badge size="sm" color={PRIORITY_COLOR[k.priority] ?? "light"}>{t(`priorities.${k.priority}`)}</Badge>
                    </td>
                    <td className={tdClass}>{k.owner_name ?? "-"}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(k.created_at)}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>
                      {k.household_id ? (
                        <Link href={`/yonetim/musteri-360/${k.household_id}`} className={linkBtn}>
                          {t("customerLink")}
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

      {newOpen && (
        <NewTicketModal
          onClose={() => setNewOpen(false)}
          onSaved={() => { setNewOpen(false); setLoading(true); reload(); }}
        />
      )}

      {statusTarget && (
        <StatusModal
          key={statusTarget.id}
          ticket={statusTarget}
          onClose={() => setStatusTarget(null)}
          onSaved={() => { setStatusTarget(null); setLoading(true); reload(); }}
        />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Yeni talep modalı — admin_destek_kaydet (yeni kayıt)
// ---------------------------------------------------------------------
function NewTicketModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.destekMasasi");
  const [subject, setSubject] = useState("");
  const [category, setCategory] = useState<GrowthTicketCategory>("other");
  const [status, setStatus] = useState<GrowthTicketStatus>("new");
  const [priority, setPriority] = useState<GrowthTicketPriority>("normal");
  const [householdId, setHouseholdId] = useState("");
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    const trimmed = subject.trim();
    if (trimmed.length < 1 || trimmed.length > 200) return setErr(t("form.errSubject"));
    const hh = householdId.trim();
    if (!UUID_RE.test(hh)) return setErr(t("form.errHousehold"));

    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_destek_kaydet", {
      p_data: { subject: trimmed, category, status, priority, household_id: hh },
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("form.title")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="d-subject">{t("form.subject")}</label>
          <input
            id="d-subject"
            type="text"
            className={inputClass}
            maxLength={200}
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
          />
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label className={labelClass} htmlFor="d-category">{t("form.category")}</label>
            <select
              id="d-category"
              className={inputClass}
              value={category}
              onChange={(e) => setCategory(e.target.value as GrowthTicketCategory)}
            >
              {CATEGORIES.map((c) => (
                <option key={c} value={c}>{t(`categories.${c}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="d-new-status">{t("form.status")}</label>
            <select
              id="d-new-status"
              className={inputClass}
              value={status}
              onChange={(e) => setStatus(e.target.value as GrowthTicketStatus)}
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>{t(`statuses.${s}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="d-new-priority">{t("form.priority")}</label>
            <select
              id="d-new-priority"
              className={inputClass}
              value={priority}
              onChange={(e) => setPriority(e.target.value as GrowthTicketPriority)}
            >
              {PRIORITIES.map((p) => (
                <option key={p} value={p}>{t(`priorities.${p}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="d-household">{t("form.householdId")}</label>
            <input
              id="d-household"
              type="text"
              className={inputClass}
              placeholder="00000000-0000-0000-0000-000000000000"
              value={householdId}
              onChange={(e) => setHouseholdId(e.target.value)}
            />
          </div>
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

// ---------------------------------------------------------------------
// Durum değiştirme modalı — admin_destek_kaydet({id, status})
// ---------------------------------------------------------------------
function StatusModal({ ticket, onClose, onSaved }: { ticket: GrowthTicket; onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.destekMasasi");
  const [status, setStatus] = useState<GrowthTicketStatus>(ticket.status);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_destek_kaydet", {
      p_data: { id: ticket.id, status },
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("statusModal.title")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="d-status-new">{t("cols.status")}</label>
          <select
            id="d-status-new"
            className={inputClass}
            value={status}
            onChange={(e) => setStatus(e.target.value as GrowthTicketStatus)}
          >
            {STATUSES.map((s) => (
              <option key={s} value={s}>{t(`statuses.${s}`)}</option>
            ))}
          </select>
        </div>
        <ErrorNote message={err} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("statusModal.cancel")}
          </button>
          <button type="button" className={primaryBtn} disabled={saving} onClick={save}>
            {saving ? t("statusModal.saving") : t("statusModal.save")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}
