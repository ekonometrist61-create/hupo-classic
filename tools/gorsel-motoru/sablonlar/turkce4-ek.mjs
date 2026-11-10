// 4. sınıf Türkçe (önceki program) — T.4.3.34 çizelge okuma ve T.4.3.22 levha işaretlerinin anlamı.
// Çizelge sorularının cevabı hücre değerlerinden kodla hesaplanır; çeldiriciler ardışık değerlerdir.
// Levha sorusunda cevap, şekildeki işaretin anlamıdır; çeldiriciler başka işaretlerin anlamlarıdır.
import { surum, pencere } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_4_turkce_onceki');
const URUNLER = ['Elma', 'Armut', 'Üzüm', 'Kiraz', 'Şeftali'];
const GUNLER = ['Pazartesi', 'Salı', 'Çarşamba'];
const ISARET_ANLAM = {
  hastane: 'Sağlık hizmeti alınabilecek yer',
  bilgi: 'Bilgi alınabilecek yer',
  su: 'İçme suyu bulunan yer',
  yemek: 'Yemek yenilebilecek yer',
  kitap: 'Kitap okunabilecek ya da ödünç alınabilecek yer',
  otopark: 'Araçların park edebileceği yer',
  otobus: 'Otobüs durağı',
};
const KONUM_AD = ['soldaki', 'ortadaki', 'sağdaki'];

// ---------- T.4.3.34: çizelge okuma ----------
export function kurCizelge({ R, sec, karistir, ekle, konum }) {
  function cizelgeSorusu() {
    const satirlar = URUNLER.map((etiket) => ({ etiket, hucreler: GUNLER.map(() => 4 + Math.floor(R() * 57)) }));
    const v = (i, j) => satirlar[i].hucreler[j];
    const tur = sec(['hucre', 'satir', 'sutun', 'fark']);
    const k = konum();
    const secenek = (dogru) => {
      const s = pencere(dogru, k, 1);
      if (!s) throw new Error('pencere');
      return s;
    };
    const ortak = (kok, dogru, s, ipucu, cozum, dogrulama) => ekle({
      kod: 'T.4.3.34', konu: 'Çizelge okuma', alt_konu: 'Tablo ya da çizelgedeki değerleri okuyup hesaplama', zorluk: tur === 'hucre' ? 1 : 2,
      spec: { tip_id: 'a7-cizelge', parametreler: { baslik: 'Satış çizelgesi (adet)', ilkSutun: 'Ürün', sutunlar: GUNLER, satirlar } },
      kok, dogru: String(dogru), sirali: s.map(String),
      gerekce: s.map((x) => (x === dogru ? '' : `${x} bu soruda istenen değer değildir; çizelgede ilgili değer ${dogru} olarak yazılmıştır.`)),
      ipucu, cozum, dogrulama,
    });
    if (tur === 'hucre') {
      const i = Math.floor(R() * URUNLER.length), j = Math.floor(R() * GUNLER.length), dogru = v(i, j);
      return ortak(`Şekildeki çizelgeye göre ${URUNLER[i]} ürününün ${GUNLER[j]} günü kaç adet satıldığı?`, dogru, secenek(dogru),
        `${URUNLER[i]} satırı ile ${GUNLER[j]} sütununun kesiştiği hücreye bak.`,
        [`${URUNLER[i]} satırı ile ${GUNLER[j]} sütunu kesiştirilir.`, `Bu hücredeki değer ${dogru}'dir.`],
        [{ yol: ['hucre', URUNLER[i], GUNLER[j]], beklenen: dogru }]);
    }
    if (tur === 'satir') {
      const i = Math.floor(R() * URUNLER.length), dogru = satirlar[i].hucreler.reduce((t, x) => t + x, 0);
      return ortak(`Şekildeki çizelgeye göre ${URUNLER[i]} ürününün üç günde toplam kaç adet satıldığı?`, dogru, secenek(dogru),
        `${URUNLER[i]} satırındaki üç değeri topla.`,
        [`${URUNLER[i]} satırındaki değerler: ${satirlar[i].hucreler.join(', ')}.`, `Toplam ${dogru} eder.`],
        [{ yol: ['satir_toplam', URUNLER[i]], beklenen: dogru }]);
    }
    if (tur === 'sutun') {
      const j = Math.floor(R() * GUNLER.length), dogru = satirlar.reduce((t, r) => t + r.hucreler[j], 0);
      return ortak(`Şekildeki çizelgeye göre ${GUNLER[j]} günü beş ürünün toplam kaç adet satıldığı?`, dogru, secenek(dogru),
        `${GUNLER[j]} sütunundaki beş değeri topla.`,
        [`${GUNLER[j]} sütunundaki değerler: ${satirlar.map((r) => r.hucreler[j]).join(', ')}.`, `Toplam ${dogru} eder.`],
        [{ yol: ['sutun_toplam', GUNLER[j]], beklenen: dogru }]);
    }
    // fark: aynı sütundaki iki hücrenin farkı
    const a = Math.floor(R() * URUNLER.length);
    let b = Math.floor(R() * URUNLER.length);
    if (b === a) b = (a + 1) % URUNLER.length;
    const j = Math.floor(R() * GUNLER.length), va = v(a, j), vb = v(b, j), dogru = Math.abs(va - vb);
    return ortak(`Şekildeki çizelgeye göre ${GUNLER[j]} günü ${URUNLER[a]} ile ${URUNLER[b]} ürünlerinin satış adetleri arasındaki fark kaçtır?`, dogru, secenek(dogru),
      `${GUNLER[j]} sütunundaki iki değeri bul ve büyük olandan küçük olanı çıkar.`,
      [`${GUNLER[j]} sütununda ${URUNLER[a]} ${va}, ${URUNLER[b]} ${vb} adet satmıştır.`, `Fark ${Math.max(va, vb)} - ${Math.min(va, vb)} = ${dogru} olur.`],
      [{ yol: ['hucre', URUNLER[a], GUNLER[j]], beklenen: va }, { yol: ['hucre', URUNLER[b], GUNLER[j]], beklenen: vb }]);
  }
  return { cizelgeSorusu };
}

// ---------- T.4.3.22: levhadaki işaretin anlamı ----------
export function kurIsaret({ R, sec, karistir, ekle, konum }) {
  function isaretSorusu() {
    const ids = karistir(Object.keys(ISARET_ANLAM)).slice(0, 3);
    const k = sec([0, 1, 2]);
    const dogru = ISARET_ANLAM[ids[k]];
    const cel = karistir(Object.values(ISARET_ANLAM).filter((a) => a !== dogru)).slice(0, 3);
    return ekle({ kod: 'T.4.3.22', konu: 'Şekil ve sembol anlamı', alt_konu: 'Levhadaki işaret ve sembollerin anlamını kavrama', zorluk: 2,
      spec: { tip_id: 'tr4-isaret-levha', parametreler: { isaretler: ids } },
      kok: `Şekildeki levhada ${KONUM_AD[k]} işaretin anlamı aşağıdakilerden hangisidir?`,
      dogru, celdirici: cel,
      gerekce: cel.map((c) => `"${c}" anlamı levhadaki ${KONUM_AD[k]} işarete değil, levhadaki başka bir işarete aittir.`),
      ipucu: 'Soruda istenen konumdaki işarete bak; işaretin şeklini tanı ve anlamını seçeneklerle karşılaştır.',
      cozum: [`${KONUM_AD[k].charAt(0).toLocaleUpperCase('tr-TR')}${KONUM_AD[k].slice(1)} işaretin şekli ${dogru} anlamını taşır.`, `Doğru seçenek "${dogru}" biçimindedir.`],
      dogrulama: [{ yol: ['isaretler', String(k)], beklenen: ids[k] }] });
  }
  return { isaretSorusu };
}

export const KAYIT = [
  { id: 'tr4-tablo-cizelge', ders: 'Türkçe', sinif: 4, idOnek: 'TR4-CZL', mufredat_surum: MUFREDAT, kodlar: ['T.4.3.34'], fabrika: kurCizelge, uret: (f) => f.cizelgeSorusu() },
  { id: 'tr4-levha-anlam', ders: 'Türkçe', sinif: 4, idOnek: 'TR4-ISR', mufredat_surum: MUFREDAT, kodlar: ['T.4.3.22'], fabrika: kurIsaret, uret: (f) => f.isaretSorusu() },
];
