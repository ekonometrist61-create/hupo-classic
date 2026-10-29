import { gorselUret } from '../motor.mjs';
// 5. sınıf Matematik — geometri şablonları (LLM yok; cevap ve çeldiriciler kodla hesaplanır).
// Her üretici parametrelidir; kayıt (KAYIT) bunları rastgele parametrelerle çağırarak sınırsız çeşitlilik sağlar.
export function kur({ R, sec, karistir, ekle, konum }) {
  const HARFLER_C = ['A', 'B', 'C', 'D', 'E', 'F', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T'];
  function cemberSorusu(tur) {
    const h = karistir(HARFLER_C).slice(0, 6);
    const [a, b, c, d, e, f] = h;
    const aci0 = 40 + Math.floor(R() * 60);
    const nk = { [a]: aci0, [b]: aci0 + 180, [c]: aci0 + 60, [d]: aci0 + 160, [e]: aci0 + 235, [f]: aci0 + 305 };
    const noktalar = Object.entries(nk).map(([ad, aci]) => ({ ad, aci }));
    const cap = `[${a}${b}]`, kiris1 = `[${c}${d}]`, yar = `[O${e}]`, yar2 = `[O${f}]`, kiris2 = `[${a}${c}]`;
    // cap/yaricap sorusunda: çap, 2 kiriş, 1 yarıçap. kiriş sorusunda: çap, 1 kiriş, 2 yarıçap (tek doğru şık).
    const cizimler = tur === 'kiris'
      ? [{ tur: 'cap', a, b }, { tur: 'kiris', a: c, b: d }, { tur: 'yaricap', a: e }, { tur: 'yaricap', a: f }]
      : [{ tur: 'cap', a, b }, { tur: 'kiris', a: c, b: d }, { tur: 'yaricap', a: e }, { tur: 'kiris', a, b: c }];
    const spec = { tip_id: 'cember-elemanlari', parametreler: { merkez: 'O', noktalar, cizimler } };
    const dg = (ad, s) => ({ yol: ['siniflar', ad], beklenen: s });
    if (tur === 'cap') {
      ekle({ kod: 'MAT.5.3.1', konu: 'Geometrik Şekiller', alt_konu: 'Çember elemanları', zorluk: 1, spec,
        kok: 'Yukarıda O merkezli çemberin üzerine bazı doğru parçaları çizilmiştir. Bu doğru parçalarından hangisi çemberin çapıdır?',
        dogru: cap, celdirici: [kiris1, yar, kiris2],
        gerekce: [`${kiris1} çemberin iki noktasını birleştirir ama merkezden geçmez; kiriştir.`, `${yar} merkezi çember üzerindeki bir noktaya bağlar; yarıçaptır, çap değildir.`, `${kiris2} merkezden geçmeyen bir kiriştir.`],
        ipucu: 'Çap, çemberin iki noktasını birleştirirken merkezden de geçer.',
        cozum: [`${cap} çemberin üzerindeki iki noktayı birleştirir.`, 'Bu doğru parçası çemberin merkezi O\'dan geçer.', 'Merkezden geçen kiriş çaptır.'],
        dogrulama: [dg(cap, 'cap'), dg(kiris1, 'kiris'), dg(yar, 'yaricap'), dg(kiris2, 'kiris')] });
    } else if (tur === 'yaricap') {
      ekle({ kod: 'MAT.5.3.1', konu: 'Geometrik Şekiller', alt_konu: 'Çember elemanları', zorluk: 1, spec,
        kok: 'Yukarıda O merkezli çemberin üzerine bazı doğru parçaları çizilmiştir. Bu doğru parçalarından hangisi çemberin yarıçapıdır?',
        dogru: yar, celdirici: [cap, kiris1, kiris2],
        gerekce: [`${cap} merkezden geçen bir kiriş, yani çaptır; yarıçapın iki katıdır.`, `${kiris1} merkezden geçmeyen bir kiriştir.`, `${kiris2} merkezden geçmeyen bir kiriştir.`],
        ipucu: 'Yarıçapın bir ucu merkezdedir, diğer ucu çemberin üzerindedir.',
        cozum: [`${yar} merkez O ile çember üzerindeki ${e} noktasını birleştirir.`, 'Bir ucu merkez, diğer ucu çember üzerinde olan doğru parçası yarıçaptır.'],
        dogrulama: [dg(yar, 'yaricap'), dg(cap, 'cap')] });
    } else {
      ekle({ kod: 'MAT.5.3.1', konu: 'Geometrik Şekiller', alt_konu: 'Çember elemanları', zorluk: 2, spec,
        kok: 'Yukarıdaki şekilde O merkezli çemberin üzerine bazı doğru parçaları çizilmiştir. Aşağıdakilerden hangisi çap olmayan bir kiriştir?',
        dogru: kiris1, celdirici: [cap, yar, yar2],
        gerekce: [`${cap} merkezden geçtiği için çaptır; her çap bir kiriştir ama çap olmayan kiriş aranıyor.`, `${yar} bir ucu merkezde olduğu için kiriş değil, yarıçaptır.`, `${yar2} bir ucu merkezde olduğu için kiriş değil, yarıçaptır.`],
        ipucu: 'Kiriş, çemberin üzerindeki iki noktayı birleştirir. Çap, merkezden geçen kiriştir.',
        cozum: [`${kiris1} çemberin iki noktasını birleştirir, merkezden geçmez.`, 'Çemberin iki noktasını birleştirip merkezden geçmeyen doğru parçası çap olmayan kiriştir.'],
        dogrulama: [dg(kiris1, 'kiris'), dg(cap, 'cap'), dg(yar, 'yaricap'), dg(yar2, 'yaricap')] });
    }
  }
  
  // ---- T2: doğru / ışın / doğru parçası sembolü ----
  const DOGRU_HARFLER = [['A', 'B'], ['K', 'L'], ['M', 'N'], ['P', 'R'], ['D', 'E']];
  function sembolSorusu(tur, i) {
    const [x, y] = DOGRU_HARFLER[i % DOGRU_HARFLER.length];
    const noktalar = [{ ad: x, x: 90 + Math.floor(R() * 30), y: 70 + Math.floor(R() * 60) }, { ad: y, x: 190 + Math.floor(R() * 30), y: 70 + Math.floor(R() * 60) }];
    const spec = { tip_id: 'dogru-modelleri', parametreler: { noktalar, nesneler: [{ tur, a: x, b: y }] } };
    const sem = { dogru_parcasi: `[${x}${y}]`, isin: `[${x}${y}`, dogru: `(${x}${y})` };
    const ad = { dogru_parcasi: 'doğru parçasının', isin: 'ışının', dogru: 'doğrunun' };
    const aciklama = { dogru_parcasi: 'iki ucu da sınırlıdır', isin: 'bir ucu sınırlı, diğer ucu sonsuzdur', dogru: 'iki yönde de sonsuza gider' };
    const adi = { dogru_parcasi: 'doğru parçası', isin: 'ışın', dogru: 'doğru' };
    const digerleri = ['dogru_parcasi', 'isin', 'dogru'].filter((t) => t !== tur).map((t) => sem[t]);
    const celdirici = [...digerleri, `[${y}${x}`]; // başlangıcı ters yazılmış ışın
    ekle({ kod: 'MAT.5.3.1', konu: 'Geometrik Şekiller', alt_konu: 'Doğru, ışın ve doğru parçası gösterimi', zorluk: tur === 'dogru_parcasi' ? 1 : 2, spec,
      kok: `Yukarıdaki şekilde ${x} ve ${y} noktalarından geçen model çizilmiştir. Bu modelin sembol ile gösterimi aşağıdakilerden hangisidir?`,
      dogru: sem[tur], celdirici,
      gerekce: celdirici.map((c, k) => (k < 2 ? `${c} başka bir geometrik modelin (${adi[['dogru_parcasi', 'isin', 'dogru'].filter((t) => t !== tur)[k]]}) gösterimidir.` : `${c}, ${y} noktasından başlayıp ${x} yönünde giden ışının gösterimidir; şekildeki model bu değildir.`)),
      ipucu: 'Şekildeki modelin uçlarına bak: uç var mı, ok var mı?',
      cozum: [`Şekildeki model ${aciklama[tur]}; bu bir ${adi[tur]}.`, `${ad[tur][0].toUpperCase()}${ad[tur].slice(1)} sembolle gösterimi ${sem[tur]} biçimindedir.`],
      dogrulama: [{ yol: ['semboller', `${x}${y}`], beklenen: sem[tur] }, { yol: ['turler', `${x}${y}`], beklenen: tur }] });
  }
  
  
  // ---- T4: kareli zeminde paralel / dik ----
  const YONLER = [[1, 1], [1, -1], [2, 1], [1, 2], [1, 0], [0, 1], [2, -1], [1, -2], [3, 1], [1, 3]];
  const AD4 = ['k', 'l', 'm', 'n'];
  function kareliSorusu(istenen) {
    for (let deneme = 0; deneme < 4000; deneme++) {
      const en = 11, boy = 8, dg = [];
      const secilen = karistir(YONLER).slice(0, 4);
      // Paralel çift rastgele seçilir; sabit (k, l) olsaydı doğru şık her zaman "k ile l" çıkardı ve metin tek başına ele verirdi.
      if (istenen === 'paralel') { const pi = Math.floor(R() * 4), pj = (pi + 1 + Math.floor(R() * 3)) % 4; secilen[pj] = secilen[pi]; }
      for (let i = 0; i < 4; i++) {
        const [dx, dy] = secilen[i], kat = 2 + Math.floor(R() * 2);
        const x1 = Math.floor(R() * (en + 1)), y1 = Math.floor(R() * (boy + 1));
        const x2 = x1 + dx * kat, y2 = y1 + dy * kat;
        if (x2 < 0 || x2 > en || y2 < 0 || y2 > boy) { dg.length = 0; break; }
        dg.push({ ad: AD4[i], p1: [x1, y1], p2: [x2, y2] });
      }
      if (dg.length !== 4) continue;
      const spec = { tip_id: 'kareli-dogrular', parametreler: { en, boy, dogrular: dg } };
      let g; try { g = gorselUret(spec, 5); } catch { continue; }
      if (g.bulgular.some((b) => b.ciddiyet === 'hata')) continue;
      const il = g.olgular.iliskiler;
      const sayilar = (t) => Object.entries(il).filter(([, v]) => v === t).map(([k]) => k);
      if (sayilar('cakisik').length) continue;
      if (sayilar(istenen).length !== 1) continue;
      if (istenen === 'paralel' && sayilar('dik').length > 1) continue;
      const cift = (k) => k.replace('|', ' ile ');
      const dogruAnahtar = sayilar(istenen)[0];
      const digerleri = Object.keys(il).filter((k) => k !== dogruAnahtar);
      const cel = karistir(digerleri).slice(0, 3);
      const tr = istenen === 'paralel' ? 'paraleldir' : 'birbirine diktir';
      ekle({ kod: 'MAT.5.3.4', konu: 'Geometrik Şekiller', alt_konu: istenen === 'paralel' ? 'Paralel doğrular' : 'Dik doğrular', zorluk: istenen === 'paralel' ? 2 : 3, spec,
        kok: `Yukarıdaki kareli zeminde k, l, m ve n doğruları verilmiştir. Bu doğrulardan hangi ikisi ${tr}?`,
        dogru: cift(dogruAnahtar), celdirici: cel.map(cift),
        gerekce: cel.map((k) => (il[k] === 'paralel' ? 'Bu doğrular paraleldir.' : il[k] === 'dik' ? 'Bu doğrular birbirine diktir.' : 'Bu doğrular birbirini dik olmayan bir açıyla keser (veya paralel değildir).')),
        ipucu: istenen === 'paralel' ? 'Paralel doğrular kareli zeminde aynı yönde, aynı eğimle ilerler.' : 'Dik doğrular arasındaki açı 90°’dir; kareli zeminde bir doğrunun yönü yer değiştirip bir işaret değişir.',
        cozum: [`Doğruların kareli zeminde yatay ve dikey ilerleme miktarları karşılaştırılır.`, `${cift(dogruAnahtar)} doğruları ${tr}.`],
        dogrulama: [{ yol: ['iliskiler', dogruAnahtar], beklenen: istenen }] });
      return;
    }
    throw new Error(`kareli_uretilemedi:${istenen}`);
  }
  
  
  // ---- T3: kesişen doğrularda açı (tek bilinmeyen: ters mi komşu mu, şekilden okunur) ----
  function aciSorusu(tur, theta) {
    const bolge = tur === 'ters' ? 2 : (R() < 0.5 ? 1 : 3);
    const dogru = tur === 'ters' ? theta : 180 - theta;
    const diger = tur === 'ters' ? 180 - theta : theta; // ters/komşu karıştırma sonucu
    const spec = { tip_id: 'kesisen-dogrular', parametreler: { dogrular: ['d', 'e'], theta, olcekli: false,
      isaretler: [{ bolge: 0, goster: 'deger' }, { bolge, goster: 'sembol', sembol: '■' }] } };
    const havuz = [30, 45, 60, 75, 105, 120, 135, 150].filter((v) => v !== dogru && v !== diger && v !== 90);
    // 90° sabit çeldirici olmasın: her zaman yanlış olduğu için metin tek başına eler. İki çeldirici rastgele seçilir.
    const cel = [diger, ...karistir(havuz).slice(0, 2)];
    ekle({ kod: 'MAT.5.3.4', konu: 'Geometrik Şekiller', alt_konu: 'Kesişen iki doğrunun oluşturduğu açılar', zorluk: tur === 'ters' ? 1 : 2, spec, olcekli: false,
      kok: `d ve e doğruları bir noktada kesişmiştir. Şekil ölçekli çizilmemiştir. Bu doğrular arasında kalan açılardan biri ${theta}°'dir. Buna göre ■ ile gösterilen açı kaç derecedir?`,
      dogru: `${dogru}°`, celdirici: cel.map((v) => `${v}°`),
      gerekce: [tur === 'ters' ? 'Komşu açıyı bulup ters açıyla karıştırma.' : 'Komşu açıyı verilen açıya eşit sanma; komşu açılar bütünlerdir, ters açılar eşittir.', 'Kesişen doğruları dik sanma; açı değeri verilenlerden hesaplanır.', `${cel[2]}° değeri verilen açıdan doğru bir ilişkiyle elde edilmez.`],
      ipucu: tur === 'ters' ? 'Ters açılar birbirine eşittir.' : 'Komşu açıların ölçüleri toplamı 180°’dir.',
      cozum: tur === 'ters' ? [`■ açısı ${theta}° olan açının ters açısıdır.`, 'Ters açıların ölçüleri eşittir.', `■ = ${theta}°`] : [`■ açısı ${theta}° olan açının komşusudur.`, `Komşu açıların ölçüleri toplamı 180° olduğundan ■ = 180° − ${theta}° = ${dogru}°.`],
      dogrulama: [{ yol: ['bolge_degerleri', bolge], beklenen: dogru }] });
  }
  
  // ---- T5: çokgen köşegenleri — şıklar ardışık pencere (T(n−k)…), tek bir n'ye işaret etmez ----
  function cokgenSorusu(n, tur) {
    const bir = tur === 'bir_koseden';
    const harfler = 'ABCDEFGHIJKL'.slice(0, n).split('');
    const kosegenler = bir ? [...Array(n - 3)].map((_, k) => [0, k + 2]) : [];
    const spec = { tip_id: 'cokgen', parametreler: { n, harfler, kosegenler, baslangic_aci: 90 + Math.floor(180 / n) } };
    const f = (m) => (bir ? m - 3 : (m * (m - 3)) / 2); // m köşeli çokgen için istenen değer
    const kp = konum();                               // doğru şık konumu (harf dengesi)
    const baslangicN = n - kp;                      // pencere: n−konum … n−konum+3 köşeli çokgenler
    if (baslangicN < 4) throw new Error('pencere_cok_kucuk');
    const nler = [0, 1, 2, 3].map((k) => baslangicN + k);
    const sirali = nler.map((m) => String(f(m)));
    const gerekce = nler.map((m) => (m === n ? '' : `${f(m)}, ${m} köşeli bir çokgen için bulunur; çokgenin köşe sayısı yanlış sayılmıştır.`));
    ekle({ kod: 'MAT.5.3.6', konu: 'Geometrik Şekiller', alt_konu: 'Çokgenlerin köşegenleri', zorluk: bir ? 2 : 3, spec, sirali, dogru: String(f(n)), gerekce,
      kok: bir ? 'Yukarıdaki düzgün çokgenin A köşesinden çizilebilen köşegenler çizilmiştir. Buna göre bu çokgenin bir köşesinden çizilebilecek köşegen sayısı kaçtır?' : 'Yukarıda köşeleri harflerle adlandırılmış bir düzgün çokgen verilmiştir. Bu çokgenin tüm köşegenleri çizilirse kaç köşegen elde edilir?',
      ipucu: bir ? 'Bir köşeden kendisine ve iki komşusuna köşegen çizilemez.' : 'Önce bir köşeden çizilen köşegen sayısını bul; her köşegenin iki ucu olduğunu unutma.',
      cozum: bir ? [`Çokgenin ${n} köşesi vardır.`, 'Bir köşeden kendisine ve iki komşu köşeye köşegen çizilemez.', `${n} − 3 = ${n - 3}`]
        : [`Çokgenin ${n} köşesi vardır; bir köşeden ${n - 3} köşegen çizilir.`, `${n} × ${n - 3} = ${n * (n - 3)}; her köşegen iki kez sayıldığı için ${n * (n - 3)} ÷ 2 = ${f(n)}.`],
      dogrulama: [bir ? { yol: ['bir_koseden_kosegen'], beklenen: f(n) } : { yol: ['kosegen_sayisi'], beklenen: f(n) }] });
  }
  
  return { cemberSorusu, sembolSorusu, aciSorusu, kareliSorusu, cokgenSorusu };
}

const MUFREDAT = 'Maarif Modeli Ortaokul Matematik DÖP (5-8)';
const ACILAR = [35, 40, 50, 55, 65, 70, 110, 115, 125, 130, 140, 145];
export const KAYIT = [
  { id: 'mat5-cember', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-GEO', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.3.1'], fabrika: kur,
    uret: (f, g) => f.cemberSorusu(g.sec(['cap', 'yaricap', 'kiris'])) },
  { id: 'mat5-dogru-isin', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-GEO', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.3.1'], fabrika: kur,
    uret: (f, g) => f.sembolSorusu(g.sec(['isin', 'dogru', 'dogru_parcasi']), Math.floor(g.R() * 5)) },
  { id: 'mat5-kesisen-aci', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-GEO', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.3.4'], fabrika: kur,
    uret: (f, g) => f.aciSorusu(g.sec(['ters', 'komsu']), g.sec(ACILAR)) },
  { id: 'mat5-kareli-dogru', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-GEO', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.3.4'], fabrika: kur,
    uret: (f, g) => f.kareliSorusu(g.sec(['paralel', 'dik'])) },
  { id: 'mat5-cokgen-kosegen', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-GEO', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.3.6'], fabrika: kur,
    uret: (f, g) => f.cokgenSorusu(g.sec([6, 7, 8, 9, 10, 11, 12]), g.sec(['tum', 'bir_koseden'])) },
];
