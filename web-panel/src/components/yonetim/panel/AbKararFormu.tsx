"use client";

import { useState, type FormEvent } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, inputClass, labelClass, primaryBtn } from "./styles";

// admin_ab_karar_kaydet (20261122000000_ab_karar.sql). Kuralları sunucu uygular:
// bitiş öncesi karar yok; guardrail kararı yalnız durdurulmuş deneyde.
type Deney = { id: string; ad: string; durum: string };

type Sonuc = "karar_hazir" | "guardrail_ihlali" | "srm_gecersiz" | "yetersiz_ornek";
type Karar = "kazan_deney" | "kazan_kontrol" | "uygulama_yok" | "tekrarla";

export default function AbKararFormu({ deneyler, onSaved }: { deneyler: Deney[]; onSaved: () => void }) {
  const t = useTranslations("yonetim.abDeney.decision");
  const uygun = deneyler.filter((d) => d.durum === "yayinda" || d.durum === "durduruldu");
  const [deneyId, setDeneyId] = useState("");
  const [sonuc, setSonuc] = useState<Sonuc>("karar_hazir");
  const [kontrol, setKontrol] = useState("");
  const [deney, setDeney] = useState("");
  const [ciAlt, setCiAlt] = useState("");
  const [ciUst, setCiUst] = useState("");
  const [p, setP] = useState("");
  const [srmP, setSrmP] = useState("");
  const [karar, setKarar] = useState<Karar>("kazan_deney");
  const [neden, setNeden] = useState("");
  const [busy, setBusy] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [mesaj, setMesaj] = useState<string | null>(null);

  const kaydet = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setHata(null);
    setMesaj(null);
    if (!deneyId) {
      setHata(t("errors.deney"));
      return;
    }
    const birincil =
      sonuc === "karar_hazir"
        ? {
            kontrol_orani: Number(kontrol) / 100,
            deney_orani: Number(deney) / 100,
            fark: (Number(deney) - Number(kontrol)) / 100,
            ci: [Number(ciAlt) / 100, Number(ciUst) / 100],
            p: Number(p),
            anlamli: Number(p) < 0.05,
          }
        : null;
    if (sonuc === "karar_hazir" && [kontrol, deney, ciAlt, ciUst, p].some((v) => v.trim() === "" || Number.isNaN(Number(v)))) {
      setHata(t("errors.sayi"));
      return;
    }
    setBusy(true);
    const { error } = await createClient().rpc("admin_ab_karar_kaydet", {
      p_deney: deneyId,
      p_sonuc_durum: sonuc,
      p_birincil: birincil,
      p_guardrail: [],
      p_srm_p: srmP.trim() === "" ? null : Number(srmP),
      p_neden: neden.trim(),
      p_karar: sonuc === "karar_hazir" ? karar : null,
    });
    setBusy(false);
    if (error) {
      setHata(error.message);
      return;
    }
    setMesaj(t("saved"));
    setDeneyId("");
    onSaved();
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("title")}</h2>
      <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("note")}</p>
      {uygun.length === 0 ? (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("none")}</p>
      ) : (
        <form onSubmit={kaydet} className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div className="sm:col-span-2 lg:col-span-3">
            <label className={labelClass} htmlFor="karar-deney">{t("fields.experiment")}</label>
            <select id="karar-deney" className={inputClass} value={deneyId} onChange={(e) => setDeneyId(e.target.value)} required>
              <option value="">{t("fields.choose")}</option>
              {uygun.map((d) => (
                <option key={d.id} value={d.id}>{d.ad}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="karar-sonuc">{t("fields.outcome")}</label>
            <select id="karar-sonuc" className={inputClass} value={sonuc} onChange={(e) => setSonuc(e.target.value as Sonuc)}>
              <option value="karar_hazir">{t("outcome.karar_hazir")}</option>
              <option value="guardrail_ihlali">{t("outcome.guardrail_ihlali")}</option>
              <option value="srm_gecersiz">{t("outcome.srm_gecersiz")}</option>
              <option value="yetersiz_ornek">{t("outcome.yetersiz_ornek")}</option>
            </select>
          </div>
          {sonuc === "karar_hazir" && (
            <>
              <div>
                <label className={labelClass} htmlFor="karar-kontrol">{t("fields.control")}</label>
                <input id="karar-kontrol" type="number" step="any" className={inputClass} value={kontrol} onChange={(e) => setKontrol(e.target.value)} />
              </div>
              <div>
                <label className={labelClass} htmlFor="karar-deney-oran">{t("fields.treatment")}</label>
                <input id="karar-deney-oran" type="number" step="any" className={inputClass} value={deney} onChange={(e) => setDeney(e.target.value)} />
              </div>
              <div>
                <label className={labelClass} htmlFor="karar-p">{t("fields.p")}</label>
                <input id="karar-p" type="number" step="any" className={inputClass} value={p} onChange={(e) => setP(e.target.value)} />
              </div>
              <div>
                <label className={labelClass} htmlFor="karar-ci-alt">{t("fields.ciLow")}</label>
                <input id="karar-ci-alt" type="number" step="any" className={inputClass} value={ciAlt} onChange={(e) => setCiAlt(e.target.value)} />
              </div>
              <div>
                <label className={labelClass} htmlFor="karar-ci-ust">{t("fields.ciHigh")}</label>
                <input id="karar-ci-ust" type="number" step="any" className={inputClass} value={ciUst} onChange={(e) => setCiUst(e.target.value)} />
              </div>
              <div>
                <label className={labelClass} htmlFor="karar-secim">{t("fields.decision")}</label>
                <select id="karar-secim" className={inputClass} value={karar} onChange={(e) => setKarar(e.target.value as Karar)}>
                  <option value="kazan_deney">{t("decisionOptions.kazan_deney")}</option>
                  <option value="kazan_kontrol">{t("decisionOptions.kazan_kontrol")}</option>
                  <option value="uygulama_yok">{t("decisionOptions.uygulama_yok")}</option>
                  <option value="tekrarla">{t("decisionOptions.tekrarla")}</option>
                </select>
              </div>
            </>
          )}
          <div>
            <label className={labelClass} htmlFor="karar-srm">{t("fields.srm")}</label>
            <input id="karar-srm" type="number" step="any" className={inputClass} value={srmP} onChange={(e) => setSrmP(e.target.value)} />
          </div>
          <div className="sm:col-span-2 lg:col-span-3">
            <label className={labelClass} htmlFor="karar-neden">{t("fields.reason")}</label>
            <input id="karar-neden" type="text" className={inputClass} value={neden} maxLength={500} onChange={(e) => setNeden(e.target.value)} required />
          </div>
          <div className="flex items-end sm:col-span-2 lg:col-span-3">
            <button type="submit" className={`${primaryBtn} w-full sm:w-auto`} disabled={busy}>{t("submit")}</button>
          </div>
        </form>
      )}
      {mesaj && <p role="status" className="mt-4 text-sm text-success-600 dark:text-success-500">{mesaj}</p>}
      {hata && <p role="alert" className="mt-4 text-sm text-error-600 dark:text-error-500">{hata}</p>}
    </section>
  );
}
