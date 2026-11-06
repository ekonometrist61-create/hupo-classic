// 1. sınıf Hayat Bilgisi — geri dönüştürülebilen atıkların sınıflandırılması (HB.1.5.4). Atık resimle verilir; malzeme şekilden okunur.
import { MUF, ADLISTE, sik4, gerekceSabit } from './hayat2-ortak.mjs';

const MALZEME = {
  kagit: { ad: 'kâğıt', kutu: 'Kâğıt kutusu', ikon: [['gazete', 'Gazete'], ['karton', 'Karton kutu']] },
  plastik: { ad: 'plastik', kutu: 'Plastik kutusu', ikon: [['suSisesi', 'Plastik su şişesi'], ['kova', 'Plastik kova']] },
  cam: { ad: 'cam', kutu: 'Cam kutusu', ikon: [['kavanoz', 'Cam kavanoz'], ['camSise', 'Cam şişe']] },
  metal: { ad: 'metal', kutu: 'Metal kutusu', ikon: [['konserve', 'Konserve kutusu'], ['icecekKutusu', 'Metal içecek kutusu']] },
};
const MALZEMELER = Object.keys(MALZEME);

export function kur({ sec, karistir, ekle, konum }) {
  const ornek = (m) => sec(MALZEME[m].ikon);

  function tekAtik() {
    const m = sec(MALZEMELER), [ikon, ad] = ornek(m), kisi = sec(ADLISTE);
    const dogru = MALZEME[m].kutu, cel = karistir(MALZEMELER.filter((x) => x !== m)).map((x) => MALZEME[x].kutu);
    ekle({ kod: 'HB.1.5.4', konu: 'Doğa ve Çevre', alt_konu: 'Geri dönüşüm kutuları', zorluk: 1,
      spec: { tip_id: 'a2-ikon-dizisi', parametreler: { ikonlar: [ikon] } },
      kok: `${kisi}, resimdeki atığı geri dönüşüm kutusuna atmak istiyor. Bu atık hangi kutuya atılmalıdır?`,
      dogru, celdirici: cel,
      gerekce: cel.map((c) => `Resimdeki atık ${MALZEME[m].ad} maddesindendir; ${c.toLowerCase()} başka bir maddenin atıkları içindir.`),
      ipucu: 'Resimdeki atığın neyden yapıldığına bak.',
      cozum: [`Resimdeki atık: ${ad.toLowerCase()}.`, `Bu atık ${MALZEME[m].ad} maddesindendir; ${dogru.toLowerCase()} atılır.`],
      dogrulama: [{ yol: ['numarali', '1'], beklenen: ikon }] });
  }

  function numaraliAtik() {
    const k = konum(), m = sec(MALZEMELER), diger = karistir(MALZEMELER.filter((x) => x !== m));
    const sirali = diger.slice(0, 3); sirali.splice(k, 0, m);
    const secimler = sirali.map((x) => ornek(x));
    const siklar = [1, 2, 3, 4].map((n) => `${n} numaralı atık`);
    const tamamlayici = (m === 'cam' || m === 'plastik') ? 'atık kutusuna' : 'atık kutusuna';
    ekle({ kod: 'HB.1.5.4', konu: 'Doğa ve Çevre', alt_konu: 'Atıkları sınıflandırma', zorluk: 1,
      spec: { tip_id: 'a2-ikon-dizisi', parametreler: { ikonlar: secimler.map((x) => x[0]), numara: true } },
      kok: `Yukarıdaki atıklardan hangisi ${MALZEME[m].ad} ${tamamlayici} atılmalıdır?`,
      dogru: siklar[k], sirali: siklar,
      gerekce: gerekceSabit(k, (s, i) => `${i + 1} numaralı atık ${MALZEME[sirali[i]].ad} maddesindendir; ${MALZEME[m].ad} atık kutusuna atılmaz.`, siklar),
      ipucu: 'Her atığın neyden yapıldığına bak.',
      cozum: [`${k + 1} numaralı resimde ${secimler[k][1].toLowerCase()} vardır.`, `Bu atık ${MALZEME[m].ad} maddesindendir; ${MALZEME[m].ad} atık kutusuna atılır.`],
      dogrulama: secimler.map((x, i) => ({ yol: ['numarali', String(i + 1)], beklenen: x[0] })) });
  }
  return { tekAtik, numaraliAtik };
}

export const KAYIT = [
  { id: 'hb1-atik-tek', ders: 'Hayat Bilgisi', sinif: 1, idOnek: 'HB1-ATK', mufredat_surum: MUF.hb1, kodlar: ['HB.1.5.4'], fabrika: kur, uret: (f, c) => (c.R() < 0.4 ? f.tekAtik() : f.numaraliAtik()) },
];
