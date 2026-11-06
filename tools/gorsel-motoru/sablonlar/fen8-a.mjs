// 8. sınıf Fen Bilimleri (önceki program) — Kalıtım: tek karakter çaprazlaması (F.8.2.2.2). Şekil: b2-punnett.
// Yavruların baskın/çekinik fenotip yüzdesi tablodaki kutulardan hesaplanır; şıklar yüzde ölçeğinin ardışık pencereleridir.
import { sayiSik } from '../tipler-b2.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 8. sınıf; program: önceki program)';
const CAPRAZ = [['Aa', 'Aa'], ['Aa', 'aa'], ['AA', 'Aa'], ['AA', 'aa'], ['aa', 'aa'], ['AA', 'AA']];

export function kur({ R, sec, ekle, konum }) {
  const sayim = (e1, e2) => { let dom = 0; for (const a of e1) for (const b of e2) if (a === a.toUpperCase() || b === b.toUpperCase()) dom++; return dom; };
  function capraz() {
    const k = konum(), v = (k + (R() < 0.5 ? 0 : 1)) * 25;                   // doğru yüzde: pencere indeksine uygun
    const adaylar = [];
    for (const c of CAPRAZ) for (const dom of [true, false]) { const n = dom ? sayim(c[0], c[1]) : 4 - sayim(c[0], c[1]); if (n * 25 === v) adaylar.push({ c, dom, n }); }
    if (!adaylar.length) throw new Error('capraz_yok');
    const { c, dom, n } = sec(adaylar), harf = sec(['A', 'B', 'D', 'T', 'K']), cevir = (g) => g.split('').map((x) => (x === x.toUpperCase() ? harf : harf.toLowerCase())).join('');
    const [e1, e2] = R() < 0.5 ? c : [c[1], c[0]];
    const s = sayiSik(v, k, R, { min: 0, max: 100, adim: 25, tercih: [100 - v], bicim: (x) => `%${x}` });
    const ad = dom ? 'baskın' : 'çekinik';
    const sayi = {}; for (const a of e1) for (const b of e2) { const g = [a, b].sort((x, y) => (x === x.toLowerCase() ? 1 : 0) - (y === y.toLowerCase() ? 1 : 0)).join(''); sayi[cevir(g)] = (sayi[cevir(g)] ?? 0) + 1; }
    ekle({ kod: 'F.8.2.2.2', konu: 'Kalıtım', alt_konu: 'Tek karakter çaprazlaması', zorluk: 3,
      spec: { tip_id: 'b2-punnett', parametreler: { e1: cevir(e1), e2: cevir(e2) } }, sirali: s.sirali, dogru: `%${v}`,
      kok: sec([
        `Şekilde, ${harf} geni için yapılan bir çaprazlama tablosu verilmiştir. Büyük harf baskın, küçük harf çekinik özelliği göstermektedir. Buna göre yavruların yüzde kaçı ${ad} özelliği gösterir?`,
        `Bir canlıda ${harf} geni ile ilgili tek karakter çaprazlaması şekildeki gibi gösterilmiştir (büyük harf: baskın, küçük harf: çekinik). Bu çaprazlamada ${ad} fenotipli yavruların oranı yüzde kaçtır?`]),
      gerekce: s.degerler.map((x) => (x === v ? '' : x === 100 - v ? `%${x}, ${dom ? 'çekinik' : 'baskın'} özellikteki yavruların oranıdır; soruda ${ad} özellik sorulmaktadır.` : `%${x}, ${x / 25} kutuya karşılık gelir; tabloda ${ad} özellik gösteren kutu sayısı ${n}’dir.`)),
      ipucu: dom ? 'Büyük harf içeren genotipler baskın özelliği gösterir. Bu kutuları say ve 4’e oranla.' : 'Yalnız iki küçük harften oluşan genotip çekinik özelliği gösterir. Bu kutuları say ve 4’e oranla.',
      cozum: [`Tabloda 4 kutu vardır; her kutu yavruların %25’ini gösterir.`, dom ? `Büyük harf taşıyan genotipli kutular baskın özelliği gösterir: ${n} kutu → ${n} × 25 = %${v}.` : `Yalnız küçük harflerden oluşan genotipli kutular çekinik özelliği gösterir: ${n} kutu → ${n} × 25 = %${v}.`],
      dogrulama: Object.entries(sayi).map(([g, m]) => ({ yol: ['sayi', g], beklenen: m })) });
  }
  return { capraz };
}

export const KAYIT = [
  { id: 'fen8-capraz-yuzde', ders: 'Fen Bilimleri', sinif: 8, idOnek: 'FEN8-CAP', mufredat_surum: MUFREDAT, kodlar: ['F.8.2.2.2'], fabrika: kur,
    uret: (f) => f.capraz() },
];
