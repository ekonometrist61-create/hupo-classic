// 2. sınıf Matematik — bütün, yarım ve çeyrek (MAT.2.1.7). Şekil tipi: b1-bolunmus (tipler-b1.mjs).
// Boyalı kısmın adı, boyanmamış kısmın adı ve dört şekilden doğru olanı seçme. Eş olmayan bölmeler tuzak olarak çizilir.
const MUFREDAT = '2026 Maarif Modeli İlkokul Matematik DÖP (1-4), 2. sınıf bölümü';
const ADLAR = ['Ayşe', 'Efe', 'Elif', 'Mert', 'Zeynep', 'Ali', 'Defne', 'Kaan', 'Deniz', 'Can', 'Sude', 'Arda'];
const NESNE = { daire: ['pizza', 'pasta', 'tabak', 'saat'], kare: ['kâğıt', 'fayans', 'peçete', 'pencere'], serit: ['çikolata', 'kurdele', 'bayrak', 'cetvel'] };
const TERIMLER = ['Yarısı', 'Çeyreği', 'Bütünü', 'Üç çeyreği'];
const ISIM = { yarım: 'Yarısı', çeyrek: 'Çeyreği', bütün: 'Bütünü', 'üç çeyrek': 'Üç çeyreği' };
const terimOf = (k, n) => (k === n ? 'bütün' : n === 2 && k === 1 ? 'yarım' : n === 4 ? { 1: 'çeyrek', 2: 'yarım', 3: 'üç çeyrek' }[k] ?? null : null);
const parcaSayisi = (sh) => (sh.sekil === 'daire' ? sh.n : sh.kesim.kosegen ? 2 : ((sh.kesim.dikey?.length ?? 0) + 1) * ((sh.kesim.yatay?.length ?? 0) + 1));
function esitMi(sh) {
  if (sh.sekil === 'daire' || sh.kesim.kosegen) return true;
  const fark = (c) => { const xs = [0, ...(c ?? []), 1], w = xs.slice(1).map((v, q) => v - xs[q]); return Math.max(...w) - Math.min(...w) < 1e-9; };
  return fark(sh.kesim.dikey) && fark(sh.kesim.yatay);
}
const terimSekil = (sh) => (esitMi(sh) ? terimOf(sh.boyali.length, parcaSayisi(sh)) : 'esit_degil');

export function kur({ R, sec, karistir, ekle, konum }) {
  const yaz = (s) => JSON.stringify(s);
  function esit(aile, n) {
    if (aile === 'daire') return { sekil: 'daire', n };
    if (aile === 'kare') {
      if (n === 2) return { sekil: 'kare', kesim: sec([{ dikey: [0.5] }, { yatay: [0.5] }, { kosegen: true }]) };
      if (n === 3) return { sekil: 'kare', kesim: sec([{ dikey: [1 / 3, 2 / 3] }, { yatay: [1 / 3, 2 / 3] }]) };
      return { sekil: 'kare', kesim: sec([{ dikey: [0.5], yatay: [0.5] }, { dikey: [0.25, 0.5, 0.75] }, { yatay: [0.25, 0.5, 0.75] }]) };
    }
    return { sekil: 'serit', kesim: { dikey: Array.from({ length: n - 1 }, (_, i) => (i + 1) / n) } };
  }
  function esitDegil(aile, n) { // yalnız kare ve şerit; hiçbir tek parça ya da bitişik ikili tam çeyrek/yarım alanı vermez
    if (aile === 'kare') {
      if (n === 2) return { sekil: 'kare', kesim: sec([{ dikey: [0.3] }, { dikey: [0.7] }, { yatay: [0.3] }, { yatay: [0.7] }]) };
      return { sekil: 'kare', kesim: sec([{ dikey: [0.12, 0.45, 0.8] }, { dikey: [0.1, 0.45, 0.85] }, { dikey: [0.3], yatay: [0.7] }]) };
    }
    if (n === 2) return { sekil: 'serit', kesim: { dikey: [sec([0.3, 0.7])] } };
    return { sekil: 'serit', kesim: { dikey: sec([[0.12, 0.45, 0.8], [0.1, 0.45, 0.85], [0.18, 0.5, 0.8]]) } };
  }
  function boyaliSec(sh, k) {
    const n = parcaSayisi(sh), idx = [...Array(n).keys()];
    if (k === 1 || k === n - 1 || k === n) return karistir(idx).slice(0, k).sort((a, b) => a - b);
    if (sh.sekil === 'daire') { const j = sec(idx); return [j, (j + 1) % n].sort((a, b) => a - b); } // k = n/2: bitişik iki parça
    if (sh.kesim.dikey?.length === 1 && sh.kesim.yatay?.length === 1) return sec([[0, 1], [2, 3], [0, 2], [1, 3]]);
    const j = sec([0, 1, 2]); return [j, j + 1];
  }

  function tekSekil(bos) {
    const aile = sec(['daire', 'kare', 'serit']), [n, k] = sec([[2, 1], [2, 1], [4, 1], [4, 1], [4, 2], [4, 2], [4, 3], [4, 3], [2, 2]]);
    if (bos && k === n) throw new Error('bos_yok');
    const sh = esit(aile, n); sh.boyali = boyaliSec(sh, k);
    const terim = terimOf(bos ? n - k : k, n);
    if (!terim) throw new Error('terim_yok');
    const dogru = ISIM[terim], cel = karistir(TERIMLER.filter((t) => t !== dogru));
    const ad = sec(ADLAR), nesne = sec(NESNE[aile]), bak = bos ? 'Boyanmamış kısım' : 'Boyalı kısım', say = bos ? n - k : k;
    ekle({ kod: 'MAT.2.1.7', konu: 'Kesirler', alt_konu: bos ? 'Boyanmamış kısmın adı' : 'Bütün, yarım ve çeyrek', zorluk: k === 1 || k === n ? 1 : 2,
      kok: `${ad}, bir ${nesne} resminin bir kısmını boyadı. ${bak} bütünün neyidir?`,
      dogru, celdirici: cel,
      gerekce: cel.map((c) => `Şekil ${n} eş parçaya bölünmüş ve ${bak.toLowerCase()} ${say} parçadır; bu bütünün ${dogru.toLowerCase()} olur, ${c.toLowerCase()} değil.`),
      ipucu: 'Önce şeklin kaç eş parçaya bölündüğüne, sonra bu parçalardan kaçının boyalı (boyasız) olduğuna bak.',
      cozum: [`Şekil ${n} eş parçaya bölünmüştür.`, `${bak} ${say} parçadır.`, `${bak} bütünün ${dogru.toLowerCase()}dir.`],
      spec: { tip_id: 'b1-bolunmus', parametreler: { sekiller: [sh], dizilim: 'tek' } },
      dogrulama: [{ yol: ['sekiller', '0', bos ? 'bos_terim' : 'terim'], beklenen: terim }] });
  }

  function dortSekil() {
    const hedef = sec(['yarım', 'çeyrek']), aile = sec(['daire', 'kare', 'serit']), dz = aile === 'serit' ? 'satir' : 'izgara';
    const mk = (n, k, e = true) => { const sh = e ? esit(aile, n) : esitDegil(aile, n); sh.boyali = boyaliSec(sh, k); return sh; };
    let dogruSh, yanlis;
    if (hedef === 'yarım') {
      dogruSh = sec([() => mk(2, 1), () => mk(4, 2)])();
      yanlis = [[() => mk(4, 1), 'Bu şekil 4 eş parçaya bölünmüş, 1 parçası boyalı: bütünün çeyreğidir.'], [() => mk(4, 3), 'Bu şekilde 4 eş parçanın 3’ü boyalıdır: bütünün üç çeyreğidir.'],
        [() => mk(3, 1), 'Bu şekil 3 eş parçaya bölünmüş, 1 parçası boyalı: yarım değildir.']];
      if (aile !== 'daire') yanlis.push([() => mk(2, 1, false), 'Bu şekil iki parçaya bölünmüş ama parçalar eş değil; boyalı kısım yarım olmaz.'], [() => mk(4, 2, false), 'Dört parça eş olmadığı için boyalı iki parça bütünün yarısı olmaz.']);
    } else {
      dogruSh = mk(4, 1);
      yanlis = [[() => mk(2, 1), 'Bu şekil 2 eş parçaya bölünmüş, 1 parçası boyalı: bütünün yarısıdır.'], [() => mk(4, 2), 'Bu şekilde 4 eş parçanın 2’si boyalıdır: bütünün yarısıdır.'],
        [() => mk(3, 1), 'Bu şekil 3 eş parçaya bölünmüş; çeyrek için 4 eş parça gerekir.']];
      if (aile !== 'daire') yanlis.push([() => mk(4, 1, false), 'Dört parça var ama parçalar eş değil; boyalı parça bütünün çeyreği olmaz.']);
    }
    const sec3 = karistir(yanlis).slice(0, 3).map(([f, g]) => ({ sh: f(), g }));
    const kp = konum(), sekiller = [], gerekce = ['', '', '', '']; let j = 0;
    for (let i = 0; i < 4; i++) { if (i === kp) sekiller.push(dogruSh); else { sekiller.push(sec3[j].sh); gerekce[i] = `${i + 1}. şekil: ${sec3[j].g}`; j++; } }
    if (new Set(sekiller.map(yaz)).size !== 4) throw new Error('sekiller_ayni');
    const sirali = ['1. şekil', '2. şekil', '3. şekil', '4. şekil'], son = hedef === 'yarım' ? 'yarısıdır' : 'çeyreğidir';
    ekle({ kod: 'MAT.2.1.7', konu: 'Kesirler', alt_konu: 'Eş parçalar ve bütünün yarımı, çeyreği', zorluk: 2,
      kok: `Aşağıda dört şekil verilmiştir. Hangisinin boyalı kısmı bütünün ${son}?`,
      sirali, dogru: sirali[kp], gerekce,
      ipucu: 'Parçaların eş olup olmadığına ve kaç parçadan kaçının boyalı olduğuna bak.',
      cozum: ['Her şekilde parçaların eş olup olmadığı ve boyalı parça sayısı incelenir.', `${kp + 1}. şekil, eş parçalara bölünmüştür ve boyalı kısmı bütünün ${son.replace('dır', 'dır')}.`],
      spec: { tip_id: 'b1-bolunmus', parametreler: { sekiller, dizilim: dz } },
      dogrulama: sekiller.map((sh, i) => ({ yol: ['sekiller', String(i), 'terim'], beklenen: terimSekil(sh) })) });
  }
  return { tek: () => tekSekil(false), bos: () => tekSekil(true), dort: dortSekil };
}

export const KAYIT = [
  { id: 'mat2-yarim-ceyrek-ad', ders: 'Matematik', sinif: 2, idOnek: 'MAT2-YC', mufredat_surum: MUFREDAT, kodlar: ['MAT.2.1.7'], fabrika: kur, uret: (f, { sec }) => sec([f.tek, f.tek, f.bos])() },
  { id: 'mat2-yarim-ceyrek-sec', ders: 'Matematik', sinif: 2, idOnek: 'MAT2-YS', mufredat_surum: MUFREDAT, kodlar: ['MAT.2.1.7'], fabrika: kur, uret: (f) => f.dort() },
];
