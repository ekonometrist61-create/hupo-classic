// Ajan A4 için şekil tipleri (Matematik 7 ve 8). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'a4-' önekiyle başlar.
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const r2 = (n) => Math.round(n * 100) / 100;
const polar = (cx, cy, r, a) => [cx + r * Math.cos(aciRad(a)), cy - r * Math.sin(aciRad(a))];
const matAci = (dx, dy) => { const a = (Math.atan2(-dy, dx) * 180) / Math.PI; return a < 0 ? a + 360 : a; };
const uz = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const orta = (a, b) => [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
const OKYON = [[1, 0], [-1, 0], [0, -1], [0, 1], [0.7, -0.7], [-0.7, -0.7], [0.7, 0.7], [-0.7, 0.7]];

// ---- şablonların kullandığı yardımcılar ----
export const eksi = (n) => (n < 0 ? `−${-n}` : String(n));
export const ondalik = (v) => String(r2(v)).replace('.', ',');
export const nokta2 = (x, y) => `(${eksi(x)}, ${eksi(y)})`;
// Doğru değer konumda (kp), komşu parametre değerleri çeldirici: f(p-kp*adim ... ) → 4 farklı pozitif tam sayı.
export function pencere(f, p, kp, adimlar = [1], min = 1) {
  for (const adim of adimlar) {
    const ps = [0, 1, 2, 3].map((i) => p + (i - kp) * adim);
    if (ps.some((v) => v < min)) continue;
    const vs = ps.map(f);
    if (vs.every((v) => Number.isInteger(v) && v > 0) && new Set(vs).size === 4) return { ps, vs };
  }
  throw new Error('pencere_kurulamadi');
}
function yanAdaylar(x, y, metin, boyut, mesafeler = [10, 18, 28]) {
  const gen = String(metin).length * boyut * 0.6;
  return mesafeler.flatMap((m) => OKYON.map(([a, b]) => [x + a * (m + Math.abs(a) * gen / 2), y + b * (m + Math.abs(b) * boyut * 0.5) + boyut * 0.35]));
}

// ---------- 1) daire / daire dilimi ----------
// { etiket:'yaricap'|'cap', deger, aci?:30..359 (dilim), yon?, baslangic?, birim? }  Uzunluk değeri doğru parçasının yanında yazılır.
function daire(p, profil) {
  const W = 300, H = 270, cx = 150, cy = 135, R = 98, s = new Sahne(W, H, profil), DOLGU = '#D7EAF8';
  const aci = p.aci ?? 360, birim = p.birim ?? 'cm', yon = p.yon ?? 30;
  const yaz = `${p.deger} ${birim}`;
  const r = p.etiket === 'cap' ? p.deger / 2 : p.deger;
  if (aci >= 360) {
    s.cember(cx, cy, R, { dolgu: DOLGU, kalinlik: 2.2 });
    const a = polar(cx, cy, R, yon);
    let m;
    if (p.etiket === 'cap') {
      const b = polar(cx, cy, R, yon + 180);
      s.cizgi(b[0], b[1], a[0], a[1], { kalinlik: 2.4 }); s.nokta(a[0], a[1]); s.nokta(b[0], b[1]);
      m = [cx, cy];
    } else { s.cizgi(cx, cy, a[0], a[1], { kalinlik: 2.4 }); m = polar(cx, cy, R / 2, yon); }
    s.nokta(cx, cy);
    const d = [Math.cos(aciRad(yon)), -Math.sin(aciRad(yon))], n = [-d[1], d[0]];
    const ad = [];
    for (const t of [0, 0.25, -0.25, 0.4, -0.4]) for (const sg of [1, -1]) for (const off of [20, 28]) ad.push([m[0] + d[0] * t * R + sg * n[0] * off, m[1] + d[1] * t * R + sg * n[1] * off + 5]);
    s.metinYerlestir(ad, yaz, { kalin: true });
  } else {
    const a0 = p.baslangic ?? 20, a1 = a0 + aci;
    s.dilim(cx, cy, R, a0, a1, { dolgu: DOLGU, kalinlik: 2.2 });
    const e0 = polar(cx, cy, R, a0), e1 = polar(cx, cy, R, a1);
    s.cizgi(cx, cy, e0[0], e0[1], { kalinlik: 2.4 }); s.cizgi(cx, cy, e1[0], e1[1], { kalinlik: 2.4 });
    s.nokta(cx, cy);
    s.yay(cx, cy, 24, a0, a1, { kalinlik: 1.6 });
    const mid = (a0 + a1) / 2, ia = [];
    for (const dd of [46, 58, 70]) ia.push(polar(cx, cy, dd, mid).map((v, i) => (i ? v + 5 : v)));
    for (const dd of [R + 20, R + 30]) ia.push(polar(cx, cy, dd, mid).map((v, i) => (i ? v + 5 : v)));
    s.metinYerlestir(ia, `${aci}°`, { kalin: true });
    const q = polar(cx, cy, R / 2, a0), d = [Math.cos(aciRad(a0)), -Math.sin(aciRad(a0))], n = [-d[1], d[0]], ad = [];
    for (const t of [0, 0.2, -0.2]) for (const sg of [1, -1]) for (const off of [18, 26]) ad.push([q[0] + d[0] * t * R + sg * n[0] * off, q[1] + d[1] * t * R + sg * n[1] * off + 5]);
    s.metinYerlestir(ad, yaz, { kalin: true });
  }
  const pa = p.pi ?? [3, 1];
  const bol = (v, k) => (Number.isInteger(v / k) ? v / k : null);
  const alan = bol(pa[0] * r * r, pa[1]), cevre = bol(2 * pa[0] * r, pa[1]);
  const dAlan = bol(pa[0] * r * r * aci, pa[1] * 360), yay = bol(2 * pa[0] * r * aci, pa[1] * 360);
  const olgular = { yaricap: r, cap: 2 * r, aci, alan, cevre, dilim_alan: dAlan, yay_uzunlugu: yay, dilim_cevre: yay === null ? null : yay + 2 * r };
  const alt = aci >= 360 ? 'Bir daire ve üzerinde uzunluğu yazılı bir doğru parçası.' : 'Merkez açısı işaretli, bir kenarında uzunluk yazılı bir daire dilimi.';
  return { sahne: s, alt, olgular };
}

// ---------- 2) üçgende özel doğru parçası ----------
// { cesit:'kenarortay'|'aciortay'|'yukseklik'|'orta_dikme', harf:{A,B,C,D,E}, t:0.2..0.8, yukseklik? }
function ucgenCizgi(p, profil) {
  const W = 340, H = 250, s = new Sahne(W, H, profil), h = p.harf;
  const B = [34, 205], C = [306, 205], A = [B[0] + (C[0] - B[0]) * p.t, 205 - (p.yukseklik ?? 150)];
  if (!['kenarortay', 'aciortay', 'yukseklik', 'orta_dikme'].includes(p.cesit)) hata(`cesit_bilinmiyor:${p.cesit}`);
  if (p.cesit === 'orta_dikme' && Math.abs(p.t - 0.5) < 0.12) hata('orta_dikme_tepeye_yakin');
  let D, E = null;
  if (p.cesit === 'kenarortay' || p.cesit === 'orta_dikme') D = orta(B, C);
  else if (p.cesit === 'aciortay') { const ab = uz(A, B), ac = uz(A, C); D = [B[0] + (C[0] - B[0]) * ab / (ab + ac), 205]; }
  else D = [A[0], 205];
  if (p.cesit === 'orta_dikme') {
    const Q = D[0] > A[0] ? C : B, u = (D[0] - A[0]) / (Q[0] - A[0]);
    E = [A[0] + (Q[0] - A[0]) * u, A[1] + (Q[1] - A[1]) * u];
  }
  for (const [x, y] of [[B, C], [C, A], [A, B]].map(([a, b]) => [a, b])) { void x; void y; }
  s.cizgi(B[0], B[1], C[0], C[1], { kalinlik: 2.2 }); s.cizgi(C[0], C[1], A[0], A[1], { kalinlik: 2.2 }); s.cizgi(A[0], A[1], B[0], B[1], { kalinlik: 2.2 });
  const OZEL = { renk: PALET.kirmizi, kalinlik: 3.6 };
  if (E) s.cizgi(D[0], D[1], E[0], E[1], OZEL); else s.cizgi(A[0], A[1], D[0], D[1], OZEL);
  const tik = (a, b) => { const m = orta(a, b), dx = b[0] - a[0], dy = b[1] - a[1], l = Math.hypot(dx, dy); s.cizgi(m[0] - (dy / l) * 6, m[1] + (dx / l) * 6, m[0] + (dy / l) * 6, m[1] - (dx / l) * 6, { kalinlik: 2 }); };
  const dikIsaret = () => s.poligon([[D[0], D[1]], [D[0] + 11, D[1]], [D[0] + 11, D[1] - 11], [D[0], D[1] - 11]], { kalinlik: 1.6 });
  if (p.cesit === 'kenarortay' || p.cesit === 'orta_dikme') { tik(B, D); tik(D, C); }
  if (p.cesit === 'orta_dikme' || p.cesit === 'yukseklik') dikIsaret();
  if (p.cesit === 'aciortay') {
    const aB = matAci(B[0] - A[0], B[1] - A[1]), aD = matAci(D[0] - A[0], D[1] - A[1]), aC = matAci(C[0] - A[0], C[1] - A[1]);
    for (const [a0, a1] of [[aB, aD], [aD, aC]]) {
      const rr = 34; s.yay(A[0], A[1], rr, a0, a1, { kalinlik: 1.8 });
      const m = (a0 + a1) / 2, i = polar(A[0], A[1], rr - 5, m), o = polar(A[0], A[1], rr + 5, m);
      s.cizgi(i[0], i[1], o[0], o[1], { kalinlik: 2 });
    }
  }
  [[h.A, A, [0, -10]], [h.B, B, [-12, 20]], [h.C, C, [12, 20]]].forEach(([ad, q, [dx, dy]]) => s.metin(q[0] + dx, q[1] + dy, ad, { kalin: true }));
  s.metin(D[0], D[1] + 22, h.D, { kalin: true });
  if (E) s.metinYerlestir(yanAdaylar(E[0], E[1], h.E, profil.yazi, [10, 16]), h.E, { kalin: true });
  const aci = (P, Q, R_) => { const u = [P[0] - Q[0], P[1] - Q[1]], v = [R_[0] - Q[0], R_[1] - Q[1]]; return (Math.acos((u[0] * v[0] + u[1] * v[1]) / (Math.hypot(...u) * Math.hypot(...v))) * 180) / Math.PI; };
  const yakin = (a, b) => Math.abs(a - b) < 0.6;
  const olgular = {
    cesit: p.cesit,
    bd_dc_esit: yakin(uz(B, D), uz(D, C)),
    bad_dac_esit: p.cesit === 'orta_dikme' ? false : yakin(aci(B, A, D), aci(D, A, C)),
    adb_dik: p.cesit === 'orta_dikme' ? false : yakin(aci(A, D, B), 90),
    ab_ac_esit: yakin(uz(A, B), uz(A, C)),
    de_bc_dik: E ? yakin(aci(E, D, C), 90) : false,
  };
  return { sahne: s, alt: 'Bir üçgen ve içinde kalın çizilmiş, işaretlerle donatılmış bir doğru parçası.', olgular };
}

// ---------- 3) koordinat sistemi ----------
// { x:[min,max], y:[min,max], adim?:[ax,ay], eksenAdi?:{x,y}, noktalar:[{ad,x,y}], cokgenler:[{koseler:[{ad,x,y}]}],
//   dogrular:[{ad?, p:[x,y], q:[x,y], kesik?, uzat?, renk?, noktalar?:[[x,y]]}], donusum?:{tur:'yansima',dogru:{x|y:k}}|{tur:'otele',dx,dy} }
function koordinat(p, profil) {
  const [x0, x1] = p.x, [y0, y1] = p.y, ax = p.adim?.[0] ?? 1, ay = p.adim?.[1] ?? 1;
  const nx = (x1 - x0) / ax, ny = (y1 - y0) / ay;
  const u = Math.max(16, Math.min(28, Math.floor(290 / nx), Math.floor(270 / ny)));
  const sol = 40, ust = 28, sag = 24, alt = p.eksenAdi ? 46 : 28, W = nx * u + sol + sag, H = ny * u + ust + alt;
  const s = new Sahne(W, H, profil), X = (v) => sol + ((v - x0) / ax) * u, Y = (v) => ust + ((y1 - v) / ay) * u;
  const ox = X(Math.min(Math.max(0, x0), x1)), oy = Y(Math.min(Math.max(0, y0), y1));
  for (let i = 0; i <= nx; i++) s.cizgi(X(x0 + i * ax), Y(y0), X(x0 + i * ax), Y(y1), { renk: '#D1D5DB', kalinlik: 0.7, izgara: true });
  for (let j = 0; j <= ny; j++) s.cizgi(X(x0), Y(y0 + j * ay), X(x1), Y(y0 + j * ay), { renk: '#D1D5DB', kalinlik: 0.7, izgara: true });
  s.cizgi(X(x0) - 4, oy, X(x1) + 12, oy, { kalinlik: 1.8, ok: true });
  s.cizgi(ox, Y(y0) + 4, ox, Y(y1) - 12, { kalinlik: 1.8, ok: true });
  for (let i = 0; i <= nx; i++) { const v = x0 + i * ax; if (v !== 0 && Math.abs(v / ax) % 2 === 0) s.metin(X(v), oy + 17, eksi(v), { boyut: 12 }); }
  for (let j = 0; j <= ny; j++) { const v = y0 + j * ay; if (v !== 0 && Math.abs(v / ay) % 2 === 0) s.metin(ox - 7, Y(v) + 4, eksi(v), { boyut: 12, hiza: 'end' }); }
  if (x0 <= 0 && y0 <= 0) s.metin(ox - 7, oy + 17, '0', { boyut: 12, hiza: 'end' });
  if (p.eksenAdi) {
    s.metin(X(x1), H - 8, p.eksenAdi.x, { boyut: 12, hiza: 'end', kalin: true });
    s.metin(ox + 8, 14, p.eksenAdi.y, { boyut: 12, hiza: 'start', kalin: true });
  } else { s.metin(X(x1) + 10, oy + 17, 'x', { boyut: 12, kalin: true }); s.metin(ox + 10, ust - 14, 'y', { boyut: 12, kalin: true }); }
  const olgular = { noktalar: {}, dogrular: {}, goruntu: {} };
  const yansit = (pt, d) => (d.x !== undefined ? [2 * d.x - pt[0], pt[1]] : [pt[0], 2 * d.y - pt[1]]);
  const don = (pt) => (!p.donusum ? null : p.donusum.tur === 'yansima' ? yansit(pt, p.donusum.dogru) : [pt[0] + p.donusum.dx, pt[1] + p.donusum.dy]);
  const nokta = (n, renk) => {
    if (n.x < x0 || n.x > x1 || n.y < y0 || n.y > y1) hata(`nokta_kafes_disi:${n.ad}`);
    s.nokta(X(n.x), Y(n.y), { r: 4.2, renk });
    olgular.noktalar[n.ad] = [n.x, n.y]; const g = don([n.x, n.y]); if (g) olgular.goruntu[n.ad] = g;
  };
  for (const c of p.cokgenler ?? []) {
    const k = c.koseler, pts = k.map((q) => [X(q.x), Y(q.y)]);
    s.poligon(pts, { renk: '#CFE5F5', dolgu: '#CFE5F5', kalinlik: 0.5 });
    pts.forEach((a, i) => { const b = pts[(i + 1) % pts.length]; s.cizgi(a[0], a[1], b[0], b[1], { renk: PALET.mavi, kalinlik: 2.4 }); });
    const gx = k.reduce((t, q) => t + X(q.x), 0) / k.length, gy = k.reduce((t, q) => t + Y(q.y), 0) / k.length;
    for (const q of k) {
      nokta(q, PALET.mavi);
      const dx = X(q.x) - gx, dy = Y(q.y) - gy, l = Math.hypot(dx, dy) || 1;
      const sirali = [...OKYON].sort((a, b) => (b[0] * dx + b[1] * dy) / l - (a[0] * dx + a[1] * dy) / l);
      const gen = q.ad.length * 7.8;
      const ad = [11, 17, 25].flatMap((m) => sirali.map(([a, b]) => [X(q.x) + a * (m + Math.abs(a) * gen / 2), Y(q.y) + b * (m + Math.abs(b) * 6) + 4.5]));
      s.metinYerlestir(ad, q.ad, { kalin: true, renk: PALET.mavi });
    }
  }
  for (const n of p.noktalar ?? []) { nokta(n, PALET.mavi); s.metinYerlestir(yanAdaylar(X(n.x), Y(n.y), n.ad, 13, [8, 14, 22]), n.ad, { kalin: true, renk: PALET.mavi }); }
  for (const d of p.dogrular ?? []) {
    const [px, py] = d.p, [qx, qy] = d.q, dx = qx - px, dy = qy - py;
    let ta = d.uzat === false ? 0 : -1e9, tb = d.uzat === false ? 1 : 1e9;
    for (const [pp, dd, lo, hi] of [[px, dx, x0, x1], [py, dy, y0, y1]]) {
      if (dd === 0) { if (pp < lo || pp > hi) hata('dogru_disarida'); continue; }
      const t1 = (lo - pp) / dd, t2 = (hi - pp) / dd; ta = Math.max(ta, Math.min(t1, t2)); tb = Math.min(tb, Math.max(t1, t2));
    }
    const e1 = [px + dx * ta, py + dy * ta], e2 = [px + dx * tb, py + dy * tb], renk = d.renk ? PALET[d.renk] : PALET.kirmizi;
    s.cizgi(X(e1[0]), Y(e1[1]), X(e2[0]), Y(e2[1]), { renk, kalinlik: 2.6, kesik: !!d.kesik });
    if (d.uzat !== false && !d.kesik) { s._okBasi(X(e2[0]), Y(e2[1]), Math.atan2(Y(e2[1]) - Y(e1[1]), X(e2[0]) - X(e1[0])), renk); s._okBasi(X(e1[0]), Y(e1[1]), Math.atan2(Y(e1[1]) - Y(e2[1]), X(e1[0]) - X(e2[0])), renk); }
    for (const [nx_, ny_] of d.noktalar ?? []) s.nokta(X(nx_), Y(ny_), { r: 4.6, renk: PALET.siyah });
    if (d.ad) {
      const ek = (t) => [X(px + dx * t), Y(py + dy * t)];
      const ad = [tb, ta].flatMap((t) => { const q = ek(t); return yanAdaylar(q[0], q[1], d.ad, 13, [10, 18]); });
      s.metinYerlestir(ad, d.ad, { kalin: true, renk });
    }
    if (dx !== 0) {
      const g = (a, b) => (b ? g(b, a % b) : Math.abs(a)), k = g(dy, dx), pay = (dy / k) * Math.sign(dx), payda = Math.abs(dx / k);
      const nPay = py * payda - pay * px; // n = nPay / payda
      const gg = g(nPay, payda) || 1;
      olgular.dogrular[d.ad ?? 'd'] = { egim: [pay, payda], kesim_y: [nPay / gg, payda / gg] };
    } else olgular.dogrular[d.ad ?? 'd'] = { egim: null, kesim_y: null };
  }
  return { sahne: s, alt: 'Kareli bir koordinat sisteminde bazı noktalar ya da doğrular işaretlenmiş.', olgular };
}

// ---------- 4) daire grafiği ----------
// { dilimler:[{ad, deger}], gosterim:'yuzde'|'aci'|'sayi' }  yuzde: değerler toplamı 100.
function pasta(p, profil) {
  const W = 340, H = 300, cx = 170, cy = 150, R = 74, s = new Sahne(W, H, profil), d = p.dilimler;
  if (d.length < 3 || d.length > 5) hata('dilim_3_5');
  const top = d.reduce((t, x) => t + x.deger, 0), DOLGU = ['#FDE7C2', '#D5EAF8', '#D7F0E3', '#F6DCEA', '#E3E0F4'];
  let ust = 90; const olgular = { yuzde: {}, aci: {}, deger: {}, toplam: top };
  d.forEach((x, i) => {
    const th = (360 * x.deger) / top, a1 = ust, a0 = ust - th; ust = a0;
    s.dilim(cx, cy, R, a0, a1, { dolgu: DOLGU[i % 5], kalinlik: 1.8 });
    const yuz = (100 * x.deger) / top;
    olgular.yuzde[x.ad] = r2(yuz); olgular.aci[x.ad] = r2(th); olgular.deger[x.ad] = x.deger;
    const gost = p.gosterim === 'yuzde' ? `%${r2(yuz)}` : p.gosterim === 'aci' ? `${r2(th)}°` : String(x.deger);
    const mid = (a0 + a1) / 2, c = Math.cos(aciRad(mid)), sn = Math.sin(aciRad(mid)), hiza = c > 0.3 ? 'start' : c < -0.3 ? 'end' : 'middle';
    const adaylar = [14, 22, 30, 40, 52, 64].map((dist) => {
      const q = polar(cx, cy, R + dist, mid); const tx = q[0] + (hiza === 'start' ? 2 : hiza === 'end' ? -2 : 0);
      const ty = Math.abs(sn) > 0.75 ? (sn > 0 ? q[1] - 20 : q[1] + 8) : q[1] - 4;
      return [tx, ty];
    });
    const sec = adaylar.find(([tx, ty]) => s.bosMu(s._kutu(tx, ty, x.ad, 13, hiza)) && s.bosMu(s._kutu(tx, ty + 19, gost, 13, hiza))) ?? adaylar[0];
    s.metin(sec[0], sec[1], x.ad, { kalin: true, hiza }); s.metin(sec[0], sec[1] + 19, gost, { hiza });
  });
  return { sahne: s, alt: `Daire grafiği: ${d.map((x) => x.ad).join(', ')} dilimleri.`, olgular };
}

// ---------- 5) çizgi grafiği (en çok 3 seri) ----------
// { baslik, birim?, x:[etiketler], seriler:[{ad, v:[...]}], max, adim }  Değerler adim/2'nin katı.
function cizgiGrafik(p, profil) {
  const W = 370, H = 270, sol = 48, sag = 292, ust = 48, alt = 200, s = new Sahne(W, H, profil), n = p.x.length;
  if (n < 3 || n > 7) hata('x_3_7');
  if (p.seriler.length > 3) hata('seri_en_cok_3');
  const Y = (v) => alt - (v / p.max) * (alt - ust), X = (i) => sol + 14 + (i * (sag - sol - 28)) / (n - 1);
  s.metin(W / 2, 20, p.baslik, { kalin: true });
  if (p.birim) s.metin(sol - 6, ust - 14, p.birim, { boyut: 12, hiza: 'end' });
  for (let v = 0; v <= p.max + 1e-9; v += p.adim) { s.cizgi(sol, Y(v), sag, Y(v), { renk: '#D1D5DB', kalinlik: 0.7, izgara: true }); s.metin(sol - 8, Y(v) + 4, String(v), { boyut: 12, hiza: 'end' }); }
  s.cizgi(sol, ust - 6, sol, alt, { kalinlik: 1.8 }); s.cizgi(sol, alt, sag, alt, { kalinlik: 1.8 });
  p.x.forEach((e, i) => s.metin(X(i), alt + 18, e, { boyut: 12 }));
  const RENK = [PALET.mavi, PALET.kirmizi, PALET.yesil], olgular = { seriler: {}, x: p.x };
  const etiketY = [];
  p.seriler.forEach((se, k) => {
    if (se.v.length !== n) hata('seri_uzunluk');
    for (const v of se.v) { const kat = v / (p.adim / 2); if (Math.abs(kat - Math.round(kat)) > 1e-9 || v < 0 || v > p.max) hata(`deger_gecersiz:${v}`); }
    olgular.seriler[se.ad] = se.v;
    for (let i = 0; i + 1 < n; i++) s.cizgi(X(i), Y(se.v[i]), X(i + 1), Y(se.v[i + 1]), { renk: RENK[k], kalinlik: 2.6 });
    se.v.forEach((v, i) => {
      if (k === 0) s.cember(X(i), Y(v), 4.2, { dolgu: RENK[k], renk: RENK[k], kalinlik: 1 });
      else if (k === 1) s.dikdortgen(X(i) - 4, Y(v) - 4, 8, 8, { dolgu: RENK[k], renk: RENK[k], kalinlik: 1 });
      else s.poligon([[X(i), Y(v) - 5.5], [X(i) - 5, Y(v) + 4], [X(i) + 5, Y(v) + 4]], { dolgu: RENK[k], renk: RENK[k], kalinlik: 1 });
    });
    etiketY.push({ k, y: Y(se.v[n - 1]) + 4, ad: se.ad });
  });
  etiketY.sort((a, b) => a.y - b.y);
  for (let i = 1; i < etiketY.length; i++) if (etiketY[i].y - etiketY[i - 1].y < 17) etiketY[i].y = etiketY[i - 1].y + 17;
  if (p.seriler.length > 1) for (const e of etiketY) s.metin(X(n - 1) + 11, e.y, e.ad, { hiza: 'start', kalin: true, renk: RENK[e.k] });
  return { sahne: s, alt: `Çizgi grafiği: ${p.baslik}.`, olgular };
}

// ---------- 6) küp yapısının üstten görünümü ----------
// { yukseklik:[[...]] }  satır sayısı 2–4, sütun 2–4; 0 = küp yok. Alt kenar ÖN, sağ kenar SAĞ.
function kupUst(p, profil) {
  const g = p.yukseklik, rows = g.length, cols = g[0].length;
  if (rows < 2 || rows > 4 || cols < 2 || cols > 4) hata('boyut_2_4');
  const cell = 48, m = 20, W = cols * cell + 2 * m + 44, H = rows * cell + 2 * m + 30, s = new Sahne(W, H, profil);
  g.forEach((satir, i) => satir.forEach((h, j) => {
    if (h < 0 || h > 5) hata('yukseklik_0_5');
    if (!h) return;
    s.dikdortgen(m + j * cell, m + i * cell, cell, cell, { dolgu: '#EEF2F7', kalinlik: 1.8 });
    s.metin(m + j * cell + cell / 2, m + i * cell + cell / 2 + 7, String(h), { boyut: 20, kalin: true });
  }));
  s.metin(m + (cols * cell) / 2, m + rows * cell + 24, 'ÖN', { kalin: true });
  s.metin(m + cols * cell + 8, m + (rows * cell) / 2 + 5, 'SAĞ', { kalin: true, hiza: 'start' });
  const T = g.flat().reduce((a, b) => a + b, 0);
  const on = Array.from({ length: cols }, (_, j) => Math.max(...g.map((r) => r[j]))).reduce((a, b) => a + b, 0);
  const sag = g.map((r) => Math.max(...r)).reduce((a, b) => a + b, 0);
  let yuzey = 0;
  g.forEach((r, i) => r.forEach((h, j) => {
    if (!h) return;
    yuzey += 2;
    for (const [di, dj] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) yuzey += Math.max(0, h - (g[i + di]?.[j + dj] ?? 0));
  }));
  const olgular = { toplam: T, on_gorunum_kare: on, sag_gorunum_kare: sag, ust_kare: g.flat().filter((h) => h > 0).length, dis_yuzey: yuzey };
  return { sahne: s, alt: 'Birim küplerden oluşan bir yapının üstten görünümü; karelerin içinde sayılar yazılı.', olgular };
}

export const TIPLER_A4 = {
  'a4-daire': daire,
  'a4-ucgen-cizgi': ucgenCizgi,
  'a4-koordinat': koordinat,
  'a4-pasta': pasta,
  'a4-cizgi-grafik': cizgiGrafik,
  'a4-kup-ust': kupUst,
};
