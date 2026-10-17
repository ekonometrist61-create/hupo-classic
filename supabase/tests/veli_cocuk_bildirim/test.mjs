// Veli–çocuk bildirim, bağlı çocuk listesi ve bağlantı kaldırma testi.
// Gerçek migration zinciri PGlite (gerçek Postgres) üzerinde çalışır. Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node test.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const BILDIRIM = path.resolve(import.meta.dirname, '../bildirim_kampanya');
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8');

// Önkoşul zinciri: bildirim testindeki stub + zincir, ardından eşleştirme ve bu migration.
const ZINCIR = [
  '20260920001000_push_notifications.sql',
  '20261026000000_site_duyurulari.sql',
  '20261030000000_duyuru_yuzeyler.sql',
  '20261032000000_duyuru_anket_arsiv_ve_sil.sql',
  '20261003000020_admin_bildirim_yonetimi.sql',
];
const YENI = '20261042000000_veli_cocuk_bildirim.sql';

const db = new PGlite();

// Beklenmeyen hatada PGlite'in tüm wasm dökümü yerine kısa mesaj.
process.on('uncaughtException', (e) => { console.log('HATA:', e.message ?? e); process.exit(1); });

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

// Oturum taklidi: auth.uid() = uid, rol = authenticated (veya anon).
async function kimsin(uid, rol = 'authenticated') {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub', '${uid ?? ''}', false); set role ${rol};`);
}
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const postgres = () => db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`);

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const ADMIN = id(1), V1 = id(2), V2 = id(3), S1 = id(4), S2 = id(5), S3 = id(6), T1 = id(7);

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await db.exec(fs.readFileSync(path.join(BILDIRIM, 'stubs.sql'), 'utf8'));
await db.exec(fs.readFileSync(path.join(BILDIRIM, 'stubs2.sql'), 'utf8'));
for (const f of ZINCIR) await db.exec(oku(f));
await db.exec(oku('20261035000000_bildirim_kampanya_ve_kutu.sql'));
await db.exec(oku('20261016000000_veli_eslestirme_kodu.sql'));
await db.exec(oku(YENI));
ok('migration zinciri hatasız (yeni migration dahil)', true);
await db.exec(oku(YENI));
ok('yeni migration ikinci kez hatasız (idempotent)', true);

await postgres();
// Üretimde username 20260920000000_initial_schema ile gelir; bildirim stub'ı profiles'ı bu kolonsuz kurar.
await db.exec(`alter table public.profiles add column if not exists username text;`);
// Üretimde consents.veli_id 20260920000800 ile gelir; stub bu kolonu içermiyor.
await db.exec(`alter table public.consents add column if not exists veli_id uuid;`);
await db.exec(`alter table public.consents add column if not exists surum text not null default 'test';`);
await db.exec(`
  insert into public.profiles (id, role, parent_id, full_name, username) values
    ('${ADMIN}', 'admin', null, 'Yönetici', 'yonetici'),
    ('${V1}', 'veli', null, 'Ayşe Yılmaz', 'ayse.veli'),
    ('${V2}', 'veli', null, 'Mehmet Kaya', 'mehmet.veli'),
    ('${S1}', 'ogrenci', '${V1}', 'Ali Yılmaz', 'ali.y'),
    ('${S2}', 'ogrenci', '${V2}', 'Zeynep Kaya', 'zeynep.k'),
    ('${S3}', 'ogrenci', null, 'Elif Demir', 'elif.d'),
    ('${T1}', 'ogretmen', null, 'Öğretmen Bir', 'ogretmen1');
`);

console.log('\n== Eşleştirme: bildirim ve e-posta kuyruğu ==');
// Veli kod üretir (S3 henüz bağlı değil)
await kimsin(V1);
const kodJson = (await sorgu(`select public.create_parent_link_code() as j`))[0].j;
const kod = kodJson.kod;
ok('veli kod üretebildi', typeof kod === 'string' && kod.length === 6, JSON.stringify(kodJson));

// Öğrenci S3 kodu kullanır
await kimsin(S3);
const sonuc = (await sorgu(`select public.redeem_parent_link_code($1) as j`, [kod]))[0].j;
ok('öğrenci kodla bağlandı', sonuc.durum === 'baglandi', JSON.stringify(sonuc));

await postgres();
const veliBildirim = await sorgu(
  `select baslik, mesaj, kategori, ikon from public.notifications where alici_id = $1 order by created_at desc`, [V1]);
ok('veliye bağlanma bildirimi kutuya düştü',
  veliBildirim.some((n) => n.baslik === 'Çocuğunuz hesabını bağladı' && n.mesaj.includes('Elif Demir')),
  JSON.stringify(veliBildirim));
ok('veli bildirimi kategorisi sistem', veliBildirim.some((n) => n.kategori === 'sistem'));

const veliEposta = await sorgu(`select konu, durum from public.eposta_outbox where alici_id = $1`, [V1]);
ok('veli için e-posta kuyruğa girdi (bekliyor)',
  veliEposta.length === 1 && veliEposta[0].durum === 'bekliyor', JSON.stringify(veliEposta));

const cocukBildirim = await sorgu(
  `select baslik from public.notifications where alici_id = $1`, [S3]);
ok('çocuğa "veli hesabına bağlandın" bildirimi düştü',
  cocukBildirim.some((n) => n.baslik === 'Veli hesabına bağlandın'), JSON.stringify(cocukBildirim));
const cocukEposta = await sorgu(`select 1 from public.eposta_outbox where alici_id = $1`, [S3]);
ok('çocuk için e-posta kuyruğa girmedi (adres ve onay politikası)', cocukEposta.length === 0);

// Bildirim tek girişten geçer: push kuyruğu da notifications trigger'ı ile dolar (push opt-in değilse boş kalır)
ok('bildirim tek giriş fonksiyonundan geçiyor (kutu kaydı mevcut)', veliBildirim.length >= 1);

console.log('\n== Bağlı çocuk listesi ==');
await kimsin(V1);
let liste = (await sorgu(`select public.veli_bagli_cocuklar() as j`))[0].j;
ok('veli listesinde bağlı çocuk var', Array.isArray(liste) && liste.length === 2,
  JSON.stringify(liste));
const elif = liste.find((c) => c.id === S3);
ok('listede çocuğun adı ve kullanıcı adı var',
  elif && elif.ad === 'Elif Demir' && elif.kullanici_adi === 'elif.d', JSON.stringify(elif));
ok('listede bağlanma zamanı var', elif && typeof elif.baglandi_at === 'string', JSON.stringify(elif));
ok('listede e-posta/telefon alanı yok',
  elif && !('email' in elif) && !('telefon' in elif) && !('phone' in elif));
ok('yeni bağlanan çocuğun onay durumu "bekliyor"', elif && elif.riza === 'bekliyor', JSON.stringify(elif));

// Veli onay verir (ConsentCard'ın yazdığı kayıtla aynı şekil)
await postgres();
await db.exec(`insert into public.consents (cocuk_id, veli_id, tur, surum) values ('${S3}', '${V1}', 'veli_acik_riza', 'test-1');`);
await kimsin(V1);
liste = (await sorgu(`select public.veli_bagli_cocuklar() as j`))[0].j;
ok('veli onay verince durum "verildi"', liste.find((c) => c.id === S3)?.riza === 'verildi');

await kimsin(V2);
const v2Liste = (await sorgu(`select public.veli_bagli_cocuklar() as j`))[0].j;
ok('başka veli bu çocuğu listede görmüyor', v2Liste.every((c) => c.id !== S3), JSON.stringify(v2Liste));

await kimsin(S1);
await hataBekle('öğrenci hesabı bağlı çocuk listesini okuyamaz',
  () => db.query(`select public.veli_bagli_cocuklar()`), 'yalnızca veli');

console.log('\n== Bağlantı kaldırma ==');
await kimsin(V2);
await hataBekle('veli, kendisine bağlı olmayan çocuğu kaldıramaz',
  () => db.query(`select public.veli_cocuk_baglantisini_kaldir($1)`, [S3]), 'size bağlı değil');

await kimsin(V1);
const kaldir = (await sorgu(`select public.veli_cocuk_baglantisini_kaldir($1) as j`, [S3]))[0].j;
ok('veli bağlantıyı kaldırdı', kaldir.durum === 'kaldirildi', JSON.stringify(kaldir));
liste = (await sorgu(`select public.veli_bagli_cocuklar() as j`))[0].j;
ok('kaldırılan çocuk listeden çıktı', liste.every((c) => c.id !== S3));

await postgres();
const parent = await sorgu(`select parent_id from public.profiles where id = $1`, [S3]);
ok('çocuğun parent_id alanı boşaldı', parent[0].parent_id === null);
const riza = await sorgu(
  `select tur from public.consents where cocuk_id = $1 order by created_at desc limit 1`, [S3]);
ok('kaldırmada veri paylaşım onayı geri çekildi kaydı yazıldı',
  riza[0]?.tur === 'veli_riza_geri_cekildi', JSON.stringify(riza));
const kaldirBildirimCocuk = await sorgu(
  `select 1 from public.notifications where alici_id = $1 and baslik = 'Veli bağlantısı kaldırıldı'`, [S3]);
ok('çocuğa bağlantı kaldırma bildirimi düştü', kaldirBildirimCocuk.length === 1);
const kaldirEpostaVeli = await sorgu(
  `select 1 from public.eposta_outbox where alici_id = $1 and konu = 'Çocuk bağlantısı kaldırıldı'`, [V1]);
ok('veliye bağlantı kaldırma e-postası kuyruğa girdi', kaldirEpostaVeli.length === 1);

// Yeniden bağlanan başka veli, önceki onayı devralmamalı
await kimsin(V2);
const kod2 = (await sorgu(`select public.create_parent_link_code() as j`))[0].j.kod;
await kimsin(S3);
const sonuc2 = (await sorgu(`select public.redeem_parent_link_code($1) as j`, [kod2]))[0].j;
ok('çocuk ikinci veliye bağlanabildi', sonuc2.durum === 'baglandi', JSON.stringify(sonuc2));
await kimsin(V2);
const v2Son = (await sorgu(`select public.veli_bagli_cocuklar() as j`))[0].j;
ok('yeni veli çocuğu görüyor ama onay "bekliyor" (öncekini devralmadı)',
  v2Son.find((c) => c.id === S3)?.riza === 'bekliyor', JSON.stringify(v2Son));

console.log('\n== Güvenlik sınırları ==');
await kimsin(V1);
await hataBekle('veli e-posta kuyruğunu okuyamaz',
  () => db.query(`select * from public.eposta_outbox`), 'permission denied');
await hataBekle('veli bildirim fonksiyonunu doğrudan çağıramaz',
  () => db.query(`select public.bildirim_gonder($1, 'x', 'y', true)`, [V1]), 'permission denied');
await kimsin(null, 'anon');
await hataBekle('anonim kullanıcı bağlı çocuk listesini çağıramaz',
  () => db.query(`select public.veli_bagli_cocuklar()`), 'permission denied');

await postgres();
const kuyrukSayi = await sorgu(`select count(*)::int as n from public.eposta_outbox`);
ok('kuyrukta satırlar servis tarafından okunabiliyor', kuyrukSayi[0].n >= 2, JSON.stringify(kuyrukSayi));

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
process.exit(fail === 0 ? 0 : 1);
