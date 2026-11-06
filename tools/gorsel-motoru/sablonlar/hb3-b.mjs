// 3. sınıf Hayat Bilgisi — doğadaki varlıkların insan yaşamı için önemi (HB.3.5.1). Doğal varlık resimle verilir; sağladığı yarar sorulur ya da tersi.
import { MUF, ADLISTE, gerekceSabit } from './hayat2-ortak.mjs';

const VARLIK = {
  agac: { ad: 'ağaç', yarar: ['Havayı temizleyip oksijen verir.', 'Gölgesinde dinlenmemizi sağlar.', 'Odun ve kâğıt gibi maddelerin kaynağıdır.'] },
  gunes: { ad: 'Güneş', yarar: ['Bize ışık ve sıcaklık verir.', 'Dünyayı aydınlatır ve ısıtır.', 'Bitkilerin büyümesi için gereken ışığı sağlar.'] },
  balik: { ad: 'balık', yarar: ['Deniz ve nehirlerden yakalanıp yemek olarak yenir.', 'Yenebilen bir su hayvanıdır; balıkçılar onu avlar.', 'Balıkçıların avlayıp pazarda sattığı besindir.'] },
  bulut: { ad: 'bulut', yarar: ['Yağmur yağdırarak yeryüzüne su getirir.', 'İçindeki sudan yağmur olup toprağı sular.', 'Yağmurla barajları ve dereleri doldurur.'] },
};
const KEYS = Object.keys(VARLIK);

export function kur({ R, sec, karistir, ekle, konum }) {
  // Tek resim: sağladığı yarar sorulur.
  function yararSor() {
    const v = sec(KEYS), kisi = sec(ADLISTE), diger = KEYS.filter((x) => x !== v);
    const sirD = karistir(diger), dogru = sec(VARLIK[v].yarar), cel = sirD.map((x) => sec(VARLIK[x].yarar));
    ekle({ kod: 'HB.3.5.1', konu: 'Doğa ve Çevre', alt_konu: 'Doğadaki varlıkların önemi', zorluk: 1,
      spec: { tip_id: 'a2-ikon-dizisi', parametreler: { ikonlar: [v] } },
      kok: `${kisi}, resimdeki doğal varlığı inceliyor. Bu varlık insan yaşamına hangi yararı sağlar?`,
      dogru, celdirici: cel,
      gerekce: sirD.map((x) => `Bu yarar ${VARLIK[x].ad} için geçerlidir; resimdeki varlık ${VARLIK[x].ad} değildir.`),
      ipucu: 'Resimdeki varlığın ne olduğunu bul, sonra insanlar için ne işe yaradığını düşün.',
      cozum: [`Resimdeki varlık ${VARLIK[v].ad.toLowerCase() === 'güneş' ? 'Güneş' : VARLIK[v].ad}.`, `${dogru}`],
      dogrulama: [{ yol: ['numarali', '1'], beklenen: v }] });
  }

  // Numaralı dört resim: verilen yarara hangi varlık sahip?
  function varlikSor() {
    const k = konum(), v = sec(KEYS), diger = karistir(KEYS.filter((x) => x !== v)).slice(0, 3);
    const sirali = diger.slice(); sirali.splice(k, 0, v);
    const yarar = sec(VARLIK[v].yarar);
    const siklar = [1, 2, 3, 4].map((n) => `${n} numaralı resim`);
    ekle({ kod: 'HB.3.5.1', konu: 'Doğa ve Çevre', alt_konu: 'Doğadaki varlıkların önemi', zorluk: 2,
      spec: { tip_id: 'a2-ikon-dizisi', parametreler: { ikonlar: sirali, numara: true } },
      kok: `Aşağıdaki varlıklardan hangisi insanlara şu yararı sağlar? “${yarar}”`,
      dogru: siklar[k], sirali: siklar,
      gerekce: gerekceSabit(k, (s, i) => `${i + 1} numaralı resimdeki varlık bu yararı sağlamaz; bu yarar başka bir varlığa aittir.`, siklar),
      ipucu: 'Her resimdeki varlığın insanlara ne sağladığını düşün.',
      cozum: [`Verilen yarar ${VARLIK[v].ad.toLowerCase() === 'güneş' ? 'Güneş' : VARLIK[v].ad} için geçerlidir.`, `${k + 1} numaralı resimde ${VARLIK[v].ad === 'Güneş' ? 'Güneş' : VARLIK[v].ad} vardır.`],
      dogrulama: sirali.map((x, i) => ({ yol: ['numarali', String(i + 1)], beklenen: x })) });
  }
  return { yararSor, varlikSor };
}

export const KAYIT = [
  { id: 'hb3-dogal-varlik', ders: 'Hayat Bilgisi', sinif: 3, idOnek: 'HB3-DVL', mufredat_surum: MUF.hb3, kodlar: ['HB.3.5.1'], fabrika: kur, uret: (f, c) => (c.R() < 0.5 ? f.yararSor() : f.varlikSor()) },
];
