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

// export_my_data kapsamı (yalnız tespit; genişletme ayrı migration işidir)
const migKlasor = path.resolve(here, '../../migrations');
const exportDosyalari = fs.readdirSync(migKlasor).filter((f) => f.endsWith('.sql')).sort()
  .filter((f) => /create or replace function public\.export_my_data\b/i.test(fs.readFileSync(path.join(migKlasor, f), 'utf8')));
const sonExport = exportDosyalari[exportDosyalari.length - 1];
const okumaKapsami = sonExport && /okuma_/.test(fs.readFileSync(path.join(migKlasor, sonExport), 'utf8'));
console.log(`\nNOT export_my_data: son tanım ${sonExport || '(bulunamadı)'}; okuma_* tablolarını kapsıyor mu: ${okumaKapsami ? 'EVET' : 'HAYIR (eksik; ayrı migration gerekir)'}`);

process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);

