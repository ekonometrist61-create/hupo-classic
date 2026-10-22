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
import "../globals.css";

const outfit = Outfit({
  subsets: ["latin", "latin-ext"],
});

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

// CMS (site_icerik) değişiklikleri yayına çıksın diye statik sayfalar 60 sn'de bir yeniden üretilir.
// Dinamik işaretlenen sayfalarda bu ayar etkisizdir; o durumda metin verisi 60 sn önbellekten gelir
// (bkz. lib/cms/icerik-sunucu.ts). Yeniden derleme gerekmez.
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
