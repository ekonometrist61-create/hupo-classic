// Yönetim Merkezi (CRM profili, segment, kampanya, anket, otomasyon, analitik) tipleri.
// Şekiller 20261007000010/20/30 migration'larındaki RPC dönüşleriyle eşleşir.

export type Channel = "eposta" | "push" | "sms" | "uygulama_ici";
export const CHANNELS: Channel[] = ["eposta", "push", "sms", "uygulama_ici"];

// ---- Aile profili -------------------------------------------------------
export interface VeliProfile {
  veli: { id: string; ad: string | null; email: string | null; uyelik_tarihi: string };
  cocuklar: { id: string; ad: string | null; sinif: number | null; son_aktif: string | null }[];
  abonelik: {
    plan_kod: string;
    plan_ad: string;
    durum: string;
    baslangic: string;
    bitis: string;
  } | null;
  tercihler: { kanal: Channel; izin: boolean; kaynak: string | null; guncelleme: string | null }[];
  notlar: { id: string; metin: string; yazar: string | null; tarih: string }[];
  zaman_cizelgesi: {
    tur: "kayit" | "odeme" | "islem" | "tercih";
    zaman: string;
    detay: Record<string, unknown>;
  }[];
}

// ---- Segment ------------------------------------------------------------
export interface SegmentCriteria {
  plan?: string[];
  sinif?: number[];
  aktiflik?: "aktif_7" | "pasif_7" | "pasif_30";
  ilk_gorev_bekleyen?: boolean;
  yenileme_yaklasan?: boolean;
}

export interface SegmentPreview {
  toplam: number;
  izinli: number;
  haric: number;
  ornek: { veli_id: string; ad: string | null; izinli: boolean }[];
}

export interface Segment {
  id: string;
  ad: string;
  aciklama: string | null;
  kriterler: SegmentCriteria;
  created_at: string;
  veli_sayisi: number;
  izinli_eposta: number;
}

// ---- Kampanya -----------------------------------------------------------
export type CampaignStatus = "taslak" | "kontrol_edildi" | "planlandi" | "iptal";

export interface PreflightResult {
  hedef: number;
  izinli: number;
  izin_haric: number;
  sinir_haric: number;
  gonderilecek: number;
  sessiz_saat: boolean;
  haftalik_limit: number;
  planlanan_at: string;
  kontrol_zamani: string;
}

export interface IletisimKampanya {
  id: string;
  ad: string;
  kanal: Channel;
  segment_id: string;
  segment_ad: string;
  baslik: string;
  mesaj: string;
  durum: CampaignStatus;
  planlanan_at: string | null;
  onkontrol: PreflightResult | null;
  created_at: string;
}

export interface IletisimAyarlari {
  haftalik_limit: number;
  sessiz_baslangic: string;
  sessiz_bitis: string;
  zaman_dilimi: string;
  updated_at: string;
}

// ---- Anket --------------------------------------------------------------
export type QuestionType =
  | "kisa_metin"
  | "uzun_metin"
  | "tek_secim"
  | "nps"
  | "csat"
  | "onay";

export interface SurveyQuestion {
  id: string;
  tur: QuestionType;
  baslik: string;
  secenekler?: string[];
  kosul?: { soru_id: string; op: "lte" | "gte" | "eq"; deger: number } | null;
}

export interface Survey {
  id: string;
  ad: string;
  anonim: boolean;
  durum: "taslak" | "yayinda" | "kapali";
  sorular: SurveyQuestion[];
  surum: number;
  tekrar_gosterim_gun: number;
  created_at: string;
  yanit_sayisi: number;
}

export interface SurveyResult {
  anket: { id: string; ad: string; anonim: boolean; surum: number; durum: string };
  yanit_sayisi: number;
  nps: {
    n: number;
    destekleyen: number;
    pasif: number;
    elestiren: number;
    skor: number | null;
  };
  sorular: { soru_id: string; baslik: string; tur: QuestionType; yanit: number; ortalama: number | null }[];
  metinler: { soru_id: string; metin: string; tarih: string }[];
}

export interface SupportTask {
  id: string;
  veli_id: string;
  veli_ad: string | null;
  kaynak: string;
  durum: "acik" | "kapali";
  kapatma_notu: string | null;
  created_at: string;
  kapatildi_at: string | null;
  nps: number | null;
}

// ---- Otomasyon ----------------------------------------------------------
export type JourneyTrigger =
  | "veli_kayit"
  | "ilk_gorev_bekleyen"
  | "yenileme_yaklasan"
  | "pasif_7_gun";

export type JourneyStep =
  | { tur: "bekle"; saat: number }
  | { tur: "kosul"; olcut: "ilk_gorev_tamamlandi" | "abonelik_aktif" | "izin_var" }
  | { tur: "mesaj"; kanal: Channel; baslik: string };

export interface Journey {
  id: string;
  ad: string;
  giris_olayi: JourneyTrigger;
  adimlar: JourneyStep[];
  durum: "taslak" | "hazir" | "duraklatildi";
  surum: number;
  created_at: string;
}

// ---- Analitik / mutabakat / denetim --------------------------------------
export interface AnalyticsSummary {
  gun: number;
  huni: { kayit: number; cocuk_bagladi: number; ilk_ogrenme: number; ucretli: number };
  kohort: { hafta: string; boyut: number; tutma: (number | null)[] }[];
  ogrenme: {
    ogrenci: number;
    aktif_7_gun: number;
    dogruluk_yuzde: number | null;
    tekrar_zamani_gelen: number;
  };
}

export interface ReconciliationItem {
  tur: "bekleyen_eski" | "abonelik_yok" | "suresi_gecmis_aktif" | "yinelenen";
  kayit_id: string;
  veli_ad: string | null;
  tutar_kurus: number | null;
  tarih: string;
}

export interface AuditRow {
  id: string;
  zaman: string;
  admin_ad: string | null;
  islem: string;
  detay: Record<string, unknown>;
}

export interface TeamMember {
  id: string;
  rol: "admin" | "ogretmen";
  ad: string | null;
  email: string | null;
  son_islem: string | null;
  islem_30_gun: number;
}
