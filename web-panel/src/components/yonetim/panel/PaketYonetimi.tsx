"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";

// admin_paket_matris() ve admin_modul_etki_onizleme() dönüş şekli (20261132 P3).
type Modul = { kod: string; ad: string; durum: string; sira: number };
type Paket = {
  kod: string;
  ad: string;
  tur: string;
  cocuk_siniri: number;
  rapor_kapsami: string;
  durum: string;
  surum: number;
  aktif_abone: number;
};
type Hucre = { paket: string; modul: string; erisim: string; gunluk_kota: number | null };
type Karar = { modul: string; paket: string; karar: string; gunluk_kota: number | null };
type Matris = { moduller: Modul[]; paketler: Paket[]; hucreler: Hucre[]; kararlar: Karar[] };

type OnizlemePaket = {
  paket: string;
  ad: string;
  karar: string | null;
  erisim: string | null;
  gunluk_kota: number | null;
  mevcut_aboneleri_kapsar: boolean;
  aktif_abone: number;
  etkilenen_abone: number;
};
type Onizleme = {
  modul: string;
  modul_durum: string;
  yayinlanabilir: boolean;
  eksik_kararlar: string[];
  paketler: OnizlemePaket[];
};

type FormDurum = { karar: string; kota: string; kapsa: boolean; gerekce: string };

const KARARLAR = ["dahil", "sinirli", "haric", "yeni_paket"] as const;

export default function PaketYonetimi() {
  const t = useTranslations("yonetim.paketler");
  const [matris, setMatris] = useState<Matris | null>(null);
  const [secili, setSecili] = useState<string>("");
  const [onizleme, setOnizleme] = useState<Onizleme | null>(null);
  const [formlar, setFormlar] = useState<Record<string, FormDurum>>({});
  const [mesaj, setMesaj] = useState<{ tip: "ok" | "hata"; metin: string } | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [yeniKod, setYeniKod] = useState("");
  const [yeniAd, setYeniAd] = useState("");
  const [yeniAciklama, setYeniAciklama] = useState("");
  // Son istenen modül: geç dönen eski modül yanıtı yeni modülün formunu ezmesin.
  const sonIstek = useRef("");

  const matrisYukle = useCallback(async () => {
    const { data, error } = await createClient().rpc("admin_paket_matris");
    if (error) {
      setMesaj({ tip: "hata", metin: error.message });
      return;
    }
    const m = data as Matris;
    setMatris(m);
    setSecili((mevcut) => mevcut || m.moduller[0]?.kod || "");
  }, []);

  // yenilenecekPaket verilirse yalnız o paketin formu sunucudan alınır; diğer paketlerde kullanıcının
  // henüz kaydetmediği girdiler korunur (bir paket kaydedilince diğerlerinin seçimi silinmesin).
  const onizlemeYukle = useCallback(async (modul: string, yenilenecekPaket?: string) => {
    if (!modul) return;
    sonIstek.current = modul;
    const { data, error } = await createClient().rpc("admin_modul_etki_onizleme", { p_modul: modul });
    if (sonIstek.current !== modul) return;
    if (error) {
      setMesaj({ tip: "hata", metin: error.message });
      return;
    }
    const o = data as Onizleme;
    setOnizleme(o);
    // Form: mevcut kararları ön doldur
    setFormlar((onceki) => {
      const yeni: Record<string, FormDurum> = {};
      for (const p of o.paketler) {
        const sunucudan: FormDurum = {
          karar: p.karar ?? "",
          kota: p.gunluk_kota != null ? String(p.gunluk_kota) : "",
          kapsa: p.mevcut_aboneleri_kapsar,
          gerekce: "",
        };
        const koru = yenilenecekPaket !== undefined && p.paket !== yenilenecekPaket && onceki[p.paket];
        yeni[p.paket] = koru ? onceki[p.paket] : sunucudan;
      }
      return yeni;
    });
  }, []);

  useEffect(() => {
    void matrisYukle();
  }, [matrisYukle]);

  useEffect(() => {
    void onizlemeYukle(secili);
  }, [secili, onizlemeYukle]);

  const kararKaydet = async (paket: string) => {
    const f = formlar[paket];
    if (!f) return;
    if (!f.karar) {
      setMesaj({ tip: "hata", metin: t("hataKararSec") });
      return;
    }
    const kota = f.kota.trim() === "" ? null : Number(f.kota);
    if ((f.karar === "sinirli" || f.karar === "dahil") && kota !== null && (!Number.isInteger(kota) || kota < 0)) {
      setMesaj({ tip: "hata", metin: t("hataKota") });
      return;
    }
    if (f.karar === "sinirli" && kota === null) {
      setMesaj({ tip: "hata", metin: t("hataSinirliKota") });
      return;
    }
    setMesgul(true);
    const { error } = await createClient().rpc("admin_modul_karar_kaydet", {
      p_modul: secili,
      p_paket: paket,
      p_karar: f.karar,
      p_gunluk_kota: f.karar === "sinirli" || f.karar === "dahil" ? kota : null,
      p_mevcut_aboneleri: f.kapsa,
      p_gerekce: f.gerekce.trim() || null,
    });
    setMesgul(false);
    if (error) {
      setMesaj({ tip: "hata", metin: error.message });
      return;
    }
    setMesaj({ tip: "ok", metin: t("kararKaydedildi") });
    // Önizleme ve matris birlikte yenilenir (matris hücreleri kayıttan hemen sonra güncel görünsün).
    await Promise.all([onizlemeYukle(secili, paket), matrisYukle()]);
  };

  const yayinla = async () => {
    setMesgul(true);
    const { data, error } = await createClient().rpc("admin_modul_yayinla", { p_modul: secili });
    setMesgul(false);
    if (error) {
      setMesaj({ tip: "hata", metin: error.message });
      return;
    }
    const etk = (data as { etkilenen_paketler?: string[] })?.etkilenen_paketler ?? [];
    setMesaj({ tip: "ok", metin: t("yayinlandi", { sayi: etk.length }) });
    await matrisYukle();
    await onizlemeYukle(secili);
  };

  const modulOlustur = async () => {
    const kod = yeniKod.trim();
    const ad = yeniAd.trim();
    if (!kod || !ad) {
      setMesaj({ tip: "hata", metin: t("hataModulAlan") });
      return;
    }
    setMesgul(true);
    const { error } = await createClient().rpc("admin_modul_olustur", {
      p_kod: kod,
      p_ad: ad,
      p_aciklama: yeniAciklama.trim() || null,
    });
    setMesgul(false);
    if (error) {
      setMesaj({ tip: "hata", metin: error.message });
      return;
    }
    setMesaj({ tip: "ok", metin: t("modulOlusturuldu") });
    setYeniKod("");
    setYeniAd("");
    setYeniAciklama("");
    setOnizleme(null);
    setFormlar({});
    await matrisYukle();
    setSecili(kod);
  };

  const modulArsivle = async () => {
    if (!secili || !window.confirm(t("arsivOnay"))) return;
    setMesgul(true);
    const { error } = await createClient().rpc("admin_modul_arsivle", { p_kod: secili });
    setMesgul(false);
    if (error) {
      setMesaj({ tip: "hata", metin: error.message });
      return;
    }
    setMesaj({ tip: "ok", metin: t("arsivlendi") });
    await Promise.all([matrisYukle(), onizlemeYukle(secili)]);
  };

  const hucre = (paket: string, modul: string) =>
    matris?.hucreler.find((h) => h.paket === paket && h.modul === modul) ?? null;

  const erisimEtiketi = (h: Hucre | null) => {
    if (!h) return "—";
    if (h.erisim === "tam") return t("erisimTam");
    if (h.erisim === "sinirli") return t("erisimSinirli", { kota: h.gunluk_kota ?? 0 });
    return h.erisim;
  };

  if (!matris) {
    return <p className="text-sm text-gray-500">{mesaj?.metin ?? t("yukleniyor")}</p>;
  }

  const secilenModul = matris.moduller.find((m) => m.kod === secili);

  return (
    <div className="space-y-8">
      {mesaj && (
        <div
          role="status"
          className={
            mesaj.tip === "ok"
              ? "rounded-lg border border-green-200 bg-green-50 p-3 text-sm text-green-800"
              : "rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-800"
          }
        >
          {mesaj.metin}
        </div>
      )}

      {/* Matris */}
      <section>
        <h2 className="mb-3 text-base font-semibold text-gray-900 dark:text-white">{t("matrisBaslik")}</h2>
        <div className="overflow-x-auto rounded-xl border border-gray-200 dark:border-gray-800">
          <table className="min-w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-900">
              <tr>
                <th className="px-3 py-2 text-left font-medium">{t("modul")}</th>
                {matris.paketler.map((p) => (
                  <th key={p.kod} className="px-3 py-2 text-left font-medium">
                    {p.ad}
                    <div className="text-xs font-normal text-gray-500">
                      {t("surumEtiketi", { surum: p.surum })} · {t("aboneEtiketi", { sayi: p.aktif_abone })}
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {matris.moduller.map((m) => (
                <tr key={m.kod} className="border-t border-gray-100 dark:border-gray-800">
                  <td className="px-3 py-2 font-medium">
                    {m.ad}
                    {m.durum !== "yayinda" && (
                      <span className="ml-2 rounded bg-amber-100 px-1.5 text-xs text-amber-800">
                        {m.durum === "arsiv" ? t("arsivEtiketi") : t("taslak")}
                      </span>
                    )}
                  </td>
                  {matris.paketler.map((p) => (
                    <td key={p.kod} className="px-3 py-2 text-gray-700 dark:text-gray-300">
                      {erisimEtiketi(hucre(p.kod, m.kod))}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* Yeni modül (taslak) */}
      <section className="space-y-3">
        <h2 className="text-base font-semibold text-gray-900 dark:text-white">{t("yeniModulBaslik")}</h2>
        <div className="grid gap-3 sm:grid-cols-4">
          <label className="text-xs text-gray-600 dark:text-gray-400">
            {t("yeniModulKod")}
            <input
              type="text"
              maxLength={30}
              className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-2 py-1.5 text-sm dark:border-gray-700 dark:bg-gray-900"
              value={yeniKod}
              onChange={(e) => setYeniKod(e.target.value)}
            />
          </label>
          <label className="text-xs text-gray-600 dark:text-gray-400">
            {t("yeniModulAd")}
            <input
              type="text"
              maxLength={60}
              className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-2 py-1.5 text-sm dark:border-gray-700 dark:bg-gray-900"
              value={yeniAd}
              onChange={(e) => setYeniAd(e.target.value)}
            />
          </label>
          <label className="text-xs text-gray-600 dark:text-gray-400 sm:col-span-2">
            {t("yeniModulAciklama")}
            <input
              type="text"
              maxLength={200}
              className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-2 py-1.5 text-sm dark:border-gray-700 dark:bg-gray-900"
              value={yeniAciklama}
              onChange={(e) => setYeniAciklama(e.target.value)}
            />
          </label>
        </div>
        <button
          type="button"
          disabled={mesgul}
          onClick={() => void modulOlustur()}
          className="rounded-lg border border-gray-300 px-3 py-1.5 text-sm font-medium dark:border-gray-700 disabled:opacity-40"
        >
          {t("yeniModulOlustur")}
        </button>
      </section>

      {/* Modül seçimi, önizleme ve yayın */}
      <section className="space-y-4">
        <h2 className="text-base font-semibold text-gray-900 dark:text-white">{t("modulBaslik")}</h2>
        <div className="flex flex-wrap items-center gap-3">
          <select
            aria-label={t("modulSec")}
            className="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-900"
            value={secili}
            onChange={(e) => {
              // Yeni modül yüklenene kadar eski modülün formu görünmesin (yanlış kayıt riski).
              setOnizleme(null);
              setFormlar({});
              setSecili(e.target.value);
            }}
          >
            {matris.moduller.map((m) => (
              <option key={m.kod} value={m.kod}>
                {m.ad} ({m.durum})
              </option>
            ))}
          </select>
          <button
            type="button"
            disabled={mesgul || !onizleme || !onizleme.yayinlanabilir || secilenModul?.durum !== "taslak"}
            onClick={() => void yayinla()}
            className="rounded-lg bg-brand-600 px-4 py-2 text-sm font-medium text-white disabled:opacity-40"
          >
            {t("yayinla")}
          </button>
          <button
            type="button"
            disabled={mesgul || !secilenModul || secilenModul.durum === "arsiv"}
            onClick={() => void modulArsivle()}
            className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium dark:border-gray-700 disabled:opacity-40"
          >
            {t("arsivle")}
          </button>
        </div>

        {onizleme && !onizleme.yayinlanabilir && (
          <p className="text-sm text-amber-700 dark:text-amber-400">
            {t("eksikKararlar", { liste: onizleme.eksik_kararlar.join(", ") })}
          </p>
        )}

        {onizleme && (
          <div className="space-y-3">
            {onizleme.paketler.map((p) => {
              const f = formlar[p.paket];
              if (!f) return null;
              return (
                <div key={p.paket} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                  <div className="flex flex-wrap items-baseline justify-between gap-2">
                    <div className="font-medium">{p.ad}</div>
                    <div className="text-xs text-gray-500">
                      {t("aktifAbone", { sayi: p.aktif_abone })}
                      {f.kapsa && p.aktif_abone > 0 ? ` · ${t("etkilenecek", { sayi: p.aktif_abone })}` : ""}
                    </div>
                  </div>
                  <div className="mt-3 grid gap-3 sm:grid-cols-4">
                    <label className="text-xs text-gray-600 dark:text-gray-400">
                      {t("karar")}
                      <select
                        className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-2 py-1.5 text-sm dark:border-gray-700 dark:bg-gray-900"
                        value={f.karar}
                        onChange={(e) => setFormlar({ ...formlar, [p.paket]: { ...f, karar: e.target.value } })}
                      >
                        <option value="">{t("kararSec")}</option>
                        {KARARLAR.map((k) => (
                          <option key={k} value={k}>
                            {t(`kararSecenek.${k}`)}
                          </option>
                        ))}
                      </select>
                    </label>
                    <label className="text-xs text-gray-600 dark:text-gray-400">
                      {t("gunlukKota")}
                      <input
                        type="number"
                        min={0}
                        disabled={f.karar !== "sinirli" && f.karar !== "dahil"}
                        className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-2 py-1.5 text-sm disabled:opacity-40 dark:border-gray-700 dark:bg-gray-900"
                        value={f.kota}
                        onChange={(e) => setFormlar({ ...formlar, [p.paket]: { ...f, kota: e.target.value } })}
                      />
                    </label>
                    <label className="flex items-end gap-2 text-xs text-gray-600 dark:text-gray-400">
                      <input
                        type="checkbox"
                        checked={f.kapsa}
                        onChange={(e) => setFormlar({ ...formlar, [p.paket]: { ...f, kapsa: e.target.checked } })}
                      />
                      {t("mevcutAboneleri")}
                    </label>
                    <label className="text-xs text-gray-600 dark:text-gray-400">
                      {t("gerekce")}
                      <input
                        type="text"
                        maxLength={200}
                        className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-2 py-1.5 text-sm dark:border-gray-700 dark:bg-gray-900"
                        value={f.gerekce}
                        onChange={(e) => setFormlar({ ...formlar, [p.paket]: { ...f, gerekce: e.target.value } })}
                      />
                    </label>
                  </div>
                  <div className="mt-3">
                    <button
                      type="button"
                      disabled={mesgul || !f.karar}
                      onClick={() => void kararKaydet(p.paket)}
                      className="rounded-lg border border-gray-300 px-3 py-1.5 text-sm font-medium dark:border-gray-700 disabled:opacity-40"
                    >
                      {t("kaydet")}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </section>
    </div>
  );
}
