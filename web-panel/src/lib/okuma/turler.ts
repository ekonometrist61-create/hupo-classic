// Okuma Dünyası hikâye türleri: sunucu anahtarı → Türkçe etiket (mobil uygulamadaki 12 tür ile aynı).
// Bilinmeyen tür anahtarı çökmez; okunabilir hâle getirilip gösterilir.
export const TUR_ETIKETLERI = {
  gizem: "Gizem",
  macera: "Macera",
  bilim: "Bilim",
  doga: "Doğa",
  mizah: "Mizah",
  hayvanlar: "Hayvanlar",
  arkadaslik: "Arkadaşlık",
  fantastik: "Fantastik",
  spor: "Spor",
  tarih_kultur: "Tarih ve kültür",
  bilim_kurgu: "Bilim kurgu",
  gezi_kultur: "Gezi ve kültür",
} as const;

export type HikayeTuru = keyof typeof TUR_ETIKETLERI;

export const HIKAYE_TURLERI = Object.keys(TUR_ETIKETLERI) as HikayeTuru[];

/** Tür anahtarının Türkçe etiketi; tanınmayan anahtar için alt çizgisiz hâli. */
export function turEtiketi(tur: string | null | undefined): string {
  if (!tur) return "-";
  return (TUR_ETIKETLERI as Record<string, string>)[tur] ?? tur.replace(/_/g, " ");
}