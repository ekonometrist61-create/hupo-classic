import BrandMark from "@/components/common/BrandMark";
import { Link } from "@/i18n/navigation";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import React from "react";

// Giris ve kayit ekranlarinin ortak kabugu. Mobilde tek sutun (16px yan bosluk);
// genis ekranda sol form, sag Hupolingo markali bilgi paneli.
export default async function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const t = await getTranslations("signin");
  const points = [t("brandPoint1"), t("brandPoint2"), t("brandPoint3")];

  return (
    <div className="min-h-dvh bg-cream text-navy">
      <div className="mx-auto flex min-h-dvh w-full max-w-6xl flex-col lg:grid lg:grid-cols-2 lg:items-stretch lg:gap-10 lg:px-10 lg:py-10">
        <div className="flex flex-1 flex-col px-4 pb-10 pt-6 sm:px-6 lg:justify-center lg:px-0 lg:py-0">
          <Link href="/" className="inline-flex self-start rounded-lg lg:hidden">
            <BrandMark />
          </Link>
          <div className="mx-auto mt-10 w-full max-w-md lg:mt-0">{children}</div>
        </div>

        <aside className="hidden flex-col justify-between rounded-3xl bg-brand-500 p-12 text-white lg:flex">
          <Link href="/" className="inline-flex self-start rounded-lg">
            <BrandMark onDark />
          </Link>

          <div>
            <h2 className="text-3xl font-extrabold leading-tight tracking-tight">
              {t("brandTitle")}
            </h2>
            <p className="mt-4 max-w-md text-base leading-relaxed">{t("brandBody")}</p>
            <ul className="mt-6 space-y-3 text-base font-semibold">
              {points.map((point) => (
                <li key={point} className="flex items-center gap-3">
                  <span aria-hidden="true" className="size-2 shrink-0 rounded-full bg-white" />
                  {point}
                </li>
              ))}
            </ul>
          </div>

          <div className="flex items-end justify-between gap-6">
            <p className="text-sm font-semibold">{t("brandCaption")}</p>
            <Image
              src="/hupo/hero.webp"
              alt="Hupo"
              width={360}
              height={380}
              className="h-auto w-40 shrink-0"
            />
          </div>
        </aside>
      </div>
    </div>
  );
}
