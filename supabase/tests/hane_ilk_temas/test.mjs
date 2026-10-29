// hane_ilk_temas_yaz: gerçek migration dosyası PGlite üzerinde, en küçük stub ile.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney')],
})).href);

const MIG = path.resolve(HERE, '../../migrations/20261127000000_hane_ilk_temas_utm.sql');
const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const hataBul = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: e.code ?? '', mesaj: String(e.message ?? e) }; }
};
const istemci = (uid) => db.exec(`set request.jwt.claims = '{"sub":"${uid}"}';`);
const anonim = () => db.exec(`set request.jwt.claims = '';`);
const satir = async (id) => (await db.query(
  'select utm_source, utm_medium, utm_campaign, utm_content from public.growth_households where id = $1', [id])).rows[0];

const VELI = '00000000-0000-4000-8000-000000000002';
const VELI2 = '00000000-0000-4000-8000-000000000004';
const YOK = '00000000-0000-4000-8000-000000000009';
const H1 = '10000000-0000-4000-8000-000000000001';
const H2 = '10000000-0000-4000-8000-000000000002';

console.log('\n== Kurulum ==');
await db.exec(`
  do $$ begin
    if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon; end if;
    if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated; end if;
  end $$;
  create schema if not exists auth;
  create or replace function auth.uid() returns uuid language sql stable as $$
    select nullif(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub', '')::uuid
  $$;
  create table public.growth_households (
    id uuid primary key,
    core_parent_user_id uuid,
    utm_source text, utm_medium text, utm_campaign text
  );
  insert into public.growth_households (id, core_parent_user_id) values
    ('${H1}', '${VELI}'), ('${H2}', '${VELI2}');
`);
await db.exec(fs.readFileSync(MIG, 'utf8'));
await db.exec(fs.readFileSync(MIG, 'utf8')); // idempotent: ikinci uygulama hata vermemeli
ok('migration iki kez uygulanır', true);

const cagir = async (utm) => (await db.query(
  'select public.hane_ilk_temas_yaz($1::jsonb) as r', [JSON.stringify(utm)])).rows[0].r;

console.log('\n== Davranış ==');
await istemci(VELI);
ok('geçerli UTM yazılır (true)', (await cagir({
  utm_source: 'instagram', utm_medium: 'sosyal', utm_campaign: 'sm-t0-h1', utm_content: 'g01',
})) === true);
let s = await satir(H1);
ok('dört alan kendi kartına yazıldı',
  s.utm_source === 'instagram' && s.utm_medium === 'sosyal' && s.utm_campaign === 'sm-t0-h1' && s.utm_content === 'g01',
  JSON.stringify(s));

await cagir({ utm_source: 'youtube', utm_campaign: 'baska' });
s = await satir(H1);
ok('ilk temas ezilmez', s.utm_source === 'instagram' && s.utm_campaign === 'sm-t0-h1', JSON.stringify(s));

ok('başka velinin kartı etkilenmedi', (await satir(H2)).utm_source === null);

await istemci(VELI2);
ok('e-posta içeren değer reddedilir', (await cagir({ utm_source: 'ali@ornek.com' })) === false);
ok('URL içeren değer reddedilir', (await cagir({ utm_source: 'https://x.com' })) === false);
ok('boşluklu değer reddedilir', (await cagir({ utm_source: 'a b' })) === false);
ok('101 karakter reddedilir', (await cagir({ utm_source: 'a'.repeat(101) })) === false);
ok('metin olmayan değer reddedilir', (await cagir({ utm_source: 5, utm_medium: { a: 1 } })) === false);
ok('utm_term kabul edilmez', (await cagir({ utm_term: 'anahtar' })) === false);
s = await satir(H2);
ok('reddedilenler kartı değiştirmedi', Object.values(s).every((v) => v === null), JSON.stringify(s));
ok('kısmen geçerli girdi yalnız geçerli alanı yazar',
  (await cagir({ utm_source: 'ali@ornek.com', utm_medium: 'sosyal' })) === true && (await satir(H2)).utm_medium === 'sosyal'
  && (await satir(H2)).utm_source === null);
ok('nesne olmayan girdi false', (await cagir(['x'])) === false);

await istemci(YOK);
ok('kartı olmayan kullanıcı false', (await cagir({ utm_source: 'instagram' })) === false);

console.log('\n== Yetki ==');
await anonim();
const h = await hataBul(() => cagir({ utm_source: 'instagram' }));
ok('oturumsuz çağrı 42501', h && h.kod === '42501', JSON.stringify(h));

await db.exec('reset role;');
const yetki = (await db.query(`
  select has_function_privilege('anon', 'public.hane_ilk_temas_yaz(jsonb)', 'execute') as anon,
         has_function_privilege('authenticated', 'public.hane_ilk_temas_yaz(jsonb)', 'execute') as auth`)).rows[0];
ok('anon çalıştıramaz, authenticated çalıştırır', yetki.anon === false && yetki.auth === true, JSON.stringify(yetki));

console.log(`\n${pass} geçti, ${fail} kaldı`);
process.exit(fail ? 1 : 0);
