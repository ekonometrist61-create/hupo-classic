import { Link } from "@/i18n/navigation";
import { getTranslations } from "next-intl/server";

// Kısa blok: kanıt kartları kaldırıldı; ayrıntı ve DOI'ler /yontem sayfasında. Hupolingo sonucu değildir.
export async function OgrenmeBilimiSection() {
  const t = await getTranslations("landing.ogrenmeBilimi");

  return (
    <section
      id="ogrenme-bilimi"
      aria-labelledby="ogrenme-bilimi-baslik"
      className="scroll-mt-20 bg-cream py-12 text-navy sm:py-16 dark:bg-gray-950 dark:text-gray-100"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <p className="text-sm font-extrabold uppercase tracking-wider text-brand-700 dark:text-brand-300">
          {t("etiket")}
        </p>
        <h2
          id="ogrenme-bilimi-baslik"
          className="mt-2 max-w-3xl text-balance text-3xl font-extrabold tracking-tight sm:text-4xl"
        >
          {t("baslik")}
        </h2>
        <p className="mt-4 max-w-3xl text-lg leading-relaxed text-navy-muted dark:text-gray-300">{t("giris")}</p>

        <p className="mt-2 text-sm font-semibold text-navy-muted dark:text-gray-400">{t("dipnot")}</p>

        <p className="mt-6">
          <Link
            href="/yontem"
            className="inline-flex min-h-11 items-center font-bold text-brand-700 underline underline-offset-2 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-brand-300"
          >
            {t("kutuphaneLink")}
          </Link>
        </p>
      </div>
    </section>
  );
}
