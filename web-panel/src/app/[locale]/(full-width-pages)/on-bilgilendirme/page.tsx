import LegalDocument from "@/components/legal/LegalDocument";
import { onBilgilendirmeSections, onBilgilendirmeSummary } from "@/lib/legal/content";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.onBilgilendirme" });
  return { title: t("title"), description: t("description") };
}

// Veli aboneliği satın alınmadan önce gösterilen ön bilgilendirme formu (ödeme adımından bağlantılıdır).
export default async function OnBilgilendirmePage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return (
    <LegalDocument
      title="Ön Bilgilendirme Formu ve Mesafeli Satış Sözleşmesi"
      updatedLabel="Son güncelleme: 29 Ekim 2026 (taslak)"
      summary={onBilgilendirmeSummary}
      sections={onBilgilendirmeSections}
    />
  );
}
