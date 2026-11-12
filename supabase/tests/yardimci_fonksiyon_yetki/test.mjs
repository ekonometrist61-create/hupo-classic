// GÖR-095 drift onarımı: set_updated_at, tr_normalize, hafta_baslangic yetki testi (PGlite, Docker gerekmez).
//
// Kullanım:  node test.mjs
// Bağımlılık: kelime_evreni/node_modules içindeki @electric-sql/pglite (anket testleriyle aynı).
// Senaryolar:
//   A) Repodaki 20260927000120 temiz kurulumda etkili mi (kayıt-canlı farkının dışında).
//   B) Drift yeniden üretimi: 20260927000120 YOK (canlıdaki gibi), sonra 20261166 uygulanır.
//      - ÖNCE: üç fonksiyonda anon ve PUBLIC EXECUTE açık.
//      - SONRA: anon/PUBLIC kapalı; authenticated (tr_normalize, hafta_baslangic) ve service_role açık.
//      - Yan etki: kontrol fonksiyonu ve SECURITY DEFINER çağıranı etkilenmez.
//      - INVOKER çağıran anon için kapanır (beklenen; repoda yok).
//      - Migration iki kez çalışır (idempotent).
// Stub'lar: stubs.sql. Gerçek production verisi kullanılmaz.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '..', '..', '..');
const kelime = path.resolve(here, '..', 'kelime_evreni');
const migrasyon = (n) => path.join(repo, 'supabase/migrations', n);

const require = createRequire(path.join(kelime, 'package.json'));
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite')).href);

const oku = (p) => fs.readFileSync(p, 'utf8').replace(/^﻿/, '');
const ESKI = '20260927000120_yardimci_fonksiyon_yetkileri.sql';
const ONARIM = '20261166000000_yardimci_fonksiyon_yetki_onarim.sql';

// Supabase rolleri ve varsayılan yetkiler (kullanim_anon_kapat testiyle aynı desen).
const roller = `
do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end $$;
grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
`;

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

async function yeniOrtam() {
  const db = new PGlite();
  await db.exec(roller);
  await db.exec(oku(path.join(here, 'stubs.sql')));
  return db;
}

// Belirli bir rolde SQL çalıştırır; hata kodunu veya sonucu döndürür.
async function rolde(db, rol, sql, params = []) {
  await db.exec(`set role ${rol}`);
  try {
    const r = await db.query(sql, params);
    return { veri: r.rows[0] ?? null };
  } catch (e) {
    return { hata: e.code ?? e.message, mesaj: e.message };
  } finally {
    await db.exec('reset role');
  }
}

// has_function_privilege: rol bazlı EXECUTE.
async function rolYetki(db, rol, fn) {
  const r = await db.query(`select has_function_privilege($1, $2::regprocedure, 'EXECUTE') as y`, [rol, fn]);
  return r.rows[0].y;
}

// PUBLIC (grantee 0) EXECUTE: proacl boşsa varsayılan (PUBLIC dahil) geçerlidir.
async function publicYetki(db, fn) {
  const r = await db.query(
    `select exists (
       select 1 from pg_proc p
         cross join lateral aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
        where p.oid = $1::regprocedure and a.grantee = 0 and a.privilege_type = 'EXECUTE'
     ) as y`,
    [fn],
  );
  return r.rows[0].y;
}

const UC = ['public.set_updated_at()', 'public.tr_normalize(text)', 'public.hafta_baslangic()'];

// --- Senaryo A: repodaki 20260927000120 temiz kurulumda etkili mi ---
console.log('\nA) Repo dosyası (20260927000120) temiz kurulumda');
{
  const db = await yeniOrtam();
  await db.exec(oku(migrasyon(ESKI)));
  kontrol('A1 set_updated_at: anon kapalı', (await rolYetki(db, 'anon', UC[0])) === false);
  kontrol('A2 tr_normalize: anon kapalı', (await rolYetki(db, 'anon', UC[1])) === false);
  kontrol('A3 hafta_baslangic: anon kapalı', (await rolYetki(db, 'anon', UC[2])) === false);
  kontrol('A4 tr_normalize: authenticated açık', (await rolYetki(db, 'authenticated', UC[1])) === true);
  kontrol('A5 hafta_baslangic: authenticated açık', (await rolYetki(db, 'authenticated', UC[2])) === true);
  await db.close();
}

// --- Senaryo B: drift yeniden üretimi ---
console.log('\nB) Drift (20260927000120 uygulanmamış gibi) -> 20261166');
const db = await yeniOrtam();

console.log('  ÖNCE (canlıdaki drift):');
kontrol('B0a set_updated_at: anon açık', (await rolYetki(db, 'anon', UC[0])) === true);
kontrol('B0b tr_normalize: anon açık', (await rolYetki(db, 'anon', UC[1])) === true);
kontrol('B0c hafta_baslangic: anon açık', (await rolYetki(db, 'anon', UC[2])) === true);
kontrol('B0d tr_normalize: PUBLIC açık', (await publicYetki(db, UC[1])) === true);

await db.exec(oku(migrasyon(ONARIM)));
console.log('  20261166 uygulandı (1. kez).');
await db.exec(oku(migrasyon(ONARIM)));
console.log('  20261166 tekrar uygulandı (idempotent kontrolü, hata vermemeli).');

console.log('  SONRA:');
kontrol('B1 set_updated_at: anon kapalı', (await rolYetki(db, 'anon', UC[0])) === false);
kontrol('B2 set_updated_at: authenticated kapalı', (await rolYetki(db, 'authenticated', UC[0])) === false);
kontrol('B3 set_updated_at: PUBLIC kapalı', (await publicYetki(db, UC[0])) === false);
kontrol('B4 set_updated_at: service_role açık (değişmedi)', (await rolYetki(db, 'service_role', UC[0])) === true);
kontrol('B5 tr_normalize: anon kapalı', (await rolYetki(db, 'anon', UC[1])) === false);
kontrol('B6 tr_normalize: PUBLIC kapalı', (await publicYetki(db, UC[1])) === false);
kontrol('B7 tr_normalize: authenticated açık', (await rolYetki(db, 'authenticated', UC[1])) === true);
kontrol('B8 tr_normalize: service_role açık', (await rolYetki(db, 'service_role', UC[1])) === true);
kontrol('B9 hafta_baslangic: anon kapalı', (await rolYetki(db, 'anon', UC[2])) === false);
kontrol('B10 hafta_baslangic: PUBLIC kapalı', (await publicYetki(db, UC[2])) === false);
kontrol('B11 hafta_baslangic: authenticated açık', (await rolYetki(db, 'authenticated', UC[2])) === true);

console.log('  Yan etki ve çağrı davranışı:');
kontrol('B12 kontrol_fonksiyon: anon hâlâ açık (başka fonksiyona dokunulmadı)',
  (await rolYetki(db, 'anon', 'public.kontrol_fonksiyon()')) === true);
{
  const r = await rolde(db, 'anon', `select public.ornek_definer_cagri('Ğül') as r`);
  kontrol('B13 SECURITY DEFINER çağıran anon ile çalışır (iç çağrı kırılmaz)',
    r.veri?.r?.startsWith('gul|'), JSON.stringify(r));
}
{
  const r = await rolde(db, 'authenticated', `select public.ornek_definer_cagri('Ğül') as r`);
  kontrol('B14 SECURITY DEFINER çağıran authenticated ile çalışır', r.veri?.r?.startsWith('gul|'), JSON.stringify(r));
}
{
  const r = await rolde(db, 'anon', `select public.tr_normalize('Ğül') as r`);
  kontrol('B15 anon doğrudan tr_normalize çağıramaz (42501)', r.hata === '42501', JSON.stringify(r));
}
{
  const r = await rolde(db, 'anon', `select public.hafta_baslangic() as r`);
  kontrol('B16 anon doğrudan hafta_baslangic çağıramaz (42501)', r.hata === '42501', JSON.stringify(r));
}
{
  const r = await rolde(db, 'authenticated', `select public.set_updated_at() as r`);
  kontrol('B17 authenticated set_updated_at çağıramaz (42501)', r.hata === '42501', JSON.stringify(r));
}
{
  const r = await rolde(db, 'authenticated', `select public.tr_normalize('Ğül') as r`);
  kontrol('B18 authenticated tr_normalize çağırabilir', r.veri?.r === 'gul', JSON.stringify(r));
}
{
  const r = await rolde(db, 'anon', `select public.ornek_invoker_cagri('Ğül') as r`);
  kontrol('B19 INVOKER çağıran anon için kapanır (beklenen; repoda INVOKER çağıran yok)',
    r.hata === '42501', JSON.stringify(r));
}
{
  // Tablo üretilen sütun: service_role insert'i tr_normalize'ı çalıştırabilmeli.
  const r = await rolde(db, 'service_role',
    `insert into public.questions_stub (soru_metni) values ('Ğül') returning arama_vektoru::text as v`);
  kontrol('B20 service_role insert: üretilen sütun çalışır', typeof r.veri?.v === 'string' && r.veri.v.includes("'gul'"),
    JSON.stringify(r));
}
{
  const r = await rolde(db, 'anon', `insert into public.questions_stub (soru_metni) values ('x') returning id`);
  kontrol('B21 anon insert reddedilir; neden tr_normalize yetkisi (yazma yolu yok)', r.hata === '42501' && /tr_normalize/.test(r.mesaj ?? ''), JSON.stringify(r));
}

await db.close();

// --- Sonuç ---
console.log(`\nSonuç: ${gecen} geçti, ${kalan} kaldı`);
if (kalan > 0) process.exit(1);
