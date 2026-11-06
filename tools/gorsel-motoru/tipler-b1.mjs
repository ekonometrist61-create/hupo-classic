// Ajan B1 için şekil tipleri (Matematik 2, 3, 6, 8). Sözleşme: render(parametreler, profil) -> { sahne, alt, olgular }. Tip adları 'b1-' önekiyle.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const rad = (d) => (d * Math.PI) / 180;
const DOLGU = '#BFE3F7'; // boyalı bölge (renk tek başına anlam taşımaz: bölge ayrıca çizgilerle sınırlıdır)
const ACIK = '#E8F1F8';
const alanPoli = (P) => Math.abs(P.reduce((t, [x, y], i) => { const [x2, y2] = P[(i + 1) % P.length]; return t + x * y2 - x2 * y; }, 0)) / 2;
const nk = (x) => Math.round(x * 100) / 100;

// ---------- bölünmüş şekil (yarım, çeyrek, kesir modelleri) ----------
// parametreler: { sekiller:[{ sekil:'daire', n, boyali:[..] } | { sekil:'kare'|'serit', kesim:{ dikey:[oranlar], yatay:[oranlar], kosegen? }, boyali:[..] }], dizilim:'tek'|'izgara'|'satir' }
// 1 şekil ('tek') ya da 4 şekil (numaralı, 'izgara' 2x2 ya da 'satir' alt alta).
function terimBul(k, n) {
  if (k === n) return 'bütün';
  if (n === 2 && k === 1) return 'yarım';
  if (n === 4) return { 1: 'çeyrek', 2: 'yarım', 3: 'üç çeyrek' }[k] ?? null;
  return null;
}
function hucreler(kesim, x, y, w, h) {
  if (kesim.kosegen) return [[[x, y], [x + w, y], [x + w, y + h]], [[x, y], [x + w, y + h], [x, y + h]]];
  const xs = [0, ...(kesim.dikey ?? []), 1].map((f) => x + f * w), ys = [0, ...(kesim.yatay ?? []), 1].map((f) => y + f * h), out = [];
  for (let r = 0; r < ys.length - 1; r++) for (let c = 0; c < xs.length - 1; c++) out.push([[xs[c], ys[r]], [xs[c + 1], ys[r]], [xs[c + 1], ys[r + 1]], [xs[c], ys[r + 1]]]);
  return out;
}
function bolunmus(p, profil) {
  const m = p.sekiller.length;
  if (m !== 1 && m !== 4) hata('sekil_sayisi_1_veya_4');
  const dz = p.dizilim ?? (m === 1 ? 'tek' : 'izgara');
  let W, H, kutular;
  if (dz === 'tek') { W = 300; H = 190; kutular = [{ x: 30, y: 15, w: 240, h: 160 }]; }
  else if (dz === 'izgara') { W = 330; H = 250; kutular = [0, 1, 2, 3].map((i) => ({ x: 48 + (i % 2) * 140, y: 14 + Math.floor(i / 2) * 118, w: 112, h: 96 })); }
  else if (dz === 'satir') { W = 300; H = 216; kutular = [0, 1, 2, 3].map((i) => ({ x: 50, y: 10 + i * 50, w: 230, h: 36 })); }
  else hata('dizilim_bilinmiyor');
  const s = new Sahne(W, H, profil), sekiller = [];
  p.sekiller.forEach((sh, i) => {
    const b = kutular[i]; let parcalar, esit;
    if (sh.sekil === 'daire') {
      const r = Math.min(b.w, b.h) / 2, cx = b.x + b.w / 2, cy = b.y + b.h / 2, n = sh.n, st = 360 / n;
      if (!(n >= 2)) hata('daire_n');
      parcalar = Array.from({ length: n }, (_, j) => ({ dilim: [cx, cy, r, 90 - (j + 1) * st, 90 - j * st] })); esit = true;
    } else {
      let { x, y, w, h } = b;
      if (sh.sekil === 'kare') { const q = Math.min(w, h); x += (w - q) / 2; y += (h - q) / 2; w = h = q; }
      else if (sh.sekil === 'serit') { h = Math.min(h, w * 0.28); y += (b.h - h) / 2; }
      else hata('sekil_bilinmiyor');
      const polys = hucreler(sh.kesim, x, y, w, h), al = polys.map(alanPoli);
      parcalar = polys.map((poly) => ({ poly })); esit = Math.max(...al) - Math.min(...al) < 1e-6;
    }
    const n = parcalar.length;
    if (new Set(sh.boyali).size !== sh.boyali.length || sh.boyali.some((j) => j < 0 || j >= n)) hata('boyali_gecersiz');
    parcalar.forEach((pc, j) => {
      const dolgu = sh.boyali.includes(j) ? DOLGU : 'none';
      if (pc.poly) s.poligon(pc.poly, { dolgu, kalinlik: 2 }); else s.dilim(...pc.dilim.slice(0, 3), pc.dilim[3], pc.dilim[4], { dolgu, kalinlik: 2 });
    });
    if (m > 1) s.metin(b.x - 14, b.y + b.h / 2 + 6, String(i + 1));
    const k = sh.boyali.length;
    sekiller.push({ sekil: sh.sekil, parca: n, boyali: k, esit, terim: esit ? terimBul(k, n) : 'esit_degil', bos_terim: esit ? terimBul(n - k, n) : 'esit_degil', kesir: esit ? `${k}/${n}` : null });
  });
  const alt = m === 1 ? 'Parçalara bölünmüş ve bazı parçaları boyanmış bir şekil.' : 'Numaralı dört şekil; her biri parçalara bölünmüş ve bir kısmı boyanmış.';
  return { sahne: s, alt, olgular: { sekiller } };
}

// ---------- madenî paralar ----------
// parametreler: { gruplar:[{ ad?, paralar:[5|10|25|50|100 (kuruş)] }] } (1 ya da 2 grup; 100 = 1 TL)
function para(p, profil) {
  const G = p.gruplar; if (G.length < 1 || G.length > 2) hata('grup_1_2');
  const adli = G.length > 1 || !!G[0].ad, perRow = adli ? 4 : 5, R = 28, P = 60, W = 330;
  const satirlar = G.map((g) => Math.ceil(g.paralar.length / perRow));
  if (G.some((g) => g.paralar.length < 1 || g.paralar.length > 8)) hata('para_sayisi_1_8');
  const H = 14 + satirlar.reduce((t, r) => t + r * (2 * R + 8) + 8, 0);
  const s = new Sahne(W, H, profil), gruplar = [];
  let y = 14;
  G.forEach((g, gi) => {
    const sayilar = {}, toplam = g.paralar.reduce((t, v) => t + v, 0);
    g.paralar.forEach((v, j) => {
      sayilar[v] = (sayilar[v] ?? 0) + 1;
      const r = Math.floor(j / perRow), c = j % perRow, kac = Math.min(perRow, g.paralar.length - r * perRow);
      const cx = adli ? 84 + R + c * P : (W - kac * P) / 2 + P / 2 + c * P, cy = y + R + r * (2 * R + 8);
      s.cember(cx, cy, R, { dolgu: v === 100 ? '#E5E7EB' : '#F6EFC8', kalinlik: 2.5 });
      s.metin(cx, cy - 1, v === 100 ? '1' : String(v), { kalin: true });
      s.metin(cx, cy + 17, v === 100 ? 'TL' : 'kuruş', { boyut: 13 });
    });
    if (adli && g.ad) s.metin(12, y + R + 6, g.ad, { hiza: 'start', kalin: true });
    gruplar.push({ ad: g.ad ?? null, toplam, sayilar });
    y += satirlar[gi] * (2 * R + 8) + 8;
  });
  return { sahne: s, alt: G.length > 1 ? 'İki çocuğun madenî paraları.' : 'Bir grup madenî para.', olgular: { gruplar, toplam: gruplar[0].toplam } };
}

// ---------- simge (piktogram) grafiği ----------
// parametreler: { baslik, satirlar:[{ ad, adet }], birim:1|2|5, simge:'daire'|'yildiz'|'kare'|'ucgen', nesne }
function simgeCiz(s, tur, cx, cy, r, renk) {
  if (tur === 'daire') s.cember(cx, cy, r, { dolgu: renk, kalinlik: 1.5 });
  else if (tur === 'kare') s.dikdortgen(cx - r, cy - r, 2 * r, 2 * r, { dolgu: renk, kalinlik: 1.5 });
  else if (tur === 'ucgen') s.poligon([[cx, cy - r - 1], [cx - r - 1, cy + r], [cx + r + 1, cy + r]], { dolgu: renk, kalinlik: 1.5 });
  else if (tur === 'yildiz') s.poligon(Array.from({ length: 10 }, (_, i) => { const a = rad(-90 + i * 36), q = i % 2 ? r * 0.45 : r * 1.15; return [cx + q * Math.cos(a), cy + q * Math.sin(a)]; }), { dolgu: renk, kalinlik: 1.5 });
  else hata('simge_bilinmiyor');
}
function simgeGrafigi(p, profil) {
  const n = p.satirlar.length; if (n < 2 || n > 4) hata('satir_2_4');
  const W = 340, rowH = 40, top = 52, H = top + n * rowH + 36, s = new Sahne(W, H, profil), degerler = {};
  s.metin(W / 2, 26, p.baslik, { kalin: true });
  p.satirlar.forEach((r, i) => {
    if (r.adet % p.birim) hata('adet_birime_bolunmuyor');
    const k = r.adet / p.birim; if (k < 1 || k > 10) hata('simge_sayisi');
    const cy = top + i * rowH + 14;
    s.metin(102, cy + 6, r.ad, { hiza: 'end' });
    for (let j = 0; j < k; j++) simgeCiz(s, p.simge, 122 + j * 22, cy, 8, PALET.mavi);
    degerler[r.ad] = r.adet;
  });
  simgeCiz(s, p.simge, 122, H - 20, 8, PALET.mavi);
  s.metin(138, H - 14, `= ${p.birim} ${p.nesne}`, { hiza: 'start', boyut: 15 });
  const v = Object.entries(degerler), mx = Math.max(...v.map(([, d]) => d)), mn = Math.min(...v.map(([, d]) => d));
  const tek = (h) => { const e = v.filter(([, d]) => d === h); return e.length === 1 ? e[0][0] : null; };
  return { sahne: s, alt: `Simge grafiği: ${p.baslik}. Satırlar: ${p.satirlar.map((r) => r.ad).join(', ')}.`, olgular: { degerler, en_cok: tek(mx), en_az: tek(mn), toplam: v.reduce((t, [, d]) => t + d, 0), birim: p.birim } };
}

// ---------- çetele tablosu ----------
// parametreler: { baslik, satirlar:[{ ad, adet }] } adet 1–25; her beşli grup 4 dikey + 1 çapraz çizgi.
function cetele(p, profil) {
  const n = p.satirlar.length; if (n < 2 || n > 4) hata('satir_2_4');
  const W = 330, rowH = 38, top = 46, H = top + n * rowH + 10, s = new Sahne(W, H, profil), degerler = {};
  s.metin(W / 2, 24, p.baslik, { kalin: true });
  p.satirlar.forEach((r, i) => {
    if (r.adet < 1 || r.adet > 25) hata('adet_1_25');
    const y0 = top + i * rowH;
    s.metin(92, y0 + 19, r.ad, { hiza: 'end' });
    for (let g = 0; g * 5 < r.adet; g++) {
      const gx = 110 + g * 40, k = Math.min(5, r.adet - g * 5);
      for (let j = 0; j < Math.min(k, 4); j++) s.cizgi(gx + j * 8, y0 + 3, gx + j * 8, y0 + 25, { renk: PALET.siyah, kalinlik: 2.6 });
      if (k === 5) s.cizgi(gx - 5, y0 + 22, gx + 29, y0 + 6, { renk: PALET.siyah, kalinlik: 2.6 });
    }
    degerler[r.ad] = r.adet;
  });
  const v = Object.entries(degerler), mx = Math.max(...v.map(([, d]) => d)), mn = Math.min(...v.map(([, d]) => d));
  const tek = (h) => { const e = v.filter(([, d]) => d === h); return e.length === 1 ? e[0][0] : null; };
  return { sahne: s, alt: `Çetele tablosu: ${p.baslik}. Satırlar: ${p.satirlar.map((r) => r.ad).join(', ')}.`, olgular: { degerler, en_cok: tek(mx), en_az: tek(mn), toplam: v.reduce((t, [, d]) => t + d, 0) } };
}

// ---------- analog saat ----------
// parametreler: { saatler:[{ h:1–12, m:0–59 }] } 1 saat (büyük) ya da 4 saat (numaralı, 2x2).
const saatYaz = (h, m) => `${h}:${String(m).padStart(2, '0')}`;
function saatCiz(s, cx, cy, R, h, m, bn) {
  s.cember(cx, cy, R, { kalinlik: 3, dolgu: '#FFFFFF' });
  let d = '';
  for (let i = 0; i < 60; i++) {
    const a = rad(i * 6), u = i % 5 ? 4 : 9, x1 = cx + (R - 2) * Math.sin(a), y1 = cy - (R - 2) * Math.cos(a), x2 = cx + (R - 2 - u) * Math.sin(a), y2 = cy - (R - 2 - u) * Math.cos(a);
    d += `M${nk(x1)} ${nk(y1)}L${nk(x2)} ${nk(y2)}`;
  }
  s.parcalar.push(`<path d="${d}" stroke="${PALET.siyah}" stroke-width="1.5" fill="none"/>`);
  for (let i = 1; i <= 12; i++) { const a = rad(i * 30), q = R - (bn >= 15 ? 19 : 16); s.metin(cx + q * Math.sin(a), cy - q * Math.cos(a) + bn * 0.35, String(i), { boyut: bn }); }
  const ml = R - (bn >= 15 ? 31 : 28), hl = ml - 17, am = rad(m * 6), ah = rad(((h % 12) * 30) + m * 0.5);
  s.cizgi(cx, cy, cx + hl * Math.sin(ah), cy - hl * Math.cos(ah), { kalinlik: 6, renk: PALET.siyah });
  s.cizgi(cx, cy, cx + ml * Math.sin(am), cy - ml * Math.cos(am), { kalinlik: 3, renk: PALET.mavi });
  s.nokta(cx, cy, { r: 4.5 });
}
function saat(p, profil) {
  const L = p.saatler, n = L.length; if (n !== 1 && n !== 4) hata('saat_sayisi_1_veya_4');
  for (const t of L) if (!(t.h >= 1 && t.h <= 12 && t.m >= 0 && t.m < 60)) hata('saat_gecersiz');
  let W, H, merkezler, R, bn;
  if (n === 1) { W = 200; H = 200; R = 86; bn = 15; merkezler = [[100, 100]]; }
  else { W = 330; H = 330; R = 70; bn = 12; merkezler = [[88, 88], [242, 88], [88, 242], [242, 242]]; }
  const s = new Sahne(W, H, profil), saatler = [];
  L.forEach((t, i) => {
    saatCiz(s, merkezler[i][0], merkezler[i][1], R, t.h, t.m, bn);
    if (n === 4) s.metin(merkezler[i][0] - R + 2, merkezler[i][1] - R + 10, String(i + 1), { boyut: 15, kalin: true });
    saatler.push(saatYaz(t.h, t.m));
  });
  return { sahne: s, alt: n === 1 ? 'Akrep ve yelkovanı olan analog bir saat.' : 'Numaralı dört analog saat.', olgular: { saat: saatler[0], saatler } };
}

// ---------- simetri doğruları ----------
// parametreler: { sekil:'kare'|'dikdortgen'|'ucgen'|'daire', dogrular:[açı (derece, 0–165, 15'in katı)], numara:bool }
// Şeklin merkezinden geçen kesikli doğrular çizilir; simetri olup olmadığı yansıtma ile sayısal hesaplanır.
const SEKIL_KOSE = {
  kare: [[-56, 56], [56, 56], [56, -56], [-56, -56]],
  dikdortgen: [[-82, 52], [82, 52], [82, -52], [-82, -52]],
  ucgen: [[0, 72], [-62.35, -36], [62.35, -36]],
};
export function simetriMi(sekil, aciDerece) {
  if (sekil === 'daire') return true;
  const V = SEKIL_KOSE[sekil], t = rad(aciDerece), c2 = Math.cos(2 * t), s2 = Math.sin(2 * t);
  const yans = ([x, y]) => [x * c2 + y * s2, x * s2 - y * c2];
  return V.every((v) => { const [a, b] = yans(v); return V.some(([x, y]) => Math.hypot(a - x, b - y) < 1e-6); });
}
function simetriDogrulari(p, profil) {
  const W = 270, H = 270, cx = 135, cy = 135, Rl = 108, s = new Sahne(W, H, profil);
  if (!(SEKIL_KOSE[p.sekil] || p.sekil === 'daire')) hata('sekil_bilinmiyor');
  if (p.sekil === 'daire') s.cember(cx, cy, 64, { dolgu: ACIK, kalinlik: 3 });
  else s.poligon(SEKIL_KOSE[p.sekil].map(([x, y]) => [cx + x, cy - y]), { dolgu: ACIK, kalinlik: 3 });
  const cizgiler = {};
  p.dogrular.forEach((a, i) => {
    if (a % 15 || a < 0 || a >= 180) hata('aci_gecersiz');
    const t = rad(a), dx = Math.cos(t), dy = Math.sin(t);
    // Kesikli çizgi: her renderlayıcıda aynı görünsün diye kısa parçalarla çizilir.
    let d = '';
    for (let u = -Rl; u < Rl; u += 13) { const u2 = Math.min(u + 8, Rl); d += `M${nk(cx + u * dx)} ${nk(cy - u * dy)}L${nk(cx + u2 * dx)} ${nk(cy - u2 * dy)}`; }
    s.parcalar.push(`<path d="${d}" stroke="${PALET.siyah}" stroke-width="2.4" stroke-linecap="butt" fill="none"/>`);
    s.cizgiler.push([cx - Rl * dx, cy + Rl * dy, cx + Rl * dx, cy - Rl * dy]); s.noktalar.push([cx - Rl * dx, cy + Rl * dy, 0], [cx + Rl * dx, cy - Rl * dy, 0]);
    cizgiler[String(i + 1)] = simetriMi(p.sekil, a);
  });
  if (p.numara !== false) p.dogrular.forEach((a, i) => {
    const t = rad(a), dx = Math.cos(t), dy = Math.sin(t), q = Rl + 16, q2 = Rl + 24;
    s.metinYerlestir([[cx + q * dx, cy - q * dy + 5], [cx - q * dx, cy + q * dy + 5], [cx + q2 * dx, cy - q2 * dy + 5], [cx - q2 * dx, cy + q2 * dy + 5]], String(i + 1), { boyut: 15, kalin: true });
  });
  return { sahne: s, alt: 'Bir şekil ve merkezinden geçen numaralı kesikli doğrular.', olgular: { cizgiler, sayi: Object.values(cizgiler).filter(Boolean).length } };
}

// Kesikli çizgi (her renderlayıcıda aynı): kısa parçalarla çizilir, çizgi listesine de yazılır.
function kesikli(s, x1, y1, x2, y2, { kalinlik = 2, dash = 7, bosluk = 5, renk = PALET.siyah } = {}) {
  const L = Math.hypot(x2 - x1, y2 - y1), ux = (x2 - x1) / L, uy = (y2 - y1) / L; let d = '';
  for (let u = 0; u < L; u += dash + bosluk) { const u2 = Math.min(u + dash, L); d += `M${nk(x1 + u * ux)} ${nk(y1 + u * uy)}L${nk(x1 + u2 * ux)} ${nk(y1 + u2 * uy)}`; }
  s.parcalar.push(`<path d="${d}" stroke="${renk}" stroke-width="${kalinlik}" fill="none"/>`);
  s.cizgiler.push([x1, y1, x2, y2]); s.noktalar.push([x1, y1, 0], [x2, y2, 0]);
}
// Dik açı işareti: köşe (x,y); a ve b birim yönler (ekran).
function dikIsaret(s, x, y, a, b, k = 10) {
  const p = [[x + a[0] * k, y + a[1] * k], [x + (a[0] + b[0]) * k, y + (a[1] + b[1]) * k], [x + b[0] * k, y + b[1] * k]];
  s.parcalar.push(`<path d="M${nk(p[0][0])} ${nk(p[0][1])}L${nk(p[1][0])} ${nk(p[1][1])}L${nk(p[2][0])} ${nk(p[2][1])}" stroke="${PALET.siyah}" stroke-width="1.6" fill="none"/>`);
  s.noktalar.push(p[0].concat(0), p[1].concat(0), p[2].concat(0));
}
const gen = (t, b) => String(t).length * b * 0.6;

// ---------- paralel doğrular ve kesen ----------
// parametreler: { psi:50–130 (≠90), etiketler:{ '1':'1', ..., '6':'x' } }  Açı numaraları: üst kesişimde 1 sol-üst, 2 sağ-üst, 3 sol-alt, 4 sağ-alt; alt kesişimde 5–8 aynı sırayla.
const ILISKI = {};
for (const [ad, liste] of Object.entries({ yondes: [[1, 5], [2, 6], [3, 7], [4, 8]], ic_ters: [[3, 6], [4, 5]], dis_ters: [[1, 8], [2, 7]], ters: [[1, 4], [2, 3], [5, 8], [6, 7]], ic_karsilikli: [[3, 5], [4, 6]], dis_karsilikli: [[1, 7], [2, 8]], komsu: [[1, 2], [1, 3], [2, 4], [3, 4], [5, 6], [5, 7], [6, 8], [7, 8]] })) for (const [a, b] of liste) ILISKI[`${a}-${b}`] = ad;
function paralelKesen(p, profil) {
  const W = 340, H = 250, T = 78, B = 176, psi = p.psi;
  if (!(psi >= 50 && psi <= 130) || psi === 90) hata('psi_gecersiz');
  const s = new Sahne(W, H, profil), cs = Math.cos(rad(psi)), sn = Math.sin(rad(psi)), dx = ((B - T) * cs) / sn, x1 = 170 - dx / 2, x2 = x1 + dx;
  [[T, 'd'], [B, 'e']].forEach(([y, ad]) => { s.cizgi(14, y, 300, y); s.cizgi(276, y - 6, 285, y); s.cizgi(276, y + 6, 285, y); s.metin(322, y + 5, ad, { boyut: 15, kalin: true }); });
  const ex = 48, tx = x1 - ex * cs, ty = T - ex * sn;
  s.cizgi(tx, ty, x2 + ex * cs, B + ex * sn);
  s.metinYerlestir([[tx - 12 * cs, ty - 12 * sn + 5], [tx + 12, ty + 5], [tx - 14, ty + 5]], 'k', { boyut: 15, kalin: true });
  const orta = { 1: 180 + psi / 2, 2: 270 + psi / 2, 3: 90 + psi / 2, 4: psi / 2 }, olcu = {};
  for (let i = 1; i <= 8; i++) {
    olcu[i] = [1, 4].includes(((i - 1) % 4) + 1) ? psi : 180 - psi;
    const t = p.etiketler?.[String(i)]; if (t === undefined) continue;
    const [px, py] = i <= 4 ? [x1, T] : [x2, B], a = rad(orta[((i - 1) % 4) + 1]);
    s.metinYerlestir([34, 44, 54, 26, 62].map((r) => [px + r * Math.cos(a), py + r * Math.sin(a) + 5]), String(t), { boyut: 14, kalin: true });
  }
  return { sahne: s, alt: 'İki paralel doğru ve bir kesen; oluşan açılar numaralandırılmış ya da işaretlenmiş.', olgular: { psi, olcu, iliski: ILISKI } };
}

// ---------- paralelkenar ve üçgenin alanı ----------
// parametreler: { sekil:'paralelkenar', b, h, d (kayma), yan } | { sekil:'ucgen', b, h, p (tepe noktasının tabandaki izdüşümü), s1, s2 }
function alanTipi(p, profil) {
  const W = 330, H = 220, yb = 168, s = new Sahne(W, H, profil), par = p.sekil === 'paralelkenar';
  if (!par && p.sekil !== 'ucgen') hata('sekil_bilinmiyor');
  const geni = par ? p.b + p.d : p.b, u = Math.min(240 / geni, 120 / p.h), x0 = Math.max(44, (W - geni * u) / 2);
  const A = [x0, yb], Bp = [x0 + p.b * u, yb], tepeX = x0 + (par ? p.d : p.p) * u, tepeY = yb - p.h * u;
  const pts = par ? [A, Bp, [x0 + (p.b + p.d) * u, tepeY], [tepeX, tepeY]] : [A, Bp, [tepeX, tepeY]];
  s.poligon(pts, { dolgu: ACIK, renk: ACIK, kalinlik: 0.5 });
  pts.forEach((q, i) => { const r = pts[(i + 1) % pts.length]; s.cizgi(q[0], q[1], r[0], r[1], { kalinlik: 2.6 }); });
  kesikli(s, tepeX, tepeY, tepeX, yb); dikIsaret(s, tepeX, yb, [1, 0], [0, -1], 9);
  const yaz = (t) => `${t} cm`;
  s.metin(x0 + (p.b * u) / 2, yb + 22, yaz(p.b), { boyut: 14 });
  const sol = [A, [tepeX, tepeY]], sag = par ? null : [Bp, [tepeX, tepeY]];
  const kenar = (seg, t, yon) => {
    const [q, r] = seg, mx = (q[0] + r[0]) / 2, my = (q[1] + r[1]) / 2, vx = r[0] - q[0], vy = r[1] - q[1], L = Math.hypot(vx, vy);
    let nx = -vy / L, ny = vx / L; if (yon * nx < 0) { nx = -nx; ny = -ny; }
    const w = gen(yaz(t), 14) / 2;
    s.metinYerlestir([8, 16, 24].map((k) => { const d = k + w * Math.abs(nx) + 8 * Math.abs(ny); return [mx + nx * d, my + ny * d + 5]; }), yaz(t), { boyut: 14 });
  };
  kenar(sol, par ? p.yan : p.s1, -1); if (sag) kenar(sag, p.s2, 1);
  const hm = yb - (p.h * u) / 2 + 5, hw = gen(yaz(p.h), 14) / 2;
  s.metinYerlestir([[tepeX + 10 + hw, hm], [tepeX - 10 - hw, hm]], yaz(p.h), { boyut: 14 });
  return { sahne: s, alt: par ? 'Kenar uzunlukları ve yüksekliği verilmiş bir paralelkenar.' : 'Kenar uzunlukları ve yüksekliği verilmiş bir üçgen.', olgular: { alan: par ? p.b * p.h : (p.b * p.h) / 2, taban: p.b, yukseklik: p.h } };
}

// ---------- çember (çap ya da yarıçap verilmiş) ----------
// parametreler: { deger, goster:'yaricap'|'cap' }
function cemberUzunluk(p, profil) {
  const W = 260, H = 240, cx = 130, cy = 120, Rr = 88, s = new Sahne(W, H, profil);
  if (!['yaricap', 'cap'].includes(p.goster)) hata('goster_gecersiz');
  s.cember(cx, cy, Rr, { kalinlik: 3, dolgu: ACIK });
  const a = rad(p.goster === 'cap' ? 20 : 35), dx = Math.cos(a), dy = -Math.sin(a), px = dy * -1, py = dx; // (px,py): doğruya dik
  if (p.goster === 'cap') { s.cizgi(cx - Rr * dx, cy - Rr * dy, cx + Rr * dx, cy + Rr * dy, { kalinlik: 2.6, renk: PALET.mavi }); s.nokta(cx - Rr * dx, cy - Rr * dy, { r: 4.5 }); s.nokta(cx + Rr * dx, cy + Rr * dy, { r: 4.5 }); }
  else { s.cizgi(cx, cy, cx + Rr * dx, cy + Rr * dy, { kalinlik: 2.6, renk: PALET.mavi }); s.nokta(cx + Rr * dx, cy + Rr * dy, { r: 4.5 }); }
  s.nokta(cx, cy, { r: 4.5 });
  const mx = p.goster === 'cap' ? cx : cx + (Rr / 2) * dx, my = p.goster === 'cap' ? cy : cy + (Rr / 2) * dy, t = `${p.deger} cm`;
  s.metinYerlestir([20, -20, 30, -30, 38, -38].map((k) => [mx + k * px, my + k * py + 5]), t, { boyut: 15, kalin: true });
  return { sahne: s, alt: 'Bir çember; merkezi ve üzerindeki bir uzunluk işaretlenmiş.', olgular: { cap: p.goster === 'cap' ? p.deger : 2 * p.deger, yaricap: p.goster === 'cap' ? p.deger / 2 : p.deger } };
}

// Kenar etiketi: kenarın ortasından, merkezin tersi yönde, çakışmayan ilk yere yazar.
function kenarYaz(s, q, r, metin, c, boyut = 14, ofs = [8, 16, 24, 32]) {
  const mx = (q[0] + r[0]) / 2, my = (q[1] + r[1]) / 2, vx = r[0] - q[0], vy = r[1] - q[1], L = Math.hypot(vx, vy);
  let nx = -vy / L, ny = vx / L; if ((mx - c[0]) * nx + (my - c[1]) * ny < 0) { nx = -nx; ny = -ny; }
  const w = gen(metin, boyut) / 2;
  s.metinYerlestir(ofs.map((k) => { const d = k + w * Math.abs(nx) + 8 * Math.abs(ny); return [mx + nx * d, my + ny * d + 5]; }), metin, { boyut });
}
const gcd = (a, b) => (b ? gcd(b, a % b) : Math.abs(a));

// ---------- dik üçgen (Pisagor) ----------
// parametreler: { a, b, c (hipotenüs), bilinmeyen:'a'|'b'|'c', donus:derece, ayna:bool }
function pisagor(p, profil) {
  const W = 330, H = 250, s = new Sahne(W, H, profil);
  if (p.a * p.a + p.b * p.b !== p.c * p.c) hata('pisagor_tutmuyor');
  let P = [[0, 0], [p.a, 0], [0, p.b]];
  if (p.ayna) P = P.map(([x, y]) => [-x, y]);
  const t = rad(p.donus); P = P.map(([x, y]) => [x * Math.cos(t) - y * Math.sin(t), x * Math.sin(t) + y * Math.cos(t)]);
  const xs = P.map((q) => q[0]), ys = P.map((q) => q[1]), bw = Math.max(...xs) - Math.min(...xs), bh = Math.max(...ys) - Math.min(...ys), u = Math.min(230 / bw, 150 / bh);
  const mx = (Math.max(...xs) + Math.min(...xs)) / 2, my = (Math.max(...ys) + Math.min(...ys)) / 2;
  const S = P.map(([x, y]) => [W / 2 + (x - mx) * u, H / 2 - (y - my) * u]), cen = [(S[0][0] + S[1][0] + S[2][0]) / 3, (S[0][1] + S[1][1] + S[2][1]) / 3];
  s.poligon(S, { dolgu: ACIK, renk: ACIK, kalinlik: 0.5 });
  const kenarlar = [[S[0], S[1], 'a'], [S[0], S[2], 'b'], [S[1], S[2], 'c']];
  for (const [q, r] of kenarlar) s.cizgi(q[0], q[1], r[0], r[1], { kalinlik: 2.8 });
  const bir = (q, r) => { const L = Math.hypot(r[0] - q[0], r[1] - q[1]); return [(r[0] - q[0]) / L, (r[1] - q[1]) / L]; };
  dikIsaret(s, S[0][0], S[0][1], bir(S[0], S[1]), bir(S[0], S[2]), 11);
  for (const [q, r, k] of kenarlar) kenarYaz(s, q, r, p.bilinmeyen === k ? 'x' : `${p[k]} cm`, cen, 15);
  return { sahne: s, alt: 'Dik açı işaretli bir dik üçgen; iki kenarının uzunluğu verilmiş, bir kenarı x.', olgular: { a: p.a, b: p.b, c: p.c, x: p[p.bilinmeyen], bilinmeyen: p.bilinmeyen } };
}

// ---------- dik dairesel silindir ----------
// parametreler: { r, h, goster:'yaricap'|'cap' }
function silindir(p, profil) {
  const W = 290, cx = 150, rx = 62, ry = 24, cyT = 36, hpx = Math.min(130, Math.max(60, (p.h / p.r) * rx * 0.8)), cyB = cyT + hpx, H = cyB + ry + 26, s = new Sahne(W, H, profil);
  if (!['yaricap', 'cap'].includes(p.goster)) hata('goster_gecersiz');
  s.parcalar.push(`<path d="M${cx - rx} ${cyT}L${cx - rx} ${cyB}A${rx} ${ry} 0 0 0 ${cx + rx} ${cyB}L${cx + rx} ${cyT}" fill="${ACIK}" stroke="${PALET.siyah}" stroke-width="2.6" stroke-linejoin="round"/>`);
  s.parcalar.push(`<ellipse cx="${cx}" cy="${cyT}" rx="${rx}" ry="${ry}" fill="${ACIK}" stroke="${PALET.siyah}" stroke-width="2.6"/>`);
  s.noktalar.push([cx - rx, cyT - ry, 0], [cx + rx, cyB + ry, 0]);
  if (p.goster === 'cap') s.cizgi(cx - rx, cyT, cx + rx, cyT, { kalinlik: 2.8, renk: PALET.mavi }); else s.cizgi(cx, cyT, cx + rx, cyT, { kalinlik: 2.8, renk: PALET.mavi });
  s.nokta(cx, cyT, { r: 3.5 });
  s.metin(cx + rx + 8, cyT + 5, `${p.goster === 'cap' ? 2 * p.r : p.r} cm`, { hiza: 'start', boyut: 14, kalin: true });
  const dx = 66; s.cizgi(dx, cyT, dx, cyB, { kalinlik: 1.8 }); s.cizgi(dx - 6, cyT, dx + 6, cyT, { kalinlik: 1.8 }); s.cizgi(dx - 6, cyB, dx + 6, cyB, { kalinlik: 1.8 });
  s.metin(dx - 8, (cyT + cyB) / 2 + 5, `${p.h} cm`, { hiza: 'end', boyut: 14, kalin: true });
  return { sahne: s, alt: 'Bir dik dairesel silindir; üst tabanında bir uzunluk, yanında yükseklik işaretlenmiş.', olgular: { r: p.r, h: p.h, cap: 2 * p.r, hacim: p.r * p.r * p.h, yuzey: 2 * p.r * (p.r + p.h) } };
}

// ---------- koordinat düzleminde doğru ----------
// parametreler: { noktalar:[[x1,y1],[x2,y2]] (kafes noktaları, −5..5), isaret:[[x,y],…] }
function dogruGrafik(p, profil) {
  const W = 300, H = 300, u = 22, cx = 150, cy = 150, s = new Sahne(W, H, profil), X = (x) => cx + x * u, Y = (y) => cy - y * u;
  const [[x1, y1], [x2, y2]] = p.noktalar; if (x1 === x2 && y1 === y2) hata('ayni_nokta');
  for (let i = -6; i <= 6; i++) { s.cizgi(X(i), Y(-6), X(i), Y(6), { renk: PALET.gri, kalinlik: 0.6, izgara: true }); s.cizgi(X(-6), Y(i), X(6), Y(i), { renk: PALET.gri, kalinlik: 0.6, izgara: true }); }
  // çizgiyi çerçeveye kırp
  const dx = x2 - x1, dy = y2 - y1; let t0 = -1e9, t1 = 1e9;
  for (const [pp, dd] of [[x1, dx], [y1, dy]]) { if (dd === 0) continue; const a = (-6 - pp) / dd, b = (6 - pp) / dd; t0 = Math.max(t0, Math.min(a, b)); t1 = Math.min(t1, Math.max(a, b)); }
  s.cizgi(X(x1 + t0 * dx), Y(y1 + t0 * dy), X(x1 + t1 * dx), Y(y1 + t1 * dy), { renk: PALET.mavi, kalinlik: 3.2 });
  s.cizgi(X(-6.5), Y(0), X(6.5), Y(0), { ok: true, kalinlik: 1.8 }); s.cizgi(X(0), Y(-6.5), X(0), Y(6.5), { ok: true, kalinlik: 1.8 });
  const yer = (adaylar, t, boyut) => { const a = adaylar.find(([x, y, h]) => s.bosMu(s._kutu(x, y, t, boyut, h))) ?? adaylar[0]; s.metin(a[0], a[1], t, { boyut, hiza: a[2] }); };
  s.metin(X(6.5) - 6, Y(0) - 9, 'x', { boyut: 14, kalin: true }); s.metin(X(0) + 12, 20, 'y', { boyut: 14, kalin: true });
  for (let i = -6; i <= 6; i++) {
    if (!i) continue;
    const t = i < 0 ? `−${-i}` : String(i);
    yer([[X(i), Y(0) + 12, 'middle'], [X(i), Y(0) - 6, 'middle']], t, 10);
    yer([[X(0) - 5, Y(i) + 4.5, 'end'], [X(0) + 5, Y(i) + 4.5, 'start']], t, 10);
  }
  for (const [x, y] of p.isaret ?? []) s.nokta(X(x), Y(y), { r: 4.5 });
  const pay = dy, payda = dx, g = gcd(pay, payda), sg = payda < 0 ? -1 : 1, rp = (sg * pay) / g, rd = Math.abs(payda) / g;
  const m = pay / payda, n = y1 - m * x1;
  return { sahne: s, alt: 'Koordinat düzleminde bir doğru ve üzerinde işaretli noktalar.', olgular: { egim: rd === 1 ? String(rp) : `${rp}/${rd}`, egim_pay: rp, egim_payda: rd, m, n } };
}

// ---------- çark (olasılık) ----------
// parametreler: { sayilar:[…] } (6, 8 ya da 10 eş dilim; her dilimde bir sayı)
const asalMi = (x) => x > 1 && Array.from({ length: Math.floor(Math.sqrt(x)) - 1 }, (_, i) => i + 2).every((d) => x % d);
function cark(p, profil) {
  const n = p.sayilar.length; if (![6, 8, 10].includes(n)) hata('dilim_6_8_10');
  const W = 240, H = 250, cx = 120, cy = 136, Rr = 90, st = 360 / n, s = new Sahne(W, H, profil);
  p.sayilar.forEach((v, i) => s.dilim(cx, cy, Rr, 90 - (i + 1) * st, 90 - i * st, { dolgu: i % 2 ? ACIK : '#FFFFFF', kalinlik: 2.2 }));
  p.sayilar.forEach((v, i) => { const a = rad(90 - (i + 0.5) * st), q = Rr * 0.64; s.metin(cx + q * Math.cos(a), cy - q * Math.sin(a) + 6, String(v), { boyut: 17, kalin: true }); });
  s.nokta(cx, cy, { r: 4 });
  s.poligon([[cx, cy - Rr + 2], [cx - 11, cy - Rr - 20], [cx + 11, cy - Rr - 20]], { dolgu: PALET.siyah, kalinlik: 1 });
  const say = (f) => p.sayilar.filter(f).length;
  return { sahne: s, alt: 'Eş dilimli bir çark; her dilimde bir sayı yazıyor ve üstte bir ok var.', olgular: { n, sayim: { asal: say(asalMi), cift: say((v) => v % 2 === 0), tek: say((v) => v % 2 === 1), uc_kati: say((v) => v % 3 === 0), buyuk5: say((v) => v > 5), kucuk10: say((v) => v < 10) } } };
}

// ---------- benzer üçgenler ----------
// parametreler: { t1:[a,b,c] (BC, CA, AB), k:2|3, bilinen:0|1|2, bilinmeyen:0|1|2 }  İkinci üçgen birincinin k katıdır; aynı yönde çizilir, eş açılar yaylarla gösterilir.
function benzer(p, profil) {
  const W = 340, H = 210, yb = 168, s = new Sahne(W, H, profil), [a, b, c] = p.t1;
  const cxl = (b * b + c * c - a * a) / (2 * c), cyl = Math.sqrt(Math.max(0, b * b - cxl * cxl));
  if (!(cyl > 0.5) || p.bilinen === p.bilinmeyen) hata('ucgen_gecersiz');
  const x0 = Math.min(0, cxl), w1 = Math.max(c, cxl) - x0, u = Math.min(14, 256 / ((1 + p.k) * w1), 118 / (cyl * p.k));
  if (u < 6) hata('olcek_kucuk');
  const ox1 = 24 - x0 * u, sag1 = ox1 + Math.max(c, cxl) * u, ox2 = sag1 + 36 - x0 * p.k * u;
  [1, p.k].forEach((kat, ti) => {
    const ox = ti ? ox2 : ox1, A = [ox, yb], B = [ox + c * kat * u, yb], C = [ox + cxl * kat * u, yb - cyl * kat * u], cen = [(A[0] + B[0] + C[0]) / 3, (A[1] + B[1] + C[1]) / 3];
    s.poligon([A, B, C], { dolgu: ACIK, renk: ACIK, kalinlik: 0.5 });
    [[B, C, 0], [C, A, 1], [A, B, 2]].forEach(([q, r, idx]) => {
      s.cizgi(q[0], q[1], r[0], r[1], { kalinlik: 2.6 });
      const deger = [a, b, c][idx] * kat, metin = ti === 0 ? String(deger) : idx === p.bilinmeyen ? 'x' : idx === p.bilinen ? String(deger) : null;
      if (metin) kenarYaz(s, q, r, metin, cen, 14, [8, 16, 24]);
    });
    const tA = (Math.atan2(cyl, cxl) * 180) / Math.PI, tB = (Math.atan2(cyl, cxl - c) * 180) / Math.PI, ra = 14 + (ti ? 4 : 0);
    s.yay(A[0], A[1], ra, 0, tA, { kalinlik: 1.8 }); s.yay(B[0], B[1], ra, tB, 180, { kalinlik: 1.8 }); s.yay(B[0], B[1], ra + 5, tB, 180, { kalinlik: 1.8 });
  });
  const t2 = p.t1.map((v) => v * p.k);
  return { sahne: s, alt: 'Aynı yönde çizilmiş iki benzer üçgen; kenar uzunlukları yazılmış, biri x.', olgular: { t1: p.t1, t2, x: t2[p.bilinmeyen], oran: p.k } };
}

export const TIPLER_B1 = {
  'b1-pisagor': pisagor,
  'b1-silindir': silindir,
  'b1-dogru-grafigi': dogruGrafik,
  'b1-cark': cark,
  'b1-benzer': benzer,
  'b1-bolunmus': bolunmus,
  'b1-para': para,
  'b1-simge-grafigi': simgeGrafigi,
  'b1-cetele': cetele,
  'b1-saat': saat,
  'b1-simetri-dogrulari': simetriDogrulari,
  'b1-paralel-kesen': paralelKesen,
  'b1-alan': alanTipi,
  'b1-cember': cemberUzunluk,
};
void Sahne;
