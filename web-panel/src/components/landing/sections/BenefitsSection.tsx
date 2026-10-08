import { IconChart, IconSteps, IconTimer } from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import type { ComponentType, SVGProps } from "react";

type Icon = ComponentType<SVGProps<SVGSVGElement>>;
const BENEFIT_ICONS: Icon[] = [IconTimer, IconSteps, IconChart];

export async function BenefitsSection() {
  const t = await getTranslations("landing");
  const benefits = t.raw("benefits.items") as { title: string; desc: string }[];

  return (
    <section className="bg-white py-8 sm:py-12 dark:bg-gray-900">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <h2 className="mx-auto max-w-2xl text-balance text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
          {t("benefits.title")}
        </h2>
        <ul className="mt-10 grid gap-6 md:grid-cols-3">
          {benefits.map((item, i) => {
            const Icon = BENEFIT_ICONS[i];
            return (
              <li
                key={item.title}
                className="rounded-2xl border border-cream-dark bg-cream p-6 dark:border-gray-700 dark:bg-gray-800"
              >
                <span className="inline-flex h-12 w-12 items-center justify-center rounded-xl bg-brand-500 text-white">
                  <Icon className="h-6 w-6" />
                </span>
                <h3 className="mt-5 text-xl font-extrabold">{item.title}</h3>
                <p className="mt-2 leading-relaxed text-navy-muted dark:text-gray-300">{item.desc}</p>
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}

