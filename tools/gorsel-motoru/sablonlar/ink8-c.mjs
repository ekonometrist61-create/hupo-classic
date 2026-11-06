// 8. sınıf İnkılap Tarihi — Atatürk döneminde kurulan fabrika sayısının yıllara göre değişimini çizgi grafiğinden okuma (İTA.8.4.6).
// Veriler kurgusaldır (gerçek veri değildir); soru yalnız grafik okuma becerisini ölçer.
// Kök ve şıklar dönem/değer ipucu taşımaz; cevap yalnız eğriden okunur. Çeldiriciler grafikteki gerçek değerlerden türetilir.
import { sayisalSik } from './sosyal6-ortak.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (T.C. İnkılap Tarihi ve Atatürkçülük 8. sınıf; program: TYMM)';
const DERS = 'T.C. İnkılap Tarihi ve Atatürkçülük';
const OLCEKLER = [{ max: 100, adim: 20 }, { max: 50, adim: 10 }, { max: 200, adim: 40 }, { max: 60, adim: 10 }];
const BASLANGIC = [1930, 1931, 1932];

export function kur({ R, sec, karistir, ekle, konum }) {
  const BASLIK = 'Kurulan Fabrika Sayısı';
  function cizgiSorusu() {
    const y0 = sec(BASLANGIC), n = 6, e = Array.from({ length: n }, (_, i) => String(y0 + i));
    const { max, adim } = sec(OLCEKLER), adet = Math.floor(max / adim);
    const tur = sec(['en_cok_artis', 'azalis', 'oku', 'fark', 'esik', 'en_yuksek']), k = konum();
    const per = (i) => `${e[i]} – ${e[i + 1]}`;
    const uret = (kosul) => {
      for (let g = 0; g < 500; g++) {
        const v = Array.from({ length: n }, () => adim * (1 + Math.floor(R() * adet)));
        const d = v.slice(1).map((x, i) => x - v[i]);
        if (kosul(v, d)) return v;
      }
      throw new Error('veri_uretilemedi');
    };
    const tekilMi = (d) => new Set(d).size === d.length;
    const kosul = {
      en_cok_artis: (v, d) => d.every((x) => x !== 0) && d.filter((x) => x < 0).length >= 1 && Math.max(...d) > 0 && d.filter((x) => x === Math.max(...d)).length === 1,
      azalis: (v, d) => d.every((x) => x !== 0) && d.filter((x) => x < 0).length === 1 && tekilMi(d),
      oku: (v) => new Set(v).size >= 5,
      fark: (v) => new Set(v).size >= 5,
      esik: (v) => new Set(v).size >= 5,
      en_yuksek: (v) => v.filter((x) => x === Math.max(...v)).length === 1 && new Set(v).size >= 5,
    }[tur];
    const v = uret(kosul), d = v.slice(1).map((x, i) => x - v[i]);
    const spec = { tip_id: 'a6-cizgi-grafigi', parametreler: { baslik: BASLIK, etiketler: e, degerler: v, max, adim } };
    const ortak = { kod: 'İTA.8.4.6', konu: 'Çağdaşlaşan Türkiye', alt_konu: 'Ekonomi alanındaki gelişmeyi grafikten okuma', spec };

    if (tur === 'en_cok_artis' || tur === 'azalis') {
      const hedef = tur === 'azalis' ? d.findIndex((x) => x < 0) : d.indexOf(Math.max(...d));
      const cel = karistir(d.map((_, i) => i).filter((i) => i !== hedef)).slice(0, 3);
      const gerekce = cel.map((i) => (tur === 'azalis'
        ? `${per(i)} arasında çizgi yukarı çıkar; grafikte bu iki nokta arasında azalış yoktur.`
        : `${per(i)} arasında çizgideki değişim ${d[i] > 0 ? `${d[i]} artış` : `${-d[i]} azalış`}tır; sorulan dönemde çizgi daha çok yükselir.`));
      const olgu = tur === 'azalis' ? { yol: ['azalis'], beklenen: [`${e[hedef]}|${e[hedef + 1]}`] } : { yol: ['en_cok_artis'], beklenen: `${e[hedef]}|${e[hedef + 1]}` };
      return ekle({ ...ortak, zorluk: 2, dogru: per(hedef), celdirici: cel.map(per), gerekce,
        kok: tur === 'azalis' ? 'Yukarıdaki grafiğe göre kurulan fabrika sayısı hangi iki yıl arasında azalmıştır?' : 'Yukarıdaki grafiğe göre kurulan fabrika sayısındaki artış hangi iki yıl arasında en fazladır?',
        ipucu: tur === 'azalis' ? 'Çizginin aşağı doğru indiği bölümü bul.' : 'Çizginin en dik yükseldiği bölümü bul.',
        cozum: ['Art arda gelen noktalar arasındaki değişim grafikten okunur.', `Aranan dönem ${per(hedef)} aralığıdır.`], dogrulama: [olgu] });
    }
    if (tur === 'en_yuksek') {
      const hedef = v.indexOf(Math.max(...v)), cel = karistir(v.map((_, i) => i).filter((i) => i !== hedef)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 1, dogru: e[hedef], celdirici: cel.map((i) => e[i]),
        gerekce: cel.map((i) => `${e[i]} yılındaki nokta, grafikteki en yüksek noktanın altında kalır.`),
        kok: 'Yukarıdaki grafiğe göre kurulan fabrika sayısı hangi yılda en yüksektir?', ipucu: 'Çizginin en üst noktasını bul, altındaki yılı oku.',
        cozum: [`Grafikte en yüksek nokta ${e[hedef]} yılına aittir.`], dogrulama: [{ yol: ['degerler', e[hedef]], beklenen: Math.max(...v) }] });
    }
    if (tur === 'esik') {
      // eşik değerini ilk kez aşan yıl: önceki yıl eşik ve altı, bu yıl eşiğin üstünde
      const adaylar = [];
      for (let q = 1; q <= adet - 1; q++) {
        const t = q * adim, i = v.findIndex((x) => x > t);
        if (i > 0 && v[i - 1] <= t && v.slice(0, i).every((x) => x <= t)) adaylar.push({ t, i });
      }
      if (!adaylar.length) throw new Error('esik_yok');
      const { t, i } = sec(adaylar), cel = karistir(e.map((_, m) => m).filter((m) => m !== i)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 2, dogru: e[i], celdirici: cel.map((m) => e[m]),
        gerekce: cel.map((m) => (m < i ? `${e[m]} yılındaki nokta ${t} çizgisinin üstüne çıkmamıştır.` : `${e[m]} yılında değer ${t} çizgisini daha önce aşmıştır ya da bu yıl ilk aşılan yıl değildir.`)),
        kok: `Yukarıdaki grafiğe göre kurulan fabrika sayısı hangi yılda ilk kez ${t} değerinin üzerine çıkmıştır?`, ipucu: `Dikey eksende ${t} çizgisini bul; çizginin ilk kez bu çizginin üstüne geçtiği noktaya bak.`,
        cozum: [`${e[i]} noktası ${v[i]} değerindedir ve ${t} çizgisinin üstündedir.`, 'Önceki noktaların hiçbiri bu çizgiyi aşmaz.'], dogrulama: [{ yol: ['degerler', e[i]], beklenen: v[i] }] });
    }
    if (tur === 'oku') {
      const i = Math.floor(R() * n), D = v[i];
      const havuz = [...v.filter((_, m) => m !== i), D - adim, D + adim, D - 2 * adim, D + 2 * adim].filter((x) => x >= adim && x <= max);
      const sirali = sayisalSik({ dogru: D, havuz, k, karistir }) ?? sayisalSik({ dogru: D, havuz, k: Math.min(k, 3), karistir });
      if (!sirali) throw new Error('oku_sik_yok');
      return ekle({ ...ortak, zorluk: 1, sirali: sirali.map(String), dogru: String(D),
        gerekce: sirali.map((x) => (x === D ? '' : `${x}, ${e[i]} noktasının ${Math.abs(x - D) / adim} çizgi ${x > D ? 'üstündeki' : 'altındaki'} değerdir.`)),
        kok: `Yukarıdaki grafiğe göre ${e[i]} yılında kurulan fabrika sayısı kaçtır?`, ipucu: 'Noktanın hangi yatay çizgiyle aynı hizada olduğuna bak.',
        cozum: [`${e[i]} noktası dikey eksende ${D} değerine karşılık gelir.`], dogrulama: [{ yol: ['degerler', e[i]], beklenen: D }] });
    }
    // fark: iki yıl arasındaki değişim (artış), araya en az bir yıl girer
    const adayCift = [];
    for (let a = 0; a < n - 2; a++) for (let c = a + 2; c < n; c++) if (v[c] > v[a]) adayCift.push([a, c]);
    if (!adayCift.length) throw new Error('fark_yok');
    const [a, c] = sec(adayCift), D = v[c] - v[a];
    const havuz = [];
    for (let p = 0; p < n; p++) for (let q = p + 1; q < n; q++) if (v[q] > v[p]) havuz.push(v[q] - v[p]);
    havuz.push(v[c], v[a], D - adim, D + adim);
    const sirali = sayisalSik({ dogru: D, havuz: havuz.filter((x) => x >= adim && x <= max), k, karistir }) ?? sayisalSik({ dogru: D, havuz: havuz.filter((x) => x >= adim && x <= max), k: Math.min(k, 3), karistir });
    if (!sirali) throw new Error('fark_sik_yok');
    return ekle({ ...ortak, zorluk: 2, sirali: sirali.map(String), dogru: String(D),
      gerekce: sirali.map((x) => (x === D ? '' : `${x}, grafikteki başka iki noktanın ya da tek bir noktanın değerinden gelen yanlış okumadır.`)),
      kok: `Yukarıdaki grafiğe göre kurulan fabrika sayısı ${e[a]} yılından ${e[c]} yılına kaç artmıştır?`, ipucu: 'İki yılın değerlerini dikey eksenden oku, büyükten küçüğü çıkar.',
      cozum: [`${e[a]} noktası ${v[a]}, ${e[c]} noktası ${v[c]} değerindedir.`, `Fark ${v[c]} − ${v[a]} = ${D} bulunur.`], dogrulama: [{ yol: ['artis', `${e[a]}|${e[c]}`], beklenen: D }] });
  }
  return { cizgiSorusu };
}

export const KAYIT = [
  { id: 'ink8-ekonomi-cizgi', ders: DERS, sinif: 8, idOnek: 'INK8-EKO', mufredat_surum: MUFREDAT, kodlar: ['İTA.8.4.6'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];
