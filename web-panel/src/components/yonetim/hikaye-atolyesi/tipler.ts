// Hikâye Atölyesi (yönetim) tipleri; alan adları OKUMA_RPC_SOZLESMESI.md ile birebir.
import type { DenetimDurumu, OkumaDurum } from "@/lib/okuma/okuma";

export interface SurumSatiri {
  hikaye_id: string;
  slug: string;
  surum_id: string;
  surum_no: number;
  durum: OkumaDurum;
  baslik: string;
  sha256: string;
  ana_sinif: number | null;
  okuma_zorlugu: number | null;
  kavram_zorlugu: number | null;
  temalar: string[] | null;
  ders_baglantisi: string[] | null;
  ana_deger: string | null;
  yardimci_deger: string | null;
  soru_sayisi: number | null;
  sayfa_sayisi: number | null;
  denetim: DenetimDurumu | null;
  olusturan_id: string | null;
  inceleyen_id: string | null;
  olusturuldu_at: string | null;
  yayin_at: string | null;
  oturum_sayisi: number | null;
}

export interface ListeYaniti {
  toplam: number;
  satirlar: SurumSatiri[];
}

// Paket parçaları (hikaye-paketi.v1). Önizleme yalnızca bilinen parça türlerini çizer.
export interface Parca {
  t: string;
  v?: string;
  hal?: string;
  yedek?: string;
  yuva?: string;
  anahtar?: string;
  kod?: string;
}
export type Sahneler = Record<string, Record<string, Parca[]>>;

export interface PaketSoru {
  id: string;
  beceri: string;
  dayanak_sayfa: number;
  metin: string;
  secenekler: { id: string; metin: string }[];
  dogru: string;
  aciklama: string;
}

export interface Paket {
  hikaye: { baslik: string; slug?: string; tanitim?: string; tur?: string };
  sayfalar: { omurga: boolean; parcalar: Parca[] }[];
  deger_sahneleri?: Sahneler;
  hareket_sahneleri?: Sahneler;
  deyim_cumleleri?: Record<string, Parca[]>;
  sorular: PaketSoru[];
}

export interface IcerikYaniti {
  surum_id: string;
  hikaye_id: string;
  surum_no: number;
  durum: OkumaDurum;
  sha256: string;
  denetim: DenetimDurumu | null;
  paket_denetimi: unknown;
  olusturan_id: string | null;
  inceleyen_id: string | null;
  paket: Paket;
}

export interface IceAktarYaniti {
  gecerli: boolean;
  yazildi: boolean;
  kuru: boolean;
  mevcut: boolean;
  surum_id?: string;
  hikaye_id?: string;
  surum_no?: number;
  sha256?: string;
  ozet?: {
    slug: string;
    baslik: string;
    ana_sinif: number;
    sayfa_sayisi: number;
    soru_sayisi: number;
    hedef_sayisi: number;
  };
  hatalar?: unknown[];
  uyarilar?: unknown[];
}

export interface DagilimSatiri {
  ana_sinif?: number;
  sinif?: number | null;
  tur?: string;
  hikaye?: number;
  oturum?: number;
  tamamlanan?: number;
}

export interface IstatistikYaniti {
  yayinda_hikaye: number;
  surum_durumlari: Partial<Record<OkumaDurum, number>>;
  toplam_oturum: number;
  tamamlanan_oturum: number;
  /** Yüzde 0-100; oturum yoksa null. */
  tamamlama_orani: number | null;
  /** Tamamlanan oturumlarda toplam doğru / toplam soru, yüzde 0-100; veri yoksa null. */
  ortalama_dogruluk: number | null;
  okunan_kelime: number;
  yayinda_sinif_dagilimi: DagilimSatiri[];
  yayinda_tur_dagilimi: DagilimSatiri[];
  oturum_sinif_dagilimi: DagilimSatiri[];
  oturum_tur_dagilimi: DagilimSatiri[];
}

export interface KarneSurumu {
  surum_id: string;
  surum_no: number;
  durum: OkumaDurum;
  min_n: number;
  baslatan_ogrenci: number;
  yeterli: boolean;
  oturum_sayisi?: number;
  tamamlama_orani?: number | null;
  ort_yildiz?: number | null;
  oy_sayisi?: number;
  sorun_kodlari?: Record<string, number> | null;
  birakilan_sayfa?: Record<string, number> | null;
  sorular?: {
    soru_id: string;
    yeterli: boolean;
    cevap_sayisi?: number;
    dogru_orani?: number | null;
    secenek_dagilimi?: Record<string, number> | null;
  }[];
}

export interface KarneYaniti {
  hikaye_id: string;
  slug: string;
  surumler: KarneSurumu[];
}

export interface BoslukHucre {
  ana_sinif: number;
  tema: string;
  deger: string;
  yayinda: number;
  incelemede: number;
}
export interface BoslukYaniti {
  hucreler: BoslukHucre[];
  temalar: string[];
  degerler: string[];
  siniflar: number[];
}

/** Sunucudan gelen hata/uyarı kalemi dize ya da nesne olabilir; ekrana güvenli metin üretir. */
export function kalemMetni(k: unknown): string {
  if (typeof k === "string") return k;
  if (k && typeof k === "object") {
    const o = k as Record<string, unknown>;
    const yol = typeof o.yol === "string" ? o.yol : typeof o.alan === "string" ? o.alan : typeof o.path === "string" ? o.path : "";
    const mesaj =
      typeof o.mesaj === "string" ? o.mesaj : typeof o.message === "string" ? o.message : typeof o.kod === "string" ? o.kod : JSON.stringify(k);
    return yol ? `${yol}: ${mesaj}` : mesaj;
  }
  return String(k);
}

/** Karne uyarı eşikleri (yüzde, 0-100). Tek yerde tutulur; karne satırlarının hepsi bunu kullanır. */
export const KARNE_ESIKLERI = { tamamlamaMin: 70, anlamaMin: 60 } as const;

export type TopluIslem = "arsiv" | "sil" | "yayina_al" | "yayindan_cek";

export interface TopluSonucSatiri {
  hikaye_id: string;
  slug: string | null;
  sonuc: "basarili" | "atlandi";
  neden: string | null;
  ayrinti: string | null;
  etkilenen_surum: number | null;
}

export interface TopluYaniti {
  islem: TopluIslem;
  kuru: boolean;
  basarili: number;
  atlanan: number;
  sonuclar: TopluSonucSatiri[];
}