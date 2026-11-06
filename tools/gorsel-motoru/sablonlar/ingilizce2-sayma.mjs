// 2. sınıf İngilizce — sınıf eşyalarını sayma (1-10) ve karşılaştırma. Şekil: b4-sayma (satır düzeni).
import { sayiYazi, IKON_ADI, IKON_COGUL } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 2. sınıf; program: TYMM)';
const TURLER = ['kalem', 'kitap', 'cetvel', 'silgi', 'canta'];
const TR = { kalem: 'kalem', kitap: 'kitap', cetvel: 'cetvel', silgi: 'silgi', canta: 'çanta' };

export function kur({ R, sec, karistir, ekle }) {
  function saymaSorusu() {
    const tur = karistir(TURLER).slice(0, 4), say = karistir([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).slice(0, 4);
    const satirlar = tur.map((t, i) => ({ tur: t, adet: say[i] }));
    const i = Math.floor(R() * 4), X = satirlar[i], kind = sec(['say', 'say', 'cok', 'az']);
    const ortak = { kod: 'ENG.2.2.V1', konu: 'Classroom objects and numbers', spec: { tip_id: 'b4-sayma', parametreler: { dizilim: 'satir', satirlar } } };
    const dogrulama = satirlar.map((s) => ({ yol: ['sayi', s.tur], beklenen: s.adet }));
    if (kind === 'say') {
      const dogru = sayiYazi(X.adet), cel = satirlar.filter((s) => s !== X).map((s) => sayiYazi(s.adet));
      ekle({ ...ortak, alt_konu: 'Nesneleri sayma', zorluk: X.adet > 6 ? 2 : 1, kok: `Look at the picture. How many ${IKON_COGUL[X.tur]} are there?`, dogru, celdirici: cel,
        gerekce: satirlar.filter((s) => s !== X).map((s) => `${sayiYazi(s.adet)}, ${TR[s.tur]} sayısıdır; sorulan nesne ${TR[X.tur]}.`),
        ipucu: `Sadece ${TR[X.tur]} olan satırı say.`, cozum: [`Resimde ${X.adet} ${TR[X.tur]} vardır.`, `${X.adet} = ${dogru}.`], dogrulama });
    } else {
      const sirali = [...satirlar].sort((a, b) => b.adet - a.adet), H = kind === 'cok' ? sirali[0] : sirali[3];
      const dogru = IKON_COGUL[H.tur], cel = satirlar.filter((s) => s !== H).map((s) => IKON_COGUL[s.tur]);
      ekle({ ...ortak, alt_konu: 'Sayıları karşılaştırma', zorluk: 2, kok: kind === 'cok' ? 'Look at the picture. There are more ____ than anything else.' : 'Look at the picture. There are fewer ____ than anything else.', dogru, celdirici: cel,
        gerekce: satirlar.filter((s) => s !== H).map((s) => `${IKON_COGUL[s.tur]} sayısı ${s.adet}; ${kind === 'cok' ? 'en çok' : 'en az'} olan ${TR[H.tur]} (${H.adet}).`),
        ipucu: 'Her satırdaki nesneleri say ve sayıları karşılaştır.', cozum: [satirlar.map((s) => `${TR[s.tur]}: ${s.adet}`).join(', ') + '.', `${kind === 'cok' ? 'En çok' : 'En az'} olan ${TR[H.tur]} (${H.adet}).`], dogrulama });
    }
  }
  return { saymaSorusu };
}

export const KAYIT = [
  { id: 'eng2-sayma', ders: 'İngilizce', sinif: 2, idOnek: 'ENG2-SAY', mufredat_surum: MUFREDAT, kodlar: ['ENG.2.2.V1'], fabrika: kur, uret: (f) => f.saymaSorusu() },
];

