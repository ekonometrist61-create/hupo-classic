import AnalyticsProvider from "@/components/analytics/AnalyticsProvider";
import CookieConsent from "@/components/analytics/CookieConsent";
import KullanimSuresi from "@/components/analytics/KullanimSuresi";
import { SidebarProvider } from "@/context/SidebarContext";
import { ThemeProvider } from "@/context/ThemeContext";
import { isRtl } from "@/i18n/languages";
import { type Locale, routing } from "@/i18n/routing";
import { NextIntlClientProvider } from "next-intl";
import { setRequestLocale } from "next-intl/server";
import { Outfit } from "next/font/google";
import { connection } from "next/server";
import "../globals.css";

const outfit = Outfit({
  subsets: ["latin", "latin-ext"],
});

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

// CMS (site_icerik) değişiklikleri yayına çıksın diye 60 sn önbellek kullanılır
// (bkz. lib/cms/icerik-sunucu.ts, unstable_cache). Yeniden derleme gerekmez.
export const revalidate = 60;

export default async function RootLayout({
  children,
  params,
}: Readonly<{
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}>) {
  // localePrefix "never" olduğu için istek /yonetim gelir; middleware bunu
  // /tr/yonetim olarak yeniden yazar. params.locale tanımsız gelirse
  // (yoksa Next.js 404 döner) varsayılan dile düşüyoruz.
  // CSP nonce'u her istekte farklı olmalı; sayfa istek anında işlenir (Next.js CSP belgesi,
  // "Forcing dynamic rendering"). Bu satır olmadan statik HTML'deki inline script'ler nonce'suz kalır.
  await connection();

  const raw = (await params).locale;
  const locale: Locale = routing.locales.includes(raw as Locale)
    ? (raw as Locale)
    : routing.defaultLocale;

  setRequestLocale(locale);

  return (
    <html lang={locale} dir={isRtl(locale) ? "rtl" : "ltr"}>
      <body className={`${outfit.className} dark:bg-gray-900`}>
        <NextIntlClientProvider locale={locale}>
          <ThemeProvider>
            <SidebarProvider>
              {children}
            </SidebarProvider>
            <CookieConsent />
            <AnalyticsProvider />
            <KullanimSuresi />
          </ThemeProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
