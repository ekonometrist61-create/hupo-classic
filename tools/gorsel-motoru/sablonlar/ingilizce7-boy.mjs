// 7. sınıf İngilizce (önceki program) — dış görünüş karşılaştırma (tall / taller / tallest ...). Şekil: b4-boy.
import { ERKEK, KADIN } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 7. sınıf; program: önceki program)';

export function kur({ R, sec, karistir, ekle }) {
  function boySorusu() {
    const adlar = karistir([...ERKEK.slice(0, 5), ...KADIN.slice(0, 5)]).slice(0, 6), boylar = karistir([88, 96, 104, 112, 120, 128, 136, 144, 152]).slice(0, 6);
    const kisiler = adlar.map((a, i) => ({ ad: a, boy: boylar[i] })), sirali = [...kisiler].sort((a, b) => b.boy - a.boy).map((k) => k.ad);
    const spec = { tip_id: 'b4-boy', parametreler: { kisiler } };
    const ortak = { kod: 'E7.1.R1', konu: 'Appearance and comparisons', spec };
    const dogrulama = [{ yol: ['sira'], beklenen: sirali }];
    const kind = sec(['uzun', 'kisa', 'daha_uzun', 'daha_kisa', 'arasinda']);
    const sec3 = (dogru, haric) => karistir(adlar.filter((a) => a !== dogru && !haric.includes(a))).slice(0, 3);
    if (kind === 'uzun' || kind === 'kisa') {
      const dogru = kind === 'uzun' ? sirali[0] : sirali[5], cel = sec3(dogru, []);
      ekle({ ...ortak, alt_konu: kind === 'uzun' ? 'En uzun' : 'En kısa', zorluk: 1, kok: `Look at the picture. Who is the ${kind === 'uzun' ? 'tallest' : 'shortest'}?`, dogru, celdirici: cel,
        gerekce: cel.map((a) => `${a}, ${kind === 'uzun' ? 'en uzun' : 'en kısa'} kişi değildir.`), ipucu: `Kişilerin ${kind === 'uzun' ? 'en yukarıya' : 'en aşağıya'} ulaşanını bul.`, cozum: [`${dogru} ${kind === 'uzun' ? 'en uzun' : 'en kısa'} kişidir.`], dogrulama });
    } else if (kind === 'daha_uzun' || kind === 'daha_kisa') {
      const X = kind === 'daha_uzun' ? sirali[1] : sirali[4], dogru = kind === 'daha_uzun' ? sirali[0] : sirali[5], cel = sec3(dogru, [X]);
      ekle({ ...ortak, alt_konu: kind === 'daha_uzun' ? 'Daha uzun' : 'Daha kısa', zorluk: 2, kok: `Look at the picture. Who is ${kind === 'daha_uzun' ? 'taller' : 'shorter'} than ${X}?`, dogru, celdirici: cel,
        gerekce: cel.map((a) => `${a}, ${X} kişisinden ${kind === 'daha_uzun' ? 'daha uzun' : 'daha kısa'} değildir.`), ipucu: `${X} kişisinin boyunu diğerleriyle karşılaştır.`,
        cozum: [`${X}, ${kind === 'daha_uzun' ? 'ikinci en uzun' : 'ikinci en kısa'} kişidir.`, `${kind === 'daha_uzun' ? 'Ondan daha uzun' : 'Ondan daha kısa'} yalnızca ${dogru} vardır.`], dogrulama });
    } else {
      const k = 1 + Math.floor(R() * 4), dogru = sirali[k], A = sirali[k - 1], B = sirali[k + 1], cel = sec3(dogru, [A, B]);
      ekle({ ...ortak, alt_konu: 'Boyca iki kişinin arasında', zorluk: 3, kok: `Look at the picture. Who is taller than ${B} but shorter than ${A}?`, dogru, celdirici: cel,
        gerekce: cel.map((a) => `${a}, ${B} ile ${A} arasındaki boyda değildir.`), ipucu: `${A} ve ${B} kişilerinin boyunu bul; aradaki boydakini seç.`,
        cozum: [`Boy sırası: ${sirali.join(' > ')}.`, `${B} ile ${A} arasında ${dogru} vardır.`], dogrulama });
    }
  }
  return { boySorusu };
}

export const KAYIT = [
  { id: 'eng7-boy-karsilastirma', ders: 'İngilizce', sinif: 7, idOnek: 'ENG7-BOY', mufredat_surum: MUFREDAT, kodlar: ['E7.1.R1'], fabrika: kur, uret: (f) => f.boySorusu() },
];
