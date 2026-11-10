// 5. sınıf Fen Bilimleri — üç şekilli şablon (tipler-h4.mjs):
//  FB.5.4.1 ışığın doğrusal yol izlemesi (h4-delik), FB.5.5.5 ısı iletkeni / yalıtkanı (h4-cubuk),
//  FB.5.4.2 maddelerin ışığı geçirme durumu (h4-gecirgenlik). Cevap her zaman şekilden okunur.
const MUFREDAT = 'Maarif Modeli Fen DÖP (tymm 2026-09-02)';
const HARF = ['A', 'B', 'C', 'D'];

// ---- FB.5.4.1: delikli kartonlar ve perde ----
// tipler-h4.mjs ile aynı sabitler: ışık kaynağı x=22, perde x=160, delik yarıçapı 7.
const DELIK_SOL = 22, DELIK_SAG = 160, DELIK_R = 7;
const KART_X = [56, 84, 112, 140];
const YUKSEKLIK = [44, 50, 56, 62, 68, 74, 80, 86];
export function kurDelik({ R, sec, karistir, ekle, konum }) {
  function delikSorusu() {
    const k = konum();
    const paneller = HARF.map((ad, i) => {
      const nK = sec([2, 3]);
      let kaynakY, ekranY;
      do { kaynakY = sec(YUKSEKLIK); ekranY = sec(YUKSEKLIK); } while (Math.abs(ekranY - kaynakY) < 20);
      const xs = karistir(KART_X).slice(0, nK).sort((a, b) => a - b);
      // doğru düzenekte tüm delikler kaynak–perde doğrusu üzerinde; diğerlerinde bir delik ±14 ya da ±18 px kaydırılmış
      const kartlar = xs.map((x) => ({ x, y: Math.round(kaynakY + ((ekranY - kaynakY) * (x - DELIK_SOL)) / (DELIK_SAG - DELIK_SOL)) }));
      if (i !== k) { const j = Math.floor(R() * nK); kartlar[j].y += sec([-18, -14, 14, 18]); }
      return { ad, kaynakY, ekranY, kartlar };
    });
    ekle({ kod: 'FB.5.4.1', konu: 'Işık', alt_konu: 'Işığın doğrusal yolla yayılması', zorluk: 2,
      spec: { tip_id: 'h4-delik', parametreler: { paneller } }, sirali: HARF, dogru: HARF[k],
      kok: sec([
        'Şekilde, bir ışık kaynağı, delikli kartonlar ve bir perdeden oluşan dört ayrı düzenek gösterilmiştir. Hangi düzenekte ışık perdeye ulaşarak perdede bir nokta oluşturur?',
        'Aynı ışık kaynağı ve perdeyle kurulmuş dört düzenek şekildedir. Işığın kaynaktan çıkıp perdeye ulaştığı düzenek hangisidir?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : `${h} düzeneğinde deliklerin merkezleri ışık kaynağı ile perde arasındaki doğru üzerinde değildir; ışık deliklerden geçemez ve perdeye ulaşamaz.`)),
      ipucu: 'Işık doğrusal yolla ilerler. Işık kaynağı, deliklerin merkezleri ve perdedeki nokta aynı doğru üzerinde mi diye bak.',
      cozum: ['Işık doğrusal bir yol izler. Işığın perdeye ulaşması için kaynak, tüm deliklerin merkezleri ve perde aynı doğru üzerinde olmalıdır.',
        `${HARF[k]} düzeneğinde deliklerin merkezleri bu doğru üzerindedir; ışık perdeye ulaşır ve perdede bir nokta oluşur.`],
      dogrulama: [{ yol: ['gecen'], beklenen: HARF[k] }, ...HARF.map((h) => ({ yol: ['isik', h], beklenen: h === HARF[k] }))] });
  }
  return { delikSorusu };
}

// ---- FB.5.5.5: çubuklarda ısı iletimi ----
export function kurCubuk({ R, sec, karistir, ekle, konum }) {
  function cubukSorusu() {
    const k = konum(), iletken = R() < 0.5;
    // hedef çubuk ile diğerleri arasında en az 2 pul fark: iletkende tüm pullar (4) düşer, yalıtkanda 0 ya da 1 pul düşer
    const hedef = iletken ? 4 : sec([0, 1]);
    const dig = [0, 1, 2].map(() => (iletken ? sec([0, 1, 2]) : sec([hedef + 2, hedef + 3, 4].filter((v) => v <= 4))));
    const sira = [...dig]; sira.splice(k, 0, hedef);
    const cubuklar = sira.map((dusen, i) => ({ ad: HARF[i], dusen }));
    ekle({ kod: 'FB.5.5.5', konu: 'Isı', alt_konu: 'Isı iletkenliği ve yalıtkanlık', zorluk: 2,
      spec: { tip_id: 'h4-cubuk', parametreler: { cubuklar } }, sirali: HARF, dogru: HARF[k],
      kok: sec(iletken ? [
        'Aynı boyda dört çubuk, ısı kaynağına yakın uçlarından ısıtılmıştır. Çubuklara mumla pullar tutturulmuştur; mum eridikçe pullar düşer. Düşen pul sayısına göre hangi çubuk ısıyı en iyi iletmiştir?',
        'Aynı boyda dört çubuğun her biri ısı kaynağında ısıtılmış ve üzerlerindeki mumla tutturulmuş pullar gözlenmiştir. Düşen pul sayısına göre ısıyı en iyi ileten çubuk hangisidir?']
        : [
        'Aynı boyda dört çubuk, ısı kaynağına yakın uçlarından ısıtılmıştır. Çubuklara mumla pullar tutturulmuştur; mum eridikçe pullar düşer. Düşen pul sayısına göre hangi çubuk ısıyı en az iletmiş, yani en iyi yalıtkan olmuştur?',
        'Aynı boyda dört çubuğun her biri ısı kaynağında ısıtılmış ve üzerlerindeki mumla tutturulmuş pullar gözlenmiştir. Düşen pul sayısına göre en iyi yalıtkan olan çubuk hangisidir?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : `${h} çubuğunda ${sira[i]} pul düşmüştür. ${iletken ? `Doğru şıkta ${hedef} pul düşmüştür; ısıyı en iyi ileten çubukta en çok pul düşer.` : `Doğru şıkta ${hedef} pul düşmüştür; en iyi yalıtkan çubukta en az pul düşer.`}`)),
      ipucu: 'Düşen pul sayısı, ısının çubukta ne kadar ilerlediğini gösterir. Her çubukta kaç pulun düştüğünü say.',
      cozum: ['Isı, ısı kaynağına yakın uçtan başlayarak iletken maddelerde hızla ilerler ve mumu eritip pulların düşmesine neden olur.',
        `${HARF[k]} çubuğunda ${hedef} pul düşmüştür; ${iletken ? 'en çok pul düşen çubuk ısıyı en iyi ileten çubuktur.' : 'en az pul düşen çubuk ısıyı en iyi yalıtan çubuktur.'}`],
      dogrulama: [{ yol: [iletken ? 'en_iletken' : 'en_yalitkan'], beklenen: HARF[k] }, ...HARF.map((h, i) => ({ yol: ['dusen', h], beklenen: sira[i] }))] });
  }
  return { cubukSorusu };
}

// ---- FB.5.4.2: ışık geçirme durumuna göre maddeler ----
export function kurGecirgen({ R, sec, karistir, ekle, konum }) {
  const ACIKLAMA = {
    yok: 'perdede hiç görüntü oluşmamıştır; madde ışığı geçirmemektedir.',
    bulanik: 'perdedeki görüntü bulanıktır; madde ışığı kısmen geçirmektedir.',
    net: 'perdede görüntü nettir; madde ışığı tam geçirmektedir.',
  };
  function gecirgenSorusu() {
    const k = konum(), opak = R() < 0.5;
    const hedef = opak ? 'yok' : 'net';
    // dört düzenek: hedef tür bir kez, diğer ikisi bulanık, kalan bir tür (ters tür) bir kez
    const dig = karistir(['yok', 'net', 'bulanik', 'bulanik'].filter((t) => t !== hedef));
    const sira = [...dig]; sira.splice(k, 0, hedef);
    const cisim = sec([18, 22, 26]), levha = sec([12, 14, 16, 20]);
    const paneller = sira.map((goruntu, i) => ({ ad: HARF[i], goruntu }));
    ekle({ kod: 'FB.5.4.2', konu: 'Işık', alt_konu: 'Maddelerin ışığı geçirme durumu', zorluk: 2,
      spec: { tip_id: 'h4-gecirgenlik', parametreler: { paneller, cisim, levha } }, sirali: HARF, dogru: HARF[k],
      kok: sec(opak ? [
        'Şekilde her düzenekte solda bir ışık kaynağı ve bir cisim, ortada bir madde levhası, sağda ise bir perde vardır. Perdede hiç görüntü oluşmayan madde ışığı geçirmez. Buna göre hangi düzenekteki madde ışığı hiç geçirmemektedir?',
        'Dört düzenekte de cismin ışıkla perdeye düşürülen görüntüsüne bakılmıştır. Perdede hiç görüntü oluşmayan madde ışığı geçirmez. Buna göre perdede hiç görüntü oluşmayan düzenek hangisidir?']
        : [
        'Şekilde her düzenekte solda bir ışık kaynağı ve bir cisim, ortada bir madde levhası, sağda ise bir perde vardır. Hangi düzenekteki madde, cismin görüntüsünü perdede net olarak oluşturmaktadır?',
        'Dört düzenekte de cismin ışıkla perdeye düşürülen görüntüsüne bakılmıştır. Perdede keskin bir görüntü oluşan düzenek hangisidir?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : `${h} düzeneğinde ${ACIKLAMA[sira[i]]}`)),
      ipucu: 'Perdedeki görüntünün net, bulanık ya da hiç olmadığına bak. Işığı geçiren maddede görüntü oluşur.',
      cozum: ['Işığı geçiren madde, cismin görüntüsünü perdeye oluşturur. Net görüntü saydam maddede, bulanık görüntü yarı saydam maddede oluşur; görüntü hiç yoksa madde ışığı geçirmez.',
        `${HARF[k]} düzeneğinde ${opak ? 'perdede görüntü oluşmadığından madde ışığı geçirmez (saydam olmayan madde).' : 'görüntü keskin olduğundan madde ışığı tam geçirir (saydam madde).'}`],
      dogrulama: [{ yol: [opak ? 'yok' : 'net'], beklenen: HARF[k] }, ...HARF.map((h, i) => ({ yol: ['goruntu', h], beklenen: sira[i] }))] });
  }
  return { gecirgenSorusu };
}

export const KAYIT = [
  { id: 'fen5-isik-dogrusal', ders: 'Fen Bilimleri', sinif: 5, idOnek: 'FEN5-DOG', mufredat_surum: MUFREDAT, kodlar: ['FB.5.4.1'], fabrika: kurDelik,
    uret: (f) => f.delikSorusu() },
  { id: 'fen5-isi-iletim', ders: 'Fen Bilimleri', sinif: 5, idOnek: 'FEN5-ISI', mufredat_surum: MUFREDAT, kodlar: ['FB.5.5.5'], fabrika: kurCubuk,
    uret: (f) => f.cubukSorusu() },
  { id: 'fen5-gecirgenlik', ders: 'Fen Bilimleri', sinif: 5, idOnek: 'FEN5-GEC', mufredat_surum: MUFREDAT, kodlar: ['FB.5.4.2'], fabrika: kurGecirgen,
    uret: (f) => f.gecirgenSorusu() },
];
