import LegalDocument from "@/components/legal/LegalDocument";
import { privacySections } from "@/lib/legal/content";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Gizlilik Politikası | Hupolingo",
  description: "Hupolingo'nun kişisel verileri nasıl işlediğini ve haklarını açıklar.",
};

export default function PrivacyPage() {
  return (
    <LegalDocument
      title="Gizlilik Politikası"
      updatedLabel="Son güncelleme: 9 Ekim 2026 (taslak)"
      sections={privacySections}
    />
  );
}
