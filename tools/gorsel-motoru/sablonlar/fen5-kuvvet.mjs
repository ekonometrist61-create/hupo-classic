// 5. sınıf Fen Bilimleri — Kuvvet: dinamometre okuma şablonu.
// Şıklar ardışık bölme değerleri penceresidir (tek bir değere işaret etmez); doğru şık konumu harf dengesine göre.
const MUFREDAT = 'Maarif Modeli Fen DÖP (tymm 2026-09-02)';
const fmt = (v) => String(Math.round(v * 1000) / 1000).replace('.', ',');

export function kur({ R, sec, ekle, konum }) {
  function dinamometreSorusu() {
    const max = sec([5, 6, 8, 10]), bolmeSayisi = sec([1, 2, 5]), bolme = 1 / bolmeSayisi;
    const nTik = Math.round(max / bolme) + 1, k = konum();
    if (nTik < 4) throw new Error('pencere_cok_kucuk');
    const s = Math.floor(R() * (nTik - 3));              // pencere: tik s … s+3
    const dogruIdx = s + k, deger = Math.round(dogruIdx * bolme * 1000) / 1000;
    if (deger <= 0) throw new Error('sifir_deger');
    const idx = [0, 1, 2, 3].map((i) => s + i);
    const sirali = idx.map((i) => `${fmt(i * bolme)} N`);
    const gerekce = idx.map((i) => (i === dogruIdx ? '' : `${fmt(i * bolme)} N, ibrenin gösterdiği çizgiden ${Math.abs(i - dogruIdx)} bölme ${i > dogruIdx ? 'ileride' : 'geride'} bir çizgidir; bölmelerin değeri ya da sayısı yanlış okunmuştur.`));
    const tam = Math.floor(deger + 1e-9), fazla = Math.round((deger - tam) / bolme);
    ekle({ kod: 'FB.5.2.1', konu: 'Kuvvet', alt_konu: 'Dinamometre ile kuvvet ölçme', zorluk: bolmeSayisi === 1 ? 1 : bolmeSayisi === 2 ? 2 : 3,
      spec: { tip_id: 'dinamometre', parametreler: { max, buyuk: 1, bolme, deger } }, sirali, dogru: `${fmt(deger)} N`, gerekce,
      kok: 'Yukarıda bir cisme uygulanan kuvveti ölçen dinamometre verilmiştir. Dinamometrenin gösterdiği kuvvet kaç newton (N) değerindedir?',
      ipucu: bolmeSayisi === 1 ? 'İbrenin hangi sayının hizasında durduğuna bak.' : 'Önce iki sayı arasında kaç bölme olduğuna bakarak bir bölmenin kaç N olduğunu bul.',
      cozum: [bolmeSayisi === 1 ? 'Skalada her çizgi 1 N’lık artışı gösterir.' : `Skalada iki sayı (1 N) arası ${bolmeSayisi} eşit bölmeye ayrılmıştır; bir bölme ${fmt(bolme)} N’dır.`,
        bolmeSayisi === 1 ? `İbre ${fmt(deger)} çizgisini gösterir.` : `İbre ${tam} çizgisinden ${fazla} bölme ileridedir: ${tam} + ${fazla} × ${fmt(bolme)} = ${fmt(deger)} N.`],
      dogrulama: [{ yol: ['okunan_deger'], beklenen: deger }] });
  }
  return { dinamometreSorusu };
}

export const KAYIT = [
  { id: 'fen5-dinamometre', ders: 'Fen Bilimleri', sinif: 5, idOnek: 'FEN5-KUV', mufredat_surum: MUFREDAT, kodlar: ['FB.5.2.1'], fabrika: kur,
    uret: (f) => f.dinamometreSorusu() },
];
