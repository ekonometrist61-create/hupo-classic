import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { kaynakDoi } from "@/components/landing/yontem/kaynaklar";
import { Link } from "@/i18n/navigation";
import { getTranslations } from "next-intl/server";

// Kanıt paketi §3 (yayına hazır metin) uyarlaması. Rakamlar ve DOI'ler kaynaklardan birebir; Hupolingo sonucu değildir.
// Akademik bulgular ürün/inceleme şemasına (Product, Review, AggregateRating) konmaz; bu yüzden JSON-LD yoktur.
const KARTLAR = [
  { anahtar: "palikot", kaynakId: "palikot2026" },
  { anahtar: "kurnaz", kaynakId: "kurnaz2025" },
  { anahtar: "ruitenburg", kaynakId: "ruitenburg2026" },
] as const;

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
        <p className="mt-2 text-sm font-semibold text-navy-muted dark:text-gray-400">{t("hupoNot")}</p>

        <RevealGroup as="ul" className="mt-8 grid gap-6 md:grid-cols-3">
          {KARTLAR.map(({ anahtar, kaynakId }) => {
            const doi = kaynakDoi(kaynakId);
            if (!doi) return null;
            return (
              <li
                key={anahtar}
                className="flex flex-col rounded-2xl border border-cream-dark bg-white p-6 dark:border-gray-700 dark:bg-gray-800"
              >
                <p className="text-sm font-extrabold text-brand-700 dark:text-brand-300">
                  {t(`kartlar.${anahtar}.kaynak`)}
                </p>
                <p className="mt-1 text-sm text-navy-muted dark:text-gray-400">{t(`kartlar.${anahtar}.tur`)}</p>
                <p className="mt-4 flex-1 text-base leading-relaxed">{t(`kartlar.${anahtar}.sonuc`)}</p>
                <a
                  href={`https://doi.org/${doi}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="mt-5 inline-flex min-h-11 items-center font-bold text-brand-700 underline underline-offset-2 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 dark:text-brand-300"
                >
                  {t("arastirmayiIncele")}
                  <span className="sr-only">{t("yeniSekme")}</span>
                </a>
              </li>
            );
          })}
        </RevealGroup>

        <p className="mt-4 text-sm font-semibold text-navy-muted dark:text-gray-400">{t("dipnot")}</p>

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
