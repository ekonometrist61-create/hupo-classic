// YALNIZCA yerel geliştirmede paneli oturum/veri olmadan görmek için kullanılan
// örnek veri. NEXT_PUBLIC_DEMO_MODE=1 tanımlıyken AdminDashboard tarafından
// kullanılır; gerçek sorguya hiç dokunmaz ve commit'e sızmaz (import edilmiyor).

import type { DashboardSummary } from "../types";

export const DEMO_SUMMARY: DashboardSummary = {
  kullanicilar: {
    veli: 1284,
    ogrenci: 1631,
    bagsiz_ogrenci: 37,
    son_30_gun_yeni: 96,
  },
  abonelikler: {
    aktif: 742,
    yakinda_bitecek: 23,
  },
  sorular: {
    toplam: 8420,
    onayli: 7915,
    bekleyen: 412,
    reddedilen: 93,
    ders_dagilimi: [
      { ders: "Matematik", adet: 2610 },
      { ders: "Fen Bilimleri", adet: 1980 },
      { ders: "Türkçe", adet: 1470 },
      { ders: "Sosyal Bilgiler", adet: 1210 },
      { ders: "İngilizce", adet: 780 },
      { ders: "Diğer", adet: 370 },
    ],
  },
  odemeler: {
    bu_ay_kurus: 18_945_000,
    gecen_ay_kurus: 16_210_000,
    basarili_adet: 812,
    bekleyen_adet: 24,
    basarisiz_adet: 9,
    iade_adet: 3,
    aylik: [
      { label: "Mar", ay: "2026-03", tutar_kurus: 12_400_000, adet: 542 },
      { label: "Nis", ay: "2026-04", tutar_kurus: 13_850_000, adet: 601 },
      { label: "May", ay: "2026-05", tutar_kurus: 14_120_000, adet: 618 },
      { label: "Haz", ay: "2026-06", tutar_kurus: 15_640_000, adet: 672 },
      { label: "Tem", ay: "2026-07", tutar_kurus: 16_210_000, adet: 698 },
      { label: "Ağu", ay: "2026-08", tutar_kurus: 18_945_000, adet: 812 },
    ],
  },
  son_odemeler: [
    { veli_ad: "Ayşe Yılmaz", tutar_kurus: 249_900, durum: "basarili", tarih: "2026-09-26" },
    { veli_ad: "Mehmet Demir", tutar_kurus: 249_900, durum: "basarili", tarih: "2026-09-26" },
    { veli_ad: "Zeynep Kaya", tutar_kurus: 99_900, durum: "beklemede", tarih: "2026-09-25" },
    { veli_ad: "Ahmet Şahin", tutar_kurus: 249_900, durum: "basarili", tarih: "2026-09-25" },
    { veli_ad: "Fatma Öztürk", tutar_kurus: 99_900, durum: "basarisiz", tarih: "2026-09-24" },
  ],
  son_islemler: [
    { islem: "soru.onaylandi", admin_ad: "Cengizhan", tarih: "2026-09-26 14:32" },
    { islem: "kullanici.veli.eslesti", admin_ad: "Cengizhan", tarih: "2026-09-26 11:05" },
    { islem: "plan.olusturuldu", admin_ad: null, tarih: "2026-09-25 16:48" },
    { islem: "soru.reddedildi", admin_ad: "Cengizhan", tarih: "2026-09-25 09:20" },
  ],
};
