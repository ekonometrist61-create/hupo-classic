// Ajan B3 için şekil tipleri. Sözleşme: render(parametreler, profil) -> { sahne, alt, olgular }. Tip adları 'b3-' önekiyle.
// Türkçe (okuma/yazma görselleri) ve Sosyal Bilgiler (şema, liste) için: harf kutuları, numaralı kartlar, cümle satırı,
// tablo, fiyat etiketi, vurgulu metin, şiir, numaralı liste/akış, düz metin kartı.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const FONT = 'Arial, Helvetica, sans-serif';
const yuv = (n) => Math.round(n * 100) / 100;
const kacis = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

// Arial yaklaşık genişlik tablosu (1/1000 em): yazı konumlarını ve altı çizgi uzunluğunu gerçeğe yakın hesaplamak için.
const GEN = {};
const tanim = (harfler, w) => { for (const c of harfler) GEN[c] = w; };
tanim(' !,./:;', 278); tanim('-()', 333); tanim("'", 191); tanim('’', 222); tanim('"', 355); tanim('?', 556); tanim('0123456789', 556); tanim('–', 556);
tanim('abdeghnopqu', 556); tanim('cksvxyz', 500); tanim('fţt', 278); tanim('ij', 222); tanim('l', 222); tanim('m', 833); tanim('r', 333); tanim('w', 722);
tanim('çş', 500); tanim('ğöü', 556); tanim('ı', 278); tanim('âû', 556); tanim('î', 278);
tanim('ABEKPSVXY', 667); tanim('CDHNRUÇ', 722); tanim('FZ', 611); tanim('GOQĞÖ', 778); tanim('IJİ', 278); GEN.J = 500; GEN.L = 556; GEN.M = 833; GEN.T = 611; GEN.W = 944; GEN.Ş = 667; GEN.Ü = 722;
export function gen(str, boyut, kalin = false) {
  let w = 0; for (const c of String(str)) w += GEN[c] ?? 560;
  return (w / 1000) * boyut * (kalin ? 1.07 : 1);
}

// Türkçede her hecede tam bir ünlü bulunur: hece sayısı = ünlü sayısı.
const UNLU = 'aeıioöuüâîû';
export const unluSay = (s) => [...String(s).toLocaleLowerCase('tr-TR')].filter((c) => UNLU.includes(c)).length;

// Doğru ölçüyle yazı: kutuyu gerçek genişlikle kaydeder (lint çakışma denetimi için).
function yaz(s, x, y, str, { boyut, kalin = false, renk = PALET.siyah, hiza = 'start' } = {}) {
  const w = gen(str, boyut, kalin);
  const x0 = hiza === 'middle' ? x - w / 2 : hiza === 'end' ? x - w : x;
  s.metinKutulari.push({ x0, y0: y - boyut, x1: x0 + w, y1: y + boyut * 0.25, metin: String(str), boyut });
  s.parcalar.push(`<text x="${yuv(x)}" y="${yuv(y)}" font-family="${FONT}" font-size="${boyut}" text-anchor="${hiza}" fill="${s._renk(renk)}"${kalin ? ' font-weight="700"' : ''}>${kacis(str)}</text>`);
  return w;
}
const rozet = (s, cx, cy, no, r = 12, boyut = 15) => { s.cember(cx, cy, r, { kalinlik: 1.8 }); yaz(s, cx, cy + boyut * 0.36, String(no), { boyut, kalin: true, hiza: 'middle' }); };
const sinirla = (profil, b, W) => { const min = profil.minYaziPx; if ((b * 360) / W < min) hata(`yazi_kucuk_olur:W=${Math.round(W)}`); };

// ---------- 1) harf kutuları ----------
// parametreler: { sozcuk }  Harfler sıra numaralı kutulara yazılır (2–10 harf). Ünlü/hece sayısı çözücüdür.
function harfKutu(p, profil) {
  const h = [...p.sozcuk]; const n = h.length; if (n < 2 || n > 10) hata('harf_sayisi_2_10');
  const bw = 34, g = 4, W = Math.max(240, n * (bw + g) - g + 28), H = 104, s = new Sahne(W, H, profil);
  const x0 = (W - (n * (bw + g) - g)) / 2;
  h.forEach((c, i) => {
    const x = x0 + i * (bw + g);
    s.dikdortgen(x, 42, bw, 46, { kalinlik: 2 });
    yaz(s, x + bw / 2, 76, c, { boyut: 26, kalin: true, hiza: 'middle' });
    yaz(s, x + bw / 2, 32, String(i + 1), { boyut: 16, hiza: 'middle' });
  });
  sinirla(profil, 16, W);
  const harfler = Object.fromEntries(h.map((c, i) => [String(i + 1), c]));
  return { sahne: s, alt: 'Harf kutularına yazılmış bir sözcük; kutuların üstünde sıra numaraları var.', olgular: { harf_sayisi: n, hece_sayisi: unluSay(p.sozcuk), unlu_sayisi: unluSay(p.sozcuk), harfler, ilk: h[0], son: h[n - 1] } };
}

// ---------- 2) numaralı kartlar ----------
// parametreler: { duzen:'chip'|'liste', kartlar:[{metin, sira}] }  Kartlar dizideki sırayla gösterilir ve 1..n numaralanır; `sira` mantıksal konumdur (çizilmez).
function kartlar(p, profil) {
  const n = p.kartlar.length; if (n < 2 || n > 6) hata('kart_sayisi_2_6');
  const b = profil.yazi, W = 360;
  if (new Set(p.kartlar.map((k) => k.sira)).size !== n) hata('sira_tekrar');
  let s;
  if (p.duzen === 'liste') {
    const rowH = b * 1.25 + 18; const H = 14 + n * (rowH + 8) + 6; s = new Sahne(W, H, profil);
    p.kartlar.forEach((k, i) => {
      const y = 14 + i * (rowH + 8); const cy = y + rowH / 2;
      if (gen(k.metin, b) > W - 58 - 22) hata(`kart_uzun:${k.metin}`);
      s.dikdortgen(12, y, W - 24, rowH, { kalinlik: 1.6 });
      rozet(s, 34, cy, i + 1, 13, 15);
      yaz(s, 58, cy + b * 0.35, k.metin, { boyut: b });
    });
  } else {
    const chipH = b * 1.25 + 16, gapX = 10, gapY = 12; let x = 16, y = 14, satir = 1; const yer = [];
    for (const k of p.kartlar) {
      const w = 36 + gen(k.metin, b) + 14; if (w > W - 32) hata(`kart_uzun:${k.metin}`);
      if (x + w > W - 16) { x = 16; y += chipH + gapY; satir += 1; }
      yer.push([x, y, w]); x += w + gapX;
    }
    const H = 14 + satir * chipH + (satir - 1) * gapY + 16; s = new Sahne(W, H, profil);
    p.kartlar.forEach((k, i) => {
      const [cx, cy, w] = yer[i];
      s.dikdortgen(cx, cy, w, chipH, { kalinlik: 1.6 });
      rozet(s, cx + 18, cy + chipH / 2, i + 1, 12, 15);
      yaz(s, cx + 36, cy + chipH / 2 + b * 0.35, k.metin, { boyut: b });
    });
  }
  sinirla(profil, 15, W);
  const no = Object.fromEntries(p.kartlar.map((k, i) => [String(i + 1), k.metin]));
  const sirali = p.kartlar.map((k, i) => ({ no: i + 1, sira: k.sira })).sort((a, c) => a.sira - c.sira);
  return { sahne: s, alt: 'Numaralı kartlar; her kartın içinde kısa bir yazı var.', olgular: { kartlar: no, no_sirasi: sirali.map((x) => x.no), cumle: [...p.kartlar].sort((a, c) => a.sira - c.sira).map((k) => k.metin).join(' ') } };
}

// ---------- 3) cümle satırı ----------
// parametreler: { mod:'bosluk', cumle:'Ayşe Ankara▢ya gitti▢', isaret? } ▢ boş kutudur.
//               { mod:'kelime', kelimeler:[..], hedef? }  Her sözcüğün altında sıra numarası vardır.
function cumle(p, profil) {
  const b = Math.round(profil.yazi * 1.2), W = 360, bas = 26, son = W - 24, bw = 24;
  const bosluk = p.mod === 'bosluk';
  const sozler = bosluk ? p.cumle.split(' ') : p.kelimeler;
  if (!bosluk && (sozler.length < 4 || sozler.length > 9)) hata('kelime_sayisi_4_9');
  const adim = bosluk ? b * 2.0 : b + 50, bosKel = gen(' ', b) + 3;
  const parcalar = (w) => w.split('▢');
  const genislik = (w) => { const pc = parcalar(w); return pc.reduce((t, x) => t + gen(x, b), 0) + (pc.length - 1) * bw; };
  const yer = []; let x = bas, satir = 0;
  for (const w of sozler) {
    const tw = genislik(w); if (tw > son - bas) hata('sozcuk_uzun');
    if (x > bas && x + tw > son) { x = bas; satir += 1; }
    yer.push([x, satir, tw]); x += tw + bosKel;
  }
  if (satir > 2) hata('cumle_uzun');
  const H = 30 + (satir + 1) * adim + (bosluk ? 0 : 6), s = new Sahne(W, H, profil);
  s.dikdortgen(8, 8, W - 16, H - 16, { kalinlik: 1.6 });
  const y0 = 22 + b * 1.2;
  sozler.forEach((w, i) => {
    const [px, sr, tw] = yer[i]; const y = y0 + sr * adim; let cx = px;
    parcalar(w).forEach((pc, j, arr) => {
      if (pc) cx += yaz(s, cx, y, pc, { boyut: b });
      if (j < arr.length - 1) { s.dikdortgen(cx + 1, y - b * 0.95, bw - 2, b * 1.2, { kalinlik: 1.6, dolgu: '#F3F4F6' }); cx += bw; }
    });
    if (!bosluk) rozet(s, px + tw / 2, y + 24, i + 1, 11, 14);
  });
  if (!bosluk) sinirla(profil, 14, W);
  const olgular = bosluk ? { cumle: p.cumle, kutu_sayisi: (p.cumle.match(/▢/g) ?? []).length, isaret: p.isaret ?? null }
    : { kelimeler: Object.fromEntries(sozler.map((w, i) => [String(i + 1), w])), hedef: p.hedef ?? null };
  return { sahne: s, alt: bosluk ? 'Bir cümle; cümlede noktalama işareti yazılmamış boş kutular var.' : 'Bir cümlenin sözcükleri; her sözcüğün altında sıra numarası var.', olgular };
}

// ---------- 4) tablo ----------
// parametreler: { baslik?, sutunlar:[..], satirlar:[[..]] }  İlk sütun satır adıdır (olgularda anahtar).
function tablo(p, profil) {
  const b = profil.yazi, nS = p.sutunlar.length; if (nS < 2 || nS > 5) hata('sutun_2_5');
  if (p.satirlar.length < 2 || p.satirlar.length > 8) hata('satir_2_8');
  const cw = p.sutunlar.map((ad, j) => Math.max(gen(ad, b, true), ...p.satirlar.map((r) => gen(String(r[j]), b))) + 20);
  const toplam = cw.reduce((t, v) => t + v, 0), W = Math.max(300, toplam + 28);
  const limit = Math.floor((360 * b) / profil.minYaziPx); if (W > limit) hata(`tablo_genis:${Math.round(W)}`);
  const rowH = b * 1.25 + 14, baslikH = p.baslik ? b * 1.25 + 14 : 0, H = 14 + baslikH + (p.satirlar.length + 1) * rowH + 14, s = new Sahne(W, H, profil);
  const x0 = (W - toplam) / 2; let y = 14;
  if (p.baslik) { yaz(s, W / 2, y + b + 4, p.baslik, { boyut: b, kalin: true, hiza: 'middle' }); y += baslikH; }
  s.dikdortgen(x0, y, toplam, rowH, { dolgu: '#E5E7EB', kalinlik: 1.6 });
  const hucre = (satir, j, metin, kalin) => { const cx = x0 + cw.slice(0, j).reduce((t, v) => t + v, 0) + cw[j] / 2; yaz(s, cx, satir + 7 + b, String(metin), { boyut: b, kalin, hiza: 'middle' }); };
  p.sutunlar.forEach((ad, j) => hucre(y, j, ad, true));
  p.satirlar.forEach((r, i) => { const yy = y + (i + 1) * rowH; s.dikdortgen(x0, yy, toplam, rowH, { kalinlik: 1.2 }); r.forEach((v, j) => hucre(yy, j, v, false)); });
  let cx = x0; for (let j = 0; j < nS - 1; j++) { cx += cw[j]; s.cizgi(cx, y, cx, y + (p.satirlar.length + 1) * rowH, { kalinlik: 1.2, izgara: true }); }
  const hucreO = {}; for (const r of p.satirlar) { hucreO[String(r[0])] = Object.fromEntries(p.sutunlar.slice(1).map((ad, j) => [ad, r[j + 1]])); }
  return { sahne: s, alt: `Satır ve sütunlardan oluşan bir tablo${p.baslik ? `: ${p.baslik}` : ''}.`, olgular: { sutunlar: p.sutunlar, hucre: hucreO } };
}

// ---------- 5) fiyat etiketi ----------
// parametreler: { urun, tutar, bicim:'rakam'|'yazi' }  rakam: büyük puntolu "245 TL"; yazi: sözcüklerle yazılmış tutar (en çok 3 satır).
function etiketTipi(p, profil) {
  const b = profil.yazi, W = 340, sol = 90, sag = W - 24, genis = sag - sol - 6;
  let satirlar, tb;
  if (p.bicim === 'rakam') { satirlar = [p.tutar]; tb = 34; if (gen(p.tutar, tb, true) > genis) hata('tutar_uzun'); }
  else if (p.bicim === 'yazi') {
    tb = 19; satirlar = []; let cur = '';
    for (const w of p.tutar.split(' ')) { const d = cur ? `${cur} ${w}` : w; if (gen(d, tb, true) <= genis) cur = d; else { satirlar.push(cur); cur = w; } }
    if (cur) satirlar.push(cur); if (satirlar.length > 3) hata('tutar_cok_satir');
  } else hata('bicim_bilinmiyor');
  if (gen(p.urun, b, true) > genis) hata('urun_uzun');
  const H = 40 + b + 18 + satirlar.length * (tb + 10) + 14, s = new Sahne(W, H, profil);
  s.poligon([[62, 14], [W - 14, 14], [W - 14, H - 14], [62, H - 14], [22, H / 2]], { kalinlik: 2.4 });
  s.cember(56, H / 2, 6, { kalinlik: 2 });
  yaz(s, sol, 14 + b + 14, p.urun, { boyut: b, kalin: true });
  satirlar.forEach((t, i) => yaz(s, sol, 14 + b + 14 + 18 + tb + i * (tb + 10), t, { boyut: tb, kalin: true }));
  return { sahne: s, alt: 'Üzerinde ürün adı ve fiyat yazan bir fiyat etiketi.', olgular: { urun: p.urun, tutar: p.tutar } };
}

// ---------- 6) vurgulu metin ----------
// parametreler: { baslik?, satirlar:[[{t, s?:'koyu'|'alt'|'cerceve'}]] }  Biçimli parçalarda baş/son boşluk olmaz; boşluklar düz parçalardadır.
function vurgulu(p, profil) {
  const b = profil.yazi + 1, L = b * 2.0; const metinW = (satir) => satir.reduce((t, g) => t + gen(g.t, b, g.s === 'koyu'), 0);
  const en = Math.max(...p.satirlar.map(metinW)), W = Math.max(330, en + 48);
  const limit = Math.floor((360 * b) / profil.minYaziPx); if (W > limit) hata(`metin_genis:${Math.round(W)}`);
  const bas = p.baslik ? b * 2.0 : 0, H = 20 + bas + p.satirlar.length * L + 14, s = new Sahne(W, H, profil);
  if (p.baslik) yaz(s, W / 2, 20 + b, p.baslik, { boyut: b + 1, kalin: true, hiza: 'middle' });
  const stil = { koyu: [], alt: [], cerceve: [] };
  p.satirlar.forEach((satir, i) => {
    const y = 20 + bas + b + i * L; let x = 26;
    for (const g of satir) {
      if (g.s && (g.t !== g.t.trim())) hata('bicimli_parca_bosluklu');
      const w = yaz(s, x, y, g.t, { boyut: b, kalin: g.s === 'koyu' });
      if (g.s === 'alt') s.cizgi(x, y + b * 0.32, x + w, y + b * 0.32, { kalinlik: 1.8 });
      if (g.s === 'cerceve') s.dikdortgen(x - 3, y - b * 0.95, w + 6, b * 1.25 + 2, { kalinlik: 1.6 });
      if (g.s) stil[g.s].push(g.t);
      x += w;
    }
  });
  return { sahne: s, alt: 'Kısa bir bilgi metni; metindeki bazı ifadeler farklı biçimlerde vurgulanmış.', olgular: { stil } };
}

// ---------- 7) şiir ----------
// parametreler: { kitalar:[[dize..]..], baslik? }  Boşluk bırakılan bölümler kıtadır.
function siir(p, profil) {
  const b = profil.yazi + 1, L = b * 1.75, ara = 14; const dizeler = p.kitalar.flat();
  if (p.kitalar.length < 2 || p.kitalar.length > 5 || dizeler.length > 16) hata('siir_boyut');
  const en = Math.max(...dizeler.map((d) => gen(d, b))), W = Math.max(300, en + 70);
  const limit = Math.floor((360 * b) / profil.minYaziPx); if (W > limit) hata(`siir_genis:${Math.round(W)}`);
  const bas = p.baslik ? b * 2.2 : 0, H = 18 + bas + dizeler.length * L + (p.kitalar.length - 1) * ara + 12, s = new Sahne(W, H, profil);
  if (p.baslik) yaz(s, W / 2, 18 + b, p.baslik, { boyut: b, kalin: true, hiza: 'middle' });
  let y = 18 + bas + b;
  p.kitalar.forEach((k, i) => { k.forEach((d) => { yaz(s, 34, y, d, { boyut: b }); y += L; }); if (i < p.kitalar.length - 1) y += ara; });
  const son = {}, hece = {};
  p.kitalar.forEach((k, i) => k.forEach((d, j) => { son[`${i + 1}.${j + 1}`] = d.replace(/[.,;:!?…]+$/u, '').split(' ').pop(); hece[`${i + 1}.${j + 1}`] = unluSay(d); }));
  // Uyak düzeni: dizelerin son üç harfi aynı olanlara aynı harf verilir (yarım/tam uyak yaklaşımı).
  const kitaSema = p.kitalar.map((k) => { const m = new Map(); return k.map((d) => { const a = d.replace(/[.,;:!?…]+$/u, '').split(' ').pop().slice(-3).toLocaleLowerCase('tr-TR'); if (!m.has(a)) m.set(a, 'abcdefgh'[m.size]); return m.get(a); }).join(''); });
  return { sahne: s, alt: 'Boşluklarla ayrılmış bölümlerden oluşan kısa bir şiir.', olgular: { kita_sayisi: p.kitalar.length, dize_sayisi: dizeler.length, kita_dize: p.kitalar.map((k) => k.length), son_sozcuk: son, hece, kita_sema: kitaSema, sema: new Set(kitaSema).size === 1 ? kitaSema[0] : null } };
}

// ---------- 8) numaralı liste / akış ----------
// parametreler: { baslik?, ogeler:[metin], ok? }  Kutular dizideki sırayla yukarıdan aşağı gösterilir; ok:true ise aralarında aşağı ok çizilir.
function numarali(p, profil) {
  const b = profil.yazi, n = p.ogeler.length; if (n < 3 || n > 6) hata('oge_sayisi_3_6');
  const W = 360, rowH = b * 1.25 + 18, ara = p.ok ? 22 : 8, bas = p.baslik ? b * 1.25 + 14 : 0, H = 14 + bas + n * rowH + (n - 1) * ara + 14, s = new Sahne(W, H, profil);
  if (p.baslik) yaz(s, W / 2, 14 + b + 2, p.baslik, { boyut: b, kalin: true, hiza: 'middle' });
  p.ogeler.forEach((t, i) => {
    const y = 14 + bas + i * (rowH + ara), cy = y + rowH / 2;
    if (gen(t, b) > W - 60 - 22) hata(`oge_uzun:${t}`);
    s.dikdortgen(12, y, W - 24, rowH, { kalinlik: 1.6 });
    rozet(s, 34, cy, i + 1, 13, 15);
    yaz(s, 58, cy + b * 0.35, t, { boyut: b });
    if (p.ok && i < n - 1) s.cizgi(W / 2, y + rowH + 2, W / 2, y + rowH + ara - 2, { ok: true, kalinlik: 2 });
  });
  sinirla(profil, 15, W);
  return { sahne: s, alt: p.ok ? 'Okla birbirine bağlanmış numaralı kutular; her kutuda kısa bir yazı var.' : 'Numaralı kutular; her kutuda kısa bir yazı var.', olgular: { ogeler: Object.fromEntries(p.ogeler.map((t, i) => [String(i + 1), t])) } };
}

// ---------- 9) düz metin kartı ----------
// parametreler: { baslik?, satirlar:[ string | {t, kalin?, ortala?, sag?} ] }
function metinKarti(p, profil) {
  const b = profil.yazi + 1, L = b * 1.7; const S = p.satirlar.map((x) => (typeof x === 'string' ? { t: x } : x));
  if (S.length < 3 || S.length > 10) hata('satir_3_10');
  const en = Math.max(...S.map((x) => gen(x.t, b, x.kalin))), W = Math.max(300, en + 50);
  const limit = Math.floor((360 * b) / profil.minYaziPx); if (W > limit) hata(`metin_genis:${Math.round(W)}`);
  const bas = p.baslik ? b * 2.0 : 0, H = 22 + bas + S.length * L + 10, s = new Sahne(W, H, profil);
  s.dikdortgen(8, 8, W - 16, H - 16, { kalinlik: 1.6 });
  if (p.baslik) yaz(s, W / 2, 22 + b, p.baslik, { boyut: b, kalin: true, hiza: 'middle' });
  S.forEach((x, i) => { const y = 22 + bas + b + i * L; yaz(s, x.ortala ? W / 2 : x.sag ? W - 26 : 26, y, x.t, { boyut: b, kalin: !!x.kalin, hiza: x.ortala ? 'middle' : x.sag ? 'end' : 'start' }); });
  return { sahne: s, alt: 'Çerçeve içinde yazılmış kısa bir yazı.', olgular: { satirlar: S.map((x) => x.t) } };
}

export const TIPLER_B3 = {
  'b3-harf-kutu': harfKutu,
  'b3-kartlar': kartlar,
  'b3-cumle': cumle,
  'b3-tablo': tablo,
  'b3-etiket': etiketTipi,
  'b3-vurgulu': vurgulu,
  'b3-siir': siir,
  'b3-numarali': numarali,
  'b3-metin': metinKarti,
};
