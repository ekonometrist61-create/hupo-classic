// GÖR-090: soru ajan kapısı (migration 20261155000000) PGlite sınaması.
// Kullanım (bu klasörde, npm install yapılmış olmalı):  node kos.mjs
// Yükleme: taklitler (stubs.sql) → gerçek migration → senaryolar.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyon = path.resolve(here, '../../migrations/20261155000000_soru_ajan_kapisi.sql');

const db = new PGlite();
await db.exec(fs.readFileSync(path.join(here, 'stubs.sql'), 'utf8'));
await db.exec(fs.readFileSync(migrasyon, 'utf8'));
console.log('tamam: migration yüklendi');

const sonuclar = [];
const kayit = (senaryo, gecti, detay = '') => sonuclar.push({ senaryo, gecti, detay });

// Bir ifadenin hata verdiğini ve mesajın beklenen parçayı içerdiğini sınar.
async function hataBekle(senaryo, sorgu, parca) {
  try {
    await sorgu();
    kayit(senaryo, false, 'hata beklenirdi, işlem başarılı oldu');
  } catch (e) {
    const ok = !parca || e.message.includes(parca);
    kayit(senaryo, ok, ok ? '' : `beklenen "${parca}", gelen: ${e.message}`);
  }
}

async function basarili(senaryo, sorgu) {
  try {
    const r = await sorgu();
    kayit(senaryo, true, '', r);
    return r;
  } catch (e) {
    kayit(senaryo, false, `beklenmeyen hata: ${e.message}`);
    return null;
  }
}

const sonucDegeri = (r) => r?.rows?.[0];

// Yardımcı: soru ekle (service_role değil, doğrudan tablo sahibi olarak).
async function soruEkle(metin, durum = 'beklemede', denetim = '{}') {
  const r = await db.query(
    `insert into public.questions (soru_metni, onay_durumu, denetim)
     values ($1, $2, $3::jsonb) returning id`,
    [metin, durum, denetim]
  );
  return r.rows[0].id;
}

// 1. Ajan kapısı kurulumu
const q1 = await soruEkle('Q1 beklemede');
kayit('beklemede soru eklenebilir (kapı yalnız onaylandi için)', true);

await hataBekle('onaylandi ile yeni ekleme ajan onaysız reddedilir (içe aktarma yolu)',
  () => soruEkle('Q-insert-onay', 'onaylandi'), 'AJAN_KAPISI');

await hataBekle('beklemede → onaylandi güncellemesi ajan onaysız reddedilir (panel yolu)',
  () => db.query(`update public.questions set onay_durumu = 'onaylandi' where id = $1`, [q1]),
  'AJAN_KAPISI');

// 2. Ajan sonuçlarını yazma: yalnız service_role
await hataBekle('denetim yazımı authenticated için yetkisiz',
  async () => {
    await db.exec('set role authenticated');
    try {
      await db.query(`select public.admin_soru_ajan_denetim_isle($1::jsonb)`,
        [JSON.stringify([{ id: q1, ajan_a: 'pass' }])]);
    } finally {
      await db.exec('reset role');
    }
  }, 'permission denied');

await hataBekle('geçersiz ajan sonucu reddedilir',
  async () => {
    await db.exec('set role service_role');
    try {
      await db.query(`select public.admin_soru_ajan_denetim_isle($1::jsonb)`,
        [JSON.stringify([{ id: q1, ajan_a: 'belki' }])]);
    } finally {
      await db.exec('reset role');
    }
  }, 'BAD_SONUC');

// Yalnız Ajan A geçti: onay hâlâ kapalı
await basarili('service_role ile yalnız ajan_a pass yazılır', async () => {
  await db.exec('set role service_role');
  try {
    return await db.query(`select public.admin_soru_ajan_denetim_isle($1::jsonb) as n`,
      [JSON.stringify([{ id: q1, ajan_a: 'pass', not: 'kök doğru' }])]);
  } finally {
    await db.exec('reset role');
  }
});

await hataBekle('yalnız ajan_a pass iken onay reddedilir',
  () => db.query(`update public.questions set onay_durumu = 'onaylandi' where id = $1`, [q1]),
  'AJAN_KAPISI');

// Ajan B de geçince onay açılır
await db.exec('set role service_role');
await db.query(`select public.admin_soru_ajan_denetim_isle($1::jsonb)`,
  [JSON.stringify([{ id: q1, ajan_b: 'pass' }])]);
await db.exec('reset role');

await basarili('iki ajan pass iken onay kabul edilir', async () =>
  db.query(`update public.questions set onay_durumu = 'onaylandi' where id = $1`, [q1]));

// 3. Denetim süzgeci
const q2 = await soruEkle('Q2 ajan reddi');
await db.exec('set role service_role');
await db.query(`select public.admin_soru_ajan_denetim_isle($1::jsonb)`,
  [JSON.stringify([{ id: q2, ajan_a: 'pass', ajan_b: 'review_needed', not: 'çeldirici zayıf' }])]);
await db.exec('reset role');

const q3 = await soruEkle('Q3 hiç denetlenmedi');

const listele = (p_denetim) => db.query(
  `select public.admin_list_questions(p_denetim => $1) as j`, [p_denetim]);

const jlist = async (p) => (await listele(p)).rows[0].j;

{
  const j = await jlist('ajan_gecti');
  const ids = (j.satirlar ?? []).map((s) => s.id);
  kayit('süzgeç ajan_gecti: yalnız iki ajanı geçen (q1)', j.toplam === 1 && ids[0] === q1,
    `toplam=${j.toplam}`);
}
{
  const j = await jlist('ajan_reddi');
  kayit('süzgeç ajan_reddi: review_needed olan q2', j.toplam === 1 && j.satirlar[0].id === q2,
    `toplam=${j.toplam}`);
}
{
  const j = await jlist('ajan_bekliyor');
  kayit('süzgeç ajan_bekliyor: hiç denetlenmemiş q3 (q2 reddi listesinde değil)',
    j.toplam === 1 && j.satirlar[0].id === q3, `toplam=${j.toplam}`);
}
{
  const j = await jlist(null);
  kayit('süzgeç boşken tüm sorular gelir', j.toplam === 3, `toplam=${j.toplam}`);
}
{
  const j = await jlist('ajan_gecti');
  const satir = j.satirlar[0];
  kayit('satırda denetim alanı döner', satir?.denetim?.ajan_a === 'pass' && satir?.denetim?.ajan_b === 'pass');
}
await hataBekle('bilinmeyen süzgeç değeri reddedilir', () => listele('hepsi'), 'BAD_FILTRE');

// 4. Toplu durum değişimi: karışık seçimde tümü geri alınır
await hataBekle('karışık toplu onay (q3 ajansız) tümünü geri alır',
  () => db.query(`select public.admin_set_question_status($1::uuid[], 'onaylandi')`, [[q1, q3]]),
  'AJAN_KAPISI');
{
  const r = await db.query(`select onay_durumu from public.questions where id = $1`, [q3]);
  kayit('karışık toplu onay sonrası q3 hâlâ beklemede', r.rows[0].onay_durumu === 'beklemede');
}
await basarili('reddetme ajan kapısına takılmaz', async () =>
  db.query(`select public.admin_set_question_status($1::uuid[], 'reddedildi')`, [[q3]]));

// 5. Mevcut onaylı sorular etkilenmez (geçiş değil, düz güncelleme)
await db.exec('alter table public.questions disable trigger questions_ajan_kapisi');
const eski = await soruEkle('Eski onaylı (kapı öncesi)', 'onaylandi');
await db.exec('alter table public.questions enable trigger questions_ajan_kapisi');
await basarili('mevcut onaylı soru konu güncellemesinde reddedilmez', async () =>
  db.query(`update public.questions set konu = 'Yeni konu' where id = $1`, [eski]));

// 6. denetim nesne olmalı
await hataBekle('denetim dizi olarak yazılamaz',
  () => db.query(`update public.questions set denetim = '[]'::jsonb where id = $1`, [q2]),
  'questions_denetim_is_object');

// Sonuç
let gecen = 0;
for (const [i, s] of sonuclar.entries()) {
  if (s.gecti) gecen++;
  console.log(`${String(i + 1).padStart(2)}. [${s.gecti ? 'OK  ' : 'FAIL'}] ${s.senaryo}`);
  if (!s.gecti && s.detay) console.log(`      detay: ${s.detay}`);
}
console.log(`\nSonuç: ${gecen}/${sonuclar.length} geçti`);
if (gecen !== sonuclar.length) process.exit(1);

