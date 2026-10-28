"use client";

import type { ReactNode } from "react";
import { useSyncExternalStore } from "react";

const abonelik = () => () => {};

/** Çocukları yalnızca istemcide çizer. Grafik kütüphaneleri (Recharts) sunucu ve istemci çıktısını
 *  eşleştiremez (ör. SVG clipPath kimliği); bu sarmalayıcı hidrasyon uyuşmazlığını önler.
 *  Sunucuda boş çıktı verir; kapsayıcının yüksekliği dışarıda sabit tutulmalıdır (kayma olmasın). */
export default function IstemciyeOzel({ children }: { children: ReactNode }) {
  const istemcide = useSyncExternalStore(abonelik, () => true, () => false);
  return istemcide ? <>{children}</> : null;
}
