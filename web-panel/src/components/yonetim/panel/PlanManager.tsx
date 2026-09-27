"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatKurus } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import type { Plan } from "../types";
import ErrorNote from "./ErrorNote";
import { kurusToInput, parseTryToKurus } from "./helpers";
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

interface FormState {
  kod: string;
  ad: string;
  aciklama: string;
  fiyat: string;
  sure: string;
  aktif: boolean;
}

const EMPTY: FormState = { kod: "", ad: "", aciklama: "", fiyat: "", sure: "30", aktif: true };

export default function PlanManager({
  plans,
  onChanged,
}: {
  plans: Plan[];
  onChanged: () => void;
}) {
  const t = useTranslations("yonetim.odemeler.plans");
  const [form, setForm] = useState<FormState | null>(null);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const openNew = () => {
    setForm(EMPTY);
    setEditing(false);
    setError(null);
  };
  const openEdit = (p: Plan) => {
    setForm({
      kod: p.kod,
      ad: p.ad,
      aciklama: p.aciklama ?? "",
      fiyat: kurusToInput(p.fiyat_kurus),
      sure: String(p.sure_gun),
      aktif: p.aktif,
    });
    setEditing(true);
    setError(null);
  };

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    setError(null);
    if (!/^[a-z0-9_]{2,30}$/.test(form.kod)) return setError(t("errKod"));
    if (!form.ad.trim()) return setError(t("errAd"));
    const kurus = parseTryToKurus(form.fiyat);
    if (kurus === null) return setError(t("errFiyat"));
    if (!/^\d+$/.test(form.sure) || Number(form.sure) < 1) return setError(t("errSure"));

    setSaving(true);
    const { error: err } = await createClient().rpc("admin_upsert_plan", {
      p_kod: form.kod,
      p_ad: form.ad.trim(),
      p_aciklama: form.aciklama.trim() || null,
      p_fiyat_kurus: kurus,
      p_sure_gun: Number(form.sure),
      p_aktif: form.aktif,
    });
    setSaving(false);
    if (err) return setError(err.message);
    setForm(null);
    onChanged();
  };

  const set = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
          {t("title")}
        </h3>
        <button type="button" className={outlineBtn} onClick={openNew}>
          {t("new")}
        </button>
      </div>

      {plans.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th className={thClass}>{t("kod")}</th>
                <th className={thClass}>{t("ad")}</th>
                <th className={thClass}>{t("fiyat")}</th>
                <th className={thClass}>{t("sure")}</th>
                <th className={thClass}>{t("aktif")}</th>
                <th className={thClass} />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {plans.map((p) => (
                <tr key={p.kod}>
                  <td className={`${tdClass} font-mono`}>{p.kod}</td>
                  <td className={tdClass}>{p.ad}</td>
                  <td className={tdClass}>{formatKurus(p.fiyat_kurus)}</td>
                  <td className={tdClass}>{p.sure_gun}</td>
                  <td className={tdClass}>
                    <Badge size="sm" color={p.aktif ? "success" : "light"}>
                      {p.aktif ? t("active") : t("inactive")}
                    </Badge>
                  </td>
                  <td className={`${tdClass} text-end`}>
                    <button type="button" className={linkBtn} onClick={() => openEdit(p)}>
                      {t("edit")}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {form && (
        <form
          onSubmit={submit}
          className="mt-6 space-y-4 rounded-xl border border-gray-200 p-4 dark:border-gray-800"
        >
          <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">
            {editing ? t("editTitle") : t("createTitle")}
          </h4>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className={labelClass} htmlFor="plan-kod">{t("kod")}</label>
              <input
                id="plan-kod"
                className={`${inputClass} font-mono`}
                value={form.kod}
                disabled={editing}
                maxLength={30}
                onChange={(e) => set("kod", e.target.value)}
              />
              <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                {t("kodHint")}
              </p>
            </div>
            <div>
              <label className={labelClass} htmlFor="plan-ad">{t("ad")}</label>
              <input
                id="plan-ad"
                className={inputClass}
                value={form.ad}
                onChange={(e) => set("ad", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="plan-fiyat">{t("fiyat")}</label>
              <input
                id="plan-fiyat"
                className={inputClass}
                inputMode="decimal"
                placeholder="149,90"
                value={form.fiyat}
                onChange={(e) => set("fiyat", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="plan-sure">{t("sure")}</label>
              <input
                id="plan-sure"
                className={inputClass}
                inputMode="numeric"
                value={form.sure}
                onChange={(e) => set("sure", e.target.value)}
              />
            </div>
          </div>
          <div>
            <label className={labelClass} htmlFor="plan-aciklama">{t("aciklama")}</label>
            <textarea
              id="plan-aciklama"
              rows={2}
              className={`${inputClass} h-auto`}
              value={form.aciklama}
              onChange={(e) => set("aciklama", e.target.value)}
            />
          </div>
          <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
            <input
              type="checkbox"
              checked={form.aktif}
              onChange={(e) => set("aktif", e.target.checked)}
            />
            {t("aktif")}
          </label>
          <ErrorNote message={error} />
          <div className="flex justify-end gap-3">
            <button type="button" className={outlineBtn} onClick={() => setForm(null)}>
              {t("cancel")}
            </button>
            <button type="submit" className={primaryBtn} disabled={saving}>
              {saving ? t("saving") : t("save")}
            </button>
          </div>
        </form>
      )}
    </section>
  );
}
