import { FaqAccordion, MobileMenu } from "@/components/landing/LandingClient";
import {
  IconArrowRight,
  IconChart,
  IconCheck,
  IconCompass,
  IconDevice,
  IconImage,
  IconInfo,
  IconLock,
  IconRepeat,
  IconShield,
  IconSparkle,
  IconSteps,
  IconTimer,
  IconUserCheck,
} from "@/components/landing/Icons";
import { marketingFont } from "@/components/landing/marketingFont";
import type { Metadata } from "next";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";
import type { ComponentType, SVGProps } from "react";

type Icon = ComponentType<SVGProps<SVGSVGElement>>;
type TitleDesc = { title: string; desc: string };

const BENEFIT_ICONS: Icon[] = [IconTimer, IconSteps, IconChart];
const HOW_ICONS: Icon[] = [IconUserCheck, IconSteps, IconChart];
const TRUST_ICONS: Icon[] = [IconShield, IconUserCheck, IconLock, IconCompass];

// Örnek veli raporu verisi; gerçek bir öğrenciye ait değildir (sayfada etiketli).
const REPORT_ROWS = [
  { key: "math", solved: 8, correct: 5 },
  { key: "turkish", solved: 7, correct: 6 },
  { key: "science", solved: 3, correct: 2 },
] as const;
// Veli panelindeki SubjectSuccessChart ile aynı eşik.
const MIN_EVIDENCE = 6;

const primaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none";
const secondaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl border-2 border-navy/15 bg-white px-6 py-3 text-base font-bold text-navy transition-colors hover:border-brand-500 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100 dark:hover:border-brand-400";

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations("landing");
  return { title: t("metaTitle"), description: t("metaDescription") };
}

export default async function LandingPage() {
  const t = await getTranslations("landing");

  const benefits = t.raw("benefits.items") as TitleDesc[];
  const steps = t.raw("how.steps") as TitleDesc[];
  const trustItems = t.raw("trust.items") as TitleDesc[];
  const faqItems = (t.raw("faq.items") as { q: string; a: string }[]).map(
    (i) => ({ q: i.q, a: i.a })
  );
  const demoOptions = t.raw("demo.options") as string[];
  const appScreenItems = t.raw("appScreens.items") as TitleDesc[];
  const planBullets = t.raw("plans.bullets") as string[];

  return (
    <div
      className={`${marketingFont.className} min-h-screen bg-cream text-navy dark:bg-gray-950 dark:text-gray-100`}
    >
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:start-4 focus:top-4 focus:z-[60] focus:rounded-lg focus:bg-white focus:px-4 focus:py-2 focus:font-bold focus:text-navy"
      >
        {t("skipToContent")}
      </a>

      {/* ── ÜST MENÜ ── */}
      <header className="sticky top-0 z-50 border-b border-cream-dark bg-cream/90 backdrop-blur-md dark:border-gray-800 dark:bg-gray-950/90">
        <div className="relative mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link href="/" className="flex items-center gap-2" aria-label={t("brand")}>
            <Image
              src="/hupo/hosgeldin.webp"
              alt=""
              width={420}
              height={415}
              className="h-9 w-9 object-contain"
            />
            <span className="text-xl font-extrabold tracking-tight">{t("brand")}</span>
          </Link>

          <nav
            aria-label={t("nav.label")}
            className="hidden items-center gap-7 text-sm font-bold text-navy-muted md:flex dark:text-gray-300"
          >
            <a href="#demo" className="hover:text-brand-600">{t("nav.demo")}</a>
            <a href="#app-screens" className="hover:text-brand-600">{t("nav.appScreens")}</a>
            <a href="#how-it-works" className="hover:text-brand-600">{t("nav.how")}</a>
            <a href="#report" className="hover:text-brand-600">{t("nav.report")}</a>
            <a href="#trust" className="hover:text-brand-600">{t("nav.trust")}</a>
            <a href="#faq" className="hover:text-brand-600">{t("nav.faq")}</a>
          </nav>

          <div className="flex items-center gap-2 sm:gap-3">
            <Link
              href="/signin"
              className="hidden min-h-11 items-center px-2 text-sm font-bold text-navy hover:text-brand-600 sm:inline-flex dark:text-gray-100"
            >
              {t("nav.signin")}
            </Link>
            <Link
              href="/signup"
              className="inline-flex min-h-11 items-center rounded-xl bg-brand-500 px-4 text-sm font-bold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none"
            >
              {t("nav.cta")}
            </Link>
            <MobileMenu />
          </div>
        </div>
      </header>

      <main id="main">
        {/* ── HERO ── */}
        <section className="mx-auto grid max-w-6xl items-center gap-8 px-4 pb-12 pt-10 sm:px-6 sm:pb-14 sm:pt-12 lg:grid-cols-[1.1fr_0.9fr] lg:gap-6 lg:px-8 lg:pb-16 lg:pt-14">
          <div>
            <p className="inline-flex rounded-full bg-gold-100 px-3 py-1 text-sm font-bold text-gold-900 dark:bg-gold-900/40 dark:text-gold-100">
              {t("hero.badge")}
            </p>
            <h1 className="mt-5 text-balance text-4xl font-extrabold leading-[1.1] tracking-tight sm:text-5xl lg:text-[3.4rem]">
              {t("hero.title")}
            </h1>
            <p className="mt-5 max-w-xl text-lg leading-relaxed text-navy-muted sm:text-xl dark:text-gray-300">
              {t("hero.subtitle")}
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link href="/demo" className={primaryBtn}>
                {t("hero.ctaPrimary")}
                <IconArrowRight className="h-5 w-5" />
              </Link>
              <Link href="/signup" className={secondaryBtn}>
                {t("hero.ctaSecondary")}
              </Link>
            </div>
            <p className="mt-4 text-sm text-navy-muted dark:text-gray-400">{t("hero.note")}</p>
            <p className="mt-6 inline-flex items-start gap-2 rounded-xl bg-white/70 px-4 py-3 text-sm text-navy-muted ring-1 ring-cream-dark dark:bg-gray-900 dark:text-gray-300 dark:ring-gray-700">
              <IconInfo className="mt-0.5 h-4 w-4 shrink-0 text-brand-600 dark:text-brand-300" />
              {t("hero.pilot")}
            </p>
          </div>

          <div className="relative mx-auto flex w-full max-w-sm justify-center lg:max-w-none">
            <div
              aria-hidden="true"
              className="absolute inset-x-6 bottom-0 top-6 rounded-[3rem] bg-gold-100 dark:bg-gold-900/30"
            />
            <Image
              src="/hupo/hero.webp"
              alt={t("hero.mascotAlt")}
              width={713}
              height={760}
              priority
              sizes="(min-width: 1024px) 420px, 70vw"
              className="relative h-auto w-64 sm:w-80 lg:w-[26rem]"
            />
          </div>
        </section>

        {/* ── FAYDALAR ── */}
        <section className="bg-white py-12 sm:py-16 dark:bg-gray-900">
          <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
            <h2 className="mx-auto max-w-2xl text-balance text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
              {t("benefits.title")}
            </h2>
            <ul className="mt-10 grid gap-6 md:grid-cols-3">
              {benefits.map((item, i) => {
                const Icon = BENEFIT_ICONS[i];
                return (
                  <li
                    key={item.title}
                    className="rounded-2xl border border-cream-dark bg-cream p-6 dark:border-gray-700 dark:bg-gray-800"
                  >
                    <span className="inline-flex h-12 w-12 items-center justify-center rounded-xl bg-brand-500 text-white">
                      <Icon className="h-6 w-6" />
                    </span>
                    <h3 className="mt-5 text-xl font-extrabold">{item.title}</h3>
                    <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">
                      {item.desc}
                    </p>
                  </li>
                );
              })}
            </ul>
          </div>
        </section>

        {/* ── ÖRNEK SORU / DEMO ── */}
        <section id="demo" className="scroll-mt-20 py-12 sm:py-16 lg:py-20">
          <div className="mx-auto grid max-w-6xl items-center gap-8 px-4 sm:px-6 lg:grid-cols-2 lg:gap-14 lg:px-8">
            <div>
              <p className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
                {t("demo.eyebrow")}
              </p>
              <h2 className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
                {t("demo.title")}
              </h2>
              <p className="mt-4 max-w-lg text-lg leading-relaxed text-navy-muted dark:text-gray-300">
                {t("demo.desc")}
              </p>
              <div className="mt-8">
                <Link href="/demo" className={primaryBtn}>
                  {t("demo.cta")}
                  <IconArrowRight className="h-5 w-5" />
                </Link>
              </div>
              <p className="mt-4 text-sm text-navy-muted dark:text-gray-400">{t("demo.note")}</p>
              {t.has("demo.langNote") && (
                <p className="mt-1 text-sm text-navy-muted dark:text-gray-400">
                  {t("demo.langNote")}
                </p>
              )}
            </div>

            <div className="relative">
              <div className="rounded-3xl border border-cream-dark bg-white p-6 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
                <div className="flex items-center justify-between gap-3">
                  <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold uppercase tracking-wide text-warning-700">
                    {t("demo.badge")}
                  </span>
                  <span className="text-sm font-bold text-navy-muted dark:text-gray-300">
                    {t("demo.subject")}
                  </span>
                </div>
                <p className="mt-5 text-lg font-semibold leading-relaxed">
                  {t.rich("demo.question", {
                    b: (chunks) => <strong className="font-extrabold underline decoration-gold-500 decoration-2 underline-offset-4">{chunks}</strong>,
                  })}
                </p>
                <ul className="mt-5 grid gap-3" aria-hidden="true">
                  {demoOptions.map((opt, i) => (
                    <li
                      key={opt}
                      className="flex min-h-12 items-center gap-3 rounded-xl border-2 border-cream-dark px-4 py-2 font-semibold dark:border-gray-600"
                    >
                      <span className="flex h-7 w-7 items-center justify-center rounded-full bg-cream-dark text-sm font-extrabold dark:bg-gray-700">
                        {String.fromCharCode(65 + i)}
                      </span>
                      {opt}
                    </li>
                  ))}
                </ul>
              </div>
              <Image
                src="/hupo/dusunuyor.webp"
                alt=""
                width={265}
                height={360}
                className="absolute -bottom-6 -end-2 hidden h-32 w-auto sm:block lg:-end-8 lg:h-40"
              />
            </div>
          </div>
        </section>

        {/* ── UYGULAMA EKRANLARI ── */}
        <section
          id="app-screens"
          className="scroll-mt-20 bg-white py-12 sm:py-16 lg:py-20 dark:bg-gray-900"
        >
          <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <p className="inline-flex items-center gap-2 rounded-full bg-brand-50 px-3 py-1 text-sm font-bold text-brand-700 dark:bg-brand-900/30 dark:text-brand-200">
                <IconDevice className="h-4 w-4" />
                {t("appScreens.eyebrow")}
              </p>
              <h2 className="mt-4 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
                {t("appScreens.title")}
              </h2>
              <p className="mt-3 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
                {t("appScreens.desc")}
              </p>
            </div>

            <div className="mt-10 grid gap-8 sm:grid-cols-3">
              {appScreenItems.map((item) => (
                <div key={item.title} className="flex flex-col items-center">
                  <div className="relative flex aspect-[9/19] w-full max-w-[220px] flex-col items-center justify-center gap-3 rounded-[2rem] border-2 border-dashed border-cream-dark bg-cream p-6 text-center dark:border-gray-700 dark:bg-gray-800">
                    <IconImage className="h-10 w-10 text-navy-muted/50 dark:text-gray-500" />
                    <p className="text-xs font-bold uppercase tracking-wide text-navy-muted/70 dark:text-gray-500">
                      {t("appScreens.comingSoon")}
                    </p>
                  </div>
                  <h3 className="mt-5 text-lg font-extrabold">{item.title}</h3>
                  <p className="mt-1 max-w-[220px] text-center leading-relaxed text-navy-muted dark:text-gray-300">
                    {item.desc}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── NASIL ÇALIŞIR ── */}
        <section
          id="how-it-works"
          className="scroll-mt-20 bg-white py-12 sm:py-16 lg:py-20 dark:bg-gray-900"
        >
          <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
            <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
              {t("how.title")}
            </h2>
            <ol className="mt-10 grid gap-8 md:grid-cols-3">
              {steps.map((step, i) => {
                const Icon = HOW_ICONS[i];
                return (
                  <li key={step.title} className="relative">
                    <div className="flex items-center gap-3">
                      <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-gold-500 text-xl font-extrabold text-navy">
                        {i + 1}
                      </span>
                      <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-50 text-brand-600 dark:bg-brand-900/30 dark:text-brand-300">
                        <Icon className="h-5 w-5" />
                      </span>
                    </div>
                    <h3 className="mt-5 text-xl font-extrabold">{step.title}</h3>
                    <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">
                      {step.desc}
                    </p>
                  </li>
                );
              })}
            </ol>
          </div>
        </section>

        {/* ── ÖRNEK VELİ RAPORU ── */}
        <section id="report" className="scroll-mt-20 py-12 sm:py-16 lg:py-20">
          <div className="mx-auto grid max-w-6xl items-start gap-8 px-4 sm:px-6 lg:grid-cols-[0.8fr_1.2fr] lg:gap-14 lg:px-8">
            <div className="min-w-0">
              <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
                {t("report.title")}
              </h2>
              <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
                {t("report.desc")}
              </p>
            </div>

            <div className="min-w-0 rounded-3xl border border-cream-dark bg-white p-5 shadow-sm sm:p-8 dark:border-gray-700 dark:bg-gray-800">
              <div className="flex flex-wrap items-center gap-3">
                <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold tracking-wide text-warning-700">
                  {t("report.badge")}
                </span>
                <p className="text-sm text-navy-muted dark:text-gray-300">{t("report.disclaimer")}</p>
              </div>

              <div className="mt-6 overflow-x-auto">
                <table className="w-full min-w-[30rem] text-start text-sm sm:text-base">
                  <thead>
                    <tr className="border-b border-cream-dark text-navy-muted dark:border-gray-700 dark:text-gray-300">
                      <th scope="col" className="py-2 pe-3 text-start font-bold">{t("report.colSubject")}</th>
                      <th scope="col" className="py-2 pe-3 text-start font-bold">{t("report.colSolved")}</th>
                      <th scope="col" className="py-2 pe-3 text-start font-bold">{t("report.colCorrect")}</th>
                      <th scope="col" className="py-2 text-start font-bold">{t("report.colRate")}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-cream-dark dark:divide-gray-700">
                    {REPORT_ROWS.map((row) => {
                      const enough = row.solved >= MIN_EVIDENCE;
                      const rate = Math.round((row.correct / row.solved) * 100);
                      return (
                        <tr key={row.key}>
                          <th scope="row" className="py-3 pe-3 text-start font-bold">
                            {t(`report.subjects.${row.key}`)}
                          </th>
                          <td className="py-3 pe-3">{row.solved}</td>
                          <td className="py-3 pe-3">{row.correct}</td>
                          <td className="py-3">
                            {enough ? (
                              <div className="flex items-center gap-3">
                                <div
                                  className="h-2.5 w-24 overflow-hidden rounded-full bg-cream-dark dark:bg-gray-700"
                                  aria-hidden="true"
                                >
                                  <div
                                    className="h-full rounded-full bg-brand-500"
                                    style={{ width: `${rate}%` }}
                                  />
                                </div>
                                <span className="font-extrabold">%{rate}</span>
                              </div>
                            ) : (
                              <span className="text-navy-muted italic dark:text-gray-300">
                                {t("report.insufficient")}
                              </span>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              <div className="mt-6 flex items-start gap-3 rounded-2xl bg-retry-500/15 p-4">
                <IconRepeat className="mt-0.5 h-5 w-5 shrink-0 text-warning-700 dark:text-retry-400" />
                <div>
                  <p className="font-extrabold">{t("report.reviewTitle")}</p>
                  <p className="mt-1 text-navy-muted dark:text-gray-300">{t("report.reviewText")}</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* ── GÜVEN ── */}
        <section id="trust" className="scroll-mt-20 bg-navy py-12 text-white sm:py-16 lg:py-20">
          <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
            <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
              {t("trust.title")}
            </h2>
            <p className="mx-auto mt-3 max-w-xl text-center text-lg text-white/80">
              {t("trust.desc")}
            </p>
            <ul className="mt-10 grid gap-6 sm:grid-cols-2">
              {trustItems.map((item, i) => {
                const Icon = TRUST_ICONS[i];
                return (
                  <li
                    key={item.title}
                    className="flex gap-4 rounded-2xl border border-white/15 bg-white/5 p-6"
                  >
                    <span className="inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-gold-500 text-navy">
                      <Icon className="h-6 w-6" />
                    </span>
                    <div>
                      <h3 className="text-lg font-extrabold">{item.title}</h3>
                      <p className="mt-1 leading-relaxed text-white/80">{item.desc}</p>
                    </div>
                  </li>
                );
              })}
            </ul>
          </div>
        </section>

        {/* ── PLANLAR ── */}
        <section id="plans" className="scroll-mt-20 py-12 sm:py-16 lg:py-20">
          <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
            <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
              {t("plans.title")}
            </h2>
            <div className="mt-8 rounded-3xl border-2 border-dashed border-navy/20 bg-white p-8 text-center dark:border-gray-600 dark:bg-gray-800">
              <span className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-gold-100 text-gold-700 dark:bg-gold-900/40 dark:text-gold-200">
                <IconSparkle className="h-7 w-7" />
              </span>
              <p className="mt-4 text-xl font-extrabold">{t("plans.cardTitle")}</p>
              <p className="mx-auto mt-3 max-w-xl leading-relaxed text-navy-muted dark:text-gray-300">
                {t("plans.cardDesc")}
              </p>
              <ul className="mx-auto mt-6 flex max-w-xl flex-col gap-3 text-start sm:flex-row sm:justify-center sm:gap-6 sm:text-center">
                {planBullets.map((bullet) => (
                  <li
                    key={bullet}
                    className="flex items-center gap-2 text-sm font-bold text-navy sm:flex-col sm:gap-2 dark:text-gray-100"
                  >
                    <IconCheck className="h-4 w-4 shrink-0 text-brand-600 dark:text-brand-300" />
                    {bullet}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </section>

        {/* ── SSS ── */}
        <section id="faq" className="scroll-mt-20 bg-white pb-12 pt-12 sm:pb-16 sm:pt-16 lg:pb-20 lg:pt-20 dark:bg-gray-900">
          <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
            <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
              {t("faq.title")}
            </h2>
            <div className="mt-10">
              <FaqAccordion items={faqItems} />
            </div>
          </div>
        </section>

        {/* ── SON ÇAĞRI ── */}
        <section className="bg-gold-100 py-12 sm:py-16 dark:bg-gold-900/30">
          <div className="mx-auto flex max-w-4xl flex-col items-center gap-8 px-4 text-center sm:px-6 md:flex-row md:text-start lg:px-8">
            <Image
              src="/hupo/tamamlandi.webp"
              alt=""
              width={420}
              height={404}
              className="h-40 w-auto shrink-0"
            />
            <div>
              <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
                {t("cta.title")}
              </h2>
              <p className="mt-3 text-lg text-navy-muted dark:text-gray-300">{t("cta.desc")}</p>
              <div className="mt-6 flex flex-col gap-3 sm:flex-row md:justify-start">
                <Link href="/demo" className={primaryBtn}>
                  {t("cta.primary")}
                  <IconArrowRight className="h-5 w-5" />
                </Link>
                <Link href="/signup" className={secondaryBtn}>
                  {t("cta.secondary")}
                </Link>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* ── ALT BİLGİ ── */}
      <footer className="bg-cream py-10 dark:bg-gray-950">
        <div className="mx-auto grid max-w-6xl gap-8 px-4 sm:px-6 md:grid-cols-[1.4fr_1fr_1fr] lg:px-8">
          <div>
            <p className="flex items-center gap-2 text-xl font-extrabold">
              <Image src="/hupo/hosgeldin.webp" alt="" width={420} height={415} className="h-9 w-9 object-contain" />
              {t("brand")}
            </p>
            <p className="mt-3 text-navy-muted dark:text-gray-300">{t("footer.tagline")}</p>
            <p className="mt-2 inline-flex items-center gap-2 text-sm text-navy-muted dark:text-gray-400">
              <IconCheck className="h-4 w-4 text-brand-600 dark:text-brand-300" />
              {t("footer.pilot")}
            </p>
          </div>
          <nav aria-label={t("footer.colProduct")}>
            <p className="font-extrabold">{t("footer.colProduct")}</p>
            <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
              <li><Link href="/demo" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.demo")}</Link></li>
              <li><a href="#how-it-works" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.how")}</a></li>
              <li><a href="#faq" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.faq")}</a></li>
            </ul>
          </nav>
          <nav aria-label={t("footer.colAccount")}>
            <p className="font-extrabold">{t("footer.colAccount")}</p>
            <ul className="mt-3 space-y-1 text-navy-muted dark:text-gray-300">
              <li><Link href="/signin" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.signin")}</Link></li>
              <li><Link href="/signup" className="inline-flex min-h-11 items-center hover:text-brand-600">{t("footer.signup")}</Link></li>
            </ul>
          </nav>
        </div>
        <p className="mx-auto mt-8 max-w-6xl px-4 text-sm text-navy-muted sm:px-6 lg:px-8 dark:text-gray-400">
          {t("footer.copyright")}
        </p>
      </footer>
    </div>
  );
}
