// 6. sınıf Türkçe — şiirin biçim özellikleri: kıta ve dize sayısı (T.O.6.17).
import { siirKur, surum } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_6_turkce');

export const KAYIT = [
  { id: 'tr6-siir', ders: 'Türkçe', sinif: 6, idOnek: 'TR6-SIR', mufredat_surum: MUFREDAT, kodlar: ['T.O.6.17'],
    fabrika: (c) => siirKur(c, { kod: 'T.O.6.17', konu: 'Şiir', alt_konu: 'Şiirin kıta ve dize özelliklerini belirleme', sorular: ['kita', 'dize', 'kitadize', 'son'], zorluk: 2 }),
    uret: (f) => f.siir() },
];
