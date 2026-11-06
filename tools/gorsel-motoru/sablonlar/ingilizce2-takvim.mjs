// 2. sınıf İngilizce — takvimde haftanın günleri (bugün / yarın / dün). Şekil: b4-takvim (aydan bağımsız sayfa).
import { GUNLER } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 2. sınıf; program: TYMM)';

export function kur({ R, sec, karistir, ekle }) {
  function takvimSorusu() {
    const basla = Math.floor(R() * 7), n = sec([28, 29, 30, 31]), tur = sec(['bugun', 'yarin', 'dun']);
    const d = 2 + Math.floor(R() * (n - 3)); // 2..n-1
    const hedef = tur === 'bugun' ? d : tur === 'yarin' ? d + 1 : d - 1;
    const gunAdi = (x) => GUNLER[(basla + x - 1) % 7];
    const dogru = gunAdi(hedef), cel = karistir(GUNLER.filter((g) => g !== dogru)).slice(0, 3);
    const kok = { bugun: 'What day is it today?', yarin: 'What day is tomorrow?', dun: 'What day was yesterday?' }[tur];
    ekle({
      kod: 'ENG.2.1.V1', konu: 'Days of the week', alt_konu: 'Takvimde günü bulma', zorluk: tur === 'bugun' ? 1 : 2,
      spec: { tip_id: 'b4-takvim', parametreler: { basla, gun_sayisi: n, isaret: [d] } },
      kok: `Look at the calendar. Today is the circled day. ${kok}`, dogru, celdirici: cel,
      gerekce: cel.map((g) => `${g}, bu tarihin üstündeki gün adı değildir; sütun başlığı ${dogru} olmalıdır.`),
      ipucu: 'Önce daire içindeki sayının hangi gün sütununda olduğunu bul.',
      cozum: [`Daire içindeki ${d} sayısı ${gunAdi(d)} sütunundadır.`, tur === 'bugun' ? `Bugün ${dogru}.` : tur === 'yarin' ? `Yarın bir sonraki gündür: ${dogru}.` : `Dün bir önceki gündü: ${dogru}.`],
      dogrulama: [{ yol: ['haftaninGunu', String(hedef)], beklenen: dogru }, { yol: ['haftaninGunu', String(d)], beklenen: gunAdi(d) }],
    });
  }
  return { takvimSorusu };
}

export const KAYIT = [
  { id: 'eng2-takvim', ders: 'İngilizce', sinif: 2, idOnek: 'ENG2-TAK', mufredat_surum: MUFREDAT, kodlar: ['ENG.2.1.V1'], fabrika: kur, uret: (f) => f.takvimSorusu() },
];
