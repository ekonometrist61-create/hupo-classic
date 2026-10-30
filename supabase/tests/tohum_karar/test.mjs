// Tohum karar kayıtları: 20261130 (P1) + 20261131 (P2) + 20261132 (P3 önizleme) + 20261134 + 20261136, PGlite üzerinde.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney'), path.resolve(HERE, '../kartsiz_deneme')],
})).href);

const MIG = (ad) => path.resolve(HERE, '../../migrations', ad);
const MIG_P1 = MIG('20261130000000_paket_modul_erisim.sql');
const MIG_P2 = MIG('20261131000000_modul_yayin_kurali.sql');
const MIG_P3 = MIG('20261132000000_paket_admin_gorunum.sql');
const MIG_F = MIG('20261134000000_ucretsiz_deneme_fircasi.sql');
const MIG_T = MIG('20261136000000_tohum_karar_kayitlari.sql');
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');

const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const tek = async (sql, p = []) => (await db.query(sql, p)).rows[0];
const satirlar = async (sql, p = []) => (await db.query(sql, p)).rows;
const yonetici = () => db.exec(`set request.jwt.claims = '{"sub":"${YONETICI}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);

const YONETICI = '00000000-0000-4000-8000-000000000005';
const VELI = '00000000-0000-4000-8000-000000000002';
const MODULLER = ['okuma', 'carpma', 'soru_cevap', 'deneme', 'kelime_evreni'];

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.deneme_donemleri (
    id uuid primary key default gen_random_uuid(),
    veli_id uuid not null, baslangic timestamptz not null, bitis timestamptz not null);
  create or replace function public.is_premium(p_uid uuid) returns boolean
  language sql stable as $$ select false $$;
  create or replace function public._deneme_sahibi(p_uid uuid) returns uuid
  language sql stable as $$
    select coalesce((select parent_id from public.profiles where id = p_uid and role = 'ogrenci'), p_uid)
  $$;
  create or replace function public._deneme_aktif(p_uid uuid) returns boolean
  language sql stable as $$
    select exists (select 1 from public.deneme_donemleri d
                    where d.veli_id = public._deneme_sahibi(p_uid) and d.bitis > now())
  $$;
  create or replace function public._deneme_sinir(p_ogrenci uuid, p_ozellik text) returns jsonb
  language sql stable as $$ select null::jsonb $$;
  create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
  returns void language plpgsql as $$ begin end $$;
`);
for (const [id, mail] of [[VELI, 'v1'], [YONETICI, 'y']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`
  insert into public.profiles (id, role) values ('${VELI}', 'veli'), ('${YONETICI}', 'admin');
`);
await db.exec(fs.readFileSync(MIG_P1, 'utf8'));
await db.exec(fs.readFileSync(MIG_P2, 'utf8'));
await db.exec(fs.readFileSync(MIG_P3, 'utf8'));
await db.exec(fs.readFileSync(MIG_F, 'utf8'));

const matrisOnce = await satirlar(`select paket_kod, modul_kod, erisim, gunluk_kota, kisit
  from public.paket_modul order by paket_kod, modul_kod`);
const surumOnce = await satirlar(`select paket_kod, surum, matris, cocuk_siniri, rapor_kapsami
  from public.paket_surum order by paket_kod, surum`);
const paketSurumOnce = await satirlar(`select kod, surum, durum from public.paketler order by kod`);

console.log('\n== Öncesi: karar tablosu boş, önizleme "eksik" der ==');
await yonetici();
let on = await tek(`select public.admin_modul_etki_onizleme('kelime_evreni') as r`);
ok('migration öncesi yayinlanabilir=false', on.r.yayinlanabilir === false, JSON.stringify(on.r));
await servis();
ok('migration öncesi karar tablosu boş',
  (await tek('select count(*)::int as n from public.modul_paket_karar')).n === 0);

await db.exec(fs.readFileSync(MIG_T, 'utf8'));

const karar = async (paket) =>
  Object.fromEntries((await satirlar(
    `select modul_kod, karar, erisim, gunluk_kota from public.modul_paket_karar where paket_kod = $1`,
    [paket])).map((r) => [r.modul_kod, r]));

console.log('\n== 1. Satır sayısı ==');
const n1 = (await tek('select count(*)::int as n from public.modul_paket_karar')).n;
ok('5 modül × 7 paket = 35 satır', n1 === 35, String(n1));

console.log('\n== 2. Tam paketi ==');
let k = await karar('tam');
ok('tam: tüm modüller dahil/tam',
  MODULLER.every((m) => k[m]?.karar === 'dahil' && k[m]?.erisim === 'tam'), JSON.stringify(k));

console.log('\n== 3. Ücretsiz paketi ==');
k = await karar('ucretsiz');
ok('ucretsiz: tüm modüller sinirli',
  MODULLER.every((m) => k[m]?.karar === 'sinirli' && k[m]?.erisim === 'sinirli'), JSON.stringify(k));
const kotalar = { okuma: 2, carpma: 40, soru_cevap: 20, deneme: 1, kelime_evreni: 30 };
ok('ucretsiz kotalar 2/40/20/1/30',
  MODULLER.every((m) => k[m]?.gunluk_kota === kotalar[m]), JSON.stringify(k));

console.log('\n== 4. HupoRead paketi ==');
k = await karar('hupo_read');
ok('hupo_read: okuma dahil', k.okuma?.karar === 'dahil' && k.okuma?.erisim === 'tam');
ok('hupo_read: diğer 4 modül haric (erisim/kota null)',
  MODULLER.filter((m) => m !== 'okuma').every((m) =>
    k[m]?.karar === 'haric' && k[m]?.erisim === null && k[m]?.gunluk_kota === null), JSON.stringify(k));

console.log('\n== 5. Soru paketi ==');
k = await karar('soru');
ok('soru: soru_cevap ve deneme dahil',
  k.soru_cevap?.karar === 'dahil' && k.deneme?.karar === 'dahil', JSON.stringify(k));
ok('soru: okuma, carpma, kelime_evreni haric',
  ['okuma', 'carpma', 'kelime_evreni'].every((m) => k[m]?.karar === 'haric'), JSON.stringify(k));

console.log('\n== Ek: ortak alanlar ==');
const ortak = await tek(`select
  count(*) filter (where mevcut_aboneleri_kapsar) as kapsar,
  count(*) filter (where karar_veren is not null) as veren,
  count(*) filter (where gerekce is distinct from 'İlk kurulum: mevcut matristen türetildi') as gerekce_farkli
  from public.modul_paket_karar`);
ok('kapsam=false, karar_veren null, gerekçe sabit',
  Number(ortak.kapsar) === 0 && Number(ortak.veren) === 0 && Number(ortak.gerekce_farkli) === 0, JSON.stringify(ortak));
const aile = await karar('aile3');
ok('aile3: tüm modüller dahil', MODULLER.every((m) => aile[m]?.karar === 'dahil'), JSON.stringify(aile));

console.log('\n== 6. İdempotent ==');
await db.exec(fs.readFileSync(MIG_T, 'utf8'));
const n2 = (await tek('select count(*)::int as n from public.modul_paket_karar')).n;
ok('ikinci çalıştırmada satır sayısı değişmedi', n2 === 35, String(n2));

// Yönetici kararı ezilmemeli
await yonetici();
await db.exec(`select public.admin_modul_karar_kaydet('okuma', 'soru', 'sinirli', 5, false, 'elle')`);
await servis();
await db.exec(fs.readFileSync(MIG_T, 'utf8'));
const elle = await tek(`select karar, gunluk_kota, gerekce from public.modul_paket_karar
  where modul_kod = 'okuma' and paket_kod = 'soru'`);
ok('yönetici kararı yeniden çalıştırmada ezilmez',
  elle.karar === 'sinirli' && elle.gunluk_kota === 5 && elle.gerekce === 'elle', JSON.stringify(elle));
// Test sonrası (7-8) temiz karşılaştırma için elle yapılan değişikliği geri al
// (karar_kaydet matrise satır yazdı; sil ve tohum kararını yeniden üret)
await db.exec(`delete from public.paket_modul where paket_kod = 'soru' and modul_kod = 'okuma';
  delete from public.modul_paket_karar where modul_kod = 'okuma' and paket_kod = 'soru';`);
await db.exec(fs.readFileSync(MIG_T, 'utf8'));

console.log('\n== 7. Etki önizleme ==');
await yonetici();
const onizleme = await tek(`select public.admin_modul_etki_onizleme('kelime_evreni') as r`);
await servis();
ok('kelime_evreni yayinlanabilir=true', onizleme.r.yayinlanabilir === true, JSON.stringify(onizleme.r));
ok('eksik karar listesi boş', (onizleme.r.eksik_kararlar ?? []).length === 0, JSON.stringify(onizleme.r.eksik_kararlar));
ok('önizleme 7 paket listeler', (onizleme.r.paketler ?? []).length === 7);

console.log('\n== 8. Matris ve sürümler değişmedi ==');
// (6'daki elle karar testi matrise yazmış ve geri alınmıştı; karşılaştırma bu yüzden en sondaki durum)
const matrisSon = await satirlar(`select paket_kod, modul_kod, erisim, gunluk_kota, kisit
  from public.paket_modul order by paket_kod, modul_kod`);
ok('paket_modul aynı', JSON.stringify(matrisOnce) === JSON.stringify(matrisSon));
const surumSon = await satirlar(`select paket_kod, surum, matris, cocuk_siniri, rapor_kapsami
  from public.paket_surum order by paket_kod, surum`);
ok('paket_surum aynı', JSON.stringify(surumOnce) === JSON.stringify(surumSon));
const paketSurumSon = await satirlar(`select kod, surum, durum from public.paketler order by kod`);
ok('paketler.surum/durum aynı', JSON.stringify(paketSurumOnce) === JSON.stringify(paketSurumSon));

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
