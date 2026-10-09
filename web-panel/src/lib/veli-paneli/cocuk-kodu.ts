"use server";

import { createClient } from "@/utils/supabase/server";

export type CocukKoduSonucu =
  | { ok: true; kod: string; sonKullanma: string }
  | { ok: false };

// Veli için 24 saat geçerli, tek kullanımlık çocuk eşleştirme kodu üretir.
// Rol ve kod üretimi veritabanındaki create_parent_link_code() RPC'sinde denetlenir.
export async function olusturCocukEslestirmeKodu(): Promise<CocukKoduSonucu> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("create_parent_link_code");
    if (error) return { ok: false };

    const kayit = data as { kod?: unknown; son_kullanma?: unknown } | null;
    if (typeof kayit?.kod !== "string" || typeof kayit.son_kullanma !== "string") {
      return { ok: false };
    }
    return { ok: true, kod: kayit.kod, sonKullanma: kayit.son_kullanma };
  } catch {
    return { ok: false };
  }
}
