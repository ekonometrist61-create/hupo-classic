// 4. sınıf Fen Bilimleri (önceki program) — mıknatısların kutupları (F.4.3.2.1); ölçüm silindiriyle hacim ölçme (F.4.4.2.1).
import { sayiSik } from '../tipler-b2.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 4. sınıf; program: önceki program)';
const HARF = ['K', 'L', 'M', 'N'];

export function kurMiknatis({ R, sec, ekle, konum }) {
  function miknatisSorusu() {
    const k = konum(), ceker = R() < 0.5, kutup = () => sec(['N', 'S']);
    const ciftler = HARF.map((ad, i) => {
      const a = kutup();
      const farkli = ceker ? i === k : i !== k;
      return { ad, sol: a, sag: farkli ? (a === 'N' ? 'S' : 'N') : a };
    });
    const cevap = ceker ? 'çeker' : 'iter';
    ekle({ kod: 'F.4.3.2.1', konu: 'Kuvvet ve Hareket', alt_konu: 'Mıknatısların kutupları', zorluk: 2,
      spec: { tip_id: 'a5-miknatis', parametreler: { ciftler } }, sirali: HARF, dogru: HARF[k],
      kok: ceker
        ? sec(['Şekilde dört çubuk mıknatıs çifti, uçları birbirine bakacak biçimde yerleştirilmiştir. Hangi çiftteki mıknatıslar birbirini çeker?', 'Yukarıda, karşılıklı duran dört çubuk mıknatıs çifti gösterilmiştir. Hangi çiftte mıknatıslar birbirini çekmektedir?'])
        : sec(['Şekilde dört çubuk mıknatıs çifti, uçları birbirine bakacak biçimde yerleştirilmiştir. Hangi çiftteki mıknatıslar birbirini iter?', 'Yukarıda, karşılıklı duran dört çubuk mıknatıs çifti gösterilmiştir. Hangi çiftte mıknatıslar birbirini itmektedir?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : ceker
        ? `${h} çiftinde karşılıklı gelen uçlar aynı kutuptur (${ciftler[i].sol}–${ciftler[i].sag}); aynı kutuplar birbirini iter, çekmez.`
        : `${h} çiftinde karşılıklı gelen uçlar farklı kutuptur (${ciftler[i].sol}–${ciftler[i].sag}); farklı kutuplar birbirini çeker, itmez.`)),
      ipucu: 'Karşılıklı gelen uçlardaki N ve S harflerine bak. Aynı kutuplar itişir, farklı kutuplar çekişir.',
      cozum: ['Mıknatıslarda aynı kutuplar birbirini iter, farklı kutuplar birbirini çeker.', `${HARF[k]} çiftinde karşılıklı uçlar ${ceker ? 'farklı' : 'aynı'} kutuptur (${ciftler[k].sol}–${ciftler[k].sag}); mıknatıslar birbirini ${cevap === 'çeker' ? 'çeker' : 'iter'}.`],
      dogrulama: HARF.map((h, i) => ({ yol: ['etki', h], beklenen: (i === k) === ceker ? 'ceker' : 'iter' })) });
  }
  return { miknatisSorusu };
}

// ---- ölçüm silindiri ----
const SIL_AD = ['I', 'II', 'III'];
export function kurSilindir({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'F.4.4.2.1', konu: 'Madde ve Değişim', alt_konu: 'Hacmi ölçme' };
  function silindirSorusu() {
    const k = konum(), tur = sec(['okuma', 'hacim', 'karsilastir']), bolme = sec([5, 10]), buyuk = bolme === 5 ? 10 : 20, max = 100;
    if (tur === 'okuma') {
      const v = bolme * (3 + Math.floor(R() * (max / bolme - 5)));
      const s = sayiSik(v, k, R, { min: 0, max, adim: bolme, tercih: [v + bolme, v - bolme, Math.round(v / buyuk) * buyuk] });
      ekle({ ...kod, zorluk: bolme === 10 ? 1 : 2, spec: { tip_id: 'a5-silindir', parametreler: { max, bolme, buyuk, silindirler: [{ ad: '', seviye: v }] } }, sirali: s.sirali.map((x) => `${x} mL`), dogru: `${v} mL`,
        kok: sec(['Yukarıdaki ölçüm silindirinde bulunan suyun hacmi kaç mL’dir?', 'Şekildeki dereceli silindirde su hangi çizgiye kadar yükselmiştir? Suyun hacmi kaç mL’dir?']),
        gerekce: s.degerler.map((x) => (x === v ? '' : `${x} mL, suyun yüzeyinin gösterdiği çizgiyle uyuşmuyor; skalada bir bölmenin kaç mL olduğuna dikkat ederek suyun seviyesini yeniden oku.`)),
        ipucu: bolme === 10 ? 'Su yüzeyinin hizasındaki çizgiye bak; iki sayı arasındaki bölmelerin kaçar mL olduğunu bul.' : 'Sayılı çizgiler arasında kaç küçük bölme olduğuna bakarak bir bölmenin kaç mL olduğunu bul.',
        cozum: [`Skalada her küçük bölme ${bolme} mL’dir.`, `Su yüzeyi ${v} mL çizgisinin hizasındadır.`],
        dogrulama: [{ yol: ['okunan', '0'], beklenen: v }] });
      return;
    }
    if (tur === 'hacim') {
      const a = bolme * (3 + Math.floor(R() * 5)), j = 2 + Math.floor(R() * 5), V = bolme * j, b = a + V;
      if (b > max - 10) throw new Error('tasma');
      const s = sayiSik(V, k, R, { min: bolme, max, adim: bolme, tercih: [b, a, a + b] });
      ekle({ ...kod, zorluk: 3, spec: { tip_id: 'a5-silindir', parametreler: { max, bolme, buyuk, silindirler: [{ ad: 'I', seviye: a }, { ad: 'II', seviye: b, cisim: true }] } }, sirali: s.sirali.map((x) => `${x} mL`), dogru: `${V} mL`,
        kok: sec(['I numaralı silindirde bir miktar su vardır. Aynı su II numaralı silindirde, içine bir taş atıldıktan sonra gösterilmiştir. Taşın hacmi kaç mL’dir?', 'Şekilde, suyun içine bir cisim bırakılmadan önce (I) ve bıraktıktan sonra (II) ölçüm silindirindeki su seviyesi görülmektedir. Cismin hacmi kaç mL’dir?']),
        gerekce: s.degerler.map((x) => (x === V ? '' : x === b ? `${x} mL, cisim bırakıldıktan sonraki toplam seviyedir; cismin hacmi için ilk seviyeyi çıkarmak gerekir.` : x === a ? `${x} mL, cisim bırakılmadan önceki su hacmidir; cismin hacmi değildir.` : `${x} mL, iki seviye arasındaki farkla uyuşmuyor; cismin hacmi, suyun yükselme miktarına eşittir.`)),
        ipucu: 'Cismin hacmi, suyun seviyesinin ne kadar yükseldiğine eşittir.',
        cozum: [`İlk seviye ${a} mL, cisim bırakıldıktan sonraki seviye ${b} mL’dir.`, `Cismin hacmi: ${b} − ${a} = ${V} mL.`],
        dogrulama: [{ yol: ['hacim', 'II'], beklenen: V }] });
      return;
    }
    // karşılaştırma: üç silindir; her birine aynı başlangıç hacminde su konmuş, farklı cisimler atılmış
    const a = bolme * (3 + Math.floor(R() * 4)), hacimler = karistir([1, 2, 3, 4, 5, 6]).slice(0, 3).map((j) => j * bolme);
    const en = Math.max(...hacimler), hedefIdx = hacimler.indexOf(en), ad3 = ['K', 'L', 'M'];
    if (a + en > max - 10) throw new Error('tasma');
    const dogru = ad3[hedefIdx], diger = karistir([...ad3.filter((x) => x !== dogru), 'Hiçbirinin hacmi diğerinden büyük değildir.']);
    ekle({ ...kod, zorluk: 2, spec: { tip_id: 'a5-silindir', parametreler: { max, bolme, buyuk, silindirler: hacimler.map((h, i) => ({ ad: ad3[i], seviye: a + h, cisim: true })) } },
      dogru, celdirici: diger,
      kok: `Aynı miktarda su bulunan üç ölçüm silindirine K, L ve M cisimleri ayrı ayrı bırakılmıştır. Silindirlerdeki ilk su hacmi ${a} mL’dir. Hangi cismin hacmi en büyüktür?`,
      gerekce: diger.map((x) => (x.length > 1 ? 'Cisimlerin hacimleri suyun yükselme miktarına bakılarak karşılaştırılır; şekilde en çok yükselme olan cismin hacmi en büyüktür, hepsi eşit değildir.' : `${x} cismi suyu en çok yükselten cisim değildir; hacmi en büyük olan cisim değildir.`)),
      ipucu: 'Suyu en çok yükselten cismin hacmi en büyüktür.',
      cozum: ['Her silindirde su seviyesinin ilk seviyeden ne kadar yükseldiğine bak.', `Suyu en çok ${dogru} cismi yükseltmiştir; hacmi en büyük olan odur.`],
      dogrulama: [{ yol: ['okunan', dogru], beklenen: a + en }] });
  }
  return { silindirSorusu };
}

export const KAYIT = [
  { id: 'b2-fen4-miknatis-kutup', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-MIK', mufredat_surum: MUFREDAT, kodlar: ['F.4.3.2.1'], fabrika: kurMiknatis, uret: (f) => f.miknatisSorusu() },
  { id: 'b2-fen4-silindir-hacim', ders: 'Fen Bilimleri', sinif: 4, idOnek: 'FEN4-HAC', mufredat_surum: MUFREDAT, kodlar: ['F.4.4.2.1'], fabrika: kurSilindir, uret: (f) => f.silindirSorusu() },
];
