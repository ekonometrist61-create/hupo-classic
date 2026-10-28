"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import DesktopOnly from "@/components/ui/DesktopOnly";
import { cardClass, inputClass, primaryBtn } from "@/components/yonetim/panel/styles";
import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";

// Deneme özellik sınırları (app_settings.deneme_sinirlari). Anahtarlar veritabanındaki
// özellik adlarıyla birebir aynıdır; sıra ekranda gösterilen sıradır.
export const DENEME_OZELLIKLER = [
  "soru",
  "kelime_evreni",
  "carpim_sifresi",
  "okuma_hikayesi",
  "meydan_okuma",
  "deneme_sinavi",
] as const;

type Ozellik = (typeof DENEME_OZELLIKLER)[number];
type Pencere = "gunluk" | "deneme";
type Kural = { sinir: number; pencere: Pencere };
type Sinirlar = {
  varsayilan?: Partial<Record<Ozellik, Kural>>;
  siniflar?: Record<string, Partial<Record<Ozellik, Kural>>>;
};
// Form alanları metin tutulur; sınıf alanında boş sınır = varsayılanı kullan.
type Alan = { sinir: string; pencere: Pencere };
type Form = Record<Ozellik, Alan>;

const SINIFLAR = ["1", "2", "3", "4", "5", "6", "7", "8"];
const VARSAYILAN_PENCERE: Record<Ozellik, Pencere> = {
  soru: "gunluk",
  kelime_evreni: "gunluk",
  carpim_sifresi: "gunluk",
  okuma_hikayesi: "gunluk",
  meydan_okuma: "deneme",
  deneme_sinavi: "deneme",
};

const tamSayiMi = (s: string) => /^\d{1,4}$/.test(s) && Number(s) <= 1000;

function bosForm(kaynak?: Partial<Record<Ozellik, Kural>>): Form {
  const form = {} as Form;
  for (const o of DENEME_OZELLIKLER) {
    const k = kaynak?.[o];
    form[o] = k
      ? { sinir: String(k.sinir), pencere: k.pencere }
      : { sinir: "", pencere: VARSAYILAN_PENCERE[o] };
  }
  return form;
}

// Form → RPC gövdesi. Geçersiz bir sınır varsa null döner.
function payloadKur(varsayilan: Form, siniflar: Record<string, Form>): Sinirlar | null {
  const v: Partial<Record<Ozellik, Kural>> = {};
  for (const o of DENEME_OZELLIKLER) {
    const a = varsayilan[o];
    if (!tamSayiMi(a.sinir)) return null;
    v[o] = { sinir: Number(a.sinir), pencere: a.pencere };
  }

  const s: Record<string, Partial<Record<Ozellik, Kural>>> = {};
  for (const [sinif, form] of Object.entries(siniflar)) {
    const ozel: Partial<Record<Ozellik, Kural>> = {};
    for (const o of DENEME_OZELLIKLER) {
      const a = form[o];
      if (a.sinir.trim() === "") continue;
      if (!tamSayiMi(a.sinir)) return null;
      ozel[o] = { sinir: Number(a.sinir), pencere: a.pencere };
    }
    if (Object.keys(ozel).length > 0) s[sinif] = ozel;
  }
  return { varsayilan: v, siniflar: s };
}

type Etiketler = { sinir: string; pencere: string; gunluk: string; deneme: string };

function AlanSatiri({
  etiket,
  alan,
  bosYer,
  onChange,
  labels,
}: {
  etiket: string;
  alan: Alan;
  bosYer?: string;
  onChange: (degisen: Partial<Alan>) => void;
  labels: Etiketler;
}) {
  return (
    <tr className="border-t border-gray-100 dark:border-gray-800">
      <th scope="row" className="py-2 pr-4 text-left text-sm font-medium text-gray-800 dark:text-white/90">
        {etiket}
      </th>
      <td className="py-2 pr-4">
        <input
          type="number"
          inputMode="numeric"
          min={0}
          max={1000}
          step={1}
          value={alan.sinir}
          placeholder={bosYer}
          onChange={(e) => onChange({ sinir: e.target.value })}
          aria-label={`${etiket} · ${labels.sinir}`}
          className={inputClass}
        />
      </td>
      <td className="py-2">
        <select
          value={alan.pencere}
          onChange={(e) => onChange({ pencere: e.target.value as Pencere })}
          aria-label={`${etiket} · ${labels.pencere}`}
          className={inputClass}
        >
          <option value="gunluk">{labels.gunluk}</option>
          <option value="deneme">{labels.deneme}</option>
        </select>
      </td>
    </tr>
  );
}

export default function DenemeSinirlariKarti() {
  const t = useTranslations("yonetim.denemeSinirlari");
  const state = useAdminRpc<Sinirlar>("admin_get_deneme_sinirlari");

  const [varsayilan, setVarsayilan] = useState<Form>(() => bosForm());
  const [siniflar, setSiniflar] = useState<Record<string, Form>>({});
  const [secili, setSecili] = useState("3");
  const [kaydediliyor, setKaydediliyor] = useState(false);
  const [geri, setGeri] = useState<{ tur: "ok" | "hata"; msg: string } | null>(null);

  useEffect(() => {
    const s = state.data;
    if (!s) return;
    setVarsayilan(bosForm(s.varsayilan));
    const harita: Record<string, Form> = {};
    for (const [sinif, ozel] of Object.entries(s.siniflar ?? {})) harita[sinif] = bosForm(ozel);
    setSiniflar(harita);
  }, [state.data]);

  const sinifForm = siniflar[secili] ?? bosForm();
  const etiketi = (o: Ozellik) => t(`ozellikler.${o}`);
  const labels: Etiketler = {
    sinir: t("sinir"),
    pencere: t("pencere"),
    gunluk: t("pencereGunluk"),
    deneme: t("pencereDeneme"),
  };

  async function kaydet() {
    setGeri(null);
    const payload = payloadKur(varsayilan, siniflar);
    if (!payload) {
      setGeri({ tur: "hata", msg: t("hataAralik") });
      return;
    }
    setKaydediliyor(true);
    const sonuc = await adminCall("admin_set_deneme_sinirlari", { p_value: payload });
    setKaydediliyor(false);
    if (sonuc.error) {
      setGeri({ tur: "hata", msg: `${t("hataKaydet")} ${sonuc.error}` });
      return;
    }
    setGeri({ tur: "ok", msg: t("kaydedildi") });
    state.reload();
  }

  return (
    <DesktopOnly>
      <section className={`${cardClass} mt-6`} aria-labelledby="deneme-sinirlari-baslik">
        <div className="px-6 pt-6">
          <h2 id="deneme-sinirlari-baslik" className="text-lg font-semibold text-gray-800 dark:text-white/90">
            {t("title")}
          </h2>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{t("desc")}</p>
        </div>

        {state.missing && (
          <p role="alert" className="px-6 pt-4 text-sm text-error-600 dark:text-error-400">
            {t("eksik")}
          </p>
        )}
        {!state.missing && state.error && (
          <p role="alert" className="px-6 pt-4 text-sm text-error-600 dark:text-error-400">
            {state.error}
          </p>
        )}

        {!state.missing && !state.error && (
          <div className="space-y-6 px-6 py-6">
            <div>
              <h3 className="text-sm font-semibold text-gray-700 dark:text-gray-200">{t("varsayilanBaslik")}</h3>
              <div className="mt-2 overflow-x-auto">
                <table className="w-full min-w-105 border-collapse">
                  <thead>
                    <tr className="text-left text-xs text-gray-500 dark:text-gray-400">
                      <th className="pb-2 pr-4 font-medium">{t("ozellik")}</th>
                      <th className="pb-2 pr-4 font-medium">{t("sinir")}</th>
                      <th className="pb-2 font-medium">{t("pencere")}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {DENEME_OZELLIKLER.map((o) => (
                      <AlanSatiri
                        key={o}
                        etiket={etiketi(o)}
                        alan={varsayilan[o]}
                        labels={labels}
                        onChange={(d) =>
                          setVarsayilan((prev) => ({ ...prev, [o]: { ...prev[o], ...d } }))
                        }
                      />
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div>
              <h3 className="text-sm font-semibold text-gray-700 dark:text-gray-200">{t("sinifBaslik")}</h3>
              <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{t("sinifDesc")}</p>
              <label className="mt-3 flex items-center gap-3 text-sm text-gray-700 dark:text-gray-300">
                <span>{t("sinifSec")}</span>
                <select
                  value={secili}
                  onChange={(e) => setSecili(e.target.value)}
                  className={inputClass}
                >
                  {SINIFLAR.map((n) => (
                    <option key={n} value={n}>
                      {t("sinifAd", { n })}
                    </option>
                  ))}
                </select>
              </label>
              <div className="mt-2 overflow-x-auto">
                <table className="w-full min-w-105 border-collapse">
                  <tbody>
                    {DENEME_OZELLIKLER.map((o) => (
                      <AlanSatiri
                        key={`${secili}-${o}`}
                        etiket={etiketi(o)}
                        alan={sinifForm[o]}
                        bosYer={t("bos")}
                        labels={labels}
                        onChange={(d) =>
                          setSiniflar((prev) => {
                            const mevcut = prev[secili] ?? bosForm();
                            return {
                              ...prev,
                              [secili]: { ...mevcut, [o]: { ...mevcut[o], ...d } },
                            };
                          })
                        }
                      />
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="flex flex-wrap items-center justify-end gap-3">
              {geri && (
                <p role={geri.tur === "hata" ? "alert" : "status"} className="mr-auto text-sm text-gray-600 dark:text-gray-300">
                  {geri.msg}
                </p>
              )}
              <button
                type="button"
                className={primaryBtn}
                onClick={kaydet}
                disabled={kaydediliyor || state.loading}
              >
                {kaydediliyor ? t("kaydediliyor") : t("kaydet")}
              </button>
            </div>
          </div>
        )}
      </section>
    </DesktopOnly>
  );
}
