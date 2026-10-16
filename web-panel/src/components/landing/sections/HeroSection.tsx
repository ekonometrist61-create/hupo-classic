import { IconArrowRight, IconInfo } from "@/components/landing/Icons";
import { TrackedLink } from "@/components/analytics/TrackedLink";
import { getTranslations } from "next-intl/server";
import Image from "next/image";

const primaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none";

// Örnek veli raporu: gerçek bir öğrenciye ait değildir, etiketiyle birlikte gösterilir.
const SAMPLE_SUBJECTS = [
  { label: "Türkçe", pct: 82, bar: "bg-success-500" },
  { label: "Matematik", pct: 58, bar: "bg-warning-500" },
  { label: "Fen Bilimleri", pct: 44, bar: "bg-error-500" },
];

export async function HeroSection() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");

  return (
    <section className="mx-auto grid max-w-6xl items-center gap-10 px-4 pb-12 pt-10 sm:px-6 sm:pb-14 sm:pt-12 lg:grid-cols-[1.05fr_0.95fr] lg:gap-12 lg:px-8 lg:pb-16 lg:pt-14">
      <div>
        <h1 className="text-balance text-4xl font-extrabold leading-[1.1] tracking-tight sm:text-5xl lg:text-[3.4rem]">
          {t("hero.title")}
        </h1>
        <p className="mt-5 max-w-xl text-lg leading-relaxed text-navy-muted sm:text-xl dark:text-gray-300">
          {t("hero.subtitle")}
        </p>
        <div className="mt-8 flex flex-col items-start gap-3">
          <TrackedLink
            href="/demo"
            olay="hero_cta_tiklandi"
            ozellik={{ konum: "ust" }}
            className={primaryBtn}
          >
            {t("hero.ctaPrimary")}
            <IconArrowRight className="h-5 w-5" />
          </TrackedLink>
          <TrackedLink
            href="/veli-paneli/kayit"
            olay="veli_kayit_baslatildi"
            ozellik={{ konum: "ust" }}
            className="inline-flex min-h-11 items-center rounded-lg px-1 text-base font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-brand-300"
          >
            {t("hero.ctaSecondary")}
          </TrackedLink>
        </div>
        <p className="mt-4 text-sm text-navy-muted dark:text-gray-400">{t("hero.note")}</p>
        <p className="mt-6 inline-flex items-start gap-2 rounded-xl bg-white/70 px-4 py-3 text-sm text-navy-muted ring-1 ring-cream-dark dark:bg-gray-900 dark:text-gray-300 dark:ring-gray-700">
          <IconInfo className="mt-0.5 h-4 w-4 shrink-0 text-brand-600 dark:text-brand-300" />
          {t("hero.pilot")}
        </p>
      </div>

      <div className="relative mx-auto w-full max-w-sm pb-6 lg:max-w-none">
        <div
          aria-hidden="true"
          className="absolute inset-x-8 bottom-0 top-10 rounded-[3rem] bg-gold-100 dark:bg-gold-900/30"
        />

        {/* Gerçek uygulama ekranı (soru ekranı) telefon çerçevesinde */}
        <div className="relative mx-auto w-60 rounded-[2.4rem] bg-navy p-2.5 shadow-2xl sm:w-64">
          <Image
            src="/landing/hero-soru.jpg"
            alt={t("hero.phoneAlt")}
            width={600}
            height={1200}
            priority
            sizes="256px"
            className="h-auto w-full rounded-[1.9rem]"
          />
        </div>

        {/* Hupo köşede, ekranın sol üstünde */}
        <Image
          src={g("hupo.hero")}
          alt={t("hero.mascotAlt")}
          width={713}
          height={760}
          className="absolute -start-2 top-6 h-24 w-auto drop-shadow-md sm:-start-6 sm:h-28"
        />

        {/* ÖRNEK RAPOR: veli kartı, etiketi açıkça görünür */}
        <aside
          aria-label={t("hero.sampleLabel")}
          className="absolute end-0 bottom-0 w-60 max-w-[calc(100%-1rem)] rounded-2xl bg-white p-4 shadow-xl ring-1 ring-cream-dark sm:-end-8 sm:w-64 dark:bg-gray-800 dark:ring-gray-700"
        >
          <div className="flex items-center justify-between gap-2">
            <span className="rounded-md bg-warning-100 px-2 py-0.5 text-[11px] font-extrabold tracking-wider text-warning-700">
              {t("hero.sampleTag")}
            </span>
            <span className="text-xs font-semibold text-navy-muted dark:text-gray-400">
              {t("hero.sampleWeek")}
            </span>
          </div>
          <div className="mt-3 grid grid-cols-2 gap-2">
            <div className="rounded-xl bg-brand-50 p-2.5 dark:bg-brand-900/30">
              <p className="text-xs font-semibold text-navy-muted dark:text-gray-400">
                {t("hero.sampleAccuracy")}
              </p>
              <p className="mt-0.5 text-2xl font-extrabold text-brand-700 dark:text-brand-200">%64</p>
            </div>
            <div className="rounded-xl bg-cream p-2.5 dark:bg-gray-900">
              <p className="text-xs font-semibold text-navy-muted dark:text-gray-400">
                {t("hero.sampleSolved")}
              </p>
              <p className="mt-0.5 text-2xl font-extrabold text-navy dark:text-gray-100">124</p>
            </div>
          </div>
          <ul className="mt-3 space-y-2">
            {SAMPLE_SUBJECTS.map((s) => (
              <li key={s.label}>
                <div className="flex justify-between text-xs font-semibold text-navy dark:text-gray-200">
                  <span>{s.label}</span>
                  <span>%{s.pct}</span>
                </div>
                <div className="mt-1 h-2 overflow-hidden rounded-full bg-cream-dark dark:bg-gray-700">
                  <div className={`h-full rounded-full ${s.bar}`} style={{ width: `${s.pct}%` }} />
                </div>
              </li>
            ))}
          </ul>
          <p className="mt-3 text-[11px] leading-snug text-navy-muted dark:text-gray-400">
            {t("hero.sampleNote")}
          </p>
        </aside>
      </div>
    </section>
  );
}
