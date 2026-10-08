import {
  IconBook,
  IconGamepad,
  IconGlobe,
  IconShield,
  IconTarget,
  IconUsers,
} from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import type { ComponentType, SVGProps } from "react";

type Icon = ComponentType<SVGProps<SVGSVGElement>>;

const BADGE_ICONS: Icon[] = [IconBook, IconShield, IconUsers, IconTarget, IconGamepad, IconGlobe];

export async function TrustBadgesBar() {
  const t = await getTranslations("landing.trustBadges");
  const items = t.raw("items") as string[];

  return (
    <section aria-label="Güven rozetleri" className="border-y border-cream-dark bg-white dark:border-gray-800 dark:bg-gray-900">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex overflow-x-auto py-4 scrollbar-hide sm:justify-center sm:gap-2">
          <ul className="flex min-w-max items-center gap-2 sm:flex-wrap sm:justify-center sm:min-w-0">
            {items.map((label, i) => {
              const Icon = BADGE_ICONS[i % BADGE_ICONS.length];
              return (
                <li
                  key={label}
                  className="flex items-center gap-2 rounded-full border border-cream-dark bg-cream px-4 py-2 text-sm font-bold text-navy whitespace-nowrap dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100"
                >
                  <Icon className="h-4 w-4 shrink-0 text-brand-500 dark:text-brand-300" />
                  {label}
                </li>
              );
            })}
          </ul>
        </div>
      </div>
    </section>
  );
}
