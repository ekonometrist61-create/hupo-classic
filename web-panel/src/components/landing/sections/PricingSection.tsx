import { IconArrowRight, IconCheckCircle } from "@/components/landing/Icons";
import { createClient } from "@/utils/supabase/server";
import { getTranslations } from "next-intl/server";
import Link from "next/link";

interface DbPlan {
  id: string;
  name: string;
  price_monthly: number | null;
  currency: string;
}

async function fetchPlans(): Promise<DbPlan[]> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase
      .from("plans")
      .select("id, name, price_monthly, currency")
      .order("price_monthly", { ascending: true, nullsFirst: true });
    if (error || !data || data.length === 0) return [];
    return data as DbPlan[];
  } catch {
    return [];
  }
}

export async function PricingSection() {
  const t = await getTranslations("landing.pricing");
  const tierKeys = ["free", "premium", "family"] as const;
  const trustBadges = t.raw("trustBadges") as string[];

  const dbPlans = await fetchPlans();

  function getPriceDisplay(key: string): string {
    if (key === "free") return t("free.priceLabel");
    const plan = dbPlans.find(
      (p) => p.name.toLowerCase().includes(key) || p.id.toLowerCase().includes(key)
    );
    if (!plan || plan.price_monthly == null) return t("comingSoon");
    return `${plan.price_monthly} ${plan.currency ?? "â‚º"}${t("perMonth")}`;
  }

  return (
    <section id="pricing" className="scroll-mt-20 py-8 sm:py-12 lg:py-14">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Başlık */}
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
            {t("title")}
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            {t("desc")}
          </p>
        </div>

        {/* Plan kartları */}
        <div className="mt-12 grid gap-6 sm:grid-cols-3">
          {tierKeys.map((key) => {
            const isPopular = key === "premium";
            const features = t.raw(`${key}.features`) as string[];
            return (
              <div
                key={key}
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

                <p className="text-xl font-extrabold">{t(`${key}.name`)}</p>
                <p className="mt-5 text-3xl font-extrabold">{getPriceDisplay(key)}</p>

                <ul className="mt-6 flex-1 space-y-3">
                  {features.map((feat) => (
                    <li key={feat} className="flex items-start gap-2 text-sm">
                      <IconCheckCircle className="mt-0.5 h-4 w-4 shrink-0 text-brand-500" />
                      <span>{feat}</span>
                    </li>
                  ))}
                </ul>

                <Link
                  href={key === "free" ? "/demo" : "/signup"}
                  className={`mt-8 inline-flex min-h-12 items-center justify-center gap-2 rounded-xl px-6 py-3 text-base font-bold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 motion-reduce:transition-none ${
                    isPopular
                      ? "bg-brand-500 text-white hover:bg-brand-600 focus-visible:outline-brand-500"
                      : "border-2 border-navy/15 bg-white text-navy hover:border-brand-500 hover:text-brand-600 focus-visible:outline-brand-500 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-100"
                  }`}
                >
                  {t(`${key}.cta`)}
                  <IconArrowRight className="h-5 w-5" />
                </Link>
              </div>
            );
          })}
        </div>

        {/* Güven rozetleri */}
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

