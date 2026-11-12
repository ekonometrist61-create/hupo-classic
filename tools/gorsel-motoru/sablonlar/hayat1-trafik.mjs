// 1. sınıf Hayat Bilgisi — trafik ışığı. Yeniden tasarım (hb123_v2): soru davranış değil şekildeki yanan lambayı okutur
// (renk, konum, sıra, üstündeki/altındaki lamba sayısı). Kök yanan lambayı söylemez; şıklar şekle bağlı değerlerdir.
// 3 yanan lamba × (5 soru biçimi, ikisi 2 kök sözlü) = 21 farklı soru.
// Not: paket.test.mjs 'eksik üretim' testi trafik kazanımında toplam 46 farklı soru bekler (trafik 21 + kavşak 25); sayıyı değiştirirsen o testi güncelle.
const MUFREDAT = 'TYMM 1-2 taslak 2026-27';
const ISIKLAR = ['kirmizi', 'sari', 'yesil']; // yukarıdan aşağıya sıra
const HICBIRI = 'Hiçbir lamba yanmıyor';
const SAYI = ['0 lamba', '1 lamba', '2 lamba', '3 lamba'];

// Her biçim: kokler, siklar (4 aday, sonuncusu/biri elenen), dogru(i) = yanan lambanın sıra numarası (0 üst, 1 orta, 2 alt) için doğru şık.
const BICIMLER = [
  { ad: 'renk', kokler: ['Yukarıdaki trafik ışığında yanan lamba hangi renktedir?', 'Şekildeki trafik ışığında hangi renkli lamba yanmaktadır?'],
    siklar: ['Kırmızı', 'Sarı', 'Yeşil', HICBIRI], dogru: (i) => ['Kırmızı', 'Sarı', 'Yeşil'][i],
    sebep: () => 'Şekilde yanan lamba bu renkte görünmüyor; renkli (yanan) lambaya bak.' },
  { ad: 'konum', kokler: ['Yukarıdaki trafik ışığında yanan lamba hangi konumdadır?', 'Şekildeki ışıkta yanan lamba ışığın neresindedir?'],
    siklar: ['Üstteki lamba', 'Ortadaki lamba', 'Alttaki lamba', HICBIRI], dogru: (i) => ['Üstteki lamba', 'Ortadaki lamba', 'Alttaki lamba'][i],
    sebep: () => 'Şekilde yanan (renkli) lamba bu konumda değil; gri lambalar yanmayan lambalardır.' },
  { ad: 'sira', kokler: ['Yukarıdaki trafik ışığında yanan lamba yukarıdan aşağıya doğru kaçıncı lambadır?'],
    siklar: ['Yukarıdan 1. lamba', 'Yukarıdan 2. lamba', 'Yukarıdan 3. lamba', HICBIRI], dogru: (i) => `Yukarıdan ${i + 1}. lamba`,
    sebep: () => 'Lambaları yukarıdan aşağıya say; yanan (renkli) lamba şekilde bu sırada değil.' },
  { ad: 'ust', kokler: ['Yukarıdaki trafik ışığında yanan lambanın üstünde kaç lamba vardır?'],
    siklar: SAYI, dogru: (i) => SAYI[i],
    sebep: () => 'Yanan lambanın üstündeki lambaları şekilde say; sayı bununla uyuşmuyor.' },
  { ad: 'alt', kokler: ['Yukarıdaki trafik ışığında yanan lambanın altında kaç lamba vardır?'],
    siklar: SAYI, dogru: (i) => SAYI[2 - i],
    sebep: () => 'Yanan lambanın altındaki lambaları şekilde say; sayı bununla uyuşmuyor.' },
];

export function kur({ sec, ekle }) {
  function isikSorusu() {
    const yanan = sec(ISIKLAR), i = ISIKLAR.indexOf(yanan), b = sec(BICIMLER);
    const dogru = b.dogru(i);
    const cel = b.siklar.filter((x) => x !== dogru);
    const sebep = (x) => (x === HICBIRI ? 'Şekilde bir lamba renkli yanmaktadır; gri lambalar sönüktür.' : b.sebep(x));
    ekle({ kod: 'HB.1.2.3', konu: 'Güvenli Yaşam', alt_konu: 'Trafik ışıkları', zorluk: 1, spec: { tip_id: 'trafik-isigi', parametreler: { yanan } },
      dogru, celdirici: cel, gerekce: cel.map(sebep),
      kok: sec(b.kokler),
      ipucu: 'Üç lambadan renkli olanı bul; gri lambalar yanmıyor. Sonra sorulan şeye göre rengine, yerine ya da çevresindeki lambalara bak.',
      cozum: ['Şekilde üç lambaya yukarıdan aşağıya bak ve renkli (yanan) lambayı bul.', 'Sorulan şeyi (renk, konum, sıra ya da lamba sayısı) şekilden oku.'],
      dogrulama: [{ yol: ['yanan'], beklenen: yanan }] });
  }
  return { isikSorusu };
}

export const KAYIT = [
  { id: 'hb1-trafik-isigi', ders: 'Hayat Bilgisi', sinif: 1, idOnek: 'HB1-TRF', mufredat_surum: MUFREDAT, kodlar: ['HB.1.2.3'], fabrika: kur, uret: (f) => f.isikSorusu() },
];
