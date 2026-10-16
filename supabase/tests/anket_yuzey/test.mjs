// Anket yüzey testi (web_sitesi kaldırma): PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node test.mjs
//
// Zincir: stubs.sql → 20261007000030 (anketler, RPC'ler) → 20261029000000 (yüzeyler)
//         → [sınama] → 20261039000000 (web_sitesi kaldırma).
// Gerçek migration dosyaları çalışır; yalnız Supabase bağımlılıkları stubs.sql ile taklit edilir.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migDir = path.resolve(here, '..', '..', 'migrations');
const M_ANKET = path.join(migDir, '20261007000030_anket_otomasyon_analitik_ve_mutabakat.sql');
const M_YUZEY = path.join(migDir, '20261029000000_anket_yuzeyler.sql');
const M_KALDIR = path.join(migDir, '20261039000000_anket_yuzey_web_sitesi_kaldir.sql');

const oku = (p) => fs.readFileSync(p, 'utf8');

let gecen = 0;
let toplam = 0;
function sonuc(ad, ok, detay = '') {
  toplam++;
  if (ok) gecen++;
  console.log(`${String(toplam).padStart(2)}. [${ok ? 'OK  ' : 'FAIL'}] ${ad}${detay && !ok ? `\n      detay: ${detay}` : ''}`);
}

// Hata beklenen çağrı: mesaj veya SQLSTATE eşleşmeli.
async function hataBekle(db, sql, params, kod) {
  try {
    await db.query(sql, params);
    return { ok: false, detay: 'hata bekleniyordu, çağrı başarılı oldu' };
  } catch (e) {
    const durum = String(e.code ?? '');
    const ok = kod ? durum === kod : true;
    return { ok, detay: `kod=${durum} mesaj=${e.message}` };
  }
}

async function veliOturumu(db, uid) {
  await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [uid]);
}

async function tabanKur() {
  const db = new PGlite();
  await db.exec(oku(path.join(here, 'stubs.sql')));
  await db.exec(oku(M_ANKET));
  await db.exec(oku(M_YUZEY));
  return db;
}

const VELI = '11111111-1111-4111-8111-111111111111';

async function veliEkle(db) {
  await db.query(`insert into public.profiles (id, role, full_name) values ($1, 'veli', 'Test Veli')`, [VELI]);
}

const SORU = `[{"id":"q1","tur":"tek_secim","baslik":"Test?","secenekler":["a","b"]}]`;

async function anketEkle(db, ad, yuzeyler, durum = 'yayinda') {
  const r = await db.query(
    `insert into public.anketler (ad, anonim, durum, sorular, yuzeyler)
     values ($1, false, $2, $3::jsonb, $4::text[]) returning id`,
    [ad, durum, SORU, yuzeyler]
  );
  return r.rows[0].id;
}

async function yuzeyleri(db, id) {
  const r = await db.query(`select yuzeyler from public.anketler where id = $1`, [id]);
  return r.rows[0].yuzeyler;
}

const esit = (a, b) => JSON.stringify([...a].sort()) === JSON.stringify([...b].sort());

// ---------------------------------------------------------------------
// Senaryo grubu 1: karışık veri, migration başarılı
// ---------------------------------------------------------------------
console.log('--- Grup 1: karışık yüzeyli veri, migration uygulanır ---');
{
  const db = await tabanKur();
  await veliEkle(db);
  const A = await anketEkle(db, 'Karışık', ['web_sitesi', 'veli_paneli']);
  const B = await anketEkle(db, 'Yalnız veli', ['veli_paneli']);
  const C = await anketEkle(db, 'Mobil ve web', ['mobil', 'web_app']);

  await veliOturumu(db, VELI);
  const onceListe = await db.query(`select public.anket_aktif_listem('web_sitesi') as j`);
  sonuc('migration öncesi: web_sitesi listesinde anket A var', onceListe.rows[0].j.some((a) => a.id === A));

  await db.exec(oku(M_KALDIR));

  sonuc('migration başarılı tamamlandı', true);
  sonuc('A yalnız veli_paneli kaldı (web_sitesi düştü)', esit(await yuzeyleri(db, A), ['veli_paneli']), JSON.stringify(await yuzeyleri(db, A)));
  sonuc('B değişmedi', esit(await yuzeyleri(db, B), ['veli_paneli']));
  sonuc('C değişmedi', esit(await yuzeyleri(db, C), ['mobil', 'web_app']));

  // Ad geçerli tutulur ki tek ihlal yüzey kısıtı olsun (ad kısıtı ayrıca 23514 üretirdi).
  const k1 = await hataBekle(db, `insert into public.anketler (ad, anonim, sorular, yuzeyler) values ('Yüzey testi', false, '[]'::jsonb, array['web_sitesi'])`, [], '23514');
  sonuc('yeni anket web_sitesi ile eklenemez (kısıt, 23514)', k1.ok, k1.detay);

  const k2 = await hataBekle(db, `update public.anketler set yuzeyler = array['web_sitesi','mobil'] where id = $1`, [B], '23514');
  sonuc('mevcut anket web_sitesi ile güncellenemez (kısıt, 23514)', k2.ok, k2.detay);

  const k3 = await hataBekle(db, `update public.anketler set yuzeyler = array[]::text[] where id = $1`, [B], '23514');
  sonuc('boş mecra dizisi reddedilir (kısıt, 23514)', k3.ok, k3.detay);

  await veliOturumu(db, VELI);
  const webListe = await db.query(`select public.anket_aktif_listem('web_sitesi') as j`);
  sonuc('anket_aktif_listem(web_sitesi) hata vermez ve boş döner', Array.isArray(webListe.rows[0].j) && webListe.rows[0].j.length === 0, JSON.stringify(webListe.rows[0].j));

  const veliListe = await db.query(`select public.anket_aktif_listem('veli_paneli') as j`);
  sonuc('anket_aktif_listem(veli_paneli) A ve B\'yi döner', veliListe.rows[0].j.some((a) => a.id === A) && veliListe.rows[0].j.some((a) => a.id === B));

  const yanit = await hataBekle(db, `select public.anket_yanit_gonder($1, '{}'::jsonb, 'web_sitesi')`, [A], 'P0002');
  sonuc('web_sitesi üzerinden yanıt P0002 ile reddedilir (anket artık orada yayında değil)', yanit.ok, yanit.detay);

  await db.query(`select public.anket_yanit_gonder($1, '{}'::jsonb, 'veli_paneli')`, [A]);
  const yanitSay = await db.query(`select count(*)::int as n from public.anket_yanitlari where anket_id = $1 and yuzey = 'veli_paneli'`, [A]);
  sonuc('veli_paneli üzerinden yanıt kaydedilir (migration yanıt akışını bozmaz)', yanitSay.rows[0].n === 1);

  await db.close();
}

// ---------------------------------------------------------------------
// Senaryo grubu 2: yalnız web_sitesi içeren anket var → migration DURUR
// ---------------------------------------------------------------------
console.log('--- Grup 2: yalnız web_sitesi içeren anket → migration durmalı ---');
{
  const db = await tabanKur();
  const W = await anketEkle(db, 'Yalnız web', ['web_sitesi'], 'taslak');

  let hata = null;
  try {
    await db.exec(oku(M_KALDIR));
  } catch (e) {
    hata = e;
  }
  sonuc('migration hata ile durdu', hata !== null, 'migration başarılı tamamlandı');
  sonuc('hata kodu 23514', hata && String(hata.code) === '23514', hata ? `kod=${hata.code} mesaj=${hata.message}` : '');
  sonuc('anket W değişmedi (web_sitesi yerinde)', esit(await yuzeyleri(db, W), ['web_sitesi']), JSON.stringify(await yuzeyleri(db, W)));

  // Kısıt eski haliyle kaldı mı? (migration yarıda kalmadı: işlem tek bloktaki DO hatası kısıtı değiştirmemeli)
  const kisit = await db.query(`select pg_get_constraintdef(oid) as d from pg_constraint where conname = 'anketler_yuzeyler'`);
  sonuc('kısıt hâlâ eski haliyle (web_sitesi kabul eder)', kisit.rows[0].d.includes('web_sitesi'), kisit.rows[0].d);

  await db.close();
}

// ---------------------------------------------------------------------
// Senaryo grubu 3: kullanıcı elle düzelttikten sonra migration geçer
// ---------------------------------------------------------------------
console.log('--- Grup 3: elle düzeltme sonrası migration geçer ---');
{
  const db = await tabanKur();
  const W = await anketEkle(db, 'Yalnız web', ['web_sitesi'], 'taslak');
  await db.query(`update public.anketler set yuzeyler = array['veli_paneli'] where id = $1`, [W]);
  await db.exec(oku(M_KALDIR));
  sonuc('elle düzeltme sonrası migration başarılı', true);
  sonuc('W veli_paneli kaldı', esit(await yuzeyleri(db, W), ['veli_paneli']));
  await db.close();
}

console.log(`\nSONUÇ: ${gecen}/${toplam} senaryo geçti`);
process.exit(gecen === toplam ? 0 : 1);
