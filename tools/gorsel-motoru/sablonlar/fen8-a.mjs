// 8. sınıf Fen Bilimleri (önceki program) — Kalıtım: tek karakter çaprazlaması (F.8.2.2.2). Şekil: b2-punnett.
// v2: soru şekildeki kutuların genotip/harf dağılımını saymayı gerektirir; metinde ebeveyn genotipi, yüzde ya da oran yoktur.
import { sayiSik } from '../tipler-b2.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 8. sınıf; program: önceki program)';
const CAPRAZ = [['Aa', 'Aa'], ['Aa', 'aa'], ['AA', 'Aa'], ['AA', 'aa'], ['aa', 'aa']];
const buyuk = (x) => x === x.toUpperCase();
const sirala = (a, b) => [a, b].sort((x, y) => (buyuk(x) ? 0 : 1) - (buyuk(y) ? 0 : 1)).join('');
const hucreler = (e1, e2) => { const r = []; for (const b of e2) for (const a of e1) r.push(sirala(a, b)); return r; }; // satır sırası: 2. birey, sütun: 1. birey

const _OLCUT_ESKI = {
  dom: { say: (h) => h.filter((g) => buyuk(g[0]) || buyuk(g[1])).length },
  rec: { say: (h) => h.filter((g) => !buyuk(g[0]) && !buyuk(g[1])).length },
  het: { say: (h) => h.filter((g) => g[0] !== g[1]).length },
  hom: { say: (h) => h.filter((g) => g[0] === g[1]).length },
  ydom: { say: (h) => OLCUT.dom.say(h) },
  yrec: { say: (h) => OLCUT.rec.say(h) },
};

const KONUMLAR = ['sol üst', 'sağ üst', 'sol alt', 'sağ alt'];
const CIFTLER = [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]];
const OZELLIK = [
  { id: 'dom', ad: () => 'baskın özellik gösterir', uy: (g) => buyuk(g[0]) || buyuk(g[1]) },
  { id: 'rec', ad: () => 'çekinik özellik gösterir', uy: (g) => !buyuk(g[0]) && !buyuk(g[1]) },
  { id: 'het', ad: () => 'heterozigot genotiplidir', uy: (g) => g[0] !== g[1] },
  { id: 'hom', ad: () => 'homozigot genotiplidir', uy: (g) => g[0] === g[1] },
  { id: 'AA', ad: (h) => `${h}${h} genotipine sahiptir`, uy: (g) => g === 'AA' },
  { id: 'Aa', ad: (h) => `${h}${h.toLowerCase()} genotipine sahiptir`, uy: (g) => g === 'Aa' },
  { id: 'aa', ad: (h) => `${h.toLowerCase()}${h.toLowerCase()} genotipine sahiptir`, uy: (g) => g === 'aa' },
];
const YAZ = (g) => (g === g.toUpperCase() ? 'baskın özellikli' : g === g.toLowerCase() ? 'çekinik özellikli' : 'baskın özellikli');

export function kur({ R, sec, ekle, konum }) {
  const karisik = (d) => { const a = [...d]; for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(R() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };
  function capraz() {
    for (let deneme = 0; deneme < 50; deneme++) {
      const tur = sec(['gen', 'gen', 'cift', 'cift', 'say', 'say']);
      const c = sec(CAPRAZ), harf = sec(['A', 'B', 'D', 'T', 'K']);
      const cevir = (g) => g.split('').map((x) => (buyuk(x) ? harf : harf.toLowerCase())).join('');
      const [e1, e2] = R() < 0.5 ? c : [c[1], c[0]];
      const ham = hucreler(e1, e2), hc = ham.map(cevir);
      const sayi = {}; for (const g of hc) sayi[g] = (sayi[g] ?? 0) + 1;
      const k = konum();
      const ust = sec([
        `Şekilde, ${harf} geni için yapılan bir çaprazlama tablosu verilmiştir.`,
        `Bir canlıda ${harf} geni ile ilgili tek karakter çaprazlaması şekildeki gibi gösterilmiştir.`]);
      const bilgi = ' Büyük harf baskın, küçük harf çekinik özelliği göstermektedir.';
      const ortak = { kod: 'F.8.2.2.2', konu: 'Kalıtım', alt_konu: 'Tek karakter çaprazlaması', zorluk: 3,
        spec: { tip_id: 'b2-punnett', parametreler: { e1: cevir(e1), e2: cevir(e2) } },
        dogrulama: Object.entries(sayi).map(([g, m]) => ({ yol: ['sayi', g], beklenen: m })) };
      if (tur === 'gen') {
        const p = Math.floor(R() * 4), gk = ham[p];
        const ifade = (g) => `${cevir(g)} genotipli, ${YAZ(g)}`;
        const tum = ['AA', 'Aa', 'aa'].flatMap((g) => [`${cevir(g)} genotipli, baskın özellikli`, `${cevir(g)} genotipli, çekinik özellikli`]);
        const dogru = ifade(gk);
        const nz = (x) => x.toLocaleLowerCase('tr-TR'), goruldu = new Set([nz(dogru)]), diger = [];
        for (const x of karisik(tum)) if (!goruldu.has(nz(x)) && diger.length < 3) { goruldu.add(nz(x)); diger.push(x); }
        ekle({ ...ortak, dogru, celdirici: diger,
          kok: `${ust}${bilgi} Buna göre tablonun ${KONUMLAR[p]} kutusundaki yavru için aşağıdakilerden hangisi doğrudur?`,
          gerekce: diger.map(() => `Bu ifade, şekilde tablonun ${KONUMLAR[p]} kutusuna yazılan genotiple ve bu genotipin gösterdiği özellikle uyuşmuyor; kutuya yeniden bak.`),
          ipucu: `Tablonun ${KONUMLAR[p]} kutusuna bak: kutudaki iki harfi oku, sonra büyük harfin baskın özelliği gösterdiğini hatırla.`,
          cozum: [`Şekilde tablonun ${KONUMLAR[p]} kutusunu bul ve içindeki harfleri oku.`, 'Okuduğun genotipin gösterdiği özelliği büyük/küçük harf kuralına göre belirle.'] });
        return;
      }
      if (tur === 'cift') {
        const o = sec(OZELLIK), uy = ham.map((g) => o.uy(g));
        const m = uy.filter(Boolean).length;
        if (m < 2 || m > 3) continue;
        const dg = CIFTLER.filter(([a, b]) => uy[a] && uy[b]), yg = CIFTLER.filter(([a, b]) => !(uy[a] && uy[b]));
        if (!dg.length || yg.length < 3) continue;
        const ad = (q) => `${KONUMLAR[q[0]]} ve ${KONUMLAR[q[1]]} kutular`;
        const dogru = ad(sec(dg)), diger = karisik(yg).slice(0, 3).map(ad);
        ekle({ ...ortak, dogru, celdirici: diger,
          kok: `${ust}${bilgi} Buna göre aşağıdaki kutu çiftlerinden hangisinde yavruların ikisi de ${o.ad(harf)}?`.replace(' yavruların ikisi de', ' iki kutudaki yavrunun da').replace('iki kutudaki yavrunun da', 'iki yavrunun da'),
          gerekce: diger.map(() => 'Bu çiftteki kutulardan en az biri istenen koşulu sağlamıyor; kutulardaki genotipleri şekilden tek tek oku.'),
          ipucu: 'Her seçenekteki iki kutuyu şekilde bul, genotiplerini oku ve ikisinin birden koşulu sağlayıp sağlamadığına bak.',
          cozum: ['Tablonun 4 kutusundaki genotipleri oku.', 'Her seçenekte adı geçen iki kutunun ikisinin de koşulu sağlayıp sağlamadığını şekilden kontrol et.'] });
        return;
      }
      // say: belirli bir genotip ya da özellikteki kutu sayısı
      const o = sec(OZELLIK.filter((x) => ['dom', 'rec', 'het', 'hom', 'AA', 'Aa', 'aa'].includes(x.id)));
      const n = ham.filter((g) => o.uy(g)).length;
      if (n < 1) continue;
      const s = sayiSik(n, k, R, { min: 0, max: 4, adim: 1, tercih: [4 - n], bicim: (x) => `${x} kutu` });
      ekle({ ...ortak, sirali: s.sirali, dogru: `${n} kutu`,
        kok: `${ust}${bilgi} Buna göre tablodaki kutuların kaçında yavru ${o.ad(harf)}?`.replace('yavru', 'yavru'),
        gerekce: s.degerler.map((x) => (x === n ? '' : 'Bu değer, şekildeki kutuların tek tek okunup sayılmasıyla uyuşmuyor; kutulara yeniden bak.')),
        ipucu: 'Şekildeki 4 kutunun her birindeki harflere bak ve koşulu sağlayanları işaretle.',
        cozum: ['Tablodaki 4 kutunun genotiplerini tek tek oku.', 'Koşulu sağlayan kutuları şekilde işaretle ve say.'] });      return;
    }
    throw new Error('capraz_yok');
  }
  return { capraz };
}
export const KAYIT = [
  { id: 'fen8-capraz-yuzde', ders: 'Fen Bilimleri', sinif: 8, idOnek: 'FEN8-CAP', mufredat_surum: MUFREDAT, kodlar: ['F.8.2.2.2'], fabrika: kur,
    uret: (f) => f.capraz() },
];



