import { IconArrowRight, IconCheckCircle } from "@/components/landing/Icons";
import { createClient } from "@/utils/supabase/server";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";

// Paket tipleri (kolonlar) ve paketler list_plan_tipleri RPC'sinden, deneme süresi get_deneme_ayari'ndan gelir.
// Admin'de tanımlanan her aktif tip bir kolon olur. Veri yoksa ilgili satır gizlenir.
interface AktifPaket {
  kod: string;
  ad: string;
  fiyat_kurus: number;
  sure_gun: number;
}

interface PlanTipi {
  kod: string;
  ad: string;
  ad_en: string | null;
  ozellikler: string[];
  ozellikler_en: string[];
  cta_metni: string;
  cta_en: string | null;
  vurgulu: boolean;
  planlar: AktifPaket[];
}

async function fetchPlanTipleri(): Promise<PlanTipi[]> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("list_plan_tipleri");
    if (error || !Array.isArray(data)) return [];
    return data as PlanTipi[];
  } catch {
    return [];
  }
}

async function fetchDenemeGun(): Promise<number | null> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("get_deneme_ayari");
    if (error || typeof data !== "number" || data <= 0) return null;
    return data;
  } catch {
    return null;
  }
}

const GRID_COLS: Record<number, string> = {
  1: "sm:grid-cols-1",
  2: "sm:grid-cols-2",
  3: "sm:grid-cols-3",
  4: "sm:grid-cols-4",
};

const kurusMetni = (kurus: number, locale: string) =>
  new Intl.NumberFormat(locale === "en" ? "en-US" : "tr-TR", { style: "currency", currency: "TRY" }).format(kurus / 100);

export async function PricingSection() {
  const t = await getTranslations("landing.pricing");
  const locale = await getLocale();
  const isEn = locale === "en";
  const trustBadges = t.raw("trustBadges") as string[];
  const [tipler, denemeGun] = await Promise.all([fetchPlanTipleri(), fetchDenemeGun()]);

  const gridCols = GRID_COLS[Math.min(Math.max(tipler.length, 1), 4)];

  return (
    <section id="pricing" className="scroll-mt-20 py-8 sm:py-12 lg:py-14">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
            {t("title")}
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            {t("desc")}
          </p>
          {denemeGun ? (
            <p className="mt-3 text-sm font-bold text-brand-700 dark:text-brand-300">
              {t("trialDays", { gun: denemeGun })}
            </p>
          ) : null}
        </div>

        <div className={`mt-12 grid gap-6 ${gridCols}`}>
          {tipler.map((tip) => {
            const isPopular = tip.vurgulu;
            const ad = isEn && tip.ad_en ? tip.ad_en : tip.ad;
            const features = isEn && tip.ozellikler_en.length > 0 ? tip.ozellikler_en : tip.ozellikler;
            const cta = isEn && tip.cta_en ? tip.cta_en : tip.cta_metni;
            return (
              <div
                key={tip.kod}
                className={`relative flex flex-col rounded-2xl border p-6 ${
                  isPopular
                    ? "border-brand-500 bg-brand-50 ring-2 ring-brand-500 dark:bg-brand-950/30"
                    : "border-cream-dark bg-white dark:border-gray-700 dark:bg-gray-800"
                }`}
              >
                {isPopular && (
                  <span className="absolute -top-3 start-1/2 -translate-x-1/2 whitespace-nowrap rounded-full bg-brand-500 px-4 py-1 text-xs font-extrabold text-white">
                    {t("premium.badge")}
                  </span>
                )}

                <p className="text-xl font-extrabold">{ad}</p>
                {tip.planlar.length > 0 && (
                  <ul className="mt-5 space-y-1">
                    {tip.planlar.map((p) => (
                      <li key={p.kod} className="text-lg font-extrabold">
                        {kurusMetni(p.fiyat_kurus, locale)}
                        <span className="ms-2 text-sm font-bold text-navy-muted dark:text-gray-400">
                          {t("sureGun", { gun: p.sure_gun })}
                        </span>
                      </li>
                    ))}
                  </ul>
                )}

                <ul className="mt-6 flex-1 space-y-3">
                  {features.map((feat) => (
                    <li key={feat} className="flex items-start gap-2 text-sm">
                      <IconCheckCircle className="mt-0.5 h-4 w-4 shrink-0 text-brand-500" />
                      <span>{feat}</span>
                    </li>
                  ))}
                </ul>

                <Link
                  href={tip.kod === "free" ? "/demo" : "/signup"}
                  className={`mt-8 inline-flex min-h-12 items-center justify-center gap-2 rounded-xl px-6 py-3 text-base font-bold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 motion-reduce:transition-none ${
                    isPopular
                      ? "bg-brand-500 text-white hover:bg-brand-600 focus-visible:outline-brand-500"
                      : "border-2 border-navy/15 bg-white text-navy hover:border-brand-500 hover:text-brand-600 focus-visible:outline-brand-500 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100"
                  }`}
                >
                  {cta}
                  <IconArrowRight className="h-5 w-5" />
                </Link>
              </div>
            );
          })}
        </div>

        <div className="mt-10 flex flex-wrap justify-center gap-x-8 gap-y-3">
          {trustBadges.map((badge) => (
            <p key={badge} className="flex items-center gap-2 text-sm text-navy-muted dark:text-gray-400">
              <IconCheckCircle className="h-4 w-4 shrink-0 text-brand-500" />
              {badge}
            </p>
          ))}
        </div>
      </div>
    </section>
  );
}
