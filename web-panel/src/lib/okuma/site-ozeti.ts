import { createClient } from "@/utils/supabase/server";

export interface SiteOzeti {
  hikaye_sayisi?: number;
  sinif_alt?: number;
  sinif_ust?: number;
  turler?: { tur: string; adet: number }[];
}

// Yayındaki hikâyelerin özeti (okuma_site_ozeti RPC). Hata ya da boş yanıtta null döner;
// çağıran bölüm "Yakında" durumunu gösterir. Sayılar metne sabit yazılmaz.
export async function okumaSiteOzetiniAl(): Promise<SiteOzeti | null> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("okuma_site_ozeti");
    if (!error && data) return data as SiteOzeti;
  } catch {
    return null;
  }
  return null;
}
