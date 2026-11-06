// Ajan A7 için şekil tipleri (Türkçe 4, 6, 7, 8). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'a7-' önekiyle başlar. Alt metinler cevabı ve şekildeki verileri yazmaz.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const taban = (W, profil) => Math.ceil((profil.minYaziPx * W) / 360 + 0.3);
const gen = (str, b) => String(str).length * b * 0.6;
const BEYAZ = '#FFFFFF';
const RENK = { kirmizi: '#D62828', mavi: '#1D4ED8', yesil: '#00A37A', sari: '#F2C500', kahve: '#8B5E3C', ten: '#F5CBA7', acik: '#F3F4F6', gri: '#6B7280' };

// ---------- çizelge (tablo, program, takvim) ----------
// p: { baslik, ilkSutun, sutunlar:[...], satirlar:[{etiket, hucreler:[...]}], etiketGen?, hucreGen? }
function cizelge(p, profil) {
  const nc = p.sutunlar.length, nr = p.satirlar.length;
  if (nc < 2 || nc > 6) hata('sutun_sayisi_2_6');
  if (nr < 2 || nr > 7) hata('satir_sayisi_2_7');
  const fw = p.etiketGen ?? 92, cw = p.hucreGen ?? 80, W = 24 + fw + nc * cw, b = taban(W, profil);
  const rowH = 32, headH = 36, top = 44, H = top + headH + nr * rowH + 16, s = new Sahne(W, H, profil), x0 = 12;
  s.metin(W / 2, 26, p.baslik, { boyut: b + 1, kalin: true });
  s.dikdortgen(x0, top, fw + nc * cw, headH, { dolgu: PALET.mavi, renk: PALET.mavi });
  const sig = (t, w) => { if (gen(t, b) > w - 4) hata(`metin_sigmiyor:${t}`); };
  if (p.ilkSutun) { sig(p.ilkSutun, fw); s.metin(x0 + fw / 2, top + headH / 2 + b * 0.35, p.ilkSutun, { boyut: b, kalin: true, renk: BEYAZ }); }
  p.sutunlar.forEach((c, i) => { sig(c, cw); s.metin(x0 + fw + cw * (i + 0.5), top + headH / 2 + b * 0.35, c, { boyut: b, kalin: true, renk: BEYAZ }); });
  const hucre = {};
  p.satirlar.forEach((r, j) => {
    if (r.hucreler.length !== nc) hata('hucre_sayisi_uyumsuz');
    const y = top + headH + j * rowH;
    s.dikdortgen(x0, y, fw, rowH, { dolgu: RENK.acik, renk: PALET.gri, kalinlik: 0.8 });
    sig(r.etiket, fw); s.metin(x0 + fw / 2, y + rowH / 2 + b * 0.35, r.etiket, { boyut: b, kalin: true });
    hucre[r.etiket] = {};
    r.hucreler.forEach((v, i) => {
      s.dikdortgen(x0 + fw + i * cw, y, cw, rowH, { renk: PALET.gri, kalinlik: 0.8 });
      sig(String(v), cw); s.metin(x0 + fw + cw * (i + 0.5), y + rowH / 2 + b * 0.35, String(v), { boyut: b });
      hucre[r.etiket][p.sutunlar[i]] = v;
    });
  });
  const olgular = { hucre, satirlar: p.satirlar.map((r) => r.etiket), sutunlar: p.sutunlar };
  if (p.satirlar.every((r) => r.hucreler.every((v) => typeof v === 'number'))) {
    olgular.satir_toplam = Object.fromEntries(p.satirlar.map((r) => [r.etiket, r.hucreler.reduce((t, v) => t + v, 0)]));
    olgular.sutun_toplam = Object.fromEntries(p.sutunlar.map((c, i) => [c, p.satirlar.reduce((t, r) => t + r.hucreler[i], 0)]));
  }
  return { sahne: s, alt: `Satır ve sütunlardan oluşan bir çizelge. Başlığı: ${p.baslik}.`, olgular };
}

// ---------- işaret / levha ----------
const ISARETLER = new Set(['girilmez', 'dur', 'saga_mecburi', 'sola_mecburi', 'dikkat', 'yuksek_gerilim', 'park', 'park_yasak', 'ilk_yardim', 'yaya_gecidi', 'cop', 'bisiklet', 'tek_yon_sag', 'tek_yon_sol']);
function isaret(p, profil) {
  if (!ISARETLER.has(p.isaret)) hata(`isaret_bilinmiyor:${p.isaret}`);
  const s = new Sahne(170, 170, profil), K = RENK.kirmizi, M = RENK.mavi, G = RENK.yesil, c = 85;
  const ayna = p.isaret.endsWith('sol') || p.isaret === 'sola_mecburi';
  const X = (x) => (ayna ? 170 - x : x);
  const L = (x1, y1, x2, y2, renk, k) => s.cizgi(X(x1), y1, X(x2), y2, { renk, kalinlik: k, izgara: true });
  const P = (pts, o) => s.poligon(pts.map(([x, y]) => [X(x), y]), o);
  switch (p.isaret) {
    case 'girilmez': s.cember(c, c, 62, { dolgu: K, renk: K, kalinlik: 2 }); s.dikdortgen(40, 76, 90, 18, { dolgu: BEYAZ, renk: BEYAZ }); break;
    case 'dur': P([0, 1, 2, 3, 4, 5, 6, 7].map((k) => [c + 68 * Math.cos(((22.5 + 45 * k) * Math.PI) / 180), c + 68 * Math.sin(((22.5 + 45 * k) * Math.PI) / 180)]), { dolgu: K, renk: BEYAZ, kalinlik: 4 }); s.metin(c, 99, 'DUR', { boyut: 34, kalin: true, renk: BEYAZ }); break;
    case 'saga_mecburi': case 'sola_mecburi':
      s.cember(c, c, 62, { dolgu: M, renk: M, kalinlik: 2 }); L(70, 128, 70, 82, BEYAZ, 14); L(70, 82, 108, 82, BEYAZ, 14); P([[104, 60], [136, 82], [104, 104]], { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); break;
    case 'dikkat': s.poligon([[85, 14], [160, 146], [10, 146]], { dolgu: BEYAZ, renk: K, kalinlik: 10 }); s.metin(c, 130, '!', { boyut: 74, kalin: true }); break;
    case 'yuksek_gerilim': s.poligon([[85, 14], [160, 146], [10, 146]], { dolgu: RENK.sari, renk: PALET.siyah, kalinlik: 8 }); s.poligon([[98, 52], [64, 106], [84, 106], [72, 140], [110, 90], [90, 90]], { dolgu: PALET.siyah, renk: PALET.siyah, kalinlik: 1 }); break;
    case 'park': s.dikdortgen(18, 18, 134, 134, { dolgu: M, renk: M, kalinlik: 3 }); s.dikdortgen(24, 24, 122, 122, { renk: BEYAZ, kalinlik: 3 }); s.metin(c, 118, 'P', { boyut: 96, kalin: true, renk: BEYAZ }); break;
    case 'park_yasak': s.cember(c, c, 60, { dolgu: M, renk: K, kalinlik: 10 }); s.metin(c, 108, 'P', { boyut: 70, kalin: true, renk: BEYAZ }); s.cizgi(46, 46, 124, 124, { renk: K, kalinlik: 10, izgara: true }); break;
    case 'ilk_yardim': s.dikdortgen(18, 18, 134, 134, { dolgu: G, renk: G, kalinlik: 3 }); s.dikdortgen(24, 24, 122, 122, { renk: BEYAZ, kalinlik: 3 }); s.dikdortgen(72, 40, 26, 90, { dolgu: BEYAZ, renk: BEYAZ }); s.dikdortgen(40, 72, 90, 26, { dolgu: BEYAZ, renk: BEYAZ }); break;
    case 'yaya_gecidi':
      s.dikdortgen(18, 18, 134, 134, { dolgu: M, renk: M, kalinlik: 3 }); s.dikdortgen(24, 24, 122, 122, { renk: BEYAZ, kalinlik: 3 });
      s.cember(85, 46, 10, { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 });
      L(85, 58, 85, 90, BEYAZ, 8); L(85, 66, 66, 84, BEYAZ, 6); L(85, 66, 106, 80, BEYAZ, 6); L(85, 90, 72, 112, BEYAZ, 7); L(85, 90, 100, 110, BEYAZ, 7);
      s.dikdortgen(38, 120, 94, 7, { dolgu: BEYAZ, renk: BEYAZ }); s.dikdortgen(38, 132, 94, 7, { dolgu: BEYAZ, renk: BEYAZ }); break;
    case 'cop':
      s.dikdortgen(18, 18, 134, 134, { dolgu: G, renk: G, kalinlik: 3 }); s.dikdortgen(24, 24, 122, 122, { renk: BEYAZ, kalinlik: 3 });
      s.dikdortgen(55, 46, 60, 9, { dolgu: BEYAZ, renk: BEYAZ }); s.dikdortgen(78, 36, 14, 10, { dolgu: BEYAZ, renk: BEYAZ });
      s.poligon([[60, 58], [110, 58], [104, 130], [66, 130]], { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); L(78, 68, 80, 120, G, 4); L(92, 68, 90, 120, G, 4); break;
    case 'bisiklet':
      s.cember(c, c, 62, { dolgu: M, renk: M, kalinlik: 2 }); s.cember(55, 105, 19, { renk: BEYAZ, kalinlik: 5 }); s.cember(115, 105, 19, { renk: BEYAZ, kalinlik: 5 });
      L(55, 105, 78, 105, BEYAZ, 5); L(78, 105, 70, 78, BEYAZ, 5); L(70, 78, 105, 78, BEYAZ, 5); L(78, 105, 105, 78, BEYAZ, 5); L(105, 78, 115, 105, BEYAZ, 5); L(105, 78, 102, 64, BEYAZ, 5); L(94, 62, 112, 62, BEYAZ, 5);
      s.dikdortgen(58, 68, 24, 6, { dolgu: BEYAZ, renk: BEYAZ }); break;
    case 'tek_yon_sag': case 'tek_yon_sol':
      s.dikdortgen(10, 40, 150, 90, { dolgu: M, renk: BEYAZ, kalinlik: 3 }); L(28, 85, 112, 85, BEYAZ, 16); P([[106, 54], [146, 85], [106, 116]], { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); break;
    default: hata('isaret_ciz');
  }
  return { sahne: s, alt: 'Bir yol ya da uyarı işaretinin çizimi.', olgular: { isaret: p.isaret } };
}

// ---------- yönerge için yol ızgarası ----------
// p: { en, boy, yerler:[{ad,x,y}], baslangic:{x,y,yon:'yukari'|'sag'|'asagi'|'sol'} }
const YON = { yukari: [0, -1], sag: [1, 0], asagi: [0, 1], sol: [-1, 0] };
function yolIzgara(p, profil) {
  const hw = 66, hh = 54, m = 14, W = p.en * hw + 2 * m, H = p.boy * hh + 2 * m, s = new Sahne(W, H, profil), b = taban(W, profil);
  if (!YON[p.baslangic.yon]) hata('yon_bilinmiyor');
  for (let i = 0; i < p.en; i++) for (let j = 0; j < p.boy; j++) s.dikdortgen(m + i * hw, m + j * hh, hw, hh, { renk: PALET.gri, kalinlik: 0.8 });
  const hucre = {};
  for (const y of p.yerler) {
    if (y.x < 0 || y.x >= p.en || y.y < 0 || y.y >= p.boy) hata('yer_disi');
    if (gen(y.ad, b) > hw - 4) hata(`metin_sigmiyor:${y.ad}`);
    s.dikdortgen(m + y.x * hw + 3, m + y.y * hh + 3, hw - 6, hh - 6, { dolgu: RENK.acik, renk: PALET.siyah, kalinlik: 1.6 });
    s.metin(m + y.x * hw + hw / 2, m + y.y * hh + hh / 2 + b * 0.35, y.ad, { boyut: b, kalin: true });
    hucre[`${y.x},${y.y}`] = y.ad;
  }
  const bs = p.baslangic, cx = m + bs.x * hw + hw / 2, cy = m + bs.y * hh + hh / 2, [dx, dy] = YON[bs.yon];
  if (hucre[`${bs.x},${bs.y}`]) hata('baslangic_yer_ustunde');
  s.dikdortgen(m + bs.x * hw + 3, m + bs.y * hh + 3, hw - 6, hh - 6, { dolgu: '#FDF3C8', renk: PALET.siyah, kalinlik: 1.6 });
  s.cizgi(cx - dx * 13, cy - 8 - dy * 13, cx + dx * 13, cy - 8 + dy * 13, { renk: RENK.kirmizi, kalinlik: 3.5, ok: true });
  s.metin(cx, cy + 17, 'Başla', { boyut: b - 1, kalin: true });
  return { sahne: s, alt: 'Kareli bir yol haritası; bazı karelerde yer adları vardır, bir karede başlangıç oku bulunur.', olgular: { hucre, baslangic: bs } };
}

// ---------- etiketli resim ----------
const elips = (cx, cy, rx, ry, n = 28) => Array.from({ length: n }, (_, i) => [cx + rx * Math.cos((2 * Math.PI * i) / n), cy + ry * Math.sin((2 * Math.PI * i) / n)]);
const RESIMLER = {
  cicek: { W: 300, H: 250, parcalar: ['kök', 'gövde', 'yaprak', 'çiçek'], ankor: { kök: [132, 226], gövde: [150, 112], yaprak: [112, 152], çiçek: [172, 78] }, etiket: { kök: [262, 214], gövde: [40, 92], yaprak: [40, 172], çiçek: [262, 46] },
    ciz(s) {
      s.dikdortgen(10, 190, 280, 50, { dolgu: '#B98B5E', renk: RENK.kahve, kalinlik: 1.5 });
      for (const [x, y] of [[128, 228], [150, 238], [172, 228]]) s.cizgi(150, 192, x, y, { renk: '#6B4423', kalinlik: 3 });
      s.cizgi(150, 190, 150, 96, { renk: '#2F9E44', kalinlik: 6 });
      s.poligon([[150, 158], [122, 138], [98, 142], [104, 162], [128, 168]], { dolgu: '#43B05A', renk: '#256F34', kalinlik: 1.5 });
      s.poligon([[150, 142], [176, 124], [200, 130], [194, 150], [172, 154]], { dolgu: '#43B05A', renk: '#256F34', kalinlik: 1.5 });
      for (let k = 0; k < 6; k++) s.cember(150 + 22 * Math.cos((k * Math.PI) / 3), 78 + 22 * Math.sin((k * Math.PI) / 3), 13, { dolgu: PALET.pembe, renk: PALET.siyah, kalinlik: 1 });
      s.cember(150, 78, 12, { dolgu: RENK.sari, renk: PALET.siyah, kalinlik: 1 });
    } },
  ev: { W: 300, H: 250, parcalar: ['çatı', 'baca', 'pencere', 'kapı'], ankor: { çatı: [112, 96], baca: [194, 74], pencere: [113, 150], kapı: [150, 200] }, etiket: { çatı: [40, 50], baca: [262, 50], pencere: [40, 160], kapı: [262, 190] },
    ciz(s) {
      s.dikdortgen(20, 220, 260, 14, { dolgu: '#7CC47F', renk: '#4C9A52', kalinlik: 1 });
      s.dikdortgen(184, 62, 20, 44, { dolgu: '#B45309', renk: PALET.siyah, kalinlik: 1.5 });
      s.dikdortgen(80, 120, 140, 100, { dolgu: '#F6E0B5', renk: PALET.siyah, kalinlik: 2 });
      s.poligon([[62, 122], [150, 52], [238, 122]], { dolgu: RENK.kirmizi, renk: PALET.siyah, kalinlik: 2 });
      s.dikdortgen(136, 158, 30, 62, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.5 }); s.nokta(158, 192, { r: 2.5 });
      s.dikdortgen(96, 142, 34, 34, { dolgu: '#BFE3F5', renk: PALET.siyah, kalinlik: 1.5 });
      s.cizgi(113, 142, 113, 176, { kalinlik: 1.5 }); s.cizgi(96, 159, 130, 159, { kalinlik: 1.5 });
    } },
  balik: { W: 300, H: 220, parcalar: ['kuyruk', 'göz', 'sırt yüzgeci', 'solungaç'], ankor: { kuyruk: [254, 110], göz: [88, 100], 'sırt yüzgeci': [150, 54], solungaç: [116, 112] }, etiket: { kuyruk: [262, 190], göz: [40, 40], 'sırt yüzgeci': [225, 22], solungaç: [60, 190] },
    ciz(s) {
      s.poligon([[105, 74], [150, 38], [190, 76]], { dolgu: '#E76F51', renk: PALET.siyah, kalinlik: 1.5 });
      s.poligon([[130, 150], [150, 182], [172, 150]], { dolgu: '#E76F51', renk: PALET.siyah, kalinlik: 1.5 });
      s.poligon([[210, 110], [268, 66], [268, 154]], { dolgu: '#E76F51', renk: PALET.siyah, kalinlik: 1.5 });
      s.poligon(elips(140, 110, 80, 48), { dolgu: '#F4A261', renk: PALET.siyah, kalinlik: 1.8 });
      s.yay(150, 110, 34, 140, 220, { kalinlik: 2.2 });
      s.cember(88, 100, 8, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.5 }); s.nokta(88, 100, { r: 3.5 });
    } },
  bisiklet: { W: 320, H: 230, parcalar: ['tekerlek', 'gidon', 'sele', 'pedal'], ankor: { tekerlek: [272, 166], gidon: [214, 74], sele: [132, 90], pedal: [151, 160] }, etiket: { tekerlek: [298, 104], gidon: [270, 30], sele: [60, 40], pedal: [150, 210] },
    ciz(s) {
      s.cember(85, 150, 40, { renk: PALET.siyah, kalinlik: 4 }); s.cember(235, 150, 40, { renk: PALET.siyah, kalinlik: 4 });
      const F = (a, b2, c2, d) => s.cizgi(a, b2, c2, d, { renk: RENK.mavi, kalinlik: 5 });
      F(85, 150, 150, 150); F(85, 150, 132, 98); F(150, 150, 132, 98); F(132, 98, 208, 98); F(150, 150, 208, 98); F(208, 98, 235, 150); F(208, 98, 203, 76);
      s.cizgi(190, 74, 216, 74, { renk: PALET.siyah, kalinlik: 5 });
      s.dikdortgen(114, 86, 36, 8, { dolgu: PALET.siyah, renk: PALET.siyah }); s.dikdortgen(140, 157, 22, 6, { dolgu: '#374151', renk: PALET.siyah });
      s.nokta(85, 150, { r: 4 }); s.nokta(235, 150, { r: 4 });
    } },
};
function etiketliResim(p, profil) {
  const r = RESIMLER[p.resim]; if (!r) hata('resim_bilinmiyor');
  const s = new Sahne(r.W, r.H, profil); r.ciz(s);
  const nums = Object.values(p.numara).sort().join('');
  if (nums !== '1234' || Object.keys(p.numara).sort().join() !== [...r.parcalar].sort().join()) hata('numara_gecersiz');
  for (const ad of r.parcalar) {
    const [lx, ly] = r.etiket[ad], [ax, ay] = r.ankor[ad], d = Math.hypot(ax - lx, ay - ly), u = [(ax - lx) / d, (ay - ly) / d];
    s.cizgi(lx + u[0] * 16, ly + u[1] * 16, ax, ay, { kalinlik: 1.6 }); s.nokta(ax, ay, { r: 3 });
    s.cember(lx, ly, 14, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.8 });
    s.metin(lx, ly + 5.5, String(p.numara[ad]), { boyut: 16, kalin: true });
  }
  const bolum = Object.fromEntries(Object.entries(p.numara).map(([ad, n]) => [String(n), ad]));
  return { sahne: s, alt: 'Dört bölümü 1, 2, 3 ve 4 numaralarıyla işaretlenmiş bir resim.', olgular: { resim: p.resim, numara: p.numara, bolum } };
}

// ---------- vurgulu metin kartı ----------
// p: { baslik, satirlar:[{metin, stil:'normal'|'kalin'|'altcizili'|'renkli'|'italik'|'buyuk'}] }
function vurgulu(p, profil) {
  const n = p.satirlar.length; if (n < 3 || n > 6) hata('satir_3_6');
  const W = 400, b = taban(W, profil), lh = 36, top = 66, H = top + n * lh + 14, s = new Sahne(W, H, profil);
  s.dikdortgen(8, 8, W - 16, H - 16, { renk: PALET.siyah, kalinlik: 2 });
  s.dikdortgen(8, 8, W - 16, 38, { dolgu: PALET.mavi, renk: PALET.mavi });
  s.metin(W / 2, 33, p.baslik, { boyut: b + 2, kalin: true, renk: BEYAZ });
  const stil = {}, kullan = new Set();
  p.satirlar.forEach((r, i) => {
    const y = top + i * lh + 8, bt = r.stil === 'buyuk' ? b + 3 : b, w = gen(r.metin, bt);
    if (w > W - 56) hata(`metin_sigmiyor:${r.metin}`);
    s.metinKutulari.push({ x0: 26, y0: y - bt, x1: 26 + w, y1: y + bt * 0.25, metin: r.metin, boyut: bt });
    s.parcalar.push(`<text x="26" y="${y}" font-family="Arial, Helvetica, sans-serif" font-size="${bt}" fill="${r.stil === 'renkli' ? PALET.kirmizi : PALET.siyah}"${r.stil === 'kalin' ? ' font-weight="700"' : ''}${r.stil === 'italik' ? ' font-style="italic"' : ''}>${esc(r.metin)}</text>`);
    s.renkler.add(r.stil === 'renkli' ? PALET.kirmizi : PALET.siyah);
    if (r.stil === 'altcizili') s.cizgi(26, y + 5, 26 + r.metin.length * bt * 0.45, y + 5, { kalinlik: 1.6, izgara: true });
    if (!['normal', 'kalin', 'altcizili', 'renkli', 'italik', 'buyuk'].includes(r.stil)) hata('stil_bilinmiyor');
    if (r.stil !== 'normal') { if (kullan.has(r.stil)) hata('stil_tekrar'); kullan.add(r.stil); }
    stil[r.metin] = r.stil;
  });
  const metin_stil = Object.fromEntries(Object.entries(stil).filter(([, v]) => v !== 'normal').map(([k, v]) => [v, k]));
  return { sahne: s, alt: 'Birkaç satırlık bir bilgi kartı; bazı satırlar farklı biçimde yazılmıştır.', olgular: { stil, stil_metin: metin_stil } };
}

// ---------- Venn şeması ----------
// p: { solBaslik, sagBaslik, sol:[...], orta:[...], sag:[...] }  (öğeler en çok 11 harf)
function venn(p, profil) {
  const r = 105, d = 105, m = 15, W = 3 * r + 2 * m, cy = 151, H = 270, b = Math.max(13, taban(W, profil)), s = new Sahne(W, H, profil), c1 = m + r, c2 = c1 + d;
  if (p.sol.length < 1 || p.sol.length > 4 || p.sag.length < 1 || p.sag.length > 4 || p.orta.length < 1 || p.orta.length > 3) hata('venn_oge_sayisi');
  s.cember(c1, cy, r, { renk: PALET.mavi, kalinlik: 2.6 }); s.cember(c2, cy, r, { renk: PALET.turuncu, kalinlik: 2.6 });
  s.metin(c1 - 20, 30, p.solBaslik, { boyut: b + 1, kalin: true }); s.metin(c2 + 20, 30, p.sagBaslik, { boyut: b + 1, kalin: true });
  const bolge = {};
  const yaz = (liste, cx, ad, mx) => liste.forEach((t, i) => {
    if (t.length > 11) hata(`oge_uzun:${t}`);
    const dy = (i - (liste.length - 1) / 2) * 27; if (Math.abs(dy) > 41) hata('venn_satir');
    s.metin(cx, cy + dy + b * 0.35, t, { boyut: b }); if (bolge[t]) hata('oge_tekrar'); bolge[t] = ad;
  });
  yaz(p.sol, 70, 'sol'); yaz(p.orta, 172.5, 'ortak'); yaz(p.sag, 275, 'sag');
  return { sahne: s, alt: 'Birbiriyle kesişen iki çemberden oluşan bir Venn şeması; çemberlerin içinde sözcükler yazılıdır.', olgular: { sol_ozel: p.sol, ortak: p.orta, sag_ozel: p.sag, bolge } };
}

// ---------- kavram haritası ----------
// p: { merkez, dallar:[4–6 öğe] }  '?' soru işareti kutusunu gösterir.
const SLOT = [[75, 46], [325, 46], [60, 145], [340, 145], [75, 244], [325, 244]];
function kavram(p, profil) {
  const n = p.dallar.length; if (n < 4 || n > 6) hata('dal_4_6');
  const W = 400, H = 290, b = taban(W, profil), s = new Sahne(W, H, profil), cx = 200, cy = 145, chw = 66, chh = 24, shw = 54, shh = 18;
  const slot = n === 4 ? [0, 1, 4, 5] : n === 5 ? [0, 1, 2, 4, 5] : [0, 1, 2, 3, 4, 5];
  const cik = (hw, hh, dx, dy) => Math.min(dx ? hw / Math.abs(dx) : Infinity, dy ? hh / Math.abs(dy) : Infinity);
  p.dallar.forEach((t, i) => {
    const [sx, sy] = SLOT[slot[i]], dx = sx - cx, dy = sy - cy, t0 = cik(chw, chh, dx, dy), t1 = 1 - cik(shw, shh, dx, dy);
    s.cizgi(cx + dx * t0, cy + dy * t0, cx + dx * t1, cy + dy * t1, { kalinlik: 1.8 });
  });
  const kutu = (x, y, hw, hh, t, merkez) => {
    if (gen(t, b) > 2 * hw - 8) hata(`metin_sigmiyor:${t}`);
    s.dikdortgen(x - hw, y - hh, 2 * hw, 2 * hh, { dolgu: t === '?' ? '#FDF3C8' : merkez ? '#DCEBFA' : BEYAZ, renk: PALET.siyah, kalinlik: merkez ? 2.2 : 1.5 });
    s.metin(x, y + b * 0.35, t, { boyut: merkez ? b + 1 : b, kalin: merkez || t === '?' });
  };
  kutu(cx, cy, chw, chh, p.merkez, true);
  p.dallar.forEach((t, i) => kutu(SLOT[slot[i]][0], SLOT[slot[i]][1], shw, shh, t, false));
  return { sahne: s, alt: 'Ortadaki bir kutudan çevresindeki kutulara çizgilerle bağlanan bir kavram haritası; kutulardan biri soru işaretidir.', olgular: { merkez: p.merkez, dallar: p.dallar } };
}

// ---------- akış şeması (işlem basamakları) ----------
// p: { baslik, adimlar:[3–6 metin, en çok 26 harf] }
function akis(p, profil) {
  const n = p.adimlar.length; if (n < 3 || n > 6) hata('adim_3_6');
  const W = 340, bh = 32, gap = 22, top = 48, H = top + n * bh + (n - 1) * gap + 16, b = taban(W, profil), s = new Sahne(W, H, profil), bx = 60, bw = W - bx - 14;
  s.metin(W / 2, 26, p.baslik, { boyut: b + 1, kalin: true });
  p.adimlar.forEach((t, i) => {
    const y = top + i * (bh + gap); if (gen(t, b) > bw - 16) hata(`metin_sigmiyor:${t}`);
    s.dikdortgen(bx, y, bw, bh, { dolgu: RENK.acik, renk: PALET.siyah, kalinlik: 1.6 });
    s.cember(32, y + bh / 2, 13, { dolgu: PALET.mavi, renk: PALET.mavi, kalinlik: 1 });
    s.metin(32, y + bh / 2 + b * 0.35, String(i + 1), { boyut: b, kalin: true, renk: BEYAZ });
    s.metin(bx + 10, y + bh / 2 + b * 0.35, t, { boyut: b, hiza: 'start' });
    if (i < n - 1) s.cizgi(bx + bw / 2, y + bh, bx + bw / 2, y + bh + gap, { ok: true, kalinlik: 2 });
  });
  return { sahne: s, alt: 'Aşağı doğru oklarla bağlanmış numaralı kutulardan oluşan bir akış şeması.', olgular: { adimlar: p.adimlar, sira: Object.fromEntries(p.adimlar.map((t, i) => [t, i + 1])) } };
}

// ---------- afiş ----------
// p: { metin, simge:'yildiz'|'daire'|'kalp'|'ucgen'|'kitap', tema:0–3 }
const TEMA = [PALET.mavi, PALET.yesil, PALET.pembe, PALET.kirmizi];
function sar(metin, max) {
  const satirlar = []; let cur = '';
  for (const k of String(metin).split(' ')) { if (cur && (cur + ' ' + k).length > max) { satirlar.push(cur); cur = k; } else cur = cur ? `${cur} ${k}` : k; }
  if (cur) satirlar.push(cur); return satirlar;
}
function afis(p, profil) {
  const W = 380, b = taban(W, profil), bs = b + 3, satirlar = sar(p.metin, 25);
  if (satirlar.length > 4) hata('afis_uzun');
  const H = 100 + satirlar.length * 34 + 44, s = new Sahne(W, H, profil), c = TEMA[p.tema ?? 0];
  s.dikdortgen(6, 6, W - 12, H - 12, { renk: c, kalinlik: 3 });
  s.dikdortgen(6, 6, W - 12, 64, { dolgu: c, renk: c });
  s.dikdortgen(6, H - 26, W - 12, 20, { dolgu: c, renk: c });
  const x = W / 2, y = 38;
  if (p.simge === 'yildiz') s.poligon(Array.from({ length: 10 }, (_, i) => { const a = (-90 + 36 * i) * Math.PI / 180, q = i % 2 ? 11 : 26; return [x + q * Math.cos(a), y + q * Math.sin(a)]; }), { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 });
  else if (p.simge === 'daire') { s.cember(x, y, 22, { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); s.cember(x, y, 11, { dolgu: c, renk: c, kalinlik: 1 }); }
  else if (p.simge === 'kalp') { s.cember(x - 11, y - 6, 13, { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); s.cember(x + 11, y - 6, 13, { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); s.poligon([[x - 23, y - 1], [x + 23, y - 1], [x, y + 24]], { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 }); }
  else if (p.simge === 'ucgen') s.poligon([[x, y - 24], [x + 26, y + 20], [x - 26, y + 20]], { dolgu: BEYAZ, renk: BEYAZ, kalinlik: 1 });
  else if (p.simge === 'kitap') { s.dikdortgen(x - 28, y - 18, 26, 36, { dolgu: BEYAZ, renk: c, kalinlik: 2 }); s.dikdortgen(x + 2, y - 18, 26, 36, { dolgu: BEYAZ, renk: c, kalinlik: 2 }); }
  else hata('simge_bilinmiyor');
  satirlar.forEach((t, i) => { if (gen(t, bs) > W - 40) hata(`metin_sigmiyor:${t}`); s.metin(W / 2, 112 + i * 34, t, { boyut: bs, kalin: true }); });
  return { sahne: s, alt: 'Renkli bir şeridi, bir simgesi ve birkaç satır yazısı olan bir afiş.', olgular: { metin: p.metin, satirlar } };
}

// ---------- çizgi grafiği ----------
// p: { baslik, birim, etiketler:[...], degerler:[...], max, adim }  (değerler adım/2'nin katı)
function cizgiGrafik(p, profil) {
  const n = p.etiketler.length; if (n < 4 || n > 7 || p.degerler.length !== n) hata('nokta_sayisi_4_7');
  const W = 380, H = 262, sol = 52, sag = W - 16, ust = 64, alt = 208, b = taban(W, profil), s = new Sahne(W, H, profil);
  const Y = (v) => alt - (v / p.max) * (alt - ust), slot = (sag - sol) / n, X = (i) => sol + slot * (i + 0.5);
  s.metin(W / 2, 22, p.baslik, { boyut: b + 1, kalin: true }); s.metin(sol, ust - 16, p.birim, { boyut: b, hiza: 'start' });
  for (let v = 0; v <= p.max + 1e-9; v += p.adim) { s.cizgi(sol, Y(v), sag, Y(v), { renk: PALET.gri, kalinlik: 0.6, izgara: true }); s.metin(sol - 8, Y(v) + 5, String(v), { hiza: 'end', boyut: b }); }
  s.cizgi(sol, ust - 6, sol, alt); s.cizgi(sol, alt, sag, alt);
  const degerler = {};
  p.degerler.forEach((v, i) => {
    const k = v / (p.adim / 2); if (Math.abs(k - Math.round(k)) > 1e-9 || v < 0 || v > p.max) hata('deger_gecersiz');
    if (i) s.cizgi(X(i - 1), Y(p.degerler[i - 1]), X(i), Y(v), { renk: PALET.mavi, kalinlik: 2.8 });
    degerler[p.etiketler[i]] = v;
  });
  p.degerler.forEach((v, i) => { s.nokta(X(i), Y(v), { r: 4.5, renk: PALET.mavi }); s.metin(X(i), alt + 22, p.etiketler[i], { boyut: b }); });
  const tekil = (h) => { const e = p.degerler.map((v, i) => [v, i]).filter(([v]) => v === h); return e.length === 1 ? p.etiketler[e[0][1]] : null; };
  const fark = p.degerler.slice(1).map((v, i) => ({ aralik: `${p.etiketler[i]}–${p.etiketler[i + 1]}`, fark: v - p.degerler[i] }));
  const mxA = Math.max(...fark.map((f) => f.fark)), mnA = Math.min(...fark.map((f) => f.fark));
  const tek = (h) => { const e = fark.filter((f) => f.fark === h); return e.length === 1 ? e[0].aralik : null; };
  return { sahne: s, alt: `Çizgi grafiği: ${p.baslik}. Yatay eksende ${n} nokta vardır.`, olgular: { degerler, en_yuksek: tekil(Math.max(...p.degerler)), en_dusuk: tekil(Math.min(...p.degerler)), fark, en_buyuk_artis: mxA > 0 ? tek(mxA) : null, en_buyuk_dusus: mnA < 0 ? tek(mnA) : null, dusen: fark.filter((f) => f.fark < 0).map((f) => f.aralik) } };
}

// ---------- daire grafiği ----------
// p: { baslik, dilimler:[{ad, yuzde}] (toplam 100, her biri ≥10 ve 5'in katı), toplam? (kişi sayısı) , nesne? }
const DILIM_RENK = [PALET.mavi, PALET.turuncu, PALET.yesil, PALET.pembe, PALET.gok];
function daireGrafik(p, profil) {
  const n = p.dilimler.length; if (n < 3 || n > 5) hata('dilim_3_5');
  if (p.dilimler.reduce((t, d) => t + d.yuzde, 0) !== 100 || p.dilimler.some((d) => d.yuzde < 10 || d.yuzde % 5)) hata('yuzde_gecersiz');
  const W = 400, H = 280, cx = 200, cy = 140, r = 76, b = taban(W, profil), s = new Sahne(W, H, profil);
  s.metin(W / 2, 22, p.baslik, { boyut: b + 1, kalin: true });
  let cum = 0; const yuzde = {};
  p.dilimler.forEach((d, i) => {
    const a1 = 90 - cum * 3.6, a0 = 90 - (cum + d.yuzde) * 3.6, mid = ((a0 + a1) / 2) * Math.PI / 180;
    s.dilim(cx, cy, r, a0, a1, { dolgu: DILIM_RENK[i], renk: PALET.siyah, kalinlik: 1.6 });
    const lx = cx + (r + 10) * Math.cos(mid), ly = cy - (r + 10) * Math.sin(mid) + b * 0.35 + (Math.sin(mid) > 0.8 ? -4 : Math.sin(mid) < -0.8 ? 6 : 0);
    s.metin(lx, ly, `${d.ad} %${d.yuzde}`, { boyut: b, kalin: true, hiza: Math.cos(mid) > 0.25 ? 'start' : Math.cos(mid) < -0.25 ? 'end' : 'middle' });
    yuzde[d.ad] = d.yuzde; cum += d.yuzde;
  });
  if (p.toplam) s.metin(W / 2, H - 12, `Toplam: ${p.toplam} ${p.nesne ?? 'kişi'}`, { boyut: b });
  const e = Object.entries(yuzde).sort((x, y) => y[1] - x[1]);
  const sayi = p.toplam ? Object.fromEntries(Object.entries(yuzde).map(([k, v]) => [k, (v * p.toplam) / 100])) : null;
  return { sahne: s, alt: `Daire grafiği: ${p.baslik}.`, olgular: { yuzde, sayi, en_cok: e[0][1] > e[1][1] ? e[0][0] : null, en_az: e[e.length - 1][1] < e[e.length - 2][1] ? e[e.length - 1][0] : null } };
}

// ---------- karikatür benzeri sahneler ----------
const SAHNELER = new Set(['musluk', 'cop', 'isik', 'telefon', 'agac', 'gurultu', 'sira', 'yardim', 'kitap']);
// p: { sahne, ayna:bool, balon:[satırlar]|null, renk:0–3 }
const GOMLEK = [PALET.turuncu, PALET.yesil, PALET.pembe, PALET.gok];
function sahneCiz(p, profil) {
  if (!SAHNELER.has(p.sahne)) hata('sahne_bilinmiyor');
  const W = 380, H = 250, s = new Sahne(W, H, profil), b = taban(W, profil) + 1, ay = !!p.ayna, X = (x) => (ay ? W - x : x), gm = GOMLEK[p.renk ?? 0];
  const R = (x, y, w, h, o) => s.dikdortgen(ay ? W - x - w : x, y, w, h, o);
  const Pg = (pts, o) => s.poligon(pts.map(([x, y]) => [X(x), y]), o);
  const L = (x1, y1, x2, y2, renk = PALET.siyah, k = 4, kesik = false) => s.cizgi(X(x1), y1, X(x2), y2, { renk, kalinlik: k, izgara: true, kesik });
  const C = (x, y, r, o) => s.cember(X(x), y, r, o);
  const kisi = (x, y, renk, { kol = 'asagi', egik = 0 } = {}) => {
    L(x - 7, y + 62, x - 9, y + 96, '#374151', 6); L(x + 7, y + 62, x + 9, y + 96, '#374151', 6);
    Pg([[x - 13, y + 16], [x + 13, y + 16], [x + 16, y + 64], [x - 16, y + 64]], { dolgu: renk, renk: PALET.siyah, kalinlik: 1.5 });
    C(x, y + egik, 14, { dolgu: RENK.ten, renk: PALET.siyah, kalinlik: 1.6 });
    const gz = (dx) => { s.nokta(X(x + dx), y - 2 + egik, { r: 1.8 }); }; gz(-5); gz(5);
    if (kol === 'asagi') { L(x - 13, y + 22, x - 20, y + 54, RENK.ten, 5); L(x + 13, y + 22, x + 20, y + 54, RENK.ten, 5); }
    return { x, y };
  };
  const balon = (satirlar, bx, by, kx, ky) => {
    if (!satirlar) return; const w = Math.max(...satirlar.map((t) => gen(t, b))) + 20, h = satirlar.length * b * 1.25 + 10;
    const gx = ay ? W - bx - w : bx;
    s.dikdortgen(gx, by, w, h, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.6 });
    const tb = Math.min(Math.max(X(kx), gx + 24), gx + w - 24); s.poligon([[X(kx), ky], [tb - 9, by + h - 1], [tb + 9, by + h - 1]], { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.6 });
    satirlar.forEach((t, i) => s.metin(gx + w / 2, by + 8 + b + i * b * 1.25 - 3, t, { boyut: b }));
  };
  const zemin = () => s.dikdortgen(0, 214, W, 36, { dolgu: '#E5E7EB', renk: '#D1D5DB', kalinlik: 1 });
  switch (p.sahne) {
    case 'musluk': {
      zemin(); R(222, 150, 130, 64, { dolgu: '#9CA3AF', renk: PALET.siyah, kalinlik: 1.5 }); R(232, 138, 110, 14, { dolgu: '#D1D5DB', renk: PALET.siyah, kalinlik: 1.5 });
      L(318, 138, 318, 106, '#6B7280', 7); L(318, 106, 280, 106, '#6B7280', 7);
      for (const dx of [-5, 0, 5]) L(280 + dx, 114, 280 + dx, 136, '#3B9AE1', 2.5);
      s.poligon(elips(X(290), 214, 62, 8).map(([x, y]) => [x, y]), { dolgu: '#8EC9F0', renk: '#3B9AE1', kalinlik: 1 });
      L(356, 152, 356, 204, '#3B9AE1', 3); L(224, 152, 224, 204, '#3B9AE1', 3);
      kisi(150, 120, gm); L(163, 142, 176, 124, RENK.ten, 5); L(176, 124, 164, 120, RENK.kirmizi, 4); balon(p.balon, 14, 14, 150, 104); break;
    }
    case 'cop': {
      zemin(); kisi(120, 120, gm, { kol: 'ozel' }); L(107, 142, 100, 174, RENK.ten, 5); L(133, 142, 158, 166, RENK.ten, 5);
      C(163, 168, 6, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.3 }); L(163, 176, 163, 204, '#6B7280', 1.6, true); C(163, 208, 6, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.3 });
      C(205, 210, 5, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.2 }); C(70, 211, 5, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.2 });
      Pg([[270, 160], [326, 160], [320, 214], [276, 214]], { dolgu: '#2F9E44', renk: PALET.siyah, kalinlik: 1.6 }); R(264, 150, 68, 11, { dolgu: '#256F34', renk: PALET.siyah, kalinlik: 1.6 });
      balon(p.balon, 160, 20, 130, 105); break;
    }
    case 'isik': {
      s.dikdortgen(0, 200, W, 50, { dolgu: '#E5E7EB', renk: '#D1D5DB', kalinlik: 1 });
      R(290, 34, 70, 70, { dolgu: '#BFE3F5', renk: PALET.siyah, kalinlik: 2 }); C(325, 69, 15, { dolgu: RENK.sari, renk: '#B79B00', kalinlik: 1.5 }); L(325, 34, 325, 104, PALET.siyah, 1.5); L(290, 69, 360, 69, PALET.siyah, 1.5);
      L(130, 0, 130, 42, PALET.siyah, 2); Pg([[112, 42], [148, 42], [160, 64], [100, 64]], { dolgu: '#6B7280', renk: PALET.siyah, kalinlik: 1.5 }); C(130, 72, 9, { dolgu: RENK.sari, renk: '#B79B00', kalinlik: 1.5 });
      for (const [dx, dy] of [[-30, 22], [-14, 30], [0, 34], [14, 30], [30, 22]]) L(130 + dx * 0.5, 82 + dy * 0.3, 130 + dx * 1.4, 82 + dy * 2, RENK.sari, 3);
      R(40, 176, 250, 12, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.5 }); R(40, 154, 250, 24, { dolgu: '#BFDBFE', renk: PALET.siyah, kalinlik: 1.5 }); R(46, 142, 46, 14, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.3 });
      C(66, 140, 14, { dolgu: RENK.ten, renk: PALET.siyah, kalinlik: 1.6 }); L(62, 139, 68, 139, PALET.siyah, 1.5); R(96, 142, 190, 22, { dolgu: gm, renk: PALET.siyah, kalinlik: 1.5 });
      s.metin(X(60), 112, 'Zzz', { boyut: b + 4, kalin: true, hiza: 'middle' }); break;
    }
    case 'telefon': {
      zemin(); R(40, 168, 300, 10, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.5 }); R(60, 178, 8, 36, { dolgu: RENK.kahve, renk: PALET.siyah }); R(312, 178, 8, 36, { dolgu: RENK.kahve, renk: PALET.siyah });
      for (const [x, k] of [[110, 0], [250, 1]]) { kisi(x, 84, GOMLEK[(p.renk + k) % 4], { kol: 'ozel', egik: 6 }); L(x - 13, 106, x - 4, 134, RENK.ten, 5); L(x + 13, 106, x + 4, 134, RENK.ten, 5); R(x - 8, 124, 16, 22, { dolgu: '#1F2937', renk: PALET.siyah, kalinlik: 1.2 }); R(x - 6, 127, 12, 15, { dolgu: '#7DD3FC', renk: '#7DD3FC', kalinlik: 0.5 }); }
      balon(p.balon, 120, 8, 250, 76); break;
    }
    case 'agac': {
      zemin(); R(278, 112, 24, 102, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.6 }); s.poligon(elips(X(290), 78, 56, 44), { dolgu: '#43B05A', renk: '#256F34', kalinlik: 1.6 });
      Pg([[278, 150], [290, 158], [278, 168]], { dolgu: '#F6E0B5', renk: PALET.siyah, kalinlik: 1 });
      for (const [x, w] of [[50, 30], [100, 26]]) { R(x, 200, w, 14, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.4 }); s.poligon(elips(X(x + w / 2), 200, w / 2, 4), { dolgu: '#F6E0B5', renk: PALET.siyah, kalinlik: 1.2 }); }
      kisi(210, 120, gm, { kol: 'ozel' }); L(197, 142, 190, 174, RENK.ten, 5); L(223, 142, 248, 158, RENK.ten, 5); L(246, 160, 262, 134, RENK.kahve, 5); Pg([[256, 130], [276, 130], [270, 152]], { dolgu: '#9CA3AF', renk: PALET.siyah, kalinlik: 1.4 });
      balon(p.balon, 20, 20, 205, 105); break;
    }
    case 'gurultu': {
      zemin(); R(150, 136, 62, 78, { dolgu: '#374151', renk: PALET.siyah, kalinlik: 1.6 }); C(181, 166, 16, { dolgu: '#9CA3AF', renk: PALET.siyah, kalinlik: 1.5 }); C(181, 196, 7, { dolgu: '#9CA3AF', renk: PALET.siyah, kalinlik: 1.5 });
      for (const rr of [22, 36, 50]) { const m0 = ay ? 140 : -40, m1 = ay ? 220 : 40; s.yay(X(212), 165, rr, m0, m1, { kalinlik: 2.2 }); }
      kisi(80, 120, gm); kisi(300, 120, GOMLEK[(p.renk + 2) % 4], { kol: 'ozel' }); L(287, 142, 288, 112, RENK.ten, 5); L(313, 142, 312, 112, RENK.ten, 5);
      balon(p.balon, 10, 8, 80, 104); break;
    }
    case 'sira': {
      zemin(); R(300, 130, 60, 84, { dolgu: '#9CA3AF', renk: PALET.siyah, kalinlik: 1.6 }); R(296, 122, 68, 10, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.5 });
      kisi(50, 120, GOMLEK[0], {}); kisi(105, 120, GOMLEK[1], {}); kisi(160, 120, GOMLEK[2], {});
      kisi(250, 120, gm, { kol: 'ozel' }); L(237, 142, 232, 174, RENK.ten, 5); L(263, 142, 280, 116, RENK.ten, 5);
      balon(p.balon, 160, 12, 250, 105); break;
    }
    case 'yardim': {
      zemin(); kisi(120, 120, GOMLEK[0], { kol: 'ozel' }); kisi(260, 120, gm, { kol: 'ozel' });
      R(158, 150, 64, 40, { dolgu: '#D4A373', renk: PALET.siyah, kalinlik: 1.6 }); L(158, 162, 222, 162, '#B07F4E', 2);
      L(107, 142, 100, 176, RENK.ten, 5); L(133, 142, 160, 168, RENK.ten, 5); L(247, 142, 220, 168, RENK.ten, 5); L(273, 142, 280, 176, RENK.ten, 5);
      balon(p.balon, 120, 8, 190, 108); break;
    }
    case 'kitap': {
      zemin(); R(236, 120, 120, 6, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.4 }); R(236, 176, 120, 6, { dolgu: RENK.kahve, renk: PALET.siyah, kalinlik: 1.4 });
      [[240, 82], [258, 90], [272, 76], [292, 86], [310, 80], [326, 90]].forEach(([x, h], i) => R(x, 120 - h * 0.5, 14, h * 0.5, { dolgu: GOMLEK[i % 4], renk: PALET.siyah, kalinlik: 1.2 }));
      [[240, 80], [258, 90], [276, 74], [296, 84], [314, 78]].forEach(([x, h], i) => R(x, 176 - h * 0.5, 16, h * 0.5, { dolgu: GOMLEK[(i + 2) % 4], renk: PALET.siyah, kalinlik: 1.2 }));
      kisi(130, 120, gm, { kol: 'ozel' }); L(117, 142, 112, 160, RENK.ten, 5); L(143, 142, 148, 160, RENK.ten, 5); R(108, 156, 44, 28, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 1.6 }); L(130, 156, 130, 184, PALET.siyah, 1.5);
      C(130, 70, 10, { dolgu: RENK.sari, renk: '#B79B00', kalinlik: 1.4 }); for (const a of [-60, -30, 0, 30, 60]) L(130 + 14 * Math.sin((a * Math.PI) / 180), 70 - 14 * Math.cos((a * Math.PI) / 180), 130 + 22 * Math.sin((a * Math.PI) / 180), 70 - 22 * Math.cos((a * Math.PI) / 180), RENK.sari, 2.5);
      balon(p.balon, 160, 10, 135, 100); break;
    }
    default: hata('sahne_ciz');
  }
  return { sahne: s, alt: 'Çizgilerle çizilmiş, kısa bir olayı gösteren karikatür tarzı bir sahne.', olgular: { sahne: p.sahne, balon: p.balon ? p.balon.join(' ') : null } };
}

// __TIP_SON__
export const TIPLER_A7 = {
  'a7-cizelge': cizelge,
  'a7-isaret': isaret,
  'a7-yol-izgara': yolIzgara,
  'a7-etiketli-resim': etiketliResim,
  'a7-vurgulu-metin': vurgulu,
  'a7-venn': venn,
  'a7-kavram': kavram,
  'a7-akis': akis,
  'a7-afis': afis,
  'a7-cizgi-grafik': cizgiGrafik,
  'a7-daire-grafik': daireGrafik,
  'a7-sahne': sahneCiz,
};
