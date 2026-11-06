// 4. sınıf Matematik (önceki program) — kesir modelleri: bileşik/tam sayılı kesir, birim kesir ve eş paydalı kesir sıralama.
// Şıklar: tam sayılı/bileşik kesirde 2×2 ızgara (bütün ±1, parça ±1), sıralamada permütasyonlar, "en büyük/küçük"te sabit harfler.
// Hiçbir şık tek bir parametreye işaret etmez; payda, bütün ve pay yalnız şekilde görünür.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 4. sınıf; program: önceki program)';

export function kur({ R, sec, karistir, ekle, konum }) {
  const fz = (n) => (n > 0 ? 'fazla' : 'eksik');

  function karmaSorusu() {
    const payda = sec([3, 4, 5, 6, 8]), butun = sec([1, 2, 3]), pay = 1 + Math.floor(R() * (payda - 1)), tur = sec(['serit', 'pasta']);
    const bicim = sec(['bilesik', 'tamsayili']);
    const d1 = sec([-1, 1]), d2 = sec([-1, 1]);
    const b2 = butun + d1, p2 = pay + d2;
    if (b2 < 1 || p2 < 1 || p2 > payda - 1) throw new Error('izgara_disi');
    const bic = (b, p) => (bicim === 'bilesik' ? `${b * payda + p}/${payda}` : `${b} ${p}/${payda}`);
    const dogru = bic(butun, pay);
    const cel = [
      { m: bic(b2, pay), g: bicim === 'bilesik' ? `Bütün sayısı ${Math.abs(d1)} ${fz(d1)} sayılmıştır; ${b2 * payda + pay}/${payda} bu hatayla bulunur.` : `Tam sayılı kesrin tam kısmı bir ${fz(d1)} yazılmıştır.` },
      { m: bic(butun, p2), g: bicim === 'bilesik' ? `Taralı parçalardan biri ${d2 > 0 ? 'fazla' : 'eksik'} sayılmıştır.` : `Kesir kısmındaki taralı parça sayısı bir ${fz(d2)} yazılmıştır.` },
      { m: bic(b2, p2), g: 'Hem bütün sayısı hem de taralı parça sayısı yanlış alınmıştır.' },
    ];
    const k = karistir(cel);
    ekle({ kod: 'M.4.1.6.1', konu: 'Kesirler', alt_konu: bicim === 'bilesik' ? 'Bileşik kesir modeli' : 'Tam sayılı kesir modeli', zorluk: bicim === 'bilesik' ? 3 : 2,
      spec: { tip_id: 'a3-kesir-modeli-cok', parametreler: { tur, payda, butun, pay } },
      kok: bicim === 'bilesik' ? 'Yukarıdaki modelde taralı bölge hangi bileşik kesirle gösterilir?' : 'Yukarıdaki modelde taralı bölge hangi tam sayılı kesirle gösterilir?',
      dogru, celdirici: k.map((x) => x.m), gerekce: k.map((x) => x.g),
      ipucu: 'Önce tamamen taralı şekilleri, sonra son şekilde taralı parçaları say; bir şekil kaç eş parçaya bölünmüş?',
      cozum: [`Her şekil ${payda} eş parçaya bölünmüştür.`, `${butun} şekil tamamen, bir şekilde ${pay} parça taralıdır.`,
        bicim === 'bilesik' ? `${butun} × ${payda} + ${pay} = ${butun * payda + pay} parça olduğundan kesir ${dogru} olur.` : `Tam kısım ${butun}, kesir kısmı ${pay}/${payda}; kesir ${dogru} olur.`],
      dogrulama: [{ yol: [bicim === 'bilesik' ? 'bilesik' : 'tam_sayili'], beklenen: dogru }] });
  }

  const HARF = ['A', 'B', 'C', 'D', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T'];
  const PERM3 = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]];
  // birim=true: tüm şeritlerde pay 1, paydalar farklı (M.4.1.6.2). birim=false: ortak payda, farklı pay (M.4.1.6.4).
  function siralaSorusu(birim) {
    const kod = birim ? 'M.4.1.6.2' : 'M.4.1.6.4';
    const harf = karistir(HARF);
    const sekil = sec(['sirala', 'sirala', 'en']);
    const n = sekil === 'sirala' ? 3 : 4;
    let seritler;
    if (birim) {
      const paydalar = karistir([2, 3, 4, 5, 6, 8, 10, 12]).slice(0, n);
      seritler = paydalar.map((d, i) => ({ ad: harf[i], payda: d, pay: 1 }));
    } else {
      const payda = sec([5, 6, 8, 10, 12]);
      const paylar = karistir(Array.from({ length: payda - 1 }, (_, i) => i + 1)).slice(0, n);
      if (paylar.length < n) throw new Error('pay_yetersiz');
      seritler = paylar.map((pa, i) => ({ ad: harf[i], payda, pay: pa }));
    }
    const deger = (x) => x.pay / x.payda;
    const baz = { kod, konu: 'Kesirler', alt_konu: birim ? 'Birim kesirleri karşılaştırma ve sıralama' : 'Paydaları eşit kesirleri karşılaştırma' };
    const ipucuBirim = 'Birim kesirlerde payda büyüdükçe parçalar küçülür; şeritlerdeki taralı parçaların büyüklüğüne bak.';
    const ipucuEsit = 'Paydalar eşitse taralı parça sayısı fazla olan kesir daha büyüktür.';
    if (sekil === 'sirala') {
      const buyukten = !birim ? sec([true, false]) : sec([true, false]);
      const sirali = [...seritler].sort((a, b) => (buyukten ? deger(b) - deger(a) : deger(a) - deger(b))).map((x) => x.ad);
      const bicim = (dizi) => dizi.join(buyukten ? ' > ' : ' < ');
      const ad = seritler.map((x) => x.ad);
      const tum = PERM3.map((pr) => pr.map((i) => ad[i]));
      const dogruStr = bicim(sirali);
      const digerler = karistir(tum.filter((d) => bicim(d) !== dogruStr));
      const cel = digerler.slice(0, 3);
      const ters = [...sirali].reverse();
      ekle({ ...baz, zorluk: 2, spec: { tip_id: 'a3-kesir-seritleri', parametreler: { seritler: karistir(seritler) } },
        kok: buyukten ? 'Yukarıdaki şeritlerde taralı bölgelerin gösterdiği kesirler büyükten küçüğe doğru sıralanırsa hangisi doğru olur?' : 'Yukarıdaki şeritlerde taralı bölgelerin gösterdiği kesirler küçükten büyüğe doğru sıralanırsa hangisi doğru olur?',
        dogru: dogruStr, celdirici: cel.map(bicim),
        gerekce: cel.map((d) => (d.join() === ters.join() ? (birim ? 'Payda büyüdükçe birim kesir küçülür; sıralama tersine yapılmıştır.' : 'Taralı parça sayısı arttıkça kesir büyür; sıralama tersine yapılmıştır.') : 'Bu sıralamada en az iki şeridin yeri yanlıştır; taralı bölgelerin büyüklükleri karşılaştırılmamıştır.')),
        ipucu: birim ? ipucuBirim : ipucuEsit,
        cozum: [birim ? 'Her şeritte bir parça taralıdır; parçalar ne kadar büyükse kesir o kadar büyüktür.' : 'Şeritler aynı sayıda eş parçaya bölündüğü için taralı parça sayısı fazla olan kesir büyüktür.', `Doğru sıralama: ${dogruStr}.`],
        dogrulama: [{ yol: [buyukten ? 'buyukten_kucuge' : 'kucukten_buyuge'], beklenen: sirali }] });
    } else {
      const enBuyuk = sec([true, false]);
      const hedef = [...seritler].sort((a, b) => (enBuyuk ? deger(b) - deger(a) : deger(a) - deger(b)))[0];
      const kp = konum();
      const digerleri = karistir(seritler.filter((x) => x !== hedef).map((x) => x.ad));
      const sirali = [...digerleri]; sirali.splice(kp, 0, hedef.ad);
      const gerekce = sirali.map((h) => {
        if (h === hedef.ad) return '';
        const x = seritler.find((y) => y.ad === h);
        return birim ? `${h} şeridindeki parça ${enBuyuk ? 'en büyük değildir' : 'en küçük değildir'}; paydası ${x.payda}.` : `${h} şeridinde ${x.pay} parça taralıdır; ${enBuyuk ? 'en çok' : 'en az'} taralı olan şerit bu değildir.`;
      });
      ekle({ ...baz, zorluk: 1, spec: { tip_id: 'a3-kesir-seritleri', parametreler: { seritler: karistir(seritler) } },
        kok: birim ? (enBuyuk ? 'Yukarıdaki şeritlerden hangisinde taralı bölge en büyük kesri gösterir?' : 'Yukarıdaki şeritlerden hangisinde taralı bölge en küçük kesri gösterir?')
          : (enBuyuk ? 'Yukarıdaki şeritlerden hangisinde taralı bölge en büyük kesri gösterir?' : 'Yukarıdaki şeritlerden hangisinde taralı bölge en küçük kesri gösterir?'),
        sirali, dogru: hedef.ad, gerekce,
        ipucu: birim ? ipucuBirim : ipucuEsit,
        cozum: [birim ? 'Parçaların büyüklüklerini karşılaştır: payda ne kadar küçükse birim kesir o kadar büyüktür.' : 'Şeritler eş parçalıdır; taralı parça sayılarını karşılaştır.', `${enBuyuk ? 'En büyük' : 'En küçük'} kesir ${hedef.ad} şeridindeki ${hedef.pay}/${hedef.payda} kesridir.`],
        dogrulama: [{ yol: [enBuyuk ? 'en_buyuk' : 'en_kucuk'], beklenen: hedef.ad }] });
    }
  }
  return { karmaSorusu, siralaSorusu };
}

const T = { ders: 'Matematik', sinif: 4, mufredat_surum: MUFREDAT, fabrika: kur };
export const KAYIT = [
  { ...T, id: 'mat4-kesir-karma', idOnek: 'MAT4-KSR', kodlar: ['M.4.1.6.1'], uret: (f) => f.karmaSorusu() },
  { ...T, id: 'mat4-birim-kesir', idOnek: 'MAT4-BKS', kodlar: ['M.4.1.6.2'], uret: (f) => f.siralaSorusu(true) },
  { ...T, id: 'mat4-esit-payda', idOnek: 'MAT4-EPK', kodlar: ['M.4.1.6.4'], uret: (f) => f.siralaSorusu(false) },
];
