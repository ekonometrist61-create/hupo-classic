import { IconCompass, IconLock, IconShield, IconUserCheck } from "@/components/landing/Icons";
import { getTranslations } from "next-intl/server";
import type { ComponentType, SVGProps } from "react";

type Icon = ComponentType<SVGProps<SVGSVGElement>>;
const TRUST_ICONS: Icon[] = [IconShield, IconUserCheck, IconLock, IconCompass];

export async function TrustSection() {
  const t = await getTranslations("landing");
  const trustItems = t.raw("trust.items") as { title: string; desc: string }[];

  return (
    <section id="trust" className="scroll-mt-20 bg-navy py-12 text-white sm:py-16 lg:py-20">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <h2 className="text-center text-3xl font-extrabold tracking-tight sm:text-4xl">
          {t("trust.title")}
        </h2>
        <p className="mx-auto mt-3 max-w-xl text-center text-lg text-white/80">
          {t("trust.desc")}
        </p>
        <ul className="mt-10 grid gap-6 sm:grid-cols-2">
          {trustItems.map((item, i) => {
            const Icon = TRUST_ICONS[i] ?? IconShield;
            return (
              <li
                key={item.title}
                className="flex gap-4 rounded-2xl border border-white/15 bg-white/5 p-6"
              >
                <span className="inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-gold-500 text-navy">
                  <Icon className="h-6 w-6" />
                </span>
                <div>
                  <h3 className="text-lg font-extrabold">{item.title}</h3>
                  <p className="mt-1 leading-relaxed text-white/80">{item.desc}</p>
                </div>
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}
