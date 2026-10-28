// W8a SQL doğrulaması: kullanim_olaylari_gonder yetkileri PGlite (Postgres WASM) üzerinde. Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: Supabase rolleri (anon, authenticated, service_role) ve varsayılan yetkiler
//          → 20261066000000 (kullanım süresi) → ÖNCE: anon çağırabiliyor (kanıt)
//          → 20261108000000 → SONRA: anon ve authenticated çağıramıyor, service_role çağırabiliyor.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyonKlasoru = path.resolve(here, '../../migrations');
const oku = (p) => fs.readFileSync(p, 'utf8').replace(/^﻿/, '');

const onceki = path.join(migrasyonKlasoru, '20261066000000_kullanim_suresi.sql');
const hedef = path.join(migrasyonKlasoru, '20261108000000_kullanim_olaylari_anon_kapat.sql');

// Supabase'in gerçek ortamını taklit eder: roller, şema kullanımı ve yeni nesnelere varsayılan yetki.
// Postgres, fonksiyonlara PUBLIC'e EXECUTE yetkisini varsayılan olarak verir; hedef migration bunu kapatır.
const roller = `
do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end $$;
grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
`;

const db = new PGlite();
let gecen = 0;
let kalan = 0;
const kontrol = (ad, kosul, detay = '') => {
  if (kosul) {
    gecen++;
    console.log(`  GEÇTİ  ${ad}`);
  } else {
    kalan++;
    console.log(`  KALDI  ${ad}${detay ? `  -> ${detay}` : ''}`);
  }
};

// Rol olarak çağrı: hata kodu ve sonuç döner; oturum her seferinde sıfırlanır.
async function cagri(rol, sql, params = []) {
  await db.exec(`set role ${rol}`);
  try {
    const r = await db.query(`select ${sql} as r`, params);
    return { veri: r.rows[0].r };
  } catch (e) {
    return { hata: { kod: e.code, mesaj: e.message } };
  } finally {
    await db.exec('reset role');
  }
}

const olay = (ek = {}) => ({
  yuzey: 'mobil',
  ekran: '/ogrenci/ana',
  sure_sn: 30,
  baslangic: new Date(Date.now() - 60_000).toISOString(),
  oturum_anahtari: 'oturum_anahtari_0001',
  rol: 'ogrenci',
  ...ek,
});
const gonderSql = 'public.kullanim_olaylari_gonder($1::jsonb)';
const govde = JSON.stringify([olay()]);

async function yetkiBayraklari() {
  const r = await db.query(
    `select has_function_privilege('anon', p.oid, 'EXECUTE') as anon,
            has_function_privilege('authenticated', p.oid, 'EXECUTE') as auth,
            has_function_privilege('service_role', p.oid, 'EXECUTE') as svc
       from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'kullanim_olaylari_gonder'`,
  );
  return r.rows[0];
}

async function adim(ad, dosya) {
  try {
    await db.exec(oku(dosya));
    console.log(`migration: ${path.basename(dosya)} tamam`);
  } catch (e) {
    console.log(`HATA [${ad}]: ${e.message}`);
    process.exit(1);
  }
}

await db.exec(roller);
await adim('20261066', onceki);

console.log('\nÖNCE (20261066): kanıt');
{
  const anon = await cagri('anon', gonderSql, [govde]);
  kontrol('ÖNCE anon çağırabiliyor (açık yüzey kanıtı)', anon.veri?.kabul === 1, JSON.stringify(anon));
  const yet = await yetkiBayraklari();
  kontrol('ÖNCE anon EXECUTE yetkisine sahip', yet.anon === true);
}

await adim('20261108', hedef);
// Idempotency: aynı migration ikinci kez de hata vermeden çalışmalı.
await adim('20261108 (tekrar)', hedef);

console.log('\nSONRA (20261108): yetki sınırı');
{
  const yet = await yetkiBayraklari();
  kontrol('anon EXECUTE yetkisi yok', yet.anon === false, JSON.stringify(yet));
  kontrol('authenticated EXECUTE yetkisi yok', yet.auth === false, JSON.stringify(yet));
  kontrol('service_role EXECUTE yetkisi var', yet.svc === true, JSON.stringify(yet));

  const anon = await cagri('anon', gonderSql, [govde]);
  kontrol('anon çağrısı reddedilir (42501)', anon.hata?.kod === '42501', JSON.stringify(anon));

  const auth = await cagri('authenticated', gonderSql, [govde]);
  kontrol('authenticated çağrısı reddedilir (42501)', auth.hata?.kod === '42501', JSON.stringify(auth));

  const once = await db.query('select count(*)::int as n from public.kullanim_olaylari');
  const svc = await cagri('service_role', gonderSql, [govde]);
  kontrol('service_role çağrısı çalışır ve kabul eder', svc.veri?.kabul === 1, JSON.stringify(svc));
  const sonra = await db.query('select count(*)::int as n from public.kullanim_olaylari');
  kontrol('service_role çağrısı tabloya yazar', sonra.rows[0].n === once.rows[0].n + 1,
    `önce ${once.rows[0].n}, sonra ${sonra.rows[0].n}`);
}

console.log(`\nSonuç: ${gecen} geçti, ${kalan} kaldı`);
if (kalan > 0) process.exit(1);
