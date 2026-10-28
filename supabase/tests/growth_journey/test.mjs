// Growth journey motoru: gerçek migration zinciri PGlite (gerçek Postgres) üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const CEKIRDEK = '20261014000000_growth_crm_core.sql';
const IZIN = '20261015000000_iletisim_izni_kayit_ve_iptal.sql';
const YENI = '20261099000000_growth_journey_motoru.sql';
const P7 = '20261103100000_admin_journey_adim_kaydet.sql';

// PGlite'ta pgcrypto ve pg_cron eklentileri yok. Bu satırlar yalnızca harness'ta atlanır; dosya değişmez.
// gen_random_uuid ve sha256 PostgreSQL yerleşiğidir, pgcrypto gerekmez.
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
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 80)); }
  }
};
const kur = async (ad, fn) => {
  try { await fn(); }
  catch (e) { console.log(`HATA [${ad}]: ${e.message}`); process.exit(1); }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const kimsin = (rol) => db.exec(`reset role; set role ${rol};`);
const postgres = () => db.exec('reset role;');

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const V1 = id(1), V3 = id(3), V4 = id(4);
const H1 = id(101), H2 = id(102), H3 = id(103), H4 = id(104), H5 = id(105);
const J1 = id(201), J2 = id(202), J3 = id(203), J4 = id(204);

const adim = async (journey, pos) => (await sorgu(
  `select id from public.growth_journey_steps where journey_id = $1 and position = $2`, [journey, pos]))[0].id;
const kayit = async (journey, hane) => (await sorgu(
  `select id, status, current_step_id, next_run_at, completed_at, error
     from public.growth_journey_enrollments where journey_id = $1 and household_id = $2
    order by entered_at desc limit 1`, [journey, hane]))[0];
const logl = (hane) => sorgu(
  `select id, channel, status, error, consent_snapshot from public.growth_message_log where household_id = $1`, [hane]);
const ilerlet = async () => (await sorgu(`select public.growth_journey_ilerlet(50) as j`))[0].j;

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(path.join(HERE, 'stubs.sql'), 'utf8')));
await kur('growth core', () => db.exec(oku(CEKIRDEK)));
await kur('ticari izin', () => db.exec(oku(IZIN)));
await kur('journey motoru', () => db.exec(oku(YENI)));
await kur('adim kaydet (P7)', () => db.exec(oku(P7)));
ok('migration zinciri hatasız (core → izin → journey motoru)', true);

await postgres();
await db.exec(`
  insert into public.profiles (id, role, full_name) values
    ('${V1}', 'veli', 'Veli Bir'), ('${V3}', 'veli', 'Veli Üç'), ('${V4}', 'veli', 'Veli Dört');
  insert into public.iletisim_tercihleri (veli_id, kanal, izin, kaynak) values
    ('${V1}', 'eposta', true, 'veli'), ('${V1}', 'uygulama_ici', true, 'veli'), ('${V1}', 'sms', true, 'veli'),
    ('${V3}', 'eposta', false, 'veli'),
    ('${V4}', 'eposta', true, 'veli');
  insert into public.growth_households (id, parent_name, email, core_parent_user_id, account_status) values
    ('${H1}', 'H1 izinli', 'h1@test.local', '${V1}', 'active'),
    ('${H2}', 'H2 veli bağlantısız', 'h2@test.local', null, 'active'),
    ('${H3}', 'H3 e-posta reddi', 'h3@test.local', '${V3}', 'active'),
    ('${H4}', 'H4 bastırılmış', 'h4@test.local', '${V4}', 'active'),
    ('${H5}', 'H5 bloklu', 'h5@test.local', '${V1}', 'blocked');
  insert into public.growth_prospect_suppressions (email_hash, channel, reason, source)
    values (public._eposta_karmasi('h4@test.local'), 'eposta', 'kullanici_iptali', 'test');
  insert into public.growth_journeys (id, name, status) values
    ('${J1}', 'Hoş geldin', 'active'), ('${J2}', 'Bozuk adım', 'active'),
    ('${J3}', 'Duraklatılan', 'active'), ('${J4}', 'Taslak', 'draft');
  insert into public.growth_journey_steps (journey_id, position, step_type, label, config) values
    ('${J1}', 1, 'email', 'Hoş geldin e-postası', '{"sablon": "test_sablon"}'),
    ('${J1}', 2, 'delay', '24 saat bekle', '{"saat": 24}'),
    ('${J1}', 3, 'in_app', 'Uygulama içi ipucu', '{}'),
    ('${J1}', 4, 'sms', 'SMS (kapalı kanal)', '{}'),
    ('${J2}', 1, 'webhook', 'Desteklenmeyen adım', '{}'),
    ('${J3}', 1, 'in_app', 'Duraklatılan adım', '{}');
`);

console.log('\n== A: giriş (service_role) ==');
await kimsin('service_role');
const e1 = (await sorgu(`select public.growth_journey_giris_al($1, $2) as id`, [J1, H1]))[0].id;
const e1b = (await sorgu(`select public.growth_journey_giris_al($1, $2) as id`, [J1, H1]))[0].id;
ok('giriş: aynı journey + hane ikinci kez eklenmez (aynı kayıt döner)', e1 === e1b, `${e1} / ${e1b}`);
const [{ n: adet1 }] = await sorgu(
  `select count(*)::int as n from public.growth_journey_enrollments where journey_id = $1 and household_id = $2`, [J1, H1]);
ok('giriş: tabloda tek satır var', adet1 === 1, `satır ${adet1}`);
const k1 = await kayit(J1, H1);
ok('giriş: current_step ilk adım (pos 1), status active, next_run_at dolu',
  k1.current_step_id === await adim(J1, 1) && k1.status === 'active' && k1.next_run_at !== null, JSON.stringify(k1));
await hataBekle('taslak journey kabul etmez', () => sorgu(`select public.growth_journey_giris_al($1, $2)`, [J4, H1]), 'aktif değil');
await hataBekle('bloklu hane kabul edilmez', () => sorgu(`select public.growth_journey_giris_al($1, $2)`, [J1, H5]), 'uygun değil');

await sorgu(`select public.growth_journey_giris_al($1, $2)`, [J1, H2]);
await sorgu(`select public.growth_journey_giris_al($1, $2)`, [J1, H3]);
await sorgu(`select public.growth_journey_giris_al($1, $2)`, [J1, H4]);
await sorgu(`select public.growth_journey_giris_al($1, $2)`, [J2, H1]);
await sorgu(`select public.growth_journey_giris_al($1, $2)`, [J3, H1]);
const k3pre = await kayit(J3, H1);

console.log('\n== B: bayrak kapalıyken ilerlet hiçbir şey yapmaz ==');
const kapali = (await sorgu(`select public.growth_journey_ilerlet(50) as j`))[0].j;
ok('bayrak kapalı → motor kapali, işlenen 0', kapali.motor === 'kapali' && kapali.islenen === 0, JSON.stringify(kapali));
const k1kapali = await kayit(J1, H1);
ok('bayrak kapalı: kayıt değişmedi (adım, status, next_run_at)',
  k1kapali.current_step_id === k1.current_step_id && k1kapali.status === 'active'
    && k1kapali.next_run_at?.getTime() === k1.next_run_at?.getTime(), JSON.stringify(k1kapali));
const [{ n: logKapali }] = await sorgu(`select count(*)::int as n from public.growth_message_log`);
ok('bayrak kapalı: mesaj günlüğünde satır yok', logKapali === 0, `satır ${logKapali}`);

await postgres();
await db.exec(`update public.growth_journeys set status = 'paused' where id = '${J3}'`);
await db.exec(`update public.growth_motor_ayarlari set deger = true where anahtar = 'growth_journey_motoru_acik'`);
await kimsin('service_role');

console.log('\n== C: ilerlet (bayrak açık): mesaj, izin, bastırma, hata, duraklatma ==');
await db.exec(`insert into public.growth_templates (name, channel, subject, body)
  values ('test_sablon', 'email', 'Test konusu', 'Merhaba {{veli_adi}}')`);
// Kapı (20261101) gerçek fonksiyonla growth_iletisim_uygunluk paketinde sınanır; burada taklit edilir:
// H2, H3, H4 için kapı izin_yok döner (izinsiz / reddedilmiş / bastırılmış).
await db.exec(`insert into public.test_uygunluk values
  ('${H2}', false, 'izin_yok', null), ('${H3}', false, 'izin_yok', null), ('${H4}', false, 'izin_yok', null)`);
await db.exec(`insert into public.test_uygunluk values ('${H1}', true, null, null)`);
const r1 = await ilerlet();
ok('bayrak açık: 5 kayıt işlendi (J1×4 + J2×1; duraklatılan J3 dışarıda)', r1.motor === 'acik' && r1.islenen === 5, JSON.stringify(r1));
ok('e-posta adımı: 1 kuyrukta, 3 engellendi (izinsiz / reddedilmiş / bastırılmış), 1 hata',
  r1.kuyruga_alindi === 1 && r1.engellendi === 3 && r1.hata === 1, JSON.stringify(r1));

const l1 = await logl(H1);
const h1Email = l1.find((x) => x.channel === 'email');
ok('izinli hane: e-posta mesajı status=kuyrukta, snapshot email=true',
  h1Email?.status === 'kuyrukta' && h1Email?.consent_snapshot?.email === true, JSON.stringify(h1Email));
const [h1Kuyruk] = await sorgu(
  `select alici_id, growth_household_id, sablon_anahtar, growth_message_id from public.eposta_outbox where growth_household_id = $1`, [H1]);
ok('kuyrukta: eposta_outbox satırı şablon anahtarı ve günlük bağlantısıyla yazıldı (alıcı kimliği boş)',
  h1Kuyruk?.alici_id === null && h1Kuyruk?.sablon_anahtar === 'test_sablon' && h1Kuyruk?.growth_message_id === h1Email?.id,
  JSON.stringify(h1Kuyruk));

for (const [ad, h] of [['veli bağlantısız', H2], ['e-posta izni reddi', H3], ['bastırılmış adres', H4]]) {
  const satirlar = (await logl(h)).filter((x) => x.channel === 'email');
  ok(`izinsiz (${ad}): status=engellendi, error=izin_yok, outbox yok`,
    satirlar.length === 1 && satirlar[0].status === 'engellendi' && satirlar[0].error === 'izin_yok', JSON.stringify(satirlar));
}
const h4Log = (await logl(H4)).find((x) => x.channel === 'email');
ok('engel satırının snapshot ı email=false (izin yok)', h4Log?.consent_snapshot?.email === false, JSON.stringify(h4Log));
ok('snapshot PII taşımaz (e-posta adresi yok)',
  !JSON.stringify(h4Log?.consent_snapshot ?? {}).includes('h4@test.local'), JSON.stringify(h4Log));

const kFail = await kayit(J2, H1);
ok('desteklenmeyen adım: kayıt status=failed, error nedeni dolu',
  kFail.status === 'failed' && /desteklenmiyor/.test(kFail.error ?? ''), JSON.stringify(kFail));
const k3 = await kayit(J3, H1);
ok('duraklatılmış journey: kayıt işlenmedi (adım ve status aynı)',
  k3.current_step_id === k3pre.current_step_id && k3.status === 'active', JSON.stringify(k3));
const k1e = await kayit(J1, H1);
ok('izinli kayıt sonraki adıma (bekleme) geçti, status active',
  k1e.current_step_id === await adim(J1, 2) && k1e.status === 'active', JSON.stringify(k1e));

console.log('\n== D: bekleme adımı next_run_at ilerletir ==');
const r2 = await ilerlet();
ok('ikinci tur: J1 dört kayıt bekleme adımını işledi (hemen vadesi gelenler)',
  r2.islenen === 4 && r2.bekleme === 4, JSON.stringify(r2));
const k1w = await kayit(J1, H1);
const [{ bekle_ok }] = await sorgu(
  `select (next_run_at - now()) between interval '23 hours' and interval '25 hours' as bekle_ok
     from public.growth_journey_enrollments where id = $1`, [k1w.id]);
ok('bekleme: status waiting, next_run_at ≈ +24 saat, current = pos 3',
  k1w.status === 'waiting' && bekle_ok === true && k1w.current_step_id === await adim(J1, 3), JSON.stringify(k1w));
const r3 = await ilerlet();
ok('bekleme sürerken tur hiçbir kaydı işlemez', r3.islenen === 0, JSON.stringify(r3));

await postgres();
await db.exec(`update public.growth_journey_enrollments set next_run_at = now() - interval '1 minute' where id = '${k1w.id}'`);
await kimsin('service_role');
const r4 = await ilerlet();
ok('bekleme bitince uygulama içi adım engellendi (tüketici yok: kanal_desteklenmiyor)',
  r4.islenen === 1 && r4.engellendi === 1 && r4.kuyruga_alindi === 0, JSON.stringify(r4));
const k1s = await kayit(J1, H1);
ok('in_app sonrası current = pos 4 (sms), status active', k1s.current_step_id === await adim(J1, 4) && k1s.status === 'active', JSON.stringify(k1s));

await postgres();
await db.exec(`update public.growth_journey_enrollments set next_run_at = now() - interval '1 minute' where id = '${k1w.id}'`);
await kimsin('service_role');
const r5 = await ilerlet();
ok('son adım (sms): tamamlandı sayılır', r5.islenen === 1 && r5.tamamlandi === 1, JSON.stringify(r5));
const k1c = await kayit(J1, H1);
ok('tamamlanan kayıt: status completed, completed_at dolu, next_run_at boş',
  k1c.status === 'completed' && k1c.completed_at !== null && k1c.next_run_at === null, JSON.stringify(k1c));
const l1son = await logl(H1);
const sms = l1son.filter((x) => x.channel === 'sms');
ok('SMS kuyruğa alınmaz: status=engellendi, error=kanal_kapali (izinli olsa bile)',
  sms.length === 1 && sms[0].status === 'engellendi' && sms[0].error === 'kanal_kapali', JSON.stringify(sms));
ok('H1 günlüğü: yalnız e-posta kuyrukta, toplam 3 satır (e-posta, uygulama içi, sms)',
  l1son.length === 3 && l1son.filter((x) => x.status === 'kuyrukta').length === 1, JSON.stringify(l1son));

console.log('\n== E: yetki (anon / authenticated çağıramaz) ==');
const yetki = (await sorgu(`select
    has_function_privilege('anon', 'public.growth_journey_ilerlet(int)', 'EXECUTE') as anon_ilerlet,
    has_function_privilege('authenticated', 'public.growth_journey_ilerlet(int)', 'EXECUTE') as auth_ilerlet,
    has_function_privilege('service_role', 'public.growth_journey_ilerlet(int)', 'EXECUTE') as svc_ilerlet,
    has_function_privilege('anon', 'public.growth_journey_giris_al(uuid, uuid)', 'EXECUTE') as anon_giris,
    has_function_privilege('authenticated', 'public.growth_journey_giris_al(uuid, uuid)', 'EXECUTE') as auth_giris,
    has_function_privilege('service_role', 'public.growth_journey_giris_al(uuid, uuid)', 'EXECUTE') as svc_giris,
    has_function_privilege('anon', 'public._growth_mesaj_engelle(uuid, uuid, uuid, text, text, jsonb)', 'EXECUTE') as anon_izin,
    has_function_privilege('authenticated', 'public._growth_mesaj_engelle(uuid, uuid, uuid, text, text, jsonb)', 'EXECUTE') as auth_izin`))[0];
ok('yetki tablosu: anon/authenticated hiçbir motor fonksiyonunu çalıştıramaz',
  !yetki.anon_ilerlet && !yetki.auth_ilerlet && !yetki.anon_giris && !yetki.auth_giris && !yetki.anon_izin && !yetki.auth_izin,
  JSON.stringify(yetki));
ok('yetki tablosu: service_role ilerlet ve giriş fonksiyonlarını çalıştırabilir',
  yetki.svc_ilerlet === true && yetki.svc_giris === true, JSON.stringify(yetki));

await kimsin('anon');
await hataBekle('anon ilerlet çağıramaz', () => sorgu(`select public.growth_journey_ilerlet(50)`), 'permission denied');
await hataBekle('anon giriş kaydı yapamaz', () => sorgu(`select public.growth_journey_giris_al($1, $2)`, [J1, H2]), 'permission denied');
await kimsin('authenticated');
await hataBekle('authenticated ilerlet çağıramaz', () => sorgu(`select public.growth_journey_ilerlet(50)`), 'permission denied');
await hataBekle('authenticated giriş kaydı yapamaz', () => sorgu(`select public.growth_journey_giris_al($1, $2)`, [J1, H2]), 'permission denied');
await kimsin('anon');
await hataBekle('anon bayrak tablosunu okuyamaz', () => sorgu(`select deger from public.growth_motor_ayarlari`), 'permission denied');
await postgres();

console.log('\n== G: P4 kapısı (sessiz saat / sıklık) ve P7 adım kaydı ==');
{
const J5 = id(205), H6 = id(106), H7 = id(107), H8 = id(108);
await postgres();
await db.exec(`
  insert into public.growth_households (id, parent_name, email, core_parent_user_id, account_status) values
    ('${H6}', 'H6 kapılı', 'h6@test.local', '${V1}', 'active'),
    ('${H7}', 'H7 izinsiz', 'h7@test.local', '${V1}', 'active'),
    ('${H8}', 'H8 sıklık', 'h8@test.local', '${V1}', 'active');
  insert into public.growth_journeys (id, name, status) values ('${J5}', 'Kapı testi', 'active');
  insert into public.growth_journey_steps (journey_id, position, step_type, label, config) values
    ('${J5}', 1, 'email', 'Kapılı e-posta', '{"sablon": "test_sablon"}'),
    ('${J5}', 2, 'in_app', 'Sonraki', '{}');
`);
for (const h of [H6, H7, H8]) await sorgu(`select public.growth_journey_giris_al($1, $2)`, [J5, h]);
const sonra = new Date(Date.now() + 5 * 3600 * 1000).toISOString();
await db.exec(`insert into public.test_uygunluk values
  ('${H6}', false, 'sessiz_saat', '${sonra}'),
  ('${H7}', false, 'izin_yok', null),
  ('${H8}', false, 'siklik_siniri', null)`);

const e1 = await ilerlet();
const g1 = await kayit(J5, H6);
ok('sessiz saatte adım ERTELENİR: kayıt waiting, aynı adımda, günlüğe yazılmaz',
  e1.ertelendi === 1 && g1.status === 'waiting' && g1.current_step_id === await adim(J5, 1) && (await logl(H6)).length === 0,
  JSON.stringify({ e1, g1 }));
ok('ertelenen kaydın next_run_at değeri kapının verdiği zamana eşit',
  Math.abs(new Date(g1.next_run_at).getTime() - new Date(sonra).getTime()) < 2000, String(g1.next_run_at));
ok('izin_yok ve sıklık sınırı: engellendi sayılır (iki kayıt), ertelenmez',
  e1.engellendi === 2, JSON.stringify(e1));

const l7 = (await logl(H7)).filter((x) => x.channel === 'email');
const g7 = await kayit(J5, H7);
ok('izin_yok: günlükte engellendi + error=izin_yok; adım ilerler (in_app)',
  l7.length === 1 && l7[0].status === 'engellendi' && l7[0].error === 'izin_yok' && g7.current_step_id === await adim(J5, 2),
  JSON.stringify({ l7, g7 }));
const l8 = (await logl(H8)).filter((x) => x.channel === 'email');
const g8 = await kayit(J5, H8);
ok('sıklık sınırı: engellendi + error=siklik_siniri; yeniden denenmez, adım ilerler',
  l8.length === 1 && l8[0].status === 'engellendi' && l8[0].error === 'siklik_siniri' && g8.current_step_id === await adim(J5, 2),
  JSON.stringify({ l8, g8 }));
ok('engellenen hanelerde eposta_outbox satırı YOK',
  (await sorgu(`select count(*)::int n from public.eposta_outbox where growth_household_id in ('${H7}', '${H8}')`))[0].n === 0);

const e2 = await ilerlet();
const g1b = await kayit(J5, H6);
ok('erteleme zamanı gelmeden H6 tekrar işlenmez (waiting ve next_run_at aynı)',
  g1b.status === 'waiting' && g1b.next_run_at.getTime() === g1.next_run_at.getTime(), JSON.stringify({ e2, g1b }));

await db.exec(`update public.test_uygunluk set uygun = true, neden = null, sonraki_uygun = null where household_id = '${H6}';
  update public.growth_journey_enrollments set next_run_at = now() where household_id = '${H6}' and journey_id = '${J5}'`);
await ilerlet();
const l6 = (await logl(H6)).filter((x) => x.channel === 'email');
ok('kapı uygun olunca e-posta kuyrukta yazılır ve adım ilerler',
  l6.length === 1 && l6[0].status === 'kuyrukta' && (await kayit(J5, H6)).current_step_id === await adim(J5, 2),
  JSON.stringify(l6));

// ---- P7: admin_journey_adim_kaydet ----
const J6 = id(206);
await db.exec(`insert into public.growth_journeys (id, name, status) values ('${J6}', 'Adım editörü', 'draft')`);
const gecerli = JSON.stringify([
  { step_type: 'trigger', label: 'Başlangıç' },
  { step_type: 'email', label: 'Hoş geldin', config: { sablon: 'test_sablon' } },
  { step_type: 'delay', label: '2 gün', config: { saat: 48 } },
  { step_type: 'push', label: 'Hatırlatma' },
]);
await db.exec(`reset role; set role authenticated; select set_config('test.admin', '', false);`);
await hataBekle('yönetici değilse adım kaydedilemez',
  () => sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb)`, [J6, gecerli]), 'Yönetici yetkisi');
await db.exec(`select set_config('test.admin', 'evet', false);`);
const kayitSonuc = (await sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb) as r`, [J6, gecerli]))[0].r;
await postgres();
const adimlar = await sorgu(`select position, step_type from public.growth_journey_steps where journey_id = $1 order by position`, [J6]);
ok('geçerli adımlar sırayla yazıldı (1..4) ve sayı döndü',
  kayitSonuc.adim_sayisi === 4 && adimlar.map((a) => a.step_type).join() === 'trigger,email,delay,push', JSON.stringify({ kayitSonuc, adimlar }));
ok('denetim izi yazıldı', (await sorgu(`select count(*)::int n from public.test_admin_log where aksiyon = 'journey_adimlari_kaydedildi'`))[0].n === 1);

await db.exec(`reset role; set role authenticated; select set_config('test.admin', 'evet', false);`);
const yeniden = JSON.stringify([{ step_type: 'email', label: 'Tek adım', config: { sablon: 'test_sablon' } }]);
await sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb)`, [J6, yeniden]);
await postgres();
ok('yeniden kaydetme adımları DEĞİŞTİRİR (eskiler silinir)',
  (await sorgu(`select count(*)::int n from public.growth_journey_steps where journey_id = $1`, [J6]))[0].n === 1);

await kimsin('authenticated');
await db.exec(`select set_config('test.admin', 'evet', false);`);
const kotu = (a) => () => sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb)`, [J6, JSON.stringify(a)]);
await hataBekle('condition adımı reddedilir (motor işlemez)', kotu([{ step_type: 'condition', label: 'x' }]), 'desteklenmiyor');
await hataBekle('webhook adımı reddedilir', kotu([{ step_type: 'webhook', label: 'x' }]), 'desteklenmiyor');
await hataBekle('boş etiket reddedilir', kotu([{ step_type: 'email', label: '  ' }]), 'etiketi');
await hataBekle('şablonsuz e-posta adımı reddedilir (motor işleyemez)', kotu([{ step_type: 'email', label: 'Sessiz' }]), 'şablon anahtarı zorunlu');
await hataBekle('bekleme saati yoksa reddedilir', kotu([{ step_type: 'delay', label: 'b' }]), 'saat sayı');
await hataBekle('bekleme saati 8760 üstü reddedilir', kotu([{ step_type: 'delay', label: 'b', config: { saat: 9000 } }]), '0-8760');
await hataBekle('21 adım reddedilir', kotu(Array.from({ length: 21 }, (_, i) => ({ step_type: 'email', label: `a${i}` }))), 'En fazla 20');
await hataBekle('dizi olmayan veri reddedilir', () => sorgu(`select public.admin_journey_adim_kaydet($1, '{}'::jsonb)`, [J6]), 'dizi');
await postgres();
ok('hatalı kayıt denemeleri mevcut adımları bozmadı',
  (await sorgu(`select count(*)::int n from public.growth_journey_steps where journey_id = $1`, [J6]))[0].n === 1);

await kimsin('authenticated');
await db.exec(`select set_config('test.admin', 'evet', false);`);
await hataBekle('aktif journey adımları değiştirilemez',
  () => sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb)`, [J5, yeniden]), 'Aktif journey');
await postgres();
await db.exec(`update public.growth_journeys set status = 'paused' where id = '${J1}'`);
await kimsin('authenticated');
await db.exec(`select set_config('test.admin', 'evet', false);`);
await hataBekle('açık kaydı olan (duraklatılmış) journey adımları değiştirilemez',
  () => sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb)`, [J1, yeniden]), 'Açık kaydı');
await kimsin('anon');
await hataBekle('anon adım kaydedemez', () => sorgu(`select public.admin_journey_adim_kaydet($1, $2::jsonb)`, [J6, yeniden]), 'permission denied');
await postgres();
}
console.log('\n== F: zamanlayıcı, RLS ve yeniden çalıştırma ==');
const [cj] = await sorgu(`select schedule, command from cron.job where jobname = 'growth-journey-ilerlet'`);
ok('pg_cron işi 5 dakikada bir kurulu ve motoru çağırıyor',
  cj?.schedule === '*/5 * * * *' && /growth_journey_ilerlet/.test(cj?.command ?? ''), JSON.stringify(cj));
const [{ rls }] = await sorgu(`select relrowsecurity as rls from pg_class where relname = 'growth_motor_ayarlari'`);
ok('growth_motor_ayarlari için RLS açık', rls === true);

await kur('yeniden çalıştırma', () => db.exec(oku(YENI)));
const [{ deger: bayrakSonra }] = await sorgu(
  `select deger from public.growth_motor_ayarlari where anahtar = 'growth_journey_motoru_acik'`);
ok('migration ikinci kez hatasız ve açık bayrağı kapatmıyor (idempotent)', bayrakSonra === true);
const [{ n: cronAdet }] = await sorgu(`select count(*)::int as n from cron.job where jobname = 'growth-journey-ilerlet'`);
ok('yeniden çalıştırmada zamanlayıcı çoğaltılmıyor', cronAdet === 1, `iş ${cronAdet}`);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
