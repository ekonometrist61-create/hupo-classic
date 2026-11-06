// 7. sınıf Sosyal Bilgiler — internet kullanıcı sayısının yıllara göre değişimini çizgi grafiğinden okuma (SB.7.2.1).
// Veriler kurgusaldır (gerçek il verisi değildir); soru yalnız grafik okuma becerisini ölçer.
import { cizgiKur } from './sosyal6-ortak.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Sosyal Bilgiler 7. sınıf; program: TYMM)';

export function kur(ctx) {
  return cizgiKur(ctx, {
    kod: 'SB.7.2.1', konu: 'Küreselleşme', alt_konu: 'İletişim teknolojisi verisini grafikten okuma',
    baslik: 'İnternet Kullanıcı Sayısı (bin kişi)', etiketler: () => ['2016', '2017', '2018', '2019', '2020', '2021'],
    olcekler: [{ max: 100, adim: 20 }, { max: 50, adim: 10 }, { max: 200, adim: 40 }, { max: 60, adim: 10 }],
    konuAd: 'internet kullanıcı sayısı', artti: 'artmıştır', degerMetni: (v) => `${v} bin`, okuSoru: (l) => `Yukarıdaki grafiğe göre bu ilde ${l} yılındaki internet kullanıcı sayısı kaç bindir?`,
    farkSoru: (a, b) => `Yukarıdaki grafiğe göre bu ilde internet kullanıcı sayısı ${a} yılından ${b} yılına kaç bin artmıştır?`, farkMetni: (d) => `${d} bin`,
  });
}

export const KAYIT = [
  { id: 'sb7-kuresel-cizgi', ders: 'Sosyal Bilgiler', sinif: 7, idOnek: 'SB7-KUR', mufredat_surum: MUFREDAT, kodlar: ['SB.7.2.1'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];
