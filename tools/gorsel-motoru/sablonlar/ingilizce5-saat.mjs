// 5. sınıf İngilizce — analog saatte zamanı söyleme (past/to ve dijital biçim). Şekil: b4-saat.
import { saatSorusuUret } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 5. sınıf; program: TYMM)';
const DAKIKALAR = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

export function kur(ctx) {
  return { saatSorusu: () => saatSorusuUret(ctx, { kod: 'ENG.5.2.V1', dakikalar: DAKIKALAR, stiller: ['g5', 'dijital'], konu: 'Classroom life: time' }) };
}

export const KAYIT = [
  { id: 'eng5-saat', ders: 'İngilizce', sinif: 5, idOnek: 'ENG5-SAA', mufredat_surum: MUFREDAT, kodlar: ['ENG.5.2.V1'], fabrika: kur, uret: (f) => f.saatSorusu() },
];
