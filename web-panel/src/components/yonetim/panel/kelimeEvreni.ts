// Kelime Evreni yönetim ekranlarının ortak tipleri ve sunucu hata eşlemesi.

export type KelimeDurum = "taslak" | "incelemede" | "yayinda" | "arsiv";
export type KelimeIliskiTuru =
  | "es_anlamli"
  | "zit_anlamli"
  | "es_sesli"
  | "deyim"
  | "atasozu"
  | "sozcuk_turu"
  | "baglamda_anlam";

export interface AnlamSecenegi {
  id: string;
  kelime: string;
  anlam: string;
}

// Sunucu hata kodu → çeviri anahtarı. Eşleşmeyen kod "genel" metnine düşer.
const BILINEN_HATALAR = [
  "DORT_GOZ",
  "DENETIM_EKSIK",
  "DENETIM_HEDEFI_INCELEMEDE_DEGIL",
  "BAD_LISTE",
  "ILISKI_ONAYSIZ",
  "GECERSIZ_GECIS",
  "DUZENLENEMEZ",
  "SECENEK_TEKRARI",
  "BAD_SECENEK_SAYISI",
  "BAD_SECENEK",
  "BAD_DOGRU_INDEKS",
  "BAD_ZORLUK",
  "SORU_BULUNAMADI",
  "ANLAM_BULUNAMADI",
  "ILISKI_BULUNAMADI",
  "ADMIN_ONLY",
] as const;

export function hataAnahtari(mesaj: string): string {
  const bulunan = BILINEN_HATALAR.find((kod) => mesaj.includes(kod));
  return bulunan ?? "genel";
}
