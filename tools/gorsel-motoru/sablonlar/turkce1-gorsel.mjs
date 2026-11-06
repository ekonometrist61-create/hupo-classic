// 1. sınıf Türkçe — harf kutuları (hece/harf/ünlü/konum), cümle sonu işareti ve olay sırası kartları.
// Kazanım kaynağı yalnız başlık verir: T.O.1.3 (çözümleme: sözcüğü harf/hece olarak çözme), T.Y.1.3 (yazma kuralları), T.O.1.2 (anlam oluşturma: olay sırası).
import { cumleKur, kartKur, OLAY3, pencere, surum, tekilEkle } from './turkce3-ortak.mjs';
import { unluSay } from '../tipler-b3.mjs';

const MUFREDAT = surum('kazanim_1_turkce');
const KELIME = {
  1: ['dal', 'göl', 'kuş', 'süt', 'top', 'taş', 'gül', 'tuz', 'bal', 'saç', 'kar', 'yağ', 'dağ', 'göz'],
  2: ['elma', 'masa', 'kedi', 'balık', 'okul', 'kalem', 'kapı', 'bebek', 'kitap', 'bahçe', 'çiçek', 'tavuk', 'koyun', 'kuzu', 'uçak', 'tilki', 'defter', 'silgi', 'balon', 'ayak', 'yıldız', 'ördek', 'çanta'],
  3: ['araba', 'kelebek', 'domates', 'patates', 'salata', 'papatya', 'bisiklet', 'sandalye', 'lokanta', 'balina', 'baklava', 'makine', 'penguen', 'fotoğraf'],
  4: ['ayakkabı', 'bilgisayar', 'televizyon', 'kütüphane', 'çikolata', 'mandalina', 'helikopter', 'kaplumbağa'],
};
for (const [h, l] of Object.entries(KELIME)) for (const w of l) if (unluSay(w) !== Number(h)) throw new Error(`hece_listesi_hatali:${w}`);

const KOK = {
  hece: ['Harf kutularına yazılmış sözcük kaç heceden oluşur?', 'Kutulardaki sözcüğü hecelere ayırırsak kaç hece olur?'],
  harf: ['Harf kutularında yazan sözcük kaç harften oluşur?', 'Kutulardaki sözcükte kaç harf vardır?'],
  unlu: ['Kutulardaki sözcükte kaç tane ünlü (sesli) harf vardır?', 'Harf kutularına yazılmış sözcükte kaç ünlü harf bulunur?'],
};

export function harfKur({ R, sec, karistir, ekle: ekleOrj, konum }) {
  const ekle = tekilEkle(ekleOrj);
  function harf() {
    const k = konum(), tur = sec(['hece', 'harf', 'unlu', 'konum', 'ilk', 'son']);
    const h = sec([1, 2, 3, 4]), w = sec(KELIME[h]), hs = [...w], n = hs.length;
    const spec = { tip_id: 'b3-harf-kutu', parametreler: { sozcuk: w } };
    const ortak = { kod: 'T.O.1.3', konu: 'Sözcüğü çözümleme', alt_konu: 'Harf kutularından hece, harf ve ünlü bulma', spec, zorluk: 1 };
    if (tur === 'hece' || tur === 'unlu' || tur === 'harf') {
      const d = tur === 'harf' ? n : h, s = pencere(d, k, tur === 'harf' ? 2 : 1); if (!s) throw new Error('pencere');
      const yol = tur === 'harf' ? 'harf_sayisi' : tur === 'hece' ? 'hece_sayisi' : 'unlu_sayisi';
      return ekle({ ...ortak, kok: sec(KOK[tur]), sirali: s.map(String), dogru: String(d),
        gerekce: s.map((v) => (v === d ? '' : tur === 'harf' ? `Kutuların sayısı ${d}'dir; ${v} kutu yoktur.` : `Sözcükte ${v} ${tur === 'hece' ? 'hece' : 'ünlü harf'} yoktur; her hecede bir ünlü olduğundan sayı ${d} olur.`)),
        ipucu: tur === 'harf' ? 'Dolu kutuları tek tek say.' : 'Ünlü harfler a, e, ı, i, o, ö, u, ü harfleridir. Her hecede bir ünlü bulunur; ünlüleri say.',
        cozum: tur === 'harf' ? ['Kutular soldan sağa tek tek sayılır.', `${d} kutu vardır.`] : ['Sözcükteki ünlü harfler sayılır.', `${d} ünlü olduğundan ${d} hece vardır.`], dogrulama: [{ yol: [yol], beklenen: d }] });
    }
    if (tur === 'konum') {
      const poz = 1 + Math.floor(R() * n), dogru = hs[poz - 1], diger = karistir([...new Set(hs)].filter((c) => c !== dogru)).slice(0, 3); if (diger.length < 3) throw new Error('harf_az');
      return ekle({ ...ortak, kok: `Harf kutularındaki sözcükte ${poz}. kutuda hangi harf vardır?`, dogru, celdirici: diger,
        gerekce: diger.map((c) => { const yer = hs.indexOf(c) + 1; return `"${c}" harfi ${yer}. kutudadır; ${poz}. kutuda değildir.`; }),
        ipucu: `Kutuların üstündeki numaralara bak ve ${poz} numaralı kutuyu bul.`, cozum: [`${poz} numaralı kutu bulunur.`, `Bu kutuda "${dogru}" harfi yazılıdır.`], dogrulama: [{ yol: ['harfler', String(poz)], beklenen: dogru }] });
    }
    const ilk = tur === 'ilk', dogru = ilk ? hs[0] : hs[n - 1], diger = karistir([...new Set(hs)].filter((c) => c !== dogru)).slice(0, 3); if (diger.length < 3) throw new Error('harf_az');
    return ekle({ ...ortak, kok: ilk ? 'Harf kutularındaki sözcüğün ilk harfi hangisidir?' : 'Harf kutularındaki sözcüğün son harfi hangisidir?', dogru, celdirici: diger,
      gerekce: diger.map((c) => `"${c}" harfi sözcüğün ${ilk ? 'ilk' : 'son'} harfi değildir.`),
      ipucu: ilk ? 'Soldaki ilk kutuya bak.' : 'Sağdaki son kutuya bak.', cozum: [ilk ? 'İlk kutu, soldaki kutudur.' : 'Son kutu, sağdaki kutudur.', `Bu kutuda "${dogru}" harfi yazılıdır.`], dogrulama: [{ yol: [ilk ? 'ilk' : 'son'], beklenen: dogru }] });
  }
  return { harf };
}

export const KAYIT = [
  { id: 'b3-tr1-harf', ders: 'Türkçe', sinif: 1, idOnek: 'B3TR1-HRF', mufredat_surum: MUFREDAT, kodlar: ['T.O.1.3'], fabrika: harfKur, uret: (f) => f.harf() },
  { id: 'b3-tr1-cumle', ders: 'Türkçe', sinif: 1, idOnek: 'B3TR1-CML', mufredat_surum: MUFREDAT, kodlar: ['T.Y.1.3'],
    fabrika: (c) => cumleKur(c, { kod: 'T.Y.1.3', konu: 'Noktalama', alt_konu: 'Cümle sonuna ve sıralanan sözcüklerin arasına uygun işaret koyma', turler: ['nokta', 'soru', 'unlem', 'virgul'], secenek: ['nokta', 'soru', 'unlem', 'virgul'], buyuk: false }), uret: (f) => f.bosluk() },
  { id: 'b3-tr1-olay', ders: 'Türkçe', sinif: 1, idOnek: 'B3TR1-OLY', mufredat_surum: MUFREDAT, kodlar: ['T.O.1.2'],
    fabrika: (c) => kartKur(c, { kod: 'T.O.1.2', konu: 'Olay sırası', alt_konu: 'Okuduğu kartlardaki olayları sıralama', tur: 'olay', banka: OLAY3, duzen: 'liste', zorluk: 1 }), uret: (f) => f.sirala() },
];
