"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useLocale, useTranslations } from "next-intl";

import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import Badge from "@/components/ui/badge/Badge";
import DesktopOnly from "@/components/ui/DesktopOnly";
import { useCurrentRole } from "@/hooks/useCurrentRole";
import { DEMO_MODE } from "@/lib/demo-mode";
import { createClient } from "@/utils/supabase/client";
import type { AdminUser } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import OgretmenPicker from "./OgretmenPicker";
import {
  cardClass,
  inputClass,
  labelClass,
  outlineBtn,
  primaryBtn,
  tdClass,
  thClass,
} from "./styles";

/** Admin listesinin satırı (admin_list_siniflar). */
interface SinifSatiri {
  id: string;
  ad: string;
  sinif_seviyesi: number;
  okul_adi: string | null;
  yil: number;
  aktif: boolean;
  ogretmen_adi: string | null;
  ogretmen_id: string | null;
  ogrenci_sayisi: number;
}

/** Öğretmen raporu satırı (ogretmen_siniflarim). Kişisel veri içermez.
 *  Sınıfta yeterli etkinlik yoksa ilerleme_gosterilir = false ve ilerleme alanları null gelir. */
interface SinifRaporu {
  id: string;
  ad: string;
  sinif_seviyesi: number;
  okul_adi: string | null;
  yil: number;
  aktif: boolean;
  ogrenci_sayisi: number;
  ilerleme_gosterilir: boolean;
  aktif_ogrenci_7g: number | null;
  ortalama_dogru_orani: number | null;
  bekleyen_tekrar: number | null;
  son_aktivite: string | null;
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

// Düzenle bağlantısı dokunma hedefi olarak en az 44 px (TASKS §20).
const satirDugmesi =
  "inline-flex min-h-11 items-center justify-center rounded-lg px-3 text-theme-sm font-medium text-brand-500 transition hover:text-brand-600 dark:text-brand-400";

function tarihMetni(iso: string | null, locale: string): string {
  if (!iso) return "-";
  return new Intl.DateTimeFormat(locale === "en" ? "en-US" : "tr-TR", {
    day: "numeric",
    month: "short",
    year: "numeric",
  }).format(new Date(iso));
}

function Olcu({ etiket, deger }: { etiket: string; deger: string }) {
  return (
    <div>
      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{etiket}</dt>
      <dd className="font-medium text-gray-800 dark:text-white/90">{deger}</dd>
    </div>
  );
}

/** Sınıf listesi. Öğretmen (salt okunur rapor) ve admin (düzenleme) aynı bileşende.
 *  Yazma işlemleri yalnızca admin için açılır; yetki yine veritabanında (admin_upsert_sinif) kontrol edilir. */
export default function SiniflarManager() {
  const t = useTranslations("yonetim.siniflar");
  const tAciklama = useTranslations("yonetim.shell.pageDesc");
  const locale = useLocale();
  const fetchedRole = useCurrentRole();
  // Demo modunda oturum yoktur; yönetici görünümü önizlenir (diğer yönetim bileşenleriyle aynı kalıp).
  const role = DEMO_MODE ? "admin" : fetchedRole;
  const yonetici = role === "admin";
  const ogretmen = role === "ogretmen";

  const [satirlar, setSatirlar] = useState<SinifSatiri[]>([]);
  const [raporlar, setRaporlar] = useState<SinifRaporu[]>([]);
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

  const ilkAlanRef = useRef<HTMLInputElement>(null);
  const formAcik = form !== null;

  // Rol çözülmeden veri çekilmez. Öğretmen raporu ayrı RPC'den, admin listesi sayfalı RPC'den gelir.
  useEffect(() => {
    if (!yonetici && !ogretmen) return;
    let cancelled = false;
    const run = async () => {
      setLoading(true);
      const supabase = createClient();
      if (ogretmen) {
        const { data, error: err } = await supabase.rpc("ogretmen_siniflarim");
        if (cancelled) return;
        if (err) {
          setError(err.message);
        } else {
          setError(null);
          setRaporlar((data as { siniflar: SinifRaporu[] }).siniflar ?? []);
        }
      } else {
        const { data, error: err } = await supabase.rpc("admin_list_siniflar", {
          p_limit: PAGE_SIZE,
          p_offset: page * PAGE_SIZE,
        });
        if (cancelled) return;
        if (err) {
          setError(err.message);
        } else {
          setError(null);
          const res = data as { satirlar: SinifSatiri[]; toplam: number };
          setSatirlar(res.satirlar ?? []);
          setToplam(res.toplam ?? 0);
        }
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [ogretmen, yonetici, page, reloadKey]);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  // Form açılınca ilk alana odaklan (Y1). Modal açılışta kapat düğmesine odaklanır; bu etki onu geçersiz kılar.
  useEffect(() => {
    if (formAcik) ilkAlanRef.current?.focus();
  }, [formAcik]);

  const formuKapat = () => {
    setForm(null);
    setEditing(null);
    setSelectedOgretmen(null);
    setFormError(null);
  };

  const openNew = () => {
    setForm(EMPTY);
    setEditing(null);
    setSelectedOgretmen(null);
    setFormError(null);
  };

  const openEdit = (s: SinifSatiri) => {
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

  const f = form ?? EMPTY;
  const set = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((cur) => (cur ? { ...cur, [k]: v } : cur));

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
    formuKapat();
    reload();
  };

  const baslik = ogretmen
    ? t("teacherTitle")
    : yonetici
      ? t("title")
      : t("genelTitle");
  const aciklama = ogretmen ? t("teacherDesc") : tAciklama("classes");
  // Yeni sınıf oluşturma masaüstü-only (TASKS §20, K3): telefonda işlem gizlenir, not gösterilir.
  const eylemler = yonetici ? (
    <DesktopOnly>
      <button type="button" className={outlineBtn} onClick={openNew}>
        {t("new")}
      </button>
    </DesktopOnly>
  ) : undefined;

  const seviyeMetni = (n: number) => t("seviyeEtiket", { seviye: n });
  // İlerleme değeri yoksa (yeterli etkinlik yok) "Veri yetersiz" gösterilir.
  const ilerleme = (r: SinifRaporu, deger: number | null, ek = "") =>
    r.ilerleme_gosterilir && deger !== null ? `${deger}${ek}` : t("ilerlemeYetersiz");

  const bos = ogretmen ? raporlar.length === 0 : satirlar.length === 0;
  const start = toplam === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(toplam, page * PAGE_SIZE + satirlar.length);

  return (
    <>
      <PageBreadcrumb pageTitle={baslik} description={aciklama} actions={eylemler} />

      <section className={`${cardClass} p-5 sm:p-6`}>
        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
            {t("loading")}
          </p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{error}</p>
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
        ) : bos ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
            {ogretmen ? t("emptyTeacher") : t("empty")}
          </p>
        ) : ogretmen ? (
          <>
            <p className="mb-4 text-theme-xs text-gray-500 dark:text-gray-400">
              {t("ilerlemeNot")}
            </p>

            {/* Telefon ve küçük tablet (md altı): kart görünümü */}
            <ul className="space-y-3 md:hidden">
              {raporlar.map((s) => (
                <li
                  key={s.id}
                  className="rounded-xl border border-gray-200 p-4 dark:border-gray-800"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">
                        {s.ad}
                      </p>
                      <p className="text-theme-sm text-gray-500 dark:text-gray-400">
                        {seviyeMetni(s.sinif_seviyesi)}
                        {s.okul_adi ? ` · ${s.okul_adi}` : ""}
                      </p>
                    </div>
                    <Badge size="sm" color={s.aktif ? "success" : "light"}>
                      {s.aktif ? t("active") : t("inactive")}
                    </Badge>
                  </div>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-3 text-theme-sm">
                    <Olcu etiket={t("cols.ogrenciler")} deger={String(s.ogrenci_sayisi)} />
                    <Olcu etiket={t("cols.aktifOgrenci")} deger={ilerleme(s, s.aktif_ogrenci_7g)} />
                    <Olcu etiket={t("cols.dogruOrani")} deger={ilerleme(s, s.ortalama_dogru_orani, "%")} />
                    <Olcu etiket={t("cols.bekleyen")} deger={ilerleme(s, s.bekleyen_tekrar)} />
                    <Olcu
                      etiket={t("cols.sonEtkinlik")}
                      deger={s.ilerleme_gosterilir ? tarihMetni(s.son_aktivite, locale) : t("ilerlemeYetersiz")}
                    />
                    <Olcu etiket={t("cols.yil")} deger={String(s.yil)} />
                  </dl>
                </li>
              ))}
            </ul>

            {/* Tablet (md ve üstü): tablo; kendi kapsayıcısında kayar */}
            <div className="hidden overflow-x-auto md:block">
              <table className="min-w-full">
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th className={thClass}>{t("cols.ad")}</th>
                    <th className={thClass}>{t("cols.seviye")}</th>
                    <th className={thClass}>{t("cols.okul")}</th>
                    <th className={thClass}>{t("cols.ogrenciler")}</th>
                    <th className={thClass}>{t("cols.aktifOgrenci")}</th>
                    <th className={thClass}>{t("cols.dogruOrani")}</th>
                    <th className={thClass}>{t("cols.bekleyen")}</th>
                    <th className={thClass}>{t("cols.sonEtkinlik")}</th>
                    <th className={thClass}>{t("cols.yil")}</th>
                    <th className={thClass}>{t("cols.aktif")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {raporlar.map((s) => (
                    <tr key={s.id}>
                      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>
                        {s.ad}
                      </td>
                      <td className={tdClass}>{seviyeMetni(s.sinif_seviyesi)}</td>
                      <td className={tdClass}>{s.okul_adi ?? "-"}</td>
                      <td className={tdClass}>{s.ogrenci_sayisi}</td>
                      <td className={tdClass}>{ilerleme(s, s.aktif_ogrenci_7g)}</td>
                      <td className={tdClass}>{ilerleme(s, s.ortalama_dogru_orani, "%")}</td>
                      <td className={tdClass}>{ilerleme(s, s.bekleyen_tekrar)}</td>
                      <td className={tdClass}>
                        {s.ilerleme_gosterilir ? tarihMetni(s.son_aktivite, locale) : t("ilerlemeYetersiz")}
                      </td>
                      <td className={tdClass}>{s.yil}</td>
                      <td className={tdClass}>
                        <Badge size="sm" color={s.aktif ? "success" : "light"}>
                          {s.aktif ? t("active") : t("inactive")}
                        </Badge>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        ) : (
          <>
            {/* Telefon ve küçük tablet (md altı): kart görünümü */}
            <ul className="space-y-3 md:hidden">
              {satirlar.map((s) => (
                <li
                  key={s.id}
                  className="rounded-xl border border-gray-200 p-4 dark:border-gray-800"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">
                        {s.ad}
                      </p>
                      <p className="text-theme-sm text-gray-500 dark:text-gray-400">
                        {seviyeMetni(s.sinif_seviyesi)}
                      </p>
                    </div>
                    <Badge size="sm" color={s.aktif ? "success" : "light"}>
                      {s.aktif ? t("active") : t("inactive")}
                    </Badge>
                  </div>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-3 text-theme-sm">
                    <Olcu etiket={t("cols.ogretmen")} deger={s.ogretmen_adi ?? "-"} />
                    <Olcu etiket={t("cols.ogrenciler")} deger={String(s.ogrenci_sayisi)} />
                    <Olcu etiket={t("cols.yil")} deger={String(s.yil)} />
                  </dl>
                  <button
                    type="button"
                    className={`${satirDugmesi} mt-3 w-full`}
                    onClick={() => openEdit(s)}
                  >
                    {t("edit")}
                  </button>
                </li>
              ))}
            </ul>

            {/* Tablet (md ve üstü): tablo; kendi kapsayıcısında kayar */}
            <div className="hidden overflow-x-auto md:block">
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
                  {satirlar.map((s) => (
                    <tr key={s.id}>
                      <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>
                        {s.ad}
                      </td>
                      <td className={tdClass}>{seviyeMetni(s.sinif_seviyesi)}</td>
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
                          className={satirDugmesi}
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
          </>
        )}

        {yonetici && !loading && !error && toplam > PAGE_SIZE && (
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
      </section>

      {/* Yazma yalnızca admin için; öğretmen bu modalı hiç görmez. */}
      {yonetici && (
        <ModalShell
          isOpen={formAcik}
          onClose={formuKapat}
          title={editing ? t("editTitle") : t("createTitle")}
        >
          <form onSubmit={submit} className="space-y-4">
            <div>
              <label className={labelClass} htmlFor="sinif-ad">
                {t("form.ad")}
              </label>
              <input
                ref={ilkAlanRef}
                id="sinif-ad"
                className={inputClass}
                autoComplete="off"
                value={f.ad}
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
                value={f.sinif_seviyesi}
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
                autoComplete="off"
                value={f.okul_adi}
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
                value={f.yil}
                onChange={(e) => set("yil", e.target.value)}
              />
            </div>
            <OgretmenPicker
              selected={selectedOgretmen}
              onSelect={(u) => {
                setSelectedOgretmen(u);
                set("ogretmen_id", u?.id ?? "");
              }}
            />
            <label className="flex min-h-11 items-center gap-3 text-sm text-gray-700 dark:text-gray-300">
              <input
                type="checkbox"
                className="h-5 w-5"
                checked={f.aktif}
                onChange={(e) => set("aktif", e.target.checked)}
              />
              {t("form.aktif")}
            </label>
            <ErrorNote message={formError} />
            <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
              <button type="button" className={outlineBtn} onClick={formuKapat}>
                {t("form.cancel")}
              </button>
              <button type="submit" className={primaryBtn} disabled={saving}>
                {saving ? t("form.saving") : t("form.save")}
              </button>
            </div>
          </form>
        </ModalShell>
      )}
    </>
  );
}
