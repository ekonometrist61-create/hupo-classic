"use client";

import { IconArrowRight, IconCheck } from "@/components/landing/Icons";
import { useTranslations } from "next-intl";
import Image from "next/image";
import Link from "next/link";
import { Fragment, useReducer } from "react";

import { DEMO_QUESTIONS } from "./demoQuestions";

type Phase = "answering" | "checked" | "done";

interface State {
  index: number;
  selected: number | null;
  phase: Phase;
  score: number;
}

type Action =
  | { type: "select"; option: number }
  | { type: "check" }
  | { type: "next" }
  | { type: "restart" };

const INITIAL: State = { index: 0, selected: null, phase: "answering", score: 0 };
const TOTAL = DEMO_QUESTIONS.length;

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "select":
      if (state.phase !== "answering") return state;
      return { ...state, selected: action.option };
    case "check": {
      // Çift tıklamada ikinci kez puan yazılmasın.
      if (state.phase !== "answering" || state.selected === null) return state;
      const dogru = DEMO_QUESTIONS[state.index].dogru === state.selected;
      return { ...state, phase: "checked", score: state.score + (dogru ? 1 : 0) };
    }
    case "next":
      if (state.phase !== "checked") return state;
      if (state.index >= TOTAL - 1) return { ...state, phase: "done" };
      return { ...state, index: state.index + 1, selected: null, phase: "answering" };
    case "restart":
      return INITIAL;
  }
}

function renderEmphasis(text: string) {
  return text.split("**").map((part, i) =>
    i % 2 === 1 ? (
      <strong
        key={i}
        className="font-extrabold underline decoration-gold-500 decoration-2 underline-offset-4"
      >
        {part}
      </strong>
    ) : (
      <Fragment key={i}>{part}</Fragment>
    )
  );
}

const primaryBtn =
  "inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:bg-navy/20 disabled:text-navy-muted disabled:shadow-none motion-reduce:transition-none sm:w-auto dark:disabled:bg-gray-700 dark:disabled:text-gray-400";
const secondaryBtn =
  "inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-xl border-2 border-navy/15 bg-white px-6 py-3 text-base font-bold text-navy transition-colors hover:border-brand-500 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none sm:w-auto dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100";

export default function DemoQuiz() {
  const t = useTranslations("demo");
  const [state, dispatch] = useReducer(reducer, INITIAL);
  const question = DEMO_QUESTIONS[state.index];
  const checked = state.phase === "checked";
  const wasCorrect = checked && state.selected === question.dogru;

  if (state.phase === "done") {
    return (
      <section
        aria-labelledby="demo-done-title"
        className="mx-auto flex max-w-xl flex-col items-center rounded-3xl border border-cream-dark bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-800"
      >
        <Image
          src="/hupo/tamamlandi.webp"
          alt={t("poseAlt.done")}
          width={420}
          height={404}
          className="h-40 w-auto"
        />
        <h2 id="demo-done-title" className="mt-4 text-3xl font-extrabold">
          {t("doneTitle")}
        </h2>
        <p className="mt-3 text-lg font-bold">
          {t("doneScore", { score: state.score, total: TOTAL })}
        </p>
        <p className="mt-2 text-navy-muted dark:text-gray-300">{t("doneNote")}</p>
        <div className="mt-8 flex w-full flex-col gap-3 sm:w-auto sm:flex-row">
          <Link href="/signup" className={primaryBtn}>
            {t("signup")}
            <IconArrowRight className="h-5 w-5" />
          </Link>
          <button type="button" onClick={() => dispatch({ type: "restart" })} className={secondaryBtn}>
            {t("again")}
          </button>
        </div>
        <p className="mt-6 text-sm text-navy-muted dark:text-gray-400">{t("sourceNote")}</p>
      </section>
    );
  }

  const progressPct = ((state.index + (checked ? 1 : 0)) / TOTAL) * 100;
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

  return (
    <section aria-labelledby="demo-question" className="mx-auto max-w-2xl">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold uppercase tracking-wide text-warning-700">
            {t("badge")}
          </span>
          <span className="text-sm text-navy-muted dark:text-gray-300">{t("notSaved")}</span>
        </div>
        <p className="text-sm font-bold">
          {t("progress", { current: state.index + 1, total: TOTAL })}
        </p>
      </div>

      <div
        role="progressbar"
        aria-valuemin={0}
        aria-valuemax={TOTAL}
        aria-valuenow={state.index + (checked ? 1 : 0)}
        aria-label={t("progress", { current: state.index + 1, total: TOTAL })}
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
            </span>
            <span
              id="demo-question"
              className="mt-2 block text-xl font-bold leading-relaxed sm:text-2xl"
            >
              {renderEmphasis(question.soru)}
            </span>
          </legend>

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
                    aria-label={`${t("optionLabel", { letter })}: ${option}`}
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
                  <span className="min-w-0 flex-1">{option}</span>
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
            src={`/hupo/${pose}.webp`}
            alt={poseAlt}
            width={poseSize.width}
            height={poseSize.height}
            className="h-20 w-auto shrink-0 sm:h-24"
          />
          <div className="min-w-0 flex-1">
            {!checked ? (
              <p className="pt-2 text-base font-semibold text-navy-muted dark:text-gray-300">
                {t("ready")}
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
                <p className="mt-3 text-sm font-extrabold uppercase tracking-wider text-navy-muted dark:text-gray-300">
                  {t("steps")}
                </p>
                <ol className="mt-2 list-decimal space-y-2 ps-5 leading-relaxed">
                  {question.adimlar.map((step) => (
                    <li key={step}>{step}</li>
                  ))}
                </ol>
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
            <button
              type="button"
              onClick={() => dispatch({ type: "next" })}
              className={primaryBtn}
            >
              {state.index >= TOTAL - 1 ? t("finish") : t("next")}
              <IconArrowRight className="h-5 w-5" />
            </button>
          )}
        </div>
      </div>

      <p className="mt-4 text-center text-sm text-navy-muted dark:text-gray-400">{t("sourceNote")}</p>
    </section>
  );
}
