// Ajan B4 için şekil tipleri (İngilizce 2-8). Sözleşme: render(parametreler, profil) -> { sahne, alt, olgular }. Tip adları 'b4-' önekiyle.
// Not: alt metinler cevabı ya da şekildeki sayıları yazmaz; çözücü `olgular` içindedir.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const yv = (n) => Math.round(n * 100) / 100;
const GRI = '#9CA3AF', ACIK = '#E5E7EB', KOYU = '#1F2937';

// ---------- ortak veri ve yardımcılar (şablonlar da kullanır) ----------
export const GUNLER = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
export const GUN3 = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
export const AYLAR = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
export const AY_GUN = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
export const ERKEK = ['Tom', 'Ben', 'Max', 'Leo', 'Dan', 'Jack', 'Luke', 'Adam', 'Noah', 'Finn'];
export const KADIN = ['Anna', 'Lily', 'Mia', 'Emma', 'Zoe', 'Kate', 'Ella', 'Eva', 'Nora', 'Ruby'];
const BIRLER = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
const ONLAR = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];
export function sayiYazi(n) {
  if (n < 20) return BIRLER[n];
  if (n < 100) return ONLAR[Math.floor(n / 10)] + (n % 10 ? '-' + BIRLER[n % 10] : '');
  const y = Math.floor(n / 100), k = n % 100;
  return BIRLER[y] + ' hundred' + (k ? ' and ' + sayiYazi(k) : '');
}
const SIRA_KISA = { 1: 'first', 2: 'second', 3: 'third', 4: 'fourth', 5: 'fifth', 6: 'sixth', 7: 'seventh', 8: 'eighth', 9: 'ninth', 10: 'tenth', 11: 'eleventh', 12: 'twelfth', 13: 'thirteenth', 14: 'fourteenth', 15: 'fifteenth', 16: 'sixteenth', 17: 'seventeenth', 18: 'eighteenth', 19: 'nineteenth', 20: 'twentieth', 30: 'thirtieth', 40: 'fortieth', 50: 'fiftieth' };
export function sirayaYazi(n) {
  if (SIRA_KISA[n]) return SIRA_KISA[n];
  return ONLAR[Math.floor(n / 10)] + '-' + SIRA_KISA[n % 10];
}
export function sirayaRakam(n) {
  const son = n % 100;
  if (son >= 11 && son <= 13) return `${n}th`;
  return `${n}${{ 1: 'st', 2: 'nd', 3: 'rd' }[n % 10] ?? 'th'}`;
}
export const buyuk = (t) => t.charAt(0).toUpperCase() + t.slice(1);

// ham çizim yardımcıları: `cizgiler` listesine kaydedilmez (yazı–çizgi denetimine girmez), sınır noktaları kaydedilir
function hl(s, x1, y1, x2, y2, { renk = PALET.siyah, k = 2, kesik = false } = {}) {
  s.noktalar.push([x1, y1, 0], [x2, y2, 0]);
  s.parcalar.push(`<line x1="${yv(x1)}" y1="${yv(y1)}" x2="${yv(x2)}" y2="${yv(y2)}" stroke="${s._renk(renk)}" stroke-width="${k}" stroke-linecap="round"${kesik ? ' stroke-dasharray="5 4"' : ''}/>`);
}
function hc(s, cx, cy, r, { dolgu = 'none', renk = PALET.siyah, k = 1.5 } = {}) {
  s.noktalar.push([cx - r, cy - r, 0], [cx + r, cy + r, 0]);
  s.parcalar.push(`<circle cx="${yv(cx)}" cy="${yv(cy)}" r="${yv(r)}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${k}"/>`);
}
function hd(s, x, y, w, h, { dolgu = 'none', renk = KOYU, k = 1, r = 0 } = {}) {
  s.noktalar.push([x, y, 0], [x + w, y + h, 0]);
  s.parcalar.push(`<rect x="${yv(x)}" y="${yv(y)}" width="${yv(w)}" height="${yv(h)}" rx="${r}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${k}"/>`);
}
function hy(s, d, pts, { dolgu = 'none', renk = PALET.siyah, k = 1.5 } = {}) {
  for (const [x, y] of pts) s.noktalar.push([x, y, 0]);
  s.parcalar.push(`<path d="${d}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${k}" stroke-linejoin="round" stroke-linecap="round"/>`);
}
function hp(s, pts, { dolgu = 'none', renk = PALET.siyah, k = 1.5 } = {}) {
  for (const [x, y] of pts) s.noktalar.push([x, y, 0]);
  s.parcalar.push(`<polygon points="${pts.map(([x, y]) => `${yv(x)},${yv(y)}`).join(' ')}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${k}" stroke-linejoin="round"/>`);
}
// Yerel koordinatlı (±14) küçük simgeler: translate/scale ile yerleştirilir.
function grup(s, cx, cy, k, ic) {
  s.noktalar.push([cx - 14 * k, cy - 14 * k, 0], [cx + 14 * k, cy + 14 * k, 0]);
  s.parcalar.push(`<g transform="translate(${yv(cx)} ${yv(cy)}) scale(${k})">${ic}</g>`);
}

const IKON = {
  kalem: '<rect x="-13" y="-4" width="17" height="8" fill="#F5C542" stroke="#8A6D00" stroke-width="1.2"/><polygon points="4,-4 13,0 4,4" fill="#F0D2A8" stroke="#8A6D00" stroke-width="1.2"/><polygon points="10,-1.4 13,0 10,1.4" fill="#1F2937"/><rect x="-13" y="-4" width="4" height="8" fill="#F4A3B5" stroke="#8A6D00" stroke-width="1.2"/>',
  kitap: '<rect x="-9" y="-12" width="18" height="24" fill="#4A90D9" stroke="#1F4E8C" stroke-width="1.4"/><rect x="-9" y="-12" width="4" height="24" fill="#1F4E8C"/><line x1="-1" y1="-4" x2="6" y2="-4" stroke="#FFFFFF" stroke-width="1.6"/><line x1="-1" y1="2" x2="6" y2="2" stroke="#FFFFFF" stroke-width="1.6"/>',
  top: '<circle r="11" fill="#E8833A" stroke="#8A3F00" stroke-width="1.4"/><path d="M-11 0 H11" stroke="#8A3F00" stroke-width="1.2" fill="none"/><path d="M0 -11 Q7 0 0 11" stroke="#8A3F00" stroke-width="1.2" fill="none"/>',
  elma: '<circle cy="2" r="10" fill="#D94F3D" stroke="#7A1F14" stroke-width="1.4"/><line x1="0" y1="-8" x2="1" y2="-13" stroke="#6B4A1F" stroke-width="2"/><ellipse cx="6" cy="-10" rx="4.5" ry="2.4" fill="#4C9F50" stroke="#2D6A3E" stroke-width="1"/>',
  cetvel: '<rect x="-13" y="-5" width="26" height="10" fill="#F3E3B0" stroke="#8A7A3F" stroke-width="1.2"/><path d="M-9 -5V0M-5 -5V-2M-1 -5V0M3 -5V-2M7 -5V0M11 -5V-2" stroke="#8A7A3F" stroke-width="1.2" fill="none"/>',
  silgi: '<rect x="-11" y="-6" width="22" height="12" fill="#F4B6C2" stroke="#A8445A" stroke-width="1.3"/><rect x="-11" y="-6" width="9" height="12" fill="#4A90D9" stroke="#1F4E8C" stroke-width="1.3"/>',
  canta: '<path d="M-5 -8 Q0 -17 5 -8" stroke="#2D6A3E" stroke-width="2" fill="none"/><rect x="-10" y="-8" width="20" height="20" rx="3" fill="#5BA66B" stroke="#2D6A3E" stroke-width="1.4"/><rect x="-6" y="2" width="12" height="7" rx="1.5" fill="#8CCB97" stroke="#2D6A3E" stroke-width="1"/>',
  yildiz: '<polygon points="0,-12 3.5,-4 12,-3.5 5.5,2.5 7.5,11 0,6.5 -7.5,11 -5.5,2.5 -12,-3.5 -3.5,-4" fill="#F5C542" stroke="#8A6D00" stroke-width="1.2"/>',
};
export const IKON_ADI = { kalem: 'pencil', kitap: 'book', top: 'ball', elma: 'apple', cetvel: 'ruler', silgi: 'eraser', canta: 'bag', yildiz: 'star' };
export const IKON_COGUL = { kalem: 'pencils', kitap: 'books', top: 'balls', elma: 'apples', cetvel: 'rulers', silgi: 'erasers', canta: 'bags', yildiz: 'stars' };

// ---------- 1) takvim ----------
// parametreler: { basla:0..6 (Pazartesi=0, ayın 1'i), gun_sayisi:28..31, baslik?:'March', isaret?:[gün...] }
function takvim(p, profil) {
  const F = profil.yazi, W = 350, hw = 46, hh = Math.max(32, F + 16);
  const bas = p.basla, n = p.gun_sayisi;
  if (!(bas >= 0 && bas <= 6) || n < 28 || n > 31) hata('takvim_parametre');
  const satir = Math.ceil((bas + n) / 7), ust = p.baslik ? 38 : 8, bh = 28, x0 = (W - 7 * hw) / 2;
  const H = ust + bh + satir * hh + 8, s = new Sahne(W, H, profil);
  if (p.baslik) s.metin(W / 2, 26, p.baslik, { kalin: true, boyut: F + 2 });
  for (let c = 0; c < 7; c++) {
    hd(s, x0 + c * hw, ust, hw, bh, { dolgu: ACIK, renk: GRI });
    s.metin(x0 + c * hw + hw / 2, ust + bh / 2 + F * 0.35, GUN3[c]);
  }
  const isaret = new Set(p.isaret ?? []);
  const haftaninGunu = {};
  for (let d = 1; d <= n; d++) {
    const idx = bas + d - 1, r = Math.floor(idx / 7), c = idx % 7;
    const x = x0 + c * hw, y = ust + bh + r * hh;
    hd(s, x, y, hw, hh, { renk: GRI });
    if (isaret.has(d)) hc(s, x + hw / 2, y + hh / 2, Math.min(hw, hh) / 2 - 2, { renk: PALET.kirmizi, k: 3 });
    s.metin(x + hw / 2, y + hh / 2 + F * 0.35, String(d), { kalin: isaret.has(d) });
    haftaninGunu[String(d)] = GUNLER[idx % 7];
  }
  return { sahne: s, alt: 'Şekil: bir ayın takvim sayfası; bir gün daire içine alınmış olabilir.', olgular: { haftaninGunu, isaretli: [...isaret], gunSayisi: n, ay: p.baslik ?? null } };
}

// ---------- 2) hava durumu ----------
const HAVA = ['sunny', 'cloudy', 'rainy', 'snowy', 'windy', 'stormy'];
function bulut(s, cx, cy, renk = '#B9C2CF', k = 1) {
  hc(s, cx - 10 * k, cy + 3 * k, 9 * k, { dolgu: renk, renk, k: 1 });
  hc(s, cx + 2 * k, cy - 5 * k, 12 * k, { dolgu: renk, renk, k: 1 });
  hc(s, cx + 14 * k, cy + 4 * k, 8 * k, { dolgu: renk, renk, k: 1 });
  hd(s, cx - 19 * k, cy + 3 * k, 40 * k, 9 * k, { dolgu: renk, renk, k: 1 });
}
function havaIkon(s, tur, cx, cy) {
  if (tur === 'sunny') {
    for (let i = 0; i < 8; i++) { const a = (i * Math.PI) / 4; hl(s, cx + 18 * Math.cos(a), cy + 18 * Math.sin(a), cx + 25 * Math.cos(a), cy + 25 * Math.sin(a), { renk: '#C9A100', k: 3 }); }
    hc(s, cx, cy, 13, { dolgu: '#F7D54A', renk: '#C9A100', k: 2 });
  } else if (tur === 'cloudy') {
    bulut(s, cx - 8, cy - 10, '#D6DCE5', 0.7); bulut(s, cx, cy, '#B9C2CF', 1);
  } else if (tur === 'rainy') {
    bulut(s, cx, cy - 10, '#9AA5B5');
    for (const dx of [-12, 0, 12]) hl(s, cx + dx, cy + 8, cx + dx - 4, cy + 20, { renk: '#2F7FD0', k: 3 });
  } else if (tur === 'snowy') {
    bulut(s, cx, cy - 10, '#C9D3E0');
    for (const [dx, dy] of [[-12, 12], [0, 20], [12, 12]]) hc(s, cx + dx, cy + dy, 3.5, { dolgu: '#FFFFFF', renk: '#2F7FD0', k: 1.6 });
  } else if (tur === 'windy') {
    for (const dy of [-12, 0, 12]) hy(s, `M${cx - 22} ${cy + dy} q11 -9 22 0 t22 0`, [[cx - 22, cy + dy - 5], [cx + 22, cy + dy + 5]], { renk: '#4B5D73', k: 3 });
  } else if (tur === 'stormy') {
    bulut(s, cx, cy - 10, '#5B6573');
    hp(s, [[cx + 3, cy + 4], [cx - 8, cy + 20], [cx - 1, cy + 20], [cx - 6, cy + 32], [cx + 9, cy + 14], [cx + 2, cy + 14]], { dolgu: '#F5C400', renk: '#8A6D00', k: 1.2 });
  } else hata(`hava_bilinmiyor:${tur}`);
}
// parametreler: { gunler:[{ad:'Mon', hava:'sunny'|…}] }
function hava(p, profil) {
  const F = profil.yazi, g = p.gunler, N = g.length, cw = 70, W = N * cw + 20, H = 126;
  if (N < 2 || N > 5) hata('gun_sayisi');
  const s = new Sahne(W, H, profil);
  const havaGun = {}, gunler = {};
  g.forEach((x, i) => {
    const cx = 10 + i * cw + cw / 2;
    hd(s, 10 + i * cw + 3, 8, cw - 6, H - 16, { dolgu: '#FFFFFF', renk: GRI, k: 1.5, r: 8 });
    s.metin(cx, 36, x.ad, { kalin: true });
    havaIkon(s, x.hava, cx, 82);
    havaGun[x.ad] = x.hava; (gunler[x.hava] ??= []).push(x.ad);
  });
  return { sahne: s, alt: 'Şekil: günlere göre hava durumu simgeleri.', olgular: { hava: havaGun, gunler, sira: g.map((x) => x.ad) } };
}

// ---------- 3) aile ağacı ----------
// parametreler: { kisiler:{ gf, gm, fa, mo, un, c1, c2, cz } } her biri { ad, cin:'m'|'f' }
const ROLLER = ['gf', 'gm', 'fa', 'mo', 'un', 'c1', 'c2', 'cz'];
function aileIliskiler(k) {
  const m = (r) => k[r].cin === 'm';
  const il = {};
  const ek = (a, b, w) => { il[`${k[a].ad}>${k[b].ad}`] = w; };
  for (const c of ['c1', 'c2']) {
    ek('gf', c, 'grandfather'); ek('gm', c, 'grandmother'); ek('fa', c, 'father'); ek('mo', c, 'mother');
    ek('un', c, m('un') ? 'uncle' : 'aunt'); ek('cz', c, 'cousin');
    const d = c === 'c1' ? 'c2' : 'c1'; ek(d, c, m(d) ? 'brother' : 'sister');
  }
  ek('gf', 'cz', 'grandfather'); ek('gm', 'cz', 'grandmother'); ek('un', 'cz', m('un') ? 'father' : 'mother');
  ek('fa', 'cz', 'uncle'); ek('mo', 'cz', 'aunt'); ek('c1', 'cz', 'cousin'); ek('c2', 'cz', 'cousin');
  ek('gf', 'fa', 'father'); ek('gm', 'fa', 'mother'); ek('gf', 'un', 'father'); ek('gm', 'un', 'mother');
  ek('un', 'fa', m('un') ? 'brother' : 'sister'); ek('fa', 'un', 'brother');
  return il;
}
function aile(p, profil) {
  const F = profil.yazi, k = p.kisiler, W = 380, H = 232;
  for (const r of ROLLER) if (!k[r]?.ad || !['m', 'f'].includes(k[r].cin)) hata(`kisi_eksik:${r}`);
  if (new Set(ROLLER.map((r) => k[r].ad)).size !== ROLLER.length) hata('ad_tekrar');
  const s = new Sahne(W, H, profil);
  const konum = { gf: [150, 34], gm: [250, 34], fa: [90, 116], mo: [190, 116], un: [320, 116], c1: [100, 198], c2: [180, 198], cz: [320, 198] };
  const cz = (a, b, c, d) => s.cizgi(a, b, c, d, { kalinlik: 2 });
  cz(186, 34, 214, 34); cz(200, 34, 200, 75); cz(90, 75, 320, 75); cz(90, 75, 90, 101); cz(320, 75, 320, 101);
  cz(126, 116, 154, 116); cz(140, 116, 140, 157); cz(100, 157, 180, 157); cz(100, 157, 100, 183); cz(180, 157, 180, 183);
  cz(320, 131, 320, 183);
  for (const r of ROLLER) {
    const [cx, cy] = konum[r], e = k[r].cin === 'm';
    hd(s, cx - 36, cy - 15, 72, 30, { dolgu: e ? '#DCEBFA' : '#FBE3EF', renk: e ? '#2F7FD0' : '#B84A8C', k: 1.8, r: 6 });
    s.metin(cx, cy + F * 0.35, k[r].ad, { kalin: true });
  }
  const iliski = aileIliskiler(k), kimdir = {};
  for (const [a, w] of Object.entries(iliski)) {
    const [x, y] = a.split('>'); const anahtar = `${y}:${w}`;
    kimdir[anahtar] = anahtar in kimdir ? null : x; // aynı ilişkiyi taşıyan birden çok kişi varsa null
  }
  return { sahne: s, alt: 'Şekil: üç kuşaklı bir aile ağacı; kişilerin adları kutuların içindedir.', olgular: { iliski, kimdir } };
}

// Aile ağacı soru üreticisi (2. ve 3. sınıf şablonları ortak kullanır).
// secenek: { kod, kelimeler:[izinli ilişki sözcükleri], iliskiTuru:bool (X is Y's ___ sorusu serbest mi) }
export function aileSorusuUret({ R, sec, karistir, ekle }, { kod, kelimeler, iliskiTuru }) {
  const cin = { gf: 'm', gm: 'f', fa: 'm', mo: 'f', un: R() < 0.5 ? 'm' : 'f', c1: R() < 0.5 ? 'm' : 'f', c2: R() < 0.5 ? 'm' : 'f', cz: R() < 0.5 ? 'm' : 'f' };
  const erkekler = karistir(ERKEK), kadinlar = karistir(KADIN), k = {};
  for (const r of ROLLER) k[r] = { ad: (cin[r] === 'm' ? erkekler : kadinlar).pop(), cin: cin[r] };
  const il = aileIliskiler(k), cinAd = Object.fromEntries(ROLLER.map((r) => [k[r].ad, k[r].cin]));
  const adaylar = Object.entries(il).filter(([, w]) => kelimeler.includes(w));
  const [a, w] = sec(adaylar), [x, y] = a.split('>');
  const kind = iliskiTuru ? sec(['kim', 'iliski']) : 'kim';
  const spec = { tip_id: 'b4-aile', parametreler: { kisiler: k } };
  const ortak = { kod, konu: 'Family members', spec };
  const ayniCin = ROLLER.map((r) => k[r].ad).filter((n) => cinAd[n] === cinAd[x] && n !== x && n !== y);
  if (kind === 'kim') {
    if (adaylar.filter(([b, v]) => b.split('>')[1] === y && v === w).length !== 1) throw new Error('birden_cok_kisi');
    if (ayniCin.length < 3) throw new Error('yetersiz_cinsiyet_secenegi');
    const cel = karistir(ayniCin).slice(0, 3);
    ekle({ ...ortak, alt_konu: 'Aile ağacında akraba bulma', zorluk: ['grandfather', 'grandmother', 'uncle', 'aunt', 'cousin'].includes(w) ? 2 : 1,
      kok: `Look at the family tree. Who is ${y}'s ${w}?`, dogru: x, celdirici: cel,
      gerekce: cel.map((n) => (il[`${n}>${y}`] ? `${n}, ${y} için "${il[`${n}>${y}`]}" olur; "${w}" değildir.` : `${n}, ${y} ile bu akrabalık ilişkisinde değildir.`)),
      ipucu: `${y} kutusunu bul; yukarıdaki ve yandaki çizgileri takip et.`,
      cozum: [`Ağaçta ${y} bulunur ve çizgiler izlenir.`, `${y}'nin ${w} olan kişi ${x}'dir.`],
      dogrulama: [{ yol: ['kimdir', `${y}:${w}`], beklenen: x }] });
    return;
  }
  if (w === 'cousin') throw new Error('cousin_notr');
  const GEN = { m: ['father', 'brother', 'grandfather', 'uncle'], f: ['mother', 'sister', 'grandmother', 'aunt'] }[cinAd[x]];
  const cel = GEN.filter((v) => v !== w);
  if (cel.length !== 3) throw new Error('cinsiyet_uyumsuz');
  ekle({ ...ortak, alt_konu: 'Aile ağacında akrabalık adı', zorluk: 2, kok: `Look at the family tree. ${x} is ${y}'s ____.`, dogru: w, celdirici: cel,
    gerekce: cel.map((v) => `${x} için "${v}" doğru değildir; ağaçta ${x} ile ${y} arasındaki ilişki "${w}" biçimindedir.`),
    ipucu: `${x} ve ${y} kutularını bul; aralarındaki çizgilere bak.`, cozum: [`${x} ile ${y} arasındaki çizgiler izlenir.`, `${x}, ${y}'nin ${w} olan kişisidir.`],
    dogrulama: [{ yol: ['iliski', `${x}>${y}`], beklenen: w }] });
}

// ---------- 4) sayma ----------
// parametreler: dizilim:'satir' → { satirlar:[{tur, adet}], kolon? }  |  dizilim:'karisik' → { sira:[tur…], kolon? }
function sayma(p, profil) {
  const kol = p.kolon ?? 10, dx = p.aralik ?? 36, dy = p.satirYuk ?? 42, kk = p.olcek ?? 1.2;
  const W = kol * dx + 20; const yer = [];
  if (p.dizilim === 'satir') {
    let r = 0;
    for (const g of p.satirlar) {
      if (g.adet < 1) hata('adet_yok');
      for (let i = 0; i < g.adet; i++) yer.push([r + Math.floor(i / kol), i % kol, g.tur]);
      r += Math.ceil(g.adet / kol);
    }
  } else if (p.dizilim === 'karisik') {
    p.sira.forEach((t, i) => yer.push([Math.floor(i / kol), i % kol, t]));
  } else hata('dizilim_bilinmiyor');
  const satirSayisi = Math.max(...yer.map((y) => y[0])) + 1, H = 20 + dy * satirSayisi;
  const s = new Sahne(W, H, profil), sayi = {};
  for (const [r, c, t] of yer) {
    if (!IKON[t]) hata(`ikon_yok:${t}`);
    grup(s, 10 + dx * (c + 0.5), 10 + dy * (r + 0.5), kk, IKON[t]);
    sayi[t] = (sayi[t] ?? 0) + 1;
  }
  return { sahne: s, alt: 'Şekil: sayılacak nesneler.', olgular: { sayi } };
}

// ---------- 5) analog saat ----------
// parametreler: { saat:1..12, dakika:0..59 }
function saat(p, profil) {
  const W = 250, cx = 125, cy = 125, R = 108, F = profil.yazi, s = new Sahne(W, W, profil);
  const h = p.saat, m = p.dakika;
  if (!(h >= 1 && h <= 12) || !(m >= 0 && m < 60)) hata('saat_parametre');
  hc(s, cx, cy, R, { dolgu: '#FFFFFF', renk: PALET.siyah, k: 3.5 });
  for (let i = 0; i < 60; i++) {
    const a = (i * Math.PI) / 30, bol = i % 5 === 0, r1 = R - (bol ? 11 : 6);
    hl(s, cx + r1 * Math.sin(a), cy - r1 * Math.cos(a), cx + (R - 3) * Math.sin(a), cy - (R - 3) * Math.cos(a), { renk: bol ? PALET.siyah : GRI, k: bol ? 2.4 : 1.2 });
  }
  for (let i = 1; i <= 12; i++) {
    const a = (i * Math.PI) / 6;
    s.metin(cx + 86 * Math.sin(a), cy - 86 * Math.cos(a) + F * 0.35, String(i), { kalin: true });
  }
  const el = (L, aci, k, renk) => hl(s, cx, cy, cx + L * Math.sin(aci), cy - L * Math.cos(aci), { renk, k });
  el(0.62 * R, (m * Math.PI) / 30, 4, PALET.mavi);
  el(0.42 * R, (((h % 12) + m / 60) * Math.PI) / 6, 7, PALET.siyah);
  hc(s, cx, cy, 5.5, { dolgu: PALET.siyah, renk: PALET.siyah, k: 1 });
  return { sahne: s, alt: 'Şekil: iki ibreli analog saat.', olgular: { saat: h, dakika: m, dijital: `${h}:${String(m).padStart(2, '0')}` } };
}

// Saat okunuşu: stil 'g4' (tam, çeyrek, buçuk) | 'g5' (5'er dakika, "past/to") | 'dijital'.
export function saatYazi(h, m, stil) {
  const sat = (x) => BIRLER[((x - 1) % 12) + 1];
  if (stil === 'dijital') return `${h}:${String(m).padStart(2, '0')}`;
  if (m === 0) return `${sat(h)} o'clock`;
  if (m === 15) return `quarter past ${sat(h)}`;
  if (m === 30) return `half past ${sat(h)}`;
  if (m === 45) return `quarter to ${sat(h + 1)}`;
  if (m < 30) return `${sayiYazi(m)} past ${sat(h)}`;
  return `${sayiYazi(60 - m)} to ${sat(h + 1)}`;
}
// Saat soru üreticisi (4. ve 5. sınıf şablonları ortak kullanır).
export function saatSorusuUret({ R, sec, karistir, ekle }, { kod, dakikalar, stiller, konu }) {
  const stil = sec(stiller), h = 1 + Math.floor(R() * 12), m = sec(dakikalar);
  const gosterilen = (hh, mm) => (stil === 'dijital' ? hh : ((stil !== 'dijital' && mm > 30) ? (hh % 12) + 1 : hh));
  const yazi = (hh, mm) => saatYazi(hh, mm, stil), ayri = new Set([yazi(h, m)]), saatler = [[h, m]];
  const hs = Math.round(m / 5) || 12, ms = (h % 12) * 5;
  let tuzak = null;
  if (dakikalar.includes(ms) && ms !== m && (hs !== h || ms !== m)) tuzak = [hs, ms];
  const aday = () => [1 + Math.floor(R() * 12), sec(dakikalar)];
  const kullanilanSaat = new Set([gosterilen(h, m)]), kullanilanDk = new Set([m]), cel = [];
  const dene = ([hh, mm], zorunlu) => {
    if (!zorunlu) return false;
    const g = gosterilen(hh, mm), y = yazi(hh, mm);
    if (ayri.has(y) || kullanilanSaat.has(g) || kullanilanDk.has(mm)) return false;
    ayri.add(y); kullanilanSaat.add(g); kullanilanDk.add(mm); cel.push([hh, mm]); return true;
  };
  const tuzakVar = tuzak ? dene(tuzak, true) : false;
  for (let g = 0; cel.length < 3 && g < 300; g++) dene(aday(), true);
  if (cel.length < 3) throw new Error('celdirici_yok');
  const frames = [
    { s: 'What time is it?', a: (t) => `It's ${t}.` },
    { s: 'The film starts at this time. What time does the film start?', a: (t) => `The film starts at ${t}.` },
    { s: 'The bus leaves at this time. What time does the bus leave?', a: (t) => `The bus leaves at ${t}.` },
    { s: 'School starts at this time. What time does school start?', a: (t) => `School starts at ${t}.` },
  ];
  const f = sec(frames);
  const dogru = f.a(yazi(h, m)), celler = cel.map(([a, b]) => f.a(yazi(a, b)));
  const gerekce = cel.map(([a, b], i) => (i === 0 && tuzakVar ? `${yazi(a, b)}: akrep ile yelkovan karıştırılmıştır; kısa kalın ibre saati, uzun ince ibre dakikayı gösterir.` : `${yazi(a, b)}, saatin gösterdiği zaman değildir; ibrelerin konumu ${h}:${String(m).padStart(2, '0')} verir.`));
  ekle({ kod, konu, alt_konu: 'Analog saati okuma', zorluk: m === 0 ? 1 : m % 15 === 0 ? 2 : 3, spec: { tip_id: 'b4-saat', parametreler: { saat: h, dakika: m } },
    kok: `Look at the clock. ${f.s}`, dogru, celdirici: celler, gerekce,
    ipucu: 'Kısa, kalın ibre saati gösterir. Uzun, ince ibre dakikayı gösterir.',
    cozum: [`Kısa ibre ${h} ile ${h % 12 + 1} arasında/üzerindedir; uzun ibre ${m / 5 || 12} rakamındadır (${m} dakika).`, `Saat ${h}:${String(m).padStart(2, '0')}; İngilizcesi: ${yazi(h, m)}.`],
    dogrulama: [{ yol: ['dijital'], beklenen: `${h}:${String(m).padStart(2, '0')}` }] });
}

// ---------- 6) konum (in / on / under / next to) ----------
// parametreler: { duzen:'sol'|'sag', yerler:{ top:'on'|'under'|'in'|'next', kitap, elma, canta } }
const KONUM_YAZI = { on: 'on the table', under: 'under the table', in: 'in the box', next: 'next to the box' };
function konumSahnesi(p, profil) {
  const W = 380, H = 150, zy = 122, sag = p.duzen === 'sag';
  const s = new Sahne(W, H, profil);
  const X = (x) => (sag ? W - x : x), R = (a, b) => [Math.min(X(a), X(b)), Math.abs(X(b) - X(a))];
  hd(s, 0, zy, W, 8, { dolgu: '#C7CDD6', renk: '#C7CDD6' });
  const [px, pw] = R(30, 180); hd(s, px, 42, pw, 12, { dolgu: '#C98B4A', renk: '#7A4A1A', k: 1.6 });
  for (const [a, b] of [[38, 50], [160, 172]]) { const [lx, lw] = R(a, b); hd(s, lx, 54, lw, zy - 54, { dolgu: '#C98B4A', renk: '#7A4A1A', k: 1.6 }); }
  const [bx, bw] = R(228, 328); hd(s, bx, 68, bw, zy - 68, { dolgu: '#F3E3C0', renk: 'none' });
  hy(s, `M${X(228)} 64 V${zy} H${X(328)} V64`, [[X(228), 64], [X(328), zy]], { renk: '#7A4A1A', k: 5 });
  const nok = { on: [105, 42 - 15], under: [105, zy - 15], in: [278, zy - 20], next: [354, zy - 15] };
  const yerler = p.yerler, olgu = { yer: {}, nesne: {} };
  for (const [t, y] of Object.entries(yerler)) {
    if (!nok[y]) hata(`yer_bilinmiyor:${y}`);
    grup(s, X(nok[y][0]), nok[y][1], 1.05, IKON[t]);
    olgu.yer[IKON_ADI[t]] = KONUM_YAZI[y]; olgu.nesne[KONUM_YAZI[y]] = IKON_ADI[t];
  }
  if (new Set(Object.values(yerler)).size !== Object.keys(yerler).length) hata('yer_cakisma');
  return { sahne: s, alt: 'Şekil: bir masa, bir kutu ve çevrelerine yerleştirilmiş nesneler.', olgular: olgu };
}

// ---------- 7) tablo ----------
// parametreler: { baslik?, ilkSutun?, sutunlar:[…], satirlar:[{ad, hucreler:[…]}], tik?:bool }  tik: hücre 'x' → onay işareti
function tablo(p, profil) {
  const F = profil.yazi, tik = !!p.tik, sut = p.sutunlar, sat = p.satirlar;
  const bas = [p.ilkSutun ?? '', ...sut];
  const gen = bas.map((b, j) => {
    const uz = Math.max(String(b).length, ...sat.map((r) => String(j === 0 ? r.ad : (r.hucreler[j - 1] === 'x' ? '' : r.hucreler[j - 1])).length));
    return Math.max(tik && j > 0 ? 38 : 0, uz * F * 0.6 + 12);
  });
  const toplam = gen.reduce((a, b) => a + b, 0), sinir = Math.floor((360 * F) / profil.minYaziPx) - 8;
  if (toplam + 20 > sinir) hata('tablo_genis');
  const W = Math.max(toplam + 20, 270), x0 = (W - toplam) / 2, rh = Math.round(F * 2.2), ust = p.baslik ? 38 : 8;
  const H = ust + (sat.length + 1) * rh + 10, s = new Sahne(W, H, profil);
  if (p.baslik) s.metin(W / 2, 26, p.baslik, { kalin: true, boyut: F + 1 });
  let x = x0; const kx = [];
  for (const g of gen) { kx.push(x); x += g; }
  const olgu = { hucre: {}, sayim: {}, tik: {} };
  bas.forEach((b, j) => {
    hd(s, kx[j], ust, gen[j], rh, { dolgu: ACIK, renk: GRI });
    if (b) s.metin(kx[j] + gen[j] / 2, ust + rh / 2 + F * 0.35, String(b), { kalin: true });
  });
  sat.forEach((r, i) => {
    const y = ust + (i + 1) * rh;
    hd(s, kx[0], y, gen[0], rh, { dolgu: '#F3F4F6', renk: GRI });
    s.metin(kx[0] + 9, y + rh / 2 + F * 0.35, String(r.ad), { hiza: 'start', kalin: true });
    olgu.tik[r.ad] = 0;
    r.hucreler.forEach((c, j) => {
      const cxh = kx[j + 1], cw = gen[j + 1];
      hd(s, cxh, y, cw, rh, { renk: GRI });
      olgu.hucre[`${r.ad}|${sut[j]}`] = c;
      if (c === 'x' && tik) {
        const mx = cxh + cw / 2, my = y + rh / 2;
        hy(s, `M${mx - 7} ${my} L${mx - 2} ${my + 6} L${mx + 8} ${my - 7}`, [[mx - 7, my - 7], [mx + 8, my + 6]], { renk: PALET.yesil, k: 3.2 });
        olgu.tik[r.ad] += 1;
      } else if (c) { s.metin(cxh + cw / 2, y + rh / 2 + F * 0.35, String(c)); olgu.sayim[c] = (olgu.sayim[c] ?? 0) + 1; }
    });
  });
  return { sahne: s, alt: 'Şekil: satır ve sütunlardan oluşan bir tablo.', olgular: olgu };
}

// ---------- 8) sokak haritası ----------
// parametreler: { ust:[ad…], alt:[ad…] } aynı uzunlukta (3–4); adlar küçük harfle
function harita(p, profil) {
  const F = profil.yazi, n = p.ust.length, W = 400, aralik = 8, bw = Math.floor((W - 20 - (n - 1) * aralik) / n), bh = 64;
  if (p.alt.length !== n || n < 3 || n > 4) hata('satir_uzunlugu');
  const tum = [...p.ust, ...p.alt]; if (new Set(tum).size !== tum.length) hata('ad_tekrar');
  const H = 200, s = new Sahne(W, H, profil);
  hd(s, 0, 78, W, 44, { dolgu: '#E5E7EB', renk: '#E5E7EB' });
  for (let x = 14; x < W - 20; x += 36) hl(s, x, 100, x + 18, 100, { renk: '#FFFFFF', k: 3 });
  const pastel = ['#FDE7C8', '#D8EBFA', '#DDF2DD', '#F6DCEB'];
  const yaz = (ad, x, y0, i) => {
    const parca = ad.split(' ').map(buyuk), cx = x + bw / 2;
    parca.forEach((t, j) => s.metin(cx, y0 + 24 + j * (F + 5) + (parca.length === 1 ? 8 : 0), t, { kalin: true }));
  };
  const olgu = { konum: {}, yanyana: {}, karsi: {}, ara: {} };
  [p.ust, p.alt].forEach((satir, r) => {
    const y0 = r === 0 ? 12 : 124;
    satir.forEach((ad, i) => {
      const x = 10 + i * (bw + aralik);
      hd(s, x, y0, bw, bh, { dolgu: pastel[(i + r) % 4], renk: KOYU, k: 1.6, r: 3 });
      hd(s, x + bw / 2 - 7, r === 0 ? y0 + bh - 13 : y0, 14, 13, { dolgu: '#C7CDD6', renk: KOYU, k: 1 });
      yaz(ad, x, y0, i);
      olgu.konum[ad] = [r, i];
      if (i > 0) { olgu.yanyana[`${ad}|${satir[i - 1]}`] = true; olgu.yanyana[`${satir[i - 1]}|${ad}`] = true; }
      if (i > 0 && i < n - 1) olgu.ara[ad] = [satir[i - 1], satir[i + 1]];
      olgu.karsi[ad] = (r === 0 ? p.alt : p.ust)[i];
    });
  });
  return { sahne: s, alt: 'Şekil: bir sokağın iki yanındaki adlandırılmış binalar.', olgular: olgu };
}

// Harita soru üreticisi (5. ve 7. sınıf şablonları ortak kullanır). havuz: küçük harfli yer adları.
export function haritaSorusuUret({ R, sec, karistir, ekle }, { kod, konu, havuz }) {
  const n = sec([3, 4]), ad = karistir(havuz).slice(0, 2 * n), ust = ad.slice(0, n), alt = ad.slice(n);
  const poz = {}; [ust, alt].forEach((sat, r) => sat.forEach((a, i) => { poz[a] = [r, i]; }));
  const satirOf = (a) => (poz[a][0] === 0 ? ust : alt), tum = [...ust, ...alt];
  const komsu = (a, b) => poz[a][0] === poz[b][0] && Math.abs(poz[a][1] - poz[b][1]) === 1;
  const karsi = (a) => (poz[a][0] === 0 ? alt : ust)[poz[a][1]];
  const ara = (a) => (poz[a][1] > 0 && poz[a][1] < n - 1 ? [satirOf(a)[poz[a][1] - 1], satirOf(a)[poz[a][1] + 1]] : null);
  const spec = { tip_id: 'b4-harita', parametreler: { ust, alt } };
  const ortak = { kod, konu, spec };
  const X = sec(tum), kind = sec(['yan', 'karsi', 'ara']), dogrulamaKonum = [{ yol: ['konum', X], beklenen: poz[X] }];
  const buyukAd = (a) => a;
  if (kind === 'karsi') {
    const Y = karsi(X), cel = karistir(tum.filter((a) => a !== X && a !== Y)).slice(0, 3);
    ekle({ ...ortak, alt_konu: 'Karşısındaki yer', zorluk: 1, kok: `Look at the map. What is opposite the ${X}?`, dogru: `The ${Y}.`, celdirici: cel.map((a) => `The ${a}.`),
      gerekce: cel.map((a) => `${a}, ${X} yerinin karşısında değildir (yolun aynı tarafında ya da farklı sırada).`), ipucu: `${X} binasından yolun karşı tarafına, tam karşıya bak.`,
      cozum: [`${X} binasının tam karşısındaki bina ${Y}.`], dogrulama: [{ yol: ['karsi', X], beklenen: Y }] });
    return;
  }
  if (kind === 'ara') {
    const a2 = ara(X); if (!a2) throw new Error('orta_degil');
    const cel = karistir(tum.filter((a) => a !== X && !a2.includes(a))).slice(0, 3), sira = R() < 0.5 ? a2 : [a2[1], a2[0]];
    ekle({ ...ortak, alt_konu: 'İki yer arasındaki yer', zorluk: 3, kok: `Look at the map. What is between the ${sira[0]} and the ${sira[1]}?`, dogru: `The ${X}.`, celdirici: cel.map((a) => `The ${a}.`),
      gerekce: cel.map((a) => `${a}, ${sira[0]} ile ${sira[1]} arasında değildir.`), ipucu: `${sira[0]} ve ${sira[1]} aynı sırada, aralarında bir bina var.`,
      cozum: [`${sira[0]} ile ${sira[1]} arasındaki bina ${X}.`], dogrulama: [{ yol: ['ara', X], beklenen: a2 }] });
    return;
  }
  // yan: "Where is the X?" — X için doğru ve yanlış ifadeler
  const diger = tum.filter((a) => a !== X);
  const adaylar = [];
  for (const y of diger) { adaylar.push({ tip: 'yan', m: `It's next to the ${y}.`, d: komsu(X, y), y }); adaylar.push({ tip: 'karsi', m: `It's opposite the ${y}.`, d: karsi(X) === y, y }); }
  for (let i = 0; i < diger.length; i++) for (let j = i + 1; j < diger.length; j++) {
    const a2 = ara(X), d = !!a2 && a2.includes(diger[i]) && a2.includes(diger[j]);
    adaylar.push({ tip: 'ara', m: `It's between the ${diger[i]} and the ${diger[j]}.`, d, y: diger[i], z: diger[j] });
  }
  const dogruAdaylar = adaylar.filter((c) => c.d);
  const D = sec(dogruAdaylar), yanlis = [], kullanilan = new Set([D.m]);
  for (let g = 0; yanlis.length < 3 && g < 200; g++) {
    const tip = sec(['yan', 'karsi', 'ara']), havuzY = adaylar.filter((c) => !c.d && c.tip === tip && !kullanilan.has(c.m));
    if (!havuzY.length) continue;
    const c = sec(havuzY); kullanilan.add(c.m); yanlis.push(c);
  }
  if (yanlis.length < 3) throw new Error('yanlis_ifade_yok');
  const neden = (c) => (c.tip === 'yan' ? `${X}, ${c.y} binasının yanında değildir.` : c.tip === 'karsi' ? `${c.y}, ${X} binasının karşısında değildir.` : `${X}, ${c.y} ile ${c.z} arasında değildir.`);
  const dg = D.tip === 'yan' ? { yol: ['yanyana', `${X}|${D.y}`], beklenen: true } : D.tip === 'karsi' ? { yol: ['karsi', X], beklenen: D.y } : { yol: ['ara', X], beklenen: ara(X) };
  ekle({ ...ortak, alt_konu: 'Yer tarifi (next to / opposite / between)', zorluk: 2, kok: `Look at the map. Where is the ${X}?`, dogru: D.m, celdirici: yanlis.map((c) => c.m),
    gerekce: yanlis.map(neden), ipucu: `${X} binasını bul; yanındaki, karşısındaki ve iki yanındaki binalara bak.`, cozum: [`${X} binası haritada bulunur ve çevresine bakılır.`, `Doğru ifade: ${D.m}`], dogrulama: [...dogrulamaKonum, dg] });
}

// ---------- 9) çok katlı bina ----------
// parametreler: { baslangic:1.., katlar:[ad…] } katlar alttan üste sıralıdır (ilk eleman baslangic. kat)
function bina(p, profil) {
  const F = profil.yazi, N = p.katlar.length, kh = 26, W = 340, H = N * kh + 56;
  if (N < 5 || N > 10 || new Set(p.katlar).size !== N) hata('kat_parametre');
  const s = new Sahne(W, H, profil), x0 = 100, bw = 200, alt = H - 14;
  const olgu = { kat: {}, ad: {} };
  hp(s, [[x0 - 8, 40], [x0 + bw / 2, 14], [x0 + bw + 8, 40]], { dolgu: '#C98B4A', renk: '#7A4A1A', k: 1.6 });
  p.katlar.forEach((ad, i) => {
    const no = p.baslangic + i, y = alt - (i + 1) * kh + 2 - 4 + 4;
    hd(s, x0, y, bw, kh, { dolgu: i % 2 ? '#E6EEF8' : '#F7EEDB', renk: KOYU, k: 1.4 });
    s.metin(x0 + bw / 2, y + kh / 2 + F * 0.35, buyuk(ad), { kalin: true });
    s.metin(x0 - 14, y + kh / 2 + F * 0.35, String(no), { hiza: 'end', kalin: true });
    olgu.kat[ad] = no; olgu.ad[String(no)] = ad;
  });
  if (p.baslangic > 1) for (const dx of [-8, 0, 8]) hc(s, x0 + bw / 2 + dx, H - 6, 2, { dolgu: PALET.siyah, renk: PALET.siyah, k: 1 });
  return { sahne: s, alt: 'Şekil: kat numaraları yanında yazılı, her katta bir yer bulunan çok katlı bir bina.', olgular: olgu };
}

// ---------- 10) yüz (saç, aksesuar) ----------
// parametreler: { uzun:bool, kivircik:bool, aksesuar:'gozluk'|'atki', sacRenk?, gomlek? }
function yuz(p, profil) {
  const W = 200, H = 230, s = new Sahne(W, H, profil), cx = 100, cy = 98, r = 36;
  const sac = p.sacRenk ?? '#5B3A1F', ten = '#F2C6A0', gom = p.gomlek ?? '#6AA7D9';
  const olgu = { sac: `${p.uzun ? 'long' : 'short'} ${p.kivircik ? 'curly' : 'straight'}`, aksesuar: p.aksesuar === 'gozluk' ? 'glasses' : 'scarf' };
  if (p.uzun && !p.kivircik) { hd(s, cx - r - 6, 92, 20, 84, { dolgu: sac, renk: sac, k: 1, r: 9 }); hd(s, cx + r - 14, 92, 20, 84, { dolgu: sac, renk: sac, k: 1, r: 9 }); }
  if (p.uzun && p.kivircik) for (let i = 0; i < 5; i++) { hc(s, cx - r - 1, 100 + i * 16, 9.5, { dolgu: sac, renk: sac, k: 1 }); hc(s, cx + r + 1, 100 + i * 16, 9.5, { dolgu: sac, renk: sac, k: 1 }); }
  hp(s, [[cx - 45, 224], [cx - 45, 176], [cx - 20, 158], [cx + 20, 158], [cx + 45, 176], [cx + 45, 224]], { dolgu: gom, renk: '#2B5F8C', k: 1.6 });
  hd(s, cx - 10, 126, 20, 36, { dolgu: ten, renk: '#B58A66', k: 1.2 });
  hc(s, cx, cy, r, { dolgu: ten, renk: '#B58A66', k: 1.6 });
  if (p.kivircik) for (let t = 0; t <= 8; t++) { const a = Math.PI + (t * Math.PI) / 8; hc(s, cx + 38 * Math.cos(a), cy + 36 * Math.sin(a), 9, { dolgu: sac, renk: sac, k: 1 }); }
  hy(s, `M${cx - r} ${cy + 2} A${r} ${r} 0 0 1 ${cx + r} ${cy + 2} Q${cx} ${cy - 24} ${cx - r} ${cy + 2} Z`, [[cx - r, cy - r], [cx + r, cy + 2]], { dolgu: sac, renk: sac, k: 1.6 });
  hc(s, cx - 13, cy + 4, 3.2, { dolgu: PALET.siyah, renk: PALET.siyah, k: 1 }); hc(s, cx + 13, cy + 4, 3.2, { dolgu: PALET.siyah, renk: PALET.siyah, k: 1 });
  hy(s, `M${cx - 12} ${cy + 20} Q${cx} ${cy + 30} ${cx + 12} ${cy + 20}`, [[cx - 12, cy + 20], [cx + 12, cy + 30]], { renk: '#7A3B2E', k: 2.2 });
  if (p.aksesuar === 'gozluk') {
    hc(s, cx - 13, cy + 4, 10, { renk: PALET.siyah, k: 2.6 }); hc(s, cx + 13, cy + 4, 10, { renk: PALET.siyah, k: 2.6 }); hl(s, cx - 3, cy + 4, cx + 3, cy + 4, { renk: PALET.siyah, k: 2.6 });
  } else if (p.aksesuar === 'atki') {
    hd(s, cx - 24, 146, 48, 15, { dolgu: PALET.kirmizi, renk: '#8A3A00', k: 1.4, r: 5 });
    hd(s, cx + 6, 158, 13, 30, { dolgu: PALET.kirmizi, renk: '#8A3A00', k: 1.4, r: 3 });
  } else hata('aksesuar_bilinmiyor');
  return { sahne: s, alt: 'Şekil: bir çocuğun yüzü ve üst gövdesi.', olgular: olgu };
}

// ---------- 11) boy karşılaştırma ----------
// parametreler: { kisiler:[{ad, boy}] } boy: 80..160 (piksel yüksekliği)
function boy(p, profil) {
  const F = profil.yazi, N = p.kisiler.length, ar = 66, W = N * ar + 20, H = 214, zy = 172;
  if (N < 4 || N > 6) hata('kisi_sayisi');
  if (new Set(p.kisiler.map((k) => k.boy)).size !== N) hata('boy_tekrar');
  const s = new Sahne(W, H, profil), renkler = [PALET.mavi, PALET.turuncu, PALET.yesil, PALET.pembe, PALET.kirmizi, PALET.gok];
  hd(s, 4, zy, W - 8, 4, { dolgu: '#C7CDD6', renk: '#C7CDD6' });
  p.kisiler.forEach((k, i) => {
    const x = 10 + ar * (i + 0.5), h = k.boy, hr = h * 0.11, bas = zy - h, omuz = bas + 2 * hr + 6, kalca = zy - h * 0.46, c = renkler[i % renkler.length];
    hc(s, x, bas + hr, hr, { dolgu: '#F2C6A0', renk: KOYU, k: 2 });
    hl(s, x, bas + 2 * hr, x, kalca, { renk: c, k: 4 });
    hl(s, x - 14, omuz + 8, x + 14, omuz + 8, { renk: c, k: 3.5 });
    hl(s, x, kalca, x - 9, zy, { renk: KOYU, k: 3.5 }); hl(s, x, kalca, x + 9, zy, { renk: KOYU, k: 3.5 });
    s.metin(x, zy + 24, k.ad, { kalin: true });
  });
  const sirali = [...p.kisiler].sort((a, b) => b.boy - a.boy).map((k) => k.ad);
  return { sahne: s, alt: 'Şekil: yan yana duran, farklı boylarda kişiler.', olgular: { sira: sirali, enUzun: sirali[0], enKisa: sirali[sirali.length - 1] } };
}

// ---------- 12) zaman çizelgesi ----------
// parametreler: { baslik, olaylar:[{yil, etiket}] } 5 olay, yıllar artan
function zaman(p, profil) {
  const F = profil.yazi, N = p.olaylar.length, W = 400, ar = 70, x0 = 60, ly = 112;
  if (N !== 5) hata('olay_sayisi');
  const s = new Sahne(W, 190, profil), olgu = { yil: {}, sira: [] };
  s.metin(10, 22, p.baslik, { hiza: 'start', kalin: true });
  hd(s, 20, ly - 2, W - 40, 4, { dolgu: KOYU, renk: KOYU });
  const bol = (t) => { if (t.length <= 13) return [t]; const kel = t.split(' '); let en = 0, fark = 99; for (let i = 1; i < kel.length; i++) { const a = kel.slice(0, i).join(' ').length, b = kel.slice(i).join(' ').length; if (Math.abs(a - b) < fark) { fark = Math.abs(a - b); en = i; } } return [kel.slice(0, en).join(' '), kel.slice(en).join(' ')]; };
  p.olaylar.forEach((o, i) => {
    const x = x0 + i * ar, yukari = i % 2 === 0, satirlar = bol(o.etiket);
    hc(s, x, ly, 6, { dolgu: PALET.turuncu, renk: KOYU, k: 1.8 });
    if (yukari) {
      hl(s, x, ly - 8, x, ly - 24, { renk: GRI, k: 1.6 });
      satirlar.forEach((t, j) => s.metin(x, 78 - (satirlar.length - 1 - j) * (F + 5), t));
      s.metin(x, ly + 26, String(o.yil), { kalin: true });
    } else {
      hl(s, x, ly + 8, x, ly + 24, { renk: GRI, k: 1.6 });
      satirlar.forEach((t, j) => s.metin(x, ly + 42 + j * (F + 5), t));
      s.metin(x, ly - 14, String(o.yil), { kalin: true });
    }
    olgu.yil[o.etiket] = o.yil; olgu.sira.push(o.etiket);
  });
  return { sahne: s, alt: 'Şekil: yıllarla işaretlenmiş olayların yer aldığı zaman çizelgesi.', olgular: olgu };
}

// ---------- 13) akış şeması ----------
// parametreler: { baslik, adimlar:[metin…] } yukarıdan aşağıya
function akis(p, profil) {
  const F = profil.yazi, N = p.adimlar.length, bh = 28, bosluk = 17, W = 300, H = 40 + N * bh + (N - 1) * bosluk + 10;
  if (N < 4 || N > 7) hata('adim_sayisi');
  const s = new Sahne(W, H, profil), olgu = { sira: p.adimlar, konum: {} };
  s.metin(W / 2, 24, p.baslik, { kalin: true });
  p.adimlar.forEach((t, i) => {
    const y = 38 + i * (bh + bosluk);
    hd(s, 35, y, 230, bh, { dolgu: i % 2 ? '#E6EEF8' : '#F7EEDB', renk: KOYU, k: 1.6, r: 5 });
    s.metin(W / 2, y + bh / 2 + F * 0.35, t);
    if (i < N - 1) s.cizgi(W / 2, y + bh + 1, W / 2, y + bh + bosluk - 1, { ok: true, kalinlik: 2.4 });
    olgu.konum[t] = i + 1;
  });
  return { sahne: s, alt: 'Şekil: oklarla bağlanmış adımlardan oluşan bir akış şeması.', olgular: olgu };
}

// ---------- 14) sütun grafiği (İngilizce etiketli) ----------
// parametreler: { baslik, kategoriler:[{ad, deger}], max, adim }
function grafik(p, profil) {
  const F = profil.yazi, K = p.kategoriler, n = K.length, W = 420, sol = 46, sag = 14, ust = 46, alt = 42, H = 296;
  if (n < 4 || n > 6) hata('kategori_sayisi');
  if (new Set(K.map((k) => k.deger)).size !== n) hata('deger_tekrar');
  const s = new Sahne(W, H, profil), pw = W - sol - sag, ph = H - ust - alt, slot = pw / n;
  s.metin(W / 2, 24, p.baslik, { kalin: true });
  const y = (v) => ust + ph - (v / p.max) * ph;
  for (let v = 0; v <= p.max; v += p.adim) {
    s.cizgi(sol, y(v), W - sag, y(v), { renk: v === 0 ? PALET.siyah : '#D1D5DB', kalinlik: v === 0 ? 2 : 1, izgara: true });
    s.metin(sol - 8, y(v) + F * 0.35, String(v), { hiza: 'end' });
  }
  s.cizgi(sol, ust, sol, ust + ph, { kalinlik: 2, izgara: true });
  const renkler = [PALET.mavi, PALET.turuncu, PALET.yesil, PALET.pembe, PALET.gok, PALET.kirmizi];
  K.forEach((k, i) => {
    const bw = slot * 0.56, bx = sol + slot * i + (slot - bw) / 2;
    hd(s, bx, y(k.deger), bw, ph - (y(k.deger) - ust), { dolgu: renkler[i % 6], renk: KOYU, k: 1.2 });
    s.metin(sol + slot * (i + 0.5), ust + ph + 20, k.ad);
  });
  const deger = Object.fromEntries(K.map((k) => [k.ad, k.deger])), sirali = [...K].sort((a, b) => b.deger - a.deger);
  return { sahne: s, alt: 'Şekil: kategorilere göre çizilmiş sütun grafiği.', olgular: { deger, enCok: sirali[0].ad, enAz: sirali[n - 1].ad } };
}

export const TIPLER_B4 = {
  'b4-takvim': takvim, 'b4-hava': hava, 'b4-aile': aile, 'b4-sayma': sayma, 'b4-saat': saat, 'b4-konum': konumSahnesi,
  'b4-tablo': tablo, 'b4-harita': harita, 'b4-bina': bina, 'b4-yuz': yuz, 'b4-boy': boy, 'b4-zaman': zaman, 'b4-akis': akis, 'b4-grafik': grafik,
};




