import { marketingFont } from "@/components/landing/marketingFont";
import { KAYNAKLAR } from "@/components/landing/yontem/kaynaklar";
import { Link } from "@/i18n/navigation";
import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

// Yöntem ve araştırma kütüphanesi. Bayrak yok (kapıya bağlı değil). Landing Header/Footer kullanılmaz:
// onların menü ve alt bağlantıları ana sayfa çapalarıdır (#pricing vb.) ve bu rotada kırılır.
// Bu yüzden sade üst çubuk ve alt bilgi kullanılır; tüm bağlantılar gerçek rotadır.

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "yontem" });
  return { title: t("metaTitle"), description: t("metaDescription") };
}

type Adim = { baslik: string; metin: string };

export default async function YontemPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("yontem");
  const tl = await getTranslations("landing");
  const bilmedikleri = t.raw("bilmedikleri.ogeler") as string[];
  const adimlar = t.raw("surec.adimlar") as Adim[];

  return (
    <div className={`${marketingFont.className} min-h-dvh bg-cream text-navy`}>
      <header className="border-b border-cream-dark bg-cream">
        <div className="mx-auto flex h-16 max-w-3xl items-center justify-between gap-4 px-4 sm:px-6">
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

        <section aria-labelledby="bilmedikleri-baslik" className="mt-10 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6">
          <h2 id="bilmedikleri-baslik" className="text-2xl font-extrabold tracking-tight">
            {t("bilmedikleri.baslik")}
          </h2>
          <ul className="mt-3 list-disc space-y-2 ps-6 text-base leading-relaxed text-gray-800">
            {bilmedikleri.map((madde) => (
              <li key={madde}>{madde}</li>
            ))}
          </ul>
        </section>

        <section aria-labelledby="surec-baslik" className="mt-10">
          <h2 id="surec-baslik" className="text-2xl font-extrabold tracking-tight">
            {t("surec.baslik")}
          </h2>
          <ol className="mt-4 space-y-4">
            {adimlar.map((adim, i) => (
              <li key={adim.baslik} className="flex gap-4">
                <span
                  aria-hidden="true"
                  className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-brand-500 text-sm font-extrabold text-white"
                >
                  {i + 1}
                </span>
                <div>
                  <h3 className="text-lg font-extrabold">{adim.baslik}</h3>
                  <p className="mt-1 text-base leading-relaxed text-gray-800">{adim.metin}</p>
                </div>
              </li>
            ))}
          </ol>
          <p className="mt-6 rounded-2xl border border-gray-200 bg-white p-4 text-base leading-relaxed text-gray-800">
            {t("surec.uzman")}
          </p>
          <p className="mt-3 text-sm leading-relaxed text-gray-700">{t("surec.yapayZeka")}</p>
        </section>

        <section aria-labelledby="kutuphane-baslik" className="mt-10">
          <h2 id="kutuphane-baslik" className="text-2xl font-extrabold tracking-tight">
            {t("kutuphane.baslik")}
          </h2>
          <p className="mt-3 text-base leading-relaxed text-gray-700">{t("kutuphane.aciklama")}</p>
          <p className="mt-2 text-sm font-semibold leading-relaxed text-gray-700">{t("kutuphane.uyari")}</p>

          <ol className="mt-6 space-y-4">
            {KAYNAKLAR.map((kaynak, i) => (
              <li key={kaynak.id} className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <p className="text-base font-extrabold leading-snug">
                  {i + 1}. {kaynak.atif}
                </p>
                {kaynak.zayif ? (
                  <p className="mt-2 inline-flex rounded-full bg-gold-100 px-3 py-1 text-xs font-bold text-gold-900">
                    {t("kutuphane.zayif")}
                  </p>
                ) : null}
                <dl className="mt-3 space-y-3 text-base leading-relaxed text-gray-800">
                  <div>
                    <dt className="text-sm font-bold text-gray-600">{t("kutuphane.tasarim")}</dt>
                    <dd>{t(`kutuphane.items.${kaynak.id}.tasarim`)}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-bold text-gray-600">{t("kutuphane.bulgu")}</dt>
                    <dd>{t(`kutuphane.items.${kaynak.id}.bulgu`)}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-bold text-gray-600">{t("kutuphane.sinir")}</dt>
                    <dd>{t(`kutuphane.items.${kaynak.id}.sinir`)}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-bold text-gray-600">{t("kutuphane.kaynak")}</dt>
                    <dd>
                      <a
                        href={`https://doi.org/${kaynak.doi}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex min-h-11 items-center break-all font-semibold text-brand-700 underline underline-offset-2 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
                      >
                        https://doi.org/{kaynak.doi}
                      </a>
                    </dd>
                  </div>
                </dl>
              </li>
            ))}
          </ol>
          <p className="mt-6 text-sm font-semibold text-gray-700">{t("kutuphane.dipnot")}</p>
        </section>

        <div className="mt-10">
          <Link
            href="/demo"
            className="inline-flex min-h-12 items-center font-bold text-brand-700 underline underline-offset-2 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("cta")} →
          </Link>
        </div>
      </main>

      <footer className="border-t border-cream-dark py-6">
        <div className="mx-auto flex max-w-3xl flex-wrap gap-x-6 gap-y-1 px-4 text-sm text-gray-600 sm:px-6">
          <span className="inline-flex min-h-11 items-center">{tl("footer.copyright")}</span>
          <Link href="/gizlilik" className="inline-flex min-h-11 items-center underline">
            {tl("footer.privacy")}
          </Link>
          <Link href="/kosullar" className="inline-flex min-h-11 items-center underline">
            {tl("footer.terms")}
          </Link>
          <Link href="/ticari-ileti-izni" className="inline-flex min-h-11 items-center underline">
            {t("ticariIleti")}
          </Link>
        </div>
      </footer>
    </div>
  );
}
