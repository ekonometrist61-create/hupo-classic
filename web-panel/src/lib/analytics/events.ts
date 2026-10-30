// Rıza tabanlı olay ölçümü. Olaylar yalnızca kullanıcı analitik çerezine "Kabul et" dediyse gönderilir;
// reddedilmişse veya karar yoksa hiçbir şey gönderilmez. Olay adları ve özellikleri kişisel veri içermez.
import posthog from "posthog-js";

import { readAnalyticsConsent } from "./consent";

export type LandingEvent =
  | "hero_cta_tiklandi"
  | "demo_tamamlandi"
  | "veli_kayit_baslatildi"
  | "fiyat_tiklandi"
  // Lead magnet (rehber) olayları: özellikler yalnız icerik (slug) ve sinif (sayı); e-posta/ad yok.
  | "lead_magnet_goruntulendi"
  | "lead_magnet_istendi"
  | "lead_magnet_icerik_acildi";

export function trackLandingEvent(olay: LandingEvent, ozellik?: Record<string, string | number>): void {
  try {
    if (readAnalyticsConsent() !== "granted") return;
    posthog.capture(olay, ozellik);
  } catch {
    // Ölçüm hatası sayfayı etkilemez.
  }
}
