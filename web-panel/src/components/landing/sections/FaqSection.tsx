import { FaqAccordion } from "@/components/landing/LandingClient";
import { getTranslations } from "next-intl/server";

export async function FaqSection() {
  const t = await getTranslations("landing");
  const faqItems = (t.raw("faq.items") as { q: string; a: string }[]).map((i) => ({
    q: i.q,
    a: i.a,
  }));

  return (
    <section
      id="faq"
      className="scroll-mt-20 bg-white py-8 sm:py-12 dark:bg-gray-900"
    >
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
          {t("faq.title")}
        </h2>
        <div className="mt-10">
          <FaqAccordion items={faqItems} />
        </div>
      </div>
    </section>
  );
}

