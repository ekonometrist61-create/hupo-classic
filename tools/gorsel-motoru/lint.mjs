// Görsel lint: sahneyi deterministik denetler (sınır, yazı çakışması, okunurluk, boyut, renk bütçesi, renk körlüğü).
// Her bulgu: { kural, ciddiyet:'hata'|'uyari', mesaj }. 'hata' varsa görsel RED.
const MAX_SVG_BAYT = 30000;
const EKRAN_GENISLIK_PX = 360; // en dar hedef

const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
const dogrusal = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
// Machado 2009, şiddet 1.0 (doğrusal RGB)
const CVD = {
  protan: [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
  deutan: [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]],
  tritan: [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]],
};
function lab(rgbDogrusal) {
  const [r, g, b] = rgbDogrusal.map((v) => Math.min(1, Math.max(0, v)));
  const X = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047, Y = 0.2126 * r + 0.7152 * g + 0.0722 * b, Z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  const f = (t) => (t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116);
  return [116 * f(Y) - 16, 500 * (f(X) - f(Y)), 200 * (f(Y) - f(Z))];
}
const deltaE = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1], a[2] - b[2]);
function simule(h, m) {
  const d = hex(h).map(dogrusal);
  return lab(m.map((satir) => satir[0] * d[0] + satir[1] * d[1] + satir[2] * d[2]));
}
export function renkAyirt(h1, h2) {
  const sonuc = { normal: deltaE(simule(h1, [[1, 0, 0], [0, 1, 0], [0, 0, 1]]), simule(h2, [[1, 0, 0], [0, 1, 0], [0, 0, 1]])) };
  for (const [ad, m] of Object.entries(CVD)) sonuc[ad] = deltaE(simule(h1, m), simule(h2, m));
  return sonuc;
}

export function gorselLint(sahne, svgMetni) {
  const bulgu = [];
  const ekle = (kural, ciddiyet, mesaj) => bulgu.push({ kural, ciddiyet, mesaj });

  for (const [x, y, pay] of sahne.noktalar) {
    if (x - pay < -0.5 || y - pay < -0.5 || x + pay > sahne.w + 0.5 || y + pay > sahne.h + 0.5) { ekle('sinir_disi', 'hata', `(${Math.round(x)},${Math.round(y)}) tuval dışında`); break; }
  }
  const k = sahne.metinKutulari;
  for (const t of k) {
    if (t.x0 < 0 || t.y0 < 0 || t.x1 > sahne.w || t.y1 > sahne.h) ekle('yazi_sinir_disi', 'hata', `"${t.metin}" tuval dışında`);
    const px = t.boyut * (EKRAN_GENISLIK_PX / sahne.w);
    if (px < sahne.profil.minYaziPx) ekle('yazi_kucuk', 'hata', `"${t.metin}" ${px.toFixed(1)}px < ${sahne.profil.minYaziPx}px`);
  }
  for (let i = 0; i < k.length; i++) for (let j = i + 1; j < k.length; j++) {
    const a = k[i], b = k[j];
    if (a.x0 < b.x1 && b.x0 < a.x1 && a.y0 < b.y1 && b.y0 < a.y1) ekle('yazi_cakisma', 'hata', `"${a.metin}" ile "${b.metin}" çakışıyor`);
  }
  for (const t of k) for (const c of sahne.cizgiler) {
    if (sahne.constructor.kutuCizgiKesisir(t, c, 0)) { ekle('yazi_cizgi_cakisma', 'hata', `"${t.metin}" bir çizginin üstüne biniyor`); break; }
  }
  const bayt = Buffer.byteLength(svgMetni, 'utf8');
  if (bayt > MAX_SVG_BAYT) ekle('svg_buyuk', 'hata', `${bayt} bayt > ${MAX_SVG_BAYT}`);
  const anlamsal = Object.keys(sahne.anlamRenkleri);
  if (anlamsal.length > sahne.profil.maxRenk) ekle('renk_butcesi', 'hata', `${anlamsal.length} anlamlı renk > ${sahne.profil.maxRenk}`);
  for (const [renk, etiket] of Object.entries(sahne.anlamRenkleri)) if (!etiket) ekle('renk_etiketsiz', 'hata', `${renk} etiketsiz (renk tek başına taşıyıcı olamaz)`);
  for (const renk of anlamsal.filter((r) => !sahne.koyuZeminRenkleri.has(r))) {
    const Y = (() => { const d = hex(renk).map(dogrusal); return 0.2126 * d[0] + 0.7152 * d[1] + 0.0722 * d[2]; })();
    const oran = 1.05 / (Y + 0.05); // beyaz zemin
    if (oran < 3) ekle('renk_kontrast', 'hata', `${renk} beyaz zeminde kontrast ${oran.toFixed(1)}:1 < 3:1`);
  }
  for (let i = 0; i < anlamsal.length; i++) for (let j = i + 1; j < anlamsal.length; j++) {
    const s = renkAyirt(anlamsal[i], anlamsal[j]);
    for (const [mod, de] of Object.entries(s)) if (de < 20) ekle('renk_ayirt_edilemez', 'hata', `${anlamsal[i]} / ${anlamsal[j]} (${mod}) ΔE=${de.toFixed(1)}`);
  }
  return bulgu;
}
