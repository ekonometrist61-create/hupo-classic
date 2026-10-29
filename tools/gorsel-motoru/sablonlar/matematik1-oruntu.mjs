// 1. sınıf Matematik — şekil örüntüsünün devamını bulma (AB, AAB, ABB, ABC birimleri). Şıklar dört şeklin adıdır; şekilsiz çözülemez.
const MUFREDAT = 'TYMM 1-2 taslak 2026-27';
const AD = { daire: 'daire', kare: 'kare', ucgen: 'üçgen', dikdortgen: 'dikdörtgen' };
const BIRIMLER = [[0, 1], [0, 0, 1], [0, 1, 1], [0, 1, 2]];

export function kur({ R, sec, karistir, ekle }) {
  function oruntuSorusu() {
    const sek = karistir(['daire', 'kare', 'ucgen', 'dikdortgen']);
    const b = sec(BIRIMLER), birim = b.map((i) => sek[i]);
    const n = Math.min(7, b.length * 2 + (R() < 0.5 ? 0 : 1)), tam = Array.from({ length: n + 1 }, (_, i) => birim[i % birim.length]);
    const dizi = tam.slice(0, n), siradaki = tam[n];
    // Çeldirici sırası rastgele: sabit sıra olsaydı araya sokulan doğru şık "sıra dışı" kalarak ele verirdi.
    const cel = karistir(['daire', 'kare', 'ucgen', 'dikdortgen'].filter((x) => x !== siradaki));
    ekle({ kod: 'MAT.1.1.6', konu: 'Örüntüler', alt_konu: 'Şekil örüntüsünün devamı', zorluk: b.length === 2 ? 1 : 2,
      spec: { tip_id: 'oruntu-dizisi', parametreler: { dizi, siradaki } },
      dogru: AD[siradaki], celdirici: cel.map((x) => AD[x]),
      gerekce: cel.map((x) => `${AD[x]} örüntüdeki sıraya uymaz; örüntü ${b.length} şekilden oluşan bir grubun tekrarıdır ve sıradaki şekil ${AD[siradaki]}dir.`.replace('daire' + 'dir', 'dairedir').replace('kare' + 'dir', 'karedir')),
      kok: 'Yukarıdaki şekil örüntüsünde soru işareti olan yere hangi şekil gelmelidir?',
      ipucu: 'Şekillerin kaç tanesinin sürekli tekrar ettiğine bak.',
      cozum: [`Örüntü her ${b.length} şekilde bir kendini tekrar eder.`, `Soru işaretinden önceki şekillere bakıldığında sıradaki şekil ${AD[siradaki]} olur.`],
      dogrulama: [{ yol: ['siradaki'], beklenen: siradaki }, { yol: ['birim_uzunlugu'], beklenen: b.length }] });
  }
  return { oruntuSorusu };
}

export const KAYIT = [
  { id: 'mat1-sekil-oruntusu', ders: 'Matematik', sinif: 1, idOnek: 'MAT1-ORU', mufredat_surum: MUFREDAT, kodlar: ['MAT.1.1.6'], fabrika: kur, uret: (f) => f.oruntuSorusu() },
];
