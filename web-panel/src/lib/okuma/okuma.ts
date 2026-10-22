// Okuma Dünyası ("Senin Hikâyen") web paneli ortak tipleri ve yardımcıları.
// Sözleşme: OKUMA_RPC_SOZLESMESI.md. Sunucu kuralları (dört göz, yayın kapısı, rıza, min-N)
// RPC'de uygulanır; panel yalnızca gösterir ve hatayı Türkçe iletir.

export type OkumaDurum = "taslak" | "incelemede" | "yayinda" | "arsiv";
export const OKUMA_DURUMLARI: OkumaDurum[] = ["taslak", "incelemede", "yayinda", "arsiv"];

export type Beceri = "hatirlama" | "cikarim" | "yorumlama" | "degerlendirme" | "sozcuk_baglami";
// Veli ve öğretmen için gösterim sırası (dört işlem türü, sonra sözcük bağlamı).
export const BECERILER: Beceri[] = ["hatirlama", "cikarim", "yorumlama", "degerlendirme", "sozcuk_baglami"];

export type DenetimDurumu = {
  ajan_a?: "pending" | "pass" | "fail" | "review_needed";
  ajan_b?: "pending" | "pass" | "fail" | "review_needed";
  insan?: "pending" | "approved" | "rejected";
};

export interface DegerKalemi {
  kod: string;
  ad: string;
}

// Sunucu hata kodları → çeviri anahtarı (hatalar.*). Eşleşmeyen kod "genel" metnine düşer.
const BILINEN_HATALAR = [
  "YAYIN_KAPISI",
  "DORT_GOZ",
  "SURUM_DEGISMEZ",
  "GECERSIZ_GECIS",
  "BAD_DURUM",
  "BAD_DENETIM",
  "SURUM_BULUNAMADI",
  "HIKAYE_BULUNAMADI",
  "SURUM_YAYINDA",
  "SURUM_SILINEMEZ",
  "OTURUM_VAR",
  "BAD_AYAR_ANAHTARI",
  "BAD_AYAR",
  "BAD_TUR",
  "BAD_ANAHTAR",
  "BAD_AD",
  "BAD_ID",
  "BAD_ETIKET",
  "BAD_SINIF",
  "BAD_KANIT",
  "EN_FAZLA_BES",
  "TEKRARLI_DEGER",
  "GECERSIZ_DEGER",
  "FORBIDDEN",
] as const;

export function hataAnahtari(mesaj: string): string {
  if (mesaj === "DEMO") return "demo";
  if (/admin yetkisi gerekir|ADMIN_ONLY/i.test(mesaj)) return "yetki";
  const bulunan = BILINEN_HATALAR.find((kod) => mesaj.includes(kod));
  return bulunan ?? "genel";
}

/** "BAD_AYAR: 0-50 olmalı" gibi sunucu mesajlarından açıklayıcı kısmı alır (sunucu metni Türkçedir). */
export function hataAyrinti(mesaj: string): string | null {
  const m = /BAD_AYAR: (.+)$/.exec(mesaj);
  return m ? m[1].trim() : null;
}

/** Yüzde değeri: null/undefined → null (sıfır sayılmaz). */
export function yuzde(deger: number | null | undefined): string | null {
  return deger === null || deger === undefined ? null : `%${Math.round(deger)}`;
}
