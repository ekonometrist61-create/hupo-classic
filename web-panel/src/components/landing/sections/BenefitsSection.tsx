import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { SplitText } from "@/components/landing/motion/SplitText";
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
        <div className="text-center">
          {/* Başlık kelime kelime belirir. py-2/-my-2: Türkçe harf işaretleri kırpılmasın, düzen değişmesin. */}
          <SplitText
            text={t("benefits.title")}
            tag="h2"
            textAlign="center"
            splitType="words"
            effect="rise"
            trigger="view"
            from={{ opacity: 0, y: 24 }}
            to={{ opacity: 1, y: 0 }}
            delay={70}
            duration={0.8}
            ease="hupo-out"
            className="max-w-2xl text-balance py-2 -my-2 text-3xl font-extrabold tracking-tight sm:text-4xl"
          />
          <noscript>
            <style>{".split-parent{visibility:visible!important}"}</style>
          </noscript>
        </div>

        <RevealGroup as="ul" className="mt-12 grid gap-6 md:grid-cols-3">
          {benefits.map((item, i) => {
            const art = BENEFIT_ART[i];
            return (
              <li
                key={item.title}
                className="group flex flex-col overflow-hidden rounded-3xl border border-cream-dark bg-white p-3 shadow-sm transition-shadow duration-300 ease-hupo-out hover:shadow-xl motion-reduce:transition-none dark:border-gray-700 dark:bg-gray-800"
              >
                <div className={`flex h-48 items-center justify-center rounded-2xl ${art.tone} dark:bg-gray-900`}>
                  <Image
                    src={g(art.image)}
                    alt=""
                    width={200}
                    height={200}
                    sizes="160px"
                    className="h-40 w-auto object-contain transition-transform duration-300 ease-hupo-out group-hover:-translate-y-1 motion-reduce:transition-none"
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
        </RevealGroup>
      </div>
    </section>
  );
}
