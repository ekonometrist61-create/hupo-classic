import LegalDocument from "@/components/legal/LegalDocument";
import { privacySections } from "@/lib/legal/content";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.gizlilik" });
  return { title: t("title"), description: t("description") };
}

export default async function PrivacyPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return (
    <LegalDocument
      title="Gizlilik Politikası"
      updatedLabel="Son güncelleme: 9 Ekim 2026 (taslak)"
      sections={privacySections}
    />
  );
}
