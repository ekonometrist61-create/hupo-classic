// Growth saklama temizliği: gerçek migration zinciri PGlite (WASM Postgres) üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: stubs (growth_journey ile ortak) → 20261014 (growth core) → 20261066 (kullanım süresi)
//         → 20261109 (saklama). Süreler HUKUK ONAYI BEKLİYOR.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../growth_journey/stubs.sql');
const CEKIRDEK = '20261014000000_growth_crm_core.sql';
const KULLANIM = '20261066000000_kullanim_suresi.sql';
const YENI = '20261109000000_growth_saklama.sql';

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
const kur = async (ad, fn) => {
  try { await fn(); }
  catch (e) { console.log(`HATA [${ad}]: ${e.message}`); process.exit(1); }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const kimsin = (rol) => db.exec(`reset role; set role ${rol};`);
const postgres = () => db.exec('reset role;');

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const H1 = id(1);

// Olay ekle: ad = test etiketi; gun = kaç gün önce (0 = şimdi).
const olay = (ad, kaynak, hane, anon, gun) => db.exec(`
  insert into public.growth_events (event_name, source, household_id, anonymous_id, occurred_at)
  values ('${ad}', '${kaynak}', ${hane ? `'${hane}'` : 'null'}, ${anon ? `'${anon}'` : 'null'},
          now() - interval '${gun} days');`);

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
await kur('growth core', () => db.exec(oku(CEKIRDEK)));
await kur('kullanim suresi', () => db.exec(oku(KULLANIM)));
await kur('saklama', () => db.exec(oku(YENI)));
ok('migration zinciri hatasız (core → kullanım süresi → saklama)', true);

await postgres();
await db.exec(`
  insert into public.growth_households (id, parent_name, email) values ('${H1}', 'Test Veli', 'h1@test.local');
  insert into public.growth_identity_links (anonymous_id, household_id) values ('vid-link-0001', '${H1}');
`);
await olay('web_500_bagli', 'web', H1, 'vid-bagli-0001', 500);      // 400 günü aşar → silinir
await olay('web_200_anonim', 'web', null, 'vid-anon-0001', 200);    // bağsız, 180 günü aşar → silinir
await olay('web_200_bagli_null', 'web', null, 'vid-link-0001', 200); // kimlik bağı var → kalır (400 gün içinde)
await olay('web_150_anonim', 'web', null, 'vid-yeni-0001', 150);    // bağsız ama 180 günden yeni → kalır
await olay('web_399_bagli', 'web', H1, 'vid-bagli-0001', 399);      // 400 gün içinde → kalır
await olay('crm_hane_kopuk', 'crm', null, null, 0);                 // anonimleştirilmiş → anında silinir
await olay('server_hane_kopuk', 'server', null, null, 5);           // anonimleştirilmiş → anında silinir
await olay('crm_bagli', 'crm', H1, null, 0);                        // bağlı → kalır
await olay('app_anonim', 'app', null, 'vid-app-0001', 0);           // app: bilerek dışarıda → kalır
await db.exec(`
  insert into public.kullanim_olaylari (yuzey, ekran, sure_sn, baslangic, oturum_anahtari, rol, created_at) values
    ('site', '/', 30, now() - interval '450 days', 'oturum-eski-0000000001', 'ziyaretci', now() - interval '450 days'),
    ('site', '/', 30, now() - interval '350 days', 'oturum-orta-0000000001', 'ziyaretci', now() - interval '350 days'),
    ('site', '/', 30, now(), 'oturum-yeni-00000000001', 'ziyaretci', now());
`);
const [{ n: onceOlay }] = await sorgu(`select count(*)::int as n from public.growth_events`);
ok('kurulum: 9 olay eklendi', onceOlay === 9, `satır ${onceOlay}`);

console.log('\n== A: yetki (service_role çalıştırır; anon ve authenticated çalıştıramaz) ==');
const yetki = (await sorgu(`select
    has_function_privilege('anon', 'public.growth_saklama_temizle()', 'EXECUTE') as anon_calistir,
    has_function_privilege('authenticated', 'public.growth_saklama_temizle()', 'EXECUTE') as auth_calistir,
    has_function_privilege('service_role', 'public.growth_saklama_temizle()', 'EXECUTE') as svc_calistir`))[0];
ok('yetki tablosu: anon ve authenticated çalıştıramaz', !yetki.anon_calistir && !yetki.auth_calistir, JSON.stringify(yetki));
ok('yetki tablosu: service_role çalıştırabilir', yetki.svc_calistir === true, JSON.stringify(yetki));

await kimsin('anon');
await hataBekle('anon temizliği çağıramaz', () => sorgu(`select public.growth_saklama_temizle()`), 'permission denied');
await kimsin('authenticated');
await hataBekle('authenticated temizliği çağıramaz', () => sorgu(`select public.growth_saklama_temizle()`), 'permission denied');
await postgres();

console.log('\n== B: temizlik (service_role) ==');
await kimsin('service_role');
const [{ r: r1 }] = await sorgu(`select public.growth_saklama_temizle() as r`);
await postgres();
ok('dönüş: web_eski=1, anonim_eski=1, hane_kopuk=2, kullanim_eski=1',
  r1.web_eski === 1 && r1.anonim_eski === 1 && r1.hane_kopuk === 2 && r1.kullanim_eski === 1, JSON.stringify(r1));

const kalan = (await sorgu(`select event_name from public.growth_events order by event_name`)).map((x) => x.event_name);
const beklenenKalan = ['app_anonim', 'crm_bagli', 'web_150_anonim', 'web_200_bagli_null', 'web_399_bagli'];
ok('kalan olaylar beklenenle aynı (silinen 4: 500 gün, 200 gün bağsız, iki hane kopuk)',
  JSON.stringify(kalan) === JSON.stringify(beklenenKalan), JSON.stringify(kalan));

const kullanimKalan = await sorgu(`select count(*)::int as n from public.kullanim_olaylari`);
ok('kullanim_olaylari: 450 günlük satır silindi, 350 ve yeni kalır', kullanimKalan[0].n === 2, JSON.stringify(kullanimKalan));

console.log('\n== C: yeniden çalıştırma ve migration tekrarı ==');
await kimsin('service_role');
const [{ r: r2 }] = await sorgu(`select public.growth_saklama_temizle() as r`);
await postgres();
ok('ikinci çalıştırma hiçbir şey silmez (tüm sayaçlar 0)',
  r2.web_eski === 0 && r2.anonim_eski === 0 && r2.hane_kopuk === 0 && r2.kullanim_eski === 0, JSON.stringify(r2));
await kur('saklama (tekrar)', () => db.exec(oku(YENI)));
ok('migration ikinci kez hatasız çalışır (idempotent)', true);

console.log('\n== D: zamanlayıcı ==');
// PGlite'ta pg_cron yok: dosya işi atlar ve hata vermez. Zamanlayıcı kurulumu gerçek
// Supabase'de (pg_cron açıkken) doğrulanır.
const [{ n: cronAdet }] = await sorgu(`select count(*)::int as n from cron.job where jobname = 'growth_saklama_temizle'`);
ok('pg_cron yokken iş atlanır (hata yok, cron.job satırı yok)', cronAdet === 0, `iş ${cronAdet}`);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
