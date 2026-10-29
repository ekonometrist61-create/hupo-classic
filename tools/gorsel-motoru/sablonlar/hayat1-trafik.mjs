// 1. sınıf Hayat Bilgisi — trafik ışığı (temel trafik kuralları). Renk + konum birlikte bilgidir.
// Not: altı değişik soru üretilebilir (3 ışık × 2 bakış); daha fazlası için yeni şablon gerekir.
const MUFREDAT = 'TYMM 1-2 taslak 2026-27';
const ISIKLAR = ['kirmizi', 'sari', 'yesil'];
const ARAC = { kirmizi: 'Durur', sari: 'Yavaşlar ve durmaya hazırlanır', yesil: 'Etrafı kontrol ederek geçer' };
const YAYA = { kirmizi: 'Etrafı kontrol ederek geçer', sari: 'Bekler', yesil: 'Bekler' };
const AC = { kirmizi: 'kırmızı', sari: 'sarı', yesil: 'yeşil' };

export function kur({ R, sec, ekle }) {
  function isikSorusu() {
    const yanan = sec(ISIKLAR), yaya = R() < 0.5, harita = yaya ? YAYA : ARAC;
    const dogru = harita[yanan];
    const havuz = yaya ? ['Etrafı kontrol ederek geçer', 'Bekler', 'Koşarak geçer', 'Araçların arasından geçer'] : ['Durur', 'Yavaşlar ve durmaya hazırlanır', 'Etrafı kontrol ederek geçer', 'Hızını artırarak geçer'];
    const cel = havuz.filter((x) => x !== dogru);
    const sebep = (x) => (x === 'Koşarak geçer' || x === 'Araçların arasından geçer' ? 'Yayanın güvenliğini tehlikeye atan bir davranıştır.' : x === 'Hızını artırarak geçer' ? 'Hız artırmak tehlikelidir; hiçbir ışıkta doğru değildir.' : `Bu davranış ${ISIKLAR.filter((k) => harita[k] === x).map((k) => AC[k]).join(' / ')} ışık için uygundur; yanan lamba ${AC[yanan]} renktedir.`);
    ekle({ kod: 'HB.1.2.3', konu: 'Güvenli Yaşam', alt_konu: 'Trafik ışıkları', zorluk: 1, spec: { tip_id: 'trafik-isigi', parametreler: { yanan } },
      dogru, celdirici: cel, gerekce: cel.map(sebep),
      kok: yaya ? 'Yukarıdaki trafik ışığı araçlar için yanmaktadır. Karşıdan karşıya geçmek isteyen yaya ne yapmalıdır?' : 'Yukarıdaki trafik ışığı araçlar için yanmaktadır. Araç sürücüleri bu ışıkta ne yapmalıdır?',
      ipucu: 'Yanan lambanın rengine ve yerine (üstte, ortada, altta) bak.',
      cozum: [`Yanan lamba ${AC[yanan]} renktedir ve ${{ kirmizi: 'en üsttedir', sari: 'ortadadır', yesil: 'en alttadır' }[yanan]}.`, `${yaya ? 'Yaya' : 'Sürücü'} bu ışıkta şunu yapmalıdır: ${dogru}.`],
      dogrulama: [{ yol: ['yanan'], beklenen: yanan }] });
  }
  return { isikSorusu };
}

export const KAYIT = [
  { id: 'hb1-trafik-isigi', ders: 'Hayat Bilgisi', sinif: 1, idOnek: 'HB1-TRF', mufredat_surum: MUFREDAT, kodlar: ['HB.1.2.3'], fabrika: kur, uret: (f) => f.isikSorusu() },
];
