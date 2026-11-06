// 6. sınıf Türkçe — numaralı cümlelerde yazım yanlışını bulma (T.Y.6.18).
import { yazimKur, surum } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_6_turkce');

export const KAYIT = [
  { id: 'tr6-yazim', ders: 'Türkçe', sinif: 6, idOnek: 'TR6-YZM', mufredat_surum: MUFREDAT, kodlar: ['T.Y.6.18'],
    fabrika: (c) => yazimKur(c, { kod: 'T.Y.6.18', konu: 'Yazım ve noktalama', alt_konu: 'Yazım kurallarını cümlede uygulama', siniflar: [6, 7], tur: true, zorluk: 2 }),
    uret: (f) => f.yazim() },
];
