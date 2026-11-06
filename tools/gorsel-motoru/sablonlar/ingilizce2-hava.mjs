// 2. sınıf İngilizce — hava durumu (günlere göre simgeler). Şekil: b4-hava.
import { GUNLER, GUN3 } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 2. sınıf; program: TYMM)';
const TURLER = ['sunny', 'cloudy', 'rainy', 'snowy', 'windy'];
const TR = { sunny: 'güneşli', cloudy: 'bulutlu', rainy: 'yağmurlu', snowy: 'karlı', windy: 'rüzgârlı' };

export function kur({ R, sec, karistir, ekle }) {
  function havaSorusu() {
    const bas = Math.floor(R() * 7), tur = karistir(TURLER);
    const gunler = tur.map((h, i) => ({ ad: GUN3[(bas + i) % 7], hava: h }));
    const i = Math.floor(R() * 5), X = gunler[i], tam = GUNLER[(bas + i) % 7];
    const spec = { tip_id: 'b4-hava', parametreler: { gunler } };
    const ortak = { kod: 'ENG.2.3.V1', konu: 'Weather conditions', spec };
    if (sec(['gunu', 'hangi']) === 'gunu') {
      const dogru = `It's ${X.hava}.`, cel = karistir(TURLER.filter((t) => t !== X.hava)).slice(0, 3).map((t) => `It's ${t}.`);
      ekle({ ...ortak, alt_konu: 'Günün havasını söyleme', zorluk: 1, kok: `Look at the weather chart. ${sec(["What's the weather like on", 'How is the weather on'])} ${tam}?`, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c} başka bir günün simgesine uyar; ${X.ad} gününde hava ${TR[X.hava]}.`),
        ipucu: `${X.ad} sütunundaki simgeye bak.`, cozum: [`${tam} günü ${X.ad} sütunundadır.`, `Simge ${TR[X.hava]} havayı gösterir: ${dogru}`],
        dogrulama: [{ yol: ['hava', X.ad], beklenen: X.hava }] });
    } else {
      const dogru = GUNLER[(bas + i) % 7], cel = karistir(gunler.filter((g) => g !== X)).slice(0, 3).map((g) => GUNLER[(bas + gunler.indexOf(g)) % 7]);
      ekle({ ...ortak, alt_konu: 'Hava durumundan günü bulma', zorluk: 2, kok: `Look at the weather chart. Which day is ${X.hava}?`, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c} günü başka bir hava durumunu gösterir.`),
        ipucu: `${X.hava} havayı gösteren simgeyi bul ve üstündeki gün adını oku.`, cozum: [`${X.hava} simgesi ${X.ad} sütunundadır.`, `${X.ad}, ${dogru} günüdür.`],
        dogrulama: [{ yol: ['gunler', X.hava], beklenen: [X.ad] }] });
    }
  }
  return { havaSorusu };
}

export const KAYIT = [
  { id: 'eng2-hava', ders: 'İngilizce', sinif: 2, idOnek: 'ENG2-HAV', mufredat_surum: MUFREDAT, kodlar: ['ENG.2.3.V1'], fabrika: kur, uret: (f) => f.havaSorusu() },
];
