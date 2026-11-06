// Ajan A5 için şekil tipleri (Fen Bilimleri 3–8). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları benzersiz: 'a5-...' öneki. Başka ajanın dosyasına dokunma.
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const r1 = (n) => Math.round(n * 10) / 10;
const LCG = (t) => () => { t = (Math.imul(t, 1664525) + 1013904223) >>> 0; return t / 4294967296; };
const KOYU = '#374151', ACIK_GRI = '#E5E7EB', SU = '#56B4E9', SARI = '#F6D860';

// Ham SVG yolu ekler; sınır denetimi için köşe noktalarını kaydeder.
function yol(s, d, { dolgu = 'none', renk = PALET.siyah, kalinlik = 1.5, kesik = false, noktalar = [] } = {}) {
  for (const [x, y] of noktalar) s.noktalar.push([x, y, 0]);
  s.parcalar.push(`<path d="${d}" fill="${dolgu === 'none' ? 'none' : s._renk(dolgu)}" stroke="${renk === 'none' ? 'none' : s._renk(renk)}" stroke-width="${kalinlik}"${kesik ? ' stroke-dasharray="5 4"' : ''} stroke-linejoin="round" stroke-linecap="round"/>`);
}
// Kesikli çizgi ve çember yardımcıları (çekirdek çizgisi yazı denetimine girer; kılavuz çizgileri girmesin diye izgara=true).
const kesikCizgi = (s, x1, y1, x2, y2, renk = PALET.gri) => s.cizgi(x1, y1, x2, y2, { renk, kalinlik: 1.2, kesik: true, izgara: true });
function kesikCember(s, cx, cy, r, renk = PALET.gri) {
  s.noktalar.push([cx - r, cy - r, 0], [cx + r, cy + r, 0]);
  s.parcalar.push(`<circle cx="${r1(cx)}" cy="${r1(cy)}" r="${r}" fill="none" stroke="${s._renk(renk)}" stroke-width="1.3" stroke-dasharray="5 4"/>`);
}
const kutuNokta = (cx, cy, w, h, hedef) => { // dikdörtgenin kenarında, merkezden hedefe giden doğrunun kesişim noktası
  const dx = hedef[0] - cx, dy = hedef[1] - cy; const t = Math.min(dx ? (w / 2) / Math.abs(dx) : 1e9, dy ? (h / 2) / Math.abs(dy) : 1e9);
  return [cx + dx * t, cy + dy * t];
};

// ---------- 1) kaplardaki maddeler (katı / sıvı / gaz) ----------
// parametreler: { kaplar:[{ad, hal:'kati'|'sivi'|'gaz', sekil:'kutu'|'yamuk'|'dar'}] }  2–4 kap.
const KAP_BOY = { kutu: [64, 100], yamuk: [54, 104], dar: [44, 112] };
function kapHal(p, profil) {
  const n = p.kaplar.length; if (n < 2 || n > 4) hata('kap_sayisi_2_4');
  const W = 360, H = 190, hucre = W / n, taban = 146, s = new Sahne(W, H, profil), olgular = { haller: {}, say: { kati: 0, sivi: 0, gaz: 0 } };
  p.kaplar.forEach((k, i) => {
    const [bw, bh] = KAP_BOY[k.sekil] ?? hata(`kap_sekli:${k.sekil}`);
    const cx = hucre * (i + 0.5), ust = taban - bh, sol = cx - bw / 2, sag = cx + bw / 2, ek = k.sekil === 'yamuk' ? 9 : 0;
    const L = [sol - ek, ust], Rr = [sag + ek, ust], Lb = [sol, taban], Rb = [sag, taban];
    const sekilNoktalar = [L, Lb, Rb, Rr];
    // içerik (duvarların altında kalsın diye önce çizilir)
    const tohum = (i + 1) * 13 + (k.hal === 'gaz' ? 3 : k.hal === 'sivi' ? 5 : 7), r = LCG(tohum);
    if (k.hal === 'sivi') {
      const f = 0.46 + 0.08 * (i % 3), y = taban - bh * f, gen = (yy) => ek * (1 - (taban - yy) / bh);
      s.poligon([[sol - gen(y), y], [sag + gen(y), y], Rb, Lb], { dolgu: SU, renk: SU, kalinlik: 1 });
    } else if (k.hal === 'gaz') {
      const nok = []; let deneme = 0;
      while (nok.length < 24 && deneme++ < 400) {
        const x = sol + 7 + r() * (bw - 14), y = ust + 7 + r() * (bh - 14);
        if (nok.every(([a, b]) => Math.hypot(a - x, b - y) > 11)) nok.push([x, y]);
      }
      for (const [x, y] of nok) s.nokta(x, y, { r: 2.6, renk: KOYU });
    } else {
      const bwid = bw * 0.62, bhei = bh * 0.34, x0 = cx - bwid / 2, y0 = taban - bhei - 2;
      s.poligon([[x0, y0 + 5 + r() * 5], [x0 + bwid * 0.3, y0 - 3 + r() * 4], [x0 + bwid * 0.75, y0 + r() * 5], [x0 + bwid, y0 + 7 + r() * 4], [x0 + bwid - 3, y0 + bhei], [x0 + 3, y0 + bhei]], { dolgu: PALET.gri, renk: KOYU, kalinlik: 1.6 });
    }
    s.cizgi(L[0], L[1], Lb[0], Lb[1], { kalinlik: 2.6 }); s.cizgi(Lb[0], Lb[1], Rb[0], Rb[1], { kalinlik: 2.6 }); s.cizgi(Rb[0], Rb[1], Rr[0], Rr[1], { kalinlik: 2.6 });
    if (k.hal === 'gaz') s.cizgi(L[0], L[1], Rr[0], Rr[1], { kalinlik: 2.6 }); // gaz kapalı kapta gösterilir
    void sekilNoktalar;
    s.metin(cx, taban + 30, k.ad, { kalin: true, boyut: 16 });
    olgular.haller[k.ad] = k.hal; olgular.say[k.hal] += 1;
  });
  const alt = `Yan yana ${n} kap; kapların altında ${p.kaplar.map((k) => k.ad).join(', ')} harfleri yazıyor ve her kapta bir madde bulunuyor.`;
  return { sahne: s, alt, olgular };
}

// ---------- 2) yaşam döngüsü şeması ----------
// parametreler: { evreler:[ad…] (3–4), gizli?: indeks (o evre "?" gösterilir), baslangic?: kutuların döndürülme sayısı }
function dongu(p, profil) {
  const n = p.evreler.length; if (n < 3 || n > 4) hata('evre_sayisi_3_4');
  const W = 360, H = 250, s = new Sahne(W, H, profil), b = 13, yer = n === 4 ? [[180, 40], [285, 125], [180, 212], [75, 125]] : [[180, 40], [285, 192], [75, 192]];
  const dön = ((p.baslangic ?? 0) % n + n) % n;
  const kutular = p.evreler.map((ad, i) => {
    const [cx, cy] = yer[(i + dön) % n], gizli = p.gizli === i;
    const w = gizli ? 44 : Math.max(54, String(ad).length * b * 0.6 + 16), h = 32;
    return { cx, cy, w, h, ad: gizli ? '?' : ad, gizli };
  });
  kutular.forEach((k, i) => {
    const sonraki = kutular[(i + 1) % n];
    const a = kutuNokta(k.cx, k.cy, k.w + 10, k.h + 10, [sonraki.cx, sonraki.cy]), z = kutuNokta(sonraki.cx, sonraki.cy, sonraki.w + 10, sonraki.h + 10, [k.cx, k.cy]);
    s.cizgi(a[0], a[1], z[0], z[1], { ok: true, kalinlik: 2 });
  });
  for (const k of kutular) {
    s.dikdortgen(k.cx - k.w / 2, k.cy - k.h / 2, k.w, k.h, { renk: PALET.siyah, kalinlik: k.gizli ? 2.6 : 1.6, dolgu: k.gizli ? '#FEF3C7' : '#FFFFFF' });
    s.metin(k.cx, k.cy + (k.gizli ? 7 : 5), k.ad, { boyut: k.gizli ? 22 : b, kalin: k.gizli });
  }
  const alt = 'Oklarla birbirine bağlı kutulardan oluşan bir döngü şeması; ' + (p.gizli === undefined ? 'kutularda evre adları yazılıdır.' : 'kutulardan birinde soru işareti vardır.');
  return { sahne: s, alt, olgular: { evreler: p.evreler, eksik: p.gizli === undefined ? null : p.evreler[p.gizli], canli: p.canli ?? null } };
}


// ---------- 3) basit elektrik devresi (paneller) ----------
// parametreler: { paneller:[{ad, pil:0..3, ampul:0..2, anahtar:null|'acik'|'kapali', kopuk?:bool, harf?:{pil,ampul,anahtar,kablo}}], etiket?:bool }  Seri devre.
function devre(p, profil) {
  const n = p.paneller.length; if (n < 1 || n > 4) hata('panel_sayisi_1_4');
  const cw = 200, ch = 150, kol = n === 1 ? 1 : 2, sat = Math.ceil(n / kol), W = cw * kol, H = ch * sat, s = new Sahne(W, H, profil), olgular = { paneller: {}, harf: {}, en_parlak: null };
  const yz = Math.max(profil.yazi, 14);
  p.paneller.forEach((pn, idx) => {
    const ox = (idx % kol) * cw, oy = Math.floor(idx / kol) * ch;
    if (n > 1) s.dikdortgen(ox + 3, oy + 3, cw - 6, ch - 6, { renk: PALET.gri, kalinlik: 1 });
    const x0 = ox + 40, x1 = ox + 168, y0 = oy + 50, y1 = oy + 122, mid = (y0 + y1) / 2;
    const pil = pn.pil, ampul = pn.ampul, anahtar = pn.anahtar ?? null; if (pil > 3 || ampul > 2 || ampul + (anahtar ? 1 : 0) > 3) hata('devre_cok_eleman');
    const W1 = { kalinlik: 2 };
    // sol kol: pil yığını
    if (pil === 0) s.cizgi(x0, y0, x0, y1, W1);
    else {
      const bas = mid - (pil * 14) / 2; s.cizgi(x0, y0, x0, bas + 3, W1); s.cizgi(x0, bas + pil * 14 - 3, x0, y1, W1);
      for (let j = 0; j < pil; j++) { const cy = bas + j * 14 + 7; s.cizgi(x0 - 12, cy - 3, x0 + 12, cy - 3, { kalinlik: 1.8 }); s.cizgi(x0 - 6, cy + 3, x0 + 6, cy + 3, { kalinlik: 4 }); if (j < pil - 1) s.cizgi(x0, cy + 3, x0, cy + 11, W1); }
    }
    // üst kol: anahtar + ampuller
    const ogeler = [...(anahtar ? ['anahtar'] : []), ...Array(ampul).fill('ampul')], m = Math.max(ogeler.length, 1), slot = (x1 - x0) / m;
    let onceki = x0; const konumlar = {};
    ogeler.forEach((o, i) => {
      const cx = x0 + slot * (i + 0.5), yar = o === 'ampul' ? 13 : 16;
      s.cizgi(onceki, y0, cx - yar, y0, W1); onceki = cx + yar;
      if (o === 'ampul') { s.cember(cx, y0, 13, { kalinlik: 2, dolgu: '#FFFFFF' }); s.cizgi(cx - 9, y0 - 9, cx + 9, y0 + 9, { kalinlik: 1.6 }); s.cizgi(cx - 9, y0 + 9, cx + 9, y0 - 9, { kalinlik: 1.6 }); konumlar.ampul = [cx, y0]; }
      else {
        s.nokta(cx - 14, y0, { r: 3 }); s.nokta(cx + 14, y0, { r: 3 });
        if (anahtar === 'kapali') s.cizgi(cx - 14, y0, cx + 14, y0, { kalinlik: 2.6 }); else s.cizgi(cx - 14, y0, cx + 9, y0 - 15, { kalinlik: 2.6 });
        konumlar.anahtar = [cx, y0];
      }
    });
    s.cizgi(onceki, y0, x1, y0, W1);
    s.cizgi(x1, y0, x1, y1, W1);
    // alt kol (kopuk olabilir)
    const xm = (x0 + x1) / 2;
    if (pn.kopuk) { s.cizgi(x0, y1, xm - 14, y1, W1); s.cizgi(xm + 14, y1, x1, y1, W1); s.nokta(xm - 14, y1, { r: 3 }); s.nokta(xm + 14, y1, { r: 3 }); } else s.cizgi(x0, y1, x1, y1, W1);
    s.metin(ox + 18, oy + 26, pn.ad, { kalin: true, boyut: 17 });
    const hr = pn.harf ?? {};
    const yer = (tur, adaylar, yazi) => { s.metinYerlestir(adaylar, yazi, { kalin: true, boyut: yz }); };
    if (hr.pil) { yer('pil', [[x0 - 24, mid + 5], [x0 + 26, mid + 5]], hr.pil); olgular.harf[`${pn.ad}:${hr.pil}`] = 'pil'; }
    if (hr.ampul && konumlar.ampul) { const [cx] = konumlar.ampul; yer('ampul', [[cx, y0 - 22], [cx, y0 + 30]], hr.ampul); olgular.harf[`${pn.ad}:${hr.ampul}`] = 'ampul'; }
    if (hr.anahtar && konumlar.anahtar) { const [cx] = konumlar.anahtar; yer('anahtar', [[cx, y0 - 26], [cx, y0 + 30]], hr.anahtar); olgular.harf[`${pn.ad}:${hr.anahtar}`] = 'anahtar'; }
    if (hr.kablo) { yer('kablo', [[x1 + 16, mid + 5], [xm, y1 + 24], [xm, y1 - 10]], hr.kablo); olgular.harf[`${pn.ad}:${hr.kablo}`] = 'kablo'; }
    if (p.etiket) {
      if (pil) s.metinYerlestir([[x0 - 22, mid + 5], [x0 + 28, mid + 5]], 'pil', { boyut: 13 });
      if (konumlar.ampul) s.metinYerlestir([[konumlar.ampul[0], y0 - 24], [konumlar.ampul[0], y0 + 34]], 'ampul', { boyut: 13 });
      if (konumlar.anahtar) s.metinYerlestir([[konumlar.anahtar[0], y0 - 24], [konumlar.anahtar[0], y0 + 34]], 'anahtar', { boyut: 13 });
    }
    const neden = pil < 1 ? 'pil_yok' : ampul < 1 ? 'ampul_yok' : pn.kopuk ? 'kopuk_kablo' : anahtar === 'acik' ? 'acik_anahtar' : null;
    olgular.paneller[pn.ad] = { calisir: !neden, neden, parlaklik: neden ? 0 : r1(pil / ampul), pil, ampul };
  });
  const pr = Object.entries(olgular.paneller).filter(([, v]) => v.parlaklik > 0).sort((a, b) => b[1].parlaklik - a[1].parlaklik);
  if (pr.length && (pr.length === 1 || pr[0][1].parlaklik > pr[1][1].parlaklik)) olgular.en_parlak = pr[0][0];
  const alt = n === 1 ? 'Pil, ampul ve bağlantı kablolarından oluşan bir elektrik devresi şeması.' : `${n} ayrı elektrik devresi şeması; her devrenin köşesinde bir harf yazıyor.`;
  return { sahne: s, alt, olgular };
}

// ---------- 4) ölçüm silindiri ----------
// parametreler: { max, bolme, buyuk, silindirler:[{ad, seviye, cisim?:bool}] }  seviye bölmenin katı olmalı.
function silindir(p, profil) {
  const n = p.silindirler.length; if (n < 1 || n > 4) hata('silindir_sayisi_1_4');
  const hucre = 92, W = Math.max(n * hucre, 150), H = 280, Y0 = 36, Y1 = 220, s = new Sahne(W, H, profil), bolme = p.bolme, max = p.max, buyuk = p.buyuk;
  const adet = Math.round(max / bolme); if ((Y1 - Y0) / adet < 5) hata('bolme_cok_sik');
  if (Math.abs(Math.round(buyuk / bolme) * bolme - buyuk) > 1e-9) hata('buyuk_bolmeye_uymuyor');
  const Y = (v) => Y1 - (v / max) * (Y1 - Y0), olgular = { okunan: {}, seviyeler: [], hacim: {} };
  const sol0 = (W - n * hucre) / 2;
  p.silindirler.forEach((c, i) => {
    if (Math.abs(c.seviye / bolme - Math.round(c.seviye / bolme)) > 1e-9 || c.seviye < 0 || c.seviye > max) hata(`seviye_gecersiz:${c.ad}`);
    const cx = sol0 + hucre * (i + 0.5), tl = cx - 30, tw = 28;
    if (c.seviye > 0) s.dikdortgen(tl, Y(c.seviye), tw, Y1 - Y(c.seviye), { dolgu: SU, renk: SU, kalinlik: 1 });
    if (c.cisim) { const yuk = Math.min(Math.max((c.cisimHacim ?? 6) / max * (Y1 - Y0), 12), 60); s.poligon([[tl + 5, Y1 - 1], [tl + tw - 5, Y1 - 1], [tl + tw - 5, Y1 - yuk * 0.8], [tl + tw / 2, Y1 - yuk], [tl + 5, Y1 - yuk * 0.8]], { dolgu: PALET.gri, renk: KOYU, kalinlik: 1.6 }); }
    s.cizgi(tl, Y0 - 6, tl, Y1, { kalinlik: 2.4 }); s.cizgi(tl + tw, Y0 - 6, tl + tw, Y1, { kalinlik: 2.4 }); s.cizgi(tl, Y1, tl + tw, Y1, { kalinlik: 2.6 });
    for (let j = 0; j <= adet; j++) {
      const v = j * bolme, ana = Math.abs(v / buyuk - Math.round(v / buyuk)) < 1e-9;
      s.cizgi(tl + tw, Y(v), tl + tw + (ana ? 11 : 6), Y(v), { kalinlik: ana ? 1.8 : 1 });
      if (ana) s.metin(tl + tw + 15, Y(v) + 5, String(Math.round(v)), { hiza: 'start', boyut: 12 });
    }
    if (c.ad) s.metin(cx, Y1 + 34, c.ad, { kalin: true, boyut: 15 });
    olgular.okunan[c.ad || String(i)] = c.seviye; olgular.seviyeler.push(c.seviye);
    if (i > 0) olgular.hacim[c.ad || String(i)] = Math.round((c.seviye - p.silindirler[0].seviye) * 1000) / 1000;
  });
  const alt = 'Su dolu dereceli (ölçüm) silindir' + (n > 1 ? 'ler; bazılarında bir cisim suyun içindedir.' : '. Silindirin yanında sayılı ve çizgili bir skala vardır.');
  return { sahne: s, alt, olgular };
}

// ---------- 5) mıknatıs çiftleri ----------
// parametreler: { ciftler:[{ad, sol:'N'|'S', sag:'N'|'S'}] }  sol/sag: karşılıklı bakan kutuplar. Aynı kutup iter, farklı kutup çeker.
function miknatis(p, profil) {
  const n = p.ciftler.length; if (n < 2 || n > 4) hata('cift_sayisi_2_4');
  const W = 320, H = 20 + n * 52, s = new Sahne(W, H, profil), olgular = { etki: {}, say: { iter: 0, ceker: 0 } };
  const tersi = (k) => (k === 'N' ? 'S' : 'N'), renk = (k) => (k === 'N' ? PALET.kirmizi : PALET.mavi);
  p.ciftler.forEach((c, i) => {
    const y = 14 + i * 52 + 10, h = 30, hw = 40;
    for (const k of [c.sol, c.sag]) if (k !== 'N' && k !== 'S') hata('kutup_gecersiz');
    const sol = [tersi(c.sol), c.sol], sag = [c.sag, tersi(c.sag)]; // her mıknatıs: [soldaki yarı, sağdaki yarı]
    [[58, sol], [58 + 2 * hw + 64, sag]].forEach(([x, k]) => k.forEach((kk, j) => { s.dikdortgen(x + j * hw, y, hw, h, { dolgu: renk(kk), renk: PALET.siyah, kalinlik: 1.6 }); s.metin(x + j * hw + hw / 2, y + 21, kk, { renk: '#FFFFFF', kalin: true, boyut: 16 }); }));
    s.metin(24, y + 21, c.ad, { kalin: true, boyut: 17 });
    const e = c.sol === c.sag ? 'iter' : 'ceker'; olgular.etki[c.ad] = e; olgular.say[e] += 1;
  });
  return { sahne: s, alt: `${n} ayrı mıknatıs çifti; her çiftte iki çubuk mıknatıs karşılıklı duruyor ve uçlarında N ya da S harfi yazıyor.`, olgular };
}

// ---------- 6) termometre ----------
// parametreler: { min, max, bolme, buyuk, termometreler:[{ad, deger}] }
function termometre(p, profil) {
  const n = p.termometreler.length; if (n < 1 || n > 3) hata('termometre_sayisi_1_3');
  const hucre = 104, W = Math.max(n * hucre, 150), H = 280, Y0 = 24, Y1 = 210, s = new Sahne(W, H, profil), olgular = { okunan: {}, fark: null };
  const bolme = p.bolme, adet = Math.round((p.max - p.min) / bolme); if ((Y1 - Y0) / adet < 5) hata('bolme_cok_sik');
  const Y = (v) => Y1 - ((v - p.min) / (p.max - p.min)) * (Y1 - Y0), sol0 = (W - n * hucre) / 2;
  p.termometreler.forEach((t, i) => {
    if (Math.abs((t.deger - p.min) / bolme - Math.round((t.deger - p.min) / bolme)) > 1e-9 || t.deger < p.min || t.deger > p.max) hata(`deger_gecersiz:${t.ad}`);
    const cx = sol0 + hucre * (i + 0.5) - 14;
    s.dikdortgen(cx - 6, Y0 - 6, 12, Y1 - Y0 + 6, { renk: PALET.siyah, kalinlik: 2, dolgu: '#FFFFFF' });
    s.cember(cx, Y1 + 10, 11, { dolgu: PALET.kirmizi, renk: PALET.siyah, kalinlik: 2 });
    s.dikdortgen(cx - 3, Y(t.deger), 6, Y1 + 6 - Y(t.deger), { dolgu: PALET.kirmizi, renk: PALET.kirmizi, kalinlik: 1 });
    for (let j = 0; j <= adet; j++) {
      const v = p.min + j * bolme, ana = Math.abs((v - p.min) / p.buyuk - Math.round((v - p.min) / p.buyuk)) < 1e-9;
      s.cizgi(cx + 6, Y(v), cx + 6 + (ana ? 11 : 6), Y(v), { kalinlik: ana ? 1.8 : 1 });
      if (ana) s.metin(cx + 22, Y(v) + 5, String(Math.round(v)).replace('-', '−'), { hiza: 'start', boyut: 12 });
    }
    if (t.ad) s.metin(cx, Y1 + 45, t.ad, { kalin: true, boyut: 15 });
    olgular.okunan[t.ad || String(i)] = t.deger;
  });
  if (n === 2) olgular.fark = Math.round((p.termometreler[1].deger - p.termometreler[0].deger) * 1000) / 1000;
  return { sahne: s, alt: 'Kırmızı sıvılı termometre' + (n > 1 ? 'ler; her birinin yanında sayılı bir skala vardır.' : '; yanında sayılı ve çizgili bir skala vardır. Skalanın birimi santigrat derecedir (°C).'), olgular };
}

// ---------- 7) Güneş – Dünya – Ay modeli ----------
// parametreler: { aylar:[{ad, aci}] } aci ∈ {180 (Güneş tarafı), 270, 0 (Güneş'in karşısı), 90}. Ay'ın dolanma yönü okla gösterilir.
const GDM_EVRE = { 180: 'Yeni Ay', 270: 'İlk dördün', 0: 'Dolunay', 90: 'Son dördün' };
function gdm(p, profil) {
  const W = 360, H = 262, ex = 214, ey = 131, R = 78, s = new Sahne(W, H, profil), olgular = { evre: {}, tutulma: {}, konum: {} };
  s.cember(34, ey, 26, { dolgu: SARI, renk: '#B45309', kalinlik: 2 });
  s.metin(34, ey + 46, 'Güneş', { boyut: 14 });
  for (const y of [78, 104, 158, 184]) s.cizgi(68, y, 104, y, { renk: '#B45309', kalinlik: 1.8, ok: true });
  kesikCember(s, ex, ey, R);
  s.cember(ex, ey, 16, { dolgu: PALET.gok, renk: PALET.siyah, kalinlik: 1.8 });
  s.metin(ex, ey + 38, 'Dünya', { boyut: 13 });
  // dolanma yönü oku (saat yönünün tersi)
  const pt = (a, r = R) => [ex + r * Math.cos(aciRad(a)), ey - r * Math.sin(aciRad(a))];
  const [ox1, oy1] = pt(40), [ox2, oy2] = pt(58); s.cizgi(ox1, oy1, ox2, oy2, { ok: true, kalinlik: 2.4 });
  for (const m of p.aylar) {
    const a = ((m.aci % 360) + 360) % 360; if (!(a in GDM_EVRE)) hata(`aci_desteklenmiyor:${a}`);
    const [x, y] = pt(a);
    s.cember(x, y, 12, { dolgu: '#6B7280', renk: PALET.siyah, kalinlik: 1.6 });
    yol(s, `M${r1(x)} ${r1(y - 12)} A12 12 0 0 0 ${r1(x)} ${r1(y + 12)} Z`, { dolgu: '#FFF3B0', renk: PALET.siyah, kalinlik: 1.2 });
    const [lx, ly] = pt(a, R + 27); s.metin(lx, ly + 5, m.ad, { kalin: true, boyut: 15 });
    olgular.evre[m.ad] = GDM_EVRE[a]; olgular.konum[m.ad] = a === 180 ? 'gunes_dunya_arasi' : a === 0 ? 'dunya_ardi' : 'yan';
    olgular.tutulma[m.ad] = a === 180 ? 'Güneş tutulması' : a === 0 ? 'Ay tutulması' : 'yok';
  }
  return { sahne: s, alt: 'Güneş, Dünya ve Dünya çevresindeki yörüngede farklı konumlarda duran Ay modeli. Ay’ın her konumu bir harfle gösterilmiştir.', olgular };
}

// ---------- 8) gölge düzenekleri ----------
// parametreler: { paneller:[{ad, d}] , h, D }  Işık kaynağı noktasal; d: kaynak–cisim uzaklığı; D: kaynak–perde uzaklığı (çizim birimi); h: cisim boyu.
function golge(p, profil) {
  const n = p.paneller.length; if (n < 2 || n > 4) hata('panel_sayisi_2_4');
  const cw = 180, ch = 118, kol = 2, sat = Math.ceil(n / kol), W = cw * kol, H = ch * sat, s = new Sahne(W, H, profil), olgular = { golge: {} };
  p.paneller.forEach((pn, i) => {
    const ox = (i % kol) * cw, oy = Math.floor(i / kol) * ch, cy = oy + 62, sx = ox + 16, px = ox + 16 + p.D, cx = sx + pn.d;
    const sh = (p.h * p.D) / pn.d; if (sh > 100) hata('golge_cok_buyuk');
    s.dikdortgen(ox + 3, oy + 3, cw - 6, ch - 6, { renk: PALET.gri, kalinlik: 1 });
    s.cizgi(px, cy - 52, px, cy + 52, { kalinlik: 3, renk: '#6B7280' });
    s.dikdortgen(px - 3, cy - sh / 2, 9, sh, { dolgu: KOYU, renk: KOYU, kalinlik: 1 });
    for (const sg of [-1, 1]) s.cizgi(sx, cy, px, cy + sg * sh / 2, { renk: '#B45309', kalinlik: 1.1, izgara: true });
    s.dikdortgen(cx - 3, cy - p.h / 2, 6, p.h, { dolgu: PALET.turuncu, renk: PALET.siyah, kalinlik: 1.4 });
    s.cember(sx, cy, 7, { dolgu: SARI, renk: '#B45309', kalinlik: 2 });
    s.metin(ox + 14, oy + 22, pn.ad, { kalin: true, boyut: 16 });
    olgular.golge[pn.ad] = r1(sh);
  });
  const sirali = Object.entries(olgular.golge).sort((a, b) => b[1] - a[1]);
  olgular.en_buyuk = sirali[0][1] > sirali[1][1] ? sirali[0][0] : null; olgular.en_kucuk = sirali.at(-1)[1] < sirali.at(-2)[1] ? sirali.at(-1)[0] : null;
  return { sahne: s, alt: `${n} ayrı gölge düzeneği; her düzenekte bir ışık kaynağı, bir cisim ve bir perde vardır. Düzeneklerin köşesinde harf yazıyor.`, olgular };
}

export const TIPLER_A5 = {
  'a5-devre': devre,
  'a5-silindir': silindir,
  'a5-miknatis': miknatis,
  'a5-termometre': termometre,
  'a5-gdm': gdm,
  'a5-golge': golge,
  'a5-kap-hal': kapHal,
  'a5-dongu': dongu,
};
void aciRad;
