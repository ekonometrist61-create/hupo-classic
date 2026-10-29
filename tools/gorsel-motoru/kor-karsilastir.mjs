// Kör çözüm karşılaştırması (CLI): node kor-karsilastir.mjs <sorular.json> <gorselli_cevap.json> <gorselsiz_cevap.json>
// Kural ve eşikler kor.mjs içindedir. Karar KOR_GECMEDI ise çıkış kodu 1.
import fs from 'node:fs';
import { korKarsilastir } from './kor.mjs';

const [, , sy, gy, zy] = process.argv;
if (!sy || !gy || !zy) {
  console.error('Kullanım: node kor-karsilastir.mjs <sorular.json> <gorselli_cevap.json> <gorselsiz_cevap.json>');
  process.exit(2);
}
const oku = (yol) => JSON.parse(fs.readFileSync(yol, 'utf8'));
const r = korKarsilastir(oku(sy), oku(gy), oku(zy));
console.log(JSON.stringify(r, null, 1));
console.error(`karar: ${r.karar} (görselli %${Math.round(r.gorselli.oran * 100)}, görselsiz %${Math.round(r.gorselsiz.oran * 100)}, n=${r.n})`);
process.exit(r.karar === 'KOR_GECMEDI' ? 1 : 0);
