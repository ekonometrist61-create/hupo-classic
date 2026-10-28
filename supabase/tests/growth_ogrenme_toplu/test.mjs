// Toplulaştırılmış öğrenme analitiği: gerçek migration zinciri PGlite üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: okuma stub → siniflar (20261003000010) → okuma tabloları (20261050000000) → ogrenme_toplu (20261117).
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../okuma_dunyasi/stubs.sql');
const ZINCIR = [
  '20261003000010_ogretmen_ve_siniflar.sql',
  '20261050000000_okuma_dunyasi_tablolar.sql',
  '20261117000000_growth_ogrenme_toplu.sql',
];

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
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 90)); }
  }
};
const kur = async (ad, fn) => {
  try { await fn(); }
  catch (e) { console.log(`HATA [${ad}]: ${e.message}`); process.exit(1); }
};
const tek = async (sql, params = []) => (await db.query(sql, params)).rows[0];
const postgres = () => db.exec('reset role;');
const rolle = (rol) => db.exec(`reset role; set role ${rol};`);
const oturum = (id) => db.exec(`set request.jwt.claims = '{"sub":"${id}"}';`);

const ADMIN = '00000000-0000-4000-8000-000000000001';
const ogrenci = (n) => `00000000-0000-4000-6000-${String(n).padStart(12, '0')}`;
const HA = '00000000-0000-4000-7000-00000000000a';
const HB = '00000000-0000-4000-7000-00000000000b';
const SA = '00000000-0000-4000-7100-00000000000a';
const SB = '00000000-0000-4000-7100-00000000000b';
const TODAY_IST = `((now() at time zone 'Europe/Istanbul')::date)`;

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
for (const f of ZINCIR) await kur(f, () => db.exec(oku(f)));
ok('migration zinciri hatasız (siniflar → okuma → ogrenme_toplu)', true);

await postgres();
await db.exec(`insert into auth.users (id, email) values ('${ADMIN}', 'a@test.local');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin');`);

// Öğrenciler: 1-12 sınıf 4 (görünür), 13-16 sınıf 5 (gizli), 17-26 sınıf 6 (60 gün önce; yalnız 90 günde)
for (let n = 1; n <= 26; n++) {
  await db.exec(`insert into auth.users (id, email) values ('${ogrenci(n)}', 'o${n}@test.local');
    insert into public.profiles (id, role, sinif) values ('${ogrenci(n)}', 'ogrenci', ${n <= 12 ? 4 : n <= 16 ? 5 : 6});`);
}

await db.exec(`
  insert into public.okuma_hikayeleri (id, slug) values ('${HA}', 'hr-a-test'), ('${HB}', 'hr-b-test');
  insert into public.okuma_hikaye_surumleri (id, hikaye_id, surum_no, durum, icerik, sha256, baslik, tur, konu,
    sinif_alt, sinif_ust, okuma_bandi, dunya_tipi, izinli_turler, yetiskin_uygun, sayfa_sayisi, soru_sayisi)
  values
    ('${SA}', '${HA}', 1, 'taslak', '{}'::jsonb, repeat('a', 64), 'A', 'macera', 'konu', 4, 4, 2, 'gercekci', '{ben}', false, 5, 3),
    ('${SB}', '${HB}', 1, 'taslak', '{}'::jsonb, repeat('b', 64), 'B', 'macera', 'konu', 4, 4, 2, 'gercekci', '{ben}', false, 5, 3);
`);

// Oturumlar: sınıf 4 → 12 öğrenci A'da, 6'sı tamamlamış; sınıf 5 → 4 öğrenci B'de, hepsi tamam;
// sınıf 6 → 10 öğrenci A'da, 60 gün önce.
const oturumEkle = async (n, hikaye, surum, gunFark, tamam) => db.exec(`
  insert into public.okuma_oturumlari (ogrenci_id, hikaye_id, surum_id, istemci_anahtari, kahraman_turu, sinif, gun,
    baslangic_at, soru_sayisi, dogru_sayisi, tamamlandi_at)
  values ('${ogrenci(n)}', '${hikaye}', '${surum}', 'anahtar-${n}-${gunFark}', 'ben',
    (select sinif from public.profiles where id = '${ogrenci(n)}'),
    ${TODAY_IST} - ${gunFark}, now() - interval '${gunFark} days', 3, 2,
    ${tamam ? `now() - interval '${gunFark} days' + interval '5 minutes'` : 'null'});`);

for (let n = 1; n <= 12; n++) await oturumEkle(n, HA, SA, 2, n <= 6);
for (let n = 13; n <= 16; n++) await oturumEkle(n, HB, SB, 2, true);
for (let n = 17; n <= 26; n++) await oturumEkle(n, HA, SA, 60, true);

console.log('\n== 30 gün: eşik ve toplulaştırma ==');
await oturum(ADMIN);
const v30 = (await tek(`select public.admin_ogrenme_toplu(30) as v`)).v;
ok('eşik 10 döner', v30.esik === 10, JSON.stringify(v30.esik));
ok('sınıf 4 görünür: 12 öğrenci, 12 oturum, tamamlama %50',
  v30.siniflar.length === 1 && v30.siniflar[0].sinif === 4 && v30.siniflar[0].ogrenci === 12
  && v30.siniflar[0].oturum === 12 && Number(v30.siniflar[0].tamamlama_orani) === 50, JSON.stringify(v30.siniflar));
ok('sınıf 5 (4 öğrenci) gizli: hiç satır yok', !v30.siniflar.some((s) => s.sinif === 5), JSON.stringify(v30.siniflar));
ok('sınıf 6 (60 gün önce) 30 günde yok', !v30.siniflar.some((s) => s.sinif === 6));
ok('hikaye A görünür: 12 öğrenci, %50',
  v30.hikayeler.length === 1 && v30.hikayeler[0].slug === 'hr-a-test' && v30.hikayeler[0].ogrenci === 12
  && Number(v30.hikayeler[0].tamamlama_orani) === 50, JSON.stringify(v30.hikayeler));
ok('hikaye B (4 öğrenci) gizli', !v30.hikayeler.some((h) => h.slug === 'hr-b-test'));

console.log('\n== 90 gün: pencere genişler ==');
const v90 = (await tek(`select public.admin_ogrenme_toplu(90) as v`)).v;
ok('90 günde sınıf 6 görünür (10 öğrenci)', v90.siniflar.some((s) => s.sinif === 6 && s.ogrenci === 10), JSON.stringify(v90.siniflar));
ok('90 günde hikaye A 22 öğrenci', v90.hikayeler.some((h) => h.slug === 'hr-a-test' && h.ogrenci === 22), JSON.stringify(v90.hikayeler));

console.log('\n== Gizlilik: çıktıda kimlik, doğruluk veya beceri yok ==');
const metin = JSON.stringify(v90);
ok('çıktıda öğrenci kimliği (uuid) yok', !/00000000-0000-4000-6000/.test(metin));
ok('çıktıda oturum/istemci anahtarı yok', !/anahtar-|istemci|oturum_id|ogrenci_id/.test(metin));
ok('çıktıda doğruluk veya beceri alanı yok', !/dogru|beceri|hedef|yanlis/i.test(metin));
ok('çıktıda kişi bazlı satır yok (her satır toplu anahtarlar)',
  [...v90.siniflar, ...v90.hikayeler].every((r) => Object.keys(r).every((k) => ['sinif', 'slug', 'ogrenci', 'oturum', 'tamamlama_orani'].includes(k))));

console.log('\n== Yetki ==');
await oturum(ogrenci(1));
await hataBekle('öğrenci toplu analitiği okuyamaz', () => tek(`select public.admin_ogrenme_toplu(30)`), 'admin yetkisi');
await oturum(ADMIN);
await rolle('anon');
await hataBekle('anon çalıştıramaz', () => tek(`select public.admin_ogrenme_toplu(30)`), 'permission denied');
await postgres();

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
