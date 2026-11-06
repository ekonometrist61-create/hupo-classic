// 3. sınıf İngilizce — aylar, doğum günü tarihleri ve gün adları (takvim sayfası). Şekil: b4-takvim.
import { GUNLER, AYLAR, AY_GUN, ERKEK, KADIN, sirayaRakam } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 3. sınıf; program: TYMM)';

export function kur({ R, sec, karistir, ekle }) {
  function takvimSorusu() {
    const ay = Math.floor(R() * 12), n = AY_GUN[ay], basla = Math.floor(R() * 7), tur = sec(['dogum', 'gun', 'yarin']);
    const d = 2 + Math.floor(R() * (n - 3)), kadin = R() < 0.5, ad = sec(kadin ? KADIN : ERKEK), iyelik = kadin ? 'her' : 'his';
    const spec = { tip_id: 'b4-takvim', parametreler: { basla, gun_sayisi: n, baslik: AYLAR[ay], isaret: [d] } };
    const gunAdi = (x) => GUNLER[(basla + x - 1) % 7];
    const ortak = { kod: 'ENG.3.1.V1', konu: 'Months of the year', spec };
    if (tur === 'gun') {
      const dogru = gunAdi(d), cel = karistir(GUNLER.filter((g) => g !== dogru)).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Takvimde gün adını bulma', zorluk: 1, kok: `Look at the calendar. ${ad}'s birthday party is on the circled day. What day is the party?`, dogru, celdirici: cel,
        gerekce: cel.map((g) => `${g}, daire içindeki tarihin sütun başlığı değildir.`),
        ipucu: 'Daire içindeki sayının üstündeki gün adına bak.', cozum: [`Daire içindeki ${d} sayısı ${dogru} sütunundadır.`],
        dogrulama: [{ yol: ['haftaninGunu', String(d)], beklenen: dogru }] });
      return;
    }
    const t = tur === 'yarin' ? d + 1 : d;
    const dogru = `${AYLAR[ay]} ${sirayaRakam(t)}`;
    const aylar = karistir([...Array(12).keys()].filter((x) => x !== ay)).slice(0, 3), cel = [];
    const kullan = new Set([t]);
    for (const m of aylar) {
      let g, tr = 0; do { g = 1 + Math.floor(R() * Math.min(AY_GUN[m], 28)); tr++; } while (kullan.has(g) && tr < 50);
      kullan.add(g); cel.push(`${AYLAR[m]} ${sirayaRakam(g)}`);
    }
    const kok = tur === 'dogum'
      ? `Look at the calendar. ${ad}'s birthday is on the circled day. When is ${iyelik} birthday?`
      : `Look at the calendar. Today is the circled day. ${ad}'s birthday is tomorrow. When is ${iyelik} birthday?`;
    ekle({ ...ortak, alt_konu: 'Ay ve tarih okuma (doğum günü)', zorluk: tur === 'dogum' ? 2 : 3, kok, dogru, celdirici: cel,
      gerekce: cel.map((c) => `${c}, takvimin başlığındaki ay (${AYLAR[ay]}) ya da işaretli tarih ile uyuşmaz.`),
      ipucu: 'Önce takvimin başlığındaki ayı oku, sonra daire içindeki sayıya bak.',
      cozum: tur === 'dogum' ? [`Takvim ${AYLAR[ay]} ayını gösterir; daire içindeki gün ${d}.`, `Doğum günü ${dogru}.`] : [`Bugün ${AYLAR[ay]} ${d}; yarın ${dogru}.`],
      dogrulama: [{ yol: ['ay'], beklenen: AYLAR[ay] }, { yol: ['isaretli'], beklenen: [d] }, { yol: ['gunSayisi'], beklenen: n }] });
  }
  return { takvimSorusu };
}

export const KAYIT = [
  { id: 'eng3-takvim', ders: 'İngilizce', sinif: 3, idOnek: 'ENG3-TAK', mufredat_surum: MUFREDAT, kodlar: ['ENG.3.1.V1'], fabrika: kur, uret: (f) => f.takvimSorusu() },
];
