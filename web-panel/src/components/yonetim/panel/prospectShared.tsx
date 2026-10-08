"use client";

import { useState } from "react";

import { createClient } from "@/utils/supabase/client";
import type { ProspectDetay } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

export const PROSPECT_KINDS = ["individual", "household", "institution", "referral", "partner"] as const;

export const KIND_LABEL: Record<string, string> = {
  individual: "Bireysel",
  household: "Hane",
  institution: "Kurum",
  referral: "Tavsiye",
  partner: "Partner",
};

export const STATUS_OPTIONS = [
  "new",
  "enriched",
  "scored",
  "qualified",
  "nurturing",
  "converted",
  "disqualified",
  "suppressed",
] as const;

export const STATUS_LABEL: Record<string, string> = {
  new: "Yeni",
  enriched: "Zenginleştirildi",
  scored: "Puanlandı",
  qualified: "Nitelikli",
  nurturing: "Beslemede",
  converted: "Dönüştü",
  disqualified: "Uygun değil",
  suppressed: "İletişim dışı",
};

const CHIP = {
  blue: "bg-blue-50 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400",
  cyan: "bg-cyan-50 text-cyan-700 dark:bg-cyan-500/15 dark:text-cyan-400",
  yellow: "bg-yellow-50 text-yellow-700 dark:bg-yellow-500/15 dark:text-yellow-400",
  green: "bg-green-50 text-green-700 dark:bg-green-500/15 dark:text-green-400",
  purple: "bg-purple-50 text-purple-700 dark:bg-purple-500/15 dark:text-purple-400",
  emerald: "bg-emerald-50 text-emerald-700 dark:bg-emerald-500/15 dark:text-emerald-400",
  red: "bg-red-50 text-red-700 dark:bg-red-500/15 dark:text-red-400",
  gray: "bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-white/80",
} as const;

export const STATUS_CHIP: Record<string, string> = {
  new: CHIP.blue,
  enriched: CHIP.cyan,
  scored: CHIP.yellow,
  qualified: CHIP.green,
  nurturing: CHIP.purple,
  converted: CHIP.emerald,
  disqualified: CHIP.red,
  suppressed: CHIP.gray,
};

export const CONSENT_CHANNELS = [
  { key: "email", label: "E-posta" },
  { key: "sms", label: "SMS" },
  { key: "push", label: "Anlık bildirim" },
  { key: "whatsapp", label: "WhatsApp" },
  { key: "phone", label: "Telefon" },
] as const;

export const CONSENT_LABEL: Record<string, string> = {
  granted: "İzinli",
  denied: "Reddedildi",
  pending: "Beklemede",
  expired: "Süresi doldu",
  none: "Kayıt yok",
};

export const CONSENT_CHIP: Record<string, string> = {
  granted: CHIP.green,
  denied: CHIP.red,
  pending: CHIP.yellow,
  expired: CHIP.gray,
  none: CHIP.gray,
};

export function Chip({ className, children }: { className: string; children: React.ReactNode }) {
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium ${className}`}>
      {children}
    </span>
  );
}

export function scoreTextClass(score: number): string {
  if (score <= 30) return "text-red-600 dark:text-red-400";
  if (score <= 60) return "text-yellow-600 dark:text-yellow-400";
  if (score <= 80) return "text-green-700 dark:text-green-400";
  return "text-green-500 dark:text-green-300";
}

export type ProspectFormValues = {
  display_name: string;
  email: string;
  phone: string;
  kind: string;
  source_channel: string;
  source_detail: string;
  fit_score: string;
  intent_score: string;
  engagement_score: string;
  data_quality_score: string;
  notes: string;
  tags: string;
};

export const EMPTY_PROSPECT_FORM: ProspectFormValues = {
  display_name: "",
  email: "",
  phone: "",
  kind: "individual",
  source_channel: "",
  source_detail: "",
  fit_score: "0",
  intent_score: "0",
  engagement_score: "0",
  data_quality_score: "0",
  notes: "",
  tags: "",
};

export function prospectToForm(p: ProspectDetay["prospect"]): ProspectFormValues {
  return {
    display_name: p.display_name,
    email: p.email ?? "",
    phone: p.phone ?? "",
    kind: p.kind,
    source_channel: p.source_type ?? "",
    source_detail: p.source_detail ?? "",
    fit_score: String(p.fit_score),
    intent_score: String(p.intent_score),
    engagement_score: String(p.engagement_score),
    data_quality_score: String(p.data_quality_score),
    notes: p.notes ?? "",
    tags: p.tags.join(", "),
  };
}

const SCORE_FIELDS = [
  { key: "fit_score", label: "Uygunluk puanı", max: 35 },
  { key: "intent_score", label: "Niyet puanı", max: 35 },
  { key: "engagement_score", label: "Etkileşim puanı", max: 20 },
  { key: "data_quality_score", label: "Veri kalitesi puanı", max: 10 },
] as const;

function parseScore(raw: string, max: number): number | null {
  const n = raw.trim() === "" ? 0 : Number(raw);
  return Number.isFinite(n) && n >= 0 && n <= max ? n : null;
}

export function ProspectFormModal({
  prospectId,
  initial,
  onClose,
  onSaved,
}: {
  prospectId?: string;
  initial?: ProspectFormValues;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [v, setV] = useState<ProspectFormValues>(initial ?? EMPTY_PROSPECT_FORM);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const editing = prospectId !== undefined;

  const set = (key: keyof ProspectFormValues, value: string) =>
    setV((prev) => ({ ...prev, [key]: value }));

  const save = async () => {
    const name = v.display_name.trim();
    if (!name) return setErr("Ad soyad zorunlu.");

    const fit = parseScore(v.fit_score, 35);
    const intent = parseScore(v.intent_score, 35);
    const engagement = parseScore(v.engagement_score, 20);
    const dataQuality = parseScore(v.data_quality_score, 10);
    if (fit === null || intent === null || engagement === null || dataQuality === null) {
      return setErr("Puanlar sınırlar içinde olmalı: uygunluk 0-35, niyet 0-35, etkileşim 0-20, veri kalitesi 0-10.");
    }

    const args = {
      p_display_name: name,
      p_email: v.email.trim() || null,
      p_phone: v.phone.trim() || null,
      p_kind: v.kind,
      p_source_channel: v.source_channel.trim() || null,
      p_source_detail: v.source_detail.trim() || null,
      p_fit_score: fit,
      p_intent_score: intent,
      p_engagement_score: engagement,
      p_data_quality_score: dataQuality,
    };
    const payload = editing
      ? {
          p_prospect_id: prospectId,
          ...args,
          p_notes: v.notes.trim() || null,
          p_tags: v.tags.split(",").map((t) => t.trim()).filter(Boolean),
        }
      : args;

    setSaving(true);
    setErr(null);
    const { error } = await createClient().rpc(
      editing ? "admin_prospect_guncelle" : "admin_prospect_kaydet",
      payload,
    );
    setSaving(false);
    if (error) return setErr(error.message);
    onSaved();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={editing ? "Adayı düzenle" : "Yeni aday ekle"}>
      <div className="space-y-4">
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <label className={labelClass} htmlFor="p-name">Ad soyad *</label>
            <input id="p-name" type="text" className={inputClass} value={v.display_name} onChange={(e) => set("display_name", e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="p-email">E-posta</label>
            <input id="p-email" type="email" className={inputClass} value={v.email} onChange={(e) => set("email", e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="p-phone">Telefon</label>
            <input id="p-phone" type="tel" className={inputClass} value={v.phone} onChange={(e) => set("phone", e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="p-kind">Tür</label>
            <select id="p-kind" className={inputClass} value={v.kind} onChange={(e) => set("kind", e.target.value)}>
              {PROSPECT_KINDS.map((k) => (
                <option key={k} value={k}>{KIND_LABEL[k]}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="p-channel">Kaynak kanalı</label>
            <input id="p-channel" type="text" className={inputClass} value={v.source_channel} onChange={(e) => set("source_channel", e.target.value)} />
          </div>
          <div className="sm:col-span-2">
            <label className={labelClass} htmlFor="p-detail">Kaynak ayrıntısı</label>
            <input id="p-detail" type="text" className={inputClass} value={v.source_detail} onChange={(e) => set("source_detail", e.target.value)} />
          </div>
          {SCORE_FIELDS.map((f) => (
            <div key={f.key}>
              <label className={labelClass} htmlFor={`p-${f.key}`}>{`${f.label} (0-${f.max})`}</label>
              <input
                id={`p-${f.key}`}
                type="number"
                min={0}
                max={f.max}
                step={1}
                className={inputClass}
                value={v[f.key]}
                onChange={(e) => set(f.key, e.target.value)}
              />
            </div>
          ))}
          {editing && (
            <>
              <div className="sm:col-span-2">
                <label className={labelClass} htmlFor="p-notes">Not</label>
                <input id="p-notes" type="text" className={inputClass} value={v.notes} onChange={(e) => set("notes", e.target.value)} />
              </div>
              <div className="sm:col-span-2">
                <label className={labelClass} htmlFor="p-tags">Etiketler (virgülle ayırın)</label>
                <input id="p-tags" type="text" className={inputClass} value={v.tags} onChange={(e) => set("tags", e.target.value)} />
              </div>
            </>
          )}
        </div>
        <ErrorNote message={err} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>Vazgeç</button>
          <button type="button" className={primaryBtn} disabled={saving} onClick={save}>
            {saving ? "Kaydediliyor..." : "Kaydet"}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}
