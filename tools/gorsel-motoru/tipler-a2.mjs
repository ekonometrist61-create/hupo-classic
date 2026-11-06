// Ajan A2 için şekil tipleri. Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'a2-' önekiyle. İkon kitaplığı: 100x100 kutuda (-50..50) çizilen basit nesneler.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const K = '#111827', G = 3.2;
const st = (f, w = G) => `fill="${f}" stroke="${K}" stroke-width="${w}" stroke-linejoin="round" stroke-linecap="round"`;
const ln = (x1, y1, x2, y2, c = K, w = G) => `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${c}" stroke-width="${w}" stroke-linecap="round"/>`;
const yol = (d, f = 'none', w = G) => `<path d="${d}" ${st(f, w)}/>`;
const el = (cx, cy, rx, ry, f, w = G) => `<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" ${st(f, w)}/>`;
const dk = (x, y, w, h, f, rx = 3, sw = G) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}" ${st(f, sw)}/>`;
const pg = (pts, f) => `<polygon points="${pts.map((p) => p.join(',')).join(' ')}" ${st(f)}/>`;
const yildizPts = (r, ri) => Array.from({ length: 10 }, (_, i) => { const a = (-90 + i * 36) * Math.PI / 180, q = i % 2 ? ri : r; return [+(q * Math.cos(a)).toFixed(1), +(q * Math.sin(a)).toFixed(1)]; });

const IKON = {
  elma: () => yol('M0,-26 C22,-42 46,-26 42,2 C38,32 16,46 0,38 C-16,46 -38,32 -42,2 C-46,-26 -22,-42 0,-26Z', '#D62828') + ln(0, -26, 5, -44, '#7B4B1E', 4) + yol('M5,-38 C16,-50 30,-46 32,-40 C22,-32 12,-32 5,-38Z', '#2E9E44'),
  muz: () => yol('M-40,-30 C-44,22 8,48 44,16 L38,4 C10,28 -20,14 -26,-34 Z', '#F2C500') + ln(-40, -30, -34, -42, '#7B4B1E', 5),
  havuc: () => yol('M-18,-24 L18,-24 L0,46 Z', '#E8731A') + ln(-8, -10, 6, -6, K, 2) + ln(-4, 8, 8, 12, K, 2) + yol('M0,-24 C-8,-44 -20,-44 -18,-34Z', '#2E9E44') + yol('M0,-24 C0,-48 8,-48 8,-34Z', '#2E9E44') + yol('M0,-24 C10,-40 22,-42 20,-32Z', '#2E9E44'),
  top: () => `<circle cx="0" cy="0" r="40" ${st('#FFFFFF')}/>` + pg([[0, -14], [13, -4], [8, 11], [-8, 11], [-13, -4]], K) + ln(0, -14, 0, -40, K, 2.5) + ln(13, -4, 38, -12, K, 2.5) + ln(8, 11, 22, 33, K, 2.5) + ln(-8, 11, -22, 33, K, 2.5) + ln(-13, -4, -38, -12, K, 2.5),
  ev: () => dk(-34, -8, 68, 48, '#F3D9A4') + pg([[-42, -8], [0, -44], [42, -8]], '#B45309') + dk(-8, 14, 16, 26, '#7B4B1E', 2) + dk(-28, 2, 14, 14, '#BFE3F5', 2) + dk(14, 2, 14, 14, '#BFE3F5', 2),
  agac: () => dk(-7, 6, 14, 42, '#7B4B1E', 2) + `<circle cx="0" cy="-12" r="30" ${st('#2E9E44')}/>` + `<circle cx="-18" cy="6" r="18" ${st('#2E9E44')}/>` + `<circle cx="18" cy="6" r="18" ${st('#2E9E44')}/>`,
  gunes: () => Array.from({ length: 8 }, (_, i) => { const a = i * Math.PI / 4; return ln((30 * Math.cos(a)).toFixed(1), (30 * Math.sin(a)).toFixed(1), (46 * Math.cos(a)).toFixed(1), (46 * Math.sin(a)).toFixed(1), '#E69F00', 5); }).join('') + `<circle cx="0" cy="0" r="22" ${st('#F2C500')}/>`,
  ay: () => yol('M10,-42 A42,42 0 1 0 10,42 A50,50 0 0 1 10,-42Z', '#F2C500'),
  yildiz: () => pg(yildizPts(44, 18), '#F2C500'),
  bulut: () => yol('M-30,22 C-48,22 -48,-6 -28,-6 C-28,-30 6,-36 14,-14 C34,-22 50,-2 38,22 Z', '#E5EEF7'),
  kitap: () => dk(-30, -38, 60, 76, '#0072B2', 4) + dk(-24, -32, 6, 64, '#E5EEF7', 1, 2) + ln(-8, -14, 20, -14, '#FFFFFF', 4) + ln(-8, 0, 20, 0, '#FFFFFF', 4),
  kalem: () => `<g transform="rotate(-45)">` + dk(-44, -9, 62, 18, '#F2C500', 2) + pg([[18, -9], [40, 0], [18, 9]], '#F3D9A4') + pg([[32, -3.5], [40, 0], [32, 3.5]], K) + dk(-52, -9, 10, 18, '#E8A0A0', 2) + `</g>`,
  cicek: () => ln(0, 6, 0, 46, '#2E9E44', 5) + yol('M0,30 C14,20 24,26 26,34 C14,40 6,38 0,30Z', '#2E9E44') + [0, 72, 144, 216, 288].map((a) => `<circle cx="${(20 * Math.cos((a - 90) * Math.PI / 180)).toFixed(1)}" cy="${(20 * Math.sin((a - 90) * Math.PI / 180) - 14).toFixed(1)}" r="13" ${st('#CC79A7', 2.5)}/>`).join('') + `<circle cx="0" cy="-14" r="10" ${st('#F2C500', 2.5)}/>`,
  araba: () => yol('M-44,14 L-44,-2 L-30,-4 L-18,-24 L16,-24 L30,-4 L44,0 L44,14 Z', '#D55E00') + pg([[-14, -20], [-24, -4], [-4, -4], [-4, -20]], '#BFE3F5') + pg([[2, -20], [2, -4], [24, -4], [14, -20]], '#BFE3F5') + `<circle cx="-24" cy="16" r="11" ${st('#374151')}/><circle cx="24" cy="16" r="11" ${st('#374151')}/>`,
  masa: () => dk(-42, -14, 84, 12, '#B45309', 3) + dk(-34, -2, 9, 46, '#7B4B1E', 2) + dk(25, -2, 9, 46, '#7B4B1E', 2),
  sandalye: () => dk(-22, -44, 8, 50, '#7B4B1E', 2) + dk(-22, -44, 40, 10, '#B45309', 2) + dk(-22, 4, 44, 10, '#B45309', 2) + dk(-22, 14, 8, 32, '#7B4B1E', 2) + dk(14, 14, 8, 32, '#7B4B1E', 2),
  saat: () => `<circle cx="0" cy="0" r="40" ${st('#FFFFFF')}/>` + [0, 90, 180, 270].map((a) => ln((32 * Math.cos(a * Math.PI / 180)).toFixed(1), (32 * Math.sin(a * Math.PI / 180)).toFixed(1), (37 * Math.cos(a * Math.PI / 180)).toFixed(1), (37 * Math.sin(a * Math.PI / 180)).toFixed(1), K, 3)).join('') + ln(0, 0, 0, -26, K, 4) + ln(0, 0, 17, 8, K, 4),
  canta: () => yol('M-14,-30 C-14,-50 14,-50 14,-30', 'none', 5) + dk(-32, -30, 64, 74, '#CC79A7', 8) + dk(-22, 8, 44, 26, '#F3D9A4', 4) + ln(-32, -8, 32, -8, K, 2.5),
  semsiye: () => yol('M-44,2 C-44,-36 44,-36 44,2 C36,-6 28,-6 22,2 C14,-6 6,-6 0,2 C-6,-6 -14,-6 -22,2 C-28,-6 -36,-6 -44,2Z', '#0072B2') + yol('M0,2 L0,36 C0,48 -14,48 -14,38', 'none', 4.5),
  balon: () => el(0, -8, 28, 34, '#D62828') + pg([[0, 26], [-6, 36], [6, 36]], '#D62828') + yol('M0,36 C-8,42 8,46 0,52', 'none', 2.5),
  kalp: () => yol('M0,38 C-60,-4 -26,-46 0,-18 C26,-46 60,-4 0,38Z', '#D62828'),
  anahtar: () => `<circle cx="-24" cy="0" r="16" ${st('#F2C500')}/><circle cx="-24" cy="0" r="6" ${st('#FFFFFF', 2.5)}/>` + dk(-10, -5, 52, 10, '#F2C500', 2) + dk(28, 4, 7, 14, '#F2C500', 1.5) + dk(16, 4, 7, 11, '#F2C500', 1.5),
  bardak: () => yol('M-26,-36 L26,-36 L20,38 L-20,38 Z', '#E5EEF7') + yol('M-23,-10 L23,-10 L20,38 L-20,38 Z', '#7CC4EE', 2),
  balik: () => el(-6, 0, 34, 22, '#E69F00') + pg([[24, 0], [46, -20], [46, 20]], '#E69F00') + `<circle cx="-22" cy="-5" r="4.5" fill="${K}"/>` + yol('M-2,-20 C4,-34 14,-30 12,-18', '#E69F00', 2.5),
  karpuz: () => yol('M-44,-6 L44,-6 A44,44 0 0 1 -44,-6Z', '#2E9E44') + yol('M-38,-6 L38,-6 A38,38 0 0 1 -38,-6Z', '#E53935', 2) + [[-18, 8], [0, 14], [18, 8]].map(([x, y]) => el(x, y, 3.2, 5, K, 1)).join(''),
  bisiklet: () => `<circle cx="-28" cy="14" r="20" ${st('none', 4)}/><circle cx="28" cy="14" r="20" ${st('none', 4)}/>` + yol('M-28,14 L-6,-14 L16,14 L-6,14 Z M-6,-14 L20,-18 M28,14 L16,-14', 'none', 4) + ln(-12, -18, 0, -18, K, 5),
  gemi: () => yol('M-46,6 L46,6 L32,34 L-32,34 Z', '#D55E00') + ln(0, 6, 0, -42, K, 4) + pg([[4, -40], [4, 0], [36, 0]], '#FFFFFF') + pg([[-4, -30], [-4, 0], [-28, 0]], '#FFFFFF'),
  televizyon: () => dk(-42, -30, 84, 56, '#374151', 6) + dk(-35, -23, 70, 42, '#9FD3F0', 3) + ln(-12, -30, -24, -46, K, 3.5) + ln(12, -30, 24, -46, K, 3.5) + dk(-16, 26, 32, 8, '#374151', 2),
  bilgisayar: () => dk(-36, -34, 72, 48, '#374151', 5) + dk(-30, -28, 60, 36, '#9FD3F0', 2) + yol('M-46,34 L46,34 L36,14 L-36,14Z', '#9CA3AF'),
  papatya: () => [0, 45, 90, 135, 180, 225, 270, 315].map((a) => `<ellipse cx="${(22 * Math.cos(a * Math.PI / 180)).toFixed(1)}" cy="${(22 * Math.sin(a * Math.PI / 180)).toFixed(1)}" rx="13" ry="7" transform="rotate(${a} ${(22 * Math.cos(a * Math.PI / 180)).toFixed(1)} ${(22 * Math.sin(a * Math.PI / 180)).toFixed(1)})" ${st('#FFFFFF', 2.5)}/>`).join('') + `<circle cx="0" cy="0" r="11" ${st('#F2C500', 2.5)}/>`,
  kelebek: () => el(-22, -12, 22, 26, '#CC79A7') + el(22, -12, 22, 26, '#CC79A7') + el(-17, 22, 14, 16, '#E69F00') + el(17, 22, 14, 16, '#E69F00') + dk(-3.5, -30, 7, 62, '#374151', 3) + ln(-2, -30, -12, -46, K, 2.5) + ln(2, -30, 12, -46, K, 2.5),
  // atıklar
  gazete: () => dk(-34, -38, 68, 76, '#F5F1E4', 3) + dk(-26, -30, 52, 12, '#9CA3AF', 1.5, 2) + [-8, 2, 12, 22].map((y) => ln(-26, y, 26, y, '#6B7280', 2.5)).join(''),
  karton: () => pg([[-40, -14], [0, -34], [40, -14], [0, 6]], '#D9A85E') + pg([[-40, -14], [0, 6], [0, 46], [-40, 26]], '#C48A3A') + pg([[0, 6], [40, -14], [40, 26], [0, 46]], '#B07A2E') + pg([[-14, -24], [14, -24], [26, -14], [0, -4]], '#E8C78F'),
  suSisesi: () => dk(-8, -46, 16, 8, '#0072B2', 2) + yol('M-8,-38 L8,-38 L10,-26 C26,-20 26,-6 24,6 L24,36 C24,44 -24,44 -24,36 L-24,6 C-26,-6 -26,-20 -10,-26Z', '#BFE3F5') + ln(-24, 10, 24, 10, '#7CC4EE', 3) + ln(-24, 20, 24, 20, '#7CC4EE', 3),
  kova: () => yol('M-34,-22 L34,-22 L26,40 L-26,40 Z', '#CC3333') + yol('M-34,-22 C-30,-46 30,-46 34,-22', 'none', 4) + ln(-30, -10, 30, -10, '#8E1F1F', 3),
  kavanoz: () => dk(-24, -42, 48, 10, '#9CA3AF', 3) + yol('M-24,-32 L24,-32 L24,36 C24,44 -24,44 -24,36 Z', '#DDF3E4') + ln(-14, -22, -14, 22, '#FFFFFF', 4),
  camSise: () => dk(-7, -46, 14, 6, '#9CA3AF', 2) + yol('M-7,-40 L7,-40 L7,-18 C26,-10 26,2 24,12 L24,38 C24,46 -24,46 -24,38 L-24,12 C-26,2 -26,-10 -7,-18Z', '#7FBF8E') + ln(-14, 0, -14, 30, '#DDF3E4', 4),
  konserve: () => `<ellipse cx="0" cy="-30" rx="28" ry="8" ${st('#D1D5DB')}/>` + yol('M-28,-30 L-28,32 C-28,44 28,44 28,32 L28,-30 C28,-22 -28,-22 -28,-30Z', '#9CA3AF') + ln(-28, -10, 28, -10, '#6B7280', 2.5) + ln(-28, 14, 28, 14, '#6B7280', 2.5),
  icecekKutusu: () => dk(-22, -36, 44, 76, '#D55E00', 6) + `<ellipse cx="0" cy="-36" rx="22" ry="5" ${st('#D1D5DB')}/>` + ln(-8, -36, 8, -38, K, 2.5) + ln(-22, -6, 22, -6, '#FFFFFF', 3) + ln(-22, 10, 22, 10, '#FFFFFF', 3),
};
export const IKON_ADLARI = Object.keys(IKON);

function ikonCiz(s, ad, cx, cy, boy) {
  const f = IKON[ad] ?? hata(`ikon_yok:${ad}`);
  s.noktalar.push([cx - boy / 2, cy - boy / 2, 0], [cx + boy / 2, cy + boy / 2, 0]);
  s.parcalar.push(`<g transform="translate(${cx} ${cy}) scale(${(boy / 100).toFixed(3)})">${f()}</g>`);
}

// ---------- ikon dizisi ----------
// parametreler: { ikonlar:[ad…], numara?:true, boy? }  Tek ya da birkaç ikon yan yana; numara varsa altında 1,2,3…
function ikonDizisi(p, profil) {
  const n = p.ikonlar.length; if (n < 1 || n > 4) hata('ikon_sayisi_1_4');
  const boy = p.boy ?? (n === 1 ? 130 : 78), hucre = n === 1 ? 190 : 88, W = n * hucre + 20, H = boy + (p.numara ? 62 : 44);
  const s = new Sahne(W, H, profil);
  p.ikonlar.forEach((ad, i) => {
    const cx = 10 + hucre * (i + 0.5);
    s.dikdortgen(cx - hucre / 2 + 4, 6, hucre - 8, boy + 24 + (p.numara ? 28 : 0) - 6 + 6, { renk: PALET.gri, kalinlik: 1 });
    ikonCiz(s, ad, cx, 18 + boy / 2, boy);
    if (p.numara) s.metin(cx, boy + 50, String(i + 1), { kalin: true, boyut: 20 });
  });
  return { sahne: s, alt: n === 1 ? 'Çerçeve içinde bir resim.' : `Numaralı ${n} resim yan yana duruyor.`, olgular: { ikonlar: p.ikonlar, numarali: Object.fromEntries(p.ikonlar.map((a, i) => [i + 1, a])) } };
}

// ---------- eşleştirme ----------
// parametreler: { sol:[ikon…], sag:[sözcük…], baglar:[[solIndeks, sagIndeks]…] }  Düz çizgilerle bağlanmış resim–sözcük.
function eslestir(p, profil) {
  const n = p.sol.length; if (n < 3 || n > 4 || p.sag.length !== n || p.baglar.length !== n) hata('eslestirme_boyut');
  const rh = 70, W = 360, H = n * rh + 24, s = new Sahne(W, H, profil), xs = 78, xd = 270;
  p.sol.forEach((ad, i) => { ikonCiz(s, ad, 50, 12 + rh * (i + 0.5), 52); s.nokta(xs, 12 + rh * (i + 0.5), { r: 4 }); });
  p.sag.forEach((w, i) => { s.nokta(xd, 12 + rh * (i + 0.5), { r: 4 }); s.metin(xd + 12, 12 + rh * (i + 0.5) + 6, w, { hiza: 'start', kalin: true, boyut: 18 }); });
  const renk = [PALET.mavi, PALET.kirmizi, PALET.yesil, PALET.pembe];
  p.baglar.forEach(([a, b], i) => s.cizgi(xs, 12 + rh * (a + 0.5), xd, 12 + rh * (b + 0.5), { renk: renk[i % 4], kalinlik: 2.6 }));
  const eslesen = Object.fromEntries(p.baglar.map(([a, b]) => [p.sol[a], p.sag[b]]));
  return { sahne: s, alt: 'Solda resimler, sağda sözcükler var; resimler çizgilerle sözcüklere bağlanmış.', olgular: { eslesen } };
}

// ---------- olay sırası panelleri ----------
// parametreler: { dizi:'bitki'|'ev'|'mum'|'elma'|'balon'|'bardak', sira:[adım indeksleri 0..3, panel soldan sağa] }
// Paneller karışık dizilir; altında 1–4 numarası vardır. olgular.adimPaneli[a] = a. adımın panel numarası (1 tabanlı).
const PH = 84;
const PANEL = {
  bitki: [
    (s, x, y) => { s.dikdortgen(x, y + 54, PH, 30, { dolgu: '#B98A5C', renk: K }); s.cember(x + 42, y + 52, 6, { dolgu: '#7B4B1E', renk: K, kalinlik: 1.5 }); },
    (s, x, y) => { s.dikdortgen(x, y + 54, PH, 30, { dolgu: '#B98A5C', renk: K }); s.cizgi(x + 42, y + 54, x + 42, y + 38, { renk: '#2E9E44', kalinlik: 4 }); s.poligon([[x + 42, y + 42], [x + 54, y + 34], [x + 50, y + 46]], { dolgu: '#2E9E44', kalinlik: 1.2 }); },
    (s, x, y) => { s.dikdortgen(x, y + 54, PH, 30, { dolgu: '#B98A5C', renk: K }); s.cizgi(x + 42, y + 54, x + 42, y + 18, { renk: '#2E9E44', kalinlik: 4 }); s.poligon([[x + 42, y + 36], [x + 62, y + 24], [x + 56, y + 42]], { dolgu: '#2E9E44', kalinlik: 1.2 }); s.poligon([[x + 42, y + 28], [x + 22, y + 18], [x + 28, y + 36]], { dolgu: '#2E9E44', kalinlik: 1.2 }); },
    (s, x, y) => { s.dikdortgen(x, y + 54, PH, 30, { dolgu: '#B98A5C', renk: K }); s.cizgi(x + 42, y + 54, x + 42, y + 16, { renk: '#2E9E44', kalinlik: 4 }); s.poligon([[x + 42, y + 40], [x + 62, y + 30], [x + 56, y + 46]], { dolgu: '#2E9E44', kalinlik: 1.2 }); for (let i = 0; i < 5; i++) { const a = (i * 72 - 90) * Math.PI / 180; s.cember(x + 42 + 11 * Math.cos(a), y + 12 + 11 * Math.sin(a), 6, { dolgu: '#CC79A7', renk: K, kalinlik: 1.2 }); } s.cember(x + 42, y + 12, 5, { dolgu: '#F2C500', renk: K, kalinlik: 1.2 }); },
  ],
  ev: [
    (s, x, y) => { s.dikdortgen(x, y + 66, PH, 18, { dolgu: '#7BAE6B', renk: K }); s.dikdortgen(x + 14, y + 62, 56, 6, { dolgu: '#9CA3AF', renk: K, kalinlik: 1.5 }); },
    (s, x, y) => { s.dikdortgen(x, y + 66, PH, 18, { dolgu: '#7BAE6B', renk: K }); s.dikdortgen(x + 14, y + 30, 56, 36, { dolgu: '#D9A85E', renk: K, kalinlik: 2 }); },
    (s, x, y) => { s.dikdortgen(x, y + 66, PH, 18, { dolgu: '#7BAE6B', renk: K }); s.dikdortgen(x + 14, y + 30, 56, 36, { dolgu: '#D9A85E', renk: K, kalinlik: 2 }); s.poligon([[x + 8, y + 30], [x + 42, y + 6], [x + 76, y + 30]], { dolgu: '#B45309', kalinlik: 2 }); },
    (s, x, y) => { s.dikdortgen(x, y + 66, PH, 18, { dolgu: '#7BAE6B', renk: K }); s.dikdortgen(x + 14, y + 30, 56, 36, { dolgu: '#F3D9A4', renk: K, kalinlik: 2 }); s.poligon([[x + 8, y + 30], [x + 42, y + 6], [x + 76, y + 30]], { dolgu: '#B45309', kalinlik: 2 }); s.dikdortgen(x + 34, y + 44, 16, 22, { dolgu: '#7B4B1E', kalinlik: 1.5 }); s.dikdortgen(x + 20, y + 38, 11, 11, { dolgu: '#BFE3F5', kalinlik: 1.5 }); s.dikdortgen(x + 54, y + 38, 11, 11, { dolgu: '#BFE3F5', kalinlik: 1.5 }); },
  ],
  mum: [0, 1, 2, 3].map((k) => (s, x, y) => { const h = [58, 40, 24, 10][k]; s.dikdortgen(x + 22, y + 80 - h, 40, h, { dolgu: '#FFF4D6', renk: K, kalinlik: 1.6 }); s.dikdortgen(x + 14, y + 80, 56, 4, { dolgu: '#9CA3AF', renk: K, kalinlik: 1.2 }); s.cizgi(x + 42, y + 80 - h, x + 42, y + 74 - h, { kalinlik: 1.5 }); s.parcalar.push(`<path d="M${x + 42} ${y + 72 - h} C${x + 34} ${y + 62 - h} ${x + 42} ${y + 58 - h} ${x + 42} ${y + 50 - h} C${x + 50} ${y + 58 - h} ${x + 50} ${y + 66 - h} ${x + 42} ${y + 72 - h}Z" fill="#E8731A" stroke="${K}" stroke-width="1.2"/>`); s.noktalar.push([x + 34, y + 48 - h, 0]); }),
  elma: [0, 1, 2, 3].map((k) => (s, x, y) => {
    const cx = x + 42, cy = y + 46;
    if (k === 0) { s.parcalar.push(`<g transform="translate(${cx} ${cy}) scale(0.62)">${IKON.elma()}</g>`); }
    if (k === 1) { s.parcalar.push(`<g transform="translate(${cx} ${cy}) scale(0.62)">${IKON.elma()}<circle cx="40" cy="-4" r="17" fill="#FFFFFF" stroke="none"/></g>`); }
    if (k === 2) { s.parcalar.push(`<g transform="translate(${cx} ${cy}) scale(0.62)">${IKON.elma()}<circle cx="38" cy="-2" r="30" fill="#FFFFFF" stroke="none"/><circle cx="10" cy="46" r="20" fill="#FFFFFF" stroke="none"/></g>`); }
    if (k === 3) { s.parcalar.push(`<g transform="translate(${cx} ${cy}) scale(0.62)"><path d="M-6,-30 C-14,-10 -14,10 -6,30 L6,30 C14,10 14,-10 6,-30Z" ${st('#F3D9A4')}/>${el(0, -4, 3.2, 5, K, 1)}${el(0, 12, 3.2, 5, K, 1)}</g>`); }
    s.noktalar.push([x + 10, y + 10, 0], [x + 74, y + 80, 0]);
  }),
  balon: [0, 1, 2, 3].map((k) => (s, x, y) => { const r = [8, 14, 20, 26][k], sc = r / 28; s.parcalar.push(`<g transform="translate(${x + 42} ${y + 36}) scale(${sc.toFixed(3)})">${el(0, 0, 28, 34, '#D62828', (2.2 / sc).toFixed(2))}</g>`); s.cizgi(x + 42, y + 36 + r * 1.2, x + 42, y + 78, { kalinlik: 1.5 }); s.noktalar.push([x + 8, y + 4, 0]); }),
  bardak: [0, 1, 2, 3].map((k) => (s, x, y) => { const f = [0.05, 0.3, 0.62, 0.95][k], yt = y + 8, yb = y + 78; s.poligon([[x + 20, yt], [x + 64, yt], [x + 58, yb], [x + 26, yb]], { dolgu: '#F4F8FB', kalinlik: 2 }); const sy = yb - 70 * f, xl = 20 + (6 * (sy - yt)) / 70, xr = 64 - (6 * (sy - yt)) / 70; s.poligon([[x + xl, sy], [x + xr, sy], [x + 58, yb], [x + 26, yb]], { dolgu: '#7CC4EE', kalinlik: 1.5 }); }),
};
const DIZI_AD = { bitki: 'Bir tohumun gelişimi', ev: 'Bir ev', mum: 'Yanan bir mum', elma: 'Bir elma', balon: 'Şişen bir balon', bardak: 'Bir bardak' };
export const SIRA_DIZILERI = Object.keys(PANEL);
function siraPaneli(p, profil) {
  const pn = PANEL[p.dizi] ?? hata(`dizi_yok:${p.dizi}`);
  if (!Array.isArray(p.sira) || p.sira.length !== 4 || new Set(p.sira).size !== 4) hata('sira_gecersiz');
  const g = 92, W = 4 * g + 12, H = PH + 52, s = new Sahne(W, H, profil);
  const adimPaneli = {};
  p.sira.forEach((adim, i) => {
    const x = 10 + i * g + 4, y = 10;
    s.dikdortgen(x - 2, y - 2, PH + 4, PH + 4, { renk: PALET.gri, kalinlik: 1 });
    pn[adim](s, x, y);
    s.metin(x + PH / 2, y + PH + 28, String(i + 1), { kalin: true, boyut: 20 });
    adimPaneli[adim + 1] = i + 1;
  });
  return { sahne: s, alt: 'Dört numaralı resim yan yana duruyor; resimler bir olayın aşamalarını karışık sırayla gösteriyor.', olgular: { dizi: p.dizi, adimPaneli, sira: p.sira } };
}

// ---------- hava ikonları ----------
const BULUT = (dy = 0) => yol(`M-30,${22 + dy} C-48,${22 + dy} -48,${-6 + dy} -28,${-6 + dy} C-28,${-30 + dy} 6,${-36 + dy} 14,${-14 + dy} C34,${-22 + dy} 50,${-2 + dy} 38,${22 + dy} Z`, '#E5EEF7');
Object.assign(IKON, {
  yagmur: () => BULUT(-14) + [-20, 0, 20].map((x) => ln(x - 4, 16, x - 10, 34, '#0072B2', 4.5)).join(''),
  kar: () => BULUT(-14) + [-20, 0, 20].map((x, i) => `<g transform="translate(${x} ${i === 1 ? 38 : 30})">${ln(-6, 0, 6, 0, '#56B4E9', 3.5)}${ln(0, -6, 0, 6, '#56B4E9', 3.5)}${ln(-4.2, -4.2, 4.2, 4.2, '#56B4E9', 3)}${ln(-4.2, 4.2, 4.2, -4.2, '#56B4E9', 3)}</g>`).join(''),
  ruzgar: () => yol('M-44,-18 L12,-18 C34,-18 34,-42 14,-40', 'none', 5) + yol('M-44,0 L28,0 C52,0 50,26 30,24', 'none', 5) + yol('M-44,18 L2,18 C20,18 20,38 6,38', 'none', 5),
});
export const ikonAdlari = () => Object.keys(IKON);

// ---------- çizelge ----------
// parametreler: { baslik?, sutunlar:[…], satirlar:[[hücre…]…], genislik:[…] }  hücre: metin (string) ya da { ikon }. İlk sütun satır adıdır.
function cizelge(p, profil) {
  const nc = p.sutunlar.length, nr = p.satirlar.length; if (nr < 2 || nr > 8 || nc < 2 || nc > 4) hata('cizelge_boyut');
  const W = 360, rh = 42, top = p.baslik ? 40 : 10, hh = 36, H = top + hh + nr * rh + 12, s = new Sahne(W, H, profil);
  const gen = p.genislik ?? Array(nc).fill((W - 20) / nc); const sum = gen.reduce((a, b) => a + b, 0), sc = (W - 20) / sum;
  const xs = [10]; gen.forEach((g, i) => xs.push(xs[i] + g * sc));
  const b = profil.yazi + 1;
  if (p.baslik) s.metin(W / 2, 26, p.baslik, { kalin: true, boyut: b + 1 });
  s.dikdortgen(10, top, W - 20, hh, { dolgu: '#DCEBF7', renk: PALET.siyah, kalinlik: 1.4 });
  p.sutunlar.forEach((c, j) => s.metin((xs[j] + xs[j + 1]) / 2, top + hh / 2 + 6, c, { kalin: true, boyut: b }));
  p.satirlar.forEach((r, i) => {
    const y = top + hh + i * rh;
    s.dikdortgen(10, y, W - 20, rh, { renk: PALET.siyah, kalinlik: 1 });
    r.forEach((h, j) => {
      const cx = (xs[j] + xs[j + 1]) / 2;
      if (typeof h === 'object') ikonCiz(s, h.ikon, cx, y + rh / 2, 34);
      else s.metin(cx, y + rh / 2 + 6, String(h), { boyut: b, kalin: j === 0 });
    });
  });
  for (let j = 1; j < nc; j++) s.cizgi(xs[j], top, xs[j], top + hh + nr * rh, { renk: PALET.siyah, kalinlik: 1, izgara: true });
  const tablo = {}; p.satirlar.forEach((r) => { tablo[r[0]] = r.slice(1).map((h) => (typeof h === 'object' ? h.ikon : h)); });
  return { sahne: s, alt: `Tablo: ${p.baslik ?? 'çizelge'}. Sütun başlıkları: ${p.sutunlar.join(', ')}.`, olgular: { tablo } };
}

// ---------- takvim ----------
// parametreler: { ay, gunSayisi, baslangic:0..6 (0=Pazartesi), isaretler:{gün:'yildiz'|'daire'|'kare'}, aciklama:{yildiz:'…'} }
const GUN_KISA = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'], GUN_UZUN = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
function takvim(p, profil) {
  const col = 48, rh = 40, satir = Math.ceil((p.baslangic + p.gunSayisi) / 7), W = 7 * col + 20, ex = Object.keys(p.aciklama ?? {}).length;
  const H = 40 + 28 + satir * rh + 14 + ex * 30, s = new Sahne(W, H, profil), b = profil.yazi;
  s.metin(W / 2, 26, p.ay, { kalin: true, boyut: b + 2 });
  GUN_KISA.forEach((g, j) => s.metin(10 + col * (j + 0.5), 40 + 18, g, { kalin: true, boyut: b }));
  const gunler = {};
  for (let d = 1; d <= p.gunSayisi; d++) {
    const k = p.baslangic + d - 1, c = k % 7, r = Math.floor(k / 7), cx = 10 + col * (c + 0.5), cy = 68 + r * rh + rh / 2;
    s.dikdortgen(10 + col * c, 68 + r * rh, col, rh, { renk: PALET.gri, kalinlik: 0.8 });
    const isr = p.isaretler?.[d];
    if (isr === 'daire') s.cember(cx, cy - 4, 17, { renk: PALET.mavi, kalinlik: 2.5 });
    if (isr === 'kare') s.dikdortgen(cx - 16, cy - 20, 32, 32, { renk: PALET.kirmizi, kalinlik: 2.5 });
    if (isr === 'yildiz') s.parcalar.push(`<g transform="translate(${cx} ${cy - 4}) scale(0.4)">${pg(yildizPts(44, 20), '#F2C500')}</g>`);
    s.metin(cx, cy + 1, String(d), { boyut: b - 1, kalin: !!isr });
    gunler[d] = GUN_UZUN[c];
  }
  const SEM = { daire: (x, y) => s.cember(x, y, 9, { renk: PALET.mavi, kalinlik: 2.5 }), kare: (x, y) => s.dikdortgen(x - 8, y - 8, 16, 16, { renk: PALET.kirmizi, kalinlik: 2.5 }), yildiz: (x, y) => s.parcalar.push(`<g transform="translate(${x} ${y}) scale(0.24)">${pg(yildizPts(44, 20), '#F2C500')}</g>`) };
  Object.entries(p.aciklama ?? {}).forEach(([sm, ad], i) => { const y = 68 + satir * rh + 24 + i * 30; SEM[sm](24, y - 5); s.metin(44, y, ad, { hiza: 'start', boyut: b }); });
  const gunDeg = {}; for (const [d, sm] of Object.entries(p.isaretler ?? {})) (gunDeg[p.aciklama?.[sm]] ??= []).push(+d);
  return { sahne: s, alt: `${p.ay} ayına ait bir takvim; bazı günler işaretlenmiş ve altında işaretlerin açıklaması var.`, olgular: { gunler, olay: gunDeg } };
}

// ---------- afiş / davetiye ----------
// parametreler: { tur:'davetiye'|'afis', baslik, ikon, satirlar:[{etiket, deger}] }
function afis(p, profil) {
  const n = p.satirlar.length; if (n < 2 || n > 5) hata('afis_satir_2_5');
  const W = 360, hd = p.tur === 'afis' ? 96 : 110, H = hd + 24 + n * 34 + 16, s = new Sahne(W, H, profil), b = profil.yazi - 1;
  if (p.tur === 'davetiye') {
    s.dikdortgen(6, 6, W - 12, H - 12, { renk: PALET.pembe, kalinlik: 3 }); s.dikdortgen(13, 13, W - 26, H - 26, { renk: PALET.pembe, kalinlik: 1.2 });
    ikonCiz(s, p.ikon, W / 2, 48, 46); s.metin(W / 2, 96, p.baslik, { boyut: b + 3, kalin: true, renk: '#7A2D5B' });
  } else {
    s.dikdortgen(6, 6, W - 12, H - 12, { renk: PALET.siyah, kalinlik: 2 }); s.dikdortgen(6, 6, W - 12, hd, { dolgu: PALET.mavi, renk: PALET.mavi, kalinlik: 1 });
    ikonCiz(s, p.ikon, 52, 6 + hd / 2, 56); s.metin(220, 6 + hd / 2 + 6, p.baslik, { boyut: b + 4, kalin: true, renk: '#FFFFFF' });
  }
  p.satirlar.forEach((r, i) => {
    const y = hd + 36 + i * 34;
    s.metin(30, y, `${r.etiket}:`, { hiza: 'start', kalin: true, boyut: b });
    s.metin(144, y, r.deger, { hiza: 'start', boyut: b });
  });
  return { sahne: s, alt: `${p.tur === 'afis' ? 'Etkinlik afişi' : 'Davetiye'}: ${p.baslik}. Üzerinde bilgi satırları yazılıdır.`, olgular: { alanlar: Object.fromEntries(p.satirlar.map((r) => [r.etiket, r.deger])), etiketler: p.satirlar.map((r) => r.etiket) } };
}

// ---------- kitap kapağı (başlık + görseller) ----------
// parametreler: { baslik, ikonlar:[3] }
function kapak(p, profil) {
  if (p.ikonlar.length !== 3) hata('kapak_3_ikon');
  const W = 330, H = 230, s = new Sahne(W, H, profil), b = profil.yazi;
  s.dikdortgen(8, 8, W - 16, H - 16, { dolgu: '#FFF4D6', renk: PALET.siyah, kalinlik: 2.5 }); s.dikdortgen(8, 8, 22, H - 16, { dolgu: PALET.mavi, renk: PALET.siyah, kalinlik: 2.5 });
  s.metin(W / 2 + 14, 52, p.baslik, { kalin: true, boyut: b + 1 });
  p.ikonlar.forEach((ad, i) => ikonCiz(s, ad, 74 + i * 84 + 12, 132, 66));
  return { sahne: s, alt: 'Bir kitabın kapağı: üstte başlık, altında üç resim var.', olgular: { baslik: p.baslik, ikonlar: p.ikonlar } };
}

// ---------- güneşe göre yön ----------
// parametreler: { taraf:'ust'|'sag'|'alt'|'sol' (güneşin göründüğü kenar), durum:'dogiyor'|'batiyor', nesneler:{ust,sag,alt,sol} }
const TARAFLAR = ['ust', 'sag', 'alt', 'sol'], YONLER = ['kuzey', 'doğu', 'güney', 'batı'];
function gunesYon(p, profil) {
  const W = 300, H = 300, c = 150, s = new Sahne(W, H, profil), ti = TARAFLAR.indexOf(p.taraf); if (ti < 0) hata('taraf_gecersiz');
  const V = { ust: [0, -1], sag: [1, 0], alt: [0, 1], sol: [-1, 0] };
  for (const t of TARAFLAR) { const [dx, dy] = V[t]; ikonCiz(s, p.nesneler[t] ?? hata('nesne_eksik'), c + dx * 78, c + dy * 78, 54); }
  const [sx, sy] = V[p.taraf]; ikonCiz(s, 'gunes', c + sx * 128, c + sy * 128, 44);
  // çocuk: baş + gövde
  s.cember(c, c - 14, 9, { dolgu: '#F3D9A4', renk: PALET.siyah, kalinlik: 2 }); s.poligon([[c - 11, c + 24], [c + 11, c + 24], [c + 7, c - 3], [c - 7, c - 3]], { dolgu: PALET.mavi, renk: PALET.siyah, kalinlik: 2 });
  const hedef = p.durum === 'dogiyor' ? 1 : 3, kayma = (ti - hedef + 4) % 4, yon = {};
  YONLER.forEach((y, d) => { yon[y] = p.nesneler[TARAFLAR[(d + kayma) % 4]]; });
  return { sahne: s, alt: 'Ortada duran bir çocuk; dört yanında birer nesne, bir kenarda da Güneş var.', olgular: { yon, gunes_yonu: p.durum === 'dogiyor' ? 'doğu' : 'batı' } };
}

// ---------- mevsim panelleri ----------
// parametreler: { sira:[mevsim×4] } panel A–D soldan sağa, iki satır.
const MEVSIM = {
  ilkbahar: (s, x, y) => { s.dikdortgen(x, y, 130, 100, { dolgu: '#DDF1FB', renk: K }); s.dikdortgen(x, y + 80, 130, 20, { dolgu: '#8CCB6B', renk: K }); s.dikdortgen(x + 60, y + 48, 10, 34, { dolgu: '#7B4B1E', kalinlik: 1.5 }); s.cember(x + 65, y + 38, 24, { dolgu: '#A8DD8B', kalinlik: 1.6 }); for (const [a, b2] of [[52, 34], [72, 28], [64, 46], [80, 42]]) s.cember(x + a, y + b2, 4.5, { dolgu: '#F4A6C6', kalinlik: 1 }); },
  yaz: (s, x, y) => { s.dikdortgen(x, y, 130, 100, { dolgu: '#BFE3F5', renk: K }); s.dikdortgen(x, y + 80, 130, 20, { dolgu: '#4E9F3D', renk: K }); s.parcalar.push(`<g transform="translate(${x + 104} ${y + 24}) scale(0.36)">${IKON.gunes()}</g>`); s.dikdortgen(x + 42, y + 48, 10, 34, { dolgu: '#7B4B1E', kalinlik: 1.5 }); s.cember(x + 47, y + 38, 27, { dolgu: '#2E9E44', kalinlik: 1.6 }); },
  sonbahar: (s, x, y) => { s.dikdortgen(x, y, 130, 100, { dolgu: '#EFE6D6', renk: K }); s.dikdortgen(x, y + 80, 130, 20, { dolgu: '#B98A5C', renk: K }); s.dikdortgen(x + 60, y + 48, 10, 34, { dolgu: '#7B4B1E', kalinlik: 1.5 }); s.cember(x + 65, y + 38, 24, { dolgu: '#E8731A', kalinlik: 1.6 }); for (const [a, b2] of [[32, 70], [48, 90], [92, 76], [104, 92], [76, 62]]) s.poligon([[x + a, y + b2 - 5], [x + a + 5, y + b2], [x + a, y + b2 + 5], [x + a - 5, y + b2]], { dolgu: '#D55E00', kalinlik: 1 }); },
  kis: (s, x, y) => { s.dikdortgen(x, y, 130, 100, { dolgu: '#D9E4EE', renk: K }); s.dikdortgen(x, y + 80, 130, 20, { dolgu: '#FFFFFF', renk: K }); s.dikdortgen(x + 60, y + 38, 10, 44, { dolgu: '#7B4B1E', kalinlik: 1.5 }); s.cizgi(x + 65, y + 52, x + 45, y + 32, { renk: '#7B4B1E', kalinlik: 3 }); s.cizgi(x + 65, y + 46, x + 86, y + 26, { renk: '#7B4B1E', kalinlik: 3 }); s.cizgi(x + 65, y + 40, x + 65, y + 18, { renk: '#7B4B1E', kalinlik: 3 }); for (const [a, b2] of [[20, 20], [100, 14], [36, 50], [108, 56], [84, 10], [14, 70]]) s.cember(x + a, y + b2, 2.6, { dolgu: '#FFFFFF', renk: '#56B4E9', kalinlik: 1.2 }); },
};
export const MEVSIMLER = Object.keys(MEVSIM);
function mevsimPaneli(p, profil) {
  if (p.sira.length !== 4 || new Set(p.sira).size !== 4) hata('sira_gecersiz');
  const W = 290, H = 262, s = new Sahne(W, H, profil), harf = 'ABCD', paneller = {};
  p.sira.forEach((m, i) => {
    const x = 10 + (i % 2) * 140, y = 8 + Math.floor(i / 2) * 124;
    (MEVSIM[m] ?? hata(`mevsim_yok:${m}`))(s, x, y); s.metin(x + 65, y + 118, harf[i], { kalin: true, boyut: 20 });
    paneller[m] = harf[i];
  });
  return { sahne: s, alt: 'A, B, C, D harfli dört resim: aynı ağacın farklı mevsimlerdeki hâlleri.', olgular: { panel: paneller } };
}

// ---------- kroki (sokak / okul koridoru) ----------
// parametreler: { tur:'sokak'|'okul', ust:[3 ad], alt:[3 ad], burasi?:{ taraf:'ust'|'alt', indeks } }
function kroki(p, profil) {
  if (p.ust.length !== 3 || p.alt.length !== 3) hata('kroki_3x2');
  const W = 360, lw = 108, lh = 62, rw = 70, H = 2 * lh + rw + 28, s = new Sahne(W, H, profil), b = profil.yazi - 1, okul = p.tur === 'okul';
  const x0 = 18, yU = 8, yR = yU + lh, yA = yR + rw;
  s.dikdortgen(x0 - 4, yR, 3 * lw + 8, rw, { dolgu: okul ? '#F3EBD3' : '#D6D9DE', renk: PALET.siyah, kalinlik: 1.5 });
  const kutu = (x, y, ad) => { s.dikdortgen(x + 3, y + 2, lw - 6, lh - 4, { dolgu: okul ? '#FFFFFF' : '#FDF3D8', renk: PALET.siyah, kalinlik: 2 }); s.metin(x + lw / 2, y + lh / 2 + 5, ad, { boyut: b, kalin: true }); };
  p.ust.forEach((ad, i) => kutu(x0 + i * lw, yU, ad)); p.alt.forEach((ad, i) => kutu(x0 + i * lw, yA, ad));
  let burasi = null;
  if (p.burasi) {
    const cx = x0 + p.burasi.indeks * lw + lw / 2;
    s.cember(cx, yR + 22, 9, { dolgu: PALET.kirmizi, renk: PALET.siyah, kalinlik: 2 }); s.metin(cx, yR + 54, 'Buradasın', { boyut: b, kalin: true, renk: '#8A2E00' });
    burasi = (p.burasi.taraf === 'ust' ? p.ust : p.alt)[p.burasi.indeks];
  }
  const sat = { ust: p.ust, alt: p.alt };
  return { sahne: s, alt: `${okul ? 'Bir okulun' : 'Bir sokağın'} krokisi: ortada ${okul ? 'koridor' : 'yol'}, iki yanında üçer yer var.`, olgular: { ust: p.ust, alt: p.alt, burasi, karsisi: burasi ? sat[p.burasi.taraf === 'ust' ? 'alt' : 'ust'][p.burasi.indeks] : null } };
}

export const TIPLER_A2 = {
  'a2-ikon-dizisi': ikonDizisi,
  'a2-eslestir': eslestir,
  'a2-sira-paneli': siraPaneli,
  'a2-cizelge': cizelge,
  'a2-takvim': takvim,
  'a2-afis': afis,
  'a2-kapak': kapak,
  'a2-gunes-yon': gunesYon,
  'a2-mevsim-paneli': mevsimPaneli,
  'a2-kroki': kroki,
};
void DIZI_AD;
export { GUN_UZUN };
