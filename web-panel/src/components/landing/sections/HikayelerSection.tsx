import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { turEtiketi } from "@/lib/okuma/turler";
import { createClient } from "@/utils/supabase/server";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

// Hupolingo'nun hizmet verdiği sınıf aralığı (2026-11-12 kararı: tüm site ve içerik 3–7).
// Sayfa aralığı RPC'den değil buradan gösterir; RPC yalnız bu aralıktaki hikâyeleri sayar (20261219).
const HEDEF_SINIF_ALT = 3;
const HEDEF_SINIF_UST = 7;

interface SiteOzeti {
  hikaye_sayisi?: number;
  sinif_alt?: number;
  sinif_ust?: number;
  turler?: { tur: string; adet: number }[];
}

// "Senin Hikâyen": okuma dünyasının tanıtımı. Sayılar okuma_site_ozeti() RPC'sinden gelir, metne sabit sayı yazılmaz.
// Durum rozeti gerçek veriye bağlıdır: yayında hikâye varsa "Erken erişim", yoksa/okuma hata verirse "Yakında".
// Bölüm hiçbir durumda gizlenmez (tanıtım değeri var), ama hazır olmayan şey yayında gibi sunulmaz.
// Hikâye yarışması, MEB onayı veya sınav iddiası yoktur; yayın kararı editörün insan onayıdır (K-0239).
export async function HikayelerSection() {
  let ozet: SiteOzeti | null = null;
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("okuma_site_ozeti");
    if (!error && data) ozet = data as SiteOzeti;
  } catch {
    ozet = null;
  }
  const hazir = Boolean(ozet?.hikaye_sayisi && ozet.turler?.length);

  const t = await getTranslations("landing.hikayeler");
  const g = await getTranslations("gorseller");
  const adimlar = t.raw("adimlar") as { baslik: string; aciklama: string }[];

  return (
    <section id="hikayeler" className="scroll-mt-20 bg-cream py-12 dark:bg-gray-950 sm:py-16 lg:py-20">
      <div className="mx-auto grid max-w-6xl items-center gap-10 px-4 sm:px-6 lg:grid-cols-[1.15fr_0.85fr] lg:gap-14 lg:px-8">
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

          <ol className="mt-8 grid gap-4 sm:grid-cols-3">
            {adimlar.map((a, i) => (
              <li
                key={a.baslik}
                className="rounded-2xl border border-cream-dark bg-white p-4 shadow-sm dark:border-gray-700 dark:bg-gray-800"
              >
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-gold-500 text-sm font-extrabold text-navy">
                  {i + 1}
                </span>
                <h3 className="mt-3 text-lg font-extrabold leading-snug">{a.baslik}</h3>
                <p className="mt-2 text-sm leading-relaxed text-navy-muted dark:text-gray-300">{a.aciklama}</p>
              </li>
            ))}
          </ol>

          {hazir && ozet && (
            <>
              <p className="mt-8 text-xl font-extrabold text-navy dark:text-white">
                {t("sayi", { count: ozet.hikaye_sayisi ?? 0 })}
                <span className="font-bold text-navy/70 dark:text-gray-300">
                  {" · "}
                  {t("sinif", { alt: HEDEF_SINIF_ALT, ust: HEDEF_SINIF_UST })}
                </span>
              </p>
              <h3 className="sr-only">{t("turler")}</h3>
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
            </>
          )}

          <p className="mt-6 max-w-xl text-sm leading-relaxed text-navy/70 dark:text-gray-400">
            {hazir ? t("not") : t("notHazirlik")}
          </p>
          <p className="mt-2 max-w-xl text-sm leading-relaxed text-navy/70 dark:text-gray-400">{t("durumNotu")}</p>

          <div className="mt-6">
            <Link href="/veli-paneli/kayit" className={landingPrimaryBtn}>
              {t("cta")}
              <IconArrowRight className="h-5 w-5" />
            </Link>
          </div>
        </Reveal>

        <Reveal className="flex justify-center">
          <div className="flex w-full max-w-sm flex-col items-center rounded-3xl bg-gold-100 px-6 pb-6 pt-8 dark:bg-gray-900">
            <Image
              src={g("hupo.hosgeldin")}
              alt=""
              width={420}
              height={415}
              sizes="(min-width: 1024px) 240px, 200px"
              className="h-48 w-auto sm:h-56"
            />
            <p className="mt-4 text-center text-lg font-extrabold leading-snug text-navy dark:text-white">
              {t("kart")}
            </p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
