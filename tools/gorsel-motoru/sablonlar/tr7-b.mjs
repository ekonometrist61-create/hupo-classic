// 7. sınıf Türkçe — şiirin biçim özellikleri: uyak düzeni (T.O.7.16).
import { siirKur, surum } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_7_turkce');

export const KAYIT = [
  { id: 'tr7-siir', ders: 'Türkçe', sinif: 7, idOnek: 'TR7-SIR', mufredat_surum: MUFREDAT, kodlar: ['T.O.7.16'],
    fabrika: (c) => siirKur(c, { kod: 'T.O.7.16', konu: 'Şiir', alt_konu: 'Şiirin uyak düzenini belirleme', sorular: ['sema', 'uyakli', 'son', 'dize'], zorluk: 3 }),
    uret: (f) => f.siir() },
];
