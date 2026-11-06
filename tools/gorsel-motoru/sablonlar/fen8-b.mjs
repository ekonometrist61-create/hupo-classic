// 8. sınıf Fen Bilimleri (önceki program) — Asit-baz: pH ölçeğinde çıkarım (F.8.4.4.4). Şekil: b2-ph.
// Dört madde pH ölçeğinde işaretlenir; soru türüne göre cevap pH değerlerinden kodla bulunur.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 8. sınıf; program: önceki program)';
const HARF = ['K', 'L', 'M', 'N'];
const TUR = ['en_asit', 'en_baz', 'notr', 'tek_asit', 'tek_baz'];

export function kur({ R, sec, karistir, ekle, konum }) {
  const ASIT = [1, 2, 3, 4, 5, 6], BAZ = [8, 9, 10, 11, 12, 13];
  const cek = (havuz, n) => karistir(havuz).slice(0, n);
  function phSorusu() {
    const k = konum(), tur = sec(TUR);
    let hedef, dig, kok, ipucu, aciklama;
    if (tur === 'en_asit') {
      const t = cek([...ASIT, ...BAZ, 7], 4).sort((a, b) => a - b); hedef = t[0]; dig = t.slice(1); if (hedef >= 7) throw new Error('asit_yok');
      kok = 'pH ölçeği üzerinde K, L, M ve N maddelerinin pH değerleri işaretlenmiştir. Hangi madde en güçlü asit özelliği gösterir?';
      ipucu = 'pH değeri 7’den küçüldükçe asitlik artar.'; aciklama = 'pH değeri en küçük olan madde en güçlü asittir';
    } else if (tur === 'en_baz') {
      const t = cek([...ASIT, ...BAZ, 7], 4).sort((a, b) => a - b); hedef = t[3]; dig = t.slice(0, 3); if (hedef <= 7) throw new Error('baz_yok');
      kok = 'Şekildeki pH ölçeğinde dört maddenin pH değeri gösterilmiştir. Hangi madde en güçlü baz özelliği gösterir?';
      ipucu = 'pH değeri 7’den büyüdükçe bazlık artar.'; aciklama = 'pH değeri en büyük olan madde en güçlü bazdır';
    } else if (tur === 'notr') {
      hedef = 7; dig = cek([...ASIT, ...BAZ], 3);
      kok = 'Şekilde pH ölçeği üzerinde K, L, M ve N maddeleri işaretlenmiştir. Hangi madde nötr özelliktedir?';
      ipucu = 'Nötr maddelerin pH değeri 7’dir.'; aciklama = 'pH değeri 7 olan madde nötrdür';
    } else if (tur === 'tek_asit') {
      hedef = sec(ASIT); dig = cek(BAZ, 3);
      kok = 'pH ölçeğinde dört maddenin pH değeri gösterilmiştir. Bu maddelerden hangisi asit özelliği gösterir?';
      ipucu = 'pH değeri 7’den küçük olan maddeler asittir.'; aciklama = 'pH değeri 7’den küçük olan tek madde asittir';
    } else {
      hedef = sec(BAZ); dig = cek(ASIT, 3);
      kok = 'Şekilde dört maddenin pH ölçeğindeki yeri gösterilmiştir. Bu maddelerden hangisi baz özelliği gösterir?';
      ipucu = 'pH değeri 7’den büyük olan maddeler bazdır.'; aciklama = 'pH değeri 7’den büyük olan tek madde bazdır';
    }
    const sira = karistir(dig); sira.splice(k, 0, hedef);
    const durum = (p) => (p < 7 ? 'asit' : p > 7 ? 'baz' : 'nötr');
    const ornekler = sira.map((ph, i) => ({ ad: HARF[i], ph }));
    ekle({ kod: 'F.8.4.4.4', konu: 'Asit ve Bazlar', alt_konu: 'pH değerinden çıkarım', zorluk: tur === 'notr' || tur.startsWith('tek') ? 1 : 2,
      spec: { tip_id: 'b2-ph', parametreler: { ornekler } }, sirali: HARF, dogru: HARF[k], kok, ipucu,
      gerekce: HARF.map((h, i) => (i === k ? '' : `${h} maddesinin pH değeri ${sira[i]}’dir; bu madde ${durum(sira[i])} özelliği gösterir ve istenen koşulu sağlamaz.`)),
      cozum: [`${aciklama}.`, `Ölçekte ${HARF[k]} maddesinin pH değeri ${hedef}’dir; istenen madde ${HARF[k]} maddesidir.`],
      dogrulama: HARF.map((h, i) => ({ yol: ['ph', h], beklenen: sira[i] })) });
  }
  return { phSorusu };
}

export const KAYIT = [
  { id: 'fen8-ph-olcegi', ders: 'Fen Bilimleri', sinif: 8, idOnek: 'FEN8-PH', mufredat_surum: MUFREDAT, kodlar: ['F.8.4.4.4'], fabrika: kur,
    uret: (f) => f.phSorusu() },
];
