// Anket D1 testi: sürüm anlık görüntüsü, kod kilidi, tek yayın, arşiv güvencesi. PGlite, Docker gerekmez.
//
// Kullanım:  node test.mjs
// Zincir:    kelime_evreni/stubs.sql → arsiv/stubs_arsiv.sql → 20261007000030 (anketler, RPC'ler)
//            → 20261026, 20261029, 20261030, 20261032 (arşiv kolonları)
//            → [yayında ve taslak veri: D1 öncesi] → 20261158000000 (D1) → senaryolar
// Gerçek migration dosyaları çalışır; Supabase bağımlılıkları stubs ile taklit edilir.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '..', '..', '..');
const kelime = path.resolve(here, '..', 'kelime_evreni');
const arsiv = path.resolve(here, '..', 'arsiv');

const require = createRequire(path.join(kelime, 'package.json'));
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite')).href);

const mig = (n) => path.join(repo, 'supabase/migrations', n);
const oku = (p) => fs.readFileSync(p, 'utf8');

const db = new PGlite();
const sonuclar = [];

async function t(ad, f) {
  try {
    const r = await f();
    sonuclar.push({ ad, ok: r === true, detay: r === true ? '' : String(r) });
  } catch (e) {
    sonuclar.push({ ad, ok: false, detay: `${e.code ?? ''} ${e.message}` });
  }
}

// Beklenen SQLSTATE döner; hata yoksa null.
async function hataKodu(sql, params = []) {
  try {
    await db.query(sql, params);
    return null;
  } catch (e) {
    return String(e.code ?? e.message);
  }
}

const SORU = `[{"id":"q1","tur":"tek_secim","baslik":"Test?","secenekler":["a","b"]}]`;
// q1 önceki senaryolarda a,b,c seçeneklerine ve yeni başlığa çıktı; sürüm 2 bu hâli korur ve q2 ekler.
const SORU_IKI = `[{"id":"q1","tur":"tek_secim","baslik":"Düzeltilmiş?","secenekler":["a","b","c"]},{"id":"q2","tur":"nps","baslik":"Öneri?"}]`;

// --- D1 öncesi taban ---
await db.exec(oku(path.join(kelime, 'stubs.sql')));
await db.exec(oku(path.join(arsiv, 'stubs_arsiv.sql')));
for (const n of [
  '20261007000030_anket_otomasyon_analitik_ve_mutabakat.sql',
  '20261026000000_site_duyurulari.sql',
  '20261029000000_anket_yuzeyler.sql',
  '20261030000000_duyuru_yuzeyler.sql',
  '20261032000000_duyuru_anket_arsiv_ve_sil.sql',
]) {
  await db.exec(oku(mig(n)));
}

// D1 öncesi veri: bir yayında anket (geriye dönük anlık görüntü beklenir) ve bir taslak.
const A = (await db.query(
  `insert into public.anketler (ad, anonim, durum, sorular, yuzeyler) values ('Eski yayın', false, 'yayinda', $1::jsonb, array['veli_paneli']::text[]) returning id`,
  [SORU],
)).rows[0].id;
const T = (await db.query(
  `insert into public.anketler (ad, anonim, durum, sorular, yuzeyler) values ('Taslak', false, 'taslak', $1::jsonb, array['veli_paneli']::text[]) returning id`,
  [SORU],
)).rows[0].id;

// --- D1 uygulanır ---
let d1Hata = null;
try {
  await db.exec(oku(mig('20261158000000_anket_d1_surum_guvence.sql')));
} catch (e) {
  d1Hata = e;
}
sonuclar.push({ ad: 'D1 migrasyonu hatasız uygulanır', ok: d1Hata === null, detay: d1Hata ? `${d1Hata.code} ${d1Hata.message}` : '' });

if (d1Hata === null) {
  await t('geriye dönük: yayındaki anketin 1. sürüm anlık görüntüsü var', async () => {
    const r = await db.query(`select count(*)::int n from public.anket_surumleri where anket_id = $1 and surum = 1`, [A]);
    return r.rows[0].n === 1 || `n=${r.rows[0].n}`;
  });

  await t('taslağın anlık görüntüsü yoktur', async () => {
    const r = await db.query(`select count(*)::int n from public.anket_surumleri where anket_id = $1`, [T]);
    return r.rows[0].n === 0 || `n=${r.rows[0].n}`;
  });

  // Arşiv güvencesi: yanıtı olan taslak silinemez (anket_yanitlari restrict)
  await db.query(`insert into public.anket_yanitlari (anket_id, surum, yanitlar) values ($1, 1, '{}'::jsonb)`, [T]);
  // ON DELETE RESTRICT: PostgreSQL 23001 (restrict_violation) üretir; NO ACTION 23503 üretirdi.
  await t('yanıtlı anket silinemez (anket_yanitlari restrict, 23001)', async () => {
    const k = await hataKodu(`delete from public.anketler where id = $1`, [T]);
    return k === '23001' || `kod=${k}`;
  });

  await t('yayınlanmış (anlık görüntülü) anket silinemez (23001)', async () => {
    const k = await hataKodu(`delete from public.anketler where id = $1`, [A]);
    return k === '23001' || `kod=${k}`;
  });

  // Tek yayında: T yayına alınınca A kapanır ve arşivlenir
  await t('yayın anında önceki yayındaki anket kapanır', async () => {
    await db.query(`update public.anketler set durum = 'yayinda' where id = $1`, [T]);
    const r = await db.query(`select durum, arsivlendi_at is not null arsiv from public.anketler where id = $1`, [A]);
    return (r.rows[0].durum === 'kapali' && r.rows[0].arsiv === true) || JSON.stringify(r.rows[0]);
  });

  await t('aynı anda yalnız bir anket yayında', async () => {
    const r = await db.query(`select count(*)::int n from public.anketler where durum = 'yayinda'`);
    return r.rows[0].n === 1 || `n=${r.rows[0].n}`;
  });

  await t('tek yayında kısmi unique indeks kurulu', async () => {
    const r = await db.query(`select count(*)::int n from pg_indexes where indexname = 'anketler_tek_yayin'`);
    return r.rows[0].n === 1 || `n=${r.rows[0].n}`;
  });

  await t('yayın anı anlık görüntüsü: T 1. sürüm', async () => {
    const r = await db.query(`select count(*)::int n from public.anket_surumleri where anket_id = $1 and surum = 1`, [T]);
    return r.rows[0].n === 1 || `n=${r.rows[0].n}`;
  });

  await t('anlık görüntü değiştirilemez (update 23514)', async () => {
    const k = await hataKodu(`update public.anket_surumleri set ad = 'X' where anket_id = $1`, [T]);
    return k === '23514' || `kod=${k}`;
  });

  await t('anlık görüntü silinemez (delete 23514)', async () => {
    const k = await hataKodu(`delete from public.anket_surumleri where anket_id = $1`, [T]);
    return k === '23514' || `kod=${k}`;
  });

  await t('aynı sürüm ikinci kez yazılamaz (23505)', async () => {
    const k = await hataKodu(
      `insert into public.anket_surumleri (anket_id, surum, ad, anonim, sorular, tekrar_gosterim_gun, yuzeyler)
       values ($1, 1, 'Kopya', false, '[]'::jsonb, 30, array['veli_paneli']::text[])`, [T]);
    return k === '23505' || `kod=${k}`;
  });

  // Kod kilidi (T yayında ve sürüm kayıtlı)
  await t('yayımlanmış soru kaldırılamaz (23514)', async () => {
    const k = await hataKodu(`update public.anketler set sorular = '[]'::jsonb where id = $1`, [T]);
    return k === '23514' || `kod=${k}`;
  });

  await t('yayımlanmış sorunun türü değiştirilemez (23514)', async () => {
    const k = await hataKodu(
      `update public.anketler set sorular = '[{"id":"q1","tur":"nps","baslik":"Test?"}]'::jsonb where id = $1`, [T]);
    return k === '23514' || `kod=${k}`;
  });

  await t('seçenek kodu kaldırılamaz (23514)', async () => {
    const k = await hataKodu(
      `update public.anketler set sorular = '[{"id":"q1","tur":"tek_secim","baslik":"Test?","secenekler":["a"]}]'::jsonb where id = $1`, [T]);
    return k === '23514' || `kod=${k}`;
  });

  await t('seçenek eklemek serbest', async () => {
    const k = await hataKodu(
      `update public.anketler set sorular = '[{"id":"q1","tur":"tek_secim","baslik":"Test?","secenekler":["a","b","c"]}]'::jsonb where id = $1`, [T]);
    return k === null || `kod=${k}`;
  });

  await t('soru metni düzeltmek serbest', async () => {
    const k = await hataKodu(
      `update public.anketler set sorular = '[{"id":"q1","tur":"tek_secim","baslik":"Düzeltilmiş?","secenekler":["a","b","c"]}]'::jsonb where id = $1`, [T]);
    return k === null || `kod=${k}`;
  });

  // Sürüm artışı: yeni soru eklenir, sürüm 2 anlık görüntüsü alınır
  await t('sorular değişip sürüm artınca 2. anlık görüntü alınır', async () => {
    await db.query(
      `update public.anketler set sorular = $2::jsonb, surum = surum + 1 where id = $1`, [T, SORU_IKI]);
    const r = await db.query(
      `select count(*)::int n, max(sorular::text) s from public.anket_surumleri where anket_id = $1 and surum = 2`, [T]);
    return (r.rows[0].n === 1 && String(r.rows[0].s).includes('q2')) || `n=${r.rows[0].n}`;
  });

  await t('eski sürüm anlık görüntüsü 2. sürümle değişmez', async () => {
    const r = await db.query(`select sorular::text s from public.anket_surumleri where anket_id = $1 and surum = 1`, [T]);
    return (!String(r.rows[0].s).includes('q2')) || 'v1 içinde q2 bulundu';
  });

  // Taslak: yayın yapılmadan kod kilidi uygulanmaz
  await t('taslakta kod kilidi uygulanmaz (soru kaldırılabilir)', async () => {
    const z = (await db.query(
      `insert into public.anketler (ad, anonim, durum, sorular, yuzeyler) values ('Taslak 2', false, 'taslak', $1::jsonb, array['veli_paneli']::text[]) returning id`,
      [SORU])).rows[0].id;
    const k = await hataKodu(`update public.anketler set sorular = '[]'::jsonb where id = $1`, [z]);
    return k === null || `kod=${k}`;
  });

  // İkinci yayın: yeni anket yayına alınınca T kapanır (otomatik arşiv)
  await t('ikinci yayın önceki yayındaki anketi kapatıp arşivler', async () => {
    const z = (await db.query(
      `insert into public.anketler (ad, anonim, durum, sorular, yuzeyler) values ('Yeni yayın', false, 'taslak', $1::jsonb, array['veli_paneli']::text[]) returning id`,
      [SORU])).rows[0].id;
    await db.query(`update public.anketler set durum = 'yayinda' where id = $1`, [z]);
    const r = await db.query(
      `select (select durum from public.anketler where id = $1) t_durum,
              (select arsivlendi_at is not null from public.anketler where id = $1) t_arsiv,
              (select durum from public.anketler where id = $2) z_durum,
              (select count(*)::int from public.anketler where durum = 'yayinda') n`, [T, z]);
    const x = r.rows[0];
    return (x.t_durum === 'kapali' && x.t_arsiv === true && x.z_durum === 'yayinda' && x.n === 1) || JSON.stringify(x);
  });

  // Yeni tablolar: RLS açık, anon/authenticated erişemez
  await t('yeni tablolar RLS açık', async () => {
    const r = await db.query(
      `select count(*)::int n from pg_class where relname in ('anket_surumleri','anket_gosterimleri','etkilesim_butcesi','anket_taslaklari') and relrowsecurity`);
    return r.rows[0].n === 4 || `n=${r.rows[0].n}`;
  });

  await t('authenticated anket_surumleri okuyamaz (42501)', async () => {
    await db.exec(`set role authenticated`);
    const k = await hataKodu(`select count(*) from public.anket_surumleri`);
    await db.exec(`reset role`);
    return k === '42501' || `kod=${k}`;
  });
}

const gecen = sonuclar.filter((s) => s.ok).length;
for (const [i, s] of sonuclar.entries()) {
  console.log(`${String(i + 1).padStart(2)}. [${s.ok ? 'OK  ' : 'FAIL'}] ${s.ad}${!s.ok && s.detay ? `\n      detay: ${s.detay}` : ''}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuclar.length} senaryo geçti`);
process.exit(gecen === sonuclar.length ? 0 : 1);
