// Veli: Okuma Dünyası özet sözleşmesi (okuma_veli_ozeti). Alan adları OKUMA_RPC_SOZLESMESI.md ile birebir.

export interface SoruDogrulugu {
  yeterli: boolean;
  soru?: number;
  dogru?: number;
  oran?: number;
}

export interface DagilimKalemi {
  tema?: string;
  deger?: string;
  ders?: string;
  ad: string | null;
  hikaye: number;
}

export interface OkumaOzet {
  gun: number;
  detay: boolean;
  okunan_hikaye: number;
  tamamlanan_hikaye: number;
  ortalama_sure_dk?: number | null;
  soru_dogrulugu?: Record<string, SoruDogrulugu>;
  tema_dagilimi?: DagilimKalemi[];
  deger_dagilimi?: DagilimKalemi[];
  ders_dagilimi?: DagilimKalemi[];
  zorluk_seyri?: { hafta: string; hikaye: number; ort_okuma_zorlugu: number | null; ort_kavram_zorlugu: number | null }[];
  hedef_durumlari?: Record<string, number>;
  pekisen_hedefler?: { hedef_id: string; etiket: string; durum: string }[];
  cocuk_puani?: { oy: number; ortalama: number | null; sevilen_temalar: string[] };
}

export interface OkumaOzetYaniti {
  riza: boolean;
  riza_durumu: "yok" | "geri_cekildi" | "verildi";
  ozet: OkumaOzet | null;
}

/** Hedef durum sırası (öğrenme basamağı); "tekrar zamanı" ayrı bir durumdur. */
export const HEDEF_DURUMLARI = ["introduced", "recognized", "retrieved", "transferred", "refresh_due"] as const;

/** Çatı değerler (sözlükte D kodu): Adalet, Saygı, Sorumluluk. */
export const CATI_DEGERLER = ["D1", "D14", "D16"] as const;
