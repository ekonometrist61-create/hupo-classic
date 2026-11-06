// 3. sınıf İngilizce — hava durumuna göre giyim (hava çizelgesi). Şekil: b4-hava.
import { GUNLER, GUN3, ERKEK, KADIN } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 3. sınıf; program: TYMM)';
const GIYSI = {
  sunny: 'a hat and sunglasses', rainy: 'a raincoat and boots', snowy: 'a coat and gloves', windy: 'a jacket and a scarf', cloudy: 'a sweater and jeans',
};
const TURLER = Object.keys(GIYSI);
const TR = { sunny: 'güneşli', cloudy: 'bulutlu', rainy: 'yağmurlu', snowy: 'karlı', windy: 'rüzgârlı' };

export function kur({ R, sec, karistir, ekle }) {
  function giysiSorusu() {
    const bas = Math.floor(R() * 7), tur = karistir(TURLER).slice(0, 4);
    const gunler = tur.map((h, i) => ({ ad: GUN3[(bas + i) % 7], hava: h }));
    const i = Math.floor(R() * 4), X = gunler[i], tam = GUNLER[(bas + i) % 7];
    const kadin = R() < 0.5, ad = sec(kadin ? KADIN : ERKEK), o = kadin ? 'She' : 'He';
    const spec = { tip_id: 'b4-hava', parametreler: { gunler } };
    const ortak = { kod: 'ENG.3.3.V1', konu: 'Weather and clothing', spec };
    const kind = sec(['giysi', 'gun', 'hava']);
    if (kind === 'giysi') {
      const dogru = `${o} wears ${GIYSI[X.hava]}.`, cel = gunler.filter((g) => g !== X).map((g) => `${o} wears ${GIYSI[g.hava]}.`);
      ekle({ ...ortak, alt_konu: 'Havaya göre giysi seçme', zorluk: 2, kok: `Look at the weather chart. It's ${tam}. What does ${ad} wear?`, dogru, celdirici: cel,
        gerekce: gunler.filter((g) => g !== X).map((g) => `Bu giysiler ${TR[g.hava]} hava içindir; ${tam} günü hava ${TR[X.hava]}.`),
        ipucu: `${X.ad} sütunundaki hava simgesine bak, sonra o havaya uygun giysiyi seç.`, cozum: [`${X.ad} günü hava ${TR[X.hava]}.`, `${TR[X.hava]} havada: ${GIYSI[X.hava]}.`],
        dogrulama: [{ yol: ['hava', X.ad], beklenen: X.hava }] });
    } else if (kind === 'gun') {
      const dogru = tam, cel = gunler.filter((g) => g !== X).map((g) => GUNLER[(bas + gunler.indexOf(g)) % 7]);
      ekle({ ...ortak, alt_konu: 'Giysiden günü bulma', zorluk: 3, kok: `Look at the weather chart. ${ad} wears ${GIYSI[X.hava]}. Which day is it?`, dogru, celdirici: cel,
        gerekce: gunler.filter((g) => g !== X).map((g) => `${GUNLER[(bas + gunler.indexOf(g)) % 7]} günü hava ${TR[g.hava]}; bu giysilere uygun değildir.`),
        ipucu: 'Giysiye uygun havayı düşün, sonra çizelgede o hava simgesini bul.', cozum: [`${GIYSI[X.hava]} ${TR[X.hava]} hava içindir.`, `${TR[X.hava]} simge ${X.ad} sütunundadır: ${dogru}.`],
        dogrulama: [{ yol: ['gunler', X.hava], beklenen: [X.ad] }] });
    } else {
      const dogru = `It's ${X.hava}.`, cel = gunler.filter((g) => g !== X).map((g) => `It's ${g.hava}.`);
      ekle({ ...ortak, alt_konu: 'Günün havasını söyleme', zorluk: 1, kok: `Look at the weather chart. What's the weather like on ${tam}?`, dogru, celdirici: cel,
        gerekce: cel.map((c) => `${c} başka bir günün havasıdır.`), ipucu: `${X.ad} sütunundaki simgeye bak.`, cozum: [`${X.ad} sütunundaki simge ${TR[X.hava]} havayı gösterir.`],
        dogrulama: [{ yol: ['hava', X.ad], beklenen: X.hava }] });
    }
  }
  return { giysiSorusu };
}

export const KAYIT = [
  { id: 'eng3-hava-giyim', ders: 'İngilizce', sinif: 3, idOnek: 'ENG3-HAV', mufredat_surum: MUFREDAT, kodlar: ['ENG.3.3.V1'], fabrika: kur, uret: (f) => f.giysiSorusu() },
];
