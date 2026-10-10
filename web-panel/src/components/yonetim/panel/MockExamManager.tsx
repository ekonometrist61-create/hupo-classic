"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import type { MockExam } from "../types";
import ErrorNote from "./ErrorNote";
import MockExamDetailModal from "./MockExamDetailModal";
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

export const SINIF_SECENEKLERI = [3, 4, 5, 6, 7, 8];

interface FormState {
  id: string | null;
  ad: string;
  baslangic: string;
  sure: string;
  siniflar: number[];
  aktif: boolean;
}

const EMPTY: FormState = { id: null, ad: "", baslangic: "", sure: "40", siniflar: [], aktif: true };

function toLocalInput(iso: string) {
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function formatWhen(iso: string) {
  return new Date(iso).toLocaleString("tr-TR", { dateStyle: "medium", timeStyle: "short" });
}

export default function MockExamManager() {
  const t = useTranslations("yonetim.mockExams");
  const [exams, setExams] = useState<MockExam[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [detailId, setDetailId] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_list_mock_exams");
      if (cancelled) return;
      if (err) {
        setError(err.message);
      } else {
        setError(null);
        setExams((data ?? []) as MockExam[]);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const detailExam = exams.find((e) => e.id === detailId) ?? null;

  const openNew = () => {
    setForm(EMPTY);
    setFormError(null);
  };

  const openEdit = (ex: MockExam) => {
    setForm({
      id: ex.id,
      ad: ex.ad,
      baslangic: toLocalInput(ex.baslangic_zamani),
      sure: String(ex.sure_dakika),
      siniflar: ex.siniflar,
      aktif: ex.aktif,
    });
    setFormError(null);
  };

  const set = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const toggleSinif = (s: number) =>
    setForm((f) =>
      f
        ? {
            ...f,
            siniflar: f.siniflar.includes(s)
              ? f.siniflar.filter((x) => x !== s)
              : [...f.siniflar, s].sort((a, b) => a - b),
          }
        : f,
    );

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    setFormError(null);
    const when = new Date(form.baslangic);
    const sure = Number(form.sure);
    if (form.ad.trim().length < 2) return setFormError(t("errAd"));
    if (!form.baslangic || Number.isNaN(when.getTime())) return setFormError(t("errBaslangic"));
    if (!Number.isInteger(sure) || sure < 5 || sure > 240) return setFormError(t("errSure"));
    if (form.siniflar.length === 0) return setFormError(t("errSinif"));

    setSaving(true);
    const { error: err } = await createClient().rpc("admin_upsert_mock_exam", {
      p_id: form.id,
      p_ad: form.ad.trim(),
      p_baslangic: when.toISOString(),
      p_sure_dakika: sure,
      p_siniflar: form.siniflar,
      p_aktif: form.aktif,
    });
    setSaving(false);
    if (err) return setFormError(err.message);
    setForm(null);
    reload();
  };

  const toggleActive = async (ex: MockExam) => {
    const { error: err } = await createClient().rpc("admin_set_mock_exam_active", {
      p_id: ex.id,
      p_aktif: !ex.aktif,
    });
    if (err) return setError(err.message);
    reload();
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h3>
        <button type="button" className={primaryBtn} onClick={openNew}>
          {t("new")}
        </button>
      </div>

      <ErrorNote message={error} />

      {loading ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : exams.length === 0 ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th className={thClass}>{t("cols.ad")}</th>
                <th className={thClass}>{t("cols.baslangic")}</th>
                <th className={thClass}>{t("cols.sure")}</th>
                <th className={thClass}>{t("cols.siniflar")}</th>
                <th className={thClass}>{t("cols.sorular")}</th>
                <th className={thClass}>{t("cols.durum")}</th>
                <th className={thClass} />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {exams.map((ex) => (
                <tr key={ex.id}>
                  <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{ex.ad}</td>
                  <td className={`${tdClass} whitespace-nowrap`}>{formatWhen(ex.baslangic_zamani)}</td>
                  <td className={tdClass}>{t("sureDk", { count: ex.sure_dakika })}</td>
                  <td className={tdClass}>{ex.siniflar.join(", ") || "-"}</td>
                  <td className={tdClass}>
                    {t("sorularOran", { atanan: ex.soru_atanan_sinif_sayisi, toplam: ex.siniflar.length })}
                  </td>
                  <td className={tdClass}>
                    <Badge size="sm" color={ex.aktif ? "success" : "light"}>
                      {ex.aktif ? t("aktif") : t("pasif")}
                    </Badge>
                  </td>
                  <td className={`${tdClass} whitespace-nowrap text-end`}>
                    <span className="flex justify-end gap-3">
                      <button type="button" className={linkBtn} onClick={() => setDetailId(ex.id)}>
                        {t("detay")}
                      </button>
                      <button type="button" className={linkBtn} onClick={() => openEdit(ex)}>
                        {t("duzenle")}
                      </button>
                      <button type="button" className={linkBtn} onClick={() => toggleActive(ex)}>
                        {ex.aktif ? t("pasifYap") : t("aktifYap")}
                      </button>
                    </span>
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
            {form.id ? t("form.editTitle") : t("form.createTitle")}
          </h4>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className={labelClass} htmlFor="mx-ad">{t("form.ad")}</label>
              <input
                id="mx-ad"
                className={inputClass}
                maxLength={120}
                value={form.ad}
                onChange={(e) => set("ad", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="mx-baslangic">{t("form.baslangic")}</label>
              <input
                id="mx-baslangic"
                type="datetime-local"
                className={inputClass}
                value={form.baslangic}
                onChange={(e) => set("baslangic", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="mx-sure">{t("form.sure")}</label>
              <input
                id="mx-sure"
                inputMode="numeric"
                className={inputClass}
                value={form.sure}
                onChange={(e) => set("sure", e.target.value)}
              />
              <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("form.sureHint")}</p>
            </div>
            <fieldset>
              <legend className={labelClass}>{t("form.siniflar")}</legend>
              <div className="flex flex-wrap gap-3">
                {SINIF_SECENEKLERI.map((s) => (
                  <label key={s} className="flex items-center gap-1.5 text-sm text-gray-700 dark:text-gray-300">
                    <input
                      type="checkbox"
                      checked={form.siniflar.includes(s)}
                      onChange={() => toggleSinif(s)}
                    />
                    {t("form.sinifEtiket", { sinif: s })}
                  </label>
                ))}
              </div>
            </fieldset>
          </div>
          <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
            <input
              type="checkbox"
              checked={form.aktif}
              onChange={(e) => set("aktif", e.target.checked)}
            />
            {t("form.aktifCheckbox")}
          </label>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("form.kilitHint")}</p>
          <ErrorNote message={formError} />
          <div className="flex justify-end gap-3">
            <button type="button" className={outlineBtn} onClick={() => setForm(null)}>
              {t("form.vazgec")}
            </button>
            <button type="submit" className={primaryBtn} disabled={saving}>
              {saving ? t("form.kaydediliyor") : t("form.kaydet")}
            </button>
          </div>
        </form>
      )}

      {detailExam && (
        <MockExamDetailModal
          exam={detailExam}
          onClose={() => setDetailId(null)}
          onChanged={reload}
        />
      )}
    </section>
  );
}
