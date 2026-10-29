// Kör çözüm karşılaştırması ve karar kuralı (plan §11.5 G9).
// Görselli çözüm (Haiku şekle bakarak) anahtarla ≥ %95 uyuşmalı: şekil okunabiliyor demektir.
// Görselsiz çözüm (yalnız metin) ≤ %40 kalmalı: görsel gerçekten gerekli demektir (şans ≈ %25).
// Karar yalnız n ≥ n_min soruda tanıdır; daha küçük örnek ön bilgidir (ON_GECTI / ON_GECMEDI).
export const ESIK = { gorselli: 0.95, gorselsiz: 0.4, n_min: 40 };

const yuvarla = (x) => Math.round(x * 1000) / 1000;

// sorular: üretilmiş kayıtlar (dogru_sik içerir). Cevaplar: [{id, cevap, belirsiz?}].
// Eksik cevap yanlış sayılır. Belirsiz görselli cevap doğru olsa bile doğrulanmış sayılmaz.
export function korKarsilastir(sorular, gorselliCevap, gorselsizCevap) {
  const g = new Map(gorselliCevap.map((x) => [x.id, x]));
  const z = new Map(gorselsizCevap.map((x) => [x.id, x]));
  const n = sorular.length;
  const gSorunlu = [], zCozulen = [];
  let gUyum = 0, gEksik = 0, zUyum = 0, zEksik = 0;
  for (const s of sorular) {
    const gv = g.get(s.id);
    if (!gv) { gEksik++; gSorunlu.push(`${s.id}: cevap yok`); }
    else if (gv.belirsiz) gSorunlu.push(`${s.id}: belirsiz (şekil okunamadı ya da iki cevap mümkün)`);
    else if (gv.cevap === s.dogru_sik) gUyum++;
    else gSorunlu.push(`${s.id}: ${gv.cevap} işaretlendi, anahtar ${s.dogru_sik}`);
    const zv = z.get(s.id);
    if (!zv) zEksik++;
    else if (zv.cevap === s.dogru_sik) { zUyum++; zCozulen.push(s.id); }
  }
  const gOran = n ? gUyum / n : 0, zOran = n ? zUyum / n : 0;
  const gecti = gOran >= ESIK.gorselli && zOran <= ESIK.gorselsiz;
  const n_yeterli = n >= ESIK.n_min;
  const karar = n_yeterli ? (gecti ? 'KOR_GECTI' : 'KOR_GECMEDI') : (gecti ? 'ON_GECTI' : 'ON_GECMEDI');
  return {
    n, n_yeterli, gecti, karar,
    gorselli: { uyum: gUyum, oran: yuvarla(gOran), eksik: gEksik, sorunlu: gSorunlu },
    gorselsiz: { uyum: zUyum, oran: yuvarla(zOran), eksik: zEksik, cozulen: zCozulen },
    esik: ESIK,
  };
}
