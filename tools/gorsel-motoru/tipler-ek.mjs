// Ek şekil tipleri: sütun grafiği, çubuk örüntüsü, nesne sayma, yer haritası (yön), trafik ışığı.
// Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const LCG = (t) => () => { t = (Math.imul(t, 1664525) + 1013904223) >>> 0; return t / 4294967296; };

// ---------- sütun grafiği ----------
// parametreler: { baslik, kategoriler:[{ad, deger}], max, adim, degerEtiketi? }  (değerler adim/2'nin katı)
function sutunGrafigi(p, profil) {
  const W = 330, H = 240, sol = 52, sag = W - 14, ust = 42, alt = 172, s = new Sahne(W, H, profil);
  const n = p.kategoriler.length; if (n < 2 || n > 6) hata('kategori_sayisi_2_6');
  const Y = (v) => alt - (v / p.max) * (alt - ust);
  s.metin(W / 2, 22, p.baslik, { kalin: true });
  for (let v = 0; v <= p.max + 1e-9; v += p.adim) {
    s.cizgi(sol, Y(v), sag, Y(v), { renk: PALET.gri, kalinlik: 0.6, izgara: true });
    s.metin(sol - 8, Y(v) + 5, String(v), { hiza: 'end', boyut: 12 });
  }
  s.cizgi(sol, ust - 6, sol, alt); s.cizgi(sol, alt, sag, alt);
  const slot = (sag - sol) / n, bw = slot * 0.5, degerler = {};
  p.kategoriler.forEach((k, i) => {
    const kat = k.deger / (p.adim / 2); if (Math.abs(kat - Math.round(kat)) > 1e-9) hata(`deger_adim_yarisina_uymuyor:${k.ad}`);
    if (k.deger < 0 || k.deger > p.max) hata(`deger_aralik_disi:${k.ad}`);
    const cx = sol + slot * (i + 0.5);
    s.dikdortgen(cx - bw / 2, Y(k.deger), bw, alt - Y(k.deger), { dolgu: PALET.mavi, renk: PALET.siyah, kalinlik: 1 });
    s.metin(cx, alt + 20, k.ad, { boyut: 12 });
    if (p.degerEtiketi) s.metin(cx, Y(k.deger) - 6, String(k.deger), { boyut: 12, kalin: true });
    degerler[k.ad] = k.deger;
  });
  const vals = Object.entries(degerler), mx = Math.max(...vals.map(([, v]) => v)), mn = Math.min(...vals.map(([, v]) => v));
  const tekil = (h) => { const e = vals.filter(([, v]) => v === h); return e.length === 1 ? e[0][0] : null; };
  const olgular = { degerler, en_cok: tekil(mx), en_az: tekil(mn), toplam: vals.reduce((t, [, v]) => t + v, 0) };
  const alter = `Sütun grafiği: ${p.baslik}. Kategoriler: ${p.kategoriler.map((k) => k.ad).join(', ')}. Dikey eksen 0 ile ${p.max} arasında.`;
  return { sahne: s, alt: alter, olgular };
}

// ---------- çubuk (kibrit) örüntüsü ----------
// parametreler: { tur:'kare'|'ucgen'|'altigen' }  İlk 3 adım çizilir. Kare 3n+1, üçgen şeridi 2n+1, altıgen sırası 5n+1 çubuk.
function cubukOruntusu(p, profil) {
  const ad = { kare: 'Kare', ucgen: 'Üçgen', altigen: 'Altıgen' }[p.tur];
  if (!ad) hata(`tur_bilinmiyor:${p.tur}`);
  const W = 340, H = 130, base = 78, s = new Sahne(W, H, profil), kare = p.tur === 'kare', altigen = p.tur === 'altigen';
  const a = { kare: 3, ucgen: 2, altigen: 5 }[p.tur], c = 1, ks = kare ? 24 : altigen ? 20 : 32;
  let x0 = 16;
  for (let n = 1; n <= 3; n++) {
    const L = (x1, y1, x2, y2) => s.cizgi(x1, y1, x2, y2, { renk: PALET.mavi, kalinlik: 3.5 });
    if (kare) {
      for (let i = 0; i < n; i++) { L(x0 + i * ks, base, x0 + (i + 1) * ks, base); L(x0 + i * ks, base - ks, x0 + (i + 1) * ks, base - ks); }
      for (let i = 0; i <= n; i++) L(x0 + i * ks, base, x0 + i * ks, base - ks);
      s.metin(x0 + (n * ks) / 2, base + 26, `${n}. adım`, { boyut: 13 });
      x0 += n * ks + 30;
    } else if (altigen) {
      // Yan yana sivri-tepeli altıgenler; komşular bir kenarı paylaşır (n altıgen = 5n+1 kenar).
      const r = ks, w = Math.sqrt(3) * r, cy = base - r, cx0 = x0 + w / 2;
      for (let i = 0; i < n; i++) {
        const cx = cx0 + i * w;
        s.poligon([90, 150, 210, 270, 330, 30].map((d) => [cx + r * Math.cos((d * Math.PI) / 180), cy - r * Math.sin((d * Math.PI) / 180)]), { renk: PALET.mavi, kalinlik: 3.5 });
      }
      s.metin(x0 + (n * w) / 2, base + 26, `${n}. adım`, { boyut: 13 });
      x0 += n * w + 30;
    } else {
      const h = ks * 0.866, P = (j) => [x0 + (j * ks) / 2, j % 2 === 0 ? base : base - h];
      for (let j = 0; j <= n; j++) { const [u1, v1] = P(j), [u2, v2] = P(j + 1); L(u1, v1, u2, v2); }
      for (let j = 0; j < n; j++) { const [u1, v1] = P(j), [u2, v2] = P(j + 2); L(u1, v1, u2, v2); }
      s.metin(x0 + ((n + 1) * ks) / 4, base + 26, `${n}. adım`, { boyut: 13 });
      x0 += ((n + 1) * ks) / 2 + 34;
    }
  }
  const cubuk = {}; for (let n = 1; n <= 20; n++) cubuk[n] = a * n + c;
  return { sahne: s, alt: `${ad} dizisinden oluşan çubuk örüntüsünün ilk üç adımı çizilmiş.`, olgular: { kural: `${a}n+${c}`, artis: a, cubuk } };
}

// ---------- nesne sayma ----------
// parametreler: { sekiller:[{sekil:'daire'|'kare'|'ucgen', sayi}], tohum }  Renkler rastgele (anlam taşımaz), düzen dağınık.
function nesneSayma(p, profil) {
  const toplam = p.sekiller.reduce((t, x) => t + x.sayi, 0); if (toplam < 1 || toplam > 20) hata('toplam_1_20');
  const kol = 6, satir = Math.ceil((toplam + 3) / kol), hucre = 46, W = kol * hucre + 20, H = satir * hucre + 20, s = new Sahne(W, H, profil);
  const r = LCG(p.tohum ?? 1), renkler = [PALET.mavi, PALET.turuncu, PALET.yesil, PALET.pembe, PALET.kirmizi];
  const hucreler = Array.from({ length: kol * satir }, (_, i) => i).sort(() => r() - 0.5);
  const liste = p.sekiller.flatMap((x) => Array(x.sayi).fill(x.sekil)).sort(() => r() - 0.5);
  liste.forEach((sk, i) => {
    const h = hucreler[i], cx = 10 + (h % kol) * hucre + hucre / 2 + (r() - 0.5) * 8, cy = 10 + Math.floor(h / kol) * hucre + hucre / 2 + (r() - 0.5) * 8, renk = renkler[Math.floor(r() * renkler.length)], b = 14;
    if (sk === 'daire') s.cember(cx, cy, b, { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
    else if (sk === 'kare') s.dikdortgen(cx - b, cy - b, 2 * b, 2 * b, { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
    else if (sk === 'ucgen') s.poligon([[cx, cy - b - 2], [cx - b - 2, cy + b], [cx + b + 2, cy + b]], { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
    else hata(`sekil_bilinmiyor:${sk}`);
  });
  const sayilar = Object.fromEntries(p.sekiller.map((x) => [x.sekil, x.sayi]));
  const en = Object.entries(sayilar).sort((a, b) => b[1] - a[1]);
  return { sahne: s, alt: 'Dağınık duran daire, kare ve üçgenlerden oluşan bir şekil grubu.', olgular: { sayilar, toplam, en_cok: en.length > 1 && en[0][1] === en[1][1] ? null : en[0][0] } };
}

// ---------- yer haritası (yön) ----------
// parametreler: { en, boy, yerler:[{ad, x, y}] }  x: sütun (sağa), y: satır (aşağı). Kuzey yukarıdadır; pusula çizilir.
const YON_ADI = { '0,1': 'kuzey', '0,-1': 'güney', '1,0': 'doğu', '-1,0': 'batı', '1,1': 'kuzeydoğu', '-1,1': 'kuzeybatı', '1,-1': 'güneydoğu', '-1,-1': 'güneybatı' };
function yerHaritasi(p, profil) {
  const hw = 78, hh = 56, m = 14, W = p.en * hw + 2 * m + 96, H = Math.max(p.boy * hh + 2 * m, 150), s = new Sahne(W, H, profil);
  for (let i = 0; i < p.en; i++) for (let j = 0; j < p.boy; j++) s.dikdortgen(m + i * hw, m + j * hh, hw, hh, { renk: PALET.gri, kalinlik: 0.8 });
  const ad = new Set();
  for (const y of p.yerler) {
    if (y.x < 0 || y.x >= p.en || y.y < 0 || y.y >= p.boy) hata(`yer_harita_disi:${y.ad}`);
    if (ad.has(y.ad)) hata(`yer_tekrar:${y.ad}`); ad.add(y.ad);
    s.dikdortgen(m + y.x * hw + 3, m + y.y * hh + 3, hw - 6, hh - 6, { renk: PALET.siyah, kalinlik: 1.6 });
    s.metin(m + y.x * hw + hw / 2, m + y.y * hh + hh / 2 + 5, y.ad, { boyut: 13, kalin: true });
  }
  const pcx = W - 58, pcy = 76;
  s.cizgi(pcx, pcy + 30, pcx, pcy - 30, { ok: true }); s.cizgi(pcx - 30, pcy, pcx + 30, pcy, { ok: true });
  s.metin(pcx, pcy - 40, 'K', { kalin: true }); s.metin(pcx, pcy + 52, 'G', { kalin: true });
  s.metin(pcx + 44, pcy + 5, 'D', { kalin: true }); s.metin(pcx - 44, pcy + 5, 'B', { kalin: true });
  const yonler = {};
  for (const a of p.yerler) for (const b of p.yerler) {
    if (a === b) continue;
    const dx = b.x - a.x, dy = a.y - b.y; // kuzey: satır numarası küçülür
    if (dx === 0 && dy === 0) continue;
    if (dx === 0 || dy === 0 || Math.abs(dx) === Math.abs(dy)) yonler[`${a.ad}|${b.ad}`] = YON_ADI[`${Math.sign(dx)},${Math.sign(dy)}`];
  }
  return { sahne: s, alt: `Izgara biçiminde bir harita; yerler: ${p.yerler.map((y) => y.ad).join(', ')}. Sağda pusula (K, G, D, B) vardır.`, olgular: { yonler } };
}

// ---------- trafik ışığı ----------
// parametreler: { yanan: 'kirmizi'|'sari'|'yesil' }  Konum da bilgi taşır (üst kırmızı, orta sarı, alt yeşil).
// Yeşil #00A37A: #2E9E44 kırmızıyla döteranopide ΔE 16.7 kalıyordu (lint eşiği 20); bu ton 28.2.
const IS_RENK = { kirmizi: '#D62828', sari: '#F2C500', yesil: '#00A37A' };
function trafikIsigi(p, profil) {
  if (!IS_RENK[p.yanan]) hata(`isik_bilinmiyor:${p.yanan}`);
  const W = 160, H = 260, s = new Sahne(W, H, profil);
  s.dikdortgen(50, 14, 60, 200, { dolgu: '#374151', renk: PALET.siyah, kalinlik: 2 });
  s.dikdortgen(76, 214, 8, 34, { dolgu: '#6B7280', renk: PALET.siyah, kalinlik: 1 });
  ['kirmizi', 'sari', 'yesil'].forEach((k, i) => {
    const yan = k === p.yanan;
    s.cember(80, 48 + i * 62, 22, { dolgu: yan ? IS_RENK[k] : '#9CA3AF', renk: '#111827', kalinlik: 2 });
  });
  s.anlamRengi(IS_RENK[p.yanan], 'yanan lamba (konumuyla birlikte)', { koyuZemin: true });
  return { sahne: s, alt: 'Üç lambalı bir trafik ışığı; lambalardan biri yanıyor.', olgular: { yanan: p.yanan, konum: { kirmizi: 'ust', sari: 'orta', yesil: 'alt' }[p.yanan] } };
}

// ---------- kavşakta iki trafik ışığı ----------
// parametreler: { ana, yan, bicim:'dikey'|'yatay', sira:'ana_ilk'|'yan_ilk' }  Yol etiketi hangi ışığın hangi yola ait olduğunu gösterir.
// Kural: iki yoldan en fazla biri kırmızı olmayabilir (ikisi birden yeşil/sarı olan durum çizilmez).
function trafikKavsak(p, profil) {
  if (!IS_RENK[p.ana] || !IS_RENK[p.yan]) hata('kavsak_isik_bilinmiyor');
  if (p.ana !== 'kirmizi' && p.yan !== 'kirmizi') hata('kavsak_cakisma');
  const yatay = p.bicim === 'yatay', ilk = p.sira === 'ana_ilk';
  const sirali = ilk ? [['ANA YOL', p.ana], ['YAN YOL', p.yan]] : [['YAN YOL', p.yan], ['ANA YOL', p.ana]];
  const W = yatay ? 280 : 260, H = yatay ? 230 : 260, s = new Sahne(W, H, profil);
  sirali.forEach(([etiket, renk], i) => {
    const lamba = (k, cx, cy) => s.cember(cx, cy, 22, { dolgu: k === renk ? IS_RENK[k] : '#9CA3AF', renk: '#111827', kalinlik: 2 });
    if (yatay) {
      const y0 = 40 + i * 110;
      s.dikdortgen(50, y0, 200, 60, { dolgu: '#374151', renk: PALET.siyah, kalinlik: 2 });
      ['kirmizi', 'sari', 'yesil'].forEach((k, j) => lamba(k, 90 + j * 60, y0 + 30));
      s.metin(150, y0 - 10, etiket, { kalin: true, boyut: 13 });
    } else {
      const x0 = 30 + i * 140;
      s.dikdortgen(x0, 14, 60, 200, { dolgu: '#374151', renk: PALET.siyah, kalinlik: 2 });
      ['kirmizi', 'sari', 'yesil'].forEach((k, j) => lamba(k, x0 + 30, 48 + j * 62));
      s.metin(x0 + 30, 240, etiket, { kalin: true, boyut: 13 });
    }
  });
  new Set([p.ana, p.yan]).forEach((k) => s.anlamRengi(IS_RENK[k], 'yanan lamba', { koyuZemin: true }));
  return { sahne: s, alt: 'İki yollu kavşakta iki trafik ışığı; her ışığın yanındaki etiket hangi yola ait olduğunu gösterir.', olgular: { ana: p.ana, yan: p.yan } };
}

// ---------- belge kartı (duyuru / ilan / davetiye) ----------
// parametreler: { tur, baslik, satirlar:[{etiket, deger}] }  Türkçe "görsel okuma" soruları için.
function belgeKart(p, profil) {
  const n = p.satirlar.length; if (n < 2 || n > 6) hata('satir_sayisi_2_6');
  const W = 360, H = 74 + n * 32 + 14, s = new Sahne(W, H, profil);
  s.dikdortgen(8, 8, W - 16, H - 16, { renk: PALET.siyah, kalinlik: 2 });
  s.dikdortgen(8, 8, W - 16, 46, { dolgu: PALET.mavi, renk: PALET.mavi, kalinlik: 1 });
  s.metin(W / 2, 38, p.baslik, { boyut: 17, kalin: true, renk: '#FFFFFF' });
  p.satirlar.forEach((r, i) => {
    const y = 84 + i * 32;
    s.metin(22, y, `${r.etiket}:`, { hiza: 'start', kalin: true, boyut: 14 });
    s.metin(122, y, r.deger, { hiza: 'start', boyut: 14 });
    if (i < n - 1) s.cizgi(20, y + 12, W - 20, y + 12, { renk: PALET.gri, kalinlik: 0.6, izgara: true });
  });
  const alanlar = Object.fromEntries(p.satirlar.map((r) => [r.etiket, r.deger]));
  return { sahne: s, alt: `${p.tur} kartı: ${p.baslik}. Kartta şu başlıklar yazılıdır: ${p.satirlar.map((r) => r.etiket).join(', ')}.`, olgular: { alanlar } };
}

// ---------- kesir modeli (şerit / pasta) ----------
// parametreler: { tur:'serit'|'pasta', payda, pay }  Taralı pay sayısı soldan/üstten saat yönünde.
function kesirModeli(p, profil) {
  if (!(p.pay > 0 && p.pay < p.payda && p.payda <= 12)) hata('kesir_gecersiz');
  const turuncu = PALET.turuncu;
  if (p.tur === 'serit') {
    const W = 320, H = 84, x0 = 20, w = 280, h = 44, y = 20, s = new Sahne(W, H, profil), bw = w / p.payda;
    for (let i = 0; i < p.payda; i++) s.dikdortgen(x0 + i * bw, y, bw, h, { dolgu: i < p.pay ? turuncu : '#FFFFFF', renk: PALET.siyah, kalinlik: 1.6 });
    return { sahne: s, alt: `Eş parçalara bölünmüş bir şerit modeli; parçaların bir kısmı taralıdır.`, olgular: kesirOlgu(p) };
  }
  if (p.tur !== 'pasta') hata(`tur_bilinmiyor:${p.tur}`);
  const W = 220, H = 220, cx = 110, cy = 110, r = 90, s = new Sahne(W, H, profil), adim = 360 / p.payda;
  for (let i = 0; i < p.payda; i++) s.dilim(cx, cy, r, 90 - (i + 1) * adim, 90 - i * adim, { dolgu: i < p.pay ? turuncu : '#FFFFFF', renk: PALET.siyah, kalinlik: 1.6 });
  return { sahne: s, alt: 'Eş dilimlere bölünmüş bir daire modeli; dilimlerin bir kısmı taralıdır.', olgular: kesirOlgu(p) };
}
const kesirOlgu = (p) => ({ pay: p.pay, payda: p.payda, tarali: `${p.pay}/${p.payda}`, tarali_olmayan: `${p.payda - p.pay}/${p.payda}` });

// ---------- şekil örüntü dizisi ----------
// parametreler: { dizi:[şekil…], siradaki }  Son hücre "?" ile gösterilir; dizi en az iki tekrar göstermelidir.
const SEKIL_RENK = { daire: PALET.mavi, kare: PALET.turuncu, ucgen: PALET.yesil, dikdortgen: PALET.pembe };
function oruntuDizisi(p, profil) {
  const n = p.dizi.length; if (n < 4 || n > 7) hata('dizi_4_7');
  const tam = [...p.dizi, p.siradaki]; let u = 0;
  for (let k = 1; k <= Math.floor(n / 2) && !u; k++) if (tam.every((x, i) => x === tam[i % k])) u = k;
  if (!u) hata('oruntu_belirsiz');
  const cell = 50, W = (n + 1) * cell + 24, H = 84, s = new Sahne(W, H, profil), b = 15;
  p.dizi.forEach((sk, i) => {
    const cx = 12 + cell * (i + 0.5), cy = 42, renk = SEKIL_RENK[sk] ?? hata(`sekil_bilinmiyor:${sk}`);
    if (sk === 'daire') s.cember(cx, cy, b, { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
    else if (sk === 'kare') s.dikdortgen(cx - b, cy - b, 2 * b, 2 * b, { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
    else if (sk === 'ucgen') s.poligon([[cx, cy - b - 2], [cx - b - 2, cy + b], [cx + b + 2, cy + b]], { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
    else s.dikdortgen(cx - b - 5, cy - b + 4, 2 * b + 10, 2 * b - 8, { dolgu: renk, renk: PALET.siyah, kalinlik: 1.2 });
  });
  const qx = 12 + cell * (n + 0.5);
  s.dikdortgen(qx - 20, 22, 40, 40, { renk: PALET.siyah, kalinlik: 1.4 });
  s.metin(qx, 49, '?', { boyut: 20, kalin: true });
  return { sahne: s, alt: 'Şekillerden oluşan bir örüntü; son kutu boştur ve soru işareti vardır.', olgular: { dizi: p.dizi, siradaki: p.siradaki, birim_uzunlugu: u } };
}

export const TIPLER_EK = {
  'belge-kart': belgeKart,
  'kesir-modeli': kesirModeli,
  'oruntu-dizisi': oruntuDizisi,
  'sutun-grafigi': sutunGrafigi,
  'cubuk-oruntusu': cubukOruntusu,
  'nesne-sayma': nesneSayma,
  'yer-haritasi': yerHaritasi,
  'trafik-isigi': trafikIsigi,
  'trafik-kavsak': trafikKavsak,
};
void aciRad;

