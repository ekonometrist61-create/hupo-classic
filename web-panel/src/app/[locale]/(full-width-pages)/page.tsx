import { LandingFooter } from "@/components/landing/Footer";
import { LandingHeader } from "@/components/landing/Header";
import { BenefitsSection } from "@/components/landing/sections/BenefitsSection";
import { CharacterUniverseSection } from "@/components/landing/sections/CharacterUniverseSection";
import { DemoSection } from "@/components/landing/sections/DemoSection";
import { DuyuruSeridi } from "@/components/landing/sections/DuyuruSeridi";
import { FaqSection } from "@/components/landing/sections/FaqSection";
import { FinalCtaSection } from "@/components/landing/sections/FinalCtaSection";
import { HeroSection } from "@/components/landing/sections/HeroSection";
import { HikayelerSection } from "@/components/landing/sections/HikayelerSection";
import { HowItWorksSection } from "@/components/landing/sections/HowItWorksSection";
import { ParentPanelSection } from "@/components/landing/sections/ParentPanelSection";
import { PricingSection } from "@/components/landing/sections/PricingSection";
import { TrustSection } from "@/components/landing/sections/TrustSection";
import { marketingFont } from "@/components/landing/marketingFont";
import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "landing" });
  return { title: t("metaTitle"), description: t("metaDescription") };
}

// Bölüm sırası sadeleştirildi: fayda → örnek soru → nasıl çalışır → veli raporu → karakterler →
// güven → fiyat → SSS → tek CTA. Tek CTA kuralı için ayrı deneme sınavı ve erken erişim
// bölümleri bu sayfadan çıkarıldı (ilgili rotalar çalışmaya devam eder).
export default async function LandingPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("landing");

  return (
    <div
      className={`${marketingFont.className} min-h-screen bg-cream text-navy dark:bg-gray-950 dark:text-gray-100`}
    >
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:start-4 focus:top-4 focus:z-[60] focus:rounded-lg focus:bg-white focus:px-4 focus:py-2 focus:font-bold focus:text-navy"
      >
        {t("skipToContent")}
      </a>

      <LandingHeader />
      <DuyuruSeridi />

      <main id="main">
        <HeroSection />
        <BenefitsSection />
        <DemoSection />
        <HowItWorksSection />
        <HikayelerSection />
        <ParentPanelSection />
        <CharacterUniverseSection />
        <TrustSection />
        <PricingSection />
        <FaqSection />
        <FinalCtaSection />
      </main>

      <LandingFooter />
    </div>
  );
}
