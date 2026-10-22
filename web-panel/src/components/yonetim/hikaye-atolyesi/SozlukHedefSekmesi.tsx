"use client";

// Sözlük (tema/ders/değer/çatı değer) ve öğrenme hedefi kataloğu. Hedef onayı dört göz: onaylayan ≠ oluşturan (sunucu zorlar).
import { useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall } from "@/components/yonetim/useAdminRpc";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni } from "./ortak";
import SozlukYukle from "./SozlukYukle";

const SOZLUK_TURLERI = ["tema", "ders", "deger", "cati_deger"] as const;
const HEDEF_TURLERI = ["lexeme", "idiom", "proverb", "homonym", "concept", "fact", "misconception", "value"] as const;
const KANIT = ["A", "B", "C", "D"] as const;

export default function SozlukHedefSekmesi() {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 lg:grid-cols-2">
        <SozlukFormu />
        <HedefFormu />
      </div>
      <SozlukYukle />
    </div>
  );
}

function SozlukFormu() {
  const t = useTranslations("yonetim.hikayeAtolyesi.sozluk");
  const hata = useHataMetni();
  const [tur, setTur] = useState<(typeof SOZLUK_TURLERI)[number]>("tema");
  const [anahtar, setAnahtar] = useState("");
  const [ad, setAd] = useState("");
  const [aktif, setAktif] = useState(true);
  const [islemde, setIslemde] = useState(false);
  const [basari, setBasari] = useState<string | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);

  const kaydet = async (e: React.FormEvent) => {
    e.preventDefault();
    setBasari(null);
    setHataMesaji(null);
    const k = anahtar.trim();
    const desen = tur === "deger" ? /^D([1-9]|1[0-9]|20)$/ : /^[a-z][a-z0-9_]{1,39}$/;
    if (!desen.test(k)) return setHataMesaji(t(tur === "deger" ? "anahtarDeger" : "anahtarKod"));
    if (ad.trim().length < 1 || ad.trim().length > 80) return setHataMesaji(t("adGerekli"));
    setIslemde(true);
    const { error } = await adminCall("okuma_sozluk_kaydet", { p_tur: tur, p_anahtar: k, p_ad: ad.trim(), p_aktif: aktif });
    setIslemde(false);
    if (error) return setHataMesaji(hata(error));
    setBasari(t("kaydedildi", { anahtar: k }));
  };

  return (
    <form onSubmit={kaydet} className="space-y-4 rounded-xl border border-gray-200 p-4 sm:p-5 dark:border-gray-800" aria-labelledby="ha-sozluk-b">
      <div>
        <h4 id="ha-sozluk-b" className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h4>
        <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-sz-tur">{t("tur")}</label>
        <select id="ha-sz-tur" className={inputClass} value={tur} onChange={(e) => setTur(e.target.value as typeof tur)}>
          {SOZLUK_TURLERI.map((x) => (
            <option key={x} value={x}>{t(`turler.${x}`)}</option>
          ))}
        </select>
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-sz-anahtar">{t("anahtar")}</label>
        <input id="ha-sz-anahtar" className={inputClass} value={anahtar} onChange={(e) => setAnahtar(e.target.value)} placeholder={tur === "deger" ? "D12" : "sabir_emek"} autoComplete="off" />
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-sz-ad">{t("ad")}</label>
        <input id="ha-sz-ad" className={inputClass} value={ad} maxLength={80} onChange={(e) => setAd(e.target.value)} />
      </div>
      <label className="flex min-h-11 items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
        <input type="checkbox" className="size-4" checked={aktif} onChange={(e) => setAktif(e.target.checked)} />
        {t("aktif")}
      </label>
      {!aktif && <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("pasifNot")}</p>}
      <div aria-live="polite" className="space-y-2">
        {basari && <p className="text-sm text-success-700 dark:text-success-400">{basari}</p>}
        <ErrorNote message={hataMesaji} />
      </div>
      <button type="submit" className={primaryBtn} disabled={islemde}>
        {islemde ? t("kaydediliyor") : t("kaydet")}
      </button>
    </form>
  );
}

function HedefFormu() {
  const t = useTranslations("yonetim.hikayeAtolyesi.hedef");
  const hata = useHataMetni();
  const [id, setId] = useState("");
  const [tur, setTur] = useState<(typeof HEDEF_TURLERI)[number]>("lexeme");
  const [etiket, setEtiket] = useState("");
  const [sinif, setSinif] = useState("");
  const [kanit, setKanit] = useState<(typeof KANIT)[number]>("C");
  const [onayla, setOnayla] = useState(false);
  const [islemde, setIslemde] = useState(false);
  const [basari, setBasari] = useState<string | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);

  const kaydet = async (e: React.FormEvent) => {
    e.preventDefault();
    setBasari(null);
    setHataMesaji(null);
    if (!/^[a-z0-9_]{1,80}$/.test(id.trim())) return setHataMesaji(t("idGecersiz"));
    if (etiket.trim().length < 2 || etiket.trim().length > 120) return setHataMesaji(t("etiketGecersiz"));
    if (sinif && !(Number(sinif) >= 1 && Number(sinif) <= 8)) return setHataMesaji(t("sinifGecersiz"));
    setIslemde(true);
    const { error } = await adminCall("okuma_hedef_kaydet", {
      p_id: id.trim(),
      p_tur: tur,
      p_etiket: etiket.trim(),
      p_sinif: sinif ? Number(sinif) : null,
      p_kanit_duzeyi: kanit,
      p_onayla: onayla,
    });
    setIslemde(false);
    if (error) return setHataMesaji(hata(error));
    setBasari(onayla ? t("onaylandi", { id: id.trim() }) : t("kaydedildi", { id: id.trim() }));
    setOnayla(false);
  };

  return (
    <form onSubmit={kaydet} className="space-y-4 rounded-xl border border-gray-200 p-4 sm:p-5 dark:border-gray-800" aria-labelledby="ha-hedef-b">
      <div>
        <h4 id="ha-hedef-b" className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h4>
        <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-hd-id">{t("id")}</label>
        <input id="ha-hd-id" className={inputClass} value={id} onChange={(e) => setId(e.target.value)} placeholder="goz_kulak_olmak" autoComplete="off" />
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label className={labelClass} htmlFor="ha-hd-tur">{t("tur")}</label>
          <select id="ha-hd-tur" className={inputClass} value={tur} onChange={(e) => setTur(e.target.value as typeof tur)}>
            {HEDEF_TURLERI.map((x) => (
              <option key={x} value={x}>{t(`turler.${x}`)}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="ha-hd-kanit">{t("kanit")}</label>
          <select id="ha-hd-kanit" className={inputClass} value={kanit} onChange={(e) => setKanit(e.target.value as typeof kanit)}>
            {KANIT.map((x) => (
              <option key={x} value={x}>{t(`kanitDuzeyleri.${x}`)}</option>
            ))}
          </select>
        </div>
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-hd-etiket">{t("etiket")}</label>
        <input id="ha-hd-etiket" className={inputClass} value={etiket} maxLength={120} onChange={(e) => setEtiket(e.target.value)} />
      </div>
      <div>
        <label className={labelClass} htmlFor="ha-hd-sinif">{t("sinif")}</label>
        <select id="ha-hd-sinif" className={`${inputClass} sm:max-w-48`} value={sinif} onChange={(e) => setSinif(e.target.value)}>
          <option value="">{t("sinifYok")}</option>
          {[1, 2, 3, 4, 5, 6, 7, 8].map((n) => (
            <option key={n} value={n}>{n}</option>
          ))}
        </select>
      </div>
      <label className="flex min-h-11 items-start gap-2 text-sm text-gray-700 dark:text-gray-300">
        <input type="checkbox" className="mt-1 size-4" checked={onayla} onChange={(e) => setOnayla(e.target.checked)} />
        <span>
          {t("onayla")}
          <span className="block text-theme-xs text-gray-500 dark:text-gray-400">{t("dortGoz")}</span>
        </span>
      </label>
      <div aria-live="polite" className="space-y-2">
        {basari && <p className="text-sm text-success-700 dark:text-success-400">{basari}</p>}
        <ErrorNote message={hataMesaji} />
      </div>
      <button type="submit" className={onayla ? outlineBtn : primaryBtn} disabled={islemde}>
        {islemde ? t("kaydediliyor") : onayla ? t("onaylaDugme") : t("kaydet")}
      </button>
    </form>
  );
}
