// 4. sınıf Fen Bilimleri (önceki program) — Dünya'nın dönme/dolanma hareketleri (F.4.1.2.1); mıknatısın çektiği nesne (F.4.3.2.2); maddenin hâlleri (F.4.4.3.1).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 4. sınıf; program: önceki program)';
const HARF = ['K', 'L', 'M', 'N'];

// ---- dönme ve dolanma ----
const DONME_ELEM = ['donme', 'dolanma', 'isik', 'eksen'];
const DONME_TANIM = {
  donme: 'Dünya’nın kendi ekseni etrafındaki dönme hareketidir',
  dolanma: 'Dünya’nın Güneş etrafındaki dolanma (yörünge) hareketidir',
  isik: 'Güneş’ten Dünya’ya gelen ışığı gösterir; Dünya’nın hareketi değildir',
  eksen: 'Dünya’nın kendi dönme ekseninin çizgisidir; bir hareket değil, eksen gösterir',
};
export function kurDonme({ sec, karistir, ekle, konum }) {
  const kod = { kod: 'F.4.1.2.1', konu: 'Dünya ve Evren', alt_konu: 'Dünya’nın dönme ve dolanma hareketleri' };
  function donmeSorusu() {
    const k = konum(), hedef = sec(['donme', 'dolanma']), cevap = HARF[k];
    const kalan = karistir(HARF.filter((_, i) => i !== k));
    const harfler = { [hedef]: cevap };
    DONME_ELEM.filter((e) => e !== hedef).forEach((e, i) => { harfler[e] = kalan[i]; });
    const kok = hedef === 'donme'
      ? sec(['Şekilde Dünya’nın kendi ekseni etrafındaki dönme hareketini gösteren işaret hangi harfle belirtilmiştir?', 'Şekilde, Dünya’nın kendi ekseni etrafında dönmesini gösteren işaret hangi harfle gösterilmiştir?'])
      : sec(['Şekilde Dünya’nın Güneş etrafındaki dolanma hareketini gösteren işaret hangi harfle belirtilmiştir?', 'Şekilde, Dünya’nın Güneş çevresindeki yörüngesinde hareket ettiğini gösteren işaret hangi harfle gösterilmiştir?']);
    const duzen = { dolanma: sec([0, 1, 2]), donme: sec([0, 1]), isik: sec([0, 1]) };
    ekle({ ...kod, zorluk: 2, spec: { tip_id: 'h2-donme-dolanma', parametreler: { harfler, duzen } }, sirali: HARF, dogru: cevap,
      kok,
      gerekce: HARF.map((h) => {
        if (h === cevap) return '';
        const e = DONME_ELEM.find((x) => harfler[x] === h);
        return `${h} ile gösterilen işaret, ${DONME_TANIM[e].charAt(0).toLocaleLowerCase('tr-TR')}${DONME_TANIM[e].slice(1)}; soruda istenen hareket bu değildir.`;
      }),
      ipucu: 'Dönme bir eksen etrafındaki, dolanma ise bir merkez (Güneş) etrafındaki harekettir.',
      cozum: ['Dönme, Dünya’nın kendi ekseni etrafındaki harekettir; dolanma ise Güneş çevresindeki yörünge hareketidir.', `Soruda istenen ${hedef === 'donme' ? 'dönme' : 'dolanma'} hareketini gösteren harf ${cevap}’dir.`],
      dogrulama: [{ yol: ['harf', hedef], beklenen: cevap }] });
  }
  return { donmeSorusu };
}

// ---- mıknatısın çektiği nesne ----
const SEKILLER = ['kare', 'daire', 'ucgen', 'altigen'];
export function kurMiknatisDeney({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'F.4.3.2.2', konu: 'Kuvvet ve Hareket', alt_konu: 'Mıknatısın etki ettiği maddeler' };
  function deneySorusu() {
    const k = konum();
    const nesneler = HARF.map((harf) => ({ harf, sekil: sec(SEKILLER) }));
    const cevap = HARF[k];
    const kok = sec([
      'Şekilde çubuk bir mıknatıs, altında bulunan harfli nesnelere yaklaştırılmıştır. Mıknatıs bu nesnelerden hangisini çekmiştir?',
      'Yukarıdaki deneyde mıknatıs altındaki nesnelerden yalnız birini yukarı doğru çekmiştir. Bu nesne hangi harfle gösterilmiştir?',
    ]);
    ekle({ ...kod, zorluk: 2, spec: { tip_id: 'h2-miknatis-deney', parametreler: { nesneler, cekilen: cevap } }, sirali: HARF, dogru: cevap,
      kok,
      gerekce: HARF.map((h) => (h === cevap ? '' : `${h} nesnesine doğru bir ok çizilmemiştir; mıknatıs bu nesneyi çekmemiştir.`)),
      ipucu: 'Deneyde mıknatısın bir nesneyi yukarı doğru çektiği, nesneden mıknatısa çizilen ok ile gösterilmiştir.',
      cozum: ['Mıknatıs yalnızca demir gibi bazı maddeleri çeker; deneyde çekilen nesne mıknatısa doğru bir okla gösterilmiştir.', `Mıknatısın çektiği nesne ${cevap} harfi ile gösterilendir.`],
      dogrulama: [{ yol: ['cekilen'], beklenen: cevap }] });
  }
  return { deneySorusu };
}

// ---- maddenin hâlleri: kaplardaki madde ----
const KAP_SEKIL = ['kutu', 'yamuk', 'dar'];
const HAL_AD = { kati: 'katı', sivi: 'sıvı', gaz: 'gaz' };
const HAL_TANIM = {
  kati: 'Katılar kendi şeklini korur ve bulunduğu kabın şeklini almaz',
  sivi: 'Sıvılar bulunduğu kabın şeklini alır, ancak kabın tamamını doldurmaz',
  gaz: 'Gazlar bulunduğu kabın tamamını doldurur ve kabın şeklini alır',
};
const HAL_KOK = {
  kati: ['Şekilde dört kap gösterilmiştir. Hangi kaptaki madde kendi şeklini korur ve bulunduğu kabın şeklini almaz?', 'Yukarıdaki kaplardan hangisinde bulunan madde kendi şeklini korur ve kabın şeklini almaz?'],
  sivi: ['Şekilde dört kap gösterilmiştir. Hangi kaptaki madde bulunduğu kabın şeklini alır, ancak kabın tamamını doldurmaz?', 'Yukarıdaki kaplardan hangisinde bulunan madde kabın şeklini alır ve kabı tamamen doldurmaz?'],
  gaz: ['Şekilde dört kap gösterilmiştir. Hangi kaptaki madde bulunduğu kabın tamamını doldurur?', 'Yukarıdaki kaplardan hangisinde bulunan madde kabın tamamını doldurmuştur?'],
};
export function kurHal({ sec, karistir, ekle, konum }) {
  const kod = { kod: 'F.4.4.3.1', konu: 'Madde ve Değişim', alt_konu: 'Maddenin hâlleri' };
  function halSorusu() {
    const k = konum(), hedef = sec(['kati', 'sivi', 'gaz']), cevap = HARF[k];
    const diger = hedef === 'kati' ? ['sivi', 'gaz'] : hedef === 'sivi' ? ['kati', 'gaz'] : ['kati', 'sivi'];
    const hallar = HARF.map((_, i) => (i === k ? hedef : sec(diger)));
    const kaplar = HARF.map((ad, i) => ({ ad, sekil: sec(KAP_SEKIL), hal: hallar[i] }));
    ekle({ ...kod, zorluk: 2, spec: { tip_id: 'a5-kap-hal', parametreler: { kaplar } }, sirali: HARF, dogru: cevap,
      kok: sec(HAL_KOK[hedef]),
      gerekce: HARF.map((h, i) => (i === k ? '' : `${h} kabındaki madde ${HAL_AD[hallar[i]]} hâldedir. ${HAL_TANIM[hallar[i]]}; soruda aranan özellik bu hâle ait değildir.`)),
      ipucu: 'Her kaptaki maddenin kendi şeklini koruyup korumadığına, kabı doldurup doldurmadığına bak.',
      cozum: [`${HAL_TANIM[hedef]}.`, `Bu özelliği taşıyan madde ${cevap} kabındadır.`],
      dogrulama: HARF.map((h, i) => ({ yol: ['haller', h], beklenen: hallar[i] })) });
  }
  return { halSorusu };
}

export const KAYIT = [
  { id: 'b2-fen4-donme-dolanma', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-DOL', mufredat_surum: MUFREDAT, kodlar: ['F.4.1.2.1'], fabrika: kurDonme, uret: (f) => f.donmeSorusu() },
  { id: 'b2-fen4-miknatis-deney', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-MDN', mufredat_surum: MUFREDAT, kodlar: ['F.4.3.2.2'], fabrika: kurMiknatisDeney, uret: (f) => f.deneySorusu() },
  { id: 'b2-fen4-madde-hal', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-HAL', mufredat_surum: MUFREDAT, kodlar: ['F.4.4.3.1'], fabrika: kurHal, uret: (f) => f.halSorusu() },
];
