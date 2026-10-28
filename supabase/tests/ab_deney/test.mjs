// A/B motoru A1: deney tanımı ve atama. Gerçek migration PGlite üzerinde; uzak DB'ye dokunmaz.
// Zincir: yaşam stub (profiles, require_admin, auth.uid) + log stub → 20261121.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');

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
const tek = async (sql, p = []) => (await db.query(sql, p)).rows[0];
const sorgu = async (sql, p = []) => (await db.query(sql, p)).rows;
const ADMIN = '00000000-0000-4000-8000-000000000001';
const VELI = '00000000-0000-4000-8000-000000000002';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`create table if not exists public.test_admin_log (aksiyon text, detay jsonb);
  create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void
  language sql as $$ insert into public.test_admin_log values (p_aksiyon, p_detay) $$;`);
await db.exec(fs.readFileSync(path.join(MIG, '20261121000000_ab_deney.sql'), 'utf8'));
await db.exec(`insert into auth.users (id, email) values ('${ADMIN}', 'a@t'), ('${VELI}', 'v@t');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin'), ('${VELI}', 'veli');`);
ok('migration yüklendi', true);

const bugun = (await tek(`select ((now() at time zone 'Europe/Istanbul')::date) as d`)).d;
const gun = (n) => `(((now() at time zone 'Europe/Istanbul')::date) + ${n})`;

await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
console.log('\n== Taslak ve başlatma kapıları ==');
const id = (await tek(`select public.admin_ab_deney_kaydet('Fiyat testi 1', 'Ucuz paket daha çok ödeme getirir', 'odeme_orani',
  array['iade_orani','sikayet_orani'], 0.10, 0.02, 0.05, 0.8, 1200, ${gun(0)}, ${gun(30)}, 'Ürün ekibi') as id`)).id;
const d0 = await tek(`select durum from public.ab_deney where id = $1`, [id]);
ok('kayıt taslak olarak oluşur', d0.durum === 'taslak');
await hataBekle('onay notu olmadan başlatılamaz', () => tek(`select public.admin_ab_deney_baslat($1, '   ')`, [id]), 'Onay notu');
await hataBekle('kol başına örneklem 30 altı reddedilir', () => tek(`select public.admin_ab_deney_kaydet('Kısa', 'Kısa bir hipotez metni', 'odeme', array['a','b'], 0.1, 0.02, 0.05, 0.8, 10, ${gun(0)}, ${gun(5)}, 'Ekip')`), 'check');
await hataBekle('tek guardrail reddedilir', () => tek(`select public.admin_ab_deney_kaydet('Tek', 'Tek guardrail hipotez metni', 'odeme', array['a'], 0.1, 0.02, 0.05, 0.8, 500, ${gun(0)}, ${gun(5)}, 'Ekip')`), 'check');
await hataBekle('bitiş başlangıçtan önce reddedilir', () => tek(`select public.admin_ab_deney_kaydet('Ters', 'Ters tarih hipotez metni', 'odeme', array['a','b'], 0.1, 0.02, 0.05, 0.8, 500, ${gun(5)}, ${gun(1)}, 'Ekip')`), 'check');
await sorgu(`select public.admin_ab_deney_baslat($1, 'Ürün ve hukuk onayı alındı')`, [id]);
const d1 = await tek(`select durum, onay_notu from public.ab_deney where id = $1`, [id]);
ok('onayla başlatılır: durum yayinda, onay notu kaydedilir', d1.durum === 'yayinda' && d1.onay_notu.length > 0, JSON.stringify(d1));
await hataBekle('yayındaki deney tekrar başlatılamaz', () => tek(`select public.admin_ab_deney_baslat($1, 'tekrar')`, [id]), 'Yalnız taslak');

console.log('\n== Atama ==');
await db.exec(`reset role;`);
await db.exec(`set request.jwt.claims = '';`);
const anonKol = await tek(`select public.ab_kol($1) as k`, [id]);
ok('oturumsuz kullanıcıya kol verilmez (null)', anonKol.k === null);

// 2000 sentetik kullanıcı, her biri kendi oturumunda
let kontrol = 0;
let deney = 0;
const kullanicilar = [];
for (let i = 1; i <= 2000; i++) {
  kullanicilar.push(`00000000-0000-4000-7000-${String(i).padStart(12, '0')}`);
}
for (const u of kullanicilar) {
  await db.exec(`set request.jwt.claims = '{"sub":"${u}"}';`);
  const r = (await tek(`select public.ab_kol($1) as k`, [id])).k;
  if (r === 'kontrol') kontrol++;
  else if (r === 'deney') deney++;
  else throw new Error(`beklenmeyen kol: ${r}`);
}
await db.exec(`reset role;`);
const oran = deney / (kontrol + deney);
ok('2000 kullanıcı iki kola da bölünür', kontrol > 0 && deney > 0 && kontrol + deney === 2000, `kontrol=${kontrol} deney=${deney}`);
ok('kol dağılımı dengeli (%45–%55 deney)', oran > 0.45 && oran < 0.55, `oran=${oran.toFixed(3)}`);

await db.exec(`set request.jwt.claims = '{"sub":"${kullanicilar[0]}"}';`);
const k1 = (await tek(`select public.ab_kol($1) as k`, [id])).k;
const k2 = (await tek(`select public.ab_kol($1) as k`, [id])).k;
ok('aynı kullanıcı her seferinde aynı kolu alır (deterministik)', k1 === k2);
ok('kol yalnız kontrol veya deney olabilir', k1 === 'kontrol' || k1 === 'deney');


console.log('\n== Durdurma ve zaman aralığı ==');
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
await sorgu(`select public.admin_ab_deney_durdur($1, 'İade oranı eşik üstü')`, [id]);
const d2 = await tek(`select durum from public.ab_deney where id = $1`, [id]);
ok('guardrail ihlalinde durdurulur', d2.durum === 'durduruldu');
await db.exec(`set request.jwt.claims = '{"sub":"${kullanicilar[0]}"}';`);
const durmus = (await tek(`select public.ab_kol($1) as k`, [id])).k;
ok('durdurulan deneyde kol verilmez', durmus === null);

await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
const sure = await tek(`select public.admin_ab_deney_kaydet('Süresi dolmuş', 'Süresi dolmuş hipotez metni', 'odeme', array['a','b'], 0.1, 0.02, 0.05, 0.8, 500, ${gun(-20)}, ${gun(-10)}, 'Ekip') as id`);
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
await hataBekle('bitmiş tarihli taslak başlatılamaz', () => tek(`select public.admin_ab_deney_baslat($1, 'geç')`, [sure.id]), 'Bitiş');

console.log('\n== Yetki ==');
await db.exec(`set request.jwt.claims = '{"sub":"${VELI}"}';`);
await hataBekle('veli deney kaydedemez', () => tek(`select public.admin_ab_deney_kaydet('V', 'Veli hipotez metni', 'o', array['a','b'], 0.1, 0.02, 0.05, 0.8, 500, ${gun(0)}, ${gun(5)}, 'V')`), 'Yetkisiz');
await hataBekle('veli deney listesini göremez', () => tek(`select public.admin_ab_deney_listele(5)`), 'Yetkisiz');
await db.exec(`reset role; set role anon;`);
await hataBekle('anon ab_kol çağıramaz', () => tek(`select public.ab_kol($1)`, [id]), 'permission denied');
await hataBekle('anon tabloyu okuyamaz', () => tek(`select * from public.ab_deney`), 'permission denied');
await db.exec(`reset role;`);

console.log('\n== Denetim ==');
const log = await sorgu(`select aksiyon from public.test_admin_log where aksiyon like 'ab_deney%' order by aksiyon`);
ok('kayıt, başlatma ve durdurma denetim kaydı bırakır', ['ab_deney_baslat','ab_deney_durdur','ab_deney_kaydet'].every((a) => log.some((l) => l.aksiyon === a)), JSON.stringify(log));

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
