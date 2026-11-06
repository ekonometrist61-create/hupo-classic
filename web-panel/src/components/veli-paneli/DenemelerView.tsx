"use client";

import DenemeGelisimi from "./DenemeGelisimi";
import DenemeKaydiKarti from "./DenemeKaydiKarti";
import CocukDenemeGecmisi from "./CocukDenemeGecmisi";

interface Props {
  cocukId: string;
  cocukAd: string | null;
}

// Deneme ve Gelişim sayfası: gelişim özeti, kayıt kartı ve geçmiş listesi.
export default function DenemelerView({ cocukId, cocukAd }: Props) {
  return (
    <div className="space-y-6">
      <DenemeGelisimi key={cocukId} cocukId={cocukId} />
      <DenemeKaydiKarti cocukId={cocukId} cocukAd={cocukAd} />
      <CocukDenemeGecmisi cocukId={cocukId} cocukAd={cocukAd} />
    </div>
  );
}
