// Sınav katılım onayı testi (K6): PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node test.mjs
//
// Zincir: stubs.sql (canlı ESKİ durum) → [önce: pazarlama onayı kısıt hatası]
//         → 20261040000000_sinav_katilim_onayi.sql → [sonra: kurallar ve yetkiler].
// Gerçek migration dosyası çalışır; yalnız Supabase bağımlılıkları stubs.sql ile taklit edilir.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const M_KATILIM = path.join(here, '..', '..', 'migrations', '20261040000000_sinav_katilim_onayi.sql');

const oku = (p) => fs.readFileSync(p, 'utf8');

let gecen = 0;
let toplam = 0;
function sonuc(ad, ok, detay = '') {
  toplam++;
  if (ok) gecen++;
  console.log(`${String(toplam).padStart(2)}. [${ok ? 'OK  ' : 'FAIL'}] ${ad}${detay && !ok ? `\n      detay: ${detay}` : ''}`);
}

// Hata beklenen çağrı: SQLSTATE kodu eşleşmeli.
async function hataBekle(db, sql, params, kod) {
  try {
    await db.query(sql, params);
    return { ok: false, detay: 'hata bekleniyordu, çağrı başarılı oldu' };
  } catch (e) {
    const durum = String(e.code ?? '');
    return { ok: durum === kod, detay: `beklenen=${kod} gelen=${durum} mesaj=${e.message}` };
  }
}

// Başarılı beklenen çağrı.
async function basariBekle(db, sql, params) {
  try {
    await db.query(sql, params);
    return { ok: true, detay: '' };
  } catch (e) {
    return { ok: false, detay: `beklenmeyen hata: ${e.code} ${e.message}` };
  }
}

async function oturum(db, uid) {
  await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [uid]);
}

const VELI = '11111111-1111-4111-8111-111111111111';
const YABANCI_VELI = '22222222-2222-4222-8222-222222222222';
const COCUK = '33333333-3333-4333-8333-333333333333';
const COCUK2 = '44444444-4444-4444-8444-444444444444';
const SINAV = '55555555-5555-4555-8555-555555555555';
const KATILIM_SURUM = 'sinav-katilim-2026-10-v1';
const PAZARLAMA_SURUM = 'sinav-pazarlama-2026-10-v1';
const TELEFON = '+90 555 111 22 33';

async function tabanKur() {
  const db = new PGlite();
  await db.exec(oku(path.join(here, 'stubs.sql')));
  await db.exec(`
    insert into public.profiles (id, role, full_name) values
      ('${VELI}', 'veli', 'Test Veli'),
      ('${YABANCI_VELI}', 'veli', 'Yabancı Veli');
    insert into public.profiles (id, role, full_name, parent_id, sinif) values
      ('${COCUK}', 'ogrenci', 'Test Çocuk', '${VELI}', 4),
      ('${COCUK2}', 'ogrenci', 'Test Çocuk 2', '${VELI}', 4);
    insert into public.deneme_sinavlari (id, ad, baslangic_zamani, sure_dakika, siniflar, aktif)
      values ('${SINAV}', 'Test sınavı', now() + interval '7 days', 40, '{4,5}', true);
  `);
  return db;
}

async function main() {
  const db = await tabanKur();

  // ---- Önce: migration uygulanmadan (canlı ESKİ durum) ----
  await oturum(db, VELI);
  const onceSonuc = await hataBekle(
    db,
    'select public.set_exam_marketing_consent($1::uuid, $2)',
    [COCUK, PAZARLAMA_SURUM],
    '23514',
  );
  sonuc('ÖNCE: pazarlama onayı tür kısıtı yüzünden reddediliyor (kusur kanıtı)', onceSonuc.ok, onceSonuc.detay);

  // ---- Migration uygulanır ----
  let migrasyonHatasi = '';
  try {
    await db.exec(oku(M_KATILIM));
  } catch (e) {
    migrasyonHatasi = `${e.code} ${e.message}`;
  }
  sonuc('migration 20261040000000 hatasız uygulanıyor', migrasyonHatasi === '', migrasyonHatasi);

  // ---- Sonra: kısıt ----
  await oturum(db, VELI);
  const pazarlama = await basariBekle(
    db,
    'select public.set_exam_marketing_consent($1::uuid, $2)',
    [COCUK, PAZARLAMA_SURUM],
  );
  sonuc('SONRA: veli pazarlama onayını kendi çocuğu için verebiliyor', pazarlama.ok, pazarlama.detay);

  const pazarlamaSayi = await db.query(
    `select count(*)::int as n from public.consents where cocuk_id = $1 and tur = 'sinav_pazarlama_izni'`,
    [COCUK],
  );
  sonuc('pazarlama onayı tek satır olarak saklanıyor', pazarlamaSayi.rows[0].n === 1, `satır=${pazarlamaSayi.rows[0].n}`);

  const katilim = await basariBekle(
    db,
    'select public.set_exam_katilim_onayi($1::uuid, $2)',
    [COCUK, KATILIM_SURUM],
  );
  sonuc('veli katılım onayını verebiliyor (set_exam_katilim_onayi)', katilim.ok, katilim.detay);

  const kisitBilinmeyen = await hataBekle(
    db,
    `insert into public.consents (cocuk_id, veli_id, tur, surum) values ($1, $2, 'bilinmeyen_tur', 's')`,
    [COCUK, VELI],
    '23514',
  );
  sonuc('kısıt bilinmeyen türü hâlâ reddediyor', kisitBilinmeyen.ok, kisitBilinmeyen.detay);

  const eskiTur = await basariBekle(
    db,
    `insert into public.consents (cocuk_id, veli_id, tur, surum) values ($1, $2, 'veli_acik_riza', 's')`,
    [COCUK, VELI],
  );
  sonuc('mevcut veli_acik_riza türü etkilenmiyor', eskiTur.ok, eskiTur.detay);

  // ---- Yetki ve doğrulama ----
  await oturum(db, YABANCI_VELI);
  const yabanciKatilim = await hataBekle(
    db,
    'select public.set_exam_katilim_onayi($1::uuid, $2)',
    [COCUK, KATILIM_SURUM],
    '42501',
  );
  sonuc('yabancı veli katılım onayı veremez', yabanciKatilim.ok, yabanciKatilim.detay);

  const yabanciKayit = await hataBekle(
    db,
    'select public.register_for_mock_exam($1::uuid, $2::uuid, $3, $4)',
    [SINAV, COCUK, TELEFON, KATILIM_SURUM],
    '42501',
  );
  sonuc('yabancı veli çocuk adına sınava kayıt yaptıramaz', yabanciKayit.ok, yabanciKayit.detay);

  await oturum(db, VELI);
  const bosSurum = await hataBekle(
    db,
    'select public.set_exam_katilim_onayi($1::uuid, $2)',
    [COCUK2, '   '],
    '22023',
  );
  sonuc('boş sürüm reddediliyor', bosSurum.ok, bosSurum.detay);

  // ---- Kayıt kuralı: pazarlama onayı kayıt için yeterli DEĞİL ----
  await basariBekle(
    db,
    'select public.set_exam_marketing_consent($1::uuid, $2)',
    [COCUK2, PAZARLAMA_SURUM],
  );
  const yalnizPazarlama = await hataBekle(
    db,
    'select public.register_for_mock_exam($1::uuid, $2::uuid, $3, $4)',
    [SINAV, COCUK2, TELEFON, KATILIM_SURUM],
    '42501',
  );
  sonuc('yalnız pazarlama onayıyla sınav kaydı reddediliyor (katılım gerekli)', yalnizPazarlama.ok, yalnizPazarlama.detay);

  const telefonKisa = await hataBekle(
    db,
    'select public.register_for_mock_exam($1::uuid, $2::uuid, $3, $4)',
    [SINAV, COCUK, '123', KATILIM_SURUM],
    '22023',
  );
  sonuc('kısa telefon numarası reddediliyor', telefonKisa.ok, telefonKisa.detay);

  const yanlisSurum = await hataBekle(
    db,
    'select public.register_for_mock_exam($1::uuid, $2::uuid, $3, $4)',
    [SINAV, COCUK, TELEFON, 'eski-surum'],
    '42501',
  );
  sonuc('katılım onayı farklı sürümle kayda yetmiyor', yanlisSurum.ok, yanlisSurum.detay);

  // ---- Mutlu yol: katılım onayıyla kayıt ----
  const kayit = await basariBekle(
    db,
    'select public.register_for_mock_exam($1::uuid, $2::uuid, $3, $4)',
    [SINAV, COCUK, TELEFON, KATILIM_SURUM],
  );
  sonuc('katılım onayıyla sınav kaydı yapılıyor', kayit.ok, kayit.detay);

  const katilimSayi = await db.query(
    `select count(*)::int as n from public.deneme_sinavi_katilimlari where exam_id = $1 and student_id = $2`,
    [SINAV, COCUK],
  );
  sonuc('katılım kaydı tek satır oluşuyor', katilimSayi.rows[0].n === 1, `satır=${katilimSayi.rows[0].n}`);

  const telefonGuncel = await db.query(`select telefon from public.profiles where id = $1`, [COCUK]);
  sonuc('çocuğun telefonu kırpılmış değerle kaydediliyor', telefonGuncel.rows[0].telefon === TELEFON, `telefon=${telefonGuncel.rows[0].telefon}`);

  // ---- Yetki satırları (anon/authenticated) ----
  const yetkiler = await db.query(`
    select
      has_function_privilege('anon', 'public.set_exam_katilim_onayi(uuid,text)', 'EXECUTE') as anon_katilim,
      has_function_privilege('authenticated', 'public.set_exam_katilim_onayi(uuid,text)', 'EXECUTE') as auth_katilim,
      has_function_privilege('anon', 'public.register_for_mock_exam(uuid,uuid,text,text)', 'EXECUTE') as anon_kayit,
      has_function_privilege('authenticated', 'public.register_for_mock_exam(uuid,uuid,text,text)', 'EXECUTE') as auth_kayit
  `);
  const y = yetkiler.rows[0];
  sonuc('anon set_exam_katilim_onayi çalıştıramaz', y.anon_katilim === false, `anon=${y.anon_katilim}`);
  sonuc('authenticated set_exam_katilim_onayi çalıştırabilir', y.auth_katilim === true, `auth=${y.auth_katilim}`);
  sonuc('anon register_for_mock_exam çalıştıramaz', y.anon_kayit === false, `anon=${y.anon_kayit}`);
  sonuc('authenticated register_for_mock_exam çalıştırabilir', y.auth_kayit === true, `auth=${y.auth_kayit}`);

  console.log(`\nSonuç: ${gecen}/${toplam} geçti`);
  await db.close();
  if (gecen !== toplam) process.exitCode = 1;
}

main().catch((e) => {
  console.error('Test koşusu çöktü:', e);
  process.exitCode = 1;
});
