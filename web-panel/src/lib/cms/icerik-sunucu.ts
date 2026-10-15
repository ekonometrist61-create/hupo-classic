import { createClient } from "@supabase/supabase-js";
import { unstable_cache } from "next/cache";

import type { IcerikSatiri } from "./icerik";
import { siteIcerikSatirlariniOku } from "./icerik-veri";

// Herkese açık sayfalar için önbellekli okuma. Anonim okuma RLS ile açık (site_icerik_oku).
// Önbellek 60 sn: yönetim ekranında yapılan değişiklik en geç bir dakika içinde yansır.
const yayinSatirlari = unstable_cache(
  async (dil: string): Promise<IcerikSatiri[]> => {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const anahtar = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
    if (!url || !anahtar) return [];
    const istemci = createClient(url, anahtar, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    return siteIcerikSatirlariniOku(istemci, dil);
  },
  ["site-icerik-yayin"],
  { revalidate: 60 },
);

/**
 * Yayındaki CMS satırları. Okuma başarısızsa boş döner ve sayfa JSON'daki yedek metinlerle açılır.
 * Hata mesajında yalnızca hata kodu yazılır (PII yok).
 */
export async function yayinSiteIcerigi(dil: string): Promise<IcerikSatiri[]> {
  try {
    return await yayinSatirlari(dil);
  } catch (hata) {
    console.error(
      "CMS okunamadı, yedek metinler kullanılıyor:",
      hata instanceof Error ? hata.message : "bilinmeyen hata",
    );
    return [];
  }
}
