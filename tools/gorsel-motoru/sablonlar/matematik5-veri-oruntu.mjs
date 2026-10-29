// 5. sınıf Matematik — kategorik veri (sütun grafiği) ve çubuk örüntüsü şablonları.
// Şıklar aritmetik pencere (sabit adımlı); doğru şık konumu harf dengesine göre. Tek bir değere işaret etmez.
const MUFREDAT = 'Maarif Modeli Ortaokul Matematik DÖP (5-8)';
const TEMALAR = [
  { baslik: 'Sevilen Meyveler', ad: ['Elma', 'Armut', 'Muz', 'Çilek', 'Kiraz'], nesne: 'öğrenci' },
  { baslik: 'Sevilen Sporlar', ad: ['Futbol', 'Yüzme', 'Basket', 'Tenis', 'Koşu'], nesne: 'öğrenci' },
  { baslik: 'Sınıftaki Evcil Hayvanlar', ad: ['Kedi', 'Köpek', 'Kuş', 'Balık', 'Tavşan'], nesne: 'öğrenci' },
  { baslik: 'Okunan Kitap Türleri', ad: ['Masal', 'Şiir', 'Roman', 'Hikâye', 'Fen'], nesne: 'kitap' },
];
const ESKALA = [{ max: 10, adim: 2 }, { max: 20, adim: 4 }, { max: 16, adim: 4 }];

export function kur({ R, sec, karistir, ekle, konum }) {
  function sutunSorusu() {
    const t = sec(TEMALAR), e = sec(ESKALA), yarim = e.adim / 2, n = sec([4, 5]);
    const adlar = karistir(t.ad).slice(0, n);
    const adet = Math.floor(e.max / yarim);
    const deger = new Set(); let guard = 0;
    while (deger.size < n && guard++ < 200) deger.add((1 + Math.floor(R() * (adet - 1))) * yarim);
    if (deger.size < n) throw new Error('deger_cesitliligi_yok');
    const kategoriler = adlar.map((ad, i) => ({ ad, deger: [...deger][i] }));
    const spec = { tip_id: 'sutun-grafigi', parametreler: { baslik: t.baslik, kategoriler, max: e.max, adim: e.adim } };
    const v = Object.fromEntries(kategoriler.map((k) => [k.ad, k.deger]));
    const byDeger = [...kategoriler].sort((a, b) => b.deger - a.deger);
    const kind = sec(['en_cok', 'deger', 'fark', 'toplam']);
    const kp = konum();
    const ortak = { kod: 'MAT.5.5.1', konu: 'Veri', alt_konu: 'Sütun grafiğini okuma ve yorumlama', spec };
    if (kind === 'en_cok') {
      const dogru = byDeger[0].ad, cel = byDeger.slice(1).map((x) => x.ad).sort(() => R() - 0.5).slice(0, 3);
      ekle({ ...ortak, zorluk: 1, kok: `Yukarıdaki sütun grafiği "${t.baslik}" verilerini göstermektedir. Buna göre en çok tercih edilen hangisidir?`, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c} sütunu (${v[c]}) en yüksek sütun değildir.`),
        ipucu: 'En yüksek sütunu bul.', cozum: ['Sütunların yüksekliği karşılaştırılır.', `En yüksek sütun ${dogru} sütunudur (${v[dogru]}).`],
        dogrulama: [{ yol: ['en_cok'], beklenen: dogru }] });
    } else if (kind === 'deger') {
      const X = sec(adlar), c = v[X], d = e.adim, start = c - kp * d;
      if (start < 0) throw new Error('pencere_negatif');
      const sirali = [0, 1, 2, 3].map((i) => String(start + i * d));
      ekle({ ...ortak, zorluk: 1, sirali, dogru: String(c), gerekce: sirali.map((s) => (Number(s) === c ? '' : `${s}, ${X} sütununun ${Math.abs(Number(s) - c) / d} çizgi ${Number(s) > c ? 'üstündeki' : 'altındaki'} değerdir.`)),
        kok: `Yukarıdaki sütun grafiğinde "${t.baslik}" gösterilmiştir. Buna göre ${X} kaç ${t.nesne} tarafından tercih edilmiştir?`,
        ipucu: `${X} sütununun üst ucunun hangi çizgiyle aynı hizada olduğuna bak.`, cozum: [`${X} sütununun yüksekliği dikey eksenden okunur.`, `Sütunun üst ucu ${c} değerindedir.`],
        dogrulama: [{ yol: ['degerler', X], beklenen: c }] });
    } else if (kind === 'fark') {
      const [A, B] = karistir(adlar).slice(0, 2), a = v[A], b = v[B], f = Math.abs(a - b);
      const cel = [a + b, Math.max(a, b), Math.min(a, b)].filter((x, i, d) => x !== f && d.indexOf(x) === i);
      if (cel.length < 3) throw new Error('fark_celdirici_yok');
      ekle({ ...ortak, zorluk: 2, dogru: String(f), celdirici: cel.map(String),
        gerekce: cel.map((x) => (x === a + b ? 'İki değer toplanmış; fark için çıkarma yapılmalı.' : `${x}, tek bir sütunun değeridir; fark iki sütun arasında bulunur.`)),
        kok: `Yukarıdaki sütun grafiğinde "${t.baslik}" gösterilmiştir. Buna göre ${A} ile ${B} sütunları arasındaki fark kaçtır?`,
        ipucu: 'İki sütunun değerini okuyup büyükten küçüğü çıkar.', cozum: [`${A} = ${a}, ${B} = ${b} okunur.`, `Fark = ${Math.max(a, b)} − ${Math.min(a, b)} = ${f}.`],
        dogrulama: [{ yol: ['degerler', A], beklenen: a }, { yol: ['degerler', B], beklenen: b }] });
    } else {
      const tp = Object.values(v).reduce((x, y) => x + y, 0), d = e.adim, start = tp - kp * d;
      if (start < 0) throw new Error('pencere_negatif');
      const sirali = [0, 1, 2, 3].map((i) => String(start + i * d));
      ekle({ ...ortak, zorluk: 2, sirali, dogru: String(tp), gerekce: sirali.map((s) => (Number(s) === tp ? '' : `${s} değeri, sütun değerlerinin toplamından ${Math.abs(Number(s) - tp)} ${Number(s) > tp ? 'fazla' : 'eksik'}tir; bir sütun yanlış okunmuş olabilir.`)),
        kok: `Yukarıdaki sütun grafiğinde "${t.baslik}" gösterilmiştir. Buna göre grafikteki tüm sütunların gösterdiği değerlerin toplamı kaçtır?`,
        ipucu: 'Her sütunun değerini ayrı ayrı oku, sonra topla.', cozum: [`Okunan değerler: ${adlar.map((x) => v[x]).join(', ')}.`, `Toplam = ${adlar.map((x) => v[x]).join(' + ')} = ${tp}.`],
        dogrulama: [{ yol: ['toplam'], beklenen: tp }] });
    }
  }

  function oruntuSorusu() {
    const tur = sec(['kare', 'ucgen', 'altigen']), a = { kare: 3, ucgen: 2, altigen: 5 }[tur], m = sec([4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]); // 3 tür × 14 adım = 42 farklı soru (n ≥ 40 kararı için)
    // Şıklar üç olası kuralın (2n+1, 3n+1, 4n+1) değerlerini ve başlangıç çubuğunu unutma hatasını içerir;
    // böylece görsel olmadan hangi kuralın doğru olduğu şıklardan çıkarılamaz (görselsiz çözüm ≈ 1/3).
    const c = a * m + 1, diger = [2, 3, 4, 5].filter((f) => f !== a).slice(0, 2);
    const celdirici = [...diger.map((f) => f * m + 1), a * m];
    const gerekce = [...diger.map((f) => `${f * m + 1} çubuk, ${f}n+1 kuralıyla bulunur; ancak şekilde 1. adımda ${a + 1} çubuk vardır, ${f}n+1 kuralı 1. adımda ${f + 1} çubuk verirdi.`), `${a * m} çubuk, başlangıçtaki ek çubuk (+1) unutularak bulunur; her adımda ${a} çubuk artar ve 1. adım ${a + 1} çubukla başlar.`];
    ekle({ kod: 'MAT.5.2.3', konu: 'Örüntüler', alt_konu: 'Şekil örüntüsünün kuralı', zorluk: m <= 7 ? 2 : 3, dogru: String(c), celdirici: celdirici.map(String), gerekce,
      spec: { tip_id: 'cubuk-oruntusu', parametreler: { tur } },
      kok: `Yukarıda çubuklarla oluşturulan bir örüntünün ilk üç adımı verilmiştir. Bu örüntünün ${m}. adımı kaç çubukla oluşturulur?`,
      ipucu: 'Bir adımdan diğerine çubuk sayısının kaç arttığına bak.',
      cozum: [`${{ kare: 'Kare', ucgen: 'Üçgen', altigen: 'Altıgen' }[tur]} sayısı her adımda 1 artar; çubuk sayısı her adımda ${a} artar.`, `n. adımda çubuk sayısı ${a}×n + 1’dir.`, `${m}. adım: ${a} × ${m} + 1 = ${c}`],
      dogrulama: [{ yol: ['cubuk', String(m)], beklenen: c }] });
  }
  return { sutunSorusu, oruntuSorusu };
}

export const KAYIT = [
  { id: 'mat5-sutun-grafigi', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-VERI', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.5.1'], fabrika: kur, uret: (f) => f.sutunSorusu() },
  { id: 'mat5-cubuk-oruntusu', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-ORU', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.2.3'], fabrika: kur, uret: (f) => f.oruntuSorusu() },
];
