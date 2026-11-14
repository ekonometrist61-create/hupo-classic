import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { getTranslations } from "next-intl/server";

// Üç farklılaştırıcı: oynayarak öğrenme, takip ve yer bilme, proje okullarına hazırlık desteği.
// Görsel yok, yalnızca numara. Metin landing.farkimiz anahtarında; sayı, garanti veya sosyal kanıt içermez.
const TONES = [
  { badge: "bg-brand-50 text-brand-700 dark:bg-brand-900/30 dark:text-brand-200" },
  { badge: "bg-gold-100 text-gold-900 dark:bg-gold-900/30 dark:text-gold-200" },
  { badge: "bg-success-50 text-success-700 dark:bg-success-900/30 dark:text-success-200" },
] as const;

export async function FarkSection() {
  const t = await getTranslations("landing");
  const items = t.raw("farkimiz.items") as { title: string; desc: string }[];

  return (
    <section aria-labelledby="farkimiz-baslik" className="py-6 sm:py-8 lg:py-10">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <h2
          id="farkimiz-baslik"
          className="mx-auto max-w-2xl text-balance text-center text-3xl font-extrabold tracking-tight sm:text-4xl"
        >
          {t("farkimiz.title")}
        </h2>

        <RevealGroup as="ol" className="mt-8 grid gap-4 md:grid-cols-3 md:gap-6">
          {items.map((item, i) => (
            <li
              key={item.title}
              className="flex flex-col rounded-3xl border border-cream-dark bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800"
            >
              <span
                aria-hidden="true"
                className={`inline-flex h-10 w-10 items-center justify-center rounded-full text-base font-extrabold ${TONES[i % TONES.length].badge}`}
              >
                {i + 1}
              </span>
              <h3 className="mt-4 text-balance text-xl font-extrabold leading-snug">{item.title}</h3>
              <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">{item.desc}</p>
            </li>
          ))}
        </RevealGroup>
      </div>
    </section>
  );
}
