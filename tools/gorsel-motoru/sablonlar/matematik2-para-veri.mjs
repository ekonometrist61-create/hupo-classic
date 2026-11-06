// 2. sınıf Matematik — madenî paralar (MAT.2.1.8) ve simge grafiği / kategorik veri (MAT.2.4.1).
// Şekil tipleri: b1-para, b1-simge-grafigi (tipler-b1.mjs).
const MUFREDAT = '2026 Maarif Modeli İlkokul Matematik DÖP (1-4), 2. sınıf bölümü';
const ADLAR = ['Ayşe', 'Efe', 'Elif', 'Mert', 'Ali', 'Can', 'Sude', 'Arda', 'Kaan', 'Deniz'];
const TAMLAMA = { Ayşe: 'Ayşe’nin', Efe: 'Efe’nin', Elif: 'Elif’in', Mert: 'Mert’in', Ali: 'Ali’nin', Can: 'Can’ın', Sude: 'Sude’nin', Arda: 'Arda’nın', Kaan: 'Kaan’ın', Deniz: 'Deniz’in' };
const TEMALAR = [
  { baslik: 'Sevilen Meyveler', ad: ['Elma', 'Armut', 'Muz', 'Çilek', 'Kiraz'], nesne: 'kişi' },
  { baslik: 'Sevilen Renkler', ad: ['Mavi', 'Kırmızı', 'Yeşil', 'Sarı', 'Mor'], nesne: 'öğrenci' },
  { baslik: 'Evcil Hayvanlar', ad: ['Kedi', 'Köpek', 'Kuş', 'Balık', 'Tavşan'], nesne: 'çocuk' },
  { baslik: 'Sevilen Sporlar', ad: ['Futbol', 'Yüzme', 'Basket', 'Tenis', 'Koşu'], nesne: 'öğrenci' },
  { baslik: 'Okunan Kitaplar', ad: ['Masal', 'Şiir', 'Hikâye', 'Roman', 'Resimli'], nesne: 'kitap' },
];
const SIMGELER = ['daire', 'yildiz', 'kare', 'ucgen'];
const pencere = (c, kp, adim, min = 0, max = Infinity) => {
  const a = [0, 1, 2, 3].map((i) => c + (i - kp) * adim);
  if (a.some((v) => v < min || v > max)) throw new Error('pencere_disi');
  return a;
};

export function kur({ R, sec, karistir, ekle, konum }) {
  // ---------- paralar ----------
  function paralar(n, ust = 100) {
    for (let g = 0; g < 80; g++) {
      const a = Array.from({ length: n }, () => sec([5, 5, 10, 10, 10, 25, 25, 50]));
      const t = a.reduce((x, y) => x + y, 0);
      if (t <= ust && t >= 20) return a.sort((x, y) => y - x);
    }
    throw new Error('para_uretilemedi');
  }
  const sayilar = (a) => { const o = {}; for (const v of a) o[v] = (o[v] ?? 0) + 1; return o; };
  function paraToplam() {
    const a = paralar(sec([3, 4, 5, 6, 7])), t = a.reduce((x, y) => x + y, 0), adim = sec([5, 5, 10]), kp = konum();
    const sirali = pencere(t, kp, adim, 5, 100).map((v) => `${v} kuruş`);
    ekle({ kod: 'MAT.2.1.8', konu: 'Paralarımız', alt_konu: 'Madenî paraların toplamı', zorluk: a.length <= 4 ? 1 : 2, sirali, dogru: `${t} kuruş`,
      gerekce: sirali.map((s) => { const v = parseInt(s, 10); return v === t ? '' : `${v} kuruş, paraların toplamı olan ${t} kuruştan ${Math.abs(v - t)} kuruş ${v > t ? 'fazladır' : 'eksiktir'}; bir para yanlış okunmuş ya da eksik veya fazla sayılmış olabilir.`; }),
      kok: 'Kumbarada bulunan madenî paralar yukarıda gösterilmiştir. Bu paraların toplamı kaç kuruştur?',
      ipucu: 'Her paranın üzerindeki değeri oku ve hepsini topla.', cozum: [`Paraların değerleri: ${a.join(', ')} kuruş.`, `Toplam: ${a.join(' + ')} = ${t} kuruştur.`],
      spec: { tip_id: 'b1-para', parametreler: { gruplar: [{ paralar: a }] } }, dogrulama: [{ yol: ['toplam'], beklenen: t }] });
  }
  function paraTamamla() {
    const a = paralar(sec([2, 3, 4, 5]), 95), t = a.reduce((x, y) => x + y, 0), d = 100 - t, adim = sec([5, 5, 10]), kp = konum();
    const sirali = pencere(d, kp, adim, 5, 95).map((v) => `${v} kuruş`);
    ekle({ kod: 'MAT.2.1.8', konu: 'Paralarımız', alt_konu: 'Kuruş ve Türk lirası ilişkisi', zorluk: 3, sirali, dogru: `${d} kuruş`,
      gerekce: sirali.map((s) => { const v = parseInt(s, 10); return v === d ? '' : `${v} kuruş eklenirse toplam ${t + v} kuruş olur; 100 kuruşa (1 TL) tamamlanmaz.`; }),
      kok: 'Yukarıdaki madenî paralara kaç kuruş daha eklenirse toplam 1 TL olur?',
      ipucu: '1 TL, 100 kuruştur. Önce paraların toplamını bul.', cozum: [`Paraların toplamı ${a.join(' + ')} = ${t} kuruştur.`, `1 TL = 100 kuruş olduğundan 100 − ${t} = ${d} kuruş gerekir.`],
      spec: { tip_id: 'b1-para', parametreler: { gruplar: [{ paralar: a }] } }, dogrulama: [{ yol: ['toplam'], beklenen: t }] });
  }
  function paraAdet() {
    const a = paralar(sec([4, 5, 6, 7, 8])), s = sayilar(a), v = sec(Object.keys(s).map(Number)), c = s[v], kp = konum();
    if (c > 6) throw new Error('adet_buyuk');
    const sirali = pencere(c, kp, 1, 1, 8).map(String);
    ekle({ kod: 'MAT.2.1.8', konu: 'Paralarımız', alt_konu: 'Paraları değerlerine göre ayırma', zorluk: 1, sirali, dogru: String(c),
      gerekce: sirali.map((x) => (Number(x) === c ? '' : `${x} değil: ${v} kuruşluk paralar tek tek sayılınca ${c} tane bulunur.`)),
      kok: `Yukarıdaki madenî paralardan kaç tanesi ${v} kuruşluktur?`,
      ipucu: `Yalnız ${v} yazan paraları say.`, cozum: [`Üzerinde ${v} yazan paralar sayılır.`, `${v} kuruşluk para sayısı ${c}’dir.`],
      spec: { tip_id: 'b1-para', parametreler: { gruplar: [{ paralar: a }] } }, dogrulama: [{ yol: ['gruplar', '0', 'sayilar', String(v)], beklenen: c }] });
  }
  function paraFark() {
    const [x, y] = karistir(ADLAR).slice(0, 2), a = paralar(sec([3, 4, 5, 6])), b = paralar(sec([3, 4, 5, 6]));
    const ta = a.reduce((p, q) => p + q, 0), tb = b.reduce((p, q) => p + q, 0), f = Math.abs(ta - tb), adim = sec([5, 5, 10]), kp = konum();
    if (f < 5 || a.join() === b.join()) throw new Error('fark_yok');
    const sirali = pencere(f, kp, adim, 5, 100).map((v) => `${v} kuruş`);
    ekle({ kod: 'MAT.2.1.8', konu: 'Paralarımız', alt_konu: 'İki paranın karşılaştırılması', zorluk: 3, sirali, dogru: `${f} kuruş`,
      gerekce: sirali.map((s) => { const v = parseInt(s, 10); return v === f ? '' : `${v} kuruş, iki toplam arasındaki farktan (${f} kuruş) ${Math.abs(v - f)} kuruş ${v > f ? 'fazladır' : 'eksiktir'}.`; }),
      kok: `${TAMLAMA[x]} parası ile ${TAMLAMA[y]} parası arasındaki fark kaç kuruştur?`,
      ipucu: 'Her çocuğun parasını ayrı ayrı topla, sonra büyükten küçüğü çıkar.', cozum: [`${x}: ${a.join(' + ')} = ${ta} kuruş.`, `${y}: ${b.join(' + ')} = ${tb} kuruş.`, `Fark: ${Math.max(ta, tb)} − ${Math.min(ta, tb)} = ${f} kuruştur.`],
      spec: { tip_id: 'b1-para', parametreler: { gruplar: [{ ad: x, paralar: a }, { ad: y, paralar: b }] } }, dogrulama: [{ yol: ['gruplar', '0', 'toplam'], beklenen: ta }, { yol: ['gruplar', '1', 'toplam'], beklenen: tb }] });
  }

  // ---------- simge grafiği ----------
  function grafik(n, birim) {
    const t = sec(TEMALAR), adlar = karistir(t.ad).slice(0, n), tut = new Set();
    for (let g = 0; g < 100 && tut.size < n; g++) tut.add(2 + Math.floor(R() * 8));
    if (tut.size < n) throw new Error('deger_yok');
    const sim = [...tut].map((k) => k * birim), satirlar = adlar.map((ad, i) => ({ ad, adet: sim[i] }));
    return { t, adlar, satirlar, v: Object.fromEntries(satirlar.map((r) => [r.ad, r.adet])), spec: { tip_id: 'b1-simge-grafigi', parametreler: { baslik: t.baslik, satirlar, birim, simge: sec(SIMGELER), nesne: t.nesne } } };
  }
  const tekil = (arr) => arr.filter((x, i, d) => d.indexOf(x) === i);
  function simgeDeger() {
    const birim = sec([1, 2, 2]), g = grafik(sec([2, 3, 4]), birim), X = sec(g.adlar), c = g.v[X], kp = konum();
    let ekle1;
    if (birim === 1) { const sirali = pencere(c, kp, 1, 1).map(String); ekle1 = { sirali, dogru: String(c), gerekce: sirali.map((x) => (Number(x) === c ? '' : `${x}: simgeler yanlış sayılmıştır; ${X} satırında ${c} simge vardır.`)) }; }
    else {
      const cel = tekil([c / 2, c + 2, c - 2, c + 4]).filter((x) => x !== c && x >= 1).slice(0, 3).map(String);
      ekle1 = { dogru: String(c), celdirici: cel, gerekce: cel.map((x) => (Number(x) === c / 2 ? `${x}, simge sayısıdır; her simge ${birim} ${g.t.nesne} gösterdiği için değeri iki katına çıkarmak gerekir.` : `${x}, her simge ${birim} ${g.t.nesne} sayılarak bulunan ${c} değerinden ${Math.abs(Number(x) - c)} farklıdır.`)) };
    }
    ekle({ kod: 'MAT.2.4.1', konu: 'Veri', alt_konu: 'Simge grafiğini okuma', zorluk: birim === 1 ? 1 : 2, ...ekle1,
      kok: `Yukarıdaki simge grafiğinde “${X}” satırı kaç ${g.t.nesne} göstermektedir?`, ipucu: 'Simgelerin her birinin kaç kişiyi (kaç şeyi) gösterdiğine grafiğin altındaki bilgiden bak.',
      cozum: [`${X} satırındaki simgeler sayılır: ${c / birim} simge.`, `Her simge ${birim} ${g.t.nesne} gösterir: ${c / birim} × ${birim} = ${c}.`],
      spec: g.spec, dogrulama: [{ yol: ['degerler', X], beklenen: c }] });
  }
  function simgeEnCok() {
    const birim = sec([1, 2]), g = grafik(4, birim), sirala = [...g.satirlar].sort((a, b) => b.adet - a.adet), kp = konum();
    void kp;
    const dogru = sirala[0].ad, cel = karistir(sirala.slice(1).map((r) => r.ad));
    ekle({ kod: 'MAT.2.4.1', konu: 'Veri', alt_konu: 'Simge grafiğinde en çok', zorluk: 1, dogru, celdirici: cel,
      gerekce: cel.map((c) => `${c} satırında ${g.v[c]} ${g.t.nesne} vardır; en çok olan satır ${dogru} (${g.v[dogru]}) satırıdır.`),
      kok: `Yukarıdaki simge grafiğine göre en çok ${g.t.nesne} hangi satırdadır?`, ipucu: 'En çok simgesi olan satıra bak.',
      cozum: ['Satırlardaki simgeler karşılaştırılır.', `En çok simge ${dogru} satırındadır.`], spec: g.spec, dogrulama: [{ yol: ['en_cok'], beklenen: dogru }] });
  }
  function simgeFark() {
    const birim = sec([1, 2]), g = grafik(sec([2, 3, 4]), birim), [A, B] = karistir(g.adlar).slice(0, 2), a = g.v[A], b = g.v[B], f = Math.abs(a - b);
    const aday = tekil([a + b, Math.max(a, b), Math.min(a, b), ...(birim === 2 ? [f / 2] : []), f + birim * 2, f + birim]).filter((x) => x !== f && x > 0);
    if (aday.length < 3) throw new Error('celdirici_yok');
    const cel = aday.slice(0, 3);
    ekle({ kod: 'MAT.2.4.1', konu: 'Veri', alt_konu: 'İki satırın farkı', zorluk: 2, dogru: String(f), celdirici: cel.map(String),
      gerekce: cel.map((x) => (x === a + b ? 'İki değer toplanmış; fark için çıkarma yapılmalı.' : x === f / 2 && birim === 2 ? 'Simge sayılarının farkı bulunmuş; her simge 2 olduğundan iki katı alınmalı.' : `${x}, iki satırın farkı değildir.`)),
      kok: `Yukarıdaki simge grafiğinde “${A}” ile “${B}” satırları arasındaki ${g.t.nesne} sayısı farkı kaçtır?`, ipucu: 'İki satırın değerini bul, büyükten küçüğü çıkar.',
      cozum: [`${A} = ${a}, ${B} = ${b} bulunur.`, `Fark: ${Math.max(a, b)} − ${Math.min(a, b)} = ${f}.`], spec: g.spec, dogrulama: [{ yol: ['degerler', A], beklenen: a }, { yol: ['degerler', B], beklenen: b }] });
  }
  function simgeToplam() {
    const birim = sec([1, 2]), g = grafik(sec([2, 3]), birim), tp = g.satirlar.reduce((t, r) => t + r.adet, 0), kp = konum();
    let ek;
    if (birim === 1) { const sirali = pencere(tp, kp, sec([1, 2]), 2).map(String); ek = { sirali, dogru: String(tp), gerekce: sirali.map((x) => (Number(x) === tp ? '' : `${x}: simgeler yanlış sayılmıştır; toplam ${tp} simgedir.`)) }; }
    else { const cel = tekil([tp / 2, tp + 2, tp - 2, tp + 4]).filter((x) => x !== tp && x >= 2).slice(0, 3).map(String); ek = { dogru: String(tp), celdirici: cel, gerekce: cel.map((x) => (Number(x) === tp / 2 ? `${x}, simgelerin sayısıdır; her simge 2 ${g.t.nesne} gösterir.` : `${x}, her satırın değeri doğru okunup toplanmamıştır.`)) }; }
    ekle({ kod: 'MAT.2.4.1', konu: 'Veri', alt_konu: 'Simge grafiğinde toplam', zorluk: 2, ...ek,
      kok: `Yukarıdaki simge grafiğine göre tüm satırlarda toplam kaç ${g.t.nesne} vardır?`, ipucu: 'Her satırın değerini bul ve hepsini topla.',
      cozum: [`Satırların değerleri: ${g.satirlar.map((r) => r.adet).join(', ')}.`, `Toplam: ${g.satirlar.map((r) => r.adet).join(' + ')} = ${tp}.`], spec: g.spec, dogrulama: [{ yol: ['toplam'], beklenen: tp }] });
  }
  return { paraSorusu: () => sec([paraToplam, paraToplam, paraTamamla, paraAdet, paraFark])(), simgeSorusu: () => sec([simgeDeger, simgeDeger, simgeEnCok, simgeFark, simgeToplam])() };
}

export const KAYIT = [
  { id: 'mat2-madeni-para', ders: 'Matematik', sinif: 2, idOnek: 'MAT2-PRA', mufredat_surum: MUFREDAT, kodlar: ['MAT.2.1.8'], fabrika: kur, uret: (f) => f.paraSorusu() },
  { id: 'mat2-simge-grafigi', ders: 'Matematik', sinif: 2, idOnek: 'MAT2-SMG', mufredat_surum: MUFREDAT, kodlar: ['MAT.2.4.1'], fabrika: kur, uret: (f) => f.simgeSorusu() },
];
