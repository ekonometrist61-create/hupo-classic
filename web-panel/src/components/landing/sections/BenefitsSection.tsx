import { getTranslations } from "next-intl/server";
import Image from "next/image";

// Her fayda bir Hupo pozuyla ve kendi renk tonuyla anlatılır (düz ikon kutuları yerine).
// Sıra: kısa çalışma → açıklama → veli özeti.
const BENEFIT_ART = [
  { image: "hupo.dusunuyor", tone: "bg-brand-50", accent: "text-brand-600" },
  { image: "hupo.dogru", tone: "bg-gold-100", accent: "text-gold-900" },
  { image: "hupo.tamamlandi", tone: "bg-success-50", accent: "text-success-700" },
] as const;

export async function BenefitsSection() {
  const t = await getTranslations("landing");
  const g = await getTranslations("gorseller");
  const benefits = t.raw("benefits.items") as { title: string; desc: string }[];

  return (
    <section className="bg-white py-10 sm:py-14 dark:bg-gray-900">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <h2 className="mx-auto max-w-2xl text-balance text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
          {t("benefits.title")}
        </h2>

        <ul className="mt-12 grid gap-6 md:grid-cols-3">
          {benefits.map((item, i) => {
            const art = BENEFIT_ART[i];
            return (
              <li
                key={item.title}
                className="group flex flex-col overflow-hidden rounded-3xl border border-cream-dark bg-white p-3 shadow-sm transition-shadow duration-300 hover:shadow-xl motion-reduce:transition-none dark:border-gray-700 dark:bg-gray-800"
              >
                <div className={`flex h-48 items-center justify-center rounded-2xl ${art.tone} dark:bg-gray-900`}>
                  <Image
                    src={g(art.image)}
                    alt=""
                    width={200}
                    height={200}
                    className="h-40 w-auto object-contain transition-transform duration-300 group-hover:-translate-y-1 motion-reduce:transition-none"
                  />
                </div>

                <div className="flex flex-1 flex-col px-3 pb-4 pt-6">
                  <span className={`text-sm font-extrabold tracking-widest ${art.accent}`}>
                    0{i + 1}
                  </span>
                  <h3 className="mt-2 text-xl font-extrabold leading-snug">{item.title}</h3>
                  <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">{item.desc}</p>
                </div>
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}
