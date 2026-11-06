// 2. sınıf Hayat Bilgisi — Güneş'in doğduğu/battığı yönden yön bulma (HB.2.5.2). Çocuğun dört yanındaki nesneler; yön ya da nesne sorulur.
import { MUF, gerekceSabit } from './hayat2-ortak.mjs';

const TARAFLAR = ['ust', 'sag', 'alt', 'sol'];
const YONLER = ['kuzey', 'doğu', 'güney', 'batı'];
const NESNE = { agac: 'ağaç', ev: 'ev', top: 'top', araba: 'araba', bisiklet: 'bisiklet', gemi: 'gemi', balon: 'balon', canta: 'çanta', kitap: 'kitap' };
const NESNELER = Object.keys(NESNE);
const buyuk = (s) => s.charAt(0).toLocaleUpperCase('tr') + s.slice(1);
const DURUM = { dogiyor: 'doğuyor', batiyor: 'batıyor' };

export function kur({ R, sec, karistir, ekle, konum }) {
  // Güneş'in kenarına göre her yönün karşılığı (tip ile aynı kural).
  function yonHaritasi(taraf, durum, nesneler) {
    const ti = TARAFLAR.indexOf(taraf), hedef = durum === 'dogiyor' ? 1 : 3, kayma = (ti - hedef + 4) % 4, yon = {};
    YONLER.forEach((y, d) => { yon[y] = nesneler[TARAFLAR[(d + kayma) % 4]]; });
    return yon;
  }
  const rasgeleDurum = () => (R() < 0.5 ? 'dogiyor' : 'batiyor');

  // Yön verilir, o yöndeki nesne sorulur.
  function nesneSor() {
    const durum = rasgeleDurum(), taraf = sec(TARAFLAR), s4 = karistir(NESNELER).slice(0, 4);
    const nesneler = Object.fromEntries(TARAFLAR.map((t, i) => [t, s4[i]]));
    const yon = yonHaritasi(taraf, durum, nesneler), y = sec(YONLER), d = yon[y];
    const dogru = buyuk(NESNE[d]), cel = s4.filter((x) => x !== d).map((x) => buyuk(NESNE[x]));
    ekle({ kod: 'HB.2.5.2', konu: 'Doğa ve Çevre', alt_konu: 'Doğadan yön bulma', zorluk: 2,
      spec: { tip_id: 'a2-gunes-yon', parametreler: { taraf, durum, nesneler } },
      kok: `Resimde Güneş ${DURUM[durum]}. Çocuğun ${y} yönünde hangi nesne vardır?`,
      dogru, celdirici: cel,
      gerekce: cel.map((c) => `${c} çocuğun ${y} yönünde değildir; ${y} yönünde ${dogru.toLowerCase()} vardır.`),
      ipucu: durum === 'dogiyor' ? 'Güneş doğudan doğar. Önce Güneş’in olduğu yönü bul, sonra diğer yönleri ona göre say.' : 'Güneş batıdan batar. Önce Güneş’in olduğu yönü bul, sonra diğer yönleri ona göre say.',
      cozum: [`Güneş ${DURUM[durum]}, bu yüzden Güneş’in olduğu taraf ${durum === 'dogiyor' ? 'doğu' : 'batı'} yönüdür.`, `Buradan ${y} yönü bulunur; orada ${NESNE[d]} vardır.`],
      dogrulama: [{ yol: ['yon', y], beklenen: d }] });
  }

  // Nesne verilir, bulunduğu yön sorulur (şıklar sabit sırada: doğru şık k. konumda).
  function yonSor() {
    const k = konum(), durum = rasgeleDurum(), taraf = sec(TARAFLAR), s4 = karistir(NESNELER).slice(0, 4);
    const ti = TARAFLAR.indexOf(taraf), hedef = durum === 'dogiyor' ? 1 : 3, kayma = (ti - hedef + 4) % 4;
    // YONLER[k] yönünde s4[0] bulunacak biçimde yerleştir.
    const nesneler = {};
    YONLER.forEach((y, d) => { nesneler[TARAFLAR[(d + kayma) % 4]] = s4[d === k ? 0 : (d < k ? d + 1 : d)]; });
    const hedefNesne = s4[0];
    const yon = yonHaritasi(taraf, durum, nesneler);
    const siklar = YONLER.map(buyuk);
    ekle({ kod: 'HB.2.5.2', konu: 'Doğa ve Çevre', alt_konu: 'Doğadan yön bulma', zorluk: 2,
      spec: { tip_id: 'a2-gunes-yon', parametreler: { taraf, durum, nesneler } },
      kok: `Resimde Güneş ${DURUM[durum]}. Çocuğa göre ${NESNE[hedefNesne]} hangi yöndedir?`,
      dogru: siklar[k], sirali: siklar,
      gerekce: gerekceSabit(k, (s, i) => `${buyuk(NESNE[hedefNesne])} ${YONLER[i]} yönünde değildir; ${YONLER[i]} yönünde ${NESNE[yon[YONLER[i]]]} vardır.`, siklar),
      ipucu: durum === 'dogiyor' ? 'Güneş doğudan doğar. Önce Güneş’in olduğu yönü bul.' : 'Güneş batıdan batar. Önce Güneş’in olduğu yönü bul.',
      cozum: [`Güneş ${DURUM[durum]}, bu yüzden Güneş’in olduğu taraf ${durum === 'dogiyor' ? 'doğu' : 'batı'} yönüdür.`, `Diğer yönler buna göre bulunur; ${NESNE[hedefNesne]} ${YONLER[k]} yönündedir.`],
      dogrulama: [{ yol: ['yon', YONLER[k]], beklenen: hedefNesne }] });
  }
  return { nesneSor, yonSor };
}

export const KAYIT = [
  { id: 'hb2-gunes-yon', ders: 'Hayat Bilgisi', sinif: 2, idOnek: 'HB2-YON', mufredat_surum: MUF.hb2, kodlar: ['HB.2.5.2'], fabrika: kur, uret: (f, c) => (c.R() < 0.5 ? f.nesneSor() : f.yonSor()) },
];
