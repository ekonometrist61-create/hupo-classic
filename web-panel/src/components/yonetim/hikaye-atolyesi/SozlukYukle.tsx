"use client";

// Sözlük JSON yükleme (sozluk.v1): dosya yükle / yapıştır → kuru çalıştırma → özet → onayla ve yaz.
// Dört göz kuralı sunucuda: kendi yazdığın girdiyi "onaylı" yapamazsın; ihlal `hatalar[]` ile döner.
import { useRef, useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall } from "@/components/yonetim/useAdminRpc";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni } from "./ortak";
import { kalemMetni } from "./tipler";

const MAKS_BAYT = 3_000_000;
const OZET_ANAHTARLARI = ["girdi_yeni", "girdi_guncel", "onaylanan", "yuva", "aday", "kavram"] as const;

interface SozlukYaniti {
  gecerli: boolean;
  yazildi: boolean;
  kuru: boolean;
  hatalar?: unknown[];
  ozet?: Partial<Record<(typeof OZET_ANAHTARLARI)[number], number>>;
}

/** Yüklenen metnin sozluk.v1 olup olmadığına dair istemci tarafı ön kontrolü (asıl doğrulama sunucuda). */
function onKontrol(metin: string): { ok: true; veri: unknown } | { ok: false; neden: "json" | "bicim" } {
  let veri: unknown;
  try {
    veri = JSON.parse(metin);
  } catch {
    return { ok: false, neden: "json" };
  }
  if (!veri || typeof veri !== "object" || Array.isArray(veri) || (veri as Record<string, unknown>).sozluk_surumu !== 1) {
    return { ok: false, neden: "bicim" };
  }
  return { ok: true, veri };
}

export default function SozlukYukle() {
  const t = useTranslations("yonetim.hikayeAtolyesi.sozlukYukle");
  const hata = useHataMetni();
  const dosyaRef = useRef<HTMLInputElement>(null);
  const [metin, setMetin] = useState("");
  const [veri, setVeri] = useState<unknown>(null);
  const [sonuc, setSonuc] = useState<SozlukYaniti | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);
  const [islemde, setIslemde] = useState(false);

  const sifirla = () => {
    setSonuc(null);
    setHataMesaji(null);
    setVeri(null);
  };

  const dosyaSec = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const dosya = e.target.files?.[0];
    if (!dosya) return;
    sifirla();
    if (dosya.size > MAKS_BAYT) {
      setHataMesaji(t("cokBuyuk"));
      return;
    }
    setMetin(await dosya.text());
  };

  const calistir = async (kuru: boolean) => {
    setHataMesaji(null);
    let gonderilecek = veri;
    if (kuru) {
      const k = onKontrol(metin);
      if (!k.ok) {
        setSonuc(null);
        setHataMesaji(k.neden === "json" ? t("jsonHatali") : t("bicimHatasi"));
        return;
      }
      gonderilecek = k.veri;
      setVeri(k.veri);
    }
    setIslemde(true);
    const { data, error } = await adminCall<SozlukYaniti>("okuma_sozluk_ice_aktar", { p_sozluk: gonderilecek, p_kuru: kuru });
    setIslemde(false);
    if (error || !data) {
      setHataMesaji(hata(error ?? ""));
      return;
    }
    setSonuc(data);
  };

  const hatalar = sonuc?.hatalar ?? [];
  const yazilabilir = !!sonuc && sonuc.gecerli && sonuc.kuru;

  return (
    <section className="space-y-4 rounded-xl border border-gray-200 p-4 sm:p-5 dark:border-gray-800" aria-labelledby="ha-szy-b">
      <div>
        <h4 id="ha-szy-b" className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h4>
        <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>
      </div>

      <div>
        <label className={labelClass} htmlFor="ha-szy-dosya">{t("dosya")}</label>
        <input
          ref={dosyaRef}
          id="ha-szy-dosya"
          type="file"
          accept=".json,application/json"
          onChange={dosyaSec}
          className="block min-h-11 w-full text-sm text-gray-700 file:mr-3 file:min-h-11 file:rounded-lg file:border-0 file:bg-gray-100 file:px-4 file:text-sm file:font-medium file:text-gray-700 dark:text-gray-300 dark:file:bg-white/10 dark:file:text-gray-200"
        />
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-szy-metin">{t("yapistir")}</label>
        <textarea
          id="ha-szy-metin"
          className={`${inputClass} h-40 py-3 font-mono text-xs md:text-xs`}
          spellCheck={false}
          value={metin}
          onChange={(e) => {
            setMetin(e.target.value);
            sifirla();
          }}
          placeholder={t("yer")}
        />
      </div>

      <div className="flex flex-wrap gap-3">
        <button type="button" className={primaryBtn} disabled={islemde || metin.trim().length === 0} onClick={() => void calistir(true)}>
          {islemde && !yazilabilir ? t("denetleniyor") : t("kuruCalistir")}
        </button>
        {metin && (
          <button
            type="button"
            className={outlineBtn}
            disabled={islemde}
            onClick={() => {
              setMetin("");
              sifirla();
              if (dosyaRef.current) dosyaRef.current.value = "";
            }}
          >
            {t("temizle")}
          </button>
        )}
      </div>

      <div aria-live="polite" className="space-y-4">
        <ErrorNote message={hataMesaji} />

        {sonuc && !sonuc.gecerli && (
          <div className="rounded-xl border border-error-200 p-4 dark:border-error-500/40">
            <h5 className="text-sm font-semibold text-error-700 dark:text-error-400">{t("gecersiz", { sayi: hatalar.length })}</h5>
            <p className="mb-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("gecersizNot")}</p>
            <ul className="max-h-64 list-disc space-y-1 overflow-y-auto ps-5 text-sm wrap-break-word text-gray-700 dark:text-gray-300">
              {hatalar.map((h, i) => (
                <li key={i}>{kalemMetni(h)}</li>
              ))}
            </ul>
          </div>
        )}

        {sonuc && sonuc.gecerli && (
          <div className="rounded-xl border border-success-200 p-4 dark:border-success-500/40">
            <h5 className="text-sm font-semibold text-success-700 dark:text-success-400">{sonuc.yazildi ? t("yazildi") : t("gecerli")}</h5>
            {sonuc.ozet && (
              <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm sm:grid-cols-3">
                {OZET_ANAHTARLARI.map((k) => (
                  <div key={k}>
                    <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t(`ozet.${k}`)}</dt>
                    <dd className="text-gray-800 dark:text-white/90">{sonuc.ozet?.[k] ?? 0}</dd>
                  </div>
                ))}
              </dl>
            )}
          </div>
        )}

        {yazilabilir && (
          <div>
            <p className="mb-2 text-sm text-gray-600 dark:text-gray-300">{t("yazNot")}</p>
            <button type="button" className={primaryBtn} disabled={islemde} onClick={() => void calistir(false)}>
              {islemde ? t("yaziliyor") : t("onaylaYaz")}
            </button>
          </div>
        )}
      </div>
    </section>
  );
}
