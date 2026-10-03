"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import type { AdminUser } from "../types";
import ErrorNote from "./ErrorNote";
import OgretmenPicker from "./OgretmenPicker";
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

interface Sinif {
  id: string;
  ad: string;
  sinif_seviyesi: number;
  okul_adi: string | null;
  yil: number;
  aktif: boolean;
  created_at: string;
  ogretmen_adi: string | null;
  ogretmen_id: string | null;
  ogrenci_sayisi: number;
}

interface FormState {
  ad: string;
  sinif_seviyesi: string;
  ogretmen_id: string;
  okul_adi: string;
  yil: string;
  aktif: boolean;
}

const EMPTY: FormState = {
  ad: "",
  sinif_seviyesi: "",
  ogretmen_id: "",
  okul_adi: "",
  yil: new Date().getFullYear().toString(),
  aktif: true,
};

const PAGE_SIZE = 25;

export default function SiniflarManager() {
  const t = useTranslations("yonetim.siniflar");

  const [siniflar, setSiniflar] = useState<Sinif[]>([]);
  const [toplam, setToplam] = useState(0);
  const [page, setPage] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  const [form, setForm] = useState<FormState | null>(null);
  const [editing, setEditing] = useState<string | null>(null);
  const [selectedOgretmen, setSelectedOgretmen] = useState<AdminUser | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      setLoading(true);
      const { data, error: err } = await createClient().rpc(
        "admin_list_siniflar",
        { p_limit: PAGE_SIZE, p_offset: page * PAGE_SIZE },
      );
      if (cancelled) return;
      if (err) {
        setError(err.message);
      } else {
        setError(null);
        const res = data as { satirlar: Sinif[]; toplam: number };
        setSiniflar(res.satirlar ?? []);
        setToplam(res.toplam ?? 0);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [page, reloadKey]);

  const openNew = () => {
    setForm(EMPTY);
    setEditing(null);
    setSelectedOgretmen(null);
    setFormError(null);
  };

  const openEdit = (s: Sinif) => {
    setForm({
      ad: s.ad,
      sinif_seviyesi: String(s.sinif_seviyesi),
      ogretmen_id: s.ogretmen_id ?? "",
      okul_adi: s.okul_adi ?? "",
      yil: String(s.yil),
      aktif: s.aktif,
    });
    setEditing(s.id);
    setSelectedOgretmen(
      s.ogretmen_id
        ? ({ id: s.ogretmen_id, ad: s.ogretmen_adi, email: null, rol: "ogretmen", veli_ad: null, sinif: null, veli_adi: null, cocuk_sayisi: 0, uyelik_tarihi: null, kayit_tarihi: null, veli_id: null, ogrenci_ad: null } as AdminUser)
        : null,
    );
    setFormError(null);
  };

  const set = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    setFormError(null);

    if (!form.ad.trim()) return setFormError(t("form.errAd"));
    const seviye = Number(form.sinif_seviyesi);
    if (
      !form.sinif_seviyesi ||
      seviye < 1 ||
      seviye > 12 ||
      !Number.isInteger(seviye)
    )
      return setFormError(t("form.errSeviye"));

    setSaving(true);
    const { error: err } = await createClient().rpc("admin_upsert_sinif", {
      p_id: editing ?? null,
      p_ad: form.ad.trim(),
      p_sinif_seviyesi: seviye,
      p_ogretmen_id: form.ogretmen_id.trim() || null,
      p_okul_adi: form.okul_adi.trim() || null,
      p_yil: Number(form.yil) || new Date().getFullYear(),
      p_aktif: form.aktif,
    });
    setSaving(false);
    if (err) return setFormError(err.message);
    setForm(null);
    setEditing(null);
    setSelectedOgretmen(null);
    reload();
  };

  const rows = siniflar;
  const start = toplam === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(toplam, page * PAGE_SIZE + rows.length);

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

      {loading ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("loading")}
        </p>
      ) : error ? (
        <div className="py-8 text-center">
          <p className="mb-3 text-sm text-error-600 dark:text-error-500">
            {error}
          </p>
          <button
            type="button"
            className={primaryBtn}
            onClick={() => {
              setLoading(true);
              reload();
            }}
          >
            {t("retry")}
          </button>
        </div>
      ) : rows.length === 0 ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th className={thClass}>{t("cols.ad")}</th>
                <th className={thClass}>{t("cols.seviye")}</th>
                <th className={thClass}>{t("cols.ogretmen")}</th>
                <th className={thClass}>{t("cols.ogrenciler")}</th>
                <th className={thClass}>{t("cols.yil")}</th>
                <th className={thClass}>{t("cols.aktif")}</th>
                <th className={thClass} />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {rows.map((s) => (
                <tr key={s.id}>
                  <td
                    className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}
                  >
                    {s.ad}
                  </td>
                  <td className={tdClass}>{s.sinif_seviyesi}. sınıf</td>
                  <td className={tdClass}>{s.ogretmen_adi ?? "-"}</td>
                  <td className={tdClass}>{s.ogrenci_sayisi}</td>
                  <td className={tdClass}>{s.yil}</td>
                  <td className={tdClass}>
                    <Badge size="sm" color={s.aktif ? "success" : "light"}>
                      {s.aktif ? t("active") : t("inactive")}
                    </Badge>
                  </td>
                  <td className={`${tdClass} text-end`}>
                    <button
                      type="button"
                      className={linkBtn}
                      onClick={() => openEdit(s)}
                    >
                      {t("edit")}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {!loading && !error && toplam > PAGE_SIZE && (
        <div className="mt-4 flex items-center justify-between text-theme-sm text-gray-500 dark:text-gray-400">
          <span>
            {start}–{end} / {toplam}
          </span>
          <div className="flex gap-2">
            <button
              type="button"
              disabled={page === 0}
              className={outlineBtn}
              onClick={() => setPage((p) => p - 1)}
            >
              ←
            </button>
            <button
              type="button"
              disabled={end >= toplam}
              className={outlineBtn}
              onClick={() => setPage((p) => p + 1)}
            >
              →
            </button>
          </div>
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
              <label className={labelClass} htmlFor="sinif-ad">
                {t("form.ad")}
              </label>
              <input
                id="sinif-ad"
                className={inputClass}
                value={form.ad}
                onChange={(e) => set("ad", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="sinif-seviye">
                {t("form.seviye")}
              </label>
              <input
                id="sinif-seviye"
                className={inputClass}
                inputMode="numeric"
                min={1}
                max={12}
                value={form.sinif_seviyesi}
                onChange={(e) => set("sinif_seviyesi", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="sinif-okul">
                {t("form.okul")}
              </label>
              <input
                id="sinif-okul"
                className={inputClass}
                value={form.okul_adi}
                onChange={(e) => set("okul_adi", e.target.value)}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="sinif-yil">
                {t("form.yil")}
              </label>
              <input
                id="sinif-yil"
                className={inputClass}
                inputMode="numeric"
                value={form.yil}
                onChange={(e) => set("yil", e.target.value)}
              />
            </div>
            <div className="sm:col-span-2">
              <OgretmenPicker
                selected={selectedOgretmen}
                onSelect={(u) => {
                  setSelectedOgretmen(u);
                  set("ogretmen_id", u?.id ?? "");
                }}
              />
            </div>
          </div>
          <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
            <input
              type="checkbox"
              checked={form.aktif}
              onChange={(e) => set("aktif", e.target.checked)}
            />
            {t("form.aktif")}
          </label>
          <ErrorNote message={formError} />
          <div className="flex justify-end gap-3">
            <button
              type="button"
              className={outlineBtn}
              onClick={() => { setForm(null); setSelectedOgretmen(null); }}
            >
              {t("form.cancel")}
            </button>
            <button type="submit" className={primaryBtn} disabled={saving}>
              {saving ? t("form.saving") : t("form.save")}
            </button>
          </div>
        </form>
      )}
    </section>
  );
}
