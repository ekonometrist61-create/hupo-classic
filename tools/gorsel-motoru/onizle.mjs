import { gorselUret } from './motor.mjs';
import fs from 'node:fs';
const out = process.argv[2];
const ornek = {
  dogru: { tip_id: 'dogru-modelleri', parametreler: { noktalar: [{ ad: 'A', x: 60, y: 60 }, { ad: 'B', x: 170, y: 60 }, { ad: 'C', x: 60, y: 120 }, { ad: 'D', x: 140, y: 150 }, { ad: 'E', x: 220, y: 120 }, { ad: 'F', x: 270, y: 170 }],
    nesneler: [{ tur: 'dogru_parcasi', a: 'A', b: 'B' }, { tur: 'isin', a: 'C', b: 'D' }, { tur: 'dogru', a: 'E', b: 'F' }] } },
  cember: { tip_id: 'cember-elemanlari', parametreler: { merkez: 'O', noktalar: [{ ad: 'A', aci: 100 }, { ad: 'C', aci: 280 }, { ad: 'B', aci: 30 }, { ad: 'D', aci: 215 }],
    cizimler: [{ tur: 'cap', a: 'A', b: 'C' }, { tur: 'kiris', a: 'A', b: 'B' }, { tur: 'yaricap', a: 'D' }] } },
  aci: { tip_id: 'kesisen-dogrular', parametreler: { dogrular: ['d', 'e'], theta: 130, isaretler: [{ bolge: 0, goster: 'deger' }, { bolge: 1, goster: 'sembol', sembol: '■' }] } },
  kareli: { tip_id: 'kareli-dogrular', parametreler: { en: 10, boy: 7, dogrular: [{ ad: 'k', p1: [1, 1], p2: [4, 4] }, { ad: 'm', p1: [2, 4], p2: [5, 7] }, { ad: 'n', p1: [6, 1], p2: [9, 2] }, { ad: 'p', p1: [1, 6], p2: [3, 4] }] } },
  sayi: { tip_id: 'sayi-dogrusu', parametreler: { min: 0, max: 10, adim: 1, isaretler: [{ deger: 7, etiket: 'A' }, { deger: 3, bos: true }] } },
};
for (const [ad, spec] of Object.entries(ornek)) { const r = gorselUret(spec, 5); fs.writeFileSync(`${out}/${ad}.svg`, r.svg); console.log(ad, r.svg.length, 'bayt', JSON.stringify(r.bulgular)); }
