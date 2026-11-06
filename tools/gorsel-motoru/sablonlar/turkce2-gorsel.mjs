// 2. sınıf Türkçe — cümle satırı (noktalama ve büyük harf), olay sırası, sözcük sırası, ders programı tablosu.
// Kazanım kaynağı yalnız başlık verir: T.Y.2.3 (yazma kuralları), T.O.2.2 (anlam oluşturma), T.Y.2.2 (içerik oluşturma), T.O.2.3 (çözümleme).
import { cumleKur, kartKur, OLAY3, OLAY4, SOZ_SIRA, surum, tekilEkle } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_2_turkce');
const DERS = ['Türkçe', 'Matematik', 'Hayat Bilgisi', 'Müzik', 'Resim', 'Beden Eğitimi'];
const GUNLER = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'];

export function programKur({ R, sec, karistir, ekle: ekleOrj }) {
  const ekle = tekilEkle(ekleOrj);
  function program() {
    const n = sec([4, 5]), gunler = GUNLER.slice(0, n), satirlar = gunler.map((g) => [g, sec(DERS), sec(DERS)]);
    const sutunlar = ['Gün', '1. Ders', '2. Ders'], spec = { tip_id: 'b3-tablo', parametreler: { baslik: 'Ders Programı', sutunlar, satirlar } };
    const ortak = { kod: 'T.O.2.3', konu: 'Tablo okuma', alt_konu: 'Ders programından bilgi bulma', spec, zorluk: 1 };
    if (R() < 0.5) {
      const r = sec(satirlar), c = sec([1, 2]), dogru = r[c], cel = karistir(DERS.filter((d) => d !== dogru)).slice(0, 3);
      return ekle({ ...ortak, kok: `Tabloya göre ${r[0]} günü ${c}. ders hangisidir?`, dogru, celdirici: cel,
        gerekce: cel.map((d) => `${d}, ${r[0]} günü ${c}. ders değildir; tabloda ${r[0]} satırında ${c}. ders ${dogru} olarak yazılıdır.`),
        ipucu: `${r[0]} satırını bul, sonra ${c}. ders sütununa bak.`, cozum: [`Tabloda ${r[0]} satırı bulunur.`, `${c}. ders sütununda ${dogru} yazılıdır.`], dogrulama: [{ yol: ['hucre', r[0], `${c}. Ders`], beklenen: dogru }] });
    }
    const c = sec([1, 2]), r = sec(satirlar), ders = r[c];
    if (satirlar.filter((x) => x[c] === ders).length !== 1) throw new Error('ders_tekil_degil');
    const cel = karistir(satirlar.filter((x) => x !== r).map((x) => x[0])).slice(0, 3);
    return ekle({ ...ortak, kok: `Tabloya göre ${c}. dersi ${ders} olan gün hangisidir?`, dogru: r[0], celdirici: cel,
      gerekce: cel.map((g) => `${g} günü ${c}. ders ${satirlar.find((x) => x[0] === g)[c]} dersidir; ${ders} değildir.`),
      ipucu: `${c}. ders sütununda ${ders} yazan satırı bul, satırın başındaki güne bak.`, cozum: [`${c}. ders sütununda ${ders} aranır.`, `Bu ders ${r[0]} satırındadır.`], dogrulama: [{ yol: ['hucre', r[0], `${c}. Ders`], beklenen: ders }] });
  }
  return { program };
}

export const KAYIT = [
  { id: 'b3-tr2-cumle', ders: 'Türkçe', sinif: 2, idOnek: 'B3TR2-CML', mufredat_surum: MUFREDAT, kodlar: ['T.Y.2.3'],
    fabrika: (c) => cumleKur(c, { kod: 'T.Y.2.3', konu: 'Yazım kuralları', alt_konu: 'Noktalama ve büyük harf kullanımı', turler: ['nokta', 'soru', 'unlem', 'virgul'], secenek: ['nokta', 'soru', 'unlem', 'virgul'], buyuk: true, buyukOran: 0.4 }), uret: (f) => f.soru() },
  { id: 'b3-tr2-olay', ders: 'Türkçe', sinif: 2, idOnek: 'B3TR2-OLY', mufredat_surum: MUFREDAT, kodlar: ['T.O.2.2'],
    fabrika: (c) => kartKur(c, { kod: 'T.O.2.2', konu: 'Olay sırası', alt_konu: 'Okuduğu metindeki olayları sıralama', tur: 'olay', banka: [...OLAY3, ...OLAY4.slice(0, 7)], duzen: 'liste', zorluk: 2 }), uret: (f) => f.sirala() },
  { id: 'b3-tr2-cumle-kur', ders: 'Türkçe', sinif: 2, idOnek: 'B3TR2-SZC', mufredat_surum: MUFREDAT, kodlar: ['T.Y.2.2'],
    fabrika: (c) => kartKur(c, { kod: 'T.Y.2.2', konu: 'Cümle kurma', alt_konu: 'Karışık sözcüklerden anlamlı cümle oluşturma', tur: 'sozcuk', banka: SOZ_SIRA, duzen: 'chip', zorluk: 1 }), uret: (f) => f.sirala() },
  { id: 'b3-tr2-program', ders: 'Türkçe', sinif: 2, idOnek: 'B3TR2-PRG', mufredat_surum: MUFREDAT, kodlar: ['T.O.2.3'], fabrika: programKur, uret: (f) => f.program() },
];
