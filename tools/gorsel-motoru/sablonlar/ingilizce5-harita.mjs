// 5. sınıf İngilizce — mahalle/şehir haritasında yer tarifi (neighbourhood and city). Şekil: b4-harita.
import { haritaSorusuUret } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 5. sınıf; program: TYMM)';
const HAVUZ = ['library', 'cinema', 'park', 'zoo', 'museum', 'stadium', 'theatre', 'aquarium', 'playground', 'shopping mall'];

export function kur(ctx) {
  return { haritaSorusu: () => haritaSorusuUret(ctx, { kod: 'ENG.5.5.V1', konu: 'Places in the neighbourhood and city', havuz: HAVUZ }) };
}

export const KAYIT = [
  { id: 'eng5-harita', ders: 'İngilizce', sinif: 5, idOnek: 'ENG5-HAR', mufredat_surum: MUFREDAT, kodlar: ['ENG.5.5.V1'], fabrika: kur, uret: (f) => f.haritaSorusu() },
];
