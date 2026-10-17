import CookiePreferencesButton from "@/components/analytics/CookiePreferencesButton";
import { legalDraftNotice, type LegalSection } from "@/lib/legal/content";
import { getTranslations } from "next-intl/server";
import Link from "next/link";

// Gizlilik ve kullanım koşulları sayfalarının ortak düzeni.
export default async function LegalDocument({
  title,
  updatedLabel,
  summary,
  sections,
}: {
  title: string;
  updatedLabel: string;
  summary?: string[];
  sections: LegalSection[];
}) {
  const t = await getTranslations("common");
  return (
    <main className="min-h-dvh bg-cream px-4 py-10 text-navy sm:px-6">
      <article className="mx-auto w-full max-w-3xl">
        <Link
          href="/"
          className="inline-flex min-h-11 items-center text-sm font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800"
        >
          {t("legalHome")}
        </Link>

        <p
          role="note"
          className="mt-6 rounded-xl border border-gold-500 bg-gold-100 px-4 py-3 text-sm font-semibold text-gold-900"
        >
          {legalDraftNotice}
        </p>

        <h1 className="mt-8 text-3xl font-extrabold tracking-tight">{title}</h1>
        <p className="mt-2 text-sm text-navy-muted">{updatedLabel}</p>

        {summary && summary.length > 0 && (
          <section
            aria-labelledby="legal-summary"
            className="mt-6 rounded-xl border border-navy/10 bg-cream-dark px-5 py-4"
          >
            <h2 id="legal-summary" className="text-lg font-bold">
              Kısaca
            </h2>
            <ul className="mt-3 list-disc space-y-2 ps-5 text-base leading-relaxed">
              {summary.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </section>
        )}

        <div className="mt-8 space-y-8">
          {sections.map((section) => (
            <section key={section.title}>
              <h2 className="text-xl font-bold">{section.title}</h2>
              <div className="mt-3 space-y-3 text-base leading-relaxed text-navy">
                {section.paragraphs.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
              </div>
            </section>
          ))}
        </div>

        <div className="mt-10 border-t border-navy/10 pt-6">
          <CookiePreferencesButton />
        </div>
      </article>
    </main>
  );
}
