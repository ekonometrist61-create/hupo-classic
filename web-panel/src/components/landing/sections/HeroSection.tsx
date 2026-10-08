import { IconArrowRight, IconInfo } from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

const primaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none";
const secondaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl border-2 border-navy/15 bg-white px-6 py-3 text-base font-bold text-navy transition-colors hover:border-brand-500 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100 dark:hover:border-brand-400";

export async function HeroSection() {
  const t = await getTranslations("landing");

  return (
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
  );
}
