// 3. sınıf Matematik — kesir modelleri: payı ile paydası arasındaki ilişki (MAT.3.1.11) ve birim kesir (MAT.3.1.10).
// Şekil tipi: b1-bolunmus (tipler-b1.mjs).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 3. sınıf; program: TYMM)';
const f = (a, b) => `${a}/${b}`;
const pencere = (c, kp, adim, min = 0, max = Infinity) => {
  const a = [0, 1, 2, 3].map((i) => c + (i - kp) * adim);
  if (a.some((v) => v < min || v > max)) throw new Error('pencere_disi');
  return a;
};

export function kur({ R, sec, karistir, ekle, konum }) {
  const serit = (n, boyali) => ({ sekil: 'serit', kesim: { dikey: Array.from({ length: n - 1 }, (_, i) => (i + 1) / n) }, boyali });
  const daire = (n, boyali) => ({ sekil: 'daire', n, boyali });
  const bitisik = (n, k) => { const b = Math.floor(R() * (n - k + 1)); return Array.from({ length: k }, (_, i) => b + i); };
  function model(n, k) {
    const aile = [3, 4, 5, 6, 8].includes(n) ? sec(['serit', 'daire']) : 'serit';
    return aile === 'serit' ? serit(n, bitisik(n, k)) : daire(n, bitisik(n, k));
  }
  const tekil = (arr, dogruDeger) => {
    const gor = new Set([f(dogruDeger[0], dogruDeger[1])]), c = [];
    for (const x of arr) { const s = f(x[0], x[1]); if (x[0] > 0 && x[1] > 0 && x[0] * dogruDeger[1] !== x[1] * dogruDeger[0] && !gor.has(s)) { gor.add(s); c.push({ s, g: x[2] }); } if (c.length === 3) break; }
    if (c.length < 3) throw new Error('celdirici_yok');
    return c;
  };
  // ---------- pay ve payda ----------
  function payPayda() {
    const n = sec([3, 4, 5, 6, 7, 8, 9, 10]), k = 1 + Math.floor(R() * (n - 1)), sh = model(n, k), tur = sec(['boyali', 'boyali', 'bos', 'pay', 'payda']);
    const spec = { tip_id: 'b1-bolunmus', parametreler: { sekiller: [sh], dizilim: 'tek' } };
    const ortak = { kod: 'MAT.3.1.11', konu: 'Kesirler', spec };
    if (tur === 'boyali') {
      const c = tekil(karistir([[n - k, n, 'Boyasız parça sayısı pay yazılmış; pay boyalı parça sayısı olmalıdır.'], [k, n - k, 'Payda, bütünün tüm eş parça sayısıdır; boyasız parçalar sayılmamalıdır.'], [n, k, 'Pay ile payda yer değiştirmiş.'], [k + 1, n, 'Boyalı parça sayısı bir fazla sayılmış.'], [k, n + 1, 'Eş parça sayısı bir fazla sayılmış.'], [k - 1, n, 'Boyalı parça sayısı bir eksik sayılmış.'], [k, n - 1, 'Eş parça sayısı bir eksik sayılmış.']]), [k, n]);
      ekle({ ...ortak, alt_konu: 'Boyalı kısmı kesirle gösterme', zorluk: 1, kok: sec(['Şekilde boyalı kısım, bütünün kaçta kaçıdır?', 'Yukarıdaki şekilde boyalı kısmı gösteren kesir hangisidir?', 'Şeklin boyalı kısmı hangi kesirle gösterilir?']),
        dogru: f(k, n), celdirici: c.map((x) => x.s), gerekce: c.map((x) => `${x.s}: ${x.g}`), ipucu: 'Payda eş parçaların hepsinin sayısı, pay boyalı parçaların sayısıdır.',
        cozum: [`Bütün ${n} eş parçaya bölünmüştür; payda ${n}.`, `${k} parça boyalıdır; pay ${k}.`, `Boyalı kısım ${f(k, n)} kesriyle gösterilir.`], dogrulama: [{ yol: ['sekiller', '0', 'kesir'], beklenen: f(k, n) }] });
    } else if (tur === 'bos') {
      const c = tekil(karistir([[k, n, 'Boyalı parça sayısı pay yazılmış; soruda boyanmamış kısım isteniyor.'], [n - k, k, 'Payda, tüm eş parçaların sayısıdır.'], [n, n - k, 'Pay ile payda yer değiştirmiş.'], [n - k + 1, n, 'Boyasız parça sayısı bir fazla sayılmış.'], [n - k, n + 1, 'Eş parça sayısı bir fazla sayılmış.'], [n - k - 1, n, 'Boyasız parça sayısı bir eksik sayılmış.']]), [n - k, n]);
      ekle({ ...ortak, alt_konu: 'Boyanmamış kısmı kesirle gösterme', zorluk: 2, kok: sec(['Şekilde boyanmamış kısım hangi kesirle gösterilir?', 'Yukarıdaki şekilde boyanmamış kısım, bütünün kaçta kaçıdır?']),
        dogru: f(n - k, n), celdirici: c.map((x) => x.s), gerekce: c.map((x) => `${x.s}: ${x.g}`), ipucu: 'Önce boyasız parçaları say.',
        cozum: [`Bütün ${n} eş parçadır.`, `Boyanmamış parça sayısı ${n - k}’dır.`, `Boyanmamış kısım ${f(n - k, n)} kesriyle gösterilir.`], dogrulama: [{ yol: ['sekiller', '0', 'parca'], beklenen: n }, { yol: ['sekiller', '0', 'boyali'], beklenen: k }] });
    } else if (tur === 'pay') {
      const kp = konum(), sirali = pencere(k, kp, 1, 1, 9).map(String);
      ekle({ ...ortak, alt_konu: 'Kesrin payı', zorluk: 1, kok: 'Şekildeki boyalı kısmı gösteren kesrin payı kaçtır?', sirali, dogru: String(k),
        gerekce: sirali.map((x) => (Number(x) === k ? '' : `${x}: boyalı parçalar sayılınca ${k} bulunur; pay boyalı parça sayısıdır.`)), ipucu: 'Pay, boyalı eş parçaların sayısıdır.',
        cozum: [`Boyalı parçalar sayılır: ${k}.`, `Pay ${k}’dır.`], dogrulama: [{ yol: ['sekiller', '0', 'boyali'], beklenen: k }] });
    } else {
      const kp = konum(), sirali = pencere(n, kp, 1, 2, 11).map(String);
      ekle({ ...ortak, alt_konu: 'Kesrin paydası', zorluk: 1, kok: 'Şekildeki boyalı kısmı gösteren kesrin paydası kaçtır?', sirali, dogru: String(n),
        gerekce: sirali.map((x) => (Number(x) === n ? '' : `${x}: bütünü oluşturan eş parçalar sayılınca ${n} bulunur; payda eş parçaların tamamının sayısıdır.`)), ipucu: 'Payda, bütünü oluşturan tüm eş parçaların sayısıdır.',
        cozum: [`Bütün ${n} eş parçaya bölünmüştür.`, `Payda ${n}’dir.`], dogrulama: [{ yol: ['sekiller', '0', 'parca'], beklenen: n }] });
    }
  }

  // ---------- birim kesir ----------
  function cesitsiz(n) { // eş olmayan n parça (kesim oranları)
    for (let g = 0; g < 200; g++) {
      const c = Array.from({ length: n - 1 }, () => 0.1 + R() * 0.8).sort((a, b) => a - b), w = [c[0], ...c.slice(1).map((v, i) => v - c[i]), 1 - c[n - 2]];
      if (Math.min(...w) >= 0.08 && Math.max(...w) - Math.min(...w) > 0.12) return { c: c.map((v) => Math.round(v * 100) / 100), w };
    }
    throw new Error('kesim_yok');
  }
  function birimSec() {
    const n = sec([2, 3, 4, 5, 6, 8]), kp = konum();
    const tur = karistir(['esitdegil', 'baska', 'iki'].filter((t) => t !== 'iki' || n >= 4));
    const yanlis = tur.slice(0, 3).length === 3 ? tur : [...tur, tur[0], tur[1]].slice(0, 3);
    const sekiller = [], gerekce = ['', '', '', ''], dogrulama = [];
    let j = 0;
    for (let i = 0; i < 4; i++) {
      if (i === kp) { sekiller.push(serit(n, [Math.floor(R() * n)])); dogrulama.push({ yol: ['sekiller', String(i), 'kesir'], beklenen: f(1, n) }); continue; }
      const t = yanlis[j++ % yanlis.length];
      if (t === 'esitdegil') {
        const { c, w } = cesitsiz(n), cand = w.map((x, q) => [x, q]).filter(([x]) => Math.abs(x - 1 / n) >= 0.05).map(([, q]) => q);
        if (!cand.length) throw new Error('boyali_secilemedi');
        sekiller.push({ sekil: 'serit', kesim: { dikey: c }, boyali: [cand[Math.floor(R() * cand.length)]] }); dogrulama.push({ yol: ['sekiller', String(i), 'kesir'], beklenen: null });
        gerekce[i] = `${i + 1}. şekil: Parçalar eş değil; boyalı parça bütünün ${f(1, n)}’i değildir.`;
      } else if (t === 'baska') {
        const m = sec([2, 3, 4, 5, 6, 8].filter((x) => x !== n));
        sekiller.push(serit(m, [Math.floor(R() * m)])); dogrulama.push({ yol: ['sekiller', String(i), 'kesir'], beklenen: f(1, m) });
        gerekce[i] = `${i + 1}. şekil: Bütün ${m} eş parçaya bölünmüş; boyalı parça ${f(1, m)}’dir.`;
      } else {
        const b = karistir([...Array(n).keys()]).slice(0, 2).sort((a, z) => a - z);
        sekiller.push(serit(n, b)); dogrulama.push({ yol: ['sekiller', String(i), 'kesir'], beklenen: f(2, n) });
        gerekce[i] = `${i + 1}. şekil: Boyalı parça sayısı 2’dir; boyalı kısım ${f(2, n)}’dir, birim kesir değildir.`;
      }
    }
    if (new Set(sekiller.map((s) => JSON.stringify(s))).size !== 4) throw new Error('sekiller_ayni');
    const sirali = ['1. şekil', '2. şekil', '3. şekil', '4. şekil'];
    ekle({ kod: 'MAT.3.1.10', konu: 'Kesirler', alt_konu: 'Eş parçalar ve birim kesir', zorluk: 2, sirali, dogru: sirali[kp], gerekce,
      kok: `Aşağıdaki şekillerden hangisinin boyalı kısmı ${f(1, n)} kesriyle gösterilir?`, ipucu: 'Birim kesirde bütün eş parçalara bölünür ve bu parçalardan yalnız biri alınır.',
      cozum: [`${f(1, n)} için bütün ${n} eş parçaya bölünmeli ve 1 parçası boyanmalıdır.`, `Bunu ${kp + 1}. şekil sağlar.`],
      spec: { tip_id: 'b1-bolunmus', parametreler: { sekiller, dizilim: 'satir' } }, dogrulama });
  }
  function birimTek() {
    const n = sec([3, 4, 5, 6, 8]), aile = sec(['serit', 'daire']), kp = konum(), b = [Math.floor(R() * n)];
    const sh = aile === 'serit' ? serit(n, b) : daire(n, b), sirali = pencere(n, kp, 1, 2, 12).map((d) => f(1, d));
    ekle({ kod: 'MAT.3.1.10', konu: 'Kesirler', alt_konu: 'Birim kesri belirleme', zorluk: 1, sirali, dogru: f(1, n),
      gerekce: sirali.map((s) => (s === f(1, n) ? '' : `${s}: bütün ${s.split('/')[1]} değil, ${n} eş parçaya bölünmüştür.`)),
      kok: sec(['Şekilde bütünün eş parçalarından biri boyanmıştır. Boyalı parça hangi birim kesirle gösterilir?', 'Aşağıdaki şekilde boyalı parçayı gösteren birim kesir hangisidir?']),
      ipucu: 'Önce bütünün kaç eş parçaya bölündüğünü say. Birim kesrin payı 1’dir.',
      cozum: [`Bütün ${n} eş parçaya bölünmüştür.`, `Boyalı parça bu parçalardan biridir: ${f(1, n)}.`],
      spec: { tip_id: 'b1-bolunmus', parametreler: { sekiller: [sh], dizilim: 'tek' } }, dogrulama: [{ yol: ['sekiller', '0', 'kesir'], beklenen: f(1, n) }] });
  }
  return { payPayda, birimSec, birimTek, birim: () => sec([birimSec, birimTek])() };
}

export const KAYIT = [
  { id: 'mat3-kesir-pay-payda', ders: 'Matematik', sinif: 3, idOnek: 'MAT3-KPP', mufredat_surum: MUFREDAT, kodlar: ['MAT.3.1.11'], fabrika: kur, uret: (f) => f.payPayda() },
  { id: 'mat3-birim-kesir', ders: 'Matematik', sinif: 3, idOnek: 'MAT3-KBR', mufredat_surum: MUFREDAT, kodlar: ['MAT.3.1.10'], fabrika: kur, uret: (f) => f.birim() },
];
