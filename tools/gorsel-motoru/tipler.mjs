// Şekil tipleri: her tip render(parametreler, profil) -> { sahne, alt, olgular } döndürür.
// `olgular` çözücüdür: şekilden kodla hesaplanan doğrular (cevap anahtarı bununla eşleşmeli).
import { Sahne, PALET, aciRad } from './cekirdek.mjs';
import { TIPLER_EK } from './tipler-ek.mjs';

const hata = (m) => { throw new Error(m); };
const r2 = (n) => Math.round(n * 100) / 100;

// ---------- 1) doğru, doğru parçası, ışın, nokta ----------
// parametreler: { noktalar:[{ad,x,y}], nesneler:[{tur:'nokta'|'dogru_parcasi'|'isin'|'dogru', a, b?}] }
// Sembol gösterimi (5. sınıf): [AB] doğru parçası, [AB ışın (A başlangıç), (AB) doğru.
const DOGRU_ADLARI = { nokta: 'nokta', dogru_parcasi: 'doğru parçası', isin: 'ışın', dogru: 'doğru' };
function dogruModelleri(p, profil) {
  const W = 320, H = 200, s = new Sahne(W, H, profil);
  const nk = Object.fromEntries(p.noktalar.map((n) => [n.ad, n]));
  const al = (ad) => nk[ad] ?? hata(`nokta_yok:${ad}`);
  const olgular = { semboller: {}, turler: {} };
  const uzat = (a, b) => { // a->b doğrultusunda kanvas kenarına kadar
    const dx = b.x - a.x, dy = b.y - a.y, uz = Math.hypot(dx, dy) || hata('ayni_nokta');
    const ux = dx / uz, uy = dy / uz; let t = 1e9;
    const sinir = (v, u, lo, hi) => { if (u > 1e-9) t = Math.min(t, (hi - v) / u); else if (u < -1e-9) t = Math.min(t, (lo - v) / u); };
    sinir(a.x, ux, 14, W - 14); sinir(a.y, uy, 14, H - 14);
    return { x: a.x + ux * t, y: a.y + uy * t };
  };
  const goster = new Set();
  for (const o of p.nesneler) {
    if (!DOGRU_ADLARI[o.tur]) hata(`tur_bilinmiyor:${o.tur}`);
    const a = al(o.a); goster.add(o.a);
    if (o.tur === 'nokta') { olgular.semboller[o.a] = o.a; olgular.turler[o.a] = 'nokta'; continue; }
    const b = al(o.b); goster.add(o.b);
    if (o.tur === 'dogru_parcasi') { s.cizgi(a.x, a.y, b.x, b.y); olgular.semboller[`${o.a}${o.b}`] = `[${o.a}${o.b}]`; }
    if (o.tur === 'isin') { const u = uzat(a, b); s.cizgi(a.x, a.y, u.x, u.y, { ok: true }); olgular.semboller[`${o.a}${o.b}`] = `[${o.a}${o.b}`; }
    if (o.tur === 'dogru') {
      const u1 = uzat(a, b), u2 = uzat(b, a);
      s.cizgi(u2.x, u2.y, u1.x, u1.y); s._okBasi(u1.x, u1.y, Math.atan2(u1.y - u2.y, u1.x - u2.x), PALET.siyah);
      s._okBasi(u2.x, u2.y, Math.atan2(u2.y - u1.y, u2.x - u1.x), PALET.siyah);
      olgular.semboller[`${o.a}${o.b}`] = `(${o.a}${o.b})`;
    }
    olgular.turler[`${o.a}${o.b}`] = o.tur;
  }
  for (const ad of goster) {
    const n = al(ad); s.nokta(n.x, n.y);
    s.metinYerlestir([[n.x, n.y - 10], [n.x, n.y + 22], [n.x - 14, n.y - 8], [n.x + 14, n.y - 8], [n.x - 14, n.y + 20], [n.x + 14, n.y + 20]], ad, { kalin: true });
  }
  // Alt metin türü söylemez (cevap sızıntısı olmasın); tür olgularda (olgular.turler) durur.
  const alt = 'Şekil: ' + [...goster].join(', ') + ' noktaları ve bu noktalarla çizilmiş bir model.';
  return { sahne: s, alt, olgular };
}

// ---------- 2) çember elemanları ----------
// parametreler: { merkez:'O', noktalar:[{ad, aci}], cizimler:[{tur:'yaricap'|'cap'|'kiris', a, b?}], olcekli? }
function cemberElemanlari(p, profil) {
  const W = 260, H = 260, cx = 130, cy = 130, R = 95, s = new Sahne(W, H, profil);
  s.cember(cx, cy, R);
  const nk = Object.fromEntries(p.noktalar.map((n) => [n.ad, n]));
  const konum = (n, ek = 0) => [cx + (R + ek) * Math.cos(aciRad(n.aci)), cy - (R + ek) * Math.sin(aciRad(n.aci))];
  const olgular = { siniflar: {}, cap_uzunlugu_yaricapin_kati: 2 };
  s.nokta(cx, cy);
  const al = (ad) => nk[ad] ?? hata(`nokta_yok:${ad}`);
  for (const c of p.cizimler) {
    if (c.tur === 'yaricap') {
      const q = konum(al(c.a)); s.cizgi(cx, cy, q[0], q[1]); olgular.siniflar[`[${p.merkez}${c.a}]`] = 'yaricap';
    } else {
      const A = al(c.a), B = al(c.b); const qa = konum(A), qb = konum(B);
      s.cizgi(qa[0], qa[1], qb[0], qb[1]);
      const fark = ((A.aci - B.aci) % 360 + 360) % 360;
      const sinif = Math.abs(fark - 180) < 1e-6 ? 'cap' : 'kiris';
      if (c.tur === 'cap' && sinif !== 'cap') hata(`cap_degil:${c.a}${c.b}`);
      olgular.siniflar[`[${c.a}${c.b}]`] = sinif;
    }
  }
  const oAday = [];
  for (const u of [12, 16, 22]) for (const [dx, dy] of [[1, 1], [-1, 1], [1, -1], [-1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]) oAday.push([cx + dx * u, cy + dy * u + 5]);
  s.metinYerlestir(oAday, p.merkez, { kalin: true });
  const gor = new Set(p.cizimler.flatMap((c) => [c.a, c.b].filter((x) => x && nk[x])));
  for (const ad of gor) { const n = nk[ad]; const q = konum(n); s.nokta(q[0], q[1]); const e = konum(n, 16); s.metin(e[0], e[1] + 5, ad, { kalin: true }); }
  const alt = `${p.merkez} merkezli çember; çemberin üzerine ${p.cizimler.length} doğru parçası çizilmiş, uç noktaları harflerle adlandırılmış.`;
  return { sahne: s, alt, olgular };
}

// ---------- 3) kesişen doğrular ve açılar ----------
// parametreler: { dogrular:['d','e'], theta:1..179, isaretler:[{bolge:0..3, goster:'deger'|'sembol'|'yok', sembol?}], olcekli? }
// Bölge 0: θ, 1: 180-θ, 2: θ (ters), 3: 180-θ. Ölçekli değilse çizim açısı dar/dik/geniş sınıfına göre sabitlenir.
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
    const yazi = i.goster === 'deger' ? `${degerler[i.bolge]}°` : i.sembol;
    s.metin(q[0], q[1] + 5, yazi, { kalin: true });
  }
  const olgular = { bolge_degerleri: degerler, ters_acilar: [[0, 2], [1, 3]], komsu_butunler: [[0, 1], [1, 2], [2, 3], [3, 0]], theta: th };
  const alt = `${p.dogrular[0]} ve ${p.dogrular[1]} doğruları bir noktada kesişiyor; ${p.olcekli ? '' : 'şekil ölçekli değildir; '}işaretli açılar: ` +
    p.isaretler.map((i) => (i.goster === 'deger' ? `${degerler[i.bolge]}°` : i.goster === 'sembol' ? i.sembol : '—')).join(', ') + '.';
  return { sahne: s, alt, olgular };
}

// ---------- 4) kareli zeminde doğrular ----------
// parametreler: { en, boy, dogrular:[{ad, p1:[x,y], p2:[x,y], renk?}] }  (kafes noktaları, y yukarı)
// Doğrular sonsuz kabul edilir: paralel / dik / kesişir / çakışık.
const RENK_SIRASI = ['mavi', 'kirmizi', 'yesil', 'turuncu', 'pembe', 'gok'];
function kareliDogrular(p, profil) {
  const kare = 22, e = p.en, b = p.boy, m = 18, W = e * kare + 2 * m, H = b * kare + 2 * m, s = new Sahne(W, H, profil);
  const X = (x) => m + x * kare, Y = (y) => m + (b - y) * kare;
  for (let i = 0; i <= e; i++) s.cizgi(X(i), Y(0), X(i), Y(b), { renk: PALET.gri, kalinlik: 0.6 });
  for (let j = 0; j <= b; j++) s.cizgi(X(0), Y(j), X(e), Y(j), { renk: PALET.gri, kalinlik: 0.6 });
  const etiketler = [];
  p.dogrular.forEach((d, i) => {
    const [x1, y1] = d.p1, [x2, y2] = d.p2;
    for (const [x, y] of [d.p1, d.p2]) if (x < 0 || x > e || y < 0 || y > b) hata(`kafes_disi:${d.ad}`);
    if (x1 === x2 && y1 === y2) hata(`ayni_nokta:${d.ad}`);
    const renk = PALET[d.renk ?? RENK_SIRASI[i % RENK_SIRASI.length]];
    s.cizgi(X(x1), Y(y1), X(x2), Y(y2), { renk, kalinlik: 2.4, ok: true });
    s._okBasi(X(x1), Y(y1), Math.atan2(Y(y1) - Y(y2), X(x1) - X(x2)), renk);
    etiketler.push({ d, renk, x1: X(x1), y1: Y(y1), x2: X(x2), y2: Y(y2) });
    if (p.renk_anlamli) s.anlamRengi(renk, d.ad); // renk soruda anlam taşıyorsa kayıt edilir (renk körlüğü + kontrast kapısı)
  });
  // Etiket: her doğruyu adıyla da işaretle (renk tek başına taşıyıcı değil); çizgi/yazı çakışmayan ilk yer seçilir.
  const YON = [[1, 0], [-1, 0], [0, -1], [0, 1], [0.7, -0.7], [-0.7, -0.7], [0.7, 0.7], [-0.7, 0.7]];
  for (const e of etiketler) {
    const noktalar = [[e.x2, e.y2], [(e.x1 + e.x2) / 2, (e.y1 + e.y2) / 2], [e.x1, e.y1]];
    const adaylar = noktalar.flatMap(([px, py]) => [14, 20].flatMap((u) => YON.map(([dx, dy]) => [px + dx * u, py + dy * u + 5])));
    s.metinYerlestir(adaylar, e.d.ad, { kalin: true, renk: e.renk });
  }
  const olgular = { iliskiler: {} };
  for (let i = 0; i < p.dogrular.length; i++) for (let j = i + 1; j < p.dogrular.length; j++) {
    const A = p.dogrular[i], B = p.dogrular[j];
    const u = [A.p2[0] - A.p1[0], A.p2[1] - A.p1[1]], v = [B.p2[0] - B.p1[0], B.p2[1] - B.p1[1]];
    const cap = u[0] * v[1] - u[1] * v[0], nokta = u[0] * v[0] + u[1] * v[1];
    let ilis;
    if (cap === 0) {
      const w = [B.p1[0] - A.p1[0], B.p1[1] - A.p1[1]];
      ilis = (u[0] * w[1] - u[1] * w[0]) === 0 ? 'cakisik' : 'paralel';
    } else ilis = nokta === 0 ? 'dik' : 'kesisir';
    olgular.iliskiler[`${A.ad}|${B.ad}`] = ilis;
  }
  const alt = `Kareli zeminde ${p.dogrular.map((d) => d.ad).join(', ')} doğruları çizilmiş.`;
  return { sahne: s, alt, olgular };
}

// ---------- 5) sayı doğrusu ----------
// parametreler: { min, max, adim, isaretler:[{deger, etiket?, bos?}] }  (bos: etiket yerine "?")
function sayiDogrusu(p, profil) {
  const W = 340, H = 90, m = 24, y0 = 52, s = new Sahne(W, H, profil);
  const n = Math.round((p.max - p.min) / p.adim); if (n < 1 || n > 20) hata('adim_sayisi_aralik_disi');
  const X = (v) => m + ((v - p.min) / (p.max - p.min)) * (W - 2 * m);
  s.cizgi(m - 8, y0, W - m + 8, y0, { ok: true }); s._okBasi(m - 8, y0, Math.PI, PALET.siyah);
  for (let i = 0; i <= n; i++) {
    const v = p.min + i * p.adim; s.cizgi(X(v), y0 - 6, X(v), y0 + 6, { kalinlik: 1.6 });
    if (n <= 10 || i % 2 === 0) s.metin(X(v), y0 + 24, String(r2(v)));
  }
  const olgular = { konumlar: {} };
  for (const i of p.isaretler) {
    if (i.deger < p.min || i.deger > p.max) hata('isaret_disinda');
    s.nokta(X(i.deger), y0, { r: 5, renk: PALET.kirmizi });
    s.metin(X(i.deger), y0 - 14, i.bos ? '?' : (i.etiket ?? ''), { kalin: true, renk: PALET.kirmizi });
    olgular.konumlar[i.etiket ?? '?'] = i.deger;
  }
  const alt = `${p.min} ile ${p.max} arasında, ${p.adim} aralıklı sayı doğrusu; işaretli noktalar: ${p.isaretler.map((i) => (i.bos ? 'bilinmeyen' : i.etiket)).join(', ')}.`;
  return { sahne: s, alt, olgular };
}

// ---------- 6) çokgen (düzgün), köşe harfleri, köşegenler ----------
// parametreler: { n:3..12, harfler:['A','B',...], kosegenler:[[i,j],…] (köşe indeksleri), baslangic_aci? }
function cokgen(p, profil) {
  const n = p.n; if (n < 3 || n > 12) hata('n_aralik_disi');
  if (p.harfler.length !== n) hata('harf_sayisi_n_degil');
  const W = 260, H = 260, cx = 130, cy = 132, R = 88, s = new Sahne(W, H, profil);
  const ba = p.baslangic_aci ?? 90;
  const kose = (i, r = R) => [cx + r * Math.cos(aciRad(ba + (360 * i) / n)), cy - r * Math.sin(aciRad(ba + (360 * i) / n))];
  for (let i = 0; i < n; i++) { const a = kose(i), b = kose((i + 1) % n); s.cizgi(a[0], a[1], b[0], b[1]); }
  const olgular = { kenar_sayisi: n, kose_sayisi: n, kosegen_sayisi: (n * (n - 3)) / 2, bir_koseden_kosegen: n - 3, cizilen_kosegenler: [] };
  for (const [i, j] of p.kosegenler ?? []) {
    const fark = Math.abs(i - j);
    if (i === j || fark === 1 || fark === n - 1) hata(`kosegen_degil:${i}-${j}`);
    const a = kose(i), b = kose(j); s.cizgi(a[0], a[1], b[0], b[1], { renk: PALET.mavi, kalinlik: 1.8, kesik: true });
    olgular.cizilen_kosegenler.push(`[${p.harfler[i]}${p.harfler[j]}]`);
  }
  for (let i = 0; i < n; i++) { const a = kose(i), e = kose(i, R + 17); s.nokta(a[0], a[1], { r: 3 }); s.metin(e[0], e[1] + 5, p.harfler[i], { kalin: true }); }
  const alt = `Düzgün çokgen; köşeleri ${p.harfler.join(', ')}.` + (olgular.cizilen_kosegenler.length ? ' Bir köşeden çizilmiş köşegenler de gösterilmiş.' : '');
  return { sahne: s, alt, olgular };
}

// ---------- 7) dinamometre (ölçü aleti okuma) ----------
// parametreler: { max (N), buyuk (büyük çizgi aralığı, N), bolme (küçük bölme, N), deger (N) }
function dinamometre(p, profil) {
  const W = 190, H = 300, Y0 = 38, Y1 = 250, s = new Sahne(W, H, profil);
  const buyuk = p.buyuk ?? 1, bolme = p.bolme, max = p.max;
  const adim = Math.round(buyuk / bolme); if (Math.abs(adim * bolme - buyuk) > 1e-9) hata('bolme_buyuge_bolunmuyor');
  const oran = p.deger / bolme; if (Math.abs(oran - Math.round(oran)) > 1e-9) hata('deger_bolmeye_uymuyor');
  if (p.deger < 0 || p.deger > max) hata('deger_aralik_disi');
  const Y = (v) => Y0 + (v / max) * (Y1 - Y0);
  s.cember(64, 14, 7); s.cizgi(64, 21, 64, 28);
  s.dikdortgen(44, 28, 40, 236, { kalinlik: 2 });
  const n = Math.round(max / bolme);
  if ((Y1 - Y0) / n < 6) hata('bolme_cok_sik'); // çizgi aralığı < 6 birim: çocuk için okunmaz
  for (let i = 0; i <= n; i++) {
    const v = i * bolme, buyukMu = i % adim === 0;
    s.cizgi(84, Y(v), buyukMu ? 102 : 94, Y(v), { kalinlik: buyukMu ? 1.8 : 1 });
    if (buyukMu) s.metin(112, Y(v) + 5, String(Math.round(v / buyuk) * buyuk), { hiza: 'start' });
  }
  s.metin(150, 20, 'N', { kalin: true });
  s.cizgi(48, Y(p.deger), 84, Y(p.deger), { renk: PALET.kirmizi, kalinlik: 2.8 });
  s.cizgi(64, 264, 64, 280); s.cember(64, 286, 6);
  const olgular = { okunan_deger: p.deger, bolme_N: bolme, buyuk_aralik_bolme_sayisi: adim };
  // Alt metin skala sayılarını yazmaz (ölçüm değerini ve sınır değerlerini ele vermesin); yalnız ne gösterildiğini anlatır.
  const alt = 'Dinamometre: sıfırdan başlayan, sayılı ve bölmeli bir skala üzerinde kırmızı bir ibre bir değeri gösteriyor. Skala birimi newtondur (N).';
  return { sahne: s, alt, olgular };
}

export const TIPLER = {
  ...TIPLER_EK,
  'dinamometre': dinamometre,
  'cokgen': cokgen,
  'dogru-modelleri': dogruModelleri,
  'cember-elemanlari': cemberElemanlari,
  'kesisen-dogrular': kesisenDogrular,
  'kareli-dogrular': kareliDogrular,
  'sayi-dogrusu': sayiDogrusu,
};
