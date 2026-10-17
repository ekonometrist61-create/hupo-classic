"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import Badge from "@/components/ui/badge/Badge";
import SurfacePicker from "@/components/yonetim/merkez/SurfacePicker";
import { DUYURU_SURFACES, type SurveySurface } from "@/components/yonetim/merkez/types";
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
  /** Yayınlanmış duyuru silinemez; null ise hiç yayınlanmamış (taslak). */
  yayinlandi_at: string | null;
  arsivlendi_at: string | null;
  created_at: string;
  updated_at: string;
}

interface FormState {
  id: string | null;
  baslik: string;
  metin: string;
  aktif: boolean;
  /** Form açıldığındaki yayın durumu; false iken aktif yapmak yayına almaktır (çift onay). */
  ilkAktif: boolean;
  /** Arşivli duyuru yayına alınamaz; onay kutusu kilitlenir. */
  arsivli: boolean;
  /** datetime-local (Türkiye saati); boşsa süresiz */
  bitis: string;
  yuzeyler: SurveySurface[];
}

const BASLIK_MAX = 120;
const METIN_MAX = 500;

const EMPTY_FORM: FormState = {
  id: null,
  baslik: "",
  metin: "",
  aktif: true,
  ilkAktif: false,
  arsivli: false,
  bitis: "",
  yuzeyler: ["web_sitesi"],
};

type Durum = "yayinda" | "suresi_doldu" | "pasif" | "arsivde";

const DURUM_RENK: Record<Durum, "success" | "warning" | "light"> = {
  yayinda: "success",
  suresi_doldu: "warning",
  pasif: "light",
  arsivde: "light",
};

// Satır eylemleri: dokunma hedefi en az 44 px.
const EYLEM_BTN = `${linkBtn} inline-flex min-h-11 items-center disabled:opacity-50`;

function durumOf(d: Duyuru, simdi: number): Durum {
  if (d.arsivlendi_at) return "arsivde";
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
  const t = useTranslations("yonetim.duyurular");
  const tMecra = useTranslations("yonetim.merkez.surveys");
  const [arsiv, setArsiv] = useState(false);
  const state = useAdminRpc<Duyuru[]>("admin_list_duyurular", { p_arsiv: arsiv });
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
      ilkAktif: d.aktif,
      arsivli: d.arsivlendi_at !== null,
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
    if (!baslik) return setFormError(t("form.errTitle"));
    if (!metin) return setFormError(t("form.errText"));
    if (form.yuzeyler.length === 0) return setFormError(t("form.errSurface"));

    let bitisIso: string | null = null;
    if (form.bitis) {
      bitisIso = turkiyeInputToIso(form.bitis);
      if (!bitisIso) return setFormError(t("form.errEndDate"));
    }

    // Yayına alma çift onay ister: kaydet düğmesi, ardından onay penceresi.
    if (form.aktif && !form.ilkAktif && !window.confirm(t("form.publishConfirm"))) return;

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
    setNotice(form.id ? t("notice.updated") : t("notice.created"));
    state.reload();
  };

  // Yayına alma (aktif = false → true) çift onay ister; yayından kaldırma onaysızdır.
  const aktifDegistir = async (d: Duyuru) => {
    if (!d.aktif && !window.confirm(t("form.publishConfirm"))) return;
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

    setNotice(d.aktif ? t("notice.unpublished") : t("notice.published"));
    state.reload();
  };

  const arsivDegistir = async (d: Duyuru, arsivle: boolean) => {
    setRowBusy(d.id);
    setRowError(null);
    setNotice(null);
    const r = await adminCall("admin_duyuru_arsivle", { p_id: d.id, p_arsivle: arsivle });
    setRowBusy(null);
    if (r.error) return setRowError(r.error);

    // Arşivden çıkan duyuru pasif kalır; yayına almak ayrı bir karardır.
    setNotice(arsivle ? t("notice.archived") : t("notice.unarchived"));
    state.reload();
  };

  const sil = async (d: Duyuru) => {
    if (!window.confirm(t("list.deleteConfirm", { baslik: d.baslik }))) return;
    setRowBusy(d.id);
    setRowError(null);
    setNotice(null);
    const r = await adminCall("admin_duyuru_sil", { p_id: d.id });
    setRowBusy(null);
    if (r.error) return setRowError(r.error);

    setNotice(t("notice.draftDeleted"));
    state.reload();
  };

  // Satır eylemleri: kart ve tabloda aynı düğmeler kullanılır.
  const islemler = (d: Duyuru) => (
    <>
      <button type="button" className={EYLEM_BTN} onClick={() => duzenle(d)}>
        {t("actions.edit")}
      </button>
      {!arsiv && (
        <button type="button" className={EYLEM_BTN} disabled={rowBusy === d.id} onClick={() => aktifDegistir(d)}>
          {d.aktif ? t("actions.unpublish") : t("actions.publish")}
        </button>
      )}
      {!arsiv && (
        <button type="button" className={EYLEM_BTN} disabled={rowBusy === d.id} onClick={() => arsivDegistir(d, true)}>
          {t("actions.archive")}
        </button>
      )}
      {arsiv && (
        <button type="button" className={EYLEM_BTN} disabled={rowBusy === d.id} onClick={() => arsivDegistir(d, false)}>
          {t("actions.unarchive")}
        </button>
      )}
      {d.yayinlandi_at === null && (
        <button
          type="button"
          className={`${EYLEM_BTN} text-error-600 hover:text-error-700`}
          disabled={rowBusy === d.id}
          onClick={() => sil(d)}
        >
          {t("actions.delete")}
        </button>
      )}
    </>
  );

  return (
    <div className="space-y-6">
      {/* Oluştur / düzenle */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-2 flex items-center justify-between gap-3">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h3>
          {!form && (
            <button type="button" className={primaryBtn} onClick={yeni}>
              {t("newAnnouncement")}
            </button>
          )}
        </div>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("intro")}</p>

        {notice && !form && (
          <div className="mb-4 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-400">
            {notice}
          </div>
        )}

        {form && (
          <form onSubmit={kaydet} className="space-y-4">
            <div>
              <label className={labelClass} htmlFor="d-baslik">{t("form.title")} *</label>
              <input
                id="d-baslik"
                className={inputClass}
                maxLength={BASLIK_MAX}
                value={form.baslik}
                onChange={(e) => setF("baslik", e.target.value)}
                placeholder={t("form.titlePlaceholder")}
              />
              <p className="mt-1 text-xs text-gray-400">{form.baslik.length}/{BASLIK_MAX}</p>
            </div>

            <div>
              <label className={labelClass} htmlFor="d-metin">{t("form.text")} *</label>
              <textarea
                id="d-metin"
                className={`${inputClass} h-auto min-h-24 resize-y py-2.5`}
                maxLength={METIN_MAX}
                value={form.metin}
                onChange={(e) => setF("metin", e.target.value)}
                placeholder={t("form.textPlaceholder")}
              />
              <p className="mt-1 text-xs text-gray-400">{form.metin.length}/{METIN_MAX}</p>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className={labelClass} htmlFor="d-bitis">{t("form.endDate")}</label>
                <div className="flex items-center gap-2">
                  <input
                    id="d-bitis"
                    type="datetime-local"
                    className={`${inputClass} min-w-0 flex-1`}
                    value={form.bitis}
                    onChange={(e) => setF("bitis", e.target.value)}
                  />
                  {form.bitis && (
                    <button type="button" className={outlineBtn} onClick={() => setF("bitis", "")}>
                      {t("form.clear")}
                    </button>
                  )}
                </div>
                <p className="mt-1 text-xs text-gray-400">{t("form.endHint")}</p>
              </div>

              <div className="flex items-end">
                <label className="flex min-h-11 cursor-pointer items-center gap-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                  <input
                    type="checkbox"
                    className="h-4 w-4 rounded border-gray-300"
                    checked={form.aktif}
                    disabled={form.arsivli}
                    onChange={(e) => setF("aktif", e.target.checked)}
                  />
                  {t("form.active")}
                </label>
                {form.arsivli && (
                  <span className="ms-2 text-xs text-gray-500">{t("form.archivedLocked")}</span>
                )}
              </div>
            </div>

            <SurfacePicker
              surfaces={DUYURU_SURFACES}
              value={form.yuzeyler}
              onChange={(v) => setF("yuzeyler", v)}
              legend={t("form.surfacesLegend")}
              help={t("form.surfacesHelp")}
              requiredMessage={t("form.surfacesRequired")}
              surfaceLabel={(y) => tMecra(`surfaces.${y}`)}
            />

            <ErrorNote message={formError} />
            <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
              <button type="button" className={outlineBtn} onClick={() => setForm(null)}>{t("form.cancel")}</button>
              <button type="submit" className={primaryBtn} disabled={saving || form.yuzeyler.length === 0}>
                {saving ? t("form.saving") : t("form.save")}
              </button>
            </div>
          </form>
        )}
      </section>

      {/* Liste */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-center gap-2 text-xs">
          <h3 className="me-2 text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h3>
          {[
            { id: false, label: t("list.active") },
            { id: true, label: t("list.archive") },
          ].map((o) => (
            <button
              key={String(o.id)}
              type="button"
              aria-pressed={arsiv === o.id}
              onClick={() => {
                setArsiv(o.id);
                setRowError(null);
              }}
              className={`inline-flex min-h-11 items-center rounded-full px-4 py-1.5 font-medium ${
                arsiv === o.id ? "bg-brand-500 text-white" : "bg-gray-100 text-gray-600 dark:bg-white/5 dark:text-gray-300"
              }`}
            >
              {o.label}
            </button>
          ))}
          <span className="text-gray-500 dark:text-gray-400">{t("list.help")}</span>
        </div>

        {rowError && <div className="mb-4"><ErrorNote message={rowError} /></div>}

        {state.loading ? (
          <p className="py-10 text-center text-sm text-gray-500">{t("list.loading")}</p>
        ) : state.missing ? (
          <p className="py-10 text-center text-sm text-error-600">{t("list.missingTable")}</p>
        ) : state.error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600">{state.error}</p>
            <button type="button" className={primaryBtn} onClick={state.reload}>{t("list.retry")}</button>
          </div>
        ) : duyurular.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500">{t("list.empty")}</p>
        ) : (
          <>
            {/* Telefon ve küçük tablet (md altı): kart görünümü; eylemler kartın altında */}
            <ul className="space-y-3 md:hidden">
              {duyurular.map((d) => {
                const durum = durumOf(d, simdi);
                return (
                  <li key={d.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                      <p className="min-w-0 font-medium wrap-break-word text-gray-800 dark:text-white/90">{d.baslik}</p>
                      <Badge size="sm" color={DURUM_RENK[durum]}>{t(`status.${durum}`)}</Badge>
                    </div>
                    <p className="mt-1 line-clamp-2 text-xs text-gray-500 dark:text-gray-400">{d.metin}</p>
                    <div className="mt-2 flex flex-wrap gap-1.5">
                      {d.yuzeyler.map((y) => (
                        <Badge key={y} size="sm" color="light">{tMecra(`surfaceShort.${y}`)}</Badge>
                      ))}
                    </div>
                    <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-xs text-gray-500 dark:text-gray-400">
                      <div>
                        <dt>{t("cols.end")}</dt>
                        <dd className="text-gray-700 dark:text-gray-300">{d.bitis_at ? tarihYaz(d.bitis_at) : t("list.noEnd")}</dd>
                      </div>
                      <div>
                        <dt>{t("cols.updated")}</dt>
                        <dd className="text-gray-700 dark:text-gray-300">{tarihYaz(d.updated_at)}</dd>
                      </div>
                    </dl>
                    <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 border-t border-gray-100 pt-2 dark:border-gray-800">
                      {islemler(d)}
                    </div>
                  </li>
                );
              })}
            </ul>

            {/* Tablet ve masaüstü (md ve üzeri): tablo; kapsayıcısı kayar */}
            <div className="hidden overflow-x-auto md:block">
              <table className="min-w-full">
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th className={thClass}>{t("cols.announcement")}</th>
                    <th className={thClass}>{t("cols.status")}</th>
                    <th className={thClass}>{t("cols.end")}</th>
                    <th className={thClass}>{t("cols.updated")}</th>
                    <th className={thClass}>{t("cols.actions")}</th>
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
                              <Badge key={y} size="sm" color="light">{tMecra(`surfaceShort.${y}`)}</Badge>
                            ))}
                          </div>
                        </td>
                        <td className={tdClass}>
                          <Badge size="sm" color={DURUM_RENK[durum]}>{t(`status.${durum}`)}</Badge>
                        </td>
                        <td className={`${tdClass} whitespace-nowrap text-xs text-gray-500`}>
                          {d.bitis_at ? tarihYaz(d.bitis_at) : t("list.noEnd")}
                        </td>
                        <td className={`${tdClass} whitespace-nowrap text-xs text-gray-500`}>
                          {tarihYaz(d.updated_at)}
                        </td>
                        <td className={`${tdClass} whitespace-nowrap`}>
                          <div className="flex flex-wrap items-center gap-x-4 gap-y-1">{islemler(d)}</div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </>
        )}
      </section>
    </div>
  );
}
