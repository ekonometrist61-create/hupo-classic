"use client";

// Veli ana sayfasındaki anket kartının sıklık kapısı (W10).
// Kural: kart en fazla 24 saatte bir gösterilir. Zaman damgası yalnızca kart gerçekten çizildiğinde yazılır.
// Depolama okunamaz ya da yazılamazsa (gizli pencere, engelli site verisi) kart sessizce gösterilir.
// Sunucuda (ilk çizim) kart gizli kalır; istemci kontrolünden sonra gösterilir.

import AnketIstemi from "@/components/anket/AnketIstemi";
import { useCallback, useState } from "react";

const ANAHTAR = "hupo.veli.anketGosterim";
const SURE_MS = 24 * 60 * 60 * 1000;

function gosterilebilirMi(): boolean {
  try {
    const son = Number(window.localStorage.getItem(ANAHTAR));
    return !(son > 0 && Date.now() - son < SURE_MS);
  } catch {
    return true;
  }
}

function gosterimiKaydet() {
  try {
    window.localStorage.setItem(ANAHTAR, String(Date.now()));
  } catch {
    // Kayıt yapılamadıysa bir sonraki sayfa yüklemesinde kart yine gösterilebilir.
  }
}

export default function VeliAnketKapisi() {
  // Lazy başlangıç: sunucuda window yoksa true döner, AnketIstemi ilk çizimde zaten boş çizilir.
  const [gosterilebilir] = useState(gosterilebilirMi);
  const kaydet = useCallback(() => gosterimiKaydet(), []);

  if (!gosterilebilir) return null;
  return <AnketIstemi yuzey="veli_paneli" onGosterildi={kaydet} />;
}
