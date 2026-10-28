"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

type OzetSatir = { gun: number; uygun_hane: number | null; tutulan: number | null; oran: number | string | null };
type CacSatir = { para_birimi: string; harcama: number | string; cac: number | string | null; durum: string };
type Icerik = {
  kohort?: { ozet?: OzetSatir[] };
  cac?: { yeni_hane?: number | null; satirlar?: CacSatir[] };
  veri_kalitesi?: { veli_toplam?: number | null; kalite?: { kod: string; sayi: number | null }[] };
};
type Rapor = {
  id: string;
  donem: string;
  durum: "taslak" | "onaylandi" | "reddedildi";
  olusturma: string;
  karar_zamani: string | null;
  karar_notu: string | null;
  icerik: Icerik;
};

// Taslaklar yalnız bu ekranda karara bağlanır. Hiçbir gönderim yapılmaz.
export default function RaporTaslakManager() {
  const t = useTranslations("yonetim.raporTaslak");
  const [liste, setListe] = useState<Rapor[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [mesaj, setMesaj] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [notlar, setNotlar] = useState<Record<string, string>>({});
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc("admin_rapor_listele", { p_limit: 20 });
      if (cancelled) return;
      if (error) {
        setHata(error.message);
        setListe(null);
      } else {
        setHata(null);
        setListe(data as Rapor[]);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const uret = async () => {
    setBusy(true);
    setMesaj(null);
    const { error } = await createClient().rpc("admin_rapor_taslak_olustur");
    setBusy(false);
    if (error) {
      setHata(error.message);
      return;
    }
    setMesaj(t("produced"));
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const karar = async (id: string, k: "onayla" | "reddet") => {
    if (k === "onayla" && !window.confirm(t("confirmApprove"))) return;
    setBusy(true);
    setMesaj(null);
    const { error } = await createClient().rpc("admin_rapor_karar", {
      p_id: id,
      p_karar: k,
      p_not: (notlar[id] ?? "").trim() || null,
    });
    setBusy(false);
    if (error) {
      setHata(error.message);
      return;
    }
    setMesaj(k === "onayla" ? t("approved") : t("rejected"));
    setLoading(true);
    setReloadKey((r) => r + 1);
  };

  const oran = (v: number | string | null | undefined) =>
    v === null || v === undefined ? t("hidden") : `${Number(v).toLocaleString("tr-TR", { maximumFractionDigits: 1 })}%`;

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("title")}</h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("description")}</p>
          </div>
          <button type="button" className={primaryBtn} disabled={busy} onClick={uret}>
            {t("produce")}
          </button>
        </div>
        {mesaj && <p role="status" className="mt-4 text-sm text-success-600 dark:text-success-500">{mesaj}</p>}
        {hata && <p role="alert" className="mt-4 text-sm text-error-600 dark:text-error-500">{hata}</p>}
      </section>

      {loading ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : !liste || liste.length === 0 ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
      ) : (
        liste.map((r) => {
          const ozet = r.icerik.kohort?.ozet ?? [];
          const cacSatirlari = r.icerik.cac?.satirlar ?? [];
          const kalite = r.icerik.veri_kalitesi?.kalite ?? [];
          return (
            <section key={r.id} className={`${cardClass} p-5 sm:p-6`}>
              <div className="mb-4 flex flex-wrap items-center gap-3">
                <h3 className="text-base font-semibold text-gray-800 dark:text-white/90">{r.donem}</h3>
                <span className="rounded-full bg-gray-100 px-2.5 py-0.5 text-theme-xs font-medium text-gray-700 dark:bg-gray-800 dark:text-gray-300">
                  {t(`status.${r.durum}`)}
                </span>
                <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                  {t("createdAt")}: {new Date(r.olusturma).toLocaleString("tr-TR")}
                </span>
              </div>

              <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                <div>
                  <p className="mb-2 text-theme-xs font-semibold text-gray-500 uppercase dark:text-gray-400">{t("sections.retention")}</p>
                  <ul className="space-y-1 text-sm text-gray-700 dark:text-gray-300">
                    {ozet.map((o) => (
                      <li key={o.gun}>D{o.gun}: {oran(o.oran)}</li>
                    ))}
                  </ul>
                </div>
                <div>
                  <p className="mb-2 text-theme-xs font-semibold text-gray-500 uppercase dark:text-gray-400">{t("sections.cac")}</p>
                  {cacSatirlari.length === 0 ? (
                    <p className="text-sm text-gray-500 dark:text-gray-400">{t("noSpend")}</p>
                  ) : (
                    <ul className="space-y-1 text-sm text-gray-700 dark:text-gray-300">
                      {cacSatirlari.map((s) => (
                        <li key={s.para_birimi}>
                          {s.para_birimi}: {s.cac === null ? t("hidden") : Number(s.cac).toLocaleString("tr-TR", { maximumFractionDigits: 2 })}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
                <div>
                  <p className="mb-2 text-theme-xs font-semibold text-gray-500 uppercase dark:text-gray-400">{t("sections.quality")}</p>
                  <ul className="space-y-1 text-sm text-gray-700 dark:text-gray-300">
                    {kalite.map((k) => (
                      <li key={k.kod}>{t(`quality.${k.kod}`)}: {k.sayi === null ? t("hidden") : k.sayi}</li>
                    ))}
                  </ul>
                </div>
              </div>

              {r.durum === "taslak" ? (
                <div className="mt-5 flex flex-col gap-3 sm:flex-row sm:items-end">
                  <div className="w-full sm:flex-1">
                    <label className={labelClass} htmlFor={`not-${r.id}`}>{t("noteLabel")}</label>
                    <input
                      id={`not-${r.id}`}
                      type="text"
                      maxLength={300}
                      className={inputClass}
                      value={notlar[r.id] ?? ""}
                      onChange={(e) => setNotlar((n) => ({ ...n, [r.id]: e.target.value }))}
                    />
                  </div>
                  <button type="button" className={primaryBtn} disabled={busy} onClick={() => karar(r.id, "onayla")}>
                    {t("approve")}
                  </button>
                  <button type="button" className={outlineBtn} disabled={busy} onClick={() => karar(r.id, "reddet")}>
                    {t("reject")}
                  </button>
                </div>
              ) : (
                <p className="mt-4 text-theme-xs text-gray-500 dark:text-gray-400">
                  {r.karar_zamani && `${t("decidedAt")}: ${new Date(r.karar_zamani).toLocaleString("tr-TR")}`}
                  {r.karar_notu && ` · ${t("noteLabel")}: ${r.karar_notu}`}
                </p>
              )}
            </section>
          );
        })
      )}
    </div>
  );
}
