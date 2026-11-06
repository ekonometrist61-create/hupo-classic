// 6. sınıf İngilizce — dış görünüş betimleme (saç, aksesuar). Şekil: b4-yuz.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 6. sınıf; program: TYMM)';
const ADLAR = ['Sam', 'Alex', 'Robin', 'Charlie', 'Jamie', 'Taylor'];
const SAC = ['#5B3A1F', '#1F2937', '#8A4B16', '#B5651D'];
const GOMLEK = ['#6AA7D9', '#8CCB97', '#F4B6C2', '#F5C542'];

export function kur({ R, sec, karistir, ekle }) {
  function yuzSorusu() {
    // Üç ikili özellik: uzunluk, doku, aksesuar. Çeldiriciler doğrudan 2 özellikte farklıdır (dört şık karşılıklı eşit uzaklıkta).
    const [u, d, a] = [R() < 0.5, R() < 0.5, R() < 0.5]; // uzun, kıvırcık, gözlük
    const metin = (uu, dd, aa) => `${uu ? 'long' : 'short'} ${dd ? 'curly' : 'straight'} hair and ${aa ? 'wears glasses' : 'wears a scarf'}`;
    const ad = sec(ADLAR);
    const secenekler = [[u, d, a], [!u, !d, a], [!u, d, !a], [u, !d, !a]];
    const dogru = `${ad} has ${metin(u, d, a)}.`, cel = secenekler.slice(1).map(([x, y, z]) => `${ad} has ${metin(x, y, z)}.`);
    const ozellik = (x, y, z) => `${x ? 'uzun' : 'kısa'}, ${y ? 'kıvırcık' : 'düz'} saç, ${z ? 'gözlük' : 'atkı'}`;
    ekle({ kod: 'ENG.6.3.V1', konu: 'Physical appearance', alt_konu: 'Görünüşü betimleme', zorluk: 2,
      spec: { tip_id: 'b4-yuz', parametreler: { uzun: u, kivircik: d, aksesuar: a ? 'gozluk' : 'atki', sacRenk: sec(SAC), gomlek: sec(GOMLEK) } },
      kok: `Look at the picture of ${ad}. Which sentence is true about ${ad}?`, dogru, celdirici: cel.map((c) => c),
      gerekce: secenekler.slice(1).map(([x, y, z]) => `Bu cümle ${ozellik(x, y, z)} anlatır; resimde ${ozellik(u, d, a)} vardır.`),
      ipucu: 'Saçın uzunluğuna, saçın kıvırcık ya da düz olmasına ve gözlük/atkıya ayrı ayrı bak.',
      cozum: [`Resimde: ${ozellik(u, d, a)}.`, dogru],
      dogrulama: [{ yol: ['sac'], beklenen: `${u ? 'long' : 'short'} ${d ? 'curly' : 'straight'}` }, { yol: ['aksesuar'], beklenen: a ? 'glasses' : 'scarf' }] });
  }
  return { yuzSorusu };
}

export const KAYIT = [
  { id: 'eng6-yuz-betimleme', ders: 'İngilizce', sinif: 6, idOnek: 'ENG6-YUZ', mufredat_surum: MUFREDAT, kodlar: ['ENG.6.3.V1'], fabrika: kur, uret: (f) => f.yuzSorusu() },
];
