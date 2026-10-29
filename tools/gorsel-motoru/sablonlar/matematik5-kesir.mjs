// 5. sınıf Matematik — kesir modelleri (şerit, pasta). Çeldiriciler yaygın yanılgılardır; her biri başka bir (pay, payda) çiftine karşılık gelir.
const MUFREDAT = 'Maarif Modeli Ortaokul Matematik DÖP (5-8)';

export function kur({ R, sec, ekle }) {
  function kesirSorusu(taraliOlmayan) {
    const payda = sec([4, 5, 6, 8, 10, 12]), pay = 1 + Math.floor(R() * (payda - 1)), tur = sec(['serit', 'pasta']);
    if (pay * 2 === payda) throw new Error('yarim_kesir');
    const t = `${pay}/${payda}`, o = `${payda - pay}/${payda}`;
    const dogru = taraliOlmayan ? o : t;
    // Şıkların hepsi aynı paydalıdır: doğru, tümleyeni ve her ikisinin bir parça fazla/eksik sayılmış hâli.
    // (Farklı paydalı çeldirici olsaydı şekilsiz bile elenebilirdi; doğru ile tümleyen de simetrik durur.)
    const asil = taraliOlmayan ? payda - pay : pay, tum = payda - asil;
    const komsu = (v) => { const ad = [v - 1, v + 1].filter((x) => x >= 1 && x <= payda - 1 && x !== asil && x !== tum); if (!ad.length) throw new Error('komsu_yok'); return ad[Math.floor(R() * ad.length)]; };
    const kA = komsu(asil), kT = komsu(tum);
    if (new Set([asil, tum, kA, kT]).size < 4) throw new Error('kesir_tekrar');
    const cel = [`${tum}/${payda}`, `${kA}/${payda}`, `${kT}/${payda}`];
    const gerekce = [
      taraliOlmayan ? 'Taralı kısmı yazma; istenen taralı olmayan kısımdır.' : 'Taralı olmayan kısmı yazma; istenen taralı kısımdır.',
      `${kA}/${payda}, istenen parça sayısı bir ${kA > asil ? 'fazla' : 'eksik'} sayılarak bulunur.`,
      `${kT}/${payda}, ${taraliOlmayan ? 'taralı' : 'taralı olmayan'} parça sayısı bir ${kT > tum ? 'fazla' : 'eksik'} sayılarak bulunur.`,
    ];
    ekle({ kod: 'MAT.5.1.3', konu: 'Kesirler', alt_konu: 'Kesri modelle gösterme', zorluk: taraliOlmayan ? 2 : 1,
      spec: { tip_id: 'kesir-modeli', parametreler: { tur, payda, pay } }, dogru, celdirici: cel, gerekce,
      kok: taraliOlmayan ? 'Yukarıdaki modelde taralı olmayan bölge hangi kesirle gösterilir?' : 'Yukarıdaki modelde taralı bölge hangi kesirle gösterilir?',
      ipucu: 'Önce bütünün kaç eş parçaya bölündüğünü, sonra istenen kısmın kaç parça olduğunu say.',
      cozum: [`Bütün ${payda} eş parçaya bölünmüştür.`, taraliOlmayan ? `Taralı olmayan parça sayısı ${payda - pay}’dir.` : `Taralı parça sayısı ${pay}’dir.`, `Kesir ${dogru} olur.`],
      dogrulama: [{ yol: [taraliOlmayan ? 'tarali_olmayan' : 'tarali'], beklenen: dogru }] });
  }
  return { kesirSorusu };
}

export const KAYIT = [
  { id: 'mat5-kesir-tarali', ders: 'Matematik', sinif: 5, idOnek: 'MAT5-KSR', mufredat_surum: MUFREDAT, kodlar: ['MAT.5.1.3'], fabrika: kur, uret: (f, g) => f.kesirSorusu(g.R() < 0.4) },
];
