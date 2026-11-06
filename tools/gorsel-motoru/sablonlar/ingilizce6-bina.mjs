// 6. sınıf İngilizce — sıra sayıları (ordinal numbers) ve çok katlı binada yer bulma. Şekil: b4-bina.
import { sirayaYazi } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 6. sınıf; program: TYMM)';
const YERLER = ['toy shop', 'bakery', 'cinema', 'library', 'bank', 'cafe', 'gym', 'shoe shop', 'pharmacy', 'museum', 'dentist', 'bookshop', 'florist', 'barber'];

export function kur({ R, sec, karistir, ekle }) {
  function katSorusu() {
    const N = sec([6, 7, 8, 9, 10]), bas = sec([1, 1, 1, 11, 21, 31, 41]);
    const katlar = karistir(YERLER).slice(0, N), kat = (i) => bas + i;
    const i = Math.floor(R() * N), X = katlar[i], digerleri = katlar.map((_, j) => j).filter((j) => j !== i);
    const spec = { tip_id: 'b4-bina', parametreler: { baslangic: bas, katlar } };
    const ortak = { kod: 'ENG.6.2.V1', konu: 'Ordinal numbers', spec };
    const cel3 = karistir(digerleri).slice(0, 3);
    const dogrulama = [{ yol: ['kat', X], beklenen: kat(i) }];
    if (sec(['nerede', 'ne']) === 'nerede') {
      ekle({ ...ortak, alt_konu: 'Hangi katta?', zorluk: bas > 20 ? 3 : 2, kok: `Look at the building. Where is the ${X}?`, dogru: `It's on the ${sirayaYazi(kat(i))} floor.`, celdirici: cel3.map((j) => `It's on the ${sirayaYazi(kat(j))} floor.`),
        gerekce: cel3.map((j) => `${sirayaYazi(kat(j))} (${kat(j)}) kat, ${katlar[j]} katıdır; ${X} ${kat(i)}. kattadır.`), ipucu: `${X} yazan kutunun solundaki kat numarasını oku.`,
        cozum: [`${X} yazan kutunun yanındaki sayı ${kat(i)}.`, `${kat(i)} = ${sirayaYazi(kat(i))}.`], dogrulama });
    } else {
      ekle({ ...ortak, alt_konu: 'Kat numarasından yeri bulma', zorluk: bas > 20 ? 3 : 2, kok: `Look at the building. What is on the ${sirayaYazi(kat(i))} floor?`, dogru: `The ${X}.`, celdirici: cel3.map((j) => `The ${katlar[j]}.`),
        gerekce: cel3.map((j) => `${katlar[j]} ${kat(j)}. kattadır; sorulan kat ${kat(i)}.`), ipucu: `${sirayaYazi(kat(i))} sözcüğünün rakamla yazılışını bul, sonra o kata bak.`,
        cozum: [`${sirayaYazi(kat(i))} = ${kat(i)}.`, `${kat(i)}. katta ${X} bulunur.`], dogrulama });
    }
  }
  return { katSorusu };
}

export const KAYIT = [
  { id: 'eng6-kat-sirasi', ders: 'İngilizce', sinif: 6, idOnek: 'ENG6-KAT', mufredat_surum: MUFREDAT, kodlar: ['ENG.6.2.V1'], fabrika: kur, uret: (f) => f.katSorusu() },
];
