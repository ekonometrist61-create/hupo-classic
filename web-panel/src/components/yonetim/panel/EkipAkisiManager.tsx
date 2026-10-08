"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { formatDateTime } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthFeedEntry, GrowthFeedList } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

const PAGE_SIZE = 25;
const FEED_TYPES = ["note", "call", "email", "meeting", "support", "system", "task"] as const;
/** admin_ekip_akisi_ekle yalnızca bu türleri kabul eder (sistem kayıtları admin tarafından üretilemez). */
const ADDABLE_TYPES = ["note", "call", "meeting", "support"] as const;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const TYPE_CLASS: Record<string, string> = {
  note: "bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-gray-300",
  call: "bg-blue-50 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400",
  email: "bg-indigo-50 text-indigo-700 dark:bg-indigo-500/15 dark:text-indigo-400",
  meeting: "bg-purple-50 text-purple-700 dark:bg-purple-500/15 dark:text-purple-400",
  support: "bg-orange-50 text-orange-700 dark:bg-orange-500/15 dark:text-orange-400",
  system: "bg-gray-100 text-gray-500 dark:bg-white/5 dark:text-gray-400",
  task: "bg-yellow-50 text-yellow-700 dark:bg-yellow-500/15 dark:text-yellow-400",
};

export default function EkipAkisiManager() {
  const t = useTranslations("yonetim.ekipAkisi");
  const [feedType, setFeedType] = useState("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);
  const [creating, setCreating] = useState(false);

  const [list, setList] = useState<GrowthFeedList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_ekip_akisi_listele", {
        p_household_id: null,
        p_lead_id: null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthFeedList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [page, reloadKey]);

  // Tür filtresi RPC'de parametre olarak yok; yüklenen sayfa üzerinde uygulanır.
  const rows = (list?.rows ?? []).filter((r) => !feedType || r.feed_type === feedType);
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + (list?.rows.length ?? 0));

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-48">
            <label className={labelClass} htmlFor="e-type">{t("filterType")}</label>
            <select
              id="e-type"
              className={inputClass}
              value={feedType}
              onChange={(e) => setFeedType(e.target.value)}
            >
              <option value="">{t("allTypes")}</option>
              {FEED_TYPES.map((v) => (
                <option key={v} value={v}>{t(`types.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <button type="button" className={primaryBtn} onClick={() => setCreating(true)}>
              {t("newNote")}
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
          <ul className="space-y-3">
            {rows.map((entry) => (
              <FeedCard key={entry.id} entry={entry} />
            ))}
          </ul>
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
        <FeedModal
          onClose={() => setCreating(false)}
          onSaved={() => { setCreating(false); setLoading(true); setPage(0); reload(); }}
        />
      )}
    </div>
  );
}

function FeedCard({ entry }: { entry: GrowthFeedEntry }) {
  const t = useTranslations("yonetim.ekipAkisi");
  return (
    <li className="rounded-xl border border-gray-100 p-4 dark:border-gray-800">
      <div className="mb-2 flex flex-wrap items-center justify-between gap-2">
        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium whitespace-nowrap ${TYPE_CLASS[entry.feed_type] ?? TYPE_CLASS.note}`}>
          {t(`types.${entry.feed_type}`)}
        </span>
        <span className="text-theme-xs text-gray-500 dark:text-gray-400">{formatDateTime(entry.created_at)}</span>
      </div>
      <p className="whitespace-pre-line text-theme-sm text-gray-800 dark:text-white/90">{entry.body ?? "-"}</p>
      <p className="mt-2 font-mono text-theme-xs text-gray-400 dark:text-gray-500">
        {t("author")}: {entry.author_user_id ? entry.author_user_id.slice(-8) : "-"}
      </p>
    </li>
  );
}

// ---------------------------------------------------------------------
// Yeni akış notu modalı — admin_ekip_akisi_ekle ile kaydeder
// ---------------------------------------------------------------------
function FeedModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const t = useTranslations("yonetim.ekipAkisi");
  const [body, setBody] = useState("");
  const [entryType, setEntryType] = useState<string>("note");
  const [householdId, setHouseholdId] = useState("");
  const [leadId, setLeadId] = useState("");
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    const text = body.trim();
    const hh = householdId.trim();
    const ld = leadId.trim();
    if (!text || text.length > 4000) return setErr(t("form.errBody"));
    if (!hh && !ld) return setErr(t("form.errTarget"));
    if ((hh && !UUID_RE.test(hh)) || (ld && !UUID_RE.test(ld))) return setErr(t("form.errUuid"));

    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_ekip_akisi_ekle", {
      p_data: {
        content: text,
        entry_type: entryType,
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
          <label className={labelClass} htmlFor="e-f-body">{t("form.body")}</label>
          <textarea
            id="e-f-body"
            rows={4}
            maxLength={4000}
            className={`${inputClass} h-auto py-2.5`}
            value={body}
            onChange={(e) => setBody(e.target.value)}
          />
        </div>
        <div>
          <label className={labelClass} htmlFor="e-f-type">{t("form.type")}</label>
          <select id="e-f-type" className={inputClass} value={entryType} onChange={(e) => setEntryType(e.target.value)}>
            {ADDABLE_TYPES.map((v) => (
              <option key={v} value={v}>{t(`types.${v}`)}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="e-f-hh">{t("form.householdId")}</label>
          <input
            id="e-f-hh"
            type="text"
            className={inputClass}
            placeholder="00000000-0000-0000-0000-000000000000"
            value={householdId}
            onChange={(e) => setHouseholdId(e.target.value)}
          />
        </div>
        <div>
          <label className={labelClass} htmlFor="e-f-lead">{t("form.leadId")}</label>
          <input
            id="e-f-lead"
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
