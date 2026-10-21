// 2. sınıf pilot (15 hikâye) içe aktarma sınaması: PGlite, uzak DB'ye dokunmaz.
// Akış: stubs → okuma migration'ları (20261057, 20261058 dahil) → yönetici profili →
// sözlük (kuru, gerçek) → 15 paket (kuru, gerçek) → fiş hikâye bağlantısı → sonuç özeti.
// Kullanım: node pilot2_ice_aktar.mjs
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
  path.join(here, 'stubs_export.sql'),
  mig('20261050000400_okuma_dunyasi_sozluk.sql'),
  mig('20261050000500_export_my_data_okuma.sql'),
  mig('20261051000000_okuma_dusun_alani.sql'),
  mig('20261057000000_okuma_hikaye_fisleri.sql'),
  mig('20261058000000_okuma_paket_fis_kodu.sql'),
];
const pilotDizin = process.env.PILOT_DIZIN || 'C:\\Dev\\Senin Hikayen - HupoRead\\icerik\\pilot-2-sinif';
const sozlukYolu = path.join(pilotDizin, 'sozluk-pilot-2.json');

const db = new PGlite();
const oku = (p) => fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, '');

await db.exec(oku(path.join(here, 'stubs.sql')));
for (const m of migrasyonlar) {
  await db.exec(oku(m));
}
console.log('migrasyonlar: tamam');

// Yönetici profili (testler gibi): auth.uid() bu kimlikle dönsün.
const adminId = '00000000-0000-4000-8000-00000000a001';
await db.query('insert into auth.users (id, email) values ($1, $2)', [adminId, 'pilot-yonetici@example.test']);
await db.query("insert into public.profiles (id, role, full_name) values ($1, 'admin', 'Pilot Yonetici')", [adminId]);
await db.query("select set_config('request.jwt.claims', $1, false)", [JSON.stringify({ sub: adminId, role: 'authenticated' })]);

const sozluk = oku(sozlukYolu);
const kuru = await db.query('select public.okuma_sozluk_ice_aktar($1::jsonb, true) as r', [sozluk]);
console.log('sozluk kuru:', JSON.stringify(kuru.rows[0].r).slice(0, 400));
const gercek = await db.query('select public.okuma_sozluk_ice_aktar($1::jsonb, false) as r', [sozluk]);
console.log('sozluk gercek:', JSON.stringify(gercek.rows[0].r).slice(0, 400));

const fisJson = oku(path.join(pilotDizin, 'fisler-pilot-2.json'));
const fr = await db.query('select public.okuma_fis_ice_aktar($1::jsonb, false) as r', [fisJson]);
console.log('fis ice aktar:', JSON.stringify(fr.rows[0].r).slice(0, 300));
const paketDizini = path.join(pilotDizin, 'paket');
const paketler = fs.readdirSync(paketDizini).filter((f) => f.endsWith('.paket.json')).sort();
let sayac = 0;
for (const f of paketler) {
  const icerik = oku(path.join(paketDizini, f));
  const k = await db.query('select public.okuma_paket_ice_aktar($1::jsonb, true) as r', [icerik]);
  const g = await db.query('select public.okuma_paket_ice_aktar($1::jsonb, false) as r', [icerik]);
  const kr = k.rows[0].r; const gr = g.rows[0].r;
  if (!(kr?.gecerli === true && kr?.yazildi === false && gr?.gecerli === true && gr?.yazildi === true)) {
    console.log(`HATA ${f}: kuru=${JSON.stringify(kr).slice(0, 300)} gercek=${JSON.stringify(gr).slice(0, 300)}`);
  } else {
    sayac++;
  }
}
console.log(`paket: ${sayac}/${paketler.length} basarili`);

const fisler = [
  ['HR-001', 'hr001-kayip-canin-izinde'], ['HR-002', 'hr002-renkli-ucurtma'], ['HR-003', 'hr003-corabini-arayan-robot'],
  ['HR-004', 'hr004-ters-gun-okulda'], ['HR-005', 'hr005-hocanin-golundeki-umut'], ['HR-006', 'hr006-dudek-kimin-olacak'],
  ['HR-007', 'hr007-kaplumbaga-ve-tavsan'], ['HR-008', 'hr008-aslan-ve-fare'], ['HR-009', 'hr009-konusan-kalem-kutusu'],
  ['HR-010', 'hr010-kelogan-ve-konusan-tas'], ['HR-012', 'hr012-yeni-arkadasin-gizli-yetenegi'],
  ['HR-013', 'hr013-kirilan-oyuncak-kopru'], ['HR-014', 'hr014-yagmur-damlasinin-yolculugu'],
  ['HR-016', 'hr016-golgeyi-kim-buyuttu'], ['HR-017', 'hr017-mahallenin-en-hizli-bisikleti'],
];
for (const [kod, slug] of fisler) {
  await db.query('update public.okuma_hikaye_fisleri set hikaye_slug = $2 where fis_kodu = $1', [kod, slug]);
}
const bagli = await db.query('select count(*)::int as n from public.okuma_hikaye_fisleri where hikaye_slug is not null');
const hikayeSayi = await db.query("select count(*)::int as n from public.okuma_hikayeleri");
const surumDurum = await db.query("select durum, count(*)::int as n from public.okuma_hikaye_surumleri group by durum");
console.log('fis baglanti:', bagli.rows[0].n, '/ 15');
console.log('hikaye sayisi:', hikayeSayi.rows[0].n, 'surum durumlari:', JSON.stringify(surumDurum.rows));
const ornek = await db.query("select s.icerik::text as icerik from public.okuma_hikaye_surumleri s limit 1");
console.log('surum icerik fis_kodu iceriyor mu:', ornek.rows.length ? /fis_kodu/.test(ornek.rows[0].icerik) : 'surum yok');
