// A/B karar kaydı: gerçek migration zinciri PGlite üzerinde. Docker yok; uzak DB'ye dokunmaz.
// Zincir: yaşam stub (profiles, require_admin, auth.uid) + log stub → 20261121 → 20261122.
// Test, "bitiş geçmiş" durumunu bitiş tarihini geriye çekerek kurar (yalnız bu testte).
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
const ADMIN = '00000000-0000-4000-8000-000000000001';
const VELI = '00000000-0000-4000-8000-000000000002';
const gun = (n) => `(((now() at time zone 'Europe/Istanbul')::date) + ${n})`;

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`create table if not exists public.test_admin_log (aksiyon text, detay jsonb);
  create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void
  language sql as $$ insert into public.test_admin_log values (p_aksiyon, p_detay) $$;`);
await db.exec(fs.readFileSync(path.join(MIG, '20261121000000_ab_deney.sql'), 'utf8'));
await db.exec(fs.readFileSync(path.join(MIG, '20261122000000_ab_karar.sql'), 'utf8'));
await db.exec(`insert into auth.users (id, email) values ('${ADMIN}', 'a@t'), ('${VELI}', 'v@t');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin'), ('${VELI}', 'veli');`);
ok('migration zinciri yüklendi', true);

await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
const yeniDeney = async (ad) => {
  const id = (await tek(`select public.admin_ab_deney_kaydet($1, 'Ucuz paket daha çok ödeme getirir', 'odeme_orani',
    array['iade_orani','sikayet_orani'], 0.10, 0.02, 0.05, 0.8, 1200, ${gun(0)}, ${gun(30)}, 'Ekip') as id`, [ad])).id;
  await tek(`select public.admin_ab_deney_baslat($1, 'Ürün onayı')`, [id]);
  return id;
};
const SONUC = {
  kontrol_orani: 0.10, deney_orani: 0.12, fark: 0.02, ci: [0.001, 0.039], p: 0.03, anlamli: true,
};
const GUARD = [{ ad: 'iade_orani', p_tek_kuyruk: 0.6, kotu: false }];

console.log('\n== Bitmemiş deneyde karar yok ==');
const d1 = await yeniDeney('Deney bitmemiş');
await hataBekle('bitiş öncesi karar reddedilir (ara bakış)', () => tek(
  `select public.admin_ab_karar_kaydet($1, 'karar_hazir', $2::jsonb, $3::jsonb, 0.5, 'Sonuç hazır', 'kazan_deney')`,
  [d1, JSON.stringify(SONUC), JSON.stringify(GUARD)]), 'ara bakış');
await hataBekle('guardrail kararı durdurulmadan verilemez', () => tek(
  `select public.admin_ab_karar_kaydet($1, 'guardrail_ihlali', null, $2::jsonb, null, 'İade arttı', null)`,
  [d1, JSON.stringify(GUARD)]), 'önce deney durdurulmalı');

console.log('\n== Bitiş sonrası karar ==');
await db.exec(`update public.ab_deney set bitis = ${gun(-1)}, baslangic = ${gun(-30)} where id = '${d1}';`);
await hataBekle('karar_hazir birincil olmadan reddedilir', () => tek(
  `select public.admin_ab_karar_kaydet($1, 'karar_hazir', null, '[]'::jsonb, 0.5, 'Eksik sonuç', 'kazan_deney')`, [d1]), 'ab_karar_birincil_zorunlu');
const kid = (await tek(
  `select public.admin_ab_karar_kaydet($1, 'karar_hazir', $2::jsonb, $3::jsonb, 0.5, 'Ön kayıtlı analiz uygulandı', 'kazan_deney') as id`,
  [d1, JSON.stringify(SONUC), JSON.stringify(GUARD)])).id;
ok('bitiş sonrası karar kaydedilir', typeof kid === 'string');
const dd = await tek(`select durum from public.ab_deney where id = $1`, [d1]);
ok('karar sonrası deney durumu bitti', dd.durum === 'bitti', JSON.stringify(dd));
await hataBekle('aynı deney için ikinci karar reddedilir', () => tek(
  `select public.admin_ab_karar_kaydet($1, 'srm_gecersiz', null, '[]'::jsonb, 0.0001, 'Tekrar', null)`, [d1]), 'zaten kayıtlı');
const g = (await tek(`select public.admin_ab_karar_getir($1) as v`, [d1])).v;
ok('getir karar ve birincil sonucu döndürür', g.karar === 'kazan_deney' && g.birincil.anlamli === true, JSON.stringify(g));

console.log('\n== Guardrail ihlali (durdurulmuş deney) ==');
const d2 = await yeniDeney('Guardrail deneyi');
await tek(`select public.admin_ab_deney_durdur($1, 'İade eşiği aşıldı')`, [d2]);
const gid = (await tek(
  `select public.admin_ab_karar_kaydet($1, 'guardrail_ihlali', null, $2::jsonb, null, 'İade oranı kötüleşti', null) as id`,
  [d2, JSON.stringify([{ ad: 'iade_orani', p_tek_kuyruk: 0.01, kotu: true }])])).id;
ok('durdurulmuş deneyde guardrail kararı yazılır (bitiş beklenmez)', typeof gid === 'string');
const d2s = await tek(`select durum from public.ab_deney where id = $1`, [d2]);
ok('guardrail kararı durumu değiştirmez (zaten durdurulmuş)', d2s.durum === 'durduruldu');

console.log('\n== Yetki ==');
await db.exec(`set request.jwt.claims = '{"sub":"${VELI}"}';`);
await hataBekle('veli karar kaydedemez', () => tek(
  `select public.admin_ab_karar_kaydet($1, 'srm_gecersiz', null, '[]'::jsonb, 0.0001, 'Veli', null)`, [d2]), 'Yetkisiz');
await db.exec(`reset role; set role anon;`);
await hataBekle('anon kararı okuyamaz (tablo)', () => tek(`select * from public.ab_karar`), 'permission denied');
await db.exec(`reset role;`);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
