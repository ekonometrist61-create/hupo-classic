// Yönetim paneli ve soru yönetiminin ortak tipleri.
// Hem `panel/` hem `sorular/` altındaki bileşenler bu dosyayı `../types` ile import eder.
// Sunucudaki public.* view ve fonksiyon dönüş şekilleriyle birebir eşleşir.

// ---------------------------------------------------------------------
// Ortak yardımcılar
// ---------------------------------------------------------------------

/** Sayfalı listelerde standart dönüş şekli (public._soru_sayfalama ve veli arama RPC'leri). */
export interface Paged<T> {
  satirlar: T[];
  toplam: number;
}

// ---------------------------------------------------------------------
// Kullanıcılar
// ---------------------------------------------------------------------

export type UserRole = "veli" | "ogrenci" | "admin" | "ogretmen";

/** public.admin_kullanicilar view'ı. */
export interface AdminUser {
  id: string;
  email: string | null;
  /** Veli adı; öğrenci kayıtlarında öğrencinin adı. */
  ad: string | null;
  veli_ad: string | null;
  rol: UserRole;
  /** Öğrencinin sınıfı; veli kayıtlarında null. */
  sinif: string | null;
  /** Bağlı veli hesabının adı; bağ yoksa null. */
  veli_adi: string | null;
  /** Bağlı çocuk sayısı (veli hesapları için). */
  cocuk_sayisi: number;
  /** Üyelik başlangıç tarihi. */
  uyelik_tarihi: string | null;
  kayit_tarihi: string | null;
  /** Veli panelinden ilişkilendirilen çocuğun id'si (yoksa null). */
  veli_id: string | null;
  /** Bağlı öğrencinin okunan adı; ilişki yoksa null. */
  ogrenci_ad: string | null;
}

// ---------------------------------------------------------------------
// Planlar ve ödemeler
// ---------------------------------------------------------------------

/** public.plans tablosu. */
export interface Plan {
  id: string;
  /** Kisa kod, örn. "aylik" / "yillik". */
  kod: string;
  ad: string;
  aciklama: string | null;
  /** Kurus cinsinden tutar. */
  fiyat_kurus: number;
  /** Abonelik suresi (gun); null ise sure sinirsiz. */
  sure_gun: number | null;
  aktif: boolean;
}

export type PaymentStatus =
  | "beklemede"
  | "basarili"
  | "basarisiz"
  | "iade";

/** public.admin_odemeler view'ı. */
export interface AdminPayment {
  id: string;
  veli_id: string | null;
  veli_ad: string | null;
  veli_email: string | null;
  plan_id: string | null;
  plan_ad: string | null;
  /** Plan silinmişse kod buradan gelir. */
  plan_kod: string | null;
  /** Ödeme sağlayıcısı (iyzico, manual, ...). */
  saglayici: string;
  aciklama: string | null;
  tutar_kurus: number;
  durum: PaymentStatus;
  tarih: string;
}

/** Ödeme listesi RPC'si; satırlar ve sayaçlarla birlikte döner. */
export interface PaymentList {
  satirlar: AdminPayment[];
  toplam: number;
  onayli_adet: number;
  bekleyen_adet: number;
  reddedilen_adet: number;
  /** Onaylanan ödemelerin toplam tutarı (kuruş). */
  basarili_tutar_kurus: number;
}
// ---------------------------------------------------------------------
// Sorular
// ---------------------------------------------------------------------

export type QuestionStatus = "beklemede" | "onaylandi" | "reddedildi";

/** Şıklar "A".."E" anahtarlı; sunucu jsonb olarak saklar. */
export type QuestionOptions = Record<string, string>;

/** public.sorular tablosunun kayıt şekli (liste görünümü). */
export interface AdminQuestion {
  id: string;
  okul: string;
  ders: string;
  konu: string;
  /** Alt konu opsiyoneldir; sunucu null dönebilir. */
  alt_konu: string | null;
  /** 1 = Kolay, 2 = Orta, 3 = Zor. */
  zorluk: 1 | 2 | 3;
  soru_metni: string;
  siklar: QuestionOptions;
  dogru_sik: string;
  cozum_adimlari: string[];
  onay_durumu: QuestionStatus;
  created_at: string;
}

/** Form ve toplu içe aktarım için gönderilen soru gövdesi.
 *  Alan adları veritabanı kolon adlarıyla aynıdır. */
export interface QuestionInput {
  okul: string;
  ders: string;
  konu: string;
  /** Zorunlu değil; boş bırakılırsa null gönderilir. */
  alt_konu: string | null;
  zorluk: number;
  soru_metni: string;
  siklar: QuestionOptions;
  dogru_sik: string;
  cozum_adimlari: string[];
  onay_durumu?: QuestionStatus;
}

// ---------------------------------------------------------------------
// Toplu içe aktarım (CSV)
// ---------------------------------------------------------------------

export interface ImportError {
  /** Hatanın ait olduğu dosya satırı (başlık = 1). */
  satir: number;
  hata: string;
}

export interface ImportResult {
  eklenen: number;
  tekrar: number;
  hatali: number;
  hatalar: ImportError[];
}

// ---------------------------------------------------------------------
// Yönetim paneli özeti
// ---------------------------------------------------------------------

/** public.admin_dashboard_su özeti. */
export interface DashboardSummary {
  kullanicilar: {
    veli: number;
    ogrenci: number;
    /** Veli hesabı olup hiç çocuğu bağlanmamış olanların sayısı. */
    bagsiz_ogrenci: number;
    /** Son 30 günde kaydolan yeni veli sayısı. */
    son_30_gun_yeni: number;
  };
  abonelikler: {
    /** Aktif abonelik sayısı. */
    aktif: number;
    /** Ömrü 7 gün içinde dolacak abonelik sayısı. */
    yakinda_bitecek: number;
  };
  sorular: {
    toplam: number;
    onayli: number;
    bekleyen: number;
    reddedilen: number;
    /** Ders başına soru dağılımı. */
    ders_dagilimi: { ders: string; adet: number }[];
  };
  odemeler: {
    /** Bu ay onaylanan ödeme tutarı (kuruş). */
    bu_ay_kurus: number;
    /** Geçen ay onaylanan ödeme tutarı (kuruş). */
    gecen_ay_kurus: number;
    basarili_adet: number;
    bekleyen_adet: number;
    basarisiz_adet: number;
    iade_adet: number;
    /** Aylara göre gelir dağılımı (grafik için). */
    aylik: { label: string; ay: string; tutar_kurus: number; adet: number }[];
  };
  /** Son yapılan ödemeler. */
  son_odemeler: {
    veli_ad: string | null;
    tutar_kurus: number;
    durum: PaymentStatus;
    tarih: string;
  }[];
  /** Son yönetim işlemleri (log). */
  son_islemler: {
    islem: string;
    admin_ad: string | null;
    tarih: string;
  }[];
}
