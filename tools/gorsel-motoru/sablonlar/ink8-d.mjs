// 8. sınıf İnkılap Tarihi — eğitim alanındaki gelişmeyi yıllara göre çizgi grafiğinden okuma (İTA.8.4.4).
// Veriler kurgusaldır (gerçek il verisi değildir); soru yalnız grafik okuma becerisini ölçer.
import { cizgiKur } from './sosyal6-ortak.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (T.C. İnkılap Tarihi ve Atatürkçülük 8. sınıf; program: TYMM)';
const DERS = 'T.C. İnkılap Tarihi ve Atatürkçülük';

export function kur(ctx) {
  return cizgiKur(ctx, {
    kod: 'İTA.8.4.4', konu: 'Çağdaşlaşan Türkiye', alt_konu: 'Eğitim alanındaki gelişmeyi grafikten okuma',
    baslik: 'Millet Mektebi Kursiyer Sayısı (bin kişi)', etiketler: () => ['1928', '1929', '1930', '1931', '1932', '1933'],
    olcekler: [{ max: 100, adim: 20 }, { max: 50, adim: 10 }, { max: 200, adim: 40 }, { max: 60, adim: 10 }],
    konuAd: 'kursiyer sayısı', artti: 'artmıştır', degerMetni: (v) => `${v} bin`, okuSoru: (l) => `Yukarıdaki grafiğe göre bu ilde ${l} yılındaki Millet Mektebi kursiyer sayısı kaç bindir?`,
    farkSoru: (a, b) => `Yukarıdaki grafiğe göre bu ilde kursiyer sayısı ${a} yılından ${b} yılına kaç bin artmıştır?`, farkMetni: (d) => `${d} bin`,
  });
}

export const KAYIT = [
  { id: 'ink8-egitim-cizgi', ders: DERS, sinif: 8, idOnek: 'INK8-EGT', mufredat_surum: MUFREDAT, kodlar: ['İTA.8.4.4'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];