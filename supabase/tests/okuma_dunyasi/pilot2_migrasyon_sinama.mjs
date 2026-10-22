// 20261059 (pilot içe aktarma) migration dosyasını, uzak DB'de çalışacağı biçimiyle sınar:
// stubs → okuma migration'ları (20261057, 20261058) → yönetici profili → 20261059 dosyası.
// Beklenen: hata yok; 15 hikâye taslak; 15 fiş bağlı; sözlük yazıldı.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const mig = (ad) => path.resolve(here, '../../migrations', ad);
const oku = (p) => fs.readFileSync(p, 'utf8').replace(/^﻿/, '');
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
  mig('20261060000000_okuma_hikaye_turleri.sql'),
  mig('20261064000000_okuma_yonetim_crud.sql'),
  mig('20261065000000_okuma_dashboard_veli_ogretmen.sql'),
  mig('20261066000000_kullanim_suresi.sql'),
  mig('20261068000000_okuma_uc_goz_yayin_kurali.sql'),
  mig('20261071000000_okuma_sayfa_siniri_40.sql'),
  mig('20261074000000_okuma_site_ozeti.sql'),
  mig('20261075000000_okuma_anket_yildiz_istege_bagli.sql'),
  mig('20261076000000_okuma_paket_sozluk_ikon.sql'),
];

const db = new PGlite();
await db.exec(oku(path.join(here, 'stubs.sql')));
for (const m of migrasyonlar) await db.exec(oku(m));

// Yönetici profili: migration ilk admin profilini bulur.
await db.query('insert into auth.users (id, email) values ($1, $2)', ['00000000-0000-4000-8000-00000000b001', 'uzak-yonetici@example.test']);
await db.query("insert into public.profiles (id, role, full_name) values ($1, 'admin', 'Uzak Yonetici')", ['00000000-0000-4000-8000-00000000b001']);

for (const ad of ['20261059000000_okuma_pilot2_icerik.sql', '20261061000000_okuma_pilot2_guncelleme.sql', '20261062000000_okuma_pilot3_4_icerik.sql', '20261067000000_okuma_pilot4_6_icerik.sql', '20261069000000_okuma_test_yayini.sql', '20261072000000_okuma_uzun_hikayeler_bolunmus.sql', '20261077000000_okuma_ikon_sozluk_taslak.sql']) {
  if (!fs.existsSync(mig(ad))) continue;
  await db.exec(oku(mig(ad)));
  console.log(ad, 'uygulandi (hata yok)');
}

const hikaye = await db.query('select count(*)::int as n from public.okuma_hikayeleri');
const fis = await db.query('select count(*)::int as n from public.okuma_hikaye_fisleri where hikaye_slug is not null');
const sozlukGirdi = await db.query('select count(*)::int as n from public.okuma_sozluk_girdileri');
const sozlukYuva = await db.query('select count(*)::int as n from public.okuma_sozluk_yuvalari');
const surum = await db.query("select durum, count(*)::int as n from public.okuma_hikaye_surumleri group by durum order by durum");
const hedef = await db.query("select tur, count(*)::int as n from public.okuma_ogrenme_hedefleri group by tur order by tur");
console.log('hikaye:', hikaye.rows[0].n);
console.log('fis baglandi:', fis.rows[0].n, '/ 15');
console.log('sozluk girdi:', sozlukGirdi.rows[0].n, 'yuva:', sozlukYuva.rows[0].n);
console.log('surum durum:', JSON.stringify(surum.rows));
console.log('hedef turleri:', JSON.stringify(hedef.rows));

await db.query("update public.okuma_ayarlari set deger = 'true'::jsonb where anahtar = 'aktif'");
const site = await db.query('select public.okuma_site_ozeti() as o');
console.log('site ozeti:', JSON.stringify(site.rows[0].o));
