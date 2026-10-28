// Giriş olayları (W7) testi: gerçek migration zinciri PGlite (gerçek Postgres) üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
//
// Kapsam:
// - giriş_olayi_kaydet: dakikada en fazla 1 kayıt, fazlası sessizce yutulur; geçersiz kanal reddedilir
// - anon ve authenticated giris_olaylari tablosuna doğrudan erişemez
// - son_giris_zamani: kendi kaydı serbest, başkasınınki yalnız admin
// - admin_giris_ozet: yalnız admin okur; çıktıda kullanıcı kimliği yoktur
// - giris_olaylari_temizle: 180 günden eski satırları siler
// - veli_cocuk_bagla: tüm sistemde dakikalık başarısız-deneme eşiği ('cok_fazla_deneme'), ayar okunur,
//   hesap başına 3/15 dk sınırı korunur
// - veli_eslestirme_kodu_tests.sql (mevcut test) hâlâ geçer
//
// Yükleme sırası: stubs.sql → 20261016 (guard) → guard tetikleyicisi → 20261025000100 → 20261107 (iki kez)
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const TESTLER = path.resolve(HERE, '..');
const GUARD = '20261016000000_veli_eslestirme_kodu.sql';
const CEKIRDEK = '20261025000100_veli_bagla_rate_limit.sql';
const YENI = '20261107000000_giris_olaylari.sql';

// PGlite'ta pgcrypto ve pg_cron eklentileri yok. Bu satırlar yalnızca harness'ta atlanır; dosya değişmez.
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
// Hata fırlatan çağrının kodunu ve mesajını döndürür; hata yoksa null.
const hatayiAl = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: String(e.code ?? ''), mesaj: String(e.message ?? e) }; }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const tek = async (sql, params = []) => (await sorgu(sql, params))[0];
// Gözlem ve kurulum: her zaman superuser (postgres) olarak çalışır; oturum rolünü değiştirmez.
const gozle = async (sql, params = []) => { await db.exec('reset role;'); return (await db.query(sql, params)).rows; };
const gozleTek = async (sql, params = []) => (await gozle(sql, params))[0];
const yaz = async (sql) => { await db.exec('reset role;'); return db.exec(sql); };
// Oturumu belirli bir rol ve kullanıcıya geçirir. uid yoksa auth.uid() null olur.
const kimsin = async (rol, uid = null) => {
  await db.exec('reset role;');
  await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [uid ?? '']);
  if (rol !== 'postgres') await db.exec(`set role ${rol};`);
};

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const ADMIN = id(1);
const V1 = id(21), V2 = id(22), V3 = id(23);
const S1 = id(11), S2 = id(12), S3 = id(13), S4 = id(14);
const GV = Array.from({ length: 40 }, (_, i) => id(101 + i));  // hata üretmek için veli havuzu

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
try {
  await yaz(fs.readFileSync(path.join(HERE, 'stubs.sql'), 'utf8'));
  await yaz(oku(GUARD));
  // Gerçek guard tetikleyicisi (canlıda profiles_guard_immutable adıyla bağlı)
  await yaz(`create trigger profiles_guard_immutable before update on public.profiles
                   for each row execute function public.profiles_guard_immutable();`);
  await yaz(oku(CEKIRDEK));
  ok('stub + 20261016 + guard tetikleyicisi + 20261025000100 hatasız yüklendi', true);
} catch (e) {
  console.log('HATA [kurulum]:', e.message);
  process.exit(1);
}

// Migration ikinci kez çalışmalı (idempotent): hata olmamalı, ayar satırı çoğalmamalı
try {
  await yaz(oku(YENI));
  await yaz(oku(YENI));
  ok('20261107 iki kez hatasız çalışır', true);
} catch (e) {
  ok('20261107 iki kez hatasız çalışır', false, e.message);
  process.exit(1);
}
const ayarSayisi = (await gozleTek(`select count(*)::int as n from public.app_settings where key = 'veli_kod_global_sinir'`)).n;
ok('global sınır ayarı tek satır (on conflict do nothing)', ayarSayisi === 1, `satır ${ayarSayisi}`);

// Kullanıcılar: admin, öğrenciler, veliler ve hata havuzu (auth.users tetikleyicisi profili açar)
await yaz(`
  insert into auth.users (id, email, raw_user_meta_data) values
    ('${ADMIN}', 'gl.admin@example.test', '{"role":"admin","full_name":"Yonetici"}'),
    ('${S1}', 'gl.s1@example.test', '{"role":"ogrenci","full_name":"Ogrenci Bir"}'),
    ('${S2}', 'gl.s2@example.test', '{"role":"ogrenci","full_name":"Ogrenci Iki"}'),
    ('${S3}', 'gl.s3@example.test', '{"role":"ogrenci","full_name":"Ogrenci Uc"}'),
    ('${S4}', 'gl.s4@example.test', '{"role":"ogrenci","full_name":"Ogrenci Dort"}'),
    ('${V1}', 'gl.v1@example.test', '{"role":"veli","full_name":"Veli Bir"}'),
    ('${V2}', 'gl.v2@example.test', '{"role":"veli","full_name":"Veli Iki"}'),
    ('${V3}', 'gl.v3@example.test', '{"role":"veli","full_name":"Veli Uc"}');
  insert into auth.users (id, email, raw_user_meta_data)
    select ('00000000-0000-4000-8000-' || lpad((100 + g)::text, 12, '0'))::uuid,
           'gl.g' || g || '@example.test', '{"role":"veli","full_name":"Veli Havuz"}'
      from generate_series(1, 40) g;
  insert into public.ogrenci_baglanti_kodlari (kod, ogrenci_id, son_gecerlilik) values
    ('111111', '${S1}', now() + interval '15 minutes'),
    ('222222', '${S2}', now() + interval '15 minutes'),
    ('444444', '${S4}', now() + interval '15 minutes');
`);

console.log('\n== A: giriş olayı yazıcısı ==');
await kimsin('authenticated', S1);
const a1 = await tek(`select public.giris_olayi_kaydet('web') as j`);
ok('ilk çağrı kayıt yazar (true)', a1.j === true, JSON.stringify(a1));
const s1Say = async () => (await gozleTek(`select count(*)::int as n from public.giris_olaylari where user_id = $1`, [S1])).n;
ok('kayıt sayısı 1', (await s1Say()) === 1);
const rolKaydi = await gozleTek(`select rol, kanal, sonuc from public.giris_olaylari where user_id = $1`, [S1]);
ok('satır rol=ogrenci, kanal=web, sonuc=basarili',
  rolKaydi?.rol === 'ogrenci' && rolKaydi?.kanal === 'web' && rolKaydi?.sonuc === 'basarili', JSON.stringify(rolKaydi));

await kimsin('authenticated', S1);
const a2 = await tek(`select public.giris_olayi_kaydet('web') as j`);
ok('1 dk içinde ikinci çağrı yeni satır üretmez (false)', a2.j === false, JSON.stringify(a2));
ok('ikinci çağrıdan sonra hâlâ 1 satır', (await s1Say()) === 1);
const a3 = await tek(`select public.giris_olayi_kaydet('mobil') as j`);
ok('farklı kanal da aynı dakika içinde yazmaz', a3.j === false && (await s1Say()) === 1);

await yaz(`update public.giris_olaylari set created_at = now() - interval '2 minutes' where user_id = '${S1}';`);
await kimsin('authenticated', S1);
const a4 = await tek(`select public.giris_olayi_kaydet('mobil') as j`);
ok('2 dk sonra yeni çağrı yazar (true), toplam 2', a4.j === true && (await s1Say()) === 2);

const a5 = await hatayiAl(() => sorgu(`select public.giris_olayi_kaydet('tablet')`));
ok('geçersiz kanal reddedilir (22023)', a5?.kod === '22023', JSON.stringify(a5));

await kimsin('anon');
const a6 = await hatayiAl(() => sorgu(`select public.giris_olayi_kaydet('web')`));
ok('anon giriş_olayi_kaydet çağıramaz (42501)', a6?.kod === '42501', JSON.stringify(a6));

await kimsin('authenticated', S1);
const a7 = await hatayiAl(() => sorgu(`select count(*) from public.giris_olaylari`));
ok('authenticated tabloyu doğrudan okuyamaz (42501)', a7?.kod === '42501', JSON.stringify(a7));
const a8 = await hatayiAl(() => sorgu(`insert into public.giris_olaylari (user_id, kanal) values ('${S1}', 'web')`));
ok('authenticated tabloya doğrudan yazamaz (42501)', a8?.kod === '42501', JSON.stringify(a8));
await kimsin('anon');
const a9 = await hatayiAl(() => sorgu(`select count(*) from public.giris_olaylari`));
ok('anon tabloyu okuyamaz (42501)', a9?.kod === '42501', JSON.stringify(a9));

console.log('\n== B: son giriş zamanı ==');
await kimsin('authenticated', S1);
const b1 = await tek(`select public.son_giris_zamani() as t`);
ok('kullanıcı kendi son girişini okur', b1.t !== null);
const b2 = await hatayiAl(() => sorgu(`select public.son_giris_zamani($1)`, [V1]));
ok('öğrenci başkasının son girişini okuyamaz (42501)', b2?.kod === '42501', JSON.stringify(b2));
await kimsin('anon');
const b3 = await hatayiAl(() => sorgu(`select public.son_giris_zamani()`));
ok('anon son_giris_zamani çağıramaz (42501)', b3?.kod === '42501', JSON.stringify(b3));
await kimsin('authenticated', ADMIN);
const b4 = await tek(`select public.son_giris_zamani($1) as t`, [S1]);
const dogru = await gozleTek(`select max(created_at) as t from public.giris_olaylari where user_id = $1`, [S1]);
ok('admin başkasının son girişini okur (değer eşleşir)', b4.t !== null && String(b4.t) === String(dogru.t));

console.log('\n== C: admin özeti ==');
await kimsin('authenticated', S1);
const c1 = await hatayiAl(() => sorgu(`select public.admin_giris_ozet(7)`));
ok('admin olmayan özeti okuyamaz (42501)', c1?.kod === '42501', JSON.stringify(c1));
await kimsin('authenticated', ADMIN);
const ozet = (await tek(`select public.admin_giris_ozet(7) as j`)).j;
ok('admin özeti toplam=2 ve ogrenci=2', ozet.toplam === 2 && ozet.roller?.ogrenci === 2, JSON.stringify(ozet));
ok('admin özeti farklı hesap sayısını verir (1)', ozet.farkli_hesap === 1, JSON.stringify(ozet));
ok('admin özetinde kullanıcı kimliği yok (PII)', !JSON.stringify(ozet).includes(S1), JSON.stringify(ozet));
ok('admin özetinde günlük kırılım var', Array.isArray(ozet.gunluk) && ozet.gunluk.length >= 1);
const c4 = (await tek(`select public.admin_giris_ozet(9999) as j`)).j;
ok('pencere en fazla 180 gün (9999 → 180)', c4.gun === 180, `gun=${c4.gun}`);

console.log('\n== D: saklama (180 gün) ==');
await yaz(`
  insert into public.giris_olaylari (user_id, rol, kanal, created_at) values
    ('${S2}', 'ogrenci', 'web', now() - interval '181 days'),
    ('${S2}', 'ogrenci', 'web', now());
`);
const d0 = (await gozleTek(`select count(*)::int as n from public.giris_olaylari`)).n;
await kimsin('postgres');
const d1 = (await tek(`select public.giris_olaylari_temizle() as n`)).n;
ok('181 günlük satır silinir (1 satır)', d1 === 1, `silinen=${d1}, önce=${d0}`);
const d2 = (await gozleTek(`select count(*)::int as n from public.giris_olaylari where created_at < now() - interval '180 days'`)).n;
ok('180 günden eski satır kalmaz', d2 === 0);
const d3 = (await gozleTek(`select count(*)::int as n from public.giris_olaylari where user_id = '${S2}'`)).n;
ok('taze satır korunur', d3 === 1, `S2 satır=${d3}`);
await kimsin('authenticated', S1);
const d4 = await hatayiAl(() => sorgu(`select public.giris_olaylari_temizle()`));
ok('authenticated temizliği çalıştıramaz (42501)', d4?.kod === '42501', JSON.stringify(d4));

console.log('\n== E: çocuk kodu global sınırı ==');
// Öncelikle tüm sistemdeki başarısız deneme sayacını temiz tut.
const hataSayisi = async () => (await gozleTek(`select count(*)::int as n from public.veli_baglama_hatalari where created_at > now() - interval '1 minute'`)).n;
// 29 başarısız deneme (her veli bir kez: hesap başına sınıra takılmadan)
for (let i = 0; i < 29; i++) {
  await kimsin('authenticated', GV[i]);
  const r = (await tek(`select public.veli_cocuk_bagla('000000') as j`)).j;
  if (!r?.hata) { ok('başarısız deneme kod hatası döndürür', false, JSON.stringify(r)); }
}
ok('29 başarısız deneme sistemde sayılır', (await hataSayisi()) === 29, `sayı=${await hataSayisi()}`);

await kimsin('authenticated', V2);
const e1 = await hatayiAl(async () => {
  const j = (await tek(`select public.veli_cocuk_bagla('111111') as j`)).j;
  if (j?.ogrenci_id !== S1) throw new Error('beklenen ogrenci_id yok: ' + JSON.stringify(j));
});
ok('eşik altında (29/30) geçerli kod bağlar', e1 === null, JSON.stringify(e1));

await kimsin('authenticated', GV[29]);
const e2 = (await tek(`select public.veli_cocuk_bagla('000000') as j`)).j;
ok('30. başarısız deneme kaydedilir', e2?.hata !== undefined && (await hataSayisi()) === 30, `sayı=${await hataSayisi()}`);

await kimsin('authenticated', V1);
const e3 = await hatayiAl(() => sorgu(`select public.veli_cocuk_bagla('222222')`));
ok('eşik aşılınca geçerli kod da reddedilir (cok_fazla_deneme, 54000)',
  e3?.kod === '54000' && e3?.mesaj.includes('cok_fazla_deneme'), JSON.stringify(e3));
const e4 = (await gozleTek(`select kullanildi_at from public.ogrenci_baglanti_kodlari where kod = '222222'`)).kullanildi_at;
ok('reddedilen denemede kod tüketilmez', e4 === null);
const e5 = (await gozleTek(`select count(*)::int as n from public.veli_baglama_hatalari where veli_id = '${V1}'`)).n;
ok('reddedilen deneme başarısız olarak sayılmaz', e5 === 0, `V1 hata=${e5}`);

await yaz(`update public.app_settings set value = '{"dakika_basina": 100}'::jsonb where key = 'veli_kod_global_sinir';`);
await kimsin('authenticated', V1);
const e6 = (await tek(`select public.veli_cocuk_bagla('222222') as j`)).j;
ok('ayar 100 yapılınca aynı kod bağlar (ayar okunur)', e6?.ogrenci_id === S2, JSON.stringify(e6));
await yaz(`update public.app_settings set value = '{"dakika_basina": 30}'::jsonb where key = 'veli_kod_global_sinir';`);

// Pencere geçince sayaç sıfırlanır
await yaz(`update public.veli_baglama_hatalari set created_at = now() - interval '2 minutes';`);
await kimsin('authenticated', V2);
const e7 = await hatayiAl(() => sorgu(`select public.veli_cocuk_bagla('444444')`));
ok('1 dk sonra sayaç sıfırlanır: bağlama başarılı', e7 === null, JSON.stringify(e7));

console.log('\n== F: hesap başına 3 / 15 dk sınırı korunur ==');
await kimsin('authenticated', V3);
for (let i = 0; i < 3; i++) {
  await sorgu(`select public.veli_cocuk_bagla('99999${i}')`);
}
const f1 = await hatayiAl(() => sorgu(`select public.veli_cocuk_bagla('444444')`));
ok('4. denemede hesap sınırı (42501, "Çok fazla hatalı")', f1?.kod === '42501' && f1?.mesaj.includes('Çok fazla hatalı'), JSON.stringify(f1));

console.log('\n== G: mevcut eşleştirme testleri (veli_eslestirme_kodu_tests.sql) ==');
await db.exec('reset role;');
await db.query(`select set_config('request.jwt.claim.sub', '', false)`);
const mevcutSonuc = await db.exec(fs.readFileSync(path.join(TESTLER, 'veli_eslestirme_kodu_tests.sql'), 'utf8'));
const mevcut = mevcutSonuc[mevcutSonuc.length - 1].rows;
const basarisiz = mevcut.filter((r) => r.gecti !== true);
ok(`mevcut eşleştirme testleri geçer (${mevcut.length - basarisiz.length}/${mevcut.length})`,
  mevcut.length > 0 && basarisiz.length === 0,
  basarisiz.map((r) => `#${r.no} ${r.senaryo}: ${r.detay}`).join(' | '));

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
process.exit(fail === 0 ? 0 : 1);
