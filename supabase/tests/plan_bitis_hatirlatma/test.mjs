// Web planı bitiş hatırlatması (20261216000000) testi.
// Bağımlılıklar (profiles, plans, subscriptions, bildirim_gonder) en küçük stub'larla kurulur;
// bildirim_gonder çağrıları bir tabloya yazılır. PGlite (gerçek Postgres), Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node test.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const YENI = '20261216000000_plan_bitis_hatirlatma.sql';

const db = new PGlite();
process.on('uncaughtException', (e) => { console.log('HATA:', e.message ?? e); process.exit(1); });

let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;

console.log('\n== Kurulum: stub + migration ==');
await db.exec(`
  create role anon; create role authenticated;
  create table public.profiles (id uuid primary key);
  create table public.plans (kod text primary key, ad text not null, fiyat_kurus int not null, sure_gun int not null);
  create table public.subscriptions (
    id uuid primary key default gen_random_uuid(),
    veli_id uuid not null references public.profiles (id),
    plan_kod text not null references public.plans (kod),
    durum text not null, baslangic timestamptz not null, bitis timestamptz not null, saglayici text);
  create table public.gonderilen (alici uuid, baslik text, mesaj text, eposta boolean);
  create function public.bildirim_gonder(p_alici uuid, p_baslik text, p_mesaj text, p_eposta boolean default false)
  returns void language sql as $$ insert into public.gonderilen values (p_alici, p_baslik, p_mesaj, p_eposta); $$;
`);
const sql = fs.readFileSync(path.join(MIG, YENI), 'utf8');
await db.exec(sql);
ok('migration hatasız (pg_cron yokken zamanlayıcı atlanır)', true);
await db.exec(sql);
ok('migration ikinci kez hatasız (idempotent)', true);

// Sabit "şimdi": 2026-12-01 07:00 UTC
const SIMDI = '2026-12-01T07:00:00Z';
const gun = (n) => `('${SIMDI}'::timestamptz + interval '${n} days')`;

await db.exec(`
  insert into public.plans values ('tam_yillik','Tam',159900,365), ('tam_aylik','Tam Aylık',19900,30), ('deneme','Deneme',0,14);
  insert into public.profiles select ('00000000-0000-4000-8000-' || lpad(i::text, 12, '0'))::uuid from generate_series(1, 20) i;
`);
const abone = (n, plan, bas, bit, saglayici = 'iyzico', durum = 'aktif') => db.exec(`
  insert into public.subscriptions (id, veli_id, plan_kod, durum, baslangic, bitis, saglayici)
  values ('${id(100 + n)}', '${id(n)}', '${plan}', '${durum}', ${bas}, ${bit}, '${saglayici}');`);

// V1: yıllık, 30 gün kala (29,5 gün) → 30 gün hatırlatması
await abone(1, 'tam_yillik', gun(-335), `(${gun(29)} + interval '12 hours')`);
// V2: yıllık, 6,5 gün kala → 7 gün hatırlatması
await abone(2, 'tam_yillik', gun(-358), `(${gun(6)} + interval '12 hours')`);
// V3: yıllık, 10 saat kala → 1 gün hatırlatması
await abone(3, 'tam_yillik', gun(-364), `(${gun(0)} + interval '10 hours')`);
// V4: aylık plan, 29,5 gün kala → 30 gün hatırlatması ATLANIR (süre < 60 gün)
await abone(4, 'tam_aylik', gun(0), `(${gun(29)} + interval '12 hours')`);
// V5: Apple aboneliği 6,5 gün kala → kapsam dışı
await abone(5, 'tam_yillik', gun(-358), `(${gun(6)} + interval '12 hours')`, 'apple');
// V6: ücretsiz deneme 6,5 gün kala → kapsam dışı
await abone(6, 'deneme', gun(-30), `(${gun(6)} + interval '12 hours')`, 'manuel');
// V7: 6,5 gün kala ama daha uzun süren ikinci aboneliği var (yenilemiş) → gönderilmez
await abone(7, 'tam_yillik', gun(-358), `(${gun(6)} + interval '12 hours')`);
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis, saglayici)
  values ('${id(7)}', 'tam_yillik', 'aktif', ${gun(0)}, ${gun(372)}, 'iyzico');`);
// V8: iptal edilmiş abonelik → gönderilmez
await abone(8, 'tam_yillik', gun(-358), `(${gun(6)} + interval '12 hours')`, 'iyzico', 'iptal');
// V9: 15 gün kala → hiçbir pencerede değil
await abone(9, 'tam_yillik', gun(-350), gun(15));

console.log('\n== Gönderim ==');
const n1 = (await sorgu(`select public.plan_bitis_hatirlatmalarini_gonder($1) as n`, [SIMDI]))[0].n;
ok('ilk çalıştırmada 3 hatırlatma (V1, V2, V3)', n1 === 3, `gelen ${n1}`);

const g = await sorgu(`select alici, baslik, mesaj, eposta from public.gonderilen order by alici`);
const kime = g.map((r) => r.alici);
ok('alıcılar V1, V2, V3', JSON.stringify(kime) === JSON.stringify([id(1), id(2), id(3)]), JSON.stringify(kime));
ok('hepsi e-posta da gönderir', g.every((r) => r.eposta === true));
ok('V1 başlığı 30 gün metni ve Türkçe tarih',
  g[0]?.baslik === 'Planınız 30 Aralık 2026 tarihinde bitiyor', g[0]?.baslik);
ok('V2 başlığı 7 gün metni', g[1]?.baslik.startsWith('Planınız 7 gün sonra, 7 Aralık 2026'), g[1]?.baslik);
ok('V3 başlığı "yarın" metni', g[2]?.baslik.startsWith('Planınız yarın, 1 Aralık 2026'), g[2]?.baslik);
ok('mesajda plan adı var', g[0]?.mesaj.startsWith('Tam planınız'), g[0]?.mesaj);
ok('mesajda indirim/fiyat/kampanya dili yok',
  g.every((r) => !/(indirim|%|TL|kampanya|fırsat|kaçırma|son şans)/i.test(r.baslik + ' ' + r.mesaj)));
ok('başlıklar ≤ 60 karakter', g.every((r) => r.baslik.length <= 60), g.map((r) => r.baslik.length).join(','));
ok('mesajlar ≤ 220 karakter', g.every((r) => r.mesaj.length <= 220), g.map((r) => r.mesaj.length).join(','));

const n2 = (await sorgu(`select public.plan_bitis_hatirlatmalarini_gonder($1) as n`, [SIMDI]))[0].n;
ok('aynı gün ikinci çalıştırma 0 gönderir (idempotent)', n2 === 0, `gelen ${n2}`);

// 23 gün sonra V1, 7 gün penceresine girer
const n3 = (await sorgu(`select public.plan_bitis_hatirlatmalarini_gonder($1::timestamptz + interval '23 days') as n`, [SIMDI]))[0].n;
ok('23 gün sonra V1 için 7 gün hatırlatması (V4 aylık da 7 gün penceresinde)', n3 === 2, `gelen ${n3}`);

console.log('\n== Yetki ==');
const yetki = await sorgu(`select has_function_privilege('authenticated', 'public.plan_bitis_hatirlatmalarini_gonder(timestamptz)', 'execute') as e`);
ok('authenticated çalıştıramaz', yetki[0].e === false);
const tablo = await sorgu(`select has_table_privilege('authenticated', 'public.plan_bitis_hatirlatmalari', 'select') as e`);
ok('authenticated kayıt tablosunu okuyamaz', tablo[0].e === false);

console.log(`\n${pass} geçti, ${fail} kaldı`);
process.exit(fail ? 1 : 0);
