"use client";

import { IconArrowRight, IconCheck } from "@/components/landing/Icons";
import { trackLandingEvent } from "@/lib/analytics/events";
import { useTranslations } from "next-intl";
import Image from "next/image";
import Link from "next/link";
import { Fragment, useEffect, useReducer, useRef } from "react";

import DemoFigure from "./DemoFigure";
import {
  DEMO_SINIFLAR,
  getDemoQuestions,
  isDemoSinif,
  type DemoBeceri,
  type DemoQuestion,
  type DemoSinif,
} from "./demoQuestions";

type Phase = "secim" | "answering" | "checked" | "done";

interface State {
  sinif: DemoSinif | null;
  index: number;
  selected: number | null;
  phase: Phase;
  /** Soru sırasına göre ilk denemede doğru mu (yalnızca cevaplananlar). */
  sonuclar: boolean[];
}

type Action =
  | { type: "sinif"; sinif: DemoSinif }
  | { type: "select"; option: number }
  | { type: "check" }
  | { type: "next" }
  | { type: "restart" }
  | { type: "changeSinif" };

const INITIAL: State = { sinif: null, index: 0, selected: null, phase: "secim", sonuclar: [] };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "sinif":
      return { sinif: action.sinif, index: 0, selected: null, phase: "answering", sonuclar: [] };
    case "select":
      if (state.phase !== "answering") return state;
      return { ...state, selected: action.option };
    case "check": {
      // Çift tıklamada ikinci kez puan yazılmasın.
      if (state.phase !== "answering" || state.selected === null || state.sinif === null) return state;
      const soru = getDemoQuestions(state.sinif)[state.index];
      return { ...state, phase: "checked", sonuclar: [...state.sonuclar, soru.dogru === state.selected] };
    }
    case "next": {
      if (state.phase !== "checked" || state.sinif === null) return state;
      const total = getDemoQuestions(state.sinif).length;
      if (state.index >= total - 1) return { ...state, phase: "done" };
      return { ...state, index: state.index + 1, selected: null, phase: "answering" };
    }
    case "restart":
      if (state.sinif === null) return state;
      return { sinif: state.sinif, index: 0, selected: null, phase: "answering", sonuclar: [] };
    case "changeSinif":
      return INITIAL;
  }
}

function renderEmphasis(text: string) {
  return text.split("**").map((part, i) =>
    i % 2 === 1 ? (
      <strong
        key={i}
        className="font-extrabold underline decoration-gold-600 decoration-2 underline-offset-4"
      >
        {part}
      </strong>
    ) : (
      <Fragment key={i}>{part}</Fragment>
    )
  );
}

const plain = (text: string) => text.replaceAll("**", "");

const primaryBtn =
  "inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:bg-navy/20 disabled:text-navy-muted disabled:shadow-none motion-reduce:transition-none sm:w-auto dark:disabled:bg-gray-700 dark:disabled:text-gray-400";
const secondaryBtn =
  "inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl border-2 border-navy/15 bg-white px-6 py-3 text-base font-bold text-navy transition-colors hover:border-brand-500 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none sm:w-auto dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100";

interface BeceriGrubu {
  kod: DemoBeceri;
  dogru: number;
  toplam: number;
}

function beceriGruplari(sorular: DemoQuestion[], sonuclar: boolean[]): BeceriGrubu[] {
  const harita = new Map<DemoBeceri, BeceriGrubu>();
  sorular.forEach((s, i) => {
    const g = harita.get(s.beceri) ?? { kod: s.beceri, dogru: 0, toplam: 0 };
    g.toplam += 1;
    if (sonuclar[i]) g.dogru += 1;
    harita.set(s.beceri, g);
  });
  return [...harita.values()];
}

export default function DemoQuiz() {
  const t = useTranslations("demo");
  const g = useTranslations("gorseller");
  const [state, dispatch] = useReducer(reducer, INITIAL);
  const baslikRef = useRef<HTMLHeadingElement>(null);
  const sorular = state.sinif ? getDemoQuestions(state.sinif) : [];
  const total = sorular.length;
  const question = sorular[state.index];
  const checked = state.phase === "checked";
  const wasCorrect = checked && question !== undefined && state.selected === question.dogru;
  const score = state.sonuclar.filter(Boolean).length;

  // Bağlantıdan gelen sınıf (?sinif=5) varsa seçim ekranı atlanır.
  useEffect(() => {
    const raw = new URLSearchParams(window.location.search).get("sinif");
    const n = raw ? Number(raw) : NaN;
    if (isDemoSinif(n)) dispatch({ type: "sinif", sinif: n });
  }, []);

  // Sınıf seçilince, sonuç görününce ya da seçime dönülünce odak ilgili başlığa taşınır (ilk yüklemede değil).
  const ilkRender = useRef(true);
  useEffect(() => {
    if (ilkRender.current) {
      ilkRender.current = false;
      return;
    }
    if (state.phase === "secim" || state.phase === "done") {
      baslikRef.current?.focus();
    } else if (state.phase === "answering" && state.index === 0) {
      document.getElementById("demo-question")?.focus();
    }
  }, [state.phase, state.sinif, state.index]);

  // Demo bitince yalnızca sınıf ve toplam puan ölçülür; tek tek cevaplar gönderilmez.
  useEffect(() => {
    if (state.phase === "done" && state.sinif) {
      trackLandingEvent("demo_tamamlandi", { puan: score, toplam: total, sinif: state.sinif });
    }
  }, [state.phase, state.sinif, score, total]);

  if (state.phase === "secim") {
    return (
      <section aria-labelledby="demo-sinif-title" className="mx-auto max-w-2xl">
        <div className="rounded-3xl border border-cream-dark bg-white p-6 text-center shadow-sm sm:p-10 dark:border-gray-700 dark:bg-gray-800">
          <Image
            src={g("hupo.hosgeldin")}
            alt=""
            width={420}
            height={415}
            className="mx-auto h-28 w-auto"
          />
          <h2
            id="demo-sinif-title"
            ref={baslikRef}
            tabIndex={-1}
            className="mt-4 text-balance text-3xl font-extrabold outline-none"
          >
            {t("sinifBaslik")}
          </h2>
          <p className="mx-auto mt-3 max-w-lg text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            {t("sinifAciklama")}
          </p>
          <ul aria-label={t("sinifGrup")} className="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-5">
            {DEMO_SINIFLAR.map((n, i) => (
              <li key={n} className={i === DEMO_SINIFLAR.length - 1 ? "col-span-2 sm:col-span-1" : ""}>
                <button
                  type="button"
                  onClick={() => dispatch({ type: "sinif", sinif: n })}
                  className="flex min-h-20 w-full flex-col items-center justify-center rounded-2xl border-2 border-cream-dark bg-white px-3 py-3 text-navy transition-colors hover:border-brand-500 hover:bg-brand-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
                >
                  <span className="text-3xl font-extrabold leading-none">{n}</span>
                  <span className="mt-1 text-sm font-bold text-navy-muted dark:text-gray-300">
                    {t("sinifSoyadi")}
                  </span>
                </button>
              </li>
            ))}
          </ul>
          <p className="mt-6 text-sm text-navy-muted dark:text-gray-400">{t("sinifNot")}</p>
        </div>
        <p className="mt-4 text-center text-sm text-navy-muted dark:text-gray-400">{t("sourceNote")}</p>
      </section>
    );
  }

  if (state.phase === "done") {
    const gruplar = beceriGruplari(sorular, state.sonuclar);
    const tekrar = gruplar.filter((x) => x.dogru < x.toplam).slice(0, 2);
    return (
      <section
        aria-labelledby="demo-done-title"
        className="mx-auto max-w-2xl rounded-3xl border border-cream-dark bg-white p-6 shadow-sm sm:p-10 dark:border-gray-700 dark:bg-gray-800"
      >
        <div className="flex flex-col items-center text-center">
          <Image
            src={g("hupo.tamamlandi")}
            alt={t("poseAlt.done")}
            width={420}
            height={404}
            className="h-32 w-auto"
          />
          <h2
            id="demo-done-title"
            ref={baslikRef}
            tabIndex={-1}
            className="mt-4 text-balance text-3xl font-extrabold outline-none"
          >
            {t("doneTitle", { sinif: state.sinif ?? 0 })}
          </h2>
          <p className="mt-2 text-navy-muted dark:text-gray-300">{t("doneIntro")}</p>
        </div>

        <div className="mt-8 rounded-2xl bg-cream p-5 sm:p-6 dark:bg-gray-900">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <h3 className="text-xl font-extrabold">{t("ozet.baslik")}</h3>
            <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold uppercase tracking-wide text-warning-700">
              {t("ozet.rozet")}
            </span>
          </div>
          <p className="mt-3 text-lg font-bold">{t("ozet.skor", { score, total })}</p>

          <h4 className="mt-5 text-sm font-extrabold uppercase tracking-wider text-navy-muted dark:text-gray-300">
            {t("ozet.beceriBaslik")}
          </h4>
          <ul className="mt-2 divide-y divide-cream-dark rounded-xl border border-cream-dark bg-white dark:divide-gray-700 dark:border-gray-700 dark:bg-gray-800">
            {gruplar.map((x) => {
              const tam = x.dogru === x.toplam;
              const durum = tam ? t("ozet.guclu") : x.dogru === 0 ? t("ozet.tekrar") : t("ozet.kismen");
              return (
                <li key={x.kod} className="flex items-center justify-between gap-3 px-4 py-3">
                  <span className="min-w-0 font-bold">{t(`beceri.${x.kod}.ad`)}</span>
                  <span className="flex shrink-0 items-center gap-2 text-sm font-bold">
                    <span
                      aria-hidden="true"
                      className={`flex h-6 w-6 items-center justify-center rounded-full text-xs font-extrabold ${
                        tam ? "bg-success-600 text-white" : "bg-retry-500 text-navy"
                      }`}
                    >
                      {tam ? <IconCheck className="h-3.5 w-3.5" /> : "!"}
                    </span>
                    <span>
                      {t("ozet.beceriSatir", { dogru: x.dogru, toplam: x.toplam })}
                      <span className="block text-xs font-semibold text-navy-muted dark:text-gray-400">{durum}</span>
                    </span>
                  </span>
                </li>
              );
            })}
          </ul>

          <h4 className="mt-5 text-sm font-extrabold uppercase tracking-wider text-navy-muted dark:text-gray-300">
            {t("ozet.destekBaslik")}
          </h4>
          {tekrar.length === 0 ? (
            <p className="mt-2 leading-relaxed">{t("ozet.hepsiDogru")}</p>
          ) : (
            <ul className="mt-2 space-y-3">
              {tekrar.map((x) => (
                <li key={x.kod} className="leading-relaxed">
                  <strong className="font-extrabold">{t(`beceri.${x.kod}.ad`)}:</strong> {t(`beceri.${x.kod}.destek`)}
                </li>
              ))}
            </ul>
          )}
          <p className="mt-5 text-sm leading-relaxed text-navy-muted dark:text-gray-400">{t("ozet.uyari")}</p>
        </div>

        <p className="mt-4 text-center text-sm text-navy-muted dark:text-gray-300">{t("doneNote")}</p>
        <div className="mt-6 flex w-full flex-col gap-3 sm:flex-row sm:flex-wrap sm:justify-center">
          <Link href="/veli-paneli/kayit" className={primaryBtn}>
            {t("signup")}
            <IconArrowRight className="h-5 w-5" />
          </Link>
          <button type="button" onClick={() => dispatch({ type: "restart" })} className={secondaryBtn}>
            {t("again")}
          </button>
          <button type="button" onClick={() => dispatch({ type: "changeSinif" })} className={secondaryBtn}>
            {t("sinifDegistir")}
          </button>
        </div>
        <p className="mt-6 text-center text-sm text-navy-muted dark:text-gray-400">{t("sourceNote")}</p>
      </section>
    );
  }

  const progressPct = ((state.index + (checked ? 1 : 0)) / total) * 100;
  const pose = !checked ? "dusunuyor" : wasCorrect ? "dogru" : "bir-daha-dene";
  const poseAlt = !checked
    ? t("poseAlt.ready")
    : wasCorrect
      ? t("poseAlt.correct")
      : t("poseAlt.incorrect");
  const poseSize = !checked
    ? { width: 265, height: 360 }
    : wasCorrect
      ? { width: 360, height: 360 }
      : { width: 339, height: 360 };
  const tuzak =
    checked && !wasCorrect && state.selected !== null
      ? question.tuzaklar?.[state.selected as 0 | 1 | 2 | 3]
      : undefined;

  return (
    <section aria-labelledby="demo-question" className="mx-auto max-w-2xl">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold uppercase tracking-wide text-warning-700">
            {t("badge")}
          </span>
          <span className="rounded-full bg-brand-50 px-3 py-1 text-xs font-extrabold text-brand-700 dark:bg-brand-900/40 dark:text-brand-200">
            {t("sinifRozet", { sinif: state.sinif ?? 0 })}
          </span>
          <span className="text-sm text-navy-muted dark:text-gray-300">{t("notSaved")}</span>
        </div>
        <p className="text-sm font-bold">{t("progress", { current: state.index + 1, total })}</p>
      </div>

      <div
        role="progressbar"
        aria-valuemin={0}
        aria-valuemax={total}
        aria-valuenow={state.index + (checked ? 1 : 0)}
        aria-label={t("progress", { current: state.index + 1, total })}
        className="mt-3 h-2.5 w-full overflow-hidden rounded-full bg-cream-dark dark:bg-gray-700"
      >
        <div
          className="h-full rounded-full bg-brand-500 transition-[width] motion-reduce:transition-none"
          style={{ width: `${progressPct}%` }}
        />
      </div>

      <div className="mt-6 rounded-3xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
        <fieldset>
          <legend className="w-full">
            <span className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
              {question.ders}
              {question.sekil ? ` · ${t("sekilli")}` : ""}
            </span>
            <span
              id="demo-question"
              tabIndex={-1}
              className="mt-2 block text-xl font-bold leading-relaxed outline-none sm:text-2xl"
            >
              {renderEmphasis(question.soru)}
            </span>
          </legend>

          {question.sekil && (
            <div className="mt-5 rounded-2xl border border-cream-dark bg-cream p-3 sm:p-4 dark:border-gray-700 dark:bg-gray-900">
              <DemoFigure sekil={question.sekil} />
            </div>
          )}

          <div className="mt-6 grid gap-3">
            {question.secenekler.map((option, i) => {
              const isSelected = state.selected === i;
              const isRight = checked && i === question.dogru;
              const isMissed = checked && isSelected && i !== question.dogru;
              const letter = String.fromCharCode(65 + i);
              const tone = isRight
                ? "border-success-600 bg-success-50 dark:bg-success-900/30"
                : isMissed
                  ? "border-retry-600 bg-retry-500/15"
                  : isSelected
                    ? "border-brand-500 bg-brand-50 dark:bg-brand-900/30"
                    : "border-cream-dark bg-white hover:border-brand-300 dark:border-gray-600 dark:bg-gray-800";
              return (
                <label
                  key={option}
                  className={`relative flex min-h-14 cursor-pointer items-center gap-3 rounded-xl border-2 px-4 py-3 text-base font-semibold transition-colors has-focus-visible:outline-2 has-focus-visible:outline-offset-2 has-focus-visible:outline-brand-500 motion-reduce:transition-none sm:text-lg ${tone} ${checked ? "cursor-default" : ""}`}
                >
                  <input
                    type="radio"
                    name="demo-option"
                    value={i}
                    checked={isSelected}
                    disabled={checked}
                    onChange={() => dispatch({ type: "select", option: i })}
                    aria-label={`${t("optionLabel", { letter })}: ${plain(option)}`}
                    className="sr-only"
                  />
                  <span
                    aria-hidden="true"
                    className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-sm font-extrabold ${
                      isRight
                        ? "bg-success-600 text-white"
                        : isMissed
                          ? "bg-retry-600 text-white"
                          : isSelected
                            ? "bg-brand-500 text-white"
                            : "bg-cream-dark text-navy dark:bg-gray-700 dark:text-gray-100"
                    }`}
                  >
                    {isRight ? <IconCheck className="h-4 w-4" /> : letter}
                  </span>
                  <span className="min-w-0 flex-1">{renderEmphasis(option)}</span>
                  {isRight && (
                    <span className="shrink-0 text-sm font-extrabold text-success-700 dark:text-success-400">
                      ✓ {t("rightAnswer", { option: letter })}
                    </span>
                  )}
                  {isMissed && (
                    <span className="shrink-0 text-sm font-extrabold text-warning-700 dark:text-retry-400">
                      {t("yourAnswer")}
                    </span>
                  )}
                </label>
              );
            })}
          </div>
        </fieldset>

        {/* Geri bildirim: nazik canlı bölge; odak zorla taşınmaz */}
        <div aria-live="polite" className="mt-6 flex items-start gap-4">
          <Image
            src={g(`hupo.${pose}`)}
            alt={poseAlt}
            width={poseSize.width}
            height={poseSize.height}
            className="h-20 w-auto shrink-0 sm:h-24"
          />
          <div className="min-w-0 flex-1">
            {!checked ? (
              <p className="pt-2 text-base font-semibold text-navy-muted dark:text-gray-300">
                {question.sekil ? t("readyFigure") : t("ready")}
              </p>
            ) : (
              <>
                <p
                  className={`text-lg font-extrabold ${
                    wasCorrect
                      ? "text-success-700 dark:text-success-400"
                      : "text-warning-700 dark:text-retry-400"
                  }`}
                >
                  {wasCorrect ? t("correct") : t("incorrect")}
                </p>
                {tuzak && (
                  <p className="mt-2 rounded-lg bg-cream px-3 py-2 text-sm leading-relaxed dark:bg-gray-900">
                    <span className="font-extrabold">{t("tuzakBaslik")}</span> {tuzak}
                  </p>
                )}
                <p className="mt-3 text-sm font-extrabold uppercase tracking-wider text-navy-muted dark:text-gray-300">
                  {t("steps")}
                </p>
                <ol className="mt-2 list-decimal space-y-2 ps-5 leading-relaxed">
                  {question.adimlar.map((step) => (
                    <li key={step}>{step}</li>
                  ))}
                </ol>
                {!wasCorrect && <p className="mt-3 font-semibold">{t("cesaret")}</p>}
              </>
            )}
          </div>
        </div>

        <div className="mt-8 flex justify-end">
          {!checked ? (
            <button
              type="button"
              onClick={() => dispatch({ type: "check" })}
              disabled={state.selected === null}
              className={primaryBtn}
            >
              {t("check")}
            </button>
          ) : (
            <button type="button" onClick={() => dispatch({ type: "next" })} className={primaryBtn}>
              {state.index >= total - 1 ? t("finish") : t("next")}
              <IconArrowRight className="h-5 w-5" />
            </button>
          )}
        </div>
      </div>

      <div className="mt-4 flex flex-col items-center gap-2 text-center">
        <button
          type="button"
          onClick={() => dispatch({ type: "changeSinif" })}
          className="inline-flex min-h-11 items-center px-3 text-sm font-bold text-navy-muted underline underline-offset-4 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-gray-300"
        >
          {t("sinifDegistir")}
        </button>
        <p className="text-sm text-navy-muted dark:text-gray-400">{t("sourceNote")}</p>
      </div>
    </section>
  );
}
