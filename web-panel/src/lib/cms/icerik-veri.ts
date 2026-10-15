import type { SupabaseClient } from "@supabase/supabase-js";

import type { IcerikSatiri } from "./icerik";

// PostgREST tek istekte en çok 1000 satır döndürür; tüm satırlar sayfalanarak okunur.
const SAYFA_BOYU = 1000;

/** Bir dilin tüm site_icerik satırlarını okur. Hata durumunda hata fırlatır (yutmaz). */
export async function siteIcerikSatirlariniOku(
  istemci: SupabaseClient,
  dil: string,
): Promise<IcerikSatiri[]> {
  const satirlar: IcerikSatiri[] = [];
  for (let bas = 0; ; bas += SAYFA_BOYU) {
    const { data, error } = await istemci
      .from("site_icerik")
      .select("anahtar, dil, deger")
      .eq("dil", dil)
      .order("anahtar", { ascending: true })
      .range(bas, bas + SAYFA_BOYU - 1);
    if (error) throw new Error(`site_icerik okunamadı (${error.code ?? "bilinmeyen"})`);
    const sayfa = (data ?? []) as IcerikSatiri[];
    satirlar.push(...sayfa);
    if (sayfa.length < SAYFA_BOYU) return satirlar;
  }
}
