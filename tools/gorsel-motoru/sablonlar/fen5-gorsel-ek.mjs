// 5. sınıf Fen Bilimleri — Işık: tam gölgeyi etkileyen değişken (FB.5.4.3). Şekil: a5-golge (4 düzenek).
// Kaynak–perde uzaklığı ve cisim boyu hepsinde aynı; yalnız cismin kaynağa uzaklığı farklı. Cevap şekilden okunur.
const MUFREDAT = 'Maarif Modeli Fen DÖP (tymm 2026-09-02)';
const HARF = ['K', 'L', 'M', 'N'];

export function kur({ R, sec, karistir, ekle, konum }) {
  function golgeSorusu() {
    const k = konum(), buyuk = R() < 0.5;
    const D = sec([110, 120]), h = sec([20, 24, 28, 30]);
    const havuz = []; for (let d = 40; d <= D - 20; d += 10) havuz.push(d);
    // 4 uzaklık; ardışık iki uzaklık en az %25 farklı (gölge boyları net ayrışsın)
    let dler = null;
    for (let t = 0; t < 500 && !dler; t++) {
      const s = karistir(havuz).slice(0, 4).sort((a, b) => a - b);
      if (s.every((d, i) => i === 0 || d / s[i - 1] >= 1.25)) dler = s;
    }
    if (!dler) throw new Error('fen5-golge: uygun uzaklık seti bulunamadı');
    const hedef = buyuk ? dler[0] : dler[3];                                  // en büyük gölge: kaynağa en yakın
    const dig = karistir(dler.filter((d) => d !== hedef));
    const sira = [...dig]; sira.splice(k, 0, hedef);
    const paneller = sira.map((d, i) => ({ ad: HARF[i], d }));
    const gol = (d) => (h * D) / d;
    ekle({ kod: 'FB.5.4.3', konu: 'Işığın Yayılması', alt_konu: 'Gölgenin büyüklüğünü etkileyen değişken', zorluk: 2,
      spec: { tip_id: 'a5-golge', parametreler: { h, D, paneller } }, sirali: HARF, dogru: HARF[k],
      kok: sec([
        `Şekilde, ışık kaynağı, cisim ve perdeden oluşan dört ayrı düzenek gösterilmiştir. Hepsinde kaynakla perde arasındaki uzaklık ve cisimlerin boyu aynıdır. Hangi düzenekte perdede oluşan gölge ${buyuk ? 'en büyüktür' : 'en küçüktür'}?`,
        `Aynı boydaki dört cisim, aynı ışık kaynağı ile perde arasına şekildeki gibi yerleştirilmiştir. Perdede oluşan gölgesi ${buyuk ? 'en büyük' : 'en küçük'} olan düzenek hangisidir?`]),
      gerekce: HARF.map((h2, i) => (i === k ? '' : `${h2} düzeneğinde cisim ışık kaynağına, doğru şıktaki düzeneğe göre ${buyuk ? 'daha uzaktır' : 'daha yakındır'}; bu yüzden gölgesi ${buyuk ? 'daha küçük' : 'daha büyük'} olur.`)),
      ipucu: 'Işık doğrusal yayılır. Cisim kaynağa yaklaştıkça perdeye düşen gölge nasıl değişir?',
      cozum: ['Işık doğrusal yolla yayıldığından cisim kaynağa yaklaştıkça gölge büyür, uzaklaştıkça küçülür.',
        `Cismin ışık kaynağına ${buyuk ? 'en yakın' : 'en uzak'} olduğu düzenek ${HARF[k]} düzeneğidir; gölge ${buyuk ? 'en büyük' : 'en küçük'} bu düzenekte oluşur.`],
      dogrulama: [{ yol: [buyuk ? 'en_buyuk' : 'en_kucuk'], beklenen: HARF[k] }, ...HARF.map((x, i) => ({ yol: ['golge', x], beklenen: Math.round(gol(sira[i]) * 10) / 10 }))] });
  }
  return { golgeSorusu };
}

export const KAYIT = [
  { id: 'fen5-golge-uzaklik', ders: 'Fen Bilimleri', sinif: 5, idOnek: 'FEN5-GOL', mufredat_surum: MUFREDAT, kodlar: ['FB.5.4.3'], fabrika: kur,
    uret: (f) => f.golgeSorusu() },
];
