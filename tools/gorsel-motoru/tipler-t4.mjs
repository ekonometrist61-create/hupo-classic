// Türkçe 4 için şekil tipleri (T.4.3.22 levha işaretleri). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'tr4-' önekiyle başlar. Alt metin işaretlerin anlamını yazmaz.
import { Sahne, PALET } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const BEYAZ = '#FFFFFF';
const BIRIM = 110, ARA = 24, KENAR = 12;

// Her işaret, kutusunun merkezinde (cx, cy) çizilir. Renk anlam taşımaz; anlam şekildedir.
const CIZIM = {
  hastane: (s, cx, cy) => {
    s.dikdortgen(cx - 12, cy - 36, 24, 72, { dolgu: PALET.mavi, renk: PALET.mavi });
    s.dikdortgen(cx - 36, cy - 12, 72, 24, { dolgu: PALET.mavi, renk: PALET.mavi });
  },
  bilgi: (s, cx, cy) => {
    s.cember(cx, cy, 38, { dolgu: PALET.mavi, renk: PALET.mavi });
    s.metin(cx, cy + 20, 'i', { boyut: 56, kalin: true, renk: BEYAZ });
  },
  su: (s, cx, cy) => {
    s.poligon([[cx, cy - 38], [cx + 24, cy + 2], [cx + 26, cy + 14], [cx + 16, cy + 28], [cx, cy + 36], [cx - 16, cy + 28], [cx - 26, cy + 14], [cx - 24, cy + 2]], { dolgu: PALET.mavi, renk: PALET.mavi });
  },
  yemek: (s, cx, cy) => {
    s.cizgi(cx - 16, cy - 12, cx - 16, cy + 36, { renk: PALET.mavi, kalinlik: 4 });
    s.cizgi(cx - 24, cy - 36, cx - 24, cy - 12, { renk: PALET.mavi, kalinlik: 3 });
    s.cizgi(cx - 16, cy - 36, cx - 16, cy - 12, { renk: PALET.mavi, kalinlik: 3 });
    s.cizgi(cx - 8, cy - 36, cx - 8, cy - 12, { renk: PALET.mavi, kalinlik: 3 });
    s.cizgi(cx - 24, cy - 12, cx - 8, cy - 12, { renk: PALET.mavi, kalinlik: 3 });
    s.poligon([[cx + 14, cy - 36], [cx + 26, cy - 30], [cx + 26, cy + 4], [cx + 14, cy + 4]], { dolgu: PALET.mavi, renk: PALET.mavi });
    s.cizgi(cx + 14, cy + 4, cx + 14, cy + 36, { renk: PALET.mavi, kalinlik: 4 });
  },
  kitap: (s, cx, cy) => {
    s.poligon([[cx - 36, cy - 24], [cx - 4, cy - 16], [cx - 4, cy + 30], [cx - 36, cy + 22]], { dolgu: BEYAZ, renk: PALET.mavi, kalinlik: 3 });
    s.poligon([[cx + 36, cy - 24], [cx + 4, cy - 16], [cx + 4, cy + 30], [cx + 36, cy + 22]], { dolgu: BEYAZ, renk: PALET.mavi, kalinlik: 3 });
  },
  otopark: (s, cx, cy) => {
    s.dikdortgen(cx - 36, cy - 36, 72, 72, { dolgu: PALET.mavi, renk: PALET.mavi });
    s.metin(cx, cy + 20, 'P', { boyut: 60, kalin: true, renk: BEYAZ });
  },
  otobus: (s, cx, cy) => {
    s.dikdortgen(cx - 34, cy - 30, 68, 46, { dolgu: PALET.mavi, renk: PALET.mavi });
    s.dikdortgen(cx - 26, cy - 22, 22, 16, { dolgu: BEYAZ, renk: BEYAZ });
    s.dikdortgen(cx + 4, cy - 22, 22, 16, { dolgu: BEYAZ, renk: BEYAZ });
    s.cember(cx - 18, cy + 20, 8, { dolgu: PALET.siyah, renk: PALET.siyah });
    s.cember(cx + 18, cy + 20, 8, { dolgu: PALET.siyah, renk: PALET.siyah });
  },
};

// parametreler: { isaretler: [kimlik, kimlik, kimlik] } (soldan sağa)
function levha(p, profil) {
  const ids = p.isaretler;
  if (!Array.isArray(ids) || ids.length < 2 || ids.length > 3) hata('isaret_sayisi_2_3');
  ids.forEach((id) => { if (!CIZIM[id]) hata(`isaret_bilinmiyor:${id}`); });
  const n = ids.length, W = 2 * KENAR + n * BIRIM + (n - 1) * ARA, H = 2 * KENAR + BIRIM + 8;
  const s = new Sahne(W, H, profil);
  ids.forEach((id, i) => {
    const x = KENAR + i * (BIRIM + ARA), cx = x + BIRIM / 2, cy = KENAR + BIRIM / 2;
    s.dikdortgen(x, KENAR, BIRIM, BIRIM, { dolgu: BEYAZ, renk: PALET.siyah, kalinlik: 3 });
    CIZIM[id](s, cx, cy);
  });
  return { sahne: s, alt: `Yan yana ${n} işaret bulunan bir levha.`, olgular: { isaretler: [...ids] } };
}

export const TIPLER_T4 = { 'tr4-isaret-levha': levha };
