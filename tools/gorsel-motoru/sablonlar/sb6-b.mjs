// 6. sınıf Sosyal Bilgiler — ekonomik faaliyetin (turizm) yıllara göre değişimini çizgi grafiğinden okuma (SB.6.5.1).
// Veriler kurgusaldır (gerçek il verisi değildir); soru yalnız grafik okuma becerisini ölçer.
import { cizgiKur } from './sosyal6-ortak.mjs';
const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
export function kur(ctx) {
  return cizgiKur(ctx, {
    kod: 'SB.6.5.1', konu: 'Ekonomik Faaliyetler', alt_konu: 'Kaynaklar ve ekonomik faaliyet verisini grafikten okuma',
    baslik: 'Turist Sayısı (bin kişi)', etiketler: () => ['2018', '2019', '2020', '2021', '2022', '2023'],
    olcekler: [{ max: 100, adim: 20 }, { max: 50, adim: 10 }, { max: 200, adim: 40 }, { max: 60, adim: 10 }],
    konuAd: 'turist sayısı', artti: 'artmıştır', degerMetni: (v) => `${v} bin`, okuSoru: (l) => `Yukarıdaki grafiğe göre bu ilde ${l} yılındaki turist sayısı kaç bindir?`,
    farkSoru: (a, b) => `Yukarıdaki grafiğe göre bu ilde turist sayısı ${a} yılından ${b} yılına kaç bin artmıştır?`, farkMetni: (d) => `${d} bin`,
  });
}
export const KAYIT = [
  { id: 'sb6-ekonomi-cizgi', ders: 'Sosyal Bilgiler', sinif: 6, idOnek: 'SB6-EKO', mufredat_surum: MUFREDAT, kodlar: ['SB.6.5.1'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];

