import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { okumaSiteOzetiniAl } from "@/lib/okuma/site-ozeti";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

const SINIFLAR = [3, 4, 5, 6, 7] as const;

// Gerçek uygulama ekranları: kahraman seçimi, kahramanın adı, yol arkadaşı (sırası ekranAlt ile aynı).
const EKRANLAR = [
  { src: "/landing/ekran/kahraman-sec.webp" },
  { src: "/landing/ekran/kahraman-ad.webp" },
  { src: "/landing/ekran/yol-arkadasi.webp" },
] as const;

// "Senin Hikâyen": çocuğun kahramanını seçtiği, adını yazdığı ve hikâyeyi kendi adıyla okuduğu deneyimin tanıtımı.
// Görsel gerçek uygulama ekranıdır (Öğren sekmesi); dekoratif maskot kullanılmaz.
export async function SeninHikayenSection() {
  const ozet = await okumaSiteOzetiniAl();
  const hazir = Boolean(ozet?.hikaye_sayisi && ozet.turler?.length);

  const t = await getTranslations("landing.seninHikayen");
  const adimlar = t.raw("adimlar") as { baslik: string; aciklama: string }[];
  const ekranAlt = t.raw("ekranAlt") as string[];

  return (
    <section id="senin-hikayen" className="scroll-mt-20 bg-white py-6 dark:bg-gray-900 sm:py-8 lg:py-10">
      <div className="mx-auto grid max-w-6xl items-center gap-10 px-4 sm:px-6 lg:grid-cols-[1.1fr_0.9fr] lg:gap-14 lg:px-8">
        <Reveal>
          <div className="flex flex-wrap items-center gap-3">
            <p className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
              {t("marka")}
            </p>
            <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold uppercase tracking-wide text-warning-700">
              {hazir ? t("rozetErken") : t("rozetYakinda")}
            </span>
          </div>
          <h2 className="mt-3 text-balance text-3xl font-extrabold tracking-tight text-navy dark:text-white sm:text-4xl">
            {t("title")}
          </h2>
          <p className="mt-4 max-w-xl text-lg leading-relaxed text-navy/80 dark:text-gray-300">{t("desc")}</p>

          <ol className="mt-8 grid gap-4">
            {adimlar.map((a, i) => (
              <li
                key={a.baslik}
                className="flex gap-4 rounded-2xl border border-cream-dark bg-cream p-4 dark:border-gray-700 dark:bg-gray-800"
              >
                <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gold-500 text-sm font-extrabold text-navy">
                  {i + 1}
                </span>
                <div>
                  <h3 className="text-lg font-extrabold leading-snug">{a.baslik}</h3>
                  <p className="mt-1 text-sm leading-relaxed text-navy-muted dark:text-gray-300">{a.aciklama}</p>
                </div>
              </li>
            ))}
          </ol>

          <p className="mt-6 max-w-xl text-sm leading-relaxed text-navy/70 dark:text-gray-400">{t("not")}</p>

          <div className="mt-6">
            <Link href="/veli-paneli/kayit" className={landingPrimaryBtn}>
              {t("cta")}
              <IconArrowRight className="h-5 w-5" />
            </Link>
          </div>

          <div className="mt-8">
            <p className="text-sm font-extrabold uppercase tracking-wider text-navy-muted dark:text-gray-300">
              {t("sinifEtiket")}
            </p>
            <ul className="mt-2 flex flex-wrap gap-2">
              {SINIFLAR.map((n) => (
                <li key={n}>
                  <Link
                    href={`/hikaye-demo?sinif=${n}`}
                    aria-label={t("sinifBaglanti", { sinif: n })}
                    className="inline-flex h-12 min-w-12 items-center justify-center rounded-xl border-2 border-navy/15 bg-white px-4 text-lg font-extrabold text-navy transition-colors hover:border-brand-500 hover:text-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 motion-reduce:transition-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100"
                  >
                    {n}
                  </Link>
                </li>
              ))}
            </ul>
            <Link
              href="/hikaye-demo"
              className="mt-4 inline-flex min-h-11 items-center font-bold text-brand-700 underline underline-offset-2 hover:text-brand-600 dark:text-brand-300"
            >
              {t("demoCta")}
              <IconArrowRight className="ms-2 h-4 w-4" />
            </Link>
          </div>
        </Reveal>

        <Reveal className="flex justify-center">
          <figure className="w-full">
            <ul className="grid grid-cols-3 gap-3">
              {EKRANLAR.map((e, i) => (
                <li key={e.src}>
                  <Image
                    src={e.src}
                    alt={ekranAlt[i]}
                    width={540}
                    height={1170}
                    sizes="(min-width: 1024px) 150px, 30vw"
                    className="h-auto w-full rounded-2xl border border-navy/10 shadow-md"
                  />
                </li>
              ))}
            </ul>
            <figcaption className="mt-4 text-center text-sm font-semibold text-navy-muted dark:text-gray-400">
              {t("gorselAltyazi")}
            </figcaption>
          </figure>
        </Reveal>
      </div>
    </section>
  );
}
