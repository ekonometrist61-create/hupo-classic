"use client";

import { IconArrowRight, IconCheck, IconChevronDown } from "@/components/landing/Icons";
import { useEffect, useState } from "react";

import { BECERI_ETIKET, DEMO_HIKAYE, type DemoSoru } from "./okumaDemoHikaye";

// Kayıtsız demo: cevaplar yalnız bu sayfanın belleğinde tutulur; sunucuya gitmez, saklanmaz.
type Cevaplar = Partial<Record<string, string>>;

function kaydirmaModu(): ScrollBehavior {
  if (typeof window === "undefined") return "auto";
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth";
}

function okumaAlaninaKaydir() {
  document.getElementById("okuma-alani")?.scrollIntoView({ behavior: kaydirmaModu(), block: "start" });
}

export function OkumaDemo() {
  const sayfalar = DEMO_HIKAYE.sayfalar;
  const sonSayfa = sayfalar.length - 1;
  const [sayfa, setSayfa] = useState(0);
  const [sorularAcik, setSorularAcik] = useState(false);
  const [cevaplar, setCevaplar] = useState<Cevaplar>({});

  useEffect(() => {
    if (!sorularAcik) return;
    document.getElementById("sorular")?.scrollIntoView({ behavior: kaydirmaModu(), block: "start" });
  }, [sorularAcik]);

  function sayfayaGit(yeni: number) {
    setSayfa(yeni);
    okumaAlaninaKaydir();
  }

  function cevapSec(soruId: string, secenekId: string) {
    setCevaplar((onceki) => ({ ...onceki, [soruId]: secenekId }));
  }

  function cevabiSifirla(soruId: string) {
    setCevaplar((onceki) => ({ ...onceki, [soruId]: undefined }));
  }

  return (
    <div className="space-y-12">
      <section
        id="okuma-alani"
        aria-label="Hikâye metni"
        className="scroll-mt-6 rounded-2xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800"
      >
        <div className="flex items-center justify-between gap-3">
          <p className="text-sm font-extrabold text-brand-600 dark:text-brand-300">
            Sayfa {sayfa + 1} / {sayfalar.length}
          </p>
          <p className="text-sm font-bold text-navy-muted dark:text-gray-300">{DEMO_HIKAYE.tur} · {DEMO_HIKAYE.sinif}. sınıf</p>
        </div>

        <div
          role="progressbar"
          aria-label="Okuma ilerlemesi"
          aria-valuemin={1}
          aria-valuemax={sayfalar.length}
          aria-valuenow={sayfa + 1}
          aria-valuetext={`${sayfalar.length} sayfadan ${sayfa + 1}. sayfa`}
          className="mt-3 h-2 overflow-hidden rounded-full bg-cream-dark dark:bg-gray-700"
        >
          <div
            className="h-full rounded-full bg-brand-500 transition-[width] duration-300 motion-reduce:transition-none"
            style={{ width: `${((sayfa + 1) / sayfalar.length) * 100}%` }}
          />
        </div>

        <p className="mt-6 wrap-break-word text-xl leading-relaxed sm:text-2xl sm:leading-relaxed">{sayfalar[sayfa]}</p>

        <div className="mt-8 flex flex-col-reverse gap-3 sm:flex-row sm:items-center sm:justify-between">
          <button
            type="button"
            onClick={() => sayfayaGit(sayfa - 1)}
            disabled={sayfa === 0}
            className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl border-2 border-cream-dark px-5 text-base font-bold text-navy transition-colors hover:border-brand-300 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-600 dark:text-gray-100 motion-reduce:transition-none"
          >
            <IconChevronDown className="h-5 w-5 rotate-90" />
            Önceki sayfa
          </button>

          {sayfa < sonSayfa ? (
            <button
              type="button"
              onClick={() => sayfayaGit(sayfa + 1)}
              className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
            >
              Sonraki sayfa
              <IconArrowRight className="h-5 w-5" />
            </button>
          ) : (
            <button
              type="button"
              onClick={() => setSorularAcik(true)}
              disabled={sorularAcik}
              className="inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 text-base font-extrabold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-60 motion-reduce:transition-none"
            >
              {sorularAcik ? "Sorular aşağıda" : "Soruları çöz"}
              <IconArrowRight className="h-5 w-5" />
            </button>
          )}
        </div>
      </section>

      {sorularAcik && (
        <section id="sorular" aria-labelledby="sorular-baslik" className="scroll-mt-6 space-y-6">
          <div>
            <h2 id="sorular-baslik" className="text-2xl font-extrabold tracking-tight">
              Anlama soruları
            </h2>
            <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">
              Bir şık seçtiğinde doğru cevap ve kısa açıklama görünür. Bu demoda cevaplar kaydedilmez.
            </p>
          </div>

          {DEMO_HIKAYE.sorular.map((soru, i) => (
            <SoruKarti
              key={soru.id}
              soru={soru}
              numara={i + 1}
              cevap={cevaplar[soru.id]}
              onSec={(secenekId) => cevapSec(soru.id, secenekId)}
              onSifirla={() => cevabiSifirla(soru.id)}
              onDayanak={() => sayfayaGit(soru.dayanakSayfa - 1)}
            />
          ))}
        </section>
      )}
    </div>
  );
}

function SoruKarti({
  soru,
  numara,
  cevap,
  onSec,
  onSifirla,
  onDayanak,
}: {
  soru: DemoSoru;
  numara: number;
  cevap: string | undefined;
  onSec: (secenekId: string) => void;
  onSifirla: () => void;
  onDayanak: () => void;
}) {
  const cevaplandi = cevap !== undefined;
  const dogruMu = cevap === soru.dogru;
  const dogruSecenek = soru.secenekler.find((s) => s.id === soru.dogru);

  return (
    <fieldset className="min-w-0 rounded-2xl border border-cream-dark bg-white p-5 sm:p-6 dark:border-gray-700 dark:bg-gray-800">
      <legend className="px-1 text-lg font-extrabold leading-snug">
        <span className="text-navy-muted dark:text-gray-400">{numara}.</span> {soru.metin}
      </legend>

      <div className="mt-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-sm">
        <span className="rounded-full bg-cream px-2.5 py-0.5 font-bold text-navy-muted dark:bg-gray-700 dark:text-gray-200">
          {BECERI_ETIKET[soru.beceri]}
        </span>
        <button
          type="button"
          onClick={onDayanak}
          className="inline-flex min-h-11 items-center font-bold text-brand-600 underline underline-offset-4 hover:text-brand-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-brand-300"
        >
          {soru.dayanakSayfa}. sayfaya dön
        </button>
      </div>

      <div className="mt-4 grid gap-3">
        {soru.secenekler.map((secenek) => (
          <label key={secenek.id} className="relative block cursor-pointer">
            <input
              type="radio"
              name={soru.id}
              value={secenek.id}
              checked={cevap === secenek.id}
              disabled={cevaplandi}
              onChange={() => onSec(secenek.id)}
              className="peer sr-only"
            />
            <span className="flex min-h-12 items-center gap-3 rounded-xl border-2 border-cream-dark px-4 py-3 text-base font-semibold transition-colors peer-checked:border-brand-500 peer-checked:bg-brand-50 peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-brand-500 dark:border-gray-600 dark:peer-checked:bg-gray-700 motion-reduce:transition-none">
              <span
                aria-hidden="true"
                className="grid h-7 w-7 shrink-0 place-items-center rounded-full border-2 border-navy-muted text-xs font-extrabold text-navy-muted dark:border-gray-400 dark:text-gray-300"
              >
                {secenek.id}
              </span>
              <span className="min-w-0 wrap-break-word">{secenek.metin}</span>
            </span>
          </label>
        ))}
      </div>

      <div role="status" aria-live="polite" className="mt-4 empty:hidden">
        {cevaplandi && dogruMu && (
          <div className="rounded-xl border border-brand-200 bg-brand-50 p-4 text-navy dark:border-brand-700 dark:bg-gray-900 dark:text-gray-100">
            <p className="flex items-center gap-2 font-extrabold">
              <IconCheck className="h-5 w-5 shrink-0 text-brand-600 dark:text-brand-300" />
              Doğru.
            </p>
            <p className="mt-1 leading-relaxed">{soru.aciklama}</p>
          </div>
        )}
        {cevaplandi && !dogruMu && (
          <div className="rounded-xl border border-gold-300 bg-gold-50 p-4 text-navy dark:border-gold-700 dark:bg-gray-900 dark:text-gray-100">
            <p className="font-extrabold">
              Bu kez olmadı. Doğru cevap: {dogruSecenek?.id}) {dogruSecenek?.metin}
            </p>
            <p className="mt-1 leading-relaxed">{soru.aciklama}</p>
            <p className="mt-2 text-sm text-navy-muted dark:text-gray-300">
              İstersen metnin {soru.dayanakSayfa}. sayfasına bakıp yeniden düşünebilirsin.
            </p>
          </div>
        )}
      </div>

      {cevaplandi && (
        <button
          type="button"
          onClick={onSifirla}
          className="mt-3 inline-flex min-h-11 items-center font-bold text-brand-600 underline underline-offset-4 hover:text-brand-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-brand-300"
        >
          Başka şık dene
        </button>
      )}
    </fieldset>
  );
}
