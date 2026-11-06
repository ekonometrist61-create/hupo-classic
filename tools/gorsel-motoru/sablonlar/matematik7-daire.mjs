// 7. sınıf Matematik — daire/çember uzunluğu (MAT.7.4.7) ve daire dilimi (MAT.7.4.8). Uzunluk ve açı yalnız şekilde; kökte sayı yok.
// Şıklar: yarıçap komşu değerleri için hesaplanmış sonuçlar (tek bir parametreye işaret etmez).
import { pencere } from '../tipler-a4.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 7. sınıf; program: TYMM)';
const BAGLAM = [
  { g: 'Şekilde daire biçimindeki bir tepsinin üstten görünümü verilmiştir.', gen: 'Bu tepsinin üst yüzünün', b: 'cm' },
  { g: 'Şekilde yuvarlak bir masanın üstten görünümü verilmiştir.', gen: 'Bu masanın üst yüzünün', b: 'cm' },
  { g: 'Şekilde daire biçimindeki bir pizzanın üstten görünümü verilmiştir.', gen: 'Bu pizzanın üst yüzünün', b: 'cm' },
  { g: 'Şekilde daire biçimindeki bir halının üstten görünümü verilmiştir.', gen: 'Bu halının üst yüzünün', b: 'm' },
  { g: 'Şekilde yuvarlak bir çiçek tarhının planı verilmiştir.', gen: 'Bu tarhın yüzeyinin', b: 'm' },
  { g: 'Şekilde daire biçimindeki bir havuzun üstten görünümü verilmiştir.', gen: 'Bu havuzun yüzeyinin', b: 'm' },
];
const BIRIM = { cm: ['santimetrekaredir', 'santimetredir'], m: ['metrekaredir', 'metredir'] };
const DILIM_BAGLAM = [
  { g: 'Şekilde daire dilimi biçimindeki bir pasta diliminin üstten görünümü verilmiştir.', n: 'pasta diliminin', b: 'cm' },
  { g: 'Şekilde daire dilimi biçimindeki bir bahçenin planı verilmiştir.', n: 'bahçenin', b: 'm' },
  { g: 'Şekilde yelpaze biçimindeki bir kâğıt parçası verilmiştir.', n: 'kâğıt parçasının', b: 'cm' },
  { g: 'Şekilde daire dilimi biçimindeki bir sulama alanı gösterilmiştir.', n: 'sulama alanının', b: 'm' },
];
const YONLER = [10, 20, 35, 50, 70, 110, 135, 200, 250];

export function kur({ R, sec, karistir, ekle, konum }) {
  function daireSorusu() {
    const b = sec(BAGLAM), tur = sec(['alan', 'cevre']), etiket = sec(['yaricap', 'cap']);
    const pi22 = R() < 0.2, pi = pi22 ? [22, 7] : [3, 1], pas = pi22 ? 7 : 1;
    const r = pi22 ? sec([7, 14]) : 3 + Math.floor(R() * 13);
    const deger = etiket === 'cap' ? 2 * r : r;
    const kp = konum();
    const f = tur === 'alan' ? (x) => (pi[0] * x * x) / pi[1] : (x) => (2 * pi[0] * x) / pi[1];
    const { ps, vs } = pencere(f, r, kp, [pas], pas);
    const spec = { tip_id: 'a4-daire', parametreler: { etiket, deger, birim: b.b, pi, yon: sec(YONLER) } };
    const piYaz = pi22 ? 'π = 22/7' : 'π = 3';
    const dogru = f(r), yk = tur === 'alan' ? 'alanı' : 'çevresi';
    ekle({ kod: 'MAT.7.4.7', konu: 'Ölçme', alt_konu: tur === 'alan' ? 'Dairenin alanı' : 'Çemberin uzunluğu', zorluk: tur === 'alan' ? 2 : 1, spec,
      kok: `${b.g} ${b.gen} ${yk} kaç ${BIRIM[b.b][tur === 'alan' ? 0 : 1]}? (${piYaz} alınız.)`,
      sirali: vs.map(String), dogru: String(dogru),
      gerekce: ps.map((x, i) => (x === r ? '' : `${vs[i]}, yarıçap ${x} ${b.b} alınarak bulunur; şekilden okunan ölçüye göre yarıçap ${r} ${b.b} uzunluğundadır.`)),
      ipucu: etiket === 'cap' ? 'Şekilde verilen doğru parçası merkezden geçiyor mu? Merkezden geçen parça çaptır; yarıçap onun yarısıdır.' : 'Önce şekildeki doğru parçasının çap mı yarıçap mı olduğuna bak.',
      cozum: [etiket === 'cap' ? `Şekildeki ${deger} ${b.b} merkezden geçtiği için çaptır; yarıçap ${deger} ÷ 2 = ${r} ${b.b}.` : `Şekildeki ${deger} ${b.b}, merkezden çember üzerine çizilen yarıçaptır.`,
        tur === 'alan' ? `Alan = π × r × r = ${piYaz.slice(4)} × ${r} × ${r} = ${dogru}.` : `Çevre = 2 × π × r = 2 × ${piYaz.slice(4)} × ${r} = ${dogru}.`],
      dogrulama: [{ yol: [tur === 'alan' ? 'alan' : 'cevre'], beklenen: dogru }, { yol: ['yaricap'], beklenen: r }] });
  }

  function dilimSorusu() {
    const b = sec(DILIM_BAGLAM), tur = sec(['alan', 'yay', 'cevre']);
    const aci = sec([45, 60, 90, 120, 135, 150, 180, 240, 270, 300]), r = 3 + Math.floor(R() * 14);
    const kp = konum();
    const f = (x) => (tur === 'alan' ? (3 * x * x * aci) / 360 : tur === 'yay' ? (6 * x * aci) / 360 : (6 * x * aci) / 360 + 2 * x);
    const { ps, vs } = pencere(f, r, kp, [1, 2, 3, 4, 5, 6, 8, 10, 12], 1);
    const spec = { tip_id: 'a4-daire', parametreler: { etiket: 'yaricap', deger: r, aci, birim: b.b, pi: [3, 1], baslangic: sec(YONLER) } };
    const dogru = f(r);
    const soru = tur === 'alan' ? `Bu ${b.n} alanı kaç ${BIRIM[b.b][0]}?` : tur === 'yay' ? `Bu ${b.n} yayının uzunluğu kaç ${BIRIM[b.b][1]}?` : `Bu ${b.n} çevresi kaç ${BIRIM[b.b][1]}?`;
    ekle({ kod: 'MAT.7.4.8', konu: 'Ölçme', alt_konu: tur === 'alan' ? 'Daire diliminin alanı' : 'Daire dilimi yay uzunluğu', zorluk: tur === 'alan' ? 2 : 3, spec,
      kok: `${b.g} ${soru} (π = 3 alınız.)`,
      sirali: vs.map(String), dogru: String(dogru),
      gerekce: ps.map((x, i) => (x === r ? '' : `${vs[i]}, yarıçap ${x} ${b.b} alınarak bulunur; şekildeki yarıçap ${r} ${b.b} uzunluğundadır.`)),
      ipucu: 'Dilimin merkez açısının 360° içindeki payını bul; bütün dairenin değerini bu payla çarp.',
      cozum: tur === 'alan' ? [`Merkez açı ${aci}° olduğundan dilim, dairenin ${aci}/360 kadarıdır.`, `Dilimin alanı = 3 × ${r} × ${r} × ${aci}/360 = ${dogru}.`]
        : tur === 'yay' ? [`Çemberin uzunluğu 2 × 3 × ${r} = ${6 * r} ${b.b}.`, `Yay uzunluğu = ${6 * r} × ${aci}/360 = ${dogru}.`]
          : [`Yay uzunluğu = 2 × 3 × ${r} × ${aci}/360 = ${(6 * r * aci) / 360}.`, `Çevre = yay + iki yarıçap = ${(6 * r * aci) / 360} + ${2 * r} = ${dogru}.`],
      dogrulama: [{ yol: [tur === 'alan' ? 'dilim_alan' : tur === 'yay' ? 'yay_uzunlugu' : 'dilim_cevre'], beklenen: dogru }, { yol: ['aci'], beklenen: aci }] });
  }
  return { daireSorusu, dilimSorusu };
}

export const KAYIT = [
  { id: 'mat7-daire', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-DAI', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.4.7'], fabrika: kur, uret: (f) => f.daireSorusu() },
  { id: 'mat7-dilim', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-DIL', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.4.8'], fabrika: kur, uret: (f) => f.dilimSorusu() },
];
