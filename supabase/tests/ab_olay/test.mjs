// A/B olay kaydı I1: gerçek migration PGlite üzerinde. Docker yok; uzak DB'ye dokunmaz.
// Zincir: yaşam stub (profiles, require_admin, auth.uid) + log stub → 20261121 (ab_deney) → 20261123 (ab_olay).
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
const kullanici = (n) => `00000000-0000-4000-7000-${String(n).padStart(12, '0')}`;
const oturum = (id) => db.exec(`set request.jwt.claims = '{"sub":"${id}"}';`);
const gun = (n) => `(((now() at time zone 'Europe/Istanbul')::date) + ${n})`;

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`create table if not exists public.test_admin_log (aksiyon text, detay jsonb);
  create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void
  language sql as $$ insert into public.test_admin_log values (p_aksiyon, p_detay) $$;`);
await db.exec(fs.readFileSync(path.join(MIG, '20261121000000_ab_deney.sql'), 'utf8'));
await db.exec(fs.readFileSync(path.join(MIG, '20261123000000_ab_olay.sql'), 'utf8'));
await db.exec(`insert into auth.users (id, email) values ('${ADMIN}', 'a@t'), ('${VELI}', 'v@t');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin'), ('${VELI}', 'veli');`);
for (let i = 1; i <= 120; i++) {
  await db.exec(`insert into auth.users (id, email) values ('${kullanici(i)}', 'k${i}@t') on conflict do nothing;`);
}
ok('migration zinciri yüklendi', true);

const deneyKur = async (ad, bitis = gun(30)) => {
  await oturum(ADMIN);
  const id = (await tek(`select public.admin_ab_deney_kaydet($1, 'Ücretli paket daha çok ödeme getirir', 'odeme_orani',
    array['iade_orani','sikayet_orani'], 0.10, 0.02, 0.05, 0.8, 30, ${gun(0)}, ${bitis}, 'Ekip') as id`, [ad])).id;
  return id;
};

// ---- Ana deney: 120 kullanıcı maruz kalır ----
const D = await deneyKur('Ana deney');
await oturum(ADMIN);
await hataBekle('taslak deneyde maruziyet kaydı yapılamaz', async () => {
  await oturum(kullanici(1));
  await tek(`select public.ab_maruziyet_kaydet($1)`, [D]);
}, 'aktif değil');
await oturum(ADMIN);
await db.exec(`select public.admin_ab_deney_baslat('${D}', 'Ürün onayı')`);

const kolSayac = { kontrol: 0, deney: 0 };
const kolOf = {};
for (let i = 1; i <= 120; i++) {
  await oturum(kullanici(i));
  const k = (await tek(`select public.ab_maruziyet_kaydet($1) as k`, [D])).k;
  kolSayac[k]++;
  kolOf[i] = k;
  // aynı kullanıcı ikinci kez: sayı artmaz
  await tek(`select public.ab_maruziyet_kaydet($1) as k`, [D]);
}
ok('maruziyet kolu ab_kol ile aynı (her iki kol da dolu)', kolSayac.kontrol > 0 && kolSayac.deney > 0, JSON.stringify(kolSayac));

await oturum(ADMIN);
const s1 = (await tek(`select public.admin_ab_sayilar($1) as v`, [D])).v;
ok('maruziyet sayısı kol başına gerçek sayıyla eşleşir (tekil; ikinci çağrı sayılmaz)',
  s1.kollar.kontrol.maruziyet === kolSayac.kontrol && s1.kollar.deney.maruziyet === kolSayac.deney, JSON.stringify(s1));

console.log('\n== Dönüşüm kuralları ==');
await oturum(kullanici(1));
await hataBekle('maruziyetsiz dönüşüm reddedilir', async () => {
  await oturum(kullanici(200));
  await tek(`select public.ab_donusum_kaydet($1, 'odeme_orani')`, [D]);
}, 'Önce maruziyet');
await oturum(kullanici(1));
await hataBekle('kullanıcı olmayan metrik reddedilir', () => tek(`select public.ab_donusum_kaydet($1, 'baska_metrik')`, [D]), 'tanımlı değil');
await hataBekle('maruziyet metriği dönüşüm olarak yazılamaz', () => tek(`select public.ab_donusum_kaydet($1, 'maruziyet')`, [D]), 'Geçersiz metrik');

let donusumKontrol = 0;
let donusumDeney = 0;
for (let i = 1; i <= 60; i++) {
  await oturum(kullanici(i));
  const yeni = (await tek(`select public.ab_donusum_kaydet($1, 'odeme_orani') as y`, [D])).y;
  const tekrar = (await tek(`select public.ab_donusum_kaydet($1, 'odeme_orani') as y`, [D])).y;
  ok(`kullanıcı ${i}: ilk dönüşüm sayılır, ikincisi sayılmaz`, yeni === true && tekrar === false, `${yeni}/${tekrar}`);
  if (i <= 60) { if (kolOf[i] === 'kontrol') donusumKontrol++; else donusumDeney++; }
  if (i >= 4) break; // ilk 4 kullanıcı ile sınırlı (aşağıda toplam kontrol)
}
await oturum(ADMIN);
const s2 = (await tek(`select public.admin_ab_sayilar($1) as v`, [D])).v;
ok('dönüşüm toplamı kol başına (sadece ilk 4) toplu sayıda', (s2.kollar.kontrol.metrikler.odeme_orani ?? 0) + (s2.kollar.deney.metrikler.odeme_orani ?? 0) === 4, JSON.stringify(s2.kollar));

console.log('\n== Gizlilik ve yapı ==');
const kolonlar = (await sorgu(`select table_name, column_name from information_schema.columns
  where table_schema='public' and table_name in ('ab_tekillik','ab_olay_gunluk')`)).map((r) => r.column_name);
ok('tekillik ve günlük tablolarında kullanıcı kimliği kolonu yok',
  !kolonlar.some((c) => /user|kullanici|veli|ogrenci|profile|auth/i.test(c)), JSON.stringify(kolonlar));
const anahtarlar = await sorgu(`select length(anahtar) as l from public.ab_tekillik`);
ok('tekillik anahtarı SHA-256 hex (64 karakter)', anahtarlar.length > 0 && anahtarlar.every((r) => r.l === 64));
const hamKimlik = await sorgu(`select 1 from public.ab_tekillik where anahtar like '%0000-4000-7000%'`);
ok('tekillik anahtarında ham kimlik izi yok', hamKimlik.length === 0);

console.log('\n== n < 30 gizleme ==');
const KUCUK = await deneyKur('Küçük deney');
await oturum(ADMIN);
await db.exec(`select public.admin_ab_deney_baslat('${KUCUK}', 'Test onayı')`);
for (let i = 1; i <= 5; i++) {
  await oturum(kullanici(i));
  await tek(`select public.ab_maruziyet_kaydet($1)`, [KUCUK]);
}
await oturum(ADMIN);
const sk = (await tek(`select public.admin_ab_sayilar($1) as v`, [KUCUK])).v;
ok('kol n<30 iken maruziyet ve metrikler gizlenir (null)',
  sk.kollar.kontrol.maruziyet === null && sk.kollar.deney.maruziyet === null &&
  sk.kollar.kontrol.metrikler === null && sk.kollar.deney.metrikler === null, JSON.stringify(sk));

console.log('\n== Yetki ve kapsam ==');
await oturum(VELI);
await hataBekle('veli yönetici sayılarını göremez', () => tek(`select public.admin_ab_sayilar($1)`, [D]), 'Yetkisiz');
await oturum(kullanici(1));
await hataBekle('deney durdurulunca maruziyet kaydı yapılamaz', async () => {
  await oturum(ADMIN);
  await tek(`select public.admin_ab_deney_durdur($1, 'Test durdurma')`, [KUCUK]);
  await oturum(kullanici(1));
  await tek(`select public.ab_maruziyet_kaydet($1)`, [KUCUK]);
}, 'aktif değil');
await db.exec(`reset role; set role anon;`);
await hataBekle('anon maruziyet kaydedemez', () => tek(`select public.ab_maruziyet_kaydet($1)`, [D]), 'permission denied');
await hataBekle('anon tekillik tablosunu okuyamaz', () => tek(`select * from public.ab_tekillik`), 'permission denied');
await db.exec('reset role;');

console.log('\n== Temizlik ==');
await db.exec(`insert into public.ab_tekillik (deney_id, metrik, anahtar, olusma)
  values ('${D}', 'eski', '${'a'.repeat(64)}', now() - interval '8 days');`);
const silinen = (await tek(`select public.ab_tekillik_temizle() as n`)).n;
ok('7 günden eski tekillik kayıtları silinir', silinen >= 1, String(silinen));
const kalanEski = (await tek(`select count(*)::int as n from public.ab_tekillik where olusma < now() - interval '7 days'`)).n;
ok('temizlikten sonra eski kayıt kalmaz', kalanEski === 0);

await db.exec(`update public.ab_deney set bitis = ${gun(-401)}, baslangic = ${gun(-430)} where id = '${KUCUK}';`);
const gsil = (await tek(`select public.ab_gunluk_temizle() as n`)).n;
const kucukKalan = (await tek(`select count(*)::int as n from public.ab_olay_gunluk where deney_id = '${KUCUK}'`)).n;
ok('bitişten 400 gün sonra günlük sayılar silinir', gsil >= 1 && kucukKalan === 0, `silinen=${gsil} kalan=${kucukKalan}`);
const anaKalan = (await tek(`select count(*)::int as n from public.ab_olay_gunluk where deney_id = '${D}'`)).n;
ok('aktif deneyin günlük sayıları temizlikten etkilenmez', anaKalan > 0);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
