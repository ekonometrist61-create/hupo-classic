import LegalDocument from "@/components/legal/LegalDocument";
import { termsSections } from "@/lib/legal/content";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.kosullar" });
  return { title: t("title"), description: t("description") };
}

export default async function TermsPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  return (
    <LegalDocument
      title="Kullanım Koşulları"
      updatedLabel="Son güncelleme: 9 Ekim 2026 (taslak)"
      sections={termsSections}
    />
  );
}
