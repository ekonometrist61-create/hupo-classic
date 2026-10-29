// Toplu vurgu önizleme / denetim aracı.
// Kullanım: node tools/vurgu/toplu.mjs [--dizin docs/soru-uretim/paket] [--rapor cikti.json] [--sql cikti.sql]
// Önce önizleme raporu; SQL yalnız 'otomatik' + denetimi geçenler için üretilir (metin md5 korumalı, geri alınabilir).
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join } from 'node:path';
import { vurguOner, vurguDenetle, parcala } from './vurgu.mjs';

const arg = (ad, varsayilan) => {
  const i = process.argv.indexOf(ad);
  return i > -1 ? process.argv[i + 1] : varsayilan;
};
const dizin = arg('--dizin', 'docs/soru-uretim/paket');
const raporYolu = arg('--rapor');
const sqlYolu = arg('--sql');

const sorular = [];
const gorulen = new Set();
for (const dosya of readdirSync(dizin).filter((d) => d.endsWith('.json'))) {
  const j = JSON.parse(readFileSync(join(dizin, dosya), 'utf8').replace(/^﻿/, ''));
  for (const s of Array.isArray(j) ? j : j.sorular ?? []) {
    if (s?.soru_metni && s.siklar && !gorulen.has(s.soru_id)) gorulen.add(s.soru_id), sorular.push({ ...s, _dosya: dosya });
  }
}

const sonuc = { toplam: sorular.length, otomatik: 0, inceleme: 0, reddedilen: 0, uyarili: 0, dersler: {}, incelemeListesi: [], ornekler: [] };
const sqlSatirlari = [];

for (const s of sorular) {
  const oner = vurguOner(s.soru_metni);
  const ders = (sonuc.dersler[s.ders] ??= { toplam: 0, otomatik: 0, inceleme: 0 });
  ders.toplam++;
  let durum = oner.durum;
  let denetim = null;
  if (durum === 'otomatik') {
    denetim = vurguDenetle({ soruMetni: s.soru_metni, highlights: oner.highlights, siklar: s.siklar, dogruSik: s.dogru_sik });
    if (!denetim.ok) {
      durum = 'inceleme';
      sonuc.reddedilen++;
    } else if (denetim.uyarilar.length) sonuc.uyarili++;
  }
  if (durum === 'otomatik') {
    sonuc.otomatik++;
    ders.otomatik++;
    if (sonuc.ornekler.length < 120) {
      sonuc.ornekler.push({ id: s.soru_id, parcalar: parcala(s.soru_metni, oner.highlights).filter((p) => p.vurgu).map((p) => p.metin), uyari: denetim.uyarilar });
    }
    const md5 = createHash('md5').update(s.soru_metni).digest('hex');
    sqlSatirlari.push(
      `update public.questions set highlights = '${JSON.stringify(oner.highlights)}'::jsonb, highlight_durum = 'otomatik' ` +
        `where dis_soru_id = '${String(s.soru_id).replace(/'/g, "''")}' and md5(soru_metni) = '${md5}' and highlights is null;`,
    );
  } else {
    sonuc.inceleme++;
    ders.inceleme++;
    sonuc.incelemeListesi.push({ id: s.soru_id, ders: s.ders, neden: oner.neden ?? denetim?.hatalar.join('; ') ?? 'denetim' });
  }
}

if (raporYolu) writeFileSync(raporYolu, JSON.stringify(sonuc, null, 2));
if (sqlYolu) {
  writeFileSync(
    sqlYolu,
    `-- Vurgu toplu yazımı. Geri alma: update public.questions set highlights = null, highlight_durum = null where highlight_durum = 'otomatik';\nbegin;\n${sqlSatirlari.join('\n')}\ncommit;\n`,
  );
}
const { ornekler, incelemeListesi, ...ozet } = sonuc;
console.log(JSON.stringify({ ...ozet, incelemeSayisi: incelemeListesi.length }, null, 2));

