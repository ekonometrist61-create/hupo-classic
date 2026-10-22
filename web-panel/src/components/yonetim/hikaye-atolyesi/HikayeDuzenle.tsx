"use client";

// Hikâye düzenleme: sürüm içeriği değişmez (sunucu kuralı). Bu form mevcut paketi alır, alanları
// değiştirir ve okuma_paket_ice_aktar ile YENİ TASLAK SÜRÜM olarak gönderir; yayındaki sürüm
// yeni sürüm denetimden geçip yayınlanana kadar aynen kalır. Ayrı bir düzenleme RPC'si yoktur.
import { useMemo, useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall } from "@/components/yonetim/useAdminRpc";
import { turEtiketi } from "@/lib/okuma/turler";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni } from "./ortak";
import SurumOnizleme from "./SurumOnizleme";
import { kalemMetni, type IceAktarYaniti, type Paket } from "./tipler";

// Pakette tipte tanımlı olmayan alanlar da (etiketler, üretim vb.) olduğu gibi geri gönderilir.
type TamPaket = Paket & Record<string, unknown>;

const METIN_PARCALARI = new Set(["metin", "vurgu"]);
const alanClass = `${inputClass} h-auto min-h-11`;

interface Props {
  paket: Paket;
  /** Kaynak sürümün hikâye anahtarı (yalnız gösterim). */
  slug: string;
  tur?: string | null;
  onKapat: () => void;
  /** Yeni taslak sürüm yazıldı; liste yenilensin. */
  onKaydedildi: () => void;
}

export default function HikayeDuzenle({ paket, slug, tur, onKapat, onKaydedildi }: Props) {
  const t = useTranslations("yonetim.hikayeAtolyesi.duzenle");
  const hata = useHataMetni();
  const [taslak, setTaslak] = useState<TamPaket>(() => structuredClone(paket) as TamPaket);
  const [islemde, setIslemde] = useState(false);
  const [mesaj, setMesaj] = useState<string | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);
  const [kalemler, setKalemler] = useState<string[]>([]);

  const degisti = useMemo(() => JSON.stringify(taslak) !== JSON.stringify(paket), [taslak, paket]);
  const baslikGecerli = (taslak.hikaye.baslik ?? "").trim().length >= 2;

  const guncelle = (fn: (p: TamPaket) => void) => {
    setTaslak((onceki) => {
      const kopya = structuredClone(onceki) as TamPaket;
      fn(kopya);
      return kopya;
    });
    setMesaj(null);
  };

  /** Boş tanıtım anahtarı gönderilmez (doğrulayıcı boş metni reddedebilir). */
  const gonderilecek = (): TamPaket => {
    const kopya = structuredClone(taslak) as TamPaket;
    kopya.hikaye.baslik = kopya.hikaye.baslik.trim();
    if (typeof kopya.hikaye.tanitim === "string") {
      kopya.hikaye.tanitim = kopya.hikaye.tanitim.trim();
      if (kopya.hikaye.tanitim === "") delete kopya.hikaye.tanitim;
    }
    return kopya;
  };

  const gonder = async (kuru: boolean) => {
    setIslemde(true);
    setMesaj(null);
    setHataMesaji(null);
    setKalemler([]);
    const { data, error } = await adminCall<IceAktarYaniti>("okuma_paket_ice_aktar", { p_paket: gonderilecek(), p_kuru: kuru });
    setIslemde(false);
    if (error) {
      setHataMesaji(hata(error));
      return;
    }
    if (!data) return;
    if (data.gecerli === false) {
      setHataMesaji(t("gecersiz"));
      setKalemler((data.hatalar ?? []).map(kalemMetni));
      return;
    }
    setKalemler((data.uyarilar ?? []).map(kalemMetni));
    // Kuru çalıştırma önizlemesi: yeni sürüm açılır mı, aynı içerik mi? Hiçbir şey yazılmaz.
    if (data.mevcut) {
      setMesaj(t("ayniIcerik", { no: data.surum_no ?? 0 }));
      return;
    }
    if (kuru) {
      setMesaj(t("dogrulamaTamam"));
      return;
    }
    setMesaj(t("kaydedildi", { no: data.surum_no ?? 0 }));
    onKaydedildi();
  };

  return (
    <section aria-label={t("baslik")} className="mt-6 rounded-2xl border border-gray-200 p-5 sm:p-6 dark:border-gray-800">
      <div className="mb-3 flex flex-wrap items-start justify-between gap-3">
        <div className="min-w-0">
          <h5 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h5>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">
            {slug}
            {tur ? ` · ${turEtiketi(tur)}` : ""}
          </p>
        </div>
        <button type="button" className={outlineBtn} onClick={onKapat}>
          {t("vazgec")}
        </button>
      </div>
      <p className="mb-5 text-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>

      <div className="space-y-6">
        {/* Başlık ve tanıtım */}
        <div className="grid gap-4">
          <div>
            <label className={labelClass} htmlFor="hd-baslik">{t("baslikAlan")}</label>
            <input
              id="hd-baslik"
              className={inputClass}
              value={taslak.hikaye.baslik ?? ""}
              maxLength={120}
              onChange={(e) => guncelle((p) => { p.hikaye.baslik = e.target.value; })}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="hd-tanitim">{t("tanitimAlan")}</label>
            <textarea
              id="hd-tanitim"
              className={alanClass}
              rows={3}
              value={taslak.hikaye.tanitim ?? ""}
              onChange={(e) => guncelle((p) => { p.hikaye.tanitim = e.target.value; })}
            />
          </div>
        </div>

        {/* Sayfa metinleri */}
        <fieldset className="space-y-4">
          <legend className="mb-1 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("sayfalar")}</legend>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("yerTutucuNotu")}</p>
          {taslak.sayfalar.map((sayfa, si) => (
            <div key={si} className="space-y-2 rounded-xl border border-gray-200 p-3 dark:border-gray-800">
              <p className="text-theme-xs font-medium text-gray-500 dark:text-gray-400">{t("sayfaNo", { n: si + 1 })}</p>
              {sayfa.parcalar.map((parca, pi) =>
                METIN_PARCALARI.has(parca.t) && typeof parca.v === "string" ? (
                  <div key={pi}>
                    <label className="sr-only" htmlFor={`hd-s${si}-p${pi}`}>
                      {t("parcaEtiket", { sayfa: si + 1, parca: pi + 1 })}
                    </label>
                    <textarea
                      id={`hd-s${si}-p${pi}`}
                      className={alanClass}
                      rows={Math.min(6, Math.max(2, Math.ceil(parca.v.length / 70)))}
                      value={parca.v}
                      onChange={(e) => guncelle((p) => { p.sayfalar[si].parcalar[pi].v = e.target.value; })}
                    />
                  </div>
                ) : (
                  <span
                    key={pi}
                    className="mr-2 inline-block rounded border border-dashed border-gray-300 px-2 py-1 text-theme-xs text-gray-600 dark:border-gray-700 dark:text-gray-400"
                  >
                    {t("yerTutucu", { tur: parca.t })}
                  </span>
                ),
              )}
            </div>
          ))}
        </fieldset>

        {/* Sorular */}
        <fieldset className="space-y-4">
          <legend className="mb-1 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("sorular")}</legend>
          {taslak.sorular.map((soru, qi) => (
            <div key={soru.id} className="space-y-3 rounded-xl border border-gray-200 p-3 dark:border-gray-800">
              <p className="text-theme-xs font-medium text-gray-500 dark:text-gray-400">
                {t("soruNo", { n: qi + 1, id: soru.id })} · {soru.beceri}
              </p>
              <div>
                <label className={labelClass} htmlFor={`hd-q${qi}-metin`}>{t("soruMetni")}</label>
                <textarea
                  id={`hd-q${qi}-metin`}
                  className={alanClass}
                  rows={2}
                  value={soru.metin}
                  onChange={(e) => guncelle((p) => { p.sorular[qi].metin = e.target.value; })}
                />
              </div>
              <div className="space-y-2">
                {soru.secenekler.map((sec, oi) => (
                  <div key={sec.id} className="flex items-start gap-3">
                    <span className="mt-3 w-5 shrink-0 text-sm font-semibold text-gray-700 dark:text-gray-300">{sec.id}</span>
                    <div className="min-w-0 flex-1">
                      <label className="sr-only" htmlFor={`hd-q${qi}-o${oi}`}>{t("secenekEtiket", { id: sec.id })}</label>
                      <input
                        id={`hd-q${qi}-o${oi}`}
                        className={inputClass}
                        value={sec.metin}
                        onChange={(e) => guncelle((p) => { p.sorular[qi].secenekler[oi].metin = e.target.value; })}
                      />
                    </div>
                  </div>
                ))}
              </div>
              <div className="grid gap-3 sm:grid-cols-[10rem_1fr]">
                <div>
                  <label className={labelClass} htmlFor={`hd-q${qi}-dogru`}>{t("dogruSecenek")}</label>
                  <select
                    id={`hd-q${qi}-dogru`}
                    className={inputClass}
                    value={soru.dogru}
                    onChange={(e) => guncelle((p) => { p.sorular[qi].dogru = e.target.value; })}
                  >
                    {soru.secenekler.map((sec) => (
                      <option key={sec.id} value={sec.id}>{sec.id}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className={labelClass} htmlFor={`hd-q${qi}-aciklama`}>{t("aciklamaAlan")}</label>
                  <textarea
                    id={`hd-q${qi}-aciklama`}
                    className={alanClass}
                    rows={2}
                    value={soru.aciklama ?? ""}
                    onChange={(e) => guncelle((p) => { p.sorular[qi].aciklama = e.target.value; })}
                  />
                </div>
              </div>
            </div>
          ))}
        </fieldset>

        {/* Önizleme */}
        <details>
          <summary className="min-h-11 cursor-pointer text-sm font-semibold text-gray-700 dark:text-gray-300">{t("onizleme")}</summary>
          <div className="mt-3">
            <SurumOnizleme paket={taslak} slug={slug} />
          </div>
        </details>
        <details>
          <summary className="min-h-11 cursor-pointer text-sm font-semibold text-gray-700 dark:text-gray-300">{t("jsonOnizleme")}</summary>
          <pre
            tabIndex={0}
            className="mt-3 max-h-96 overflow-auto rounded-lg bg-gray-50 p-3 text-theme-xs text-gray-800 dark:bg-gray-900 dark:text-gray-200"
          >
            {JSON.stringify(gonderilecek(), null, 2)}
          </pre>
        </details>

        <div>
          <div className="flex flex-wrap gap-3">
            <button type="button" className={primaryBtn} disabled={islemde || !degisti || !baslikGecerli} onClick={() => void gonder(false)}>
              {t("yeniTaslakKaydet")}
            </button>
            <button type="button" className={outlineBtn} disabled={islemde || !baslikGecerli} onClick={() => void gonder(true)}>
              {t("dogrula")}
            </button>
          </div>
          {!degisti && <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("degisiklikYok")}</p>}
          <div aria-live="polite" className="mt-3 space-y-2">
            {mesaj && <p className="text-sm text-success-700 dark:text-success-400">{mesaj}</p>}
            <ErrorNote message={hataMesaji} />
            {kalemler.length > 0 && (
              <ul className="list-disc space-y-1 ps-5 text-theme-sm text-gray-700 dark:text-gray-300">
                {kalemler.map((k, i) => (
                  <li key={i} className="wrap-break-word">{k}</li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}