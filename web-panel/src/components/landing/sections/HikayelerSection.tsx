import { landingPrimaryBtn } from "@/components/landing/buttons";
import { IconArrowRight } from "@/components/landing/Icons";
import { Reveal } from "@/components/landing/motion/Reveal";
import { RevealGroup } from "@/components/landing/motion/RevealGroup";
import { okumaSiteOzetiniAl } from "@/lib/okuma/site-ozeti";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import Link from "next/link";

// "Hikâyeler": uygulamadaki hikâye keşif ekranının örnek kompozisyonu (Bugünkü hikâye + tür kapakları).
// Kapaklar uygulamanın gerçek vitrin görselleridir (mobile-app/assets/okuma/vitrin); "Tarih ve kültür" kapağı
// ve "Bugünkü hikâye" küçük resmi hikâye sahne görselinden kırpıldı. Maskot/kuş kullanılmaz, sayı yazılmaz.
// Hikâye yayın kararı editörün insan onayıdır; yalnız yayındaki türler gösterilir (okuma_site_ozeti).
// Veri yoksa kompozisyon yine görünür, rozet "Yakında" olur.

type TurId = "gizem" | "uzay" | "macera" | "tarih";

const KAPAKLAR: { id: TurId; tur: string; src: string }[] = [
  { id: "gizem", tur: "gizem", src: "/landing/hikaye/tur-gizem.webp" },
  { id: "uzay", tur: "bilim_kurgu", src: "/landing/hikaye/tur-uzay.webp" },
  { id: "macera", tur: "macera", src: "/landing/hikaye/tur-macera.webp" },
  { id: "tarih", tur: "tarih_kultur", src: "/landing/hikaye/tur-tarih.webp" },
];

const ADIM_IKONLARI = ["/landing/ikon/ikon-konu.webp", "/landing/ikon/ikon-oku.webp", "/landing/ikon/ikon-ozet.webp"];

export async function HikayelerSection() {
  const ozet = await okumaSiteOzetiniAl();
  const hazir = Boolean(ozet?.hikaye_sayisi && ozet.turler?.length);

  // Veri varsa yalnız yayında hikâyesi olan türlerin kapağı çizilir; çift sayıda kalması için tek kalan atılır.
  let kapaklar = KAPAKLAR;
  if (hazir) {
    const yayinda = new Set(ozet?.turler?.map((x) => x.tur));
    kapaklar = KAPAKLAR.filter((k) => yayinda.has(k.tur));
    if (kapaklar.length % 2 === 1) kapaklar = kapaklar.slice(0, -1);
  }
  const erken = hazir && kapaklar.length >= 2;
  if (kapaklar.length < 2) kapaklar = KAPAKLAR;

  const t = await getTranslations("landing.hikayeler");
  const adimlar = t.raw("adimlar") as { baslik: string; aciklama: string }[];

  return (
    <section id="hikayeler" className="scroll-mt-20 overflow-hidden bg-cream py-6 dark:bg-gray-950 sm:py-8 lg:py-10">
      <div className="mx-auto grid max-w-6xl items-center gap-10 px-4 sm:px-6 lg:grid-cols-[1fr_0.9fr] lg:gap-14 lg:px-8">
        <Reveal>
          <div className="flex flex-wrap items-center gap-3">
            <p className="text-sm font-extrabold uppercase tracking-wider text-brand-600 dark:text-brand-300">
              {t("marka")}
            </p>
            <span className="rounded-full bg-warning-100 px-3 py-1 text-xs font-extrabold uppercase tracking-wide text-warning-700">
              {erken ? t("rozetErken") : t("rozetYakinda")}
            </span>
          </div>
          <h2 className="mt-3 text-balance text-3xl font-extrabold tracking-tight text-navy dark:text-white sm:text-4xl">
            {t("title")}
          </h2>
          <p className="mt-4 max-w-xl text-lg leading-relaxed text-navy/80 dark:text-gray-300">{t("desc")}</p>

          <ul className="mt-7 grid max-w-xl gap-3">
            {adimlar.map((a, i) => (
              <li
                key={a.baslik}
                className="flex items-start gap-4 rounded-2xl border border-cream-dark bg-white/80 p-3.5 dark:border-gray-700 dark:bg-gray-900"
              >
                <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-white ring-1 ring-gold-200 dark:ring-gray-600">
                  <Image src={ADIM_IKONLARI[i]} alt="" width={36} height={36} className="h-9 w-9" />
                </span>
                <div>
                  <h3 className="text-lg font-extrabold leading-snug">{a.baslik}</h3>
                  <p className="mt-1 text-sm leading-relaxed text-navy-muted dark:text-gray-300">{a.aciklama}</p>
                </div>
              </li>
            ))}
          </ul>

          <p className="mt-6 max-w-xl text-sm leading-relaxed text-navy/70 dark:text-gray-400">
            {erken ? t("not") : t("notHazirlik")}
          </p>

          <div className="mt-6">
            <Link href="/veli-paneli/kayit" className={landingPrimaryBtn}>
              {t("cta")}
              <IconArrowRight className="h-5 w-5" />
            </Link>
          </div>
        </Reveal>

        <Reveal className="flex justify-center">
          <figure className="w-full">
            <div role="img" aria-label={t("mockAlt")} className="relative isolate mx-auto w-full max-w-md">
              <div
                aria-hidden="true"
                className="absolute -inset-4 -z-10 rounded-[3rem] bg-gradient-to-br from-brand-200/70 via-gold-100/80 to-transparent blur-2xl dark:from-brand-800/40 dark:via-gold-900/20"
              />
              <div className="rounded-[2.5rem] bg-navy p-2 shadow-2xl shadow-navy/25 ring-1 ring-navy/10 dark:bg-gray-800 dark:ring-white/10">
                <div className="overflow-hidden rounded-[2rem] bg-cream dark:bg-gray-900">
                  <div className="flex justify-center pt-2.5">
                    <span className="h-1.5 w-14 rounded-full bg-navy/15 dark:bg-white/15" />
                  </div>

                  <div className="px-4 pb-5 pt-2">
                    <div className="flex items-center justify-between">
                      <p className="text-lg font-extrabold text-navy dark:text-white">{t("mock.baslik")}</p>
                      <Image src="/landing/ikon/ikon-hikayeler.webp" alt="" width={32} height={32} className="h-8 w-8 rounded-lg bg-cream" />
                    </div>

                    {/* Bugünkü hikâye */}
                    <div className="mt-3 rounded-3xl bg-brand-50 p-4 dark:bg-brand-900/40">
                      <div className="flex items-stretch gap-3">
                        <div className="min-w-0 flex-1">
                          <span className="inline-block rounded-full bg-white px-3 py-1 text-xs font-extrabold text-brand-700 dark:bg-gray-900 dark:text-brand-200">
                            {t("mock.bugun")}
                          </span>
                          <p className="mt-2.5 text-balance text-xl font-extrabold leading-tight text-navy dark:text-white">
                            {t("mock.bugunBaslik")}
                          </p>
                          <p className="mt-1.5 text-sm font-semibold text-navy-muted dark:text-gray-300">
                            {t("mock.bugunMeta")}
                          </p>
                        </div>
                        <Image
                          src="/landing/hikaye/bugun-kuledeki-son-isik.webp"
                          alt=""
                          width={360}
                          height={360}
                          sizes="112px"
                          className="h-24 w-24 shrink-0 rounded-2xl object-cover shadow-md ring-1 ring-navy/10 sm:h-28 sm:w-28 dark:ring-white/10"
                        />
                      </div>
                      <div className="mt-4 rounded-2xl bg-brand-500 px-4 py-3 text-center text-base font-extrabold text-white shadow-[0_4px_0_0_var(--color-brand-700)]">
                        {t("mock.basla")}
                      </div>
                    </div>

                    {/* Tür kapakları */}
                    <p className="mt-5 text-lg font-extrabold text-navy dark:text-white">{t("mock.kesfet")}</p>
                    <RevealGroup as="ul" className="mt-3 grid grid-cols-2 gap-x-3 gap-y-4">
                      {kapaklar.map((k) => (
                        <li key={k.id} className="min-w-0">
                          <div className="relative aspect-[4/5] overflow-hidden rounded-2xl bg-brand-100 shadow-sm ring-1 ring-navy/10 dark:bg-gray-800 dark:ring-white/10">
                            <Image
                              src={k.src}
                              alt=""
                              width={540}
                              height={720}
                              sizes="(min-width: 1024px) 200px, 45vw"
                              className="h-full w-full object-cover"
                            />
                          </div>
                          <p className="mt-2 text-sm font-extrabold leading-tight text-navy dark:text-gray-100">
                            {t(`mock.turler.${k.id}`)}
                          </p>
                        </li>
                      ))}
                    </RevealGroup>
                  </div>
                </div>
              </div>
            </div>
            <figcaption className="mt-5 text-center text-sm font-semibold text-navy-muted dark:text-gray-400">
              {t("mockNot")}
            </figcaption>
          </figure>
        </Reveal>
      </div>
    </section>
  );
}
