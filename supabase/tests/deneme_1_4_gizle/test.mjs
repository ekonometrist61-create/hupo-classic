// Deneme 1-4. sınıf puan/sıra gizleme: minimal stub şema + migration 20261138000000 (PGlite).
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney')],
})).href);

const MIG = path.resolve(HERE, '../../migrations/20261138000000_deneme_1_4_puan_sira_gizle.sql');

const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const tek = async (sql, p = []) => (await db.query(sql, p)).rows[0];
const hataBul = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: e.code ?? '', mesaj: String(e.message ?? e) }; }
};
const istemci = (uid) => db.exec(`set request.jwt.claims = '{"sub":"${uid}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);
const J = (v) => JSON.stringify(v);

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const VELI = id(1), S3 = id(3), S5 = id(5), S5B = id(6);
const EX0 = id(100), EX1 = id(101), EX2 = id(102), EX3 = id(103);
const Q = [id(201), id(202), id(203), id(204)];

console.log('\n== Kurulum ==');
await db.exec(`
  create role anon nologin; create role authenticated nologin; create role service_role nologin;
  create schema auth;
  create table auth.users (id uuid primary key, email text);
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub', '')::uuid $$;

  create table public.profiles (id uuid primary key, full_name text, username text,
    sinif smallint, parent_id uuid, role text);
  create table public.deneme_sinavlari (id uuid primary key, ad text, baslangic_zamani timestamptz,
    sure_dakika int, aktif boolean default true, siniflar smallint[] default '{}');
  create table public.deneme_sinavi_denemeleri (id uuid primary key default gen_random_uuid(),
    exam_id uuid, student_id uuid, sinif smallint, puan numeric, dogru_sayisi smallint,
    yanlis_sayisi smallint, bos_sayisi smallint, bitis_zamani timestamptz, started_at timestamptz,
    supheli boolean, teslim_turu text);
  create table public.deneme_sinavi_sorulari (exam_id uuid, sinif smallint, question_id uuid, sira int);
  create table public.deneme_sinavi_cevaplari (deneme_id uuid, question_id uuid, secilen_sik text,
    dogru boolean, cevap_zamani timestamptz, unique (deneme_id, question_id));
  create table public.questions (id uuid primary key, dogru_sik text);
  create table public.olay_kutusu (id uuid primary key default gen_random_uuid(), tur text, payload jsonb);

  create function public.current_user_role() returns text language sql stable as
    $$ select role from public.profiles where id = auth.uid() $$;
  create function public.require_admin() returns void language plpgsql as $$ begin end $$;
  create function public.deneme_ana_profil(p uuid) returns uuid language sql stable as $$ select p $$;
  create function public.is_parent_of(p uuid) returns boolean language sql stable as
    $$ select exists (select 1 from public.profiles where id = p and parent_id = auth.uid()) $$;
  create function public._deneme_bitis_zamani(e public.deneme_sinavlari) returns timestamptz
    language sql stable as $$ select now() + interval '1 hour' $$;
`);
const migHata = await hataBul(() => db.exec(fs.readFileSync(MIG, 'utf8')));
ok('migration hatasız uygulandı', migHata === null, J(migHata));

await db.exec(`
  insert into auth.users values ('${VELI}', 'veli@example.com');
  insert into public.profiles values
    ('${VELI}', 'Veli Ad', 'veli', null, null, 'veli'),
    ('${S3}',  'Ogr Uc',  'ogr3', 3, '${VELI}', 'ogrenci'),
    ('${S5}',  'Ogr Bes', 'ogr5', 5, '${VELI}', 'ogrenci'),
    ('${S5B}', 'Ogr Bes B', 'ogr5b', 5, null, 'ogrenci');
  insert into public.questions values ${Q.map((q) => `('${q}','A')`).join(',')};
  insert into public.deneme_sinavlari values
    ('${EX0}', 'Eski', now() - interval '10 days', 40, true, '{3,5}'),
    ('${EX1}', 'Sinav 1', now() - interval '5 days', 40, true, '{3,5}'),
    ('${EX2}', 'Sinav 2', now() - interval '2 days', 40, true, '{3,5}'),
    ('${EX3}', 'Sinav 3', now() - interval '1 days', 40, true, '{3,5}');
  insert into public.deneme_sinavi_sorulari
    select e, s, q, row_number() over ()
      from unnest(array['${EX2}','${EX3}']::uuid[]) e,
           unnest(array[3,5]::smallint[]) s,
           unnest(array['${Q[0]}','${Q[1]}']::uuid[]) q;
  -- Biten denemeler (EX0: önceki, EX1: sonuç okuma)
  insert into public.deneme_sinavi_denemeleri
    (exam_id, student_id, sinif, puan, dogru_sayisi, yanlis_sayisi, bos_sayisi, bitis_zamani, started_at, supheli, teslim_turu) values
    ('${EX0}','${S3}', 3, 40, 4, 3, 3, now() - interval '9 days', now() - interval '9 days', false, 'elle'),
    ('${EX0}','${S5}', 5, 40, 4, 3, 3, now() - interval '9 days', now() - interval '9 days', false, 'elle'),
    ('${EX1}','${S3}', 3, 70, 7, 2, 1, now() - interval '4 days', now() - interval '4 days', false, 'elle'),
    ('${EX1}','${S5}', 5, 60, 6, 3, 1, now() - interval '4 days', now() - interval '4 days', false, 'elle'),
    ('${EX1}','${S5B}',5, 90, 9, 1, 0, now() - interval '4 days', now() - interval '4 days', false, 'elle');
`);

console.log('\n== 1. _deneme_puan_gorunur ==');
const g = async (v) => (await tek(`select public._deneme_puan_gorunur(${v}::smallint) as r`)).r;
ok('1,2,3,4 -> false', (await g(1)) === false && (await g(2)) === false && (await g(3)) === false && (await g(4)) === false);
ok('5,8 -> true', (await g(5)) === true && (await g(8)) === true);
ok('null -> false', (await g('null')) === false);

console.log('\n== 2. get_child_exam_history ==');
await istemci(VELI);
const h3 = (await tek(`select public.get_child_exam_history($1) as r`, [S3])).r.find((x) => x.sinav_id === EX1);
const h5 = (await tek(`select public.get_child_exam_history($1) as r`, [S5])).r.find((x) => x.sinav_id === EX1);
ok('sınıf 3: puan/sira/sinif_katilimci null', h3.puan === null && h3.sira === null && h3.sinif_katilimci === null, J(h3));
ok('sınıf 3: dogru/yanlis/bos dolu', h3.dogru === 7 && h3.yanlis === 2 && h3.bos === 1, J(h3));
ok('sınıf 5: puan ve sira dolu', Number(h5.puan) === 60 && Number(h5.sira) === 2 && Number(h5.sinif_katilimci) === 2, J(h5));

console.log('\n== 3. admin_get_mock_exam_results ==');
await istemci(VELI);
const a = (await db.query(`select * from public.admin_get_mock_exam_results($1)`, [EX1])).rows;
const a3 = a.find((x) => x.student_id === S3);
const a5 = a.find((x) => x.student_id === S5);
const a5b = a.find((x) => x.student_id === S5B);
ok('sınıf 3: puan ve sira null, sayılar dolu', a3.puan === null && a3.sira === null && a3.dogru_sayisi === 7, J(a3));
ok('sınıf 5: puan ve sira dolu', Number(a5.puan) === 60 && Number(a5.sira) === 2 && Number(a5b.sira) === 1, J([a5, a5b]));
ok('sıralama bozulmamış (sinif, puan desc)', a.map((x) => x.student_id).join() === [S3, S5B, S5].join(), a.map((x) => x.student_id).join());

console.log('\n== 4. list_my_exams ==');
await istemci(S3);
const l3 = (await tek(`select public.list_my_exams() as r`)).r.find((x) => x.id === EX1);
await istemci(S5);
const l5 = (await tek(`select public.list_my_exams() as r`)).r.find((x) => x.id === EX1);
ok('sınıf 3: puan null, dogru_sayisi dolu, bitti', l3.puan === null && l3.dogru_sayisi === 7 && l3.bitti === true, J(l3));
ok('sınıf 5: puan dolu', Number(l5.puan) === 60, J(l5));

console.log('\n== 5. get_mock_exam_result ==');
await istemci(S3);
const r3 = (await tek(`select public.get_mock_exam_result($1) as r`, [EX1])).r;
await istemci(S5);
const r5 = (await tek(`select public.get_mock_exam_result($1) as r`, [EX1])).r;
ok('sınıf 3: puan/sira/toplam null', r3.puan === null && r3.sira === null && r3.toplam === null, J(r3));
ok('sınıf 3: sayılar dolu, onceki_deneme.puan null', r3.dogru_sayisi === 7 && r3.yanlis_sayisi === 2 && r3.bos_sayisi === 1
  && r3.onceki_deneme && r3.onceki_deneme.puan === null && r3.onceki_deneme.ad === 'Eski', J(r3));
ok('sınıf 5: puan/sira/toplam dolu', Number(r5.puan) === 60 && Number(r5.sira) === 2 && Number(r5.toplam) === 2
  && Number(r5.onceki_deneme.puan) === 40, J(r5));

console.log('\n== 6. submit_mock_exam ==');
await servis();
const d6 = {};
for (const [k, uid, s] of [['3', S3, 3], ['5', S5, 5]]) {
  d6[k] = (await tek(`insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif, started_at)
    values ($1,$2,$3, now() - interval '5 minutes') returning id`, [EX2, uid, s])).id;
}
const cev = J([{ question_id: Q[0], secilen_sik: 'A' }, { question_id: Q[1], secilen_sik: 'B' }]);
await istemci(S3);
const s3 = (await tek(`select public.submit_mock_exam($1, $2::jsonb) as r`, [d6['3'], cev])).r;
await istemci(S5);
const s5 = (await tek(`select public.submit_mock_exam($1, $2::jsonb) as r`, [d6['5'], cev])).r;
ok('sınıf 3: puan null, dogru_sayisi doğru', s3.puan === null && s3.dogru_sayisi === 1 && s3.yanlis_sayisi === 1 && s3.toplam === 2, J(s3));
ok('sınıf 5: puan dolu (50)', Number(s5.puan) === 50 && s5.dogru_sayisi === 1, J(s5));

console.log('\n== 7. _deneme_sinavi_bitir ==');
await servis();
const d7 = {};
for (const [k, uid, s] of [['3', S3, 3], ['5', S5, 5]]) {
  d7[k] = (await tek(`insert into public.deneme_sinavi_denemeleri (exam_id, student_id, sinif, started_at)
    values ($1,$2,$3, now() - interval '5 minutes') returning id`, [EX3, uid, s])).id;
  await db.query(`insert into public.deneme_sinavi_cevaplari values ($1,$2,'A',true,now()), ($1,$3,'B',false,now())`,
    [d7[k], Q[0], Q[1]]);
}
const b3 = (await tek(`select public._deneme_sinavi_bitir($1) as r`, [d7['3']])).r;
const b5 = (await tek(`select public._deneme_sinavi_bitir($1) as r`, [d7['5']])).r;
ok('sınıf 3: dönüş puan null, dogru doğru', b3.puan === null && b3.dogru_sayisi === 1 && b3.yanlis_sayisi === 1, J(b3));
ok('sınıf 5: dönüş puan dolu', Number(b5.puan) === 50, J(b5));
const o = (await db.query(`select payload from public.olay_kutusu where tur='deneme_sonuc_bildirimi' order by payload->>'student_id'`)).rows.map((x) => x.payload);
const o3 = o.find((x) => x.student_id === S3), o5 = o.find((x) => x.student_id === S5);
ok('sınıf 3: olay payload puan ve sira null (anahtarlar var)', o3 && o3.puan === null && o3.sira === null && 'puan' in o3 && 'sira' in o3, J(o3));
ok('sınıf 5: olay payload puan ve sira dolu', o5 && Number(o5.puan) === 50 && Number(o5.sira) === 1, J(o5));
const b3b = (await tek(`select public._deneme_sinavi_bitir($1) as r`, [d7['3']])).r;
ok('sınıf 3: tekrar çağrı (bitmiş dal) puan null', b3b.puan === null && b3b.dogru_sayisi === 1, J(b3b));

console.log('\n== 8. deneme_bildirim_alici ==');
await servis();
const n3 = (await tek(`select public.deneme_bildirim_alici($1,$2) as r`, [EX1, S3])).r;
const n5 = (await tek(`select public.deneme_bildirim_alici($1,$2) as r`, [EX1, S5])).r;
ok('sınıf 3: puan/sira/katilimci null', n3.puan === null && n3.sira === null && n3.katilimci === null, J(n3));
ok('sınıf 3: dogru/yanlis/bos ve veli_eposta dolu', n3.dogru === 7 && n3.yanlis === 2 && n3.bos === 1 && n3.veli_eposta === 'veli@example.com', J(n3));
ok('sınıf 5: puan/sira/katilimci dolu', Number(n5.puan) === 60 && Number(n5.sira) === 2 && Number(n5.katilimci) === 2, J(n5));

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail ? 1 : 0);

