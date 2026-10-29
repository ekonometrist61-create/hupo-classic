import { createClient } from "@/utils/supabase/client";

/** Müfredat planının yılı (mufredat_hafta.kaynak_yili). 2025-2026 kayıtları yalnız DKAB 4/8 içindir. */
export const MUFREDAT_YILI = "2026-2027";

/** PostgREST tek istekte en fazla bu kadar satır döndürür; daha fazlası sayfalanır. */
const SAYFA_BOYU = 1000;

/** Kazanım seçicide gösterilen tek bir kazanım (hafta satırlarının kod bazında özeti). */
export interface KazanimSecenek {
  kod: string;
  metin: string;
  /** Kazanımın müfredatta ilk göründüğü hafta (min(hafta)). */
  ilkHafta: number;
  uniteTema: string | null;
}

interface SorguSonucu<T> {
  data: T[] | null;
  error: { message: string } | null;
}

/** Tüm satırları sayfa sayfa okur (sayfa boyu dolmayınca durur). */
async function tumSatirlar<T>(
  sorgu: (from: number, to: number) => PromiseLike<SorguSonucu<T>>,
): Promise<T[]> {
  const satirlar: T[] = [];
  for (let from = 0; ; from += SAYFA_BOYU) {
    const { data, error } = await sorgu(from, from + SAYFA_BOYU - 1);
    if (error) throw new Error(error.message);
    const parca = data ?? [];
    satirlar.push(...parca);
    if (parca.length < SAYFA_BOYU) return satirlar;
  }
}

/** Verilen sınıfta, kazanım kodu olan müfredat derslerini (tekil, sıralı) döndürür. */
export async function fetchDersler(sinif: number): Promise<string[]> {
  const supabase = createClient();
  const satirlar = await tumSatirlar<{ ders: string }>((from, to) =>
    supabase
      .from("mufredat_hafta")
      .select("ders")
      .eq("kaynak_yili", MUFREDAT_YILI)
      .eq("sinif", sinif)
      .neq("kazanim_kodu", "")
      .order("id", { ascending: true })
      .range(from, to),
  );
  const tekil = new Set(satirlar.map((s) => s.ders));
  return [...tekil].sort((a, b) => a.localeCompare(b, "tr"));
}

interface MufredatSatir {
  kazanim_kodu: string;
  kazanim_metni: string | null;
  hafta: number;
  unite_tema: string | null;
}

/** Ders + sınıf için kazanımları kod bazında gruplar; her kod için en erken hafta alınır. */
export async function fetchKazanimlar(
  ders: string,
  sinif: number,
): Promise<KazanimSecenek[]> {
  const supabase = createClient();
  const satirlar = await tumSatirlar<MufredatSatir>((from, to) =>
    supabase
      .from("mufredat_hafta")
      .select("kazanim_kodu, kazanim_metni, hafta, unite_tema")
      .eq("kaynak_yili", MUFREDAT_YILI)
      .eq("ders", ders)
      .eq("sinif", sinif)
      .neq("kazanim_kodu", "")
      .order("id", { ascending: true })
      .range(from, to),
  );

  const kodlar = new Map<string, KazanimSecenek>();
  for (const s of satirlar) {
    const mevcut = kodlar.get(s.kazanim_kodu);
    if (!mevcut) {
      kodlar.set(s.kazanim_kodu, {
        kod: s.kazanim_kodu,
        metin: s.kazanim_metni ?? "",
        ilkHafta: s.hafta,
        uniteTema: s.unite_tema,
      });
      continue;
    }
    if (s.hafta < mevcut.ilkHafta) mevcut.ilkHafta = s.hafta;
    if (!mevcut.metin && s.kazanim_metni) mevcut.metin = s.kazanim_metni;
    if (!mevcut.uniteTema && s.unite_tema) mevcut.uniteTema = s.unite_tema;
  }

  return [...kodlar.values()].sort(
    (a, b) => a.ilkHafta - b.ilkHafta || a.kod.localeCompare(b.kod, "tr"),
  );
}
