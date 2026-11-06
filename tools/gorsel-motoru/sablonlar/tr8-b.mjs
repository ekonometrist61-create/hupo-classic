// 8. sınıf Türkçe (önceki program) — T.8.3.35 Metindeki iş ve işlem basamaklarını kavrar.
import { kartKur, KILAVUZ8, surum } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_8_turkce_onceki');

export const KAYIT = [
  { id: 'tr8-basamak', ders: 'Türkçe', sinif: 8, idOnek: 'TR8-BSM', mufredat_surum: MUFREDAT, kodlar: ['T.8.3.35'],
    fabrika: (c) => kartKur(c, { kod: 'T.8.3.35', konu: 'İşlem basamakları', alt_konu: 'Kullanım kılavuzundaki işlem basamaklarının sırasını belirleme', tur: 'basamak', banka: KILAVUZ8, duzen: 'liste', zorluk: 2 }),
    uret: (f) => f.sirala() },
];