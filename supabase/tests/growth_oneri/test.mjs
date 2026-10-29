// Growth kural tabanlı öneri üreticisi testi (P5 / E5). LLM yok.
// Gerçek migration zinciri PGlite (gerçek Postgres) üzerinde çalışır. Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node test.mjs
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8');
const CEKIRDEK = '20261014000000_growth_crm_core.sql';
const MUSTERI = '20261027000000_musteri_360_veri_toplama.sql';
const YENI = '20261102000000_growth_oneri_uretici.sql';

const db = new PGlite({ extensions: { pgcrypto } });

process.on('uncaughtException', (e) => { console.log('HATA:', e.message ?? e); process.exit(1); });

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
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 80)); }
  }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const postgres = () => db.exec('reset role;');
const rol = (r) => db.exec(`reset role; set role ${r};`);

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const V = {
  v1: id(1), v2: id(2), v3: id(3), v4: id(4), v5: id(5), v6: id(6), v7: id(7), v8: id(8),
  v9: id(9), v10: id(10), v11: id(11), v12: id(12), v13: id(13), v18: id(18), v19: id(19), v20: id(20),
};
const COCUK_V1 = id(30);
const COCUK_V19 = id(31);
const COCUK_V20 = id(32);

// Gerçek bağımlılık sırası: stub -> 20261014 (CRM çekirdeği) -> 20261027 (müşteri 360 veri toplama)
console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await db.exec(fs.readFileSync(path.join(import.meta.dirname, 'stubs.sql'), 'utf8'));
await db.exec(oku(CEKIRDEK));
ok('20261014 CRM çekirdeği hatasız', true);
await db.exec(oku(MUSTERI));
ok('20261027 müşteri 360 hatasız', true);
await db.exec(oku(YENI));
ok('20261102 öneri üreticisi ilk kez hatasız', true);
await db.exec(oku(YENI));
ok('20261102 öneri üreticisi ikinci kez hatasız (idempotent)', true);

const [cronIs] = await sorgu(`select schedule, command from cron.job where jobname = 'growth-oneri-uret'`);
ok('cron işi 06:00 UTC ile kayıtlı', cronIs?.schedule === '0 6 * * *', JSON.stringify(cronIs));
ok('cron işi growth_oneri_uret(200) çağırır', cronIs?.command?.includes('public.growth_oneri_uret(200)'), JSON.stringify(cronIs));
const [{ n: cronSayi }] = await sorgu(`select count(*)::int as n from cron.job where jobname = 'growth-oneri-uret'`);
ok('ikinci kurulumda cron işi çoğalmaz', cronSayi === 1, `kayıt ${cronSayi}`);

console.log('\n== A: yetkiler ve güvenlik tanımı ==');
const [fn] = await sorgu(`select prosecdef, proconfig::text as cfg from pg_proc where proname = 'growth_oneri_uret'`);
ok('growth_oneri_uret security definer', fn?.prosecdef === true);
ok("growth_oneri_uret set search_path = ''", (fn?.cfg ?? '').includes('search_path='), fn?.cfg);
const [yetki] = await sorgu(`select
    has_function_privilege('anon', 'public.growth_oneri_uret(integer)', 'EXECUTE') as anon_ok,
    has_function_privilege('authenticated', 'public.growth_oneri_uret(integer)', 'EXECUTE') as auth_ok,
    has_function_privilege('service_role', 'public.growth_oneri_uret(integer)', 'EXECUTE') as servis_ok`);
ok('anon ve authenticated EXECUTE yetkisi yok', yetki.anon_ok === false && yetki.auth_ok === false);
ok('service_role EXECUTE yetkisine sahip', yetki.servis_ok === true);
const [ayarYetki] = await sorgu(`select has_table_privilege('anon', 'public.growth_oneri_ayar', 'SELECT') as a,
  has_table_privilege('authenticated', 'public.growth_oneri_ayar', 'SELECT') as b`);
ok('growth_oneri_ayar istemciye kapalı', ayarYetki.a === false && ayarYetki.b === false);

console.log('\n== B: veri kurulumu (core + CRM) ==');
await db.exec(`
  insert into public.profiles (id, role, full_name) values
    ('${V.v1}', 'veli', 'Veli Bir'), ('${V.v2}', 'veli', 'Veli İki'), ('${V.v3}', 'veli', 'Veli Üç'),
    ('${V.v4}', 'veli', 'Veli Dört'), ('${V.v5}', 'veli', 'Veli Beş'), ('${V.v6}', 'veli', 'Veli Altı'),
    ('${V.v7}', 'veli', 'Veli Yedi'), ('${V.v8}', 'veli', 'Veli Sekiz'), ('${V.v9}', 'veli', 'Veli Dokuz'),
    ('${V.v10}', 'veli', 'Veli On'), ('${V.v11}', 'veli', 'Veli On Bir'), ('${V.v12}', 'veli', 'Veli On İki'),
    ('${V.v13}', 'veli', 'Veli On Üç'), ('${V.v18}', 'veli', 'Veli On Sekiz'),
    ('${V.v19}', 'veli', 'Veli On Dokuz'), ('${V.v20}', 'veli', 'Veli Yirmi');
  insert into public.profiles (id, role, parent_id, full_name, sinif) values
    ('${COCUK_V1}', 'ogrenci', '${V.v1}', 'Gizli Çocuk', 5),
    ('${COCUK_V19}', 'ogrenci', '${V.v19}', 'Gizli Çocuk Dokuz', 4),
    ('${COCUK_V20}', 'ogrenci', '${V.v20}', 'Gizli Çocuk Yirmi', 6);
  -- Çocuğun son öğrenme günü (XP/seri kaydı yazar). Yerel (İstanbul) takvim gününe göre.
  insert into public.student_stats (student_id, last_active_date) values
    ('${COCUK_V19}', (now() at time zone 'Europe/Istanbul')::date - 3),
    ('${COCUK_V20}', (now() at time zone 'Europe/Istanbul')::date - 9);
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun) values
    ('aylik', 'Aylık', 14900, 30), ('deneme', 'Ücretsiz deneme', 0, 14);
`);
// Abonelikler households eklenmeden önce yazılır: 20261027 tetikleyicisi hane yoksa yan etki üretmez.
await db.exec(`
  insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis) values
    ('${V.v8}', 'aylik', 'suresi_doldu', now() - interval '40 days', now() - interval '3 days'),
    ('${V.v10}', 'aylik', 'aktif', now() - interval '10 days', now() + interval '20 days'),
    ('${V.v18}', 'deneme', 'aktif', now() - interval '13 days', now() + interval '1 day');
`);

const H = {};
const hane = async (k, veli, plan, sonGorme, hesap = 'active') => {
  const [{ id: hid }] = await sorgu(
    `insert into public.growth_households (core_parent_user_id, parent_name, email, plan, last_seen_at, account_status)
     values ($1, $2, $3, $4, ${sonGorme}, $5) returning id`,
    [veli, `Hane ${k}`, `${k}@test.local`, plan, hesap]);
  H[k] = hid;
};
await hane('h1', V.v1, 'trial', 'now()');
await hane('h2', V.v2, 'trial', 'now()');
await hane('h3', V.v3, 'trial', 'now()');
await hane('h4', V.v4, 'free', "now() - interval '10 days'");
await hane('h5', V.v5, 'free', "now() - interval '6 days'");
await hane('h6', V.v6, 'free', 'now()');
await hane('h7', V.v7, 'free', 'now()');
await hane('h8', V.v8, 'free', 'now()');
await hane('h9', V.v9, 'free', 'now()');
await hane('h10', V.v10, 'premium', 'now()');
await hane('h11', V.v11, 'free', 'now()');
await hane('h12', V.v12, 'free', 'now()');
await hane('h13', V.v13, 'free', 'now()', 'blocked');
await hane('h14', null, 'trial', 'now()');
await hane('h15', null, 'premium', 'now()');
await hane('h16', null, 'free', 'now()');
await hane('h17', null, 'free', "now() - interval '30 days'");
await hane('h18', V.v18, 'trial', 'now()');
// Son görülme 20 gün önce; yalnız çocuğun öğrenme günü etkinlik sayılır.
await hane('h19', V.v19, 'free', "now() - interval '20 days'");
await hane('h20', V.v20, 'free', "now() - interval '20 days'");

await db.exec(`
  insert into public.deneme_donemleri (veli_id, baslangic, bitis) values
    ('${V.v1}',  now() - interval '12 days', now() + interval '2 days'),
    ('${V.v2}',  now() - interval '9 days',  now() + interval '5 days'),
    ('${V.v3}',  now() - interval '15 days', now() - interval '1 day'),
    ('${V.v10}', now() - interval '12 days', now() + interval '2 days'),
    ('${V.v13}', now() - interval '12 days', now() + interval '2 days');
  insert into public.growth_students (household_id, nickname, grade) values
    ('${H.h1}', 'Gizli Çocuk', 5);
  insert into public.growth_events (household_id, event_name, source, occurred_at) values
    ('${H.h4}', 'hesap_olusturuldu', 'server', now() - interval '1 day');
  insert into public.growth_financial_transactions (household_id, document_no, transaction_type, status, amount, amount_try, occurred_at) values
    ('${H.h6}', 'ODM-TEST6', 'monthly_subscription', 'failed', 149, 149, now() - interval '5 days'),
    ('${H.h7}', 'ODM-TEST7A', 'monthly_subscription', 'failed', 149, 149, now() - interval '5 days'),
    ('${H.h7}', 'ODM-TEST7B', 'monthly_subscription', 'paid', 149, 149, now() - interval '1 day');
  insert into public.iletisim_tercihleri (veli_id, kanal, izin, kaynak) values
    ('${V.v9}', 'eposta', true, 'veli'),
    ('${V.v11}', 'eposta', true, 'veli'),
    ('${V.v13}', 'eposta', true, 'veli');
  insert into public.growth_household_izinleri (household_id, channel, granted, source) values
    ('${H.h16}', 'sms', true, 'web_form');
  insert into public.growth_message_log (household_id, channel, status, consent_snapshot, sent_at) values
    ('${H.h11}', 'email', 'sent', '{}'::jsonb, now() - interval '2 days');
  insert into public.growth_subscription_projection (household_id, plan, status, trial_ends_at) values
    ('${H.h14}', 'trial', 'trial', now() + interval '1 day');
  insert into public.growth_subscription_projection (household_id, plan, status, ends_at) values
    ('${H.h15}', 'premium', 'expired', now() - interval '2 days');
`);
ok('veri kurulumu hatasız', true);

const toplamOneri = async () => (await sorgu(`select count(*)::int as n from public.growth_ai_recommendations`))[0].n;
const mesajSayisi = async () => (await sorgu(`select count(*)::int as n from public.growth_message_log`))[0].n;

console.log('\n== C: bayrak kapalıyken (varsayılan) hiçbir şey üretilmez ==');
const [ayar0] = await sorgu(`select aktif from public.growth_oneri_ayar`);
ok('bayrak varsayılan KAPALI', ayar0.aktif === false);
await rol('service_role');
const [{ n: kapali }] = await sorgu(`select public.growth_oneri_uret(200) as n`);
await postgres();
ok('bayrak kapalıyken growth_oneri_uret() → 0', kapali === 0, `dönen ${kapali}`);
ok('bayrak kapalıyken öneri tablosu boş', (await toplamOneri()) === 0);

console.log('\n== D: yetkisiz çağrı reddedilir ==');
await rol('anon');
await hataBekle('anon growth_oneri_uret çağıramaz', () => sorgu(`select public.growth_oneri_uret(200)`), 'permission denied');
await rol('authenticated');
await hataBekle('authenticated growth_oneri_uret çağıramaz', () => sorgu(`select public.growth_oneri_uret(200)`), 'permission denied');
await hataBekle('anon growth_oneri_ayar okuyamaz', () => sorgu(`select aktif from public.growth_oneri_ayar`), 'permission denied');
await postgres();

console.log('\n== E: bayrak açık: dört kural ==');
await db.exec(`update public.growth_oneri_ayar set aktif = true, guncelleyen = 'test';`);
await rol('service_role');
const [{ n: ilk }] = await sorgu(`select public.growth_oneri_uret(200) as n`);
await postgres();
ok('ilk çalıştırma 10 yeni öneri üretir', ilk === 10, `dönen ${ilk}`);

const satirlar = await sorgu(`
  select h.email, r.recommendation_type as tur, r.reason, r.status, r.requires_approval, r.agent_name,
         r.proposed_action, r.model
    from public.growth_ai_recommendations r
    join public.growth_households h on h.id = r.household_id
   order by h.email, r.recommendation_type`);
const beklenen = [
  'h1@test.local|deneme_bitiyor', 'h14@test.local|deneme_bitiyor', 'h18@test.local|deneme_bitiyor',
  'h4@test.local|pasif_aile', 'h20@test.local|pasif_aile',
  'h15@test.local|odeme_sorunu', 'h6@test.local|odeme_sorunu', 'h8@test.local|odeme_sorunu',
  'h16@test.local|ilk_temas', 'h9@test.local|ilk_temas',
].sort();
const gelen = satirlar.map((r) => `${r.email}|${r.tur}`).sort();
ok('üretilen çiftler tam beklenenle eşleşir (deneme 3, pasif 2, ödeme 3, ilk temas 2)',
  JSON.stringify(gelen) === JSON.stringify(beklenen), JSON.stringify(gelen));

const reasonOf = (email, tur) => satirlar.find((r) => r.email === email && r.tur === tur)?.reason ?? '';
ok('deneme (core, 2 gün): "2 gün kaldı" yazar', reasonOf('h1@test.local', 'deneme_bitiyor').includes('2 gün kaldı'), reasonOf('h1@test.local', 'deneme_bitiyor'));
ok('deneme (ücretsiz abonelik, 1 gün): "1 gün kaldı" yazar', reasonOf('h18@test.local', 'deneme_bitiyor').includes('1 gün kaldı'));
ok('deneme (CRM projeksiyonu): öneri üretilir', reasonOf('h14@test.local', 'deneme_bitiyor') !== '');
ok('pasif: "10 gündür" yazar (sunucu olayı etkinlik sayılmaz)', reasonOf('h4@test.local', 'pasif_aile').includes('10 gündür'), reasonOf('h4@test.local', 'pasif_aile'));
ok('pasif (çocuk öğrenme günü 9 gün önce): "9 gündür" yazar', reasonOf('h20@test.local', 'pasif_aile').includes('9 gündür'), reasonOf('h20@test.local', 'pasif_aile'));
ok('çocuk 3 gün önce öğrendiyse hane pasif sayılmaz (son görülme 20 gün önce olsa da)',
  !satirlar.some((r) => r.email === 'h19@test.local'));
ok('ödeme (başarısız): "1 başarısız ödeme" yazar', reasonOf('h6@test.local', 'odeme_sorunu').includes('Son 30 günde 1 başarısız ödeme'), reasonOf('h6@test.local', 'odeme_sorunu'));
ok('ödeme (abonelik bitti): "sona erdi" yazar', reasonOf('h8@test.local', 'odeme_sorunu').includes('sona erdi'), reasonOf('h8@test.local', 'odeme_sorunu'));
ok('ödeme (projeksiyon bitti): öneri üretilir', reasonOf('h15@test.local', 'odeme_sorunu') !== '');
ok('ilk temas (core izin): kanal adı "e-posta" yazar', reasonOf('h9@test.local', 'ilk_temas').includes('e-posta'), reasonOf('h9@test.local', 'ilk_temas'));
ok('ilk temas (CRM izni): kanal adı "SMS" yazar', reasonOf('h16@test.local', 'ilk_temas').includes('SMS'), reasonOf('h16@test.local', 'ilk_temas'));

ok('her öneri: pending, onay gerekli, kural_motoru, model yok',
  satirlar.every((r) => r.status === 'pending' && r.requires_approval === true && r.agent_name === 'kural_motoru' && r.model === null));
ok('her öneri: mesaj_gonderilir=false (yalnız kayıt)',
  satirlar.every((r) => r.proposed_action?.mesaj_gonderilir === false));
ok('gerekçeler boş değil', satirlar.every((r) => (r.reason ?? '').trim().length > 0));
const yasak = /gizli|test\.local|@|garanti|puan|sınav|kanıt|yorum|ortalama/i;
ok('gerekçelerde çocuk adı, e-posta, puan/sınav garantisi veya sosyal kanıt yok',
  satirlar.every((r) => !yasak.test(r.reason)), satirlar.filter((r) => yasak.test(r.reason)).map((r) => r.reason).join(' | '));
ok('gerekçeler kanal/tür dışında hane kimliği içermez (uuid yok)',
  satirlar.every((r) => !/[0-9a-f]{8}-[0-9a-f]{4}-/i.test(r.reason)));

ok('mesaj günlüğü değişmedi (öneri yalnız kayıt)', (await mesajSayisi()) === 1);
ok('toplam öneri 10', (await toplamOneri()) === 10);

console.log('\n== F: idempotent ==');
await rol('service_role');
const [{ n: ikinci }] = await sorgu(`select public.growth_oneri_uret(200) as n`);
await postgres();
ok('açık öneri varken ikinci çalıştırma 0 üretir', ikinci === 0, `dönen ${ikinci}`);
ok('ikinci çalıştırmadan sonra toplam hâlâ 10', (await toplamOneri()) === 10);

console.log('\n== G: reddedilen öneri, açık kalmadığı için yeniden üretilebilir ==');
await db.exec(`update public.growth_ai_recommendations set status = 'rejected'
                where household_id = '${H.h4}' and recommendation_type = 'pasif_aile';`);
await rol('service_role');
const [{ n: yeniden }] = await sorgu(`select public.growth_oneri_uret(200) as n`);
await postgres();
ok('reddedilen hane+tür için yeni bekleyen öneri → 1', yeniden === 1, `dönen ${yeniden}`);
const [{ n: pasifAcik }] = await sorgu(`select count(*)::int as n from public.growth_ai_recommendations
   where household_id = '${H.h4}' and recommendation_type = 'pasif_aile' and status = 'pending'`);
ok('aynı hane+tür için aynı anda tek bekleyen öneri', pasifAcik === 1, `açık ${pasifAcik}`);
ok('toplam 11 (reddedilen kayıt korunur)', (await toplamOneri()) === 11);

console.log('\n== H: p_limit kural başına yeni öneri sınırı ==');
await db.exec(`update public.growth_ai_recommendations set status = 'expired' where status = 'pending';`);
await rol('service_role');
const [{ n: l1 }] = await sorgu(`select public.growth_oneri_uret(1) as n`);
const [{ n: l2 }] = await sorgu(`select public.growth_oneri_uret(1) as n`);
await postgres();
ok('p_limit=1: her kuraldan en fazla bir yeni öneri (4 kural)', l1 === 4, `dönen ${l1}`);
ok('p_limit=1 ikinci çağrı kalan adayları alır (deneme 1, pasif 1, ödeme 1, ilk temas 1)', l2 === 4, `dönen ${l2}`);

console.log('\n== I: bayrak tekrar kapanınca üretim durur ==');
await db.exec(`update public.growth_oneri_ayar set aktif = false;`);
await rol('service_role');
const [{ n: kapandi }] = await sorgu(`select public.growth_oneri_uret(200) as n`);
await postgres();
ok('bayrak kapalıyken 0', kapandi === 0, `dönen ${kapandi}`);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
