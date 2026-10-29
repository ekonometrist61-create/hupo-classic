// Growth analitik huni testi: gerçek migration zinciri PGlite (gerçek Postgres) üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const CEKIRDEK = '20261014000000_growth_crm_core.sql';
const WEB = '20261028000000_growth_web_olaylari.sql';
const YENI = '20261105000000_growth_analitik_huni.sql';

// PGlite'ta pgcrypto ve pg_cron eklentileri yok. Bu satırlar yalnızca harness'ta atlanır; dosya değişmez.
const eklentiSatiri = /^\s*create extension if not exists (pgcrypto|pg_cron)\b[^;]*;\s*$/gim;
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8')
  .replace(eklentiSatiri, "-- eklenti PGlite harness'ta atlandı");

const db = new PGlite();

let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const hataBekle = async (ad, fn, parca) => {
  try {
    await fn();
    fail++;
    console.log('  ✗', ad, '(hata bekleniyordu)');
  } catch (e) {
    const m = String(e.message ?? e);
    if (parca && !m.includes(parca)) { fail++; console.log('  ✗', ad, `beklenen "${parca}", gelen: ${m}`); }
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 90)); }
  }
};
const kur = async (ad, fn) => {
  try { await fn(); }
  catch (e) { console.log(`HATA [${ad}]: ${e.message}`); process.exit(1); }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const tek = async (sql, params = []) => (await sorgu(sql, params))[0];
const postgres = () => db.exec('reset role;');
const rolle = (rol) => db.exec(`reset role; set role ${rol};`);
// Oturum: auth.uid() bu değeri okur (stubs.sql). Rol değişince değer kalır.
const oturum = async (kullanici) => {
  await db.exec('reset role;');
  await db.query("select set_config('request.jwt.claim.sub', $1, false)", [kullanici]);
  await db.exec('set role authenticated;');
};

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const ADMIN = id(1);
const V = (n) => id(100 + n);   // veli profilleri (fonksiyon fixture'ı)
const K = (n) => id(200 + n);   // çocuk profilleri
const H = (n) => id(300 + n);   // huni fixture'ı hane kimlikleri
const ESKI1 = id(321), ESKI2 = id(322);
const S = (n) => id(400 + n);   // aktiflik fixture'ı öğrencileri
const Q = (n) => id(500 + n);   // soru kimlikleri
const P = (n) => id(600 + n);   // UTM fixture'ı velileri
const UH = (n) => id(700 + n);  // UTM fixture'ı haneleri

const huni = async (gun = 30) => (await tek('select public.admin_growth_funnel($1) as j', [gun])).j;
const utm = async (gun = 30) => (await tek('select public.admin_growth_utm_atif($1) as j', [gun])).j;
const aktif = async (gun = 30) => (await tek('select public.admin_growth_aktiflik($1) as j', [gun])).j;
const ozet = async (gun = 30) => (await tek('select public.admin_analitik_ozet($1) as j', [gun])).j;
const adim = (h, anahtar) => h.adimlar.find((a) => a.adim === anahtar);

console.log('\n== Kurulum: stub + gerçek migration zinciri (core → web olayları → analitik huni) ==');
await kur('stubs', () => db.exec(fs.readFileSync(path.join(HERE, 'stubs.sql'), 'utf8')));
await kur('growth core', () => db.exec(oku(CEKIRDEK)));
await kur('web olayları', () => db.exec(oku(WEB)));
await kur('analitik huni', () => db.exec(oku(YENI)));
ok('migration zinciri hatasız yüklendi', true);

// ---------------------------------------------------------------------
// FİKSTÜR 1: huni (10 kohort hanesi + 2 eski hane)
//   kayıt 10 | çocuklu 7 | ilk soru (user_answers) 5 | deneme 5 | ücretli 4 | churn 3
//   Eski haneler (100 gün önce) ve onların ödemesi sayılmamalı.
// ---------------------------------------------------------------------
await postgres();
await db.exec(`
  insert into public.profiles (id, role, full_name) values ('${ADMIN}', 'admin', 'Yönetici');
  insert into public.profiles (id, role, full_name) values
    ${[1,2,3,4,5,6,7,8,9,10,11,12].map((n) => `('${V(n)}', 'veli', 'Veli ${n}')`).join(',\n    ')};
  insert into public.profiles (id, role, parent_id, full_name) values
    ${[1,2,3,4,5,6,7].map((n) => `('${K(n)}', 'ogrenci', '${V(n)}', 'Çocuk ${n}')`).join(',\n    ')};
  insert into public.questions (id) values ('${Q(1)}'), ('${Q(2)}'), ('${Q(3)}');
  insert into public.user_answers (student_id, question_id, dogru_mu, son_cevap_tarihi, sonraki_tekrar_tarihi, dogru_sayisi)
    values
    ${[1,2,3,4,5].map((n) => `('${K(n)}', '${Q(1)}', true, now(), now() + interval '1 day', 1)`).join(',\n    ')};
  insert into public.growth_households (id, parent_name, email, core_parent_user_id, lifecycle, trial_started_at, created_at) values
    ${[1,2,3,4,5,6,7,8,9,10].map((n) => `('${H(n)}', 'Hane ${n}', 'h${n}@test.local', '${V(n)}',
        '${n >= 8 ? 'churned' : 'lead'}', ${n <= 5 ? 'now()' : 'null'}, now())`).join(',\n    ')},
    ('${ESKI1}', 'Eski 1', 'eski1@test.local', '${V(11)}', 'lead', now() - interval '100 days', now() - interval '100 days'),
    ('${ESKI2}', 'Eski 2', 'eski2@test.local', '${V(12)}', 'lead', null, now() - interval '100 days');
  insert into public.payments (veli_id, tutar_kurus, durum) values
    ${[1,2,3,4].map((n) => `('${V(n)}', 22900, 'basarili')`).join(',\n    ')},
    ('${V(6)}', 22900, 'beklemede'),
    ('${V(11)}', 22900, 'basarili');
`);

console.log('\n== A: huni sayıları (kolon yok → user_answers yedeği) ==');
await rolle('authenticated');
await db.exec("select set_config('request.jwt.claim.sub', '" + ADMIN + "', false);");
const h1 = await huni(30);
ok('kohort: 100 gün önceki haneler dışarıda, kayıt = 10', adim(h1, 'kayit').sayi === 10, JSON.stringify(adim(h1, 'kayit')));
ok('çocuk bağlı = 7', adim(h1, 'cocuk_bagli').sayi === 7, JSON.stringify(adim(h1, 'cocuk_bagli')));
ok('ilk soru (yedek) = 5', adim(h1, 'ilk_soru').sayi === 5, JSON.stringify(adim(h1, 'ilk_soru')));
ok('deneme başladı = 5', adim(h1, 'deneme_basladi').sayi === 5, JSON.stringify(adim(h1, 'deneme_basladi')));
ok('ilk soru kaynağı user_answers', h1.ilk_soru_kaynagi === 'user_answers', h1.ilk_soru_kaynagi);
ok('ücretli 4 → n<5 gizlendi (sayi null); eski haneki ödeme sayılmadı', adim(h1, 'ucretli').sayi === null, JSON.stringify(adim(h1, 'ucretli')));
ok('churn 3 → n<5 gizlendi (sayi null)', h1.churn.sayi === null, JSON.stringify(h1.churn));
ok('yüzde: çocuk bağlı kayıta oranı 70.0', adim(h1, 'cocuk_bagli').kayit_yuzde === 70, JSON.stringify(adim(h1, 'cocuk_bagli')));
ok('yüzde: ilk soru önceki adıma oranı 71.4 (5/7)', adim(h1, 'ilk_soru').onceki_yuzde === 71.4, JSON.stringify(adim(h1, 'ilk_soru')));
ok('yüzde: deneme kayda oranı 50.0', adim(h1, 'deneme_basladi').kayit_yuzde === 50, JSON.stringify(adim(h1, 'deneme_basladi')));
ok('yüzde: ücretli (gizli) → yüzde null', adim(h1, 'ucretli').kayit_yuzde === null && adim(h1, 'ucretli').onceki_yuzde === null);
ok('yüzde: kayıt adımı 100.0', adim(h1, 'kayit').kayit_yuzde === 100);
ok('eşik bilgisi 5', h1.esik === 5);

console.log('\n== B: W2 activated_at kolonu eklenince onu kullanır ==');
await postgres();
await db.exec(`
  alter table public.growth_households add column activated_at timestamptz;
  update public.growth_households set activated_at = now()
   where id in (${[1,2,3,4,5,6,7,8].map((n) => `'${H(n)}'`).join(',')});
`);
await rolle('authenticated');
await db.exec("select set_config('request.jwt.claim.sub', '" + ADMIN + "', false);");
const h2 = await huni(30);
ok('activated_at varsa ilk soru = 8 (yedek 5 değil)', adim(h2, 'ilk_soru').sayi === 8, JSON.stringify(adim(h2, 'ilk_soru')));
ok('ilk soru kaynağı activated_at', h2.ilk_soru_kaynagi === 'activated_at', h2.ilk_soru_kaynagi);
ok('activated_at: kayda oranı 80.0 ve önceki adıma oranı 114.3', adim(h2, 'ilk_soru').kayit_yuzde === 80 && adim(h2, 'ilk_soru').onceki_yuzde === 114.3, JSON.stringify(adim(h2, 'ilk_soru')));
ok('activated_at: diğer adımlar değişmedi (kayıt 10)', adim(h2, 'kayit').sayi === 10);

console.log('\n== C: yetki ve admin kapısı ==');
await oturum(V(1));
await hataBekle('admin olmayan huni çağrısı reddedilir', () => sorgu('select public.admin_growth_funnel(30)'), 'admin yetkisi');
await hataBekle('admin olmayan UTM çağrısı reddedilir', () => sorgu('select public.admin_growth_utm_atif(30)'), 'admin yetkisi');
await hataBekle('admin olmayan aktiflik çağrısı reddedilir', () => sorgu('select public.admin_growth_aktiflik(30)'), 'admin yetkisi');
await hataBekle('admin olmayan analitik özeti reddedilir', () => sorgu('select public.admin_analitik_ozet(30)'), 'admin yetkisi');
await postgres();
await db.exec('reset role;');
await db.exec('set role anon;');
await hataBekle('anon huni çağıramaz', () => sorgu('select public.admin_growth_funnel(30)'), 'permission denied');
await hataBekle('anon UTM çağıramaz', () => sorgu('select public.admin_growth_utm_atif(30)'), 'permission denied');
await postgres();
const yetki = await tek(`select
    has_function_privilege('anon', 'public.admin_growth_funnel(int)', 'EXECUTE') as a_huni,
    has_function_privilege('authenticated', 'public.admin_growth_funnel(int)', 'EXECUTE') as u_huni,
    has_function_privilege('anon', 'public.admin_growth_utm_atif(int)', 'EXECUTE') as a_utm,
    has_function_privilege('authenticated', 'public.admin_growth_utm_atif(int)', 'EXECUTE') as u_utm,
    has_function_privilege('anon', 'public.admin_growth_aktiflik(int)', 'EXECUTE') as a_akt,
    has_function_privilege('authenticated', 'public.admin_growth_aktiflik(int)', 'EXECUTE') as u_akt,
    has_function_privilege('anon', 'public.admin_analitik_ozet(integer)', 'EXECUTE') as a_ozet,
    has_function_privilege('authenticated', 'public.admin_analitik_ozet(integer)', 'EXECUTE') as u_ozet,
    has_function_privilege('anon', 'public._growth_gizle(bigint)', 'EXECUTE') as a_gizle,
    has_function_privilege('authenticated', 'public._growth_gizle(bigint)', 'EXECUTE') as u_gizle`);
ok('yetki: anon yeni RPC\'lerin hiçbirini çalıştıramaz', !yetki.a_huni && !yetki.a_utm && !yetki.a_akt && !yetki.a_ozet && !yetki.a_gizle, JSON.stringify(yetki));
ok('yetki: authenticated RPC\'leri çalıştırabilir (admin kapısı fonksiyon içinde)', yetki.u_huni && yetki.u_utm && yetki.u_akt && yetki.u_ozet, JSON.stringify(yetki));
ok('yetki: yardımcı gizleme fonksiyonu authenticated\'a kapalı', !yetki.u_gizle, JSON.stringify(yetki));

// ---------------------------------------------------------------------
// FİKSTÜR 2: UTM atfı (ilk temas, kayıt, ücretli, küçük grup gizleme)
//   meta/cpc/kis     : 6 ziyaretçi, 5 kayıt, 5 ücretli
//   google/organic/yaz: 5 ziyaretçi (biri ilk temas google, sonra meta), 5 kayıt, 1 ücretli
//   küçük gruplar    : newsletter (2), tiktok (1) -> "(diğer)" altında 3 ziyaretçi
//   eski ziyaretçi   : 40 gün önce ilk temas, sayılmamalı
// ---------------------------------------------------------------------
await postgres();
await db.exec(`
  insert into public.profiles (id, role, full_name) values
    ${[1,2,3,4,5,6].map((n) => `('${P(n)}', 'veli', 'UTM veli ${n}')`).join(',\n    ')};
  insert into public.growth_households (id, parent_name, email, core_parent_user_id, created_at) values
    ${[1,2,3,4,5,6,7,8,9,10,11].map((n) => `('${UH(n)}', 'UTM hane ${n}', 'u${n}@test.local',
        ${n <= 6 ? `'${P(n)}'` : 'null'}, now())`).join(',\n    ')};
  insert into public.payments (veli_id, tutar_kurus, durum) values
    ${[1,2,3,4,5,6].map((n) => `('${P(n)}', 22900, 'basarili')`).join(',\n    ')};
  insert into public.growth_events (anonymous_id, event_name, source, occurred_at, utm) values
    ('vis-old-01', 'erken_erisim_gonderildi', 'web', now() - interval '40 days',
     '{"utm_source":"eski","utm_medium":"x","utm_campaign":"y"}'),
    ('vis-ft-01', 'erken_erisim_gonderildi', 'web', now() - interval '2 hours',
     '{"utm_source":"google","utm_medium":"organic","utm_campaign":"yaz"}');
`);
// Ziyaretçi olayları gerçek RPC ile (anon), kimlik bağı da gerçek RPC ile.
await db.exec('reset role; set role anon;');
const META = '{"utm_source":"meta","utm_medium":"cpc","utm_campaign":"kis"}';
const GOOG = '{"utm_source":"google","utm_medium":"organic","utm_campaign":"yaz"}';
const NEWS = '{"utm_source":"newsletter","utm_medium":"email","utm_campaign":"x"}';
const TT = '{"utm_source":"tiktok","utm_medium":"social","utm_campaign":"y"}';
for (const n of [1,2,3,4,5,6]) {
  await db.query('select public.growth_web_olay_kaydet($1, $2, $3::jsonb)', [`vis-meta-0${n}`, 'erken_erisim_gonderildi', META]);
}
for (const n of [1,2,3,4]) {
  await db.query('select public.growth_web_olay_kaydet($1, $2, $3::jsonb)', [`vis-goog-0${n}`, 'erken_erisim_gonderildi', GOOG]);
}
// İlk temas google; sonraki ziyarette meta. İlk temas kuralı google'ı seçmeli.
await db.query('select public.growth_web_olay_kaydet($1, $2, $3::jsonb)', ['vis-ft-01', 'erken_erisim_gonderildi', META]);
await db.query('select public.growth_web_olay_kaydet($1, $2, $3::jsonb)', ['vis-news-01', 'erken_erisim_gonderildi', NEWS]);
await db.query('select public.growth_web_olay_kaydet($1, $2, $3::jsonb)', ['vis-news-02', 'erken_erisim_gonderildi', NEWS]);
await db.query('select public.growth_web_olay_kaydet($1, $2, $3::jsonb)', ['vis-tt-01', 'erken_erisim_gonderildi', TT]);
for (const n of [1,2,3,4,5]) {
  await db.query('select public.growth_web_kimlik_bagla($1, $2)', [`vis-meta-0${n}`, `u${n}@test.local`]);
}
for (const n of [1,2,3,4]) {
  await db.query('select public.growth_web_kimlik_bagla($1, $2)', [`vis-goog-0${n}`, `u${n + 5}@test.local`]);
}
await db.query('select public.growth_web_kimlik_bagla($1, $2)', ['vis-ft-01', 'u10@test.local']);
await db.query('select public.growth_web_kimlik_bagla($1, $2)', ['vis-news-01', 'u11@test.local']);
await postgres();

console.log('\n== D: UTM atfı (ilk temas, kayıt, ücretli, gizleme) ==');
await oturum(ADMIN);
const u1 = await utm(30);
ok('toplam ziyaretçi 14 (eski ziyaretçi hariç)', u1.toplam.ziyaretci === 14, JSON.stringify(u1.toplam));
ok('toplam kayıt 11 (bağlı tekil haneler)', u1.toplam.kayit === 11, JSON.stringify(u1.toplam));
ok('toplam ücretli 6', u1.toplam.ucretli === 6, JSON.stringify(u1.toplam));
ok('eski ziyaretçi kampanyası satırlarda yok', !JSON.stringify(u1.satirlar).includes('eski'), JSON.stringify(u1.satirlar));
const satirA = u1.satirlar.find((s) => s.kanal === 'meta');
const satirB = u1.satirlar.find((s) => s.kanal === 'google');
const satirD = u1.satirlar.find((s) => s.diger === true);
ok('meta satırı: ziyaretçi 6, kayıt 5, ücretli 5', satirA && satirA.ziyaretci === 6 && satirA.kayit === 5 && satirA.ucretli === 5, JSON.stringify(satirA));
ok('meta satırı: kayıt yüzdesi 83.3, ücretli yüzdesi 100.0', satirA?.kayit_yuzde === 83.3 && satirA?.ucretli_yuzde === 100, JSON.stringify(satirA));
ok('ilk temas kuralı: google kampanyası 5 ziyaretçi (vis-ft-01 meta değil google sayılır)', satirB && satirB.ziyaretci === 5 && satirB.kayit === 5, JSON.stringify(satirB));
ok('google satırı: ücretli 1 → n<5 gizli (null), ücretli yüzdesi null', satirB?.ucretli === null && satirB?.ucretli_yuzde === null, JSON.stringify(satirB));
ok('küçük gruplar "(diğer)" altında toplandı (kanal ayrı satır yok)', !u1.satirlar.some((s) => s.kanal === 'newsletter' || s.kanal === 'tiktok'), JSON.stringify(u1.satirlar));
ok('"(diğer)" satırı var ve ziyaretçi sayısı gizli (3 < 5)', satirD && satirD.ziyaretci === null && satirD.kayit === null, JSON.stringify(satirD));
ok('satırlar ziyaretçi sayısına göre azalan', u1.satirlar[0].kanal === 'meta' && u1.satirlar[1].kanal === 'google', JSON.stringify(u1.satirlar.map((s) => s.kanal)));

// ---------------------------------------------------------------------
// FİKSTÜR 3: aktiflik (answer_events), düzeltilmiş aktif_7_gun, doğruluk ve tekrar
//   Olaylar: S1 bugün+dün, S2 bugün, S3 dün, S4 3 gün önce, S5 10 gün önce, S6 40 gün önce.
//   S6 yalnız student_stats.last_active_date = bugün (XP/streak): DAU'ya girmemeli.
// ---------------------------------------------------------------------
await postgres();
await db.exec(`
  insert into public.profiles (id, role, full_name) values
    ${[1,2,3,4,5,6].map((n) => `('${S(n)}', 'ogrenci', 'Öğrenci ${n}')`).join(',\n    ')};
  insert into public.answer_events (student_id, question_id, dogru_mu, created_at) values
    ('${S(1)}', '${Q(1)}', true,  now()),
    ('${S(1)}', '${Q(1)}', true,  now() - interval '1 day'),
    ('${S(2)}', '${Q(1)}', false, now()),
    ('${S(3)}', '${Q(1)}', true,  now() - interval '1 day'),
    ('${S(4)}', '${Q(1)}', false, now() - interval '3 days'),
    ('${S(5)}', '${Q(1)}', true,  now() - interval '10 days'),
    ('${S(6)}', '${Q(1)}', false, now() - interval '40 days');
  insert into public.student_stats (student_id, last_active_date) values ('${S(6)}', current_date);
  insert into public.user_answers (student_id, question_id, dogru_mu, son_cevap_tarihi, sonraki_tekrar_tarihi) values
    ('${S(1)}', '${Q(1)}', true,  now() - interval '1 day',  now() - interval '1 hour'),
    ('${S(2)}', '${Q(2)}', false, now() - interval '40 days', now() - interval '1 hour'),
    ('${S(3)}', '${Q(3)}', true,  now(),                     now() + interval '1 day');
`);
await oturum(ADMIN);
const a1 = await aktif(30);
ok('DAU (bugün) = 2 (S1, S2); XP/streak kaynaklı S6 sayılmadı', a1.dau === 2, JSON.stringify({ dau: a1.dau }));
ok('WAU (son 7 takvim günü) = 4 (S1..S4)', a1.wau === 4, JSON.stringify({ wau: a1.wau }));
ok('MAU (son 30 takvim günü) = 5 (S1..S5; S6 40 gün önce)', a1.mau === 5, JSON.stringify({ mau: a1.mau }));
ok('yapışkanlık DAU/MAU = 40.0', a1.yapismazlik_yuzde === 40, JSON.stringify({ y: a1.yapismazlik_yuzde }));
ok('seri uzunluğu p_gun (30) kadar', a1.seri.length === 30, String(a1.seri.length));
ok('seri son gün bugün ve aktif = 2', a1.seri[29].gun === a1.bugun && a1.seri[29].aktif === 2, JSON.stringify(a1.seri.slice(-2)));
ok('seri dünkü gün aktif = 2 (S1, S3)', a1.seri[28].aktif === 2, JSON.stringify(a1.seri.slice(-3)));
const a7 = await aktif(7);
ok('p_gun=7 seri uzunluğu 7', a7.seri.length === 7);

const o1 = await ozet(30);
ok('analitik: aktif_7_gun = 4 (XP/streak değil answer_events)', o1.ogrenme.aktif_7_gun === 4, JSON.stringify(o1.ogrenme));
ok('analitik: doğruluk 30 gün penceresi = 66.7 (4/6)', o1.ogrenme.dogruluk_yuzde === 66.7, JSON.stringify(o1.ogrenme));
ok('analitik: tekrar zamanı gelen 30 gün = 1 (son cevabı pencerede olan)', o1.ogrenme.tekrar_zamani_gelen === 1, JSON.stringify(o1.ogrenme));
ok('analitik: öğrenci sayısı 13 (7 çocuk + 6 öğrenci)', o1.ogrenme.ogrenci === 13, JSON.stringify(o1.ogrenme));
ok('analitik: üst anahtarlar korundu (gun, huni, kohort, ogrenme)', ['gun','huni','kohort','ogrenme'].every((k) => k in o1));
const o2 = await ozet(60);
ok('analitik: 60 gün penceresi doğruluk = 57.1 (4/7) ve tekrar = 2', o2.ogrenme.dogruluk_yuzde === 57.1 && o2.ogrenme.tekrar_zamani_gelen === 2, JSON.stringify(o2.ogrenme));

console.log('\n== E: huni ve UTM tekrar çalışır (yeniden çalıştırma, idempotent) ==');
await postgres();
await kur('yeniden çalıştırma', () => db.exec(oku(YENI)));
await oturum(ADMIN);
const h3 = await huni(30);
ok('yeniden çalıştırma sonrası huni aynı (ilk soru 8, activated_at)', adim(h3, 'ilk_soru').sayi === 8);
const u3 = await utm(30);
ok('yeniden çalıştırma sonrası UTM aynı (toplam 14)', u3.toplam.ziyaretci === 14);

console.log('\n== F: p_gun penceresi ve sınır ==');
await postgres();
await oturum(ADMIN);
// Bugün oluşan haneler: 10 huni + 11 UTM = 21. Pencere 1 gün olunca eski haneler dışarıda kalır.
const hBir = await huni(1);
ok('p_gun=1: kohort bugünkü 21 hane (100 gün önceki haneler yok)', adim(hBir, 'kayit').sayi === 21, JSON.stringify(adim(hBir, 'kayit')));
ok('p_gun=1: ücretli 10 (eski haneye ait ödeme sayılmadı)', adim(hBir, 'ucretli').sayi === 10, JSON.stringify(adim(hBir, 'ucretli')));
const hSifir = await huni(0);
ok('p_gun=0 → en az 1 gün (kohort boş değil)', hSifir.gun === 1 && adim(hSifir, 'kayit').sayi === 21, JSON.stringify(hSifir.gun));
const hMax = await huni(9999);
ok('p_gun aralık dışıysa 365 ile sınırlanır', hMax.gun === 365, String(hMax.gun));

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
