// 3. sınıf İngilizce — aile ağacında akrabalar ve akrabalık adları (amca/dayı, teyze/hala, kuzen dahil). Şekil: b4-aile.
import { aileSorusuUret } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 3. sınıf; program: TYMM)';
const KELIMELER = ['mother', 'father', 'brother', 'sister', 'grandmother', 'grandfather', 'uncle', 'aunt', 'cousin'];

export function kur(ctx) {
  return { aileSorusu: () => aileSorusuUret(ctx, { kod: 'ENG.3.4.V1', kelimeler: KELIMELER, iliskiTuru: true }) };
}

export const KAYIT = [
  { id: 'eng3-aile', ders: 'İngilizce', sinif: 3, idOnek: 'ENG3-AIL', mufredat_surum: MUFREDAT, kodlar: ['ENG.3.4.V1'], fabrika: kur, uret: (f) => f.aileSorusu() },
];
