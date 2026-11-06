// Ajan A8 için şekil tipleri (İngilizce). Sözleşme tipler.mjs ile aynı: render(parametreler, profil) -> { sahne, alt, olgular }.
// Tip adları 'a8-' önekiyle başlar. Başka ajanın dosyasına dokunma.
// Bu dosya ayrıca şablonların paylaştığı küçük yardımcıları dışa aktarır (seçenek üretimi, saat sözcükleri, ad havuzları).
import { Sahne, PALET, aciRad } from './cekirdek.mjs';

const hata = (m) => { throw new Error(m); };
const LCG = (t) => () => { t = (Math.imul(t, 1664525) + 1013904223) >>> 0; return t / 4294967296; };
const K = '#1F2937';

// ---------- ortak: ham SVG parçası ekleme ----------
function ham(s, parca, kutu) {
  for (const [x, y] of kutu) s.noktalar.push([x, y, 0]);
  s.parcalar.push(parca);
}

// ---------- ikon kütüphanesi (birim kutu -1..1, y aşağı) ----------
const SW = 0.075;
const yol = (d, f = 'none', w = SW) => `<path d="${d}" fill="${f}" stroke="${K}" stroke-width="${w}" stroke-linejoin="round" stroke-linecap="round"/>`;
const daire = (x, y, r, f = 'none', w = SW) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${f}" stroke="${K}" stroke-width="${w}"/>`;
const dik = (x, y, w, h, f, rx = 0, sw = SW) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}" fill="${f}" stroke="${K}" stroke-width="${sw}" stroke-linejoin="round"/>`;
const cizgiS = (d, renk = K, w = 0.1) => `<path d="${d}" fill="none" stroke="${renk}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;
const bulut = (f, g = '') => `<g transform="${g}">${yol('M-0.7 0.4 Q-0.95 0.4 -0.95 0.1 Q-0.95 -0.2 -0.6 -0.2 Q-0.55 -0.65 -0.05 -0.65 Q0.4 -0.65 0.5 -0.25 Q0.95 -0.25 0.95 0.1 Q0.95 0.4 0.6 0.4 Z', f)}</g>`;
const yildizPts = (r1, r2) => Array.from({ length: 10 }, (_, i) => { const a = (-90 + i * 36) * Math.PI / 180, r = i % 2 ? r2 : r1; return `${(r * Math.cos(a)).toFixed(3)},${(r * Math.sin(a)).toFixed(3)}`; }).join(' ');
const bes = Array.from({ length: 5 }, (_, i) => { const a = (-90 + i * 72) * Math.PI / 180; return [0.27 * Math.cos(a), 0.27 * Math.sin(a)]; });

export const IKON = {
  apple: () => yol('M0 -0.5 C0.2 -0.85 0.85 -0.7 0.8 0 C0.75 0.55 0.4 0.9 0 0.75 C-0.4 0.9 -0.75 0.55 -0.8 0 C-0.85 -0.7 -0.2 -0.85 0 -0.5 Z', '#D62828') + cizgiS('M0 -0.5 L0.1 -0.92', '#6B3F1D', 0.1) + yol('M0.12 -0.8 Q0.55 -1.0 0.65 -0.62 Q0.25 -0.55 0.12 -0.8 Z', '#2E9E44'),
  orange: () => daire(0, 0.08, 0.76, '#F28C1B') + yol('M0 -0.68 Q0.1 -0.9 0.4 -0.9 Q0.3 -0.65 0 -0.68 Z', '#2E9E44') + daire(-0.25, -0.1, 0.05, '#C96F0E', 0.02) + daire(0.2, 0.05, 0.05, '#C96F0E', 0.02) + daire(-0.05, 0.38, 0.05, '#C96F0E', 0.02) + daire(0.35, 0.4, 0.05, '#C96F0E', 0.02),
  banana: () => yol('M-0.9 -0.15 Q-0.1 0.95 0.9 -0.6 Q0.88 -0.88 0.68 -0.82 Q-0.02 0.2 -0.72 -0.55 Z', '#F2C500'),
  cake: () => dik(-0.8, 0.1, 1.6, 0.7, '#F4A6C0', 0.1) + dik(-0.55, -0.35, 1.1, 0.45, '#FFF2D6', 0.1) + yol('M-0.55 -0.35 Q-0.4 -0.1 -0.28 -0.35 Q-0.15 -0.1 0 -0.35 Q0.15 -0.1 0.28 -0.35 Q0.4 -0.1 0.55 -0.35', 'none') + dik(-0.05, -0.75, 0.1, 0.4, '#3B82F6', 0.02, 0.05) + yol('M0 -0.95 Q0.1 -0.85 0 -0.76 Q-0.1 -0.85 0 -0.95 Z', '#F28C1B', 0.05),
  bread: () => yol('M-0.85 0.55 L-0.85 0 Q-0.85 -0.65 0 -0.65 Q0.85 -0.65 0.85 0 L0.85 0.55 Z', '#D9A441') + cizgiS('M-0.35 -0.4 L-0.2 0', K, 0.07) + cizgiS('M0 -0.45 L0.15 -0.05', K, 0.07) + cizgiS('M0.35 -0.4 L0.5 0', K, 0.07),
  egg: () => yol('M0 -0.85 C0.55 -0.85 0.7 0 0.7 0.3 C0.7 0.75 0.35 0.9 0 0.9 C-0.35 0.9 -0.7 0.75 -0.7 0.3 C-0.7 0 -0.55 -0.85 0 -0.85 Z', '#FFF3CF'),
  milk: () => dik(-0.45, -0.2, 0.9, 1.1, '#E3F0FB') + yol('M-0.45 -0.2 L-0.2 -0.7 L0.2 -0.7 L0.45 -0.2 Z', '#BBD8F2') + dik(-0.2, -0.88, 0.4, 0.18, '#3B82F6', 0.04) + yol('M0 0.1 Q0.22 0.42 0 0.62 Q-0.22 0.42 0 0.1 Z', '#3B82F6', 0.05),
  icecream: () => yol('M-0.45 -0.05 L0.45 -0.05 L0 0.95 Z', '#D9A441') + daire(0, -0.3, 0.5, '#F4A6C0') + daire(0.12, -0.88, 0.1, '#D62828', 0.05),
  pizza: () => yol('M0 0.9 L-0.82 -0.5 Q0 -0.95 0.82 -0.5 Z', '#F2C500') + cizgiS('M-0.82 -0.5 Q0 -0.95 0.82 -0.5', '#C47F2B', 0.2) + daire(-0.22, -0.2, 0.15, '#D62828', 0.05) + daire(0.25, -0.12, 0.15, '#D62828', 0.05) + daire(0, 0.3, 0.13, '#D62828', 0.05),
  burger: () => yol('M-0.8 -0.1 Q-0.8 -0.8 0 -0.8 Q0.8 -0.8 0.8 -0.1 Z', '#E0A04A') + yol('M-0.85 -0.05 Q-0.6 0.15 -0.4 -0.05 Q-0.2 0.15 0 -0.05 Q0.2 0.15 0.4 -0.05 Q0.6 0.15 0.85 -0.05 L0.85 0.1 L-0.85 0.1 Z', '#4DA64D') + dik(-0.8, 0.1, 1.6, 0.27, '#7B4A2A', 0.12) + dik(-0.8, 0.37, 1.6, 0.3, '#E0A04A', 0.15),
  juice: () => yol('M-0.5 -0.8 L0.5 -0.8 L0.38 0.85 L-0.38 0.85 Z', '#FFFFFF') + yol('M-0.46 -0.25 L0.46 -0.25 L0.38 0.85 L-0.38 0.85 Z', '#F5A623') + cizgiS('M0.15 -0.35 L0.45 -1.0', '#D62828', 0.09),
  pencil: () => `<g transform="rotate(-45) scale(0.78)">${dik(-0.95, -0.17, 1.4, 0.34, '#F2C500')}${yol('M0.45 -0.17 L0.95 0 L0.45 0.17 Z', '#F3D9B1')}${yol('M0.8 -0.05 L0.95 0 L0.8 0.05 Z', K, 0.03)}${dik(-1.12, -0.17, 0.17, 0.34, '#F4A6C0')}</g>`,
  book: () => dik(-0.65, -0.85, 1.3, 1.7, '#3B82F6', 0.05) + cizgiS('M-0.45 -0.85 L-0.45 0.85', K, 0.06) + dik(-0.25, -0.6, 0.75, 0.38, '#FFFFFF', 0.03, 0.05),
  ruler: () => dik(-0.95, -0.3, 1.9, 0.6, '#F2E394', 0.04) + [-0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75].map((x, i) => cizgiS(`M${x} -0.3 L${x} ${i % 2 ? -0.1 : 0.02}`, K, 0.05)).join(''),
  bag: () => dik(-0.6, -0.5, 1.2, 1.4, '#D55E00', 0.25) + cizgiS('M-0.25 -0.5 Q0 -0.98 0.25 -0.5', K, 0.08) + dik(-0.4, 0.3, 0.8, 0.45, '#A94800', 0.12, 0.06) + cizgiS('M-0.6 -0.05 L0.6 -0.05', K, 0.05),
  ball: () => daire(0, 0, 0.85, '#FFFFFF') + `<polygon points="${bes.map(([x, y]) => `${x.toFixed(3)},${y.toFixed(3)}`).join(' ')}" fill="${K}"/>` + bes.map(([x, y]) => cizgiS(`M${x.toFixed(3)} ${y.toFixed(3)} L${(x * 2.5).toFixed(3)} ${(y * 2.5).toFixed(3)}`, K, 0.06)).join(''),
  star: () => `<polygon points="${yildizPts(0.95, 0.4)}" fill="#F2C500" stroke="${K}" stroke-width="${SW}" stroke-linejoin="round"/>`,
  heart: () => yol('M0 0.85 C-1.0 0.1 -0.95 -0.7 -0.4 -0.7 C-0.15 -0.7 0 -0.5 0 -0.4 C0 -0.5 0.15 -0.7 0.4 -0.7 C0.95 -0.7 1.0 0.1 0 0.85 Z', '#D62828'),
  flower: () => cizgiS('M0 -0.1 L0 0.95', '#2E9E44', 0.1) + yol('M0 0.65 Q0.5 0.35 0.62 0.7 Q0.3 0.9 0 0.65 Z', '#2E9E44', 0.05) + bes.map(([x, y]) => daire((x * 1.5).toFixed(3), (y * 1.5 - 0.3).toFixed(3), 0.3, '#F4A6C0', 0.06)).join('') + daire(0, -0.3, 0.2, '#F2C500', 0.06),
  tree: () => dik(-0.14, 0.15, 0.28, 0.75, '#8B5A2B', 0.03) + daire(0, -0.25, 0.65, '#4DA64D') + daire(-0.38, 0.0, 0.38, '#4DA64D') + daire(0.38, 0.0, 0.38, '#4DA64D'),
  tshirt: () => yol('M-0.35 -0.75 L-0.82 -0.4 L-0.6 0.0 L-0.42 -0.12 L-0.42 0.8 L0.42 0.8 L0.42 -0.12 L0.6 0.0 L0.82 -0.4 L0.35 -0.75 Q0 -0.5 -0.35 -0.75 Z', '#56B4E9'),
  trousers: () => yol('M-0.45 -0.85 L0.45 -0.85 L0.58 0.9 L0.12 0.9 L0 -0.05 L-0.12 0.9 L-0.58 0.9 Z', '#4C6EA8') + cizgiS('M-0.45 -0.62 L0.45 -0.62', K, 0.06),
  shorts: () => yol('M-0.52 -0.6 L0.52 -0.6 L0.66 0.4 L0.1 0.4 L0 -0.02 L-0.1 0.4 L-0.66 0.4 Z', '#E69F00') + cizgiS('M-0.52 -0.4 L0.52 -0.4', K, 0.06),
  skirt: () => yol('M-0.35 -0.6 L0.35 -0.6 L0.85 0.7 L-0.85 0.7 Z', '#CC79A7') + cizgiS('M-0.15 -0.5 L-0.35 0.65', K, 0.05) + cizgiS('M0.15 -0.5 L0.35 0.65', K, 0.05),
  dress: () => yol('M-0.25 -0.92 L-0.35 -0.4 L-0.25 -0.1 L-0.8 0.9 L0.8 0.9 L0.25 -0.1 L0.35 -0.4 L0.25 -0.92 L0.1 -0.62 L-0.1 -0.62 Z', '#9B6BC9'),
  hat: () => yol('M-0.7 0.35 Q-0.7 -0.6 0 -0.6 Q0.7 -0.6 0.7 0.35 Z', '#D62828') + dik(-0.78, 0.25, 1.56, 0.32, '#FFFFFF', 0.1) + daire(0, -0.72, 0.18, '#FFFFFF'),
  shoe: () => yol('M-0.85 0.05 L-0.85 0.62 L0.9 0.62 Q0.9 0.25 0.5 0.18 L0.12 -0.08 L-0.02 -0.6 L-0.58 -0.6 L-0.58 0.05 Z', '#8B5A2B') + cizgiS('M-0.85 0.45 L0.9 0.45', K, 0.06),
  umbrella: () => yol('M-0.9 0 A0.9 0.9 0 0 1 0.9 0 Q0.45 -0.2 0 0 Q-0.45 -0.2 -0.9 0 Z', '#D62828').replace('<path', '<path transform="translate(0 -0.15)"') + cizgiS('M0 -0.15 L0 0.7 Q0 0.92 -0.25 0.92', K, 0.09),
  sun: () => [0, 45, 90, 135, 180, 225, 270, 315].map((a) => cizgiS(`M${(0.62 * Math.cos(a * Math.PI / 180)).toFixed(3)} ${(0.62 * Math.sin(a * Math.PI / 180)).toFixed(3)} L${(0.95 * Math.cos(a * Math.PI / 180)).toFixed(3)} ${(0.95 * Math.sin(a * Math.PI / 180)).toFixed(3)}`, '#E69F00', 0.12)).join('') + daire(0, 0, 0.45, '#F2C500'),
  cloud: () => bulut('#E5EEF7', 'translate(0 0.1)'),
  rain: () => bulut('#C5D0DC', 'translate(0 -0.3) scale(0.95)') + [-0.45, 0, 0.45].map((x) => cizgiS(`M${x} 0.3 L${x - 0.12} 0.7`, '#0072B2', 0.11)).join(''),
  snow: () => bulut('#E5EEF7', 'translate(0 -0.3) scale(0.95)') + [-0.45, 0, 0.45].map((x) => [0, 60, 120].map((a) => cizgiS(`M${(x + 0.12 * Math.cos(a * Math.PI / 180)).toFixed(3)} ${(0.62 + 0.12 * Math.sin(a * Math.PI / 180)).toFixed(3)} L${(x - 0.12 * Math.cos(a * Math.PI / 180)).toFixed(3)} ${(0.62 - 0.12 * Math.sin(a * Math.PI / 180)).toFixed(3)}`, '#2B7FB8', 0.07)).join('')).join(''),
  wind: () => cizgiS('M-0.9 -0.3 H0.35 Q0.8 -0.3 0.8 -0.65 Q0.8 -0.9 0.5 -0.9', '#6B7280', 0.11) + cizgiS('M-0.9 0.05 H0.65 Q1.0 0.05 1.0 0.35 Q1.0 0.6 0.7 0.6', '#6B7280', 0.11) + cizgiS('M-0.9 0.4 H-0.1 Q0.25 0.4 0.25 0.7 Q0.25 0.95 0 0.95', '#6B7280', 0.11),
  storm: () => bulut('#8B95A3', 'translate(0 -0.35) scale(0.95)') + yol('M0.12 0.12 L-0.3 0.7 L0 0.66 L-0.12 1.0 L0.38 0.38 L0.08 0.42 Z', '#F2C500', 0.05),
  chair: () => dik(-0.45, -0.92, 0.9, 0.72, '#C48A4A', 0.05) + dik(-0.55, -0.2, 1.1, 0.25, '#C48A4A', 0.05) + dik(-0.5, 0.05, 0.13, 0.85, '#8B5A2B', 0.02) + dik(0.37, 0.05, 0.13, 0.85, '#8B5A2B', 0.02),
  table: () => dik(-0.92, -0.4, 1.84, 0.22, '#C48A4A', 0.04) + dik(-0.8, -0.18, 0.15, 1.05, '#8B5A2B', 0.02) + dik(0.65, -0.18, 0.15, 1.05, '#8B5A2B', 0.02),
  bed: () => dik(-0.95, -0.55, 0.14, 1.4, '#8B5A2B', 0.03) + dik(0.8, -0.2, 0.14, 1.05, '#8B5A2B', 0.03) + dik(-0.85, 0.05, 1.65, 0.4, '#56B4E9', 0.06) + dik(-0.8, -0.2, 0.5, 0.25, '#FFFFFF', 0.1) + dik(-0.85, 0.45, 1.65, 0.12, '#9CA3AF', 0.03),
  sofa: () => dik(-0.78, -0.6, 1.56, 0.65, '#CC79A7', 0.2) + dik(-0.92, -0.05, 1.84, 0.55, '#B35E8E', 0.15) + dik(-0.97, -0.25, 0.28, 0.75, '#CC79A7', 0.13) + dik(0.69, -0.25, 0.28, 0.75, '#CC79A7', 0.13) + dik(-0.8, 0.5, 0.12, 0.3, '#8B5A2B', 0.02) + dik(0.68, 0.5, 0.12, 0.3, '#8B5A2B', 0.02),
  lamp: () => yol('M-0.55 -0.05 L0.55 -0.05 L0.32 -0.82 L-0.32 -0.82 Z', '#F2C500') + cizgiS('M0 -0.05 L0 0.75', K, 0.09) + dik(-0.38, 0.75, 0.76, 0.17, '#6B7280', 0.06),
  tv: () => cizgiS('M-0.2 -0.62 L-0.45 -0.95', K, 0.07) + cizgiS('M0.2 -0.62 L0.45 -0.95', K, 0.07) + dik(-0.92, -0.62, 1.84, 1.15, '#2F3A4A', 0.1) + dik(-0.78, -0.48, 1.4, 0.87, '#9CC4E4', 0.05, 0.04) + yol('M-0.35 0.92 L0.35 0.92 L0.2 0.53 L-0.2 0.53 Z', '#6B7280', 0.06),
  cup: () => dik(-0.55, -0.45, 1.0, 1.0, '#FFFFFF', 0.12) + yol('M0.45 -0.2 Q0.98 -0.2 0.98 0.1 Q0.98 0.4 0.45 0.35', 'none') + dik(-0.55, -0.1, 1.0, 0.25, '#56B4E9', 0, 0.04),
  fish: () => yol('M-0.15 -0.38 Q0.5 -0.4 0.6 0 Q0.5 0.4 -0.15 0.38 Q-0.7 0.3 -0.85 0 Q-0.7 -0.3 -0.15 -0.38 Z', '#F28C1B').replace('M-0.15 -0.38 Q0.5 -0.4 0.6 0 Q0.5 0.4 -0.15 0.38 Q-0.7 0.3 -0.85 0 Q-0.7 -0.3 -0.15 -0.38 Z', 'M-0.2 -0.38 Q-0.8 -0.3 -0.9 0 Q-0.8 0.3 -0.2 0.38 Q0.4 0.4 0.55 0 Q0.4 -0.4 -0.2 -0.38 Z') + yol('M0.5 0 L0.95 -0.4 L0.95 0.4 Z', '#E69F00') + daire(-0.55, -0.08, 0.06, K, 0.02),
};
export const IKON_ADLARI = Object.keys(IKON);

export function ikonCiz(s, ad, cx, cy, b) {
  const f = IKON[ad] ?? hata(`ikon_yok:${ad}`);
  ham(s, `<g transform="translate(${Math.round(cx * 100) / 100} ${Math.round(cy * 100) / 100}) scale(${b})">${f()}</g>`, [[cx - b, cy - b], [cx + b, cy + b]]);
}

// ---------- ortak yardımcılar (şablonlar için) ----------
// Doğru sayının 3 çeldiricisi: doğru sayının sıralamadaki yeri düzgün dağılır (ortadaki seçeneği seçme eğilimi yok).
export function sayiCeldirici(R, dogru, { min = 0, max = 99, yayilim = 3 } = {}) {
  const alt = [], ust = [];
  for (let d = 1; d <= yayilim; d++) { if (dogru - d >= min) alt.push(dogru - d); if (dogru + d <= max) ust.push(dogru + d); }
  const lo = Math.max(0, 3 - ust.length), hi = Math.min(3, alt.length);
  if (lo > hi) hata('sayi_cesitliligi_yok');
  const k = lo + Math.floor(R() * (hi - lo + 1));
  const al = (a, n) => { const c = [...a]; for (let i = c.length - 1; i > 0; i--) { const j = Math.floor(R() * (i + 1)); [c[i], c[j]] = [c[j], c[i]]; } return c.slice(0, n); };
  return [...al(alt, k), ...al(ust, 3 - k)];
}
export const SAYI_SOZ = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen', 'twenty'];
const ONLAR = { 20: 'twenty', 30: 'thirty', 40: 'forty', 50: 'fifty', 60: 'sixty', 70: 'seventy', 80: 'eighty', 90: 'ninety' };
export function sayiYazi(n) {
  if (n <= 20) return SAYI_SOZ[n];
  if (n < 100) return n % 10 === 0 ? ONLAR[n] : `${ONLAR[n - (n % 10)]}-${SAYI_SOZ[n % 10]}`;
  const y = Math.floor(n / 100), k = n % 100;
  return `${SAYI_SOZ[y]} hundred${k ? ` and ${sayiYazi(k)}` : ''}`;
}
const SIRA_ISTISNA = { 1: 'first', 2: 'second', 3: 'third', 5: 'fifth', 8: 'eighth', 9: 'ninth', 12: 'twelfth' };
export function siraYazi(n) {
  if (SIRA_ISTISNA[n]) return SIRA_ISTISNA[n];
  if (n < 20) return `${SAYI_SOZ[n]}th`;
  if (n % 10 === 0) return `${ONLAR[n].replace(/y$/, 'ie')}th`;
  return `${ONLAR[n - (n % 10)]}-${siraYazi(n % 10)}`;
}
export const GUNLER = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
export const AYLAR = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
export const ERKEK = ['Tom', 'Ben', 'Sam', 'Max', 'Jack', 'Leo', 'Ali', 'Can', 'Mert', 'Efe', 'Alp', 'Kerem'];
export const KIZ = ['Anna', 'Mia', 'Lily', 'Emma', 'Zoe', 'Eva', 'Ece', 'Ela', 'Sara', 'Elif', 'Defne', 'Nil'];
export const siraNo = (n) => `${n}${n % 100 >= 11 && n % 100 <= 13 ? 'th' : ({ 1: 'st', 2: 'nd', 3: 'rd' }[n % 10] ?? 'th')}`;
export const dakikaYaz = (m) => String(m).padStart(2, '0');
// Saat ifadeleri. seviye 1: o'clock + half past; 2: + quarter past/to; 3: + beş dakikalık adımlar.
export function saatSozcuk(h, m) {
  const adi = (x) => SAYI_SOZ[((x - 1) % 12) + 1];
  if (m === 0) return `It's ${adi(h)} o'clock.`;
  if (m === 30) return `It's half past ${adi(h)}.`;
  if (m === 15) return `It's quarter past ${adi(h)}.`;
  if (m === 45) return `It's quarter to ${adi(h + 1)}.`;
  if (m < 30) return `It's ${sayiYazi(m)} past ${adi(h)}.`;
  return `It's ${sayiYazi(60 - m)} to ${adi(h + 1)}.`;
}
export const saatRakam = (h, m) => `${h}:${dakikaYaz(m)}`;

// ---------- 1) saat ----------
// parametreler: { saat:1..12, dakika:0..59, tur:'analog'|'dijital' }
function saat(p, profil) {
  const h = p.saat, m = p.dakika;
  if (!(h >= 1 && h <= 12) || !(m >= 0 && m < 60)) hata('saat_aralik_disi');
  const olgular = { saat: h, dakika: m, zaman: saatRakam(h, m) };
  if (p.tur === 'dijital') {
    const s = new Sahne(240, 130, profil);
    s.dikdortgen(16, 16, 208, 98, { dolgu: '#1F2937', renk: '#111827', kalinlik: 3 });
    s.metin(120, 82, saatRakam(h, m), { boyut: 52, kalin: true, renk: '#FFFFFF' });
    return { sahne: s, alt: 'Dijital bir saat bir zamanı gösteriyor.', olgular };
  }
  const W = 240, cx = 120, cy = 120, R = 108, s = new Sahne(W, W, profil);
  s.cember(cx, cy, R, { dolgu: '#FFFFFF', kalinlik: 3.5 });
  for (let i = 0; i < 60; i++) {
    const a = (i * 6 * Math.PI) / 180, u = i % 5 === 0 ? 11 : 5;
    s.cizgi(cx + (R - 4) * Math.sin(a), cy - (R - 4) * Math.cos(a), cx + (R - 4 - u) * Math.sin(a), cy - (R - 4 - u) * Math.cos(a), { kalinlik: i % 5 === 0 ? 2 : 1, izgara: true });
  }
  for (let n = 1; n <= 12; n++) {
    const a = (n * 30 * Math.PI) / 180, r = R * 0.74;
    s.metin(cx + r * Math.sin(a), cy - r * Math.cos(a) + profil.yazi * 0.36, String(n), { kalin: true });
  }
  const ha = ((h % 12) * 30 + m * 0.5) * Math.PI / 180, ma = m * 6 * Math.PI / 180;
  s.cizgi(cx, cy, cx + R * 0.38 * Math.sin(ha), cy - R * 0.38 * Math.cos(ha), { kalinlik: 7.5 });
  s.cizgi(cx, cy, cx + R * 0.58 * Math.sin(ma), cy - R * 0.58 * Math.cos(ma), { kalinlik: 4, renk: PALET.mavi });
  s.nokta(cx, cy, { r: 5.5 });
  return { sahne: s, alt: 'Akrep ve yelkovanı olan, 1’den 12’ye sayılı bir duvar saati.', olgular };
}

// ---------- 2) takvim ----------
// parametreler: { ay: 'March'|null, baslangic:0..6 (1. gün: 0=Pazartesi), gun_sayisi:28..31, isaretler:[{gun, sekil:'daire'|'kare', etiket}] }
const GUN3 = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
function takvim(p, profil) {
  const n = p.gun_sayisi, b0 = p.baslangic;
  if (!(n >= 28 && n <= 31) || !(b0 >= 0 && b0 <= 6)) hata('takvim_parametre');
  const cw = 42, ch = 33, m = 14, W = 7 * cw + 2 * m, satir = Math.ceil((b0 + n) / 7), yb = p.ay ? 48 : 14;
  const etiketler = [...new Set((p.isaretler ?? []).map((i) => i.etiket))];
  const H = yb + 30 + satir * ch + (etiketler.length ? 14 + etiketler.length * 28 : 8);
  const s = new Sahne(W, H, profil), bo = Math.min(profil.yazi, 16);
  if (p.ay) s.metin(W / 2, 30, p.ay, { boyut: bo + 3, kalin: true });
  GUN3.forEach((g, i) => {
    s.dikdortgen(m + i * cw, yb, cw, 30, { dolgu: '#E5E7EB', renk: PALET.gri, kalinlik: 0.8 });
    s.metin(m + i * cw + cw / 2, yb + 21, g, { boyut: bo - 1, kalin: true });
  });
  const hafta = {}, isr = {};
  for (let d = 1; d <= n; d++) {
    const k = b0 + d - 1, c = k % 7, r = Math.floor(k / 7), x = m + c * cw, y = yb + 30 + r * ch;
    s.dikdortgen(x, y, cw, ch, { renk: PALET.gri, kalinlik: 0.8 });
    s.metin(x + cw / 2, y + ch / 2 + bo * 0.36, String(d), { boyut: bo });
    hafta[d] = GUNLER[c];
  }
  const RENK = { daire: PALET.kirmizi, kare: PALET.mavi };
  for (const i of p.isaretler ?? []) {
    if (!(i.gun >= 1 && i.gun <= n)) hata('isaret_gun_disi');
    const k = b0 + i.gun - 1, x = m + (k % 7) * cw + cw / 2, y = yb + 30 + Math.floor(k / 7) * ch + ch / 2;
    if (i.sekil === 'daire') s.cember(x, y, 14.5, { renk: RENK.daire, kalinlik: 2.6 });
    else s.dikdortgen(x - 14, y - 13, 28, 26, { renk: RENK.kare, kalinlik: 2.6 });
    isr[i.etiket] = { gun: i.gun, hafta_gunu: hafta[i.gun] };
  }
  etiketler.forEach((e, j) => {
    const sek = p.isaretler.find((i) => i.etiket === e).sekil, y = yb + 30 + satir * ch + 28 + j * 28;
    if (sek === 'daire') s.cember(m + 14, y - 5, 10, { renk: RENK.daire, kalinlik: 2.4 });
    else s.dikdortgen(m + 4, y - 15, 20, 20, { renk: RENK.kare, kalinlik: 2.4 });
    s.metin(m + 36, y, e, { hiza: 'start', boyut: bo });
  });
  return { sahne: s, alt: `${p.ay ? 'Aylık bir takvim; ' : 'Bir takvim; '}haftanın günleri üstte, tarihler altta sıralı; bazı günler işaretli.`, olgular: { ay: p.ay ?? null, hafta_gunu: hafta, isaret: isr, gun_sayisi: n } };
}

// ---------- 3) tablo ----------
// parametreler: { baslik?, ilkSutun?, sutunlar:[str], satirlar:[{ad, hucreler:[str | {ikon} | {tik:bool}]}] }
function tablo(p, profil) {
  const bo = profil.yazi, gen = (t) => String(t).length * bo * 0.6;
  const nS = p.sutunlar.length; if (nS < 1 || nS > 7) hata('sutun_sayisi');
  if (p.satirlar.length < 2 || p.satirlar.length > 8) hata('satir_sayisi');
  const m = 10, sw = [Math.max(gen(p.ilkSutun ?? ''), ...p.satirlar.map((r) => gen(r.ad))) + 22];
  for (let j = 0; j < nS; j++) {
    let w = gen(p.sutunlar[j]) + 18;
    for (const r of p.satirlar) { const c = r.hucreler[j]; w = Math.max(w, typeof c === 'string' ? gen(c) + 18 : (p.hucreGenislik ?? 46)); }
    sw.push(w);
  }
  const W = Math.ceil(sw.reduce((t, x) => t + x, 0) + 2 * m), yb = p.baslik ? 42 : 12, hh = 36, rh = 40;
  const H = yb + hh + p.satirlar.length * rh + 12, s = new Sahne(W, H, profil);
  if ((bo * 360) / W < profil.minYaziPx + 0.3) hata('tablo_cok_genis');
  if (p.baslik) s.metin(W / 2, 28, p.baslik, { kalin: true, boyut: bo + 2 });
  const xs = [m]; sw.forEach((w) => xs.push(xs[xs.length - 1] + w));
  const hucreOlgu = {};
  s.dikdortgen(xs[0], yb, sw[0], hh, { dolgu: '#E5E7EB', renk: PALET.gri, kalinlik: 0.9 });
  if (p.ilkSutun) s.metin(xs[0] + sw[0] / 2, yb + hh / 2 + bo * 0.36, p.ilkSutun, { kalin: true });
  p.sutunlar.forEach((c, j) => { s.dikdortgen(xs[j + 1], yb, sw[j + 1], hh, { dolgu: '#E5E7EB', renk: PALET.gri, kalinlik: 0.9 }); s.metin(xs[j + 1] + sw[j + 1] / 2, yb + hh / 2 + bo * 0.36, c, { kalin: true }); });
  p.satirlar.forEach((r, i) => {
    const y = yb + hh + i * rh, cy = y + rh / 2;
    s.dikdortgen(xs[0], y, sw[0], rh, { dolgu: '#F3F4F6', renk: PALET.gri, kalinlik: 0.9 });
    s.metin(xs[0] + sw[0] / 2, cy + bo * 0.36, r.ad, { kalin: true });
    hucreOlgu[r.ad] = {};
    r.hucreler.forEach((c, j) => {
      const x = xs[j + 1], mx = x + sw[j + 1] / 2;
      s.dikdortgen(x, y, sw[j + 1], rh, { renk: PALET.gri, kalinlik: 0.9 });
      if (typeof c === 'string') { s.metin(mx, cy + bo * 0.36, c); hucreOlgu[r.ad][p.sutunlar[j]] = c; }
      else if (c.ikon) { ikonCiz(s, c.ikon, mx, cy, 15); hucreOlgu[r.ad][p.sutunlar[j]] = `ikon:${c.ikon}`; }
      else {
        const cc = (d) => ham(s, `<g transform="translate(${mx} ${cy}) scale(13)">${d}</g>`, [[mx - 13, cy - 13], [mx + 13, cy + 13]]);
        cc(c.tik ? cizgiS('M-0.7 0.05 L-0.25 0.55 L0.75 -0.55', '#009E73', 0.28) : cizgiS('M-0.55 -0.55 L0.55 0.55 M0.55 -0.55 L-0.55 0.55', '#D55E00', 0.26));
        hucreOlgu[r.ad][p.sutunlar[j]] = c.tik ? 'evet' : 'hayir';
      }
    });
  });
  return { sahne: s, alt: `Satır ve sütunlardan oluşan bir tablo${p.baslik ? `: ${p.baslik}` : ''}. Sütun başlıkları: ${p.sutunlar.join(', ')}.`, olgular: { hucre: hucreOlgu } };
}

// ---------- 4) sayım (dağınık ya da onluk bloklar) ----------
// parametreler: { ogeler:[{ikon, sayi}], tohum, mod:'dagin'|'blok' }
function sayim(p, profil) {
  const toplam = p.ogeler.reduce((t, x) => t + x.sayi, 0), r = LCG(p.tohum ?? 1);
  const blok = p.mod === 'blok';
  if (toplam < 1 || toplam > (blok ? 50 : 24)) hata('toplam_aralik_disi');
  const kol = blok ? 10 : 6, hucre = blok ? 30 : 50, b = blok ? 12 : 17, satir = blok ? Math.ceil(toplam / 10) : Math.ceil((toplam + 3) / kol);
  const W = kol * hucre + 20, H = satir * hucre + 20, s = new Sahne(W, H, profil);
  const liste = p.ogeler.flatMap((x) => Array(x.sayi).fill(x.ikon)).sort(() => r() - 0.5);
  const yerler = Array.from({ length: kol * satir }, (_, i) => i);
  if (!blok) yerler.sort(() => r() - 0.5);
  liste.forEach((ik, i) => {
    const h = yerler[i];
    ikonCiz(s, ik, 10 + (h % kol) * hucre + hucre / 2 + (blok ? 0 : (r() - 0.5) * 8), 10 + Math.floor(h / kol) * hucre + hucre / 2 + (blok ? 0 : (r() - 0.5) * 8), b);
  });
  const sayilar = Object.fromEntries(p.ogeler.map((x) => [x.ikon, x.sayi]));
  const sirali = Object.entries(sayilar).sort((a, c) => c[1] - a[1]);
  return { sahne: s, alt: 'Birkaç çeşit resimli nesnenin dağınık durduğu bir görsel.', olgular: { sayilar, toplam, en_cok: sirali.length > 1 && sirali[0][1] === sirali[1][1] ? null : sirali[0][0], en_az: sirali.length > 1 && sirali[sirali.length - 1][1] === sirali[sirali.length - 2][1] ? null : sirali[sirali.length - 1][0] } };
}

// ---------- 5) resimler (A–D kutuları) ----------
// parametreler: { ikonlar:[4 ikon adı] }
function resimler(p, profil) {
  if (p.ikonlar.length !== 4 || new Set(p.ikonlar).size !== 4) hata('dort_farkli_ikon');
  const bw = 88, g = 8, m = 10, W = 4 * bw + 3 * g + 2 * m, H = 138, s = new Sahne(W, H, profil);
  const harf = {}, ters = {};
  p.ikonlar.forEach((ik, i) => {
    const x = m + i * (bw + g);
    s.dikdortgen(x, 40, bw, 88, { renk: PALET.siyah, kalinlik: 1.8 });
    s.metin(x + bw / 2, 28, 'ABCD'[i], { kalin: true, boyut: profil.yazi + 2 });
    ikonCiz(s, ik, x + bw / 2, 84, 32);
    harf['ABCD'[i]] = ik; ters[ik] = 'ABCD'[i];
  });
  return { sahne: s, alt: 'A, B, C ve D harfli dört kutuda dört farklı resim var.', olgular: { harf, ters } };
}

// ---------- 6) bölmeler (oda / okul yeri) ----------
// parametreler: { en:2|3, boy:1|2, bolmeler:[{ad, ikon}] }
function bolmeler(p, profil) {
  const cw = p.en === 3 ? 128 : 150, ch = 112, m = 10, W = p.en * cw + 2 * m, H = p.boy * ch + 2 * m, s = new Sahne(W, H, profil);
  if (p.bolmeler.length !== p.en * p.boy) hata('bolme_sayisi');
  const nerede = {}, icinde = {};
  p.bolmeler.forEach((b, i) => {
    const x = m + (i % p.en) * cw, y = m + Math.floor(i / p.en) * ch;
    s.dikdortgen(x, y, cw, ch, { dolgu: i % 2 ? '#FDF6E3' : '#F1F7FD', renk: PALET.siyah, kalinlik: 2 });
    s.metin(x + cw / 2, y + 27, b.ad, { kalin: true });
    ikonCiz(s, b.ikon, x + cw / 2, y + 72, 25);
    nerede[b.ikon] = b.ad; icinde[b.ad] = b.ikon;
  });
  return { sahne: s, alt: 'Adları yazılı bölmelere ayrılmış bir plan; her bölmede bir nesne var.', olgular: { nerede, icinde } };
}

// ---------- 7) sokak (karşısında / yanında / arasında) ----------
// parametreler: { ust:[ad|null,…], alt:[ad|null,…] }  (iki sıra aynı uzunlukta; karşılıklı hücre = karşısı)
const BINA_RENK = ['#FDE2E4', '#E2F0CB', '#D6E4FF', '#FFF1C1', '#E8DAEF', '#D5F5E3'];
function sokak(p, profil) {
  const n = p.ust.length; if (n < 3 || n > 4 || p.alt.length !== n) hata('sokak_uzunluk');
  const bw = 84, g = 6, m = 8, W = n * (bw + g) - g + 2 * m, H = 232, s = new Sahne(W, H, profil), bo = profil.yazi;
  const maxHarf = Math.floor((bw - 8) / (bo * 0.6));
  s.dikdortgen(0, 92, W, 34, { dolgu: '#D1D5DB', renk: '#D1D5DB', kalinlik: 0.5 });
  s.cizgi(6, 109, W - 6, 109, { renk: '#FFFFFF', kalinlik: 2.5, kesik: true, izgara: true });
  const olgular = { karsi: {}, yan: {}, arasi: {} };
  const bina = (ad, x, y, i, ust) => {
    if (ad === null) { ikonCiz(s, 'tree', x + bw / 2, y + 40, 26); return; }
    if (ad.length > maxHarf) hata(`ad_uzun:${ad}`);
    s.poligon([[x - 2, y + 2], [x + bw / 2, y - 16], [x + bw + 2, y + 2]], { dolgu: '#B45309', renk: PALET.siyah, kalinlik: 1.5 });
    s.dikdortgen(x, y, bw, 62, { dolgu: BINA_RENK[i % BINA_RENK.length], renk: PALET.siyah, kalinlik: 1.8 });
    s.metin(x + bw / 2, y + 36 + bo * 0.3, ad, { kalin: true });
  };
  p.ust.forEach((ad, i) => bina(ad, m + i * (bw + g), 22, i, true));
  p.alt.forEach((ad, i) => bina(ad, m + i * (bw + g), 148, i + 2, false));
  const sirala = (a) => a.forEach((ad, i) => {
    if (ad === null) return;
    const kom = [a[i - 1], a[i + 1]].filter((x) => x), t = (a === p.ust ? p.alt : p.ust)[i];
    olgular.yan[ad] = kom;
    if (t) olgular.karsi[ad] = t;
    if (i > 0 && i < n - 1 && a[i - 1] && a[i + 1]) olgular.arasi[ad] = [a[i - 1], a[i + 1]];
  });
  sirala(p.ust); sirala(p.alt);
  return { sahne: s, alt: 'İki sıra bina arasından geçen bir yol; binaların adları üzerlerinde yazılı.', olgular };
}

// ---------- 8) konum (üstünde / altında / içinde) ----------
// parametreler: { nesneler:[{ikon, yer:'masa_ustu'|'masa_alti'|'sandalye_ustu'|'sandalye_alti'|'kutu_ici'|'kutu_ustu'}] }
function konum(p, profil) {
  const W = 340, H = 168, y0 = 156, s = new Sahne(W, H, profil), b = 15;
  s.cizgi(8, y0, W - 8, y0, { kalinlik: 2.2, izgara: true });
  const sandY = 106, masaY = 90, kutuY = 114;
  const yerlestir = { sandalye_ustu: [44, sandY - b - 2], sandalye_alti: [44, y0 - b - 2], masa_ustu: [150, masaY - b - 2], masa_alti: [150, y0 - b - 2], kutu_ici: [284, kutuY - 9], kutu_ustu: [284, kutuY - b - 4] };
  const secili = new Set(p.nesneler.map((n) => n.yer));
  // nesneler önce çizilir (kutu_ici kutunun ön yüzü ile örtülür)
  const olgular = { yer: {} };
  for (const n of p.nesneler) {
    if (!yerlestir[n.yer]) hata(`yer_bilinmiyor:${n.yer}`);
    ikonCiz(s, n.ikon, yerlestir[n.yer][0], yerlestir[n.yer][1], b);
    olgular.yer[n.ikon] = n.yer;
  }
  if (secili.size !== p.nesneler.length) hata('yer_cakisma');
  ham(s, `<g stroke="${K}" stroke-width="2" stroke-linejoin="round">` +
    `<rect x="22" y="${sandY - 2}" width="44" height="9" fill="#C48A4A"/><rect x="24" y="${sandY + 7}" width="6" height="${y0 - sandY - 7}" fill="#8B5A2B"/><rect x="58" y="${sandY + 7}" width="6" height="${y0 - sandY - 7}" fill="#8B5A2B"/><rect x="22" y="${sandY - 56}" width="7" height="56" fill="#C48A4A"/>` +
    `<rect x="100" y="${masaY}" width="100" height="10" fill="#C48A4A"/><rect x="106" y="${masaY + 10}" width="8" height="${y0 - masaY - 10}" fill="#8B5A2B"/><rect x="186" y="${masaY + 10}" width="8" height="${y0 - masaY - 10}" fill="#8B5A2B"/>` +
    `<rect x="248" y="${kutuY}" width="72" height="${y0 - kutuY}" fill="#D9A441"/><rect x="248" y="${kutuY}" width="72" height="9" fill="#B9822C"/></g>`,
  [[22, sandY - 56], [66, y0], [100, masaY], [200, y0], [248, kutuY], [320, y0]]);
  return { sahne: s, alt: 'Bir sandalye, bir masa ve bir kutu bulunan bir sahne; bazı nesneler bunların üstünde, altında ya da içinde duruyor.', olgular };
}

// ---------- 9) aile ağacı ----------
// parametreler: { ad:{buyukbaba, buyukanne, teyze, amca, baba, anne, erkek_kardes, kiz_kardes} } (teyze/amca: babanın kardeşleri → aunt/uncle)
function aile(p, profil) {
  const A = p.ad, W = 364, H = 232, bw = 76, bh = 34, s = new Sahne(W, H, profil), bo = Math.min(profil.yazi, 15);
  const roller = ['buyukbaba', 'buyukanne', 'teyze', 'amca', 'baba', 'anne', 'erkek_kardes', 'kiz_kardes'];
  if (roller.some((r) => !A[r]) || new Set(roller.map((r) => A[r])).size !== 8) hata('aile_adlari');
  const pos = { buyukbaba: [62, 14], buyukanne: [212, 14], teyze: [50, 100], amca: [135, 100], baba: [220, 100], anne: [314, 100], erkek_kardes: [224, 186], kiz_kardes: [310, 186] };
  const kutu = (r) => {
    const [cx, y] = pos[r], erkek = ['buyukbaba', 'amca', 'baba', 'erkek_kardes'].includes(r);
    s.dikdortgen(cx - bw / 2, y, bw, bh, { dolgu: erkek ? '#DCEBFA' : '#FBE3EE', renk: PALET.siyah, kalinlik: 1.8 });
    s.metin(cx, y + bh / 2 + bo * 0.36, A[r], { kalin: true, boyut: bo });
  };
  const L = (x1, y1, x2, y2) => s.cizgi(x1, y1, x2, y2, { kalinlik: 2, izgara: true });
  L(62 + bw / 2, 31, 212 - bw / 2, 31);            // büyükanne-büyükbaba
  L(137, 31, 137, 68); L(50, 68, 220, 68); L(50, 68, 50, 100); L(135, 68, 135, 100); L(220, 68, 220, 100); // kardeşler
  L(220 + bw / 2, 117, 314 - bw / 2, 117);         // baba-anne
  L(267, 117, 267, 150); L(224, 150, 310, 150); L(224, 150, 224, 186); L(310, 150, 310, 186); // çocuklar
  roller.forEach(kutu);
  const gen = (r) => (['buyukbaba', 'amca', 'baba', 'erkek_kardes'].includes(r) ? 'erkek' : 'kiz');
  return { sahne: s, alt: 'Üç kuşaklı bir aile ağacı; kişilerin adları kutuların içinde yazılı.', olgular: { rol: Object.fromEntries(roller.map((r) => [A[r], r])), cinsiyet: Object.fromEntries(roller.map((r) => [A[r], gen(r)])) } };
}

// ---------- 10) doğum günü pastası ----------
// parametreler: { ad, mum:1..12 }
function pasta(p, profil) {
  const n = p.mum; if (!(n >= 1 && n <= 12)) hata('mum_aralik');
  const W = 300, H = 244, s = new Sahne(W, H, profil), bo = profil.yazi;
  s.dikdortgen(24, 206, 252, 10, { dolgu: '#D1D5DB', renk: PALET.siyah, kalinlik: 1.5 });
  s.dikdortgen(52, 156, 196, 50, { dolgu: '#F4A6C0', renk: PALET.siyah, kalinlik: 2 });
  s.dikdortgen(68, 112, 164, 44, { dolgu: '#FFF2D6', renk: PALET.siyah, kalinlik: 2 });
  ham(s, `<path d="M68 112 Q80 134 92 112 Q104 134 116 112 Q128 134 140 112 Q152 134 164 112 Q176 134 188 112 Q200 134 212 112 Q224 134 232 112" fill="none" stroke="${K}" stroke-width="2"/>`, [[68, 112], [232, 134]]);
  const x0 = 78, x1 = 222, ds = n === 1 ? 0 : (x1 - x0) / (n - 1), renk = ['#3B82F6', '#F2C500', '#D62828'];
  for (let i = 0; i < n; i++) {
    const x = n === 1 ? 150 : x0 + i * ds;
    s.dikdortgen(x - 3.5, 80, 7, 32, { dolgu: renk[i % 3], renk: PALET.siyah, kalinlik: 1 });
    ham(s, `<path d="M${x} 62 Q${x + 6} 72 ${x} 79 Q${x - 6} 72 ${x} 62 Z" fill="#F28C1B" stroke="${K}" stroke-width="1"/>`, [[x - 6, 62], [x + 6, 79]]);
  }
  s.metin(W / 2, 236, `Happy Birthday, ${p.ad}!`, { kalin: true, boyut: bo });
  return { sahne: s, alt: 'Üzerinde mumlar bulunan bir doğum günü pastası.', olgular: { mum: n, ad: p.ad } };
}

// ---------- 11) zaman çizgisi ----------
// parametreler: { olaylar:[{yil, etiket:[satir1, satir2]}] }  (4–5 olay, yıllar artan; aralıklar eşit çizilir)
function zaman(p, profil) {
  const n = p.olaylar.length; if (n < 4 || n > 5) hata('olay_sayisi_4_5');
  const W = 388, H = 150, m = 44, y0 = 98, s = new Sahne(W, H, profil), bo = profil.yazi;
  const dx = (W - 2 * m) / (n - 1), maxHarf = Math.floor((dx - 6) / (bo * 0.6));
  for (let i = 1; i < n; i++) if (p.olaylar[i].yil <= p.olaylar[i - 1].yil) hata('yillar_artan_degil');
  s.cizgi(14, y0, W - 14, y0, { kalinlik: 3, ok: true });
  const yil = {}, sira = [];
  p.olaylar.forEach((o, i) => {
    const x = m + i * dx;
    if (o.etiket.some((e) => e.length > maxHarf)) hata(`etiket_uzun:${o.etiket.join(' ')}`);
    s.cizgi(x, y0 - 12, x, y0 + 12, { kalinlik: 2.4, izgara: true });
    s.nokta(x, y0, { r: 5.5, renk: PALET.mavi });
    s.metin(x, 38, o.etiket[0], { boyut: bo });
    s.metin(x, 38 + bo + 3, o.etiket[1], { boyut: bo });
    s.cizgi(x, 38 + bo + 12, x, y0 - 12, { kalinlik: 1, renk: PALET.gri, izgara: true });
    s.metin(x, y0 + 36, String(o.yil), { kalin: true, boyut: bo + 1 });
    yil[o.etiket.join(' ')] = o.yil; sira.push(o.etiket.join(' '));
  });
  return { sahne: s, alt: 'Yatay bir zaman çizgisi; olaylar kısa yazılarla, yıllar çizginin altında gösterilmiş.', olgular: { yil, sira } };
}

export const TIPLER_A8 = {
  'a8-zaman': zaman,
  'a8-saat': saat,
  'a8-takvim': takvim,
  'a8-tablo': tablo,
  'a8-sayim': sayim,
  'a8-resimler': resimler,
  'a8-bolmeler': bolmeler,
  'a8-sokak': sokak,
  'a8-konum': konum,
  'a8-aile': aile,
  'a8-pasta': pasta,
};
void aciRad;
