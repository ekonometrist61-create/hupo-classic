// Ajan H2 (4. sınıf Fen Bilimleri, önceki program) şekil tipleri: Dünya'nın dönme/dolanma işaretleri (F.4.1.2.1), mıknatısın çektiği nesne deneyi (F.4.3.2.2).
// Sözleşme: render(parametreler, profil) -> { sahne, alt, olgular }. Tip adları 'h2-' önekiyle.
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const cos = (d) => Math.cos(aciRad(d)), sin = (d) => Math.sin(aciRad(d));
const SARI = '#F6D860', MAVI_AC = '#CFE8F6', GRI_AC = '#E5E7EB';
const nokta = (x) => x.toFixed(1);

// Açık çok parçalı yol (yay gibi); ok: son parçanın yönünde ok ucu.
function acikYol(s, pts, { renk = PALET.siyah, kalinlik = 2.4, ok = false } = {}) {
  s.noktalar.push(...pts.map(([x, y]) => [x, y, 0]));
  s.parcalar.push(`<polyline points="${pts.map(([x, y]) => `${nokta(x)},${nokta(y)}`).join(' ')}" fill="none" stroke="${s._renk(renk)}" stroke-width="${kalinlik}" stroke-linecap="round" stroke-linejoin="round"/>`);
  if (ok) {
    const [x1, y1] = pts[pts.length - 2], [x2, y2] = pts[pts.length - 1];
    const a = Math.atan2(y2 - y1, x2 - x1), u = 9, g = 0.45;
    const p = [[x2, y2], [x2 - u * Math.cos(a - g), y2 - u * Math.sin(a - g)], [x2 - u * Math.cos(a + g), y2 - u * Math.sin(a + g)]];
    s.parcalar.push(`<polygon points="${p.map(([x, y]) => `${nokta(x)},${nokta(y)}`).join(' ')}" fill="${s._renk(renk)}"/>`);
  }
}

// ---------- Dünya: dönme ve dolanma işaretleri (F.4.1.2.1) ----------
// parametreler: { harfler: { donme, dolanma, isik, eksen } } her biri farklı bir harf (K/L/M/N).
// Ortada Güneş; yörünge kesikli daire; Dünya’nın kendi ekseni etrafında dönme oku; yörünge üzerinde dolanma oku;
// Güneş’ten gelen ışık oku; Dünya’dan geçen kesikli eksen çizgisi.
function donmeDolanma(p, profil) {
  const H = p.harfler;
  if (!H || new Set(['donme', 'dolanma', 'isik', 'eksen'].map((k) => H[k])).size !== 4) hata('donme_harf');
  const W = 380, Hy = 270, s = new Sahne(W, Hy, profil);
  const cx = 190, cy = 150, RO = 110, ex = cx + RO, ey = cy, ER = 16;
  // yörünge (kesikli daire, izgara dışı: yazı çakışması denetimine girmez)
  s.parcalar.push(`<circle cx="${cx}" cy="${cy}" r="${RO}" fill="none" stroke="${s._renk(PALET.gri)}" stroke-width="1.4" stroke-dasharray="6 4"/>`);
  s.noktalar.push([cx - RO, cy - RO, 0], [cx + RO, cy + RO, 0]);
  s.cember(cx, cy, 22, { dolgu: SARI, renk: '#B45309', kalinlik: 2 });
  s.metin(cx, cy + 50, 'Güneş', { boyut: 15 });
  s.cember(ex, ey, ER, { dolgu: MAVI_AC, renk: PALET.mavi, kalinlik: 2 });
  s.metin(ex, ey + 56, 'Dünya', { boyut: 15 });
  // ışık oku: Güneş’ten Dünya’ya
  s.cizgi(cx + 24, cy, ex - ER - 6, cy, { renk: '#B45309', kalinlik: 2, ok: true });
  // eksen: Dünya’dan geçen kesikli çizgi
  s.cizgi(ex, ey - 36, ex, ey + 36, { renk: PALET.gri, kalinlik: 1.6, kesik: true });
  // dönme oku: Dünya’nın sağ yanında, kendi ekseni etrafında yukarı doğru
  const dz = p.duzen ?? {};
  const dA = [36, 46, 56][dz.dolanma ?? 0] ?? 36, dM = dz.donme === 1 ? 1 : 0, iT = [0.4, 0.6][dz.isik ?? 0] ?? 0.4;
  const donme = []; for (let i = 0; i <= 10; i++) { const a = -60 + (120 * i) / 10; donme.push([ex + 28 * cos(a), ey - 28 * sin(a)]); }
  acikYol(s, donme, { kalinlik: 2.4, ok: true });
  // dolanma oku: yörünge üzerinde, Dünya’nın önünde (saat yönünün tersine)
  const dolanma = []; for (let i = 0; i <= 8; i++) { const a = dA + (22 * i) / 8; dolanma.push([cx + RO * cos(a), cy - RO * sin(a)]); }
  acikYol(s, dolanma, { kalinlik: 3.2, ok: true });
  // harfler: her harf kısa bir çizgiyle ait olduğu işarete bağlanır; harfler yaydan ve birbirinden ayrık durur
  const bag = (x1, y1, x2, y2) => s.cizgi(x1, y1, x2, y2, { renk: PALET.gri, kalinlik: 1.2 });
  const dm = dA + 11;
  bag(cx + 114 * cos(dm), cy - 114 * sin(dm), cx + 128 * cos(dm), cy - 128 * sin(dm));
  s.metin(cx + 140 * cos(dm), cy - 140 * sin(dm), H.dolanma, { kalin: true, boyut: 16 });
  if (dM === 0) { bag(ex + 28 * cos(60) + 1, ey - 28 * sin(60) - 1, ex + 44, ey - 52); s.metin(ex + 50, ey - 62, H.donme, { kalin: true, boyut: 16 }); }
  else { bag(ex + 29, ey, ex + 44, ey); s.metin(ex + 54, ey, H.donme, { kalin: true, boyut: 16 }); }
  bag(ex, ey - 36, ex + 6, ey - 46);
  s.metin(ex + 12, ey - 56, H.eksen, { kalin: true, boyut: 16 });
  const lx = (cx + 24) + (ex - ER - 6 - cx - 24) * iT;
  bag(lx, cy - 2, lx, cy - 16);
  s.metin(lx, cy - 26, H.isik, { kalin: true, boyut: 16 });
  return {
    sahne: s,
    alt: 'Ortada Güneş, sağında Dünya bulunmaktadır. Yörünge kesikli daireyle gösterilmiştir. Şekilde dört harfli işaret vardır.',
    olgular: { harf: { donme: H.donme, dolanma: H.dolanma, isik: H.isik, eksen: H.eksen } },
  };
}

// ---------- mıknatıs deneyi: çeken nesne (F.4.3.2.2) ----------
// parametreler: { nesneler: [{ harf, sekil }] (tam 4 nesne, soldan sağa), cekilen: harf }
// sekil: kare | daire | ucgen | altigen. Mıknatıs nesneyi yukarı çekerse nesneden mıknatısa ok çizilir.
const SEKIL_AD = ['kare', 'daire', 'ucgen', 'altigen'];
function sekilCiz(s, ad, x, y, r) {
  if (ad === 'kare') s.dikdortgen(x - r, y - r, 2 * r, 2 * r, { dolgu: GRI_AC, kalinlik: 1.8 });
  else if (ad === 'daire') s.cember(x, y, r, { dolgu: GRI_AC, kalinlik: 1.8 });
  else if (ad === 'ucgen') s.poligon([[x, y - r], [x + r, y + r * 0.8], [x - r, y + r * 0.8]], { dolgu: GRI_AC, kalinlik: 1.8 });
  else if (ad === 'altigen') s.poligon(Array.from({ length: 6 }, (_, j) => [x + r * cos(60 * j), y + r * sin(60 * j)]), { dolgu: GRI_AC, kalinlik: 1.8 });
  else hata(`deney_sekil:${ad}`);
}
function miknatisDeney(p, profil) {
  const N = p.nesneler;
  if (!Array.isArray(N) || N.length !== 4) hata('deney_nesne_4');
  if (!N.every((n) => SEKIL_AD.includes(n.sekil))) hata('deney_sekil_bilinmiyor');
  const ci = N.findIndex((n) => n.harf === p.cekilen);
  if (ci < 0) hata('deney_cekilen');
  const W = 380, Hy = 200, s = new Sahne(W, Hy, profil), y = 146, XS = [80, 160, 240, 320];
  s.dikdortgen(40, 34, 300, 36, { dolgu: '#9CA3AF', renk: PALET.siyah, kalinlik: 2 });
  s.cizgi(190, 34, 190, 70, { renk: PALET.siyah, kalinlik: 1.5, izgara: true });
  s.metin(190, 24, 'Mıknatıs', { boyut: 15 });
  N.forEach((n, i) => {
    sekilCiz(s, n.sekil, XS[i], y, 22);
    s.metin(XS[i], 186, n.harf, { kalin: true, boyut: 16 });
  });
  s.cizgi(XS[ci], y - 26, XS[ci], 72, { renk: PALET.siyah, kalinlik: 2.6, ok: true });
  return {
    sahne: s,
    alt: 'Üstte yatay bir çubuk mıknatıs bulunmaktadır. Altında harfli dört nesne vardır.',
    olgular: { cekilen: N[ci].harf, harfler: N.map((n) => n.harf) },
  };
}

export const TIPLER_H2 = {
  'h2-donme-dolanma': donmeDolanma,
  'h2-miknatis-deney': miknatisDeney,
};
