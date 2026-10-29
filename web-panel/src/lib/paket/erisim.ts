import { createClient } from "@/utils/supabase/server";

// Supabase my_access() dönüşü: modül kodu → erişim bilgisi (20261130 P1 migration'ı).
export type ModulErisimDurumu = "tam" | "sinirli" | "onizleme" | "yok";

export type ModulErisim = {
  erisim: ModulErisimDurumu;
  gunluk_kota: number | null;
  kaynak: string;
  paket_kod: string | null;
};

const SIRA: Record<ModulErisimDurumu, number> = {
  yok: 0,
  onizleme: 1,
  sinirli: 2,
  tam: 3,
};

/**
 * Erişim, istenen seviyeye ulaşıyor mu? "sinirli" istenirse hem "sinirli" hem "tam" kabul edilir.
 * Kota kontrolü ayrıca yapılır (bu fonksiyon yalnız seviyeye bakar).
 */
export function erisimYeterliMi(
  erisim: ModulErisimDurumu,
  gereken: Exclude<ModulErisimDurumu, "yok">,
): boolean {
  return SIRA[erisim] >= SIRA[gereken];
}

/** Oturumdaki kullanıcının bir modüle erişimi. Oturum yoksa null; modül yoksa "yok". */
export async function modulErisimiGetir(modul: string): Promise<ModulErisim | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data, error } = await supabase.rpc("my_access");
  if (error || !data || typeof data !== "object") {
    // Hata durumunda kapalı (fail-closed): erişim yok say.
    return { erisim: "yok", gunluk_kota: null, kaynak: "hata", paket_kod: null };
  }

  const kayit = (data as Record<string, ModulErisim | undefined>)[modul];
  if (!kayit) return { erisim: "yok", gunluk_kota: null, kaynak: "yok", paket_kod: null };
  return kayit;
}
