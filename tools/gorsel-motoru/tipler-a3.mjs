// Ajan A3 için şekil tipleri (Matematik 4. ve 6. sınıf + 5. sınıf düzeltmesi). Sözleşme tipler.mjs ile aynı:
// render(parametreler, profil) -> { sahne, alt, olgular }. Tip adları 'a3-' önekiyle başlar.
// Alt metinler cevabı ve şekildeki sayıları yazmaz (kapı: alt_metin_cevabi_sizdiriyor).
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const yuv2 = (n) => Math.round(n * 100) / 100;
const BEYAZ = '#FFFFFF';

// ---------- a3-kesisen-dogrular ----------
// tipler.mjs'teki 'kesisen-dogrular' ile aynı çizim; tek fark alt metin: açı değerini yazmaz.
// (Orijinal alt metin işaretli açı değerlerini yazdığı için, değer yalnız şekilde verildiğinde cevabı sızdırır.)
// parametreler: { dogrular:['d','e'], theta:1..179, isaretler:[{bolge:0..3, goster:'deger'|'sembol'|'yok', sembol?}], olcekli? }
function kesisenDogrular(p, profil) {
  const W = 300, H = 240, cx = 150, cy = 120, L = 105, s = new Sahne(W, H, profil);
  const th = p.theta; if (!(th > 0 && th < 180)) hata('theta_aralik_disi');
  const gorsel = p.olcekli ? th : (th < 90 ? 55 : th === 90 ? 90 : 125);
  const f1 = 15; const f2 = f1 + gorsel;
  const uc = (fi, uz) => [cx + uz * Math.cos(aciRad(fi)), cy - uz * Math.sin(aciRad(fi))];
  const a1 = uc(f1, L), a2 = uc(f1 + 180, L), b1 = uc(f2, L), b2 = uc(f2 + 180, L);
  s.cizgi(a2[0], a2[1], a1[0], a1[1]); s.cizgi(b2[0], b2[1], b1[0], b1[1]);
  s.metin(a1[0] + 4, a1[1] - 4, p.dogrular[0], { kalin: true, hiza: 'start' });
  s.metin(b1[0] + 4, b1[1] - 4, p.dogrular[1], { kalin: true, hiza: 'start' });
  const baslangic = [f1, f2, f1 + 180, f2 + 180, f1 + 360];
  const degerler = [th, 180 - th, th, 180 - th];
  for (const i of p.isaretler) {
    const a0 = baslangic[i.bolge];
    const son = i.bolge === 3 ? f1 + 360 : baslangic[i.bolge + 1];
    s.yay(cx, cy, 26, a0, son);
    if (i.goster === 'yok') continue;
    const orta = (a0 + son) / 2, q = uc(orta, 42);
    s.metin(q[0], q[1] + 5, i.goster === 'deger' ? `${degerler[i.bolge]}°` : i.sembol, { kalin: true });
  }
  const olgular = { bolge_degerleri: degerler, ters_acilar: [[0, 2], [1, 3]], komsu_butunler: [[0, 1], [1, 2], [2, 3], [3, 0]], theta: th };
  const alt = `${p.dogrular[0]} ve ${p.dogrular[1]} doğruları bir noktada kesişiyor; ${p.olcekli ? '' : 'şekil ölçekli değildir; '}açılardan biri ölçüsüyle yazılmış, biri işaretle gösterilmiştir.`;
  return { sahne: s, alt, olgular };
}

// ---------- a3-kesir-modeli-cok ----------
// Aynı büyüklükte birkaç şekil: `butun` tanesi tamamen, son şekil `pay` parça taralı (pay=0 ise son şekil yok).
// parametreler: { tur:'serit'|'pasta', payda:2..10, butun:0..3, pay:0..payda-1 }
function kesirCok(p, profil) {
  const { payda, butun, pay } = p;
  if (!(payda >= 2 && payda <= 10)) hata('payda_aralik');
  if (!(butun >= 0 && butun <= 3) || !(pay >= 0 && pay < payda)) hata('butun_pay_aralik');
  const n = butun + (pay > 0 ? 1 : 0); if (n < 1) hata('sekil_yok');
  const dolu = (i) => (i < butun ? payda : pay);
  let s;
  if (p.tur === 'serit') {
    const bw = 220, bh = 26, gap = 14, m = 14, W = bw + 2 * m, H = n * bh + (n - 1) * gap + 2 * m;
    s = new Sahne(W, H, profil);
    for (let i = 0; i < n; i++) for (let j = 0; j < payda; j++) {
      s.dikdortgen(m + (j * bw) / payda, m + i * (bh + gap), bw / payda, bh, { dolgu: j < dolu(i) ? PALET.turuncu : BEYAZ, renk: PALET.siyah, kalinlik: 1.6 });
    }
  } else if (p.tur === 'pasta') {
    const r = 40, gap = 14, m = 14, W = n * 2 * r + (n - 1) * gap + 2 * m, H = 2 * r + 2 * m;
    s = new Sahne(W, H, profil);
    const adim = 360 / payda;
    for (let i = 0; i < n; i++) for (let j = 0; j < payda; j++) {
      s.dilim(m + r + i * (2 * r + gap), m + r, r, 90 - (j + 1) * adim, 90 - j * adim, { dolgu: j < dolu(i) ? PALET.turuncu : BEYAZ, renk: PALET.siyah, kalinlik: 1.6 });
    }
  } else hata(`tur_bilinmiyor:${p.tur}`);
  const bilesik = butun * payda + pay;
  const olgular = { payda, butun_sekil: butun, kalan_parca: pay, bilesik_pay: bilesik, bilesik: `${bilesik}/${payda}`, tam_sayili: pay > 0 ? `${butun} ${pay}/${payda}` : `${butun}` };
  return { sahne: s, alt: 'Aynı büyüklükte, eş parçalara bölünmüş şekillerden oluşan bir kesir modeli; parçaların bir kısmı taralıdır.', olgular };
}

// ---------- a3-kesir-seritleri ----------
// Aynı uzunlukta etiketli şeritler; her şeridin ilk `pay` parçası taralıdır.
// parametreler: { seritler:[{ad, payda, pay}] }  (2–4 şerit; değerler birbirinden farklı olmalı)
function kesirSeritleri(p, profil) {
  const n = p.seritler.length; if (n < 2 || n > 4) hata('serit_sayisi_2_4');
  const bw = 232, bh = 26, gap = 14, m = 14, sol = 46, W = sol + bw + m, H = n * bh + (n - 1) * gap + 2 * m;
  const s = new Sahne(W, H, profil);
  const deger = {};
  p.seritler.forEach((k, i) => {
    if (!(k.pay >= 1 && k.pay <= k.payda && k.payda <= 12)) hata(`kesir_gecersiz:${k.ad}`);
    const y = m + i * (bh + gap);
    for (let j = 0; j < k.payda; j++) s.dikdortgen(sol + (j * bw) / k.payda, y, bw / k.payda, bh, { dolgu: j < k.pay ? PALET.turuncu : BEYAZ, renk: PALET.siyah, kalinlik: 1.5 });
    s.metin(sol - 18, y + bh / 2 + 5, k.ad, { kalin: true });
    deger[k.ad] = k.pay / k.payda;
  });
  const vals = Object.values(deger);
  for (let i = 0; i < vals.length; i++) for (let j = i + 1; j < vals.length; j++) if (Math.abs(vals[i] - vals[j]) < 1e-9) hata('esit_deger');
  const sirali = Object.keys(deger).sort((a, b) => deger[b] - deger[a]);
  const olgular = {
    kesirler: Object.fromEntries(p.seritler.map((k) => [k.ad, `${k.pay}/${k.payda}`])),
    buyukten_kucuge: sirali, kucukten_buyuge: [...sirali].reverse(), en_buyuk: sirali[0], en_kucuk: sirali[sirali.length - 1],
  };
  return { sahne: s, alt: `Aynı uzunlukta ${n} şerit; her biri eş parçalara bölünmüş ve bir kısmı taralıdır. Şeritler ${p.seritler.map((k) => k.ad).join(', ')} harfleriyle adlandırılmıştır.`, olgular };
}

// ---------- a3-simetri ----------
// Şekil kütüphanesi (birim koordinat, y aşağı). Çizgiler ağırlık merkezinden geçer; ofsetli olanlar kaydırılmıştır.
const KUT = (n, ba = -90) => Array.from({ length: n }, (_, i) => [Math.cos(aciRad(ba + (360 * i) / n)), Math.sin(aciRad(ba + (360 * i) / n))]);
export const SEKILLER = {
  ikizkenar_ucgen: [[0, -1], [-0.85, 0.8], [0.85, 0.8]],
  eskenar_ucgen: KUT(3),
  ikizkenar_yamuk: [[-0.55, -0.7], [0.55, -0.7], [1, 0.7], [-1, 0.7]],
  dikdortgen: [[-1, -0.6], [1, -0.6], [1, 0.6], [-1, 0.6]],
  kare: [[-0.8, -0.8], [0.8, -0.8], [0.8, 0.8], [-0.8, 0.8]],
  eskenar_dortgen: [[0, -1], [0.65, 0], [0, 1], [-0.65, 0]],
  paralelkenar: [[-0.4, -0.6], [1, -0.6], [0.4, 0.6], [-1, 0.6]],
  ucurtma: [[0, -1], [0.62, -0.15], [0, 0.95], [-0.62, -0.15]],
  ev: [[-0.8, 0.8], [0.8, 0.8], [0.8, -0.1], [0, -0.95], [-0.8, -0.1]],
  duzgun_besgen: KUT(5),
  duzgun_altigen: KUT(6),
  ok: [[-1, -0.25], [0.2, -0.25], [0.2, -0.7], [1, 0], [0.2, 0.7], [0.2, 0.25], [-1, 0.25]],
};
function agirlikMerkezi(pts) {
  let a = 0, cx = 0, cy = 0;
  for (let i = 0; i < pts.length; i++) {
    const [x0, y0] = pts[i], [x1, y1] = pts[(i + 1) % pts.length], c = x0 * y1 - x1 * y0;
    a += c; cx += (x0 + x1) * c; cy += (y0 + y1) * c;
  }
  return [cx / (3 * a), cy / (3 * a)];
}
// c noktasından geçen, yönü psi (derece, ekran koordinatı) olan çizgi eksen mi? (köşe kümesi yansımada aynı kalır mı)
function eksenMi(pts, c, psi, kaydir = [0, 0]) {
  const dx = Math.cos(aciRad(psi)), dy = Math.sin(aciRad(psi)), px = c[0] + kaydir[0], py = c[1] + kaydir[1];
  const anahtar = ([x, y]) => `${Math.round(x * 1000) / 1000},${Math.round(y * 1000) / 1000}`;
  const kume = new Set(pts.map(anahtar));
  return pts.every(([x, y]) => {
    const t = (x - px) * dx + (y - py) * dy, fx = px + t * dx, fy = py + t * dy;
    return kume.has(anahtar([2 * fx - x, 2 * fy - y]));
  });
}
// Aday çizgiler: ad -> { psi, kaydir }
const ADAY_CIZGI = {
  dikey: { psi: 90, kaydir: [0, 0] }, yatay: { psi: 0, kaydir: [0, 0] }, capraz1: { psi: 45, kaydir: [0, 0] }, capraz2: { psi: 135, kaydir: [0, 0] },
  egik1: { psi: 65, kaydir: [0, 0] }, egik2: { psi: 115, kaydir: [0, 0] }, egik3: { psi: 20, kaydir: [0, 0] }, egik4: { psi: 160, kaydir: [0, 0] },
  dikey_sag: { psi: 90, kaydir: [0.38, 0] }, dikey_sol: { psi: 90, kaydir: [-0.38, 0] }, yatay_alt: { psi: 0, kaydir: [0, 0.32] }, yatay_ust: { psi: 0, kaydir: [0, -0.32] },
};
export const ADAY_CIZGI_ADLARI = Object.keys(ADAY_CIZGI);
export function eksenOzellikleri(sekil, cizgiAdi) {
  const pts = SEKILLER[sekil] ?? hata(`sekil_yok:${sekil}`), c = agirlikMerkezi(pts), a = ADAY_CIZGI[cizgiAdi] ?? hata(`cizgi_yok:${cizgiAdi}`);
  return eksenMi(pts, c, a.psi, a.kaydir);
}
export function eksenSayisi(sekil) {
  const pts = SEKILLER[sekil] ?? hata(`sekil_yok:${sekil}`), c = agirlikMerkezi(pts);
  let n = 0;
  for (let psi = 0; psi < 180; psi += 1) if (eksenMi(pts, c, psi)) n++;
  return n;
}
// parametreler: { sekil, cizgiler?:[{ad, cizgi}] }  cizgiler yoksa yalnız şekil çizilir (eksen sayısı sorulur).
function simetri(p, profil) {
  const pts = SEKILLER[p.sekil] ?? hata(`sekil_yok:${p.sekil}`);
  const W = 280, H = 236, cx = W / 2, cy = H / 2, k = 72, m = 24, s = new Sahne(W, H, profil);
  const c = agirlikMerkezi(pts);
  const ekran = (u, v) => [cx + (u - c[0]) * k, cy + (v - c[1]) * k];
  s.poligon(pts.map(([u, v]) => ekran(u, v)), { renk: PALET.siyah, dolgu: PALET.gok, kalinlik: 2 });
  const olgular = { eksen_sayisi: eksenSayisi(p.sekil), eksenler: {} };
  const harfler = [];
  for (const cz of p.cizgiler ?? []) {
    const a = ADAY_CIZGI[cz.cizgi] ?? hata(`cizgi_yok:${cz.cizgi}`);
    const dx = Math.cos(aciRad(a.psi)), dy = Math.sin(aciRad(a.psi)), ox = cx + a.kaydir[0] * k, oy = cy + a.kaydir[1] * k;
    // kutuya (m kenar payı) kadar iki yönde uzat
    const kes = (yon) => {
      let t = 1e9;
      const x = yon * dx, y = yon * dy;
      if (x > 1e-9) t = Math.min(t, (W - m - ox) / x); else if (x < -1e-9) t = Math.min(t, (m - ox) / x);
      if (y > 1e-9) t = Math.min(t, (H - m - oy) / y); else if (y < -1e-9) t = Math.min(t, (m - oy) / y);
      return [ox + x * t, oy + y * t];
    };
    const u1 = kes(1), u2 = kes(-1);
    s.cizgi(u1[0], u1[1], u2[0], u2[1], { renk: PALET.kirmizi, kalinlik: 2.2, kesik: true });
    harfler.push({ ad: cz.ad, u1, u2, dx, dy });
    olgular.eksenler[cz.ad] = eksenMi(pts, c, a.psi, a.kaydir);
  }
  for (const h of harfler) {
    const adaylar = [];
    for (const [u, yon] of [[h.u1, 1], [h.u2, -1]]) for (const mesafe of [12, 17]) adaylar.push([u[0] + yon * h.dx * mesafe, u[1] + yon * h.dy * mesafe + 5]);
    s.metinYerlestir(adaylar, h.ad, { kalin: true });
  }
  const alt = harfler.length ? `Bir geometrik şekil ve onu kesen kesikli doğrular; doğrular ${harfler.map((h) => h.ad).join(', ')} harfleriyle adlandırılmıştır.` : 'Bir geometrik şekil.';
  return { sahne: s, alt, olgular };
}

// ---------- a3-yansima ----------
// Kareli zeminde ayna doğrusu (kesikli), bir çokgen ve K köşesi; sağda/altta A–D adaylı noktalar.
// parametreler: { en, boy, eksen:'dikey'|'yatay', ayna:int, poligon:[[x,y]…] (kafes noktaları, y aşağı), k:int (köşe indeksi), adaylar:[{ad,x,y}] }
function yansima(p, profil) {
  const kare = 26, m = 24, W = p.en * kare + 2 * m, H = p.boy * kare + 2 * m, s = new Sahne(W, H, profil);
  const X = (x) => m + x * kare, Y = (y) => m + y * kare;
  for (let i = 0; i <= p.en; i++) s.cizgi(X(i), Y(0), X(i), Y(p.boy), { renk: PALET.gri, kalinlik: 0.6, izgara: true });
  for (let j = 0; j <= p.boy; j++) s.cizgi(X(0), Y(j), X(p.en), Y(j), { renk: PALET.gri, kalinlik: 0.6, izgara: true });
  const dikey = p.eksen === 'dikey'; if (!dikey && p.eksen !== 'yatay') hata('eksen_bilinmiyor');
  if (dikey) s.cizgi(X(p.ayna), Y(0) - 8, X(p.ayna), Y(p.boy) + 8, { renk: PALET.kirmizi, kalinlik: 2.4, kesik: true });
  else s.cizgi(X(0) - 8, Y(p.ayna), X(p.en) + 8, Y(p.ayna), { renk: PALET.kirmizi, kalinlik: 2.4, kesik: true });
  for (const [x, y] of p.poligon) if (x < 0 || x > p.en || y < 0 || y > p.boy) hata('kafes_disi');
  s.poligon(p.poligon.map(([x, y]) => [X(x), Y(y)]), { renk: PALET.siyah, dolgu: PALET.gok, kalinlik: 2 });
  const K = p.poligon[p.k] ?? hata('k_yok');
  const yansit = ([x, y]) => (dikey ? [2 * p.ayna - x, y] : [x, 2 * p.ayna - y]);
  const nokta = (x, y, ad) => {
    s.nokta(X(x), Y(y), { r: 4.5 });
    const adaylar = [[-11, -7], [11, -7], [-11, 15], [11, 15], [0, -10], [0, 20], [-14, 4], [14, 4]].map(([dx, dy]) => [X(x) + dx, Y(y) + dy]);
    s.metinYerlestir(adaylar, ad, { kalin: true });
  };
  nokta(K[0], K[1], 'K');
  const hedef = yansit(K);
  let bulunan = null;
  for (const a of p.adaylar) {
    if (a.x < 0 || a.x > p.en || a.y < 0 || a.y > p.boy) hata(`aday_disarda:${a.ad}`);
    nokta(a.x, a.y, a.ad);
    if (a.x === hedef[0] && a.y === hedef[1]) bulunan = a.ad;
  }
  return { sahne: s, alt: 'Kareli zeminde kesikli bir doğru (ayna), bir çokgen ve K köşesi; ayrıca A, B, C, D harfleriyle adlandırılmış noktalar vardır.', olgular: { simetrik_nokta: bulunan } };
}

// ---------- a3-acilar ----------
// 2×2 panel; her panelde bir açı (başlangıç ışını rot derece döndürülmüş). 90° açıda dik açı işareti çizilir.
// parametreler: { paneller:[{harf, aci:1..180, rot:0..359}] }  (4 panel)
const aciTuru = (a) => (a < 90 ? 'dar' : a === 90 ? 'dik' : a < 180 ? 'genis' : 'dogru');
function acilar(p, profil) {
  if (p.paneller.length !== 4) hata('panel_sayisi_4');
  const pw = 120, ph = 112, g = 8, W = 2 * pw + 3 * g, H = 2 * ph + 3 * g, s = new Sahne(W, H, profil);
  const olgular = { acilar: {}, turler: {} };
  p.paneller.forEach((q, i) => {
    if (!(q.aci > 0 && q.aci <= 180)) hata('aci_aralik');
    const px = g + (i % 2) * (pw + g), py = g + Math.floor(i / 2) * (ph + g), vx = px + pw / 2, vy = py + 62, L = 44;
    s.dikdortgen(px, py, pw, ph, { renk: PALET.gri, kalinlik: 1 });
    const u = (a, l) => [vx + l * Math.cos(aciRad(a)), vy - l * Math.sin(aciRad(a))];
    const a0 = q.rot, a1 = q.rot + q.aci, e0 = u(a0, L), e1 = u(a1, L);
    s.cizgi(vx, vy, e0[0], e0[1], { kalinlik: 2.6 }); s.cizgi(vx, vy, e1[0], e1[1], { kalinlik: 2.6 });
    s.nokta(vx, vy, { r: 3 });
    if (q.aci === 90) {
      const c0 = u(a0, 12), c1 = u(a1, 12), c01 = [c0[0] + c1[0] - vx, c0[1] + c1[1] - vy];
      s.cizgi(c0[0], c0[1], c01[0], c01[1], { kalinlik: 1.4 }); s.cizgi(c01[0], c01[1], c1[0], c1[1], { kalinlik: 1.4 });
    } else s.yay(vx, vy, 16, a0, a1, { kalinlik: 1.6 });
    s.metin(px + 14, py + 18, q.harf, { kalin: true });
    olgular.acilar[q.harf] = q.aci; olgular.turler[q.harf] = aciTuru(q.aci);
  });
  const h = Object.keys(olgular.acilar), deg = olgular.acilar;
  const k = [...h].sort((a, b) => deg[a] - deg[b]);
  for (let i = 1; i < k.length; i++) if (deg[k[i]] - deg[k[i - 1]] < 12) hata('acilar_cok_yakin');
  olgular.kucukten_buyuge = k; olgular.buyukten_kucuge = [...k].reverse(); olgular.en_buyuk = k[3]; olgular.en_kucuk = k[0];
  return { sahne: s, alt: 'Dört ayrı panelde dörder açı çizilmiştir; her panel bir harfle adlandırılmıştır.', olgular };
}

// ---------- a3-izgara-sekil ----------
// Kareli zeminde birimkarelerden oluşan şekil. parametreler: { en, boy, hucreler:[[sutun,satir]…] }  (satır yukarıdan aşağı)
function izgaraSekil(p, profil) {
  const k = 24, m = 14, W = p.en * k + 2 * m, H = p.boy * k + 2 * m, s = new Sahne(W, H, profil);
  const kume = new Set(p.hucreler.map(([c, r]) => `${c},${r}`));
  if (kume.size !== p.hucreler.length) hata('hucre_tekrar');
  for (const [c, r] of p.hucreler) if (c < 0 || c >= p.en || r < 0 || r >= p.boy) hata('hucre_disi');
  for (let i = 0; i <= p.en; i++) s.cizgi(m + i * k, m, m + i * k, m + p.boy * k, { renk: PALET.gri, kalinlik: 0.6, izgara: true });
  for (let j = 0; j <= p.boy; j++) s.cizgi(m, m + j * k, m + p.en * k, m + j * k, { renk: PALET.gri, kalinlik: 0.6, izgara: true });
  let cevre = 0;
  for (const [c, r] of p.hucreler) {
    s.dikdortgen(m + c * k, m + r * k, k, k, { dolgu: PALET.gok, renk: PALET.gri, kalinlik: 0.6 });
    const var_ = (a, b) => kume.has(`${a},${b}`);
    const x0 = m + c * k, y0 = m + r * k;
    if (!var_(c, r - 1)) { s.cizgi(x0, y0, x0 + k, y0, { kalinlik: 2.8 }); cevre++; }
    if (!var_(c, r + 1)) { s.cizgi(x0, y0 + k, x0 + k, y0 + k, { kalinlik: 2.8 }); cevre++; }
    if (!var_(c - 1, r)) { s.cizgi(x0, y0, x0, y0 + k, { kalinlik: 2.8 }); cevre++; }
    if (!var_(c + 1, r)) { s.cizgi(x0 + k, y0, x0 + k, y0 + k, { kalinlik: 2.8 }); cevre++; }
  }
  return { sahne: s, alt: 'Kareli zemin üzerinde birimkarelerden oluşan bir şekil.', olgular: { alan: p.hucreler.length, cevre } };
}

// ---------- a3-saat ----------
// Analog saat. parametreler: { saat:1..12, dakika:0..59 }
function saat(p, profil) {
  if (!(p.saat >= 1 && p.saat <= 12 && p.dakika >= 0 && p.dakika < 60)) hata('saat_aralik');
  const W = 200, H = 200, cx = 100, cy = 100, R = 66, s = new Sahne(W, H, profil);
  s.cember(cx, cy, R, { kalinlik: 2.4 });
  const nk = (aci, r) => [cx + r * Math.sin(aciRad(aci)), cy - r * Math.cos(aciRad(aci))];
  for (let i = 0; i < 60; i++) {
    const u = i % 5 === 0 ? 9 : 4, a = nk(i * 6, R - u), b = nk(i * 6, R);
    s.cizgi(a[0], a[1], b[0], b[1], { kalinlik: i % 5 === 0 ? 1.8 : 0.8, izgara: true });
  }
  for (let n = 1; n <= 12; n++) { const q = nk(n * 30, R + 16); s.metin(q[0], q[1] + 5, String(n), { kalin: true }); }
  const hs = nk(((p.saat % 12) + p.dakika / 60) * 30, 36), ms = nk(p.dakika * 6, 56);
  s.cizgi(cx, cy, hs[0], hs[1], { kalinlik: 5.5 }); s.cizgi(cx, cy, ms[0], ms[1], { kalinlik: 3 });
  s.nokta(cx, cy, { r: 4 });
  const mm = String(p.dakika).padStart(2, '0');
  return { sahne: s, alt: 'Akrep ve yelkovanı olan, rakamlı analog bir saat.', olgular: { saat: p.saat, dakika: p.dakika, gosterim: `${p.saat}:${mm}` } };
}

// ---------- a3-sekil-grafigi ----------
// Şekil (simge) grafiği: her simge `birim` kişiyi (ya da nesneyi) gösterir; yarım simge birim/2'dir.
// parametreler: { baslik, birim:çift sayı, birimAd, kategoriler:[{ad, sayi, yarim?}] }
function sekilGrafigi(p, profil) {
  const n = p.kategoriler.length; if (n < 3 || n > 5) hata('kategori_3_5');
  if (p.birim % 2 !== 0) hata('birim_cift_olmali');
  const maks = Math.max(...p.kategoriler.map((k) => k.sayi + (k.yarim ? 1 : 0)));
  const sol = 96, adim = 24, W = Math.max(300, sol + maks * adim + 16), H = 46 + n * 30 + 40, s = new Sahne(W, H, profil);
  s.metin(W / 2, 22, p.baslik, { kalin: true });
  const olgular = { degerler: {}, birim: p.birim };
  p.kategoriler.forEach((k, j) => {
    const y = 56 + j * 30;
    s.metin(sol - 12, y + 5, k.ad, { hiza: 'end' });
    for (let i = 0; i < k.sayi; i++) s.cember(sol + 10 + i * adim, y, 9, { dolgu: PALET.mavi, renk: PALET.siyah, kalinlik: 1.2 });
    if (k.yarim) { const cx = sol + 10 + k.sayi * adim; s.cember(cx, y, 9, { renk: PALET.siyah, kalinlik: 1.2 }); s.dilim(cx, y, 9, 90, 270, { dolgu: PALET.mavi, renk: PALET.siyah, kalinlik: 1.2 }); }
    if (j < n - 1) s.cizgi(14, y + 15, W - 14, y + 15, { renk: PALET.gri, kalinlik: 0.5, izgara: true });
    olgular.degerler[k.ad] = k.sayi * p.birim + (k.yarim ? p.birim / 2 : 0);
  });
  const yl = H - 18;
  s.cember(sol + 10, yl, 9, { dolgu: PALET.mavi, renk: PALET.siyah, kalinlik: 1.2 });
  s.metin(sol + 26, yl + 5, `= ${p.birim} ${p.birimAd}`, { hiza: 'start' });
  const v = Object.entries(olgular.degerler), mx = Math.max(...v.map(([, d]) => d)), mn = Math.min(...v.map(([, d]) => d));
  const tek = (d) => { const e = v.filter(([, x]) => x === d); return e.length === 1 ? e[0][0] : null; };
  olgular.toplam = v.reduce((t, [, d]) => t + d, 0); olgular.en_cok = tek(mx); olgular.en_az = tek(mn);
  return { sahne: s, alt: `Şekil grafiği: ${p.baslik}. Kategoriler: ${p.kategoriler.map((k) => k.ad).join(', ')}. Her satırda simgeler vardır; alt kısımda bir simgenin değeri yazılıdır.`, olgular };
}

export const TIPLER_A3 = {
  'a3-acilar': acilar,
  'a3-izgara-sekil': izgaraSekil,
  'a3-saat': saat,
  'a3-sekil-grafigi': sekilGrafigi,
  'a3-kesisen-dogrular': kesisenDogrular,
  'a3-kesir-modeli-cok': kesirCok,
  'a3-kesir-seritleri': kesirSeritleri,
  'a3-simetri': simetri,
  'a3-yansima': yansima,
};
void yuv2;
