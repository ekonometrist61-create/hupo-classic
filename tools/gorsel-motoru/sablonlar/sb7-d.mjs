// 7. sınıf Sosyal Bilgiler — üretim miktarının yıllara göre değişimini çizgi grafiğinden okuma (SB.7.5.2).
// Veriler kurgusaldır (gerçek il verisi değildir); soru yalnız grafik okuma becerisini ölçer.
import { cizgiKur } from './sosyal6-ortak.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Sosyal Bilgiler 7. sınıf; program: TYMM)';

export function kur(ctx) {
  return cizgiKur(ctx, {
    kod: 'SB.7.5.2', konu: 'Üretim, Dağıtım ve Tüketim', alt_konu: 'Üretim verisini grafikten okuma',
    baslik: 'Buğday Üretimi (bin ton)', etiketler: () => ['2018', '2019', '2020', '2021', '2022', '2023'],
    olcekler: [{ max: 100, adim: 20 }, { max: 50, adim: 10 }, { max: 200, adim: 40 }, { max: 60, adim: 10 }],
    konuAd: 'buğday üretimi', artti: 'artmıştır', degerMetni: (v) => `${v} bin ton`, okuSoru: (l) => `Yukarıdaki grafiğe göre bu ilde ${l} yılındaki buğday üretimi kaç bin tondur?`,
    farkSoru: (a, b) => `Yukarıdaki grafiğe göre bu ilde buğday üretimi ${a} yılından ${b} yılına kaç bin ton artmıştır?`, farkMetni: (d) => `${d} bin ton`,
  });
}

export const KAYIT = [
  { id: 'sb7-uretim-cizgi', ders: 'Sosyal Bilgiler', sinif: 7, idOnek: 'SB7-URE', mufredat_surum: MUFREDAT, kodlar: ['SB.7.5.2'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];