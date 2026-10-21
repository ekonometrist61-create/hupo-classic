"use client";

// İçe aktar: paket JSON yükle/yapıştır → kuru çalıştırma → sonucu göster → onayla ve yaz.
// Geçersiz paket hata fırlatmaz; `gecerli:false` ve `hatalar[]` döner, panel `gecerli`'yi denetler.
import { useRef, useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall } from "@/components/yonetim/useAdminRpc";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni } from "./ortak";
import { kalemMetni, type IceAktarYaniti } from "./tipler";

const MAKS_BAYT = 1_500_000;

export default function IceAktarSekmesi({ onYazildi }: { onYazildi: () => void }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.iceAktar");
  const hata = useHataMetni();
  const dosyaRef = useRef<HTMLInputElement>(null);
  const [metin, setMetin] = useState("");
  const [paket, setPaket] = useState<unknown>(null);
  const [sonuc, setSonuc] = useState<IceAktarYaniti | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);
  const [islemde, setIslemde] = useState(false);

  const sifirla = () => {
    setSonuc(null);
    setHataMesaji(null);
    setPaket(null);
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
    let ayrisan = paket;
    if (kuru) {
      try {
        ayrisan = JSON.parse(metin);
      } catch {
        setSonuc(null);
        setHataMesaji(t("jsonHatali"));
        return;
      }
      setPaket(ayrisan);
    }
    setIslemde(true);
    const { data, error } = await adminCall<IceAktarYaniti>("okuma_paket_ice_aktar", { p_paket: ayrisan, p_kuru: kuru });
    setIslemde(false);
    if (error || !data) {
      setHataMesaji(hata(error ?? ""));
      return;
    }
    setSonuc(data);
    if (!kuru && data.yazildi) onYazildi();
  };

  const hatalar = sonuc?.hatalar ?? [];
  const uyarilar = sonuc?.uyarilar ?? [];
  const yazilabilir = !!sonuc && sonuc.gecerli && sonuc.kuru && !sonuc.mevcut;

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>

      <div>
        <label className={labelClass} htmlFor="ha-paket-dosya">{t("dosya")}</label>
        <input
          ref={dosyaRef}
          id="ha-paket-dosya"
          type="file"
          accept=".json,application/json"
          onChange={dosyaSec}
          className="block min-h-11 w-full text-sm text-gray-700 file:mr-3 file:min-h-11 file:rounded-lg file:border-0 file:bg-gray-100 file:px-4 file:text-sm file:font-medium file:text-gray-700 dark:text-gray-300 dark:file:bg-white/10 dark:file:text-gray-200"
        />
      </div>

      <div>
        <label className={labelClass} htmlFor="ha-paket-metin">{t("yapistir")}</label>
        <textarea
          id="ha-paket-metin"
          className={`${inputClass} h-56 py-3 font-mono text-xs md:text-xs`}
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
            <h4 className="text-sm font-semibold text-error-700 dark:text-error-400">{t("gecersiz", { sayi: hatalar.length })}</h4>
            <p className="mb-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("gecersizNot")}</p>
            <ul className="list-disc space-y-1 pl-5 text-sm wrap-break-word text-gray-700 dark:text-gray-300">
              {hatalar.map((h, i) => (
                <li key={i}>{kalemMetni(h)}</li>
              ))}
            </ul>
          </div>
        )}

        {sonuc && sonuc.gecerli && (
          <div className="rounded-xl border border-success-200 p-4 dark:border-success-500/40">
            <h4 className="text-sm font-semibold text-success-700 dark:text-success-400">
              {sonuc.yazildi ? t("yazildi") : sonuc.mevcut ? t("mevcut") : t("gecerli")}
            </h4>
            {sonuc.ozet && (
              <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm sm:grid-cols-4">
                {(
                  [
                    ["baslik", sonuc.ozet.baslik],
                    ["sinif", String(sonuc.ozet.ana_sinif)],
                    ["sayfa", String(sonuc.ozet.sayfa_sayisi)],
                    ["soru", String(sonuc.ozet.soru_sayisi)],
                    ["hedef", String(sonuc.ozet.hedef_sayisi)],
                    ["surum", sonuc.surum_no !== undefined ? String(sonuc.surum_no) : "-"],
                  ] as const
                ).map(([k, v]) => (
                  <div key={k}>
                    <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t(`ozet.${k}`)}</dt>
                    <dd className="wrap-break-word text-gray-800 dark:text-white/90">{v}</dd>
                  </div>
                ))}
              </dl>
            )}
          </div>
        )}

        {sonuc && uyarilar.length > 0 && (
          <div className="rounded-xl border border-warning-200 p-4 dark:border-warning-500/40">
            <h4 className="text-sm font-semibold text-warning-700 dark:text-warning-400">{t("uyarilar", { sayi: uyarilar.length })}</h4>
            <ul className="mt-2 list-disc space-y-1 pl-5 text-sm wrap-break-word text-gray-700 dark:text-gray-300">
              {uyarilar.map((u, i) => (
                <li key={i}>{kalemMetni(u)}</li>
              ))}
            </ul>
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
    </div>
  );
}
