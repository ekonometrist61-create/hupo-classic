"use client";

import { useState } from "react";

import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
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

export interface PlanTipi {
  kod: string;
  ad: string;
  ad_en: string | null;
  aciklama: string | null;
  ozellikler: string[];
  ozellikler_en: string[];
  cta_metni: string;
  cta_en: string | null;
  vurgulu: boolean;
  sira: number;
  aktif: boolean;
}

interface FormState {
  kod: string;
  ad: string;
  ad_en: string;
  aciklama: string;
  ozellikler: string;
  ozellikler_en: string;
  cta_metni: string;
  cta_en: string;
  vurgulu: boolean;
  sira: string;
  aktif: boolean;
}

const EMPTY: FormState = {
  kod: "",
  ad: "",
  ad_en: "",
  aciklama: "",
  ozellikler: "",
  ozellikler_en: "",
  cta_metni: "Başla",
  cta_en: "",
  vurgulu: false,
  sira: "0",
  aktif: true,
};

const satirlar = (metin: string) =>
  metin.split("\n").map((s) => s.trim()).filter(Boolean);

export default function PlanTipiManager({
  tipler,
  onChanged,
}: {
  tipler: PlanTipi[];
  onChanged: () => void;
}) {
  const [form, setForm] = useState<FormState | null>(null);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const openNew = () => {
    setForm(EMPTY);
    setEditing(false);
    setError(null);
  };

  const openEdit = (t: PlanTipi) => {
    setForm({
      kod: t.kod,
      ad: t.ad,
      ad_en: t.ad_en ?? "",
      aciklama: t.aciklama ?? "",
      ozellikler: t.ozellikler.join("\n"),
      ozellikler_en: t.ozellikler_en.join("\n"),
      cta_metni: t.cta_metni,
      cta_en: t.cta_en ?? "",
      vurgulu: t.vurgulu,
      sira: String(t.sira),
      aktif: t.aktif,
    });
    setEditing(true);
    setError(null);
  };

  const set = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    setError(null);
    if (!/^[a-z0-9_]{2,30}$/.test(form.kod)) return setError("Tip kodu 2-30 karakter: küçük harf, rakam, alt çizgi.");
    if (form.ad.trim().length < 2) return setError("Tip adı en az 2 karakter olmalı.");
    if (!/^-?\d+$/.test(form.sira.trim())) return setError("Sıra bir tam sayı olmalı.");

    setSaving(true);
    const { error: err } = await createClient().rpc("admin_upsert_plan_tipi", {
      p_kod: form.kod,
      p_ad: form.ad.trim(),
      p_ad_en: form.ad_en.trim() || null,
      p_aciklama: form.aciklama.trim() || null,
      p_ozellikler: satirlar(form.ozellikler),
      p_ozellikler_en: satirlar(form.ozellikler_en),
      p_cta_metni: form.cta_metni.trim() || "Başla",
      p_cta_en: form.cta_en.trim() || null,
      p_vurgulu: form.vurgulu,
      p_sira: Number(form.sira),
      p_aktif: form.aktif,
    });
    setSaving(false);
    if (err) return setError(err.message);
    setForm(null);
    onChanged();
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="mb-2 flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">Paket tipleri</h3>
        <button type="button" className={outlineBtn} onClick={openNew}>
          Yeni tip
        </button>
      </div>
      <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
        Her aktif tip, web sitesinde bir fiyat kolonu olur. Özellik listesi her satır bir madde olacak şekilde girilir.
        Tipin altına bağlı aktif paketler kolonda fiyatla birlikte görünür.
      </p>

      {tipler.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">Henüz paket tipi yok.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th className={thClass}>Kod</th>
                <th className={thClass}>Ad</th>
                <th className={thClass}>Sıra</th>
                <th className={thClass}>Vurgulu</th>
                <th className={thClass}>Durum</th>
                <th className={thClass} />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {tipler.map((t) => (
                <tr key={t.kod}>
                  <td className={`${tdClass} font-mono`}>{t.kod}</td>
                  <td className={tdClass}>{t.ad}</td>
                  <td className={tdClass}>{t.sira}</td>
                  <td className={tdClass}>{t.vurgulu ? "Evet" : "—"}</td>
                  <td className={tdClass}>{t.aktif ? "Aktif" : "Pasif"}</td>
                  <td className={`${tdClass} text-end`}>
                    <button type="button" className={linkBtn} onClick={() => openEdit(t)}>
                      Düzenle
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {form && (
        <form onSubmit={submit} className="mt-6 space-y-4 rounded-xl border border-gray-200 p-4 dark:border-gray-800">
          <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">
            {editing ? "Tipi düzenle" : "Yeni paket tipi"}
          </h4>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className={labelClass} htmlFor="tip-kod">Kod</label>
              <input id="tip-kod" className={`${inputClass} font-mono`} value={form.kod} disabled={editing}
                maxLength={30} onChange={(e) => set("kod", e.target.value)} />
            </div>
            <div>
              <label className={labelClass} htmlFor="tip-ad">Ad (TR)</label>
              <input id="tip-ad" className={inputClass} value={form.ad} onChange={(e) => set("ad", e.target.value)} />
            </div>
            <div>
              <label className={labelClass} htmlFor="tip-ad-en">Ad (EN, boşsa TR)</label>
              <input id="tip-ad-en" className={inputClass} value={form.ad_en} onChange={(e) => set("ad_en", e.target.value)} />
            </div>
            <div>
              <label className={labelClass} htmlFor="tip-sira">Sıra</label>
              <input id="tip-sira" className={inputClass} inputMode="numeric" value={form.sira}
                onChange={(e) => set("sira", e.target.value)} />
            </div>
            <div>
              <label className={labelClass} htmlFor="tip-cta">Buton metni (TR)</label>
              <input id="tip-cta" className={inputClass} value={form.cta_metni} onChange={(e) => set("cta_metni", e.target.value)} />
            </div>
            <div>
              <label className={labelClass} htmlFor="tip-cta-en">Buton metni (EN, boşsa TR)</label>
              <input id="tip-cta-en" className={inputClass} value={form.cta_en} onChange={(e) => set("cta_en", e.target.value)} />
            </div>
          </div>
          <div>
            <label className={labelClass} htmlFor="tip-ozellik">Özellikler (TR, her satır bir madde)</label>
            <textarea id="tip-ozellik" rows={5} className={`${inputClass} h-auto`} value={form.ozellikler}
              onChange={(e) => set("ozellikler", e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="tip-ozellik-en">Özellikler (EN, her satır bir madde)</label>
            <textarea id="tip-ozellik-en" rows={5} className={`${inputClass} h-auto`} value={form.ozellikler_en}
              onChange={(e) => set("ozellikler_en", e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="tip-aciklama">Açıklama (iç not)</label>
            <textarea id="tip-aciklama" rows={2} className={`${inputClass} h-auto`} value={form.aciklama}
              onChange={(e) => set("aciklama", e.target.value)} />
          </div>
          <div className="flex flex-wrap gap-6">
            <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
              <input type="checkbox" checked={form.vurgulu} onChange={(e) => set("vurgulu", e.target.checked)} />
              Vurgulu (en çok tercih edilen rozeti)
            </label>
            <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
              <input type="checkbox" checked={form.aktif} onChange={(e) => set("aktif", e.target.checked)} />
              Aktif (sitede göster)
            </label>
          </div>
          <ErrorNote message={error} />
          <div className="flex justify-end gap-3">
            <button type="button" className={outlineBtn} onClick={() => setForm(null)}>Vazgeç</button>
            <button type="submit" className={primaryBtn} disabled={saving}>{saving ? "Kaydediliyor..." : "Kaydet"}</button>
          </div>
        </form>
      )}
    </section>
  );
}
