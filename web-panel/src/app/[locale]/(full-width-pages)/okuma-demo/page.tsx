import { marketingFont } from "@/components/landing/marketingFont";
import { OkumaDemo } from "@/components/okuma-site/OkumaDemo";
import { DEMO_HIKAYE } from "@/components/okuma-site/okumaDemoHikaye";
import { OkumaSiteUst } from "@/components/okuma-site/OkumaSiteUst";
import { VeliOkumaBolumu } from "@/components/okuma-site/VeliOkumaBolumu";
import type { Metadata } from "next";

// Yayın kapısı: bu sayfa navigasyona, sitemap'e veya canonical'a eklenmez; yalnız doğrudan URL ile açılır.
// Pilot bitişi ve hukuk onayı sonrası kararla birlikte noindex kaldırılır.
export const metadata: Metadata = {
  title: "Örnek hikâye · Hupolingo",
  description: "Hupolingo Okuma Dünyası'ndan kayıtsız bir örnek hikâye: sayfaları oku, soruları dene.",
  robots: { index: false, follow: false },
};

export default function OkumaDemoPage() {
  return (
    <div className={`${marketingFont.className} min-h-screen bg-cream text-navy dark:bg-gray-950 dark:text-gray-100`}>
      <OkumaSiteUst />

      <main id="main" className="mx-auto max-w-2xl space-y-12 px-4 py-8 sm:px-6 sm:py-12">
        <header className="space-y-4">
          <p className="inline-flex items-center rounded-full bg-gold-100 px-3 py-1 text-xs font-extrabold text-gold-900 dark:bg-gold-900/30 dark:text-gold-200">
            Önizleme · Kayıt gerekmez
          </p>
          <h1 className="text-3xl font-extrabold leading-tight tracking-tight sm:text-4xl">{DEMO_HIKAYE.baslik}</h1>
          <p className="leading-relaxed text-navy-muted dark:text-gray-300">
            Hupo ile Ela’nın bir damlanın yolculuğunu takip ettiği kısa bir hikâye. Sayfaları kendi hızında oku;
            sorular hikâyenin sonunda gelir. Maarif değeri: {DEMO_HIKAYE.deger}.
          </p>
        </header>

        <OkumaDemo />

        <VeliOkumaBolumu />
      </main>
    </div>
  );
}
