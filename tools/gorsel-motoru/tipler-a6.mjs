// Ajan A6 için şekil tipleri (Sosyal Bilgiler 4-7, İnkılap Tarihi 8). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'a6-' önekiyle başlar. Haritalar şematiktir; gerçek coğrafya iddiası taşımaz.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
export const AYLAR = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const GRI_ACIK = '#E5E7EB';

export function yilMetni(o, bc) {
  if (o.ay) return `${AYLAR[o.ay - 1]} ${o.yil}`;
  return bc || o.yil < 0 ? `M.Ö. ${Math.abs(o.yil)}` : String(o.yil);
}
function satirBol(ad, max) {
  const out = []; let cur = '';
  for (const x of ad.split(' ')) {
    if (x.length > max) hata(`sozcuk_uzun:${x}`);
    const dene = cur ? `${cur} ${x}` : x;
    if (dene.length <= max) cur = dene; else { out.push(cur); cur = x; }
  }
  if (cur) out.push(cur);
  if (out.length > 3) hata(`satir_fazla:${ad}`);
  return out;
}

// ---------- zaman şeridi ----------
// parametreler: { olaylar:[{ad, yil, ay?, harf}] (eskiden yeniye), birim:'yil'|'ay', bc? }  Aralıklar eşit çizilir (ölçekli değil).
function zamanSeridi(p, profil) {
  const o = p.olaylar, n = o.length; if (n < 4 || n > 6) hata('olay_sayisi_4_6');
  const birim = p.birim ?? 'yil', t = (e) => (birim === 'ay' ? e.yil * 12 + (e.ay - 1) : e.yil);
  for (let i = 1; i < n; i++) if (t(o[i]) <= t(o[i - 1])) hata('sira_bozuk');
  if (new Set(o.map((e) => e.harf)).size !== n) hata('harf_tekrar');
  const orta = profil.yazi >= 15, b = orta ? 15 : 14, maxC = orta ? 13 : 14, W = 440, mx = 66, lh = b + 3, d = (W - 2 * mx) / (n - 1), R = 13;
  const satirlar = o.map((e) => [...satirBol(e.ad, maxC), yilMetni(e, p.bc)]);
  const mUst = Math.max(...satirlar.filter((_, i) => i % 2 === 0).map((l) => l.length));
  const mAlt = Math.max(...satirlar.filter((_, i) => i % 2 === 1).map((l) => l.length));
  const axisY = 6 + 38 + 0.25 * b + (mUst - 1) * lh + b, H = Math.ceil(axisY + 38 + b + (mAlt - 1) * lh + 0.25 * b + 8);
  const s = new Sahne(W, H, profil);
  o.forEach((e, i) => {
    const cx = mx + i * d, ust = i % 2 === 0, l = satirlar[i];
    if (i < n - 1) s.cizgi(cx + R, axisY, mx + (i + 1) * d - R, axisY);
    else s.cizgi(cx + R, axisY, cx + R + 30, axisY, { ok: true });
    s.cember(cx, axisY, R, { dolgu: '#FFFFFF', kalinlik: 2 });
    s.metin(cx, axisY + b * 0.35, e.harf, { boyut: b, kalin: true });
    if (ust) {
      s.cizgi(cx, axisY - R, cx, axisY - R - 22);
      const son = axisY - 38 - 0.25 * b;
      l.forEach((m, k) => s.metin(cx, son - (l.length - 1 - k) * lh, m, { boyut: b, kalin: k === l.length - 1 }));
    } else {
      s.cizgi(cx, axisY + R, cx, axisY + R + 22);
      const ilk = axisY + 38 + b;
      l.forEach((m, k) => s.metin(cx, ilk + k * lh, m, { boyut: b, kalin: k === l.length - 1 }));
    }
  });
  const ad = {}, yil = {}, fark = {}, sira = o.map((e) => e.harf);
  o.forEach((e) => { ad[e.harf] = e.ad; yil[e.harf] = yilMetni(e, p.bc); });
  for (const a of o) for (const c of o) if (a !== c) fark[`${a.harf}|${c.harf}`] = Math.abs(t(a) - t(c));
  return { sahne: s, alt: `Yatay bir zaman şeridi: harflerle işaretlenmiş ${n} olay, adları ve tarihleriyle eskiden yeniye soldan sağa dizilmiştir. Aralıklar eşit çizilmiştir, şerit ölçekli değildir.`, olgular: { sira, ad, yil, fark } };
}

// ---------- aile ağacı ----------
// parametreler: { babaTarafi:{dede,nine}, anneTarafi:{dede,nine}, babaSib:[{rol:'amca'|'hala',ad}], baba, anne, anneSib:[{rol:'dayi'|'teyze',ad}], cocuklar:[ad] }
function aileAgaci(p, profil) {
  const bw = 54, bh = 28, gap = 9, W = 404, gm = 24, b = 14, y1 = 14, y2 = y1 + bh + 44, y3 = y2 + bh + 44, H = y3 + bh + 14;
  const L = [...p.babaSib.map((x) => x.ad), p.baba], Rr = [p.anne, ...p.anneSib.map((x) => x.ad)], cnt = L.length + Rr.length;
  if (cnt < 4 || cnt > 6 || p.cocuklar.length < 1 || p.cocuklar.length > 3) hata('agac_boyutu');
  const adlar = [p.babaTarafi.dede, p.babaTarafi.nine, p.anneTarafi.dede, p.anneTarafi.nine, ...L, ...Rr, ...p.cocuklar];
  if (new Set(adlar).size !== adlar.length) hata('ad_tekrar');
  const half = (k) => (k * bw + (k - 1) * gap) / 2, cg = Math.max(26, 142 - half(L.length) - half(Rr.length));
  const tot = bw * cnt + gap * (cnt - 2) + cg; let x = (W - tot) / 2;
  const pos = []; L.forEach((_, i) => { pos.push(x); x += bw + (i < L.length - 1 ? gap : cg); }); Rr.forEach((_, i) => { pos.push(x); x += bw + gap; });
  const s = new Sahne(W, H, profil);
  const kutu = (xx, yy, ad) => { s.dikdortgen(xx, yy, bw, bh, { dolgu: '#FFFFFF', kalinlik: 1.6 }); s.metin(xx + bw / 2, yy + bh / 2 + b * 0.35, ad, { boyut: b, kalin: true }); };
  const cL = (i) => pos[i] + bw / 2;
  const grup = (ilk, son, cift) => {
    const cx = (pos[ilk] + pos[son] + bw) / 2, ym = y1 + bh / 2, barY = y1 + bh + 22;
    kutu(cx - gm / 2 - bw, y1, cift.dede); kutu(cx + gm / 2, y1, cift.nine);
    s.cizgi(cx - gm / 2, ym, cx + gm / 2, ym); s.cizgi(cx, ym, cx, barY);
    s.cizgi(cL(ilk), barY, cL(son), barY);
    for (let i = ilk; i <= son; i++) s.cizgi(cL(i), barY, cL(i), y2);
  };
  grup(0, L.length - 1, p.babaTarafi); grup(L.length, cnt - 1, p.anneTarafi);
  pos.forEach((px, i) => kutu(px, y2, i < L.length ? L[i] : Rr[i - L.length]));
  const mx = (pos[L.length - 1] + bw + pos[L.length]) / 2, ym2 = y2 + bh / 2, bar2 = y2 + bh + 22, m = p.cocuklar.length;
  s.cizgi(pos[L.length - 1] + bw, ym2, pos[L.length], ym2); s.cizgi(mx, ym2, mx, bar2);
  const cc = p.cocuklar.map((_, i) => mx + (i - (m - 1) / 2) * (bw + gap));
  if (m > 1) s.cizgi(cc[0], bar2, cc[m - 1], bar2);
  cc.forEach((c, i) => { s.cizgi(c, bar2, c, y3); kutu(c - bw / 2, y3, p.cocuklar[i]); });
  const iliski = {};
  for (const c of p.cocuklar) {
    iliski[`${c}|${p.baba}`] = 'babası'; iliski[`${c}|${p.anne}`] = 'annesi';
    for (const k of p.babaSib) iliski[`${c}|${k.ad}`] = k.rol === 'amca' ? 'amcası' : 'halası';
    for (const k of p.anneSib) iliski[`${c}|${k.ad}`] = k.rol === 'dayi' ? 'dayısı' : 'teyzesi';
    iliski[`${c}|${p.babaTarafi.dede}`] = 'baba tarafındaki dedesi'; iliski[`${c}|${p.babaTarafi.nine}`] = 'babaannesi';
    iliski[`${c}|${p.anneTarafi.dede}`] = 'anne tarafındaki dedesi'; iliski[`${c}|${p.anneTarafi.nine}`] = 'anneannesi';
    for (const k of p.cocuklar) if (k !== c) iliski[`${c}|${k}`] = 'kardeşi';
  }
  return { sahne: s, alt: 'Üç kuşaklık bir aile ağacı: üstte iki çift büyükanne ve büyükbaba, ortada bu çiftlerin çocukları, altta torunlar. Çizgiler eşleri ve çocukları birbirine bağlar.', olgular: { iliski } };
}

// ---------- kroki (doğal ve insan yapımı unsurlar) ----------
// parametreler: { en, boy, ogeler:[{tur, hucre}] }  Her öge adıyla birlikte çizilir.
const KROKI_AD = { gol: 'Göl', dag: 'Dağ', orman: 'Orman', nehir: 'Nehir', ev: 'Ev', okul: 'Okul', kopru: 'Köprü', fabrika: 'Fabrika', market: 'Market', hastane: 'Hastane' };
export const KROKI_DOGAL = ['gol', 'dag', 'orman', 'nehir'];
export const KROKI_BESERI = ['ev', 'okul', 'kopru', 'fabrika', 'market', 'hastane'];
function krokiIkon(s, tur, cx, cy) {
  const bl = (x, y, w, h, dolgu) => s.dikdortgen(x, y, w, h, { dolgu, kalinlik: 1.2 });
  if (tur === 'gol') s.poligon(Array.from({ length: 20 }, (_, i) => [cx + 30 * Math.cos((i * Math.PI) / 10), cy + 17 * Math.sin((i * Math.PI) / 10)]), { dolgu: PALET.gok, kalinlik: 1.5 });
  else if (tur === 'dag') { s.poligon([[cx - 32, cy + 20], [cx, cy - 22], [cx + 32, cy + 20]], { dolgu: PALET.gri, kalinlik: 1.5 }); s.poligon([[cx - 9, cy - 9], [cx, cy - 22], [cx + 9, cy - 9]], { dolgu: '#FFFFFF', kalinlik: 1 }); }
  else if (tur === 'orman') [[-20, 4], [0, -2], [20, 4]].forEach(([dx, o]) => { s.poligon([[cx + dx, cy - 16 + o], [cx + dx - 11, cy + 8 + o], [cx + dx + 11, cy + 8 + o]], { dolgu: PALET.yesil, kalinlik: 1.2 }); bl(cx + dx - 2, cy + 8 + o, 4, 9, PALET.siyah); });
  else if (tur === 'nehir') { const pts = [[-32, -8], [-16, 6], [0, -8], [16, 6], [32, -8]]; for (let i = 0; i < 4; i++) s.cizgi(cx + pts[i][0], cy + pts[i][1], cx + pts[i + 1][0], cy + pts[i + 1][1], { renk: PALET.gok, kalinlik: 7 }); }
  else if (tur === 'ev') { bl(cx - 18, cy - 4, 36, 26, '#FDE68A'); s.poligon([[cx - 23, cy - 4], [cx, cy - 24], [cx + 23, cy - 4]], { dolgu: PALET.kirmizi, kalinlik: 1.2 }); bl(cx - 4, cy + 8, 8, 14, PALET.siyah); }
  else if (tur === 'okul') { bl(cx - 28, cy - 6, 56, 28, GRI_ACIK); bl(cx - 31, cy - 12, 62, 7, PALET.siyah); s.cizgi(cx, cy - 12, cx, cy - 28, { kalinlik: 1.5 }); s.poligon([[cx, cy - 28], [cx + 14, cy - 24], [cx, cy - 20]], { dolgu: PALET.kirmizi, kalinlik: 1 }); bl(cx - 22, cy, 12, 10, '#FFFFFF'); bl(cx + 10, cy, 12, 10, '#FFFFFF'); bl(cx - 4, cy + 8, 8, 14, PALET.siyah); }
  else if (tur === 'kopru') { bl(cx - 34, cy - 2, 68, 9, PALET.gri); [-24, 0, 24].forEach((dx) => s.cizgi(cx + dx, cy + 7, cx + dx, cy + 22, { kalinlik: 3 })); s.cizgi(cx - 34, cy - 10, cx + 34, cy - 10, { kalinlik: 1.5 }); [-34, -17, 0, 17, 34].forEach((dx) => s.cizgi(cx + dx, cy - 10, cx + dx, cy - 2, { kalinlik: 1.5 })); }
  else if (tur === 'fabrika') { bl(cx - 26, cy - 2, 52, 24, '#D1D5DB'); bl(cx + 10, cy - 22, 10, 20, PALET.gri); s.poligon([[cx - 26, cy - 2], [cx - 13, cy - 14], [cx - 13, cy - 2], [cx, cy - 14], [cx, cy - 2]], { dolgu: '#D1D5DB', kalinlik: 1.2 }); bl(cx - 20, cy + 6, 10, 8, '#FFFFFF'); bl(cx - 4, cy + 6, 10, 8, '#FFFFFF'); }
  else if (tur === 'market') { bl(cx - 24, cy - 2, 48, 24, '#FEF3C7'); s.poligon([[cx - 28, cy - 2], [cx - 22, cy - 14], [cx + 22, cy - 14], [cx + 28, cy - 2]], { dolgu: PALET.turuncu, kalinlik: 1.2 }); bl(cx - 5, cy + 6, 10, 16, PALET.siyah); }
  else if (tur === 'hastane') { bl(cx - 24, cy - 14, 48, 36, GRI_ACIK); s.cizgi(cx, cy - 8, cx, cy + 14, { renk: PALET.mavi, kalinlik: 6 }); s.cizgi(cx - 11, cy + 3, cx + 11, cy + 3, { renk: PALET.mavi, kalinlik: 6 }); }
  else hata(`kroki_tur_bilinmiyor:${tur}`);
}
function kroki(p, profil) {
  const cw = 100, ch = 88, W = p.en * cw + 20, H = p.boy * ch + 20, b = profil.yazi >= 15 ? 15 : 14, s = new Sahne(W, H, profil), kullanilan = new Set();
  for (let i = 0; i < p.en * p.boy; i++) s.dikdortgen(10 + (i % p.en) * cw, 10 + Math.floor(i / p.en) * ch, cw, ch, { renk: PALET.gri, kalinlik: 0.8 });
  const sayilar = {};
  for (const e of p.ogeler) {
    if (!KROKI_AD[e.tur]) hata(`kroki_tur_bilinmiyor:${e.tur}`);
    if (e.hucre < 0 || e.hucre >= p.en * p.boy || kullanilan.has(e.hucre)) hata('hucre_gecersiz'); kullanilan.add(e.hucre);
    const x0 = 10 + (e.hucre % p.en) * cw, y0 = 10 + Math.floor(e.hucre / p.en) * ch;
    krokiIkon(s, e.tur, x0 + cw / 2, y0 + 34); s.metin(x0 + cw / 2, y0 + 78, KROKI_AD[e.tur], { boyut: b, kalin: true });
    sayilar[e.tur] = (sayilar[e.tur] ?? 0) + 1;
  }
  const topla = (liste) => liste.reduce((t, k) => t + (sayilar[k] ?? 0), 0);
  return { sahne: s, alt: 'Yakın çevreyi gösteren bir kroki: kareli zemin üzerinde adları yazılı doğal ve insan yapımı unsurlar vardır.', olgular: { sayilar, dogal: topla(KROKI_DOGAL), besri: topla(KROKI_BESERI) } };
}

// ---------- tablo ----------
// parametreler: { baslik?, sutunlar:[..], satirlar:[[..]] }  Sayı olan hücreler number olarak verilir.
function tablo(p, profil) {
  const b = profil.yazi >= 15 ? 15 : 14, nc = p.sutunlar.length, rh = 32, ust = p.baslik ? 34 : 12;
  const wd = p.sutunlar.map((c, j) => Math.max(String(c).length, ...p.satirlar.map((r) => String(r[j]).length)) * b * 0.6 + 20);
  const W = Math.ceil(wd.reduce((t, x) => t + x, 0) + 20); if (W > 420) hata('tablo_genis');
  const H = ust + rh * (p.satirlar.length + 1) + 12, s = new Sahne(W, H, profil);
  if (p.baslik) s.metin(W / 2, 22, p.baslik, { boyut: b, kalin: true });
  s.dikdortgen(10, ust, W - 20, rh, { dolgu: GRI_ACIK, renk: GRI_ACIK, kalinlik: 0 });
  s.dikdortgen(10, ust, W - 20, rh * (p.satirlar.length + 1), { kalinlik: 1.8 });
  let x = 10; const xs = [];
  wd.forEach((w, j) => { xs.push(x + w / 2); if (j > 0) s.cizgi(x, ust, x, ust + rh * (p.satirlar.length + 1), { izgara: true, renk: PALET.gri, kalinlik: 0.9 }); x += w; });
  for (let i = 1; i <= p.satirlar.length; i++) s.cizgi(10, ust + i * rh, W - 10, ust + i * rh, { izgara: true, renk: PALET.gri, kalinlik: 0.9 });
  p.sutunlar.forEach((c, j) => s.metin(xs[j], ust + rh / 2 + b * 0.35, c, { boyut: b, kalin: true }));
  p.satirlar.forEach((r, i) => r.forEach((v, j) => s.metin(xs[j], ust + (i + 1) * rh + rh / 2 + b * 0.35, String(v), { boyut: b })));
  const satir = {}; p.satirlar.forEach((r) => { satir[r[0]] = r.slice(1); });
  const sayisal = {}, enYuksek = {}, enDusuk = {};
  p.sutunlar.forEach((c, j) => {
    if (j === 0 || !p.satirlar.every((r) => typeof r[j] === 'number')) return;
    sayisal[c] = true; const v = p.satirlar.map((r) => r[j]), mx = Math.max(...v), mn = Math.min(...v);
    enYuksek[c] = v.filter((q) => q === mx).length === 1 ? p.satirlar[v.indexOf(mx)][0] : null;
    enDusuk[c] = v.filter((q) => q === mn).length === 1 ? p.satirlar[v.indexOf(mn)][0] : null;
  });
  const toplam = {};
  if (p.grupSutun != null && p.sayiSutun != null) for (const r of p.satirlar) toplam[r[p.grupSutun]] = (toplam[r[p.grupSutun]] ?? 0) + r[p.sayiSutun];
  return { sahne: s, alt: `Tablo${p.baslik ? `: ${p.baslik}` : ''}. Sütun başlıkları: ${p.sutunlar.join(', ')}.`, olgular: { satir, en_yuksek: enYuksek, en_dusuk: enDusuk, toplam } };
}

// ---------- koordinat ızgarası (şematik) ----------
// parametreler: { enlemler:[üstten alta], boylamlar:[soldan sağa], noktalar:[{ad, enlem, boylam}] }  Şematiktir; gerçek bir yeri göstermez.
export const enlemMetni = (v) => (v === 0 ? '0°' : `${Math.abs(v)}° ${v > 0 ? 'K' : 'G'}`);
export const boylamMetni = (v) => (v === 0 ? '0°' : `${Math.abs(v)}° ${v > 0 ? 'D' : 'B'}`);
function koordinat(p, profil) {
  const nlat = p.enlemler.length, nlon = p.boylamlar.length, cw = 52, rh = 44, left = 62, top = 30, b = 13;
  const W = left + (nlon - 1) * cw + 22, H = top + (nlat - 1) * rh + 28, s = new Sahne(W, H, profil);
  const X = (lon) => left + p.boylamlar.indexOf(lon) * cw, Y = (lat) => top + p.enlemler.indexOf(lat) * rh;
  p.enlemler.forEach((v) => { s.cizgi(left, Y(v), W - 22, Y(v), { izgara: true, renk: v === 0 ? PALET.siyah : PALET.gri, kalinlik: v === 0 ? 1.6 : 0.8 }); s.metin(left - 8, Y(v) + 5, enlemMetni(v), { boyut: b, hiza: 'end' }); });
  p.boylamlar.forEach((v) => { s.cizgi(X(v), top, X(v), top + (nlat - 1) * rh, { izgara: true, renk: v === 0 ? PALET.siyah : PALET.gri, kalinlik: v === 0 ? 1.6 : 0.8 }); s.metin(X(v), top - 10, boylamMetni(v), { boyut: b }); });
  const koor = {}, adlar = new Set();
  for (const n of p.noktalar) {
    if (!p.enlemler.includes(n.enlem) || !p.boylamlar.includes(n.boylam)) hata(`nokta_izgara_disi:${n.ad}`);
    if (adlar.has(n.ad)) hata('nokta_tekrar'); adlar.add(n.ad);
    s.nokta(X(n.boylam), Y(n.enlem), { r: 5 }); s.metin(X(n.boylam) + 10, Y(n.enlem) + 17, n.ad, { boyut: b + 1, kalin: true });
    koor[n.ad] = { enlem: n.enlem, boylam: n.boylam, enlem_metni: enlemMetni(n.enlem), boylam_metni: boylamMetni(n.boylam), metin: `${enlemMetni(n.enlem)}, ${boylamMetni(n.boylam)}` };
  }
  const ayniEnlem = [], ayniBoylam = [];
  for (const a of p.noktalar) for (const c of p.noktalar) if (a.ad < c.ad) { if (a.enlem === c.enlem) ayniEnlem.push(`${a.ad}|${c.ad}`); if (a.boylam === c.boylam) ayniBoylam.push(`${a.ad}|${c.ad}`); }
  return { sahne: s, alt: 'Enlem ve boylam çizgileriyle bölünmüş şematik bir ızgara; harflerle adlandırılmış noktalar çizgilerin kesiştiği yerlerdedir.', olgular: { koordinat: koor, ayni_enlem: ayniEnlem, ayni_boylam: ayniBoylam } };
}

// ---------- ölçekli kareli harita (şematik) ----------
// parametreler: { en, boy, kare_km, noktalar:[{ad, x, y}] }  Karenin kenarı ölçek çubuğuna eşittir; noktalar çizgi kesişimlerindedir.
function olcekliHarita(p, profil) {
  const cs = 38, left = 20, top = 24, b = 13, W = left * 2 + p.en * cs, H = top + p.boy * cs + 56, s = new Sahne(W, H, profil), adlar = new Set();
  s.dikdortgen(left, top, p.en * cs, p.boy * cs, { kalinlik: 1.6 });
  for (let i = 1; i < p.en; i++) s.cizgi(left + i * cs, top, left + i * cs, top + p.boy * cs, { izgara: true, renk: PALET.gri, kalinlik: 0.8 });
  for (let j = 1; j < p.boy; j++) s.cizgi(left, top + j * cs, left + p.en * cs, top + j * cs, { izgara: true, renk: PALET.gri, kalinlik: 0.8 });
  const sy = top + p.boy * cs + 18;
  s.cizgi(left, sy, left + cs, sy, { kalinlik: 2.5 }); s.cizgi(left, sy - 5, left, sy + 5, { kalinlik: 2 }); s.cizgi(left + cs, sy - 5, left + cs, sy + 5, { kalinlik: 2 });
  s.metin(left + cs + 14, sy + 5, 'Ölçek', { boyut: b, hiza: 'start', kalin: true }); s.metin(left + cs / 2, sy + 24, `${p.kare_km} km`, { boyut: b });
  const duz = {}, yol = {};
  for (const n of p.noktalar) {
    if (n.x < 0 || n.x > p.en || n.y < 0 || n.y > p.boy) hata(`nokta_disarida:${n.ad}`);
    if (adlar.has(n.ad)) hata('nokta_tekrar'); adlar.add(n.ad);
    s.nokta(left + n.x * cs, top + n.y * cs, { r: 5 }); s.metin(left + n.x * cs + 10, top + n.y * cs - 8, n.ad, { boyut: b + 1, kalin: true });
  }
  for (const a of p.noktalar) for (const c of p.noktalar) if (a !== c) {
    const dx = Math.abs(a.x - c.x), dy = Math.abs(a.y - c.y);
    duz[`${a.ad}|${c.ad}`] = dx === 0 || dy === 0 ? (dx + dy) * p.kare_km : null; yol[`${a.ad}|${c.ad}`] = (dx + dy) * p.kare_km;
  }
  return { sahne: s, alt: 'Kare ağıyla bölünmüş şematik bir harita; harflerle adlandırılmış noktalar çizgilerin kesiştiği yerlerdedir. Altta ölçek çubuğu vardır.', olgular: { duz, yol } };
}

// ---------- çizgi grafiği ----------
// parametreler: { baslik, etiketler:[..], degerler:[..], max, adim }  Değerler adim/2'nin katıdır.
function cizgiGrafigi(p, profil) {
  const W = 340, H = 232, sol = 52, sag = W - 18, ust = 48, alt = 180, n = p.etiketler.length, b = 12; if (n < 4 || n > 6 || p.degerler.length !== n) hata('nokta_sayisi_4_6');
  const s = new Sahne(W, H, profil), Y = (v) => alt - (v / p.max) * (alt - ust), X = (i) => sol + ((sag - sol) * (i + 0.5)) / n;
  s.metin(W / 2, 22, p.baslik, { kalin: true });
  for (let v = 0; v <= p.max + 1e-9; v += p.adim) { s.cizgi(sol, Y(v), sag, Y(v), { izgara: true, renk: PALET.gri, kalinlik: 0.6 }); s.metin(sol - 8, Y(v) + 5, String(v), { hiza: 'end', boyut: b }); }
  for (let i = 0; i < n; i++) { s.cizgi(X(i), ust, X(i), alt, { izgara: true, renk: GRI_ACIK, kalinlik: 0.6 }); s.metin(X(i), alt + 20, String(p.etiketler[i]), { boyut: b }); }
  s.cizgi(sol, ust - 6, sol, alt); s.cizgi(sol, alt, sag, alt);
  p.degerler.forEach((v, i) => { const k = v / (p.adim / 2); if (Math.abs(k - Math.round(k)) > 1e-9 || v < 0 || v > p.max) hata(`deger_gecersiz:${v}`); });
  for (let i = 0; i < n - 1; i++) s.cizgi(X(i), Y(p.degerler[i]), X(i + 1), Y(p.degerler[i + 1]), { renk: PALET.mavi, kalinlik: 2.6 });
  p.degerler.forEach((v, i) => s.nokta(X(i), Y(v), { r: 4.5, renk: PALET.mavi }));
  const degerler = {}, artis = {}, donem = [];
  p.etiketler.forEach((e, i) => { degerler[e] = p.degerler[i]; });
  for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) artis[`${p.etiketler[i]}|${p.etiketler[j]}`] = p.degerler[j] - p.degerler[i];
  for (let i = 0; i < n - 1; i++) donem.push(p.degerler[i + 1] - p.degerler[i]);
  const tekil = (f) => { const h = f(...donem); return donem.filter((d) => d === h).length === 1 ? `${p.etiketler[donem.indexOf(h)]}|${p.etiketler[donem.indexOf(h) + 1]}` : null; };
  return { sahne: s, alt: `Çizgi grafiği: ${p.baslik}. Yatay eksende ${p.etiketler.length} dönem, dikey eksende 0 ile ${p.max} arası değerler vardır.`, olgular: { degerler, artis, en_cok_artis: tekil(Math.max), en_az_artis: tekil(Math.min), azalis: donem.map((d, i) => (d < 0 ? `${p.etiketler[i]}|${p.etiketler[i + 1]}` : null)).filter(Boolean) } };
}

// ---------- ikili sütun grafiği ----------
// parametreler: { baslik, kategoriler:[{ad,a,b}], seriA, seriB, max, adim }  A dolu mavi, B beyaz (kenarlıklı); gösterge çizilir.
function ikiliSutun(p, profil) {
  const W = 350, H = 232, sol = 52, sag = W - 14, ust = 66, alt = 196, n = p.kategoriler.length, b = 12; if (n < 3 || n > 5) hata('kategori_3_5');
  const s = new Sahne(W, H, profil), Y = (v) => alt - (v / p.max) * (alt - ust);
  s.metin(W / 2, 20, p.baslik, { kalin: true });
  s.dikdortgen(sol, 31, 13, 13, { dolgu: PALET.mavi, kalinlik: 1.2 }); s.metin(sol + 19, 42, p.seriA, { boyut: 13, hiza: 'start' });
  s.dikdortgen(sol + 135, 31, 13, 13, { dolgu: '#FFFFFF', kalinlik: 1.6 }); s.metin(sol + 154, 42, p.seriB, { boyut: 13, hiza: 'start' });
  for (let v = 0; v <= p.max + 1e-9; v += p.adim) { s.cizgi(sol, Y(v), sag, Y(v), { izgara: true, renk: PALET.gri, kalinlik: 0.6 }); s.metin(sol - 8, Y(v) + 5, String(v), { hiza: 'end', boyut: b }); }
  s.cizgi(sol, ust - 6, sol, alt); s.cizgi(sol, alt, sag, alt);
  const slot = (sag - sol) / n, bw = slot * 0.3, a = {}, bb = {}, fark = {};
  p.kategoriler.forEach((k, i) => {
    for (const v of [k.a, k.b]) { const q = v / (p.adim / 2); if (Math.abs(q - Math.round(q)) > 1e-9 || v < 0 || v > p.max) hata(`deger_gecersiz:${k.ad}`); }
    const cx = sol + slot * (i + 0.5);
    s.dikdortgen(cx - bw, Y(k.a), bw, alt - Y(k.a), { dolgu: PALET.mavi, kalinlik: 1.2 }); s.dikdortgen(cx, Y(k.b), bw, alt - Y(k.b), { dolgu: '#FFFFFF', kalinlik: 1.6 });
    s.metin(cx, alt + 20, String(k.ad), { boyut: b });
    a[k.ad] = k.a; bb[k.ad] = k.b; fark[k.ad] = k.a - k.b;
  });
  const ad = p.kategoriler.map((k) => k.ad), mx = Math.max(...ad.map((x) => Math.abs(fark[x])));
  return { sahne: s, alt: `İkili sütun grafiği: ${p.baslik}. Her kategoride iki sütun vardır; göstergede ${p.seriA} dolu, ${p.seriB} boş sütun olarak belirtilmiştir.`, olgular: { a, b: bb, fark, a_fazla: ad.filter((x) => fark[x] > 0), b_fazla: ad.filter((x) => fark[x] < 0), esit: ad.filter((x) => fark[x] === 0), en_buyuk_fark: ad.filter((x) => Math.abs(fark[x]) === mx).length === 1 ? ad.find((x) => Math.abs(fark[x]) === mx) : null } };
}

export const TIPLER_A6 = {
  'a6-zaman-seridi': zamanSeridi,
  'a6-aile-agaci': aileAgaci,
  'a6-kroki': kroki,
  'a6-tablo': tablo,
  'a6-koordinat': koordinat,
  'a6-olcekli-harita': olcekliHarita,
  'a6-cizgi-grafigi': cizgiGrafigi,
  'a6-ikili-sutun': ikiliSutun,
};
