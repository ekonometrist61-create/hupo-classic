// Ajan A1 için şekil tipleri (Matematik 2 ve 3. sınıf). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları benzersiz: 'a1-...' önekiyle başlar. Başka ajanın dosyasına dokunma.
// Not: alt metinler cevabı ya da şekildeki sayıları yazmaz; çözücü `olgular` içindedir.
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const yv = (n) => Math.round(n * 100) / 100;
const LCG = (t) => () => { t = (Math.imul(t, 1664525) + 1013904223) >>> 0; return t / 4294967296; };
const GRI_CIZGI = '#6B7280';

// Ham yol (path) ekler; sınır denetimi için köşe noktalarını kaydeder.
function yolEkle(s, d, pts, { dolgu = 'none', renk = PALET.siyah, kalinlik = 1.2, kesik = false } = {}) {
  for (const [x, y] of pts) s.noktalar.push([x, y, 0]);
  s.parcalar.push(`<path d="${d}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${kalinlik}" stroke-linejoin="round" stroke-linecap="round"${kesik ? ' stroke-dasharray="5 4"' : ''}/>`);
}
function elips(s, cx, cy, rx, ry, { dolgu = 'none', renk = PALET.siyah, kalinlik = 1.4 } = {}) {
  s.noktalar.push([cx - rx, cy - ry, 0], [cx + rx, cy + ry, 0]);
  s.parcalar.push(`<ellipse cx="${yv(cx)}" cy="${yv(cy)}" rx="${yv(rx)}" ry="${yv(ry)}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${s._renk(renk)}" stroke-width="${kalinlik}"/>`);
}
const poly = (s, pts, o = {}) => s.poligon(pts, { renk: PALET.siyah, kalinlik: 1.6, ...o });
const izgaraYolu = (x, y, w, h, nx, ny) => {
  let d = '';
  for (let i = 1; i < nx; i++) d += `M${yv(x + (w * i) / nx)} ${yv(y)}V${yv(y + h)}`;
  for (let j = 1; j < ny; j++) d += `M${yv(x)} ${yv(y + (h * j) / ny)}H${yv(x + w)}`;
  return d;
};

// ---------- 1) taban blokları (yüzlük kare, onluk çubuk, birlik küp) ----------
// parametreler: { sayi: 1..999 }  Modelde büyük kare = yüzlük, uzun çubuk = onluk, küçük kare = birlik.
function tabanBlok(p, profil) {
  const n = p.sayi; if (!Number.isInteger(n) || n < 1 || n > 999) hata('sayi_aralik_disi');
  const y = Math.floor(n / 100), o = Math.floor(n / 10) % 10, b = n % 10;
  const u = y > 0 ? 6 : 9, S = 10 * u, W = y > 0 ? 360 : 270;
  const satir = Math.ceil(y / 5), hh = y > 0 ? satir * (S + 8) - 8 : 0;
  const y1 = y > 0 ? 12 + hh + 14 : 14, H = y1 + 10 * u + 14;
  const s = new Sahne(W, H, profil);
  for (let i = 0; i < y; i++) {
    const x = 12 + (i % 5) * (S + 8), yy = 12 + Math.floor(i / 5) * (S + 8);
    s.dikdortgen(x, yy, S, S, { dolgu: '#CFE8F8', renk: PALET.siyah, kalinlik: 1.4 });
    yolEkle(s, izgaraYolu(x, yy, S, S, 10, 10), [[x, yy], [x + S, yy + S]], { renk: GRI_CIZGI, kalinlik: 0.6 });
  }
  for (let i = 0; i < o; i++) {
    const x = 12 + i * (u + 5);
    s.dikdortgen(x, y1, u, 10 * u, { dolgu: '#BDE5D2', renk: PALET.siyah, kalinlik: 1.2 });
    yolEkle(s, izgaraYolu(x, y1, u, 10 * u, 1, 10), [[x, y1], [x + u, y1 + 10 * u]], { renk: GRI_CIZGI, kalinlik: 0.6 });
  }
  const bx = 12 + 9 * (u + 5) + 26;
  for (let i = 0; i < b; i++) {
    s.dikdortgen(bx + (i % 5) * (u + 5), y1 + Math.floor(i / 5) * (u + 5), u, u, { dolgu: '#F7C98B', renk: PALET.siyah, kalinlik: 1.2 });
  }
  const alt = 'Taban bloklarıyla gösterilmiş bir sayı modeli: büyük kareler yüzlük, uzun çubuklar onluk, küçük kareler birliktir.';
  return { sahne: s, alt, olgular: { sayi: n, yuzluk: y, onluk: o, birlik: b, yuzler_basamak_degeri: y * 100, onlar_basamak_degeri: o * 10, birler_basamak_degeri: b } };
}

// ---------- 2) bölünmüş şekil (bütün, yarım, çeyrek, kesir, eş parça) ----------
// Tek şekil: { bicim:'dikdortgen'|'kare'|'daire', bolme:'dikey'|'yatay'|'izgara'|'capraz'|'dilim', n, tarali:[indeks], oranlar?:[...], bas_aci? }
// oranlar yoksa parçalar eştir. 'izgara' n=4 (2x2) ya da n=8 (4x2); 'capraz' n=2 (köşegen) ya da n=4 (kare, iki köşegen).
function bolunmusParcalar(q, kx, ky, kw, kh) {
  const { bicim, bolme, n } = q;
  const oran = q.oranlar ?? Array(n).fill(1 / n);
  if (oran.length !== n || Math.abs(oran.reduce((a, c) => a + c, 0) - 1) > 1e-9) hata('oranlar_toplami_1_degil');
  const esit = oran.every((r) => Math.abs(r - 1 / n) < 1e-9);
  let w = kw, h = kh;
  if (bicim === 'kare' || bicim === 'daire') { w = h = Math.min(kw, kh); }
  const x0 = kx + (kw - w) / 2, y0 = ky + (kh - h) / 2;
  const parcalar = [];
  if (bicim === 'daire') {
    if (bolme !== 'dilim') hata('daire_dilim_olmali');
    const bas = q.bas_aci ?? 90; let a = bas;
    oran.forEach((r) => { parcalar.push({ tur: 'dilim', cx: x0 + w / 2, cy: y0 + h / 2, r: w / 2, a0: a - 360 * r, a1: a }); a -= 360 * r; });
    return { parcalar, esit, w, h, x0, y0 };
  }
  if (bolme === 'dikey') { let x = x0; oran.forEach((r) => { parcalar.push({ tur: 'poli', pts: [[x, y0], [x + w * r, y0], [x + w * r, y0 + h], [x, y0 + h]] }); x += w * r; }); }
  else if (bolme === 'yatay') { let yy = y0; oran.forEach((r) => { parcalar.push({ tur: 'poli', pts: [[x0, yy], [x0 + w, yy], [x0 + w, yy + h * r], [x0, yy + h * r]] }); yy += h * r; }); }
  else if (bolme === 'izgara') {
    if (!esit || (n !== 4 && n !== 8)) hata('izgara_n_4_8_esit');
    const kol = n / 2, cw = w / kol, ch = h / 2;
    for (let i = 0; i < n; i++) { const c = i % kol, r = Math.floor(i / kol); parcalar.push({ tur: 'poli', pts: [[x0 + c * cw, y0 + r * ch], [x0 + (c + 1) * cw, y0 + r * ch], [x0 + (c + 1) * cw, y0 + (r + 1) * ch], [x0 + c * cw, y0 + (r + 1) * ch]] }); }
  } else if (bolme === 'capraz') {
    if (!esit) hata('capraz_esit_olmali');
    const A = [x0, y0], B = [x0 + w, y0], C = [x0 + w, y0 + h], D = [x0, y0 + h], M = [x0 + w / 2, y0 + h / 2];
    if (n === 2) { parcalar.push({ tur: 'poli', pts: [A, B, C] }, { tur: 'poli', pts: [A, C, D] }); }
    else if (n === 4 && bicim === 'kare') { parcalar.push({ tur: 'poli', pts: [A, B, M] }, { tur: 'poli', pts: [B, C, M] }, { tur: 'poli', pts: [C, D, M] }, { tur: 'poli', pts: [D, A, M] }); }
    else hata('capraz_n_2_ya_da_kare_4');
  } else hata(`bolme_bilinmiyor:${bolme}`);
  return { parcalar, esit, w, h, x0, y0 };
}
const TARAMA = PALET.turuncu;
function bolunmusCiz(s, q, kx, ky, kw, kh) {
  const r = bolunmusParcalar(q, kx, ky, kw, kh);
  const tarali = new Set(q.tarali ?? []);
  r.parcalar.forEach((pc, i) => {
    const dolgu = tarali.has(i) ? TARAMA : '#FFFFFF';
    if (pc.tur === 'dilim') s.dilim(pc.cx, pc.cy, pc.r, pc.a0, pc.a1, { dolgu, renk: PALET.siyah, kalinlik: 1.8 });
    else s.poligon(pc.pts, { dolgu, renk: PALET.siyah, kalinlik: 1.8 });
  });
  return r;
}
function bolunmus(p, profil) {
  if (!(p.n >= 2 && p.n <= 12)) hata('n_2_12');
  for (const i of p.tarali ?? []) if (!(i >= 0 && i < p.n)) hata('tarali_indeks_disi');
  const W = 250, H = 170, s = new Sahne(W, H, profil);
  const r = bolunmusCiz(s, p, 20, 15, W - 40, H - 30);
  const k = new Set(p.tarali ?? []).size;
  return { sahne: s, alt: 'Parçalara bölünmüş bir şekil; parçaların bir kısmı taralıdır.', olgular: { n: p.n, tarali: k, esit: r.esit, kesir: `${k}/${p.n}`, tarali_olmayan: p.n - k } };
}

// Dört şekil (A–D) yan yana: her biri ayrı bölünmüş şekil. parametreler: { paneller:[{bicim,bolme,n,oranlar?,tarali?}] }
function bolunmusDortlu(p, profil) {
  if (p.paneller.length !== 4) hata('panel_4_olmali');
  const W = 340, H = 250, s = new Sahne(W, H, profil), harf = 'ABCD', esit = {};
  p.paneller.forEach((q, i) => {
    const cx = 12 + (i % 2) * 164, cy = 10 + Math.floor(i / 2) * 120;
    s.metin(cx + 8, cy + 20, harf[i], { kalin: true, hiza: 'start' });
    const r = bolunmusCiz(s, q, cx + 30, cy + 8, 120, 92);
    esit[harf[i]] = r.esit;
  });
  const esitler = Object.keys(esit).filter((k) => esit[k]);
  return { sahne: s, alt: 'Harflerle adlandırılmış dört şekil; her biri parçalara bölünmüştür.', olgular: { esit, esit_harfler: esitler, parca_sayilari: Object.fromEntries(p.paneller.map((q, i) => [harf[i], q.n])) } };
}

// ---------- 3) analog saat ----------
// parametreler: { saat: 1..12, dakika: 0..59 }
function saatTipi(p, profil) {
  const h = p.saat, m = p.dakika;
  if (!(Number.isInteger(h) && h >= 1 && h <= 12 && Number.isInteger(m) && m >= 0 && m <= 59)) hata('saat_gecersiz');
  const W = 220, H = 220, cx = 110, cy = 110, R = 92, s = new Sahne(W, H, profil);
  s.cember(cx, cy, R, { kalinlik: 3, dolgu: '#FFFFFF' });
  for (let i = 0; i < 60; i++) {
    const a = aciRad(90 - i * 6), buyuk = i % 5 === 0, r1 = R - (buyuk ? 10 : 5);
    s.cizgi(cx + r1 * Math.cos(a), cy - r1 * Math.sin(a), cx + R * Math.cos(a), cy - R * Math.sin(a), { kalinlik: buyuk ? 2 : 0.9, izgara: true });
  }
  for (let k = 1; k <= 12; k++) {
    const a = aciRad(90 - k * 30);
    s.metin(cx + 70 * Math.cos(a), cy - 70 * Math.sin(a) + 6, String(k), { boyut: 18, kalin: true });
  }
  const ah = aciRad(90 - ((h % 12) * 30 + m * 0.5)), am = aciRad(90 - m * 6);
  s.cizgi(cx, cy, cx + 38 * Math.cos(ah), cy - 38 * Math.sin(ah), { kalinlik: 7, izgara: true });
  s.cizgi(cx, cy, cx + 58 * Math.cos(am), cy - 58 * Math.sin(am), { kalinlik: 3.5, izgara: true });
  s.nokta(cx, cy, { r: 5 });
  const mm = String(m).padStart(2, '0');
  return { sahne: s, alt: 'Akrep ve yelkovanı olan, 1’den 12’ye kadar sayılı bir analog saat.', olgular: { saat: h, dakika: m, dijital: `${h}:${mm}` } };
}

// ---------- 4) madeni ve kâğıt paralar ----------
// parametreler: { paralar:[{tur:'madeni'|'kagit', deger:kuruş}] }  madeni: 5,10,25,50,100; kağıt: 500,1000,2000 (kuruş cinsinden)
const MADENI = { 5: '5', 10: '10', 25: '25', 50: '50', 100: '1' };
const KAGIT_RENK = { 500: '#E3D2F0', 1000: '#F6C9C0', 2000: '#CDEBCF' };
function paraTipi(p, profil) {
  const liste = [...p.paralar].sort((a, b) => b.deger - a.deger);
  if (liste.length < 1 || liste.length > 9) hata('para_sayisi_1_9');
  const kagit = liste.filter((x) => x.tur === 'kagit'), madeni = liste.filter((x) => x.tur === 'madeni');
  for (const x of kagit) if (!KAGIT_RENK[x.deger]) hata(`kagit_deger:${x.deger}`);
  for (const x of madeni) if (!MADENI[x.deger]) hata(`madeni_deger:${x.deger}`);
  const W = 330, kr = Math.ceil(kagit.length / 3), mr = Math.ceil(madeni.length / 4);
  const H = 14 + kr * 68 + (kr && mr ? 6 : 0) + mr * 76 + 8;
  const s = new Sahne(W, H, profil);
  kagit.forEach((x, i) => {
    const bx = 12 + (i % 3) * 106, by = 14 + Math.floor(i / 3) * 68;
    s.dikdortgen(bx, by, 98, 56, { dolgu: KAGIT_RENK[x.deger], renk: PALET.siyah, kalinlik: 1.6 });
    s.dikdortgen(bx + 5, by + 5, 88, 46, { renk: GRI_CIZGI, kalinlik: 0.8 });
    s.metin(bx + 49, by + 36, `${x.deger / 100} TL`, { boyut: 22, kalin: true });
  });
  madeni.forEach((x, i) => {
    const cx = 44 + (i % 4) * 78, cy = 14 + kr * 68 + (kr ? 6 : 0) + Math.floor(i / 4) * 76 + 34;
    const tl = x.deger === 100;
    s.cember(cx, cy, 31, { dolgu: tl ? '#DCE3EB' : '#F1D88F', renk: PALET.siyah, kalinlik: tl ? 3 : 2 });
    s.metin(cx, cy - 3, MADENI[x.deger], { boyut: 22, kalin: true });
    s.metin(cx, cy + 17, tl ? 'TL' : 'kuruş', { boyut: 14 });
  });
  const sayilar = {}; let toplam = 0;
  for (const x of liste) { sayilar[x.deger] = (sayilar[x.deger] ?? 0) + 1; toplam += x.deger; }
  return { sahne: s, alt: 'Üzerinde değerleri yazılı madeni ve kâğıt paralar.', olgular: { toplam, sayilar, madeni_sayisi: madeni.length, kagit_sayisi: kagit.length } };
}

// ---------- 5) geometrik cisimler ----------
// parametreler: { duzen:'tek'|'panel'|'grup', turler:[...], renkler?:[0..4] }  panel: 4 cisim (A–D); grup: 2..12 cisim.
const CISIM_AD = { kup: 'küp', prizma: 'dikdörtgenler prizması', ucgenprizma: 'üçgen prizma', piramit: 'kare piramit', silindir: 'silindir', koni: 'koni', kure: 'küre' };
const CISIM_OZ = {
  kup: { kose: 8, yuz: 6, ayrit: 12 }, prizma: { kose: 8, yuz: 6, ayrit: 12 },
  ucgenprizma: { kose: 6, yuz: 5, ayrit: 9 }, piramit: { kose: 5, yuz: 5, ayrit: 8 }, kure: { kose: 0, yuz: null, ayrit: 0 },
};
const CISIM_RENK = ['#8EC5E8', '#F2B84B', '#9AD3B5', '#E8A5C5', '#C9B8E8'];
const mix = (h, t, hedef) => { const d = hedef === 'b' ? 255 : 0; return '#' + [1, 3, 5].map((i) => Math.round(parseInt(h.slice(i, i + 2), 16) * (1 - t) + d * t).toString(16).padStart(2, '0')).join(''); };
const gizli = (s, x1, y1, x2, y2) => s.cizgi(x1, y1, x2, y2, { kalinlik: 1.2, kesik: true, izgara: true });

function cisimCiz(s, tur, bx, by, bw, bh, renk) {
  const m = Math.min(bw * 0.9, bh * 0.9), acik = mix(renk, 0.45, 'b'), koyu = mix(renk, 0.25, 'k'), cx = bx + bw / 2, cy = by + bh / 2;
  const kutu = (w, h, k) => {
    const x = cx - (w + k) / 2, y = cy - (h + k) / 2 + k;
    const F = [[x, y], [x + w, y], [x + w, y + h], [x, y + h]], B = F.map(([a, b]) => [a + k, b - k]);
    poly(s, [F[0], F[1], B[1], B[0]], { dolgu: acik }); poly(s, [F[1], F[2], B[2], B[1]], { dolgu: koyu }); poly(s, F, { dolgu: renk });
    gizli(s, F[3][0], F[3][1], B[3][0], B[3][1]); gizli(s, B[3][0], B[3][1], B[2][0], B[2][1]); gizli(s, B[3][0], B[3][1], B[0][0], B[0][1]);
  };
  if (tur === 'kup') { const u = m * 0.66; kutu(u, u, u * 0.38); }
  else if (tur === 'prizma') { const u = m / 1.95; kutu(1.5 * u, 0.62 * u, 0.4 * u); }
  else if (tur === 'ucgenprizma') {
    const w = m * 0.7, h = w * 0.78, k = w * 0.3, x = cx - (w + k) / 2, y = cy - (h + k) / 2 + k;
    const A = [x, y + h], B = [x + w, y + h], C = [x + w / 2, y], A2 = [A[0] + k, A[1] - k], B2 = [B[0] + k, B[1] - k], C2 = [C[0] + k, C[1] - k];
    poly(s, [A, C, C2, A2], { dolgu: acik }); poly(s, [C, B, B2, C2], { dolgu: koyu }); poly(s, [A, B, C], { dolgu: renk });
    gizli(s, A[0], A[1], A2[0], A2[1]); gizli(s, A2[0], A2[1], B2[0], B2[1]);
  } else if (tur === 'piramit') {
    const w = m * 0.62, k = w * 0.4, H = m * 0.62, x = cx - (w + k) / 2, yb = cy + (H + k) / 2 - k / 2 + 2;
    const P0 = [x, yb], P1 = [x + w, yb], P2 = [x + w + k, yb - k], P3 = [x + k, yb - k], Q = [x + (w + k) / 2, yb - k / 2 - H];
    poly(s, [P1, P2, Q], { dolgu: koyu }); poly(s, [P0, P1, Q], { dolgu: renk });
    gizli(s, P3[0], P3[1], P0[0], P0[1]); gizli(s, P3[0], P3[1], P2[0], P2[1]); gizli(s, P3[0], P3[1], Q[0], Q[1]);
  } else if (tur === 'silindir') {
    const rx = m * 0.3, ry = rx * 0.32, t = cy - m * 0.34, b = cy + m * 0.34;
    yolEkle(s, `M${yv(cx - rx)} ${yv(t)}V${yv(b)}A${yv(rx)} ${yv(ry)} 0 0 0 ${yv(cx + rx)} ${yv(b)}V${yv(t)}Z`, [[cx - rx, t - ry], [cx + rx, b + ry]], { dolgu: renk, kalinlik: 1.6 });
    elips(s, cx, t, rx, ry, { dolgu: acik, kalinlik: 1.6 });
  } else if (tur === 'koni') {
    const rx = m * 0.32, ry = rx * 0.32, t = cy - m * 0.42, b = cy + m * 0.3;
    yolEkle(s, `M${yv(cx)} ${yv(t)}L${yv(cx - rx)} ${yv(b)}A${yv(rx)} ${yv(ry)} 0 0 0 ${yv(cx + rx)} ${yv(b)}Z`, [[cx, t], [cx - rx, b + ry], [cx + rx, b + ry]], { dolgu: renk, kalinlik: 1.6 });
    yolEkle(s, `M${yv(cx - rx)} ${yv(b)}A${yv(rx)} ${yv(ry)} 0 0 1 ${yv(cx + rx)} ${yv(b)}`, [[cx - rx, b], [cx + rx, b]], { kalinlik: 1.2, kesik: true });
  } else if (tur === 'kure') {
    const r = m * 0.4;
    s.cember(cx, cy, r, { dolgu: renk, renk: PALET.siyah, kalinlik: 1.6 });
    s.cember(cx - r * 0.35, cy - r * 0.35, r * 0.2, { dolgu: acik, renk: acik, kalinlik: 0.5 });
  } else hata(`cisim_bilinmiyor:${tur}`);
}
function cisimler(p, profil) {
  const turler = p.turler, rk = (i) => CISIM_RENK[(p.renkler?.[i] ?? i) % CISIM_RENK.length];
  const olgular = { turler: {}, ad: {}, kose: {}, yuz: {}, ayrit: {}, sayilar: {} };
  let s;
  if (p.duzen === 'tek') {
    if (turler.length !== 1) hata('tek_cisim');
    s = new Sahne(220, 170, profil); cisimCiz(s, turler[0], 10, 8, 200, 154, rk(0));
  } else if (p.duzen === 'panel') {
    if (turler.length !== 4) hata('panel_4_olmali');
    s = new Sahne(340, 250, profil);
    turler.forEach((t, i) => {
      const cx = 10 + (i % 2) * 165, cy = 8 + Math.floor(i / 2) * 120;
      s.metin(cx + 8, cy + 22, 'ABCD'[i], { kalin: true, hiza: 'start' });
      cisimCiz(s, t, cx + 28, cy + 4, 128, 108, rk(i));
    });
  } else if (p.duzen === 'grup') {
    if (turler.length < 2 || turler.length > 12) hata('grup_2_12');
    const satir = Math.ceil(turler.length / 4); s = new Sahne(340, satir * 84 + 8, profil);
    turler.forEach((t, i) => cisimCiz(s, t, 8 + (i % 4) * 82, 6 + Math.floor(i / 4) * 84, 80, 80, rk(i)));
  } else hata(`duzen_bilinmiyor:${p.duzen}`);
  turler.forEach((t, i) => {
    const k = p.duzen === 'panel' ? 'ABCD'[i] : String(i);
    olgular.turler[k] = t; olgular.ad[k] = CISIM_AD[t] ?? hata(`cisim_bilinmiyor:${t}`);
    const oz = CISIM_OZ[t]; olgular.kose[k] = oz ? oz.kose : null; olgular.yuz[k] = oz ? oz.yuz : null; olgular.ayrit[k] = oz ? oz.ayrit : null;
    olgular.sayilar[t] = (olgular.sayilar[t] ?? 0) + 1;
  });
  olgular.kose8 = turler.filter((t) => CISIM_OZ[t]?.kose === 8).length;
  return { sahne: s, alt: p.duzen === 'tek' ? 'Bir geometrik cisim çizimi.' : 'Geometrik cisim çizimleri.', olgular };
}

// ---------- 6) çokgen grubu (kenar sayısına göre) ----------
// parametreler: { duzen:'tek'|'panel'|'grup', siralar:[{n, tohum, duzgun?}] }  Köşeler çember üzerinde, açıları oynatılmış (dışbükey, düzgün olmayan) çokgenler.
const COKGEN_AD = { 3: 'üçgen', 4: 'dörtgen', 5: 'beşgen', 6: 'altıgen', 7: 'yedigen', 8: 'sekizgen' };
const CK_RENK = ['#BDE5D2', '#F7D9A0', '#CFE8F8', '#F3C9DC', '#DAD2F0'];
function cokgenKoseleri(q, cx, cy, r) {
  const rnd = LCG(q.tohum ?? 1), adim = 360 / q.n, ba = rnd() * 360;
  const pts = [];
  for (let i = 0; i < q.n; i++) {
    const j = q.duzgun ? 0 : (rnd() - 0.5) * 0.5 * adim;
    const a = aciRad(ba + i * adim + j);
    pts.push([cx + r * Math.cos(a), cy - r * Math.sin(a)]);
  }
  return pts;
}
function cokgenGrubu(p, profil) {
  for (const q of p.siralar) if (!(q.n >= 3 && q.n <= 8)) hata('n_3_8');
  const olgular = { kenar: {}, ad: {}, sayilar: {} }; let s;
  if (p.duzen === 'tek') {
    s = new Sahne(220, 180, profil);
    poly(s, cokgenKoseleri(p.siralar[0], 110, 90, 68), { dolgu: CK_RENK[(p.siralar[0].tohum ?? 0) % 5] });
  } else if (p.duzen === 'panel') {
    if (p.siralar.length !== 4) hata('panel_4_olmali');
    s = new Sahne(340, 250, profil);
    p.siralar.forEach((q, i) => {
      const cx = 10 + (i % 2) * 165, cy = 8 + Math.floor(i / 2) * 120;
      s.metin(cx + 8, cy + 22, 'ABCD'[i], { kalin: true, hiza: 'start' });
      poly(s, cokgenKoseleri(q, cx + 95, cy + 60, 46), { dolgu: CK_RENK[i] });
    });
  } else if (p.duzen === 'grup') {
    if (p.siralar.length < 3 || p.siralar.length > 12) hata('grup_3_12');
    s = new Sahne(340, Math.ceil(p.siralar.length / 4) * 84 + 8, profil);
    p.siralar.forEach((q, i) => poly(s, cokgenKoseleri(q, 48 + (i % 4) * 82, 46 + Math.floor(i / 4) * 84, 34), { dolgu: CK_RENK[i % 5] }));
  } else hata(`duzen_bilinmiyor:${p.duzen}`);
  p.siralar.forEach((q, i) => {
    const k = p.duzen === 'panel' ? 'ABCD'[i] : String(i);
    olgular.kenar[k] = q.n; olgular.ad[k] = COKGEN_AD[q.n]; olgular.sayilar[q.n] = (olgular.sayilar[q.n] ?? 0) + 1;
  });
  return { sahne: s, alt: p.duzen === 'tek' ? 'Bir çokgen şekil.' : 'Çokgen şekiller.', olgular };
}

// ---------- 7) simetri doğrusu ----------
// parametreler: { paneller:[{ pts:[[x,y]…] (şekil köşeleri), cizgi?:[[x1,y1],[x2,y2]] }] }  1–4 şekil; çözücü yansıtarak denetler.
const yansit = (P, a, b) => { const dx = b[0] - a[0], dy = b[1] - a[1], L = dx * dx + dy * dy, t = ((P[0] - a[0]) * dx + (P[1] - a[1]) * dy) / L; const fx = a[0] + t * dx, fy = a[1] + t * dy; return [2 * fx - P[0], 2 * fy - P[1]]; };
const ayniKume = (A, B) => A.every((p) => B.some((q) => Math.hypot(p[0] - q[0], p[1] - q[1]) < 1e-6)) && B.every((p) => A.some((q) => Math.hypot(p[0] - q[0], p[1] - q[1]) < 1e-6));
function simetriDogruSayisi(pts) {
  const n = pts.length, c = [pts.reduce((t, q) => t + q[0], 0) / n, pts.reduce((t, q) => t + q[1], 0) / n], acilar = [];
  const aday = [...pts.map((q) => [q[0] - c[0], q[1] - c[1]]), ...pts.map((q, i) => { const r = pts[(i + 1) % n]; return [(q[0] + r[0]) / 2 - c[0], (q[1] + r[1]) / 2 - c[1]]; })];
  for (const v of aday) {
    if (Math.hypot(v[0], v[1]) < 1e-9) continue;
    const a = Math.atan2(v[1], v[0]), b = [c[0] + Math.cos(a), c[1] + Math.sin(a)];
    if (ayniKume(pts.map((q) => yansit(q, c, b)), pts)) { const k = ((a % Math.PI) + Math.PI) % Math.PI; if (!acilar.some((x) => Math.abs(x - k) < 1e-6 || Math.abs(Math.abs(x - k) - Math.PI) < 1e-6)) acilar.push(k); }
  }
  return acilar.length;
}
function simetri(p, profil) {
  const N = p.paneller.length; if (N < 1 || N > 4) hata('panel_1_4');
  const tek = N === 1, W = tek ? 220 : 340, H = tek ? 180 : N > 2 ? 250 : 130, s = new Sahne(W, H, profil), olgular = { gecerli: {}, simetri_sayisi: {} };
  p.paneller.forEach((q, i) => {
    const ox = tek ? 10 : 10 + (i % 2) * 165, oy = tek ? 8 : 8 + Math.floor(i / 2) * 120, cw = tek ? 200 : 150, ch = tek ? 164 : 108;
    const xs = q.pts.map((t) => t[0]), ys = q.pts.map((t) => t[1]), mnx = Math.min(...xs), mxx = Math.max(...xs), mny = Math.min(...ys), mxy = Math.max(...ys);
    const sc = Math.min((cw - 40) / (mxx - mnx), (ch - 34) / (mxy - mny)), dx = ox + (cw - sc * (mxx - mnx)) / 2 - sc * mnx + (tek ? 0 : 10), dy = oy + (ch - sc * (mxy - mny)) / 2 - sc * mny + (tek ? 0 : 6);
    const T = (t) => [t[0] * sc + dx, t[1] * sc + dy];
    if (!tek) s.metin(ox + 8, oy + 22, 'ABCD'[i], { kalin: true, hiza: 'start' });
    poly(s, q.pts.map(T), { dolgu: CK_RENK[i % 5] });
    const k = tek ? '0' : 'ABCD'[i];
    olgular.simetri_sayisi[k] = simetriDogruSayisi(q.pts);
    if (q.cizgi) {
      const [a, b] = q.cizgi, ux = b[0] - a[0], uy = b[1] - a[1], e = 0.18;
      const A = T([a[0] - ux * e, a[1] - uy * e]), B = T([b[0] + ux * e, b[1] + uy * e]);
      s.cizgi(A[0], A[1], B[0], B[1], { renk: PALET.kirmizi, kalinlik: 2.4, kesik: true, izgara: true });
      olgular.gecerli[k] = ayniKume(q.pts.map((t) => yansit(t, a, b)), q.pts);
    }
  });
  return { sahne: s, alt: 'Şekiller ve üzerlerinde kesikli çizgiler.', olgular };
}

// ---------- 8) kareli zeminde simetri ----------
// parametreler: { kol, satir, eksen:'dikey'|'yatay', boyali:[[c,r]…], hedef?:[c,r], harfler?:{A:[c,r],…} }
// Eksen dikey ise sütunlar ortadan yansır: (c,r)->(kol-1-c, r); yatay ise (c,r)->(c, satir-1-r).
function simetriKareli(p, profil) {
  const { kol, satir, eksen } = p, kare = 36, m = 12, W = kol * kare + 2 * m, H = satir * kare + 2 * m, s = new Sahne(W, H, profil);
  if (eksen === 'dikey' && kol % 2) hata('kol_cift_olmali'); if (eksen === 'yatay' && satir % 2) hata('satir_cift_olmali');
  const ya = ([c, r]) => (eksen === 'dikey' ? [kol - 1 - c, r] : [c, satir - 1 - r]);
  const boy = new Set(p.boyali.map((q) => q.join(',')));
  const yarimda = ([c, r]) => (eksen === 'dikey' ? c < kol / 2 : r < satir / 2);
  for (const q of p.boyali) if (!yarimda(q)) hata('boyali_ilk_yarida_olmali');
  for (let c = 0; c < kol; c++) for (let r = 0; r < satir; r++) s.dikdortgen(m + c * kare, m + r * kare, kare, kare, { dolgu: boy.has(`${c},${r}`) ? '#9ED0EE' : '#FFFFFF', renk: GRI_CIZGI, kalinlik: 0.8 });
  if (eksen === 'dikey') s.cizgi(m + (kol * kare) / 2, m - 6, m + (kol * kare) / 2, m + satir * kare + 6, { renk: PALET.kirmizi, kalinlik: 2.6, kesik: true, izgara: true });
  else s.cizgi(m - 6, m + (satir * kare) / 2, m + kol * kare + 6, m + (satir * kare) / 2, { renk: PALET.kirmizi, kalinlik: 2.6, kesik: true, izgara: true });
  const mrk = (q) => [m + q[0] * kare + kare / 2, m + q[1] * kare + kare / 2];
  if (p.hedef) { if (!boy.has(p.hedef.join(','))) hata('hedef_boyali_degil'); const [x, y] = mrk(p.hedef); s.nokta(x, y, { r: 7 }); }
  const harfKonum = {};
  for (const [h, q] of Object.entries(p.harfler ?? {})) { if (yarimda(q) || boy.has(q.join(','))) hata('harf_diger_yarida_olmali'); const [x, y] = mrk(q); s.metin(x, y + 7, h, { kalin: true }); harfKonum[h] = q; }
  const olgular = { boyali_sayisi: p.boyali.length, tamamlanan_boyali: p.boyali.length * 2 };
  if (p.hedef) { const e = ya(p.hedef); olgular.es_harf = Object.keys(harfKonum).find((h) => harfKonum[h][0] === e[0] && harfKonum[h][1] === e[1]) ?? null; }
  return { sahne: s, alt: 'Kareli zeminde boyanmış kareler ve kırmızı kesikli bir simetri doğrusu.', olgular };
}

// ---------- 9) ızgara harita (yer ve yön) ----------
// parametreler: { kol, satir, yerler:[{ad, c, r}] }  c sağa, r aşağı; yukarı = sayfanın üstü.
function izgaraYol(p, profil) {
  const k = 62, m = 12, W = p.kol * k + 2 * m, H = p.satir * k + 2 * m, s = new Sahne(W, H, profil), olgular = { yerler: {} };
  for (let c = 0; c < p.kol; c++) for (let r = 0; r < p.satir; r++) s.dikdortgen(m + c * k, m + r * k, k, k, { renk: PALET.gri, kalinlik: 0.8 });
  const gorulen = new Set();
  for (const y of p.yerler) {
    if (y.c < 0 || y.c >= p.kol || y.r < 0 || y.r >= p.satir) hata(`yer_disi:${y.ad}`);
    if (gorulen.has(`${y.c},${y.r}`)) hata('yer_cakisma'); gorulen.add(`${y.c},${y.r}`);
    s.dikdortgen(m + y.c * k + 4, m + y.r * k + 4, k - 8, k - 8, { dolgu: y.ad === 'Ev' ? '#F7D9A0' : '#DDEFF9', renk: PALET.siyah, kalinlik: 1.6 });
    s.metin(m + y.c * k + k / 2, m + y.r * k + k / 2 + 5, y.ad, { boyut: 16, kalin: true });
    olgular.yerler[y.ad] = [y.c, y.r];
  }
  return { sahne: s, alt: 'Kareli bir haritada adları yazılı yerler.', olgular };
}

// ---------- 10) resimli grafik (piktogram) ----------
// parametreler: { baslik, kategoriler:[{ad, sayi}], birim:1|2, birimAd }  Her simge `birim` kadar nesneyi gösterir.
function piktogram(p, profil) {
  const n = p.kategoriler.length; if (n < 2 || n > 5) hata('kategori_2_5');
  const W = 400, H = 50 + n * 34 + 40, s = new Sahne(W, H, profil), degerler = {};
  s.metin(W / 2, 28, p.baslik, { kalin: true });
  p.kategoriler.forEach((k, i) => {
    if (k.sayi < 1 || k.sayi > 10) hata('simge_1_10');
    const y = 50 + i * 34 + 17;
    s.metin(12, y + 5, k.ad, { hiza: 'start', boyut: 16 });
    for (let j = 0; j < k.sayi; j++) s.cember(118 + j * 27, y, 10, { dolgu: PALET.gok, renk: PALET.siyah, kalinlik: 1.3 });
    degerler[k.ad] = k.sayi * p.birim;
  });
  const ly = H - 22;
  s.cember(24, ly, 10, { dolgu: PALET.gok, renk: PALET.siyah, kalinlik: 1.3 });
  s.metin(42, ly + 5, `= ${p.birim} ${p.birimAd}`, { hiza: 'start', boyut: 16 });
  const v = Object.entries(degerler), mx = Math.max(...v.map(([, x]) => x)), mn = Math.min(...v.map(([, x]) => x));
  const tekil = (h) => { const e = v.filter(([, x]) => x === h); return e.length === 1 ? e[0][0] : null; };
  return { sahne: s, alt: `Resimli grafik: ${p.baslik}. Her simge bir miktarı gösterir.`, olgular: { degerler, en_cok: tekil(mx), en_az: tekil(mn), toplam: v.reduce((t, [, x]) => t + x, 0) } };
}

// ---------- 11) çetele tablosu ----------
// parametreler: { baslik, kategoriler:[{ad, sayi}] }  Beşli gruplar: dört çizgi + bir çapraz çizgi.
function cetele(p, profil) {
  const n = p.kategoriler.length; if (n < 2 || n > 5) hata('kategori_2_5');
  const W = 360, H = 50 + n * 40 + 12, s = new Sahne(W, H, profil), degerler = {};
  s.metin(W / 2, 28, p.baslik, { kalin: true });
  s.dikdortgen(8, 40, W - 16, n * 40 + 4, { renk: PALET.siyah, kalinlik: 1.6 });
  s.cizgi(112, 40, 112, 40 + n * 40 + 4, { kalinlik: 1.2, izgara: true });
  p.kategoriler.forEach((k, i) => {
    if (k.sayi < 1 || k.sayi > 20) hata('cetele_1_20');
    const y0 = 44 + i * 40;
    if (i) s.cizgi(8, y0 - 2, W - 8, y0 - 2, { kalinlik: 0.8, izgara: true });
    s.metin(18, y0 + 25, k.ad, { hiza: 'start', boyut: 16 });
    let x = 126;
    for (let kalan = k.sayi; kalan > 0; kalan -= 5) {
      const t = Math.min(5, kalan);
      for (let j = 0; j < Math.min(4, t); j++) s.cizgi(x + j * 7, y0 + 6, x + j * 7, y0 + 30, { kalinlik: 2.4, izgara: true });
      if (t === 5) s.cizgi(x - 4, y0 + 27, x + 25, y0 + 9, { kalinlik: 2.4, izgara: true });
      x += 42;
    }
    degerler[k.ad] = k.sayi;
  });
  const v = Object.entries(degerler), mx = Math.max(...v.map(([, x]) => x)), mn = Math.min(...v.map(([, x]) => x));
  const tekil = (h) => { const e = v.filter(([, x]) => x === h); return e.length === 1 ? e[0][0] : null; };
  return { sahne: s, alt: `Çetele tablosu: ${p.baslik}. Her satırda bir kategorinin çetele işaretleri vardır.`, olgular: { degerler, en_cok: tekil(mx), en_az: tekil(mn), toplam: v.reduce((t, [, x]) => t + x, 0) } };
}

// ---------- 12) yüzlük tablo ve ritmik sayma ----------
// parametreler: { satir:1..10, adim, terim }  1..satir*10 sayıları; adim'in ilk `terim` katı boyalıdır.
function yuzluk(p, profil) {
  const { satir, adim, terim } = p; if (!(satir >= 1 && satir <= 10 && adim >= 2 && terim >= 3)) hata('yuzluk_parametre');
  if ((terim + 1) * adim > satir * 10) hata('sonraki_tablo_disi');
  const c = 32, rh = 30, m = 12, W = 10 * c + 2 * m, H = satir * rh + 2 * m, s = new Sahne(W, H, profil), boyali = [];
  for (let r = 0; r < satir; r++) for (let k = 0; k < 10; k++) {
    const v = r * 10 + k + 1, b = v % adim === 0 && v <= terim * adim;
    if (b) boyali.push(v);
    s.dikdortgen(m + k * c, m + r * rh, c, rh, { dolgu: b ? '#F2C46D' : '#FFFFFF', renk: GRI_CIZGI, kalinlik: 0.8 });
    s.metin(m + k * c + c / 2, m + r * rh + 21, String(v), { boyut: 15, kalin: b });
  }
  return { sahne: s, alt: 'Sayıları sıralı yazılmış bir tablo; bazı kareler boyanmıştır.', olgular: { adim, boyali, son_boyali: terim * adim, sonraki: (terim + 1) * adim } };
}

// ---------- 13) büyüyen kare örüntüsü ----------
// parametreler: { sira, ek }  n. adımda: her biri n kareli `sira` satır + soldaki `ek` karelik sütun = sira*n + ek kare.
function oruntuKare(p, profil) {
  const { sira: r, ek: e } = p; if (!(r >= 1 && r <= 4 && e >= 1 && e <= 3)) hata('oruntu_parametre');
  const u = 17, W = 360, s = new Sahne(W, 140, profil); let x0 = 14; const baz = 96;
  for (let n = 1; n <= 3; n++) {
    for (let i = 0; i < e; i++) s.dikdortgen(x0, baz - (i + 1) * u, u, u, { dolgu: '#F7C98B', renk: PALET.siyah, kalinlik: 1.2 });
    for (let a = 0; a < r; a++) for (let b = 0; b < n; b++) s.dikdortgen(x0 + u + 3 + b * u, baz - (a + 1) * u, u, u, { dolgu: '#9ED0EE', renk: PALET.siyah, kalinlik: 1.2 });
    const gen = u + 3 + n * u;
    s.metin(x0 + gen / 2, baz + 28, `${n}. adım`, { boyut: 15 });
    x0 += gen + 36;
  }
  const kare = {}; for (let n = 1; n <= 20; n++) kare[n] = r * n + e;
  return { sahne: s, alt: 'Karelerden oluşan, adım adım büyüyen bir örüntünün ilk üç adımı.', olgular: { kare, artis: r } };
}

// ---------- 14) kareli zeminde şekil ve çevre ----------
// parametreler: { kol, satir, hucreler:[[c,r]…] }  Birim karelerin birleşimi; çevre = dış kenarların sayısı.
function kareliCevre(p, profil) {
  const k = 30, m = 12, W = p.kol * k + 2 * m, H = p.satir * k + 2 * m, s = new Sahne(W, H, profil);
  const dolu = new Set(p.hucreler.map((q) => q.join(',')));
  for (const [c, r] of p.hucreler) if (c < 0 || c >= p.kol || r < 0 || r >= p.satir) hata('hucre_disi');
  for (let c = 0; c < p.kol; c++) for (let r = 0; r < p.satir; r++) s.dikdortgen(m + c * k, m + r * k, k, k, { dolgu: dolu.has(`${c},${r}`) ? '#9ED0EE' : '#FFFFFF', renk: GRI_CIZGI, kalinlik: 0.8 });
  let cevre = 0;
  for (const [c, r] of p.hucreler) for (const [dc, dr] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
    if (dolu.has(`${c + dc},${r + dr}`)) continue; cevre += 1;
    const x = m + c * k, y = m + r * k;
    if (dc === 1) s.cizgi(x + k, y, x + k, y + k, { kalinlik: 3, izgara: true }); else if (dc === -1) s.cizgi(x, y, x, y + k, { kalinlik: 3, izgara: true });
    else if (dr === 1) s.cizgi(x, y + k, x + k, y + k, { kalinlik: 3, izgara: true }); else s.cizgi(x, y, x + k, y, { kalinlik: 3, izgara: true });
  }
  return { sahne: s, alt: 'Kareli zeminde boyanmış karelerden oluşan bir şekil.', olgular: { cevre, alan: p.hucreler.length } };
}

export const TIPLER_A1 = {
  'a1-izgara-yol': izgaraYol,
  'a1-piktogram': piktogram,
  'a1-cetele': cetele,
  'a1-yuzluk': yuzluk,
  'a1-oruntu-kare': oruntuKare,
  'a1-kareli-cevre': kareliCevre,
  'a1-taban-blok': tabanBlok,
  'a1-bolunmus': bolunmus,
  'a1-bolunmus-dortlu': bolunmusDortlu,
  'a1-saat': saatTipi,
  'a1-para': paraTipi,
  'a1-cisimler': cisimler,
  'a1-cokgen-grubu': cokgenGrubu,
  'a1-simetri': simetri,
  'a1-simetri-kareli': simetriKareli,
};
void LCG; void elips; void poly;
