// 5. sınıf Sosyal Bilgiler — ilin ekonomik faaliyetlerini sütun grafiğinden okuma (SB.5.5.3).
// Veriler kurgusaldır (gerçek il verisi değildir); soru yalnız grafik okuma becerisini ölçer.
const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const TEMALAR = [
  { baslik: 'Bir İlde Yetiştirilen Ürünler (bin ton)', ad: ['Buğday', 'Arpa', 'Mısır', 'Pamuk', 'Fındık'] },
  { baslik: 'Bir İldeki Hayvan Sayıları (bin)', ad: ['İnek', 'Koyun', 'Keçi', 'Tavuk', 'Arı'] },
  { baslik: 'Bir İlde Üretilen Sebzeler (bin ton)', ad: ['Domates', 'Biber', 'Patlıcan', 'Salatalık', 'Havuç'] },
];
const ESKALA = [{ max: 10, adim: 2 }, { max: 20, adim: 4 }, { max: 16, adim: 4 }];

export function kur({ R, sec, karistir, ekle, konum }) {
  function ekonomiSorusu() {
    const t = sec(TEMALAR), e = sec(ESKALA), yarim = e.adim / 2, n = sec([4, 5]);
    const adlar = karistir(t.ad).slice(0, n), adet = Math.floor(e.max / yarim), deger = new Set(); let g = 0;
    while (deger.size < n && g++ < 200) deger.add((1 + Math.floor(R() * (adet - 1))) * yarim);
    if (deger.size < n) throw new Error('deger_cesitliligi_yok');
    const kategoriler = adlar.map((ad, i) => ({ ad, deger: [...deger][i] })), v = Object.fromEntries(kategoriler.map((k) => [k.ad, k.deger]));
    const sirali = [...kategoriler].sort((a, b) => b.deger - a.deger);
    const spec = { tip_id: 'sutun-grafigi', parametreler: { baslik: t.baslik, kategoriler, max: e.max, adim: e.adim } };
    const ortak = { kod: 'SB.5.5.3', konu: 'Ekonomi', alt_konu: 'İlin ekonomik faaliyetlerini grafikten okuma', spec };
    if (R() < 0.5) {
      const dogru = sirali[0].ad, cel = sirali.slice(1).map((x) => x.ad).sort(() => R() - 0.5).slice(0, 3);
      ekle({ ...ortak, zorluk: 1, kok: `Yukarıdaki grafik "${t.baslik}" bilgisini göstermektedir. Buna göre en fazla bulunan hangisidir?`, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c} sütunu (${v[c]}) en yüksek sütun değildir.`), ipucu: 'En yüksek sütunu bul.', cozum: ['Sütunların yüksekliği karşılaştırılır.', `En yüksek sütun ${dogru} sütunudur.`],
        dogrulama: [{ yol: ['en_cok'], beklenen: dogru }] });
    } else {
      const X = sec(adlar), c = v[X], d = e.adim, kp = konum(), start = c - kp * d;
      if (start < 0) throw new Error('pencere_negatif');
      const sirasi = [0, 1, 2, 3].map((i) => String(start + i * d));
      ekle({ ...ortak, zorluk: 1, sirali: sirasi, dogru: String(c), gerekce: sirasi.map((x) => (Number(x) === c ? '' : `${x}, ${X} sütununun ${Math.abs(Number(x) - c) / d} çizgi ${Number(x) > c ? 'üstündeki' : 'altındaki'} değerdir.`)),
        kok: `Yukarıdaki grafik "${t.baslik}" bilgisini göstermektedir. Buna göre ${X} değeri kaçtır?`, ipucu: `${X} sütununun üst ucunun hangi çizgiyle aynı hizada olduğuna bak.`,
        cozum: [`${X} sütununun yüksekliği dikey eksenden okunur.`, `Sütunun üst ucu ${c} değerindedir.`], dogrulama: [{ yol: ['degerler', X], beklenen: c }] });
    }
  }
  return { ekonomiSorusu };
}

export const KAYIT = [
  { id: 'sb5-ekonomi-grafik', ders: 'Sosyal Bilgiler', sinif: 5, idOnek: 'SB5-EKO', mufredat_surum: MUFREDAT, kodlar: ['SB.5.5.3'], fabrika: kur, uret: (f) => f.ekonomiSorusu() },
];
