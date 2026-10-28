// Veli sonraki adim RPC testi: veli_sonraki_adim().
// Gercek migration PGlite (gercek Postgres) uzerinde calisir. Docker gerekmez.
//
// Kullanim (bu klasorde bir kez: npm install):
//   node test.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const YENI = '20261111000000_veli_sonraki_adim.sql';
const oku = (f) => fs.readFileSync(f, 'utf8');

const db = new PGlite();

// Beklenmeyen hatada PGlite'in tum wasm dokumu yerine kisa mesaj.
process.on('uncaughtException', (e) => { console.log('HATA:', e.message ?? e); process.exit(1); });

let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  OK   ', ad); }
  else { fail++; console.log('  FAIL ', ad, detay); }
};
// Beklenen hata: mesajda 'parca' gecmeli.
const hataBekle = async (ad, fn, parca) => {
  try {
    await fn();
    fail++;
    console.log('  FAIL ', ad, '(hata bekleniyordu)');
  } catch (e) {
    const m = String(e.message ?? e);
    if (parca && !m.includes(parca)) { fail++; console.log('  FAIL ', ad, `beklenen "${parca}", gelen: ${m}`); }
    else { pass++; console.log('  OK   ', ad, '->', m.slice(0, 90)); }
  }
};

// Oturum taklidi: auth.uid() = uid, rol = authenticated (veya anon).
async function kimsin(uid, rol = 'authenticated') {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub', '${uid ?? ''}', false); set role ${rol};`);
}
const postgres = () => db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`);
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const sonuc = async () => (await sorgu(`select public.veli_sonraki_adim() as j`))[0].j;

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const ADMIN = id(1), OGRENCI = id(2), OGRETMEN = id(3);
const VBOS = id(10), VKOD = id(11), VBAGLI = id(12), VCEVAP = id(13), VTAM = id(14), VSURE = id(15), VDENEME = id(16), VBASKA = id(17);
const CBAGLI = id(20), CCEVAP = id(21), CTAM = id(22), CSURE = id(23), CDENEME = id(24), CBASKA = id(25);
const Q1 = id(90);

// Adim sirasi sabit: cocuk_ekle, eslestir, ilk_ders, deneme_veya_plan
const KODLAR = ['cocuk_ekle', 'eslestir', 'ilk_ders', 'deneme_veya_plan'];
const ozet = (j) => ({ durumlar: j.adimlar.map((a) => a.durum), siradaki: j.siradaki });

console.log('\n== Kurulum: stub + gercek migration ==');
await db.exec(oku(path.join(HERE, 'stubs.sql')));
await db.exec(oku(path.join(MIG, YENI)));
ok('migration hatasiz uygulandi', true);
await db.exec(oku(path.join(MIG, YENI)));
ok('migration ikinci kez hatasiz (idempotent)', true);

await postgres();
await db.exec(`
  insert into public.profiles (id, role, parent_id, full_name) values
    ('${ADMIN}', 'admin', null, 'Yonetici'),
    ('${OGRENCI}', 'ogrenci', null, 'Bagsiz Ogrenci'),
    ('${OGRETMEN}', 'ogretmen', null, 'Ogretmen'),
    ('${VBOS}', 'veli', null, 'Veli Bos'),
    ('${VKOD}', 'veli', null, 'Veli Kod'),
    ('${VBAGLI}', 'veli', null, 'Veli Bagli'),
    ('${VCEVAP}', 'veli', null, 'Veli Cevap'),
    ('${VTAM}', 'veli', null, 'Veli Tam'),
    ('${VSURE}', 'veli', null, 'Veli Sure'),
    ('${VDENEME}', 'veli', null, 'Veli Deneme'),
    ('${VBASKA}', 'veli', null, 'Baska Veli'),
    ('${CBAGLI}', 'ogrenci', '${VBAGLI}', 'Cocuk Bagli'),
    ('${CCEVAP}', 'ogrenci', '${VCEVAP}', 'Cocuk Cevap'),
    ('${CTAM}', 'ogrenci', '${VTAM}', 'Cocuk Tam'),
    ('${CSURE}', 'ogrenci', '${VSURE}', 'Cocuk Sure'),
    ('${CDENEME}', 'ogrenci', '${VDENEME}', 'Cocuk Deneme'),
    ('${CBASKA}', 'ogrenci', '${VBASKA}', 'Baska Cocuk');
  insert into public.parent_link_codes (kod, veli_id, son_kullanma)
    values ('K12345', '${VKOD}', now() + interval '1 day');
  insert into public.questions (id) values ('${Q1}');
  insert into public.user_answers (student_id, question_id, secilen_sik, dogru_mu) values
    ('${CCEVAP}', '${Q1}', 'A', true),
    ('${CTAM}', '${Q1}', 'B', false),
    ('${CSURE}', '${Q1}', 'C', true),
    ('${CDENEME}', '${Q1}', 'A', true),
    ('${CBASKA}', '${Q1}', 'D', true);
  insert into public.plans (kod, ad) values ('aylik', 'Aylik');
  insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis) values
    ('${VTAM}', 'aylik', 'aktif', now() - interval '1 day', now() + interval '30 days'),
    ('${VSURE}', 'aylik', 'aktif', now() - interval '60 days', now() - interval '1 day');
  insert into public.growth_households (core_parent_user_id, parent_name, email, trial_started_at)
    values ('${VDENEME}', 'Veli Deneme', 'deneme@example.invalid', now() - interval '2 days');
`);

console.log('\n== Guvenlik sertlestirme ==');
const guvenlik = (await sorgu(`
  select p.prosecdef as definer, p.proconfig as cfg,
         has_function_privilege('anon', 'public.veli_sonraki_adim()', 'EXECUTE') as anon_ok,
         has_function_privilege('authenticated', 'public.veli_sonraki_adim()', 'EXECUTE') as auth_ok
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.proname = 'veli_sonraki_adim'`))[0];
ok('SECURITY DEFINER', guvenlik?.definer === true);
ok("search_path = '' (GOR-004)", (guvenlik?.cfg ?? []).some((c) => c === 'search_path=""' || c === 'search_path='),
  JSON.stringify(guvenlik?.cfg));
ok('anon EXECUTE yok', guvenlik?.anon_ok === false);
ok('authenticated EXECUTE var', guvenlik?.auth_ok === true);

console.log('\n== Senaryolar (durum fixture\'lari) ==');
// [ad, veli uid, beklenen durumlar, beklenen siradaki]
const beklenenler = [
  ['yeni veli: hic kod ve cocuk yok', VBOS,
    ['siradaki', 'bekliyor', 'bekliyor', 'bekliyor'], 'cocuk_ekle'],
  ['kod uretildi, cocuk henuz baglanmadi', VKOD,
    ['tamam', 'siradaki', 'bekliyor', 'bekliyor'], 'eslestir'],
  ['cocuk bagli, cevap yok', VBAGLI,
    ['tamam', 'tamam', 'siradaki', 'bekliyor'], 'ilk_ders'],
  ['cocuk cevap verdi, plan yok', VCEVAP,
    ['tamam', 'tamam', 'tamam', 'siradaki'], 'deneme_veya_plan'],
  ['aktif abonelik (suresi dolmamis): hepsi tamam', VTAM,
    ['tamam', 'tamam', 'tamam', 'tamam'], null],
  ['abonelik suresi dolmus: deneme/plan sirada', VSURE,
    ['tamam', 'tamam', 'tamam', 'siradaki'], 'deneme_veya_plan'],
  ['deneme baslatilmis (growth_households): hepsi tamam', VDENEME,
    ['tamam', 'tamam', 'tamam', 'tamam'], null],
];

for (const [ad, uid, durumlar, siradaki] of beklenenler) {
  await kimsin(uid);
  const j = await sonuc();
  await postgres();
  const o = ozet(j);
  ok(ad, JSON.stringify(o.durumlar) === JSON.stringify(durumlar) && o.siradaki === siradaki,
    JSON.stringify(o));
}

console.log('\n== Sekil ve sira ==');
await kimsin(VBOS);
const sekil = await sonuc();
await postgres();
ok('ust anahtarlar yalnizca adimlar ve siradaki',
  JSON.stringify(Object.keys(sekil).sort()) === JSON.stringify(['adimlar', 'siradaki']), JSON.stringify(Object.keys(sekil)));
ok('adim sirasi sabit ve her adimda yalnizca kod ve durum',
  JSON.stringify(sekil.adimlar.map((a) => a.kod)) === JSON.stringify(KODLAR) &&
  sekil.adimlar.every((a) => Object.keys(a).sort().join() === 'durum,kod'));

console.log('\n== Veri izolasyonu ==');
// VBAGLI'nin cocugu cevap vermedi; diger velilerin cocuklari cevap verdi. Sonuc yalnizca VBAGLI'ninkini yansitmali.
await kimsin(VBAGLI);
const izole = await sonuc();
await postgres();
ok('baska velinin cocugu cevap verdiyse ilk_ders yine sirada',
  izole.adimlar[2].durum === 'siradaki', JSON.stringify(izole));
const metin = JSON.stringify(izole);
ok('sonuc baska velinin cocugunu/kimligini icermiyor',
  ![CCEVAP, CTAM, CSURE, CDENEME, CBASKA, VBASKA, VCEVAP, VTAM].some((x) => metin.includes(x)));
ok('sonuc ad, e-posta veya kisisel alan icermiyor',
  !/Cocuk|Veli|@|full_name|email/.test(metin));

// Cocuk bagi kaldirilirsa veli adimlari geriye doner (veli -> cocuk bagi dinamik okunur)
await db.exec(`update public.profiles set parent_id = null where id = '${CBAGLI}';`);
await kimsin(VBAGLI);
const bagKalktiki = await sonuc();
await postgres();
ok('cocuk bagi kaldirilinca cocuk_ekle sira baslasina doner',
  JSON.stringify(ozet(bagKalktiki)) === JSON.stringify({ durumlar: ['siradaki', 'bekliyor', 'bekliyor', 'bekliyor'], siradaki: 'cocuk_ekle' }),
  JSON.stringify(ozet(bagKalktiki)));

console.log('\n== Yetkisiz cagrilar ==');
await hataBekle('anon cagiramaz (izin yok)', async () => {
  await kimsin(null, 'anon');
  await sonuc();
}, 'permission denied');
await postgres();

await hataBekle('oturumsuz (auth.uid() null) reddedilir', async () => {
  await kimsin(null, 'authenticated');
  await sonuc();
}, 'Oturum bulunam');
await postgres();

await hataBekle('ogrenci hesabi reddedilir', async () => {
  await kimsin(OGRENCI);
  await sonuc();
}, 'veli hesaplar');
await postgres();

await hataBekle('ogretmen hesabi reddedilir', async () => {
  await kimsin(OGRETMEN);
  await sonuc();
}, 'veli hesaplar');
await postgres();

await hataBekle('yonetici hesabi reddedilir', async () => {
  await kimsin(ADMIN);
  await sonuc();
}, 'veli hesaplar');
await postgres();

await hataBekle('parametre ile baska veli hedeflenemez (imza yok)', async () => {
  await kimsin(VBAGLI);
  await db.query(`select public.veli_sonraki_adim($1)`, [VBASKA]);
}, 'veli_sonraki_adim');
await postgres();

console.log(`\nSonuc: ${pass} gecti, ${fail} kaldi`);
process.exit(fail === 0 ? 0 : 1);
