// 4. sınıf İngilizce (önceki program) — analog saatte zamanı söyleme (tam, çeyrek, buçuk). Şekil: b4-saat.
import { saatSorusuUret } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 4. sınıf; program: önceki program)';

export function kur(ctx) {
  return { saatSorusu: () => saatSorusuUret(ctx, { kod: 'E4.5.L2', dakikalar: [0, 15, 30, 45], stiller: ['g4'], konu: 'My Day: telling the time' }) };
}

export const KAYIT = [
  { id: 'eng4-saat', ders: 'İngilizce', sinif: 4, idOnek: 'ENG4-SAA', mufredat_surum: MUFREDAT, kodlar: ['E4.5.L2'], fabrika: kur, uret: (f) => f.saatSorusu() },
];
