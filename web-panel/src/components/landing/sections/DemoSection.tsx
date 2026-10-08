import { IconArrowRight } from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

const primaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none";

export async function DemoSection() {
  const t = await getTranslations("landing");
  const demoOptions = t.raw("demo.options") as string[];

  return (
    <section id="demo" className="scroll-mt-20 py-8 sm:py-12">
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
                b: (chunks) => (
                  <strong className="font-extrabold underline decoration-gold-500 decoration-2 underline-offset-4">
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
            src="/hupo/dusunuyor.webp"
            alt=""
            width={265}
            height={360}
            className="absolute -bottom-6 -end-2 hidden h-32 w-auto sm:block lg:-end-8 lg:h-40"
          />
        </div>
      </div>
    </section>
  );
}

