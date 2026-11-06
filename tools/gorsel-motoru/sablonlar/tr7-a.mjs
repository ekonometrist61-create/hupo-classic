// 7. sınıf Türkçe — yazım ve noktalama kurallarını uygulama (T.Y.7.19).
import { yazimKur, surum } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_7_turkce');

export const KAYIT = [
  { id: 'tr7-yazim', ders: 'Türkçe', sinif: 7, idOnek: 'TR7-YZM', mufredat_surum: MUFREDAT, kodlar: ['T.Y.7.19'],
    fabrika: (c) => yazimKur(c, { kod: 'T.Y.7.19', konu: 'Yazım ve noktalama', alt_konu: 'Yazım ve noktalama kurallarını uygulama', siniflar: [6, 7], tur: true, zorluk: 3 }),
    uret: (f) => f.yazim() },
];
