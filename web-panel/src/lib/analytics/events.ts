// Rıza tabanlı olay ölçümü. Olaylar yalnızca kullanıcı analitik çerezine "Kabul et" dediyse gönderilir;
// reddedilmişse veya karar yoksa hiçbir şey gönderilmez. Olay adları ve özellikleri kişisel veri içermez.
import { analitikIstemcisi } from "./posthog-istemci";
import { readAnalyticsConsent } from "./consent";
import { utmOzellikleri } from "./utm";

export type LandingEvent =
  | "hero_cta_tiklandi"
  | "demo_tamamlandi"
  | "veli_kayit_baslatildi"
  | "fiyat_tiklandi";

// Promise, olayın gönderildiği (ya da gönderilmediği) anda çözülür. Çağıranlar beklemek zorunda değildir;
// testler için ise capture'ın tamamlandığı garanti edilir. Hata asla dışarı sızmaz.
export function trackLandingEvent(olay: LandingEvent, ozellik?: Record<string, string | number>): Promise<void> {
  try {
    if (readAnalyticsConsent() !== "granted") return Promise.resolve();
    const anahtar = process.env.NEXT_PUBLIC_POSTHOG_KEY;
    if (!anahtar) return Promise.resolve();
    // İlk temas UTM'si (oturum kapsamlı, rıza kapılı) olay özelliklerine eklenir; çağıranın alanları öncelikli.
    return analitikIstemcisi(anahtar)
      .then((posthog) => {
        posthog.capture(olay, { ...utmOzellikleri(), ...ozellik });
      })
      .catch(() => {
        // Ölçüm hatası sayfayı etkilemez.
      });
  } catch {
    // Ölçüm hatası sayfayı etkilemez.
    return Promise.resolve();
  }
}
