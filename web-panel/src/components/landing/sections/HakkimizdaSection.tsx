import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { Link } from "@/i18n/navigation";
import { getTranslations } from "next-intl/server";

// Kısa Hakkımızda: neden varız, Hupo kim, pilot notu ve /hakkimizda bağlantısı.
// Sayfanın tek birincil CTA'sı demo kalır; bu bağlantı ikincil (çerçeveli, sakin) tutulur.
// Görsel yok. Metin landing.hakkimizda anahtarında.
export async function HakkimizdaSection() {
  const t = await getTranslations("landing");

  return (
    <section aria-labelledby="hakkimizda-baslik" className="py-6 sm:py-8 lg:py-10">
      <Reveal className="mx-auto grid max-w-5xl items-start gap-6 px-4 sm:px-6 md:grid-cols-[1.4fr_1fr] md:gap-10 lg:px-8">
        <div>
          <p className="text-sm font-extrabold uppercase tracking-wider text-brand-700 dark:text-brand-300">
            {t("hakkimizda.eyebrow")}
          </p>
          <h2
            id="hakkimizda-baslik"
            className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl"
          >
            {t("hakkimizda.title")}
          </h2>
          <div className="mt-4 space-y-3 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            <p>{t("hakkimizda.p1")}</p>
            <p>{t("hakkimizda.p2")}</p>
          </div>
          <Link
            href="/hakkimizda"
            className="mt-6 inline-flex min-h-11 items-center gap-2 rounded-xl border border-brand-300 px-5 py-2.5 text-base font-bold text-brand-700 transition-colors duration-200 hover:bg-brand-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none dark:border-brand-700 dark:text-brand-200 dark:hover:bg-brand-900/30"
          >
            {t("hakkimizda.link")}
            <IconArrowRight className="h-5 w-5 rtl:rotate-180" />
          </Link>
        </div>

        <aside className="rounded-3xl border border-cream-dark bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800">
          <h3 className="text-xl font-extrabold leading-snug">{t("hakkimizda.hupoTitle")}</h3>
          <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">{t("hakkimizda.hupoText")}</p>
        </aside>
      </Reveal>
    </section>
  );
}
