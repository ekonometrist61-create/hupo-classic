// 8. sınıf Türkçe (önceki program) — T.8.3.28 Metinde önemli noktaların vurgulanış biçimlerini kavrar.
import { vurguluKur, VURGU8, surum } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_8_turkce_onceki');

export const KAYIT = [
  { id: 'tr8-vurgu', ders: 'Türkçe', sinif: 8, idOnek: 'TR8-VRG', mufredat_surum: MUFREDAT, kodlar: ['T.8.3.28'],
    fabrika: (c) => vurguluKur(c, { kod: 'T.8.3.28', konu: 'Vurgulama biçimleri', alt_konu: 'Metinde önemli noktaların vurgulanış biçimlerini belirleme', metinler: VURGU8, zorluk: 2 }),
    uret: (f) => f.vurgu() },
];