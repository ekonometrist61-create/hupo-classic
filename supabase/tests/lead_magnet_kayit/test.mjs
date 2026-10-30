// Lead magnet kayÄ±t testi: PGlite (Postgres WASM). Docker gerekmez.
// KullanÄ±m (bu klasÃ¶rde bir kez: npm install): node test.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const MIG = path.resolve(here, '..', '..', 'migrations', '20261030000100_lead_magnet_kayit.sql');

let gecen = 0;
let toplam = 0;
function sonuc(ad, ok, detay = '') {
  toplam++;
  if (ok) gecen++;
  console.log(`${String(toplam).padStart(2)}. [${ok ? 'OK  ' : 'FAIL'}] ${ad}${detay && !ok ? `\n      detay: ${detay}` : ''}`);
}

async function hataBekle(db, sql, params, kod) {
  try {
    await db.query(sql, params);
    return { ok: false, detay: 'hata bekleniyordu, Ã§aÄŸrÄ± baÅŸarÄ±lÄ± oldu' };
  } catch (e) {
    const durum = String(e.code ?? '');
    return { ok: kod ? durum === kod : true, detay: `kod=${durum} mesaj=${e.message}` };
  }
}

const db = new PGlite();
await db.exec(`
  create role anon nologin; create role authenticated nologin; create role service_role nologin;
`);
await db.exec(fs.readFileSync(MIG, 'utf8'));

const CAGRI = `select public.lead_magnet_kayit_ekle($1, $2, $3::smallint, $4, $5, $6, $7, $8::jsonb) as id`;
const K = 'lead-magnet-kvkk-2026-10-v1';
const I = 'lead-magnet-izin-2026-10-v1';
const M = 'carpim-pif-noktalari';

// 1. Normal kayÄ±t
let r = await db.query(CAGRI, [M, 'Veli@Ornek.com ', 3, true, K, I, false, '{"kaynak":"x"}']);
const id1 = r.rows[0].id;
sonuc('kayÄ±t oluÅŸur, uuid dÃ¶ner', typeof id1 === 'string' && id1.length === 36);

let k = (await db.query(`select * from public.lead_magnet_kayitlari`)).rows;
sonuc('e-posta kÃ¼Ã§Ã¼k harfe Ã§evrilir ve kÄ±rpÄ±lÄ±r', k[0].eposta === 'veli@ornek.com');
sonuc('izin iÅŸaretlenmediyse false', k[0].izin_eposta === false);
sonuc('doÄŸrulama zamanÄ± boÅŸ (gÃ¶nderim motoru yok)', k[0].dogrulandi_zaman === null);

// 2. AynÄ± kiÅŸi tekrar, bu kez izinli: tek satÄ±r, izin gÃ¼ncellenir, log 2+2 satÄ±r
await db.query(CAGRI, [M, 'veli@ornek.com', 4, true, K, I, true, '{}']);
k = (await db.query(`select * from public.lead_magnet_kayitlari`)).rows;
sonuc('aynÄ± magnet+e-posta tek satÄ±r kalÄ±r', k.length === 1);
sonuc('son beyan geÃ§erli: izin true, sÄ±nÄ±f 4', k[0].izin_eposta === true && k[0].sinif === 4);
let log = (await db.query(`select tur, verildi from public.lead_magnet_izin_logu order by id`)).rows;
sonuc('izin logu append-only: 4 satÄ±r', log.length === 4);
sonuc('ilk gÃ¶nderimde e-posta izni false loglandÄ±', log[1].tur === 'eposta' && log[1].verildi === false);

// 3. Ä°zin geri Ã§ekme de loglanÄ±r
await db.query(CAGRI, [M, 'veli@ornek.com', 4, true, K, I, false, '{}']);
k = (await db.query(`select izin_eposta from public.lead_magnet_kayitlari`)).rows;
sonuc('izin geri Ã§ekilebilir', k[0].izin_eposta === false);

// 4. DoÄŸrulamalar
let h = await hataBekle(db, CAGRI, [M, 'a@b.co', 4, false, K, I, false, '{}'], '22023');
sonuc('KVKK onayÄ± yoksa reddedilir', h.ok, h.detay);
h = await hataBekle(db, CAGRI, [M, 'a@b.co', 8, true, K, I, false, '{}'], '22023');
sonuc('8. sÄ±nÄ±f reddedilir (pilot 3â€“7)', h.ok, h.detay);
h = await hataBekle(db, CAGRI, [M, 'a@b.co', 2, true, K, I, false, '{}'], '22023');
sonuc('2. sÄ±nÄ±f reddedilir', h.ok, h.detay);
h = await hataBekle(db, CAGRI, [M, 'geÃ§ersiz', 4, true, K, I, false, '{}']);
sonuc('geÃ§ersiz e-posta tablo kÄ±sÄ±tÄ±yla reddedilir', h.ok, h.detay);
h = await hataBekle(db, CAGRI, ['BÃœYÃœK_Harf', 'a@b.co', 4, true, K, I, false, '{}']);
sonuc('geÃ§ersiz magnet kimliÄŸi reddedilir', h.ok, h.detay);

// 5. Yetkiler: anon/authenticated ne tabloyu ne RPC'yi kullanabilir
for (const rol of ['anon', 'authenticated']) {
  await db.exec(`set role ${rol}`);
  h = await hataBekle(db, `select * from public.lead_magnet_kayitlari`, [], '42501');
  sonuc(`${rol}: tabloyu okuyamaz`, h.ok, h.detay);
  h = await hataBekle(db, CAGRI, [M, 'x@y.co', 4, true, K, I, false, '{}'], '42501');
  sonuc(`${rol}: RPC Ã§aÄŸÄ±ramaz`, h.ok, h.detay);
  await db.exec('reset role');
}
await db.exec('set role service_role');
r = await db.query(CAGRI, [M, 'servis@y.co', 5, true, K, I, true, '{}']);
sonuc('service_role RPC Ã§aÄŸÄ±rabilir', typeof r.rows[0].id === 'string');
await db.exec('reset role');

console.log(`\n${gecen}/${toplam} geÃ§ti`);
process.exit(gecen === toplam ? 0 : 1);

