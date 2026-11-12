// 1. sınıf Hayat Bilgisi — kavşakta iki trafik ışığı (ana yol ve yan yol). Renk + yol etiketi birlikte bilgidir.
// Yeniden tasarım (hb123_v2): soru davranış değil şekildeki ışığı okutur (hangi renk yanıyor / hangi etiketli ışıkta yanıyor).
// Kök yanan rengi ya da yolu söylemez; şıklar şekle bağlı değerlerdir; doğru ve dağılım kodda hesaplanır.
// Kural: iki yoldan en fazla biri kırmızı olmayabilir. Renk sorusu 10 + yol sorusu 15 = 25 farklı soru; yerleşim (biçim/sıra) her soruya sabit atanır.
// Not: paket.test.mjs 'eksik üretim' testi trafik kazanımında toplam 46 farklı soru bekler (trafik 21 + kavşak 25); sayıyı değiştirirsen o testi güncelle.
const MUFREDAT = 'TYMM 1-2 taslak 2026-27';
const DURUMLAR = [['kirmizi', 'kirmizi'], ['kirmizi', 'sari'], ['kirmizi', 'yesil'], ['sari', 'kirmizi'], ['yesil', 'kirmizi']];
const RENKLER = ['kirmizi', 'sari', 'yesil'];
const AD = { kirmizi: 'Kırmızı', sari: 'Sarı', yesil: 'Yeşil' };
const ETIKET = { ana: 'ANA YOL', yan: 'YAN YOL' };
const HICBIRI = 'Hiçbir lamba yanmıyor';
const YOL_SIKLARI = { ana: 'Yalnız ANA YOL etiketli ışıkta', yan: 'Yalnız YAN YOL etiketli ışıkta', iki: 'İki ışıkta da', hic: 'Hiçbir ışıkta' };
const SINIFLAR = ['ana', 'yan', 'iki', 'hic'];

// Renk sorusu adayları: her renk için (durum, sorulan yol) çiftleri. Doğru renk eşit dağılsın diye önce renk seçilir.
let sayac = 0;
const yerlesim = () => { const n = sayac++; return { bicim: n % 2 ? 'yatay' : 'dikey', sira: (n >> 1) % 2 ? 'yan_ilk' : 'ana_ilk' }; };
const RENK_ADAY = Object.fromEntries(RENKLER.map((c) => [c, DURUMLAR.flatMap((d) => ['ana', 'yan'].filter((y) => d[y === 'ana' ? 0 : 1] === c).map((y) => ({ durum: d, yol: y, ...yerlesim() })))]));
// Yol sorusu adayları: (renk, durum) çiftleri, o rengin yandığı yollar kümesine göre sınıflanır. Doğru şık eşit dağılsın diye önce sınıf seçilir.
const sinifla = (durum, c) => { const a = durum[0] === c, y = durum[1] === c; return a && y ? 'iki' : a ? 'ana' : y ? 'yan' : 'hic'; };
const YOL_ADAY = Object.fromEntries(SINIFLAR.map((s) => [s, RENKLER.flatMap((c) => DURUMLAR.filter((d) => sinifla(d, c) === s).map((d) => ({ durum: d, renk: c, ...yerlesim() })))]));

export function kur({ sec, ekle }) {
  function kavsakSorusu() {
    const renkSorusu = sec([true, false]);
    let durum, bicim, sira, kok, dogru, cel, gerekce, cozum, ipucu;
    if (renkSorusu) {
      const c = sec(RENKLER), a = sec(RENK_ADAY[c]);
      ({ durum, bicim, sira } = a);
      const e = ETIKET[a.yol];
      dogru = AD[c];
      const havuz = [...RENKLER.map((k) => AD[k]), HICBIRI];
      cel = havuz.filter((x) => x !== dogru);
      kok = `Yukarıdaki kavşakta her ışığın yanında bir yol etiketi vardır. ${e} etiketli ışıkta hangi renkli lamba yanmaktadır?`;
      gerekce = cel.map((x) => (x === HICBIRI
        ? `Şekilde ${e} etiketli ışıkta renkli yanan bir lamba görülür; gri lambalar sönüktür.`
        : `${e} etiketli ışıkta yanan lamba şekilde bu renkte görünmüyor; renkli lambaya bak.`));
      cozum = [`Şekilde ${e} etiketini bul ve o etiketin ait olduğu ışığa bak.`, 'Bu ışıkta renkli görünen lambanın rengini oku; gri lambalar yanmayan lambalardır.'];
      ipucu = 'Önce etiketin hangi ışığa ait olduğunu bul, sonra o ışıktaki renkli lambaya bak.';
    } else {
      const s = sec(SINIFLAR), a = sec(YOL_ADAY[s]);
      ({ durum, bicim, sira } = a);
      const c = a.renk;
      dogru = YOL_SIKLARI[s];
      cel = SINIFLAR.filter((x) => x !== s).map((x) => YOL_SIKLARI[x]);
      kok = `Yukarıdaki kavşakta iki trafik ışığı vardır ve her ışığın yanında bir yol etiketi bulunur. ${AD[c]} renkli lamba hangi ışıkta yanmaktadır?`;
      gerekce = cel.map(() => 'Bu seçenek, şekildeki iki etiketli ışıkta yanan lambaların renkleriyle uyuşmuyor; her ışıktaki renkli lambaya ayrı ayrı bak.');
      cozum = ['Şekilde ANA YOL ve YAN YOL etiketli ışıkların her birine ayrı ayrı bak.', 'Her ışıkta renkli yanan lambanın rengini oku ve sorulan renkle karşılaştır.'];
      ipucu = 'Her etiketli ışıkta renkli (yanan) lambayı bul; gri lambalar yanmıyor.';
    }
    const [ana, yan] = durum;
    ekle({ kod: 'HB.1.2.3', konu: 'Güvenli Yaşam', alt_konu: 'Trafik ışıkları', zorluk: 2,
      spec: { tip_id: 'trafik-kavsak', parametreler: { ana, yan, bicim, sira } },
      dogru, celdirici: cel, gerekce, kok, ipucu, cozum,
      dogrulama: [{ yol: ['ana'], beklenen: ana }, { yol: ['yan'], beklenen: yan }] });
  }
  return { kavsakSorusu };
}

export const KAYIT = [
  { id: 'hb1-trafik-kavsak', ders: 'Hayat Bilgisi', sinif: 1, idOnek: 'HB1-KAV', mufredat_surum: MUFREDAT, kodlar: ['HB.1.2.3'], fabrika: kur, uret: (f) => f.kavsakSorusu() },
];
