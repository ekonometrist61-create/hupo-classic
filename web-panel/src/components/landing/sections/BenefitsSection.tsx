import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { getTranslations } from "next-intl/server";
import Image from "next/image";

// Her fayda uygulamanın gerçek ekranıyla ve kendi renk tonuyla anlatılır (maskot/illüstrasyon kullanılmaz).
// Sıra: kısa çalışma (soru ekranı) → açıklama (cevap sonrası) → veli özeti (veli raporu).
// Görseller test hesaplarıyla alınmış gerçek ekranlardır; kırpma yalnız durum çubuğu ve alt gezinmeyi dışarıda bırakır.
const BENEFIT_ART = [
  { src: "/landing/ekran/soru.webp", tone: "bg-brand-50", accent: "text-brand-600" },
  { src: "/landing/ekran/aciklama.webp", tone: "bg-gold-100", accent: "text-gold-900" },
  { src: "/landing/ekran/veli-raporu.webp", tone: "bg-success-50", accent: "text-success-700" },
] as const;

type BenefitItem = { title: string; desc: string; gorselAlt?: string };

export async function BenefitsSection() {
  const t = await getTranslations("landing");
  const benefits = t.raw("benefits.items") as BenefitItem[];

  return (
    <section className="bg-white py-6 sm:py-8 lg:py-10 dark:bg-gray-900">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          {/* Düz başlık: SplitText hidrasyona kadar başlığı gizliyordu (hız ölçümü GÖR-086, K-0201). */}
          <h2 className="mx-auto max-w-2xl text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
            {t("benefits.title")}
          </h2>
        </div>

        <RevealGroup as="ul" className="mt-12 grid gap-6 md:grid-cols-3">
          {benefits.map((item, i) => {
            const art = BENEFIT_ART[i];
            return (
              <li
                key={item.title}
                className="group flex flex-col overflow-hidden rounded-3xl border border-cream-dark bg-white p-3 shadow-sm transition-shadow duration-300 ease-hupo-out hover:shadow-xl motion-reduce:transition-none dark:border-gray-700 dark:bg-gray-800"
              >
                {/* Sabit yükseklikli çerçeve: ekran görüntüsü kırpılmadan, oranı bozulmadan sığar; yatay taşma olmaz. */}
                <div
                  className={`flex h-72 items-center justify-center overflow-hidden rounded-2xl p-4 sm:h-80 ${art.tone} dark:bg-gray-900`}
                >
                  <Image
                    src={art.src}
                    alt={item.gorselAlt ?? ""}
                    width={540}
                    height={900}
                    sizes="(min-width: 768px) 200px, 220px"
                    className="h-auto max-h-full w-auto max-w-full rounded-xl bg-white shadow-lg ring-1 ring-navy/10 transition-transform duration-300 ease-hupo-out group-hover:-translate-y-1 motion-reduce:transition-none dark:ring-white/10"
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
