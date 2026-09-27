// Veli paneli ortak tipleri.
// public.veli_paneli_ozet ve ilgili RPC'lerden gelen veriyi tanimlar.
// Alan adlari bilesenlerdeki kullanimla birebir ortusur.

/** Bagli ogrenci (public.profiles, veli_id ile eslesen kayit). */
export interface Student {
  id: string;
  full_name: string | null;
  username: string | null;
  avatar_url: string | null;
  /** public.veli_paneli_ozet icindeki sinif bilgisi. */
  sinif: string | null;
}

/** Ogrencinin genel calisma ozeti (public.get_student_dashboard -> ozet). */
export interface StudentSummary {
  xp: number;
  level: number;
  streak_count: number;
  /** Toplam cozulen soru; istatistik kartlarinda kullanilir. */
  toplam_soru?: number;
  rozet_sayisi?: number;
}

/** Ders bazinda basari orani (SubjectSuccessChart). */
export interface SubjectSuccess {
  ders: string;
  oran: number;
  dogru: number;
  toplam: number;
}

/** Tek gunluk calisma kaydi (WeeklyStudyChart). */
export interface DailyStudy {
  /** "YYYY-MM-DD" */
  gun: string;
  sure_dk: number | string;
  soru_sayisi: number;
  dogru_sayisi: number;
}

/** Tekrar edilmesi onerilen konu (ReviewTopicsList). */
export interface ReviewTopic {
  konu: string;
  ders: string;
  yanlis: number;
  bekleyen: number;
  /** Yuzde 0-100; yeterli veri yoksa null. */
  oran: number | null;
}

/** Veli paneli ozet verisi (public.get_student_dashboard donusu). */
export interface DashboardData {
  cocuk: Student | null;
  /** Ogrencinin genel ozeti. */
  ozet: StudentSummary;
  /** Son 7 gunun gunluk kayitlari. */
  haftalik: DailyStudy[];
  /** Ders bazinda basari oranlari. */
  ders_basari: SubjectSuccess[];
  /** Tekrar onerilen konular. */
  tekrar_konulari: ReviewTopic[];
  /** Cocuk verisinin kullanilabilmesi icin veli onayi ("yok" | "verildi" | "geri_cekildi"). */
  riza: string;
  /** Veli adi. */
  veli_ad: string | null;
}
