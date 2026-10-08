import {
  IconBook,
  IconChart,
  IconCheckCircle,
  IconHeart,
  IconShield,
  IconStar,
  IconTimer,
  IconTrophy,
} from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import type { ComponentType, SVGProps } from "react";

type Icon = ComponentType<SVGProps<SVGSVGElement>>;
const ICONS: Icon[] = [IconStar, IconTrophy, IconChart, IconBook, IconShield, IconTimer];

export async function WhyParentsSection() {
  const t = await getTranslations("landing.whyParents");
  const items = t.raw("items") as { title: string; desc: string }[];

  return (
    <section
      id="why-parents"
      className="scroll-mt-20 bg-white py-8 sm:py-12 lg:py-14 dark:bg-gray-900"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-balance text-3xl font-extrabold tracking-tight sm:text-4xl">
            {t("title")}
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-navy-muted dark:text-gray-300">
            {t("desc")}
          </p>
        </div>

        <ul className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((item, i) => {
            const Icon = ICONS[i] ?? IconCheckCircle;
            return (
              <li
                key={item.title}
                className="flex gap-4 rounded-2xl border border-cream-dark bg-cream p-6 dark:border-gray-700 dark:bg-gray-800"
              >
                <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-brand-50 text-brand-600 dark:bg-brand-900/30 dark:text-brand-300">
                  <Icon className="h-6 w-6" />
                </span>
                <div>
                  <h3 className="text-lg font-extrabold">{item.title}</h3>
                  <p className="mt-1 leading-relaxed text-navy-muted dark:text-gray-300">
                    {item.desc}
                  </p>
                </div>
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}

