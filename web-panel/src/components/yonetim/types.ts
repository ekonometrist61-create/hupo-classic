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
// Veli adayları (CRM leads)
// ---------------------------------------------------------------------

/** Satış/pazarlama hunisi aşamaları (veli_adaylari.asama ile birebir). */
export type LeadStage = "yeni" | "iletisim" | "deneme" | "musteri" | "kapandi";

/** public.admin_list_veli_adaylari() satır şekli. */
export interface VeliAday {
  id: string;
  email: string;
  ad: string;
  telefon: string | null;
  kaynak: string;
  asama: LeadStage;
  pazarlama_izni: boolean;
  izin_at: string | null;
  /** Aday gerçek bir veli hesabına dönüştüyse o hesabın id'si. */
  veli_id: string | null;
  created_at: string;
  updated_at: string;
}

/** public.olay_kutusu kaydı (admin_veli_adayi_detay zaman çizelgesi). */
export interface OutboxEvent {
  tur: string;
  payload: Record<string, unknown>;
  created_at: string;
  islendi_at: string | null;
}

/** admin_veli_adayi_detay() dönüşü. */
export interface VeliAdayDetay {
  aday: VeliAday;
  olaylar: OutboxEvent[];
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

// ---------------------------------------------------------------------
// Potansiyel adaylar (Growth CRM, üst huni)
// ---------------------------------------------------------------------

/** admin_prospect_listele() dönüş şekli. */
export interface GrowthProspectList {
  rows: GrowthProspect[];
  total: number;
}

/** public.growth_prospects liste satırı (admin_prospect_listele). */
export interface GrowthProspect {
  id: string;
  display_name: string;
  email: string | null;
  phone: string | null;
  /** individual, household, institution, referral, partner */
  kind: string;
  /** new, enriched, scored, qualified, nurturing, converted, disqualified, suppressed */
  status: string;
  source_type: string | null;
  source_detail: string | null;
  total_score: number;
  fit_score: number;
  intent_score: number;
  engagement_score: number;
  data_quality_score: number;
  tags: string[];
  created_at: string;
  updated_at: string;
}

/** admin_prospect_detay() dönüşü. */
export interface ProspectDetay {
  prospect: GrowthProspect & {
    utm_source: string | null;
    utm_medium: string | null;
    utm_campaign: string | null;
    notes: string | null;
    converted_household_id: string | null;
    converted_lead_id: string | null;
  };
  consents: Array<{
    id: string;
    channel: string;
    /** granted, denied, pending, expired */
    status: string;
    legal_basis: string | null;
    granted_at: string | null;
    expires_at: string | null;
  }>;
  events: Array<{
    id: string;
    event_type: string;
    event_name: string;
    channel: string | null;
    created_at: string;
    metadata: Record<string, unknown>;
  }>;
  provenance: Array<{
    id: string;
    provider: string;
    match_type: string;
    confidence: number;
    fetched_at: string;
    raw_payload: Record<string, unknown>;
  }>;
  score_history: Array<{
    id: string;
    total_score: number;
    fit_score: number;
    intent_score: number;
    engagement_score: number;
    data_quality_score: number;
    computed_at: string;
    reason: string | null;
  }>;
}

// ---------------------------------------------------------------------
// Müşteri 360° (Growth CRM)
// ---------------------------------------------------------------------

/** admin_musteri_360_listele() satır şekli (hane / müşteri ana kaydı). */
export interface GrowthHousehold {
  id: string;
  customer_no: string | null;
  parent_name: string;
  email: string | null;
  phone: string | null;
  city: string | null;
  lifecycle: string;
  plan: string;
  subscription_status: string | null;
  account_status: string | null;
  owner_name: string | null;
  total_revenue_try: number;
  lead_score: number | null;
  churn_score: number | null;
  tags: string[];
  last_seen_at: string | null;
  next_follow_up_at: string | null;
  created_at: string;
}

/** admin_musteri_360_listele() dönüş şekli. */
export interface GrowthHouseholdList {
  rows: GrowthHousehold[];
  total: number;
}

/** admin_musteri_360_detay() dönüşü — RPC Türkçe anahtarlar döner. */
export interface Musteri360Detay {
  musteri: {
    id: string;
    customer_no: string | null;
    parent_name: string;
    email: string | null;
    phone: string | null;
    city: string | null;
    lifecycle: string;
    plan: string;
    subscription_status: string | null;
    account_status: string | null;
    owner_name: string | null;
    total_revenue_try: number;
    lead_score: number | null;
    churn_score: number | null;
    tags: string[];
    notes: string | null;
    preferred_contact_channel: string | null;
    utm_source: string | null;
    utm_medium: string | null;
    utm_campaign: string | null;
    last_seen_at: string | null;
    next_follow_up_at: string | null;
    created_at: string;
    [key: string]: unknown;
  };
  cocuklar: Array<Record<string, unknown>> | null;
  iletisim_izinleri: Array<{
    kanal: string;
    izin: boolean;
    kaynak: string | null;
    degisim: string | null;
  }>;
  kisiler: Array<{
    id: string;
    person_role: string;
    first_name: string;
    last_name: string;
    email: string | null;
    phone: string | null;
    national_id_masked: string | null;
    birth_date: string | null;
    gender: string | null;
    grade: string | null;
    active: boolean;
    created_at: string;
  }>;
  adresler: Array<{
    id: string;
    label: string | null;
    city: string | null;
    district: string | null;
    address_line: string | null;
    is_default: boolean;
    created_at: string;
  }>;
  abonelik: Record<string, unknown> | null;
  abonelik_projeksiyonu: Array<Record<string, unknown>>;
  islemler: Array<{
    id: string;
    transaction_type: string;
    amount_try: number;
    currency: string;
    status: string;
    occurred_at: string;
    description: string | null;
  }>;
  olaylar: Array<{
    id: string;
    event_name: string;
    source: string | null;
    occurred_at: string;
    properties: Record<string, unknown> | null;
  }>;
  ekip_akisi: Array<{
    id: string;
    feed_type: string;
    body: string | null;
    author_user_id: string | null;
    created_at: string;
  }>;
  destek_talepleri: Array<{
    id: string;
    ticket_no: string;
    subject: string;
    status: string;
    priority: string;
    created_at: string;
  }>;
}

// ---------------------------------------------------------------------
// Destek masası (growth_support_tickets)
// ---------------------------------------------------------------------

/** growth_ticket_status enum'u (migration 20261014000000). */
export type GrowthTicketStatus = "new" | "open" | "waiting" | "resolved";
/** growth_ticket_priority enum'u. */
export type GrowthTicketPriority = "low" | "normal" | "high" | "critical";
/** growth_support_tickets.category check kısıtı. */
export type GrowthTicketCategory = "billing" | "technical" | "account" | "content" | "subscription" | "other";

/** admin_destek_listele() satır şekli (growth_support_tickets kolonları). */
export interface GrowthTicket {
  /** Talep numarası (TKT-... olarak üretilir). */
  id: string;
  household_id: string;
  subject: string;
  category: GrowthTicketCategory;
  status: GrowthTicketStatus;
  priority: GrowthTicketPriority;
  owner_user_id: string | null;
  /** Atanan kişinin adı. */
  owner_name: string | null;
  sentiment: string | null;
  first_response_due_at: string | null;
  first_responded_at: string | null;
  resolution_due_at: string | null;
  resolved_at: string | null;
  created_at: string;
  updated_at: string;
}

/** admin_destek_listele() dönüş şekli. */
export interface GrowthTicketList {
  rows: GrowthTicket[];
  total: number;
}

// ---------------------------------------------------------------------
// CRM görevleri ve ekip akışı (Growth CRM)
// ---------------------------------------------------------------------

/** admin_crm_gorev_listele() satır şekli. */
export interface GrowthTask {
  id: string;
  task_no: string | null;
  household_id: string | null;
  lead_id: string | null;
  task_type: string; // call, email, meeting, follow_up, demo, proposal, other
  title: string;
  status: string; // open, in_progress, done, cancelled, deferred
  priority: string; // low, normal, high, urgent
  due_at: string | null;
  assignee_name: string | null;
  completed_at: string | null;
  created_at: string;
}

export interface GrowthTaskList {
  rows: GrowthTask[];
  total: number;
}

/** admin_ekip_akisi_listele() satır şekli. */
export interface GrowthFeedEntry {
  id: string;
  household_id: string | null;
  lead_id: string | null;
  feed_type: string; // note, call, email, meeting, support, system, task
  body: string | null;
  author_user_id: string | null;
  created_at: string;
}

export interface GrowthFeedList {
  rows: GrowthFeedEntry[];
  total: number;
}

// ---------------------------------------------------------------------
// Satış hattı (Growth CRM, lead / fırsat)
// ---------------------------------------------------------------------

/** Lead aşamaları (growth_lead_stage enum ile birebir). */
export type GrowthLeadStage = "new" | "contacted" | "qualified" | "trial" | "decision" | "won" | "lost";

/** admin_lead_listele() satır şekli (public.growth_leads kolonları). */
export interface GrowthLead {
  id: string;
  household_id: string | null;
  /** Kişi / veli adı (tabloda parent_name). */
  parent_name: string;
  email: string;
  phone: string | null;
  source: string | null;
  campaign: string | null;
  owner_name: string | null;
  stage: GrowthLeadStage;
  /** 0-100 lead puanı. */
  score: number;
  next_action: string | null;
  next_action_at: string | null;
  /** Tahmini değer (TL). */
  value_estimate: number;
  tags: string[];
  created_at: string;
  updated_at: string;
}

/** admin_lead_listele() dönüş şekli. */
export interface GrowthLeadList {
  rows: GrowthLead[];
  total: number;
}

// ---------------------------------------------------------------------
// Journey otomasyonları ve mesaj şablonları (Growth pazarlama motoru)
// ---------------------------------------------------------------------

/** admin_journey_listele() satır şekli (growth_journeys; segment_id ve enrolled_count RPC'de alias'tır). */
export interface GrowthJourney {
  id: string;
  name: string;
  status: string; // draft, active, paused
  trigger_type: string | null;
  segment_id: string | null;
  enrolled_count: number;
  created_at: string;
  updated_at: string;
}

export interface GrowthJourneyList {
  rows: GrowthJourney[];
  total: number;
}

/** admin_template_listele() satır şekli (growth_templates). */
export interface GrowthTemplate {
  id: string;
  name: string;
  channel: string; // email, sms, push, in_app, whatsapp
  subject: string | null;
  body: string;
  variables: string[];
  status: string; // draft, active, archived
  created_at: string;
  updated_at: string;
}

export interface GrowthTemplateList {
  rows: GrowthTemplate[];
  total: number;
}

// ---------------------------------------------------------------------
// Growth analitik ve AI öneriler (salt okunur)
// ---------------------------------------------------------------------

/** admin_growth_ozet(p_gun) dönüşü. */
export interface GrowthOzet {
  total_households: number;
  active_households: number;
  total_prospects: number;
  converted_prospects: number;
  open_leads: number;
  open_tickets: number;
  recent_events: number;
  message_log_count: number;
}

/** admin_lifecycle_dagilim() satırı. */
export interface GrowthLifecycleDagilim {
  lifecycle: string;
  count: number;
}

/** admin_prospect_kaynaklar() satırı. */
export interface GrowthProspectKaynak {
  source_channel: string;
  count: number;
}

/** admin_ai_oneri_listele() satır şekli.
 *  Not: growth_ai_recommendations'ta score / expires_at kolonu yok (RPC null döner);
 *  accepted, status alanından türetilir. status, bekliyor ile süresi dolmuşu ayırmak için eklendi. */
export interface GrowthAiOneri {
  id: string;
  household_id: string | null;
  recommendation_type: string;
  title: string;
  description: string | null;
  score: number | null;
  accepted: boolean | null;
  /** pending, approved, rejected, executed, expired */
  status: string;
  expires_at: string | null;
  created_at: string;
}

export interface GrowthAiOneriList {
  rows: GrowthAiOneri[];
  total: number;
}
