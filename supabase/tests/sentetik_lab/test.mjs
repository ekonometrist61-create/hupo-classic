// Customer-Lab L2 sentetik tabloları: gerçek migration PGlite üzerinde. Docker yok; uzak DB'ye dokunmaz.
// Zincir: yaşam stub (profiles, require_admin) → 20261120.
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

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(fs.readFileSync(path.join(MIG, '20261120000000_sentetik_lab.sql'), 'utf8'));
await db.exec(`insert into auth.users (id, email) values ('${ADMIN}', 'a@t'), ('${VELI}', 'v@t');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin'), ('${VELI}', 'veli');`);
ok('migration yüklendi', true);

const sonuclar = JSON.stringify([
  { senaryo: 'fiyat_A', fiyat_kurus: 9900, beklenen_alt: 0.05, beklenen_ust: 0.09 },
  { senaryo: 'fiyat_B', fiyat_kurus: 14900, beklenen_alt: 0.03, beklenen_ust: 0.06 },
]);
const varsayim = JSON.stringify({ fiyat_esnekligi: -0.5, not: 'varsayım' });
const persona = JSON.stringify({ id: 'ilk_gun_geri_donen', d1_oran_yuzde: 70 });

console.log('\n== Kayıt ve listeleme (yönetici) ==');
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
const kosu = (await tek(`select public.admin_sentetik_kaydet('v1', 42, $1::jsonb, $2::jsonb, $3::jsonb, 'deneme') as id`,
  [varsayim, persona, sonuclar])).id;
ok('koşu kaydedilir ve id döner', typeof kosu === 'string');
const liste = (await tek(`select public.admin_sentetik_listele(5) as v`)).v;
ok('listede koşu ve iki sonuç var', liste.length === 1 && liste[0].sonuclar.length === 2, JSON.stringify(liste).slice(0, 200));
ok('her sonuç etiket=hipotez', liste[0].sonuclar.every((s) => s.etiket === 'hipotez'));
ok('tohum ve varsayımlar saklanır', liste[0].tohum === 42 && liste[0].varsayimlar.fiyat_esnekligi === -0.5);

console.log('\n== Veri kuralları (check) ==');
await hataBekle('etiket hipotez dışı reddedilir', () => tek(`select public.admin_sentetik_kaydet('v1', 1, '{}'::jsonb, '{}'::jsonb,
  '[{"senaryo":"x","fiyat_kurus":100,"beklenen_alt":0.1,"beklenen_ust":0.2,"etiket":"gercek"}]'::jsonb)`), 'check');
await hataBekle('alt > üst reddedilir', () => tek(`select public.admin_sentetik_kaydet('v1', 1, '{}'::jsonb, '{}'::jsonb,
  '[{"senaryo":"x","fiyat_kurus":100,"beklenen_alt":0.3,"beklenen_ust":0.2}]'::jsonb)`), 'check');
await hataBekle('boş sonuç listesi reddedilir', () => tek(`select public.admin_sentetik_kaydet('v1', 1, '{}'::jsonb, '{}'::jsonb, '[]'::jsonb)`), 'boş olamaz');
await hataBekle('200 üstü sonuç reddedilir', () => tek(`select public.admin_sentetik_kaydet('v1', 1, '{}'::jsonb, '{}'::jsonb,
  (select jsonb_agg(jsonb_build_object('senaryo','s','fiyat_kurus',100,'beklenen_alt',0.1,'beklenen_ust',0.2)) from generate_series(1,201)))`), 'en fazla 200');

console.log('\n== Ayrım: gerçek tablolara bağlantı yok ==');
const fk = (await db.query(`select tc.table_name, ccu.table_name as referans from information_schema.table_constraints tc
  join information_schema.constraint_column_usage ccu on ccu.constraint_name = tc.constraint_name
  where tc.constraint_type = 'FOREIGN KEY' and tc.table_name like 'sentetik_%'`)).rows;
const dis = fk.filter((r) => !r.referans.startsWith('sentetik_'));
ok('sentetik tabloların gerçek tablolara FK bağı yok', dis.length === 0, JSON.stringify(fk));

console.log('\n== Yetki ==');
await db.exec(`set request.jwt.claims = '{"sub":"${VELI}"}';`);
await hataBekle('veli kayıt yapamaz', () => tek(`select public.admin_sentetik_kaydet('v1', 1, '{}'::jsonb, '{}'::jsonb, '[{"senaryo":"x","fiyat_kurus":1,"beklenen_alt":0,"beklenen_ust":0}]'::jsonb)`), 'Yetkisiz');
await hataBekle('veli listeyi göremez', () => tek(`select public.admin_sentetik_listele(5)`), 'Yetkisiz');
await db.exec(`reset role; set role anon;`);
await hataBekle('anon tabloyu okuyamaz', () => tek(`select * from public.sentetik_sonuc`), 'permission denied');
await hataBekle('anon fonksiyonu çağıramaz', () => tek(`select public.admin_sentetik_listele(5)`), 'permission denied');
await db.exec('reset role;');

console.log('\n== Silme kademesi ==');
await db.exec(`delete from public.sentetik_kosu where id = '${kosu}'`);
const kalan = (await tek(`select count(*)::int as n from public.sentetik_sonuc where kosu_id = '${kosu}'`)).n;
ok('koşu silinince sonuçları da gider', kalan === 0);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
