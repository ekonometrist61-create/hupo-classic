// 7. sınıf İngilizce (önceki program) — kamu binaları haritası: yer adları ve konum ifadeleri. Şekil: b4-harita.
import { haritaSorusuUret } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 7. sınıf; program: önceki program)';
const HAVUZ = ['bank', 'post office', 'library', 'hospital', 'police station', 'fire station', 'town hall', 'school', 'museum', 'bus station', 'pharmacy', 'airport'];

export function kur(ctx) {
  return { haritaSorusu: () => haritaSorusuUret(ctx, { kod: 'E7.8.L1', konu: 'Public buildings', havuz: HAVUZ }) };
}

export const KAYIT = [
  { id: 'eng7-kamu-binalari', ders: 'İngilizce', sinif: 7, idOnek: 'ENG7-KAM', mufredat_surum: MUFREDAT, kodlar: ['E7.8.L1'], fabrika: kur, uret: (f) => f.haritaSorusu() },
];
