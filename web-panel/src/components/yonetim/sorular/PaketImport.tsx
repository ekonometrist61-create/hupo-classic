"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useState } from "react";

import DesktopOnly from "@/components/ui/DesktopOnly";
import { dokunmaHedefi } from "../ui/responsive";

// Soru Atölyesi JSON paketi (sema/soru-paketi, sürüm 1 ve 2) içe aktarma. Sunucu tarafı doğrulama RPC'dedir;
// burada yalnızca dosyanın okunabilir bir paket olup olmadığı ve önizleme kontrol edilir.
// Bu ekran yalnızca yöneticiye açıktır: doğru şık ve görsel önizlemede gösterilir.
// gorsel_spec (cevap ipucu) istemcide gösterilmez.

const cardClass =
  "mb-6 rounded-2xl border border-gray-200 bg-white p-4 sm:p-6 dark:border-gray-800 dark:bg-white/3";
const headingClass =
  "mb-3 text-base font-semibold text-gray-800 dark:text-white/90";
const outlineButton =
  `${dokunmaHedefi} justify-center rounded-lg border border-gray-300 px-4 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`;
const primaryButton =
  `${dokunmaHedefi} justify-center rounded-lg bg-brand-500 px-4 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-50`;

const ONIZLEME_SAYISI = 50;

type PaketGorsel = { svg?: string; alt_metin?: string; tip_id?: string };

type PaketSoru = {
  soru_id?: string;
  soru_metni?: string;
  siklar?: unknown;
  dogru_sik?: string;
  gorsel_gerekli?: boolean;
  gorsel?: PaketGorsel | null;
};

type Paket = { surum?: string; parti?: { parti_id?: string }; sorular?: PaketSoru[] };

type Sonuc = {
  parti_id: string;
  eklenen: number;
  gorselli: number;
  tekrar: number;
  hatali: number;
  hatalar: { satir: number; soru_id: string | null; hata: string }[];
};

// Şıkları anahtara göre sıralı döndürür; beklenmeyen biçimde (dizi, sayı vb.) boş liste verir.
function siklListesi(siklar: unknown): [string, string][] {
  if (!siklar || typeof siklar !== "object" || Array.isArray(siklar)) return [];
  return Object.entries(siklar as Record<string, unknown>)
    .map(([anahtar, deger]): [string, string] => [anahtar, String(deger ?? "")])
    .sort(([a], [b]) => a.localeCompare(b));
}

function gorselSvgVar(soru: PaketSoru): boolean {
  return typeof soru.gorsel?.svg === "string" && soru.gorsel.svg.trim().length > 0;
}

export default function PaketImport() {
  const t = useTranslations("yonetim.sorular.paket");
  const [paket, setPaket] = useState<Paket | null>(null);
  const [dosyaAdi, setDosyaAdi] = useState<string | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [onayla, setOnayla] = useState(false);
  const [hepsi, setHepsi] = useState(false);
  const [calisiyor, setCalisiyor] = useState(false);
  const [sonuc, setSonuc] = useState<Sonuc | null>(null);
  const [geriAlId, setGeriAlId] = useState("");
  const [geriAlMesaj, setGeriAlMesaj] = useState<string | null>(null);

  const onFile = async (file: File | undefined) => {
    setSonuc(null);
    setHata(null);
    setPaket(null);
    setDosyaAdi(file?.name ?? null);
    if (!file) return;
    try {
      const veri = JSON.parse(await file.text()) as Paket;
      if (
        !veri ||
        (veri.surum !== "1" && veri.surum !== "2") ||
        !Array.isArray(veri.sorular) ||
        !veri.parti?.parti_id
      ) {
        setHata(t("invalidFile"));
        return;
      }
      setPaket(veri);
    } catch {
      setHata(t("invalidFile"));
    }
  };

  const ice = async () => {
    if (!paket) return;
    setCalisiyor(true);
    setHata(null);
    const supabase = createClient();
    const { data, error } = await supabase.rpc("admin_import_questions_v3", {
      p_paket: paket,
      p_onayla: onayla,
      p_hepsi_veya_hicbiri: hepsi,
    });
    setCalisiyor(false);
    if (error) {
      setHata(t("error", { hata: error.message }));
      return;
    }
    setSonuc(data as Sonuc);
  };

  const geriAl = async () => {
    const id = geriAlId.trim();
    if (!id) return;
    setGeriAlMesaj(null);
    const supabase = createClient();
    const { data, error } = await supabase.rpc("admin_geri_al_parti", { p_parti_id: id });
    if (error) {
      setGeriAlMesaj(t("error", { hata: error.message }));
      return;
    }
    setGeriAlMesaj(t("undoDone", { adet: (data as { geri_alinan: number }).geri_alinan }));
  };

  const sorular = paket?.sorular ?? [];
  const gorselliSayisi = sorular.filter((soru) => soru.gorsel != null).length;

  return (
    <DesktopOnly>
      <div className={cardClass}>
        <h3 className={headingClass}>{t("title")}</h3>
        <p className="mb-4 text-theme-sm text-gray-600 dark:text-gray-400">{t("help")}</p>

        <div className="mb-4 flex flex-wrap items-center gap-3">
          <input
            type="file"
            accept=".json,application/json"
            disabled={calisiyor}
            onChange={(e) => onFile(e.target.files?.[0])}
            className="block text-base text-gray-700 md:text-sm file:me-3 file:min-h-11 file:rounded-lg file:border-0 file:bg-gray-100 file:px-4 file:py-2.5 file:text-sm file:font-medium file:text-gray-700 hover:file:bg-gray-200 dark:text-gray-300 dark:file:bg-white/10 dark:file:text-gray-300"
            aria-label={t("pick")}
          />
          {dosyaAdi && <span className="text-sm text-gray-500 dark:text-gray-400">{dosyaAdi}</span>}
        </div>

        {paket && (
          <div className="mb-4 space-y-3">
            <p className="text-sm text-gray-700 dark:text-gray-300">
              {t("preview", { parti: paket.parti?.parti_id ?? "", adet: sorular.length })}
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              {t("previewCounts", { toplam: sorular.length, gorselli: gorselliSayisi })}
            </p>

            <div className="rounded-lg border border-gray-200 p-3 dark:border-gray-800">
              <h4 className="mb-1 text-sm font-semibold text-gray-800 dark:text-white/90">{t("previewTitle")}</h4>
              <p className="mb-3 text-xs text-gray-500 dark:text-gray-400">
                {t("previewShowing", { adet: Math.min(sorular.length, ONIZLEME_SAYISI) })}
              </p>
              <ol className="space-y-3">
                {sorular.slice(0, ONIZLEME_SAYISI).map((soru, i) => {
                  const siklar = siklListesi(soru.siklar);
                  const dogruSik = soru.dogru_sik?.toUpperCase() ?? "";
                  const gorselVar = gorselSvgVar(soru);
                  return (
                    <li
                      key={`${soru.soru_id ?? "soru"}-${i}`}
                      className="rounded-lg border border-gray-100 p-3 text-sm text-gray-700 dark:border-gray-800 dark:text-gray-300"
                    >
                      <p className="mb-1 text-xs font-medium text-gray-500 dark:text-gray-400">
                        {t("previewNumber", { no: i + 1 })}
                        {soru.soru_id ? ` · ${soru.soru_id}` : ""}
                      </p>
                      <p className="mb-2 font-medium text-gray-800 dark:text-white/90">
                        {soru.soru_metni?.trim() ? soru.soru_metni : t("noText")}
                      </p>
                      {siklar.length > 0 && (
                        <ul className="mb-2 space-y-1">
                          {siklar.map(([anahtar, metin]) => {
                            const dogru = anahtar.toUpperCase() === dogruSik;
                            return (
                              <li
                                key={anahtar}
                                className={dogru ? "font-semibold text-brand-600 dark:text-brand-400" : ""}
                              >
                                {anahtar}) {metin}
                                {dogru && <span className="ms-2 text-xs">({t("correct")})</span>}
                              </li>
                            );
                          })}
                        </ul>
                      )}
                      {soru.gorsel && (
                        <div className="mb-2">
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            {t("tip", { tip: soru.gorsel.tip_id ?? "—" })}
                          </p>
                          {gorselVar && (
                            // eslint-disable-next-line @next/next/no-img-element -- yönetim önizlemesi; SVG istemci tarafında data URL olarak gösterilir
                            <img
                              src={`data:image/svg+xml;charset=utf-8,${encodeURIComponent(soru.gorsel.svg ?? "")}`}
                              alt={soru.gorsel.alt_metin?.trim() ? soru.gorsel.alt_metin : t("gorselAltYok")}
                              className="mt-1 h-40 w-40 rounded-lg border border-gray-200 bg-white object-contain dark:border-gray-700"
                            />
                          )}
                        </div>
                      )}
                      {soru.gorsel_gerekli && !gorselVar && (
                        <p className="text-xs font-medium text-amber-700 dark:text-amber-400">{t("gorselEksik")}</p>
                      )}
                    </li>
                  );
                })}
              </ol>
            </div>

            <label className="flex items-start gap-2 text-sm text-gray-700 dark:text-gray-300">
              <input type="checkbox" checked={onayla} onChange={(e) => setOnayla(e.target.checked)} className="mt-0.5 h-4 w-4" />
              {t("approve")}
            </label>
            <label className="flex items-start gap-2 text-sm text-gray-700 dark:text-gray-300">
              <input type="checkbox" checked={hepsi} onChange={(e) => setHepsi(e.target.checked)} className="mt-0.5 h-4 w-4" />
              {t("allOrNothing")}
            </label>
            <button type="button" className={primaryButton} disabled={calisiyor} onClick={ice}>
              {calisiyor ? t("busy") : t("start")}
            </button>
          </div>
        )}

        {hata && <p role="alert" className="mb-4 text-sm text-red-600 dark:text-red-400">{hata}</p>}

        {sonuc && (
          <div className="mb-6 space-y-2 text-sm text-gray-700 dark:text-gray-300">
            <p className="font-medium">
              {t("summary", {
                eklenen: sonuc.eklenen,
                gorselli: sonuc.gorselli ?? 0,
                tekrar: sonuc.tekrar,
                hatali: sonuc.hatali,
              })}
            </p>
            <p className="text-gray-500 dark:text-gray-400">{t("partiId", { parti: sonuc.parti_id })}</p>
            {sonuc.hatalar.length > 0 && (
              <div>
                <p className="font-medium">{t("rejected")}</p>
                <ul className="list-disc space-y-1 ps-5">
                  {sonuc.hatalar.slice(0, 50).map((h) => (
                    <li key={`${h.satir}-${h.soru_id ?? ""}`}>
                      {t("rowError", { satir: h.satir, soru: h.soru_id ?? "—", hata: h.hata })}
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        )}

        <div className="border-t border-gray-200 pt-4 dark:border-gray-800">
          <h4 className="mb-2 text-sm font-semibold text-gray-800 dark:text-white/90">{t("undoTitle")}</h4>
          <div className="flex flex-wrap items-center gap-2">
            <input
              value={geriAlId}
              onChange={(e) => setGeriAlId(e.target.value)}
              placeholder={t("undoPlaceholder")}
              aria-label={t("undoPlaceholder")}
              className="min-h-11 min-w-0 flex-1 rounded-lg border border-gray-300 bg-white px-3 text-base md:text-sm dark:border-gray-700 dark:bg-gray-900"
            />
            <button type="button" className={outlineButton} onClick={geriAl} disabled={!geriAlId.trim()}>
              {t("undo")}
            </button>
          </div>
          {geriAlMesaj && <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">{geriAlMesaj}</p>}
          <p className="mt-2 text-xs text-gray-500 dark:text-gray-400">{t("undoNote")}</p>
        </div>
      </div>
    </DesktopOnly>
  );
}
