"use client";

import { useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import { dokunmaHedefi } from "../ui/responsive";
import { fetchDersler, fetchKazanimlar, type KazanimSecenek } from "./kazanimVeri";

// Mobilde 16 px (iOS odak yakınlaştırması); masaüstünde 14 px.
const fieldClass =
  "h-11 w-full rounded-lg border border-gray-300 bg-transparent px-3 text-base text-gray-800 shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden disabled:cursor-not-allowed disabled:opacity-60 md:text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30 dark:focus:border-brand-800";

const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8] as const;
const GORUNEN_LIMIT = 100;

interface KazanimSeciciProps {
  baslangicSinif?: number | null;
  baslangicDers?: string;
  /** Seçili kazanım kodu (yoksa null). */
  secili: string | null;
  onSec: (kod: string) => void;
  disabled?: boolean;
}

interface Yuklenen<T> {
  key: string;
  data: T;
  error: string | null;
}

/**
 * Ders + sınıfa göre müfredat kazanımı arayan ve seçen bileşen.
 * Veriyi yalnız müfredat tablosundan (mufredat_hafta) okur; kazanım kodu uydurmaz.
 */
export default function KazanimSecici({
  baslangicSinif = null,
  baslangicDers = "",
  secili,
  onSec,
  disabled = false,
}: KazanimSeciciProps) {
  const t = useTranslations("yonetim.sorular.kazanim.picker");

  const [sinif, setSinif] = useState<number | null>(baslangicSinif);
  const [ders, setDers] = useState(baslangicDers);
  const [arama, setArama] = useState("");
  const [dersler, setDersler] = useState<Yuklenen<string[]> | null>(null);
  const [kazanimlar, setKazanimlar] = useState<Yuklenen<KazanimSecenek[]> | null>(null);

  const sinifKey = sinif !== null ? String(sinif) : "";
  const listeKey = sinif !== null && ders ? `${sinif}|${ders}` : "";

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
    const key = `${sinif}|${ders}`;
    fetchKazanimlar(ders, sinif).then(
      (data) => {
        if (!iptal) setKazanimlar({ key, data, error: null });
      },
      (e: Error) => {
        if (!iptal) setKazanimlar({ key, data: [], error: e.message });
      },
    );
    return () => {
      iptal = true;
    };
  }, [sinif, ders]);

  const dersYukleniyor = sinif !== null && dersler?.key !== sinifKey;
  const dersListesi = dersler?.key === sinifKey ? dersler.data : [];
  const dersHata = dersler?.key === sinifKey ? dersler.error : null;

  const kazanimYukleniyor = listeKey !== "" && kazanimlar?.key !== listeKey;
  const tumKazanimlar = useMemo(
    () => (kazanimlar?.key === listeKey ? kazanimlar.data : []),
    [kazanimlar, listeKey],
  );
  const kazanimHata = kazanimlar?.key === listeKey ? kazanimlar.error : null;

  const eslesen = useMemo(() => {
    const q = arama.trim().toLocaleLowerCase("tr-TR");
    if (!q) return tumKazanimlar;
    return tumKazanimlar.filter(
      (k) =>
        k.kod.toLocaleLowerCase("tr-TR").includes(q) ||
        k.metin.toLocaleLowerCase("tr-TR").includes(q),
    );
  }, [arama, tumKazanimlar]);
  const gorunen = eslesen.slice(0, GORUNEN_LIMIT);
  const eslesenSayisi = eslesen.length;

  const secSinif = (value: string) => {
    setSinif(value ? Number(value) : null);
    setDers("");
    setArama("");
  };

  const secDers = (value: string) => {
    setDers(value);
    setArama("");
  };

  return (
    <div className="space-y-3">
      <div className="grid gap-3 sm:grid-cols-3">
        <div>
          <label htmlFor="ks-sinif" className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400">
            {t("sinif")}
          </label>
          <select
            id="ks-sinif"
            className={fieldClass}
            value={sinifKey}
            disabled={disabled}
            onChange={(e) => secSinif(e.target.value)}
          >
            <option value="">{t("selectSinif")}</option>
            {SINIFLAR.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>
        <div className="sm:col-span-2">
          <label htmlFor="ks-ders" className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400">
            {t("ders")}
          </label>
          <select
            id="ks-ders"
            className={fieldClass}
            value={ders}
            disabled={disabled || sinif === null || dersYukleniyor}
            onChange={(e) => secDers(e.target.value)}
          >
            <option value="">{dersYukleniyor ? t("loadingDers") : t("selectDers")}</option>
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

      <div>
        <label htmlFor="ks-arama" className="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400">
          {t("search")}
        </label>
        <input
          id="ks-arama"
          type="search"
          className={fieldClass}
          value={arama}
          disabled={disabled || !ders}
          placeholder={t("searchPlaceholder")}
          onChange={(e) => setArama(e.target.value)}
        />
      </div>

      {sinif === null ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("pickSinif")}</p>
      ) : !ders ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("pickDers")}</p>
      ) : kazanimYukleniyor ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : kazanimHata ? (
        <div className="py-4 text-center">
          <p role="alert" className="text-sm text-error-600 dark:text-error-400">
            {t("loadError")}: {kazanimHata}
          </p>
        </div>
      ) : tumKazanimlar.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
      ) : gorunen.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("noMatch")}</p>
      ) : (
        <>
          <ul
            aria-label={t("listLabel")}
            className="max-h-72 space-y-2 overflow-y-auto pe-1"
          >
            {gorunen.map((k) => {
              const aktif = secili === k.kod;
              return (
                <li key={k.kod}>
                  <button
                    type="button"
                    disabled={disabled}
                    aria-pressed={aktif}
                    onClick={() => onSec(k.kod)}
                    className={`${dokunmaHedefi} w-full flex-col items-start gap-1 rounded-lg border px-3 py-2 text-start text-theme-sm transition disabled:opacity-60 ${
                      aktif
                        ? "border-brand-400 bg-brand-25 dark:border-brand-500 dark:bg-brand-500/10"
                        : "border-gray-200 hover:bg-gray-50 dark:border-gray-800 dark:hover:bg-white/5"
                    }`}
                  >
                    <span className="flex w-full flex-wrap items-center gap-x-2 gap-y-1">
                      <span className="font-mono text-theme-xs font-semibold text-gray-800 dark:text-white/90">
                        {k.kod}
                      </span>
                      <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                        {t("week", { hafta: k.ilkHafta })}
                      </span>
                    </span>
                    <span className="line-clamp-2 wrap-break-word text-gray-700 dark:text-gray-300">
                      {k.metin || "—"}
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">
            {eslesenSayisi > GORUNEN_LIMIT
              ? t("moreResults", { gosterilen: GORUNEN_LIMIT, toplam: eslesenSayisi })
              : t("count", { toplam: eslesenSayisi })}
          </p>
        </>
      )}

      {secili && (
        <p role="status" className="text-theme-sm font-medium text-gray-800 dark:text-white/90">
          {t("selected", { kod: secili })}
        </p>
      )}
    </div>
  );
}
