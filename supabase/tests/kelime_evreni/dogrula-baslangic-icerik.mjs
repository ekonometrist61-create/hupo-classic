// Başlangıç içerik paketi doğrulaması (PGlite).
// Kullanım (bu klasörde): node dogrula-baslangic-icerik.mjs
import fs from 'node:fs/promises';
import path from 'node:path';
import pathUrl from 'node:url';
import { PGlite } from '@electric-sql/pglite';

const here = path.dirname(pathUrl.fileURLToPath(import.meta.url));
const db = new PGlite();
await db.exec((await fs.readFile(path.join(here, 'stubs.sql'), 'utf8')));

const read = (p) => fs.readFile(path.resolve(p), 'utf8');

await db.exec(await read('../../migrations/20261022000000_kelime_evreni.sql'));
await db.exec(await read('../../migrations/20261022000001_kelime_evreni_baslangic_icerik.sql'));

const q = (sql) => db.query(sql);

// 1. Satır sayıları
let r = await q(`select
  (select count(*) from public.kelime_anlamlari) as anlamlar,
  (select count(*) from public.kelime_iliskileri) as iliskiler,
  (select count(*) from public.kelime_sorulari) as sorular`);
console.log('satirlar:', r.rows[0]);
if (r.rows[0].anlamlar !== 93 || r.rows[0].iliskiler !== 49 || r.rows[0].sorular !== 48) {
  throw new Error('beklenen satır sayıları 93/49/48');
}

// 2. İlişki türü dağılımı
r = await q(`select iliski_turu, count(*) from public.kelime_iliskileri group by 1 order by 1`);
console.log('iliski dagilimi:', r.rows);
if (JSON.stringify(r.rows.map((x) => x.count)) !== JSON.stringify([20, 9, 20])) throw new Error('ilişki dağılımı 20/10/20 değil');

// 3. Soru sınıf ve tür dağılımı
r = await q(`select iliski_turu, min(sinif) as min_sinif, max(sinif) as max_sinif, count(*) from public.kelime_sorulari group by 1 order by 1`);
console.log('soru dagilimi:', r.rows);

// 4. Her soruda ipucu ve açıklama dolu, 3 şık, doğru indeks aralıkta
r = await q(`select count(*) as hatali from public.kelime_sorulari
  where ipucu is null or aciklama is null
     or jsonb_array_length(secenekler) <> 3
     or dogru_indeks < 0 or dogru_indeks >= 3`);
if (r.rows[0].hatali > 0) throw new Error('hatalı soru satırı: ' + r.rows[0].hatali);

// 5. Doğru şık indeks dağılımı dengeli mi (en fazla 60%'ı aynı konumda)
r = await q(`select dogru_indeks, count(*) from public.kelime_sorulari group by 1 order by 1`);
console.log('dogru_indeks dagilimi:', r.rows);

// 6. dogru_anlam_id dolu sorularda kök-doğru anlamlar arası onaysız ama VAR olan ilişki
//    (onay beklediği için ILISKI_ONAYSIZ yalnız yayın anında denetlenir; burada eşleşme bakarız)
r = await q(`select count(*) as eslesmeyen from public.kelime_sorulari s
  where s.dogru_anlam_id is not null
    and not exists (select 1 from public.kelime_iliskileri i
      where i.iliski_turu = s.iliski_turu
        and ((i.kaynak_anlam_id = s.anlam_id and i.hedef_anlam_id = s.dogru_anlam_id)
          or (i.kaynak_anlam_id = s.dogru_anlam_id and i.hedef_anlam_id = s.anlam_id)))`);
if (r.rows[0].eslesmeyen > 0) throw new Error('ilişkisi olmayan soru: ' + r.rows[0].eslesmeyen);

// 7. Onaylı ilişki YOK (taslak paket, editör bekler)
r = await q(`select count(*) as onayli from public.kelime_iliskileri where onay_tarihi is not null`);
if (r.rows[0].onayli > 0) throw new Error('beklenmedik onaylı ilişki var');
r = await q(`select count(*) as yayinda from public.kelime_sorulari where durum <> 'taslak'`);
if (r.rows[0].yayinda > 0) throw new Error('beklenmedik taslak dışı soru var');

// 8. benzersiz anlam kaydı (kelime+anlam) çakışması yok (insert zaten koştu; mükerrer bak)
r = await q(`select kelime, count(*) from public.kelime_anlamlari group by kelime having count(*) > 1 order by kelime`);
console.log('cok anlamlı kelimeler:', r.rows.map((x) => x.kelime));

console.log('DOGRULAMA: tamam');
process.exit(0);
