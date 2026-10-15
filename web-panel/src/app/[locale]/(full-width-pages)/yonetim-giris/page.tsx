import SignInForm from "@/components/auth/SignInForm";
import BrandMark from "@/components/common/BrandMark";
import { Link } from "@/i18n/navigation";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";
import React from "react";

// Yönetim girişi: kurumsal ve operasyonel. Pazarlama dili, maskot ve animasyon yok;
// arama motorlarına kapalı. Kenar panelindeki alanlar mevcut yönetim sayfalarını anlatır.
export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.yonetimGiris" });
  return { title: t("title"), description: t("description"), robots: { index: false, follow: false } };
}

function Icon({ children }: { children: React.ReactNode }) {
  return (
    <svg
      aria-hidden="true"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.7}
      strokeLinecap="round"
      strokeLinejoin="round"
      className="size-[18px]"
    >
      {children}
    </svg>
  );
}

const ikonlar = [
  // Soru bankası
  <Icon key="soru">
    <path d="M4 19.5V5.5A1.5 1.5 0 0 1 5.5 4H20v13H5.5A1.5 1.5 0 0 0 4 18.5" />
    <path d="M4 19.5A1.5 1.5 0 0 0 5.5 21H20v-4" />
  </Icon>,
  // Kullanıcılar
  <Icon key="kullanici">
    <circle cx="9.5" cy="8" r="3.5" />
    <path d="M3 20v-1a5 5 0 0 1 5-5h3a5 5 0 0 1 5 5v1" />
    <path d="M16 4.6a3.5 3.5 0 0 1 0 6.8M21 20v-1a5 5 0 0 0-3.5-4.8" />
  </Icon>,
  // Ödemeler
  <Icon key="odeme">
    <rect x="3" y="6" width="18" height="13" rx="2" />
    <path d="M3 10.5h18M7 15.5h4" />
  </Icon>,
  // Destek
  <Icon key="destek">
    <path d="M21 12a8.5 8.5 0 0 1-12.4 7.5L4 20.5l1-4.2A8.5 8.5 0 1 1 21 12Z" />
  </Icon>,
  // Analitik
  <Icon key="analitik">
    <path d="M4 20V11M10 20V5M16 20v-6M22 20H2" />
  </Icon>,
];

export default async function YonetimGiris({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("adminSignin");
  const alanlar = [1, 2, 3, 4, 5].map((n, i) => ({
    ikon: ikonlar[i],
    baslik: t(`area${n}Title`),
    aciklama: t(`area${n}Body`),
  }));

  return (
    <div className="grid min-h-dvh bg-[#f3f5f8] text-navy lg:grid-cols-[minmax(0,1.1fr)_minmax(0,1fr)]">
      <aside className="relative flex flex-col overflow-hidden bg-navy px-6 py-7 text-white sm:px-10 lg:px-14 lg:py-12">
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 bg-[radial-gradient(rgb(255_255_255/0.08)_1px,transparent_1px)] [background-size:24px_24px]"
        />

        <div className="relative flex items-center justify-between gap-4">
          <Link href="/" className="inline-flex rounded-lg">
            <BrandMark onDark />
          </Link>
          <span className="rounded-full border border-white/20 px-2.5 py-0.5 text-xs font-medium text-white/80">
            {t("version")}
          </span>
        </div>

        <div className="relative mt-6 flex flex-1 flex-col justify-center lg:mt-0 lg:py-12">
          <p className="text-xs font-semibold tracking-[0.14em] text-white/55 uppercase">
            {t("eyebrow")}
          </p>
          <h2 className="mt-2 text-xl font-bold tracking-tight lg:mt-3 lg:text-4xl">{t("title")}</h2>
          <p className="mt-4 hidden max-w-md text-base leading-relaxed text-white/75 lg:block">{t("lead")}</p>

          <p className="mt-12 hidden text-xs font-semibold tracking-[0.14em] text-white/55 uppercase lg:block">
            {t("areasTitle")}
          </p>
          <ul className="mt-4 hidden divide-y divide-white/10 border-y border-white/10 lg:block">
            {alanlar.map((alan) => (
              <li key={alan.baslik} className="flex items-start gap-4 py-4">
                <span className="grid size-9 shrink-0 place-items-center rounded-lg bg-white/10 text-white">
                  {alan.ikon}
                </span>
                <span className="min-w-0">
                  <span className="block text-sm font-semibold">{alan.baslik}</span>
                  <span className="mt-0.5 block text-sm text-white/65">{alan.aciklama}</span>
                </span>
              </li>
            ))}
          </ul>
        </div>

        <p className="relative mt-auto hidden text-xs text-white/55 lg:block">{t("footerNote")}</p>
      </aside>

      <main className="flex items-center justify-center px-4 py-12 sm:px-8 lg:px-16">
        <div className="w-full max-w-[400px]">
          <h1 className="text-2xl font-bold tracking-tight text-navy">{t("formTitle")}</h1>
          <p className="mt-2 text-sm leading-relaxed text-navy-muted">{t("formNote")}</p>

          <div className="mt-8">
            <SignInForm variant="yonetim" />
          </div>

          <p className="mt-8 border-t border-navy/10 pt-6 text-sm leading-relaxed text-navy-muted">
            {t("supportNote")}
          </p>
        </div>
      </main>
    </div>
  );
}
