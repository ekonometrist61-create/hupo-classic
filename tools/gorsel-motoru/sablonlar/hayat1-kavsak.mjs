// 1. sınıf Hayat Bilgisi — kavşakta iki trafik ışığı (ana yol ve yan yol). Renk + yol etiketi birlikte bilgidir.
// Kural: iki yoldan en fazla biri kırmızı olmayabilir. 5 durum × 2 sürücü × 2 sıra × 2 biçim = 40 farklı soru.
const MUFREDAT = 'TYMM 1-2 taslak 2026-27';
const DURUMLAR = [['kirmizi', 'kirmizi'], ['kirmizi', 'sari'], ['kirmizi', 'yesil'], ['sari', 'kirmizi'], ['yesil', 'kirmizi']];
const ARAC = { kirmizi: 'Durur', sari: 'Yavaşlar ve durmaya hazırlanır', yesil: 'Etrafı kontrol ederek geçer' };
const AC = { kirmizi: 'kırmızı', sari: 'sarı', yesil: 'yeşil' };
const HAVUZ = ['Durur', 'Yavaşlar ve durmaya hazırlanır', 'Etrafı kontrol ederek geçer', 'Hızını artırarak geçer'];
const YOL = { ana: 'ana yol', yan: 'yan yol' };
const YOLDAN = { ana: 'Ana yoldan', yan: 'Yan yoldan' };

export function kur({ sec, ekle }) {
  function kavsakSorusu() {
    const [ana, yan] = sec(DURUMLAR), bicim = sec(['dikey', 'yatay']), sira = sec(['ana_ilk', 'yan_ilk']), sur = sec(['ana', 'yan']);
    const renk = { ana, yan }[sur];
    const dogru = ARAC[renk];
    const cel = HAVUZ.filter((x) => x !== dogru);
    const sebep = (x) => {
      const uygun = Object.keys(ARAC).filter((k) => ARAC[k] === x);
      return uygun.length === 0
        ? 'Hız artırmak tehlikelidir; hiçbir ışıkta doğru değildir.'
        : `Bu davranış ${uygun.map((k) => AC[k]).join(' / ')} ışık için uygundur; ${YOL[sur]} ışığı ${AC[renk]} renktedir.`;
    };
    ekle({ kod: 'HB.1.2.3', konu: 'Güvenli Yaşam', alt_konu: 'Trafik ışıkları', zorluk: 2,
      spec: { tip_id: 'trafik-kavsak', parametreler: { ana, yan, bicim, sira } },
      dogru, celdirici: cel, gerekce: cel.map(sebep),
      kok: `Yukarıdaki kavşakta iki trafik ışığı vardır; ışıkların yanındaki etiketler hangi yola ait olduğunu gösterir. ${YOLDAN[sur]} gelen araç sürücüleri ne yapmalıdır?`,
      ipucu: 'Sürücünün geldiği yolun etiketini bul ve o yoldaki ışığın rengine bak.',
      cozum: [`${YOL[sur][0].toUpperCase() + YOL[sur].slice(1)} ışığı ${AC[renk]} renktedir.`, `Bu ışıkta araç sürücüsü şunu yapmalıdır: ${dogru}.`],
      dogrulama: [{ yol: ['ana'], beklenen: ana }, { yol: ['yan'], beklenen: yan }] });
  }
  return { kavsakSorusu };
}

export const KAYIT = [
  { id: 'hb1-trafik-kavsak', ders: 'Hayat Bilgisi', sinif: 1, idOnek: 'HB1-KAV', mufredat_surum: MUFREDAT, kodlar: ['HB.1.2.3'], fabrika: kur, uret: (f) => f.kavsakSorusu() },
];
