import { LandingFooter } from "@/components/landing/Footer";
import { LandingHeader } from "@/components/landing/Header";
import { LandingMotion } from "@/components/landing/motion/LandingMotion";
import { CharacterUniverseSection } from "@/components/landing/sections/CharacterUniverseSection";
import { DemoSection } from "@/components/landing/sections/DemoSection";
import { DuyuruSeridi } from "@/components/landing/sections/DuyuruSeridi";
import { FaqSection } from "@/components/landing/sections/FaqSection";
import { FarkSection } from "@/components/landing/sections/FarkSection";
import { FinalCtaSection } from "@/components/landing/sections/FinalCtaSection";
import { HakkimizdaSection } from "@/components/landing/sections/HakkimizdaSection";
import { HeroSection } from "@/components/landing/sections/HeroSection";
import { HikayelerSection } from "@/components/landing/sections/HikayelerSection";
import { HowItWorksSection } from "@/components/landing/sections/HowItWorksSection";
import { KesfetSection } from "@/components/landing/sections/KesfetSection";
import { OgrenmeBilimiSection } from "@/components/landing/sections/OgrenmeBilimiSection";
import { ParentPanelSection } from "@/components/landing/sections/ParentPanelSection";
import { PricingSection } from "@/components/landing/sections/PricingSection";
import { SeninHikayenSection } from "@/components/landing/sections/SeninHikayenSection";
import { RehberBandi } from "@/components/landing/sections/RehberBandi";
import { TrustSection } from "@/components/landing/sections/TrustSection";
import { marketingFont } from "@/components/landing/marketingFont";
import type { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "landing" });
  return { title: t("metaTitle"), description: t("metaDescription") };
}

// Bölüm sırası sadeleştirildi: fayda (farkımız dahil) → örnek soru → nasıl çalışır → veli raporu →
// karakterler → güven → fiyat → SSS → hakkımızda → tek CTA. Tek CTA kuralı için ayrı deneme sınavı ve erken erişim
// bölümleri bu sayfadan çıkarıldı (ilgili rotalar çalışmaya devam eder).
// LandingMotion: Lenis (yalnız bu sayfa) ve GSAP köprüsünü sarar; bölümler server component kalır.
export default async function LandingPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("landing");

  return (
    <LandingMotion>
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
          {/* Farkımız: oynayarak öğrenme, takip ve yer bilme, proje okullarına hazırlık desteği. */}
          <FarkSection />
          {/* Benefits (01–03 kartları) gerçek ekran görüntüleri hazır olana kadar sayfada gösterilmez. */}
          <DemoSection />
          <HowItWorksSection />
          <ParentPanelSection />
          {/* Okuma dünyası: veli raporundan sonra, karakter bölümünden önce (FK-006). */}
          <HikayelerSection />
          {/* Senin Hikâyen: kişisel kahraman ve sınıf başına hikâye deneyimi; gerçek uygulama ekranıyla. */}
          <SeninHikayenSection />
          {/* Çarpım Şifreleri, Kelime Evreni, Arena: dürüst durum rozetli keşif alanları. */}
          <KesfetSection />
          <CharacterUniverseSection />
          <TrustSection />
          {/* Öğrenme Bilimi: kanıt paketi §3 uyarlaması; akademik bulgular ürün şemasına konmaz. */}
          <OgrenmeBilimiSection />
          <PricingSection />
          {/* İkincil, düşük vurgulu rehber bandı (NEXT_PUBLIC_LEAD_MAGNET_ACIK kapalıyken çizilmez). */}
          <RehberBandi />
          <FaqSection />
          {/* Kısa Hakkımızda: neden varız, Hupo kim, pilot notu; /hakkimizda bağlantısı. */}
          <HakkimizdaSection />
          <FinalCtaSection />
        </main>

        <LandingFooter />
      </div>
    </LandingMotion>
  );
}
