// 3. sınıf Matematik — çetele tablosu (MAT.3.4.1) ve simetri doğruları (MAT.3.3.6).
// Şekil tipleri: b1-cetele, b1-simetri-dogrulari (tipler-b1.mjs). Simetri doğruluğu yansıtma ile sayısal hesaplanır.
import { simetriMi } from '../tipler-b1.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 3. sınıf; program: TYMM)';
const TEMALAR = [
  { baslik: 'Sevilen Meyveler', ad: ['Elma', 'Armut', 'Muz', 'Çilek', 'Kiraz'], nesne: 'öğrenci' },
  { baslik: 'Okuldaki Kuşlar', ad: ['Serçe', 'Güvercin', 'Karga', 'Kumru', 'Martı'], nesne: 'kuş' },
  { baslik: 'Okunan Kitaplar', ad: ['Masal', 'Şiir', 'Hikâye', 'Roman', 'Fen'], nesne: 'kitap' },
  { baslik: 'Bahçedeki Çiçekler', ad: ['Gül', 'Lale', 'Papatya', 'Menekşe', 'Sümbül'], nesne: 'çiçek' },
];
const pencere = (c, kp, adim, min = 0, max = Infinity) => {
  const a = [0, 1, 2, 3].map((i) => c + (i - kp) * adim);
  if (a.some((v) => v < min || v > max)) throw new Error('pencere_disi');
  return a;
};

export function kur({ R, sec, karistir, ekle, konum }) {
  // ---------- çetele ----------
  function tablo(n) {
    const t = sec(TEMALAR), adlar = karistir(t.ad).slice(0, n), tut = new Set();
    for (let g = 0; g < 200 && tut.size < n; g++) tut.add(3 + Math.floor(R() * 22));
    if (tut.size < n) throw new Error('deger_yok');
    const satirlar = adlar.map((ad, i) => ({ ad, adet: [...tut][i] }));
    return { t, adlar, satirlar, v: Object.fromEntries(satirlar.map((r) => [r.ad, r.adet])), spec: { tip_id: 'b1-cetele', parametreler: { baslik: t.baslik, satirlar } } };
  }
  const gruplar = (a) => Math.floor(a / 5);
  const sec3 = (aday, dogru) => { const gor = new Set([dogru]), c = []; for (const x of karistir(aday)) { if (x.v >= 1 && !gor.has(x.v)) { gor.add(x.v); c.push(x); } if (c.length === 3) break; } if (c.length < 3) throw new Error('celdirici_yok'); return c; };
  function ceteleDeger() {
    const g = tablo(sec([2, 3, 4])), X = sec(g.adlar), c = g.v[X], G = gruplar(c);
    const aday = [{ v: c + 1, g: 'bir çizgi fazla sayılmıştır' }, { v: c - 1, g: 'bir çizgi eksik sayılmıştır' }, { v: c + 5, g: 'bir beşli grup fazla sayılmıştır' }, { v: c - 5, g: 'bir beşli grup eksik sayılmıştır' }];
    if (G >= 1) aday.push({ v: c - G, g: 'beşli gruplardaki çapraz çizgiler sayılmamıştır (her grup 5 sayılmalıdır)' }, { v: G + (c % 5), g: 'her beşli grup 1 sayılmıştır' });
    const cel = sec3(aday, c);
    ekle({ kod: 'MAT.3.4.1', konu: 'Veri', alt_konu: 'Çetele tablosunu okuma', zorluk: c < 10 ? 1 : 2, dogru: String(c), celdirici: cel.map((x) => String(x.v)), gerekce: cel.map((x) => `${x.v}: ${x.g}.`),
      kok: `Yukarıdaki çetele tablosunda “${X}” kaç ${g.t.nesne} göstermektedir?`, ipucu: 'Çaprazlı grup 5 çizgiyi gösterir. Grupları 5’er 5’er say, kalan çizgileri ekle.',
      cozum: [`${X} satırında ${G} tam grup (${G} × 5 = ${G * 5}) ve ${c % 5} çizgi vardır.`, `${G * 5} + ${c % 5} = ${c}.`], spec: g.spec, dogrulama: [{ yol: ['degerler', X], beklenen: c }] });
  }
  function ceteleEnCok() {
    const g = tablo(4), s = [...g.satirlar].sort((a, b) => b.adet - a.adet), dogru = s[0].ad, cel = karistir(s.slice(1).map((r) => r.ad));
    ekle({ kod: 'MAT.3.4.1', konu: 'Veri', alt_konu: 'Çetelede en çok', zorluk: 1, dogru, celdirici: cel, gerekce: cel.map((c) => `${c} satırında ${g.v[c]} çizgi var; en çok ${dogru} satırında (${g.v[dogru]}) vardır.`),
      kok: `Yukarıdaki çetele tablosuna göre en çok ${g.t.nesne} hangi satırdadır?`, ipucu: 'Her satırdaki çizgileri say ve karşılaştır.', cozum: ['Satırlardaki çizgiler 5’er 5’er sayılır.', `En çok çizgi ${dogru} satırındadır.`],
      spec: g.spec, dogrulama: [{ yol: ['en_cok'], beklenen: dogru }] });
  }
  function ceteleFark() {
    const g = tablo(sec([2, 3, 4])), [A, B] = karistir(g.adlar).slice(0, 2), a = g.v[A], b = g.v[B], f = Math.abs(a - b);
    const cel = sec3([{ v: a + b, g: 'iki değer toplanmıştır; fark için çıkarma yapılmalıdır' }, { v: Math.max(a, b), g: 'yalnız büyük satırın değeridir' }, { v: Math.min(a, b), g: 'yalnız küçük satırın değeridir' }, { v: f + 1, g: 'fark bir fazla bulunmuştur' }, { v: f - 1, g: 'fark bir eksik bulunmuştur' }, { v: f + 5, g: 'fark beş fazla bulunmuştur' }], f);
    ekle({ kod: 'MAT.3.4.1', konu: 'Veri', alt_konu: 'Çetelede iki satırın farkı', zorluk: 2, dogru: String(f), celdirici: cel.map((x) => String(x.v)), gerekce: cel.map((x) => `${x.v}: ${x.g}.`),
      kok: `Yukarıdaki çetele tablosunda “${A}” ile “${B}” satırları arasındaki ${g.t.nesne} sayısı farkı kaçtır?`, ipucu: 'İki satırı ayrı ayrı say, büyükten küçüğü çıkar.',
      cozum: [`${A} = ${a}, ${B} = ${b} bulunur.`, `Fark: ${Math.max(a, b)} − ${Math.min(a, b)} = ${f}.`], spec: g.spec, dogrulama: [{ yol: ['degerler', A], beklenen: a }, { yol: ['degerler', B], beklenen: b }] });
  }
  function ceteleToplam() {
    const g = tablo(sec([2, 3])), tp = g.satirlar.reduce((t, r) => t + r.adet, 0), G = g.satirlar.reduce((t, r) => t + gruplar(r.adet), 0);
    const cel = sec3([{ v: tp + 1, g: 'bir çizgi fazla sayılmıştır' }, { v: tp - 1, g: 'bir çizgi eksik sayılmıştır' }, { v: tp + 5, g: 'bir beşli grup fazla sayılmıştır' }, { v: tp - 5, g: 'bir beşli grup eksik sayılmıştır' }, { v: tp - G, g: 'çapraz çizgiler sayılmamıştır' }, { v: tp + 10, g: 'iki beşli grup fazla sayılmıştır' }], tp);
    ekle({ kod: 'MAT.3.4.1', konu: 'Veri', alt_konu: 'Çetelede toplam', zorluk: 2, dogru: String(tp), celdirici: cel.map((x) => String(x.v)), gerekce: cel.map((x) => `${x.v}: ${x.g}.`),
      kok: `Yukarıdaki çetele tablosuna göre toplam kaç ${g.t.nesne} vardır?`, ipucu: 'Her satırın değerini bul ve hepsini topla.',
      cozum: [`Satırların değerleri: ${g.satirlar.map((r) => r.adet).join(', ')}.`, `Toplam: ${g.satirlar.map((r) => r.adet).join(' + ')} = ${tp}.`], spec: g.spec, dogrulama: [{ yol: ['toplam'], beklenen: tp }] });
  }

  // ---------- simetri doğruları ----------
  const ACILAR = Array.from({ length: 12 }, (_, i) => i * 15);
  const uzak = (a, b) => { const d = Math.abs(a - b) % 180; return Math.min(d, 180 - d) >= 30; };
  function sec_uzak(adaylar, n, once = []) { // en az 30° aralıklı n doğru
    const s = [...once];
    for (const a of karistir(adaylar)) { if (s.every((b) => uzak(a, b))) s.push(a); if (s.length === n) return s; }
    throw new Error('dogru_secilemedi');
  }
  function simetriSay() {
    const sekil = sec(['kare', 'dikdortgen', 'daire']), m = sec([3, 4]), aci = sec_uzak(ACILAR, m), ans = aci.filter((a) => simetriMi(sekil, a)).length, kp = konum();
    if (ans < 1) throw new Error('simetri_yok');
    const sirali = pencere(ans, kp, 1, 0, 5).map(String);
    const sim = aci.map((a, i) => [a, i + 1]).filter(([a]) => simetriMi(sekil, a)).map(([, i]) => i);
    ekle({ kod: 'MAT.3.3.6', konu: 'Geometri', alt_konu: 'Simetri doğrusu sayma', zorluk: sekil === 'daire' ? 1 : 2, sirali, dogru: String(ans),
      gerekce: sirali.map((x) => (Number(x) === ans ? '' : `${x}: şekil bu doğrular boyunca katlandığında iki yarısı tam üst üste gelenler sayılınca ${ans} bulunur.`)),
      kok: 'Yukarıdaki şeklin içinde numaralı kesikli doğrular çizilmiştir. Bu doğrulardan kaç tanesi şeklin simetri doğrusudur?',
      ipucu: 'Şekli bir doğru boyunca katladığını düşün. İki yarım tam üst üste geliyorsa doğru simetri doğrusudur.',
      cozum: [`Her doğru boyunca katlanınca iki yarısı üst üste gelen doğrular bulunur.`, `Simetri doğruları: ${sim.join(', ')} numaralı doğrulardır; toplam ${ans}.`],
      spec: { tip_id: 'b1-simetri-dogrulari', parametreler: { sekil, dogrular: aci } }, dogrulama: [{ yol: ['sayi'], beklenen: ans }] });
  }
  function simetriSec() {
    const sekil = sec(['kare', 'dikdortgen']), kp = konum(), S = ACILAR.filter((a) => simetriMi(sekil, a)), N = ACILAR.filter((a) => !simetriMi(sekil, a));
    const dogruAci = sec(S), digerleri = sec_uzak(N, 4, [dogruAci]).slice(1), aci = [];
    let j = 0; for (let i = 0; i < 4; i++) aci.push(i === kp ? dogruAci : digerleri[j++]);
    const sirali = ['1 numaralı doğru', '2 numaralı doğru', '3 numaralı doğru', '4 numaralı doğru'];
    ekle({ kod: 'MAT.3.3.6', konu: 'Geometri', alt_konu: 'Simetri doğrusunu belirleme', zorluk: 2, sirali, dogru: sirali[kp],
      gerekce: sirali.map((_, i) => (i === kp ? '' : `${i + 1} numaralı doğru boyunca katlanınca şeklin iki yarısı üst üste gelmez; bu doğru simetri doğrusu değildir.`)),
      kok: 'Yukarıdaki şekil için numaralı kesikli doğrulardan hangisi simetri doğrusudur?', ipucu: 'Şekli doğru boyunca katladığını düşün; iki yarım tam üst üste gelmeli.',
      cozum: ['Her doğru boyunca katlama düşünülür.', `Yalnız ${kp + 1} numaralı doğrunun iki yanındaki parçalar tam üst üste gelir.`],
      spec: { tip_id: 'b1-simetri-dogrulari', parametreler: { sekil, dogrular: aci } }, dogrulama: aci.map((_, i) => ({ yol: ['cizgiler', String(i + 1)], beklenen: i === kp })) });
  }
  return { cetele: () => sec([ceteleDeger, ceteleDeger, ceteleEnCok, ceteleFark, ceteleToplam])(), simetri: () => sec([simetriSay, simetriSec])() };
}

export const KAYIT = [
  { id: 'mat3-cetele-tablosu', ders: 'Matematik', sinif: 3, idOnek: 'MAT3-CTL', mufredat_surum: MUFREDAT, kodlar: ['MAT.3.4.1'], fabrika: kur, uret: (f) => f.cetele() },
  { id: 'mat3-simetri-dogrusu', ders: 'Matematik', sinif: 3, idOnek: 'MAT3-SIM', mufredat_surum: MUFREDAT, kodlar: ['MAT.3.3.6'], fabrika: kur, uret: (f) => f.simetri() },
];
