"use client";

// Ayarlar: her anahtar ayrı kaydedilir (okuma_ayar_yaz). Aralık ve tür denetimi sunucuda; burada ön uyarı.
import { useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni, VeriDurumu } from "./ortak";

type Ayarlar = Record<string, unknown>;

const SAYI_ALANLARI = [
  { anahtar: "okuma_gunluk_hikaye", min: 0, max: 50 },
  { anahtar: "okuma_pdf_aylik_ucretsiz", min: 0, max: 100 },
  { anahtar: "xp_tamamlama", min: 0, max: 30, adim: 10 },
  { anahtar: "xp_dogru_bonus", min: 0, max: 30, adim: 10 },
  { anahtar: "xp_gunluk_hikaye_tavani", min: 0, max: 20 },
  { anahtar: "dogru_orani_esik", min: 1, max: 100 },
  { anahtar: "min_n", min: 3, max: 100 },
  { anahtar: "saatlik_baslatma_siniri", min: 1, max: 200 },
] as const;

const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8];
const UUID_DESENI = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

export default function AyarlarSekmesi() {
  const veri = useAdminRpc<Ayarlar>("okuma_ayarlari_getir");
  return (
    <>
      <VeriDurumu loading={veri.loading} error={veri.error} missing={veri.missing} onRetry={veri.reload} />
      {veri.data && !veri.error && <AyarFormu ayarlar={veri.data} />}
    </>
  );
}

function AyarFormu({ ayarlar }: { ayarlar: Ayarlar }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.ayarlar");
  const hata = useHataMetni();

  const [aktif, setAktif] = useState(ayarlar.aktif === true);
  const [pilot, setPilot] = useState<number[]>(Array.isArray(ayarlar.pilot_siniflari) ? (ayarlar.pilot_siniflari as number[]) : []);
  const [izinli, setIzinli] = useState(Array.isArray(ayarlar.izinli_kullanicilar) ? (ayarlar.izinli_kullanicilar as string[]).join("\n") : "");
  const [sayilar, setSayilar] = useState<Record<string, string>>(
    Object.fromEntries(SAYI_ALANLARI.map((a) => [a.anahtar, ayarlar[a.anahtar] === undefined ? "" : String(ayarlar[a.anahtar])])),
  );
  const [islemde, setIslemde] = useState<string | null>(null);
  const [basari, setBasari] = useState<string | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);

  const yaz = async (anahtar: string, deger: unknown) => {
    setIslemde(anahtar);
    setBasari(null);
    setHataMesaji(null);
    const { error } = await adminCall("okuma_ayar_yaz", { p_anahtar: anahtar, p_deger: deger });
    setIslemde(null);
    if (error) {
      setHataMesaji(hata(error));
      return false;
    }
    setBasari(t("kaydedildi", { ad: t(`alanlar.${anahtar}.ad`) }));
    return true;
  };

  const aktifKaydet = async () => {
    const yeni = !aktif;
    // Bayrağı açmak çocuk ekranlarına özelliği getirir (pilot sınıf/izinli liste kısıtı geçerli kalır).
    if (yeni && !window.confirm(t("aktifOnay"))) return;
    if (await yaz("aktif", yeni)) setAktif(yeni);
  };

  const izinliKaydet = () => {
    const kimlikler = izinli.split(/[\s,;]+/).map((s) => s.trim().toLowerCase()).filter(Boolean);
    if (kimlikler.length > 200) return setHataMesaji(t("izinliCok"));
    if (kimlikler.some((k) => !UUID_DESENI.test(k))) return setHataMesaji(t("izinliGecersiz"));
    void yaz("izinli_kullanicilar", [...new Set(kimlikler)]);
  };

  const sayiKaydet = (a: (typeof SAYI_ALANLARI)[number]) => {
    const ham = sayilar[a.anahtar];
    const n = Number(ham);
    if (ham.trim() === "" || !Number.isInteger(n) || n < a.min || n > a.max) {
      return setHataMesaji(t("aralik", { ad: t(`alanlar.${a.anahtar}.ad`), min: a.min, max: a.max }));
    }
    if ("adim" in a && n % a.adim !== 0) {
      return setHataMesaji(t("onunKati", { ad: t(`alanlar.${a.anahtar}.ad`) }));
    }
    if (a.anahtar === "xp_tamamlama" || a.anahtar === "xp_dogru_bonus") {
      const diger = Number(sayilar[a.anahtar === "xp_tamamlama" ? "xp_dogru_bonus" : "xp_tamamlama"]);
      if (Number.isFinite(diger) && n + diger > 30) return setHataMesaji(t("xpToplam"));
    }
    void yaz(a.anahtar, n);
  };

  return (
    <div className="space-y-6">
      <div aria-live="polite" className="space-y-2">
        {basari && <p className="text-sm text-success-700 dark:text-success-400">{basari}</p>}
        <ErrorNote message={hataMesaji} />
      </div>

      <section className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
        <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("alanlar.aktif.ad")}</h4>
        <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("alanlar.aktif.aciklama")}</p>
        <p className="mt-2 text-sm font-medium text-gray-800 dark:text-white/90" role="status">
          {aktif ? t("aktifAcik") : t("aktifKapali")}
        </p>
        <button type="button" className={`${aktif ? outlineBtn : primaryBtn} mt-3`} disabled={islemde !== null} onClick={() => void aktifKaydet()}>
          {aktif ? t("kapat") : t("ac")}
        </button>
      </section>

      <section className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
        <fieldset>
          <legend className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("alanlar.pilot_siniflari.ad")}</legend>
          <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("alanlar.pilot_siniflari.aciklama")}</p>
          <div className="mt-3 flex flex-wrap gap-2">
            {SINIFLAR.map((n) => (
              <label key={n} className="inline-flex min-h-11 cursor-pointer items-center gap-2 rounded-lg px-3 text-sm text-gray-700 ring-1 ring-inset ring-gray-300 dark:text-gray-300 dark:ring-gray-700">
                <input
                  type="checkbox"
                  className="size-4"
                  checked={pilot.includes(n)}
                  onChange={(e) => setPilot((p) => (e.target.checked ? [...p, n].sort((a, b) => a - b) : p.filter((x) => x !== n)))}
                />
                {t("sinifDeger", { n })}
              </label>
            ))}
          </div>
          <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{pilot.length === 0 ? t("pilotHepsi") : t("pilotSecili", { liste: pilot.join(", ") })}</p>
          <button type="button" className={`${outlineBtn} mt-3`} disabled={islemde !== null} onClick={() => void yaz("pilot_siniflari", pilot)}>
            {t("kaydet")}
          </button>
        </fieldset>
      </section>

      <section className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
        <label className="text-sm font-semibold text-gray-800 dark:text-white/90" htmlFor="ha-izinli">{t("alanlar.izinli_kullanicilar.ad")}</label>
        <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("alanlar.izinli_kullanicilar.aciklama")}</p>
        <textarea id="ha-izinli" className={`${inputClass} mt-3 h-28 py-3 font-mono text-xs md:text-xs`} spellCheck={false} value={izinli} onChange={(e) => setIzinli(e.target.value)} />
        <button type="button" className={`${outlineBtn} mt-3`} disabled={islemde !== null} onClick={izinliKaydet}>
          {t("kaydet")}
        </button>
      </section>

      <div className="grid gap-4 md:grid-cols-2">
        {SAYI_ALANLARI.map((a) => (
          <section key={a.anahtar} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
            <label className={labelClass} htmlFor={`ha-ayar-${a.anahtar}`}>{t(`alanlar.${a.anahtar}.ad`)}</label>
            <p className="mb-2 text-theme-xs text-gray-500 dark:text-gray-400">{t(`alanlar.${a.anahtar}.aciklama`)}</p>
            <div className="flex gap-3">
              <input
                id={`ha-ayar-${a.anahtar}`}
                type="number"
                inputMode="numeric"
                min={a.min}
                max={a.max}
                step={"adim" in a ? a.adim : 1}
                className={`${inputClass} max-w-32`}
                value={sayilar[a.anahtar]}
                onChange={(e) => setSayilar((s) => ({ ...s, [a.anahtar]: e.target.value }))}
              />
              <button type="button" className={outlineBtn} disabled={islemde !== null} onClick={() => sayiKaydet(a)}>
                {t("kaydet")}
              </button>
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}
