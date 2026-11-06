// 8. sınıf İnkılap Tarihi — Atatürk döneminde kurulan fabrika sayısının yıllara göre değişimini çizgi grafiğinden okuma (İTA.8.4.6).
// Veriler kurgusaldır (gerçek veri değildir); soru yalnız grafik okuma becerisini ölçer.
import { cizgiKur } from './sosyal6-ortak.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (T.C. İnkılap Tarihi ve Atatürkçülük 8. sınıf; program: TYMM)';
const DERS = 'T.C. İnkılap Tarihi ve Atatürkçülük';

export function kur(ctx) {
  return cizgiKur(ctx, {
    kod: 'İTA.8.4.6', konu: 'Çağdaşlaşan Türkiye', alt_konu: 'Ekonomi alanındaki gelişmeyi grafikten okuma',
    baslik: 'Kurulan Fabrika Sayısı', etiketler: () => ['1930', '1931', '1932', '1933', '1934', '1935'],
    olcekler: [{ max: 100, adim: 20 }, { max: 50, adim: 10 }, { max: 200, adim: 40 }, { max: 60, adim: 10 }],
    konuAd: 'fabrika sayısı', artti: 'artmıştır', degerMetni: (v) => `${v}`, okuSoru: (l) => `Yukarıdaki grafiğe göre ${l} yılında kurulan fabrika sayısı kaçtır?`,
    farkSoru: (a, b) => `Yukarıdaki grafiğe göre kurulan fabrika sayısı ${a} yılından ${b} yılına kaç artmıştır?`, farkMetni: (d) => `${d}`,
  });
}

export const KAYIT = [
  { id: 'ink8-ekonomi-cizgi', ders: DERS, sinif: 8, idOnek: 'INK8-EKO', mufredat_surum: MUFREDAT, kodlar: ['İTA.8.4.6'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];
