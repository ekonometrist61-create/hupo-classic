// Veli: Okuma Dünyası özet sözleşmesi (okuma_veli_ozeti). Alan adları OKUMA_RPC_SOZLESMESI.md ile birebir.

export interface SoruDogrulugu {
  yeterli: boolean;
  soru?: number;
  dogru?: number;
  yanlis?: number;
  oran?: number;
}

/** Haftalık zorluk seyri satırı (veli: kendi çocuğu; öğretmen sınıfı: ogrenci_sayisi ile, en az 3 öğrenci). */
export interface ZorlukHaftasi {
  hafta: string;
  hikaye: number;
  ogrenci_sayisi?: number;
  ort_okuma_zorlugu: number | null;
  ort_kavram_zorlugu: number | null;
}

export interface DagilimKalemi {
  tema?: string;
  deger?: string;
  ders?: string;
  ad: string | null;
  hikaye: number;
}

/** Öğrenme hedefi satırı (kavram / atasözü-deyim / sözcük): ad + durum + son görüldüğü hikâye. */
export interface HedefSatiri {
  hedef_id: string;
  etiket: string;
  tur: string;
  durum: string;
  hikaye: string | null;
  /** Dönem içinde bu hedefe bağlı sorular (20261078+). */
  soru?: number;
  dogru?: number;
  yanlis?: number;
}

export interface SonHikaye {
  hikaye_id: string;
  baslik: string;
  tur: string;
  tarih: string;
  tamamlandi: boolean;
  dogru: number;
  soru: number;
}

export interface TurKalemi {
  tur: string;
  hikaye: number;
  oturum: number;
}

export interface OkumaOzet {
  gun: number;
  detay: boolean;
  okunan_hikaye: number;
  tamamlanan_hikaye: number;
  okunan_kelime?: number;
  toplam_sure_dk?: number;
  son_hikayeler?: SonHikaye[];
  tur_dagilimi?: TurKalemi[];
  kavramlar?: HedefSatiri[];
  atasozleri?: HedefSatiri[];
  kelimeler?: HedefSatiri[];
  olcme_turu_dogrulugu?: Record<string, SoruDogrulugu>;
  ortalama_sure_dk?: number | null;
  soru_dogrulugu?: Record<string, SoruDogrulugu>;
  dogruluk_toplami?: SoruDogrulugu;
  tema_dagilimi?: DagilimKalemi[];
  deger_dagilimi?: DagilimKalemi[];
  ders_dagilimi?: DagilimKalemi[];
  zorluk_seyri?: ZorlukHaftasi[];
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

/** Soru türü (ölçme türü) anahtarları. */
export const OLCME_TURLERI = ["metin_kaniti", "kavram_dogrulugu", "transfer"] as const;

/** Çatı değerler (sözlükte D kodu): Adalet, Saygı, Sorumluluk. */
export const CATI_DEGERLER = ["D1", "D14", "D16"] as const;
