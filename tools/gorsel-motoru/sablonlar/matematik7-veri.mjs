// 7. sınıf Matematik — daire grafiği okuma (MAT.7.6.1) ve çizgi grafiği yorumlama (MAT.7.6.2).
// Veriler yalnız grafikte; kökte toplam dışında sayı yok. Şıklar komşu yüzde/değer pencereleri ya da tüm aralık/ay adlarıdır.
import { pencere } from '../tipler-a4.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 7. sınıf; program: TYMM)';
const TEMA = [
  { soru: 'en sevdikleri spor dalı', ad: ['Futbol', 'Yüzme', 'Basket', 'Tenis', 'Koşu'] },
  { soru: 'en sevdikleri meyve', ad: ['Elma', 'Armut', 'Muz', 'Çilek', 'Kiraz'] },
  { soru: 'en sevdikleri ders', ad: ['Fen', 'Türkçe', 'Müzik', 'Resim', 'Sosyal'] },
  { soru: 'okula geliş şekli', ad: ['Servis', 'Yürüyüş', 'Bisiklet', 'Otobüs', 'Araba'] },
  { soru: 'en sevdikleri hayvan', ad: ['Kedi', 'Köpek', 'Kuş', 'Balık', 'Tavşan'] },
];
const TOPLAMLAR = [40, 60, 80, 100, 120, 160, 200, 240, 300, 400];
const AYLAR = [['Oca', 'Ocak'], ['Şub', 'Şubat'], ['Mar', 'Mart'], ['Nis', 'Nisan'], ['May', 'Mayıs'], ['Haz', 'Haziran']];
const GUNLER = [['Pzt', 'Pazartesi'], ['Sal', 'Salı'], ['Çar', 'Çarşamba'], ['Per', 'Perşembe'], ['Cum', 'Cuma']];
const CIZGI_TEMA = [
  { baslik: 'Okunan Kitap Sayısı', birim: 'kitap', adlar: ['Ayşe', 'Efe', 'Deniz'], gen: 'Üç arkadaşın okuduğu kitap sayısı', zaman: AYLAR },
  { baslik: 'Satılan Ürün Sayısı', birim: 'adet', adlar: ['Şube A', 'Şube B', 'Şube C'], gen: 'Bir mağazanın şubelerinde satılan ürün sayısı', zaman: AYLAR },
  { baslik: 'Toplanan Kâğıt (kg)', birim: 'kg', adlar: ['5-A', '5-B', '5-C'], gen: 'Üç sınıfın topladığı atık kâğıt miktarı', zaman: GUNLER },
];
const OLCEK = [[12, 2], [20, 4], [10, 2], [16, 4]];

export function kur({ R, sec, karistir, ekle, konum }) {
  const rast = (a, b) => a + Math.floor(R() * (b - a + 1));
  function pastaSorusu() {
    const t = sec(TEMA), n = rast(3, 5), N = sec(TOPLAMLAR), tur = sec(['yuzde', 'aci', 'fark']);
    let birim = Array(n).fill(2); for (let k = 0; k < (100 - 10 * n) / 5 - 0; k++) birim[rast(0, n - 1)] += 1; // her dilim 10 + 5·ek
    const yuz = birim.map((b) => 5 * b);
    if (yuz.reduce((a, b) => a + b, 0) !== 100 || new Set(yuz).size < 2) throw new Error('paylar');
    const adlar = karistir(t.ad).slice(0, n), dilimler = adlar.map((ad, i) => ({ ad, deger: yuz[i] }));
    const gosterim = tur === 'aci' ? 'aci' : 'yuzde';
    const spec = { tip_id: 'a4-pasta', parametreler: { dilimler, gosterim } };
    const giris = `Bir okulda ${N} öğrenciye ${t.soru} sorulmuş ve cevaplar daire grafiğiyle gösterilmiştir.`;
    const kp = konum();
    const ortak = { kod: 'MAT.7.6.1', konu: 'Veri', alt_konu: 'Daire grafiğini okuma', spec };
    if (tur !== 'fark') {
      const X = sec(adlar), p = yuz[adlar.indexOf(X)];
      const { ps, vs } = pencere((q) => (N * q) / 100, p, kp, [5], 5);
      ekle({ ...ortak, zorluk: tur === 'aci' ? 3 : 2, kok: `${giris} Buna göre ${X} cevabını veren öğrenci sayısı kaçtır?`, sirali: vs.map(String), dogru: String((N * p) / 100),
        gerekce: ps.map((q, i) => (q === p ? '' : `${vs[i]} öğrenci, ${tur === 'aci' ? `${q * 3.6}°` : `%${q}`} dilimine karşılık gelir; grafikte ${X} dilimi ${tur === 'aci' ? `${p * 3.6}°` : `%${p}`} gösterilmiştir.`)),
        ipucu: tur === 'aci' ? 'Dilimin açısının 360° içindeki payını bul, toplam öğrenci sayısıyla çarp.' : 'Dilimin yüzdesini toplam öğrenci sayısıyla çarp.',
        cozum: tur === 'aci' ? [`${X} diliminin merkez açısı ${p * 3.6}°'dir, yani dairenin ${p * 3.6}/360 kadarıdır.`.replace("'dir", ' olarak okunur'), `${N} × ${p * 3.6}/360 = ${(N * p) / 100}`] : [`${X} dilimi %${p} olarak okunur.`, `${N} × ${p}/100 = ${(N * p) / 100}`],
        dogrulama: [{ yol: [tur === 'aci' ? 'aci' : 'yuzde', X], beklenen: tur === 'aci' ? p * 3.6 : p }] });
    } else {
      const sirala = [...dilimler].sort((a, b) => b.deger - a.deger), A = sirala[0], B = sirala[sirala.length - 1];
      if (A.deger === B.deger) throw new Error('esit');
      const f = (q) => (N * (q - B.deger)) / 100;
      const { ps, vs } = pencere(f, A.deger, kp, [5], B.deger + 5);
      ekle({ ...ortak, zorluk: 3, kok: `${giris} Buna göre ${A.ad} cevabını veren öğrenci sayısı, ${B.ad} cevabını veren öğrenci sayısından kaç fazladır?`, sirali: vs.map(String), dogru: String(f(A.deger)),
        gerekce: ps.map((q, i) => (q === A.deger ? '' : `${vs[i]}, ${A.ad} dilimi %${q} okunarak bulunur; grafikte %${A.deger} gösterilmiştir.`)),
        ipucu: 'İki dilimin yüzde farkını bul, toplam öğrenci sayısıyla çarp.',
        cozum: [`${A.ad} dilimi %${A.deger}, ${B.ad} dilimi %${B.deger} olarak okunur.`, `Fark %${A.deger - B.deger}; ${N} × ${A.deger - B.deger}/100 = ${f(A.deger)}`],
        dogrulama: [{ yol: ['yuzde', A.ad], beklenen: A.deger }, { yol: ['yuzde', B.ad], beklenen: B.deger }] });
    }
  }

  function cizgiSorusu() {
    const t = sec(CIZGI_TEMA), [max, adim] = sec(OLCEK), yarim = adim / 2, tur = sec(['artis', 'fark', 'toplam']);
    const n = tur === 'artis' ? 5 : sec([5, 6]), bas = t.zaman === AYLAR ? rast(0, AYLAR.length - n) : 0;
    const zaman = t.zaman.slice(bas, bas + n), kisa = zaman.map((z) => z[0]), tam = zaman.map((z) => z[1]);
    const seriSay = tur === 'artis' ? 1 : tur === 'fark' ? 2 : sec([2, 3]);
    const adlar = karistir(t.adlar).slice(0, seriSay);
    const deger = () => (1 + Math.floor(R() * (max / yarim - 1))) * yarim;
    const seriler = adlar.map((ad) => ({ ad, v: Array.from({ length: n }, deger) }));
    const spec = { tip_id: 'a4-cizgi-grafik', parametreler: { baslik: t.baslik, birim: t.birim === 'kg' ? 'kg' : undefined, x: kisa, seriler, max, adim } };
    const kp = konum();
    const birimZ = t.zaman === AYLAR ? 'ay' : 'gün';
    const ortak = { kod: 'MAT.7.6.2', konu: 'Veri', alt_konu: 'Çizgi grafiğini yorumlama', spec };
    if (tur === 'artis') {
      const v = seriler[0].v, farklar = v.slice(1).map((x, i) => x - v[i]), mx = Math.max(...farklar);
      if (farklar.filter((x) => x === mx).length !== 1 || mx <= 0) throw new Error('artis_belirsiz');
      const arl = farklar.map((_, i) => `${tam[i]}–${tam[i + 1]}`), dogru = arl[farklar.indexOf(mx)];
      const celdirici = arl.filter((x) => x !== dogru);
      ekle({ ...ortak, zorluk: 2, kok: `Grafikte ${seriler[0].ad} için "${t.baslik}" değerleri gösterilmiştir. Buna göre bu değer hangi iki ${birimZ} arasında en çok artmıştır?`, dogru, celdirici,
        gerekce: celdirici.map((c) => `${c} aralığında artış ${farklar[arl.indexOf(c)]} birimdir (ya da azalıştır); en büyük artış değildir.`),
        ipucu: 'Her iki ay arasındaki değişimi ayrı ayrı bul, en büyük artışı seç.',
        cozum: [`Ardışık aylar arasındaki değişimler: ${farklar.join(', ')}.`, `En büyük artış ${mx} birimdir ve ${dogru} aylarındadır.`],
        dogrulama: [{ yol: ['seriler', seriler[0].ad], beklenen: v }] });
    } else if (tur === 'fark') {
      const [a, b] = seriler, fark = a.v.map((x, i) => Math.abs(x - b.v[i])), mx = Math.max(...fark);
      if (fark.filter((x) => x === mx).length !== 1) throw new Error('fark_belirsiz');
      const dogru = tam[fark.indexOf(mx)], digerleri = karistir(tam.filter((x) => x !== dogru)).slice(0, 3);
      ekle({ ...ortak, zorluk: 2, kok: `${t.gen} grafikte gösterilmiştir. Buna göre ${a.ad} ile ${b.ad} arasındaki fark hangi zaman diliminde en fazladır?`, dogru, celdirici: digerleri,
        gerekce: digerleri.map((c) => `${c} döneminde iki değer arasındaki fark ${fark[tam.indexOf(c)]} birimdir; en büyük fark değildir.`),
        ipucu: 'Her zaman diliminde iki çizginin değerini oku ve farkı bul.',
        cozum: [`Farklar: ${fark.join(', ')}.`, `En büyük fark ${mx} birimdir ve ${dogru} döneminde görülür.`],
        dogrulama: [{ yol: ['seriler', a.ad], beklenen: a.v }, { yol: ['seriler', b.ad], beklenen: b.v }] });
    } else {
      const i = rast(0, n - 1), tp = seriler.reduce((s, x) => s + x.v[i], 0);
      if (tp - kp * yarim < yarim) throw new Error('pencere');
      const sirali = [0, 1, 2, 3].map((j) => String(tp + (j - kp) * yarim));
      ekle({ ...ortak, zorluk: 2, kok: `${t.gen} grafikte gösterilmiştir. Buna göre ${tam[i]} döneminde ${adlar.join(', ').replace(/, ([^,]*)$/, ' ve $1')} toplam kaç ${t.birim} ${t.birim === 'kg' ? 'kâğıt toplamıştır' : t.birim === 'kitap' ? 'okumuştur' : 'satmıştır'}?`.replace(' kg kâğıt toplamıştır', ' kilogram kâğıt toplamıştır'),
        sirali, dogru: String(tp),
        gerekce: sirali.map((c, j) => (j === kp ? '' : `${c}, değerlerden biri ${Math.abs(j - kp) * yarim} birim ${j > kp ? 'fazla' : 'eksik'} okunarak bulunur; doğru toplam ${tp}'dir.`.replace("'dir", ' olarak hesaplanır'))),
        ipucu: 'Her çizginin o zamandaki değerini oku ve topla.',
        cozum: [`${tam[i]} döneminde değerler: ${seriler.map((x) => x.v[i]).join(', ')}.`, `Toplam = ${seriler.map((x) => x.v[i]).join(' + ')} = ${tp}`],
        dogrulama: seriler.map((x) => ({ yol: ['seriler', x.ad], beklenen: x.v })) });
    }
  }
  return { pastaSorusu, cizgiSorusu };
}
export const KAYIT = [
  { id: 'mat7-daire-grafigi', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-PAS', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.6.1'], fabrika: kur, uret: (f) => f.pastaSorusu() },
  { id: 'mat7-cizgi-grafigi', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-CIZ', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.6.2'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];

