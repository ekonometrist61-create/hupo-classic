// 6. sınıf İngilizce — etkinlik (festival) programını okuma: gün, saat, etkinlik. Şekil: b4-tablo.
import { GUNLER } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 6. sınıf; program: TYMM)';
const ETKINLIK = ['Concert', 'Dance show', 'Art fair', 'Film night', 'Magic show', 'Race day', 'Music party'];
const SAATLER = ['10:00', '11:30', '13:00', '14:30', '15:30', '16:00', '17:30', '18:00', '19:30'];
const GUN = GUNLER.slice(3);

export function kur({ R, sec, karistir, ekle }) {
  function etkinlikSorusu() {
    const e = karistir(ETKINLIK).slice(0, 5), t = karistir(SAATLER).slice(0, 5), g = e.map(() => sec(GUN));
    const satirlar = e.map((a, i) => ({ ad: a, hucreler: [g[i], t[i]] }));
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: 'Festival programme', ilkSutun: 'Event', sutunlar: ['Day', 'Time'], satirlar } };
    const ortak = { kod: 'ENG.6.5.R2', konu: 'Festivals and events', spec };
    const i = Math.floor(R() * 5), kind = sec(['saat', 'gun', 'hangi', 'gunsaat']), diger = karistir(e.map((_, j) => j).filter((j) => j !== i)).slice(0, 3);
    const dgr = (j) => [{ yol: ['hucre', `${e[j]}|Day`], beklenen: g[j] }, { yol: ['hucre', `${e[j]}|Time`], beklenen: t[j] }];
    const dogrulama = e.flatMap((_, j) => dgr(j));
    if (kind === 'saat') {
      ekle({ ...ortak, alt_konu: 'Etkinlik saatini bulma', zorluk: 1, kok: `Look at the programme. What time does the ${e[i].toLowerCase()} start?`, dogru: `It starts at ${t[i]}.`, celdirici: diger.map((j) => `It starts at ${t[j]}.`),
        gerekce: diger.map((j) => `${t[j]}, ${e[j]} etkinliğinin saatidir.`), ipucu: `${e[i]} satırını bul ve Time sütununa bak.`, cozum: [`${e[i]} satırında saat ${t[i]} yazar.`], dogrulama });
    } else if (kind === 'gun') {
      const dogru = `On ${g[i]}.`, cel = GUN.filter((x) => x !== g[i]).map((x) => `On ${x}.`);
      ekle({ ...ortak, alt_konu: 'Etkinlik gününü bulma', zorluk: 1, kok: `Look at the programme. On which day is the ${e[i].toLowerCase()}?`, dogru, celdirici: cel,
        gerekce: GUN.filter((x) => x !== g[i]).map((x) => `${x} günü ${e[i]} etkinliğinin günü değildir.`), ipucu: `${e[i]} satırını bul ve Day sütununa bak.`, cozum: [`${e[i]} satırında gün ${g[i]} yazar.`], dogrulama });
    } else if (kind === 'hangi') {
      ekle({ ...ortak, alt_konu: 'Saatten etkinliği bulma', zorluk: 2, kok: `Look at the programme. Which event starts at ${t[i]}?`, dogru: `The ${e[i].toLowerCase()}.`, celdirici: diger.map((j) => `The ${e[j].toLowerCase()}.`),
        gerekce: diger.map((j) => `${e[j]} etkinliği ${t[j]} saatinde başlar.`), ipucu: `Time sütununda ${t[i]} yazan satırı bul.`, cozum: [`${t[i]} saati ${e[i]} satırındadır.`], dogrulama });
    } else {
      ekle({ ...ortak, alt_konu: 'Gün ve saatten etkinliği bulma', zorluk: 3, kok: `Look at the programme. What is on ${g[i]} at ${t[i]}?`, dogru: `The ${e[i].toLowerCase()}.`, celdirici: diger.map((j) => `The ${e[j].toLowerCase()}.`),
        gerekce: diger.map((j) => `${e[j]} etkinliği ${g[j]} günü ${t[j]} saatindedir.`), ipucu: `Hem Day hem Time sütunu uyan satırı bul.`, cozum: [`${g[i]} ve ${t[i]} birlikte ${e[i]} satırında yazar.`], dogrulama });
    }
  }
  return { etkinlikSorusu };
}

export const KAYIT = [
  { id: 'eng6-etkinlik-programi', ders: 'İngilizce', sinif: 6, idOnek: 'ENG6-ETK', mufredat_surum: MUFREDAT, kodlar: ['ENG.6.5.R2'], fabrika: kur, uret: (f) => f.etkinlikSorusu() },
];
