// 4. sınıf İngilizce (önceki program) — nesnelerin yeri (in / on / under / next to). Şekil: b4-konum.
import { IKON_ADI } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 4. sınıf; program: önceki program)';
const YERLER = ['on', 'under', 'in', 'next'];
const YAZI = { on: 'on the table', under: 'under the table', in: 'in the box', next: 'next to the box' };
const TR = { on: 'masanın üstünde', under: 'masanın altında', in: 'kutunun içinde', next: 'kutunun yanında' };
const NESNELER = ['top', 'kitap', 'elma', 'canta'];

export function kur({ R, sec, karistir, ekle }) {
  function konumSorusu() {
    const yer = karistir(YERLER), yerler = Object.fromEntries(NESNELER.map((n, i) => [n, yer[i]])), duzen = sec(['sol', 'sag']);
    const X = sec(NESNELER), spec = { tip_id: 'b4-konum', parametreler: { duzen, yerler } };
    const ortak = { kod: 'E4.6.L2', konu: 'Locations of objects', spec };
    const dogrulama = NESNELER.map((n) => ({ yol: ['yer', IKON_ADI[n]], beklenen: YAZI[yerler[n]] }));
    if (sec(['nerede', 'ne']) === 'nerede') {
      const dogru = `It's ${YAZI[yerler[X]]}.`, digerleri = NESNELER.filter((n) => n !== X);
      ekle({ ...ortak, alt_konu: 'Nesnenin yerini söyleme', zorluk: 1, kok: `Look at the picture. Where is the ${IKON_ADI[X]}?`, dogru, celdirici: digerleri.map((n) => `It's ${YAZI[yerler[n]]}.`),
        gerekce: digerleri.map((n) => `Bu cümle ${IKON_ADI[n]} için doğrudur (${TR[yerler[n]]}); ${IKON_ADI[X]} ${TR[yerler[X]]}.`),
        ipucu: `${IKON_ADI[X]} nesnesini bul; masaya ya da kutuya göre yerine bak.`, cozum: [`${IKON_ADI[X]} ${TR[yerler[X]]}.`], dogrulama });
    } else {
      const Y = yerler[X], dogru = `The ${IKON_ADI[X]}.`, digerleri = NESNELER.filter((n) => n !== X);
      ekle({ ...ortak, alt_konu: 'Yerden nesneyi bulma', zorluk: 2, kok: `Look at the picture. What is ${YAZI[Y]}?`, dogru, celdirici: digerleri.map((n) => `The ${IKON_ADI[n]}.`),
        gerekce: digerleri.map((n) => `${IKON_ADI[n]} ${TR[yerler[n]]}; sorulan yer ${TR[Y]}.`),
        ipucu: `${YAZI[Y]} olan nesneyi resimde bul.`, cozum: [`${TR[Y][0].toUpperCase()}${TR[Y].slice(1)} duran nesne ${IKON_ADI[X]}.`], dogrulama });
    }
  }
  return { konumSorusu };
}

export const KAYIT = [
  { id: 'eng4-konum', ders: 'İngilizce', sinif: 4, idOnek: 'ENG4-KON', mufredat_surum: MUFREDAT, kodlar: ['E4.6.L2'], fabrika: kur, uret: (f) => f.konumSorusu() },
];
