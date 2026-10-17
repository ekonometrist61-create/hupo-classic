// Bildirim kampanyası + kutu testi: gerçek migration zinciri PGlite (gerçek Postgres) üzerinde çalışır.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const YENI = '20261035000000_bildirim_kampanya_ve_kutu.sql';
const ZINCIR = [
  '20260920001000_push_notifications.sql',
  '20261026000000_site_duyurulari.sql',
  '20261030000000_duyuru_yuzeyler.sql',
  '20261032000000_duyuru_anket_arsiv_ve_sil.sql',
  '20261003000020_admin_bildirim_yonetimi.sql',
];

const db = new PGlite();
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
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 80)); }
  }
};

// Oturum taklidi: auth.uid() = uid, rol = authenticated (veya anon).
async function kimsin(uid, rol = 'authenticated') {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub', '${uid ?? ''}', false); set role ${rol};`);
}
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const postgres = () => db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`);

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const ADMIN = id(1), V1 = id(2), V2 = id(3), S1 = id(4), S2 = id(5), T1 = id(6);

const CRM = ['20261007000010_crm_profil_tercihler_ve_denetim.sql', '20261007000020_segment_kampanya_ve_iletisim_ayarlari.sql'];
const KAMPANYA = '20261036000000_kampanya_push_dagitim.sql';

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await db.exec(fs.readFileSync(path.join(import.meta.dirname, 'stubs.sql'), 'utf8'));
await db.exec(fs.readFileSync(path.join(import.meta.dirname, 'stubs2.sql'), 'utf8'));
for (const f of ZINCIR) await db.exec(oku(f));
for (const f of CRM) await db.exec(oku(f));
await db.exec(oku(YENI));
ok('20261035 migration ilk kez hatasız', true);
await db.exec(oku(YENI));
ok('20261035 migration ikinci kez hatasız (idempotent)', true);
await db.exec(oku(KAMPANYA));
ok('20261036 migration ilk kez hatasız', true);
// Kayıt izni trigger'ları (auth.users) — 20261037 push kutusunu ekler
await db.exec(oku('20261015000000_iletisim_izni_kayit_ve_iptal.sql'));
await db.exec(oku('20261020000300_iletisim_kanal_telefon_ve_uc_kanal_kayit.sql'));
await db.exec(oku('20261037000000_kayit_push_izni.sql'));
ok('kayıt izni migration zinciri (20261015 → 20261037) hatasız', true);
// 20261036'nın ikinci çalıştırması ANCAK 20261038'den ÖNCE yapılır: sıra değişirse eski gövde yeniyi ezer.
await db.exec(oku(KAMPANYA));
ok('20261036 migration ikinci kez hatasız (idempotent)', true);
await db.exec(oku('20261038000000_pazarlama_push_kapisi_ve_olcum.sql'));
ok('hukuk kapısı + ölçüm migration hatasız', true);
await db.exec(oku('20261038000000_pazarlama_push_kapisi_ve_olcum.sql'));
ok('hukuk kapısı + ölçüm migration ikinci kez hatasız (idempotent)', true);
await db.exec(oku('20261044000000_segment_bildirim_dagitim_kapisi.sql'));
ok('segmentli bildirim kanal ve kapı migration (20261044) hatasız', true);
await db.exec(oku('20261044000000_segment_bildirim_dagitim_kapisi.sql'));
ok('segmentli bildirim migration (20261044) ikinci kez hatasız (idempotent)', true);

await postgres();
await db.exec(`
  insert into public.profiles (id, role, parent_id, full_name) values
    ('${ADMIN}', 'admin', null, 'Yönetici'),
    ('${V1}', 'veli', null, 'Veli Bir'),
    ('${V2}', 'veli', null, 'Veli İki'),
    ('${S1}', 'ogrenci', '${V1}', 'Öğrenci Bir'),
    ('${S2}', 'ogrenci', '${V2}', 'Öğrenci İki'),
    ('${T1}', 'ogretmen', null, 'Öğretmen Bir');
`);

console.log('\n== B: Yönetici kayıt kuralları ==');
await kimsin(ADMIN);
const [{ id: idIndirim }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Yaz indirimi', 'Veli panelinde indirim', true, null,
     array['veli_paneli'], 'indirim') as id`);
ok('indirim yalnızca veli panelinde kaydedilir', !!idIndirim);

await hataBekle('indirim öğrenci yüzeyine (mobil) kaydedilemez',
  () => sorgu(`select public.admin_save_duyuru(null, 'X', 'Y', true, null, array['mobil'], 'indirim')`),
  'yalnızca web sitesi');

await hataBekle('indirim kutuya (inbox) gönderilemez',
  () => sorgu(`select public.admin_save_duyuru(null, 'X', 'Y', true, null, array['web_sitesi'], 'indirim', 'veli', null, true)`),
  'kutusuna gönderilemez');

await hataBekle('geçersiz kategori reddedilir',
  () => sorgu(`select public.admin_save_duyuru(null, 'X', 'Y', true, null, array['web_sitesi'], 'promosyon')`),
  'Geçersiz duyuru kategorisi');

const [{ id: idLegacy }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Eski', 'Eski altı parametreli çağrı', true, null, array['web_sitesi']) as id`);
await postgres();
const [legacy] = await sorgu(`select kategori, hedef_rol, inbox_yayin from public.duyurular where id = $1`, [idLegacy]);
ok('eski 6 parametreli çağrı çalışır ve varsayılanları alır',
  legacy.kategori === 'duyuru' && legacy.hedef_rol === 'tumu' && legacy.inbox_yayin === false, JSON.stringify(legacy));

await kimsin(V1);
await hataBekle('veli duyuru kaydedemez', () =>
  sorgu(`select public.admin_save_duyuru(null, 'X', 'Y', true, null, array['web_sitesi'])`), 'Yetkisiz');

await postgres();
await hataBekle('DB seviyesi: indirim kutuya açılamaz (CHECK)', () =>
  db.exec(`update public.duyurular set inbox_yayin = true where id = '${idIndirim}'`), 'duyurular_indirim_korumasi');
await hataBekle('DB seviyesi: indirim öğrenci yüzeyinde insert edilemez (CHECK)', () =>
  db.exec(`insert into public.duyurular (baslik, metin, aktif, yuzeyler, kategori)
           values ('x', 'y', true, array['mobil'], 'indirim')`), 'duyurular_indirim_korumasi');

console.log('\n== C: Kutu dağıtımı ==');
await kimsin(ADMIN);
const [{ id: idTumu }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Bakım penceresi', 'Bu gece 02:00 kısa bakım', true, null,
     array['web_sitesi'], 'sistem', 'tumu', null, true) as id`);

await postgres();
const [{ n: dagitim1 }] = await sorgu(`select public.duyuru_inbox_yayinla() as n`);
ok('tümü: veli+öğrenci+öğretmen alır (yönetici almaz) → 5', Number(dagitim1) === 5, `gelen ${dagitim1}`);
const [{ n: dagitim2 }] = await sorgu(`select public.duyuru_inbox_yayinla() as n`);
ok('ikinci çalıştırma tekrar göndermez → 0', Number(dagitim2) === 0, `gelen ${dagitim2}`);

await kimsin(ADMIN);
const [{ id: idVeli }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Akademik takvim', 'Deneme tarihleri', true, null,
     array['veli_paneli'], 'akademik', 'veli', now() + interval '1 day', true) as id`);
await postgres();
const [{ n: gelecek }] = await sorgu(`select public.duyuru_inbox_yayinla() as n`);
ok('başlangıcı gelecekte olan duyuru dağıtılmaz → 0', Number(gelecek) === 0, `gelen ${gelecek}`);
await db.exec(`update public.duyurular set baslangic_at = now() - interval '1 minute' where id = '${idVeli}'`);
const [{ n: zamanli }] = await sorgu(`select public.duyuru_inbox_yayinla() as n`);
ok('zamanı gelince yalnız veliler alır → 2', Number(zamanli) === 2, `gelen ${zamanli}`);

const [{ n: ogrenciVeli }] = await sorgu(
  `select count(*)::int as n from public.notifications n join public.profiles p on p.id = n.alici_id
    where n.kaynak_duyuru_id = $1 and p.role = 'ogrenci'`, [idVeli]);
ok('hedef=veli iken öğrenciye kutu kaydı yok', ogrenciVeli === 0, `öğrenci kaydı ${ogrenciVeli}`);

console.log('\n== D: get_bildirimler (kutu okuma) ==');
await kimsin(S1);
let r = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('öğrenci S1: yalnız tümü duyurusu → okunmamış 1', r.okunmamis_sayi === 1 && r.satirlar.length === 1, JSON.stringify(r).slice(0, 200));
ok('satır alanları: tur, kategori, baslik, mesaj, okundu', ['tur', 'kategori', 'baslik', 'mesaj', 'okundu', 'okundu_at', 'created_at'].every((k) => k in r.satirlar[0]));

await kimsin(V1);
r = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('veli V1: tümü + akademik → okunmamış 2', r.okunmamis_sayi === 2 && r.satirlar.length === 2, JSON.stringify(r).slice(0, 200));
const [{ j: sayfa }] = await sorgu(`select public.get_bildirimler(1, 0) as j`);
ok('sayfalama: limit 1 iken okunmamış sayısı tam kalır (2)', sayfa.satirlar.length === 1 && sayfa.okunmamis_sayi === 2);

await kimsin(ADMIN);
r = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('yönetici kutusu boş', r.okunmamis_sayi === 0 && r.satirlar.length === 0);

await hataBekle('anonim kullanıcı kutuyu okuyamaz', async () => {
  await kimsin(null, 'anon');
  await sorgu(`select public.get_bildirimler()`);
}, 'permission denied');

console.log('\n== E: arşiv ve süre sonu kutuyu gizler ==');
await kimsin(ADMIN);
await sorgu(`select public.admin_duyuru_arsivle($1, true)`, [idTumu]);
await kimsin(S1);
r = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('arşivlenen tümü duyurusu öğrencinin kutusundan gider → 0', r.okunmamis_sayi === 0 && r.satirlar.length === 0);
await postgres();
await db.exec(`update public.duyurular set bitis_at = now() - interval '1 minute' where id = '${idVeli}'`);
await kimsin(V1);
r = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('süresi dolan akademik duyuru veli kutusundan gider → 0', r.okunmamis_sayi === 0 && r.satirlar.length === 0, JSON.stringify(r).slice(0, 150));

console.log('\n== F: okundu işaretleme kalıcı ==');
await kimsin(ADMIN);
const [{ id: idYeni }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Yeni içerik', 'Yeni kelime seti yayında', true, null,
     array['web_sitesi'], 'akademik', 'veli', null, true) as id`);
await postgres();
await sorgu(`select public.duyuru_inbox_yayinla()`);
await kimsin(V1);
const [{ n: okunan }] = await sorgu(`select public.mark_notifications_read(null) as n`);
// V1'in okunmamış 3 kaydı var (arşivli tümü, süresi dolmuş akademik, yeni akademik); gizli kayıtlar da okundu olur.
ok('mark_notifications_read tüm okunmamış kayıtları işaretler (3)', Number(okunan) === 3, `gelen ${okunan}`);
r = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('okundu sonrası okunmamış sayısı 0 (kalıcı)', r.okunmamis_sayi === 0);
await postgres();
const [{ okundu_at }] = await sorgu(
  `select okundu_at from public.notifications where alici_id = $1 and kaynak_duyuru_id = $2`, [V1, idYeni]);
ok('okundu_at yazıldı', okundu_at !== null);

await kimsin(S1);
await hataBekle('istemci notifications tablosunu doğrudan güncelleyemez (eski web hatasının regresyon testi)',
  () => db.exec(`reset role; set role authenticated; select set_config('request.jwt.claim.sub', '${S1}', false);
                  update public.notifications set okundu = true where alici_id = '${S1}'`),
  'permission denied');

console.log('\n== G: banner zamanlama ==');
await kimsin(ADMIN);
const [{ id: idBanner }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Gelecek banner', 'Henüz başlamadı', true, null,
     array['web_sitesi'], 'duyuru', 'tumu', now() + interval '1 day', false) as id`);
await kimsin(null, 'anon');
let b = (await sorgu(`select public.get_aktif_duyuru('web_sitesi') as j`))[0].j;
ok('başlangıcı gelmemiş banner gösterilmez', b === null || b.id !== idBanner, JSON.stringify(b));
await postgres();
await db.exec(`update public.duyurular set baslangic_at = now() - interval '1 minute' where id = '${idBanner}'`);
await kimsin(null, 'anon');
b = (await sorgu(`select public.get_aktif_duyuru('web_sitesi') as j`))[0].j;
ok('başlangıcı gelen banner en yenisi olarak gösterilir', b && b.id === idBanner, JSON.stringify(b));

console.log('\n== H: yönetici listeleri ==');
await kimsin(ADMIN);
const [{ j: liste }] = await sorgu(`select public.admin_list_notifications(50, 0) as j`);
ok('admin_list_notifications kampanya kopyalarını saymaz', liste.toplam === 0 && liste.satirlar.length === 0, JSON.stringify(liste).slice(0, 120));
await postgres();
const [{ n: kopya }] = await sorgu(`select count(*)::int as n from public.notifications where kaynak_duyuru_id is not null`);
ok('kampanya kopyaları gerçekten var (sayım bağlamı)', kopya > 0, `kopya ${kopya}`);
await kimsin(ADMIN);
const [{ j: duyurular }] = await sorgu(`select public.admin_list_duyurular(false) as j`);
ok('admin_list_duyurular yeni alanları döner',
  duyurular.length > 0 && ['kategori', 'hedef_rol', 'baslangic_at', 'inbox_yayin', 'inbox_yayinlandi_at'].every((k) => k in duyurular[0]));

const [{ n: legacySend }] = await sorgu(
  `select public.admin_send_notification('Eski gönderim', 'Mesaj', 'bell', null, 'veli') as n`);
ok('admin_send_notification (eski akış) hâlâ çalışır → 2 veli', Number(legacySend) === 2, `gelen ${legacySend}`);

console.log('\n== I: push hattı (opt-in şartı korunur) ==');
await kimsin(V1);
await sorgu(`select public.set_push_preference(true, '00:00', '00:00')`);
await kimsin(ADMIN);
const [{ id: idPush }] = await sorgu(
  `select public.admin_save_duyuru(null, 'Push testi', 'Push kuyruğu', true, null,
     array['web_sitesi'], 'duyuru', 'tumu', now() - interval '1 minute', true) as id`);
await postgres();
await sorgu(`select public.duyuru_inbox_yayinla()`);
const outbox = await sorgu(
  `select po.user_id from public.push_outbox po
     join public.notifications n on n.id = po.notification_id
    where n.kaynak_duyuru_id = $1`, [idPush]);
ok('yalnız push açmış veli için kuyruk satırı oluşur', outbox.length === 1 && outbox[0].user_id === V1,
  JSON.stringify(outbox));

console.log('\n== J: pazarlama push kampanyası (segment veya elle seçilen veli, push izni şart) ==');
await postgres();
// Hukuk kapısı varsayılan KAPALI olmalı; dağıtım testleri onu yönetici kararıyla açtıktan sonra çalışır.
await kimsin(ADMIN);
const [{ j: kapiVarsayilan }] = await sorgu(`select public.admin_pazarlama_push_kapisi_getir() as j`);
ok('hukuk kapısı başlangıçta kapalı (varsayılan)', kapiVarsayilan.durum === 'kapali', JSON.stringify(kapiVarsayilan));
await kimsin(ADMIN);
await sorgu(`select public.admin_pazarlama_push_kapisi_guncelle('onaylandi', 'hupolingo-ticari-ileti-2026-10-v2', 'gerekli_degil', 'test kapısı')`);
await postgres();
await db.exec(`update public.iletisim_ayarlari set sessiz_baslangic = '00:00', sessiz_bitis = '00:00'`);
await db.exec(`
  insert into public.iletisim_tercihleri (veli_id, kanal, izin, kaynak) values
    ('${V1}', 'push', true, 'veli'),
    ('${V2}', 'push', false, 'veli'),
    ('${S1}', 'push', true, 'sistem');
`);
const [{ id: segListe }] = await sorgu(
  `insert into public.segmentler (ad, kriterler) values ('Elle seçilen', $1::jsonb) returning id`,
  [JSON.stringify({ veli_idleri: [V1, V2, S1] })]);
const [{ id: segPlan }] = await sorgu(
  `insert into public.segmentler (ad, kriterler) values ('Ücretsiz plan', '{"plan":["free"]}'::jsonb) returning id`);
const [{ id: segBos }] = await sorgu(
  `insert into public.segmentler (ad, kriterler) values ('Boş kriter', '{}'::jsonb) returning id`);
const [{ id: segBosListe }] = await sorgu(
  `insert into public.segmentler (ad, kriterler) values ('Boş liste', '{"veli_idleri": []}'::jsonb) returning id`);
const [{ id: segOgrenci }] = await sorgu(
  `insert into public.segmentler (ad, kriterler) values ('Yalnız öğrenci', $1::jsonb) returning id`,
  [JSON.stringify({ veli_idleri: [S1] })]);

const kampanya = async (ad, seg) => (await sorgu(
  `insert into public.iletisim_kampanyalari (ad, kanal, segment_id, baslik, mesaj, durum, planlanan_at)
   values ($1, 'push', $2, 'Yeni fırsat', 'Hupo ile bu hafta bir adım daha!', 'planlandi', now() - interval '1 minute')
   returning id`, [ad, seg]))[0].id;
const dagit = async () => Number((await sorgu(`select public.kampanya_push_gonder() as n`))[0].n);
const durumu = async (kid) => (await sorgu(`select durum, onkontrol from public.iletisim_kampanyalari where id = $1`, [kid]))[0];
const kutu = async (kid) => sorgu(`select alici_id, pazarlama, kategori from public.notifications where kaynak_kampanya_id = $1`, [kid]);

const k1 = await kampanya('Elle seçilen 1', segListe);
const k1n = await dagit();
const k1r = await kutu(k1);
ok('elle seçilen liste: yalnız push izni olan veli alır (V2 izinsiz, S1 öğrenci)',
  k1n === 1 && k1r.length === 1 && k1r[0].alici_id === V1, JSON.stringify(k1r));
ok('pazarlama satırı: kategori kampanya, pazarlama=true', k1r[0]?.pazarlama === true && k1r[0]?.kategori === 'kampanya');
ok('kampanya durumu gonderildi', (await durumu(k1)).durum === 'gonderildi');

const k2 = await kampanya('Plan segmenti', segPlan);
await dagit();
ok('plan segmenti: yalnız izinli veli (V1) → 1 kayıt', (await kutu(k2)).length === 1);

const k3 = await kampanya('Boş kriter', segBos);
await dagit();
const d3 = await durumu(k3);
ok('boş kriterli segment herkese gitmez: iptal edilir',
  d3.durum === 'iptal' && d3.onkontrol.iptal_nedeni === 'segment_bos_veya_yok', JSON.stringify(d3));
ok('boş kriterli kampanyanın hiçbir alıcısı yok', (await kutu(k3)).length === 0);

const k4 = await kampanya('Boş liste', segBosListe);
await dagit();
const d4 = await durumu(k4);
ok('boş veli listesi hata verir, kampanya iptal olur (diğerleri etkilenmez)',
  d4.durum === 'iptal' && d4.onkontrol.iptal_nedeni === 'dagitim_hatasi', JSON.stringify(d4));

const k5 = await kampanya('Yalnız öğrenci', segOgrenci);
await dagit();
ok('öğrenci hesabı pazarlama alamaz (yalnız öğrenci seçilse de)', (await kutu(k5)).length === 0);

await db.exec(`update public.iletisim_ayarlari set haftalik_limit = 2`);
const k6 = await kampanya('Limit testi', segPlan);
await dagit();
ok('haftalık limit (2) dolmuş veliye yeni pazarlama gitmez', (await kutu(k6)).length === 0);
await db.exec(`update public.iletisim_ayarlari set haftalik_limit = 3`);

await db.exec(`update public.iletisim_tercihleri set izin = false where veli_id = '${V1}' and kanal = 'push'`);
const k7 = await kampanya('Rıza geri çekildi', segPlan);
await dagit();
ok('push izni geri çekilmişse kayıt oluşmaz', (await kutu(k7)).length === 0);
await db.exec(`update public.iletisim_tercihleri set izin = true where veli_id = '${V1}' and kanal = 'push'`);

await db.exec(`update public.iletisim_ayarlari set sessiz_baslangic = '00:00', sessiz_bitis = '23:59:59'`);
const k8 = await kampanya('Sessiz saat', segPlan);
await dagit();
const d8 = await durumu(k8);
ok('sessiz saatte dağıtım yapılmaz, kampanya iptal olur', d8.durum === 'iptal' && d8.onkontrol.iptal_nedeni === 'sessiz_saat', JSON.stringify(d8));
await db.exec(`update public.iletisim_ayarlari set sessiz_baslangic = '00:00', sessiz_bitis = '00:00'`);

await kimsin(V1);
await sorgu(`select public.set_push_preference(true, '00:00', '00:00')`);
await postgres();
const k9 = await kampanya('Push cihazı açık', segPlan);
await dagit();
const k9out = await sorgu(
  `select po.user_id from public.push_outbox po join public.notifications n on n.id = po.notification_id
    where n.kaynak_kampanya_id = $1`, [k9]);
ok('cihaz izni ve push izni olan veliye push kuyruğu oluşur', k9out.length === 1 && k9out[0].user_id === V1, JSON.stringify(k9out));

await kimsin(V2);
await sorgu(`select public.set_push_preference(true, '00:00', '00:00')`);
await postgres();
const [{ id: v2Bildirim }] = await sorgu(
  `insert into public.notifications (alici_id, tur, baslik, mesaj, ikon, kategori, pazarlama)
   values ($1, 'bilgi', 'Doğrudan pazarlama', 'Test', 'bell', 'kampanya', true) returning id`, [V2]);
const v2Out = await sorgu(`select 1 from public.push_outbox where notification_id = $1`, [v2Bildirim]);
ok('veri katmanı savunması: push izni olmayan veliye pazarlama push kuyruğu oluşmaz', v2Out.length === 0);

const k10 = await dagit();
ok('tekrar çalıştırma yeni kayıt üretmez', k10 === 0);
const [{ n: v1Kopya }] = await sorgu(
  `select count(*)::int as n from public.notifications where kaynak_kampanya_id = $1 and alici_id = $2`, [k1, V1]);
ok('aynı kampanya aynı kişiye tek kez düşer', v1Kopya === 1, `kopya ${v1Kopya}`);

await kimsin(V1);
await kimsin(ADMIN);
const [{ j: listeK }] = await sorgu(`select public.admin_list_notifications(50, 0) as j`);
await postgres();
const [{ n: kaynaksiz }] = await sorgu(
  `select count(*)::int as n from public.notifications
    where tur = 'bilgi' and kaynak_duyuru_id is null and kaynak_kampanya_id is null`);
ok('admin listesi yalnız kaynaksız bilgi kayıtlarını sayar (kampanya kopyaları hariç)',
  listeK.toplam === kaynaksiz && !listeK.satirlar.some((x) => x.baslik === 'Yeni fırsat'),
  `toplam ${listeK.toplam}, kaynaksız ${kaynaksiz}`);

await kimsin(V1);
const rv1 = (await sorgu(`select public.get_bildirimler() as j`))[0].j;
ok('kampanya kaydı veli kutusunda kategori kampanya ile görünür',
  rv1.satirlar.some((x) => x.kategori === 'kampanya'));
await postgres();
const [{ n: ogrenciPazarlama }] = await sorgu(
  `select count(*)::int as n from public.notifications n join public.profiles p on p.id = n.alici_id
    where n.pazarlama and p.role = 'ogrenci'`);
ok('hiçbir öğrenciye pazarlama kaydı yok', ogrenciPazarlama === 0, `kayıt ${ogrenciPazarlama}`);

console.log('\n== K: kayıt formunda isteğe bağlı push izni (boş = yok, işaretli = kayıt) ==');
const KULLANICI_K = { veliPushAcik: id(21), veliPushKapali: id(22), veliEskiForm: id(23), cocuk: id(24) };
const kayitMetni = (extra) => JSON.stringify({
  role: 'veli', full_name: 'Kayıt Testi', iletisim_metin_surumu: 'hupolingo-ticari-ileti-2026-10-v2', ...extra,
});
await postgres();
await db.exec(`
  insert into public.profiles (id, role, full_name) values
    ('${KULLANICI_K.veliPushAcik}', 'veli', 'Push açık'),
    ('${KULLANICI_K.veliPushKapali}', 'veli', 'Push kapalı'),
    ('${KULLANICI_K.veliEskiForm}', 'veli', 'Eski form'),
    ('${KULLANICI_K.cocuk}', 'ogrenci', 'Çocuk');
`);
const kayitEt = async (uid, meta) => db.exec(`
  insert into auth.users (id, email, raw_user_meta_data, email_confirmed_at)
  values ('${uid}', '${uid}@test.local', '${meta.replace(/'/g, "''")}'::jsonb, now());
`);
await kayitEt(KULLANICI_K.veliPushAcik, kayitMetni({
  iletisim_eposta: false, iletisim_sms: false, iletisim_telefon: false, iletisim_push: true }));
await kayitEt(KULLANICI_K.veliPushKapali, kayitMetni({
  iletisim_eposta: false, iletisim_sms: false, iletisim_telefon: false, iletisim_push: false }));
await kayitEt(KULLANICI_K.veliEskiForm, kayitMetni({
  iletisim_eposta: true, iletisim_sms: false, iletisim_telefon: false }));
await kayitEt(KULLANICI_K.cocuk, JSON.stringify({ role: 'ogrenci', iletisim_push: true, iletisim_metin_surumu: 'v2' }));

const tercihi = async (uid) => sorgu(
  `select kanal, izin from public.iletisim_tercihleri where veli_id = $1 order by kanal`, [uid]);
const pushTercihi = async (uid) => (await tercihi(uid)).find((x) => x.kanal === 'push');

ok('push işaretli veli: push izni true kaydedilir', (await pushTercihi(KULLANICI_K.veliPushAcik))?.izin === true);
ok('push işaretsiz veli: izin=false kaydı (açık ret kanıtı, diğer kanallarla aynı)',
  (await pushTercihi(KULLANICI_K.veliPushKapali))?.izin === false);
ok('push alanı hiç gelmeyen eski form: push satırı yok', (await pushTercihi(KULLANICI_K.veliEskiForm)) === undefined);
ok('eski formda e-posta izni hâlâ doğru yazılır', (await tercihi(KULLANICI_K.veliEskiForm)).find((x) => x.kanal === 'eposta')?.izin === true);
ok('çocuk hesabına hiçbir iletişim tercihi yazılmaz', (await tercihi(KULLANICI_K.cocuk)).length === 0);

const [{ n: gecmis }] = await sorgu(
  `select count(*)::int as n from public.iletisim_tercih_gecmisi
    where veli_id = $1 and kanal = 'push' and izin = true and gerekce like '%v2%'`, [KULLANICI_K.veliPushAcik]);
ok('push onayı geçmişe metin sürümüyle (v2) yazılır (KVKK kanıtı)', gecmis === 1, `kayıt ${gecmis}`);

console.log('\n== L: hukuk kapısı, ön izin ölçümü ve sıklık sınırı ==');
const V1_ID = V1;
const v2Metin = 'hupolingo-ticari-ileti-2026-10-v2';
const kapiAc = (not, surum, iys) => sorgu(`select public.admin_pazarlama_push_kapisi_guncelle($1, $2, $3, $4) as j`,
  ['onaylandi', surum, iys, not]);
const kapiKapat = () => sorgu(`select public.admin_pazarlama_push_kapisi_guncelle('kapali', null, 'bilinmiyor', 'test') as j`);
const ozet = async (gun = 1) => (await sorgu(`select public.admin_push_on_izin_ozeti($1) as j`, [gun]))[0].j;

await kimsin(ADMIN);
await kapiKapat();
await postgres();
const kKapali = await kampanya('Kapı kapalı', segPlan);
await dagit();
const dKapali = await durumu(kKapali);
ok('kapı kapalıyken kampanya gönderilmez ve iptal edilir (yasal_kapi_kapali)',
  dKapali.durum === 'iptal' && dKapali.onkontrol.iptal_nedeni === 'yasal_kapi_kapali' && (await kutu(kKapali)).length === 0,
  JSON.stringify(dKapali));

await kimsin(null, 'anon');
ok('kapı kapalıyken kayıt formunda push kutusu gösterilmez (anonim sorgu false)',
  (await sorgu(`select public.iletisim_push_kullanilabilir($1) as b`, [v2Metin]))[0].b === false);

await kimsin(V1);
await hataBekle('veli kapıyı açamaz (yönetici yetkisi)',
  () => sorgu(`select public.admin_pazarlama_push_kapisi_guncelle('onaylandi', $1, 'gerekli_degil', null)`, [v2Metin]),
  'Yetkisiz');

await kimsin(ADMIN);
await hataBekle('metin sürümü olmadan açılamaz',
  () => sorgu(`select public.admin_pazarlama_push_kapisi_guncelle('onaylandi', '', 'gerekli_degil', null)`),
  'metin sürümü');
await hataBekle('İYS kararı "bilinmiyor" iken açılamaz',
  () => sorgu(`select public.admin_pazarlama_push_kapisi_guncelle('onaylandi', $1, 'bilinmiyor', null)`, [v2Metin]),
  'İYS kararı');
await postgres();
await hataBekle('DB seviyesi: onaysız açık kapı yazılamaz (CHECK)', () =>
  db.exec(`update public.pazarlama_push_kapisi set durum = 'onaylandi', metin_surumu = null, iys_karari = 'bilinmiyor'`),
  'pazarlama_push_kapisi_onay_sarti');

await kimsin(ADMIN);
const [{ j: acilan }] = await kapiAc('Avukat görüşü alındı (test)', v2Metin, 'gerekli_degil');
ok('yönetici kararı ile kapı açılır', acilan.durum === 'onaylandi' && acilan.metin_surumu === v2Metin);
await kimsin(null, 'anon');
ok('kapı açık + onaylı sürüm: kayıt formunda push kutusu görünür',
  (await sorgu(`select public.iletisim_push_kullanilabilir($1) as b`, [v2Metin]))[0].b === true);
ok('onaylı olmayan metin sürümü için kutu görünmez',
  (await sorgu(`select public.iletisim_push_kullanilabilir('hupolingo-ticari-ileti-2026-10-v1') as b`))[0].b === false);

await postgres();
await db.exec(`update public.iletisim_ayarlari set haftalik_limit = 20`);
const kAcik = await kampanya('Kapı açık', segPlan);
await dagit();
const kAcikKutu = await kutu(kAcik);
const alicilar = kAcikKutu.map((x) => x.alici_id).sort();
const beklenen = [V1_ID, KULLANICI_K.veliPushAcik].sort();
ok('kapı açılınca kampanya dağıtılır: yalnız push izni veren veliler (V2 ve çocuk hariç)',
  (await durumu(kAcik)).durum === 'gonderildi' && JSON.stringify(alicilar) === JSON.stringify(beklenen),
  JSON.stringify(alicilar));

await kimsin(S1);
ok('çocuk hesabı ön izin gösterimi alamaz (veli onayı yok → false)',
  (await sorgu(`select public.push_on_izin_baslat() as b`))[0].b === false);

// Küçük hücre kuralı (10'dan az gösterimde sayı dönmez) için hacmi yükselt; deltalar bu tabanın üstünde ölçülür.
await postgres();
await db.exec(`insert into public.push_on_izin_gunluk (gun, sonuc, adet)
               values ((now() at time zone 'Europe/Istanbul')::date, 'gosterildi', 20)
               on conflict (gun, sonuc) do update set adet = public.push_on_izin_gunluk.adet + 20`);
await kimsin(ADMIN);
const o0 = await ozet(1);
ok('hacim eşiğin üstündeyken sayılar döner', o0.yetersiz_veri === false && typeof o0.gosterildi === 'number', JSON.stringify(o0));
await kimsin(V1);
const t1 = (await sorgu(`select public.push_on_izin_baslat() as b`))[0].b;
const t2 = (await sorgu(`select public.push_on_izin_baslat() as b`))[0].b;
const t3 = (await sorgu(`select public.push_on_izin_baslat() as b`))[0].b;
ok('14 günde en fazla 2 gösterim: ilk iki true, üçüncüsü false', t1 === true && t2 === true && t3 === false,
  `${t1} ${t2} ${t3}`);

await kimsin(V1);
await sorgu(`select public.push_on_izin_bildir('evet')`);
await kimsin(V2);
await sorgu(`select public.push_on_izin_bildir('ertele')`);
await kimsin(V1);
await sorgu(`select public.push_on_izin_bildir('sistem_verildi')`);
await kimsin(ADMIN);
const o1 = await ozet(1);
ok('ölçüm: gösterim +2, evet +1, ertele +1, sistem verildi +1 (kimliksiz toplam)',
  o1.gosterildi - o0.gosterildi === 2 && o1.evet - o0.evet === 1 && o1.ertele - o0.ertele === 1
    && o1.sistem_verildi - o0.sistem_verildi === 1,
  JSON.stringify({ o0, o1 }));
ok('oranlar tutarlı: evet_orani = evet / gösterim',
  o1.evet_orani === Math.round((1000 * o1.evet) / o1.gosterildi) / 10, JSON.stringify(o1));

await kimsin(V1);
await hataBekle('geçersiz ön izin sonucu reddedilir', () => sorgu(`select public.push_on_izin_bildir('kabul')`), 'Geçersiz ön izin');
await kimsin(ADMIN);
await hataBekle('veli ölçüm özetini göremez', async () => { await kimsin(V1); await sorgu(`select public.admin_push_on_izin_ozeti(1)`); }, 'Yetkisiz');
await kimsin(null, 'anon');
await hataBekle('anonim kullanıcı ön izin sayacını çağıramaz', () => sorgu(`select public.push_on_izin_baslat()`), 'permission denied');

await postgres();
await db.exec(`update public.push_on_izin_durumu set pencere_baslangic = now() - interval '15 days' where user_id = '${V1_ID}'`);
await kimsin(V1);
ok('14 gün geçince pencere sıfırlanır: yeniden gösterilebilir',
  (await sorgu(`select public.push_on_izin_baslat() as b`))[0].b === true);

// Küçük hücre: bugünkü gösterim sayısı 3'e indirilince özet sayıları gizler
await postgres();
await db.exec(`update public.push_on_izin_gunluk set adet = 3
               where gun = (now() at time zone 'Europe/Istanbul')::date and sonuc = 'gosterildi'`);
await kimsin(ADMIN);
const az = await ozet(1);
ok('10\'dan az gösterimde sayılar ve oranlar gizlenir (yetersiz_veri)',
  az.yetersiz_veri === true && az.gosterildi === null && az.evet === null && az.evet_orani === null, JSON.stringify(az));
await postgres();
await db.exec(`update public.push_on_izin_gunluk set adet = 25
               where gun = (now() at time zone 'Europe/Istanbul')::date and sonuc = 'gosterildi'`);

await kimsin(ADMIN);
await kapiKapat();
await kimsin(null, 'anon');
ok('kapı tekrar kapanınca kayıt formu kutusu gizlenir',
  (await sorgu(`select public.iletisim_push_kullanilabilir($1) as b`, [v2Metin]))[0].b === false);
await kimsin(ADMIN);
await kapiAc('Yeniden açıldı (test)', v2Metin, 'gerekli_kayit_tamam');
await kimsin(ADMIN);
const [{ j: son }] = await sorgu(`select public.admin_pazarlama_push_kapisi_getir() as j`);
ok('İYS kararı "gerekli_kayit_tamam" olarak saklanır', son.iys_karari === 'gerekli_kayit_tamam');

console.log('\n== M: cihaz → kuyruk → push_targets → Edge Function sözleşmesi (send-push/logic.ts) ==');
const { parseWebhookPayload, buildFcmMessage } = await import('../../functions/send-push/logic.ts');
const JETON = `fcm-test-jeton-${'x'.repeat(40)}`;
await kimsin(V1);
await sorgu(`select public.register_device_token($1, 'android')`, [JETON]);
await postgres();
const [{ id: bildirimM }] = await sorgu(
  `insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
   values ($1, 'rozet', 'Yeni rozet!', 'Tebrikler, rozet kazandın.', 'bell') returning id`, [V1]);
const [kuyruk] = await sorgu(
  `select id, notification_id, status from public.push_outbox where notification_id = $1`, [bildirimM]);
ok('cihazı ve push izni olan veliye kuyruk satırı düşer (pending)', !!kuyruk && kuyruk.status === 'pending', JSON.stringify(kuyruk));

const hedefler = await sorgu(`select * from public.push_targets($1)`, [bildirimM]);
ok('push_targets: cihaz jetonu, platform ve başlık/mesaj döner',
  hedefler.length === 1 && hedefler[0].token === JETON && hedefler[0].platform === 'android' && hedefler[0].baslik === 'Yeni rozet!',
  JSON.stringify(hedefler));

const webhook = parseWebhookPayload({
  type: 'INSERT', table: 'push_outbox', record: { id: kuyruk.id, notification_id: kuyruk.notification_id },
});
ok('gerçek outbox satırı webhook gövdesi olarak edge parser tarafından kabul edilir', webhook.outboxId === kuyruk.id);

const fcm = buildFcmMessage(hedefler[0]);
ok('FCM mesajı: jeton, başlık, route ve bildirim kimliği taşır',
  fcm.message.token === JETON && fcm.message.notification.title === 'Yeni rozet!'
    && fcm.message.data.route === 'notifications' && fcm.message.data.notification_id === bildirimM);
ok('FCM mesajında kullanıcı kimliği (PII) yok', !JSON.stringify(fcm).includes(V1));

await db.exec(`update public.push_preferences set quiet_start = '00:00', quiet_end = '23:59:59' where user_id = '${V1}'`);
ok('gönderim anında sessiz saat: push_targets boş (edge fonksiyonu tekrar kontrol eder)',
  (await sorgu(`select * from public.push_targets($1)`, [bildirimM])).length === 0);
await db.exec(`update public.push_preferences set quiet_start = '00:00', quiet_end = '00:00' where user_id = '${V1}'`);

await kimsin(V1);
await sorgu(`select public.unregister_device_token($1)`, [JETON]);
await postgres();
ok('jeton silinince hedef kalmaz', (await sorgu(`select * from public.push_targets($1)`, [bildirimM])).length === 0);

const [{ id: cocukM }] = await sorgu(
  `insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
   values ($1, 'rozet', 'Çocuk rozeti', 'Test', 'bell') returning id`, [S1]);
ok('velinin onayı olmayan çocuğa push kuyruğu oluşmaz', (await sorgu(
  `select 1 from public.push_outbox where notification_id = $1`, [cocukM])).length === 0);

console.log('\n== N: segmentli bildirim: kanal ve kapı kontrolü (20261044) ==');
await postgres();
await kimsin(ADMIN);
await kapiKapat();
await postgres();
await db.exec(`update public.iletisim_ayarlari set haftalik_limit = 20, sessiz_baslangic = '00:00', sessiz_bitis = '00:00'`);
const segN = async (ad, kriter) => (await sorgu(
  `insert into public.segmentler (ad, kriterler) values ($1, $2::jsonb) returning id`, [ad, JSON.stringify(kriter)]))[0].id;
const segIzinli = await segN('N: izinli veli', { veli_idleri: [V1] });
const segIzinsiz = await segN('N: izinsiz veli', { veli_idleri: [V2] });
const segSadeceOgrenci = await segN('N: yalnız öğrenci', { veli_idleri: [S1] });
const yarin = new Date(Date.now() + 86400000).toISOString();

await kimsin(ADMIN);
await hataBekle('kanal e-posta olarak kaydedilemez',
  () => sorgu(`select public.admin_kampanya_kaydet(null, 'E-posta', 'eposta', $1, 'Başlık', 'Mesaj')`, [segIzinli]),
  'Yalnızca push');
const [{ id: n1 }] = await sorgu(
  `select public.admin_kampanya_kaydet(null, 'N kampanya', 'push', $1, 'Yeni fırsat', 'Hupo ile bu hafta bir adım daha!') as id`, [segIzinli]);
ok('push kanallı taslak kaydedilir', !!n1);

const [{ j: nOn1 }] = await sorgu(`select public.admin_kampanya_on_kontrol($1, $2) as j`, [n1, yarin]);
ok('ön kontrol kapı kapalıyken de çalışır: kapi_acik=false, kanal_dagitilir=true, gönderilecek 1',
  nOn1.kapi_acik === false && nOn1.kanal_dagitilir === true && nOn1.gonderilecek === 1, JSON.stringify(nOn1));

await hataBekle('kapı kapalıyken planlama reddedilir', () => sorgu(`select public.admin_kampanya_planla($1)`, [n1]), 'kapısı kapalı');
await postgres();
ok('reddedilen planlama kampanyayı kontrol_edildi durumunda bırakır',
  (await sorgu(`select durum from public.iletisim_kampanyalari where id = $1`, [n1]))[0].durum === 'kontrol_edildi');

await postgres();
const [{ id: nEposta }] = await sorgu(
  `insert into public.iletisim_kampanyalari (ad, kanal, segment_id, baslik, mesaj)
   values ('Eski e-posta', 'eposta', $1, 'B', 'M') returning id`, [segIzinli]);
await kimsin(ADMIN);
await sorgu(`select public.admin_kampanya_on_kontrol($1, $2)`, [nEposta, yarin]);
await hataBekle('eski e-posta taslağı planlanamaz (kanal kontrolü)',
  () => sorgu(`select public.admin_kampanya_planla($1)`, [nEposta]), 'Yalnızca push');

const [{ j: nOn2 }] = await sorgu(
  `select public.admin_kampanya_on_kontrol($1, $2) as j`,
  [(await sorgu(`select public.admin_kampanya_kaydet(null, 'N izinsiz', 'push', $1, 'B', 'M') as id`, [segIzinsiz]))[0].id, yarin]);
ok('izinsiz tek veli: hedef 1, izinli 0, gönderilecek 0', nOn2.hedef === 1 && nOn2.izinli === 0 && nOn2.gonderilecek === 0, JSON.stringify(nOn2));

const [{ j: nOn3 }] = await sorgu(
  `select public.admin_kampanya_on_kontrol($1, $2) as j`,
  [(await sorgu(`select public.admin_kampanya_kaydet(null, 'N öğrenci', 'push', $1, 'B', 'M') as id`, [segSadeceOgrenci]))[0].id, yarin]);
ok('öğrenci hesabı hedef listesine girmez (hedef 0)', nOn3.hedef === 0 && nOn3.gonderilecek === 0, JSON.stringify(nOn3));

await kimsin(null, 'anon');
await hataBekle('anonim kullanıcı planlayamaz', () => sorgu(`select public.admin_kampanya_planla($1)`, [n1]), 'permission denied');

await kimsin(ADMIN);
await sorgu(`select public.admin_pazarlama_push_kapisi_guncelle('onaylandi', 'hupolingo-ticari-ileti-2026-10-v2', 'gerekli_kayit_tamam', 'N testi: kapı açık')`);
await kimsin(ADMIN);
await sorgu(`select public.admin_kampanya_planla($1)`, [n1]);
await postgres();
const [{ durum: dPlan }] = await sorgu(`select durum from public.iletisim_kampanyalari where id = $1`, [n1]);
ok('kapı açılınca planlama başarılı → planlandi', dPlan === 'planlandi', dPlan);

await postgres();
await db.exec(`update public.iletisim_kampanyalari set planlanan_at = now() - interval '1 minute' where id = '${n1}'`);
const dn = await dagit();
const dN = await durumu(n1);
const nKutu = await kutu(n1);
ok('dağıtım: yalnız izinli veli alır, durum gonderildi, alici_sayisi onkontrol içinde',
  dn === 1 && nKutu.length === 1 && nKutu[0].alici_id === V1 && dN.durum === 'gonderildi' && dN.onkontrol.alici_sayisi === 1,
  JSON.stringify({ dn, dN, nKutu }));

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
