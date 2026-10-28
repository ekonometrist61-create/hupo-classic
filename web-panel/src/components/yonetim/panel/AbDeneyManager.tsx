"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

// admin_ab_deney_* RPC'leri (20261121000000_ab_deney.sql). Atama ekranda yok; yalnız yönetim.
const ALFA = 0.05;
const GUC = 0.8;

type Deney = {
  id: string;
  ad: string;
  hipotez: string;
  birincil_metrik: string;
  guardrail: string[];
  referans_orani: number;
  minimum_fark: number;
  kol_basi_ornek: number;
  baslangic: string;
  bitis: string;
  sorumlu: string;
  durum: "taslak" | "yayinda" | "bitti" | "durduruldu";
  onay_notu: string | null;
};

const bosForm = () => ({
  ad: "",
  hipotez: "",
  birincil: "",
  guardrail: "",
  referans: "",
  minFark: "",
  kolOrnek: "",
  baslangic: "",
  bitis: "",
  sorumlu: "",
});

export default function AbDeneyManager() {
  const t = useTranslations("yonetim.abDeney");
  const [liste, setListe] = useState<Deney[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [mesaj, setMesaj] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [form, setForm] = useState(bosForm());
  const [notlar, setNotlar] = useState<Record<string, string>>({});
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_ab_deney_listele", { p_limit: 50 });
      if (cancelled) return;
      if (error) {
        setHata(error.message);
        setListe(null);
      } else {
        setHata(null);
        setListe(data as Deney[]);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const yenile = () => {
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const kaydet = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setHata(null);
    setMesaj(null);
    const guardrail = form.guardrail.split(",").map((s) => s.trim()).filter(Boolean);
    const referans = Number(form.referans) / 100;
    const minFark = Number(form.minFark) / 100;
    const kolOrnek = Number(form.kolOrnek);
    if (guardrail.length < 2) {
      setHata(t("errors.guardrail"));
      return;
    }
    if (!(referans > 0 && referans < 1) || !(minFark > 0 && minFark < 1)) {
      setHata(t("errors.percent"));
      return;
    }
    setBusy(true);
    const { error } = await createClient().rpc("admin_ab_deney_kaydet", {
      p_ad: form.ad.trim(),
      p_hipotez: form.hipotez.trim(),
      p_birincil_metrik: form.birincil.trim(),
      p_guardrail: guardrail,
      p_referans_orani: referans,
      p_minimum_fark: minFark,
      p_alfa: ALFA,
      p_guc: GUC,
      p_kol_basi_ornek: kolOrnek,
      p_baslangic: form.baslangic,
      p_bitis: form.bitis,
      p_sorumlu: form.sorumlu.trim(),
    });
    setBusy(false);
    if (error) {
      setHata(error.message);
      return;
    }
    setForm(bosForm());
    setMesaj(t("saved"));
    yenile();
  };

  const baslat = async (id: string) => {
    const not = (notlar[id] ?? "").trim();
    if (!not) {
      setHata(t("errors.onayNotu"));
      return;
    }
    if (!window.confirm(t("confirmStart"))) return;
    setBusy(true);
    const { error } = await createClient().rpc("admin_ab_deney_baslat", { p_id: id, p_onay_notu: not });
    setBusy(false);
    if (error) {
      setHata(error.message);
      return;
    }
    setMesaj(t("started"));
    yenile();
  };

  const durdur = async (id: string) => {
    const neden = (notlar[id] ?? "").trim();
    if (!neden) {
      setHata(t("errors.neden"));
      return;
    }
    if (!window.confirm(t("confirmStop"))) return;
    setBusy(true);
    const { error } = await createClient().rpc("admin_ab_deney_durdur", { p_id: id, p_neden: neden });
    setBusy(false);
    if (error) {
      setHata(error.message);
      return;
    }
    setMesaj(t("stopped"));
    yenile();
  };

  const alan = (anahtar: keyof ReturnType<typeof bosForm>, etiket: string, tip = "text") => (
    <div>
      <label className={labelClass} htmlFor={`ab-${anahtar}`}>{etiket}</label>
      <input
        id={`ab-${anahtar}`}
        type={tip}
        className={inputClass}
        value={form[anahtar]}
        onChange={(e) => setForm((f) => ({ ...f, [anahtar]: e.target.value }))}
        required
      />
    </div>
  );

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("create.title")}</h2>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("create.note")}</p>
        <form onSubmit={kaydet} className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {alan("ad", t("create.fields.name"))}
          {alan("birincil", t("create.fields.primary"))}
          {alan("sorumlu", t("create.fields.owner"))}
          <div className="sm:col-span-2 lg:col-span-3">
            <label className={labelClass} htmlFor="ab-hipotez">{t("create.fields.hypothesis")}</label>
            <input id="ab-hipotez" type="text" className={inputClass} value={form.hipotez}
              onChange={(e) => setForm((f) => ({ ...f, hipotez: e.target.value }))} required />
          </div>
          <div className="sm:col-span-2 lg:col-span-3">
            <label className={labelClass} htmlFor="ab-guardrail">{t("create.fields.guardrail")}</label>
            <input id="ab-guardrail" type="text" className={inputClass} value={form.guardrail}
              placeholder={t("create.fields.guardrailPlaceholder")}
              onChange={(e) => setForm((f) => ({ ...f, guardrail: e.target.value }))} required />
          </div>
          {alan("referans", t("create.fields.baseline"), "number")}
          {alan("minFark", t("create.fields.minEffect"), "number")}
          {alan("kolOrnek", t("create.fields.sample"), "number")}
          {alan("baslangic", t("create.fields.start"), "date")}
          {alan("bitis", t("create.fields.end"), "date")}
          <div className="flex items-end">
            <button type="submit" className={`${primaryBtn} w-full`} disabled={busy}>{t("create.submit")}</button>
          </div>
        </form>
      </section>

      {mesaj && <p role="status" className="text-sm text-success-600 dark:text-success-500">{mesaj}</p>}
      {hata && <p role="alert" className="text-sm text-error-600 dark:text-error-500">{hata}</p>}

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">{t("list.title")}</h2>
        {loading ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : !liste || liste.length === 0 ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("list.empty")}</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <caption className="sr-only">{t("list.title")}</caption>
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th scope="col" className={thClass}>{t("list.cols.name")}</th>
                  <th scope="col" className={thClass}>{t("list.cols.status")}</th>
                  <th scope="col" className={thClass}>{t("list.cols.dates")}</th>
                  <th scope="col" className={thClass}>{t("list.cols.guardrail")}</th>
                  <th scope="col" className={thClass}>{t("list.cols.action")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {liste.map((d) => (
                  <tr key={d.id}>
                    <td className={tdClass}>
                      <span className="block font-medium text-gray-800 dark:text-white/90">{d.ad}</span>
                      <span className="block text-theme-xs text-gray-500 dark:text-gray-400">{d.hipotez}</span>
                    </td>
                    <td className={tdClass}>{t(`status.${d.durum}`)}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>{d.baslangic} → {d.bitis}</td>
                    <td className={tdClass}>{d.guardrail.join(", ")}</td>
                    <td className={tdClass}>
                      {d.durum === "taslak" && (
                        <div className="flex flex-col gap-2">
                          <input type="text" className={inputClass} aria-label={t("start.note")}
                            placeholder={t("start.notePlaceholder")} value={notlar[d.id] ?? ""}
                            onChange={(e) => setNotlar((n) => ({ ...n, [d.id]: e.target.value }))} />
                          <button type="button" className={primaryBtn} disabled={busy} onClick={() => baslat(d.id)}>
                            {t("start.label")}
                          </button>
                        </div>
                      )}
                      {d.durum === "yayinda" && (
                        <div className="flex flex-col gap-2">
                          <input type="text" className={inputClass} aria-label={t("stop.reason")}
                            placeholder={t("stop.reasonPlaceholder")} value={notlar[d.id] ?? ""}
                            onChange={(e) => setNotlar((n) => ({ ...n, [d.id]: e.target.value }))} />
                          <button type="button" className={outlineBtn} disabled={busy} onClick={() => durdur(d.id)}>
                            {t("stop.label")}
                          </button>
                        </div>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
