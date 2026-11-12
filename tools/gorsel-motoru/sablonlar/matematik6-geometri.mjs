// 6. sınıf Matematik — paralel doğrular ve kesen (MAT.6.3.1, iki şablon), paralelkenar/üçgen alanı (MAT.6.4.2), çember uzunluğu (MAT.6.4.5).
// Şekil tipleri: b1-paralel-kesen, b1-alan, b1-cember (tipler-b1.mjs).
const MUFREDAT = '2026 Maarif Modeli Matematik (5-8) DÖP, 6. sınıf bölümü';
const TERIM = { yondes: 'Yöndeş açılar', ic_ters: 'İç ters açılar', dis_ters: 'Dış ters açılar', ters: 'Ters açılar' };
const TERIM_LISTE = Object.values(TERIM);
const TIP_A = [1, 4, 5, 8]; // ölçüsü psi olan konumlar; diğerleri 180 - psi
const ILISKI = {};
for (const [ad, liste] of Object.entries({ yondes: [[1, 5], [2, 6], [3, 7], [4, 8]], ic_ters: [[3, 6], [4, 5]], dis_ters: [[1, 8], [2, 7]], ters: [[1, 4], [2, 3], [5, 8], [6, 7]] })) for (const [a, b] of liste) ILISKI[`${a}-${b}`] = ad;
const AYIRAC = { yondes: 'aynı yönde, farklı kesişim noktalarında ve doğruların aynı tarafında bulunan', ic_ters: 'iki doğrunun arasında kalan ve kesenin zıt yanlarında bulunan', dis_ters: 'iki doğrunun dışında kalan ve kesenin zıt yanlarında bulunan', ters: 'aynı kesişim noktasında karşılıklı bulunan' };

export function kur({ R, sec, karistir, ekle, konum }) {
  const yaz = (v) => `${v}°`;
  // ---------- açı çiftinin adı ----------
  function aciAdi() {
    const psi = sec([50, 55, 60, 65, 70, 75, 80, 85, 95, 100, 105, 110, 115, 120, 125, 130]), anahtar = sec(Object.keys(ILISKI)), [a, b] = anahtar.split('-').map(Number), rel = ILISKI[anahtar];
    const etik = karistir([1, 2, 3, 4, 5, 6, 7, 8]), et = (i) => etik[i - 1], etiketler = Object.fromEntries([1, 2, 3, 4, 5, 6, 7, 8].map((i) => [String(i), String(et(i))]));
    const sirali = [a, b].sort((x, y) => et(x) - et(y)), dogru = TERIM[rel], cel = karistir(TERIM_LISTE.filter((t) => t !== dogru));
    ekle({ kod: 'MAT.6.3.1', konu: 'Geometri', alt_konu: 'Paralel doğrularda açı çiftlerini adlandırma', zorluk: rel === 'ters' ? 1 : 2, dogru, celdirici: cel,
      gerekce: cel.map((c) => `${c}: ${et(a)} ve ${et(b)} numaralı açılar ${AYIRAC[rel]} açılardır; bu çift ${dogru.toLowerCase()} olur.`),
      kok: `Şekilde d ve e doğruları paraleldir, k doğrusu kesendir. ${et(sirali[0])} numaralı açı ile ${et(sirali[1])} numaralı açı hangi açı çiftidir?`,
      ipucu: 'Açıların iki paralel doğrunun arasında mı dışında mı olduğuna ve kesenin hangi yanında bulunduğuna bak.',
      cozum: [`${et(a)} ve ${et(b)} numaralı açıların konumu şekilden incelenir.`, `Bu açılar ${AYIRAC[rel]} açılardır.`, `Bu çift: ${dogru.toLowerCase()}.`],
      spec: { tip_id: 'b1-paralel-kesen', parametreler: { psi, etiketler } }, dogrulama: [{ yol: ['iliski', anahtar], beklenen: rel }] });
  }
  // ---------- bilinmeyen açı ----------
  function aciOlcu() {
    const v = sec([50, 55, 60, 65, 70, 75, 80, 100, 105, 110, 115, 120, 125, 130]);
    const [i, j] = karistir([1, 2, 3, 4, 5, 6, 7, 8]).slice(0, 2), ayni = TIP_A.includes(i) === TIP_A.includes(j);
    const psi = TIP_A.includes(i) ? v : 180 - v;
    if (psi < 50 || psi > 130) throw new Error('psi_disi');
    const dogruDeger = ayni ? v : 180 - v, diger = ayni ? 180 - v : v;
    let u = 0; for (let g = 0; g < 40; g++) { u = sec([40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 95, 100, 105, 110, 115, 120, 125, 130, 135, 140]); if (u !== v && u !== 180 - v) break; }
    if (u === v || u === 180 - v) throw new Error('u_yok');
    const cel = karistir([diger, u, 180 - u]);
    ekle({ kod: 'MAT.6.3.1', konu: 'Geometri', alt_konu: 'Paralel doğrularda bilinmeyen açı', zorluk: 2, dogru: yaz(dogruDeger), celdirici: cel.map(yaz),
      gerekce: cel.map((c) => (c === diger ? (ayni ? `${c}°: Bu iki açı eş (aynı ölçüde) açılardır; toplamları 180° olan çift değildir.` : `${c}°: Bu iki açı bütünler açılardır (toplamları 180°); eşit değildir.`) : `${c}°: Verilen ${v}° açıdan bu sonuca ulaşılmaz.`)),
      kok: 'Şekilde d ve e doğruları paraleldir, k doğrusu kesendir. Buna göre x açısı kaç derecedir?',
      ipucu: 'x ile verilen açının konumuna bak: eş mi, yoksa toplamları 180° mi?',
      cozum: [ayni ? `Verilen açı ile x aynı konumdaki (eş) açılardır.` : `Verilen açı ile x doğrusal çift ya da bütünler açılardır; toplamları 180°’dir.`, ayni ? `x = ${v}°.` : `x = 180° − ${v}° = ${180 - v}°.`],
      spec: { tip_id: 'b1-paralel-kesen', parametreler: { psi, etiketler: { [i]: `${v}°`, [j]: 'x' } } }, dogrulama: [{ yol: ['olcu', String(i)], beklenen: v }, { yol: ['olcu', String(j)], beklenen: dogruDeger }] });
  }

  // ---------- alan ----------
  const H3 = { 3: [[4, 5]], 4: [[3, 5]], 5: [[12, 13]], 6: [[8, 10]], 8: [[6, 10], [15, 17]], 9: [[12, 15]], 12: [[5, 13], [9, 15], [16, 20]], 15: [[8, 17], [20, 25]], 20: [[15, 25]] };
  const cm2 = (v) => `${v} cm²`;
  function adaySec(aday, dogru, n = 3) { const gor = new Set([dogru]), c = []; for (const x of karistir(aday)) { if (Number.isInteger(x.v) && x.v > 0 && !gor.has(x.v)) { gor.add(x.v); c.push(x); } if (c.length === n) break; } if (c.length < n) throw new Error('celdirici_yok'); return c; }
  // Alan şıkları: arada 2 katı/yarısı ilişkisi olmamalı; yoksa doğru şık şıklardan çıkarılabilir.
  function adaySecAlan(aday, dogru, n = 3) { const gor = new Set([dogru]), c = []; for (const x of karistir(aday)) { if (Number.isInteger(x.v) && x.v > 0 && !gor.has(x.v) && ![...gor].some((g) => g === 2 * x.v || 2 * g === x.v)) { gor.add(x.v); c.push(x); } if (c.length === n) break; } if (c.length < n) throw new Error('celdirici_yok'); return c; }
  function alanParalelkenar() {
    const h = sec(Object.keys(H3).map(Number)), [d, yan] = sec(H3[h]), b = d + 1 + Math.floor(R() * 8);
    if (b > 20) throw new Error('b_buyuk');
    const A = b * h, c = adaySecAlan([{ v: b * yan, g: 'Yükseklik yerine yan kenar kullanılmıştır; yükseklik, tabana dik olan uzunluktur.' }, { v: (b * h) / 2, g: 'Üçgenin alan formülü (taban × yükseklik ÷ 2) kullanılmıştır.' }, { v: 2 * (b + yan), g: 'Çevre hesaplanmıştır.' }, { v: b + h, g: 'Taban ile yükseklik toplanmıştır.' }, { v: yan * h, g: 'Yan kenar ile yükseklik çarpılmıştır; taban kullanılmamıştır.' }], A);
    ekle({ kod: 'MAT.6.4.2', konu: 'Ölçme', alt_konu: 'Paralelkenarın alanı', zorluk: 2, dogru: cm2(A), celdirici: c.map((x) => cm2(x.v)), gerekce: c.map((x) => `${x.v} cm²: ${x.g}`),
      kok: sec(['Yukarıda ölçüleri verilen paralelkenarın alanı kaç santimetrekaredir?', 'Şekildeki paralelkenarın alanı kaç santimetrekaredir?']),
      ipucu: 'Alan = taban × tabana ait yükseklik. Yükseklik, tabana dik çizilen kesikli doğrudur.', cozum: [`Taban ${b} cm, taban üzerine inen yükseklik ${h} cm’dir.`, `Alan = ${b} × ${h} = ${A} cm².`],
      spec: { tip_id: 'b1-alan', parametreler: { sekil: 'paralelkenar', b, h, d, yan } }, dogrulama: [{ yol: ['alan'], beklenen: A }] });
  }
  function alanUcgen() {
    const h = sec(Object.keys(H3).map(Number)), [p, s1] = sec(H3[h]), [q, s2] = sec(H3[h]), b = p + q;
    if ((b * h) % 2 || b > 40) throw new Error('alan_tam_degil');
    const A = (b * h) / 2, c = adaySecAlan([{ v: b * h, g: 'Üçgenin alanı için çarpım 2’ye bölünmemiştir.' }, { v: (b * s1) / 2, g: 'Yükseklik yerine yan kenar kullanılmıştır; yükseklik tabana diktir.' }, { v: (b * s2) / 2, g: 'Yükseklik yerine yan kenar kullanılmıştır; yükseklik tabana diktir.' }, { v: b + s1 + s2, g: 'Çevre hesaplanmıştır.' }, { v: (s1 * h) / 2, g: 'Yan kenar ile yükseklik çarpılmıştır; taban kullanılmamıştır.' }], A);
    ekle({ kod: 'MAT.6.4.2', konu: 'Ölçme', alt_konu: 'Üçgenin alanı', zorluk: 3, dogru: cm2(A), celdirici: c.map((x) => cm2(x.v)), gerekce: c.map((x) => `${x.v} cm²: ${x.g}`),
      kok: sec(['Yukarıda ölçüleri verilen üçgenin alanı kaç santimetrekaredir?', 'Şekildeki üçgenin alanı kaç santimetrekaredir?']),
      ipucu: 'Alan = taban × tabana ait yükseklik ÷ 2. Yükseklik, tabana dik olan kesikli doğrudur.', cozum: [`Taban ${b} cm, tabana ait yükseklik ${h} cm’dir.`, `Alan = ${b} × ${h} ÷ 2 = ${A} cm².`],
      spec: { tip_id: 'b1-alan', parametreler: { sekil: 'ucgen', b, h, p, s1, s2 } }, dogrulama: [{ yol: ['alan'], beklenen: A }] });
  }

  // ---------- çember uzunluğu ----------
  function cember() {
    const goster = sec(['yaricap', 'cap']), pi = sec(['3', '3', '22/7']), pv = pi === '3' ? 3 : 22 / 7;
    const v = pi === '3' ? (goster === 'yaricap' ? sec([...Array(23).keys()].map((x) => x + 3)) : sec([...Array(23).keys()].map((x) => 2 * (x + 3)))) : (goster === 'yaricap' ? sec([7, 14, 21, 28, 35]) : sec([14, 28, 42, 56, 70]));
    const r = goster === 'yaricap' ? v : v / 2, C = 2 * pv * r;
    const aday = goster === 'yaricap'
      ? [{ v: pv * v, g: 'Çevre = 2 × π × r olduğundan 2 ile çarpmak unutulmuştur.' }, { v: pv * v * v, g: 'Çemberin alanı (π × r × r) hesaplanmıştır.' }, { v: 4 * pv * v, g: 'Verilen yarıçap çap sanılıp ikiye katlanmıştır, sonra bir kez daha 2 ile çarpılmıştır.' }, { v: 2 * v, g: 'Yalnız çap bulunmuştur; çevre değildir.' }]
      : [{ v: 2 * pv * v, g: 'Verilen uzunluk yarıçap sanılmıştır; şekilde çap gösterilmiştir.' }, { v: pv * r, g: 'Çevre = π × çap olduğundan yarıçap kullanılmıştır.' }, { v: pv * r * r, g: 'Çemberin alanı (π × r × r) hesaplanmıştır.' }, { v: v / 2, g: 'Yalnız yarıçap bulunmuştur; çevre değildir.' }];
    const c = adaySec(aday.map((x) => ({ ...x, v: Math.round(x.v * 1e6) / 1e6 })), C);
    ekle({ kod: 'MAT.6.4.5', konu: 'Ölçme', alt_konu: 'Çemberin uzunluğu', zorluk: goster === 'cap' ? 3 : 2, dogru: `${C} cm`, celdirici: c.map((x) => `${x.v} cm`), gerekce: c.map((x) => `${x.v} cm: ${x.g}`),
      kok: sec(['Yukarıdaki çemberin uzunluğu kaç santimetredir?', 'Şekildeki çemberin çevresi kaç santimetredir?']) + ` (π = ${pi} alınız.)`,
      ipucu: 'Önce çizgi çap mı yarıçap mı, ona bak. Çember uzunluğu = π × çap = 2 × π × yarıçap.',
      cozum: goster === 'yaricap' ? [`Gösterilen uzunluk yarıçaptır: r = ${v} cm.`, `Çevre = 2 × π × r = 2 × ${pi} × ${v} = ${C} cm.`] : [`Gösterilen uzunluk çaptır: çap = ${v} cm.`, `Çevre = π × çap = ${pi} × ${v} = ${C} cm.`],
      spec: { tip_id: 'b1-cember', parametreler: { deger: v, goster } }, dogrulama: [{ yol: ['yaricap'], beklenen: r }] });
  }
  return { aciAdi, aciOlcu, alan: () => sec([alanParalelkenar, alanUcgen])(), cember };
}

export const KAYIT = [
  { id: 'mat6-paralel-aci-adi', ders: 'Matematik', sinif: 6, idOnek: 'MAT6-PAD', mufredat_surum: MUFREDAT, kodlar: ['MAT.6.3.1'], fabrika: kur, uret: (f) => f.aciAdi() },
  { id: 'mat6-paralel-aci-olcu', ders: 'Matematik', sinif: 6, idOnek: 'MAT6-POL', mufredat_surum: MUFREDAT, kodlar: ['MAT.6.3.1'], fabrika: kur, uret: (f) => f.aciOlcu() },
  { id: 'mat6-alan', ders: 'Matematik', sinif: 6, idOnek: 'MAT6-ALN', mufredat_surum: MUFREDAT, kodlar: ['MAT.6.4.2'], fabrika: kur, uret: (f) => f.alan() },
  { id: 'mat6-cember-uzunlugu', ders: 'Matematik', sinif: 6, idOnek: 'MAT6-CMB', mufredat_surum: MUFREDAT, kodlar: ['MAT.6.4.5'], fabrika: kur, uret: (f) => f.cember() },
];
