// Ajan B2 için şekil tipleri (Fen Bilimleri 4, 6, 7, 8; Hayat Bilgisi 2, 3). Sözleşme: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'b2-' önekiyle. Şablonlar için ortak şık yardımcıları da buradan dışa aktarılır.
import { Sahne, PALET, aciRad } from './cekirdek.mjs';
import { TIPLER_A5 } from './tipler-a5.mjs';

const hata = (m) => { throw new Error(m); };
const r1 = (n) => Math.round(n * 10) / 10;
const sin = (d) => Math.sin(aciRad(d)), cos = (d) => Math.cos(aciRad(d));
const KOYU = '#374151', ACIK = '#E5E7EB', SU = '#BFE3F5', SARI = '#F6D860', TURUNCU_AC = '#F6C177';
const kesik = (s, x1, y1, x2, y2, renk = PALET.gri) => s.cizgi(x1, y1, x2, y2, { renk, kalinlik: 1.2, kesik: true, izgara: true });
function yol(s, d, { dolgu = 'none', renk = PALET.siyah, kalinlik = 1.5, noktalar = [] } = {}) {
  for (const [x, y] of noktalar) s.noktalar.push([x, y, 0]);
  s.parcalar.push(`<path d="${d}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${kalinlik}" stroke-linejoin="round" stroke-linecap="round"/>`);
}

// ---------- şablonlar için şık yardımcıları ----------
// Artan sıralı `liste` içinden doğru olanı (dogruIdx) k. sıraya koyacak 4 indeks seçer (k küçük, 3-k büyük aday). Doğru şık hep k. konumda olur.
export function pencereSik(liste, dogruIdx, k, R, tercih = []) {
  const alt = [], ust = [];
  liste.forEach((_, i) => { if (i < dogruIdx) alt.push(i); else if (i > dogruIdx) ust.push(i); });
  if (dogruIdx < 0 || alt.length < k || ust.length < 3 - k) throw new Error('sik_uretilemedi');
  const kar = (a) => { const b = [...a]; for (let i = b.length - 1; i > 0; i--) { const j = Math.floor(R() * (i + 1)); [b[i], b[j]] = [b[j], b[i]]; } return b; };
  const al = (havuz, n) => {
    if (n === 0) return [];
    const t = kar(havuz.filter((i) => tercih.includes(i))), d = kar(havuz.filter((i) => !tercih.includes(i)));
    const tn = Math.min(t.length, n, R() < 0.5 ? 1 : 2);
    const sonuc = [...t.slice(0, tn), ...d.slice(0, n - tn)];
    for (const x of t.slice(tn)) if (sonuc.length < n) sonuc.push(x);
    return sonuc.sort((a, b) => a - b);
  };
  return [...al(alt, k), dogruIdx, ...al(ust, 3 - k)];
}
const fmtTr = (v) => String(Math.round(v * 100) / 100).replace('.', ',');
// Sayısal şıklar: artan sıralı, doğru k. sırada. tercih: yaygın yanılgıların sayısal sonuçları (önce bunlardan seçilir).
export function sayiSik(dogru, k, R, { min = 0, max = 1e9, adim = 1, genislik = 4, tercih = [], bicim = fmtTr } = {}) {
  const kume = new Set();
  for (let j = -genislik; j <= genislik; j++) { const v = Math.round((dogru + j * adim) * 1000) / 1000; if (v >= min && v <= max) kume.add(v); }
  const tc = tercih.map((t) => Math.round(t * 1000) / 1000).filter((t) => t >= min && t <= max);
  tc.forEach((t) => kume.add(t));
  const liste = [...kume].sort((a, b) => a - b), di = liste.indexOf(Math.round(dogru * 1000) / 1000);
  const tIdx = tc.map((t) => liste.indexOf(t)).filter((i) => i >= 0 && i !== di);
  const idx = pencereSik(liste, di, k, R, tIdx);
  return { degerler: idx.map((i) => liste[i]), sirali: idx.map((i) => bicim(liste[i])) };
}

// ---------- 1) Güneş–Dünya: gece/gündüz ----------
// parametreler: { noktalar:[{ad, aci}] }  aci: Güneş soldadır (180°); matematik yönü derece. Gündüz: cos(aci) < 0.
function dunya(p, profil) {
  const W = 360, H = 246, cx = 244, cy = 118, R = 70, s = new Sahne(W, H, profil);
  s.cember(40, cy, 26, { dolgu: SARI, renk: '#B45309', kalinlik: 2 });
  s.metin(40, cy + 50, 'Güneş', { boyut: 14 });
  for (const dy of [-38, 0, 38]) s.cizgi(78, cy + dy, 146, cy + dy, { renk: '#B45309', kalinlik: 1.8, ok: true, izgara: true });
  s.dilim(cx, cy, R, 90, 270, { dolgu: '#CFE8F6', kalinlik: 2 });
  s.dilim(cx, cy, R, -90, 90, { dolgu: '#6B7280', kalinlik: 2 });
  const durum = {};
  for (const n of p.noktalar) {
    const a = ((n.aci % 360) + 360) % 360;
    if (Math.abs(cos(a)) < 0.3) hata('sinira_yakin_nokta');
    s.cember(cx + R * cos(a), cy - R * sin(a), 6, { dolgu: '#FFFFFF', kalinlik: 2 });
    s.metin(cx + (R + 22) * cos(a), cy - (R + 22) * sin(a) + 5, n.ad, { kalin: true, boyut: 16 });
    durum[n.ad] = cos(a) < 0 ? 'gunduz' : 'gece';
  }
  s.metin(cx, cy + R + 44, 'Dünya', { boyut: 14 });
  const gunduz = p.noktalar.filter((n) => durum[n.ad] === 'gunduz');
  const yakin = [...p.noktalar].sort((a, b) => Math.abs(((a.aci % 360) + 360) % 360 - 180) - Math.abs(((b.aci % 360) + 360) % 360 - 180));
  const en_isik = yakin.length > 1 && Math.abs(((yakin[0].aci % 360) + 360) % 360 - 180) === Math.abs(((yakin[1].aci % 360) + 360) % 360 - 180) ? null : yakin[0].ad;
  return { sahne: s, alt: 'Solda Güneş, sağında Dünya; Dünya’nın Güneş’e bakan yarısı açık, karşı yarısı koyu renklidir. Dünya yüzeyinde harfli noktalar vardır.', olgular: { durum, gunduz_sayisi: gunduz.length, en_isik } };
}

// ---------- 2) cisme etki eden yatay kuvvetler ----------
// parametreler: { cisimler:[{ad, sol, sag}] } kuvvetler N (0 ya da 10..40, 5'in katı); sol: cismi sola çeken, sag: sağa çeken.
function kuvvet(p, profil) {
  const n = p.cisimler.length; if (n < 1 || n > 4) hata('cisim_sayisi_1_4');
  const W = 360, ph = n === 1 ? 96 : 74, H = ph * n + 8, cx = 180, bw = 46, bh = 34, olcek = 3.6, s = new Sahne(W, H, profil);
  const olgular = { net: {}, yon: {}, dengeli: {}, sol: {}, sag: {} };
  p.cisimler.forEach((c, i) => {
    for (const v of [c.sol, c.sag]) if (!(v === 0 || (v >= 10 && v <= 40 && v % 5 === 0))) hata('kuvvet_degeri');
    const cy = ph * i + ph / 2 + 4;
    s.cizgi(10, cy + bh / 2 + 1, 350, cy + bh / 2 + 1, { renk: PALET.gri, kalinlik: 1.5, izgara: true });
    s.dikdortgen(cx - bw / 2, cy - bh / 2, bw, bh, { dolgu: '#FDE68A', kalinlik: 2 });
    s.metin(cx, cy + 6, c.ad, { kalin: true, boyut: 17 });
    for (const [deger, yon] of [[c.sol, -1], [c.sag, 1]]) {
      if (!deger) continue;
      const x0 = cx + yon * bw / 2, x1 = x0 + yon * deger * olcek;
      s.cizgi(x0, cy, x1, cy, { renk: PALET.kirmizi, kalinlik: 3, ok: true });
      const mx = (x0 + x1) / 2;
      s.metin(yon < 0 ? Math.min(mx, x0 - 22) : Math.max(mx, x0 + 22), cy - 12, `${deger} N`, { boyut: 14 });
    }
    const net = c.sag - c.sol;
    olgular.net[c.ad] = Math.abs(net); olgular.yon[c.ad] = net > 0 ? 'sag' : net < 0 ? 'sol' : 'yok'; olgular.dengeli[c.ad] = net === 0;
    olgular.sol[c.ad] = c.sol; olgular.sag[c.ad] = c.sag;
  });
  return { sahne: s, alt: n === 1 ? 'Yatay zeminde duran bir cisim; cisme iki yandan birer ok ile gösterilen kuvvetler uygulanıyor.' : `${n} ayrı cisim; her birine iki yandan birer ok ile gösterilen kuvvetler uygulanıyor. Cisimlerin üzerinde harf yazıyor.`, olgular };
}

// ---------- 3) ışığın yansıması (düz ayna) ----------
// parametreler: { mod:'aday'|'aci', gelen (normalden, 20..70), adaylar:[{ad, aci}] (mod aday) }
function yansima(p, profil) {
  const W = 360, H = 236, ox = 180, oy = 192, L = 140, th = p.gelen, s = new Sahne(W, H, profil);
  if (th < 20 || th > 70) hata('gelen_aci_aralik');
  s.cizgi(40, oy, 320, oy, { kalinlik: 5, renk: KOYU });
  for (let x = 52; x <= 316; x += 16) s.cizgi(x, oy + 3, x - 9, oy + 13, { renk: PALET.gri, kalinlik: 1.4, izgara: true });
  kesik(s, ox, oy, ox, 40);
  s.metin(ox, 28, 'Normal', { boyut: 13 });
  s.cizgi(ox - L * sin(th), oy - L * cos(th), ox, oy, { renk: PALET.mavi, kalinlik: 3, ok: true });
  const yer = (a, r) => [ox + r * cos(a), oy - r * sin(a) + 5];
  const olgular = { gelen: th, yansima: th, yuzeyle_aci: 90 - th, yansiyan: null };
  if (p.mod === 'aday') {
    const ac = p.adaylar.map((x) => x.aci).sort((a, b) => a - b);
    for (let i = 1; i < ac.length; i++) if (ac[i] - ac[i - 1] < 9) hata('adaylar_yakin');
    for (const a of p.adaylar) {
      if (a.aci < 8 || a.aci > 78) hata('aday_aci_aralik');
      s.cizgi(ox, oy, ox + L * sin(a.aci), oy - L * cos(a.aci), { renk: PALET.turuncu, kalinlik: 2.6, ok: true });
      s.metin(ox + (L + 16) * sin(a.aci), oy - (L + 16) * cos(a.aci) + 5, a.ad, { kalin: true, boyut: 16 });
      if (a.aci === th) olgular.yansiyan = a.ad;
    }
    s.yay(ox, oy, 36, 90, 90 + th, { renk: PALET.mavi });
    s.metinYerlestir([yer(90 + th / 2, 62), yer(90 + th / 2, 76), yer(90 + th + 12, 66), yer(90 - 14, 64)], `${th}°`, { boyut: 14 });
  } else {
    s.cizgi(ox, oy, ox + L * sin(th), oy - L * cos(th), { renk: PALET.turuncu, kalinlik: 2.6, ok: true });
    s.yay(ox, oy, 40, 90 + th, 180, { renk: PALET.mavi });
    const b = (90 + th + 180) / 2;
    s.metinYerlestir([yer(b, 66), yer(b, 80), yer(b - 14, 70), yer(185, 62)], `${90 - th}°`, { boyut: 14 });
  }
  return { sahne: s, alt: p.mod === 'aday' ? 'Düz bir aynaya gelen ışın, aynanın dik doğrusu (normal) ve aynadan çıkan, harflerle adlandırılmış birkaç ışın.' : 'Düz bir aynaya gelen ışın ve yansıyan ışın; gelen ışın ile ayna yüzeyi arasındaki açı derece olarak yazılmıştır.', olgular };
}

// ---------- 4) hâl değişimi: sıcaklık–zaman grafiği ----------
// parametreler: { T0, Te, Tk, d1, d2, d3, d4 }  T0→Te (d1 dk), erime (d2), Te→Tk (d3), kaynama (d4). Bölümler K, L, M, N.
function halGrafigi(p, profil) {
  const { T0, Te, Tk, d1, d2, d3, d4 } = p;
  if (!(T0 < Te && Te < Tk)) hata('sicakliklar_sirasiz');
  const W = 360, H = 252, L = 58, Rx = 342, T = 28, B = 198, s = new Sahne(W, H, profil);
  const top = d1 + d2 + d3 + d4, tmax = Math.ceil((top + 1) / 2) * 2;
  const ymin = Math.floor(T0 / 10) * 10 - 10, ymax = Tk + 10, adimY = ymax - ymin > 90 ? 20 : 10;
  const X = (t) => L + ((Rx - L) * t) / tmax, Y = (v) => B - ((B - T) * (v - ymin)) / (ymax - ymin);
  const yz = (v) => String(v).replace('-', '−');
  for (let v = Math.ceil(ymin / adimY) * adimY; v <= ymax; v += adimY) {
    s.cizgi(L, Y(v), Rx, Y(v), { renk: ACIK, kalinlik: 1, izgara: true });
    s.metin(L - 6, Y(v) + 5, yz(v), { hiza: 'end', boyut: 13 });
  }
  for (let t = 0; t <= tmax; t += 2) {
    s.cizgi(X(t), T, X(t), B, { renk: ACIK, kalinlik: 1, izgara: true });
    s.metin(X(t), B + 17, String(t), { boyut: 13 });
  }
  s.cizgi(L, B, Rx, B, { kalinlik: 2 }); s.cizgi(L, T - 6, L, B, { kalinlik: 2 });
  s.metin(L + 4, 16, 'Sıcaklık (°C)', { hiza: 'start', boyut: 13 });
  s.metin(Rx, H - 8, 'Zaman (dk)', { hiza: 'end', boyut: 13 });
  const nk = [[0, T0], [d1, Te], [d1 + d2, Te], [d1 + d2 + d3, Tk], [top, Tk]];
  const harf = ['K', 'L', 'M', 'N'];
  for (let i = 0; i < 4; i++) {
    const [t1, v1] = nk[i], [t2, v2] = nk[i + 1];
    s.cizgi(X(t1), Y(v1), X(t2), Y(v2), { renk: PALET.mavi, kalinlik: 3 });
  }
  nk.forEach(([t, v]) => s.nokta(X(t), Y(v), { r: 3.5, renk: KOYU }));
  for (let i = 0; i < 4; i++) {
    const mx = (X(nk[i][0]) + X(nk[i + 1][0])) / 2, my = (Y(nk[i][1]) + Y(nk[i + 1][1])) / 2;
    const ad = i % 2 === 0 ? [[mx - 15, my - 6], [mx + 15, my + 18], [mx - 24, my + 4]] : [[mx, my - 12], [mx, my + 22]];
    s.metinYerlestir(ad, harf[i], { kalin: true, boyut: 16 });
  }
  const olgular = { erime: Te, kaynama: Tk, baslangic: T0, erime_suresi: d2, kaynama_suresi: d4, kaynama_baslangic_dk: d1 + d2 + d3, erime_baslangic_dk: d1, bolum: { K: 'kati_isinma', L: 'erime', M: 'sivi_isinma', N: 'kaynama' } };
  return { sahne: s, alt: 'Sıcaklık–zaman grafiği: bir madde ısıtılırken sıcaklık önce artıyor, sonra bir süre sabit kalıyor, yeniden artıyor ve yine sabitleniyor. Dört bölüm K, L, M, N harfleriyle adlandırılmış.', olgular };
}

// ---------- 5) ışığın kırılması ----------
const KIRILMA_N = { hava: 1.0, su: 1.33, cam: 1.5 }, KIRILMA_AD = { hava: 'Hava', su: 'Su', cam: 'Cam' };
const KIRILMA_DOLGU = { hava: '#FFFFFF', su: '#D6ECF8', cam: '#E3EEE4' };
// parametreler: { ust:'hava'|'su'|'cam', alt:..., gelen (normalden, derece), adaylar:[{ad, aci}] } adaylar: alt ortamda normalden sapma açısı.
function kirilma(p, profil) {
  const W = 360, H = 274, ox = 180, oy = 130, s = new Sahne(W, H, profil);
  const n1 = KIRILMA_N[p.ust], n2 = KIRILMA_N[p.alt]; if (!n1 || !n2 || n1 === n2) hata('ortam_gecersiz');
  const th = p.gelen, sr = (n1 * sin(th)) / n2; if (sr > 0.92) hata('tam_yansima_yakini');
  const r = (Math.asin(sr) * 180) / Math.PI;
  s.dikdortgen(8, 8, 344, oy - 8, { dolgu: KIRILMA_DOLGU[p.ust], renk: PALET.gri, kalinlik: 1 });
  s.dikdortgen(8, oy, 344, H - 8 - oy, { dolgu: KIRILMA_DOLGU[p.alt], renk: PALET.gri, kalinlik: 1 });
  s.cizgi(8, oy, 352, oy, { kalinlik: 2.5, renk: KOYU });
  kesik(s, ox, 30, ox, H - 10);
  s.metin(ox, 24, 'Normal', { boyut: 13 });
  s.metin(14, 30, KIRILMA_AD[p.ust], { hiza: 'start', boyut: 14, kalin: true });
  s.metin(14, H - 16, KIRILMA_AD[p.alt], { hiza: 'start', boyut: 14, kalin: true });
  s.cizgi(ox - 112 * sin(th), oy - 112 * cos(th), ox, oy, { renk: PALET.mavi, kalinlik: 3, ok: true });
  const ac = p.adaylar.map((x) => x.aci).sort((a, b) => a - b);
  for (let i = 1; i < ac.length; i++) if (ac[i] - ac[i - 1] < 9) hata('adaylar_yakin');
  let kirilan = null;
  for (const a of p.adaylar) {
    if (a.aci < 6 || a.aci > 78) hata('aday_aci_aralik');
    s.cizgi(ox, oy, ox + 110 * sin(a.aci), oy + 110 * cos(a.aci), { renk: PALET.turuncu, kalinlik: 2.6, ok: true });
    s.metin(ox + 128 * sin(a.aci), oy + 128 * cos(a.aci) + 5, a.ad, { kalin: true, boyut: 16 });
    if (Math.abs(a.aci - r) < 0.05) kirilan = a.ad;
  }
  return { sahne: s, alt: 'İki ortamı ayıran yatay bir sınır, sınıra dik kesikli çizgi (normal) ve üst ortamdan gelen bir ışın. Alt ortamda harflerle adlandırılmış birkaç olası yol çizilmiştir.', olgular: { kirilan, kirilma_acisi: r1(r), normale_yaklasir: n2 > n1, gelen: th } };
}
export const kirilmaHesap = (ust, alt, th) => { const sr = (KIRILMA_N[ust] * sin(th)) / KIRILMA_N[alt]; return sr > 0.92 ? null : (Math.asin(sr) * 180) / Math.PI; };

// ---------- 6) mercekler ----------
// parametreler: { paneller:[{ad, sekil:'cift-tumsek'|'duz-tumsek'|'cift-cukur'|'duz-cukur'}] } 2..4 panel; paralel ışınlar.
const TUMSEK = new Set(['cift-tumsek', 'duz-tumsek']);
function lensCiz(s, x, mid, sekil) {
  const t = mid - 42, b = mid + 42, o = { dolgu: '#DCEBF7', renk: PALET.siyah, kalinlik: 2, noktalar: [[x - 12, t], [x + 12, b]] };
  if (sekil === 'cift-tumsek') yol(s, `M${x} ${t} Q${x + 22} ${mid} ${x} ${b} Q${x - 22} ${mid} ${x} ${t} Z`, o);
  else if (sekil === 'duz-tumsek') yol(s, `M${x - 9} ${t} Q${x + 24} ${mid} ${x - 9} ${b} Z`, o);
  else if (sekil === 'cift-cukur') yol(s, `M${x - 12} ${t} L${x + 12} ${t} Q${x + 1} ${mid} ${x + 12} ${b} L${x - 12} ${b} Q${x - 1} ${mid} ${x - 12} ${t} Z`, o);
  else if (sekil === 'duz-cukur') yol(s, `M${x - 12} ${t} L${x + 12} ${t} Q${x - 4} ${mid} ${x + 12} ${b} L${x - 12} ${b} Z`, o);
  else hata('lens_sekli');
}
function mercek(p, profil) {
  const n = p.paneller.length; if (n < 2 || n > 4) hata('panel_sayisi_2_4');
  const pw = 180, ph = 120, sat = Math.ceil(n / 2), W = 360, H = ph * sat + 4, s = new Sahne(W, H, profil), olgular = { tur: {}, sekil: {} };
  p.paneller.forEach((pn, i) => {
    const ox = (i % 2) * pw, oy = Math.floor(i / 2) * ph + 2, mid = oy + ph / 2, x = ox + 74, yak = TUMSEK.has(pn.sekil);
    s.dikdortgen(ox + 3, oy + 2, pw - 6, ph - 4, { renk: PALET.gri, kalinlik: 1 });
    kesik(s, ox + 8, mid, ox + pw - 8, mid);
    lensCiz(s, x, mid, pn.sekil);
    const f = pn.sekil === 'duz-tumsek' ? 66 : 52;
    for (const dy of [-20, 0, 20]) {
      s.cizgi(ox + 8, mid + dy, x - 8, mid + dy, { renk: PALET.turuncu, kalinlik: 2.2, ok: true });
      if (yak) s.cizgi(x, mid + dy, x + 1.4 * f, mid - 0.4 * dy, { renk: PALET.turuncu, kalinlik: 2.2 });
      else s.cizgi(x, mid + dy, x + 66, mid + dy * (1 + 66 / 48), { renk: PALET.turuncu, kalinlik: 2.2 });
    }
    if (!yak) s.cizgi(x, mid, x + 66, mid, { renk: PALET.turuncu, kalinlik: 2.2 });
    else s.cizgi(x, mid, x + 1.4 * f, mid, { renk: PALET.turuncu, kalinlik: 2.2 });
    s.metin(ox + 18, oy + 24, pn.ad, { kalin: true, boyut: 17 });
    olgular.tur[pn.ad] = yak ? 'yakinsak' : 'iraksak'; olgular.sekil[pn.ad] = pn.sekil;
  });
  return { sahne: s, alt: `${n} ayrı panel; her panelde bir mercek ve merceğe soldan gelen üç paralel ışın çizilmiştir. Panellerin köşesinde harf yazıyor.`, olgular };
}

// ---------- 7) atom modeli ----------
const KATMAN_KAP = [2, 8, 8];
export function katmanDagilim(e) { const r = []; let k = e; for (const c of KATMAN_KAP) { if (k <= 0) break; const t = Math.min(c, k); r.push(t); k -= t; } return r; }
export const ELEMENT = { 1: ['H', 0], 2: ['He', 2], 3: ['Li', 4], 4: ['Be', 5], 5: ['B', 6], 6: ['C', 6], 7: ['N', 7], 8: ['O', 8], 9: ['F', 10], 10: ['Ne', 10], 11: ['Na', 12], 12: ['Mg', 12], 13: ['Al', 14], 14: ['Si', 14], 15: ['P', 16], 16: ['S', 16], 17: ['Cl', 18], 18: ['Ar', 22] };
// parametreler: { z (proton), n (nötron), e? (elektron; varsayılan z) }
function atom(p, profil) {
  const e = p.e ?? p.z, kat = katmanDagilim(e), W = 230, H = 230, cx = 115, cy = 115, s = new Sahne(W, H, profil), yar = [40, 60, 80];
  if (kat.length > 3) hata('katman_fazla');
  kat.forEach((c, i) => {
    s.cember(cx, cy, yar[i], { renk: PALET.gri, kalinlik: 1.5 });
    for (let j = 0; j < c; j++) { const a = -90 + (360 * (j + 0.5)) / c; s.nokta(cx + yar[i] * cos(a), cy - yar[i] * sin(a), { r: 5, renk: PALET.mavi }); }
  });
  s.cember(cx, cy, 25, { dolgu: TURUNCU_AC, renk: PALET.siyah, kalinlik: 2 });
  s.metin(cx, cy - 5, `${p.z}p`, { boyut: 14, kalin: true }); s.metin(cx, cy + 15, `${p.n}n`, { boyut: 14, kalin: true });
  return { sahne: s, alt: 'Bir atom modeli: ortada çekirdek, çevresinde halkalar (katmanlar) ve halkalar üzerinde noktalarla gösterilen elektronlar. Çekirdeğin içinde proton ve nötron sayıları yazıyor.', olgular: { proton: p.z, notron: p.n, elektron: e, katman: kat.length, son_katman: kat[kat.length - 1], kutle: p.z + p.n, yuk: p.z - e } };
}

// ---------- 8) periyodik tablo (ilk 18 element, kısa biçim) ----------
const GRUPLAR = [1, 2, 13, 14, 15, 16, 17, 18];
const SEMBOL = [['H', null, null, null, null, null, null, 'He'], ['Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne'], ['Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar']];
export const periyodikKonumlar = () => { const l = []; for (let r = 0; r < 3; r++) for (let c = 0; c < 8; c++) if (SEMBOL[r][c]) l.push({ satir: r, sutun: c }); return l; };
export const grupNo = (sutun) => GRUPLAR[sutun];
// parametreler: { isaretler:[{ad, satir, sutun}] }  İşaretli hücrede element yerine harf yazar.
function periyodik(p, profil) {
  const W = 360, H = 200, x0 = 68, y0 = 52, cw = 36, ch = 44, s = new Sahne(W, H, profil);
  s.metin(x0 + 4 * cw, 15, 'Grup', { boyut: 13, kalin: true });
  s.metin(34, 42, 'Periyot', { boyut: 13, kalin: true });
  GRUPLAR.forEach((g, c) => s.metin(x0 + c * cw + cw / 2, 42, String(g), { boyut: 13, kalin: true }));
  const isr = new Map(p.isaretler.map((i) => [`${i.satir},${i.sutun}`, i.ad])), konum = {};
  let sayac = 0, numara = 0;
  for (let r = 0; r < 3; r++) {
    s.metin(52, y0 + r * ch + ch / 2 + 5, String(r + 1), { boyut: 13, kalin: true });
    for (let c = 0; c < 8; c++) {
      const sm = SEMBOL[r][c]; if (!sm) continue;
      numara += 0; sayac += 1;
      const x = x0 + c * cw, y = y0 + r * ch, ad = isr.get(`${r},${c}`);
      s.dikdortgen(x, y, cw, ch, { dolgu: ad ? '#FDE68A' : '#FFFFFF', renk: PALET.siyah, kalinlik: ad ? 2 : 1 });
      if (ad) { s.metin(x + cw / 2, y + ch / 2 + 7, ad, { boyut: 19, kalin: true }); konum[ad] = { periyot: r + 1, grup: GRUPLAR[c] }; }
      else { s.metin(x + 4, y + 14, String(sayac), { hiza: 'start', boyut: 11 }); s.metin(x + cw / 2, y + 36, sm, { boyut: 16, kalin: true }); }
    }
  }
  for (const i of p.isaretler) if (!SEMBOL[i.satir]?.[i.sutun]) hata('isaret_bos_hucre');
  return { sahne: s, alt: 'Periyodik tablonun ilk 18 elementini gösteren kısa biçimli tablo; üç periyot (satır) ve sekiz grup (sütun) var. Bazı hücrelerde element yerine harf yazıyor.', olgular: { konum } };
}

// ---------- 9) enerji: yükseklikteki ve hareketli cisimler ----------
// parametreler: { mod:'yukseklik'|'hiz', cisimler:[{ad, kutle (kg), deger (m ya da m/s)}] }
const CISIM_RENK = ['#FDE68A', '#BFE3F5', '#F9C6D0', '#C8E6C9'];
function cisimler(p, profil) {
  const n = p.cisimler.length; if (n < 2 || n > 4) hata('cisim_sayisi_2_4');
  const ad = p.cisimler.map((c) => c.ad), olgular = { kutle: {}, deger: {} };
  p.cisimler.forEach((c) => { olgular.kutle[c.ad] = c.kutle; olgular.deger[c.ad] = c.deger; });
  if (p.mod === 'yukseklik') {
    const W = 360, H = 240, zemin = 216, adim = 28, ax = 50, s = new Sahne(W, H, profil), cols = n === 2 ? [140, 270] : n === 3 ? [118, 208, 298] : [104, 176, 248, 320];
    for (let h = 0; h <= 5; h++) {
      const y = zemin - h * adim;
      s.cizgi(ax, y, 350, y, { renk: ACIK, kalinlik: 1, izgara: true });
      s.metin(ax - 9, y + 5, String(h), { hiza: 'end', boyut: 13 });
    }
    s.cizgi(ax, zemin - 5 * adim - 6, ax, zemin, { kalinlik: 2 });
    s.metin(4, 14, 'Yükseklik (m)', { hiza: 'start', boyut: 13 });
    p.cisimler.forEach((c, i) => {
      if (c.deger < 1 || c.deger > 5) hata('yukseklik_aralik');
      const cx = cols[i], yt = zemin - c.deger * adim;
      s.dikdortgen(cx - 22, yt, 44, c.deger * adim, { dolgu: '#D1D5DB', renk: KOYU, kalinlik: 1.5 });
      s.dikdortgen(cx - 22, yt - 28, 44, 28, { dolgu: CISIM_RENK[i], kalinlik: 2 });
      s.metin(cx, yt - 9, `${c.kutle} kg`, { boyut: 14 });
      s.metin(cx, yt - 35, c.ad, { kalin: true, boyut: 16 });
    });
    return { sahne: s, alt: `${n} cisim, soldaki yükseklik skalasına göre farklı yüksekliklerdeki sütunların üzerinde duruyor; her cismin üzerinde kütlesi yazılı.`, olgular };
  }
  const W = 360, H = n * 58 + 12, s = new Sahne(W, H, profil);
  p.cisimler.forEach((c, i) => {
    if (c.deger < 2 || c.deger > 12) hata('hiz_aralik');
    const cy = 12 + i * 58 + 29;
    s.cizgi(30, cy + 19, 350, cy + 19, { renk: PALET.gri, kalinlik: 1.5, izgara: true });
    s.metin(16, cy + 6, c.ad, { kalin: true, boyut: 17 });
    s.dikdortgen(36, cy - 17, 66, 34, { dolgu: CISIM_RENK[i], kalinlik: 2 });
    s.metin(69, cy + 5, `${c.kutle} kg`, { boyut: 14 });
    s.cizgi(102, cy, 102 + c.deger * 17, cy, { renk: PALET.kirmizi, kalinlik: 3, ok: true });
    s.metin(106, cy - 9, `${c.deger} m/s`, { hiza: 'start', boyut: 14 });
  });
  void ad;
  return { sahne: s, alt: `${n} hareketli cisim; her cismin üzerinde kütlesi yazılı, önündeki okun yanında da hızı yazılı.`, olgular };
}

// ---------- 10) besin ağı ----------
// parametreler: { dugumler:[{ad, x, y}], oklar:[[yenen, yiyen]] }
function besin(p, profil) {
  const r = 17, ymax = Math.max(...p.dugumler.map((d) => d.y)), W = 360, H = ymax + 36, s = new Sahne(W, H, profil), kon = {};
  for (const d of p.dugumler) kon[d.ad] = d;
  for (const [a, b] of p.oklar) {
    const A = kon[a], B = kon[b]; if (!A || !B) hata('ok_dugumu_yok');
    const dx = B.x - A.x, dy = B.y - A.y, u = Math.hypot(dx, dy), ux = dx / u, uy = dy / u;
    s.cizgi(A.x + ux * (r + 3), A.y + uy * (r + 3), B.x - ux * (r + 4), B.y - uy * (r + 4), { renk: KOYU, kalinlik: 2, ok: true });
  }
  for (const d of p.dugumler) { s.cember(d.x, d.y, r, { dolgu: '#F3F4F6', renk: PALET.siyah, kalinlik: 2 }); s.metin(d.x, d.y + 6, d.ad, { boyut: 16, kalin: true }); }
  const yiyen = {}, yenen = {};
  for (const d of p.dugumler) { yiyen[d.ad] = []; yenen[d.ad] = []; }
  for (const [a, b] of p.oklar) { yiyen[a].push(b); yenen[b].push(a); }
  const uretici = p.dugumler.map((d) => d.ad).filter((a) => yenen[a].length === 0).sort(), ust = p.dugumler.map((d) => d.ad).filter((a) => yiyen[a].length === 0).sort();
  return { sahne: s, alt: 'Harflerle adlandırılmış canlıları birbirine bağlayan oklardan oluşan bir besin ağı şeması.', olgular: { uretici, ust, yiyen, yenen, tuketici_sayisi: p.dugumler.length - uretici.length } };
}

// ---------- 11) Dünya'nın yörüngesi ve mevsimler ----------
// parametreler: { egim:'sag'|'sol' (eksenin üst ucunun eğildiği yön), yon:'saat-tersi'|'saat', harf:{sol,alt,sag,ust} }
function yorunge(p, profil) {
  const W = 360, H = 300, cx = 180, cy = 150, R = 100, s = new Sahne(W, H, profil);
  s.cember(cx, cy, R, { renk: PALET.gri, kalinlik: 1.4 });
  s.cember(cx, cy, 22, { dolgu: SARI, renk: '#B45309', kalinlik: 2 });
  s.metin(cx, cy + 45, 'Güneş', { boyut: 14 });
  const SIRA = ['sol', 'alt', 'sag', 'ust'], OFS = { sol: [-1, 0], alt: [0, 1], sag: [1, 0], ust: [0, -1] };
  const tilt = p.egim === 'sag' ? 23.5 : -23.5, ux = sin(tilt), uy = -cos(tilt), proj = p.egim === 'sag' ? 1 : -1;
  const sezon = {};
  for (const yer of SIRA) { const dot = proj * -OFS[yer][0]; sezon[yer] = dot > 0 ? 'yaz' : dot < 0 ? 'kış' : null; }
  SIRA.forEach((yer, i) => { if (!sezon[yer]) { const sonraki = SIRA[(i + (p.yon === 'saat-tersi' ? 1 : 3)) % 4]; sezon[yer] = sezon[sonraki] === 'yaz' ? 'ilkbahar' : 'sonbahar'; } });
  for (const a of [45, 225]) {
    const px = cx + R * cos(a), py = cy - R * sin(a), g = p.yon === 'saat-tersi' ? 1 : -1, tx = -sin(a) * g, ty = -cos(a) * g;
    s.cizgi(px - tx * 9, py - ty * 9, px + tx * 9, py + ty * 9, { renk: KOYU, kalinlik: 2.4, ok: true });
  }
  const mevsim = {};
  for (const yer of SIRA) {
    const x = cx + OFS[yer][0] * R, y = cy + OFS[yer][1] * R;
    s.cember(x, y, 14, { dolgu: '#9CC9E8', renk: PALET.siyah, kalinlik: 2 });
    s.cizgi(x - ux * 26, y - uy * 26, x + ux * 26, y + uy * 26, { kalinlik: 2.4 });
    s.nokta(x + ux * 26, y + uy * 26, { r: 4 });
    s.metin(x + (yer === 'sol' ? -34 : 32), y + 5, p.harf[yer], { kalin: true, boyut: 17 });
    mevsim[p.harf[yer]] = sezon[yer];
  }
  const ters = { yaz: 'kış', kış: 'yaz', ilkbahar: 'sonbahar', sonbahar: 'ilkbahar' };
  return { sahne: s, alt: 'Güneş’in çevresinde dört konumda Dünya; her Dünya’nın ekseni eğiktir ve konumlar harflerle adlandırılmıştır. Yörüngede dolanma yönünü gösteren oklar vardır.', olgular: { mevsim, guney: Object.fromEntries(Object.entries(mevsim).map(([h, m]) => [h, ters[m]])) } };
}

// ---------- 12) çaprazlama tablosu (Punnett) ----------
// parametreler: { e1:'Aa', e2:'Aa', gizli?:[satir, sutun] }
const genoSirala = (a, b) => [a, b].sort((u, v) => (u === u.toLowerCase() ? 1 : 0) - (v === v.toLowerCase() ? 1 : 0)).join('');
function punnett(p, profil) {
  const W = 310, H = 206, x0 = 74, rw = 46, cw = 88, y0 = 34, hh = 34, bh = 62, s = new Sahne(W, H, profil);
  const g1 = [p.e1[0], p.e1[1]], g2 = [p.e2[0], p.e2[1]];
  s.metin(x0 + rw + cw, 20, '1. birey', { boyut: 14, kalin: true });
  s.metin(4, y0 + hh + bh + 5, '2. birey', { hiza: 'start', boyut: 14, kalin: true });
  s.dikdortgen(x0, y0, rw, hh, { renk: PALET.siyah, kalinlik: 1 });
  g1.forEach((a, i) => { s.dikdortgen(x0 + rw + i * cw, y0, cw, hh, { dolgu: '#DCEBF7', kalinlik: 1.2 }); s.metin(x0 + rw + i * cw + cw / 2, y0 + 25, a, { boyut: 20, kalin: true }); });
  g2.forEach((a, j) => { s.dikdortgen(x0, y0 + hh + j * bh, rw, bh, { dolgu: '#DCEBF7', kalinlik: 1.2 }); s.metin(x0 + rw / 2, y0 + hh + j * bh + 37, a, { boyut: 20, kalin: true }); });
  const hucre = [[], []], sayi = {};
  for (let j = 0; j < 2; j++) for (let i = 0; i < 2; i++) {
    const g = genoSirala(g1[i], g2[j]), gizli = p.gizli && p.gizli[0] === j && p.gizli[1] === i;
    hucre[j].push(g); sayi[g] = (sayi[g] ?? 0) + 1;
    s.dikdortgen(x0 + rw + i * cw, y0 + hh + j * bh, cw, bh, { dolgu: gizli ? '#FEF3C7' : '#FFFFFF', renk: PALET.siyah, kalinlik: gizli ? 2.4 : 1.4 });
    s.metin(x0 + rw + i * cw + cw / 2, y0 + hh + j * bh + 38, gizli ? '?' : g, { boyut: 22, kalin: true });
  }
  return { sahne: s, alt: 'İki bireyin eşey hücrelerinin (gametlerin) üst satırda ve sol sütunda yazıldığı 2 × 2 çaprazlama tablosu; kutularda yavruların genotipleri yazıyor.', olgular: { hucre, sayi, gizli_deger: p.gizli ? hucre[p.gizli[0]][p.gizli[1]] : null } };
}

// ---------- 13) dikdörtgenler prizması blokları (katı basıncı) ----------
// parametreler: { bloklar:[{ad, w, h, d}] }  cm; w: ön yüz eni, h: yükseklik, d: derinlik. Taban = w × d.
function blok(p, profil) {
  const n = p.bloklar.length; if (n < 2 || n > 3) hata('blok_sayisi_2_3');
  const pw = 360 / n, W = 360, H = 206, k = 1.15, ybase = 152, s = new Sahne(W, H, profil), olgular = { taban: {}, basinc: {} };
  p.bloklar.forEach((b, i) => {
    const ox = pw * i, wp = b.w * k, hp = b.h * k, dp = b.d * k * 0.5 * 0.7071, x = ox + (n === 2 ? 56 : 30);
    s.cizgi(ox + 8, ybase, ox + pw - 8, ybase, { renk: PALET.gri, kalinlik: 3, izgara: true });
    s.poligon([[x, ybase - hp], [x + dp, ybase - hp - dp], [x + wp + dp, ybase - hp - dp], [x + wp, ybase - hp]], { dolgu: '#FBE3B8', kalinlik: 1.5 });
    s.poligon([[x + wp, ybase - hp], [x + wp + dp, ybase - hp - dp], [x + wp + dp, ybase - dp], [x + wp, ybase]], { dolgu: '#D9A55B', kalinlik: 1.5 });
    s.dikdortgen(x, ybase - hp, wp, hp, { dolgu: TURUNCU_AC, kalinlik: 1.8 });
    s.metin(ox + pw / 2, 26, b.ad, { kalin: true, boyut: 18 });
    s.metin(x + wp / 2, ybase + 19, String(b.w), { boyut: 14 });
    s.metin(x - 6, ybase - hp / 2 + 5, String(b.h), { hiza: 'end', boyut: 14 });
    s.metin(x + wp + dp + 5, ybase - hp - dp / 2 + 5, String(b.d), { hiza: 'start', boyut: 14 });
    olgular.taban[b.ad] = b.w * b.d;
    if (p.F) olgular.basinc[b.ad] = r1(p.F / (b.w * b.d) * 100) / 100;
  });
  return { sahne: s, alt: `Aynı dikdörtgenler prizması biçimli bir cismin yatay zemin üzerindeki ${n} farklı duruşu; kenar uzunlukları santimetre cinsinden yazılmıştır.`, olgular };
}

// ---------- 14) sıvı dolu kaplar (sıvı basıncı) ----------
const KAP_SEKIL = { dar: [26, 26], genis: [48, 48], huni: [26, 48], ters: [48, 26] };
// parametreler: { kaplar:[{ad, sekil, h}] }  h: sıvı yüksekliği (cm, 4..22).
function kaplar(p, profil) {
  const n = p.kaplar.length; if (n < 2 || n > 4) hata('kap_sayisi_2_4');
  const pw = 360 / n, W = 360, H = 214, base = 172, Hc = 128, kp = 5.2, s = new Sahne(W, H, profil), olgular = { h: {}, sekil: {} };
  p.kaplar.forEach((c, i) => {
    const [wb, wt] = KAP_SEKIL[c.sekil] ?? hata('kap_sekli'); if (c.h < 4 || c.h > 22) hata('seviye_aralik');
    const wm = Math.max(wb, wt), cx = pw * i + 10 + wm / 2, hp = c.h * kp, wl = wb + ((wt - wb) * hp) / Hc;
    s.poligon([[cx - wb / 2, base], [cx + wb / 2, base], [cx + wl / 2, base - hp], [cx - wl / 2, base - hp]], { dolgu: SU, renk: PALET.mavi, kalinlik: 1 });
    s.cizgi(cx - wt / 2, base - Hc, cx - wb / 2, base, { kalinlik: 2.6 }); s.cizgi(cx - wb / 2, base, cx + wb / 2, base, { kalinlik: 2.6 }); s.cizgi(cx + wb / 2, base, cx + wt / 2, base - Hc, { kalinlik: 2.6 });
    const xd = pw * i + 10 + wm + 12, ym = base - hp / 2;
    s.cizgi(xd, ym, xd, base - hp, { renk: KOYU, kalinlik: 1.6, ok: true }); s.cizgi(xd, ym, xd, base, { renk: KOYU, kalinlik: 1.6, ok: true });
    s.metin(xd + 6, ym + 5, String(c.h), { hiza: 'start', boyut: 14 });
    s.metin(cx, base + 28, c.ad, { kalin: true, boyut: 18 });
    olgular.h[c.ad] = c.h; olgular.sekil[c.ad] = c.sekil;
  });
  return { sahne: s, alt: `Aynı sıvıyla doldurulmuş, farklı biçimli ${n} kap; her kabın yanında sıvı yüksekliğini gösteren bir ölçü oku ve sayı vardır.`, olgular };
}

// ---------- 15) pH ölçeği ----------
const PH_RENK = ['#D73027', '#E34A2E', '#F46D43', '#F98C52', '#FDAE61', '#FDCE74', '#FEE08B', '#A6D96A', '#7FC866', '#66BD63', '#35A66B', '#1A9850', '#4575B4', '#5E3C99'];
// parametreler: { ornekler:[{ad, ph}] }  ph: 1..13 tam sayı.
function ph(p, profil) {
  const W = 360, H = 130, x0 = 20, bw = 320 / 14, by = 72, bh = 26, s = new Sahne(W, H, profil), olgular = { ph: {} };
  PH_RENK.forEach((c, i) => s.dikdortgen(x0 + i * bw, by, bw, bh, { dolgu: c, renk: c, kalinlik: 0.5 }));
  s.dikdortgen(x0, by, 320, bh, { kalinlik: 1.6 });
  for (let i = 0; i <= 14; i++) { s.cizgi(x0 + i * bw, by + bh, x0 + i * bw, by + bh + 5, { izgara: true }); s.metin(x0 + i * bw, by + bh + 22, String(i), { boyut: 13 }); }
  const kul = new Set();
  for (const o of p.ornekler) {
    if (!Number.isInteger(o.ph) || o.ph < 1 || o.ph > 13 || kul.has(o.ph)) hata('ph_gecersiz'); kul.add(o.ph);
    const x = x0 + o.ph * bw;
    s.poligon([[x - 7, by - 14], [x + 7, by - 14], [x, by - 2]], { dolgu: KOYU, renk: KOYU, kalinlik: 1 });
    s.metin(x, by - 22, o.ad, { kalin: true, boyut: 16 });
    olgular.ph[o.ad] = o.ph;
  }
  return { sahne: s, alt: 'Renkli bir pH ölçeği (0’dan 14’e kadar sayılı). Ölçeğin üstünde harflerle adlandırılmış maddelerin pH değerlerini gösteren işaretler var.', olgular };
}

// ---------- 16) kaldıraç (eşit kollu) ----------
// parametreler: { sol:[{d, w}], sag:[{d, w|null}], adaylar?:[{ad, d}] }  d: dayanak noktasına uzaklık (1..5), w: ağırlık (N). w null: bilinmeyen (?).
function kaldirac(p, profil) {
  const W = 360, H = 190, fx = 180, by = 98, u = 29, s = new Sahne(W, H, profil);
  s.cizgi(fx - 5 * u - 14, by, fx + 5 * u + 14, by, { kalinlik: 5, renk: KOYU });
  s.poligon([[fx, by + 4], [fx - 12, by + 30], [fx + 12, by + 30]], { dolgu: '#9CA3AF', renk: KOYU, kalinlik: 1.5 });
  for (let i = 1; i <= 5; i++) for (const yon of [-1, 1]) { const x = fx + yon * i * u; s.cizgi(x, by - 6, x, by, { izgara: true }); s.metin(x, by - 12, String(i), { boyut: 13 }); }
  let torkSol = 0, torkSag = 0, bilinmeyen = null;
  const as = (liste, yon) => {
    const ds = liste.map((x) => x.d).sort((a, b) => a - b);
    for (let i = 1; i < ds.length; i++) if (ds[i] - ds[i - 1] < 2) hata('asilar_yakin');
    for (const a of liste) {
      const x = fx + yon * a.d * u; if (a.d < 1 || a.d > 5) hata('uzaklik_aralik');
      s.cizgi(x, by, x, by + 36, { kalinlik: 1.5 });
      s.dikdortgen(x - 21, by + 36, 42, 26, { dolgu: a.w == null ? '#FEF3C7' : '#FDE68A', kalinlik: 2 });
      s.metin(x, by + 55, a.w == null ? '? N' : `${a.w} N`, { boyut: 14, kalin: a.w == null });
      if (a.w != null) { if (yon < 0) torkSol += a.w * a.d; else torkSag += a.w * a.d; } else bilinmeyen = a.d;
    }
  };
  as(p.sol, -1); as(p.sag, 1);
  const konum = {};
  for (const c of p.adaylar ?? []) { const x = fx + c.d * u; s.nokta(x, by, { r: 5, renk: PALET.kirmizi }); s.metin(x, by + 40, c.ad, { kalin: true, boyut: 16 }); konum[c.ad] = c.d; }
  return { sahne: s, alt: 'Eşit kollu bir kaldıraç: ortada dayanak noktası, kolun iki yanında dayanak noktasından uzaklığı gösteren sayılar. Kolun altında asılı ağırlıklar yazılıdır.', olgular: { tork_sol: torkSol, bilinmeyen_uzaklik: bilinmeyen, konum } };
}

// ---------- 17) a5-devre sarmalayıcı: alt metin devre elemanı adlarını söylemez ----------
function devreTek(p, profil) {
  const r = TIPLER_A5['a5-devre'](p, profil);
  return { ...r, alt: 'Bir elektrik devresi şeması; bazı elemanların yanında harfler yazıyor.' };
}

export const TIPLER_B2 = {
  'b2-devre': devreTek,
  'b2-dunya': dunya,
  'b2-kuvvet': kuvvet,
  'b2-yansima': yansima,
  'b2-hal-grafigi': halGrafigi,
  'b2-kirilma': kirilma,
  'b2-mercek': mercek,
  'b2-atom': atom,
  'b2-periyodik': periyodik,
  'b2-cisimler': cisimler,
  'b2-besin': besin,
  'b2-yorunge': yorunge,
  'b2-punnett': punnett,
  'b2-blok': blok,
  'b2-kaplar': kaplar,
  'b2-ph': ph,
  'b2-kaldirac': kaldirac,
};
