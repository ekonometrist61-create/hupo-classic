// Growth mesaj günlüğü testi: gerçek core + growth + mesaj migration zinciri PGlite (gerçek Postgres) üzerinde çalışır.
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import fs from 'node:fs';
import path from 'node:path';

const DIZIN = import.meta.dirname;
const MIG = path.resolve(DIZIN, '../../migrations');
const CORE = '20261014000000_growth_crm_core.sql';
const YENI = '20261100000000_growth_mesaj_gunlugu.sql';
const IMZA = 'public.growth_mesaj_kaydet(uuid,uuid,uuid,text,text,text,jsonb,text,text)';
const IMZA_GUNCELLE = 'public.growth_mesaj_durum_guncelle(uuid,text,text,boolean,boolean,boolean)';

// Core migration "create extension pgcrypto" satırını içerir; PGlite'ta contrib olarak yüklenir.
const db = new PGlite({ extensions: { pgcrypto } });
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8');

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

const rol = (r) => db.exec(`reset role; set role ${r};`);
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const tek = async (sql, params = []) => (await sorgu(sql, params))[0];
const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const H1 = id(1), H2 = id(2), K1 = id(3), K2 = id(4), J1 = id(5), YOK = id(99);

const KAYDET_SQL = `select public.growth_mesaj_kaydet($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9) as id`;
const kaydet = (o = {}) => tek(KAYDET_SQL, [
  o.hane === undefined ? H1 : o.hane,
  o.kampanya === undefined ? K1 : o.kampanya,
  o.yolculuk ?? null,
  o.kanal ?? 'email',
  o.durum ?? 'kuyrukta',
  o.saglayici ?? null,
  o.izin === undefined ? '{"eposta": true}' : o.izin,
  o.hash ?? 'sha256:abc',
  o.hata ?? null,
]).then((r) => r.id);

const guncelle = (mid, durum, saglayici = null, acildi = false, tiklandi = false, donustu = false) =>
  sorgu(`select public.growth_mesaj_durum_guncelle($1, $2, $3, $4, $5, $6)`, [mid, durum, saglayici, acildi, tiklandi, donustu]);

const sayac = (kid) => tek(`select sent, opened, clicked, converted from public.growth_campaigns where id = $1`, [kid]);
const satir = (mid) => tek(`select * from public.growth_message_log where id = $1`, [mid]);

console.log('\n== Kurulum: stub + core growth + mesaj migration ==');
await db.exec(fs.readFileSync(path.join(DIZIN, 'stubs.sql'), 'utf8'));
await db.exec(oku(CORE));
ok('core growth migration hatasız', true);
await db.exec(oku(YENI));
ok('mesaj migration ilk kez hatasız', true);
await db.exec(oku(YENI));
ok('mesaj migration ikinci kez hatasız (idempotent)', true);
const [{ n: kisitSayi }] = await sorgu(
  `select count(*)::int as n from pg_constraint where conname = 'growth_message_log_status_chk'`);
ok('durum kısıtı tam bir kez var', kisitSayi === 1, `sayı ${kisitSayi}`);

await db.exec(`
  insert into public.growth_households (id, parent_name, email) values
    ('${H1}', 'Test Veli Bir', 'veli1@test.local'),
    ('${H2}', 'Test Veli İki', 'veli2@test.local');
  insert into public.growth_campaigns (id, name, channel) values
    ('${K1}', 'Kampanya A', 'email'),
    ('${K2}', 'Kampanya B', 'push');
  insert into public.growth_journeys (id, name) values ('${J1}', 'Yolculuk');
`);

console.log('\n== A: yetki (yalnız service_role) ==');
const acl = async (r, imza) => (await tek(`select has_function_privilege('${r}', '${imza}', 'EXECUTE') as b`)).b;
ok('anon: growth_mesaj_kaydet çalıştıramaz', (await acl('anon', IMZA)) === false);
ok('authenticated: growth_mesaj_kaydet çalıştıramaz', (await acl('authenticated', IMZA)) === false);
ok('service_role: growth_mesaj_kaydet çalıştırabilir', (await acl('service_role', IMZA)) === true);
ok('anon: durum güncelleme çalıştıramaz', (await acl('anon', IMZA_GUNCELLE)) === false);
ok('authenticated: durum güncelleme çalıştıramaz', (await acl('authenticated', IMZA_GUNCELLE)) === false);
ok('service_role: durum güncelleme çalıştırabilir', (await acl('service_role', IMZA_GUNCELLE)) === true);
ok('anon: sayaç tetikleyici fonksiyonunu çalıştıramaz',
  (await acl('anon', 'public._growth_mesaj_sayac()')) === false);

await rol('anon');
await hataBekle('anon kaydet çağıramaz', () => kaydet({ durum: 'kuyrukta' }), 'permission denied');
await rol('authenticated');
await hataBekle('authenticated kaydet çağıramaz', () => kaydet({ durum: 'kuyrukta' }), 'permission denied');
await hataBekle('authenticated durum güncelleyemez', () => guncelle(YOK, 'gonderildi'), 'permission denied');
await hataBekle('authenticated günlük tablosunu okuyamaz', () => sorgu('select id from public.growth_message_log'), 'permission denied');
await rol('anon');
await hataBekle('anon kampanya sayaçlarını okuyamaz', () => sorgu('select sent from public.growth_campaigns'), 'permission denied');
await rol('service_role');

console.log('\n== B: kaydet doğrulamaları ==');
await hataBekle('geçersiz durum reddedilir', () => kaydet({ durum: 'hatali' }), 'Geçersiz mesaj durumu');
await hataBekle('geçersiz kanal reddedilir', () => kaydet({ kanal: 'fax' }), 'Geçersiz kanal');
await hataBekle('hane kimliği zorunlu', () => kaydet({ hane: null }), 'Hane kimliği zorunlu');
await hataBekle('izin anlık görüntüsü null reddedilir', () => kaydet({ izin: null }), 'İzin anlık görüntüsü nesne olmalı');
await hataBekle('izin anlık görüntüsü dizi reddedilir', () => kaydet({ izin: '[]' }), 'İzin anlık görüntüsü nesne olmalı');
await hataBekle('kaydet ile acildi yazılamaz (işaret gerekir)', () => kaydet({ durum: 'acildi' }),
  'growth_mesaj_durum_guncelle');
await hataBekle('kaydet ile tiklandi yazılamaz', () => kaydet({ durum: 'tiklandi' }), 'growth_mesaj_durum_guncelle');
await hataBekle('kaydet ile donustu yazılamaz', () => kaydet({ durum: 'donustu' }), 'growth_mesaj_durum_guncelle');
await hataBekle('var olmayan kampanya FK ile reddedilir', () => kaydet({ kampanya: YOK }), 'foreign key');

console.log('\n== C: kaydet ve gönderim sayacı ==');
const s0 = await sayac(K1);
const ilk = await kaydet({ durum: 'kuyrukta', kampanya: K1 });
const ilkS = await satir(ilk);
ok('kuyrukta satır oluşur, sent_at boş', !!ilk && ilkS.sent_at === null && ilkS.status === 'kuyrukta');
ok('kuyrukta kampanya sayacını artırmaz', JSON.stringify(await sayac(K1)) === JSON.stringify(s0));

const gonderilen = await kaydet({ durum: 'gonderildi', kampanya: K1, saglayici: '  prov-1  ', hata: 'h'.repeat(600) });
const gS = await satir(gonderilen);
ok('gonderildi: sent_at dolar, sağlayıcı kimliği kırpılır', gS.sent_at !== null && gS.provider_message_id === 'prov-1');
ok('gonderildi: hata metni 500 karakterle sınırlanır', gS.error.length === 500, `uzunluk ${gS.error?.length}`);
ok('gonderildi: kampanya sent +1', (await sayac(K1)).sent === s0.sent + 1);

const basarisiz = await kaydet({ durum: 'basarisiz', kampanya: K1, saglayici: '   ', hata: 'Sağlayıcı reddetti' });
const bS = await satir(basarisiz);
ok('basarisiz: sent_at boş, boş sağlayıcı kimliği null', bS.sent_at === null && bS.provider_message_id === null);
ok('basarisiz: kampanya sayacı değişmez', (await sayac(K1)).sent === s0.sent + 1);

const izinYok = await kaydet({ durum: 'izin_yok', kampanya: K1 });
ok('izin_yok: sayaç değişmez', (await sayac(K1)).sent === s0.sent + 1 && (await satir(izinYok)).sent_at === null);

const yolculuk = await kaydet({ durum: 'gonderildi', kampanya: null, yolculuk: J1 });
ok('kampanyasız (yolculuk) satırı hatasız yazılır ve sayaç etkilenmez',
  !!yolculuk && (await sayac(K1)).sent === s0.sent + 1);

const teslim = await kaydet({ durum: 'teslim_edildi', kampanya: K2, kanal: 'push' });
ok('teslim_edildi sent_at yazar, K2 sent +1', (await satir(teslim)).sent_at !== null && (await sayac(K2)).sent === 1);

console.log('\n== D: durum güncelleme ve tek sefer sayım ==');
await hataBekle('geçersiz durum güncellemede reddedilir', () => guncelle(gonderilen, 'hatali'), 'Geçersiz mesaj durumu');
await hataBekle('kayıt yoksa P0002 ile reddedilir', () => guncelle(YOK, 'gonderildi'), 'Mesaj kaydı bulunamadı');
await hataBekle('acildi işaretsiz reddedilir', () => guncelle(gonderilen, 'acildi', null, false), 'açılma işareti');
ok('reddedilen acildi satırın durumunu değiştirmez', (await satir(gonderilen)).status === 'gonderildi');

await guncelle(gonderilen, 'acildi', null, true);
const acildiZaman = (await satir(gonderilen)).opened_at;
ok('acildi (işaretli): opened_at dolar, kampanya opened 1',
  acildiZaman !== null && (await sayac(K1)).opened === 1);
await guncelle(gonderilen, 'acildi', null, true);
ok('aynı açılma tekrar gelirse sayaç 1 kalır ve zaman damgası değişmez',
  (await sayac(K1)).opened === 1 && (await satir(gonderilen)).opened_at.getTime() === acildiZaman.getTime());

await hataBekle('tiklandi işaretsiz reddedilir', () => guncelle(gonderilen, 'tiklandi', null, false, false), 'tıklama işareti');
await guncelle(gonderilen, 'tiklandi', null, false, true);
ok('tiklandi (işaretli): clicked 1, opened değişmez', (await sayac(K1)).clicked === 1 && (await sayac(K1)).opened === 1);
await guncelle(gonderilen, 'tiklandi', null, false, true);
ok('tekrar tıklama clicked değerini artırmaz', (await sayac(K1)).clicked === 1);

await guncelle(gonderilen, 'donustu', null, false, false, true);
ok('donustu (işaretli): converted 1', (await sayac(K1)).converted === 1);
await guncelle(gonderilen, 'donustu', null, false, false, true);
ok('tekrar dönüşüm converted değerini artırmaz', (await sayac(K1)).converted === 1);

await guncelle(gonderilen, 'gonderildi', 'prov-2');
ok('durum gerilese de sayaçlar azalmaz (4 sayaç da 1)',
  JSON.stringify(await sayac(K1)) === JSON.stringify({ sent: s0.sent + 1, opened: 1, clicked: 1, converted: 1 }),
  JSON.stringify(await sayac(K1)));
ok('gerileme durumu yazar', (await satir(gonderilen)).status === 'gonderildi');
ok('sağlayıcı kimliği güncellenir', (await satir(gonderilen)).provider_message_id === 'prov-2');
await guncelle(gonderilen, 'gonderildi', null);
ok('boş sağlayıcı kimliği mevcut değeri korur', (await satir(gonderilen)).provider_message_id === 'prov-2');

console.log('\n== E: tetikleyici savunması (doğrudan UPDATE / INSERT) ==');
const d = await kaydet({ durum: 'kuyrukta', kampanya: K2, kanal: 'push' });
const k2_0 = await sayac(K2);
await db.exec(`update public.growth_message_log set sent_at = now() where id = '${d}'`);
const k2_1 = await sayac(K2);
ok('doğrudan UPDATE ile sent_at NULL -> dolu: sent +1', k2_1.sent === k2_0.sent + 1);
await db.exec(`update public.growth_message_log set sent_at = now() + interval '1 minute' where id = '${d}'`);
ok('dolu sent_at tekrar değişince sayaç artmaz', (await sayac(K2)).sent === k2_1.sent);
await db.exec(`update public.growth_message_log set opened_at = now() where id = '${d}'`);
ok('doğrudan opened_at yazımı opened +1', (await sayac(K2)).opened === k2_1.opened + 1);
await db.exec(`update public.growth_message_log set status = 'tiklandi' where id = '${d}'`);
ok('yalnız durum değişimi sayaçları artırmaz', JSON.stringify(await sayac(K2)) === JSON.stringify({ ...k2_1, opened: k2_1.opened + 1 }));

const k2_2 = await sayac(K2);
await db.exec(`insert into public.growth_message_log
    (household_id, campaign_id, channel, status, consent_snapshot, sent_at, opened_at)
  values ('${H2}', '${K2}', 'push', 'acildi', '{}'::jsonb, now(), now())`);
const k2_3 = await sayac(K2);
ok('tek INSERT (sent_at ve opened_at dolu) sent +1 ve opened +1',
  k2_3.sent === k2_2.sent + 1 && k2_3.opened === k2_2.opened + 1, JSON.stringify({ k2_2, k2_3 }));

console.log('\n== F: kısıt (yeni satırlara uygulanır) ==');
await hataBekle('doğrudan INSERT geçersiz durumu reddeder (CHECK)', () => db.exec(`insert into public.growth_message_log
    (household_id, channel, status, consent_snapshot) values ('${H1}', 'email', 'hatali', '{}'::jsonb)`),
  'growth_message_log_status_chk');
await hataBekle('doğrudan UPDATE geçersiz durumu reddeder (CHECK)', () => db.exec(`update public.growth_message_log
    set status = 'hatali' where id = '${ilk}'`), 'growth_message_log_status_chk');

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
