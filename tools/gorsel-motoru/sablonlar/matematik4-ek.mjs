// 4. sınıf Matematik (önceki program) — sütun grafiği ile problem, birimkare ile alan ve açı türü şablonları.
// Şekil tipleri mevcut: sutun-grafigi, a3-izgara-sekil, a3-acilar. Doğru şık konum() ile yerleşir.
// Çeldiriciler tek bir parametreye işaret etmez (pencere veya farklı işlem sonuçları).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 4. sınıf; program: önceki program)';
const TEMALAR = [
  { baslik: 'Pazar Günü Satılan Ürünler', ad: ['Süt', 'Yumurta', 'Peynir', 'Ekmek', 'Bal'] },
  { baslik: 'Hafta Sonu Etkinlikleri', ad: ['Bisiklet', 'Yüzme', 'Resim', 'Okuma', 'Film'] },
  { baslik: 'Okul Bahçesine Dikilen Fideler', ad: ['Lale', 'Papatya', 'Gül', 'Menekşe', 'Nergis'] },
  { baslik: 'Kütüphaneden Ödünç Alınan Kitaplar', ad: ['Masal', 'Şiir', 'Roman', 'Fen', 'Tarih'] },
];
const ESKALA = [{ max: 10, adim: 2 }, { max: 20, adim: 4 }, { max: 16, adim: 4 }];
const TUR_AD = { dar: 'dar', dik: 'dik', genis: 'geniş' };
// Panel etiketleri şıkların harfleriyle (A-D) karışmasın diye K, L, M, N kullanılır.
const PANEL_HARF = ['K', 'L', 'M', 'N'];

export function kur({ R, sec, karistir, ekle }) {
  // Adayların ilkini değil, rastgele üçünü seçer: değeri doğru değere eşit olmayan ve birbirinden farklı olanlar.
  function uc(aday, dogru) {
    const secilen = [];
    for (const x of karistir(aday)) {
      if (x.m > 0 && x.m !== dogru && !secilen.some((y) => y.m === x.m)) secilen.push(x);
      if (secilen.length === 3) break;
    }
    if (secilen.length < 3) throw new Error('celdirici_yetersiz');
    return secilen;
  }

  // M.4.4.1.4: sütun grafiğinden fark, toplam ve en yüksek-en alçak farkı.
  function sutunSorusu() {
    const t = sec(TEMALAR), e = sec(ESKALA), yarim = e.adim / 2, n = sec([4, 5]);
    const adlar = karistir(t.ad).slice(0, n);
    const adet = Math.floor(e.max / yarim);
    const deger = new Set(); let guard = 0;
    while (deger.size < n && guard++ < 200) deger.add((1 + Math.floor(R() * (adet - 1))) * yarim);
    if (deger.size < n) throw new Error('deger_cesitliligi_yok');
    const kategoriler = adlar.map((ad, i) => ({ ad, deger: [...deger][i] }));
    const v = Object.fromEntries(kategoriler.map((k) => [k.ad, k.deger]));
    const spec = { tip_id: 'sutun-grafigi', parametreler: { baslik: t.baslik, kategoriler, max: e.max, adim: e.adim } };
    const ortak = { kod: 'M.4.4.1.4', konu: 'Veri Toplama ve Değerlendirme', alt_konu: 'Sütun grafiği ile problem çözme', spec,
      ipucu: 'Her sütunun üst ucunun dikey eksende hangi çizgiye denk geldiğine bak; iki değeri okuyup işlemi yap.' };
    const kind = sec(['fark', 'toplam', 'enfark']);

    if (kind === 'fark') {
      const iki = karistir(adlar).slice(0, 2).sort((x, y) => v[y] - v[x]);
      const [A, B] = iki, a = v[A], b = v[B], f = a - b;
      const secilen = uc([
        { m: a + b, g: 'Değerler toplanmış, fark alınmamıştır.' },
        { m: a, g: 'Yalnızca büyük değer yazılmış, fark hesaplanmamıştır.' },
        { m: b, g: 'Yalnızca küçük değer yazılmış, fark hesaplanmamıştır.' },
        { m: f + e.adim, g: 'Fark bir çizgi kadar fazla okunmuştur.' },
        { m: f - e.adim, g: 'Fark bir çizgi kadar eksik okunmuştur.' },
      ], f);
      ekle({ ...ortak, zorluk: 2, dogru: String(f), celdirici: secilen.map((x) => String(x.m)), gerekce: secilen.map((x) => x.g),
        kok: `Yukarıdaki sütun grafiği "${t.baslik}" konusunda bilgi vermektedir. Buna göre ${A} sütunu, ${B} sütunundan kaç fazladır?`,
        cozum: [`${A} sütununun değeri ${a}, ${B} sütununun değeri ${b}'dir.`, `Fark ${a} - ${b} = ${f} olur.`],
        dogrulama: [{ yol: ['degerler', A], beklenen: a }, { yol: ['degerler', B], beklenen: b }] });
    } else if (kind === 'toplam') {
      const [A, B] = karistir(adlar).slice(0, 2), a = v[A], b = v[B], s = a + b;
      const secilen = uc([
        { m: s + e.adim, g: 'Toplam bir çizgi kadar fazla okunmuştur.' },
        { m: s - e.adim, g: 'Toplam bir çizgi kadar eksik okunmuştur.' },
        { m: Math.abs(a - b), g: 'İki değerin farkı alınmış, toplama işlemi yapılmamıştır.' },
        { m: Math.max(a, b), g: 'Yalnızca büyük değer yazılmış, toplama işlemi yapılmamıştır.' },
      ], s);
      ekle({ ...ortak, zorluk: 1, dogru: String(s), celdirici: secilen.map((x) => String(x.m)), gerekce: secilen.map((x) => x.g),
        kok: `Yukarıdaki sütun grafiği "${t.baslik}" konusunda bilgi vermektedir. Buna göre ${A} ve ${B} sütunlarındaki değerlerin toplamı kaçtır?`,
        cozum: [`${A} sütununun değeri ${a}, ${B} sütununun değeri ${b}'dir.`, `Toplam ${a} + ${b} = ${s} olur.`],
        dogrulama: [{ yol: ['degerler', A], beklenen: a }, { yol: ['degerler', B], beklenen: b }] });
    } else {
      const sirali = [...adlar].sort((x, y) => v[y] - v[x]);
      const enB = sirali[0], enK = sirali[sirali.length - 1], f = v[enB] - v[enK];
      const secilen = uc([
        { m: v[enB] + v[enK], g: 'En yüksek ve en alçak değerler toplanmış, fark alınmamıştır.' },
        { m: v[enB], g: 'Yalnızca en yüksek değer yazılmış, fark hesaplanmamıştır.' },
        { m: v[enK], g: 'Yalnızca en alçak değer yazılmış, fark hesaplanmamıştır.' },
        { m: f + e.adim, g: 'Fark bir çizgi kadar fazla okunmuştur.' },
        { m: f - e.adim, g: 'Fark bir çizgi kadar eksik okunmuştur.' },
      ], f);
      ekle({ ...ortak, zorluk: 2, dogru: String(f), celdirici: secilen.map((x) => String(x.m)), gerekce: secilen.map((x) => x.g),
        kok: `Yukarıdaki sütun grafiği "${t.baslik}" konusunda bilgi vermektedir. Buna göre en yüksek sütun ile en alçak sütun arasındaki fark kaçtır?`,
        cozum: [`En yüksek sütun ${enB} (${v[enB]}), en alçak sütun ${enK} (${v[enK]}) değerindedir.`, `Fark ${v[enB]} - ${v[enK]} = ${f} olur.`],
        dogrulama: [{ yol: ['en_cok'], beklenen: enB }, { yol: ['en_az'], beklenen: enK }] });
    }
  }

  // M.4.3.3.1: bağlantılı birimkarelerden oluşan şeklin alanı = birimkare sayısı.
  function birimkareSorusu() {
    const n = sec([3, 4, 5, 6, 7, 8, 9, 10]);
    const h = new Set(['0,0']); const hucre = [[0, 0]];
    let guard = 0;
    while (hucre.length < n && guard++ < 400) {
      const [c, r] = sec(hucre);
      const [dc, dr] = sec([[1, 0], [-1, 0], [0, 1], [0, -1]]);
      const anahtar = `${c + dc},${r + dr}`;
      if (!h.has(anahtar)) { h.add(anahtar); hucre.push([c + dc, r + dr]); }
    }
    if (hucre.length < n) throw new Error('sekil_uretilemedi');
    const minC = Math.min(...hucre.map(([c]) => c)), minR = Math.min(...hucre.map(([, r]) => r));
    const norm = hucre.map(([c, r]) => [c - minC, r - minR]).sort((x, y) => x[1] - y[1] || x[0] - y[0]);
    const en = Math.max(...norm.map(([c]) => c)) + 1, boy = Math.max(...norm.map(([, r]) => r)) + 1;
    if (en < 2 || boy < 2 || en > 7 || boy > 6) throw new Error('sekil_olcu');
    // Çeldiriciler alan hesabına bağlı yanlış stratejilerdir (pencere değil); doğru şıkkın sıralı konumu rastgele seçilir.
    const kenar = new Set(norm.map(([c, r]) => `${c},${r}`));
    let cevre = 0;
    for (const [c, r] of norm) for (const [dc, dr] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) if (!kenar.has(`${c + dc},${r + dr}`)) cevre++;
    const hepsi = [
      { m: cevre, g: 'Şeklin çevresindeki kenar sayısı sayılmıştır; alan birimkare sayısıdır.' },
      { m: en * boy, g: 'Şeklin içine girdiği dikdörtgenin tüm kareleri sayılmış, taralı olmayan kareler de eklenmiştir.' },
      { m: 4 * n, g: 'Her karenin dört kenarı ayrı ayrı sayılmıştır.' },
      { m: en + boy, g: 'Yalnızca satır ve sütun sayıları toplanmıştır.' },
      { m: 2 * n, g: 'Birimkare sayısı iki katına çıkarılmıştır.' },
      { m: n + en, g: 'Birimkare sayısına şeklin genişliği eklenmiştir.' },
      { m: n + boy, g: 'Birimkare sayısına şeklin yüksekliği eklenmiştir.' },
      { m: cevre / 2, g: 'Çevre uzunluğunun yarısı alınmıştır; alan birimkare sayısıdır.' },
      { m: en * boy - n, g: 'Taralı olmayan boş kareler sayılmıştır.' },
      { m: n * en, g: 'Birimkare sayısı şeklin genişliğiyle çarpılmıştır.' },
      { m: n - en, g: 'Şeklin bir sütunundaki birimkareler sayılmamıştır.' },
      { m: n - boy, g: 'Şeklin bir satırındaki birimkareler sayılmamıştır.' },
      { m: Math.ceil(n / 2), g: 'Birimkarelerin yalnızca yarısı sayılmıştır.' },
      { m: Math.max(en, boy) + 1, g: 'Şeklin en uzun kenarındaki kare sayısına bakılmıştır.' },
      { m: Math.floor(n / 2) + boy, g: 'Birimkarelerin yarısı sayılıp satır sayısı eklenmiştir.' },
      { m: n - 2 * boy + 1, g: 'Satırların ilk kareleri sayılmamıştır.' },
    ].filter((x) => Number.isInteger(x.m) && x.m > 0 && x.m !== n && x.m <= 40);
    // Doğru şıkkın sıralı konumu (0-3) rastgele olsun; ortanca konum tek başına ipucu vermesin.
    const hedef = sec([0, 1, 2, 3]);
    let secilen = null;
    for (let d = 0; d < 80 && !secilen; d++) {
      const s3 = [];
      for (const x of karistir(hepsi)) { if (!s3.some((y) => y.m === x.m)) s3.push(x); if (s3.length === 3) break; }
      if (s3.length < 3) break;
      if (s3.filter((x) => x.m < n).length === hedef) secilen = s3;
    }
    if (!secilen) throw new Error('celdirici_yetersiz');    ekle({ kod: 'M.4.3.3.1', konu: 'Alan Ölçme', alt_konu: 'Birimkarelerle alan', zorluk: n >= 7 ? 2 : 1,
      spec: { tip_id: 'a3-izgara-sekil', parametreler: { en, boy, hucreler: norm } },
      kok: 'Yukarıdaki kareli zeminde taralı şeklin alanı kaç birimkaredir?',
      dogru: String(n), celdirici: secilen.map((x) => String(x.m)),
      gerekce: secilen.map((x) => x.g),
      ipucu: 'Şekli oluşturan her birimkareyi tek tek say; kenar çizgilerini değil, kareleri say.',
      cozum: [`Taralı şekil ${n} birimkareden oluşur.`, `Alan, birimkare sayısına eşit olduğundan ${n} birimkaredir.`],
      dogrulama: [{ yol: ['alan'], beklenen: n }] });
  }

  // M.4.2.3.4: dört açıdan biri verilen türde (dar, dik, geniş); diğer üçü farklı türde.
  function aciSorusu() {
    const T = sec(['dar', 'dik', 'genis']);
    const diger = ['dar', 'dik', 'genis'].filter((x) => x !== T);
    const turler = karistir([T, sec(diger), sec(diger), sec(diger)]);
    const deger = (tur) => (tur === 'dar' ? 15 + Math.floor(R() * 64) : tur === 'dik' ? 90 : 100 + Math.floor(R() * 66));
    const paneller = turler.map((tur, i) => ({ harf: PANEL_HARF[i], tur, aci: deger(tur), rot: 15 * Math.floor(R() * 24) }));
    const sirali = paneller.map((p) => p.aci).sort((x, y) => x - y);
    for (let i = 1; i < sirali.length; i++) if (sirali[i] - sirali[i - 1] < 12) throw new Error('aci_yakin');
    const dogruP = paneller.find((p) => p.tur === T);
    const celP = paneller.filter((p) => p !== dogruP);
    ekle({ kod: 'M.4.2.3.4', konu: 'Geometride Temel Kavramlar', alt_konu: 'Açı türleri', zorluk: 1,
      spec: { tip_id: 'a3-acilar', parametreler: { paneller } },
      kok: `Yukarıdaki dört açıdan hangisi ${TUR_AD[T]} açıdır?`,
      dogru: dogruP.harf, celdirici: celP.map((p) => p.harf),
      gerekce: celP.map((p) => `${p.harf} açısı ${p.aci}° ölçülüdür; ${TUR_AD[p.tur]} açıdır, ${TUR_AD[T]} açı değildir.`),
      ipucu: 'Dar açı 90°den küçük, dik açı tam 90°, geniş açı 90° ile 180° arasındadır.',
      cozum: [`Dar açılar 90°den küçük, geniş açılar 90° ile 180° arasındadır.`, `${dogruP.harf} açısı ${dogruP.aci}° olduğundan ${TUR_AD[T]} açıdır.`],
      dogrulama: paneller.map((p) => ({ yol: ['turler', p.harf], beklenen: p.tur })) });
  }

  return { sutunSorusu, birimkareSorusu, aciSorusu };
}

const T = { ders: 'Matematik', sinif: 4, mufredat_surum: MUFREDAT, fabrika: kur };
export const KAYIT = [
  { ...T, id: 'mat4-ek-sutun-problem', idOnek: 'MAT4-SUT', kodlar: ['M.4.4.1.4'], uret: (f) => f.sutunSorusu() },
  { ...T, id: 'mat4-ek-birimkare-alan', idOnek: 'MAT4-BKA', kodlar: ['M.4.3.3.1'], uret: (f) => f.birimkareSorusu() },
  { ...T, id: 'mat4-ek-aci-turu', idOnek: 'MAT4-ACT', kodlar: ['M.4.2.3.4'], uret: (f) => f.aciSorusu() },
];
