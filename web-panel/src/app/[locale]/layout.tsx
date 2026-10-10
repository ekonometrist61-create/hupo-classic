import AnalyticsProvider from "@/components/analytics/AnalyticsProvider";
import CookieConsent from "@/components/analytics/CookieConsent";
import { SidebarProvider } from "@/context/SidebarContext";
import { ThemeProvider } from "@/context/ThemeContext";
import { isRtl } from "@/i18n/languages";
import { type Locale, routing } from "@/i18n/routing";
import { NextIntlClientProvider } from "next-intl";
import { setRequestLocale } from "next-intl/server";
import { Outfit } from "next/font/google";
import "../globals.css";

const outfit = Outfit({
  subsets: ["latin", "latin-ext"],
});

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

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
          </ThemeProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
