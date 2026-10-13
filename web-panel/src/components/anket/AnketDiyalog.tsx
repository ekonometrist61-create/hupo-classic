"use client";

import { useEffect, useId, useMemo, useRef, useState } from "react";
import type { KeyboardEvent } from "react";
import { useTranslations } from "next-intl";
import { createClient } from "@/utils/supabase/client";
import {
  METIN_MAKS,
  soruGorunurMu,
  yanitlariHazirla,
  type Anket,
  type Cevap,
  type Cevaplar,
  type Soru,
  type Yuzey,
} from "./anketMantik";

interface AnketDiyalogProps {
  anket: Anket;
  yuzey: Yuzey;
  onBitti: (durum: "tesekkur" | "zaten") => void;
}

// Anketin kendisi: sorular, gönderim ve teşekkür görünümü. Modal (Modal bileşeni) içinde
// yalnızca açıkken bağlanır; odak, bağlandığı anda bu diyaloğa geçer. Kapatma (Escape,
// X düğmesi) Modal tarafından yönetilir.
export default function AnketDiyalog({
  anket,
  yuzey,
  onBitti,
}: AnketDiyalogProps) {
  const t = useTranslations("anket");
  const idTaban = useId();
  const baslikId = `${idTaban}-baslik`;
  const ipucuId = `${idTaban}-ipucu`;
  const diyalogRef = useRef<HTMLDivElement>(null);

  const [cevaplar, setCevaplar] = useState<Cevaplar>({});
  const [gonderiliyor, setGonderiliyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [tamam, setTamam] = useState(false);

  // Mount'ta ve teşekkür görünümüne geçişte odağı diyaloğa ver (klavye kullanıcısı için).
  useEffect(() => {
    diyalogRef.current?.focus();
  }, [tamam]);

  const gonderilecek = useMemo(
    () => yanitlariHazirla(anket.sorular, cevaplar),
    [anket.sorular, cevaplar]
  );
  const gonderilebilir = Object.keys(gonderilecek).length > 0 && !gonderiliyor;

  function degistir(soruId: string, deger: Cevap | undefined) {
    setCevaplar((onceki) => {
      const sonraki = { ...onceki };
      if (deger === undefined) delete sonraki[soruId];
      else sonraki[soruId] = deger;
      return sonraki;
    });
  }

  async function gonder() {
    if (!gonderilebilir) return;
    setGonderiliyor(true);
    setHata(null);
    const { error } = await createClient().rpc("anket_yanit_gonder", {
      p_anket_id: anket.id,
      p_yanitlar: gonderilecek,
      p_yuzey: yuzey,
    });
    setGonderiliyor(false);

    if (!error) {
      setTamam(true);
      return;
    }
    // Aynı ankete yakın zamanda katılınmış: kullanıcıyı rahatsız etmeden kapat.
    if (error.code === "23505") {
      onBitti("zaten");
      return;
    }
    setHata(error.code === "22023" ? t("hataGecersiz") : t("hata"));
  }

  // Odak tuzağı: Tab/Shift+Tab yalnızca diyalog içindeki öğeler arasında döner.
  function tuzakla(e: KeyboardEvent<HTMLDivElement>) {
    if (e.key !== "Tab" || !diyalogRef.current) return;
    const odaklanabilir = Array.from(
      diyalogRef.current.querySelectorAll<HTMLElement>(
        'button:not([disabled]), input:not([disabled]), textarea:not([disabled]), select:not([disabled]), [tabindex="0"]'
      )
    );
    if (odaklanabilir.length === 0) return;
    const ilk = odaklanabilir[0];
    const son = odaklanabilir[odaklanabilir.length - 1];
    if (e.shiftKey && document.activeElement === ilk) {
      e.preventDefault();
      son.focus();
    } else if (!e.shiftKey && document.activeElement === son) {
      e.preventDefault();
      ilk.focus();
    }
  }

  if (tamam) {
    return (
      <div
        ref={diyalogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={baslikId}
        tabIndex={-1}
        onKeyDown={tuzakla}
        className="max-h-[85vh] overflow-y-auto p-6 pe-12 outline-none sm:p-8"
      >
        <h2 id={baslikId} className="text-lg font-bold text-gray-900 dark:text-white">
          {t("tesekkurBaslik")}
        </h2>
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
          {t("tesekkurMetni")}
        </p>
        <button
          type="button"
          onClick={() => onBitti("tesekkur")}
          className="mt-6 inline-flex min-h-11 items-center justify-center rounded-xl bg-brand-500 px-5 text-sm font-semibold text-white transition-colors hover:bg-brand-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-900"
        >
          {t("kapat")}
        </button>
      </div>
    );
  }

  return (
    <div
      ref={diyalogRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby={baslikId}
      tabIndex={-1}
      onKeyDown={tuzakla}
      className="max-h-[85vh] overflow-y-auto p-6 pe-12 outline-none sm:p-8"
    >
      <form
        noValidate
        onSubmit={(e) => {
          e.preventDefault();
          void gonder();
        }}
      >
        <h2 id={baslikId} className="text-lg font-bold text-gray-900 dark:text-white">
          {anket.ad}
        </h2>
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
          {anket.anonim ? t("anonimNot") : t("kimlikliNot")}
        </p>

        <div className="mt-6 space-y-6">
          {anket.sorular.map((soru) =>
            soruGorunurMu(soru, anket.sorular, cevaplar) ? (
              <SoruAlani
                key={soru.id}
                soru={soru}
                idTaban={idTaban}
                deger={cevaplar[soru.id]}
                onDegis={degistir}
              />
            ) : null
          )}
        </div>

        {hata && (
          <p role="alert" className="mt-4 text-sm text-error-500 dark:text-error-400">
            {hata}
          </p>
        )}

        <div className="mt-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <p id={ipucuId} className="text-xs text-gray-500 dark:text-gray-400">
            {t("ipucu")}
          </p>
          <button
            type="submit"
            disabled={!gonderilebilir}
            aria-describedby={ipucuId}
            className="inline-flex min-h-11 shrink-0 items-center justify-center rounded-xl bg-brand-500 px-5 text-sm font-semibold text-white transition-colors hover:bg-brand-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 dark:focus-visible:ring-offset-gray-900"
          >
            {gonderiliyor ? t("gonderiliyor") : t("gonder")}
          </button>
        </div>
      </form>
    </div>
  );
}

interface SoruAlaniProps {
  soru: Soru;
  idTaban: string;
  deger: Cevap | undefined;
  onDegis: (soruId: string, deger: Cevap | undefined) => void;
}

const ETIKET_SINIFI =
  "text-sm font-semibold text-gray-900 dark:text-white/90";

function SoruAlani({ soru, idTaban, deger, onDegis }: SoruAlaniProps) {
  const t = useTranslations("anket");
  const alanId = `${idTaban}-${soru.id}`;

  if (soru.tur === "nps" || soru.tur === "csat") {
    const nps = soru.tur === "nps";
    const secenekler = nps
      ? Array.from({ length: 11 }, (_, i) => i)
      : [1, 2, 3, 4, 5];
    return (
      <fieldset className="min-w-0">
        <legend className={ETIKET_SINIFI}>{soru.baslik}</legend>
        <div
          className={`mt-3 grid gap-2 ${
            nps ? "grid-cols-6 sm:grid-cols-11" : "grid-cols-5"
          }`}
        >
          {secenekler.map((n) => (
            <label key={n} className="relative cursor-pointer">
              <input
                type="radio"
                name={alanId}
                value={n}
                checked={deger === n}
                onChange={() => onDegis(soru.id, n)}
                className="peer sr-only"
              />
              <span className="flex h-11 w-full items-center justify-center rounded-xl border border-gray-300 bg-white text-sm font-semibold text-gray-700 transition-colors peer-hover:border-brand-400 peer-checked:border-brand-500 peer-checked:bg-brand-500 peer-checked:text-white peer-focus-visible:ring-2 peer-focus-visible:ring-brand-500 peer-focus-visible:ring-offset-2 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:peer-checked:border-brand-500 dark:peer-checked:bg-brand-500 dark:peer-checked:text-white dark:peer-focus-visible:ring-offset-gray-900">
                {n}
              </span>
            </label>
          ))}
        </div>
        <div className="mt-2 flex justify-between gap-3 text-xs text-gray-500 dark:text-gray-400">
          <span>{nps ? t("npsAlt") : t("csatAlt")}</span>
          <span className="text-end">{nps ? t("npsUst") : t("csatUst")}</span>
        </div>
      </fieldset>
    );
  }

  if (soru.tur === "tek_secim") {
    return (
      <fieldset className="min-w-0">
        <legend className={ETIKET_SINIFI}>{soru.baslik}</legend>
        <div className="mt-3 flex flex-col gap-2">
          {(soru.secenekler ?? []).map((secenek) => (
            <label
              key={secenek}
              className="flex min-h-11 cursor-pointer items-center gap-3 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm text-gray-800 transition-colors hover:border-brand-300 has-checked:border-brand-500 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:hover:border-brand-400"
            >
              <input
                type="radio"
                name={alanId}
                value={secenek}
                checked={deger === secenek}
                onChange={() => onDegis(soru.id, secenek)}
                className="size-4 accent-brand-500"
              />
              <span>{secenek}</span>
            </label>
          ))}
        </div>
      </fieldset>
    );
  }

  if (soru.tur === "onay") {
    return (
      <fieldset className="min-w-0">
        <legend className={ETIKET_SINIFI}>{soru.baslik}</legend>
        <label className="mt-3 flex min-h-11 cursor-pointer items-center gap-3 text-sm text-gray-800 dark:text-gray-200">
          <input
            type="checkbox"
            checked={deger === true}
            onChange={(e) => onDegis(soru.id, e.target.checked ? true : undefined)}
            className="size-5 accent-brand-500"
          />
          <span>{t("evet")}</span>
        </label>
      </fieldset>
    );
  }

  const metin = typeof deger === "string" ? deger : "";
  const alanSinifi =
    "mt-2 w-full rounded-xl border border-gray-300 bg-white px-3 py-2.5 text-sm text-gray-900 placeholder:text-gray-400 focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/30 dark:border-gray-700 dark:bg-gray-800 dark:text-white dark:placeholder:text-gray-500";

  return (
    <div>
      <label htmlFor={alanId} className={`block ${ETIKET_SINIFI}`}>
        {soru.baslik}
      </label>
      {soru.tur === "uzun_metin" ? (
        <textarea
          id={alanId}
          value={metin}
          maxLength={METIN_MAKS}
          rows={4}
          onChange={(e) => onDegis(soru.id, e.target.value)}
          className={alanSinifi}
        />
      ) : (
        <input
          id={alanId}
          type="text"
          value={metin}
          maxLength={METIN_MAKS}
          onChange={(e) => onDegis(soru.id, e.target.value)}
          className={alanSinifi}
        />
      )}
    </div>
  );
}
