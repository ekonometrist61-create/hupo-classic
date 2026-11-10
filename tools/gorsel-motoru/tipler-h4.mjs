// Ajan H4 (5. sınıf Fen): ışığın doğrusal yolu, çubukta ısı iletimi, ışık geçirme şekil tipleri.
// Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }. Tip adları 'h4-' öneki ile benzersiz.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const KOYU = '#374151', ACIK_GRI = '#E5E7EB', SARI = '#F6D860';

// ---------- 1) delikli kartonlar ve perde (ışığın doğrusal yolu) ----------
// parametreler: { paneller:[{ad, kaynakY, ekranY, kartlar:[{x, y}]}] }  2–4 düzenek (2 sütun).
// Işık kaynağı (SOL, kaynakY); perde x = SAG. Her kartın delik merkezi (x, y) kaynak–perde doğrusundan DELIK_R kadar uzaktaysa ışık geçer.
export const DELIK_R = 7, DELIK_SOL = 22, DELIK_SAG = 160;
function delik(p, profil) {
  const n = p.paneller.length; if (n < 2 || n > 4) hata('panel_sayisi_2_4');
  const cw = 180, ch = 130, kol = 2, sat = Math.ceil(n / kol), W = cw * kol, H = ch * sat;
  const s = new Sahne(W, H, profil), olgular = { isik: {}, gecen: null };
  const gecenler = [];
  p.paneller.forEach((pn, idx) => {
    const ox = (idx % kol) * cw, oy = Math.floor(idx / kol) * ch;
    if (!pn.kartlar.length || pn.kartlar.length > 3) hata('kart_sayisi_1_3');
    for (const k of pn.kartlar) if (k.y - DELIK_R < 16 || k.y + DELIK_R > ch - 16) hata('delik_tuval_disi');
    s.dikdortgen(ox + 3, oy + 3, cw - 6, ch - 6, { renk: PALET.gri, kalinlik: 1 });
    const yDogru = (x) => pn.kaynakY + ((pn.ekranY - pn.kaynakY) * (x - DELIK_SOL)) / (DELIK_SAG - DELIK_SOL);
    const gecer = pn.kartlar.every((k) => Math.abs(yDogru(k.x) - k.y) <= DELIK_R);
    s.cember(ox + DELIK_SOL, oy + pn.kaynakY, 7, { dolgu: SARI, renk: KOYU, kalinlik: 1.8 });
    s.cizgi(ox + DELIK_SAG, oy + 14, ox + DELIK_SAG, oy + ch - 14, { renk: KOYU, kalinlik: 3 });
    for (const k of pn.kartlar) {
      s.dikdortgen(ox + k.x - 4, oy + 14, 8, k.y - DELIK_R - 14, { dolgu: ACIK_GRI, renk: KOYU, kalinlik: 1.2 });
      s.dikdortgen(ox + k.x - 4, oy + k.y + DELIK_R, 8, ch - 14 - (k.y + DELIK_R), { dolgu: ACIK_GRI, renk: KOYU, kalinlik: 1.2 });
    }
    if (gecer) s.cember(ox + DELIK_SAG, oy + pn.ekranY, 5, { dolgu: KOYU, renk: KOYU, kalinlik: 1 });
    s.metin(ox + 10, oy + 118, pn.ad, { kalin: true, hiza: 'start', boyut: 14 });
    olgular.isik[pn.ad] = gecer; if (gecer) gecenler.push(pn.ad);
  });
  olgular.gecen = gecenler.length === 1 ? gecenler[0] : null;
  return { sahne: s, alt: `${n} ayrı düzenek; her düzenekte solda sarı bir ışık kaynağı, ortada delikli kartonlar ve sağda bir perde vardır. Düzeneklerin altında harfler yazıyor.`, olgular };
}

// ---------- 2) çubuklarda ısı iletimi (mumla tutturulmuş pullar) ----------
// parametreler: { cubuklar:[{ad, dusen}] }  dusen: ısı kaynağına en yakın pullardan kaç tanesi düşmüş (0–4). 2–4 çubuk (2 sütun).
const PUL_X = [62, 92, 122, 152];
function cubuk(p, profil) {
  const n = p.cubuklar.length; if (n < 2 || n > 4) hata('cubuk_sayisi_2_4');
  const cw = 180, ch = 130, kol = 2, sat = Math.ceil(n / kol), W = cw * kol, H = ch * sat;
  const s = new Sahne(W, H, profil), olgular = { dusen: {}, en_iletken: null, en_yalitkan: null };
  p.cubuklar.forEach((c, idx) => {
    const ox = (idx % kol) * cw, oy = Math.floor(idx / kol) * ch, cy = oy + 60;
    if (!Number.isInteger(c.dusen) || c.dusen < 0 || c.dusen > PUL_X.length) hata('dusen_aralik');
    s.dikdortgen(ox + 3, oy + 3, cw - 6, ch - 6, { renk: PALET.gri, kalinlik: 1 });
    s.poligon([[ox + 14, cy + 14], [ox + 34, cy + 14], [ox + 24, cy - 8]], { dolgu: KOYU, renk: KOYU, kalinlik: 1 }); // ısı kaynağı (alev)
    s.dikdortgen(ox + 40, cy - 4, 130, 8, { dolgu: ACIK_GRI, renk: KOYU, kalinlik: 1.4 }); // çubuk
    PUL_X.forEach((x, i) => {
      const px = ox + x;
      if (i < c.dusen) s.cizgi(px - 7, cy + 18, px + 7, cy + 18, { renk: KOYU, kalinlik: 2.4 }); // düşmüş pul: çubuğun altında yatıyor
      else { s.cizgi(px, cy - 4, px, cy - 18, { renk: KOYU, kalinlik: 2 }); s.cember(px, cy - 22, 3, { dolgu: KOYU, renk: KOYU, kalinlik: 1 }); } // yerinde pul
    });
    s.metin(ox + 10, oy + 118, c.ad, { kalin: true, hiza: 'start', boyut: 14 });
    olgular.dusen[c.ad] = c.dusen;
  });
  const sirali = Object.entries(olgular.dusen).sort((a, b) => b[1] - a[1]);
  olgular.en_iletken = sirali[0][1] > sirali[1][1] ? sirali[0][0] : null;
  olgular.en_yalitkan = sirali.at(-1)[1] < sirali.at(-2)[1] ? sirali.at(-1)[0] : null;
  return { sahne: s, alt: `${n} ayrı çubuk; her çubuğun solunda bir ısı kaynağı vardır. Çubukların üstünde mumla tutturulmuş pullar bulunur. Çubukların altında harfler yazıyor.`, olgular };
}

// ---------- 3) ışık geçirme: cisim, madde levhası ve perdedeki görüntü ----------
// parametreler: { paneller:[{ad, goruntu:'net'|'bulanik'|'yok'}], cisim: 18|22|26 }
// net: perdede keskin görüntü (saydam); bulanik: perdede kesikli kenarlı görüntü (yarı saydam); yok: görüntü yok (saydam olmayan).
function gecirgenlik(p, profil) {
  const n = p.paneller.length; if (n < 2 || n > 4) hata('panel_sayisi_2_4');
  if (![18, 22, 26].includes(p.cisim)) hata('cisim_boyu');
  const lv = p.levha ?? 14; if (![12, 14, 16, 20].includes(lv)) hata('levha_genisligi');
  const c = p.cisim, cw = 180, ch = 130, kol = 2, sat = Math.ceil(n / kol), W = cw * kol, LEJ = 34, H = ch * sat + LEJ;
  const s = new Sahne(W, H, profil), olgular = { goruntu: {}, net: null, yok: null };
  const ucgen = (x, y) => [[x - c / 2, y + c / 2], [x + c / 2, y + c / 2], [x, y - c / 2]];
  const ucgenK = (x, y, b) => [[x - b / 2, y + b / 2], [x + b / 2, y + b / 2], [x, y - b / 2]];
  p.paneller.forEach((pn, idx) => {
    const ox = (idx % kol) * cw, oy = Math.floor(idx / kol) * ch, cy = oy + 62;
    if (!['net', 'bulanik', 'yok'].includes(pn.goruntu)) hata(`goruntu_bilinmiyor:${pn.goruntu}`);
    s.dikdortgen(ox + 3, oy + 3, cw - 6, ch - 6, { renk: PALET.gri, kalinlik: 1 });
    s.cember(ox + 16, cy, 7, { dolgu: SARI, renk: KOYU, kalinlik: 1.6 }); // ışık kaynağı
    s.poligon(ucgen(ox + 48, cy), { dolgu: KOYU, renk: KOYU, kalinlik: 1 }); // cisim
    s.dikdortgen(ox + 84, cy - 34, lv, 68, { dolgu: ACIK_GRI, renk: KOYU, kalinlik: 1.2 }); // madde levhası
    s.cizgi(ox + 166, cy - 40, ox + 166, cy + 40, { renk: KOYU, kalinlik: 3 }); // perde
    const gx = ox + 148;
    if (pn.goruntu === 'net') s.poligon(ucgen(gx, cy), { dolgu: KOYU, renk: KOYU, kalinlik: 1 });
    else if (pn.goruntu === 'bulanik') {
      const t = ucgen(gx, cy);
      for (let i = 0; i < 3; i++) { const [x1, y1] = t[i], [x2, y2] = t[(i + 1) % 3]; s.cizgi(x1, y1, x2, y2, { renk: KOYU, kalinlik: 2, kesik: true }); }
    }
    s.metin(ox + 10, oy + 118, pn.ad, { kalin: true, hiza: 'start', boyut: 14 });
    olgular.goruntu[pn.ad] = pn.goruntu;
  });
  // lejant: yalnız perdedeki işaretin ne anlama geldiği (hiçbir düzeneğin sonucu değil)
  const ly = ch * sat + 18;
  s.poligon(ucgenK(16, ly, 12), { dolgu: KOYU, renk: KOYU, kalinlik: 1 });
  s.metin(36, ly, 'Net görüntü', { hiza: 'start', boyut: 11 });
  { const t = ucgenK(116, ly, 12); for (let i = 0; i < 3; i++) { const [x1, y1] = t[i], [x2, y2] = t[(i + 1) % 3]; s.cizgi(x1, y1, x2, y2, { renk: KOYU, kalinlik: 1.6, kesik: true }); } }
  s.metin(136, ly, 'Bulanık görüntü', { hiza: 'start', boyut: 11 });
  s.metin(244, ly, 'Boş: Görüntü yok', { hiza: 'start', boyut: 11 });
  const say = (t) => { const a = Object.entries(olgular.goruntu).filter(([, v]) => v === t); return a.length === 1 ? a[0][0] : null; };
  olgular.net = say('net'); olgular.yok = say('yok');
  return { sahne: s, alt: `${n} ayrı düzenek; her düzenekte solda bir ışık kaynağı ve bir cisim, ortada bir madde levhası, sağda bir perde vardır. Perdede görüntü olup olmadığı düzeneğe göre değişir. Düzeneklerin altında harfler yazıyor. En altta perdedeki işaretlerin anlamını gösteren bir açıklama kutusu bulunur.`, olgular };
}

export const TIPLER_H4 = {
  'h4-delik': delik,
  'h4-cubuk': cubuk,
  'h4-gecirgenlik': gecirgenlik,
};
