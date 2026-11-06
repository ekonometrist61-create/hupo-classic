// 4. sınıf İngilizce (önceki program) — sayılar 11-40 (karışık nesneler arasından sayma). Şekil: b4-sayma (karışık düzen).
import { sayiYazi, IKON_COGUL } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 4. sınıf; program: önceki program)';
const TURLER = ['elma', 'yildiz', 'top', 'kitap', 'kalem', 'silgi'];
const TR = { elma: 'elma', yildiz: 'yıldız', top: 'top', kitap: 'kitap', kalem: 'kalem', silgi: 'silgi' };

export function kur({ R, sec, karistir, ekle }) {
  function saymaSorusu() {
    const [A, B] = karistir(TURLER), a = 11 + Math.floor(R() * 25), b = 5 + Math.floor(R() * 12);
    if (a + b > 50 || a === b) throw new Error('toplam_asildi');
    const sira = karistir([...Array(a).fill(A), ...Array(b).fill(B)]);
    const aksi = R() < 0.5, hedef = aksi ? B : A, say = aksi ? b : a, diger = aksi ? a : b;
    const adaylar = [];
    for (let g = 0; adaylar.length < 3 && g < 100; g++) {
      const v = 8 + Math.floor(R() * 40);
      if (v !== say && v !== diger && v !== say + diger && !adaylar.includes(v)) adaylar.push(v);
    }
    if (adaylar.length < 3) throw new Error('celdirici_yok');
    const cel = [diger, adaylar[0], adaylar[1]].map(sayiYazi), dogru = sayiYazi(say);
    ekle({ kod: 'E4.1.L4', konu: 'Numbers 1-50', alt_konu: 'Nesneleri sayma (11-50)', zorluk: say > 24 ? 3 : 2,
      spec: { tip_id: 'b4-sayma', parametreler: { dizilim: 'karisik', sira } },
      kok: `Look at the picture. How many ${IKON_COGUL[hedef]} are there?`, dogru, celdirici: cel,
      gerekce: [`${sayiYazi(diger)}, diğer nesnenin (${TR[aksi ? A : B]}) sayısıdır.`, `${cel[1]} yanlış sayımdır; ${TR[hedef]} sayısı ${say}.`, `${cel[2]} yanlış sayımdır; ${TR[hedef]} sayısı ${say}.`],
      ipucu: `Yalnızca ${TR[hedef]} olanları say. Gruplar halinde saymak işi kolaylaştırır.`, cozum: [`Resimde ${say} ${TR[hedef]} vardır.`, `${say} = ${dogru}.`],
      dogrulama: [{ yol: ['sayi', hedef], beklenen: say }, { yol: ['sayi', aksi ? A : B], beklenen: diger }] });
  }
  return { saymaSorusu };
}

export const KAYIT = [
  { id: 'eng4-sayma', ders: 'İngilizce', sinif: 4, idOnek: 'ENG4-SAY', mufredat_surum: MUFREDAT, kodlar: ['E4.1.L4'], fabrika: kur, uret: (f) => f.saymaSorusu() },
];
