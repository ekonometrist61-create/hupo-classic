"use client";

import { turEtiketi } from "@/lib/okuma/turler";
import { useTranslations } from "next-intl";
import { useId, useState } from "react";
import { HIKAYE_DEMOLARI, type SecenekHarf } from "./hikayeDemoVeri";

const SINIFLAR = [3, 4, 5, 6, 7] as const;
const VARSAYILAN_AD = "Ela";

// Yalnızca bu sayfanın belleğinde tutulur; hiçbir yere gönderilmez ve kaydedilmez.
function metinDoldur(metin: string, ad: string, yol: string): string {
  return metin.split("{ad}").join(ad).split("{yol}").join(yol);
}

export default function HikayeDemo({ baslangicSinif }: { baslangicSinif: number }) {
  const t = useTranslations("hikayeDemo");
  const id = useId();
  const [sinif, setSinif] = useState<number>(baslangicSinif);
  const [ad, setAd] = useState("");
  const [yol, setYol] = useState("");
  const [secim, setSecim] = useState<SecenekHarf | null>(null);

  const demo = HIKAYE_DEMOLARI.find((d) => d.sinif === sinif) ?? HIKAYE_DEMOLARI[0];
  const adGoster = ad.trim() || VARSAYILAN_AD;
  const yolGoster = demo.sabitYol ?? (yol.trim() || demo.varsayilanYol || "Deniz");
  const yerTutucuVar = /\{(ad|yol)\}/.test(`${demo.parca} ${demo.deyim.cumle}`);
  const dogruMu = secim !== null && secim === demo.soru.dogru;

  function sinifSec(n: number) {
    setSinif(n);
    setSecim(null);
  }

  return (
    <div className="flex flex-col gap-8">
      <div role="group" aria-label={t("sinifEtiket")} className="flex flex-wrap gap-2">
        {SINIFLAR.map((n) => (
          <button
            key={n}
            type="button"
            aria-pressed={sinif === n}
            onClick={() => sinifSec(n)}
            className={`inline-flex h-12 min-w-12 items-center justify-center rounded-xl border-2 px-4 text-lg font-extrabold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none ${
              sinif === n
                ? "border-brand-600 bg-brand-600 text-white"
                : "border-navy/15 bg-white text-navy hover:border-brand-500 hover:text-brand-600 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100"
            }`}
          >
            {n}
          </button>
        ))}
      </div>

      <article className="rounded-3xl border border-cream-dark bg-white p-6 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
        <div className="flex flex-wrap items-center gap-3 text-sm font-bold text-navy-muted dark:text-gray-300">
          <span className="rounded-full bg-cream-dark px-3 py-1 dark:bg-gray-700">{turEtiketi(demo.tur)}</span>
          <span>
            {t("anaDeger")}: {demo.anaDeger}
          </span>
        </div>
        <h2 className="mt-4 text-2xl font-extrabold tracking-tight">{demo.baslik}</h2>

        {yerTutucuVar ? (
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <div>
              <label htmlFor={`${id}-ad`} className="block text-sm font-bold text-navy dark:text-gray-200">
                {t("ad")} <span className="font-normal text-navy-muted dark:text-gray-400">({t("istege")})</span>
              </label>
              <input
                id={`${id}-ad`}
                type="text"
                value={ad}
                maxLength={20}
                autoComplete="off"
                placeholder={VARSAYILAN_AD}
                onChange={(e) => setAd(e.target.value)}
                className="mt-1 h-12 w-full rounded-xl border-2 border-cream-dark bg-white px-4 font-semibold dark:border-gray-600 dark:bg-gray-900"
              />
            </div>
            {demo.sabitYol ? (
              <p className="self-end text-sm text-navy-muted dark:text-gray-400">{t("yolSabit", { ad: demo.sabitYol })}</p>
            ) : demo.parca.includes("{yol}") || demo.deyim.cumle.includes("{yol}") ? (
              <div>
                <label htmlFor={`${id}-yol`} className="block text-sm font-bold text-navy dark:text-gray-200">
                  {t("yol")} <span className="font-normal text-navy-muted dark:text-gray-400">({t("istege")})</span>
                </label>
                <input
                  id={`${id}-yol`}
                  type="text"
                  value={yol}
                  maxLength={20}
                  autoComplete="off"
                  placeholder={demo.varsayilanYol ?? "Deniz"}
                  onChange={(e) => setYol(e.target.value)}
                  className="mt-1 h-12 w-full rounded-xl border-2 border-cream-dark bg-white px-4 font-semibold dark:border-gray-600 dark:bg-gray-900"
                />
              </div>
            ) : null}
          </div>
        ) : (
          <p className="mt-4 text-sm text-navy-muted dark:text-gray-400">{t("adYok")}</p>
        )}

        <p className="mt-6 text-lg leading-relaxed">{metinDoldur(demo.parca, adGoster, yolGoster)}</p>
        <p className="mt-2 text-sm text-navy-muted dark:text-gray-400">{t("parcaNot")}</p>

        <div className="mt-6 rounded-2xl bg-gold-100 p-4 dark:bg-gray-900">
          <p className="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-gray-200">{t("deyim")}</p>
          <p className="mt-1 text-lg font-extrabold">{demo.deyim.ifade}</p>
          <p className="mt-1 text-sm text-navy-muted dark:text-gray-300">{demo.deyim.anlam}</p>
          <p className="mt-2 text-sm italic text-navy-muted dark:text-gray-300">
            {metinDoldur(demo.deyim.cumle, adGoster, yolGoster)}
          </p>
        </div>

        <fieldset className="mt-8">
          <legend className="text-lg font-extrabold">{t("soru")}</legend>
          <p className="mt-2 font-semibold leading-relaxed">{metinDoldur(demo.soru.metin, adGoster, yolGoster)}</p>
          <ul className="mt-4 grid gap-3">
            {demo.soru.secenekler.map((s) => (
              <li key={s.harf}>
                <button
                  type="button"
                  aria-pressed={secim === s.harf}
                  onClick={() => setSecim(s.harf)}
                  className={`flex min-h-12 w-full items-center gap-3 rounded-xl border-2 px-4 py-2 text-left font-semibold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 ${
                    secim === s.harf
                      ? "border-brand-600 bg-brand-50 dark:bg-brand-900/40"
                      : "border-cream-dark hover:border-brand-500 dark:border-gray-600"
                  }`}
                >
                  <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-cream-dark text-sm font-extrabold dark:bg-gray-700">
                    {s.harf}
                  </span>
                  {s.metin}
                </button>
              </li>
            ))}
          </ul>
          {secim !== null ? (
            <p role="status" className="mt-4 rounded-xl bg-cream p-4 font-semibold dark:bg-gray-900">
              {dogruMu ? `${t("dogru")} ${demo.soru.aciklama}` : demo.soru.yanlis}
            </p>
          ) : null}
        </fieldset>
      </article>

      <p className="text-sm leading-relaxed text-navy-muted dark:text-gray-400">{t("gizlilik")}</p>
    </div>
  );
}
