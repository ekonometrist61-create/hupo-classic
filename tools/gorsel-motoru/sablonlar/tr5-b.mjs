// 5. sınıf Türkçe — T.O.5.10 Okuduklarını karşılaştırabilme (tablodaki iki değeri karşılaştırma).
// En çok/en az sorusunun cevabı tablo değerlerinden kodla bulunur; çeldiriciler diğer satırlardır.
import { surum } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_5_turkce');
const ADLAR = ['Ada', 'Mert', 'Elif', 'Can', 'Defne', 'Emir', 'Zeynep', 'Kerem', 'Işıl', 'Barış'];
const SUTUN = ['Okunan kitap (adet)', 'Okunan sayfa'];

export function kur({ R, sec, karistir, ekle }) {
  function karsilastirma() {
    const adlar = karistir(ADLAR).slice(0, 4);
    const kitap = karistir([3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]).slice(0, 4);
    const sayfa = karistir([120, 160, 210, 260, 310, 350, 420, 480, 540, 610, 680, 750]).slice(0, 4);
    const satirlar = adlar.map((a, i) => [a, kitap[i], sayfa[i]]);
    const j = sec([0, 1]), enCok = sec([true, false]);
    const deg = j === 0 ? kitap : sayfa;
    const hedef = enCok ? Math.max(...deg) : Math.min(...deg);
    const di = deg.indexOf(hedef);
    const dogru = adlar[di];
    const cel = adlar.filter((_, k) => k !== di);
    const sutun = SUTUN[j];
    const kok = j === 0
      ? `Tabloya göre en ${enCok ? 'çok' : 'az'} kitap okuyan öğrenci kimdir?`
      : `Tabloya göre en ${enCok ? 'çok' : 'az'} sayfa okuyan öğrenci kimdir?`;
    ekle({ kod: 'T.O.5.10', konu: 'Karşılaştırma', alt_konu: 'Tablodaki değerleri karşılaştırma', zorluk: 1,
      spec: { tip_id: 'b3-tablo', parametreler: { baslik: 'Okuma Tablosu', sutunlar: ['Öğrenci', ...SUTUN], satirlar } },
      kok, dogru, celdirici: cel,
      gerekce: cel.map((c) => `${c}, "${sutun}" sütununda ${enCok ? 'en büyük' : 'en küçük'} değere sahip değildir.`),
      ipucu: `"${sutun}" sütunundaki değerleri karşılaştır; ${enCok ? 'en büyüğünü' : 'en küçüğünü'} bul.`,
      cozum: [`"${sutun}" sütunundaki değerler karşılaştırılır.`, `${enCok ? 'En büyük' : 'En küçük'} değer ${hedef}'dir ve ${dogru} satırındadır.`],
      dogrulama: [{ yol: ['hucre', dogru, sutun], beklenen: hedef }] });
  }
  return { karsilastirma };
}

export const KAYIT = [
  { id: 'tr5-tablo-karsilastir', ders: 'Türkçe', sinif: 5, idOnek: 'TR5-TKR', mufredat_surum: MUFREDAT, kodlar: ['T.O.5.10'], fabrika: kur, uret: (f) => f.karsilastirma() },
];
