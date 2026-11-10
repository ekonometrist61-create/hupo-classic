// 5. sınıf Sosyal Bilgiler — iki şekilli şablon (mevcut şekil tipleri: a6-tablo, a6-cizgi-grafigi).
// SB.5.5.2: kurgusal bir ailenin aylık bütçe tablosundan gelir, gider ve kalan parayı hesaplama.
// SB.5.2.2: kurgusal bir ilde ağaçlık alanın yıllara göre değişimini çizgi grafiğinden yorumlama.
// Veriler kurgusaldır (gerçek veri değildir); tablo ya da grafik olmadan cevap bulunamaz.
const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const GELIR = ['Maaş', 'Kira geliri', 'Ek iş geliri'];
const GIDER = ['Kira', 'Market', 'Ulaşım', 'Fatura', 'Kırtasiye', 'Giysi', 'Sağlık', 'Okul servisi'];
const DEGISIM_BASLIK = 'Bir İlde Ağaçlık Alan (bin dekar)';

const topla = (xs) => xs.reduce((t, x) => t + x, 0);
const tl = (x) => `${x} TL`;

// Aynı değeri iki kez vermemek için ilk görülen adayı tutar.
function tekilAdaylar(adaylar, dogru) {
  const goruldu = new Map();
  for (const a of adaylar) if (a.v > 0 && a.v !== dogru && !goruldu.has(a.v)) goruldu.set(a.v, a);
  return [...goruldu.values()];
}

export function kur({ R, sec, karistir, ekle }) {
  function butceSorusu() {
    const g = sec([1, 2]), d = sec([3, 4]);
    const gelir = karistir(GELIR).slice(0, g).map((ad) => ({ ad, tur: 'Gelir', tutar: 50 * (30 + Math.floor(R() * 51)) }));
    const gider = karistir(GIDER).slice(0, d).map((ad) => ({ ad, tur: 'Gider', tutar: 50 * (2 + Math.floor(R() * 19)) }));
    const G0 = topla(gelir.map((x) => x.tutar)), D = topla(gider.map((x) => x.tutar));
    if (G0 - D < 200) gelir[0].tutar += Math.ceil((D + 200 - G0) / 50) * 50;
    const G = topla(gelir.map((x) => x.tutar)), kalan = G - D;
    const satirlar = karistir([...gelir, ...gider]).map((r) => [r.ad, r.tur, r.tutar]);
    const spec = { tip_id: 'a6-tablo', parametreler: { baslik: 'Aylık Bütçe (TL)', sutunlar: ['Kalem', 'Tür', 'Tutar (TL)'], satirlar, grupSutun: 1, sayiSutun: 2 } };
    const ortak = { kod: 'SB.5.5.2', konu: 'Ekonomi', alt_konu: 'Bütçe tablosundan gelir, gider ve kalan parayı hesaplama', spec };
    const gelirMetin = gelir.map((x) => x.tutar).join(' + '), giderMetin = gider.map((x) => x.tutar).join(' + ');

    if (R() < 0.5) {
      const adaylar = tekilAdaylar([
        { v: G, a: `${tl(G)} toplam gelirdir; kalan para toplam giderin de bu değerden çıkarılmasıyla bulunur.` },
        { v: D, a: `${tl(D)} toplam giderdir; kalan para bu değer değildir.` },
        { v: G + D, a: `${tl(G + D)} gelir ile giderin toplamıdır; giderler gelirden çıkarılmalıdır, toplanmamalıdır.` },
        ...karistir([-950, -600, -300, 300, 650, 1000]).filter((o) => kalan + o > 0).slice(0, 2).map((o) => ({ v: kalan + o, a: `${tl(kalan + o)}, toplam gelir ile toplam giderin farkı değildir.` })),
      ], kalan);
      const cel = karistir(adaylar).slice(0, 3);
      if (cel.length < 3) throw new Error('butce_celdirici_yok');
      return ekle({ ...ortak, zorluk: 2, dogru: tl(kalan), celdirici: cel.map((c) => tl(c.v)), gerekce: cel.map((c) => c.a),
        kok: 'Yukarıdaki tabloda bir ailenin aylık gelir ve gider kalemleri verilmiştir. Buna göre ay sonunda kalan para kaç TL\'dir?',
        ipucu: 'Tür sütununa bak; gelir satırlarını ve gider satırlarını ayrı ayrı topla.',
        cozum: [`Gelir satırları: ${gelirMetin} = ${G}.`, `Gider satırları: ${giderMetin} = ${D}.`, `Kalan para ${G} − ${D} = ${kalan} TL'dir.`],
        dogrulama: [{ yol: ['toplam', 'Gelir'], beklenen: G }, { yol: ['toplam', 'Gider'], beklenen: D }] });
    }

    const maxG = Math.max(...gider.map((x) => x.tutar)), minG = Math.min(...gider.map((x) => x.tutar));
    const adaylar = tekilAdaylar([
      { v: G, a: `${tl(G)} toplam gelirdir; gider satırlarının toplamı değildir.` },
      { v: kalan, a: `${tl(kalan)} gelir ile giderin farkıdır; gider toplamı değildir.` },
      { v: D + maxG, a: `${tl(D + maxG)} en büyük gider kalemi iki kez sayılarak bulunur; gider toplamı bu değildir.` },
      { v: D - minG, a: `${tl(D - minG)} en küçük gider kalemi toplamdan çıkarılarak bulunur; gider toplamı bu değildir.` },
      { v: D + 50, a: `${tl(D + 50)} gider toplamına yakındır ama tablodaki gider satırlarının toplamı değildir.` },
      { v: D - 50, a: `${tl(D - 50)} gider toplamına yakındır ama tablodaki gider satırlarının toplamı değildir.` },
    ], D);
    const cel = karistir(adaylar).slice(0, 3);
    if (cel.length < 3) throw new Error('butce_celdirici_yok');
    return ekle({ ...ortak, zorluk: 1, dogru: tl(D), celdirici: cel.map((c) => tl(c.v)), gerekce: cel.map((c) => c.a),
      kok: 'Yukarıdaki tabloya göre gider satırlarının toplamı kaç TL\'dir?',
      ipucu: 'Yalnızca Tür sütunu "Gider" olan satırların tutarlarını topla.',
      cozum: [`Gider satırları: ${giderMetin} = ${D}.`],
      dogrulama: [{ yol: ['toplam', 'Gider'], beklenen: D }] });
  }

  function degisimSorusu() {
    const y0 = sec([2016, 2017, 2019]), n = 5, e = Array.from({ length: n }, (_, i) => String(y0 + 2 * i));
    const max = 50, adim = 10;
    const tur = sec(['en_cok_artis', 'fark']);
    const kosul = tur === 'en_cok_artis'
      ? (dd) => Math.max(...dd) > 0 && dd.filter((x) => x === Math.max(...dd)).length === 1
      : (dd) => dd.every((x) => x !== 0);
    const veri = () => {
      for (let q = 0; q < 500; q++) {
        const w = Array.from({ length: n }, () => (adim / 2) * (2 + Math.floor(R() * 9)));
        const dd = w.slice(1).map((x, i) => x - w[i]);
        if (kosul(dd)) return { w, dd };
      }
      throw new Error('veri_uretilemedi');
    };
    const { w: v, dd: d } = veri();
    const spec = { tip_id: 'a6-cizgi-grafigi', parametreler: { baslik: DEGISIM_BASLIK, etiketler: e, degerler: v, max, adim } };
    const ortak = { kod: 'SB.5.2.2', konu: 'Doğal ve beşerî çevre', alt_konu: 'Çevredeki değişimi çizgi grafiğinden yorumlama', spec };
    const per = (i) => `${e[i]} – ${e[i + 1]}`;

    if (tur === 'en_cok_artis') {
      const h = d.indexOf(Math.max(...d));
      const cel = karistir(d.map((_, i) => i).filter((i) => i !== h)).slice(0, 3);
      const yon = (x) => (x > 0 ? 'artmıştır' : x < 0 ? 'azalmıştır' : 'değişmemiştir');
      return ekle({ ...ortak, zorluk: 2, dogru: per(h), celdirici: cel.map(per),
        gerekce: cel.map((i) => `${per(i)} arasında ağaçlık alan ${Math.abs(d[i])} bin dekar ${yon(d[i])}; en büyük artış bu dönemde değildir.`),
        kok: 'Yukarıdaki grafiğe göre ağaçlık alandaki artış hangi iki yıl arasında en fazladır?',
        ipucu: 'Çizginin en dik yükseldiği bölümü bul.',
        cozum: ['Art arda gelen yıllardaki değerler dikey eksenden okunur.', `En büyük artış ${per(h)} arasında ${d[h]} bin dekardır.`],
        dogrulama: [{ yol: ['en_cok_artis'], beklenen: `${e[h]}|${e[h + 1]}` }] });
    }

    const parlar = [];
    for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) if (v[j] !== v[i]) parlar.push([i, j]);
    const [i, j] = sec(parlar), D = v[j] - v[i];
    const lab = (x) => `${Math.abs(x)} bin dekar ${x > 0 ? 'artış' : 'azalış'}`;
    const havuz = [...new Set([-D, D + 10, D - 10, -D + 10, -D - 10].filter((x) => x !== 0 && x !== D))];
    const cel = karistir(havuz).slice(0, 3);
    if (cel.length < 3) throw new Error('fark_celdirici_yok');
    return ekle({ ...ortak, zorluk: 2, dogru: lab(D), celdirici: cel.map(lab),
      gerekce: cel.map((x) => (Math.sign(x) !== Math.sign(D)
        ? `Grafikte ${e[i]} ile ${e[j]} yılları arasında değişim ${x > 0 ? 'artış' : 'azalış'} yönündedir; ${lab(D)} değildir.`
        : `Yön doğru olsa da değişim miktarı ${Math.abs(D)} bin dekardır; ${lab(x)} grafikle uyuşmaz.`)),
      kok: `Yukarıdaki grafiğe göre ağaçlık alan ${e[i]} yılından ${e[j]} yılına kadar nasıl değişmiştir?`,
      ipucu: 'İki yılın değerlerini dikey eksenden oku; sonraki değerden öncekini çıkar.',
      cozum: [`${e[i]} yılında ${v[i]}, ${e[j]} yılında ${v[j]} bin dekardır.`, `Değişim ${v[j]} − ${v[i]} = ${D} bin dekardır.`],
      dogrulama: [{ yol: ['artis', `${e[i]}|${e[j]}`], beklenen: D }] });
  }

  return { butceSorusu, degisimSorusu };
}

export const KAYIT = [
  { id: 'sb5-butce-tablo', ders: 'Sosyal Bilgiler', sinif: 5, idOnek: 'SB5-BUT', mufredat_surum: MUFREDAT, kodlar: ['SB.5.5.2'], fabrika: kur, uret: (f) => f.butceSorusu() },
  { id: 'sb5-degisim-cizgi', ders: 'Sosyal Bilgiler', sinif: 5, idOnek: 'SB5-DEG', mufredat_surum: MUFREDAT, kodlar: ['SB.5.2.2'], fabrika: kur, uret: (f) => f.degisimSorusu() },
];
