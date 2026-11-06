// 4. sınıf İngilizce (önceki program) — hava durumu ve giysi (hava çizelgesi). Şekil: b4-hava.
import { GUNLER, GUN3, ERKEK, KADIN } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 4. sınıf; program: önceki program)';
const TURLER = ['sunny', 'cloudy', 'rainy', 'snowy', 'windy', 'stormy'];
const TR = { sunny: 'güneşli', cloudy: 'bulutlu', rainy: 'yağmurlu', snowy: 'karlı', windy: 'rüzgârlı', stormy: 'fırtınalı' };
const EYLEM = { sunny: 'to wear sunglasses', rainy: 'to take an umbrella', snowy: 'to wear gloves', windy: 'to fly a kite' };

export function kur({ R, sec, karistir, ekle }) {
  function havaSorusu() {
    const bas = Math.floor(R() * 7), tur = karistir(TURLER).slice(0, 4);
    const gunler = tur.map((h, i) => ({ ad: GUN3[(bas + i) % 7], hava: h }));
    const kind = sec(['gunu', 'hangi', 'esya']);
    const aday = kind === 'esya' ? gunler.filter((g) => EYLEM[g.hava]) : gunler;
    if (!aday.length) throw new Error('esya_gunu_yok');
    const X = sec(aday), i = gunler.indexOf(X), tam = GUNLER[(bas + i) % 7], tamAd = (g) => GUNLER[(bas + gunler.indexOf(g)) % 7];
    const kadin = R() < 0.5, ad = sec(kadin ? KADIN : ERKEK);
    const ortak = { kod: 'E4.8.L1', konu: 'Weather conditions', spec: { tip_id: 'b4-hava', parametreler: { gunler } } };
    if (kind === 'gunu') {
      const dogru = `It's ${X.hava}.`, cel = gunler.filter((g) => g !== X).map((g) => `It's ${g.hava}.`);
      ekle({ ...ortak, alt_konu: 'Hava durumunu betimleme', zorluk: 1, kok: `Look at the weather chart. What's the weather like on ${tam}?`, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c} başka bir günün havasıdır.`), ipucu: `${X.ad} sütunundaki simgeye bak.`, cozum: [`${X.ad} sütunundaki simge ${TR[X.hava]} havayı gösterir.`],
        dogrulama: [{ yol: ['hava', X.ad], beklenen: X.hava }] });
    } else if (kind === 'hangi') {
      const dogru = tam, cel = gunler.filter((g) => g !== X).map(tamAd);
      ekle({ ...ortak, alt_konu: 'Hava durumundan günü bulma', zorluk: 2, kok: `Look at the weather chart. On which day is it ${X.hava}?`, dogru, celdirici: cel,
        gerekce: gunler.filter((g) => g !== X).map((g) => `${tamAd(g)} günü hava ${TR[g.hava]}.`), ipucu: `${X.hava} simgesini bul ve sütun başlığını oku.`,
        cozum: [`${X.hava} simgesi ${X.ad} sütunundadır.`, `Cevap ${dogru}.`], dogrulama: [{ yol: ['gunler', X.hava], beklenen: [X.ad] }] });
    } else {
      const dogru = tam, cel = gunler.filter((g) => g !== X).map(tamAd);
      ekle({ ...ortak, alt_konu: 'Havaya uygun etkinlik/eşya', zorluk: 3, kok: `Look at the weather chart. ${ad} wants ${EYLEM[X.hava]}. Which day is it?`, dogru, celdirici: cel,
        gerekce: gunler.filter((g) => g !== X).map((g) => `${tamAd(g)} günü hava ${TR[g.hava]}; "${EYLEM[X.hava]}" bu havaya uygun değildir.`),
        ipucu: `"${EYLEM[X.hava]}" hangi havaya uyar? O simgeyi bul.`, cozum: [`"${EYLEM[X.hava]}" ${TR[X.hava]} havaya uyar.`, `${TR[X.hava]} simge ${X.ad} sütunundadır: ${dogru}.`],
        dogrulama: [{ yol: ['hava', X.ad], beklenen: X.hava }] });
    }
  }
  return { havaSorusu };
}

export const KAYIT = [
  { id: 'eng4-hava', ders: 'İngilizce', sinif: 4, idOnek: 'ENG4-HAV', mufredat_surum: MUFREDAT, kodlar: ['E4.8.L1'], fabrika: kur, uret: (f) => f.havaSorusu() },
];

