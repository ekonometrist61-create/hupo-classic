// 6. sınıf Fen Bilimleri — Güneş ve Ay tutulması (FB.6.1.3); aynı doğrultudaki kuvvetlerin bileşkesi (FB.6.2.1); dengelenmiş / dengelenmemiş kuvvetler (FB.6.2.2).
// Not: kazanim_6_fen.json içindeki program_surumu alanı "5. sınıf DÖP" yazıyor; kural gereği kaynak dosyadaki değer aynen kullanıldı.
const MUFREDAT = 'Maarif Modeli 5. sınıf DÖP (FB)';
const SETLER = [['K', 'L', 'M', 'N'], ['P', 'R', 'S', 'T']];

export function kurTutulma({ R, sec, karistir, ekle, konum }) {
  function tutulmaSorusu() {
    const k = konum(), harf = sec(SETLER), gunes = R() < 0.5, hedef = gunes ? 180 : 0;
    const diger = karistir([0, 180, 90, 270].filter((a) => a !== hedef));
    const acilar = [...diger]; acilar.splice(k, 0, hedef);
    const kok = gunes
      ? sec(['Şekilde Güneş, Dünya ve Ay’ın dört farklı konumu gösterilmiştir. Ay hangi konumdayken Güneş tutulması gerçekleşebilir?', 'Ay, Dünya’nın çevresinde dolanırken şekildeki dört konumdan geçer. Hangi konumda Güneş tutulması olabilir?'])
      : sec(['Şekilde Güneş, Dünya ve Ay’ın dört farklı konumu gösterilmiştir. Ay hangi konumdayken Ay tutulması gerçekleşebilir?', 'Ay, Dünya’nın çevresinde dolanırken şekildeki dört konumdan geçer. Hangi konumda Ay tutulması olabilir?']);
    ekle({ kod: 'FB.6.1.3', konu: 'Dünya ve Evren', alt_konu: 'Güneş ve Ay tutulması', zorluk: 2,
      spec: { tip_id: 'a5-gdm', parametreler: { aylar: acilar.map((aci, i) => ({ ad: harf[i], aci })) } }, sirali: harf, dogru: harf[k], kok,
      gerekce: harf.map((h, i) => (i === k ? '' : acilar[i] === 90 || acilar[i] === 270
        ? `${h} konumunda Ay yan konumdadır; Güneş, Dünya ve Ay aynı doğrultuda değildir, bu yüzden tutulma olmaz.`
        : gunes ? `${h} konumunda Dünya, Güneş ile Ay’ın arasındadır; bu konum Ay tutulmasının konumudur, Güneş tutulmasının değil.`
          : `${h} konumunda Ay, Güneş ile Dünya’nın arasındadır; bu konum Güneş tutulmasının konumudur, Ay tutulmasının değil.`)),
      ipucu: gunes ? 'Güneş tutulmasında Ay, Güneş ile Dünya arasına girer.' : 'Ay tutulmasında Dünya, Güneş ile Ay arasına girer ve Ay Dünya’nın gölgesine düşer.',
      cozum: [gunes ? 'Güneş tutulması, Ay’ın Güneş ile Dünya arasında bulunduğu konumda olur.' : 'Ay tutulması, Dünya’nın Güneş ile Ay arasında bulunduğu konumda olur.', `${harf[k]} konumunda ${gunes ? 'Ay, Güneş ile Dünya’nın arasındadır' : 'Dünya, Güneş ile Ay’ın arasındadır'}.`],
      dogrulama: [{ yol: ['tutulma', harf[k]], beklenen: gunes ? 'Güneş tutulması' : 'Ay tutulması' }] });
  }
  return { tutulmaSorusu };
}

// ---- yatay kuvvetler ----
const V = [10, 15, 20, 25, 30, 35, 40];
const YON = { sag: 'sağa', sol: 'sola' };
const HARF = ['K', 'L', 'M', 'N'];
export function kurBileske({ R, sec, karistir, ekle, konum }) {
  function bileskeSorusu() {
    const k = konum(), x = sec(V), y = sec(V.filter((v) => v !== x)), d = Math.abs(x - y), yon = y > x ? 'sag' : 'sol', ters = yon === 'sag' ? 'sol' : 'sag';
    const ad = sec(['K', 'L', 'M', 'N', 'P']), buyuk = Math.max(x, y);
    const metin = (v, yn) => `${v} N, ${YON[yn]}`;
    const havuz = [
      { v: x + y, yn: yon, g: `Zıt yönlü kuvvetler toplanmaz, çıkarılır; ${x} + ${y} = ${x + y} N bileşke kuvvet değildir.` },
      { v: x + y, yn: ters, g: `Zıt yönlü kuvvetler toplanmaz, çıkarılır; ayrıca yön de büyük kuvvetin yönü olmalıdır.` },
      { v: buyuk, yn: yon, g: `Bileşke kuvvet, büyük kuvvetin kendisi değil, iki kuvvetin farkıdır (${buyuk} − ${Math.min(x, y)} = ${d} N).` },
      { v: buyuk, yn: ters, g: `Bileşke kuvvet büyük kuvvetin kendisi değil, farkıdır; yön de yanlıştır.` },
      { v: d + 5, yn: yon, g: `Kuvvetlerin farkı ${d} N’dur; ${d + 5} N değildir.` },
      { v: d + 10, yn: ters, g: `Kuvvetlerin farkı ${d} N’dur ve bileşke büyük kuvvetin yönündedir.` },
      { v: Math.abs(d - 5), yn: yon, g: `Kuvvetlerin farkı ${d} N’dur; ${Math.abs(d - 5)} N değildir.` },
    ].filter((c) => c.v > 0 && c.v !== d);
    const secilen = [], kullanilan = new Set();
    if (R() < 0.25) { secilen.push({ v: d, yn: ters, g: `Kuvvetlerin farkı doğru bulunmuş ancak yön yanlıştır; bileşke kuvvet büyük kuvvetin yönündedir (${YON[yon]}).` }); kullanilan.add(metin(d, ters)); }
    for (const c of karistir(havuz)) { const m = metin(c.v, c.yn); if (secilen.length < 3 && !kullanilan.has(m) && !secilen.some((s) => s.v === c.v)) { secilen.push(c); kullanilan.add(m); } }
    if (secilen.length < 3) throw new Error('sik_yetersiz');
    ekle({ kod: 'FB.6.2.1', konu: 'Kuvvet ve Enerji', alt_konu: 'Aynı doğrultudaki kuvvetlerin bileşkesi', zorluk: 2,
      spec: { tip_id: 'b2-kuvvet', parametreler: { cisimler: [{ ad, sol: x, sag: y }] } },
      dogru: metin(d, yon), celdirici: secilen.map((c) => metin(c.v, c.yn)), gerekce: secilen.map((c) => c.g),
      kok: sec([`Şekilde ${ad} cismine zıt yönlerde iki kuvvet uygulanmaktadır. Cisme etki eden bileşke (net) kuvvetin büyüklüğü ve yönü nedir?`, `Yatay zeminde duran ${ad} cismine şekildeki gibi iki kuvvet etki etmektedir. Bu kuvvetlerin bileşkesi hangisidir?`]),
      ipucu: 'Zıt yönlü kuvvetlerin bileşkesi, büyük kuvvetten küçük kuvvet çıkarılarak bulunur ve büyük kuvvetin yönündedir.',
      cozum: [`Sola ${x} N, sağa ${y} N kuvvet uygulanıyor.`, `Bileşke: ${buyuk} − ${Math.min(x, y)} = ${d} N; yönü büyük kuvvetle aynıdır (${YON[yon]}).`],
      dogrulama: [{ yol: ['net', ad], beklenen: d }, { yol: ['yon', ad], beklenen: yon }] });
  }
  return { bileskeSorusu };
}

function netli(d, R, sec) { // |sag - sol| = d olan (sol, sag)
  const lo = sec(V.filter((v) => v + d <= 40)), hi = lo + d, ters = R() < 0.5;
  return d === 0 ? { sol: lo, sag: lo } : ters ? { sol: hi, sag: lo } : { sol: lo, sag: hi };
}
export function kurDenge({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'FB.6.2.2', konu: 'Kuvvet ve Enerji', alt_konu: 'Dengelenmiş ve dengelenmemiş kuvvetler' };
  function dengeSorusu() {
    const k = konum(), tur = sec(['dengeli', 'saga', 'enbuyuk']);
    let net;
    if (tur === 'dengeli') { net = karistir([5, 10, 15, 20, 25]).slice(0, 3); net.splice(k, 0, 0); }
    else if (tur === 'saga') net = null;
    else { const d = karistir([0, 5, 10, 15, 20, 25]).slice(0, 3), mx = sec([30]); net = d; net.splice(k, 0, mx); }
    let cisimler;
    if (tur === 'saga') {
      cisimler = HARF.map((ad, i) => { if (i === k) { const lo = sec(V.filter((v) => v <= 25)), hi = Math.min(40, lo + sec([5, 10, 15])); return { ad, sol: lo, sag: hi }; } const t = sec(['esit', 'sol']), lo = sec(V.filter((v) => v <= 30)); return t === 'esit' ? { ad, sol: lo, sag: lo } : { ad, sol: lo + sec([5, 10]), sag: lo }; });
    } else cisimler = HARF.map((ad, i) => ({ ad, ...netli(net[i], R, sec) }));
    const spec = { tip_id: 'b2-kuvvet', parametreler: { cisimler } };
    const gos = (c) => (c.sag === c.sol ? `kuvvetler eşit (${c.sol} N – ${c.sag} N)` : `${c.sol} N’a karşı ${c.sag} N`);
    if (tur === 'dengeli') {
      ekle({ ...kod, zorluk: 2, spec, sirali: HARF, dogru: HARF[k],
        kok: sec(['Şekilde dört cisme etki eden yatay kuvvetler gösterilmiştir. Hangi cisme etki eden kuvvetler dengelenmiştir?', 'Yukarıdaki cisimlerden hangisine etki eden kuvvetler birbirini dengelemektedir?']),
        gerekce: HARF.map((h, i) => (i === k ? '' : `${h} cismine etki eden kuvvetler eşit değildir (${gos(cisimler[i])}); bileşke kuvvet sıfır olmadığı için kuvvetler dengelenmemiştir.`)),
        ipucu: 'Dengelenmiş kuvvetler zıt yönlüdür ve büyüklükleri eşittir.',
        cozum: ['Kuvvetlerin dengelenmesi için zıt yönlü kuvvetlerin büyüklükleri eşit olmalıdır.', `${HARF[k]} cismine her iki yönde ${cisimler[k].sol} N kuvvet etki eder; bileşke sıfırdır.`],
        dogrulama: HARF.map((h, i) => ({ yol: ['dengeli', h], beklenen: i === k })) });
    } else if (tur === 'saga') {
      ekle({ ...kod, zorluk: 2, spec, sirali: HARF, dogru: HARF[k],
        kok: sec(['Şekilde durgun hâldeki dört cisme yatay kuvvetler uygulanmaktadır. Hangi cisim sağa doğru hareket etmeye başlar?', 'Dört cisme uygulanan kuvvetler şekilde gösterilmiştir. Hangi cismin hareket durumu değişir ve cisim sağa doğru hareket eder?']),
        gerekce: HARF.map((h, i) => (i === k ? '' : cisimler[i].sag === cisimler[i].sol ? `${h} cismine etki eden kuvvetler eşittir; bileşke sıfır olduğundan cisim durmaya devam eder.` : `${h} cismine sola doğru uygulanan kuvvet daha büyüktür; bileşke sola doğrudur, cisim sola hareket eder.`)),
        ipucu: 'Bileşke kuvvet, büyük kuvvetin yönündedir; cisim bileşke kuvvet yönünde hareket eder.',
        cozum: ['Cisim, bileşke kuvvetin yönünde hareket eder.', `${HARF[k]} cismine sağa doğru uygulanan kuvvet (${cisimler[k].sag} N) soldakinden (${cisimler[k].sol} N) büyüktür; cisim sağa doğru hareket eder.`],
        dogrulama: HARF.map((h, i) => ({ yol: ['yon', h], beklenen: i === k ? 'sag' : cisimler[i].sag === cisimler[i].sol ? 'yok' : 'sol' })) });
    } else {
      ekle({ ...kod, zorluk: 3, spec, sirali: HARF, dogru: HARF[k],
        kok: sec(['Şekilde dört cisme yatay kuvvetler etki etmektedir. Hangi cisme etki eden bileşke kuvvet en büyüktür?', 'Yukarıdaki cisimlerden hangisine uygulanan kuvvetlerin bileşkesi en büyüktür?']),
        gerekce: HARF.map((h, i) => (i === k ? '' : `${h} cismine etki eden kuvvetlerin farkı ${net[i]} N’dur; bu, ${net[k]} N olan en büyük bileşke kuvvetten küçüktür.`)),
        ipucu: 'Her cisim için zıt yönlü iki kuvvetin farkını bul.',
        cozum: ['Her cisimde büyük kuvvetten küçük kuvvet çıkarılır.', `Bileşkeler: ${HARF.map((h, i) => `${h}: ${net[i]} N`).join(', ')}. En büyüğü ${HARF[k]} cismindedir.`],
        dogrulama: HARF.map((h, i) => ({ yol: ['net', h], beklenen: net[i] })) });
    }
  }
  return { dengeSorusu };
}

export const KAYIT = [
  { id: 'b2-fen6-tutulma', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-TUT', mufredat_surum: MUFREDAT, kodlar: ['FB.6.1.3'], fabrika: kurTutulma, uret: (f) => f.tutulmaSorusu() },
  { id: 'b2-fen6-kuvvet-bileske', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-BIL', mufredat_surum: MUFREDAT, kodlar: ['FB.6.2.1'], fabrika: kurBileske, uret: (f) => f.bileskeSorusu() },
  { id: 'b2-fen6-kuvvet-denge', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-DEN', mufredat_surum: MUFREDAT, kodlar: ['FB.6.2.2'], fabrika: kurDenge, uret: (f) => f.dengeSorusu() },
];
