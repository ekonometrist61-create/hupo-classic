// 7. sınıf Matematik — koordinat düzleminde yansıma (MAT.7.3.1) ve doğru orantı grafiği (MAT.7.1.7).
// Nokta konumları ve grafik yalnız şekilde; kökte sayı yok. Şıklar: yansıma doğrusu/oran değeri yanlış okunduğunda çıkan değerler.
import { nokta2 } from '../tipler-a4.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 7. sınıf; program: TYMM)';
const HARF = ['A', 'B', 'C', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T'];
const ARALIK = 7;

const BAGLAM = [
  { ex: 'Süre (saat)', ey: 'Yol (km)', g: 'Grafik, sabit hızla giden bir aracın yol–süre ilişkisini göstermektedir.', yq: (n) => `Araç aynı hızla gitmeye devam ederse ${n} saatte kaç kilometre yol alır?`, xq: (m) => `Araç aynı hızla gitmeye devam ederse ${m} kilometre yolu kaç saatte alır?`, sq: 'Bu aracın bir saatte aldığı yol kaç kilometredir?' },
  { ex: 'Miktar (kg)', ey: 'Ücret (TL)', g: 'Grafik, bir manavda satılan elmanın kilogramı ile ödenecek ücret arasındaki ilişkiyi göstermektedir.', yq: (n) => `${n} kilogram elma için kaç lira ödenir?`, xq: (m) => `${m} lira ödenerek kaç kilogram elma alınır?`, sq: 'Bu manavda 1 kilogram elmanın fiyatı kaç liradır?' },
  { ex: 'Süre (dk)', ey: 'Su (L)', g: 'Grafik, bir musluktan akan su miktarının süreye göre değişimini göstermektedir.', yq: (n) => `Musluk aynı şekilde akmaya devam ederse ${n} dakikada kaç litre su akar?`, xq: (m) => `Musluktan ${m} litre su kaç dakikada akar?`, sq: 'Bu musluktan bir dakikada kaç litre su akar?' },
  { ex: 'Adet', ey: 'Ücret (TL)', g: 'Grafik, bir kırtasiyede satılan defterlerin sayısı ile ödenecek ücret arasındaki ilişkiyi göstermektedir.', yq: (n) => `${n} defter için kaç lira ödenir?`, xq: (m) => `${m} lira ile kaç defter alınır?`, sq: 'Bir defterin fiyatı kaç liradır?' },
];

export function kur({ R, sec, karistir, ekle, konum }) {
  const rast = (a, b) => a + Math.floor(R() * (b - a + 1));
  function yansimaSorusu() {
    const dik = R() < 0.5, k = rast(-3, 3), tur = sec(['nokta', 'cokgen']);
    const [P, Q, S] = karistir(HARF).slice(0, 3);
    const yansit = (x, y) => (dik ? [2 * k - x, y] : [x, 2 * k - y]);
    const ic = ([x, y]) => Math.abs(x) <= ARALIK && Math.abs(y) <= ARALIK;
    let noktalar = [], cokgenler = [], ad = [P];
    const uygun = (x, y) => (dik ? x !== k : y !== k) && ic(yansit(x, y)) && Math.abs(x) <= 6 && Math.abs(y) <= 6;
    if (tur === 'nokta') {
      let x, y, n = 0; do { x = rast(-6, 6); y = rast(-6, 6); n++; } while ((!uygun(x, y) || (dik ? Math.abs(x - k) : Math.abs(y - k)) < 1 || x === 0 || y === 0) && n < 200);
      noktalar = [{ ad: P, x, y }];
    } else {
      const tepe = [];
      for (let n = 0; n < 400 && tepe.length < 3; n++) {
        const x = rast(-6, 6), y = rast(-6, 6);
        if (x === 0 || y === 0 || !uygun(x, y) || tepe.some(([a, b]) => a === x && b === y)) continue;
        if (tepe.length && (dik ? tepe.some(([a]) => (a < k) !== (x < k)) : tepe.some(([, b]) => (b < k) !== (y < k)))) continue;
        if (tepe.length && tepe.some(([a, b]) => Math.hypot(a - x, b - y) > 7 || Math.hypot(a - x, b - y) < 2)) continue;
        tepe.push([x, y]);
      }
      if (tepe.length < 3) throw new Error('tepe_bulunamadi');
      const [a, b, c] = tepe;
      if ((b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]) === 0) throw new Error('dogrusal');
      const koseler = [[P, a], [Q, b], [S, c]].map(([nm, v]) => ({ ad: nm, x: v[0], y: v[1] }));
      cokgenler = [{ koseler }]; ad = [P, Q, S];
    }
    const hedef = sec(ad), kp = konum();
    const kaynak = tur === 'nokta' ? noktalar[0] : cokgenler[0].koseler.find((q) => q.ad === hedef);
    const [ix, iy] = yansit(kaynak.x, kaynak.y);
    const sirali = [0, 1, 2, 3].map((i) => (dik ? nokta2(ix + 2 * (i - kp), iy) : nokta2(ix, iy + 2 * (i - kp))));
    const dogru = nokta2(ix, iy);
    const dg = dik ? { x: k } : { y: k };
    const dogruAd = 'd', ayna = dik ? { p: [k, -ARALIK], q: [k, ARALIK], ad: dogruAd, kesik: true, uzat: false } : { p: [-ARALIK, k], q: [ARALIK, k], ad: dogruAd, kesik: true, uzat: false };
    const spec = { tip_id: 'a4-koordinat', parametreler: { x: [-ARALIK, ARALIK], y: [-ARALIK, ARALIK], noktalar, cokgenler, dogrular: [ayna], donusum: { tur: 'yansima', dogru: dg } } };
    const kok = tur === 'nokta'
      ? `Şekilde ${P} noktası ve d doğrusu verilmiştir. ${P} noktasının d doğrusuna göre yansıması ${P}' noktası olduğuna göre ${P}' noktasının koordinatları aşağıdakilerden hangisidir?`
      : `Şekilde ${P}${Q}${S} üçgeni ve d doğrusu verilmiştir. Üçgenin d doğrusuna göre yansıması ${P}'${Q}'${S}' üçgeni olduğuna göre ${hedef}' köşesinin koordinatları aşağıdakilerden hangisidir?`;
    ekle({ kod: 'MAT.7.3.1', konu: 'Geometri', alt_konu: 'Yansıma dönüşümü', zorluk: tur === 'nokta' ? 2 : 3, spec, kok,
      sirali, dogru,
      gerekce: sirali.map((c, i) => (i === kp ? '' : `${c}, yansıma doğrusu ${dik ? 'x' : 'y'} = ${k + (i - kp)} gibi okunduğunda bulunur; şekildeki d doğrusu ${dik ? 'x' : 'y'} = ${k} doğrusudur.`)),
      ipucu: 'Noktanın d doğrusuna uzaklığını say; görüntü, doğrunun öbür tarafında aynı uzaklıktadır.',
      cozum: [`Şekilden ${hedef} = ${nokta2(kaynak.x, kaynak.y)} ve d doğrusu ${dik ? 'x' : 'y'} = ${k} olarak okunur.`,
        `${hedef} noktasının d doğrusuna uzaklığı ${Math.abs((dik ? kaynak.x : kaynak.y) - k)} birimdir; görüntü doğrunun öbür tarafında aynı uzaklıktadır.`, `${hedef}' = ${dogru}`],
      dogrulama: [{ yol: ['goruntu', hedef], beklenen: [ix, iy] }] });
  }

  function orantiSorusu() {
    const b = sec(BAGLAM), k = rast(2, 9), tur = sec(['y', 'x', 'k']);
    let ys = 0; const adayYs = [1, 2, 3, 4, 5, 6, 10, 12];
    for (const c of adayYs) { const ymax = c * Math.ceil((6 * k) / c); const nokta = [1, 2, 3, 4, 5, 6].filter((x) => (k * x) % c === 0); if (ymax / c <= 10 && nokta.length >= 2) { ys = c; break; } }
    if (!ys) throw new Error('olcek_yok');
    const ymax = ys * Math.ceil((6 * k) / ys), isaret = [1, 2, 3, 4, 5, 6].filter((x) => (k * x) % ys === 0).map((x) => [x, k * x]);
    const spec = { tip_id: 'a4-koordinat', parametreler: { x: [0, 6], y: [0, ymax], adim: [1, ys], eksenAdi: { x: b.ex, y: b.ey }, dogrular: [{ ad: undefined, p: [0, 0], q: [6, 6 * k], uzat: false, noktalar: isaret.slice(0, 3) }] } };
    const kp = konum();
    const N = rast(7, 12);
    let kok, dogru, sirali, gerekce, cozum, ipucu;
    if (tur === 'y') {
      sirali = [0, 1, 2, 3].map((i) => String((k + i - kp) * N)); dogru = String(k * N);
      if (k + 0 - kp < 1) throw new Error('pencere');
      kok = `${b.g} ${b.yq(N)}`;
      gerekce = sirali.map((c, i) => (i === kp ? '' : `${c}, oran sabiti ${k + i - kp} alınarak bulunur; grafikte oran sabiti ${k}'dır.`.replace("'dır", ' değerindedir')));
      cozum = [`Grafikten oran sabiti okunur: y ÷ x = ${k}.`, `${N} × ${k} = ${dogru}`]; ipucu = 'Grafikteki bir noktadan y değerini x değerine bölerek oranı bul.';
    } else if (tur === 'x') {
      sirali = [0, 1, 2, 3].map((i) => String(N + i - kp)); dogru = String(N);
      if (N - kp < 1) throw new Error('pencere');
      kok = `${b.g} ${b.xq(k * N)}`;
      gerekce = sirali.map((c, i) => (i === kp ? '' : `${c} değeri için ${k} × ${c} = ${k * (N + i - kp)} olurdu; sorulan değer ${k * N}'dir.`.replace("'dir", ' olduğundan uymaz')));
      cozum = [`Grafikten oran sabiti okunur: y ÷ x = ${k}.`, `${k * N} ÷ ${k} = ${N}`]; ipucu = 'Önce oran sabitini grafikten bul; sonra bölme yap.';
    } else {
      if (k - kp < 1) throw new Error('pencere');
      sirali = [0, 1, 2, 3].map((i) => String(k + i - kp)); dogru = String(k);
      kok = `${b.g} ${b.sq}`;
      gerekce = sirali.map((c, i) => (i === kp ? '' : `${c}, grafikteki noktaların değerleriyle uyuşmaz; ${c} × x ile y değeri bulunamaz.`));
      cozum = [`Grafikte (${isaret[0][0]}, ${isaret[0][1]}) noktası vardır.`, `${isaret[0][1]} ÷ ${isaret[0][0]} = ${k}`]; ipucu = 'Grafikteki bir noktanın y değerini x değerine böl.';
    }
    ekle({ kod: 'MAT.7.1.7', konu: 'Oran-Orantı', alt_konu: 'Doğru orantı grafiği', zorluk: tur === 'k' ? 1 : 2, spec, kok, sirali, dogru, gerekce, ipucu, cozum,
      dogrulama: [{ yol: ['dogrular', 'd', 'egim'], beklenen: [k, 1] }] });
  }
  return { yansimaSorusu, orantiSorusu };
}
export const KAYIT = [
  { id: 'mat7-yansima', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-YAN', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.3.1'], fabrika: kur, uret: (f) => f.yansimaSorusu() },
  { id: 'mat7-oranti-grafik', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-ORN', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.1.7'], fabrika: kur, uret: (f) => f.orantiSorusu() },
];
