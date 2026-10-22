// Kullanım süresi (20261066) sınaması: PGlite, uzak veritabanına dokunmaz.
// Kullanım: node kullanim_testleri.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const oku = (p) => fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, '');
const db = new PGlite();
await db.exec(oku(path.join(here, 'stubs.sql')));
await db.exec(oku(path.resolve(here, '../../migrations/20261066000000_kullanim_suresi.sql')));

const A1 = '00000000-0000-4000-8000-00000000a001';
const O1 = '00000000-0000-4000-8000-00000000b001';
await db.exec(`insert into auth.users (id, email) values ('${A1}','a@example.test'), ('${O1}','o@example.test')`);
await db.exec(`insert into public.profiles (id, role, full_name, sinif) values ('${A1}','admin','Y',null), ('${O1}','ogrenci','O',4)`);

async function cagri(uid, sql, params = []) {
  await db.query("select set_config('request.jwt.claims', $1, false)", [uid ? JSON.stringify({ sub: uid, role: 'authenticated' }) : '']);
  await db.exec(`set role ${uid ? 'authenticated' : 'anon'}`);
  try {
    const r = await db.query(`select ${sql} as r`, params);
    return { veri: r.rows[0].r };
  } catch (e) {
    return { hata: { kod: e.code, mesaj: e.message } };
  } finally {
    await db.exec('reset role');
    await db.query("select set_config('request.jwt.claims', '', false)");
  }
}
const sonuc = [];
const k = (ad, gecti, ek = '') => { sonuc.push(!!gecti); console.log(`${gecti ? 'GEÇTİ' : 'KALDI'}  ${ad}${gecti ? '' : '  -> ' + ek}`); };

const anahtar = (i) => `oturum_anahtari_${String(i).padStart(4, '0')}`;
const olay = (o = {}) => ({ yuzey: 'mobil', ekran: '/ogrenci/ana', sure_sn: 30, baslangic: new Date(Date.now() - 60000).toISOString(), oturum_anahtari: anahtar(1), rol: 'ogrenci', ...o });
const gonder = (uid, dizi) => cagri(uid, 'public.kullanim_olaylari_gonder($1::jsonb)', [JSON.stringify(dizi)]);
const say = async () => Number((await db.query('select count(*)::int n from public.kullanim_olaylari')).rows[0].n);

try {
  // Doğrulama reddi
  const kotu = {
    'sure_sn 0': olay({ sure_sn: 0 }),
    'sure_sn 14401': olay({ sure_sn: 14401 }),
    'sure_sn kesirli': olay({ sure_sn: 1.5 }),
    'yuzey geçersiz': olay({ yuzey: 'masaustu' }),
    'rol geçersiz': olay({ rol: 'cocuk' }),
    'ekran 61 karakter': olay({ ekran: 'a'.repeat(61) }),
    'ekran sorgu içerir': olay({ ekran: '/ogrenci?id=5' }),
    'ekran boşluk/serbest metin': olay({ ekran: 'Ali ders yapıyor' }),
    'oturum anahtarı kısa': olay({ oturum_anahtari: 'kisa' }),
    'baslangic çok eski': olay({ baslangic: new Date(Date.now() - 5 * 864e5).toISOString() }),
    'baslangic gelecek': olay({ baslangic: new Date(Date.now() + 3600e3).toISOString() }),
    'alan eksik': (() => { const o = olay(); delete o.rol; return o; })(),
  };
  let hepsi = true; const ayrinti = [];
  for (const [ad, o] of Object.entries(kotu)) {
    const r = await gonder(null, [o]);
    if (!r.hata || r.hata.kod !== '22023') { hepsi = false; ayrinti.push(ad); }
  }
  k('geçersiz alanlar reddedilir (22023)', hepsi && (await say()) === 0, ayrinti.join(','));
  k('dizi olmayan girdi reddedilir', (await cagri(null, `public.kullanim_olaylari_gonder('{}'::jsonb)`)).hata?.kod === '22023');

  // Tam parti atomik: bir kötü olay hepsini düşürür
  const r1 = await gonder(null, [olay(), olay({ sure_sn: 0 })]);
  k('karışık parti tümüyle reddedilir', r1.hata && (await say()) === 0);

  // 50 limit
  const elli = Array.from({ length: 50 }, (_, i) => olay({ oturum_anahtari: anahtar(100 + i) }));
  const r50 = await gonder(null, elli);
  k('50 olay kabul edilir', r50.veri?.kabul === 50 && (await say()) === 50, JSON.stringify(r50));
  const r51 = await gonder(null, [...elli, olay()]);
  k('51 olay reddedilir', r51.hata?.kod === '22023' && (await say()) === 50);

  // Anon yazar, okuyamaz; authenticated da doğrudan okuyamaz
  const anonOku = await cagri(null, '(select count(*) from public.kullanim_olaylari)');
  const authOku = await cagri(O1, '(select count(*) from public.kullanim_olaylari)');
  k('anon ve authenticated tabloyu doğrudan okuyamaz', anonOku.hata?.kod === '42501' && authOku.hata?.kod === '42501', JSON.stringify([anonOku, authOku]));
  const authYaz = await cagri(O1, 'public.kullanim_olaylari_gonder($1::jsonb)', [JSON.stringify([olay({ oturum_anahtari: anahtar(7) })])]);
  k('authenticated RPC ile yazabilir', authYaz.veri?.kabul === 1);
  const rls = (await db.query(`select relrowsecurity from pg_class where oid = 'public.kullanim_olaylari'::regclass`)).rows[0].relrowsecurity;
  k('RLS açık', rls === true);

  // Hız sınırı: aynı oturum anahtarı dakikada 100
  const hizAnahtar = anahtar(9999);
  const grup = () => Array.from({ length: 50 }, () => olay({ oturum_anahtari: hizAnahtar }));
  const h1 = await gonder(null, grup()); const h2 = await gonder(null, grup()); const h3 = await gonder(null, [olay({ oturum_anahtari: hizAnahtar })]);
  k('hız sınırı: oturum başına dakikada 100, sonrası reddedilir (54000)', h1.veri && h2.veri && h3.hata?.kod === '54000', JSON.stringify([h1, h2, h3]));

  // Admin raporu
  await db.exec('truncate public.kullanim_olaylari');
  const rows = [];
  for (let i = 0; i < 6; i++) rows.push(olay({ oturum_anahtari: anahtar(200 + i), ekran: '/ogrenci/ana', sure_sn: 60 }));
  for (let i = 0; i < 4; i++) rows.push(olay({ oturum_anahtari: anahtar(300 + i), ekran: '/ogrenci/nadir', sure_sn: 90 }));
  for (let i = 0; i < 5; i++) rows.push(olay({ yuzey: 'site', rol: 'ziyaretci', oturum_anahtari: anahtar(400 + i), ekran: '/fiyat', sure_sn: 10 }));
  await gonder(null, rows);
  const rapor = await cagri(A1, 'public.kullanim_raporu(30)');
  const s = rapor.veri?.satirlar ?? [];
  const ana = s.find((x) => x.ekran === '/ogrenci/ana');
  k('admin raporu toplam/oturum/ortalama', ana && ana.toplam_sn === 360 && ana.oturum === 6 && Number(ana.ortalama_sn) === 60, JSON.stringify(s));
  k('5\'ten az oturumlu satır bastırılır', !s.some((x) => x.ekran === '/ogrenci/nadir') && s.some((x) => x.ekran === '/fiyat'));
  k('günlük trend döner (bastırma uygulanır)', Array.isArray(rapor.veri?.trend) && rapor.veri.trend.length === 2 && rapor.veri.trend.every((t) => t.oturum >= 5), JSON.stringify(rapor.veri?.trend));
  const filtre = await cagri(A1, `public.kullanim_raporu(30, 'site')`);
  k('yüzey filtresi', filtre.veri?.satirlar.length === 1 && filtre.veri.satirlar[0].yuzey === 'site');
  const ogrRapor = await cagri(O1, 'public.kullanim_raporu(30)');
  const anonRapor = await cagri(null, 'public.kullanim_raporu(30)');
  k('rapor yalnız admin: öğrenci 42501, anon 42501', ogrRapor.hata?.kod === '42501' && anonRapor.hata?.kod === '42501', JSON.stringify([ogrRapor, anonRapor]));

  // Temizlik 300 gün
  await db.exec('truncate public.kullanim_olaylari');
  await db.exec(`insert into public.kullanim_olaylari (yuzey, ekran, sure_sn, baslangic, oturum_anahtari, rol, created_at) values
    ('mobil','/a',10, now() - interval '301 days','${anahtar(1)}','ogrenci', now() - interval '301 days'),
    ('mobil','/b',10, now() - interval '299 days','${anahtar(2)}','ogrenci', now() - interval '299 days'),
    ('mobil','/c',10, now(),'${anahtar(3)}','ogrenci', now())`);
  const t = (await db.query('select public.kullanim_olaylari_temizle() as n')).rows[0].n;
  const kalan = (await db.query('select ekran from public.kullanim_olaylari order by ekran')).rows.map((x) => x.ekran).join(',');
  k('temizlik 300 günden eskiyi siler', t === 1 && kalan === '/b,/c', `${t} ${kalan}`);
  const tAnon = await cagri(null, 'public.kullanim_olaylari_temizle()');
  const tAuth = await cagri(A1, 'public.kullanim_olaylari_temizle()');
  k('temizlik istemciden çağrılamaz', tAnon.hata?.kod === '42501' && tAuth.hata?.kod === '42501');

  // Envanter
  const b = (await db.query(`select p.proname, p.prosecdef, has_function_privilege('anon', p.oid, 'execute') anon, p.proconfig::text cfg
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname='public' and p.proname like 'kullanim\\_%'`)).rows;
  k('RPC\'ler SECURITY DEFINER + sabit search_path', b.length === 3 && b.every((r) => r.prosecdef && /search_path=/.test(r.cfg)), JSON.stringify(b));
} catch (e) {
  console.log('BEKLENMEYEN HATA:', e.message);
  sonuc.push(false);
}
const gecen = sonuc.filter(Boolean).length;
console.log(`\nSONUÇ: ${gecen}/${sonuc.length} senaryo geçti`);
process.exit(gecen === sonuc.length && sonuc.length > 0 ? 0 : 1);