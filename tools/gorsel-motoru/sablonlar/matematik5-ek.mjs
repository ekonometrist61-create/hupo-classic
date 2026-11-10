// 5. sınıf Matematik — şekil gerektiren ek kazanımlar: birim kare ile alan (MAT.5.4.2), çark ile olasılık (MAT.5.6.1), akış şemasında işlem sırası (MAT.5.2.4).
// Şekil tipleri mevcut: a1-kareli-cevre, b1-cark, a7-akis. Çeldiriciler yaygın yanılgılardır; her biri tek bir parametreye işaret etmez.
const MUFREDAT = 'Maarif Modeli Ortaokul Matematik DÖP (5-8)';

const gcd = (a, b) => (b ? gcd(b, a % b) : Math.abs(a));
const kesirYaz = (p, q) => { const g = gcd(p, q); return q / g === 1 ? String(p / g) : `${p / g}/${q / g}`; };
const asalMi = (v) => { if (v < 2) return false; for (let d = 2; d * d <= v; d++) if (v % d === 0) return false; return true; };
const OLAYLAR = {
  asal: { metin: 'asal sayı', yuklem: asalMi },
  cift: { metin: 'çift sayı', yuklem: (v) => v % 2 === 0 },
  tek: { metin: 'tek sayı', yuklem: (v) => v % 2 === 1 },
  uc_kati: { metin: '3’ün katı olan bir sayı', yuklem: (v) => v % 3 === 0 },
  buyuk5: { metin: '5’ten büyük bir sayı', yuklem: (v) => v > 5 },
};
const ISLEM_METIN = {
  carp: (v) => `Sayıyı ${v} ile çarp`,
  ekle: (v) => `Sayıya ${v} ekle`,
  cikar: (v) => `Sayıdan ${v} çıkar`,
};

export function kur({ R, sec, karistir, ekle }) {
  function kareliAlan() {
    const kol = 8, satir = 6, en = sec([2, 3, 4, 5, 6]), boy = sec([2, 3, 4]);
    const c0 = Math.floor(R() * (kol - en + 1)), r0 = Math.floor(R() * (satir - boy + 1));
    const hucreler = [];
    for (let c = c0; c < c0 + en; c++) for (let r = r0; r < r0 + boy; r++) hucreler.push([c, r]);
    const alan = en * boy, cevre = 2 * (en + boy), kenarTop = en + boy, fazla = (en + 1) * (boy + 1);
    const cel = [cevre, kenarTop, fazla];
    if (new Set([alan, ...cel]).size < 4) throw new Error('alan_celdirici_cakisma');
    const spec = { tip_id: 'a1-kareli-cevre', parametreler: { kol, satir, hucreler } };
    ekle({ kod: 'MAT.5.4.2', konu: 'Ölçme', alt_konu: 'Dikdörtgenin alanını birim karelerle ölçme', zorluk: alan >= 12 ? 2 : 1, spec,
      dogru: String(alan), celdirici: cel.map(String),
      gerekce: [
        `${cevre}, dikdörtgenin çevre uzunluğudur; alan birim kare sayısıyla bulunur.`,
        `${kenarTop}, iki kenar uzunluğunun toplamıdır; alan için kenar uzunlukları çarpılır.`,
        `${fazla}, bir fazla satır ve sütunla (${en + 1} × ${boy + 1}) hesaplanmış bir değerdir; alan ${en} × ${boy} = ${alan} olur.`,
      ],
      kok: 'Yukarıdaki kareli zeminde boyalı dikdörtgenin alanı kaç birim karedir?',
      ipucu: 'Dikdörtgenin bir satırındaki ve bir sütunundaki kare sayılarını bul.',
      cozum: [`Dikdörtgen ${en} sütun ve ${boy} satırdan oluşur.`, `Alan = ${en} × ${boy} = ${alan} birim karedir.`],
      dogrulama: [{ yol: ['alan'], beklenen: alan }] });
  }

  function carkOlasilik() {
    // Şıklar 2x2 çarpımsal küme: {k, k'} x {n, n'}. Doğru k/n; pay ve payda başka şıklarla simetrik paylaşılır. n ve k yalnız şekilden okunur.
    const n = sec([8, 10]); // çizici n=6/8/10 kabul eder
    const anahtar = sec(Object.keys(OLAYLAR)), ol = OLAYLAR[anahtar];
    const k = 2 + Math.floor(R() * (n - 3)); // 2..n-2 düzgün; olay türünden bağımsız
    const hav = Array.from({ length: 20 }, (_, i) => i + 1), evet = hav.filter(ol.yuklem), hayir = hav.filter((x) => !ol.yuklem(x));
    const sayilar = karistir([...Array.from({ length: k }, () => sec(evet)), ...Array.from({ length: n - k }, () => sec(hayir))]);
    if (sayilar.filter(ol.yuklem).length !== k) throw new Error('olasilik_k_tutarsiz');
    const hedefYakin = R() < 0.25; // doğru şıkkın 1/2'ye en yakın olma sıklığı ≈ %25
    let v = null;
    for (let d = 0; d < 60 && !v; d++) {
      const kp = k + sec([-2, -1, 1, 2]), np = n + sec([-2, 2]);
      if (kp < 1 || kp >= Math.min(n, np) || k >= np) continue;
      const aday = [[k, n], [kp, n], [k, np], [kp, np]];
      if (new Set(aday.map(([p, q]) => (p / q).toFixed(6))).size < 4) continue;
      const u = aday.map(([p, q]) => Math.abs(p / q - 0.5)), en = Math.min(...u);
      if (u.filter((x) => x === en).length !== 1 || u[3] === en) continue;
      if ((u[0] === en) !== hedefYakin) continue;
      v = aday;
    }
    if (!v) throw new Error('olasilik_celdirici_kurulamadi');    const kp = v[1][0], np = v[2][1];
    const [dogru, c1, c2, c3] = v.map(([p, q]) => `${p}/${q}`);
    const spec = { tip_id: 'b1-cark', parametreler: { sayilar } };
    ekle({ kod: 'MAT.5.6.1', konu: 'Olasılık', alt_konu: 'Olasılığı 0 ile 1 arasında bir kesirle gösterme', zorluk: n === 8 ? 1 : 2, spec,
      dogru, celdirici: [c1, c2, c3],
      gerekce: [
        `${c1}, payı yanlış sayılmış: istenen olaya uyan dilim sayısı ${k}’dir, ${kp} değil.`,
        `${c2}, paydası yanlış alınmış: çarkta ${n} eşit dilim vardır, ${np} değil.`,
        `${c3}, hem pay hem payda yanlış: pay ${k}, payda ${n} olmalıdır.`,
      ],
      kok: `Çarkın dilimleri eşit büyüklüktedir. Bu çark bir kez çevrildiğinde ${ol.metin} gelme olasılığı hangi kesirle gösterilir?`,
      ipucu: 'Önce istenen olaya uyan dilimleri say, sonra toplam dilim sayısına böl.',
      cozum: [`Çarkta ${n} eşit dilim vardır.`, `İstenen olaya uyan dilim sayısı ${k}’dir.`, `Olasılık = ${k}/${n}.`],
      dogrulama: [{ yol: ['sayim', anahtar], beklenen: k }, { yol: ['n'], beklenen: n }] });
  }

  function islemAkisi() {
    const s = sec([2, 3, 4, 5, 6, 7, 8, 9]), ops = [];
    for (let i = 0; i < 3; i++) {
      const t = sec(['carp', 'ekle', 'cikar']);
      ops.push({ t, v: t === 'carp' ? sec([2, 3]) : sec([2, 3, 4, 5, 6, 7, 8]) });
    }
    if (!ops.some((o) => o.t === 'carp') || !ops.some((o) => o.t !== 'carp')) throw new Error('islem_cesitliligi');
    const uygula = (liste, x0) => liste.reduce((x, o) => {
      const y = o.t === 'carp' ? x * o.v : o.t === 'ekle' ? x + o.v : x - o.v;
      if (y < 0) throw new Error('negatif_ara_sonuc');
      return y;
    }, x0);
    const dogru = uygula(ops, s), ters = uygula([...ops].reverse(), s), sonAtla = uygula(ops.slice(0, 2), s), ilkAtla = uygula(ops.slice(1), s);
    const cel = [ters, sonAtla, ilkAtla];
    if (new Set([dogru, ...cel]).size < 4) throw new Error('islem_celdirici_cakisma');
    const adimlar = ops.map((o) => ISLEM_METIN[o.t](o.v));
    const spec = { tip_id: 'a7-akis', parametreler: { baslik: 'Sayı akış şeması', adimlar } };
    const cozum = []; let x = s;
    ops.forEach((o, i) => { const y = uygula([o], x); cozum.push(`${i + 1}. adım: ${x} → ${y}.`); x = y; });
    ekle({ kod: 'MAT.5.2.4', konu: 'İşlemler', alt_konu: 'Algoritmik yapıyı yorumlama', zorluk: 2, spec,
      dogru: String(dogru), celdirici: cel.map(String),
      gerekce: [
        `Adımlar ters sırada uygulanmıştır; şemadaki numaralı sıra ${s} sayısına bu sırayla uygulanmalıdır.`,
        'Son adım dikkate alınmamıştır; şemadaki bütün adımlar uygulanmalıdır.',
        'İlk adım dikkate alınmamıştır; sayı ilk adımdan başlayarak değiştirilmelidir.',
      ],
      kok: `Yukarıdaki akış şemasının adımları 1 numaralıdan başlayarak sırayla uygulanıyor. Başlangıç sayısı ${s} olduğunda son sonuç kaç olur?`,
      ipucu: 'Önce 1 numaralı adımı uygula, sonra sırayla devam et.',
      cozum: [...cozum, `Son sonuç ${dogru}.`],
      dogrulama: adimlar.map((t, i) => ({ yol: ['sira', t], beklenen: i + 1 })) });
  }

  return { kareliAlan, carkOlasilik, islemAkisi };
}

export const KAYIT = [
  { id: 'mat5-kareli-alan', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-ALN', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.4.2'], fabrika: kur, uret: (f) => f.kareliAlan() },
  { id: 'mat5-cark-olasilik', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-OLS', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.6.1'], fabrika: kur, uret: (f) => f.carkOlasilik() },
  { id: 'mat5-islem-akisi', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-ALG', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.2.4'], fabrika: kur, uret: (f) => f.islemAkisi() },
];
