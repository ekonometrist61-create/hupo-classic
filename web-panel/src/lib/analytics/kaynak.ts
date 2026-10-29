// Hane kaynağı: kayıt anındaki ilk temas UTM'si veli hane kartına yazılır (hane_ilk_temas_yaz RPC'si).
// E-posta doğrulaması başka sekmede/tarayıcıda açılabildiği için UTM, kayıtta hesabın metadata'sına
// konur ve ilk oturumda RPC'ye gönderilir. Kişisel veri yok; yalnız 4 UTM alanı.
// Rıza: metadata'ya yalnız analitik çerezine "Kabul et" denmişse yazılır (utmOzellikleri rıza kapılıdır).
// Karar: docs/hupo-design-growth/decisions.md "Kanal ölçümü (2026-10-29)".
import type { SupabaseClient, User } from "@supabase/supabase-js";

import { readAnalyticsConsent } from "./consent";
import { utmDogrula, utmOzellikleri } from "./utm";

export const KAYIT_UTM_ANAHTARI = "hupo_utm";

// signUp options.data içine yayılır. Rıza yoksa veya UTM yoksa boş nesne.
export function kayitUtmMetadata(): Record<string, unknown> {
  try {
    const utm = utmOzellikleri();
    return Object.keys(utm).length > 0 ? { [KAYIT_UTM_ANAHTARI]: utm } : {};
  } catch {
    return {};
  }
}

// İlk oturumda çağrılır. RPC yalnız boş alanları doldurur, bu yüzden tekrar çağrı zararsızdır.
// Hata girişi veya kaydı bozmaz.
export async function haneKaynagiYaz(supabase: SupabaseClient, kullanici: User | null | undefined): Promise<void> {
  try {
    if (!kullanici) return;
    if (readAnalyticsConsent() === "denied") return;
    const utm = utmDogrula(kullanici.user_metadata?.[KAYIT_UTM_ANAHTARI]);
    if (Object.keys(utm).length === 0) return;
    await supabase.rpc("hane_ilk_temas_yaz", { p_utm: utm });
  } catch {
    // Ölçüm hatası akışı etkilemez.
  }
}
