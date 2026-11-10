// Okuma Dünyası SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez; uzak veritabanına dokunmaz.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: stubs.sql → 20261003000010 (siniflar) → 20261050000000..300 (okuma_dunyasi) → gerçek paketler
//          (test_paketler tablosu) → testler.sql (pg_temp.okuma_testleri) → sonuç.
// Paket kaynağı: OKUMA_PAKET_DIZINI (varsayılan: C:\Dev\Senin Hikayen - HupoRead\atolye\cikti);
// yoksa fixtures/ içindeki kayip-defter.paket.json kullanılır.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const mig = (ad) => path.resolve(here, '../../migrations', ad);
const migrasyonlar = [
  mig('20261003000010_ogretmen_ve_siniflar.sql'),
  mig('20261050000000_okuma_dunyasi_tablolar.sql'),
  mig('20261050000100_okuma_dunyasi_yonetim.sql'),
  mig('20261050000200_okuma_dunyasi_ogrenci.sql'),
  mig('20261050000300_okuma_dunyasi_veli_ogretmen.sql'),
  path.join(here, 'stubs_export.sql'),             // export_my_data bağımlılık tabloları (yalnız test)
  // GÖR-048: kelime tabloları GERÇEK migrasyonlardan (taklit yok); üretimdeki sıra: 22 → 23 (düzeltme) → 45 → 46
  mig('20261022000000_kelime_evreni.sql'),
  mig('20261023000000_kelime_evreni_duzeltme.sql'),
  mig('20261045000000_kelime_veli_ozeti_riza_kapisi.sql'),
  mig('20261046000000_export_my_data_kelime.sql'),
  mig('20261050000400_okuma_dunyasi_sozluk.sql'),
  mig('20261050000500_export_my_data_okuma.sql'),
  mig('20261051000000_okuma_dusun_alani.sql'),
  mig('20261057000000_okuma_hikaye_fisleri.sql'),
  mig('20261058000000_okuma_paket_fis_kodu.sql'),
  mig('20261060000000_okuma_hikaye_turleri.sql'),
  mig('20261068000000_okuma_uc_goz_yayin_kurali.sql'),
  mig('20261064000000_okuma_yonetim_crud.sql'),
  mig('20261065000000_okuma_dashboard_veli_ogretmen.sql'),
  mig('20261066000000_kullanim_suresi.sql'),
  mig('20261071000000_okuma_sayfa_siniri_40.sql'),
  mig('20261075000000_okuma_anket_yildiz_istege_bagli.sql'),
  mig('20261076000000_okuma_paket_sozluk_ikon.sql'),
  // 2026-11-10: hikâye yayın kapısı yalnız insan onayı (ajan şartı kaldırıldı); testler.sql bölüm C bunu bekler
  mig('20261201000000_okuma_hikaye_insan_onayi_yeter.sql'),
];
const paketDizini = process.env.OKUMA_PAKET_DIZINI || 'C:\\Dev\\Senin Hikayen - HupoRead\\atolye\\cikti';

const db = new PGlite();

async function adim(ad, fn) {
  try {
    return await fn();
  } catch (e) {
    console.log(`HATA [${ad}]: ${e.message}`);
    if (e.position) console.log(`  konum: ${e.position}`);
    process.exit(1);
  }
}

await adim('stubs', () => db.exec(fs.readFileSync(path.join(here, 'stubs.sql'), 'utf8')));
console.log('stubs: tamam');
for (const m of migrasyonlar) {
  await adim(path.basename(m), () => db.exec(fs.readFileSync(m, 'utf8')));
  console.log(`migration: ${path.basename(m)} tamam`);
}

// GÖR-048: export_my_data SON tanımı (20261106 growth_kvkk_birlestirme) gerçek zincirin üstüne uygulanır.
// Tüm 20261106 migrasyonu growth/musteri_360 zinciri ister; yalnız export_my_data gövdesi (bölüm 9) ve
// yetki satırları dosyadan KESİLEREK yüklenir (metin elle kopyalanmaz). growth tabloları stubs_export.sql'de taklit.
const sonExportDosya = mig('20261106000000_growth_kvkk_birlestirme.sql');
const sonExportMetin = fs.readFileSync(sonExportDosya, 'utf8');
const govdeRe = /create or replace function public\.export_my_data\(\)[\s\S]*?\n\$\$;/;
const yetkiRe = /revoke execute on function public\.export_my_data\(\) from public, anon;\s*grant\s+execute on function public\.export_my_data\(\) to authenticated;/;
const sonGovde = sonExportMetin.match(govdeRe)?.[0];
const sonYetki = sonExportMetin.match(yetkiRe)?.[0];
if (!sonGovde || !sonYetki) { console.log('HATA: 20261106 export_my_data gövdesi/yetkisi bulunamadı'); process.exit(1); }
// Önceki tanım (20261050000500) ile karşılaştırma: kelime + okuma bölümleri aynen korunmalı.
const oncekiMetin = fs.readFileSync(mig('20261050000500_export_my_data_okuma.sql'), 'utf8');
const bolum = (s) => {
  const a = s.indexOf("'kelime', jsonb_build_object(");
  const b = s.indexOf("'growth', jsonb_build_object(");
  const sonu = b > 0 ? b : s.indexOf('\n  );\nend;');
  return s.slice(a, sonu).replace(/\s+/g, ' ').replace(/--[^\n]*/g, '').replace(/,\s*(--.*)?$/, '').trim();
};
const normalize = (s) => bolum(s).replace(/--.*?(?= ')/g, '').replace(/[,\s]+$/, '').replace(/\)\s*\)\s*;?$/, '').trim();
const oncekiBolum = normalize(oncekiMetin.replace(/--[^\n]*/g, ''));
const sonBolum = normalize(sonExportMetin.slice(sonExportMetin.indexOf('create or replace function public.export_my_data()')).replace(/--[^\n]*/g, ''));
const bolumKarsilastirma = oncekiBolum.length > 500 && sonBolum.startsWith(oncekiBolum.slice(0, oncekiBolum.length - 12));
console.log(`export_my_data karşılaştırma (20261050000500 → 20261106): kelime+okuma bölümleri ${bolumKarsilastirma ? 'AYNEN KORUNUYOR' : 'FARKLI'} (${oncekiBolum.length}/${sonBolum.length} karakter)`);
if (!bolumKarsilastirma) process.exit(1);
await adim('20261106-export_my_data', () => db.exec(sonGovde + '\n' + sonYetki));
console.log('migration: 20261106 export_my_data (son tanım, kesit) tamam');

// Gerçek paketler (yoksa fixture)
await db.exec('create table public.test_paketler (ad text primary key, icerik jsonb not null)');
await db.exec('revoke all on public.test_paketler from anon, authenticated');
let dizin = paketDizini;
let kaynak = 'canlı atölye çıktısı';
if (!fs.existsSync(dizin)) {
  dizin = path.join(here, 'fixtures');
  kaynak = 'fixtures (atölye dizini bulunamadı)';
}
const dosyalar = fs.readdirSync(dizin).filter((f) => f.endsWith('.paket.json'));
for (const f of dosyalar) {
  const metin = fs.readFileSync(path.join(dizin, f), 'utf8').replace(/^\uFEFF/, '');
  await db.query('insert into public.test_paketler (ad, icerik) values ($1, $2::jsonb)', [f.replace('.paket.json', ''), metin]);
}
console.log(`paketler: ${dosyalar.length} dosya yüklendi (${kaynak})`);

// Sözlük örneği (test_sozlukler): fixtures/sozluk.ornek.json
await db.exec('create table public.test_sozlukler (ad text primary key, icerik jsonb not null)');
await db.exec('revoke all on public.test_sozlukler from anon, authenticated');
const sozlukOrnek = path.join(here, 'fixtures', 'sozluk.ornek.json');
if (fs.existsSync(sozlukOrnek)) {
  await db.query('insert into public.test_sozlukler (ad, icerik) values ($1, $2::jsonb)', ['sozluk.ornek', fs.readFileSync(sozlukOrnek, 'utf8').replace(/^\uFEFF/, '')]);
}

await adim('test-yukleme', () => db.exec(fs.readFileSync(path.join(here, 'testler.sql'), 'utf8')));
const bildirimler = [];
await adim('testler', async () => {
  try {
    await db.query('select pg_temp.okuma_testleri()', [], { onNotice: (n) => bildirimler.push(n.message) });
  } catch (e) {
    console.log(bildirimler.join('\n'));
    throw e;
  }
});

// Hikâye fişleri: 120 fişlik katalog (fixtures/hr_katalog.json) katalog → fiş eşlemesiyle sınanır.
await adim('fis-testler-yukleme', () => db.exec(fs.readFileSync(path.join(here, 'fis_testler.sql'), 'utf8')));
const katalog = JSON.parse(fs.readFileSync(path.join(here, 'fixtures', 'hr_katalog.json'), 'utf8').replace(/^﻿/, ''));
const fisKatalogu = katalog.entries.map((e) => ({
  fis_kodu: e.id,
  baslik: e.title,
  sinif: e.grade,
  sinif_bandi: e.band.replace('–', '-'),
  tur: e.genre,
  kurgu_cekirdegi: e.story_seed,
  soz_varligi: e.language,
  bilgi_beceri_deger: e.concepts,
  ikon_onerileri: e.icon_suggestions,
  telif_sinifi: e.rights_class,
  kaynak_sinifi: e.source,
  telif_notu: e.rights_explanation,
}));
await adim('fis-testleri', () => db.query('select pg_temp.fis_testleri($1::jsonb)', [JSON.stringify(fisKatalogu)]));
const sonuc = await adim('sonuc', () => db.query('select no, senaryo, gecti, detay from pg_temp.sonuc order by no'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 600)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);

// GÖR-048: export_my_data son tanımı (20261106) senaryoları
await adim('export-son-yukleme', () => db.exec(fs.readFileSync(path.join(here, 'export_son_testleri.sql'), 'utf8')));
const sonSonuc = await adim('export-son', () => db.query('select * from pg_temp.export_son_testleri()'));
let sonGecen = 0;
for (const r of sonSonuc.rows) {
  if (r.gecti) sonGecen++;
  console.log(`E${r.no}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 600)}`);
}
console.log(`EXPORT SON TANIM: ${sonGecen}/${sonSonuc.rows.length} senaryo geçti`);
const sonTamam = sonGecen === sonSonuc.rows.length && sonSonuc.rows.length > 0;

// export_my_data kapsamı (yalnız tespit; genişletme ayrı migration işidir)
const migKlasor = path.resolve(here, '../../migrations');
const exportDosyalari = fs.readdirSync(migKlasor).filter((f) => f.endsWith('.sql')).sort()
  .filter((f) => /create or replace function public\.export_my_data\b/i.test(fs.readFileSync(path.join(migKlasor, f), 'utf8')));
const sonExport = exportDosyalari[exportDosyalari.length - 1];
const okumaKapsami = sonExport && /okuma_/.test(fs.readFileSync(path.join(migKlasor, sonExport), 'utf8'));
console.log(`\nNOT export_my_data: son tanım ${sonExport || '(bulunamadı)'}; okuma_* tablolarını kapsıyor mu: ${okumaKapsami ? 'EVET' : 'HAYIR (eksik; ayrı migration gerekir)'}`);

process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 && sonTamam ? 0 : 1);

