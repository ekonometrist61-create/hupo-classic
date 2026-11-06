// 8. sınıf İngilizce (önceki program) — turizm: tur programı (saat, fiyat) tablosundan bilgi bulma. Şekil: b4-tablo.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 8. sınıf; program: önceki program)';
const TURLAR = ['Castle tour', 'Boat trip', 'Museum visit', 'Cave walk', 'Market tour', 'Bike tour', 'Zoo trip'];
const SAATLER = ['09:00', '09:30', '10:30', '11:00', '13:00', '14:30', '16:00'];

export function kur({ R, sec, karistir, ekle }) {
  function turSorusu() {
    const t = karistir(TURLAR).slice(0, 5), s = karistir(SAATLER).slice(0, 5), f = karistir(Array.from({ length: 19 }, (_, i) => 80 + i * 10)).slice(0, 5);
    const satirlar = t.map((a, i) => ({ ad: a, hucreler: [s[i], `${f[i]} TL`] }));
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: 'City tours', ilkSutun: 'Tour', sutunlar: ['Time', 'Price'], satirlar } };
    const ortak = { kod: 'E8.7.R1', konu: 'Tourism: tour programmes', spec };
    const dogrulama = t.flatMap((a, j) => [{ yol: ['hucre', `${a}|Time`], beklenen: s[j] }, { yol: ['hucre', `${a}|Price`], beklenen: `${f[j]} TL` }]);
    const i = Math.floor(R() * 5), diger = karistir([0, 1, 2, 3, 4].filter((j) => j !== i)).slice(0, 3), kind = sec(['saat', 'fiyat', 'hangi_saat', 'ucuz', 'erken']);
    const al = (x) => x.toLowerCase();
    if (kind === 'saat') ekle({ ...ortak, alt_konu: 'Saat bilgisi', zorluk: 1, kok: `Look at the tour programme. What time does the ${al(t[i])} start?`, dogru: `It starts at ${s[i]}.`, celdirici: diger.map((j) => `It starts at ${s[j]}.`),
      gerekce: diger.map((j) => `${s[j]}, ${t[j]} turunun saatidir.`), ipucu: `${t[i]} satırını bul, Time sütununa bak.`, cozum: [`${t[i]} satırında saat ${s[i]}.`], dogrulama });
    else if (kind === 'fiyat') ekle({ ...ortak, alt_konu: 'Fiyat bilgisi', zorluk: 1, kok: `Look at the tour programme. How much is the ${al(t[i])}?`, dogru: `It costs ${f[i]} TL.`, celdirici: diger.map((j) => `It costs ${f[j]} TL.`),
      gerekce: diger.map((j) => `${f[j]} TL, ${t[j]} turunun fiyatıdır.`), ipucu: `${t[i]} satırını bul, Price sütununa bak.`, cozum: [`${t[i]} satırında fiyat ${f[i]} TL.`], dogrulama });
    else if (kind === 'hangi_saat') ekle({ ...ortak, alt_konu: 'Saatten turu bulma', zorluk: 2, kok: `Look at the tour programme. Which one starts at ${s[i]}?`, dogru: `The ${al(t[i])}.`, celdirici: diger.map((j) => `The ${al(t[j])}.`),
      gerekce: diger.map((j) => `${t[j]} turu ${s[j]} saatinde başlar.`), ipucu: `Time sütununda ${s[i]} yazan satırı bul.`, cozum: [`${s[i]} saati ${t[i]} satırındadır.`], dogrulama });
    else {
      const sirali = [0, 1, 2, 3, 4].sort((a, b) => (kind === 'ucuz' ? f[a] - f[b] : s[a].localeCompare(s[b]))), H = sirali[0], c3 = karistir([0, 1, 2, 3, 4].filter((j) => j !== H)).slice(0, 3);
      ekle({ ...ortak, alt_konu: kind === 'ucuz' ? 'En ucuz tur' : 'En erken tur', zorluk: 2, kok: kind === 'ucuz' ? 'Look at the tour programme. Which one is the cheapest?' : 'Look at the tour programme. Which one starts the earliest?', dogru: `The ${al(t[H])}.`, celdirici: c3.map((j) => `The ${al(t[j])}.`),
        gerekce: c3.map((j) => (kind === 'ucuz' ? `${t[j]} ${f[j]} TL; en ucuz ${t[H]} (${f[H]} TL).` : `${t[j]} ${s[j]}'de başlar; en erken ${t[H]} (${s[H]}).`)), ipucu: kind === 'ucuz' ? 'Price sütunundaki en küçük sayıyı bul.' : 'Time sütunundaki en erken saati bul.',
        cozum: [kind === 'ucuz' ? `En küçük fiyat ${f[H]} TL: ${t[H]}.` : `En erken saat ${s[H]}: ${t[H]}.`], dogrulama });
    }
  }
  return { turSorusu };
}

export const KAYIT = [
  { id: 'eng8-tur-programi', ders: 'İngilizce', sinif: 8, idOnek: 'ENG8-TUR', mufredat_surum: MUFREDAT, kodlar: ['E8.7.R1'], fabrika: kur, uret: (f) => f.turSorusu() },
];
