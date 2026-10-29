// Motor girişi: spec -> { svg, alt, olgular, bulgular }. Yanlış spec'te hata fırlatır (RED).
import { profilBul } from './cekirdek.mjs';
import { TIPLER } from './tipler.mjs';
import { gorselLint } from './lint.mjs';

export function gorselUret(spec, sinif) {
  const tip = TIPLER[spec.tip_id];
  if (!tip) throw new Error(`tip_yok:${spec.tip_id}`);
  const { sahne, alt, olgular } = tip(spec.parametreler, profilBul(sinif));
  const svg = sahne.svg(alt);
  return { svg, alt, olgular, bulgular: gorselLint(sahne, svg) };
}

// "dogrulama": [{ yol:['siniflar','[AB]'], beklenen:'cap' }, …] — anahtarı destekleyen olgular spec'ten hesaplananla birebir eşleşmeli.
export function olguDogrula(olgular, dogrulama) {
  const sorun = [];
  for (const d of dogrulama ?? []) {
    let v = olgular; for (const k of d.yol) v = v?.[k];
    if (JSON.stringify(v) !== JSON.stringify(d.beklenen)) sorun.push(`olgu_uyusmuyor:${d.yol.join('.')} hesaplanan=${JSON.stringify(v)} beklenen=${JSON.stringify(d.beklenen)}`);
  }
  return sorun;
}
