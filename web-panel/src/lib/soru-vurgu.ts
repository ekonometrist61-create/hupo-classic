// Akıllı soru vurgulama: saf mantık (React'ten bağımsız, Node'da test edilir).
//
// Sözleşme (Flutter'daki lib/utils/soru_vurgu.dart ile birebir aynı):
//  - Metin DEĞİŞMEZ; vurgu ayrı metadata'dır: highlights = [{ start, end }].
//  - start/end KOD NOKTASI (Unicode code point) ofsetidir, soru KÖKÜ metnine göredir.
//    start dahil, end hariç: [start, end). JS'in UTF-16 indeksi DEĞİLDİR; emoji gibi
//    vekil çift (surrogate pair) içeren metinde de doğru kesilir. Dart tarafı da runes kullanır.
//  - Aralıklar artan sırada, çakışmasız ve 0 <= start < end <= kod noktası sayısı olmalı.
//    Herhangi biri geçersizse TÜM vurgu düşer ve düz metin gösterilir (sessiz düşüş, hata atmaz).
//  - Seçenek metinleri ve doğru cevap durumuyla ilgisi yoktur; yalnız soru köküne uygulanır.

export type VurguAraligi = { start: number; end: number };
export type VurguParcasi = { metin: string; vurgulu: boolean };

/** Ham veriyi (jsonb) doğrular. Geçerliyse aralık listesi, değilse null döner. */
export function vurguAraliklariniDogrula(
  kodNoktasiSayisi: number,
  highlights: unknown,
): VurguAraligi[] | null {
  if (!Array.isArray(highlights) || highlights.length === 0) return null;
  const sonuc: VurguAraligi[] = [];
  let oncekiBitis = 0;
  for (const oge of highlights) {
    if (oge === null || typeof oge !== "object") return null;
    const { start, end } = oge as { start?: unknown; end?: unknown };
    if (typeof start !== "number" || typeof end !== "number") return null;
    if (!Number.isInteger(start) || !Number.isInteger(end)) return null;
    if (start < oncekiBitis || end <= start || end > kodNoktasiSayisi) return null;
    sonuc.push({ start, end });
    oncekiBitis = end;
  }
  return sonuc;
}

/**
 * Metni vurgulu/vurgusuz parçalara böler. Birleştirilen parçalar her zaman özgün metne eşittir.
 * Geçersiz veya boş highlights için tek parça (düz metin) döner.
 */
export function vurguParcalari(metin: string, highlights: unknown): VurguParcasi[] {
  const duz: VurguParcasi[] = [{ metin, vurgulu: false }];
  if (!metin) return duz;
  const kodNoktalari = Array.from(metin);
  const araliklar = vurguAraliklariniDogrula(kodNoktalari.length, highlights);
  if (!araliklar) return duz;

  const parcalar: VurguParcasi[] = [];
  let imlec = 0;
  for (const { start, end } of araliklar) {
    if (start > imlec) parcalar.push({ metin: kodNoktalari.slice(imlec, start).join(""), vurgulu: false });
    parcalar.push({ metin: kodNoktalari.slice(start, end).join(""), vurgulu: true });
    imlec = end;
  }
  if (imlec < kodNoktalari.length) {
    parcalar.push({ metin: kodNoktalari.slice(imlec).join(""), vurgulu: false });
  }
  return parcalar;
}
