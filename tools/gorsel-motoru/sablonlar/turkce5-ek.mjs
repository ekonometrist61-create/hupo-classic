// 5. sınıf Türkçe — iki görsel şablon (şablonsuz kazanımlar).
// T.O.5.4  Kitap kapağından içerik tahmini: başlık nötrdür, konu yalnız üç resimden çıkar (a2-kapak).
// T.O.5.17 Şiirin biçim özellikleri: kıta ve dize düzeni yalnız şekilde görünür (b3-siir).
//          Soru kalıbı 6. sınıf şablonunun (tr6-b) 5. sınıf uyarlamasıdır; değerler şekilden sayılır.
import { surum, COUPLET, pencere, tekilEkle, sonSoz } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_5_turkce');

// ---------- T.O.5.4: kitap kapağı ----------
const BASLIKLAR = ['Bir Gün', 'Sessiz Kapı', 'Son Sayfa', 'Küçük Hikâye', 'Yeni Başlangıç', 'Ortak Hikâye'];
// Her konunun üç resmi farklıdır; çeldirici konuların resimleri doğru konuyla kesişmez.
const KONULAR = [
  { konu: 'Gökyüzü ve uzay gözlemi', ikonlar: ['ay', 'yildiz', 'bulut'], adlar: ['ay', 'yıldız', 'bulut'] },
  { konu: 'Meyveler ve sağlıklı beslenme', ikonlar: ['elma', 'muz', 'karpuz'], adlar: ['elma', 'muz', 'karpuz'] },
  { konu: 'Evde aile yaşamı', ikonlar: ['ev', 'masa', 'sandalye'], adlar: ['ev', 'masa', 'sandalye'] },
  { konu: 'Bahçede doğa ve canlılar', ikonlar: ['agac', 'cicek', 'kelebek'], adlar: ['ağaç', 'çiçek', 'kelebek'] },
  { konu: 'Spor ve oyun', ikonlar: ['top', 'bisiklet', 'balon'], adlar: ['top', 'bisiklet', 'balon'] },
  { konu: 'Okul, kitap ve okuma', ikonlar: ['kitap', 'kalem', 'gazete'], adlar: ['kitap', 'kalem', 'gazete'] },
];

function kapakKur({ sec, karistir, ekle }) {
  function kapakSorusu() {
    const dogru = sec(KONULAR);
    const diger = karistir(KONULAR.filter((k) => k !== dogru)).slice(0, 3);
    const ikonlar = karistir(dogru.ikonlar.slice());
    const baslik = sec(BASLIKLAR);
    const adlarYazi = dogru.adlar.join(', ');
    const spec = { tip_id: 'a2-kapak', parametreler: { baslik, ikonlar } };
    const kok = sec([
      'Kitabın kapağına ve başlığına bakıldığında kitabın konusu hakkında en uygun tahmin hangisidir?',
      'Kapaktaki üç resme göre bu kitapta hangi konu anlatılıyor olabilir?',
    ]);
    ekle({
      kod: 'T.O.5.4', konu: 'Tahmin', alt_konu: 'Kitap kapağından içerik tahmini yapabilme', zorluk: 1,
      spec, kok, dogru: dogru.konu, celdirici: diger.map((k) => k.konu),
      gerekce: diger.map((k) => `Kapaktaki resimler (${adlarYazi}) "${k.konu}" konusuna ait değildir.`),
      ipucu: 'Başlık tek başına konuyu göstermez; üç resmin ortak anlamına bak.',
      cozum: [`Kapaktaki üç resim (${adlarYazi}) incelenir.`, 'Resimlerin ortak konusu bulunur ve ona uygun tahmin seçilir.'],
      dogrulama: [{ yol: ['ikonlar'], beklenen: ikonlar }, { yol: ['baslik'], beklenen: baslik }],
    });
  }
  return { kapakSorusu };
}

// ---------- T.O.5.17: şiirin kıta ve dize düzeni ----------
function siirKur({ R, sec, karistir, konum, ekle: ekleOrj }) {
  const ekle = tekilEkle(ekleOrj);
  function siir() {
    const tur = sec(['n4', 'n2', 'toplam', 'sonrasi', 'sonIki', 'son']), k = konum();
    // 2 ve 4 dizelik kıtalar karışık; hem 2 hem 4 dizelik kıta bulunur
    const f = sec([1, 2]), t = sec([1, 2, 3]);
    if (f + t < 3) throw new Error('kita_az');
    const boyutlar = karistir([...Array(f).fill(4), ...Array(t).fill(2)]);
    const havuz = karistir(COUPLET); const kitalar = [];
    for (const b of boyutlar) {
      if (b === 2) { const c = havuz.shift(); if (!c) throw new Error('cift_yok'); kitalar.push([c.a, c.b]); }
      else {
        const c1 = havuz.shift(); const j = havuz.findIndex((c) => c.key !== c1?.key);
        if (!c1 || j < 0) throw new Error('cift_yok');
        const [c2] = havuz.splice(j, 1); kitalar.push([c1.a, c2.a, c1.b, c2.b]);
      }
    }
    const spec = { tip_id: 'b3-siir', parametreler: { kitalar } };
    const ortak = { kod: 'T.O.5.17', konu: 'Şiir', alt_konu: 'Şiirin kıta ve dize özelliklerini belirleme', spec, zorluk: 2 };
    const dz = kitalar.flat(), toplam = dz.length, n = kitalar.length;
    const say = (b) => boyutlar.filter((x) => x === b).length;
    const sayisal = (kok, dogru, dogrulama, atif, cozum, ipucu) => {
      const s = pencere(dogru, k, 1); if (!s) throw new Error('pencere');
      return ekle({ ...ortak, kok, sirali: s.map(String), dogru: String(dogru),
        gerekce: s.map((v) => `Şekildeki şiirde bu değer ${v} değildir; ${atif}`),
        ipucu, cozum, dogrulama: [{ yol: dogrulama.yol, beklenen: dogrulama.beklenen }] });
    };
    if (tur === 'n4' || tur === 'n2') {
      const b = tur === 'n4' ? 4 : 2, d = say(b);
      return sayisal(`Şekildeki şiirde ${b} dizeden oluşan kaç kıta vardır?`, d, { yol: ['kita_dize'], beklenen: boyutlar },
        `${b} dizelik kıtalar şekilde tek tek sayılmalıdır.`,
        ['Şekilde boşluklarla ayrılmış kıtalar ayırt edilir.', `Her kıtanın dizeleri sayılır ve ${b} dizelik olanlar toplanır.`], 'Önce kıtaları ayır, sonra her kıtanın satırlarını say.');
    }
    if (tur === 'toplam') {
      const s = pencere(toplam, k, 2); if (!s) throw new Error('pencere');
      return ekle({ ...ortak, kok: sec(['Şekildeki şiirde bütün kıtalardaki dizeler toplam kaç tanedir?', 'Şekildeki şiir toplam kaç dizeden (mısradan) oluşmaktadır?']), sirali: s.map(String), dogru: String(toplam),
        gerekce: s.map((v) => `Şekildeki şiirin bütün satırları sayıldığında bu değer ${v} çıkmaz.`),
        ipucu: 'Dize, şiirin her bir satırıdır; kıtalar ayırt edilmeden bütün satırlar sayılır.', cozum: ['Şekildeki bütün kıtaların satırları tek tek sayılır.', 'Elde edilen sayı toplam dize sayısıdır.'], dogrulama: [{ yol: ['dize_sayisi'], beklenen: toplam }] });
    }
    if (tur === 'sonrasi') {
      const i = 1 + Math.floor(R() * (n - 2)), d = kitalar.slice(i).flat().length; // i. kıtadan (1 tabanlı) sonrası
      return sayisal(`Şekildeki şiirde ${i}. kıtadan sonra gelen dizelerin sayısı kaçtır?`, d, { yol: ['kita_dize'], beklenen: boyutlar },
        `${i}. kıtadan sonraki kıtaların satırları şekilde sayılmalıdır.`,
        [`Şekilde ${i}. kıtanın bitişi bulunur.`, 'Bu kıtadan sonraki bütün satırlar sayılır.'], 'Önce istenen kıtayı bul, ondan sonraki satırları say.');
    }
    if (tur === 'sonIki') {
      const d = kitalar.slice(-2).flat().length;
      return sayisal('Şekildeki şiirin son iki kıtası toplam kaç dizeden oluşur?', d, { yol: ['kita_dize'], beklenen: boyutlar },
        'şiirin son iki kıtasının satırları şekilde sayılmalıdır.',
        ['Şekilde sondan iki kıta belirlenir.', 'Bu iki kıtadaki satırlar sayılıp toplanır.'], 'Şiirin altından başlayarak iki kıtayı ayır, satırlarını say.');
    }
    const ki = Math.floor(R() * n), di = Math.floor(R() * kitalar[ki].length), dogru = sonSoz(kitalar[ki][di]);
    const diger = karistir([...new Set(dz.map(sonSoz))].filter((w) => w !== dogru)).slice(0, 3); if (diger.length < 3) throw new Error('sozcuk_az');
    return ekle({ ...ortak, kok: `Şekildeki şiirde ${ki + 1}. kıtanın ${di + 1}. dizesinin son sözcüğü hangisidir?`, dogru, celdirici: diger,
      gerekce: diger.map((w) => `"${w}", şekilde başka bir dizenin sonunda yer alır; sorulan dize değildir.`),
      ipucu: 'Önce kıtayı, sonra o kıtadaki dizeyi bul; dizenin en sağdaki sözcüğüne bak.', cozum: [`Şekilde ${ki + 1}. kıta ve onun ${di + 1}. dizesi bulunur.`, 'Dizenin en sağdaki sözcüğü okunur.'], dogrulama: [{ yol: ['son_sozcuk', `${ki + 1}.${di + 1}`], beklenen: dogru }] });
  }
  return { siir };
}

export const KAYIT = [
  { id: 'tr5-kapak-tahmin', ders: 'Türkçe', sinif: 5, idOnek: 'TR5-KPK', mufredat_surum: MUFREDAT, kodlar: ['T.O.5.4'], fabrika: kapakKur, uret: (f) => f.kapakSorusu() },
  { id: 'tr5-siir-bicim', ders: 'Türkçe', sinif: 5, idOnek: 'TR5-SIR', mufredat_surum: MUFREDAT, kodlar: ['T.O.5.17'], fabrika: siirKur, uret: (f) => f.siir() },
];
