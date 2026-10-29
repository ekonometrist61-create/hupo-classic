// Growth iletişim uygunluk kapısı testi (20261101): izin, sessiz saat, sıklık sınırı, yetki.
// Gerçek migration zinciri PGlite (WASM Postgres) üzerinde çalışır.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const YENI = '20261101000000_growth_iletisim_uygunluk.sql';
const ZINCIR = [
  '20261007000010_crm_profil_tercihler_ve_denetim.sql',
  '20261007000020_segment_kampanya_ve_iletisim_ayarlari.sql',
  '20261015000000_iletisim_izni_kayit_ve_iptal.sql',
  '20261020000300_iletisim_kanal_telefon_ve_uc_kanal_kayit.sql',
];

const db = new PGlite();
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8');
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;

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

// Rol taklidi: çağrı bittiğinde (hata olsa bile) postgres rolüne dönülür.
const rolde = async (rol, fn) => {
  await db.exec(`reset role; set role ${rol};`);
  try { return await fn(); }
  finally { await db.exec('reset role;'); }
};

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const V1 = id(2), V2 = id(3), S1 = id(4);
const H = (n) => id(100 + n);            // hane kimliği
const BASE = '2026-10-27T09:00:00Z';     // 12:00 İstanbul (UTC+3, yaz saati yok)
const IST_SABAH = '2026-10-28T06:00:00Z'; // 28 Ekim 09:00 İstanbul
const fnSql = 'select public.growth_iletisim_uygun_mu($1::uuid, $2::text, $3::timestamptz) as j';
const kontrol = (hane, kanal, zaman = BASE) =>
  rolde('service_role', async () => (await sorgu(fnSql, [hane, kanal, zaman]))[0].j);
const ayniAn = (j, iso) => j.sonraki_uygun !== null && Date.parse(j.sonraki_uygun) === Date.parse(iso);
const hane = (n, core, email) => db.query(
  `insert into public.growth_households (id, core_parent_user_id, parent_name, email) values ($1, $2, 'Test', $3)`,
  [H(n), core, email]);
const mesaj = (n, kanal, durum, zaman, gonderim = zaman) => db.query(
  `insert into public.growth_message_log (household_id, channel, status, consent_snapshot, sent_at, created_at)
   values ($1, $2, $3, '{}'::jsonb, $4::timestamptz, $5::timestamptz)`,
  [H(n), kanal, durum, gonderim, zaman]);
const varsayilanAyar = () => db.exec(`
  update public.iletisim_ayarlari
     set haftalik_limit = 3, sessiz_baslangic = '21:00', sessiz_bitis = '09:00', zaman_dilimi = 'Europe/Istanbul';
  update public.growth_iletisim_limitleri set gunluk_limit = 1;`);

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await db.exec(fs.readFileSync(path.join(import.meta.dirname, 'stubs.sql'), 'utf8'));
for (const f of ZINCIR) await db.exec(oku(f));
// 20261101 izni growth_consent_bridge üzerinden okur (tek tanım). Görünüm 20261014000000'daki
// tanımın birebir kopyasıdır; bu harness 20261014 zincirini yüklemez.
await db.exec(`
  create or replace view public.growth_consent_bridge with (security_invoker = true) as
  select h.id as household_id,
    case t.kanal when 'eposta' then 'email' when 'push' then 'push' when 'sms' then 'sms' when 'uygulama_ici' then 'in_app' end as channel,
    t.izin as granted, t.kaynak as source, t.updated_at as changed_at
  from public.iletisim_tercihleri t
  join public.growth_households h on h.core_parent_user_id = t.veli_id;`);
ok('iletişim izni ve ayar zinciri hatasız', true);
await db.exec(oku(YENI));
ok('20261101 migration ilk kez hatasız', true);
await db.exec(oku(YENI));
ok('20261101 migration ikinci kez hatasız (idempotent)', true);

await db.exec(`insert into public.profiles (id, role, parent_id, full_name) values
  ('${V1}', 'veli', null, 'Veli Bir'), ('${V2}', 'veli', null, 'Veli İki'),
  ('${S1}', 'ogrenci', '${V1}', 'Öğrenci Bir');`);
for (const [kanal, izin] of [['eposta', true], ['push', true], ['sms', true], ['uygulama_ici', false]]) {
  await db.query(`select public._tercih_yaz($1, $2, $3, 'admin', null, 'test')`, [V1, kanal, izin]);
}
await db.query(`select public._tercih_yaz($1, 'eposta', false, 'admin', null, 'test')`, [V2]);

// H1 izinli; H2 veli izinsiz; H3 core velisi yok; H4 e-postası iptal bastırmasında;
// H5-H11 sıklık senaryoları; H30 ayar-0 senaryosu.
const haneler = [
  [1, V1, 'h1@test.local'], [2, V2, 'h2@test.local'], [3, null, 'h3@test.local'],
  [4, V1, 'h4@test.local'], [5, V1, 'h5@test.local'], [6, V1, 'h6@test.local'],
  [7, V1, 'h7@test.local'], [8, V1, 'h8@test.local'], [9, V1, 'h9@test.local'],
  [10, V1, 'h10@test.local'], [11, V1, 'h11@test.local'], [30, V1, 'h30@test.local'],
];
for (const [n, core, email] of haneler) await hane(n, core, email);
await db.query(
  `insert into public.growth_prospect_suppressions (email_hash, channel, reason, source)
   values (public._eposta_karmasi($1), 'eposta', 'kullanici_iptali', 'iptal_sayfasi')`,
  ['h4@test.local']);

console.log('\n== A: izin kapısı ==');
await varsayilanAyar();
let j = await kontrol(H(1), 'email');
ok('izinli e-posta (H1): uygun=true, neden=null', j.uygun === true && j.neden === null, JSON.stringify(j));
ok('uygunda sonraki_uygun = şimdi', ayniAn(j, BASE), JSON.stringify(j));
ok('sms izni olan hane uygun', (await kontrol(H(1), 'sms')).uygun === true);
ok('push izni olan hane uygun', (await kontrol(H(1), 'push')).uygun === true);
ok('kanal adı büyük harf ve boşlukla da çalışır (" EMAIL ")', (await kontrol(H(1), ' EMAIL ')).uygun === true);
ok('core kanal adı kabul edilir ("eposta")', (await kontrol(H(1), 'eposta')).uygun === true);
j = await kontrol(H(1), 'in_app');
ok('uygulama içi izni false → izin_yok, sonraki null', j.uygun === false && j.neden === 'izin_yok' && j.sonraki_uygun === null, JSON.stringify(j));
ok('uygulama_ici takma adı da izin_yok', (await kontrol(H(1), 'uygulama_ici')).neden === 'izin_yok');
j = await kontrol(H(1), 'whatsapp');
ok('whatsapp core kanalı değil → izin_yok', j.neden === 'izin_yok' && j.sonraki_uygun === null, JSON.stringify(j));
j = await kontrol(H(2), 'email');
ok('ticari izni kapalı veli (V2) → izin_yok', j.uygun === false && j.neden === 'izin_yok', JSON.stringify(j));
ok('hiç izin kaydı olmayan kanal (V2 push) → izin_yok', (await kontrol(H(2), 'push')).neden === 'izin_yok');
ok('core velisi olmayan hane (H3) → izin_yok', (await kontrol(H(3), 'email')).neden === 'izin_yok');
j = await kontrol(H(4), 'email');
ok('e-posta iptal bastırması (H4) → izin_yok', j.neden === 'izin_yok', JSON.stringify(j));
ok('bastırma yalnız e-postayı etkiler: H4 push uygun', (await kontrol(H(4), 'push')).uygun === true);
await db.query(`update public.iletisim_tercihleri set izin = false where veli_id = $1 and kanal = 'eposta'`, [V1]);
ok('velinin e-posta izni geri çekilince H1 → izin_yok', (await kontrol(H(1), 'email')).neden === 'izin_yok');
await db.query(`update public.iletisim_tercihleri set izin = true where veli_id = $1 and kanal = 'eposta'`, [V1]);
ok('izin geri verilince H1 yeniden uygun', (await kontrol(H(1), 'email')).uygun === true);
await hataBekle('desteklenmeyen kanal (telefon) reddedilir', () => kontrol(H(1), 'telefon'), 'Geçersiz kanal');
await hataBekle('boş kanal reddedilir', () => kontrol(H(1), ''), 'Geçersiz kanal');
await hataBekle('olmayan hane → hata', () => kontrol(id(999), 'email'), 'Hane bulunamadı');

console.log('\n== B: sessiz saat (21:00-09:00 İstanbul) ==');
const sessizSenaryo = [
  ['20:59 İstanbul: uygun', '2026-10-27T17:59:00Z', false],
  ['21:00 İstanbul: sessiz, sonraki 09:00', '2026-10-27T18:00:00Z', true],
  ['23:30 İstanbul: sessiz, sonraki 09:00', '2026-10-27T20:30:00Z', true],
  ['00:30 İstanbul: sessiz, sonraki 09:00', '2026-10-27T21:30:00Z', true],
  ['08:59 İstanbul: sessiz, sonraki 09:00', '2026-10-28T05:59:00Z', true],
  ['09:00 İstanbul: uygun', '2026-10-28T06:00:00Z', false],
];
for (const [ad, zaman, sessizBeklenen] of sessizSenaryo) {
  const r = await kontrol(H(1), 'email', zaman);
  if (sessizBeklenen) {
    ok(ad, r.uygun === false && r.neden === 'sessiz_saat' && ayniAn(r, IST_SABAH), JSON.stringify(r));
  } else {
    ok(ad, r.uygun === true, JSON.stringify(r));
  }
}
j = await kontrol(H(2), 'email', '2026-10-27T18:30:00Z');
ok('izin kontrolü sessiz saatten önce: H2 (izinsiz) 21:30\'da izin_yok', j.neden === 'izin_yok', JSON.stringify(j));
await db.exec(`update public.iletisim_ayarlari set sessiz_baslangic = '20:00'`);
ok('sessiz saat satırdan okunur: 20:00 ayarında 20:30 sessiz', (await kontrol(H(1), 'email', '2026-10-27T17:30:00Z')).neden === 'sessiz_saat');
await varsayilanAyar();
ok('ayar 21:00\'a dönünce 20:30 uygun', (await kontrol(H(1), 'email', '2026-10-27T17:30:00Z')).uygun === true);
await db.exec(`delete from public.iletisim_ayarlari`);
ok('ayar satırı yokken 21:30 İstanbul sessiz (varsayılan 21:00)', (await kontrol(H(1), 'email', '2026-10-27T18:30:00Z')).neden === 'sessiz_saat');
ok('ayar satırı yokken 20:30 İstanbul uygun (varsayılan 21:00)', (await kontrol(H(1), 'email', '2026-10-27T17:30:00Z')).uygun === true);
await db.exec(`insert into public.iletisim_ayarlari (id) values (true)`);
await varsayilanAyar();

console.log('\n== C: sıklık sınırı (günlük 1, haftalık 3; BASE = 12:00 İstanbul) ==');
await mesaj(5, 'email', 'basarisiz', '2026-10-27T08:00:00Z');
await mesaj(5, 'email', 'iptal', '2026-10-27T08:30:00Z');
ok('sayılmayan durumlar (basarisiz, iptal) sınır oluşturmaz', (await kontrol(H(5), 'email')).uygun === true);

await mesaj(6, 'email', 'gonderildi', '2026-10-27T07:00:00Z');
j = await kontrol(H(6), 'email');
ok('son 24 saatte 1 e-posta → siklik_siniri', j.uygun === false && j.neden === 'siklik_siniri', JSON.stringify(j));
ok('sonraki_uygun = mesaj + 24 saat (28 Ekim 10:00 İstanbul)', ayniAn(j, '2026-10-28T07:00:00Z'), JSON.stringify(j));

await mesaj(7, 'push', 'gonderildi', '2026-10-27T08:00:00Z');
ok('push mesajı e-posta sınırını etkilemez (H7 e-posta uygun)', (await kontrol(H(7), 'email')).uygun === true);
j = await kontrol(H(7), 'push');
ok('aynı kanalda (push) sınır uygulanır', j.neden === 'siklik_siniri' && ayniAn(j, '2026-10-28T08:00:00Z'), JSON.stringify(j));

await mesaj(8, 'email', 'gonderildi', '2026-10-26T09:00:00Z');
ok('tam 24 saat önceki mesaj sayılmaz (pencere dışlayıcı)', (await kontrol(H(8), 'email')).uygun === true);
await mesaj(9, 'email', 'gonderildi', '2026-10-26T09:01:00Z');
j = await kontrol(H(9), 'email');
ok('23 saat 59 dakika önceki mesaj sayılır, sonraki +1 dk', j.neden === 'siklik_siniri' && ayniAn(j, '2026-10-27T09:01:00Z'), JSON.stringify(j));

const sayilanDurumlar = ['gonderildi', 'teslim_edildi', 'acildi', 'tiklandi', 'donustu', 'kuyrukta'];
for (let i = 0; i < sayilanDurumlar.length; i++) {
  const n = 150 + i;
  const durum = sayilanDurumlar[i];
  await hane(n, V1, `durum${i}@test.local`);
  await mesaj(n, 'email', durum, '2026-10-27T08:00:00Z', durum === 'kuyrukta' ? null : '2026-10-27T08:00:00Z');
  const r = await kontrol(H(n), 'email');
  ok(`sayılan durum "${durum}" sınır oluşturur`, r.neden === 'siklik_siniri', JSON.stringify(r));
}

for (const z of ['2026-10-21T20:00:00Z', '2026-10-23T10:00:00Z', '2026-10-25T10:00:00Z']) {
  await mesaj(10, 'email', 'gonderildi', z);
}
j = await kontrol(H(10), 'email');
ok('son 7 günde 3 e-posta → haftalık sınır', j.neden === 'siklik_siniri', JSON.stringify(j));
ok('sonraki = en eski + 7 gün (23:00 İst) sessize düştüğü için 29 Ekim 09:00', ayniAn(j, '2026-10-29T06:00:00Z'), JSON.stringify(j));

await mesaj(11, 'email', 'gonderildi', '2026-10-21T20:00:00Z');
await mesaj(11, 'email', 'gonderildi', '2026-10-23T10:00:00Z');
ok('son 7 günde 2 e-posta (sınır 3) → uygun', (await kontrol(H(11), 'email')).uygun === true);
await db.exec(`update public.iletisim_ayarlari set haftalik_limit = 2`);
j = await kontrol(H(11), 'email');
ok('haftalık ayar 2 iken aynı hane engellenir (ayar satırından okunur)',
  j.neden === 'siklik_siniri' && ayniAn(j, '2026-10-29T06:00:00Z'), JSON.stringify(j));
await varsayilanAyar();

await db.exec(`update public.growth_iletisim_limitleri set gunluk_limit = 2`);
ok('günlük ayar 2 iken tek mesajlı H6 uygun (tablodan okunur)', (await kontrol(H(6), 'email')).uygun === true);
await db.exec(`update public.growth_iletisim_limitleri set gunluk_limit = 0`);
j = await kontrol(H(30), 'email');
ok('günlük sınır 0 → kanal kapalı: siklik_siniri, sonraki yok', j.neden === 'siklik_siniri' && j.sonraki_uygun === null, JSON.stringify(j));
await varsayilanAyar();
j = await kontrol(H(6), 'email');
ok('varsayılana dönünce H6 yeniden engellenir', j.neden === 'siklik_siniri', JSON.stringify(j));

console.log('\n== D: yetki ve sertleştirme ==');
await hataBekle('anon çağıramaz', () => rolde('anon', () => sorgu(fnSql, [H(1), 'email', BASE])), 'permission denied');
await hataBekle('authenticated çağıramaz', () => rolde('authenticated', () => sorgu(fnSql, [H(1), 'email', BASE])), 'permission denied');
ok('service_role çağırabilir', (await kontrol(H(1), 'email')).uygun === true);
await hataBekle('anon ayar tablosunu okuyamaz', () => rolde('anon', () => sorgu('select * from public.growth_iletisim_limitleri')), 'permission denied');
await hataBekle('authenticated ayar tablosunu okuyamaz', () => rolde('authenticated', () => sorgu('select * from public.growth_iletisim_limitleri')), 'permission denied');
await hataBekle('authenticated iç yardımcıyı çağıramaz (_growth_sessiz_mi)',
  () => rolde('authenticated', () => sorgu(`select public._growth_sessiz_mi(now(), time '21:00', time '09:00', 'Europe/Istanbul')`)), 'permission denied');
await hataBekle('anon iç yardımcıyı çağıramaz (_growth_siklik_sonraki)',
  () => rolde('anon', () => sorgu(`select public._growth_siklik_sonraki($1, 'email', now(), interval '1 day', 1)`, [H(1)])), 'permission denied');
const [pr] = await sorgu(`select prosecdef, proconfig from pg_proc where proname = 'growth_iletisim_uygun_mu'`);
ok("growth_iletisim_uygun_mu SECURITY DEFINER ve search_path = ''",
  pr.prosecdef === true && JSON.stringify(pr.proconfig).includes('search_path='), JSON.stringify(pr));
const [rls] = await sorgu(`select relrowsecurity from pg_class where relname = 'growth_iletisim_limitleri'`);
ok('growth_iletisim_limitleri için RLS açık', rls.relrowsecurity === true);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
