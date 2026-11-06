// 3. sınıf Fen Bilimleri — kaplardaki maddelerin hâli (FB.3.4.1), yaşam döngüsü şeması (FB.3.2.3), elektrik tasarrufu sütun grafiği (FB.3.6.3).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 3. sınıf; program: TYMM)';
const HARF = ['K', 'L', 'M', 'N'];
const HAL_AD = { kati: 'katı', sivi: 'sıvı', gaz: 'gaz' };
const OZELLIK = {
  kati: ['şekli sabit olan ve kabın şeklini almayan', 'kabın içinde belirli bir yer kaplayan, şeklini koruyan'],
  sivi: ['bulunduğu kabın şeklini alan ve yüzeyi düz duran', 'kabın alt kısmını dolduran, üstü düz yüzey oluşturan'],
  gaz: ['bulunduğu kabın tamamını dolduran', 'taneciklerle kabın her yerine yayılmış olan'],
};
const SEKILLER = ['kutu', 'yamuk', 'dar'];

export function kur({ R, sec, karistir, ekle, konum }) {
  function kapSorusu() {
    const kind = sec(['kati', 'sivi', 'gaz', 'say']), k = konum();
    const kaplar = HARF.map((ad) => ({ ad, hal: 'kati', sekil: sec(SEKILLER) }));
    const kod = { kod: 'FB.3.4.1', konu: 'Madde ve Değişim', alt_konu: 'Maddeleri hâllerine göre sınıflandırma' };
    if (kind !== 'say') {
      const digerleri = Object.keys(HAL_AD).filter((h) => h !== kind);
      kaplar.forEach((c, i) => { c.hal = i === k ? kind : sec(digerleri); });
      const ozel = sec(OZELLIK[kind]), uzun = R() < 0.5;
      const kok = uzun ? `Yukarıdaki şekilde dört kapta farklı maddeler bulunmaktadır. Hangi kaptaki madde ${ozel} bir maddedir?` : `Yukarıdaki kaplardan hangisinde ${HAL_AD[kind]} hâlde bir madde bulunmaktadır?`;
      ekle({ ...kod, zorluk: 1, spec: { tip_id: 'a5-kap-hal', parametreler: { kaplar } }, sirali: HARF, dogru: HARF[k], kok,
        gerekce: HARF.map((h, i) => (i === k ? '' : `${h} kabındaki madde ${HAL_AD[kaplar[i].hal]} hâldedir; ${HAL_AD[kind]} hâlin özelliğini göstermez.`)),
        ipucu: 'Her kaptaki maddenin kabı nasıl doldurduğuna ve şeklini koruyup korumadığına bak.',
        cozum: [`Katı madde kabın içinde şeklini korur, sıvı kabın alt kısmında düz yüzey oluşturur, gaz ise kabın tamamına yayılır.`, `${HARF[k]} kabındaki madde ${HAL_AD[kind]} hâldedir.`],
        dogrulama: [{ yol: ['haller', HARF[k]], beklenen: kind }] });
    } else {
      const hedef = sec(['kati', 'sivi', 'gaz']), c = 1 + Math.floor(R() * 3), baslangic = c - k;
      if (baslangic < 0) throw new Error('pencere_negatif');
      const idx = karistir([0, 1, 2, 3]);
      kaplar.forEach((cp, i) => { cp.hal = 'kati'; });
      const digerleri = Object.keys(HAL_AD).filter((h) => h !== hedef);
      idx.forEach((ix, j) => { kaplar[ix].hal = j < c ? hedef : sec(digerleri); });
      const sirali = [0, 1, 2, 3].map((i) => String(baslangic + i));
      ekle({ ...kod, zorluk: 2, spec: { tip_id: 'a5-kap-hal', parametreler: { kaplar } }, sirali, dogru: String(c),
        gerekce: sirali.map((s) => `${s} sayısı, ${HAL_AD[hedef]} hâldeki kapların yanlış sayılmasıyla bulunur; şekilde ${c} kapta ${HAL_AD[hedef]} vardır.`),
        kok: `Yukarıdaki şekilde dört kapta farklı maddeler bulunmaktadır. Kaplardaki maddelerden kaç tanesi ${HAL_AD[hedef]} hâldedir?`,
        ipucu: 'Her kaptaki maddeye tek tek bak ve katı, sıvı ya da gaz olduğuna karar ver.',
        cozum: ['Her kaptaki maddenin kabı nasıl doldurduğuna bakılarak hâli belirlenir.', `${HAL_AD[hedef]} hâlde ${c} madde vardır.`],
        dogrulama: [{ yol: ['say', hedef], beklenen: c }] });
    }
  }
  return { kapSorusu };
}

// ---- yaşam döngüsü ----
const CEVRIM = {
  Kelebek: ['Yumurta', 'Tırtıl', 'Pupa', 'Kelebek'],
  Kurbağa: ['Yumurta', 'İribaş', 'Genç kurbağa', 'Kurbağa'],
  Tavuk: ['Yumurta', 'Civciv', 'Tavuk'],
  'Fasulye bitkisi': ['Tohum', 'Filiz', 'Genç bitki', 'Çiçekli bitki'],
};

export function kurDongu({ R, sec, karistir, ekle }) {
  function donguSorusu() {
    const canli = sec(Object.keys(CEVRIM)), evreler = CEVRIM[canli], baslangic = Math.floor(R() * evreler.length);
    const kod = { kod: 'FB.3.2.3', konu: 'Canlılar Dünyası', alt_konu: 'Canlıların yaşam döngüsü' };
    if (R() < 0.7) {
      const gizli = Math.floor(R() * evreler.length), dogru = evreler[gizli];
      const adaylar = [...new Set(Object.entries(CEVRIM).filter(([c]) => c !== canli).flatMap(([, e]) => e).filter((x) => !evreler.includes(x)))];
      if (adaylar.length < 3) throw new Error('celdirici_yok');
      const cel = karistir(adaylar).slice(0, 3);
      ekle({ ...kod, zorluk: 2, spec: { tip_id: 'a5-dongu', parametreler: { evreler, gizli, baslangic, canli } }, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c}, başka bir canlının yaşam döngüsünde yer alır; şekildeki döngü ${canli.toLowerCase()} canlısına aittir.`),
        kok: 'Yukarıdaki şekilde bir canlının yaşam döngüsü verilmiştir. Şekilde soru işaretiyle gösterilen evre aşağıdakilerden hangisidir?',
        ipucu: 'Şekildeki diğer evrelerden canlıyı tanı, sonra döngüdeki sırayı düşün.',
        cozum: [`Döngüdeki evreler ${canli} canlısına aittir.`, `Okların gösterdiği sıraya göre eksik evre ${dogru} evresidir.`],
        dogrulama: [{ yol: ['eksik'], beklenen: dogru }] });
    } else {
      const cel = karistir(Object.keys(CEVRIM).filter((c) => c !== canli));
      ekle({ ...kod, zorluk: 1, spec: { tip_id: 'a5-dongu', parametreler: { evreler, baslangic, canli } }, dogru: canli, celdirici: cel,
        gerekce: cel.map((c) => `${c} canlısının yaşam döngüsünde şekildeki evreler yoktur.`),
        kok: 'Yukarıdaki şekilde bir canlının yaşam döngüsü evreleriyle verilmiştir. Bu yaşam döngüsü aşağıdaki canlılardan hangisine aittir?',
        ipucu: 'Kutulardaki evre adlarına bak; hangi canlı için bu evreler sırayla yaşanır?',
        cozum: [`Şekilde ${evreler.join(', ')} evreleri vardır.`, `Bu evreler ${canli} canlısının yaşam döngüsüdür.`],
        dogrulama: [{ yol: ['canli'], beklenen: canli }] });
    }
  }
  return { donguSorusu };
}

// ---- elektrik tasarrufu: sütun grafiği ----
const TEMALAR = [
  { baslik: 'Açık Kalan Lambalar', ad: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum'], bag: 'Okulda gün sonunda her gün kapatılmayı unutulan lamba sayıları grafikte gösterilmiştir.', nesne: 'lamba', son: 'gün', dat: 'güne' },
  { baslik: 'Açık Kalan Televizyon (saat)', ad: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum'], bag: 'Bir evde izlenmeyen hâlde açık kalan televizyonun günlük süresi (saat) grafikte gösterilmiştir.', nesne: 'saat', son: 'gün', dat: 'güne' },
  { baslik: 'Açık Unutulan Elektrikli Araçlar', ad: ['Salon', 'Mutfak', 'Oda', 'Hol', 'Banyo'], bag: 'Bir evde odalarda açık unutulan elektrikli araç sayıları grafikte gösterilmiştir.', nesne: 'araç', son: 'oda', dat: 'odaya' },
  { baslik: 'Boş Sınıflarda Açık Işıklar', ad: ['3-A', '3-B', '3-C', '3-D', '3-E'], bag: 'Teneffüste boş kalan sınıflarda açık unutulan ışık sayıları grafikte gösterilmiştir.', nesne: 'ışık', son: 'sınıf', dat: 'sınıfa' },
];
const ESKALA = [{ max: 10, adim: 2 }, { max: 8, adim: 2 }, { max: 12, adim: 4 }];

export function kurTasarruf({ R, sec, karistir, ekle, konum }) {
  function tasarrufSorusu() {
    const t = sec(TEMALAR), e = sec(ESKALA), yarim = e.adim / 2, n = sec([4, 5]), adlar = t.ad.slice(0, n);
    const adet = Math.floor(e.max / yarim), deger = new Set();
    let g = 0; while (deger.size < n && g++ < 300) deger.add((1 + Math.floor(R() * (adet - 1))) * yarim);
    if (deger.size < n) throw new Error('deger_cesitliligi_yok');
    const vals = karistir([...deger]);
    const kategoriler = adlar.map((ad, i) => ({ ad, deger: vals[i] }));
    const spec = { tip_id: 'sutun-grafigi', parametreler: { baslik: t.baslik, kategoriler, max: e.max, adim: e.adim, degerEtiketi: false } };
    const v = Object.fromEntries(kategoriler.map((x) => [x.ad, x.deger]));
    const sirali = [...kategoriler].sort((a, b) => b.deger - a.deger);
    const kind = sec(['en_cok', 'deger', 'fark', 'toplam']), kp = konum();
    const ortak = { kod: 'FB.3.6.3', konu: 'Elektrik', alt_konu: 'Elektriği tasarruflu kullanma (grafik yorumu)', spec };
    if (kind === 'en_cok') {
      if (sirali[0].deger === sirali[1].deger) throw new Error('en_cok_esit');
      const dogru = sirali[0].ad, cel = sirali.slice(1).map((x) => x.ad).sort(() => R() - 0.5).slice(0, 3);
      ekle({ ...ortak, zorluk: 1, dogru, celdirici: cel, gerekce: cel.map((c) => `${c} sütunu (${v[c]}) en yüksek sütun değildir; en çok ${t.nesne} bu ${t.son} için görülmemiştir.`),
        kok: `${t.bag} Elektrik tasarrufu için ilk olarak hangi ${t.son === 'gün' ? 'güne' : t.dat} dikkat edilmesi gerekir?`,
        ipucu: 'En çok elektrik harcanan yeri bulmak için en yüksek sütuna bak.', cozum: ['Sütunların yükseklikleri karşılaştırılır.', `En yüksek sütun ${dogru} sütunudur (${v[dogru]}).`],
        dogrulama: [{ yol: ['en_cok'], beklenen: dogru }] });
    } else if (kind === 'deger') {
      const X = sec(adlar), c = v[X], d = e.adim, start = c - kp * d; if (start < 0) throw new Error('pencere_negatif');
      const sir = [0, 1, 2, 3].map((i) => String(start + i * d));
      ekle({ ...ortak, zorluk: 1, sirali: sir, dogru: String(c), gerekce: sir.map((s) => `${s}, ${X} sütununun ${Math.abs(Number(s) - c) / d} çizgi ${Number(s) > c ? 'üstündeki' : 'altındaki'} değerdir.`),
        kok: `${t.bag} Buna göre ${X} için grafikte gösterilen değer kaçtır?`, ipucu: `${X} sütununun üst ucunun hangi çizgiyle aynı hizada olduğuna bak.`,
        cozum: [`${X} sütununun yüksekliği dikey eksenden okunur.`, `Sütunun üst ucu ${c} değerindedir.`], dogrulama: [{ yol: ['degerler', X], beklenen: c }] });
    } else if (kind === 'fark') {
      const [A, B] = karistir(adlar).slice(0, 2), a = v[A], b = v[B], f = Math.abs(a - b); if (f === 0) throw new Error('fark_sifir');
      const cel = [a + b, Math.max(a, b), Math.min(a, b)].filter((x, i, d) => x !== f && d.indexOf(x) === i);
      if (cel.length < 3) throw new Error('fark_celdirici_yok');
      ekle({ ...ortak, zorluk: 2, dogru: String(f), celdirici: cel.map(String),
        gerekce: cel.map((x) => (x === a + b ? 'İki değer toplanmış; fark için çıkarma yapılmalıdır.' : `${x}, tek bir sütunun değeridir; fark iki sütun arasında bulunur.`)),
        kok: `${t.bag} Buna göre ${A} ile ${B} sütunları arasındaki fark kaçtır?`, ipucu: 'İki sütunun değerini okuyup büyükten küçüğü çıkar.',
        cozum: [`${A} = ${a}, ${B} = ${b} okunur.`, `Fark = ${Math.max(a, b)} − ${Math.min(a, b)} = ${f}.`], dogrulama: [{ yol: ['degerler', A], beklenen: a }, { yol: ['degerler', B], beklenen: b }] });
    } else {
      const tp = Object.values(v).reduce((x, y) => x + y, 0), d = e.adim, start = tp - kp * d; if (start < 0) throw new Error('pencere_negatif');
      const sir = [0, 1, 2, 3].map((i) => String(start + i * d));
      ekle({ ...ortak, zorluk: 2, sirali: sir, dogru: String(tp), gerekce: sir.map((s) => `${s}, sütun değerlerinin toplamından ${Math.abs(Number(s) - tp)} ${Number(s) > tp ? 'fazla' : 'eksik'}tir; bir sütun yanlış okunmuş olabilir.`),
        kok: `${t.bag} Buna göre grafikteki tüm sütunların gösterdiği değerlerin toplamı kaçtır?`, ipucu: 'Her sütunun değerini ayrı ayrı oku, sonra topla.',
        cozum: [`Okunan değerler: ${adlar.map((x) => v[x]).join(', ')}.`, `Toplam = ${adlar.map((x) => v[x]).join(' + ')} = ${tp}.`], dogrulama: [{ yol: ['toplam'], beklenen: tp }] });
    }
  }
  return { tasarrufSorusu };
}

export const KAYIT = [
  { id: 'fen3-kap-hal', ders: 'Fen Bilimleri', sinif: 3, idOnek: 'FEN3-HAL', mufredat_surum: MUFREDAT, kodlar: ['FB.3.4.1'], fabrika: kur, uret: (f) => f.kapSorusu() },
  { id: 'fen3-yasam-dongusu', ders: 'Fen Bilimleri', sinif: 3, idOnek: 'FEN3-DON', mufredat_surum: MUFREDAT, kodlar: ['FB.3.2.3'], fabrika: kurDongu, uret: (f) => f.donguSorusu() },
  { id: 'fen3-tasarruf-grafik', ders: 'Fen Bilimleri', sinif: 3, idOnek: 'FEN3-TAS', mufredat_surum: MUFREDAT, kodlar: ['FB.3.6.3'], fabrika: kurTasarruf, uret: (f) => f.tasarrufSorusu() },
];

