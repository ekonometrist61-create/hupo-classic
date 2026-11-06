// 5. sınıf İngilizce — ders programı (timetable) okuma: ders, gün, saat. Şekil: b4-tablo.
import { GUNLER, GUN3, ERKEK, KADIN } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 5. sınıf; program: TYMM)';
const DERSLER = ['Maths', 'Science', 'English', 'Turkish', 'Art', 'Music', 'P.E.'];
const SAATLER = ['09:00', '10:00', '11:00', '13:00'];

export function kur({ R, sec, karistir, ekle }) {
  function programSorusu() {
    const perm = karistir(DERSLER), ad = sec([...ERKEK, ...KADIN]);
    const ders = (r, c) => perm[(c + 2 * r) % 7];
    const satirlar = SAATLER.map((s, r) => ({ ad: s, hucreler: GUN3.slice(0, 5).map((_, c) => ders(r, c)) }));
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: `${ad}'s timetable`, ilkSutun: 'Time', sutunlar: GUN3.slice(0, 5), satirlar } };
    const r = Math.floor(R() * 4), c = Math.floor(R() * 5), kind = sec(['ders', 'gun', 'sonra']);
    const ortak = { kod: 'ENG.5.2.R2', konu: 'Timetables', spec };
    const hucre = (rr, cc) => ({ yol: ['hucre', `${SAATLER[rr]}|${GUN3[cc]}`], beklenen: ders(rr, cc) });
    if (kind === 'ders') {
      const dogru = ders(r, c), cel = karistir(DERSLER.filter((d) => d !== dogru)).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Gün ve saatten dersi bulma', zorluk: 1, kok: `Look at the timetable. What lesson does ${ad} have on ${GUNLER[c]} at ${SAATLER[r]}?`, dogru, celdirici: cel,
        gerekce: cel.map((d) => `${d}, ${GUNLER[c]} günü saat ${SAATLER[r]} dersi değildir.`), ipucu: `${GUN3[c]} sütununu ve ${SAATLER[r]} satırını bul; kesiştikleri kutuya bak.`,
        cozum: [`${GUN3[c]} sütunu ile ${SAATLER[r]} satırı ${dogru} kutusunda kesişir.`], dogrulama: [hucre(r, c)] });
    } else if (kind === 'gun') {
      const dogru = GUNLER[c], cel = karistir(GUNLER.slice(0, 5).filter((g) => g !== dogru)).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Dersten günü bulma', zorluk: 2, kok: `Look at the timetable. On which day does ${ad} have ${ders(r, c)} at ${SAATLER[r]}?`, dogru, celdirici: cel,
        gerekce: cel.map((g) => `${g} günü saat ${SAATLER[r]} dersi ${ders(r, GUNLER.indexOf(g))}; ${ders(r, c)} değildir.`), ipucu: `${SAATLER[r]} satırında ${ders(r, c)} yazan kutuyu bul, sütun başlığını oku.`,
        cozum: [`${SAATLER[r]} satırında ${ders(r, c)} ${GUN3[c]} sütunundadır.`, `Cevap ${dogru}.`], dogrulama: [hucre(r, c)] });
    } else {
      const rr = Math.min(r, 2), dogru = ders(rr + 1, c), cel = karistir(DERSLER.filter((d) => d !== dogru)).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Sıradaki dersi bulma', zorluk: 3, kok: `Look at the timetable. What lesson does ${ad} have after ${ders(rr, c)} on ${GUNLER[c]}?`, dogru, celdirici: cel,
        gerekce: cel.map((d) => `${d}, ${GUNLER[c]} günü ${ders(rr, c)} dersinden hemen sonra gelen ders değildir.`), ipucu: `${GUN3[c]} sütununda ${ders(rr, c)} yazan kutunun hemen altına bak.`,
        cozum: [`${GUN3[c]} sütununda ${ders(rr, c)} dersinin altındaki kutu ${dogru} yazar.`], dogrulama: [hucre(rr, c), hucre(rr + 1, c)] });
    }
  }
  return { programSorusu };
}

export const KAYIT = [
  { id: 'eng5-ders-programi', ders: 'İngilizce', sinif: 5, idOnek: 'ENG5-PRG', mufredat_surum: MUFREDAT, kodlar: ['ENG.5.2.R2'], fabrika: kur, uret: (f) => f.programSorusu() },
];
