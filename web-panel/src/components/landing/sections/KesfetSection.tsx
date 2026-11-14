import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { getTranslations } from "next-intl/server";
import Image from "next/image";

// Çarpım Şifreleri, Kelime Evreni ve Arena: çalışmanın içindeki keşif alanları.
// Konumlandırma (ajan önerisi, kullanıcı onayı bekliyor): "Senin Hikâyen" değer çıpasıdır (veli neyle karşılaştıracağını görür),
// bu üç alan ise çocuğun kendi isteğiyle açtığı merak alanlarıdır. Pazarlama metninde bu terimler geçmez.
// Görseller uygulamanın gerçek ekranlarıdır (maskot/illüstrasyon değil); kırpma yalnız durum çubuğu ve alt gezinmeyi dışarıda bırakır.
// Durum rozetleri koddaki/belgedeki gerçek duruma bağlıdır (K-0215, GÖR-091, arena_screen.dart); hazır olmayan "Yakında" yazar.
// Çocuğa satış, ödül baskısı, süre dayatması yok; metrik öğrenmedir (XP/sıra değil).
const KARTLAR = [
  { key: "carpim", image: "/landing/ekran/carpim.webp", h: 1004, durum: "erken" },
  { key: "kelime", image: "/landing/ekran/kelime.webp", h: 498, durum: "yakinda" },
  { key: "arena", image: "/landing/ekran/arena.webp", h: 845, durum: "erken" },
] as const;

export async function KesfetSection() {
  const t = await getTranslations("landing.kesfet");

  return (
    <section id="kesfet" className="scroll-mt-20 bg-white py-6 dark:bg-gray-900 sm:py-8 lg:py-10">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
            {t("eyebrow")}
          </p>
          <h2 className="mt-2 text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">{t("title")}</h2>
          <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">{t("desc")}</p>
        </div>

        <RevealGroup as="ul" className="mt-10 grid gap-6 md:grid-cols-3">
          {KARTLAR.map((k) => (
            <li
              key={k.key}
              className="flex flex-col overflow-hidden rounded-3xl border border-cream-dark bg-white p-3 shadow-sm dark:border-gray-700 dark:bg-gray-800"
            >
              <div className="relative h-72 overflow-hidden rounded-2xl border border-cream-dark bg-cream dark:border-gray-700 dark:bg-gray-900 sm:h-80">
                <Image
                  src={k.image}
                  alt={t(`${k.key}.alt`)}
                  width={540}
                  height={k.h}
                  sizes="(min-width: 768px) 340px, 90vw"
                  className="h-full w-full object-cover object-top"
                />
              </div>
              <div className="flex flex-1 flex-col px-3 pb-4 pt-5">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <h3 className="text-xl font-extrabold leading-snug">{t(`${k.key}.ad`)}</h3>
                  <span
                    className={`rounded-full px-3 py-1 text-xs font-extrabold uppercase tracking-wide ${
                      k.durum === "erken"
                        ? "bg-brand-50 text-brand-700 dark:bg-brand-900/40 dark:text-brand-200"
                        : "bg-warning-100 text-warning-700"
                    }`}
                  >
                    {t(k.durum === "erken" ? "rozetErken" : "rozetYakinda")}
                  </span>
                </div>
                <p className="mt-3 leading-relaxed text-navy-muted dark:text-gray-300">{t(`${k.key}.desc`)}</p>
              </div>
            </li>
          ))}
        </RevealGroup>

        <p className="mx-auto mt-8 max-w-2xl text-center text-sm leading-relaxed text-navy-muted dark:text-gray-400">
          {t("durumNotu")}
        </p>
      </div>
    </section>
  );
}
