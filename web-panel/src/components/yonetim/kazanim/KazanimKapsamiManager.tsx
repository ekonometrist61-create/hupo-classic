"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import { toCsv } from "../sorular/csv";
import { cardClass, tdClass, thClass } from "../panel/styles";
import { dokunmaHedefi, masaustuTablo, mobilKart } from "../ui/responsive";
import { fetchDersler } from "./kazanimVeri";

/** admin_kazanim_kapsam() satır şekli. */
interface KapsamSatir {
  kazanim_kodu: string;
  kazanim_metni: string | null;
  ilk_hafta: number;
  unite_tema: string | null;
  onayli_soru: number;
  bekleyen_soru: number;
  sinav1_ort: number | null;
  sinav2_ort: number | null;
}

interface Yuklenen<T> {
  key: string;
  data: T;
  error: string | null;
}

const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8] as const;
const fieldClass =
  "h-11 w-full rounded-lg border border-gray-300 bg-transparent px-3 text-base text-gray-800 shadow-theme-xs focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden disabled:cursor-not-allowed disabled:opacity-60 md:text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:focus:border-brand-800";
const outlineButton = `${dokunmaHedefi} justify-center rounded-lg border border-gray-300 px-4 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`;

function downloadCsv(filename: string, content: string) {
  const blob = new Blob([content], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

function sayi(value: number | null): string {
  return value === null ? "—" : value.toLocaleString("tr-TR", { maximumFractionDigits: 1 });
}

/** Ders + sınıfa göre kazanım kapsamı: hafta sırasıyla kazanım, onaylı/bekleyen soru sayısı. */
export default function KazanimKapsamiManager() {
  const t = useTranslations("yonetim.sorular.kazanim.kapsam");

  const [sinif, setSinif] = useState<number | null>(null);
  const [ders, setDers] = useState("");
  const [dersler, setDersler] = useState<Yuklenen<string[]> | null>(null);
  const [kapsam, setKapsam] = useState<Yuklenen<KapsamSatir[]> | null>(null);
  const [reloadCounter, setReloadCounter] = useState(0);

  const sinifKey = sinif !== null ? String(sinif) : "";
  const kapsamKey = sinif !== null && ders ? `${sinif}|${ders}|${reloadCounter}` : "";

  useEffect(() => {
    if (sinif === null) return;
    let iptal = false;
    const key = String(sinif);
    fetchDersler(sinif).then(
      (data) => {
        if (!iptal) setDersler({ key, data, error: null });
      },
      (e: Error) => {
        if (!iptal) setDersler({ key, data: [], error: e.message });
      },
    );
    return () => {
      iptal = true;
    };
  }, [sinif]);

  useEffect(() => {
    if (sinif === null || !ders) return;
    let iptal = false;
    const key = `${sinif}|${ders}|${reloadCounter}`;
    createClient()
      .rpc("admin_kazanim_kapsam", { p_ders: ders, p_sinif: sinif })
      .then(({ data, error }) => {
        if (iptal) return;
        if (error) {
          setKapsam({ key, data: [], error: error.message });
          return;
        }
        const satirlar = (data ?? []) as KapsamSatir[];
        const sirali = [...satirlar].sort(
          (a, b) =>
            a.ilk_hafta - b.ilk_hafta ||
            a.kazanim_kodu.localeCompare(b.kazanim_kodu, "tr"),
        );
        setKapsam({ key, data: sirali, error: null });
      });
    return () => {
      iptal = true;
    };
  }, [sinif, ders, reloadCounter]);

  const dersYukleniyor = sinif !== null && dersler?.key !== sinifKey;
  const dersListesi = dersler?.key === sinifKey ? dersler.data : [];
  const dersHata = dersler?.key === sinifKey ? dersler.error : null;

  const yukleniyor = kapsamKey !== "" && kapsam?.key !== kapsamKey;
  const hata = kapsamKey !== "" && kapsam?.key === kapsamKey ? kapsam.error : null;
  const satirlar = useMemo(
    () => (kapsamKey !== "" && kapsam?.key === kapsamKey ? kapsam.data : []),
    [kapsam, kapsamKey],
  );

  const bosSayisi = satirlar.filter((s) => s.onayli_soru === 0).length;
  // Sınav ortalaması yalnız 5–8. sınıflarda ve değer varsa gösterilir.
  const sinavGoster =
    sinif !== null &&
    sinif >= 5 &&
    satirlar.some((s) => s.sinav1_ort !== null || s.sinav2_ort !== null);
  const hazir = !yukleniyor && !hata && satirlar.length > 0;

  const secSinif = (value: string) => {
    setSinif(value ? Number(value) : null);
    setDers("");
  };

  const indirCsv = () => {
    if (sinif === null) return;
    const baslik = [
      t("columns.hafta"),
      t("columns.kod"),
      t("columns.kazanim"),
      t("columns.unite"),
      t("columns.onayli"),
      t("columns.bekleyen"),
      ...(sinavGoster ? [t("columns.sinav1"), t("columns.sinav2")] : []),
    ];
    const satirVerisi = satirlar.map((s) => [
      String(s.ilk_hafta),
      s.kazanim_kodu,
      s.kazanim_metni ?? "",
      s.unite_tema ?? "",
      String(s.onayli_soru),
      String(s.bekleyen_soru),
      ...(sinavGoster
        ? [s.sinav1_ort === null ? "" : String(s.sinav1_ort), s.sinav2_ort === null ? "" : String(s.sinav2_ort)]
        : []),
    ]);
    const dosyaAdi = `kazanim-kapsami-${sinif}-sinif-${ders.toLocaleLowerCase("tr-TR").replace(/\s+/g, "-")}.csv`;
    downloadCsv(dosyaAdi, toCsv([baslik, ...satirVerisi]));
  };

  return (
    <div className={`${cardClass} p-4 sm:p-6`}>
      <div className="mb-5 grid gap-3 sm:grid-cols-3">
        <div>
          <label htmlFor="kk-sinif" className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400">
            {t("filters.sinif")}
          </label>
          <select
            id="kk-sinif"
            className={fieldClass}
            value={sinifKey}
            onChange={(e) => secSinif(e.target.value)}
          >
            <option value="">{t("filters.selectSinif")}</option>
            {SINIFLAR.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>
        <div className="sm:col-span-2">
          <label htmlFor="kk-ders" className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400">
            {t("filters.ders")}
          </label>
          <select
            id="kk-ders"
            className={fieldClass}
            value={ders}
            disabled={sinif === null || dersYukleniyor}
            onChange={(e) => setDers(e.target.value)}
          >
            <option value="">
              {dersYukleniyor ? t("filters.loadingDers") : t("filters.selectDers")}
            </option>
            {dersListesi.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
          {dersHata && (
            <p role="alert" className="mt-1 text-theme-xs text-error-600 dark:text-error-400">
              {t("loadError")}: {dersHata}
            </p>
          )}
        </div>
      </div>

      {sinif === null ? (
        <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">{t("pickSinif")}</p>
      ) : !ders ? (
        <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">{t("pickDers")}</p>
      ) : yukleniyor ? (
        <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : hata ? (
        <div className="py-8 text-center">
          <p role="alert" className="mb-3 text-sm text-error-600 dark:text-error-400">
            {t("loadError")}: {hata}
          </p>
          <button type="button" onClick={() => setReloadCounter((c) => c + 1)} className={outlineButton}>
            {t("retry")}
          </button>
        </div>
      ) : satirlar.length === 0 ? (
        <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
      ) : (
        <>
          <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
            <p role="status" className="text-sm font-medium text-gray-800 dark:text-white/90">
              {bosSayisi > 0
                ? t("summary", { toplam: satirlar.length, bos: bosSayisi })
                : t("summaryAllCovered", { toplam: satirlar.length })}
            </p>
            <button type="button" disabled={!hazir} onClick={indirCsv} className={outlineButton}>
              {t("csv")}
            </button>
          </div>

          <div className={mobilKart}>
            <ul className="space-y-3">
              {satirlar.map((s) => {
                const bos = s.onayli_soru === 0;
                return (
                  <li
                    key={s.kazanim_kodu}
                    className={`rounded-xl border p-4 ${
                      bos
                        ? "border-error-200 bg-error-50 dark:border-error-500/30 dark:bg-error-500/10"
                        : "border-gray-200 dark:border-gray-800"
                    }`}
                  >
                    <div className="flex flex-wrap items-center gap-2 text-theme-xs text-gray-500 dark:text-gray-400">
                      <span className="font-semibold text-gray-700 dark:text-gray-300">
                        {t("week", { hafta: s.ilk_hafta })}
                      </span>
                      <span className="font-mono">{s.kazanim_kodu}</span>
                    </div>
                    <p className="mt-1 text-theme-sm wrap-break-word text-gray-800 dark:text-white/90">
                      {s.kazanim_metni ?? "—"}
                    </p>
                    {s.unite_tema && (
                      <p className="mt-1 text-theme-xs wrap-break-word text-gray-500 dark:text-gray-400">
                        {s.unite_tema}
                      </p>
                    )}
                    <dl className="mt-3 grid grid-cols-2 gap-2 text-theme-xs">
                      <div>
                        <dt className="text-gray-500 dark:text-gray-400">{t("columns.onayli")}</dt>
                        <dd className={bos ? "font-semibold text-error-700 dark:text-error-400" : "font-medium text-gray-800 dark:text-white/90"}>
                          {s.onayli_soru}
                        </dd>
                      </div>
                      <div>
                        <dt className="text-gray-500 dark:text-gray-400">{t("columns.bekleyen")}</dt>
                        <dd className="font-medium text-gray-800 dark:text-white/90">{s.bekleyen_soru}</dd>
                      </div>
                      {sinavGoster && (
                        <>
                          <div>
                            <dt className="text-gray-500 dark:text-gray-400">{t("columns.sinav1")}</dt>
                            <dd className="font-medium text-gray-800 dark:text-white/90">{sayi(s.sinav1_ort)}</dd>
                          </div>
                          <div>
                            <dt className="text-gray-500 dark:text-gray-400">{t("columns.sinav2")}</dt>
                            <dd className="font-medium text-gray-800 dark:text-white/90">{sayi(s.sinav2_ort)}</dd>
                          </div>
                        </>
                      )}
                    </dl>
                  </li>
                );
              })}
            </ul>
          </div>

          <div className={masaustuTablo}>
            <table className="w-full min-w-160 text-start">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th scope="col" className={thClass}>{t("columns.hafta")}</th>
                  <th scope="col" className={thClass}>{t("columns.kod")}</th>
                  <th scope="col" className={thClass}>{t("columns.kazanim")}</th>
                  <th scope="col" className={thClass}>{t("columns.unite")}</th>
                  <th scope="col" className={thClass}>{t("columns.onayli")}</th>
                  <th scope="col" className={thClass}>{t("columns.bekleyen")}</th>
                  {sinavGoster && <th scope="col" className={thClass}>{t("columns.sinav1")}</th>}
                  {sinavGoster && <th scope="col" className={thClass}>{t("columns.sinav2")}</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {satirlar.map((s) => {
                  const bos = s.onayli_soru === 0;
                  return (
                    <tr
                      key={s.kazanim_kodu}
                      className={bos ? "bg-error-50 dark:bg-error-500/10" : ""}
                    >
                      <td className={tdClass}>{s.ilk_hafta}</td>
                      <td className={`${tdClass} font-mono text-theme-xs`}>{s.kazanim_kodu}</td>
                      <td className={`${tdClass} max-w-md`}>
                        <span className="line-clamp-2" title={s.kazanim_metni ?? ""}>
                          {s.kazanim_metni ?? "—"}
                        </span>
                      </td>
                      <td className={tdClass}>{s.unite_tema ?? "—"}</td>
                      <td className={bos ? `${tdClass} font-semibold text-error-700 dark:text-error-400` : tdClass}>
                        {s.onayli_soru}
                        {bos && <span className="ms-2 text-theme-xs font-medium">{t("noApproved")}</span>}
                      </td>
                      <td className={tdClass}>{s.bekleyen_soru}</td>
                      {sinavGoster && <td className={tdClass}>{sayi(s.sinav1_ort)}</td>}
                      {sinavGoster && <td className={tdClass}>{sayi(s.sinav2_ort)}</td>}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
