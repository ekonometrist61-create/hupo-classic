// Growth entegrasyon testi (W9): gerçek migration zinciri PGlite (WASM Postgres) üzerinde.
// Kapsam: izin kapısı (gerçek 20261101), sessiz saat, sıklık, bayrak, form izni olan deneme kişisi,
// otomatik giriş, çıkış koşulları, eposta_outbox kuyruğu, gönderim anı izin kontrolü, sonuç yazımı,
// seed şablon/journey'lerin taslak olması ve render kuralları (çocuk verisi yok).
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { growthDegiskenleri, growthMesajiHazirla } from '../../functions/_shared/growth_eposta.ts';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');

// PGlite'ta pgcrypto ve pg_cron yok: yalnız harness'ta atlanır, migration dosyaları değişmez.
const eklentiSatiri = /^\s*create extension if not exists (pgcrypto|pg_cron)\b[^;]*;\s*$/gim;
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8')
  .replace(eklentiSatiri, "-- eklenti PGlite harness'ta atlandı");

// Tam dosya yerine ilgili DDL bölümü (gerçek metin): 20261014200 şema ekleri (growth_templates.status)
// ve 20261027 bölüm 1 (growth_household_izinleri + growth_consent_bridge birleşik görünüm).
const bolum = (metin, bas, son) => {
  const i = metin.indexOf(bas);
  const j = metin.indexOf(son, i + 1);
  if (i < 0 || j < 0) throw new Error(`bölüm bulunamadı: ${bas}`);
  return metin.slice(i, j);
};
const SEMA_200 = bolum(oku('20261014000200_growth_marketing_rpcs.sql'), '-- 0. Şema eklemeleri', '-- 1. JOURNEY');
const KONSENT_27 = bolum(oku('20261027000000_musteri_360_veri_toplama.sql'), '-- 1. İzin tablosu', '-- 2. Müşteri numarası');

const db = new PGlite();
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const tek = async (sql, params = []) => (await sorgu(sql, params))[0];
const kimsin = (rol) => db.exec(`reset role; set role ${rol};`);
const postgres = () => db.exec('reset role;');

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

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
// Veliler (hesap) ve çocuk
const V1 = id(1), V2 = id(2), V5 = id(5), V6 = id(6), V7 = id(7), V8 = id(8), V9 = id(9), C7 = id(17);
// Haneler
const H = (n) => id(100 + n);
const H1 = H(1), H2 = H(2), H3 = H(3), H4 = H(4), H5 = H(5), H6 = H(6), H7 = H(7), H8 = H(8);
const H9 = H(9), H10 = H(10), H11 = H(11), H12 = H(12), H13 = H(13), H15 = H(15), H17 = H(17);
const W1 = H(21), W2 = H(22);
// Journey'ler (test için)
const JE = id(210), JX = id(211), JO = id(212), JD = id(213), JDG = id(214), JP7 = id(215), JP30 = id(216), JW = id(218);
// Seed journey kimlikleri (20261110)
const SEED = ['a1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000002',
  'a1000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000004',
  'a1000000-0000-4000-8000-000000000005', 'a1000000-0000-4000-8000-000000000006'];

const kayit = (journey, hane) => tek(
  `select id, status, current_step_id, next_run_at, completed_at, error, metadata
     from public.growth_journey_enrollments where journey_id = $1 and household_id = $2
    order by entered_at desc limit 1`, [journey, hane]);
const adim = async (journey, pos) => (await tek(
  `select id from public.growth_journey_steps where journey_id = $1 and position = $2`, [journey, pos])).id;
const logl = (hane) => sorgu(
  `select id, channel, status, error, consent_snapshot from public.growth_message_log where household_id = $1 order by created_at, id`, [hane]);
const epostaLog = async (hane) => (await logl(hane)).filter((x) => x.channel === 'email');
const outbox = (hane) => sorgu(
  `select id, alici_id, growth_household_id, sablon_anahtar, growth_message_id, durum from public.eposta_outbox
    where growth_household_id = $1`, [hane]);
const ilerlet = async () => (await tek(`select public.growth_journey_ilerlet(50) as j`)).j;
const bayrak = (acik) => db.exec(`update public.growth_motor_ayarlari set deger = ${acik} where anahtar = 'growth_journey_motoru_acik'`);

// ---------------------------------------------------------------------
console.log('\n== Kurulum: stub + gerçek migration zinciri (taklit yok) ==');
await kur('stubs', () => db.exec(fs.readFileSync(path.join(HERE, 'stubs.sql'), 'utf8')));
await kur('growth core 20261014', () => db.exec(oku('20261014000000_growth_crm_core.sql')));
await kur('ticari izin 20261015', () => db.exec(oku('20261015000000_iletisim_izni_kayit_ve_iptal.sql')));
await kur('growth şema 20261014200', () => db.exec(SEMA_200));
await kur('birleşik izin görünümü 20261027 (bölüm 1)', () => db.exec(KONSENT_27));
await kur('journey motoru 20261099', () => db.exec(oku('20261099000000_growth_journey_motoru.sql')));
await kur('mesaj günlüğü 20261100', () => db.exec(oku('20261100000000_growth_mesaj_gunlugu.sql')));
await kur('uygunluk kapısı 20261101', () => db.exec(oku('20261101000000_growth_iletisim_uygunluk.sql')));
await kur('entegrasyon seed 20261110', () => db.exec(oku('20261110000000_growth_entegrasyon_seed.sql')));
ok('zincir hatasız: core → izin → birleşik izin → 1099 → 1100 → 1101 → 1110', true);
await kur('yeniden çalıştırma 20261110 (idempotent)', () => db.exec(oku('20261110000000_growth_entegrasyon_seed.sql')));
ok('20261110 ikinci kez hatasız (idempotent)', true);

await db.exec(`
  update public.iletisim_ayarlari set sessiz_baslangic = '00:00', sessiz_bitis = '00:00';
  insert into auth.users (id, email, email_confirmed_at) values
    ('${V1}', 'v1@t.local', now()), ('${V2}', 'v2@t.local', now()), ('${V5}', 'v5@t.local', null),
    ('${V6}', 'v6@t.local', now()), ('${V7}', 'v7@t.local', now()), ('${V8}', 'v8@t.local', now()),
    ('${V9}', 'v9@t.local', null);
  insert into public.profiles (id, role, full_name) values
    ('${V1}', 'veli', 'Veli Bir'), ('${V2}', 'veli', 'Veli İki'), ('${V5}', 'veli', 'Veli Beş'),
    ('${V6}', 'veli', 'Veli Altı'), ('${V7}', 'veli', 'Veli Yedi'), ('${V8}', 'veli', 'Veli Sekiz'),
    ('${V9}', 'veli', 'Veli Dokuz');
  insert into public.profiles (id, role, parent_id, full_name) values ('${C7}', 'ogrenci', '${V7}', 'Çocuk Yedi');
  insert into public.iletisim_tercihleri (veli_id, kanal, izin, kaynak) values
    ('${V1}', 'eposta', true, 'veli'), ('${V2}', 'eposta', false, 'veli');
  insert into public.growth_households (id, parent_name, email, core_parent_user_id, account_status, last_seen_at, created_at) values
    ('${H1}',  'H1 izinli',         'h1@t.local',  '${V1}', 'active', now(), now()),
    ('${H2}',  'H2 izinsiz',        'h2@t.local',  null,    'active', now(), now()),
    ('${H3}',  'H3 bastırılmış',    'h3@t.local',  '${V1}', 'active', now(), now()),
    ('${H4}',  'H4 deneme kişisi',  'h4@t.local',  null,    'active', now(), now()),
    ('${H5}',  'H5 bloklu',         'h5@t.local',  '${V1}', 'blocked', now(), now()),
    ('${H6}',  'H6 e-posta reddi',  'h6@t.local',  '${V2}', 'active', now(), now()),
    ('${H7}',  'H7 sıklık',         'h7@t.local',  '${V1}', 'active', now(), now()),
    ('${H8}',  'H8 doğrulanmamış',  'h8@t.local',  '${V5}', 'active', now(), now()),
    ('${H9}',  'H9 pasif 10 gün',   'h9@t.local',  '${V6}', 'active', now() - interval '10 days', now()),
    ('${H10}', 'H10 pasif 40 gün',  'h10@t.local', '${V8}', 'active', now() - interval '40 days', now()),
    ('${H11}', 'H11 çocuklu',       'h11@t.local', '${V7}', 'active', now(), now()),
    ('${H12}', 'H12 ücretli',       'h12@t.local', '${V1}', 'active', now(), now()),
    ('${H13}', 'H13 deneme bitiş',  'h13@t.local', null,    'active', now(), now()),
    ('${H15}', 'H15 kayıt olayı',   'h15@t.local', '${V1}', 'active', now(), now()),
    ('${H17}', 'H17 sessiz',        'h17@t.local', '${V1}', 'active', now(), now()),
    ('${W1}',  'W1 doğrulama çıkışı', 'w1@t.local', '${V5}', 'active', now(), now()),
    ('${W2}',  'W2 geri dönüş çıkışı', 'w2@t.local', '${V9}', 'active', now() - interval '1 day', now());
  update public.growth_households set created_at = now() - interval '30 hours' where id = '${H8}';
  update public.growth_households set plan = 'premium' where id = '${H12}';
  insert into public.growth_households (id, parent_name, email, core_parent_user_id, account_status) values
    ('${H(16)}', 'H16 izinsiz', 'h16@t.local', null, 'active');
  update public.growth_households set created_at = now() where id = '${H(16)}';
  insert into public.growth_prospect_suppressions (email_hash, channel, reason, source)
    values (public._eposta_karmasi('h3@t.local'), 'eposta', 'kullanici_iptali', 'test');
  -- Form/CRM izni: hesabı olmayan deneme kişisi (H4). Bridge görünümü bu tablodan okur.
  insert into public.growth_household_izinleri (household_id, channel, granted, source, surum) values
    ('${H4}', 'email', true, 'web_form', 'v1');
  -- Deneme: H13 CRM projeksiyonunda 2 gün içinde bitiyor
  insert into public.growth_subscription_projection (household_id, plan, status, trial_ends_at)
    values ('${H13}', 'trial', 'trial', now() + interval '2 days');
  -- Kayıt olayı (hesap oluşturuldu): H15
  insert into public.growth_events (household_id, event_name, source, occurred_at)
    values ('${H15}', 'hesap_olusturuldu', 'server', now());
  -- H7: son 24 saatte bir e-posta gönderilmiş (sıklık sınırı 1/gün)
  insert into public.growth_message_log (household_id, channel, status, consent_snapshot, sent_at, created_at)
    values ('${H7}', 'email', 'gonderildi', '{}'::jsonb, now() - interval '1 hour', now() - interval '1 hour');

  insert into public.growth_templates (name, channel, subject, body, status)
    values ('test_sablon', 'email', 'Test {{veli_adi}}', 'Merhaba {{veli_adi}}', 'active');

  insert into public.growth_journeys (id, name, status, giris_kosulu, exit_conditions) values
    ('${JE}',  'Manuel e-posta', 'active', '{}', '{}'),
    ('${JX}',  'Çıkış (anlık)',  'active', '{}', '{"satin_alma": true, "izin_iptal": true, "cocuk_bagli": true}'),
    ('${JO}',  'Olay girişi',    'active', '{"tip": "olay", "olay": "hesap_olusturuldu", "son_saat": 24}', '{}'),
    ('${JD}',  'Deneme bitiş',   'active', '{"tip": "deneme_bitis", "kalan_gun": 3}', '{"satin_alma": true}'),
    ('${JDG}', 'Doğrulanmamış',  'active', '{"tip": "dogrulanmamis", "min_saat": 24, "max_saat": 72}', '{"dogrulandi": true}'),
    ('${JP7}', 'Pasif 7 gün',    'active', '{"tip": "pasif", "min_gun": 7, "max_gun": 30}', '{"geri_dondu": true}'),
    ('${JP30}', 'Pasif 30 gün',  'active', '{"tip": "pasif", "min_gun": 30, "max_gun": 90}', '{"geri_dondu": true}'),
    ('${JW}',  'Bekleyen çıkış', 'active', '{}', '{"dogrulandi": true, "geri_dondu": true}');
  insert into public.growth_journey_steps (journey_id, position, step_type, label, config) values
    ('${JE}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JX}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JO}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JD}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JDG}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JP7}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JP30}', 1, 'email', 'e-posta', '{"sablon": "test_sablon"}'),
    ('${JW}', 1, 'delay', 'bekle', '{"saat": 24}'),
    ('${JW}', 2, 'email', 'e-posta', '{"sablon": "test_sablon"}');
`);

// ---------------------------------------------------------------------
console.log('\n== A: seed şablon ve journey\'ler taslak; render kuralları ==');
const sablonlar = await sorgu(`select name, subject, body, status, approved, variables from public.growth_templates where name in
  ('hos_geldin','eslestirme_hatirlatma','dogrulama_hatirlatma','deneme_bitis_uyarisi','pasiflik_7_gun','winback_30_gun')`);
ok('6 seed şablon var', sablonlar.length === 6, JSON.stringify(sablonlar.map((s) => s.name)));
ok('seed şablonların tümü taslak (status=draft, approved=false)',
  sablonlar.every((s) => s.status === 'draft' && s.approved === false));
const seedJ = await sorgu(`select id, status, giris_kosulu, exit_conditions from public.growth_journeys where id = any($1::uuid[])`, [SEED]);
ok('6 seed journey var ve tümü taslak', seedJ.length === 6 && seedJ.every((j) => j.status === 'draft'), JSON.stringify(seedJ.map((j) => j.status)));
ok('seed journey\'ler giriş ve çıkış koşuluna sahip',
  seedJ.every((j) => Object.keys(j.giris_kosulu ?? {}).length > 0 && Object.keys(j.exit_conditions ?? {}).length > 0));
const seedAdim = await sorgu(`select s.step_type, s.config from public.growth_journey_steps s
   where s.journey_id = any($1::uuid[]) and s.step_type = 'email'`, [SEED]);
const sablonAdlari = new Set(sablonlar.map((s) => s.name));
ok('her seed e-posta adımı mevcut bir şablonu gösterir',
  seedAdim.length === 6 && seedAdim.every((s) => sablonAdlari.has(s.config.sablon)), JSON.stringify(seedAdim));
const izinliYer = new Set(['veli_adi', 'iptal_baglantisi']);
for (const s of sablonlar) {
  const yer = [...`${s.subject} ${s.body}`.matchAll(/\{\{\s*([A-Za-z_]\w*)\s*\}\}/g)].map((m) => m[1]);
  ok(`${s.name}: yalnız veli değişkenleri (çocuk verisi yok) ve iptal bağlantısı var`,
    yer.every((d) => izinliYer.has(d)) && yer.includes('iptal_baglantisi') && s.body.includes('{{iptal_baglantisi}}'),
    JSON.stringify(yer));
  ok(`${s.name}: puan/sınav garantisi veya sahte kanıt ifadesi yok`,
    !/garanti|puan|%|kesin|binlerce|milyon|yüzlerce/i.test(`${s.subject} ${s.body}`));
  const r = growthMesajiHazirla(s, growthDegiskenleri('Ayşe Yılmaz', 'https://hupolingo.com'));
  ok(`${s.name}: render başarılı, yer tutucu kalmadı, iptal URL'si doğru`,
    r.ok === true && !r.mesaj.metin.includes('{{') && r.mesaj.metin.includes('https://hupolingo.com/ticari-ileti-izni')
      && r.mesaj.metin.includes('Ayşe'), JSON.stringify(r));
}
const seedMesaj = await sorgu(`select count(*)::int n from public.growth_journey_enrollments where journey_id = any($1::uuid[])`, [SEED]);
ok('seed journey\'lere (taslak) hiç kayıt açılmadı', seedMesaj[0].n === 0);

// ---------------------------------------------------------------------
console.log('\n== B: bayrak kapalıyken hiçbir şey yapılmaz ==');
await postgres();
for (const h of [H1, H2, H3, H4, H7]) await tek(`select public.growth_journey_giris_al($1, $2)`, [JE, h]);
for (const h of [H6, H11, H12]) await tek(`select public.growth_journey_giris_al($1, $2)`, [JX, h]);
await tek(`select public.growth_journey_giris_al($1, $2)`, [JW, W1]);
await tek(`select public.growth_journey_giris_al($1, $2)`, [JW, W2]);
const kapali = await ilerlet();
ok('bayrak kapalı → motor kapali, işlenen 0', kapali.motor === 'kapali' && kapali.islenen === 0, JSON.stringify(kapali));
const [{ n: logK }] = await sorgu(`select count(*)::int n from public.growth_message_log`);
const [{ n: oboxK }] = await sorgu(`select count(*)::int n from public.eposta_outbox`);
ok('bayrak kapalı: günlük ve e-posta kuyruğu boş (ilk kayıtlar hariç, yalnız H7 önceden var)', logK === 1 && oboxK === 0,
  JSON.stringify({ logK, oboxK }));
const otoK = await sorgu(`select count(*)::int n from public.growth_journey_enrollments where journey_id in ($1,$2,$3,$4,$5)`, [JO, JD, JDG, JP7, JP30]);
ok('bayrak kapalı: otomatik giriş yapılmadı (olay, deneme, doğrulanmamış, pasif)', otoK[0].n === 0, JSON.stringify(otoK));
ok('bayrak kapalı: kayıt adımları değişmedi (hepsi ilk adım, active/waiting)',
  (await kayit(JE, H1)).status === 'active' && (await kayit(JE, H1)).current_step_id === await adim(JE, 1));

// ---------------------------------------------------------------------
console.log('\n== C: bayrak açık, tur 1: izin kapısı, form izni, sıklık, çıkış, otomatik giriş ==');
await bayrak(true);
const t1 = await ilerlet();
ok('tur 1: otomatik giriş yeni kayıt açtı (olay, deneme, doğrulanmamış, pasif 7 ve 30 gün)',
  t1.giris >= 5, JSON.stringify(t1));

const h1 = await epostaLog(H1);
ok('izinli hane (H1): e-posta günlüğe "kuyrukta" yazıldı', h1.length === 1 && h1[0].status === 'kuyrukta', JSON.stringify(h1));
const o1 = await outbox(H1);
ok('izinli hane (H1): eposta_outbox satırı (alıcı kimliği boş, şablon anahtarı, günlük bağlantısı)',
  o1.length === 1 && o1[0].alici_id === null && o1[0].sablon_anahtar === 'test_sablon'
    && o1[0].growth_message_id === h1[0]?.id && o1[0].durum === 'bekliyor', JSON.stringify(o1));

const h2 = await epostaLog(H2);
ok('izinsiz hane (H2, hesapsız, izin yok): engellendi + error=izin_yok; outbox YOK',
  h2.length === 1 && h2[0].status === 'engellendi' && h2[0].error === 'izin_yok'
    && (await outbox(H2)).length === 0, JSON.stringify(h2));
const h3 = await epostaLog(H3);
ok('bastırılmış adres (H3, izinli veli): engellendi + error=izin_yok (bastırma kapısı)',
  h3.length === 1 && h3[0].status === 'engellendi' && h3[0].error === 'izin_yok', JSON.stringify(h3));
const h4 = await epostaLog(H4);
ok('form izni olan deneme kişisi (H4, hesapsız): geçer, kuyrukta + outbox',
  h4.length === 1 && h4[0].status === 'kuyrukta' && (await outbox(H4)).length === 1, JSON.stringify(h4));
const h7 = await epostaLog(H7);
const h7son = h7.filter((x) => x.status === 'engellendi');
ok('sıklık sınırı aşımı (H7, 1 saat önce gönderim): engellendi + error=siklik_siniri, outbox YOK',
  h7son.length === 1 && h7son[0].error === 'siklik_siniri' && (await outbox(H7)).length === 0, JSON.stringify(h7));
ok('engellenen adım ilerler (H7 artık ikinci adımda / tamamlandı)', (await kayit(JE, H7)).current_step_id === null
  || (await kayit(JE, H7)).status === 'completed', JSON.stringify(await kayit(JE, H7)));
ok('bloklu hane (H5) kayıt alamaz', await tek(`select count(*)::int n from public.growth_journey_enrollments where household_id = $1`, [H5])
  .then((r) => r.n === 0));

const ex6 = await kayit(JX, H6);
ok('çıkış (izin iptali): H6 exited, cikis_nedeni=izin_iptal',
  ex6.status === 'exited' && ex6.metadata?.cikis_nedeni === 'izin_iptal', JSON.stringify(ex6));
const ex11 = await kayit(JX, H11);
ok('çıkış (çocuk bağlandı): H11 exited, cikis_nedeni=cocuk_bagli',
  ex11.status === 'exited' && ex11.metadata?.cikis_nedeni === 'cocuk_bagli', JSON.stringify(ex11));
const ex12 = await kayit(JX, H12);
ok('çıkış (satın alma): H12 exited (ücretli plan), cikis_nedeni=satin_alma',
  ex12.status === 'exited' && ex12.metadata?.cikis_nedeni === 'satin_alma', JSON.stringify(ex12));
ok('çıkan kayıtlardan e-posta kuyruğa girmedi', (await outbox(H6)).length === 0 && (await outbox(H11)).length === 0);

const olay = await kayit(JO, H15);
ok('olay girişi: H15 (hesap_olusturuldu son 24 saat) JO\'ya girdi ve e-posta kuyrukta',
  !!olay && (await epostaLog(H15)).some((x) => x.status === 'kuyrukta'), JSON.stringify(olay));
ok('olay girişi: olay yok hane (H1) JO\'ya girmedi', (await kayit(JO, H1)) === undefined);
const dn = await kayit(JD, H13);
ok('deneme bitiş girişi: H13 (2 gün kala) JD\'ye girdi', !!dn, JSON.stringify(dn));
ok('deneme girişi: projeksiyonu olmayan H4 JD\'ye girmedi', (await kayit(JD, H4)) === undefined);
const dg = await kayit(JDG, H8);
ok('doğrulanmamış giriş: H8 (30 saat önce, e-posta doğrulanmamış) JDG\'ye girdi', !!dg, JSON.stringify(dg));
ok('doğrulanmamış giriş: yeni hesap (H1) JDG\'ye girmedi', (await kayit(JDG, H1)) === undefined);
ok('pasif 7 gün girişi: H9 (10 gün pasif) JP7\'ye girdi', !!(await kayit(JP7, H9)));
ok('pasif 30 gün girişi: H10 (40 gün pasif) JP30\'a girdi, JP7\'ye değil',
  !!(await kayit(JP30, H10)) && (await kayit(JP7, H10)) === undefined);
ok('pasif girişi: son etkinliği 1 gün önce olan W2 pasif listelere girmedi', (await kayit(JP7, W2)) === undefined);

// Tur 2: otomatik giriş tekrar açmaz (her journey + hane için tek kayıt)
const t2 = await ilerlet();
const [{ n: olayAdet }] = await sorgu(`select count(*)::int n from public.growth_journey_enrollments where journey_id = $1 and household_id = $2`, [JO, H15]);
ok('tur 2: aynı journey + hane için yeni kayıt açılmadı (tek satır)', olayAdet === 1 && t2.giris === 0, JSON.stringify({ olayAdet, t2 }));

// ---------------------------------------------------------------------
console.log('\n== D: çıkış koşulları (bekleyen kayıt: dogrulandi, geri_dondu) ==');
await tek(`select public.growth_journey_giris_al($1, $2)`, [JW, W1]).catch(() => {});
const w1 = await kayit(JW, W1);
const w2 = await kayit(JW, W2);
ok('bekleyen kayıtlar (JW, bekleme adımında) hazır', w1?.status === 'waiting' && w2?.status === 'waiting', JSON.stringify({ w1, w2 }));
await db.exec(`update auth.users set email_confirmed_at = now() where id = '${V5}';
  update public.growth_journey_enrollments set next_run_at = now() where journey_id = '${JW}' and household_id = '${W1}'`);
await ilerlet();
const w1s = await kayit(JW, W1);
ok('e-posta doğrulanınca bekleyen kayıt çıkar (dogrulandi)', w1s.status === 'exited' && w1s.metadata?.cikis_nedeni === 'dogrulandi',
  JSON.stringify(w1s));
const w2Once = await kayit(JW, W2);
ok('W2 bu aşamada hâlâ bekliyor (dogrulandi koşulu yok, V9 doğrulanmamış)', w2Once.status === 'waiting', JSON.stringify(w2Once));
await db.exec(`update public.growth_households set last_seen_at = clock_timestamp() where id = '${W2}';
  update public.growth_journey_enrollments set next_run_at = now() where journey_id = '${JW}' and household_id = '${W2}'`);
await ilerlet();
const w2s = await kayit(JW, W2);
ok('kayıt sonrası etkinlik olunca bekleyen kayıt çıkar (geri_dondu)', w2s.status === 'exited' && w2s.metadata?.cikis_nedeni === 'geri_dondu',
  JSON.stringify(w2s));

// ---------------------------------------------------------------------
console.log('\n== E: sessiz saat → ertelenir (günlük satırı yok, adım aynı) ==');
await db.exec(`update public.iletisim_ayarlari set sessiz_baslangic = '00:00', sessiz_bitis = '23:59:59'`);
await tek(`select public.growth_journey_giris_al($1, $2)`, [JE, H17]);
const e17 = await ilerlet();
const k17 = await kayit(JE, H17);
const sonrakiZaman = new Date(k17.next_run_at).getTime();
ok('sessiz saatte kayıt ertelenir: waiting, aynı adım, günlüğe yazılmaz, outbox yok',
  k17.status === 'waiting' && k17.current_step_id === await adim(JE, 1)
    && (await logl(H17)).length === 0 && (await outbox(H17)).length === 0, JSON.stringify({ e17, k17 }));
ok('ertelenen kaydın zamanı gelecekte (sonraki uygun an)', sonrakiZaman > Date.now(), String(k17.next_run_at));
await db.exec(`update public.iletisim_ayarlari set sessiz_baslangic = '00:00', sessiz_bitis = '00:00'`);

// ---------------------------------------------------------------------
console.log('\n== F: gönderim anı izin kontrolü ve sonuç yazımı (service_role RPC\'leri) ==');
await postgres();
const [{ izin_h1 }] = [{ izin_h1: (await tek(`select public.growth_pazarlama_izni_var_mi($1, 'email') as v`, [H1])).v }];
ok('gönderim anı: izinli H1 → true', izin_h1 === true);
ok('gönderim anı: form izinli deneme kişisi H4 → true', (await tek(`select public.growth_pazarlama_izni_var_mi($1, 'email') as v`, [H4])).v === true);
ok('gönderim anı: izinsiz H2 → false', (await tek(`select public.growth_pazarlama_izni_var_mi($1, 'email') as v`, [H2])).v === false);
await db.exec(`update public.iletisim_tercihleri set izin = false where veli_id = '${V1}' and kanal = 'eposta'`);
ok('kuyruğa alındıktan sonra izin geri çekilirse gönderim anı kontrolü false döner (H1)',
  (await tek(`select public.growth_pazarlama_izni_var_mi($1, 'email') as v`, [H1])).v === false);
await db.exec(`update public.iletisim_tercihleri set izin = true where veli_id = '${V1}' and kanal = 'eposta'`);
await db.exec(`update public.growth_households set account_status = 'blocked' where id = '${H4}'`);
ok('engelli (blocked) hane gönderim anında uygun değil (H4)',
  (await tek(`select public.growth_pazarlama_izni_var_mi($1, 'email') as v`, [H4])).v === false);
await db.exec(`update public.growth_households set account_status = 'active' where id = '${H4}'`);
await hataBekle('e-posta dışı kanal reddedilir', () => sorgu(`select public.growth_pazarlama_izni_var_mi($1, 'sms')`, [H1]),
  'yalnız e-posta');

const mesajH1 = h1[0].id;
await tek(`select public.growth_gonderim_sonucu_yaz($1, 'gonderildi', null) as x`, [mesajH1]);
const m1 = await tek(`select status, sent_at, error from public.growth_message_log where id = $1`, [mesajH1]);
ok('sonuç: gönderildi → günlük status=gonderildi, sent_at dolu', m1.status === 'gonderildi' && m1.sent_at !== null, JSON.stringify(m1));
const mesajH4 = h4[0].id;
await tek(`select public.growth_gonderim_sonucu_yaz($1, 'basarisiz', 'HTTP 500') as x`, [mesajH4]);
const m4 = await tek(`select status, sent_at, error from public.growth_message_log where id = $1`, [mesajH4]);
ok('sonuç: basarisiz → status=basarisiz, error=HTTP 500', m4.status === 'basarisiz' && m4.error === 'HTTP 500', JSON.stringify(m4));
await hataBekle('geçersiz sonuç durumu reddedilir', () => sorgu(`select public.growth_gonderim_sonucu_yaz($1, 'kuyrukta', null)`, [mesajH1]),
  'Geçersiz gönderim sonucu');

// ---------------------------------------------------------------------
console.log('\n== G: e-posta kuyruğu bütünlük kuralı ve yetkiler ==');
await hataBekle('alıcı kimliği de hane de yoksa outbox satırı reddedilir',
  () => db.exec(`insert into public.eposta_outbox (alici_id, konu, govde) values (null, 'k', 'g')`),
  'eposta_outbox_alici_kaynak_chk');
const yetki = await tek(`select
    has_function_privilege('anon', 'public.growth_pazarlama_izni_var_mi(uuid, text)', 'EXECUTE') as anon_izin,
    has_function_privilege('authenticated', 'public.growth_pazarlama_izni_var_mi(uuid, text)', 'EXECUTE') as auth_izin,
    has_function_privilege('service_role', 'public.growth_pazarlama_izni_var_mi(uuid, text)', 'EXECUTE') as svc_izin,
    has_function_privilege('anon', 'public.growth_gonderim_sonucu_yaz(uuid, text, text)', 'EXECUTE') as anon_sonuc,
    has_function_privilege('authenticated', 'public.growth_gonderim_sonucu_yaz(uuid, text, text)', 'EXECUTE') as auth_sonuc,
    has_function_privilege('service_role', 'public.growth_gonderim_sonucu_yaz(uuid, text, text)', 'EXECUTE') as svc_sonuc,
    has_function_privilege('anon', 'public._growth_izin_var_mi(uuid, text)', 'EXECUTE') as anon_ic,
    has_function_privilege('authenticated', 'public._growth_otomatik_giris(int)', 'EXECUTE') as auth_oto,
    has_function_privilege('anon', 'public._growth_mesaj_engelle(uuid, uuid, uuid, text, text, jsonb)', 'EXECUTE') as anon_engel`);
ok('yetki: yeni RPC\'ler yalnız service_role', !yetki.anon_izin && !yetki.auth_izin && yetki.svc_izin
  && !yetki.anon_sonuc && !yetki.auth_sonuc && yetki.svc_sonuc, JSON.stringify(yetki));
ok('yetki: iç yardımcılar anon/authenticated\'a kapalı',
  !yetki.anon_ic && !yetki.auth_oto && !yetki.anon_engel, JSON.stringify(yetki));
await kimsin('anon');
await hataBekle('anon gönderim anı kontrolü çağıramaz', () => sorgu(`select public.growth_pazarlama_izni_var_mi($1, 'email')`, [H1]), 'permission denied');
await kimsin('authenticated');
await hataBekle('authenticated sonuç yazamaz', () => sorgu(`select public.growth_gonderim_sonucu_yaz($1, 'gonderildi', null)`, [mesajH1]), 'permission denied');
await postgres();

// ---------------------------------------------------------------------
console.log('\n== H: gizlilik: günlük ve kuyrukta e-posta adresi / çocuk verisi yok ==');
const tumGunluk = JSON.stringify(await sorgu(`select consent_snapshot, error from public.growth_message_log`));
ok('günlük satırlarında e-posta adresi yok', !/@t\.local/.test(tumGunluk), tumGunluk.slice(0, 200));
const tumKuyruk = JSON.stringify(await sorgu(`select konu, govde, sablon_anahtar from public.eposta_outbox`));
ok('kuyrukta çocuk adı yok (C7 adı hiçbir yerde değil)', !tumKuyruk.includes('Çocuk Yedi') && !tumGunluk.includes('Çocuk Yedi'));

// ---------------------------------------------------------------------
console.log('\n== I: yeniden çalıştırma (idempotent) ==');
await kur('20261099 yeniden', () => db.exec(oku('20261099000000_growth_journey_motoru.sql')));
const bayrakSonra = await tek(`select deger from public.growth_motor_ayarlari where anahtar = 'growth_journey_motoru_acik'`);
ok('20261099 ikinci kez çalışınca açık bayrak kapanmıyor', bayrakSonra.deger === true);
const [{ n: cronAdet }] = await sorgu(`select count(*)::int n from cron.job where jobname = 'growth-journey-ilerlet'`);
ok('zamanlayıcı çoğalmıyor', cronAdet === 1, `iş ${cronAdet}`);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
