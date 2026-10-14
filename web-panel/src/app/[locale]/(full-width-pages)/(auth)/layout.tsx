import BrandMark from "@/components/common/BrandMark";
import { Link } from "@/i18n/navigation";
import { getTranslations } from "next-intl/server";
import Image from "next/image";
import React from "react";

// Veli giriş ve kayıt ekranlarının ortak kabuğu. Mobilde tek sütun (16px yan boşluk),
// Hupo kısa bir karşılama balonuyla açılır. Geniş ekranda sol form, sağ marka paneli:
// adım akışı ve yüzen Hupo (hareket tercihi "azalt" ise sabit).
export default async function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const t = await getTranslations("signin");
  const steps = [t("step1"), t("step2"), t("step3")];

  return (
    <div className="min-h-dvh bg-cream text-navy">
      <div className="mx-auto flex min-h-dvh w-full max-w-6xl flex-col lg:grid lg:grid-cols-2 lg:items-stretch lg:gap-10 lg:px-10 lg:py-10">
        <div className="flex flex-1 flex-col px-4 pb-10 pt-6 sm:px-6 lg:justify-center lg:px-0 lg:py-0">
          <div className="flex items-center justify-between gap-4 lg:hidden">
            <Link href="/" className="inline-flex rounded-lg">
              <BrandMark />
            </Link>
          </div>

          <div className="mt-6 flex items-center gap-3 lg:hidden">
            <Image
              src="/hupo/hosgeldin.webp"
              alt=""
              width={64}
              height={64}
              className="size-16 shrink-0 object-contain"
            />
            <p className="rounded-2xl rounded-bl-sm bg-white px-4 py-2.5 text-sm font-semibold text-navy shadow-sm ring-1 ring-navy/10">
              {t("bubble")}
            </p>
          </div>

          <div className="mx-auto mt-8 w-full max-w-md lg:mt-0">{children}</div>
        </div>

        <aside className="relative hidden overflow-hidden rounded-3xl bg-gradient-to-br from-brand-800 via-brand-700 to-brand-600 p-12 text-white lg:flex lg:flex-col lg:justify-between">
          <span aria-hidden="true" className="absolute -end-24 -top-24 size-80 rounded-full bg-white/10" />
          <span aria-hidden="true" className="absolute -bottom-16 -start-16 size-56 rounded-full bg-brand-900/20" />

          <div className="relative">
            <BrandMark onDark />
          </div>

          <div className="relative">
            <h2 className="text-3xl font-extrabold leading-tight tracking-tight">
              {t("brandTitle")}
            </h2>
            <p className="mt-4 max-w-md text-base leading-relaxed text-white/90">{t("brandBody")}</p>

            <p className="mt-8 text-sm font-bold tracking-wider text-white/80 uppercase">
              {t("stepsTitle")}
            </p>
            <ol className="mt-3 space-y-3">
              {steps.map((step, index) => (
                <li key={step} className="flex items-center gap-3.5">
                  <span
                    aria-hidden="true"
                    className="grid size-8 shrink-0 place-items-center rounded-full bg-white text-sm font-extrabold text-brand-700"
                  >
                    {index + 1}
                  </span>
                  <span className="text-base font-semibold">{step}</span>
                </li>
              ))}
            </ol>
          </div>

          <div className="relative flex items-end justify-between gap-6">
            <div className="max-w-[13rem]">
              <p className="rounded-2xl rounded-bl-sm bg-white px-4 py-3 text-sm font-semibold text-navy shadow-lg">
                {t("bubble")}
              </p>
              <p className="mt-3 text-sm font-semibold text-white/90">{t("brandCaption")}</p>
            </div>
            <Image
              src="/hupo/hero.webp"
              alt="Hupo"
              width={360}
              height={380}
              className="h-auto w-44 shrink-0 drop-shadow-xl motion-safe:animate-hupo-float"
            />
          </div>
        </aside>
      </div>
    </div>
  );
}
