import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

export async function DemoSection() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");
  const demoOptions = t.raw("demo.options") as string[];

  return (
    <section id="demo" className="scroll-mt-20 py-6 sm:py-8 lg:py-10">
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
          <p className="mt-6 text-sm font-extrabold uppercase tracking-wider text-navy-muted dark:text-gray-300">
            {t("demo.sinifEtiket")}
          </p>
          <ul className="mt-2 flex flex-wrap gap-2" aria-label={t("demo.sinifEtiket")}>
            {[3, 4, 5, 6, 7].map((n) => (
              <li key={n}>
                <Link
                  href={`/demo?sinif=${n}`}
                  aria-label={t("demo.sinifBaglanti", { sinif: n })}
                  className="inline-flex h-12 min-w-12 items-center justify-center rounded-xl border-2 border-navy/15 bg-white px-4 text-lg font-extrabold text-navy transition-colors hover:border-brand-500 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100"
                >
                  {n}
                </Link>
              </li>
            ))}
          </ul>
          <div className="mt-6">
            <Link href="/demo" className={landingPrimaryBtn}>
              {t("demo.cta")}
              <IconArrowRight className="h-5 w-5" />
            </Link>
          </div>
        </div>

        <Reveal className="relative">
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
                b: (chunks) => (
                  <strong className="font-extrabold underline decoration-gold-600 decoration-2 underline-offset-4">
                    {chunks}
                  </strong>
                ),
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
            src={g("hupo.dusunuyor")}
            alt=""
            width={265}
            height={360}
            sizes="(min-width: 1024px) 118px, 94px"
            className="absolute -bottom-6 -end-2 hidden h-32 w-auto sm:block lg:-end-8 lg:h-40"
          />
        </Reveal>
      </div>
    </section>
  );
}

