// 6. sınıf İngilizce — 100-500 arası sayılar: fiyat listesini okuma. Şekil: b4-tablo.
import { sayiYazi } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 6. sınıf; program: TYMM)';
const URUNLER = ['Jacket', 'Bag', 'Shoes', 'Bike', 'Tablet', 'Watch', 'Ball', 'Helmet', 'Guitar', 'Camera'];

export function kur({ R, sec, karistir, ekle }) {
  function fiyatSorusu() {
    const urun = karistir(URUNLER).slice(0, 5), fiyat = karistir(Array.from({ length: 81 }, (_, i) => 100 + i * 5)).slice(0, 5);
    const satirlar = urun.map((u, i) => ({ ad: u, hucreler: [String(fiyat[i])] }));
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: 'Shop prices', ilkSutun: 'Item', sutunlar: ['Price (TL)'], satirlar } };
    const i = Math.floor(R() * 5), X = urun[i], cel = karistir(urun.map((_, j) => j).filter((j) => j !== i)).slice(0, 3);
    const ortak = { kod: 'ENG.6.2.R2', konu: 'Cardinal numbers 100-500', spec };
    const dogrulama = urun.map((u, j) => ({ yol: ['hucre', `${u}|Price (TL)`], beklenen: String(fiyat[j]) }));
    if (sec(['fiyat', 'hangi']) === 'fiyat') {
      ekle({ ...ortak, alt_konu: 'Fiyatı sözcükle söyleme', zorluk: 2, kok: `Look at the price list. How much is the ${X.toLowerCase()}?`, dogru: `It's ${sayiYazi(fiyat[i])} TL.`, celdirici: cel.map((j) => `It's ${sayiYazi(fiyat[j])} TL.`),
        gerekce: cel.map((j) => `${sayiYazi(fiyat[j])} (${fiyat[j]}), ${urun[j].toLowerCase()} fiyatıdır; ${X.toLowerCase()} ${fiyat[i]} TL.`), ipucu: `${X} satırındaki sayıyı İngilizce yaz: yüzler basamağı, sonra "and", sonra onlar ve birler.`,
        cozum: [`${X} satırında fiyat ${fiyat[i]} TL.`, `${fiyat[i]} = ${sayiYazi(fiyat[i])}.`], dogrulama });
    } else {
      ekle({ ...ortak, alt_konu: 'Sözcükle verilen fiyattan ürünü bulma', zorluk: 3, kok: `Look at the price list. Which item costs ${sayiYazi(fiyat[i])} TL?`, dogru: `The ${X.toLowerCase()}.`, celdirici: cel.map((j) => `The ${urun[j].toLowerCase()}.`),
        gerekce: cel.map((j) => `${urun[j]} ${fiyat[j]} TL'dir; sorulan fiyat ${fiyat[i]} TL.`), ipucu: `${sayiYazi(fiyat[i])} sayısını rakamla yaz ve listede ara.`,
        cozum: [`${sayiYazi(fiyat[i])} = ${fiyat[i]}.`, `${fiyat[i]} TL yazan satır ${X}.`], dogrulama });
    }
  }
  return { fiyatSorusu };
}

export const KAYIT = [
  { id: 'eng6-fiyat-listesi', ders: 'İngilizce', sinif: 6, idOnek: 'ENG6-FYT', mufredat_surum: MUFREDAT, kodlar: ['ENG.6.2.R2'], fabrika: kur, uret: (f) => f.fiyatSorusu() },
];
