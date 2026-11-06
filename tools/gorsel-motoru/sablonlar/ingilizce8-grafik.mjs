// 8. sınıf İngilizce (önceki program) — internet alışkanlıkları sütun grafiğini okuma. Şekil: b4-grafik.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 8. sınıf; program: önceki program)';
const KONULAR = [
  { baslik: 'Hours a week on the Internet', ad: ['Games', 'Videos', 'Music', 'Chat', 'Homework', 'News', 'Email', 'Shopping', 'Reading'], birim: 'hours' },
  { baslik: 'Hours a week online (age 14)', ad: ['Games', 'Videos', 'Music', 'Chat', 'Homework', 'News', 'Email', 'Shopping', 'Reading'], birim: 'hours' },
  { baslik: 'Minutes a day on the Internet', ad: ['Games', 'Videos', 'Music', 'Chat', 'Homework', 'News', 'Email', 'Shopping', 'Reading'], birim: 'minutes', carpan: 10 },
];

export function kur({ R, sec, karistir, ekle }) {
  function grafikSorusu() {
    const K = sec(KONULAR), n = 5, c = K.carpan ?? 1, ad = karistir(K.ad).slice(0, n);
    const deg = karistir([2, 4, 6, 8, 10, 12, 14, 16, 18]).slice(0, n).map((v) => v * c);
    const kat = ad.map((a, i) => ({ ad: a, deger: deg[i] }));
    const max = 20 * c, adim = 2 * c;
    const spec = { tip_id: 'b4-grafik', parametreler: { baslik: K.baslik, kategoriler: kat, max, adim } };
    const ortak = { kod: 'E8.5.R2', konu: 'The Internet: habits', spec };
    const dogrulama = kat.map((k) => ({ yol: ['deger', k.ad], beklenen: k.deger }));
    const i = Math.floor(R() * n), X = kat[i], diger = kat.filter((k) => k !== X), cel = () => karistir(diger).slice(0, 3);
    const kind = sec(['en_cok', 'en_az', 'deger', 'hangi']);
    if (kind === 'en_cok' || kind === 'en_az') {
      const sirali = [...kat].sort((a, b) => b.deger - a.deger), H = kind === 'en_cok' ? sirali[0] : sirali[n - 1], c3 = karistir(kat.filter((k) => k !== H)).slice(0, 3);
      ekle({ ...ortak, alt_konu: kind === 'en_cok' ? 'En çok zaman' : 'En az zaman', zorluk: 1, kok: `Look at the graph. Which activity do students spend the ${kind === 'en_cok' ? 'most' : 'least'} time on?`, dogru: H.ad, celdirici: c3.map((k) => k.ad),
        gerekce: c3.map((k) => `${k.ad} sütunu ${k.deger} ${K.birim}; ${kind === 'en_cok' ? 'en yüksek' : 'en alçak'} sütun ${H.ad} (${H.deger}).`), ipucu: `${kind === 'en_cok' ? 'En yüksek' : 'En alçak'} sütunu bul.`, cozum: [`${H.ad} sütunu ${H.deger} ${K.birim} ile ${kind === 'en_cok' ? 'en yüksek' : 'en alçak'}.`], dogrulama });
    } else if (kind === 'deger') {
      const c3 = cel();
      ekle({ ...ortak, alt_konu: 'Değer okuma', zorluk: 2, kok: `Look at the graph. How many ${K.birim} ${K.birim === 'hours' ? 'a week' : 'a day'} do students spend on ${X.ad.toLowerCase()}?`, dogru: `${X.deger} ${K.birim}.`, celdirici: c3.map((k) => `${k.deger} ${K.birim}.`),
        gerekce: c3.map((k) => `${k.deger}, ${k.ad} sütununun değeridir; ${X.ad} sütunu ${X.deger}.`), ipucu: `${X.ad} sütununun üst ucunun hangi çizgiye geldiğine bak.`, cozum: [`${X.ad} sütununun yüksekliği dikey eksende ${X.deger} değerindedir.`], dogrulama });
    } else {
      const c3 = cel();
      ekle({ ...ortak, alt_konu: 'Değerden etkinliği bulma', zorluk: 2, kok: `Look at the graph. Which activity takes ${X.deger} ${K.birim} ${K.birim === 'hours' ? 'a week' : 'a day'}?`, dogru: X.ad, celdirici: c3.map((k) => k.ad),
        gerekce: c3.map((k) => `${k.ad} sütunu ${k.deger} ${K.birim}; sorulan değer ${X.deger}.`), ipucu: `Dikey eksende ${X.deger} değerine gelen sütunu bul.`, cozum: [`${X.deger} çizgisine ulaşan sütun ${X.ad} sütunudur.`], dogrulama });
    }
  }
  return { grafikSorusu };
}

export const KAYIT = [
  { id: 'eng8-internet-grafigi', ders: 'İngilizce', sinif: 8, idOnek: 'ENG8-GRF', mufredat_surum: MUFREDAT, kodlar: ['E8.5.R2'], fabrika: kur, uret: (f) => f.grafikSorusu() },
];
