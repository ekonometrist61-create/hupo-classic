// Yalnızca yerel önizleme (DEMO_MODE) için örnek veriler. Üretimde hiçbir yerde kullanılmaz.
import type {
  AnalyticsSummary,
  AuditRow,
  IletisimAyarlari,
  IletisimKampanya,
  Journey,
  ReconciliationItem,
  Segment,
  SegmentPreview,
  Survey,
  SurveyResult,
  SupportTask,
  TeamMember,
  VeliProfile,
} from "./types";

const iso = (daysAgo: number, hour = 10) => {
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  d.setHours(hour, 0, 0, 0);
  return d.toISOString();
};

export const DEMO_PROFILE: VeliProfile = {
  veli: { id: "demo-veli", ad: "Örnek Veli 01", email: "veli01@example.test", uyelik_tarihi: iso(60) },
  cocuklar: [
    { id: "c1", ad: "Öğrenci A", sinif: 4, son_aktif: iso(0).slice(0, 10) },
    { id: "c2", ad: "Öğrenci B", sinif: 4, son_aktif: iso(3).slice(0, 10) },
  ],
  abonelik: { plan_kod: "premium", plan_ad: "Premium", durum: "aktif", baslangic: iso(30), bitis: iso(-335) },
  tercihler: [
    { kanal: "eposta", izin: true, kaynak: "veli", guncelleme: iso(20) },
    { kanal: "push", izin: false, kaynak: null, guncelleme: null },
    { kanal: "sms", izin: false, kaynak: null, guncelleme: null },
    { kanal: "uygulama_ici", izin: true, kaynak: "veli", guncelleme: iso(20) },
  ],
  notlar: [{ id: "n1", metin: "Aile deneme sürecinde. Rapor sorusu için arandı.", yazar: "Hupo Yönetici", tarih: iso(5) }],
  zaman_cizelgesi: [
    { tur: "odeme", zaman: iso(2), detay: { durum: "basarili", tutar_kurus: 49900 } },
    { tur: "tercih", zaman: iso(20), detay: { kanal: "eposta", izin: true, kaynak: "veli" } },
    { tur: "kayit", zaman: iso(60), detay: {} },
  ],
};

export const DEMO_SEGMENTS: Segment[] = [
  { id: "s1", ad: "İlk görevi bekleyenler", aciklama: "Çocuğu bağlı ama henüz soru çözmemiş aileler", kriterler: { ilk_gorev_bekleyen: true }, created_at: iso(10), veli_sayisi: 214, izinli_eposta: 131 },
  { id: "s2", ad: "4. sınıf Premium velileri", aciklama: null, kriterler: { plan: ["premium"], sinif: [4] }, created_at: iso(6), veli_sayisi: 188, izinli_eposta: 120 },
  { id: "s3", ad: "Yenilemesi yaklaşanlar", aciklama: "7 gün içinde biten abonelikler", kriterler: { yenileme_yaklasan: true }, created_at: iso(2), veli_sayisi: 23, izinli_eposta: 17 },
];

export const DEMO_SEGMENT_PREVIEW: SegmentPreview = {
  toplam: 214,
  izinli: 131,
  haric: 83,
  ornek: [
    { veli_id: "1", ad: "Örnek Veli 02", izinli: true },
    { veli_id: "2", ad: "Örnek Veli 05", izinli: false },
    { veli_id: "3", ad: "Örnek Veli 07", izinli: true },
  ],
};

export const DEMO_CAMPAIGNS: IletisimKampanya[] = [
  {
    id: "k1", ad: "İlk göreve birlikte başlayın", kanal: "eposta", segment_id: "s1", segment_ad: "İlk görevi bekleyenler",
    baslik: "Hupo ile ilk görev bir dakika sürer", mesaj: "Çocuğunuzla ilk görevi birlikte tamamlayın; ilerlemeyi veli panelinden izleyin.",
    durum: "kontrol_edildi", planlanan_at: iso(-1, 12),
    onkontrol: { hedef: 214, izinli: 131, izin_haric: 83, sinir_haric: 4, gonderilecek: 127, sessiz_saat: false, haftalik_limit: 3, planlanan_at: iso(-1, 12), kontrol_zamani: iso(0) },
    created_at: iso(1),
  },
  { id: "k2", ad: "Haftalık öğrenme özeti", kanal: "push", segment_id: "s2", segment_ad: "4. sınıf Premium velileri", baslik: "Bu haftanın özeti hazır", mesaj: "Çocuğunuzun ilerlediği konuları veli panelinizde inceleyin.", durum: "taslak", planlanan_at: null, onkontrol: null, created_at: iso(3) },
];

export const DEMO_SETTINGS: IletisimAyarlari = {
  haftalik_limit: 3,
  sessiz_baslangic: "20:00",
  sessiz_bitis: "09:00",
  zaman_dilimi: "Europe/Istanbul",
  updated_at: iso(7),
};

export const DEMO_SURVEYS: Survey[] = [
  {
    id: "a1", ad: "İlk ay veli deneyimi", anonim: false, durum: "yayinda", surum: 2, tekrar_gosterim_gun: 30, created_at: iso(14), yanit_sayisi: 48,
    sorular: [
      { id: "nps1", tur: "nps", baslik: "Hupolingo’yu başka bir veliye önerme olasılığınız nedir?" },
      { id: "neden", tur: "uzun_metin", baslik: "Neyi iyileştirebiliriz?", kosul: { soru_id: "nps1", op: "lte", deger: 6 } },
    ],
  },
  { id: "a2", ad: "İptal nedeni", anonim: true, durum: "taslak", surum: 1, tekrar_gosterim_gun: 90, created_at: iso(3), yanit_sayisi: 0, sorular: [{ id: "q1", tur: "tek_secim", baslik: "Ayrılma nedeniniz?", secenekler: ["Fiyat", "İhtiyaç kalmadı", "Başka uygulama"] }] },
];

export const DEMO_SURVEY_RESULT: SurveyResult = {
  anket: { id: "a1", ad: "İlk ay veli deneyimi", anonim: false, surum: 2, durum: "yayinda" },
  yanit_sayisi: 48,
  nps: { n: 48, destekleyen: 30, pasif: 11, elestiren: 7, skor: 48 },
  sorular: [
    { soru_id: "nps1", baslik: "Hupolingo’yu başka bir veliye önerme olasılığınız nedir?", tur: "nps", yanit: 48, ortalama: 8.1 },
    { soru_id: "neden", baslik: "Neyi iyileştirebiliriz?", tur: "uzun_metin", yanit: 7, ortalama: null },
  ],
  metinler: [{ soru_id: "neden", metin: "Raporlar daha açıklayıcı olabilir.", tarih: iso(1) }],
};

export const DEMO_TASKS: SupportTask[] = [
  { id: "t1", veli_id: "v", veli_ad: "Örnek Veli 05", kaynak: "anket_dusuk_nps", durum: "acik", kapatma_notu: null, created_at: iso(1), kapatildi_at: null, nps: 3 },
];

export const DEMO_JOURNEYS: Journey[] = [
  {
    id: "j1", ad: "İlk öğrenme oturumuna davet", giris_olayi: "veli_kayit", durum: "taslak", surum: 1, created_at: iso(5),
    adimlar: [
      { tur: "bekle", saat: 24 },
      { tur: "kosul", olcut: "ilk_gorev_tamamlandi" },
      { tur: "mesaj", kanal: "eposta", baslik: "Başlangıç rehberi" },
    ],
  },
];

export const DEMO_ANALYTICS: AnalyticsSummary = {
  gun: 30,
  huni: { kayit: 1000, cocuk_bagladi: 790, ilk_ogrenme: 620, ucretli: 84 },
  kohort: [
    { hafta: "08.09", boyut: 120, tutma: [100, 68, 54, 46, 42] },
    { hafta: "15.09", boyut: 134, tutma: [100, 72, 58, 49, null] },
    { hafta: "22.09", boyut: 141, tutma: [100, 75, 61, null, null] },
    { hafta: "29.09", boyut: 128, tutma: [100, 78, null, null, null] },
    { hafta: "06.10", boyut: 40, tutma: [100, null, null, null, null] },
  ],
  ogrenme: { ogrenci: 1631, aktif_7_gun: 1286, dogruluk_yuzde: 71.4, tekrar_zamani_gelen: 5320 },
};

export const DEMO_RECON: ReconciliationItem[] = [
  { tur: "bekleyen_eski", kayit_id: "p1", veli_ad: "Örnek Veli 04", tutar_kurus: 49900, tarih: iso(6) },
  { tur: "abonelik_yok", kayit_id: "p2", veli_ad: "Örnek Veli 03", tutar_kurus: 79900, tarih: iso(3) },
];

export const DEMO_AUDIT: { toplam: number; satirlar: AuditRow[] } = {
  toplam: 3,
  satirlar: [
    { id: "l1", zaman: iso(0, 10), admin_ad: "Hupo Yönetici", islem: "iletisim_kampanyasi_on_kontrol", detay: {} },
    { id: "l2", zaman: iso(0, 9), admin_ad: "Hupo Yönetici", islem: "aileler_disa_aktarildi", detay: { adet: 120 } },
    { id: "l3", zaman: iso(1, 16), admin_ad: "Hupo Yönetici", islem: "veli_notu_eklendi", detay: {} },
  ],
};

export const DEMO_TEAM: TeamMember[] = [
  { id: "u1", rol: "admin", ad: "Hupo Yönetici", email: "admin@example.test", son_islem: iso(0, 10), islem_30_gun: 42 },
  { id: "u2", rol: "ogretmen", ad: "Örnek Öğretmen", email: "ogretmen@example.test", son_islem: null, islem_30_gun: 0 },
];
