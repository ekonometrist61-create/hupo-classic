"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import DesktopOnly from "@/components/ui/DesktopOnly";
import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import { cardClass, inputClass, labelClass, linkBtn, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

interface Kupon {
  id: string;
  kod: string;
  tur: "yuzde" | "tutar" | "ucretsiz";
  deger: number;
  kampanya_ad: string | null;
  maks_kullanim: number | null;
  kullanim: number;
  rezerve: number;
  baslangic: string | null;
  bitis: string | null;
  aktif: boolean;
  yeni_uye_only: boolean;
  created_at: string;
}

interface Kampanya {
  id: string;
  ad: string;
  aciklama: string | null;
  baslangic: string | null;
  bitis: string | null;
  aktif: boolean;
  kupon_sayisi: number;
  kullanim: number;
  toplam_indirim_kurus: number;
}

interface FormState {
  kod: string;
  tur: string;
  deger: string;
  maks_kullanim: string;
  kullanici_basina: string;
  baslangic: string;
  bitis: string;
  aktif: boolean;
  yeni_uye_only: boolean;
  campaign_id: string;
}

const EMPTY_FORM: FormState = {
  kod: "",
  tur: "yuzde",
  deger: "10",
  maks_kullanim: "",
  kullanici_basina: "1",
  baslangic: "",
  bitis: "",
  aktif: true,
  yeni_uye_only: false,
  campaign_id: "",
};

const TUR_SECENEKLERI = ["yuzde", "tutar", "ucretsiz"] as const;
const TABS = ["kuponlar", "kampanyalar"] as const;

// Tablo (md ve üzeri) kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";

function formatTL(kurus: number) {
  return (kurus / 100).toFixed(2).replace(".", ",") + " ₺";
}

export default function KuponManager() {
  const t = useTranslations("yonetim.kuponlar");
  const [tab, setTab] = useState<"kuponlar" | "kampanyalar">("kuponlar");

  /* — Kuponlar — */
  const [kuponlar, setKuponlar] = useState<Kupon[]>([]);
  const [toplam, setToplam] = useState(0);
  const [page, setPage] = useState(0);
  const [aramaK, setAramaK] = useState("");
  const [aktifFil, setAktifFil] = useState<"" | "true" | "false">("");
  const [loadingK, setLoadingK] = useState(true);
  const [errorK, setErrorK] = useState<string | null>(null);
  const [reloadK, setReloadK] = useState(0);

  const [form, setForm] = useState<FormState | null>(null);
  const [editId, setEditId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  /* — Kampanyalar — */
  const [kampanyalar, setKampanyalar] = useState<Kampanya[]>([]);
  const [loadingKamp, setLoadingKamp] = useState(true);
  const [errorKamp, setErrorKamp] = useState<string | null>(null);
  const [reloadKamp, setReloadKamp] = useState(0);
  const [kampForm, setKampForm] = useState<{ ad: string; aciklama: string; aktif: boolean } | null>(null);
  const [kampEditId, setKampEditId] = useState<string | null>(null);
  const [kampSaving, setKampSaving] = useState(false);
  const [kampFormError, setKampFormError] = useState<string | null>(null);

  const PAGE_SIZE = 25;

  /* Kuponları yükle */
  useEffect(() => {
    let cancelled = false;
    setLoadingK(true);
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_list_coupons", {
        p_aktif: aktifFil === "" ? null : aktifFil === "true",
        p_arama: aramaK.trim() || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
        p_campaign_id: null,
      });
      if (cancelled) return;
      if (error) { setErrorK(error.message); } else {
        setErrorK(null);
        const d = data as { toplam: number; satirlar: Kupon[] };
        setKuponlar(d.satirlar ?? []);
        setToplam(d.toplam ?? 0);
      }
      setLoadingK(false);
    };
    void run();
    return () => { cancelled = true; };
  }, [aramaK, aktifFil, page, reloadK]);

  /* Kampanyaları yükle */
  useEffect(() => {
    if (tab !== "kampanyalar") return;
    let cancelled = false;
    setLoadingKamp(true);
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_list_campaigns");
      if (cancelled) return;
      if (error) { setErrorKamp(error.message); } else {
        setErrorKamp(null);
        setKampanyalar((data as Kampanya[]) ?? []);
      }
      setLoadingKamp(false);
    };
    void run();
    return () => { cancelled = true; };
  }, [tab, reloadKamp]);

  const reloadKuponlar = useCallback(() => setReloadK((k) => k + 1), []);
  const reloadKampanyalar = useCallback(() => setReloadKamp((k) => k + 1), []);

  const openNew = () => { setForm(EMPTY_FORM); setEditId(null); setFormError(null); };
  const openEdit = (k: Kupon) => {
    setForm({
      kod: k.kod,
      tur: k.tur,
      deger: String(k.deger),
      maks_kullanim: k.maks_kullanim !== null ? String(k.maks_kullanim) : "",
      kullanici_basina: "1",
      baslangic: k.baslangic ? k.baslangic.slice(0, 16) : "",
      bitis: k.bitis ? k.bitis.slice(0, 16) : "",
      aktif: k.aktif,
      yeni_uye_only: k.yeni_uye_only,
      campaign_id: "",
    });
    setEditId(k.id);
    setFormError(null);
  };

  const setF = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const submitKupon = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    setFormError(null);
    const deger = Number(form.deger);
    if (!form.kod.trim() && !editId) return setFormError(t("form.errCode"));
    if (isNaN(deger) || deger <= 0) return setFormError(t("form.errValue"));

    setSaving(true);
    const { error } = await createClient().rpc("admin_upsert_coupon", {
      p_id: editId ?? null,
      p_kod: editId ? "" : form.kod.trim().toUpperCase(),
      p_tur: form.tur,
      p_deger: deger,
      p_plan_kodlari: null,
      p_min_tutar_kurus: 0,
      p_maks_kullanim: form.maks_kullanim ? Number(form.maks_kullanim) : null,
      p_kullanici_basina: Number(form.kullanici_basina) || 1,
      p_baslangic: form.baslangic || null,
      p_bitis: form.bitis || null,
      p_aktif: form.aktif,
      p_yeni_uye_only: form.yeni_uye_only,
      p_ucretsiz_izin: form.tur === "ucretsiz",
      p_campaign_id: form.campaign_id || null,
    });
    setSaving(false);
    if (error) return setFormError(error.message);
    setForm(null);
    setEditId(null);
    reloadKuponlar();
  };

  const toggleAktif = async (id: string, aktif: boolean) => {
    await createClient().rpc("admin_set_coupon_active", { p_id: id, p_aktif: !aktif });
    reloadKuponlar();
  };

  const openKampNew = () => {
    setKampForm({ ad: "", aciklama: "", aktif: true });
    setKampEditId(null);
    setKampFormError(null);
  };
  const openKampEdit = (k: Kampanya) => {
    setKampForm({ ad: k.ad, aciklama: k.aciklama ?? "", aktif: k.aktif });
    setKampEditId(k.id);
    setKampFormError(null);
  };

  const submitKampanya = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!kampForm) return;
    if (!kampForm.ad.trim()) return setKampFormError(t("campaignForm.errName"));
    setKampSaving(true);
    const { error } = await createClient().rpc("admin_upsert_campaign", {
      p_id: kampEditId ?? null,
      p_ad: kampForm.ad.trim(),
      p_aciklama: kampForm.aciklama.trim() || null,
      p_baslangic: null,
      p_bitis: null,
      p_aktif: kampForm.aktif,
    });
    setKampSaving(false);
    if (error) return setKampFormError(error.message);
    setKampForm(null);
    setKampEditId(null);
    reloadKampanyalar();
  };

  const start = toplam === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(toplam, page * PAGE_SIZE + kuponlar.length);

  // Kupon türüne göre değer metni (kart ve tablo aynı kuralı kullanır).
  const degerMetni = (k: Kupon) =>
    k.tur === "yuzde" ? `%${k.deger}` : k.tur === "tutar" ? formatTL(k.deger) : t("valueFree");

  return (
    <div className="space-y-5">
      {/* Tab seçimi */}
      <div className="flex gap-1 rounded-xl border border-gray-200 bg-gray-50 p-1 dark:border-gray-800 dark:bg-gray-900">
        {TABS.map((id) => (
          <button
            key={id}
            type="button"
            aria-pressed={tab === id}
            onClick={() => setTab(id)}
            className={`min-h-11 flex-1 rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
              tab === id
                ? "bg-white text-gray-900 shadow-sm dark:bg-gray-800 dark:text-white"
                : "text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300"
            }`}
          >
            {t(`tabs.${id}`)}
          </button>
        ))}
      </div>

      {/* KUPONLAR */}
      {tab === "kuponlar" && (
        <section className={`${cardClass} p-5 sm:p-6`}>
          <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
            <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("tabs.kuponlar")}</h3>
            {/* Kupon oluşturma ve düzenleme masaüstüne özeldir (K3); telefonda bilgi notu görünür. */}
            <DesktopOnly>
              <button type="button" className={primaryBtn} onClick={openNew}>{t("newCoupon")}</button>
            </DesktopOnly>
          </div>

          <div className="mb-4 grid grid-cols-1 gap-3 sm:grid-cols-[minmax(0,1fr)_12rem]">
            <input
              className={inputClass}
              type="search"
              aria-label={t("searchPlaceholder")}
              placeholder={t("searchPlaceholder")}
              value={aramaK}
              onChange={(e) => { setAramaK(e.target.value); setPage(0); }}
            />
            <select
              className={inputClass}
              aria-label={t("filterLabel")}
              value={aktifFil}
              onChange={(e) => { setAktifFil(e.target.value as "" | "true" | "false"); setPage(0); }}
            >
              <option value="">{t("filterAll")}</option>
              <option value="true">{t("active")}</option>
              <option value="false">{t("passive")}</option>
            </select>
          </div>

          {loadingK ? (
            <p className="py-10 text-center text-sm text-gray-500">{t("loading")}</p>
          ) : errorK ? (
            <div className="py-8 text-center">
              <p className="mb-3 text-sm text-error-600">{errorK}</p>
              <button type="button" className={primaryBtn} onClick={reloadKuponlar}>{t("retry")}</button>
            </div>
          ) : kuponlar.length === 0 ? (
            <p className="py-10 text-center text-sm text-gray-500">{t("emptyCoupons")}</p>
          ) : (
            <>
              {/* Telefon ve küçük tablet (md altı): kart görünümü; işlem düğmeleri yok */}
              <ul className="space-y-3 md:hidden">
                {kuponlar.map((k) => (
                  <li key={k.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <p className="font-mono font-bold break-all text-gray-800 dark:text-white/90">{k.kod}</p>
                      <Badge size="sm" color={k.aktif ? "success" : "light"}>
                        {k.aktif ? t("active") : t("passive")}
                      </Badge>
                    </div>
                    <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-3 text-theme-sm">
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.typeValue")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">
                          {degerMetni(k)}
                          {k.yeni_uye_only && (
                            <span className="ms-2 rounded-full bg-purple-100 px-1.5 py-0.5 text-xs text-purple-700">{t("newMember")}</span>
                          )}
                        </dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.usage")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{k.kullanim} / {k.maks_kullanim ?? "∞"}</dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.end")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">
                          {k.bitis ? new Date(k.bitis).toLocaleDateString("tr-TR") : "—"}
                        </dd>
                      </div>
                    </dl>
                  </li>
                ))}
              </ul>

              {/* Tablet ve masaüstü (md ve üzeri): tablo; işlemler burada */}
              <div className={`hidden overflow-x-auto md:block ${ILK_SUTUN_SABIT}`}>
                <table className="min-w-full">
                  <thead className="border-b border-gray-100 dark:border-gray-800">
                    <tr>
                      <th className={thClass}>{t("cols.code")}</th>
                      <th className={thClass}>{t("cols.typeValue")}</th>
                      <th className={thClass}>{t("cols.usage")}</th>
                      <th className={thClass}>{t("cols.end")}</th>
                      <th className={thClass}>{t("cols.status")}</th>
                      <th className={thClass}><span className="sr-only">{t("cols.actions")}</span></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {kuponlar.map((k) => (
                      <tr key={k.id}>
                        <td className={`${tdClass} font-mono font-bold text-gray-800 dark:text-white/90`}>{k.kod}</td>
                        <td className={tdClass}>
                          <span className="text-xs">{degerMetni(k)}</span>
                          {k.yeni_uye_only && (
                            <span className="ms-2 rounded-full bg-purple-100 px-1.5 py-0.5 text-xs text-purple-700">{t("newMember")}</span>
                          )}
                        </td>
                        <td className={tdClass}>
                          {k.kullanim} / {k.maks_kullanim ?? "∞"}
                        </td>
                        <td className={tdClass}>
                          {k.bitis ? new Date(k.bitis).toLocaleDateString("tr-TR") : "—"}
                        </td>
                        <td className={tdClass}>
                          <Badge size="sm" color={k.aktif ? "success" : "light"}>
                            {k.aktif ? t("active") : t("passive")}
                          </Badge>
                        </td>
                        <td className={`${tdClass} whitespace-nowrap text-end`}>
                          <DesktopOnly>
                            <button type="button" className={`${linkBtn} inline-flex min-h-11 items-center`} onClick={() => openEdit(k)}>
                              {t("edit")}
                            </button>
                            <button
                              type="button"
                              className="ms-3 inline-flex min-h-11 items-center text-theme-sm font-medium text-gray-500 hover:text-gray-700 dark:text-gray-400"
                              onClick={() => toggleAktif(k.id, k.aktif)}
                            >
                              {k.aktif ? t("deactivate") : t("activate")}
                            </button>
                          </DesktopOnly>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {!loadingK && !errorK && toplam > PAGE_SIZE && (
            <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-theme-sm text-gray-500">
              <span>{start}–{end} / {toplam}</span>
              <div className="flex gap-2">
                <button
                  type="button"
                  disabled={page === 0}
                  className={outlineBtn}
                  aria-label={t("pager.prevLabel")}
                  onClick={() => setPage((p) => p - 1)}
                >
                  ←
                </button>
                <button
                  type="button"
                  disabled={end >= toplam}
                  className={outlineBtn}
                  aria-label={t("pager.nextLabel")}
                  onClick={() => setPage((p) => p + 1)}
                >
                  →
                </button>
              </div>
            </div>
          )}

          {form && (
            <ModalShell isOpen onClose={() => setForm(null)} title={editId ? t("form.editTitle") : t("form.createTitle")}>
              <form onSubmit={submitKupon} className="space-y-4">
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {!editId && (
                    <div>
                      <label className={labelClass} htmlFor="kp-kod">{t("form.code")} *</label>
                      <input
                        id="kp-kod"
                        className={`${inputClass} uppercase`}
                        placeholder="YAZI-1234"
                        value={form.kod}
                        onChange={(e) => setF("kod", e.target.value.toUpperCase())}
                      />
                      <p className="mt-1 text-xs text-gray-400">{t("form.codeHint")}</p>
                    </div>
                  )}
                  <div>
                    <label className={labelClass} htmlFor="kp-tur">{t("form.type")} *</label>
                    <select id="kp-tur" className={inputClass} value={form.tur} onChange={(e) => setF("tur", e.target.value)}>
                      {TUR_SECENEKLERI.map((v) => (
                        <option key={v} value={v}>{t(`types.${v}`)}</option>
                      ))}
                    </select>
                  </div>
                  {form.tur !== "ucretsiz" && (
                    <div>
                      <label className={labelClass} htmlFor="kp-deger">
                        {form.tur === "yuzde" ? t("form.percent") : t("form.amount")} *
                      </label>
                      <input
                        id="kp-deger"
                        className={inputClass}
                        inputMode="numeric"
                        value={form.deger}
                        onChange={(e) => setF("deger", e.target.value)}
                      />
                      {form.tur === "tutar" && <p className="mt-1 text-xs text-gray-400">{t("form.amountHint")}</p>}
                    </div>
                  )}
                  <div>
                    <label className={labelClass} htmlFor="kp-maks">{t("form.maxUsage")}</label>
                    <input
                      id="kp-maks"
                      className={inputClass}
                      inputMode="numeric"
                      value={form.maks_kullanim}
                      onChange={(e) => setF("maks_kullanim", e.target.value)}
                    />
                  </div>
                  <div>
                    <label className={labelClass} htmlFor="kp-bas">{t("form.start")}</label>
                    <input
                      id="kp-bas"
                      className={inputClass}
                      type="datetime-local"
                      value={form.baslangic}
                      onChange={(e) => setF("baslangic", e.target.value)}
                    />
                  </div>
                  <div>
                    <label className={labelClass} htmlFor="kp-bit">{t("form.end")}</label>
                    <input
                      id="kp-bit"
                      className={inputClass}
                      type="datetime-local"
                      value={form.bitis}
                      onChange={(e) => setF("bitis", e.target.value)}
                    />
                  </div>
                </div>
                <div className="flex flex-wrap gap-x-6 gap-y-1">
                  <label className="flex min-h-11 items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                    <input type="checkbox" className="h-4 w-4" checked={form.aktif} onChange={(e) => setF("aktif", e.target.checked)} />
                    {t("form.active")}
                  </label>
                  <label className="flex min-h-11 items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                    <input
                      type="checkbox"
                      className="h-4 w-4"
                      checked={form.yeni_uye_only}
                      onChange={(e) => setF("yeni_uye_only", e.target.checked)}
                    />
                    {t("form.newMembersOnly")}
                  </label>
                </div>
                <ErrorNote message={formError} />
                <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
                  <button type="button" className={outlineBtn} onClick={() => setForm(null)}>{t("form.cancel")}</button>
                  <button type="submit" className={primaryBtn} disabled={saving}>
                    {saving ? t("form.saving") : t("form.save")}
                  </button>
                </div>
              </form>
            </ModalShell>
          )}
        </section>
      )}

      {/* KAMPANYALAR */}
      {tab === "kampanyalar" && (
        <section className={`${cardClass} p-5 sm:p-6`}>
          <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
            <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("tabs.kampanyalar")}</h3>
            <DesktopOnly>
              <button type="button" className={primaryBtn} onClick={openKampNew}>{t("newCampaign")}</button>
            </DesktopOnly>
          </div>

          {loadingKamp ? (
            <p className="py-10 text-center text-sm text-gray-500">{t("loading")}</p>
          ) : errorKamp ? (
            <p className="py-8 text-center text-sm text-error-600">{errorKamp}</p>
          ) : kampanyalar.length === 0 ? (
            <p className="py-10 text-center text-sm text-gray-500">{t("emptyCampaigns")}</p>
          ) : (
            <>
              <ul className="space-y-3 md:hidden">
                {kampanyalar.map((k) => (
                  <li key={k.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">{k.ad}</p>
                      <Badge size="sm" color={k.aktif ? "success" : "light"}>{k.aktif ? t("active") : t("passive")}</Badge>
                    </div>
                    {k.aciklama && <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">{k.aciklama}</p>}
                    <dl className="mt-3 grid grid-cols-3 gap-x-4 gap-y-3 text-theme-sm">
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("campaignCols.count")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{k.kupon_sayisi}</dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.usage")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{k.kullanim}</dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("campaignCols.totalDiscount")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{formatTL(k.toplam_indirim_kurus)}</dd>
                      </div>
                    </dl>
                  </li>
                ))}
              </ul>

              <div className={`hidden overflow-x-auto md:block ${ILK_SUTUN_SABIT}`}>
                <table className="min-w-full">
                  <thead className="border-b border-gray-100 dark:border-gray-800">
                    <tr>
                      <th className={thClass}>{t("campaignCols.name")}</th>
                      <th className={thClass}>{t("campaignCols.count")}</th>
                      <th className={thClass}>{t("cols.usage")}</th>
                      <th className={thClass}>{t("campaignCols.totalDiscount")}</th>
                      <th className={thClass}>{t("cols.status")}</th>
                      <th className={thClass}><span className="sr-only">{t("cols.actions")}</span></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {kampanyalar.map((k) => (
                      <tr key={k.id}>
                        <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>
                          {k.ad}
                          {k.aciklama && <p className="mt-0.5 text-xs text-gray-400">{k.aciklama}</p>}
                        </td>
                        <td className={tdClass}>{k.kupon_sayisi}</td>
                        <td className={tdClass}>{k.kullanim}</td>
                        <td className={tdClass}>{formatTL(k.toplam_indirim_kurus)}</td>
                        <td className={tdClass}>
                          <Badge size="sm" color={k.aktif ? "success" : "light"}>{k.aktif ? t("active") : t("passive")}</Badge>
                        </td>
                        <td className={`${tdClass} text-end`}>
                          <DesktopOnly>
                            <button type="button" className={`${linkBtn} inline-flex min-h-11 items-center`} onClick={() => openKampEdit(k)}>
                              {t("edit")}
                            </button>
                          </DesktopOnly>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {kampForm && (
            <ModalShell isOpen onClose={() => setKampForm(null)} title={kampEditId ? t("campaignForm.editTitle") : t("campaignForm.createTitle")}>
              <form onSubmit={submitKampanya} className="space-y-4">
                <div>
                  <label className={labelClass} htmlFor="kmp-ad">{t("campaignForm.name")} *</label>
                  <input
                    id="kmp-ad"
                    className={inputClass}
                    value={kampForm.ad}
                    onChange={(e) => setKampForm((f) => f && { ...f, ad: e.target.value })}
                  />
                </div>
                <div>
                  <label className={labelClass} htmlFor="kmp-aciklama">{t("campaignForm.description")}</label>
                  <input
                    id="kmp-aciklama"
                    className={inputClass}
                    value={kampForm.aciklama}
                    onChange={(e) => setKampForm((f) => f && { ...f, aciklama: e.target.value })}
                  />
                </div>
                <label className="flex min-h-11 items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                  <input
                    type="checkbox"
                    className="h-4 w-4"
                    checked={kampForm.aktif}
                    onChange={(e) => setKampForm((f) => f && { ...f, aktif: e.target.checked })}
                  />
                  {t("form.active")}
                </label>
                <ErrorNote message={kampFormError} />
                <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
                  <button type="button" className={outlineBtn} onClick={() => setKampForm(null)}>{t("form.cancel")}</button>
                  <button type="submit" className={primaryBtn} disabled={kampSaving}>
                    {kampSaving ? t("form.saving") : t("form.save")}
                  </button>
                </div>
              </form>
            </ModalShell>
          )}
        </section>
      )}
    </div>
  );
}
