// 2. sınıf Hayat Bilgisi — mevsimler ve hava olayları (HB.2.5.1). Aynı ağacın dört mevsimdeki resmi; mevsim ya da resim harfi sorulur.
import { MUF, gerekceSabit } from './hayat2-ortak.mjs';

const MEVSIM = {
  ilkbahar: { ad: 'İlkbahar', ipucu: ['Ağaçlar çiçek açar ve hava yavaş yavaş ısınır.', 'Doğa canlanır, ağaçlarda yeni yapraklar çıkar.', 'Hava ılıktır, sık sık yağmur yağar.'] },
  yaz: { ad: 'Yaz', ipucu: ['Hava çok sıcaktır, okullar tatildir.', 'Günler en uzundur, çocuklar denizde yüzer.', 'Güneş çok parlaktır, insanlar ince giysiler giyer.'] },
  sonbahar: { ad: 'Sonbahar', ipucu: ['Ağaçların yaprakları sararıp dökülür.', 'Hava serinlemeye başlar, okullar açılır.', 'Rüzgâr yaprakları yerlere savurur.'] },
  kis: { ad: 'Kış', ipucu: ['Hava çok soğuktur ve kar yağar.', 'Yerler karla kaplanır, kalın giysiler giyilir.', 'Gündüzler kısa, geceler uzundur ve hava dondurucudur.'] },
};
const MEVSIMLER = Object.keys(MEVSIM);
const HARF = 'ABCD';

export function kur({ R, sec, karistir, ekle, konum }) {
  // Doğru mevsim k. panelde; cevap harfli şık.
  function harfSor() {
    const k = konum(), m = sec(MEVSIMLER), diger = karistir(MEVSIMLER.filter((x) => x !== m)).slice(0, 3);
    const sira = diger.slice(); sira.splice(k, 0, m);
    const ipucu = sec(MEVSIM[m].ipucu);
    const siklar = HARF.split('').map((h) => `${h} resmi`);
    ekle({ kod: 'HB.2.5.1', konu: 'Doğa ve Çevre', alt_konu: 'Mevsimler ve hava olayları', zorluk: 1,
      spec: { tip_id: 'a2-mevsim-paneli', parametreler: { sira } },
      kok: `Resimde aynı ağaç dört farklı mevsimde gösteriliyor. ${ipucu} Bu özellik hangi resimdeki mevsime aittir?`,
      dogru: siklar[k], sirali: siklar,
      gerekce: gerekceSabit(k, (s, i) => `${HARF[i]} resmi ${MEVSIM[sira[i]].ad.toLowerCase()} mevsimini gösterir; verilen özellik bu mevsime ait değildir.`, siklar),
      ipucu: 'Önce özelliğin hangi mevsime ait olduğunu düşün, sonra ağacın her resimde nasıl göründüğüne bak.',
      cozum: [`Verilen özellik ${MEVSIM[m].ad.toLowerCase()} mevsimine aittir.`, `${MEVSIM[m].ad} mevsimi ${HARF[k]} resminde gösterilmiştir.`],
      dogrulama: [{ yol: ['panel', m], beklenen: HARF[k] }] });
  }

  // Belirli harfli resmin mevsimi; cevap mevsim adı.
  function mevsimSor() {
    const sira = karistir(MEVSIMLER.slice()), i = Math.floor(R() * 4), m = sira[i];
    const dogru = MEVSIM[m].ad, cel = sira.filter((x) => x !== m).map((x) => MEVSIM[x].ad);
    ekle({ kod: 'HB.2.5.1', konu: 'Doğa ve Çevre', alt_konu: 'Mevsimler ve hava olayları', zorluk: 1,
      spec: { tip_id: 'a2-mevsim-paneli', parametreler: { sira } },
      kok: `Resimde aynı ağaç dört farklı mevsimde gösteriliyor. ${HARF[i]} resmi hangi mevsimi gösterir?`,
      dogru, celdirici: cel,
      gerekce: cel.map((c) => `${HARF[i]} resmindeki ağacın görünümü ${dogru.toLowerCase()} mevsimine uygundur; ${c.toLowerCase()} mevsimine uymaz.`),
      ipucu: 'Ağacın dallarına, yapraklarına ve yerdeki zemine bak.',
      cozum: [`${HARF[i]} resmindeki ağaç ve zemin ${dogru.toLowerCase()} mevsimindeki hâlini gösterir.`, `Doğru cevap ${dogru}.`],
      dogrulama: [{ yol: ['panel', m], beklenen: HARF[i] }] });
  }
  return { harfSor, mevsimSor };
}

export const KAYIT = [
  { id: 'hb2-mevsim-panel', ders: 'Hayat Bilgisi', sinif: 2, idOnek: 'HB2-MVS', mufredat_surum: MUF.hb2, kodlar: ['HB.2.5.1'], fabrika: kur, uret: (f, c) => (c.R() < 0.5 ? f.harfSor() : f.mevsimSor()) },
];
