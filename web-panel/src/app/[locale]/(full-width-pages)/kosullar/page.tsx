import LegalDocument from "@/components/legal/LegalDocument";
import { termsSections } from "@/lib/legal/content";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Kullanım Koşulları | Hupolingo",
  description: "Hupolingo hizmetinin kullanım koşulları.",
};

export default function TermsPage() {
  return (
    <LegalDocument
      title="Kullanım Koşulları"
      updatedLabel="Son güncelleme: 9 Ekim 2026 (taslak)"
      sections={termsSections}
    />
  );
}
