// Growth manuel reklam harcaması: gerçek migration PGlite (WASM Postgres) üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: stubs (growth_journey ile ortak: require_admin, log_admin_action, roller) → 20261113 (harcama).
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../growth_journey/stubs.sql');
const YENI = '20261113000000_growth_harcama.sql';

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
const kimsin = (rol) => db.exec(`reset role; set role ${rol};`);
const postgres = () => db.exec('reset role;');
const adminOl = async (evet = true) => {
  await db.exec(`set test.admin = '${evet ? 'evet' : 'hayir'}';`);
};
const ADMIN = '00000000-0000-4000-8000-000000000001';

console.log('\n== Kurulum: stub + harcama migration ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
await kur('harcama', () => db.exec(fs.readFileSync(path.join(MIG, YENI), 'utf8')));
ok('migration zinciri hatasız', true);
await db.exec(`set request.jwt.claim.sub = '${ADMIN}';`);
await adminOl(true);

console.log('\n== Yetki ==');
await hataBekle('admin olmayan ekleyemez', async () => {
  await adminOl(false);
  await sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 100)`);
  await adminOl(true);
}, 'yetki');
await adminOl(true);

await kimsin('anon');
await hataBekle('anon tabloyu okuyamaz', () => sorgu(`select * from public.growth_harcama`), 'permission denied');
await kimsin('authenticated');
await hataBekle('authenticated tabloya doğrudan yazamaz', () =>
  sorgu(`insert into public.growth_harcama (tarih, kanal, tutar) values (current_date, 'meta', 10)`), 'permission denied');
await postgres();

console.log('\n== Ekleme ve doğrulama ==');
let idMeta;
await db.exec(`set request.jwt.claim.sub = '${ADMIN}';`);
{
  const r = await sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 1500.50, 'TRY', 'Mart kampanyası') as id`);
  idMeta = r[0].id;
  ok('geçerli kayıt eklenir ve id döner', typeof idMeta === 'string' && idMeta.length === 36);
}
await hataBekle('bilinmeyen kanal reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date, 'facebook', 100)`), 'check');
await hataBekle('sıfır tutar reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 0)`), 'check');
await hataBekle('negatif tutar reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date, 'meta', -5)`), 'check');
await hataBekle('bilinmeyen para birimi reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 10, 'GBP')`), 'check');
await hataBekle('gelecek tarih reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date + 1, 'meta', 10)`), 'Tarih geçersiz');
await hataBekle('3 yıldan eski tarih reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date - 1100, 'meta', 10)`), 'Tarih geçersiz');
await hataBekle('notta e-posta reddedilir (PII)', () =>
  sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 10, 'TRY', 'ali@ornek.com ile')`), 'kişisel veri');
await hataBekle('200 karakteri aşan not reddedilir', () =>
  sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 10, 'TRY', repeat('a', 201))`), 'check');
{
  const r = await sorgu(`select public.admin_harcama_ekle(current_date, 'meta', 10, null, '   ') as id`);
  const satir = await sorgu(`select para_birimi, not_metni from public.growth_harcama where id = $1`, [r[0].id]);
  ok('para birimi boşsa TRY, boş not NULL kaydedilir',
    satir[0].para_birimi === 'TRY' && satir[0].not_metni === null, JSON.stringify(satir));
}

console.log('\n== Listeleme ve toplam ==');
await db.exec(`
  insert into public.growth_harcama (tarih, kanal, tutar, para_birimi) values
    (current_date - 2000, 'google_ads', 999, 'TRY'),
    (current_date - 10, 'google_ads', 200, 'USD'),
    (current_date - 5, 'google_ads', 300, 'TRY');
`);
{
  const r = (await sorgu(`select public.admin_harcama_listele(90) as v`))[0].v;
  ok('90 günlük pencerede 2000 gün önceki kayıt yok',
    !r.satirlar.some((s) => s.tutar === '999.00' || s.tutar === 999), JSON.stringify(r.satirlar.map((s) => s.tutar)));
  const g = r.kanal_toplamlari.find((t) => t.kanal === 'google_ads' && t.para_birimi === 'TRY');
  const u = r.kanal_toplamlari.find((t) => t.kanal === 'google_ads' && t.para_birimi === 'USD');
  ok('TRY toplamı yalnız TRY kayıtlarını toplar (300)', g && Number(g.toplam) === 300, JSON.stringify(g));
  ok('USD ayrı toplanır, TRY ile karışmaz (200)', u && Number(u.toplam) === 200, JSON.stringify(u));
  ok('meta TRY toplamı ekleme kaydıyla eşleşir (1500.50 + 10)',
    r.kanal_toplamlari.some((t) => t.kanal === 'meta' && t.para_birimi === 'TRY' && Number(t.toplam) === 1510.5));
  ok('satırlar tarih azalan sıralı', r.satirlar.every((s, i, a) => i === 0 || a[i - 1].tarih >= s.tarih));
}
{
  const r = (await sorgu(`select public.admin_harcama_listele(100000) as v`))[0].v;
  ok('pencere üst sınırda 1095 gün ile kırpılır', r.gun === 1095, String(r.gun));
  const r0 = (await sorgu(`select public.admin_harcama_listele(0) as v`))[0].v;
  ok('pencere alt sınırda 1 gün ile kırpılır', r0.gun === 1, String(r0.gun));
}
{
  // Pencere dışındaki satırlar sayıya girmemeli: liste, SQL'in kendi saydığı pencere kadar olmalı.
  const r = (await sorgu(`select public.admin_harcama_listele(90) as v`))[0].v;
  const [{ n }] = await sorgu(`select count(*)::int as n from public.growth_harcama where tarih >= current_date - 90`);
  ok('liste yalnız pencere içindeki kayıtları döner (sayı eşleşir)', r.satirlar.length === n,
    `liste ${r.satirlar.length}, sayım ${n}`);
}

console.log('\n== Silme ve denetim ==');
await sorgu(`select public.admin_harcama_sil($1)`, [idMeta]);
{
  const kalan = await sorgu(`select count(*)::int as n from public.growth_harcama where id = $1`, [idMeta]);
  ok('kayıt silinir', kalan[0].n === 0);
}
await hataBekle('olmayan kayıt silinemez', () =>
  sorgu(`select public.admin_harcama_sil('00000000-0000-4000-8000-0000000000ff')`), 'bulunamadı');
{
  const log = await sorgu(`select aksiyon from public.test_admin_log where aksiyon like 'growth_harcama%' order by 1`);
  const ekle = log.filter((l) => l.aksiyon === 'growth_harcama_ekle').length;
  const sil = log.filter((l) => l.aksiyon === 'growth_harcama_sil').length;
  ok('her ekleme denetim kaydı bırakır', ekle >= 1, JSON.stringify(log));
  ok('silme denetim kaydı bırakır', sil === 1, JSON.stringify(log));
}

{
  await db.exec(`delete from public.growth_harcama;`);
  const bos = (await sorgu(`select public.admin_harcama_listele(90) as v`))[0].v;
  ok('kayıt yokken liste boş ve toplamlar boş (uydurma sayı yok)',
    bos.satirlar.length === 0 && bos.kanal_toplamlari.length === 0);
}

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
