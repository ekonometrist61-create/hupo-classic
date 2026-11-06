// 7. sınıf Matematik — eş küplerle oluşturulan yapıların görünümleri (MAT.7.4.1). Sütun yükseklikleri yalnız üstten görünüm şeklindedir.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 7. sınıf; program: TYMM)';
const GIRIS = 'Aşağıda, eş birim küplerden yapılmış bir yapının üstten görünümü verilmiştir. Her karedeki sayı, o sütunda üst üste kaç küp bulunduğunu gösterir.';

export function kur({ R, sec, ekle, konum }) {
  const rast = (a, b) => a + Math.floor(R() * (b - a + 1));
  function kupSorusu() {
    const tur = sec(['toplam', 'on', 'sag', 'yuzey']), satir = rast(2, 3), sutun = rast(2, 4);
    const g = Array.from({ length: satir }, () => Array.from({ length: sutun }, () => (R() < 0.12 ? 0 : rast(1, 4))));
    if (g.flat().filter((h) => h > 0).length < 4 || new Set(g.flat()).size < 3) throw new Error('yapi_zayif');
    const spec = { tip_id: 'a4-kup-ust', parametreler: { yukseklik: g } };
    const T = g.flat().reduce((a, b) => a + b, 0);
    const on = Array.from({ length: sutun }, (_, j) => Math.max(...g.map((r) => r[j]))).reduce((a, b) => a + b, 0);
    const sag = g.map((r) => Math.max(...r)).reduce((a, b) => a + b, 0);
    const kp = konum();
    let yuzey = 0;
    g.forEach((r, i) => r.forEach((h, j) => { if (!h) return; yuzey += 2; for (const [di, dj] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) yuzey += Math.max(0, h - (g[i + di]?.[j + dj] ?? 0)); }));
    const T_ = { toplam: T, on, sag, yuzey }[tur], adim = tur === 'yuzey' ? 2 : 1;
    if (T_ - kp * adim < 1) throw new Error('pencere');
    const sirali = [0, 1, 2, 3].map((i) => String(T_ + (i - kp) * adim));
    const soru = {
      toplam: 'Bu yapı kaç birim küpten oluşmuştur?',
      on: 'Bu yapıya ÖN yazılı taraftan bakıldığında kaç birim kare görülür?',
      sag: 'Bu yapıya SAĞ yazılı taraftan bakıldığında kaç birim kare görülür?',
      yuzey: 'Bu yapının tabanı dahil tüm dış yüzeyi boyanırsa kaç birim kare yüzey boyanmış olur?',
    }[tur];
    const olguAd = { toplam: 'toplam', on: 'on_gorunum_kare', sag: 'sag_gorunum_kare', yuzey: 'dis_yuzey' }[tur];
    const nedenTxt = { toplam: 'bir sütundaki küp sayısı yanlış sayıldığında', on: 'bir sütunun yüksekliği yanlış alındığında', sag: 'bir satırın en yüksek sütunu yanlış alındığında', yuzey: 'bir yüzey eksik ya da fazla sayıldığında' }[tur];
    ekle({ kod: 'MAT.7.4.1', konu: 'Geometri', alt_konu: 'Küp yapıları ve görünümleri', zorluk: tur === 'toplam' ? 1 : tur === 'yuzey' ? 3 : 2, spec,
      kok: `${GIRIS} ${soru}`, sirali, dogru: String(T_),
      gerekce: sirali.map((c, i) => (i === kp ? '' : `${c}, ${nedenTxt} bulunur; şekle göre doğru değer ${T_}'dir.`.replace("'dir", ' olur'))),
      ipucu: { toplam: 'Her karedeki sayıları topla.', on: 'Önden bakınca her dikey sıradaki en yüksek sütun görünür.', sag: 'Sağdan bakınca her yatay sıradaki en yüksek sütun görünür.', yuzey: 'Üst ve alt yüzleri say; yan yüzleri komşu sütunlara göre sayma.' }[tur],
      cozum: {
        toplam: [`Sayılar toplanır: ${g.flat().filter((h) => h).join(' + ')} = ${T}.`],
        on: ['Önden bakınca her dikey sıranın en yüksek sütunu görünür.', `Bu değerler toplanır: ${on}.`],
        sag: ['Sağdan bakınca her yatay sıranın en yüksek sütunu görünür.', `Bu değerler toplanır: ${sag}.`],
        yuzey: ['Her sütunun üst ve alt yüzü boyanır; yan yüzlerde komşu sütundan yüksek kısım boyanır.', `Toplam boyanan yüzey ${yuzey} birim karedir.`],
      }[tur],
      dogrulama: [{ yol: [olguAd], beklenen: T_ }] });
  }
  return { kupSorusu };
}
export const KAYIT = [
  { id: 'mat7-kup-yapi', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-KUP', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.4.1'], fabrika: kur, uret: (f) => f.kupSorusu() },
];
