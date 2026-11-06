// 8. sınıf Matematik (önceki program) — Pisagor bağıntısı (M.8.3.1.5), silindir hacmi (M.8.3.4.4) ve yüzey alanı (M.8.3.4.3), benzer üçgenler (M.8.3.3.2).
// Şekil tipleri: b1-pisagor, b1-silindir, b1-benzer (tipler-b1.mjs).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 8. sınıf; program: önceki program)';
const UCLUL = [[3, 4, 5], [5, 12, 13], [8, 15, 17], [7, 24, 25], [20, 21, 29], [6, 8, 10], [9, 12, 15], [12, 16, 20], [15, 20, 25], [9, 40, 41], [10, 24, 26], [12, 35, 37], [16, 30, 34], [18, 24, 30], [21, 28, 35], [24, 32, 40], [15, 36, 39]];

export function kur({ R, sec, karistir, ekle, konum }) {
  function aday(liste, dogru, n = 3) { // liste: [{ s, g }]; dogru: gösterim metni
    const gor = new Set([dogru]), c = [];
    for (const x of karistir(liste)) { if (!gor.has(x.s)) { gor.add(x.s); c.push(x); } if (c.length === n) break; }
    if (c.length < n) throw new Error('celdirici_yok');
    return c;
  }
  // ---------- Pisagor ----------
  function pisagor() {
    const [a0, b0, c] = sec(UCLUL), ayna = sec([false, true]), cik = sec(['c', 'c', 'a', 'b']);
    const [a, b] = sec([true, false]) ? [a0, b0] : [b0, a0];
    const hipYatay = Math.round((-Math.atan2(b, -a) * 1800) / Math.PI) / 10;
    const donus = sec([0, 90, 180, 270, 25, -30, 50, -60, hipYatay, hipYatay + 180]);
    const x = { a, b, c }[cik], cm = (v) => `${v} cm`;
    let liste;
    if (cik === 'c') liste = [{ s: cm(a + b), g: 'Dik kenarların uzunlukları toplanmıştır; Pisagor bağıntısında kareler toplanır ve karekök alınır.' }, { s: cm(Math.abs(a - b)), g: 'Dik kenarların farkı alınmıştır.' }, { s: cm(a * a + b * b), g: 'Karekök alınmamıştır: x² = a² + b² değeri x sanılmıştır.' }, { s: cm(a * b), g: 'Dik kenarlar çarpılmıştır.' }];
    else { const g = cik === 'a' ? b : a; liste = [{ s: cm(c - g), g: 'Hipotenüs ile dik kenarın farkı alınmıştır; Pisagor bağıntısında kareler çıkarılır ve karekök alınır.' }, { s: cm(c + g), g: 'Hipotenüs ile dik kenar toplanmıştır.' }, { s: cm(c * c - g * g), g: 'Karekök alınmamıştır: x² = c² − g² değeri x sanılmıştır.' }, { s: `√${c * c + g * g} cm`, g: 'Hipotenüs, dik kenar gibi kullanılmıştır; oysa dik açının karşısındaki en uzun kenar hipotenüstür ve kareler çıkarılmalıdır.' }]; }
    const cel = aday(liste, cm(x));
    ekle({ kod: 'M.8.3.1.5', konu: 'Geometri', alt_konu: 'Pisagor bağıntısı', zorluk: cik === 'c' ? 2 : 3, dogru: cm(x), celdirici: cel.map((q) => q.s), gerekce: cel.map((q) => `${q.s}: ${q.g}`),
      kok: sec(['Yukarıdaki dik üçgende x kaç santimetredir?', 'Şekildeki dik üçgende x ile gösterilen kenarın uzunluğu kaç santimetredir?']),
      ipucu: 'Önce dik açının karşısındaki en uzun kenarı (hipotenüsü) bul. Hipotenüsün karesi, dik kenarların kareleri toplamına eşittir.',
      cozum: cik === 'c' ? [`Dik kenarlar ${a} ve ${b} cm; x hipotenüstür.`, `x² = ${a}² + ${b}² = ${a * a + b * b}`, `x = ${x} cm.`] : [`Hipotenüs ${c} cm, bilinen dik kenar ${cik === 'a' ? b : a} cm; x diğer dik kenardır.`, `x² = ${c}² − ${cik === 'a' ? b : a}² = ${c * c - (cik === 'a' ? b * b : a * a)}`, `x = ${x} cm.`],
      spec: { tip_id: 'b1-pisagor', parametreler: { a, b, c, bilinmeyen: cik, donus, ayna } }, dogrulama: [{ yol: ['x'], beklenen: x }] });
  }
  // ---------- silindir ----------
  function silindir(tur) {
    const r = 2 + Math.floor(R() * 8), h = 3 + Math.floor(R() * 12), goster = sec(['yaricap', 'cap']), cap = goster === 'cap';
    const pi = (v, br) => `${v}π ${br}`;
    if (tur === 'hacim') {
      const V = r * r * h, liste = [
        ...(cap ? [{ v: 4 * r * r * h, g: 'Şekilde çap verilmiştir; çap, yarıçap gibi kullanılmıştır (r yerine 2r).' }] : [{ v: (r * r * h) / 4, g: 'Verilen uzunluk çap sanılıp yarıçap yarıya bölünmüştür.' }, { v: 4 * r * r * h, g: 'Yarıçap yerine çap (2r) kullanılmıştır.' }]),
        { v: (r * r * h) / 3, g: 'Koni hacim formülündeki 1/3 çarpanı kullanılmıştır; silindirin hacmi taban alanı × yüksekliktir.' }, { v: 2 * r * h, g: 'Yanal alanla ilgili 2 × r × h değeri alınmıştır; hacim için π × r² × h gerekir.' }, { v: r * r + h, g: 'Taban alanı ile yükseklik toplanmıştır; çarpılmalıdır.' }, { v: 2 * r * r * h, g: 'Taban alanı 2 ile çarpılmıştır.' }];
      const cel = aday(liste.filter((q) => Number.isInteger(q.v)).map((q) => ({ s: pi(q.v, 'cm³'), g: q.g })), pi(V, 'cm³'));
      ekle({ kod: 'M.8.3.4.4', konu: 'Geometri', alt_konu: 'Silindirin hacmi', zorluk: cap ? 3 : 2, dogru: pi(V, 'cm³'), celdirici: cel.map((q) => q.s), gerekce: cel.map((q) => `${q.s}: ${q.g}`),
        kok: sec(['Yukarıdaki dik dairesel silindirin hacmi kaç santimetreküptür?', 'Şekildeki silindirin hacmi kaç santimetreküptür?']),
        ipucu: 'Hacim = taban alanı × yükseklik = π × r² × h. Üstteki çizgi yarıçap mı, çap mı, önce ona bak.',
        cozum: [cap ? `Gösterilen uzunluk çaptır (${2 * r} cm); yarıçap r = ${r} cm.` : `Gösterilen uzunluk yarıçaptır: r = ${r} cm.`, `Yükseklik h = ${h} cm.`, `Hacim = π × ${r}² × ${h} = ${V}π cm³.`],
        spec: { tip_id: 'b1-silindir', parametreler: { r, h, goster } }, dogrulama: [{ yol: ['hacim'], beklenen: V }] });
    } else {
      const A = 2 * r * (r + h), liste = [
        { v: 2 * r * h, g: 'Yalnız yanal alan (2πrh) hesaplanmıştır; iki taban alanı da eklenmelidir.' }, { v: r * r + 2 * r * h, g: 'Tek taban alanı eklenmiştir; silindirin iki tabanı vardır.' }, { v: 2 * r * r, g: 'Yalnız iki taban alanı hesaplanmıştır; yanal alan da eklenmelidir.' }, { v: r * (r + h), g: 'Toplam alan 2 ile çarpılmamıştır.' },
        ...(cap ? [{ v: 2 * (2 * r) * (2 * r + h), g: 'Şekilde çap verilmiştir; çap, yarıçap gibi kullanılmıştır.' }] : [{ v: 2 * (2 * r) * (2 * r + h), g: 'Yarıçap yerine çap (2r) kullanılmıştır.' }])];
      const cel = aday(liste.map((q) => ({ s: pi(q.v, 'cm²'), g: q.g })), pi(A, 'cm²'));
      ekle({ kod: 'M.8.3.4.3', konu: 'Geometri', alt_konu: 'Silindirin yüzey alanı', zorluk: 3, dogru: pi(A, 'cm²'), celdirici: cel.map((q) => q.s), gerekce: cel.map((q) => `${q.s}: ${q.g}`),
        kok: sec(['Yukarıdaki dik dairesel silindirin tüm yüzey alanı kaç santimetrekaredir?', 'Şekildeki silindirin toplam yüzey alanı kaç santimetrekaredir?']),
        ipucu: 'Yüzey alanı = 2 × taban alanı + yanal alan = 2πr² + 2πrh. Önce yarıçapı bul.',
        cozum: [cap ? `Gösterilen uzunluk çaptır (${2 * r} cm); yarıçap r = ${r} cm.` : `Gösterilen uzunluk yarıçaptır: r = ${r} cm.`, `Yükseklik h = ${h} cm.`, `Alan = 2π × ${r} × (${r} + ${h}) = ${A}π cm².`],
        spec: { tip_id: 'b1-silindir', parametreler: { r, h, goster } }, dogrulama: [{ yol: ['yuzey'], beklenen: A }] });
    }
  }
  // ---------- benzer üçgenler ----------
  const UC = [[4, 5, 6], [5, 6, 7], [6, 7, 8], [4, 6, 7], [5, 7, 8], [3, 4, 5], [6, 8, 10], [5, 5, 6], [6, 6, 8], [7, 8, 9], [4, 5, 7], [5, 6, 8], [6, 7, 9], [3, 5, 6], [4, 4, 5]];
  function benzer() {
    const t1 = sec(UC), k = sec([2, 2, 3]), [i, j] = karistir([0, 1, 2]).slice(0, 2), l = 3 - i - j, a = t1[i], b = t1[j], x = k * b, kn = k * a;
    const ad = ['BC', 'CA', 'AB'];
    const liste = [{ s: b + (kn - a), g: 'Ölçek farkı eklenmiştir (toplamsal düşünme); benzer şekillerde kenarlar aynı oranla çarpılır.' }, { s: k * t1[l], g: 'Eş olmayan bir kenar çifti eşlenmiştir; eş açıların karşısındaki kenarlar eşlenmelidir.' }, { s: b, g: 'Oran uygulanmamış, ilk üçgenin kenarı yazılmıştır.' }, { s: x + a, g: 'Yanlış kenar çiftiyle oranlanmıştır.' }, { s: x - 1, g: 'Oran doğru bulunmuş ama çarpma yanlış yapılmıştır.' }, { s: (b * a) / kn, g: 'Oran ters çevrilmiştir (küçük üçgenden büyüğe giderken bölünmüştür).' }];
    const cel = aday(liste.filter((q) => Number.isInteger(q.s) && q.s > 0).map((q) => ({ s: `${q.s} cm`, g: q.g })), `${x} cm`);
    ekle({ kod: 'M.8.3.3.2', konu: 'Geometri', alt_konu: 'Benzer üçgenlerde kenar oranı', zorluk: 3, dogru: `${x} cm`, celdirici: cel.map((q) => q.s), gerekce: cel.map((q) => `${q.s}: ${q.g}`),
      kok: 'Şekildeki iki üçgen benzerdir (eş açılar yaylarla işaretlenmiştir). Kenar uzunlukları santimetre cinsinden verildiğine göre x kaç santimetredir?',
      ipucu: 'Önce aynı konumdaki (eş açıların karşısındaki) kenarları eşle. İki üçgenin kenarları aynı sayıyla çarpılır.',
      cozum: [`Eş kenarlar: ${a} ↔ ${kn}. Benzerlik oranı ${kn} ÷ ${a} = ${k}.`, `x, ${b} cm’lik kenara karşılık gelir: x = ${b} × ${k} = ${x} cm.`],
      spec: { tip_id: 'b1-benzer', parametreler: { t1, k, bilinen: i, bilinmeyen: j } }, dogrulama: [{ yol: ['x'], beklenen: x }] });
    void ad;
  }
  return { pisagor, hacim: () => silindir('hacim'), yuzey: () => silindir('yuzey'), benzer };
}

export const KAYIT = [
  { id: 'mat8-pisagor', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-PSG', mufredat_surum: MUFREDAT, kodlar: ['M.8.3.1.5'], fabrika: kur, uret: (f) => f.pisagor() },
  { id: 'mat8-silindir-hacim', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-SHC', mufredat_surum: MUFREDAT, kodlar: ['M.8.3.4.4'], fabrika: kur, uret: (f) => f.hacim() },
  { id: 'mat8-silindir-yuzey', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-SYZ', mufredat_surum: MUFREDAT, kodlar: ['M.8.3.4.3'], fabrika: kur, uret: (f) => f.yuzey() },
  { id: 'mat8-benzer-ucgen', ders: 'Matematik', sinif: 8, idOnek: 'MAT8-BNZ', mufredat_surum: MUFREDAT, kodlar: ['M.8.3.3.2'], fabrika: kur, uret: (f) => f.benzer() },
];
