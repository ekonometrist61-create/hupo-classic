"use client";

// Veli ana sayfasındaki anket kartı. Sıklık kuralı (günlük bütçe, sessiz saat 22–08,
// atlama takvimi 3/14/90 gün) sunucudadır: anket_siradaki_kart. İstemcide ayrı bir
// zaman kapısı tutulmaz; kart yoksa AnketIstemi hiçbir şey çizmez.

import AnketIstemi from "@/components/anket/AnketIstemi";

export default function VeliAnketKapisi() {
  return <AnketIstemi yuzey="veli_paneli" />;
}
