"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import Badge from "@/components/ui/badge/Badge";
import SurfacePicker from "@/components/yonetim/merkez/SurfacePicker";
import type { SurveySurface } from "@/components/yonetim/merkez/types";
import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { isoToTurkiyeInput, turkiyeInputToIso } from "@/components/yonetim/turkiyeTarih";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, labelClass, linkBtn, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

interface Duyuru {
  id: string;
  baslik: string;
  metin: string;
  aktif: boolean;
  bitis_at: string | null;
  yuzeyler: SurveySurface[];
  created_at: string;
  updated_at: string;
}

interface FormState {
  id: string | null;
  baslik: string;
  metin: string;
  aktif: boolean;
  /** datetime-local (Türkiye saati); boşsa süresiz */
  bitis: string;
  yuzeyler: SurveySurface[];
}

const BASLIK_MAX = 120;
const METIN_MAX = 500;

const EMPTY_FORM: FormState = { id: null, baslik: "", metin: "", aktif: true, bitis: "", yuzeyler: ["web_sitesi"] };

type Durum = "yayinda" | "suresi_doldu" | "pasif";

const DURUM_ETIKET: Record<Durum, string> = {
  yayinda: "Yayında",
  suresi_doldu: "Süresi doldu",
  pasif: "Pasif",
};

const DURUM_RENK: Record<Durum, "success" | "warning" | "light"> = {
  yayinda: "success",
  suresi_doldu: "warning",
  pasif: "light",
};

function durumOf(d: Duyuru, simdi: number): Durum {
  if (!d.aktif) return "pasif";
  if (d.bitis_at && new Date(d.bitis_at).getTime() <= simdi) return "suresi_doldu";
  return "yayinda";
}

function tarihYaz(iso: string): string {
  return new Date(iso).toLocaleString("tr-TR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default function DuyuruManager() {
  const t = useTranslations("yonetim.merkez.surveys");
  const state = useAdminRpc<Duyuru[]>("admin_list_duyurular");
  // Durum (yayında / süresi doldu) render anında hesaplanır; saat bileşen ömrü boyunca sabit kalır.
  const [simdi] = useState(() => Date.now());

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [rowBusy, setRowBusy] = useState<string | null>(null);
  const [rowError, setRowError] = useState<string | null>(null);

  const duyurular = state.data ?? [];

  const setF = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const yeni = () => {
    setForm(EMPTY_FORM);
    setFormError(null);
    setNotice(null);
  };

  const duzenle = (d: Duyuru) => {
    setForm({
      id: d.id,
      baslik: d.baslik,
      metin: d.metin,
      aktif: d.aktif,
      bitis: d.bitis_at ? isoToTurkiyeInput(d.bitis_at) : "",
      yuzeyler: d.yuzeyler,
    });
    setFormError(null);
    setNotice(null);
  };

  const kaydet = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    const baslik = form.baslik.trim();
    const metin = form.metin.trim();
    if (!baslik) return setFormError("Başlık boş olamaz.");
    if (!metin) return setFormError("Metin boş olamaz.");
    if (form.yuzeyler.length === 0) return setFormError("En az bir yayın mecrası seçin.");

    let bitisIso: string | null = null;
    if (form.bitis) {
      bitisIso = turkiyeInputToIso(form.bitis);
      if (!bitisIso) return setFormError("Bitiş tarihi geçerli değil.");
    }

    setSaving(true);
    setFormError(null);
    const r = await adminCall("admin_save_duyuru", {
      p_id: form.id,
      p_baslik: baslik,
      p_metin: metin,
      p_aktif: form.aktif,
      p_bitis_at: bitisIso,
      p_yuzeyler: form.yuzeyler,
    });
    setSaving(false);
    if (r.error) return setFormError(r.error);

    setForm(null);
    setNotice(form.id ? "Duyuru güncellendi." : "Duyuru oluşturuldu.");
    state.reload();
  };

  const aktifDegistir = async (d: Duyuru) => {
    setRowBusy(d.id);
    setRowError(null);
    setNotice(null);
    const r = await adminCall("admin_save_duyuru", {
      p_id: d.id,
      p_baslik: d.baslik,
      p_metin: d.metin,
      p_aktif: !d.aktif,
      p_bitis_at: d.bitis_at,
      p_yuzeyler: d.yuzeyler,
    });
    setRowBusy(null);
    if (r.error) return setRowError(r.error);

    setNotice(d.aktif ? "Duyuru yayından kaldırıldı." : "Duyuru yayına alındı.");
    state.reload();
  };

  return (
    <div className="space-y-6">
      {/* Oluştur / düzenle */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-2 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">Duyurular</h3>
          {!form && (
            <button type="button" className={primaryBtn} onClick={yeni}>
              + Yeni Duyuru
            </button>
          )}
        </div>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
          Yayındaki en yeni duyuru, seçtiğiniz mecralarda gösterilir. Süresi dolan veya pasif duyurular görünmez.
        </p>

        {notice && !form && (
          <div className="mb-4 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-400">
            {notice}
          </div>
        )}

        {form && (
          <form onSubmit={kaydet} className="space-y-4">
            <div>
              <label className={labelClass} htmlFor="d-baslik">Başlık *</label>
              <input
                id="d-baslik"
                className={inputClass}
                maxLength={BASLIK_MAX}
                value={form.baslik}
                onChange={(e) => setF("baslik", e.target.value)}
                placeholder="Örn. Türkiye Geneli Deneme Sınavı kayıtları açıldı"
              />
              <p className="mt-1 text-xs text-gray-400">{form.baslik.length}/{BASLIK_MAX}</p>
            </div>

            <div>
              <label className={labelClass} htmlFor="d-metin">Metin *</label>
              <textarea
                id="d-metin"
                className={`${inputClass} h-auto min-h-24 resize-y py-2.5`}
                maxLength={METIN_MAX}
                value={form.metin}
                onChange={(e) => setF("metin", e.target.value)}
                placeholder="Ziyaretçilere gösterilecek kısa metin..."
              />
              <p className="mt-1 text-xs text-gray-400">{form.metin.length}/{METIN_MAX}</p>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className={labelClass} htmlFor="d-bitis">Bitiş tarihi (isteğe bağlı)</label>
                <div className="flex items-center gap-2">
                  <input
                    id="d-bitis"
                    type="datetime-local"
                    className={inputClass}
                    value={form.bitis}
                    onChange={(e) => setF("bitis", e.target.value)}
                  />
                  {form.bitis && (
                    <button type="button" className={outlineBtn} onClick={() => setF("bitis", "")}>
                      Temizle
                    </button>
                  )}
                </div>
                <p className="mt-1 text-xs text-gray-400">
                  Boş bırakılırsa süresiz yayında kalır. Türkiye saati (UTC+3).
                </p>
              </div>

              <div className="flex items-end">
                <label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                  <input
                    type="checkbox"
                    className="h-4 w-4 rounded border-gray-300"
                    checked={form.aktif}
                    onChange={(e) => setF("aktif", e.target.checked)}
                  />
                  Yayında (seçili mecralarda görünsün)
                </label>
              </div>
            </div>

            <SurfacePicker
              value={form.yuzeyler}
              onChange={(v) => setF("yuzeyler", v)}
              legend="Yayın mecraları"
              help="Duyuru yalnızca seçili mecralarda gösterilir."
              requiredMessage="Kaydetmek için en az bir yayın mecrası seçin."
              surfaceLabel={(y) => t(`surfaces.${y}`)}
            />

            <ErrorNote message={formError} />
            <div className="flex justify-end gap-3">
              <button type="button" className={outlineBtn} onClick={() => setForm(null)}>Vazgeç</button>
              <button type="submit" className={primaryBtn} disabled={saving || form.yuzeyler.length === 0}>
                {saving ? "Kaydediliyor..." : "Kaydet"}
              </button>
            </div>
          </form>
        )}
      </section>

      {/* Liste */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">Duyurular</h3>

        {rowError && <div className="mb-4"><ErrorNote message={rowError} /></div>}

        {state.loading ? (
          <p className="py-10 text-center text-sm text-gray-500">Yükleniyor...</p>
        ) : state.missing ? (
          <p className="py-10 text-center text-sm text-error-600">
            Duyuru tablosu veritabanında yok. 20261026000000_site_duyurulari migration&apos;ı uygulanmalı.
          </p>
        ) : state.error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600">{state.error}</p>
            <button type="button" className={primaryBtn} onClick={state.reload}>Tekrar Dene</button>
          </div>
        ) : duyurular.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500">Henüz duyuru yok.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>Duyuru</th>
                  <th className={thClass}>Durum</th>
                  <th className={thClass}>Bitiş</th>
                  <th className={thClass}>Son güncelleme</th>
                  <th className={thClass}>İşlem</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {duyurular.map((d) => {
                  const durum = durumOf(d, simdi);
                  return (
                    <tr key={d.id}>
                      <td className={`${tdClass} max-w-md`}>
                        <p className="font-medium text-gray-800 dark:text-white/90">{d.baslik}</p>
                        <p className="mt-0.5 line-clamp-2 text-xs text-gray-500 dark:text-gray-400">{d.metin}</p>
                        <div className="mt-2 flex flex-wrap gap-1.5">
                          {d.yuzeyler.map((y) => (
                            <Badge key={y} size="sm" color="light">{t(`surfaceShort.${y}`)}</Badge>
                          ))}
                        </div>
                      </td>
                      <td className={tdClass}>
                        <Badge size="sm" color={DURUM_RENK[durum]}>{DURUM_ETIKET[durum]}</Badge>
                      </td>
                      <td className={`${tdClass} whitespace-nowrap text-xs text-gray-500`}>
                        {d.bitis_at ? tarihYaz(d.bitis_at) : "Süresiz"}
                      </td>
                      <td className={`${tdClass} whitespace-nowrap text-xs text-gray-500`}>
                        {tarihYaz(d.updated_at)}
                      </td>
                      <td className={`${tdClass} whitespace-nowrap`}>
                        <div className="flex items-center gap-4">
                          <button type="button" className={linkBtn} onClick={() => duzenle(d)}>
                            Düzenle
                          </button>
                          <button
                            type="button"
                            className={linkBtn}
                            disabled={rowBusy === d.id}
                            onClick={() => aktifDegistir(d)}
                          >
                            {d.aktif ? "Yayından kaldır" : "Yayına al"}
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
