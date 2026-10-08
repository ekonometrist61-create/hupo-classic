"use client";

import { useCallback, useEffect, useState } from "react";
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
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-40">
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
          <div className="ms-auto">
            <button type="button" className={primaryBtn} onClick={() => setCreateOpen(true)}>
              {t("newJourney")}
            </button>
          </div>
        </div>

        <ErrorNote message={actionError} />

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
                        {status === "active" ? (
                          <button type="button" className={linkBtn} disabled={busy} onClick={() => changeStatus(j, "paused")}>
                            {t("pause")}
                          </button>
                        ) : (
                          <button type="button" className={linkBtn} disabled={busy} onClick={() => changeStatus(j, "active")}>
                            {t("activate")}
                          </button>
                        )}
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
