// Anket D2 (tüketim), D4 (yönetim RPC'leri) ve duyuru sayfalama testi. PGlite, Docker gerekmez.
//
// Kullanım:  node test.mjs
// Zincir:    kelime_evreni/stubs.sql → arsiv/stubs_arsiv.sql → 20261007000030, 26, 29, 30, 32, 39
//            → 20261158 (D1) → 20261161 (D2) → 20261162 (D4) → 20261163 (duyuru sayfalama) → senaryolar
// Gerçek migration dosyaları çalışır; Supabase bağımlılıkları stubs ile taklit edilir.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '..', '..', '..');
const kelime = path.resolve(here, '..', 'kelime_evreni');
const arsiv = path.resolve(here, '..', 'arsiv');

const require = createRequire(path.join(kelime, 'package.json'));
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite')).href);

const mig = (n) => path.join(repo, 'supabase/migrations', n);
const oku = (p) => fs.readFileSync(p, 'utf8');

const db = new PGlite();
const sonuclar = [];

async function t(ad, f) {
  try {
    const r = await f();
    sonuclar.push({ ad, ok: r === true, detay: r === true ? '' : String(r) });
  } catch (e) {
    sonuclar.push({ ad, ok: false, detay: `${e.code ?? ''} ${e.message}` });
  }
}

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const ADMIN = id(1), V1 = id(2), V2 = id(3), V3 = id(4), OGR = id(5);

// Oturum taklidi: auth.uid() = uid (superuser; security definer fonksiyonlar çalışır).
async function kimsin(uid) {
  await db.query(`select set_config('request.jwt.claims', $1, false)`, [uid ? JSON.stringify({ sub: uid }) : '']);
}
const rpc = async (sql, params = []) => (await db.query(sql, params)).rows[0];
async function hataKodu(sql, params = []) {
  try {
    await db.query(sql, params);
    return null;
  } catch (e) {
    return String(e.code ?? e.message);
  }
}
const sayi = async (sql, params = []) => Number((await db.query(sql, params)).rows[0].n);

const S3 = JSON.stringify([
  { id: 'q1', tur: 'csat', baslik: 'Memnun musunuz?' },
  { id: 'q2', tur: 'tek_secim', baslik: 'En çok neyi seviyorsunuz?', secenekler: ['a', 'b'] },
  { id: 'q3', tur: 'kisa_metin', baslik: 'Öneriniz?' },
]);
const soruDizisi = (n) => JSON.stringify(Array.from({ length: n }, (_, i) => ({ id: `s${i + 1}`, tur: 'kisa_metin', baslik: `Soru ${i + 1}?` })));

// --- Kurulum ---
await db.exec(oku(path.join(kelime, 'stubs.sql')));
await db.exec(oku(path.join(arsiv, 'stubs_arsiv.sql')));
for (const n of [
  '20261007000030_anket_otomasyon_analitik_ve_mutabakat.sql',
  '20261026000000_site_duyurulari.sql',
  '20261029000000_anket_yuzeyler.sql',
  '20261030000000_duyuru_yuzeyler.sql',
  '20261032000000_duyuru_anket_arsiv_ve_sil.sql',
  '20261039000000_anket_yuzey_web_sitesi_kaldir.sql',
  '20261158000000_anket_d1_surum_guvence.sql',
  '20261161000000_anket_d2_tuketim.sql',
  '20261162000000_anket_d4_yonetim.sql',
  '20261163000000_duyuru_liste_sayfalama.sql',
]) {
  await db.exec(oku(mig(n)));
}
sonuclar.push({ ad: 'D1+D2+D4+duyuru migrasyon zinciri hatasız', ok: true, detay: '' });

for (const [uid, rol] of [[ADMIN, 'admin'], [V1, 'veli'], [V2, 'veli'], [V3, 'veli'], [OGR, 'ogrenci']]) {
  await db.query(`insert into auth.users (id, email) values ($1, $2)`, [uid, `${uid}@test.local`]);
  await db.query(`insert into public.profiles (id, role) values ($1, $2)`, [uid, rol]);
}

// Anket A: admin oluşturur ve yayınlar (D4 yayın RPC'siyle)
await kimsin(ADMIN);
const A = (await rpc(`select public.admin_anket_kaydet(null, 'Anket A', false, $1::jsonb, 30, array['veli_paneli','mobil']) id`, [S3])).id;

// ---------- D4 önce: yayın kontrol listesi ve yayınlama ----------
await t('D4: kontrol listesi hazır (3 soru, yüzey var)', async () => {
  const r = (await rpc(`select public.admin_anket_yayin_kontrol($1) r`, [A])).r;
  return (r.hazir === true && r.soru_sayisi === 3 && r.maddeler.some((m) => m.kod === 'riza_surumu' && m.tamam === null)) || JSON.stringify(r);
});

await t('D4: 8 soruluk taslak için kontrol listesi hazır değil, yayınla 23514', async () => {
  const x = (await rpc(`select public.admin_anket_kaydet(null, 'Çok uzun', false, $1::jsonb) id`, [soruDizisi(8)])).id;
  const r = (await rpc(`select public.admin_anket_yayin_kontrol($1) r`, [x])).r;
  const k = await hataKodu(`select public.admin_anket_yayinla($1)`, [x]);
  return (r.hazir === false && k === '23514') || `hazir=${r.hazir} kod=${k}`;
});

await t('D4: sert tavan trigger: 8 soruyla doğrudan yayına alma 23514', async () => {
  const x = (await rpc(`select id from public.anketler where ad = 'Çok uzun'`)).id;
  const k = await hataKodu(`update public.anketler set durum = 'yayinda' where id = $1`, [x]);
  return k === '23514' || `kod=${k}`;
});

await t('D4: veli yayınla çağıramaz (42501)', async () => {
  await kimsin(V1);
  const k = await hataKodu(`select public.admin_anket_yayinla($1)`, [A]);
  await kimsin(ADMIN);
  return k === '42501' || `kod=${k}`;
});

await t('D4: yayınla A -> yayında, 1. sürüm anlık görüntüsü', async () => {
  const r = (await rpc(`select public.admin_anket_yayinla($1) r`, [A])).r;
  const d = await rpc(`select durum from public.anketler where id = $1`, [A]);
  const n = await sayi(`select count(*) n from public.anket_surumleri where anket_id = $1 and surum = 1`, [A]);
  return (d.durum === 'yayinda' && n === 1 && r.kapanan_anket_id === null) || JSON.stringify({ d, n, r });
});

// ---------- D2 ----------
await t('D2: öğrenci hesabı kart alamaz (42501)', async () => {
  await kimsin(OGR);
  const k = await hataKodu(`select public.anket_siradaki_kart('mobil')`);
  await kimsin(V1);
  return k === '42501' || `kod=${k}`;
});

await kimsin(V1);
await t('D2: web_sitesi yüzeyi geçersiz (22023)', async () => {
  const k = await hataKodu(`select public.anket_siradaki_kart('web_sitesi', time '12:00')`);
  return k === '22023' || `kod=${k}`;
});

await t('D2: sessiz saatte (23:00, 07:59) kart yok ve bütçe harcanmaz', async () => {
  const a = (await rpc(`select public.anket_siradaki_kart('mobil', time '23:00') r`)).r;
  const b = (await rpc(`select public.anket_siradaki_kart('mobil', time '07:59') r`)).r;
  const n = await sayi(`select count(*) n from public.etkilesim_butcesi where veli_id = $1`, [V1]);
  const g = await sayi(`select count(*) n from public.anket_gosterimleri where veli_id = $1`, [V1]);
  return (a === null && b === null && n === 0 && g === 0) || JSON.stringify({ a, b, n, g });
});

await t('D2: sınır saatleri: 08:00 ve 21:59 kart verir (V3 ile, sonra geri alınır)', async () => {
  await kimsin(V3);
  const a = (await rpc(`select public.anket_siradaki_kart('mobil', time '08:00') r`)).r;
  await db.query(`delete from public.anket_gosterimleri where veli_id = $1`, [V3]);
  await db.query(`delete from public.etkilesim_butcesi where veli_id = $1`, [V3]);
  const b = (await rpc(`select public.anket_siradaki_kart('mobil', time '21:59') r`)).r;
  await db.query(`delete from public.anket_gosterimleri where veli_id = $1`, [V3]);
  await db.query(`delete from public.etkilesim_butcesi where veli_id = $1`, [V3]);
  const c = (await rpc(`select public.anket_siradaki_kart('mobil', time '22:00') r`)).r;
  await kimsin(V1);
  return (a?.id === A && b?.id === A && c === null) || JSON.stringify({ a: a?.id, b: b?.id, c });
});

await t('D2: gündüz kart gelir: 3 soru, süre 1 dk, 1 gösterim, bütçe 1', async () => {
  const r = (await rpc(`select public.anket_siradaki_kart('veli_paneli', time '12:00') r`)).r;
  const g = await sayi(`select count(*) n from public.anket_gosterimleri where veli_id = $1 and olay = 'gosterildi'`, [V1]);
  const b = await sayi(`select coalesce(sum(sayi),0) n from public.etkilesim_butcesi where veli_id = $1 and kanal = 'anket'`, [V1]);
  return (r && r.id === A && r.soru_sayisi === 3 && r.sure_dk === 1 && g === 1 && b === 1) || JSON.stringify({ r: r && r.id, g, b });
});

await t('D2: aynı kart yenilemede bütçeyi yeniden harcamaz', async () => {
  const r = (await rpc(`select public.anket_siradaki_kart('veli_paneli', time '13:00') r`)).r;
  const g = await sayi(`select count(*) n from public.anket_gosterimleri where veli_id = $1 and olay = 'gosterildi'`, [V1]);
  const b = await sayi(`select coalesce(sum(sayi),0) n from public.etkilesim_butcesi where veli_id = $1`, [V1]);
  return (r?.id === A && g === 1 && b === 1) || JSON.stringify({ g, b });
});

await t('D2: anketin yüzeyinde olmayan mecrada (web_app) kart yok', async () => {
  const r = (await rpc(`select public.anket_siradaki_kart('web_app', time '12:00') r`)).r;
  return r === null || JSON.stringify(r);
});

await t('D2: başka veli (V2) kendi sayacıyla kart alır', async () => {
  await kimsin(V2);
  const r = (await rpc(`select public.anket_siradaki_kart('mobil', time '12:00') r`)).r;
  await kimsin(V1);
  return r?.id === A || JSON.stringify(r);
});

await t('D2: atlama takvimi yardımcısı 3/14/90/90 gün', async () => {
  const r = (await db.query(
    `select (public._anket_atlama_bekleme(0))::text s0, (public._anket_atlama_bekleme(1))::text s1,
            (public._anket_atlama_bekleme(2))::text s2, (public._anket_atlama_bekleme(3))::text s3,
            (public._anket_atlama_bekleme(9))::text s9`)).rows[0];
  return (r.s0 === '00:00:00' && r.s1 === '3 days' && r.s2 === '14 days' && r.s3 === '90 days' && r.s9 === '90 days') || JSON.stringify(r);
});

await t('D2: 1. atlama 3 gün sonra; ikinci kapatma sayılmaz', async () => {
  const r1 = (await rpc(`select public.anket_kart_atla($1, 'veli_paneli') r`, [A])).r;
  const r2 = (await rpc(`select public.anket_kart_atla($1, 'veli_paneli') r`, [A])).r;
  const gun = Math.round((new Date(r1.sonraki_gosterim) - Date.now()) / 864e5);
  return (r1.atlama_sayisi === 1 && r2.atlama_sayisi === 1 && gun === 3) || JSON.stringify({ r1, r2, gun });
});

await t('D2: atlama sonrası kart yok (bekleme)', async () => {
  const r = (await rpc(`select public.anket_siradaki_kart('veli_paneli', time '12:00') r`)).r;
  return r === null || 'kart döndü';
});

// 4 gün geriye al: bekleme (3 gün) ve 24 saat bütçe penceresi dolar
const geriAl = async (veli, gun) => {
  await db.query(`update public.anket_gosterimleri set created_at = created_at - make_interval(days => $2) where veli_id = $1`, [veli, gun]);
  await db.query(`delete from public.etkilesim_butcesi where veli_id = $1`, [veli]);
};

await t('D2: 3 gün sonra kart yeniden gelir; 2. atlama 14 gün', async () => {
  await geriAl(V1, 4);
  const k = (await rpc(`select public.anket_siradaki_kart('veli_paneli', time '12:00') r`)).r;
  const r = (await rpc(`select public.anket_kart_atla($1, 'veli_paneli') r`, [A])).r;
  const gun = Math.round((new Date(r.sonraki_gosterim) - Date.now()) / 864e5);
  return (k?.id === A && r.atlama_sayisi === 2 && gun === 14) || JSON.stringify({ k: k?.id, r, gun });
});

await t('D2: 14 gün dolmadan (10 gün) kart yok, 15 gün sonra gelir; 3. atlama 90 gün', async () => {
  await geriAl(V1, 10);
  const yok = (await rpc(`select public.anket_siradaki_kart('veli_paneli', time '12:00') r`)).r;
  await geriAl(V1, 6);
  const var_ = (await rpc(`select public.anket_siradaki_kart('veli_paneli', time '12:00') r`)).r;
  const r = (await rpc(`select public.anket_kart_atla($1, 'veli_paneli') r`, [A])).r;
  const gun = Math.round((new Date(r.sonraki_gosterim) - Date.now()) / 864e5);
  return (yok === null && var_?.id === A && r.atlama_sayisi === 3 && gun === 90) || JSON.stringify({ yok, v: var_?.id, r, gun });
});

await t('D2: 4. atlama da 90 gün (sayaç sıfırlanmaz)', async () => {
  await geriAl(V1, 91);
  await rpc(`select public.anket_siradaki_kart('veli_paneli', time '12:00') r`);
  const r = (await rpc(`select public.anket_kart_atla($1, 'veli_paneli') r`, [A])).r;
  const gun = Math.round((new Date(r.sonraki_gosterim) - Date.now()) / 864e5);
  return (r.atlama_sayisi === 4 && gun === 90) || JSON.stringify({ r, gun });
});

await t('D2: gösterilmemiş karta atla çağrısı sayaç artırmaz', async () => {
  await kimsin(V3);
  const r = (await rpc(`select public.anket_kart_atla($1, 'mobil') r`, [A])).r;
  await kimsin(V1);
  return (r.atlama_sayisi === 0 && r.sonraki_gosterim === null) || JSON.stringify(r);
});

await t('D2: yanıt gönderilince tamamlandi kaydı ve kart bir daha gelmez', async () => {
  await kimsin(V2);
  await db.query(`select public.anket_yanit_gonder($1, '{"q1":5}'::jsonb, 'mobil')`, [A]);
  const n = await sayi(`select count(*) n from public.anket_gosterimleri where veli_id = $1 and olay = 'tamamlandi' and yuzey = 'mobil'`, [V2]);
  await geriAl(V2, 2);
  const r = (await rpc(`select public.anket_siradaki_kart('mobil', time '12:00') r`)).r;
  await kimsin(V1);
  return (n === 1 && r === null) || JSON.stringify({ n, r });
});

await t('D2: ortak bütçe: bugün push harcanmışsa anket kartı yok', async () => {
  await kimsin(V3);
  await db.query(
    `insert into public.etkilesim_butcesi (veli_id, gun, kanal, sayi) values ($1, (now() at time zone 'Europe/Istanbul')::date, 'push', 1)`, [V3]);
  const r = (await rpc(`select public.anket_siradaki_kart('mobil', time '12:00') r`)).r;
  await kimsin(V1);
  return r === null || 'kart döndü';
});

await t('D2: anon D2 RPC çağıramaz, authenticated iç yardımcıyı çağıramaz (42501)', async () => {
  await db.exec(`set role anon`);
  const k1 = await hataKodu(`select public.anket_siradaki_kart('mobil')`);
  await db.exec(`reset role; set role authenticated`);
  const k2 = await hataKodu(`select public._etkilesim_butce_al(gen_random_uuid(), 'anket', 1)`);
  const k3 = await hataKodu(`select public.admin_anket_yayinla(gen_random_uuid())`);
  await db.exec(`reset role`);
  return (k1 === '42501' && k2 === '42501' && k3 === '42501') || `anon=${k1} yardimci=${k2} admin-yetkisiz=${k3}`;
});

// ---------- D4 devamı ----------
await kimsin(ADMIN);
const B = (await rpc(`select public.admin_anket_kaydet(null, 'Anket B', false, $1::jsonb, 30, array['veli_paneli']) id`, [S3])).id;

await t('D4: yayınla B (arşiv işaretli) -> A kapanır ve arşivlenir', async () => {
  const r = (await rpc(`select public.admin_anket_yayinla($1, true) r`, [B])).r;
  const a = await rpc(`select durum, arsivlendi_at is not null arsiv from public.anketler where id = $1`, [A]);
  return (r.kapanan_anket_id === A && a.durum === 'kapali' && a.arsiv === true) || JSON.stringify({ r, a });
});

await t('D4: sürüm geçmişi: B 2. sürüm (q4 eklendi, q1 metni değişti)', async () => {
  const yeni = JSON.parse(S3);
  yeni[0].baslik = 'Çok memnun musunuz?';
  yeni.push({ id: 'q4', tur: 'onay', baslik: 'Önerir misiniz?' });
  await db.query(`select public.admin_anket_kaydet($1, 'Anket B', false, $2::jsonb, 30, array['veli_paneli'])`, [B, JSON.stringify(yeni)]);
  const g = (await rpc(`select public.admin_anket_surum_gecmisi($1) r`, [B])).r;
  const s2 = g.find((x) => x.surum === 2), s1 = g.find((x) => x.surum === 1);
  return (g.length === 2 && g[0].surum === 2 && s2.soru_sayisi === 4
    && JSON.stringify(s2.eklenen) === '["q4"]' && JSON.stringify(s2.degisen) === '["q1"]'
    && JSON.stringify(s2.kaldirilan) === '[]' && s1.eklenen.length === 0) || JSON.stringify(g);
});

await t('D4: soru kütüphanesi yayımlanmış soruları verir (A ve B)', async () => {
  const k = (await rpc(`select public.admin_anket_soru_kutuphanesi() r`)).r;
  const idler = new Set(k.map((x) => x.anket_id));
  return (idler.has(A) && idler.has(B) && k.some((x) => x.soru.id === 'q4')) || JSON.stringify(k.length);
});

await t('D4: arşivdeki A kopyalanır: yeni taslak, arşivde değil, sorular aynı', async () => {
  const c = (await rpc(`select public.admin_anket_kopyala($1) id`, [A])).id;
  const r = await rpc(`select ad, durum, arsivlendi_at, sorular = (select sorular from public.anketler where id = $2) esit from public.anketler where id = $1`, [c, A]);
  return (r.ad === 'Anket A (kopya)' && r.durum === 'taslak' && r.arsivlendi_at === null && r.esit === true) || JSON.stringify(r);
});

await t('D4: yayınla C arşiv işaretsiz -> B kapanır ama arşivlenmez', async () => {
  const C = (await rpc(`select public.admin_anket_kaydet(null, 'Anket C', false, $1::jsonb, 30, array['veli_paneli']) id`, [S3])).id;
  await db.query(`select public.admin_anket_yayinla($1, false)`, [C]);
  const b = await rpc(`select durum, arsivlendi_at from public.anketler where id = $1`, [B]);
  const n = await sayi(`select count(*) n from public.anketler where durum = 'yayinda'`);
  return (b.durum === 'kapali' && b.arsivlendi_at === null && n === 1) || JSON.stringify({ b, n });
});

await t('D4: yayınlanmış anket silinemez, arşivlenmez kuralı korunur (arşiv RPC 23514)', async () => {
  const c = (await rpc(`select id from public.anketler where ad = 'Anket C'`)).id;
  const k = await hataKodu(`select public.admin_anket_arsivle($1, true)`, [c]);
  return k === '23514' || `kod=${k}`;
});

await t('D4: dışa aktarım n<5 gizli (A: 1 yanıt) ve audit yazılır', async () => {
  const r = (await rpc(`select public.admin_anket_disa_aktar($1) r`, [A])).r;
  const n = await sayi(`select count(*) n from public.admin_audit_log where islem = 'anket_disa_aktarildi'`);
  return (r.gizli === true && r.satirlar.length === 0 && n === 1) || JSON.stringify({ gizli: r.gizli, n });
});

await t('D4: dışa aktarım 5+ yanıtta kimliksiz satır verir', async () => {
  for (let i = 0; i < 5; i++) {
    await db.query(`insert into public.anket_yanitlari (anket_id, surum, veli_id, yanitlar, yuzey) values ($1, 1, $2, '{"q1":4}'::jsonb, 'mobil')`, [B, V1]);
  }
  const r = (await rpc(`select public.admin_anket_disa_aktar($1) r`, [B])).r;
  const metin = JSON.stringify(r);
  return (r.gizli === false && r.satirlar.length === 5 && !metin.includes('veli_id') && !metin.includes(V1)) || metin.slice(0, 200);
});

await t('D4: gevşek taslak kaydet/listele/ankete dönüştür/sil', async () => {
  const d = (await rpc(`select public.admin_anket_taslak_kaydet(null, 'Yarım', false, '[{"id":"x"}]'::jsonb) id`)).id;
  const l1 = (await rpc(`select jsonb_array_length(public.admin_anket_taslak_listele()) n`)).n;
  const k = await hataKodu(`select public.admin_anket_taslaktan_olustur($1)`, [d]); // geçersiz soru -> 22023
  await db.query(`select public.admin_anket_taslak_kaydet($1, 'Tamam', false, $2::jsonb)`, [d, S3]);
  const a = (await rpc(`select public.admin_anket_taslaktan_olustur($1) id`, [d])).id;
  const dur = await rpc(`select durum from public.anketler where id = $1`, [a]);
  const kalan = await sayi(`select count(*) n from public.anket_taslaklari`);
  const d2 = (await rpc(`select public.admin_anket_taslak_kaydet(null, 'Silinecek', false, '[]'::jsonb) id`)).id;
  await db.query(`select public.admin_anket_taslak_sil($1)`, [d2]);
  const kalan2 = await sayi(`select count(*) n from public.anket_taslaklari`);
  return (Number(l1) === 1 && k === '22023' && dur.durum === 'taslak' && kalan === 0 && kalan2 === 0)
    || JSON.stringify({ l1, k, dur, kalan, kalan2 });
});

// ---------- Arşiv ve yanıt koruması (TASKS §16'daki açık test) ----------
await t('arşiv: arşivlenen ve yanıtı olan anketin yanıtları korunur', async () => {
  const once = await sayi(`select count(*) n from public.anket_yanitlari where anket_id = $1`, [A]);
  const k = await hataKodu(`delete from public.anketler where id = $1`, [A]);
  const sonra = await sayi(`select count(*) n from public.anket_yanitlari where anket_id = $1`, [A]);
  const arsivli = await sayi(`select count(*) n from public.anketler where id = $1 and arsivlendi_at is not null`, [A]);
  return (once >= 1 && k === '23001' && sonra === once && arsivli === 1) || JSON.stringify({ once, k, sonra, arsivli });
});

// ---------- Duyuru sayfalama (200 sınırı) ----------
await db.query(`insert into public.duyurular (baslik, metin) select 'D' || g, 'metin' from generate_series(1, 260) g`);

await t('duyuru: varsayılan çağrı 200 kayıt (eski davranış), toplam 260', async () => {
  const r = (await rpc(`select public.admin_list_duyurular(p_arsiv => false) r`)).r;
  const top = await sayi(`select public.admin_duyuru_sayisi(false) n`);
  return (r.length === 200 && top === 260) || `n=${r.length} top=${top}`;
});

await t('duyuru: sayfalama 3. sayfa (offset 250, limit 50) 10 kayıt, çakışma yok', async () => {
  const s1 = (await rpc(`select public.admin_list_duyurular(false, 200, 0) r`)).r;
  const s2 = (await rpc(`select public.admin_list_duyurular(false, 50, 200) r`)).r;
  const s3 = (await rpc(`select public.admin_list_duyurular(false, 50, 250) r`)).r;
  const ids = new Set([...s1, ...s2].map((x) => x.id));
  return (s2.length === 50 && s3.length === 10 && ids.size === 250) || `s2=${s2.length} s3=${s3.length} benzersiz=${ids.size}`;
});

await t('duyuru: aşırı limit (5000) 1000 ile kırpılır, 260 kaydın hepsi gelir', async () => {
  const r = (await rpc(`select public.admin_list_duyurular(false, 5000, 0) r`)).r;
  return r.length === 260 || `n=${r.length}`;
});

await t('duyuru: yönetici olmayan sayfalı listeyi çağıramaz (42501)', async () => {
  await kimsin(V1);
  const k = await hataKodu(`select public.admin_list_duyurular(false, 10, 0)`);
  const k2 = await hataKodu(`select public.admin_duyuru_sayisi(false)`);
  await kimsin(ADMIN);
  return (k === '42501' && k2 === '42501') || `kod=${k}/${k2}`;
});

const gecen = sonuclar.filter((s) => s.ok).length;
for (const [i, s] of sonuclar.entries()) {
  console.log(`${String(i + 1).padStart(2)}. [${s.ok ? 'OK  ' : 'FAIL'}] ${s.ad}${!s.ok && s.detay ? `\n      detay: ${s.detay}` : ''}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuclar.length} senaryo geçti`);
process.exit(gecen === sonuclar.length ? 0 : 1);

