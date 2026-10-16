import { IconArrowRight } from "@/components/landing/Icons";
import { TrackedLink } from "@/components/analytics/TrackedLink";
import { getTranslations } from "next-intl/server";
import Image from "next/image";

const primaryBtn =
  "inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-brand-500 px-6 py-3 text-base font-bold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none";

// Sayfanın tek CTA'sı: hero ile aynı hedef (örnek sorular).
export async function FinalCtaSection() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");

  return (
    <section className="bg-gold-100 py-8 sm:py-12 dark:bg-gold-900/30">
      <div className="mx-auto flex max-w-4xl flex-col items-center gap-8 px-4 text-center sm:px-6 md:flex-row md:text-start lg:px-8">
        <Image
          src={g("hupo.tamamlandi")}
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
          <div className="mt-6 flex md:justify-start">
            <TrackedLink href="/demo" olay="hero_cta_tiklandi" ozellik={{ konum: "son" }} className={primaryBtn}>
              {t("cta.primary")}
              <IconArrowRight className="h-5 w-5" />
            </TrackedLink>
          </div>
        </div>
      </div>
    </section>
  );
}
