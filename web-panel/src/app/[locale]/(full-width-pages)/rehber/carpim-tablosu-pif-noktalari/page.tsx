import CarpimRehberi from "@/components/landing/rehber/CarpimRehberi";
import { Link } from "@/i18n/navigation";
import { LEAD_MAGNET_ACIK } from "@/lib/lead-magnet";
import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";
import { notFound } from "next/navigation";

// Pilot 1 lead magnet. Bayrak (NEXT_PUBLIC_LEAD_MAGNET_ACIK) "true" değilse sayfa yoktur (404).
// Schema yalnız Article; akademik kaynaklar Product/Review şemasına konmaz.

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "landing.rehber" });
  return {
    title: t("metaTitle"),
    description: t("metaDescription"),
    robots: LEAD_MAGNET_ACIK ? { index: true, follow: true } : { index: false, follow: false },
  };
}

export default async function CarpimRehberPage({ params }: { params: Promise<{ locale: string }> }) {
  if (!LEAD_MAGNET_ACIK) notFound();

  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("landing.rehber");
  const tl = await getTranslations("landing");
  const ogeler = t.raw("alirsin.ogeler") as string[];
  const ipuclari = t.raw("onizleme.ipuclari") as { baslik: string; metin: string; ornek: string }[];

  const articleSchema = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: t("baslik"),
    description: t("metaDescription"),
    inLanguage: locale,
    author: { "@type": "Organization", name: "Hupolingo" },
    publisher: { "@type": "Organization", name: "Hupolingo" },
  };

  return (
    <div className="min-h-dvh bg-cream text-navy">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleSchema).replace(/</g, "\\u003c") }}
      />
      <header className="border-b border-cream-dark bg-cream">
        <div className="mx-auto flex h-16 max-w-3xl items-center justify-between px-4 sm:px-6">
          <Link href="/" className="inline-flex min-h-11 items-center text-xl font-extrabold tracking-tight">
            Hupolingo
          </Link>
          <Link
            href="/"
            className="inline-flex min-h-11 items-center text-sm font-semibold text-brand-700 underline-offset-2 hover:underline"
          >
            ← {t("geri")}
          </Link>
        </div>
      </header>

      <main id="main" className="mx-auto max-w-3xl px-4 pb-16 pt-8 sm:px-6">
        <p className="text-sm font-extrabold uppercase tracking-wider text-brand-700">{t("etiket")}</p>
        <h1 className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">{t("baslik")}</h1>
        <p className="mt-4 text-lg leading-relaxed text-gray-700">{t("giris")}</p>

        <section aria-labelledby="alirsin-baslik" className="mt-8 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6">
          <h2 id="alirsin-baslik" className="text-2xl font-extrabold tracking-tight">
            {t("alirsin.baslik")}
          </h2>
          <ul className="mt-3 list-disc space-y-1.5 ps-6 text-base leading-relaxed text-gray-800">
            {ogeler.map((o) => (
              <li key={o}>{o}</li>
            ))}
          </ul>
        </section>

        <section aria-labelledby="onizleme-baslik" className="mt-8">
          <h2 id="onizleme-baslik" className="text-2xl font-extrabold tracking-tight">
            {t("onizleme.baslik")}
          </h2>
          <p className="mt-2 text-base leading-relaxed text-gray-700">{t("onizleme.aciklama")}</p>
          <div className="mt-4 grid gap-4 sm:grid-cols-2">
            {ipuclari.map((i) => (
              <article key={i.baslik} className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <h3 className="text-lg font-extrabold">{i.baslik}</h3>
                <p className="mt-2 text-base leading-relaxed text-gray-800">{i.metin}</p>
                <p className="mt-3 rounded-lg bg-cream px-3 py-2 text-sm font-semibold text-brand-700">
                  {t("onizleme.ornek")}: {i.ornek}
                </p>
              </article>
            ))}
          </div>
        </section>

        <div className="mt-8">
          <CarpimRehberi />
        </div>
      </main>

      <footer className="border-t border-cream-dark py-6">
        <div className="mx-auto flex max-w-3xl flex-wrap gap-x-6 gap-y-1 px-4 text-sm text-gray-600 sm:px-6">
          <span className="inline-flex min-h-11 items-center">{tl("footer.copyright")}</span>
          <Link href="/gizlilik" className="inline-flex min-h-11 items-center underline">
            {tl("footer.privacy")}
          </Link>
          <Link href="/ticari-ileti-izni" className="inline-flex min-h-11 items-center underline">
            {t("ticariIleti")}
          </Link>
        </div>
      </footer>
    </div>
  );
}
