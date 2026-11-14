import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { okumaSiteOzetiniAl } from "@/lib/okuma/site-ozeti";
import { turEtiketi } from "@/lib/okuma/turler";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

// "Onlarca Hikâye": yayındaki hikâyelerin kütüphane özeti. Sayılar RPC'den gelir, metne sabit sayı yazılmaz.
// Hikâye yayın kararı editörün insan onayıdır; bölüm yalnız yayında olanı sayar.
export async function HikayelerSection() {
  const ozet = await okumaSiteOzetiniAl();
  const hazir = Boolean(ozet?.hikaye_sayisi && ozet.turler?.length);

  const t = await getTranslations("landing.hikayeler");

  return (
    <section id="hikayeler" className="scroll-mt-20 bg-cream py-6 dark:bg-gray-950 sm:py-8 lg:py-10">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
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
          <p className="mt-4 max-w-2xl text-lg leading-relaxed text-navy/80 dark:text-gray-300">{t("desc")}</p>

          {hazir && ozet ? (
            <>
              <h3 className="mt-8 text-xl font-extrabold text-navy dark:text-white">{t("turler")}</h3>
              <ul className="mt-3 flex flex-wrap gap-2">
                {ozet.turler?.map((x) => (
                  <li
                    key={x.tur}
                    className="rounded-full border border-navy/15 bg-white px-4 py-1.5 text-sm font-bold text-navy dark:border-white/15 dark:bg-gray-900 dark:text-gray-100"
                  >
                    {turEtiketi(x.tur)}
                  </li>
                ))}
              </ul>
              <div className="mt-8 grid gap-4 sm:grid-cols-2">
                <figure>
                  <Image
                    src="/landing/ekran/hikaye-tur.webp"
                    alt={t("ekranTurAlt")}
                    width={540}
                    height={1170}
                    sizes="(min-width: 640px) 260px, 60vw"
                    className="h-auto w-full rounded-2xl border border-navy/10 shadow-sm"
                  />
                </figure>
                <figure>
                  <Image
                    src="/landing/ekran/hikaye-kesfet.webp"
                    alt={t("ekranKesfetAlt")}
                    width={540}
                    height={1170}
                    sizes="(min-width: 640px) 260px, 60vw"
                    className="h-auto w-full rounded-2xl border border-navy/10 shadow-sm"
                  />
                </figure>
              </div>
            </>
          ) : (
            <p className="mt-8 max-w-2xl text-base leading-relaxed text-navy/70 dark:text-gray-400">
              {t("notHazirlik")}
            </p>
          )}

          <p className="mt-6 max-w-2xl text-sm leading-relaxed text-navy/70 dark:text-gray-400">{t("not")}</p>

          <div className="mt-6">
            <Link href="/veli-paneli/kayit" className={landingPrimaryBtn}>
              {t("cta")}
              <IconArrowRight className="h-5 w-5" />
            </Link>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
