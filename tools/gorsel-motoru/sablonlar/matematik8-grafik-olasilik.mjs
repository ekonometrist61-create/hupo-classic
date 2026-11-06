// 8. sınıf Matematik (önceki program) — doğrunun eğimi (M.8.2.2.6), doğrusal denklemin grafiği (M.8.2.2.4), çarkla basit olay olasılığı (M.8.5.1.5).
// Şekil tipleri: b1-dogru-grafigi, b1-cark (tipler-b1.mjs).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 8. sınıf; program: önceki program)';
const gcd = (a, b) => (b ? gcd(b, a % b) : Math.abs(a));
const eksi = (n) => (n < 0 ? '−' : '');
const kesir = (pay, payda) => { const g = gcd(pay, payda), s = payda < 0 ? -1 : 1, p = (s * pay) / g, q = Math.abs(payda) / g; return q === 1 ? `${eksi(p)}${Math.abs(p)}` : `${eksi(p)}${Math.abs(p)}/${q}`; };
const denk = (m, n) => `y = ${m === 1 ? '' : m === -1 ? '−' : m < 0 ? `−${-m}` : m}x ${n < 0 ? '−' : '+'} ${Math.abs(n)}`;
const asalMi = (x) => x > 1 && Array.from({ length: Math.floor(Math.sqrt(x)) - 1 }, (_, i) => i + 2).every((d) => x % d);
const KOSUL = {
  asal: ['asal sayıyı göstermesi', asalMi], cift: ['çift sayıyı göstermesi', (v) => v % 2 === 0], tek: ['tek sayıyı göstermesi', (v) => v % 2 === 1],
  uc_kati: ['3’ün katı olan bir sayıyı göstermesi', (v) => v % 3 === 0], buyuk5: ['5’ten büyük bir sayıyı göstermesi', (v) => v > 5], kucuk10: ['10’dan küçük bir sayıyı göstermesi', (v) => v < 10],
};

export function kur({ R, sec, karistir, ekle, konum }) {
  function aday(liste, dogru, n = 3) {
    const gor = new Set([dogru]), c = [];
    for (const x of karistir(liste)) { if (!gor.has(x.s)) { gor.add(x.s); c.push(x); } if (c.length === n) break; }
    if (c.length < n) throw new Error('celdirici_yok');
    return c;
  }
  // ---------- eğim ----------
  function egim() {
    const [p, q] = sec([[1, 2], [1, 3], [2, 1], [2, 3], [3, 1], [3, 2]]), sg = sec([1, -1]), kk = sec([1, 1, 2]);
    const x1 = -5 + Math.floor(R() * 6), y1 = -5 + Math.floor(R() * 11), x2 = x1 + q * kk, y2 = y1 + sg * p * kk;
    if (x2 > 5 || y2 > 5 || y2 < -5) throw new Error('nokta_disi');
    const m = kesir(sg * p, q), liste = [{ s: kesir(-sg * p, q), g: 'İşaret yanlış alınmıştır: doğru sağa doğru yükseliyorsa eğim pozitif, alçalıyorsa negatiftir.' }, { s: kesir(sg * q, p), g: 'Eğim, dikey değişimin yatay değişime oranıdır; pay ile payda yer değiştirmiştir.' }, { s: kesir(-sg * q, p), g: 'Hem işaret hem de pay-payda yanlıştır.' }];
    const cel = aday(liste, m);
    ekle({ kod: 'M.8.2.2.6', konu: 'Cebir', alt_konu: 'Doğrunun eğimi', zorluk: q === 1 ? 2 : 3, dogru: m, celdirici: cel.map((c) => c.s), gerekce: cel.map((c) => `${c.s}: ${c.g}`),
      kok: sec(['Koordinat düzleminde gösterilen doğrunun eğimi kaçtır?', 'Grafiği verilen doğrunun eğimi kaçtır?']),
      ipucu: 'İşaretli iki noktaya bak: sağa kaç birim gidince yukarı (aşağı) kaç birim değişiyor? Eğim = dikey değişim ÷ yatay değişim.',
      cozum: [`İşaretli noktalar (${x1}, ${y1}) ve (${x2}, ${y2}).`, `Yatay değişim ${q * kk}, dikey değişim ${sg * p * kk}.`, `Eğim = ${sg * p * kk}/${q * kk} = ${m}.`],
      spec: { tip_id: 'b1-dogru-grafigi', parametreler: { noktalar: [[x1, y1], [x2, y2]], isaret: [[x1, y1], [x2, y2]] } }, dogrulama: [{ yol: ['egim'], beklenen: m.replace('−', '-') }] });
  }
  // ---------- denklem ----------
  function denklem() {
    const m = sec([-3, -2, -1, 1, 2, 3]), n = sec([-4, -3, -2, -1, 1, 2, 3, 4]);
    if (Math.abs(n + m) > 5) throw new Error('nokta_disi');
    const d = denk(m, n), liste = [{ s: denk(-m, n), g: 'Eğimin işareti ters alınmıştır; doğru yükseliyorsa eğim pozitiftir.' }, { s: denk(m, -n), g: 'y eksenini kestiği nokta (0, ' + n + ') iken işareti ters yazılmıştır.' }, { s: denk(n, m), g: 'Eğim ile y eksenini kestiği değer (sabit terim) yer değiştirmiştir.' }, { s: denk(-m, -n), g: 'Hem eğim hem sabit terimin işareti ters alınmıştır.' }, { s: denk(2 * m, n), g: 'Eğim iki katı alınmıştır; sağa 1 gidince değişim m kadardır.' }];
    const cel = aday(liste, d);
    ekle({ kod: 'M.8.2.2.4', konu: 'Cebir', alt_konu: 'Grafiği verilen doğrusal denklem', zorluk: 3, dogru: d, celdirici: cel.map((c) => c.s), gerekce: cel.map((c) => `${c.s}: ${c.g}`),
      kok: sec(['Yukarıda grafiği verilen doğrunun denklemi aşağıdakilerden hangisidir?', 'Koordinat düzleminde grafiği çizilen doğrunun denklemi hangisidir?']),
      ipucu: 'Doğrunun y eksenini kestiği noktaya ve sağa 1 birim giderken y’nin ne kadar değiştiğine bak.',
      cozum: [`Doğru y eksenini (0, ${n}) noktasında keser: sabit terim ${n}.`, `Sağa 1 birim gidince y ${m > 0 ? 'artar' : 'azalır'}: eğim ${m}.`, `Denklem ${d}.`],
      spec: { tip_id: 'b1-dogru-grafigi', parametreler: { noktalar: [[0, n], [1, n + m]], isaret: [[0, n], [1, n + m]] } }, dogrulama: [{ yol: ['egim'], beklenen: String(m) }, { yol: ['n'], beklenen: n }] });
  }
  // ---------- çark ----------
  function carkOlasilik() {
    const n = sec([6, 8, 10]), sayilar = karistir(Array.from({ length: 20 }, (_, i) => i + 1)).slice(0, n), anahtar = sec(Object.keys(KOSUL)), [ifade, f] = KOSUL[anahtar];
    const uygun = sayilar.filter(f), k = uygun.length;
    if (k < 1 || k > n - 1) throw new Error('k_gecersiz');
    const o = kesir(k, n), eq = (a, b, c, d) => a * d === b * c;
    const liste = [[n - k, n, 'Soruda istenmeyen (koşulu sağlamayan) dilimler sayılmıştır.'], [k, n - k, 'Olasılıkta payda tüm dilimlerin sayısıdır; koşulu sağlamayan dilimler paydaya yazılmıştır.'], [1, n, 'Yalnız bir dilim sayılmıştır.'], [k + 1, n, 'Uygun dilimlerden biri fazla sayılmıştır.'], [Math.max(k - 1, 1), n, 'Uygun dilimlerden biri eksik sayılmıştır.'], [k, n + 2, 'Dilim sayısı yanlış alınmıştır.']]
      .filter(([a, b]) => !eq(a, b, k, n)).map(([a, b, g]) => ({ s: kesir(a, b), g }));
    const cel = aday(liste, o);
    ekle({ kod: 'M.8.5.1.5', konu: 'Olasılık', alt_konu: 'Basit olayın olasılığı', zorluk: 2, dogru: o, celdirici: cel.map((c) => c.s), gerekce: cel.map((c) => `${c.s}: ${c.g}`),
      kok: `Yukarıdaki çark çevrildiğinde ok işaretinin ${ifade} olasılığı kaçtır?`, ipucu: 'Olasılık = istenen durumların sayısı ÷ tüm durumların sayısı. Çarkta kaç dilim olduğunu ve kaçının koşulu sağladığını say.',
      cozum: [`Çark ${n} eş dilimlidir.`, `Koşulu sağlayan sayılar: ${uygun.sort((x, y) => x - y).join(', ')} (${k} tane).`, `Olasılık = ${k}/${n}${o !== `${k}/${n}` ? ` = ${o}` : ''}.`],
      spec: { tip_id: 'b1-cark', parametreler: { sayilar } }, dogrulama: [{ yol: ['sayim', anahtar], beklenen: k }, { yol: ['n'], beklenen: n }] });
  }
  return { egim, denklem, cark: carkOlasilik };
}

export const KAYIT = [
  { id: 'mat8-dogru-egim', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-EGM', mufredat_surum: MUFREDAT, kodlar: ['M.8.2.2.6'], fabrika: kur, uret: (f) => f.egim() },
  { id: 'mat8-dogru-denklem', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-DNK', mufredat_surum: MUFREDAT, kodlar: ['M.8.2.2.4'], fabrika: kur, uret: (f) => f.denklem() },
  { id: 'mat8-cark-olasilik', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-OLS', mufredat_surum: MUFREDAT, kodlar: ['M.8.5.1.5'], fabrika: kur, uret: (f) => f.cark() },
];
