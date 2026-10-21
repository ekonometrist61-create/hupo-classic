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
];

const db = new PGlite();
await db.exec(oku(path.join(here, 'stubs.sql')));
for (const m of migrasyonlar) await db.exec(oku(m));

// Yönetici profili: migration ilk admin profilini bulur.
await db.query('insert into auth.users (id, email) values ($1, $2)', ['00000000-0000-4000-8000-00000000b001', 'uzak-yonetici@example.test']);
await db.query("insert into public.profiles (id, role, full_name) values ($1, 'admin', 'Uzak Yonetici')", ['00000000-0000-4000-8000-00000000b001']);

await db.exec(oku(mig('20261059000000_okuma_pilot2_icerik.sql')));
console.log('20261059 uygulandi (hata yok)');

const hikaye = await db.query('select count(*)::int as n from public.okuma_hikayeleri');
const fis = await db.query('select count(*)::int as n from public.okuma_hikaye_fisleri where hikaye_slug is not null');
const sozlukGirdi = await db.query('select count(*)::int as n from public.okuma_sozluk_girdileri');
const sozlukYuva = await db.query('select count(*)::int as n from public.okuma_sozluk_yuvalari');
const surum = await db.query("select durum, count(*)::int as n from public.okuma_hikaye_surumleri group by durum");
const hedef = await db.query("select tur, count(*)::int as n from public.okuma_ogrenme_hedefleri group by tur order by tur");
console.log('hikaye:', hikaye.rows[0].n);
console.log('fis baglandi:', fis.rows[0].n, '/ 15');
console.log('sozluk girdi:', sozlukGirdi.rows[0].n, 'yuva:', sozlukYuva.rows[0].n);
console.log('surum durum:', JSON.stringify(surum.rows));
console.log('hedef turleri:', JSON.stringify(hedef.rows));
