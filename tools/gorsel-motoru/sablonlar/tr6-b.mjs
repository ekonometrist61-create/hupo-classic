// 6. sınıf Türkçe — şiirin biçim özellikleri: kıta ve dize sayısı (T.O.6.17).
// Şiir yapısı (kıta/dize düzeni) yalnız şekilde görünür; kıtalar 2 ve 4 dizelik karışık kurulur,
// soru kökleri ve şıklar sayıyı vermez, değer şekilden sayılarak bulunur.
import { surum, COUPLET, pencere, tekilEkle, sonSoz } from './turkce3-ortak.mjs';
const MUFREDAT = surum('kazanim_6_turkce');

function siirKurV2(ctx, cfg) {
  const { R, sec, karistir, konum } = ctx, ekle = tekilEkle(ctx.ekle);
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
    const ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec, zorluk: 2 };
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
        [`Şekilde boşluklarla ayrılmış kıtalar ayırt edilir.`, `Her kıtanın dizeleri sayılır ve ${b} dizelik olanlar toplanır.`], 'Önce kıtaları ayır, sonra her kıtanın satırlarını say.');
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
  { id: 'tr6-siir', ders: 'Türkçe', sinif: 6, idOnek: 'TR6-SIR', mufredat_surum: MUFREDAT, kodlar: ['T.O.6.17'],
    fabrika: (c) => siirKurV2(c, { kod: 'T.O.6.17', konu: 'Şiir', alt_konu: 'Şiirin kıta ve dize özelliklerini belirleme' }),
    uret: (f) => f.siir() },
];
