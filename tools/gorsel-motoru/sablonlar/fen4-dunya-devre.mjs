// 4. sınıf Fen Bilimleri (önceki program) — Dünya'nın hareketleri: gece/gündüz (F.4.1.2.2); basit elektrik devresi (F.4.7.1.1, F.4.7.1.2).
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 4. sınıf; program: önceki program)';
const HARF = ['K', 'L', 'M', 'N'];

// ---- gece / gündüz ----
const GUNDUZ = [120, 150, 180, 210, 240], GECE = [300, 330, 0, 30, 60];
export function kurDunya({ sec, karistir, ekle, konum }) {
  function dunyaSorusu() {
    const tur = sec(['gece', 'gunduz', 'isik']), k = konum();
    const kod = { kod: 'F.4.1.2.2', konu: 'Dünya ve Evren', alt_konu: 'Dünya’nın dönmesi: gece ve gündüz' };
    let acilar;
    if (tur === 'gece') { acilar = karistir(GUNDUZ).slice(0, 3); acilar.splice(k, 0, sec(GECE)); }
    else if (tur === 'gunduz') { acilar = karistir(GECE).slice(0, 3); acilar.splice(k, 0, sec(GUNDUZ)); }
    else { acilar = karistir(GUNDUZ.filter((a) => a !== 180)).slice(0, 3); acilar.splice(k, 0, 180); }
    const spec = { tip_id: 'b2-dunya', parametreler: { noktalar: acilar.map((aci, i) => ({ ad: HARF[i], aci })) } };
    if (tur === 'isik') {
      ekle({ ...kod, zorluk: 2, spec, sirali: HARF, dogru: HARF[k],
        kok: sec(['Şekilde Dünya’nın, Güneş’ten gelen ışıkla aydınlanan yarısı açık renkle gösterilmiştir. K, L, M ve N noktalarından hangisi Güneş ışığını en çok alır?', 'Şekilde Güneş’e bakan Dünya’da dört nokta işaretlenmiştir. Hangi noktada Güneş tam karşıda, en yüksekte görülür (öğle vakti)?']),
        gerekce: HARF.map((h, i) => (i === k ? '' : `${h} noktası aydınlık yarıdadır; ancak Güneş’in tam karşısında değil, kenara daha yakındır. Güneş ışığını en çok alan nokta değildir.`)),
        ipucu: 'Güneş’in tam karşısındaki noktaya bak.',
        cozum: ['Güneş ışığını en çok, Güneş’in tam karşısındaki nokta alır.', `Bu nokta ${HARF[k]} noktasıdır.`],
        dogrulama: [{ yol: ['en_isik'], beklenen: HARF[k] }] });
      return;
    }
    const gece_mi = tur === 'gece';
    ekle({ ...kod, zorluk: 1, spec, sirali: HARF, dogru: HARF[k],
      kok: gece_mi
        ? sec(['Şekilde Güneş ve Dünya gösterilmiştir. Dünya’nın üzerinde işaretlenen K, L, M ve N noktalarından hangisinde şu anda gece yaşanmaktadır?', 'Aşağıdaki şekilde Dünya’nın Güneş’e dönük yarısı açık renktedir. K, L, M ve N noktalarında yaşayan insanlardan hangisi şu anda geceyi yaşar?'])
        : sec(['Şekilde Güneş ve Dünya gösterilmiştir. Dünya’nın üzerinde işaretlenen K, L, M ve N noktalarından hangisinde şu anda gündüz yaşanmaktadır?', 'Aşağıdaki şekilde Dünya’nın Güneş’e dönük yarısı açık renktedir. K, L, M ve N noktalarında yaşayan insanlardan hangisi şu anda gündüzü yaşar?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : gece_mi
        ? `${h} noktası Güneş’e dönük, aydınlık yarıdadır; orada gündüz yaşanır.`
        : `${h} noktası Güneş’e dönük olmayan, karanlık yarıdadır; orada gece yaşanır.`)),
      ipucu: 'Güneş ışığı Dünya’nın yalnız Güneş’e dönük yarısını aydınlatır.',
      cozum: ['Dünya’nın Güneş’e dönük yarısında gündüz, öbür yarısında gece yaşanır.', `${HARF[k]} noktası ${gece_mi ? 'karanlık' : 'aydınlık'} yarıdadır; orada ${gece_mi ? 'gece' : 'gündüz'} vardır.`],
      dogrulama: [{ yol: ['durum', HARF[k]], beklenen: gece_mi ? 'gece' : 'gunduz' }, ...HARF.filter((_, i) => i !== k).map((h) => ({ yol: ['durum', h], beklenen: gece_mi ? 'gunduz' : 'gece' }))] });
  }
  return { dunyaSorusu };
}

// ---- elektrik devresi ----
const NEDEN = {
  pil_yok: { metin: 'Devrede pil yoktur.', gerekce: 'pil olmadığı için devreye elektrik enerjisi sağlanmaz', yok: 'Şekildeki devrede pil bulunmaktadır.' },
  ampul_yok: { metin: 'Devrede ampul yoktur.', gerekce: 'ampul olmadığı için ışık verecek bir eleman yoktur', yok: 'Şekildeki devrede ampul bulunmaktadır.' },
  acik_anahtar: { metin: 'Anahtar açıktır.', gerekce: 'anahtar açık olduğu için devre tamamlanmamıştır', yok: 'Şekildeki devrede açık bir anahtar yoktur.' },
  kopuk_kablo: { metin: 'Bir kablo kopuktur.', gerekce: 'kablo kopuk olduğu için akım geçemez', yok: 'Şekildeki devrede kopuk bir kablo yoktur.' },
};
const NEDENLER = Object.keys(NEDEN);
function panel(ad, neden, R, sec) {
  const pil = sec([1, 2]);
  const sw = sec([null, 'kapali']);
  if (neden === 'pil_yok') return { ad, pil: 0, ampul: 1, anahtar: sw };
  if (neden === 'ampul_yok') return { ad, pil, ampul: 0, anahtar: sw ?? 'kapali' };
  if (neden === 'acik_anahtar') return { ad, pil, ampul: 1, anahtar: 'acik' };
  if (neden === 'kopuk_kablo') return { ad, pil, ampul: 1, anahtar: sw, kopuk: true };
  return { ad, pil, ampul: 1, anahtar: sw };
}
export function kurDevre({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'F.4.7.1.2', konu: 'Elektrik', alt_konu: 'Çalışan basit elektrik devresi' };
  function devreSorusu() {
    const k = konum();
    if (R() < 0.55) {
      const nedenler = karistir(NEDENLER).slice(0, 3), paneller = [];
      for (let i = 0, j = 0; i < 4; i++) paneller.push(i === k ? panel(HARF[i], null, R, sec) : panel(HARF[i], nedenler[j++], R, sec));
      let j = 0;
      ekle({ ...kod, zorluk: 2, spec: { tip_id: 'a5-devre', parametreler: { paneller } }, sirali: HARF, dogru: HARF[k],
        kok: sec(['Aşağıda dört farklı elektrik devresi verilmiştir. Hangi devrede ampul yanar?', 'Yukarıdaki devrelerden hangisi tamamlanmış, çalışan bir elektrik devresidir?']),
        gerekce: HARF.map((h, i) => { if (i === k) return ''; const n = nedenler[j++]; return `${h} devresinde ${NEDEN[n].gerekce}; bu yüzden ampul yanmaz.`; }),
        ipucu: 'Çalışan devrede pil, ampul ve kablolar kesintisiz bir halka oluşturur; anahtar varsa kapalıdır.',
        cozum: ['Ampulün yanması için devrede pil ve ampul bulunmalı, anahtar kapalı olmalı ve kablolar kopuk olmamalıdır.', `Yalnız ${HARF[k]} devresi bu koşulları sağlar.`],
        dogrulama: HARF.map((h, i) => ({ yol: ['paneller', h, 'calisir'], beklenen: i === k })) });
      return;
    }
    const nedeni = sec(NEDENLER), pn = panel('', nedeni, R, sec), cel = karistir(NEDENLER.filter((n) => n !== nedeni));
    ekle({ ...kod, zorluk: 2, spec: { tip_id: 'a5-devre', parametreler: { paneller: [pn] } }, dogru: NEDEN[nedeni].metin, celdirici: cel.map((n) => NEDEN[n].metin),
      kok: sec(['Yukarıdaki elektrik devresinde ampul yanmamaktadır. Bunun nedeni aşağıdakilerden hangisidir?', 'Şekildeki devre kurulmuş ancak ampul ışık vermemektedir. Ampulün yanmamasının nedeni nedir?']),
      gerekce: cel.map((n) => `${NEDEN[n].yok} Ampulün yanmamasının nedeni bu değildir.`),
      ipucu: 'Devrede pil, ampul ve anahtar olup olmadığına, anahtarın açık mı kapalı mı olduğuna ve kabloların kopuk olup olmadığına bak.',
      cozum: ['Şekildeki devrenin elemanlarını ve bağlantılarını tek tek incele.', `Ampulün yanmamasının nedeni: ${NEDEN[nedeni].metin.toLowerCase().replace('.', '')}.`],
      dogrulama: [{ yol: ['paneller', '', 'neden'], beklenen: nedeni }] });
  }
  return { devreSorusu };
}

const ELEMAN = { pil: 'Pil', ampul: 'Ampul', anahtar: 'Anahtar', kablo: 'Kablo' };
const ISLEV = {
  pil: 'devreye elektrik enerjisi sağlayan', ampul: 'elektrik enerjisini ışığa dönüştüren (ışık veren)',
  anahtar: 'devreyi açıp kapatmaya yarayan', kablo: 'devre elemanlarını birbirine bağlayan ve elektriğin gitmesini sağlayan',
};
export function kurEleman({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'F.4.7.1.1', konu: 'Elektrik', alt_konu: 'Devre elemanları ve işlevleri' };
  const ELEMANLAR = Object.keys(ELEMAN);
  function elemanSorusu() {
    const k = konum(), hedef = sec(ELEMANLAR), anah = sec(['kapali', 'acik']), isim = R() < 0.5, atama = {};
    if (isim) { const h = karistir(HARF); ELEMANLAR.forEach((e, i) => { atama[e] = h[i]; }); }
    else { const diger = karistir(HARF.filter((_, i) => i !== k)); atama[hedef] = HARF[k]; ELEMANLAR.filter((e) => e !== hedef).forEach((e, i) => { atama[e] = diger[i]; }); }
    const spec = { tip_id: 'b2-devre', parametreler: { paneller: [{ ad: '', pil: 1, ampul: 1, anahtar: anah, harf: { pil: atama.pil, ampul: atama.ampul, anahtar: atama.anahtar, kablo: atama.kablo } }] } };
    const dog = ELEMANLAR.map((e) => ({ yol: ['harf', `:${atama[e]}`], beklenen: e }));
    if (isim) {
      const hl = sec(HARF), eleman = ELEMANLAR.find((e) => atama[e] === hl), cel = karistir(ELEMANLAR.filter((e) => e !== eleman));
      ekle({ ...kod, zorluk: 2, spec, dogru: ELEMAN[eleman], celdirici: cel.map((e) => ELEMAN[e]),
        kok: sec([`Yukarıdaki devre şemasında ${hl} harfi ile gösterilen devre elemanı hangisidir?`, `Şemada ${hl} harfi ile belirtilen devre elemanının adı aşağıdakilerden hangisidir?`]),
        gerekce: cel.map((e) => `${hl} ile gösterilen eleman "${ELEMAN[e].toLowerCase()}" değildir; şemadaki simgesi başka bir devre elemanına aittir.`),
        ipucu: 'Pil, ampul, anahtar ve kablonun devre şemasındaki simgelerini düşün.',
        cozum: [`${hl} harfi şemada "${ELEMAN[eleman].toLowerCase()}" simgesinin yanında yazılıdır.`, `Doğru cevap: ${ELEMAN[eleman]}.`], dogrulama: dog });
    } else {
      ekle({ ...kod, zorluk: 2, spec, sirali: HARF, dogru: HARF[k],
        kok: sec([`Aşağıdaki devre şemasında ${ISLEV[hedef]} devre elemanı hangi harfle gösterilmiştir?`, `Şekildeki devrede ${ISLEV[hedef]} eleman hangi harfle belirtilmiştir?`]),
        gerekce: HARF.map((h, i) => { if (i === k) return ''; const e = ELEMANLAR.find((x) => atama[x] === h); return `${h} ile gösterilen devre elemanı "${ELEMAN[e].toLowerCase()}" elemanıdır; ${ISLEV[hedef]} eleman bu değildir.`; }),
        ipucu: 'Önce hangi devre elemanının bu işi yaptığını düşün, sonra şemada onun simgesini bul.',
        cozum: [`${ISLEV[hedef]} devre elemanı "${ELEMAN[hedef].toLowerCase()}" elemanıdır.`, `Şemada ${ELEMAN[hedef].toLowerCase()} ${HARF[k]} harfi ile gösterilmiştir.`], dogrulama: dog });
    }
  }
  return { elemanSorusu };
}
export const KAYIT = [
  { id: 'b2-fen4-dunya-gece-gunduz', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-DUN', mufredat_surum: MUFREDAT, kodlar: ['F.4.1.2.2'], fabrika: kurDunya, uret: (f) => f.dunyaSorusu() },
  { id: 'b2-fen4-devre-calisan', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-DEV', mufredat_surum: MUFREDAT, kodlar: ['F.4.7.1.2'], fabrika: kurDevre, uret: (f) => f.devreSorusu() },
  { id: 'b2-fen4-devre-eleman', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-ELE', mufredat_surum: MUFREDAT, kodlar: ['F.4.7.1.1'], fabrika: kurEleman, uret: (f) => f.elemanSorusu() },
];

