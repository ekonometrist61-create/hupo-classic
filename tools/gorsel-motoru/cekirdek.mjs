// Görsel motoru çekirdeği: sahne oluşturucu (SVG), sınıf profili, renk paleti.
// Bağımlılık yok. Her çizim tipi `sahne` ile çizer; kapı (lint.mjs) sahneyi denetler.

// Okabe-Ito: renk körlüğüne dayanıklı palet.
export const PALET = {
  mavi: '#0072B2', turuncu: '#E69F00', yesil: '#009E73', kirmizi: '#D55E00',
  gok: '#56B4E9', pembe: '#CC79A7', sari: '#F0E442', siyah: '#1F2937', gri: '#9CA3AF',
};

// Sınıf başına stil bütçesi (plan §3.2).
export const PROFIL = {
  ilk: { siniflar: [1, 2], yazi: 18, cizgi: 3.5, maxRenk: 3, minYaziPx: 14 },
  orta: { siniflar: [3, 4], yazi: 15, cizgi: 3, maxRenk: 5, minYaziPx: 12 },
  ust: { siniflar: [5, 6, 7, 8], yazi: 13, cizgi: 2.2, maxRenk: 6, minYaziPx: 11 },
};
export function profilBul(sinif) {
  const p = Object.values(PROFIL).find((x) => x.siniflar.includes(sinif));
  if (!p) throw new Error(`sinif_profili_yok:${sinif}`);
  return p;
}

const rad = (d) => (d * Math.PI) / 180;
const yuv = (n) => Math.round(n * 100) / 100;
const kacis = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

export class Sahne {
  constructor(w, h, profil) {
    this.w = w; this.h = h; this.profil = profil;
    this.parcalar = [];
    this.noktalar = [];      // sınır denetimi için: [x, y, pay]
    this.metinKutulari = []; // çakışma denetimi için: {x0,y0,x1,y1,metin}
    this.cizgiler = [];      // ızgara dışı doğru parçaları (yazı–çizgi çakışması için)
    this.renkler = new Set();
    this.anlamRenkleri = {}; // renk -> etiket (renk anlam taşıyorsa)
    this.koyuZeminRenkleri = new Set();
  }
  _renk(r) { this.renkler.add(r); return r; }
  nokta(x, y, { r = 3.5, renk = PALET.siyah } = {}) {
    this.noktalar.push([x, y, r]);
    this.parcalar.push(`<circle cx="${yuv(x)}" cy="${yuv(y)}" r="${r}" fill="${this._renk(renk)}"/>`);
  }
  cizgi(x1, y1, x2, y2, { renk = PALET.siyah, kalinlik = this.profil.cizgi, kesik = false, ok = false, izgara = false } = {}) {
    this.noktalar.push([x1, y1, 0], [x2, y2, 0]);
    if (!izgara) this.cizgiler.push([x1, y1, x2, y2]);
    this.parcalar.push(`<line x1="${yuv(x1)}" y1="${yuv(y1)}" x2="${yuv(x2)}" y2="${yuv(y2)}" stroke="${this._renk(renk)}" stroke-width="${kalinlik}" stroke-linecap="round"${kesik ? ' stroke-dasharray="6 4"' : ''}/>`);
    if (ok) this._okBasi(x2, y2, Math.atan2(y2 - y1, x2 - x1), renk);
  }
  _okBasi(x, y, a, renk) {
    const u = 9; const g = 0.45;
    const p = [[x, y], [x - u * Math.cos(a - g), y - u * Math.sin(a - g)], [x - u * Math.cos(a + g), y - u * Math.sin(a + g)]];
    this.parcalar.push(`<polygon points="${p.map((q) => `${yuv(q[0])},${yuv(q[1])}`).join(' ')}" fill="${this._renk(renk)}"/>`);
  }
  cember(cx, cy, r, { renk = PALET.siyah, kalinlik = this.profil.cizgi, dolgu = 'none' } = {}) {
    this.noktalar.push([cx - r, cy - r, 0], [cx + r, cy + r, 0]);
    this.parcalar.push(`<circle cx="${yuv(cx)}" cy="${yuv(cy)}" r="${yuv(r)}" fill="${dolgu === 'none' ? 'none' : this._renk(dolgu)}" stroke="${this._renk(renk)}" stroke-width="${kalinlik}"/>`);
  }
  // Merkez (cx,cy), yarıçap r, açılar derece (matematik yönü: saat yönünün tersi), a0→a1 yayı.
  yay(cx, cy, r, a0, a1, { renk = PALET.siyah, kalinlik = 1.6 } = {}) {
    const p0 = [cx + r * Math.cos(rad(a0)), cy - r * Math.sin(rad(a0))];
    const p1 = [cx + r * Math.cos(rad(a1)), cy - r * Math.sin(rad(a1))];
    const buyuk = Math.abs(a1 - a0) > 180 ? 1 : 0;
    this.noktalar.push(p0.concat(0), p1.concat(0));
    this.parcalar.push(`<path d="M${yuv(p0[0])} ${yuv(p0[1])} A${r} ${r} 0 ${buyuk} 0 ${yuv(p1[0])} ${yuv(p1[1])}" fill="none" stroke="${this._renk(renk)}" stroke-width="${kalinlik}"/>`);
  }
  // Daire dilimi: merkez (cx,cy), yarıçap r, açılar derece (matematik yönü), a0 < a1.
  dilim(cx, cy, r, a0, a1, { dolgu = 'none', renk = PALET.siyah, kalinlik = 1.5 } = {}) {
    const p0 = [cx + r * Math.cos(rad(a0)), cy - r * Math.sin(rad(a0))], p1 = [cx + r * Math.cos(rad(a1)), cy - r * Math.sin(rad(a1))];
    this.noktalar.push([cx - r, cy - r, 0], [cx + r, cy + r, 0]);
    this.parcalar.push(`<path d="M${yuv(cx)} ${yuv(cy)} L${yuv(p0[0])} ${yuv(p0[1])} A${r} ${r} 0 ${a1 - a0 > 180 ? 1 : 0} 0 ${yuv(p1[0])} ${yuv(p1[1])} Z" fill="${dolgu === 'none' ? 'none' : this._renk(dolgu)}" stroke="${this._renk(renk)}" stroke-width="${kalinlik}" stroke-linejoin="round"/>`);
  }
  poligon(pts, { renk = PALET.siyah, dolgu = 'none', kalinlik = 1.5 } = {}) {
    for (const [x, y] of pts) this.noktalar.push([x, y, 0]);
    this.parcalar.push(`<polygon points="${pts.map(([x, y]) => `${yuv(x)},${yuv(y)}`).join(' ')}" fill="${dolgu === 'none' ? 'none' : this._renk(dolgu)}" stroke="${this._renk(renk)}" stroke-width="${kalinlik}" stroke-linejoin="round"/>`);
  }
  dikdortgen(x, y, w, h, { renk = PALET.siyah, dolgu = 'none', kalinlik = 1 } = {}) {
    this.noktalar.push([x, y, 0], [x + w, y + h, 0]);
    this.parcalar.push(`<rect x="${yuv(x)}" y="${yuv(y)}" width="${yuv(w)}" height="${yuv(h)}" fill="${dolgu === 'none' ? 'none' : this._renk(dolgu)}" stroke="${this._renk(renk)}" stroke-width="${kalinlik}"/>`);
  }
  metin(x, y, s, { boyut = this.profil.yazi, renk = PALET.siyah, hiza = 'middle', kalin = false } = {}) {
    const gen = String(s).length * boyut * 0.6;
    const x0 = hiza === 'middle' ? x - gen / 2 : hiza === 'end' ? x - gen : x;
    this.metinKutulari.push({ x0, y0: y - boyut, x1: x0 + gen, y1: y + boyut * 0.25, metin: String(s), boyut });
    this.parcalar.push(`<text x="${yuv(x)}" y="${yuv(y)}" font-family="Arial, Helvetica, sans-serif" font-size="${boyut}" text-anchor="${hiza}" fill="${this._renk(renk)}"${kalin ? ' font-weight="700"' : ''}>${kacis(s)}</text>`);
  }
  // Kutunun (yazı) bir çizgiyle kesişip kesişmediği (örnekleme).
  static kutuCizgiKesisir(k, [x1, y1, x2, y2], pay = 1.5) {
    const n = Math.max(8, Math.ceil(Math.hypot(x2 - x1, y2 - y1) / 2));
    for (let i = 0; i <= n; i++) {
      const x = x1 + ((x2 - x1) * i) / n, y = y1 + ((y2 - y1) * i) / n;
      if (x > k.x0 - pay && x < k.x1 + pay && y > k.y0 - pay && y < k.y1 + pay) return true;
    }
    return false;
  }
  _kutu(x, y, s, boyut, hiza) {
    const gen = String(s).length * boyut * 0.6;
    const x0 = hiza === 'middle' ? x - gen / 2 : hiza === 'end' ? x - gen : x;
    return { x0, y0: y - boyut, x1: x0 + gen, y1: y + boyut * 0.25, metin: String(s), boyut };
  }
  bosMu(k) {
    if (k.x0 < 0 || k.y0 < 0 || k.x1 > this.w || k.y1 > this.h) return false;
    if (this.metinKutulari.some((t) => k.x0 < t.x1 && t.x0 < k.x1 && k.y0 < t.y1 && t.y0 < k.y1)) return false;
    return !this.cizgiler.some((c) => Sahne.kutuCizgiKesisir(k, c));
  }
  // Adaylar sırayla denenir ([x,y] listesi); ilk boş olana yazılır, yoksa ilkine (lint hata verir).
  metinYerlestir(adaylar, s, secenek = {}) {
    const boyut = secenek.boyut ?? this.profil.yazi, hiza = secenek.hiza ?? 'middle';
    const sec = adaylar.find(([x, y]) => this.bosMu(this._kutu(x, y, s, boyut, hiza))) ?? adaylar[0];
    this.metin(sec[0], sec[1], s, secenek);
  }
  // koyuZemin: renk koyu bir zemin üzerinde kullanılıyorsa beyaz-zemin kontrast kontrolü atlanır.
  anlamRengi(renk, etiket, { koyuZemin = false } = {}) { this.anlamRenkleri[renk] = etiket; if (koyuZemin) this.koyuZeminRenkleri.add(renk); }
  svg(altMetin) {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${this.w} ${this.h}" role="img" aria-label="${kacis(altMetin)}"><rect width="${this.w}" height="${this.h}" fill="#FFFFFF"/>${this.parcalar.join('')}</svg>`;
  }
}

export const aciRad = rad;
