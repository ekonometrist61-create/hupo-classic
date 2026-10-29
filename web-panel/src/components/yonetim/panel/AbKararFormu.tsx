"use client";

import { useState, type FormEvent } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

// admin_ab_karar_kaydet (20261122000000_ab_karar.sql). Kuralları sunucu uygular:
// bitiş öncesi karar yok; guardrail kararı yalnız durdurulmuş deneyde.
type Deney = { id: string; ad: string; durum: string; birincil_metrik: string };

type Sonuc = "karar_hazir" | "guardrail_ihlali" | "srm_gecersiz" | "yetersiz_ornek";
type Karar = "kazan_deney" | "kazan_kontrol" | "uygulama_yok" | "tekrarla";

type KolSayi = { maruziyet: number | null; metrikler: Record<string, number> | null };
type SayilarYanit = { esik: number; kollar: { kontrol: KolSayi; deney: KolSayi } };

// Normal dağılım: Abramowitz-Stegun 7.1.26 erf yaklaşımı (hata < 1.5e-7).
// Referans hesap: scripts/ab-analiz/analiz.py (iki oranlı z, iki kuyruklu).
function erf(x: number): number {
  const s = Math.sign(x);
  const a = Math.abs(x);
  const t = 1 / (1 + 0.3275911 * a);
  const y = 1 - ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * Math.exp(-a * a);
  return s * y;
}
const normalCdf = (z: number) => 0.5 * (1 + erf(z / Math.SQRT2));

// Kontrol (xk/nk) ve deney (xd/nd) için p (iki kuyruklu) ve %95 güven aralığı (oran farkı, 0–1 ölçeğinde).
export function ikiOranli(xk: number, nk: number, xd: number, nd: number) {
  const pk = xk / nk;
  const pd = xd / nd;
  const fark = pd - pk;
  const havuz = (xk + xd) / (nk + nd);
  const se0 = Math.sqrt(havuz * (1 - havuz) * (1 / nk + 1 / nd));
  const z = se0 === 0 ? 0 : fark / se0;
  const p = 2 * (1 - normalCdf(Math.abs(z)));
  const se = Math.sqrt((pk * (1 - pk)) / nk + (pd * (1 - pd)) / nd);
  return { p, lo: fark - 1.959964 * se, hi: fark + 1.959964 * se };
}

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
  const [dolduruluyor, setDolduruluyor] = useState(false);

  // Sayıları veritabanından alır (admin_ab_sayilar); oran, p ve güven aralığını bu sayılardan hesaplar.
  const veritabanindanDoldur = async () => {
    setHata(null);
    setMesaj(null);
    const d = uygun.find((x) => x.id === deneyId);
    if (!d) {
      setHata(t("errors.deney"));
      return;
    }
    setDolduruluyor(true);
    const { data, error } = await createClient().rpc("admin_ab_sayilar", { p_deney: d.id });
    setDolduruluyor(false);
    if (error) {
      setHata(error.message);
      return;
    }
    const y = data as SayilarYanit;
    const k = y.kollar.kontrol;
    const dy = y.kollar.deney;
    if (k.maruziyet === null || dy.maruziyet === null || !k.maruziyet || !dy.maruziyet) {
      setHata(t("lowN", { esik: y.esik }));
      return;
    }
    const xk = k.metrikler?.[d.birincil_metrik] ?? 0;
    const xd = dy.metrikler?.[d.birincil_metrik] ?? 0;
    const r = ikiOranli(xk, k.maruziyet, xd, dy.maruziyet);
    setKontrol(((xk / k.maruziyet) * 100).toFixed(2));
    setDeney(((xd / dy.maruziyet) * 100).toFixed(2));
    setP(r.p.toFixed(6));
    setCiAlt((r.lo * 100).toFixed(2));
    setCiUst((r.hi * 100).toFixed(2));
    setMesaj(t("filled", { kn: k.maruziyet, dn: dy.maruziyet }));
  };
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
            <button type="button" className={`${outlineBtn} mr-3 w-full sm:w-auto`} disabled={dolduruluyor || !deneyId} onClick={veritabanindanDoldur}>
              {t("fill")}
            </button>
            <button type="submit" className={`${primaryBtn} w-full sm:w-auto`} disabled={busy}>{t("submit")}</button>
          </div>
        </form>
      )}
      {mesaj && <p role="status" className="mt-4 text-sm text-success-600 dark:text-success-500">{mesaj}</p>}
      {hata && <p role="alert" className="mt-4 text-sm text-error-600 dark:text-error-500">{hata}</p>}
    </section>
  );
}
