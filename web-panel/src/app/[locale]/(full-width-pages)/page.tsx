import { LandingFooter } from "@/components/landing/Footer";
import { LandingHeader } from "@/components/landing/Header";
import { AppScreensSection } from "@/components/landing/sections/AppScreensSection";
import { BenefitsSection } from "@/components/landing/sections/BenefitsSection";
import { CharacterUniverseSection } from "@/components/landing/sections/CharacterUniverseSection";
import { DemoSection } from "@/components/landing/sections/DemoSection";
import { DenemeExamSection } from "@/components/landing/sections/DenemeExamSection";
import { DuyuruSeridi } from "@/components/landing/sections/DuyuruSeridi";
import { ErkenErisimSection } from "@/components/landing/sections/ErkenErisimSection";
import { FaqSection } from "@/components/landing/sections/FaqSection";
import { FinalCtaSection } from "@/components/landing/sections/FinalCtaSection";
import { HeroSection } from "@/components/landing/sections/HeroSection";
import { HowItWorksSection } from "@/components/landing/sections/HowItWorksSection";
import { ParentPanelSection } from "@/components/landing/sections/ParentPanelSection";
import { PricingSection } from "@/components/landing/sections/PricingSection";
import { TrustBadgesBar } from "@/components/landing/sections/TrustBadgesBar";
import { TrustSection } from "@/components/landing/sections/TrustSection";
import { WhyParentsSection } from "@/components/landing/sections/WhyParentsSection";
import { marketingFont } from "@/components/landing/marketingFont";
import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "landing" });
  return { title: t("metaTitle"), description: t("metaDescription") };
}

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
        <TrustBadgesBar />
        <BenefitsSection />
        <DemoSection />
        <AppScreensSection />
        <CharacterUniverseSection />
        <HowItWorksSection />
        <WhyParentsSection />
        <ParentPanelSection />
        <DenemeExamSection />
        <PricingSection />
        <TrustSection />
        <ErkenErisimSection />
        <FaqSection />
        <FinalCtaSection />
      </main>

      <LandingFooter />
    </div>
  );
}
