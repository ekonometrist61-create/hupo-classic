"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthTemplate, GrowthTemplateList } from "../types";
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
const CHANNELS = ["email", "sms", "push", "in_app", "whatsapp"] as const;
type Channel = (typeof CHANNELS)[number];
const TEMPLATE_STATUSES = ["draft", "active", "archived"] as const;
type TemplateStatus = (typeof TEMPLATE_STATUSES)[number];
const STATUS_COLOR: Record<TemplateStatus, "warning" | "success" | "light"> = {
  draft: "warning",
  active: "success",
  archived: "light",
};

export default function MesajSablonlariManager() {
  const t = useTranslations("yonetim.mesajSablonlari");
  const [kanal, setKanal] = useState<"" | Channel>("");
  const [durum, setDurum] = useState<"" | TemplateStatus>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthTemplateList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // null: kapalı; {} : yeni şablon; dolu: düzenleme
  const [editTarget, setEditTarget] = useState<GrowthTemplate | "new" | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_template_listele", {
        p_channel: kanal || null,
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
        setList(data as GrowthTemplateList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [kanal, durum, page, reloadKey]);

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-40">
            <label className={labelClass} htmlFor="s-kanal">{t("filters.channel")}</label>
            <select
              id="s-kanal"
              className={inputClass}
              value={kanal}
              onChange={(e) => { setKanal(e.target.value as "" | Channel); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allChannels")}</option>
              {CHANNELS.map((c) => (
                <option key={c} value={c}>{t(`channels.${c}`)}</option>
              ))}
            </select>
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="s-durum">{t("filters.status")}</label>
            <select
              id="s-durum"
              className={inputClass}
              value={durum}
              onChange={(e) => { setDurum(e.target.value as "" | TemplateStatus); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allStatus")}</option>
              {TEMPLATE_STATUSES.map((s) => (
                <option key={s} value={s}>{t(`statuses.${s}`)}</option>
              ))}
            </select>
          </div>
          <div className="ms-auto">
            <button type="button" className={primaryBtn} onClick={() => setEditTarget("new")}>
              {t("newTemplate")}
            </button>
          </div>
        </div>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{error}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
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
                  <th className={thClass}>{t("cols.channel")}</th>
                  <th className={thClass}>{t("cols.subject")}</th>
                  <th className={thClass}>{t("cols.status")}</th>
                  <th className={thClass}>{t("cols.created")}</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((s) => {
                  const status = (TEMPLATE_STATUSES as readonly string[]).includes(s.status)
                    ? (s.status as TemplateStatus)
                    : "draft";
                  return (
                    <tr key={s.id}>
                      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{s.name}</td>
                      <td className={tdClass}>
                        {(CHANNELS as readonly string[]).includes(s.channel)
                          ? t(`channels.${s.channel as Channel}`)
                          : s.channel}
                      </td>
                      <td className={tdClass}>{s.subject ?? "-"}</td>
                      <td className={tdClass}>
                        <Badge size="sm" color={STATUS_COLOR[status]}>{t(`statuses.${status}`)}</Badge>
                      </td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        {s.created_at ? formatDate(new Date(s.created_at)) : "-"}
                      </td>
                      <td className={`${tdClass} whitespace-nowrap text-end`}>
                        <button type="button" className={linkBtn} onClick={() => setEditTarget(s)}>
                          {t("edit")}
                        </button>
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

      {editTarget !== null && (
        <TemplateModal
          key={editTarget === "new" ? "new" : editTarget.id}
          template={editTarget === "new" ? null : editTarget}
          onClose={() => setEditTarget(null)}
          onSaved={() => { setEditTarget(null); setLoading(true); setReloadKey((k) => k + 1); }}
        />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Yeni / düzenle şablon modalı
// ---------------------------------------------------------------------
function TemplateModal({
  template,
  onClose,
  onSaved,
}: {
  template: GrowthTemplate | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const t = useTranslations("yonetim.mesajSablonlari");
  const [name, setName] = useState(template?.name ?? "");
  const [channel, setChannel] = useState<Channel>(
    (CHANNELS as readonly string[]).includes(template?.channel ?? "")
      ? (template!.channel as Channel)
      : "email",
  );
  const [subject, setSubject] = useState(template?.subject ?? "");
  const [body, setBody] = useState(template?.body ?? "");
  const [status, setStatus] = useState<TemplateStatus>(
    (TEMPLATE_STATUSES as readonly string[]).includes(template?.status ?? "")
      ? (template!.status as TemplateStatus)
      : "draft",
  );
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const save = async () => {
    const ad = name.trim();
    if (ad.length < 1 || ad.length > 120) return setErr(t("form.errName"));
    if (body.trim().length < 1) return setErr(t("form.errBody"));

    // {{degisken}} biçimindeki alanlar değişken listesine yazılır.
    const variables = Array.from(
      new Set(Array.from(body.matchAll(/\{\{\s*([A-Za-z_]\w*)\s*\}\}/g), (m) => m[1])),
    );

    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc("admin_template_kaydet", {
      p_data: {
        ...(template ? { id: template.id } : {}),
        name: ad,
        channel,
        subject: channel === "email" ? subject.trim() || null : null,
        body,
        status,
        variables,
      },
    });
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={template ? t("form.titleEdit") : t("form.titleNew")}>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="s-name">{t("form.name")}</label>
          <input id="s-name" type="text" className={inputClass} value={name} onChange={(e) => setName(e.target.value)} />
        </div>
        <div>
          <label className={labelClass} htmlFor="s-channel">{t("form.channel")}</label>
          <select
            id="s-channel"
            className={inputClass}
            value={channel}
            onChange={(e) => setChannel(e.target.value as Channel)}
          >
            {CHANNELS.map((c) => (
              <option key={c} value={c}>{t(`channels.${c}`)}</option>
            ))}
          </select>
        </div>
        {channel === "email" && (
          <div>
            <label className={labelClass} htmlFor="s-subject">{t("form.subject")}</label>
            <input id="s-subject" type="text" className={inputClass} value={subject} onChange={(e) => setSubject(e.target.value)} />
          </div>
        )}
        <div>
          <label className={labelClass} htmlFor="s-body">{t("form.body")}</label>
          <textarea
            id="s-body"
            rows={6}
            className={`${inputClass} h-auto py-2.5`}
            value={body}
            onChange={(e) => setBody(e.target.value)}
          />
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("form.bodyHint")}</p>
        </div>
        <div>
          <label className={labelClass} htmlFor="s-new-status">{t("form.status")}</label>
          <select
            id="s-new-status"
            className={inputClass}
            value={status}
            onChange={(e) => setStatus(e.target.value as TemplateStatus)}
          >
            {TEMPLATE_STATUSES.map((s) => (
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
