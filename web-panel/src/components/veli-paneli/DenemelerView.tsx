"use client";

import DenemeKaydiKarti from "./DenemeKaydiKarti";
import CocukDenemeGecmisi from "./CocukDenemeGecmisi";

interface Props {
  cocukId: string;
  cocukAd: string | null;
}

// Deneme Sınavları tam sayfası: kayıt kartı + geçmiş listesi yan yana.
export default function DenemelerView({ cocukId, cocukAd }: Props) {
  return (
    <div className="space-y-6">
      <DenemeKaydiKarti cocukId={cocukId} cocukAd={cocukAd} />
      <CocukDenemeGecmisi cocukId={cocukId} cocukAd={cocukAd} />
    </div>
  );
}
