import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { okumaSiteOzetiniAl } from "@/lib/okuma/site-ozeti";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

const SINIFLAR = [3, 4, 5, 6, 7] as const;

const IKON = "/landing/ikon/ikon-";
const KARAKTER = "/landing/ikon/karakter-";

// Sol adımların ikonları (sıra adimlar ile aynı): kahraman, tür, ad, yol arkadaşı.
const ADIM_IKONLARI = [`${IKON}kahraman.webp`, `${IKON}konu.webp`, `${IKON}kalem.webp`, `${IKON}yol-arkadasi.webp`];

// Kahraman kartları (sıra mock.kahramanlar etiketleriyle aynı). Görseller uygulamanın karakter setidir;
// maskot/kuş yoktur. İlk kart ("Ben") seçili gösterilir.
const KAHRAMANLAR: { portreler: string[]; zemin: string }[] = [
  { portreler: [`${KARAKTER}ben-erkek.webp`, `${KARAKTER}ben-kiz.webp`], zemin: "bg-brand-100" },
  { portreler: [`${KARAKTER}anne.webp`], zemin: "bg-error-100" },
  { portreler: [`${KARAKTER}baba.webp`], zemin: "bg-blue-light-100" },
  { portreler: [`${KARAKTER}kardes.webp`], zemin: "bg-success-100" },
  { portreler: [`${KARAKTER}arkadas.webp`], zemin: "bg-gold-100" },
  { portreler: [`${KARAKTER}hayvan.webp`], zemin: "bg-orange-100" },
  { portreler: [`${KARAKTER}arac.webp`], zemin: "bg-brand-100" },
  { portreler: [`${KARAKTER}hayali.webp`], zemin: "bg-gold-100" },
  { portreler: [`${KARAKTER}baska.webp`], zemin: "bg-gray-100" },
];

const ROZET_NO =
  "flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-gold-500 text-xs font-extrabold text-navy";
const ETIKET = "text-sm font-extrabold text-navy dark:text-gray-100";
const KUTU = "rounded-2xl border-2 border-cream-dark bg-white dark:border-gray-700 dark:bg-gray-800";

// "Senin Hikâyen": çocuğun kahramanını seçtiği, adını yazdığı ve hikâyeyi kendi adıyla okuduğu deneyimin tanıtımı.
// Sağdaki kompozisyon uygulamanın kahraman akışına benzeyen örnek bir ekrandır (kurgu adlar); adımlar 1-4 ile eşleşir.
export async function SeninHikayenSection() {
  const ozet = await okumaSiteOzetiniAl();
  const hazir = Boolean(ozet?.hikaye_sayisi && ozet.turler?.length);

  const t = await getTranslations("landing.seninHikayen");
  const adimlar = t.raw("adimlar") as { baslik: string; aciklama: string }[];
  const kahramanlar = t.raw("mock.kahramanlar") as string[];
  const turler = t.raw("mock.turler") as string[];

  return (
    <section
      id="senin-hikayen"
      className="scroll-mt-20 overflow-hidden bg-white py-6 dark:bg-gray-900 sm:py-8 lg:py-10"
    >
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
                className="flex items-start gap-4 rounded-2xl border border-cream-dark bg-cream p-4 dark:border-gray-700 dark:bg-gray-800"
              >
                <span className="relative flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-white ring-1 ring-cream-dark dark:ring-gray-600">
                  <Image src={ADIM_IKONLARI[i]} alt="" width={36} height={36} className="h-9 w-9" />
                  <span className="absolute -bottom-2 -end-2 flex h-6 w-6 items-center justify-center rounded-full bg-gold-500 text-xs font-extrabold text-navy ring-2 ring-cream dark:ring-gray-800">
                    {i + 1}
                  </span>
                </span>
                <div>
                  <h3 className="text-lg font-extrabold leading-snug">{a.baslik}</h3>
                  <p className="mt-1 text-sm leading-relaxed text-navy-muted dark:text-gray-300">{a.aciklama}</p>
                </div>
              </li>
            ))}
          </ol>

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
            <div role="img" aria-label={t("mockAlt")} className="relative isolate mx-auto w-full max-w-md">
              <div
                aria-hidden="true"
                className="absolute -inset-4 -z-10 rounded-[3rem] bg-gradient-to-br from-gold-100/90 via-brand-100/70 to-transparent blur-2xl dark:from-gold-900/25 dark:via-brand-800/30"
              />
              <div className="rounded-[2.5rem] bg-navy p-2 shadow-2xl shadow-navy/25 ring-1 ring-navy/10 dark:bg-gray-700 dark:ring-white/10">
                <div className="overflow-hidden rounded-[2rem] bg-cream dark:bg-gray-900">
                  <div className="flex justify-center pt-2.5">
                    <span className="h-1.5 w-14 rounded-full bg-navy/15 dark:bg-white/15" />
                  </div>

                  <div className="px-4 pb-5 pt-2">
                    <p className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
                      {t("mock.baslik")}
                    </p>
                    <p className="mt-1 text-2xl font-extrabold leading-tight text-navy dark:text-white">
                      {t("mock.soru")}
                    </p>

                    {/* 1 · Kahraman */}
                    <div className="mt-4 flex items-center gap-2">
                      <span className={ROZET_NO}>1</span>
                      <p className={ETIKET}>{t("mock.kahramanEtiket")}</p>
                    </div>
                    <ul className="mt-2.5 grid grid-cols-3 gap-2">
                      {KAHRAMANLAR.map((k, i) => {
                        const secili = i === 0;
                        return (
                          <li
                            key={kahramanlar[i]}
                            className={`relative flex min-w-0 flex-col items-center gap-1.5 rounded-2xl px-1 pb-2 pt-2.5 text-center ${
                              secili
                                ? "border-[3px] border-brand-500 bg-white shadow-md ring-4 ring-brand-500/15 dark:bg-gray-800"
                                : "border-2 border-cream-dark bg-white dark:border-gray-700 dark:bg-gray-800"
                            }`}
                          >
                            {secili ? (
                              <Image
                                src={`${IKON}onay.webp`}
                                alt=""
                                width={24}
                                height={24}
                                className="absolute -end-2 -top-2 h-6 w-6 rounded-full ring-2 ring-white dark:ring-gray-800"
                              />
                            ) : null}
                            <span className="flex h-14 items-center -space-x-3 rtl:space-x-reverse">
                              {k.portreler.map((src) => (
                                <span
                                  key={src}
                                  className={`block overflow-hidden rounded-full ring-2 ring-white dark:ring-gray-800 ${k.zemin} ${
                                    k.portreler.length > 1 ? "h-10 w-10" : "h-14 w-14"
                                  }`}
                                >
                                  <Image src={src} alt="" width={96} height={96} className="h-full w-full object-cover" />
                                </span>
                              ))}
                            </span>
                            <span
                              className={`w-full truncate text-xs font-extrabold ${
                                secili ? "text-brand-700 dark:text-brand-200" : "text-navy dark:text-gray-100"
                              }`}
                            >
                              {kahramanlar[i]}
                            </span>
                          </li>
                        );
                      })}
                    </ul>

                    {/* 2 · Tür */}
                    <div className="mt-5 flex items-center gap-2">
                      <span className={ROZET_NO}>2</span>
                      <p className={ETIKET}>{t("mock.turEtiket")}</p>
                    </div>
                    <ul className="mt-2.5 flex flex-wrap gap-2">
                      {turler.map((tur, i) => (
                        <li
                          key={tur}
                          className={`rounded-full px-4 py-2 text-sm font-extrabold ${
                            i === 0
                              ? "bg-brand-500 text-white shadow-[0_3px_0_0_var(--color-brand-700)]"
                              : "border-2 border-cream-dark bg-white text-navy dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100"
                          }`}
                        >
                          {tur}
                        </li>
                      ))}
                    </ul>

                    {/* 3 · Ad */}
                    <div className="mt-5 flex items-center gap-2">
                      <span className={ROZET_NO}>3</span>
                      <p className={ETIKET}>{t("mock.adEtiket")}</p>
                    </div>
                    <div className="mt-2.5 flex items-center justify-between gap-3 rounded-2xl border-2 border-navy-muted/70 bg-white px-4 py-3 dark:border-gray-500 dark:bg-gray-800">
                      <span className="flex items-center text-lg font-bold text-navy dark:text-white">
                        {t("mock.ad")}
                        <span className="ms-0.5 inline-block h-5 w-0.5 rounded-full bg-brand-500 motion-safe:animate-pulse" />
                      </span>
                      <span className="shrink-0 rounded-full bg-gold-100 px-2.5 py-1 text-xs font-extrabold text-gold-900 dark:bg-gold-900/40 dark:text-gold-200">
                        {t("mock.oneri")}
                      </span>
                    </div>

                    {/* 4 · Yol arkadaşı */}
                    <div className={`mt-5 p-3 shadow-[0_3px_0_0_var(--color-cream-dark)] dark:shadow-none ${KUTU}`}>
                      <div className="flex items-center justify-between gap-3">
                        <div className="flex min-w-0 items-center gap-2">
                          <span className={ROZET_NO}>4</span>
                          <p className="text-sm font-extrabold leading-snug text-navy dark:text-gray-100">
                            {t("mock.yoldasEtiket")}
                          </p>
                        </div>
                        <span className="relative h-7 w-12 shrink-0 rounded-full bg-brand-500">
                          <span className="absolute end-1 top-1 h-5 w-5 rounded-full bg-white shadow" />
                        </span>
                      </div>
                      <div className="relative mt-4 flex items-center gap-3 rounded-xl border-2 border-brand-500 px-3 py-2.5">
                        <span className="absolute -top-2.5 start-3 bg-white px-1 text-[11px] font-bold leading-none text-brand-600 dark:bg-gray-800 dark:text-brand-300">
                          {t("mock.yoldasAdEtiket")}
                        </span>
                        <span className="block h-9 w-9 shrink-0 overflow-hidden rounded-full bg-gold-100">
                          <Image
                            src={`${KARAKTER}yoldas.webp`}
                            alt=""
                            width={72}
                            height={72}
                            className="h-full w-full object-cover"
                          />
                        </span>
                        <span className="text-base font-extrabold text-navy dark:text-white">{t("mock.yoldasAd")}</span>
                      </div>
                    </div>

                    <div className="mt-5 flex items-center justify-center gap-2 rounded-2xl bg-brand-500 px-4 py-3.5 text-base font-extrabold text-white shadow-[0_4px_0_0_var(--color-brand-700)]">
                      {t("mock.cta")}
                      <IconArrowRight className="h-5 w-5 rtl:rotate-180" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </figure>
        </Reveal>
      </div>
    </section>
  );
}
