"use client";

// Kelime Evreni yönetimi: metrikler, soru taslakları, inceleme ve yayın akışı.
// Sunucu kuralları (dört göz, onaylı ilişki, geçiş kuralları) RPC'de uygulanır; burada yalnızca gösterilir.

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import KelimeSozlukPanel from "./KelimeSozlukPanel";
import ModalShell from "./ModalShell";
import { cardClass, inputClass, labelClass, linkBtn, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";
import { hataAnahtari, type AnlamSecenegi, type KelimeDurum, type KelimeIliskiTuru } from "./kelimeEvreni";

export interface KelimeSoruSatiri {
  id: string;
  kelime: string;
  anlam: string;
  anlam_id: string;
  iliski_turu: KelimeIliskiTuru;
  sinif: number;
  zorluk: number;
  kazanim_kodu: string | null;
  soru_metni: string;
  secenekler: string[];
  dogru_indeks: number;
  dogru_anlam_id: string | null;
  ipucu: string | null;
  aciklama: string;
  durum: KelimeDurum;
  olusturan_id: string | null;
  inceleyen_id: string | null;
  yayin_tarihi: string | null;
  guncellendi: string;
}

interface Metrik {
  durumlar: Partial<Record<KelimeDurum, number>>;
  son_7_gun: {
    deneme: number;
    ogrenci: number;
    dogru_orani: number | null;
    ipucu_orani: number | null;
    ipucusuz_dogru_orani: number | null;
  };
}

interface SoruForm {
  id: string | null;
  anlamId: string;
  iliski: KelimeIliskiTuru;
  sinif: string;
  zorluk: string;
  kazanim: string;
  soru: string;
  secenekler: string[];
  dogruIndeks: number;
  dogruAnlamId: string;
  ipucu: string;
  aciklama: string;
}

const DURUMLAR: KelimeDurum[] = ["taslak", "incelemede", "yayinda", "arsiv"];
const ILISKILER: KelimeIliskiTuru[] = ["es_anlamli", "zit_anlamli", "es_sesli"];
const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const BOS_FORM: SoruForm = {
  id: null,
  anlamId: "",
  iliski: "es_anlamli",
  sinif: "5",
  zorluk: "1",
  kazanim: "",
  soru: "",
  secenekler: ["", ""],
  dogruIndeks: 0,
  dogruAnlamId: "",
  ipucu: "",
  aciklama: "",
};

// Satır eylemleri: dokunma hedefi en az 44 px.
const EYLEM_BTN = `${linkBtn} inline-flex min-h-11 items-center disabled:opacity-50`;

// Tablo kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";

export default function KelimeEvreniManager() {
  const t = useTranslations("yonetim.kelimeEvreni");
  const [satirlar, setSatirlar] = useState<KelimeSoruSatiri[]>([]);
  const [toplam, setToplam] = useState(0);
  const [metrik, setMetrik] = useState<Metrik | null>(null);
  const [anlamlar, setAnlamlar] = useState<AnlamSecenegi[]>([]);
  const [filtre, setFiltre] = useState<KelimeDurum | "">("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  const [form, setForm] = useState<SoruForm | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [islemde, setIslemde] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();
    const run = async () => {
      const [liste, metrikSonuc, anlamSonuc] = await Promise.all([
        supabase.rpc("kelime_yonetim_liste", { p_durum: filtre || null, p_sinif: null, p_iliski_turu: null, p_limit: 200 }),
        supabase.rpc("kelime_metrikleri"),
        supabase.rpc("kelime_yonetim_anlamlar"),
      ]);
      if (cancelled) return;
      const hata = liste.error ?? metrikSonuc.error ?? anlamSonuc.error;
      if (hata) {
        setError(t(`hatalar.${hataAnahtari(hata.message)}`));
      } else {
        setError(null);
        const veri = liste.data as { toplam: number; satirlar: KelimeSoruSatiri[] };
        setToplam(veri.toplam);
        setSatirlar(veri.satirlar ?? []);
        setMetrik(metrikSonuc.data as Metrik);
        setAnlamlar((anlamSonuc.data ?? []) as AnlamSecenegi[]);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
    // t sabit çeviri fonksiyonu; yalnızca filtre ve yenileme anahtarı veri çekmeyi tetikler
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filtre, reloadKey]);

  const openNew = () => {
    setForm({ ...BOS_FORM });
    setFormError(null);
  };

  const openEdit = (s: KelimeSoruSatiri) => {
    setForm({
      id: s.id,
      anlamId: s.anlam_id,
      iliski: s.iliski_turu,
      sinif: String(s.sinif),
      zorluk: String(s.zorluk),
      kazanim: s.kazanim_kodu ?? "",
      soru: s.soru_metni,
      secenekler: [...s.secenekler],
      dogruIndeks: s.dogru_indeks,
      dogruAnlamId: s.dogru_anlam_id ?? "",
      ipucu: s.ipucu ?? "",
      aciklama: s.aciklama,
    });
    setFormError(null);
  };

  const setAlan = <K extends keyof SoruForm>(k: K, v: SoruForm[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const setSecenek = (i: number, v: string) =>
    setForm((f) => {
      if (!f) return f;
      const secenekler = f.secenekler.map((s, idx) => (idx === i ? v : s));
      return { ...f, secenekler };
    });

  const secenekEkle = () =>
    setForm((f) => (f && f.secenekler.length < 4 ? { ...f, secenekler: [...f.secenekler, ""] } : f));

  const secenekSil = (i: number) =>
    setForm((f) => {
      if (!f || f.secenekler.length <= 2) return f;
      const secenekler = f.secenekler.filter((_, idx) => idx !== i);
      const dogruIndeks = f.dogruIndeks === i ? 0 : f.dogruIndeks > i ? f.dogruIndeks - 1 : f.dogruIndeks;
      return { ...f, secenekler, dogruIndeks };
    });

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    setFormError(null);
    if (!form.anlamId) return setFormError(t("form.anlamGerekli"));
    if (form.soru.trim().length < 5) return setFormError(t("form.sorugerekli"));
    if (form.aciklama.trim().length < 5) return setFormError(t("form.aciklamaGerekli"));
    const secenekler = form.secenekler.map((s) => s.trim());
    if (secenekler.some((s) => s.length === 0)) return setFormError(t("form.secenekBos"));

    setSaving(true);
    const { error: err } = await createClient().rpc("kelime_soru_kaydet", {
      p_id: form.id,
      p_anlam_id: form.anlamId,
      p_iliski_turu: form.iliski,
      p_sinif: Number(form.sinif),
      p_zorluk: Number(form.zorluk),
      p_kazanim_kodu: form.kazanim.trim() || null,
      p_soru_metni: form.soru.trim(),
      p_secenekler: secenekler,
      p_dogru_indeks: form.dogruIndeks,
      p_dogru_anlam_id: form.dogruAnlamId || null,
      p_ipucu: form.ipucu.trim() || null,
      p_aciklama: form.aciklama.trim(),
    });
    setSaving(false);
    if (err) return setFormError(t(`hatalar.${hataAnahtari(err.message)}`));
    setForm(null);
    reload();
  };

  const durumDegistir = async (s: KelimeSoruSatiri, hedef: KelimeDurum) => {
    // Yayın öğrencilere hemen görünür olur; onay istenir
    if (hedef === "yayinda" && !window.confirm(t("actions.yayinOnay"))) return;
    setIslemde(s.id);
    const { error: err } = await createClient().rpc("kelime_soru_durum_degistir", { p_id: s.id, p_hedef: hedef });
    setIslemde(null);
    if (err) return setError(t(`hatalar.${hataAnahtari(err.message)}`));
    setError(null);
    reload();
  };

  // Durum eylemleri: kart ve tabloda aynı düğmeler.
  const islemler = (s: KelimeSoruSatiri) => {
    const dis = islemde === s.id;
    switch (s.durum) {
      case "taslak":
        return (
          <>
            <button type="button" className={EYLEM_BTN} onClick={() => openEdit(s)} disabled={dis}>{t("actions.duzenle")}</button>
            <button type="button" className={EYLEM_BTN} onClick={() => durumDegistir(s, "incelemede")} disabled={dis}>{t("actions.incelemeye")}</button>
          </>
        );
      case "incelemede":
        return (
          <>
            <button type="button" className={EYLEM_BTN} onClick={() => durumDegistir(s, "yayinda")} disabled={dis}>{t("actions.yayinla")}</button>
            <button type="button" className={EYLEM_BTN} onClick={() => durumDegistir(s, "taslak")} disabled={dis}>{t("actions.geriAl")}</button>
          </>
        );
      case "yayinda":
        return (
          <button type="button" className={EYLEM_BTN} onClick={() => durumDegistir(s, "arsiv")} disabled={dis}>{t("actions.arsivle")}</button>
        );
      case "arsiv":
        return (
          <button type="button" className={EYLEM_BTN} onClick={() => durumDegistir(s, "taslak")} disabled={dis}>{t("actions.geriYukle")}</button>
        );
    }
  };

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h3>
          <button type="button" className={primaryBtn} onClick={openNew}>{t("new")}</button>
        </div>

        {metrik && (
          <div className="mb-5 grid grid-cols-2 gap-3 md:grid-cols-4">
            {DURUMLAR.map((d) => (
              <div key={d} className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
                <p className="text-xs text-gray-500 dark:text-gray-400">{t(`durumlar.${d}`)}</p>
                <p className="text-2xl font-semibold text-gray-800 dark:text-white/90">{metrik.durumlar[d] ?? 0}</p>
              </div>
            ))}
            <div className="col-span-2 rounded-xl border border-gray-200 p-3 md:col-span-4 dark:border-gray-800">
              <p className="text-xs text-gray-500 dark:text-gray-400">{t("son7Gun", { deneme: metrik.son_7_gun.deneme, ogrenci: metrik.son_7_gun.ogrenci })}</p>
              <p className="mt-1 text-sm text-gray-700 dark:text-gray-300">
                {t("oranlar", {
                  dogru: metrik.son_7_gun.dogru_orani ?? "–",
                  ipucusuz: metrik.son_7_gun.ipucusuz_dogru_orani ?? "–",
                  ipucu: metrik.son_7_gun.ipucu_orani ?? "–",
                })}
              </p>
            </div>
          </div>
        )}

        <ErrorNote message={error} />

        <div className="mb-3 flex flex-wrap items-center gap-3">
          <label className="text-sm text-gray-600 dark:text-gray-300" htmlFor="kelime-durum-filtre">{t("filtre")}</label>
          <select
            id="kelime-durum-filtre"
            className={`${inputClass} w-full sm:w-auto sm:max-w-xs`}
            value={filtre}
            onChange={(e) => setFiltre(e.target.value as KelimeDurum | "")}
          >
            <option value="">{t("tumu")}</option>
            {DURUMLAR.map((d) => (
              <option key={d} value={d}>{t(`durumlar.${d}`)}</option>
            ))}
          </select>
          <span className="text-sm text-gray-500 dark:text-gray-400">{t("toplam", { sayi: toplam })}</span>
        </div>

        {!loading && toplam > satirlar.length && (
          <p className="mb-3 text-sm text-amber-700 dark:text-amber-400">{t("sinirUyari", { limit: satirlar.length })}</p>
        )}

        {loading ? (
          <p className="text-sm text-gray-500">{t("loading")}</p>
        ) : satirlar.length === 0 ? (
          <p className="text-sm text-gray-500">{t("empty")}</p>
        ) : (
          <>
            {/* Telefon ve küçük tablet (md altı): kart görünümü */}
            <ul className="space-y-3 md:hidden">
              {satirlar.map((s) => (
                <li key={s.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <div className="min-w-0">
                      <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">{s.kelime}</p>
                      <p className="text-xs wrap-break-word text-gray-500 dark:text-gray-400">{s.anlam}</p>
                    </div>
                    <span className="text-theme-xs font-medium text-gray-600 dark:text-gray-300">{t(`durumlar.${s.durum}`)}</span>
                  </div>
                  <p className="mt-2 line-clamp-2 text-theme-sm text-gray-700 dark:text-gray-300">{s.soru_metni}</p>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm">
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.tur")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">{t(`turler.${s.iliski_turu}`)}</dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.sinif")}</dt>
                      <dd className="text-gray-800 dark:text-white/90">
                        {s.sinif}. {t("sinifKisa")}{s.kazanim_kodu ? ` · ${s.kazanim_kodu}` : ""}
                      </dd>
                    </div>
                  </dl>
                  <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 border-t border-gray-100 pt-2 dark:border-gray-800">
                    {islemler(s)}
                  </div>
                </li>
              ))}
            </ul>

            {/* Tablet ve masaüstü (md ve üzeri): tablo; kapsayıcısı kayar */}
            <div className={`hidden overflow-x-auto md:block ${ILK_SUTUN_SABIT}`}>
              <table className="min-w-full text-left text-sm">
                <thead>
                  <tr>
                    <th className={thClass}>{t("cols.kelime")}</th>
                    <th className={thClass}>{t("cols.tur")}</th>
                    <th className={thClass}>{t("cols.sinif")}</th>
                    <th className={thClass}>{t("cols.soru")}</th>
                    <th className={thClass}>{t("cols.durum")}</th>
                    <th className={thClass}>{t("cols.islem")}</th>
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map((s) => (
                    <tr key={s.id}>
                      <td className={tdClass}>
                        <span className="font-medium text-gray-800 dark:text-white/90">{s.kelime}</span>
                        <span className="block text-xs text-gray-500">{s.anlam}</span>
                      </td>
                      <td className={tdClass}>{t(`turler.${s.iliski_turu}`)}</td>
                      <td className={tdClass}>{s.sinif}. {t("sinifKisa")}{s.kazanim_kodu ? ` · ${s.kazanim_kodu}` : ""}</td>
                      <td className={`${tdClass} max-w-md`}>
                        <span className="line-clamp-2">{s.soru_metni}</span>
                      </td>
                      <td className={tdClass}>{t(`durumlar.${s.durum}`)}</td>
                      <td className={tdClass}>
                        <div className="flex flex-wrap gap-x-3 gap-y-1">{islemler(s)}</div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
      </section>

      {form && (
        <ModalShell isOpen onClose={() => setForm(null)} title={form.id ? t("form.duzenle") : t("form.yeni")}>
          <form className="grid gap-4 sm:grid-cols-2" onSubmit={submit}>
            <div>
              <label className={labelClass} htmlFor="kelime-anlam">{t("form.anlam")}</label>
              <select id="kelime-anlam" className={inputClass} value={form.anlamId} onChange={(e) => setAlan("anlamId", e.target.value)}>
                <option value="">{t("form.anlamSec")}</option>
                {anlamlar.map((a) => (
                  <option key={a.id} value={a.id}>{a.kelime} — {a.anlam}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="kelime-iliski">{t("form.oyunTuru")}</label>
              <select id="kelime-iliski" className={inputClass} value={form.iliski} onChange={(e) => setAlan("iliski", e.target.value as KelimeIliskiTuru)}>
                {ILISKILER.map((i) => (
                  <option key={i} value={i}>{t(`turler.${i}`)}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="kelime-sinif">{t("form.sinif")}</label>
              <select id="kelime-sinif" className={inputClass} value={form.sinif} onChange={(e) => setAlan("sinif", e.target.value)}>
                {SINIFLAR.map((s) => (
                  <option key={s} value={s}>{s}. {t("sinifKisa")}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="kelime-zorluk">{t("form.zorluk")}</label>
              <select id="kelime-zorluk" className={inputClass} value={form.zorluk} onChange={(e) => setAlan("zorluk", e.target.value)}>
                {[1, 2, 3].map((z) => (
                  <option key={z} value={z}>{t("form.zorlukSecenek", { z, xp: z * 10 })}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="kelime-kazanim">{t("form.kazanim")}</label>
              <input id="kelime-kazanim" className={inputClass} maxLength={40} value={form.kazanim} onChange={(e) => setAlan("kazanim", e.target.value)} />
            </div>
            <div className="sm:col-span-2">
              <label className={labelClass} htmlFor="kelime-soru">{t("form.soru")}</label>
              <textarea id="kelime-soru" className={`${inputClass} h-auto py-2.5`} rows={2} maxLength={400} value={form.soru} onChange={(e) => setAlan("soru", e.target.value)} />
            </div>

            <fieldset className="sm:col-span-2">
              <legend className={labelClass}>{t("form.secenekler")}</legend>
              <div className="space-y-2">
                {form.secenekler.map((s, i) => (
                  <div key={i} className="flex items-center gap-2">
                    <input
                      type="radio"
                      name="kelime-dogru"
                      className="h-5 w-5 shrink-0"
                      aria-label={t("form.dogruSecenek", { no: i + 1 })}
                      checked={form.dogruIndeks === i}
                      onChange={() => setAlan("dogruIndeks", i)}
                    />
                    <input
                      className={`${inputClass} min-w-0 flex-1`}
                      maxLength={120}
                      aria-label={t("form.secenekNo", { no: i + 1 })}
                      value={s}
                      onChange={(e) => setSecenek(i, e.target.value)}
                    />
                    <button
                      type="button"
                      className={`${EYLEM_BTN} shrink-0`}
                      onClick={() => secenekSil(i)}
                      disabled={form.secenekler.length <= 2}
                    >
                      {t("form.secenekSil")}
                    </button>
                  </div>
                ))}
              </div>
              <div className="mt-2 flex flex-wrap items-center gap-3">
                <button type="button" className={outlineBtn} onClick={secenekEkle} disabled={form.secenekler.length >= 4}>
                  {t("form.secenekEkle")}
                </button>
                <span className="text-xs text-gray-500">{t("form.dogruAciklama")}</span>
              </div>
            </fieldset>

            <div>
              <label className={labelClass} htmlFor="kelime-dogru-anlam">{t("form.dogruAnlam")}</label>
              <select id="kelime-dogru-anlam" className={inputClass} value={form.dogruAnlamId} onChange={(e) => setAlan("dogruAnlamId", e.target.value)}>
                <option value="">{t("form.yok")}</option>
                {anlamlar.map((a) => (
                  <option key={a.id} value={a.id}>{a.kelime} — {a.anlam}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="kelime-ipucu">{t("form.ipucu")}</label>
              <input id="kelime-ipucu" className={inputClass} maxLength={200} value={form.ipucu} onChange={(e) => setAlan("ipucu", e.target.value)} />
            </div>
            <div className="sm:col-span-2">
              <label className={labelClass} htmlFor="kelime-aciklama">{t("form.aciklama")}</label>
              <textarea id="kelime-aciklama" className={`${inputClass} h-auto py-2.5`} rows={2} maxLength={500} value={form.aciklama} onChange={(e) => setAlan("aciklama", e.target.value)} />
            </div>

            <div className="sm:col-span-2">
              <ErrorNote message={formError} />
              <div className="mt-2 flex flex-col-reverse gap-3 sm:flex-row">
                <button type="submit" className={primaryBtn} disabled={saving}>{saving ? t("form.kaydediliyor") : t("form.kaydet")}</button>
                <button type="button" className={outlineBtn} onClick={() => setForm(null)}>{t("form.vazgec")}</button>
              </div>
            </div>
          </form>
        </ModalShell>
      )}

      <KelimeSozlukPanel anlamlar={anlamlar} onDegisti={reload} />
    </div>
  );
}
