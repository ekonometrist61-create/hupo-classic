// 1. sınıf Matematik — dağınık nesne sayma ve karşılaştırma şablonları (20'ye kadar).
const MUFREDAT = 'TYMM 1-2 taslak 2026-27';
const AD = { daire: 'daire', kare: 'kare', ucgen: 'üçgen' };

export function kur({ R, sec, karistir, ekle, konum }) {
  function planla() {
    const adet = sec([2, 3]), sekiller = karistir(['daire', 'kare', 'ucgen']).slice(0, adet);
    let g = 0; const liste = [];
    while (liste.length < adet && g++ < 200) { const s = 1 + Math.floor(R() * 7); if (!liste.includes(s)) liste.push(s); }
    if (liste.length < adet) throw new Error('sayi_cesitliligi_yok');
    return sekiller.map((sekil, i) => ({ sekil, sayi: liste[i] }));
  }
  function saymaSorusu() {
    const sekiller = planla(), toplam = sekiller.reduce((t, x) => t + x.sayi, 0), kp = konum();
    const hedef = sec(sekiller), c = hedef.sayi, start = c - kp;
    if (start < 0 || start + 3 > 20) throw new Error('pencere_disi');
    const sirali = [0, 1, 2, 3].map((i) => String(start + i));
    const spec = { tip_id: 'nesne-sayma', parametreler: { sekiller, tohum: 1 + Math.floor(R() * 100000) } };
    ekle({ kod: 'MAT.1.1.2', konu: 'Sayılar', alt_konu: 'Dağınık nesneleri sayma', zorluk: toplam <= 10 ? 1 : 2, spec, sirali, dogru: String(c),
      gerekce: sirali.map((s) => (Number(s) === c ? '' : `${s}, ${Math.abs(Number(s) - c)} ${Number(s) > c ? 'fazla' : 'eksik'} sayılmış bir sonuçtur; sayarken aynı şekli iki kez saymak ya da bir şekli atlamak bu sonucu verir.`)),
      kok: `Yukarıdaki şekil grubunda kaç tane ${AD[hedef.sekil]} vardır?`,
      ipucu: `Yalnız ${AD[hedef.sekil]} olanları say; saydığın her şekle bir işaret koyabilirsin.`,
      cozum: [`Şekiller arasından yalnız ${AD[hedef.sekil]} olanlar tek tek sayılır.`, `${AD[hedef.sekil][0].toUpperCase()}${AD[hedef.sekil].slice(1)} sayısı ${c}’dir.`],
      dogrulama: [{ yol: ['sayilar', hedef.sekil], beklenen: c }] });
  }
  function enCokSorusu() {
    const sekiller = planla(); if (sekiller.length < 3) throw new Error('uc_sekil_gerekir');
    const s = [...sekiller].sort((a, b) => b.sayi - a.sayi), dogru = AD[s[0].sekil];
    const cel = [AD[s[1].sekil], AD[s[2].sekil], 'dikdörtgen'];
    const spec = { tip_id: 'nesne-sayma', parametreler: { sekiller, tohum: 1 + Math.floor(R() * 100000) } };
    ekle({ kod: 'MAT.1.1.1', konu: 'Sayılar', alt_konu: 'Nesne gruplarını karşılaştırma', zorluk: 2, spec, dogru, celdirici: cel,
      gerekce: [`${cel[0]} sayısı (${s[1].sayi}) en çok olandan azdır.`, `${cel[1]} sayısı (${s[2].sayi}) en çok olandan azdır.`, 'Şekilde dikdörtgen yoktur.'],
      kok: 'Yukarıdaki şekil grubunda en çok bulunan şekil hangisidir?',
      ipucu: 'Her şekilden kaç tane olduğunu ayrı ayrı say, sonra karşılaştır.',
      cozum: sekiller.map((x) => `${AD[x.sekil]}: ${x.sayi} tane`).concat([`En çok olan şekil ${{ daire: 'daire', kare: 'kare', ucgen: 'üçgen' }[s[0].sekil]}dir`.replace('daire' + 'dir', 'dairedir').replace('kare' + 'dir', 'karedir')]),
      dogrulama: [{ yol: ['en_cok'], beklenen: s[0].sekil }] });
  }
  return { saymaSorusu, enCokSorusu };
}

export const KAYIT = [
  { id: 'mat1-nesne-sayma', ders: 'Matematik', sinif: 1, idOnek: 'MAT1-SAY', mufredat_surum: MUFREDAT, kodlar: ['MAT.1.1.2'], fabrika: kur, uret: (f) => f.saymaSorusu() },
  { id: 'mat1-en-cok', ders: 'Matematik', sinif: 1, idOnek: 'MAT1-ENC', mufredat_surum: MUFREDAT, kodlar: ['MAT.1.1.1'], fabrika: kur, uret: (f) => f.enCokSorusu() },
];

