import { legalDraftNotice, type LegalSection } from "@/lib/legal/content";
import Link from "next/link";

// Gizlilik ve kullanım koşulları sayfalarının ortak düzeni.
export default function LegalDocument({
  title,
  updatedLabel,
  sections,
}: {
  title: string;
  updatedLabel: string;
  sections: LegalSection[];
}) {
  return (
    <main className="min-h-dvh bg-cream px-4 py-10 text-navy sm:px-6">
      <article className="mx-auto w-full max-w-3xl">
        <Link
          href="/"
          className="inline-flex min-h-11 items-center text-sm font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800"
        >
          Hupolingo ana sayfası
        </Link>

        <p
          role="note"
          className="mt-6 rounded-xl border border-gold-500 bg-gold-100 px-4 py-3 text-sm font-semibold text-gold-900"
        >
          {legalDraftNotice}
        </p>

        <h1 className="mt-8 text-3xl font-extrabold tracking-tight">{title}</h1>
        <p className="mt-2 text-sm text-navy-muted">{updatedLabel}</p>

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
      </article>
    </main>
  );
}
