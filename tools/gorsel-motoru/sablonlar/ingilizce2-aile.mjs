// 2. sınıf İngilizce — aile ağacında akrabalar (anne, baba, kardeş, büyükanne, büyükbaba). Şekil: b4-aile.
import { aileSorusuUret } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 2. sınıf; program: TYMM)';
const KELIMELER = ['mother', 'father', 'brother', 'sister', 'grandmother', 'grandfather'];

export function kur(ctx) {
  return { aileSorusu: () => aileSorusuUret(ctx, { kod: 'ENG.2.4.V1', kelimeler: KELIMELER, iliskiTuru: false }) };
}

export const KAYIT = [
  { id: 'eng2-aile', ders: 'İngilizce', sinif: 2, idOnek: 'ENG2-AIL', mufredat_surum: MUFREDAT, kodlar: ['ENG.2.4.V1'], fabrika: kur, uret: (f) => f.aileSorusu() },
];
