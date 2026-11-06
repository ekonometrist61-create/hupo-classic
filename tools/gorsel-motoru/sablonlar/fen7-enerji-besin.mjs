// 7. sınıf Fen Bilimleri — potansiyel ve kinetik enerji karşılaştırma (FB.7.2.2); besin ağında canlılar arası ilişkiler (FB.7.7.1).
// besinFabrika, 8. sınıf besin ağı şablonu (fen8-*) tarafından da kullanılır.
import { sayiSik, pencereSik } from '../tipler-b2.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 7. sınıf; program: TYMM)';
const HARF = ['K', 'L', 'M', 'N'];

// ---- enerji ----
export function kurEnerji({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'FB.7.2.2', konu: 'Kuvvet ve Enerji', alt_konu: 'Kinetik ve potansiyel enerji' };
  const dort = (n, f) => Array.from({ length: n }, f);
  function enerjiSorusu() {
    const k = konum(), potansiyel = R() < 0.5, mod = potansiyel ? 'yukseklik' : 'hiz', tur = sec(['en', 'kutle', 'deger']);
    const dMin = potansiyel ? 1 : 2, dMax = potansiyel ? 5 : 12;
    let kut, deg;
    if (tur === 'en') {
      const tm = 4 + Math.floor(R() * 5), td = potansiyel ? 3 + Math.floor(R() * 3) : 6 + Math.floor(R() * 7);
      kut = dort(4, (_, i) => (i === k ? tm : 1 + Math.floor(R() * (tm - 1)))); deg = dort(4, (_, i) => (i === k ? td : dMin + Math.floor(R() * (td - dMin))));
      if (td === dMin) throw new Error('aralik');
    } else if (tur === 'kutle') { // kütleler eşit: en büyük değer (yükseklik/hız) kazanır
      const m = 2 + Math.floor(R() * 7), vals = karistir(Array.from({ length: dMax - dMin + 1 }, (_, i) => dMin + i)).slice(0, 4).sort((a, b) => a - b);
      kut = dort(4, () => m); const dg = karistir(vals.slice(0, 3)); dg.splice(k, 0, vals[3]); deg = dg;
    } else { // değerler eşit: en büyük kütle kazanır
      const d = dMin + 1 + Math.floor(R() * (dMax - dMin - 1)), ms = karistir([1, 2, 3, 4, 5, 6, 7, 8, 9]).slice(0, 4).sort((a, b) => a - b);
      deg = dort(4, () => d); const kg = karistir(ms.slice(0, 3)); kg.splice(k, 0, ms[3]); kut = kg;
    }
    const cisimler = HARF.map((ad, i) => ({ ad, kutle: kut[i], deger: deg[i] }));
    const spec = { tip_id: 'b2-cisimler', parametreler: { mod, cisimler } };
    const neden = (h, i) => {
      const c = cisimler[i], o = cisimler[k];
      if (tur === 'en') return `${h} cisminin kütlesi (${c.kutle} kg) ve ${potansiyel ? 'yüksekliği' : 'hızı'} (${c.deger} ${potansiyel ? 'm' : 'm/s'}) ${HARF[k]} cismininkinden küçüktür; ${potansiyel ? 'potansiyel' : 'kinetik'} enerjisi daha azdır.`;
      if (tur === 'kutle') return `${h} cisminin kütlesi ${HARF[k]} cismiyle aynıdır, ancak ${potansiyel ? 'yüksekliği' : 'hızı'} daha küçüktür (${c.deger} ${potansiyel ? 'm' : 'm/s'}); enerjisi daha azdır.`;
      return `${h} cisminin ${potansiyel ? 'yüksekliği' : 'hızı'} ${HARF[k]} cismiyle aynıdır, ancak kütlesi daha küçüktür (${c.kutle} kg); enerjisi daha azdır.`;
    };
    const ad_enerji = potansiyel ? 'yer çekimi potansiyel enerjisi' : 'kinetik enerjisi';
    const baslik = potansiyel
      ? sec(['Şekilde farklı yüksekliklerdeki sütunların üzerinde duran dört cisim gösterilmiştir.', 'Yer yüzeyinden farklı yüksekliklerde duran dört cismin kütleleri şekilde yazılıdır.'])
      : sec(['Şekilde düz bir yolda hareket eden dört cismin kütleleri ve hızları gösterilmiştir.', 'Dört cisim, kütleleri ve hızları şekilde yazıldığı gibi hareket etmektedir.']);
    ekle({ ...kod, zorluk: tur === 'en' ? 2 : 3, spec, sirali: HARF, dogru: HARF[k],
      kok: `${baslik} Hangi cismin ${ad_enerji} en büyüktür?`,
      gerekce: HARF.map((h, i) => (i === k ? '' : neden(h, i))),
      ipucu: potansiyel ? 'Potansiyel enerji, cismin kütlesi ve yerden yüksekliği arttıkça artar.' : 'Kinetik enerji, cismin kütlesi ve hızı arttıkça artar.',
      cozum: [potansiyel ? 'Yer çekimi potansiyel enerjisi kütle ve yükseklikle artar.' : 'Kinetik enerji kütle ve hızla artar.', `${HARF[k]} cisminin ${tur === 'deger' ? 'kütlesi' : tur === 'kutle' ? (potansiyel ? 'yüksekliği' : 'hızı') : 'kütlesi ve ' + (potansiyel ? 'yüksekliği' : 'hızı')} diğerlerinden ${tur === 'en' ? 'büyüktür' : 'büyüktür'}; enerjisi en büyük olan cisim odur.`],
      dogrulama: [{ yol: ['kutle', HARF[k]], beklenen: kut[k] }, { yol: ['deger', HARF[k]], beklenen: deg[k] }] });
  }
  return { enerjiSorusu };
}

// ---- besin ağı ----
const TOPO = [
  { seviye: [[0, 1], [2, 3], [4]], ok: [[0, 2], [0, 3], [1, 3], [2, 4], [3, 4]] },
  { seviye: [[0], [1, 2], [3, 4]], ok: [[0, 1], [0, 2], [1, 3], [1, 4], [2, 4]] },
  { seviye: [[0, 1, 2], [3, 4], [5]], ok: [[0, 3], [1, 3], [1, 4], [2, 4], [3, 5], [4, 5]] },
  { seviye: [[0, 1], [2, 3], [4], [5]], ok: [[0, 2], [1, 3], [2, 4], [3, 4], [4, 5]] },
  { seviye: [[0, 1], [2, 3, 4], [5]], ok: [[0, 2], [0, 3], [1, 3], [1, 4], [2, 5], [3, 5], [4, 5]] },
];
const HARFLER = ['K', 'L', 'M', 'N', 'P', 'R', 'S'];
function agKur(sec, karistir) {
  const t = sec(TOPO), n = t.seviye.flat().length, harf = karistir(HARFLER).slice(0, n), L = t.seviye.length, pos = [];
  t.seviye.forEach((lv, li) => lv.forEach((idx, j) => { const xs = lv.length === 1 ? [180] : lv.length === 2 ? [110, 250] : [70, 180, 290]; pos[idx] = { ad: harf[idx], x: xs[j], y: 38 + (L - 1 - li) * 68 }; }));
  return { dugumler: pos, oklar: t.ok.map(([a, b]) => [harf[a], harf[b]]) };
}
const yiyenOlgu = (ag) => { const y = {}, e = {}; ag.dugumler.forEach((d) => { y[d.ad] = []; e[d.ad] = []; }); ag.oklar.forEach(([a, b]) => { y[a].push(b); e[b].push(a); }); return { yiyen: y, yenen: e }; };

// kindler: 'uretici' | 'etkilenen' | 'ust' | 'cokbesin' | 'uretici-say' | 'tuketici-say'
export function besinFabrika({ kod, kindler }) {
  return ({ R, sec, karistir, ekle, konum }) => ({
    besinSorusu() {
      const k = konum(), tur = sec(kindler), ag = agKur(sec, karistir), { yiyen, yenen } = yiyenOlgu(ag), tum = ag.dugumler.map((d) => d.ad).sort();
      const uretici = tum.filter((a) => yenen[a].length === 0), ust = tum.filter((a) => yiyen[a].length === 0);
      const spec = { tip_id: 'b2-besin', parametreler: { dugumler: ag.dugumler, oklar: ag.oklar } };
      const giris = 'Şekilde bir besin ağı gösterilmiştir; oklar, yenen canlıdan onu yiyen canlıya doğrudur.';
      const harfSik = (dogru, gerekceF, kok, ipucu, cozum, dogrulama, zorluk = 2) => {
        const idx = tum.indexOf(dogru), sec4 = pencereSik(tum, idx, k, R);
        ekle({ ...kod, zorluk, spec, sirali: sec4.map((i) => tum[i]), dogru, kok, gerekce: sec4.map((i) => (i === idx ? '' : gerekceF(tum[i]))), ipucu, cozum, dogrulama });
      };
      const sayiSor = (deger, say, kok, ipucu, cozum) => {
        const s = sayiSik(deger, k, R, { min: 0, max: 6, genislik: 3, tercih: [] });
        ekle({ ...kod, zorluk: 2, spec, sirali: s.sirali, dogru: String(deger), kok, gerekce: s.degerler.map((v) => (v === deger ? '' : `${v} yanlıştır; ${say}`)), ipucu, cozum, dogrulama: [{ yol: ['tuketici_sayisi'], beklenen: tum.length - uretici.length }] });
      };
      if (tur === 'uretici') {
        if (uretici.length !== 1) throw new Error('tek_uretici_degil');
        harfSik(uretici[0], (h) => `${h} canlısı başka canlılarla beslenir (kendisine ok gelir); üretici değildir. Üreticiler kendi besinini üretir, hiçbir canlıdan ok almaz.`,
          `${giris} Bu besin ağındaki üretici hangi harfle gösterilen canlıdır?`, 'Üreticiler besinini kendisi üretir; şemada hiçbir canlıdan ok almazlar.', ['Üreticiye başka bir canlıdan ok gelmez.', `Yalnız ${uretici[0]} canlısına ok gelmez; üretici odur.`], [{ yol: ['uretici'], beklenen: uretici }]);
      } else if (tur === 'ust') {
        if (ust.length !== 1) throw new Error('tek_ust_degil');
        harfSik(ust[0], (h) => `${h} canlısından başka bir canlıya ok gider; yani ${h} canlısı başka bir canlı tarafından yenir.`,
          `${giris} Hiçbir canlı tarafından yenmeyen canlı hangisidir?`, 'Yenmeyen canlıdan başka hiçbir canlıya ok gitmez.', ['Hiçbir canlı tarafından yenmeyen canlıdan çıkan ok yoktur.', `${ust[0]} canlısından çıkan ok yoktur.`], [{ yol: ['ust'], beklenen: ust }]);
      } else if (tur === 'etkilenen') {
        const adaylar = tum.filter((a) => yiyen[a].length === 1);
        if (!adaylar.length) throw new Error('aday_yok');
        const x = sec(adaylar), e = yiyen[x][0];
        harfSik(e, (h) => (h === x ? `${h}, sayısı azalan canlının kendisidir.` : `${h} canlısı ${x} canlısını yemez; ${x} azalınca besini doğrudan azalan canlı değildir.`),
          `${giris} ${x} canlısının sayısı azalırsa besini doğrudan azalan canlı hangisidir?`, `${x} canlısından çıkan oku izle; ok hangi canlıya gidiyorsa o canlı ${x} ile beslenir.`, [`${x} canlısından çıkan ok ${e} canlısına gider.`, `${e} canlısı ${x} ile beslenir; ${x} azalırsa besini azalır.`], [{ yol: ['yiyen', x], beklenen: [e] }]);
      } else if (tur === 'cokbesin') {
        const adaylar = tum.filter((a) => yenen[a].length >= 2);
        if (adaylar.length !== 1) throw new Error('tek_aday_degil');
        const x = adaylar[0];
        harfSik(x, (h) => `${h} canlısına gelen ok sayısı ${yenen[h].length} tanedir; birden fazla canlıyla beslenen canlı değildir.`,
          `${giris} Birden fazla canlıyla beslenen canlı hangisidir?`, 'Bir canlıya gelen ok sayısı, onun kaç canlıyla beslendiğini gösterir.', ['Birden fazla ok alan canlıyı bul.', `${x} canlısına ${yenen[x].length} ok gelir.`], [{ yol: ['yenen', x], beklenen: yenen[x] }], 3);
      } else if (tur === 'uretici-say') {
        sayiSor(uretici.length, `şemada hiçbir canlıdan ok almayan ${uretici.length} üretici vardır.`, `${giris} Bu besin ağında kaç canlı üreticidir?`, 'Üreticiler hiçbir canlıdan ok almaz.', [`Ok almayan canlıları say: ${uretici.join(', ')}.`, `${uretici.length} üretici vardır.`]);
      } else {
        const t = tum.length - uretici.length;
        sayiSor(t, `üretici olmayan ${t} canlı tüketicidir.`, `${giris} Bu besin ağında kaç canlı tüketicidir?`, 'Tüketiciler başka canlılarla beslenir; kendilerine ok gelir.', [`Üreticiler: ${uretici.join(', ')}.`, `Geri kalan ${t} canlı tüketicidir.`]);
      }
    },
  });
}

export const KAYIT = [
  { id: 'b2-fen7-enerji', ders: 'Fen Bilimleri', sinif: 7, idOnek: 'FEN7-ENR', mufredat_surum: MUFREDAT, kodlar: ['FB.7.2.2'], fabrika: kurEnerji, uret: (f) => f.enerjiSorusu() },
  { id: 'b2-fen7-besin-agi', ders: 'Fen Bilimleri', sinif: 7, idOnek: 'FEN7-BES', mufredat_surum: MUFREDAT, kodlar: ['FB.7.7.1'],
    fabrika: besinFabrika({ kod: { kod: 'FB.7.7.1', konu: 'Canlılar ve Yaşam', alt_konu: 'Besin ağında canlılar arasındaki ilişkiler' }, kindler: ['uretici', 'ust', 'etkilenen', 'etkilenen', 'cokbesin'] }), uret: (f) => f.besinSorusu() },
];
