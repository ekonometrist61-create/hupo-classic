// Veli okuma kapısı (K-0257 / GÖR-113) testi: 20261220000000 PGlite (gerçek Postgres) üzerinde.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
//
// Kapsam (tablolar RLS ile, roller authenticated):
// - rıza "verildi": veli çocuğun satırlarını okur
// - rıza "geri_cekildi" ve "yok": veli 0 satır görür (user_answers, answer_events, user_badges,
//   student_stats, xp_events, quest_claims, kelime_denemeleri, kelime_ustaliklari)
// - çocuk kendi satırlarını her rıza durumunda okur
// - başka ailenin velisi hiçbir durumda okuyamaz
// - consents tablosu muaf: veli rıza geçmişini her durumda görür
// - get_daily_goal / get_profile_overview / get_child_topic_progress / get_league_status:
//   rızasız veli 42501 alır; rızalı veli ve çocuk çalışır
// - veli_okuyabilir anon'a kapalı
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const YENI = '20261220000000_veli_riza_kapisi_tablolar.sql';

const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const hatayiAl = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: String(e.code ?? ''), mesaj: String(e.message ?? e) }; }
};

const VELI = '00000000-0000-0000-0000-0000000000a1';
const COCUK = '00000000-0000-0000-0000-0000000000c1';
const YABANCI_VELI = '00000000-0000-0000-0000-0000000000b9';

// Taban: yalnızca migration'ın dokunduğu nesnelerin küçük taklidi.
await db.exec(`
  do $$ begin
    if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
    if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  end $$;
  create schema if not exists auth;
  create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('test.uid', true), '')::uuid $$;
  grant usage on schema public, auth to anon, authenticated;

  create table public.profiles (id uuid primary key, parent_id uuid, role text);
  create table public.consents (id bigserial primary key, cocuk_id uuid, tur text,
    created_at timestamptz default now());

  create function public.is_parent_of(p_student_id uuid) returns boolean
    language sql stable security definer set search_path = '' as $$
    select exists (select 1 from public.profiles where id = p_student_id and parent_id = (select auth.uid())) $$;
  create function public._veli_riza_durumu(p_cocuk_id uuid) returns text
    language plpgsql stable security definer set search_path = '' as $$
    declare v_tur text; begin
      select c.tur into v_tur from public.consents c
       where c.cocuk_id = p_cocuk_id and c.tur in ('veli_acik_riza','veli_riza_geri_cekildi')
       order by c.created_at desc, c.id desc limit 1;
      return case when v_tur is null then 'yok' when v_tur = 'veli_acik_riza' then 'verildi' else 'geri_cekildi' end;
    end; $$;

  create table public.user_answers (id bigserial primary key, student_id uuid, question_id uuid,
    dogru_sayisi int default 0, deneme_sayisi int default 0);
  create table public.answer_events (id bigserial primary key, student_id uuid,
    created_at timestamptz default now());
  create table public.user_badges (id bigserial primary key, student_id uuid);
  create table public.student_stats (student_id uuid primary key, gunluk_hedef int default 10,
    seri_kalkani int default 0, en_uzun_seri int default 0);
  create table public.xp_events (id bigserial primary key, student_id uuid);
  create table public.quest_claims (id bigserial primary key, student_id uuid);
  create table public.kelime_denemeleri (id bigserial primary key, ogrenci_id uuid);
  create table public.kelime_ustaliklari (id bigserial primary key, ogrenci_id uuid);
  create table public.questions (id uuid primary key default gen_random_uuid(), ders text, onay_durumu text);
  -- get_league_status bildirim bölümünde çağırır (kapıdan önce); yalnız fixture için.
  create function public.hafta_baslangic() returns date language sql stable as
    $$ select date_trunc('week', now())::date $$;

  -- Eski politikalar (is_parent_of): migration bunları yeniler.
  do $$ declare t text; begin
    foreach t in array array['user_answers','answer_events','user_badges','student_stats','xp_events','quest_claims'] loop
      execute format('alter table public.%I enable row level security', t);
      execute format('create policy %I on public.%I for select to authenticated using (student_id = (select auth.uid()) or is_parent_of(student_id))', t||'_select', t);
    end loop;
    foreach t in array array['kelime_denemeleri','kelime_ustaliklari'] loop
      execute format('alter table public.%I enable row level security', t);
    end loop;
  end $$;
  create policy "kelime denemeleri ogrenci ve veli okur" on public.kelime_denemeleri
    for select to authenticated using (ogrenci_id = (select auth.uid()) or (select is_parent_of(ogrenci_id)));
  create policy "kelime ustaliklari ogrenci ve veli okur" on public.kelime_ustaliklari
    for select to authenticated using (ogrenci_id = (select auth.uid()) or (select is_parent_of(ogrenci_id)));
  alter table public.consents enable row level security;
  create policy consents_select on public.consents for select to authenticated
    using (cocuk_id = (select auth.uid()) or is_parent_of(cocuk_id));

  grant select on all tables in schema public to authenticated;
  grant execute on all functions in schema public to authenticated;

  insert into public.profiles values ('${VELI}', null, 'veli'), ('${COCUK}', '${VELI}', 'ogrenci'),
    ('${YABANCI_VELI}', null, 'veli');
  insert into public.user_answers (student_id) values ('${COCUK}'), ('${COCUK}');
  insert into public.answer_events (student_id) values ('${COCUK}');
  insert into public.user_badges (student_id) values ('${COCUK}');
  insert into public.student_stats (student_id) values ('${COCUK}');
  insert into public.xp_events (student_id) values ('${COCUK}');
  insert into public.quest_claims (student_id) values ('${COCUK}');
  insert into public.kelime_denemeleri (ogrenci_id) values ('${COCUK}');
  insert into public.kelime_ustaliklari (ogrenci_id) values ('${COCUK}');
`);

await db.exec(fs.readFileSync(path.join(MIG, YENI), 'utf8'));
await db.exec(fs.readFileSync(path.join(MIG, YENI), 'utf8'));
ok('migration iki kez hatasız uygulanır', true);

const TABLOLAR = [
  ['user_answers', 'student_id'], ['answer_events', 'student_id'], ['user_badges', 'student_id'],
  ['student_stats', 'student_id'], ['xp_events', 'student_id'], ['quest_claims', 'student_id'],
  ['kelime_denemeleri', 'ogrenci_id'], ['kelime_ustaliklari', 'ogrenci_id'],
];

// Rol ve kimlik ayarlar, sorguyu çalıştırır, superuser'a döner.
const olarak = async (uid, sql, params = []) => {
  await db.exec(`set role authenticated; select set_config('test.uid', '${uid}', false);`);
  try { return (await db.query(sql, params)).rows; }
  finally { await db.exec(`reset role; select set_config('test.uid', '', false);`); }
};
const say = async (uid, tablo) => (await olarak(uid, `select count(*)::int n from public.${tablo}`))[0].n;
const rizaYaz = (tur) => db.query(`insert into public.consents (cocuk_id, tur) values ($1, $2)`, [COCUK, tur]);

// 1) rıza yok
for (const [t] of TABLOLAR) {
  ok(`rıza yok: veli ${t} göremez`, (await say(VELI, t)) === 0);
}
ok('rıza yok: çocuk kendi user_answers satırını görür', (await say(COCUK, 'user_answers')) === 2);

// 2) rıza verildi
await rizaYaz('veli_acik_riza');
for (const [t] of TABLOLAR) {
  ok(`rıza verildi: veli ${t} görür`, (await say(VELI, t)) >= 1);
}
ok('rıza verildi: yabancı veli göremez', (await say(YABANCI_VELI, 'user_answers')) === 0);

// 3) geri çekildi
await rizaYaz('veli_riza_geri_cekildi');
for (const [t] of TABLOLAR) {
  ok(`geri çekildi: veli ${t} göremez`, (await say(VELI, t)) === 0);
  ok(`geri çekildi: çocuk kendi ${t} satırını görür`, (await olarak(COCUK, `select count(*)::int n from public.${t}`))[0].n >= 1);
}
ok('geri çekildi: consents veli için görünür (muaf)', (await say(VELI, 'consents')) === 2);

// 4) fonksiyonlar (rıza şu an geri çekildi)
const f = (uid, sql) => hatayiAl(() => olarak(uid, sql));
const hedef = `select public.get_daily_goal('${COCUK}')`;
const ozet = `select public.get_profile_overview('${COCUK}')`;
const konu = `select public.get_child_topic_progress('${COCUK}', 'Matematik')`;
const lig = `select public.get_league_status('${COCUK}')`;
for (const [ad, q] of [['get_daily_goal', hedef], ['get_profile_overview', ozet], ['get_child_topic_progress', konu], ['get_league_status', lig]]) {
  const h = await f(VELI, q);
  ok(`geri çekildi: veli ${ad} 42501 alır`, h?.kod === '42501', JSON.stringify(h));
}
// "İzinli" senaryoda kapı geçilir: hata yoksa ya da farklı bir hata varsa (fixture'da tabloların
// tüm sütunları yok) bu 42501 DEĞİLDİR; test yalnızca erişim kapısını doğrular.
const kapiGecildi = (h) => h === null || h.kod !== '42501';
ok('geri çekildi: çocuk get_daily_goal çalışır', (await f(COCUK, hedef)) === null);
ok('geri çekildi: çocuk get_profile_overview kapıdan geçer', kapiGecildi(await f(COCUK, ozet)));
ok('geri çekildi: çocuk get_league_status kapıdan geçer', kapiGecildi(await f(COCUK, lig)));

await rizaYaz('veli_acik_riza');
ok('rıza verildi: veli get_daily_goal çalışır', (await f(VELI, hedef)) === null);
ok('rıza verildi: veli get_profile_overview kapıdan geçer', kapiGecildi(await f(VELI, ozet)));
ok('rıza verildi: veli get_child_topic_progress kapıdan geçer', kapiGecildi(await f(VELI, konu)));
ok('rıza verildi: veli get_league_status kapıdan geçer', kapiGecildi(await f(VELI, lig)));
const yab = await f(YABANCI_VELI, hedef);
ok('yabancı veli get_daily_goal 42501 alır', yab?.kod === '42501', JSON.stringify(yab));

// 5) yetkiler
const yetki = (await db.query(`select
  has_function_privilege('anon','public.veli_okuyabilir(uuid)','EXECUTE') a,
  has_function_privilege('authenticated','public.veli_okuyabilir(uuid)','EXECUTE') u`)).rows[0];
ok('veli_okuyabilir anon\'a kapalı, authenticated\'a açık', !yetki.a && yetki.u, JSON.stringify(yetki));

console.log(`\n${pass} geçti, ${fail} başarısız`);
process.exit(fail ? 1 : 0);
