// 7. sınıf Matematik — üçgende kenarortay, açıortay, yükseklik (MAT.7.5.1). Doğru parçasının türü yalnız şekildeki işaretlerden anlaşılır.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 7. sınıf; program: TYMM)';
const ADLAR = { kenarortay: 'Kenarortay', aciortay: 'Açıortay', yukseklik: 'Yükseklik', orta_dikme: 'Orta dikme' };
const HARFLER = [['A', 'B', 'C', 'D', 'E'], ['K', 'L', 'M', 'N', 'P'], ['P', 'R', 'S', 'T', 'U'], ['D', 'E', 'F', 'K', 'L'], ['M', 'N', 'K', 'L', 'R']];

export function kur({ R, sec, karistir, ekle, konum }) {
  function uret(tur) {
    const [A, B, C, D, E] = sec(HARFLER);
    let cesit = sec(['kenarortay', 'aciortay', 'yukseklik', 'orta_dikme']);
    if (tur === 'ifade' && cesit === 'orta_dikme') cesit = sec(['kenarortay', 'aciortay', 'yukseklik']);
    let t = 0.22 + R() * 0.56; if (cesit === 'orta_dikme' && Math.abs(t - 0.5) < 0.13) t = t < 0.5 ? 0.3 : 0.7;
    t = Math.round(t * 100) / 100;
    const yukseklik = 120 + Math.floor(R() * 40);
    const spec = { tip_id: 'a4-ucgen-cizgi', parametreler: { cesit, harf: { A, B, C, D, E }, t, yukseklik } };
    const ozel = cesit === 'orta_dikme' ? `[${D}${E}]` : `[${A}${D}]`;
    if (tur === 'ad') {
      const celdirici = karistir(['kenarortay', 'aciortay', 'yukseklik', 'orta_dikme'].filter((c) => c !== cesit)).map((c) => ADLAR[c]);
      const neden = {
        kenarortay: 'Kenarortay, köşeyi karşı kenarın orta noktasına birleştirir; şekilde kenarın iki parçasının eşit olduğunu gösteren işaretler vardır.',
        aciortay: 'Açıortay, köşedeki açıyı iki eş açıya ayırır; şekilde eşit açıları gösteren yaylar vardır.',
        yukseklik: 'Yükseklik, köşeden karşı kenara indirilen dik doğru parçasıdır; şekilde dik açı işareti vardır.',
        orta_dikme: 'Orta dikme, bir kenarın orta noktasından geçen ve kenara dik olan doğrudur; şekilde hem eşit parça hem dik açı işareti vardır ve doğru parçası köşeden çıkmaz.',
      };
      ekle({ kod: 'MAT.7.5.1', konu: 'Geometri', alt_konu: 'Üçgende özel doğru parçaları', zorluk: 1, spec,
        kok: `Aşağıdaki ${A}${B}${C} üçgeninde kalın çizilen ${ozel} doğru parçası, şekildeki işaretlere göre aşağıdakilerden hangisidir?`,
        dogru: ADLAR[cesit], celdirici,
        gerekce: celdirici.map((c) => `${c} için gerekli işaret şekilde yoktur. ` + neden[Object.keys(ADLAR).find((k) => ADLAR[k] === c)]),
        ipucu: 'Şekildeki işaretlere bak: eşit çizgiler, eşit yaylar ya da dik açı işareti var mı?',
        cozum: [neden[cesit], `Bu nedenle ${ozel} bir ${ADLAR[cesit].toLowerCase()}dir.`.replace('açıortaydır', 'açıortaydır')],
        dogrulama: [{ yol: ['cesit'], beklenen: cesit }] });
    } else {
      const ifadeler = {
        kenarortay: [`|${B}${D}| = |${D}${C}|`, 'bd_dc_esit'],
        aciortay: [`m(${B}${A}${D}) = m(${D}${A}${C})`, 'bad_dac_esit'],
        yukseklik: [`m(${A}${D}${B}) = 90°`, 'adb_dik'],
      };
      const ekstra = [`|${A}${B}| = |${A}${C}|`, `m(${A}${B}${C}) = m(${A}${C}${B})`, `|${A}${D}| = |${B}${D}|`, `m(${B}${A}${C}) = 90°`];
      const yanlis = Object.keys(ifadeler).filter((c) => c !== cesit).map((c) => ifadeler[c][0]);
      const bos = karistir(ekstra)[0];
      const celdirici = karistir([...yanlis, bos].slice(0, 3));
      ekle({ kod: 'MAT.7.5.1', konu: 'Geometri', alt_konu: 'Üçgende özel doğru parçaları', zorluk: 2, spec,
        kok: `Aşağıdaki ${A}${B}${C} üçgeninde kalın çizilen ${ozel} doğru parçasının işaretleri verilmiştir. Bu işaretlere göre aşağıdakilerden hangisi kesinlikle doğrudur?`,
        dogru: ifadeler[cesit][0], celdirici,
        gerekce: celdirici.map((c) => `${c} eşitliğini gösteren bir işaret şekilde yoktur; bu bilgi şekilden çıkarılamaz.`),
        ipucu: 'Şekilde hangi uzunlukların ya da açıların eşit olduğunu veya hangi açının dik olduğunu gösteren işaret var?',
        cozum: [`Şekildeki işaretler ${ADLAR[cesit].toLowerCase()} özelliğini gösterir.`, `Bu işaretlerden ${ifadeler[cesit][0]} sonucu çıkar.`],
        dogrulama: [{ yol: [ifadeler[cesit][1]], beklenen: true }] });
    }
  }
  return { ad: () => uret('ad'), ifade: () => uret('ifade') };
}
export const KAYIT = [
  { id: 'mat7-ucgen-cizgi', ders: 'Matematik', sinif: 7, idOnek: 'MAT7-UCG', mufredat_surum: MUFREDAT, kodlar: ['MAT.7.5.1'], fabrika: kur, uret: (f, g) => (g.R() < 0.6 ? f.ad() : f.ifade()) },
];
