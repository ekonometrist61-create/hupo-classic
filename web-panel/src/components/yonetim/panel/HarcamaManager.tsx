"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, dangerBtn, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";

// DB CHECK ve admin_harcama_ekle ile aynı liste (20261113000000_growth_harcama.sql).
const CHANNELS = ["meta", "google_ads", "tiktok", "youtube", "instagram", "diger"] as const;
const CURRENCIES = ["TRY", "USD", "EUR"] as const;
const WINDOWS = [30, 90, 365] as const;

type Channel = (typeof CHANNELS)[number];
type Currency = (typeof CURRENCIES)[number];

type Satir = {
  id: string;
  tarih: string;
  kanal: string;
  tutar: number | string;
  para_birimi: string;
  not: string | null;
};
type KanalToplam = { kanal: string; para_birimi: string; toplam: number | string };
type HarcamaListe = { gun: number; satirlar: Satir[]; kanal_toplamlari: KanalToplam[] };

// Yerel takvim gününü YYYY-MM-DD olarak verir (toISOString UTC kaydırır).
function bugunYerel(): string {
  const d = new Date();
  const ay = String(d.getMonth() + 1).padStart(2, "0");
  const gun = String(d.getDate()).padStart(2, "0");
  return `${d.getFullYear()}-${ay}-${gun}`;
}

function paraFormat(tutar: number | string, para: string): string {
  try {
    return new Intl.NumberFormat("tr-TR", { style: "currency", currency: para }).format(Number(tutar));
  } catch {
    return `${Number(tutar).toFixed(2)} ${para}`;
  }
}

type CacSatir = {
  para_birimi: string;
  harcama: number | string;
  yeni_hane: number | null;
  cac: number | string | null;
  durum: "hesaplandi" | "veri_az";
};
type CacYanit = { gun: number; yeni_hane: number | null; satirlar: CacSatir[]; durum: "ok" | "harcama_yok" };

// admin_growth_cac: toplam harcama / kayıtlı hane. Kanal bazlı CAC yok; para birimleri ayrı.
function CacKarti({ gun, reloadKey }: { gun: number; reloadKey: number }) {
  const t = useTranslations("yonetim.harcama");
  const [veri, setVeri] = useState<CacYanit | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_growth_cac", { p_gun: gun });
      if (cancelled) return;
      if (error) {
        setHata(error.message);
        setVeri(null);
      } else {
        setHata(null);
        setVeri(data as CacYanit);
      }
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [gun, reloadKey]);

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("cac.title")}</h2>
      <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("cac.note")}</p>
      {hata ? (
        <p role="status" className="text-sm text-error-600 dark:text-error-500">{hata}</p>
      ) : !veri ? null : (
        <>
          <p className="mb-4 text-sm text-gray-700 dark:text-gray-300">
            {t("cac.newHouseholds")}:{" "}
            <span className="font-semibold">{veri.yeni_hane === null ? t("cac.hidden") : veri.yeni_hane}</span>
          </p>
          {veri.durum === "harcama_yok" ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("cac.noSpend")}</p>
          ) : (
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              {veri.satirlar.map((s) => (
                <div key={s.para_birimi} className="rounded-xl border border-gray-100 p-4 dark:border-gray-800">
                  <p className="text-theme-xs text-gray-500 dark:text-gray-400">{s.para_birimi}</p>
                  <p className="mt-1 text-lg font-semibold text-gray-800 dark:text-white/90">
                    {s.cac === null ? t("cac.none") : paraFormat(s.cac, s.para_birimi)}
                  </p>
                  <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                    {t("cac.spend")}: {paraFormat(s.harcama, s.para_birimi)}
                    {s.durum === "veri_az" && ` · ${t("cac.lowData")}`}
                  </p>
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </section>
  );
}

export default function HarcamaManager() {
  const t = useTranslations("yonetim.harcama");

  const [gun, setGun] = useState<number>(90);
  const [reloadKey, setReloadKey] = useState(0);
  const [liste, setListe] = useState<HarcamaListe | null>(null);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [tarih, setTarih] = useState(bugunYerel());
  const [kanal, setKanal] = useState<Channel>("meta");
  const [tutar, setTutar] = useState("");
  const [para, setPara] = useState<Currency>("TRY");
  const [not, setNot] = useState("");
  const [saving, setSaving] = useState(false);
  const [formMsg, setFormMsg] = useState<{ tip: "ok" | "err"; metin: string } | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_harcama_listele", { p_gun: gun });
      if (cancelled) return;
      if (error) {
        setLoadError(error.message);
        setListe(null);
      } else {
        setLoadError(null);
        setListe(data as HarcamaListe);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [gun, reloadKey]);

  const kaydet = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setFormMsg(null);
    const sayi = Number(tutar.replace(",", "."));
    if (!tutar || !Number.isFinite(sayi) || sayi <= 0) {
      setFormMsg({ tip: "err", metin: t("form.errAmount") });
      return;
    }
    setSaving(true);
    const { error } = await createClient().rpc("admin_harcama_ekle", {
      p_tarih: tarih,
      p_kanal: kanal,
      p_tutar: sayi,
      p_para_birimi: para,
      p_not: not.trim() || null,
    });
    setSaving(false);
    if (error) {
      // Sunucu doğrulama mesajı (tarih, e-posta, tutar sınırı) olduğu gibi gösterilir.
      setFormMsg({ tip: "err", metin: error.message });
      return;
    }
    setFormMsg({ tip: "ok", metin: t("form.saved") });
    setTutar("");
    setNot("");
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const sil = async (id: string) => {
    if (!window.confirm(t("table.confirmDelete"))) return;
    setBusyId(id);
    const { error } = await createClient().rpc("admin_harcama_sil", { p_id: id });
    setBusyId(null);
    if (error) {
      setLoadError(error.message);
      return;
    }
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const satirlar = liste?.satirlar ?? [];
  const toplamlar = liste?.kanal_toplamlari ?? [];

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="mb-1 text-base font-semibold text-gray-800 dark:text-white/90">{t("form.title")}</h2>
        <p className="mb-5 text-sm text-gray-500 dark:text-gray-400">{t("description")}</p>

        <form onSubmit={kaydet} className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-6">
          <div className="lg:col-span-1">
            <label className={labelClass} htmlFor="h-tarih">{t("form.date")}</label>
            <input id="h-tarih" type="date" className={inputClass} value={tarih} max={bugunYerel()}
              onChange={(e) => setTarih(e.target.value)} required />
          </div>
          <div className="lg:col-span-1">
            <label className={labelClass} htmlFor="h-kanal">{t("form.channel")}</label>
            <select id="h-kanal" className={inputClass} value={kanal} onChange={(e) => setKanal(e.target.value as Channel)}>
              {CHANNELS.map((c) => (
                <option key={c} value={c}>{t(`channels.${c}`)}</option>
              ))}
            </select>
          </div>
          <div className="lg:col-span-1">
            <label className={labelClass} htmlFor="h-tutar">{t("form.amount")}</label>
            <input id="h-tutar" type="text" inputMode="decimal" className={inputClass} value={tutar}
              placeholder="0,00" onChange={(e) => setTutar(e.target.value)} required />
          </div>
          <div className="lg:col-span-1">
            <label className={labelClass} htmlFor="h-para">{t("form.currency")}</label>
            <select id="h-para" className={inputClass} value={para} onChange={(e) => setPara(e.target.value as Currency)}>
              {CURRENCIES.map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
          </div>
          <div className="sm:col-span-2 lg:col-span-1">
            <label className={labelClass} htmlFor="h-not">{t("form.note")}</label>
            <input id="h-not" type="text" maxLength={200} className={inputClass} value={not}
              placeholder={t("form.notePlaceholder")} onChange={(e) => setNot(e.target.value)} />
          </div>
          <div className="flex items-end">
            <button type="submit" className={`${primaryBtn} w-full`} disabled={saving}>
              {saving ? t("form.saving") : t("form.submit")}
            </button>
          </div>
        </form>

        {formMsg && (
          <p role="status" className={`mt-4 text-sm ${formMsg.tip === "ok" ? "text-success-600 dark:text-success-500" : "text-error-600 dark:text-error-500"}`}>
            {formMsg.metin}
          </p>
        )}
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("totals.title")}</h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("totals.note")}</p>
          </div>
          <div className="w-full sm:w-48">
            <label className={labelClass} htmlFor="h-gun">{t("window.label")}</label>
            <select id="h-gun" className={inputClass} value={gun}
              onChange={(e) => { setLoading(true); setGun(Number(e.target.value)); }}>
              {WINDOWS.map((w) => (
                <option key={w} value={w}>{t("window.days", { count: w })}</option>
              ))}
            </select>
          </div>
        </div>

        {loading ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : loadError ? (
          <div className="py-6 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{t("loadError")}</p>
            <p className="mb-3 text-xs text-gray-500 dark:text-gray-400">{loadError}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
              {t("retry")}
            </button>
          </div>
        ) : toplamlar.length === 0 ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("totals.empty")}</p>
        ) : (
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {toplamlar.map((k) => (
              <div key={`${k.kanal}-${k.para_birimi}`} className="rounded-xl border border-gray-100 p-4 dark:border-gray-800">
                <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                  {CHANNELS.includes(k.kanal as Channel) ? t(`channels.${k.kanal as Channel}`) : k.kanal}
                </p>
                <p className="mt-1 text-lg font-semibold text-gray-800 dark:text-white/90">
                  {paraFormat(k.toplam, k.para_birimi)}
                </p>
              </div>
            ))}
          </div>
        )}
        <p className="mt-4 text-theme-xs text-gray-500 dark:text-gray-400">{t("totals.cacNote")}</p>
      </section>

      <CacKarti gun={gun} reloadKey={reloadKey} />

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">{t("table.title")}</h2>
        {loading ? null : satirlar.length === 0 ? (
          <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("table.empty")}</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <caption className="sr-only">{t("table.title")}</caption>
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th scope="col" className={thClass}>{t("table.cols.date")}</th>
                  <th scope="col" className={thClass}>{t("table.cols.channel")}</th>
                  <th scope="col" className={thClass}>{t("table.cols.amount")}</th>
                  <th scope="col" className={thClass}>{t("table.cols.note")}</th>
                  <th scope="col" className={thClass}><span className="sr-only">{t("table.cols.action")}</span></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {satirlar.map((s) => (
                  <tr key={s.id}>
                    <td className={`${tdClass} whitespace-nowrap`}>{s.tarih}</td>
                    <td className={tdClass}>
                      {CHANNELS.includes(s.kanal as Channel) ? t(`channels.${s.kanal as Channel}`) : s.kanal}
                    </td>
                    <td className={`${tdClass} whitespace-nowrap`}>{paraFormat(s.tutar, s.para_birimi)}</td>
                    <td className={`${tdClass} max-w-xs wrap-break-word`}>{s.not ?? "-"}</td>
                    <td className={tdClass}>
                      <button type="button" className={dangerBtn} disabled={busyId === s.id} onClick={() => sil(s.id)}>
                        {t("table.delete")}
                      </button>
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
