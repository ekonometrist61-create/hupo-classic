// Okuma Dünyası yönetim CRUD sınaması (20261064): PGlite, uzak veritabanına dokunmaz.
// Kullanım: node yonetim_crud_testleri.mjs
// Senaryolar: yetki (42501), yayında sürüm silinemez, oturumlu sürüm/hikâye silinemez,
// oturumsuz taslak hikâye silinir + fiş bağlantısı boşalır, arşiv sürüm silinir,
// düzenleme akışı (yeni taslak sürüm), istatistik değerleri.
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
  mig('20261068000000_okuma_uc_goz_yayin_kurali.sql'),
  mig('20261079000000_okuma_toplu_islem.sql'),
];

const db = new PGlite();
await db.exec(oku(path.join(here, 'stubs.sql')));
for (const m of migrasyonlar) await db.exec(oku(m));

const A1 = '00000000-0000-4000-8000-00000000a001';
const A2 = '00000000-0000-4000-8000-00000000a002';
const O1 = '00000000-0000-4000-8000-00000000b001';
const O2 = '00000000-0000-4000-8000-00000000b002';
await db.exec(`insert into auth.users (id, email) select x, x::text || '@example.test' from unnest(array['${A1}','${A2}','${O1}','${O2}']::uuid[]) x`);
await db.exec(`insert into public.profiles (id, role, full_name, sinif) values
  ('${A1}','admin','Yonetici Bir',null), ('${A2}','admin','Yonetici Iki',null),
  ('${O1}','ogrenci','Ogrenci Bir',4), ('${O2}','ogrenci','Ogrenci Iki',4)`);

// Kullanıcı olarak çağırır; hata olursa { hata: { kod, mesaj } } döner.
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
const ok = async (uid, sql, params) => {
  const r = await cagri(uid, sql, params);
  if (r.hata) throw new Error(`beklenmeyen hata [${sql}]: ${r.hata.kod} ${r.hata.mesaj}`);
  return r.veri;
};

const temel = JSON.parse(oku(path.join(here, 'fixtures', 'kayip-defter.paket.json')));
const paket = (slug, degistir) => {
  const p = JSON.parse(JSON.stringify(temel));
  p.hikaye.slug = slug;
  p.hikaye.etiketler.olculen = { kelime_sayisi: 321, tahmini_sure_dk: 3 };
  if (degistir) degistir(p);
  return p;
};
const ice = (uid, p) => ok(uid, 'public.okuma_paket_ice_aktar($1::jsonb, false)', [JSON.stringify(p)]);
const durum = (uid, sid, d, den) => ok(uid, 'public.okuma_surum_durum_degistir($1, $2, $3::jsonb)', [sid, d, den ? JSON.stringify(den) : null]);
async function yayinla(sid) {
  await durum(A1, sid, 'incelemede');
  await durum(A2, sid, 'incelemede', { ajan_a: 'pass', ajan_b: 'pass', insan: 'approved' });
  await durum(A2, sid, 'yayinda');
}
const say = async (tablo, kosul = 'true') => (await db.query(`select count(*)::int as n from public.${tablo} where ${kosul}`)).rows[0].n;

const sonuc = [];
const k = (ad, gecti, detay = '') => { sonuc.push(gecti); console.log(`${String(sonuc.length).padStart(2)}. [${gecti ? 'OK  ' : 'FAIL'}] ${ad}${gecti ? '' : ' :: ' + detay}`); };
const hataIcerir = (r, parca, kod) => !!r.hata && r.hata.mesaj.includes(parca) && (!kod || r.hata.kod === kod);

try {
  // --- Yetki ------------------------------------------------------------
  const rastgele = '00000000-0000-4000-8000-0000000000ff';
  for (const [ad, sql] of [
    ['okuma_surum_sil', `public.okuma_surum_sil('${rastgele}')`],
    ['okuma_hikaye_sil', `public.okuma_hikaye_sil('${rastgele}')`],
    ['okuma_yonetim_istatistik', 'public.okuma_yonetim_istatistik()'],
  ]) {
    const ogr = await cagri(O1, sql);
    const anon = await cagri(null, sql);
    k(`yetki: ${ad} öğrenci için 42501`, ogr.hata?.kod === '42501', JSON.stringify(ogr));
    k(`yetki: ${ad} anon için reddedilir`, !!anon.hata, JSON.stringify(anon));
  }
  const yokSurum = await cagri(A1, `public.okuma_surum_sil('${rastgele}')`);
  k('olmayan sürüm: SURUM_BULUNAMADI (P0002)', hataIcerir(yokSurum, 'SURUM_BULUNAMADI', 'P0002'), JSON.stringify(yokSurum));
  const yokHikaye = await cagri(A1, `public.okuma_hikaye_sil('${rastgele}')`);
  k('olmayan hikâye: HIKAYE_BULUNAMADI (P0002)', hataIcerir(yokHikaye, 'HIKAYE_BULUNAMADI', 'P0002'), JSON.stringify(yokHikaye));

  // --- Boş istatistik ---------------------------------------------------
  const bos = await ok(A1, 'public.okuma_yonetim_istatistik()');
  k('istatistik (boş): sıfırlar, oran/doğruluk null',
    bos.yayinda_hikaye === 0 && bos.toplam_oturum === 0 && bos.tamamlama_orani === null && bos.ortalama_dogruluk === null && bos.okunan_kelime === 0,
    JSON.stringify(bos));

  // --- Yayındaki hikâye (A) ---------------------------------------------
  const ra = await ice(A1, paket('crud-yayinda'));
  await yayinla(ra.surum_id);
  const hA = (await db.query("select id from public.okuma_hikayeleri where slug = 'crud-yayinda'")).rows[0].id;

  const silYayin = await cagri(A1, 'public.okuma_surum_sil($1)', [ra.surum_id]);
  k('yayında sürüm silinemez (SURUM_YAYINDA, 55000)', hataIcerir(silYayin, 'SURUM_YAYINDA', '55000'), JSON.stringify(silYayin));
  const silYayinH = await cagri(A1, 'public.okuma_hikaye_sil($1)', [hA]);
  k('yayında sürümü olan hikâye silinemez (SURUM_YAYINDA)', hataIcerir(silYayinH, 'SURUM_YAYINDA', '55000'), JSON.stringify(silYayinH));
  k('yayında sürüm hâlâ yerinde', (await say('okuma_hikaye_surumleri', `id = '${ra.surum_id}' and durum = 'yayinda'`)) === 1);

  // --- Düzenleme akışı: yeni taslak sürüm, yayındaki değişmez ------------
  const duzenli = await ice(A1, paket('crud-yayinda', (p) => { p.hikaye.baslik = 'Kayıp Defter (düzeltildi)'; }));
  k('düzenleme: ice_aktar yeni TASLAK sürüm üretir (surum_no 2), yayındaki sürüm değişmez',
    duzenli.surum_id !== ra.surum_id && (await say('okuma_hikaye_surumleri', `hikaye_id = '${hA}' and durum = 'taslak' and surum_no = 2`)) === 1
      && (await say('okuma_hikaye_surumleri', `id = '${ra.surum_id}' and durum = 'yayinda' and baslik = 'Kayıp Defter'`)) === 1,
    JSON.stringify(duzenli));
  const tekrar = await ice(A1, paket('crud-yayinda', (p) => { p.hikaye.baslik = 'Kayıp Defter (düzeltildi)'; }));
  k('düzenleme: aynı içerik tekrar gönderilirse yeni sürüm açılmaz', (await say('okuma_hikaye_surumleri', `hikaye_id = '${hA}'`)) === 2, JSON.stringify(tekrar));

  // taslak düzenleme sürümü silinir (oturumsuz); yayındaki hikâye kalır
  const silTaslak = await ok(A1, 'public.okuma_surum_sil($1)', [duzenli.surum_id]);
  k('oturumsuz taslak sürüm silinir; etiketleri de gider',
    silTaslak.silindi === true && (await say('okuma_hikaye_surumleri', `id = '${duzenli.surum_id}'`)) === 0
      && (await say('okuma_hikaye_etiketleri', `surum_id = '${duzenli.surum_id}'`)) === 0 && (await say('okuma_hikayeleri', `id = '${hA}'`)) === 1);

  // --- Oturumlar + istatistik -------------------------------------------
  await db.query(`insert into public.okuma_oturumlari (ogrenci_id, hikaye_id, surum_id, istemci_anahtari, kahraman_turu, sinif, gun, tamamlandi_at, soru_sayisi, dogru_sayisi)
    values ($1, $2, $3, 'anahtar-crud-001', 'ben', 4, current_date, now(), 3, 2)`, [O1, hA, ra.surum_id]);
  await db.query(`insert into public.okuma_oturumlari (ogrenci_id, hikaye_id, surum_id, istemci_anahtari, kahraman_turu, sinif, gun, soru_sayisi, dogru_sayisi)
    values ($1, $2, $3, 'anahtar-crud-002', 'ben', 4, current_date, 3, 0)`, [O2, hA, ra.surum_id]);
  const ist = await ok(A1, 'public.okuma_yonetim_istatistik()');
  k('istatistik: yayında=1, oturum=2, tamamlanan=1, oran=50.0, doğruluk=66.7, kelime=321',
    ist.yayinda_hikaye === 1 && ist.toplam_oturum === 2 && ist.tamamlanan_oturum === 1 && Number(ist.tamamlama_orani) === 50
      && Number(ist.ortalama_dogruluk) === 66.7 && Number(ist.okunan_kelime) === 321, JSON.stringify(ist));
  k('istatistik: sınıf ve tür dağılımı (yayında + oturum)',
    ist.yayinda_sinif_dagilimi.length === 1 && ist.yayinda_sinif_dagilimi[0].hikaye === 1
      && ist.yayinda_tur_dagilimi.length === 1 && ist.yayinda_tur_dagilimi[0].tur === 'gizem'
      && ist.oturum_sinif_dagilimi[0].sinif === 4 && ist.oturum_sinif_dagilimi[0].oturum === 2 && ist.oturum_sinif_dagilimi[0].tamamlanan === 1
      && ist.oturum_tur_dagilimi[0].oturum === 2 && ist.surum_durumlari.yayinda === 1, JSON.stringify(ist));
  k('istatistik: yanıtta öğrenci kimliği yok', !JSON.stringify(ist).includes(O1) && !JSON.stringify(ist).includes(O2));

  // --- Oturumlu sürüm/hikâye: arşivde bile silinemez --------------------
  await durum(A2, ra.surum_id, 'arsiv');
  const silOturumlu = await cagri(A1, 'public.okuma_surum_sil($1)', [ra.surum_id]);
  k('oturumlu (arşiv) sürüm silinemez: OTURUM_VAR, arşiv önerilir', hataIcerir(silOturumlu, 'OTURUM_VAR', '55000') && silOturumlu.hata.mesaj.includes('arşiv'), JSON.stringify(silOturumlu));
  const silOturumluH = await cagri(A1, 'public.okuma_hikaye_sil($1)', [hA]);
  k('oturumlu hikâye silinemez: OTURUM_VAR', hataIcerir(silOturumluH, 'OTURUM_VAR', '55000'), JSON.stringify(silOturumluH));
  k('oturumlu hikâye ve oturumlar yerinde', (await say('okuma_hikayeleri', `id = '${hA}'`)) === 1 && (await say('okuma_oturumlari', `hikaye_id = '${hA}'`)) === 2);

  // --- Oturumsuz taslak hikâye + fiş bağlantısı -------------------------
  const rb1 = await ice(A1, paket('crud-taslak'));
  await ice(A1, paket('crud-taslak', (p) => { p.hikaye.baslik = 'Taslak ikinci sürüm'; }));
  const hB = (await db.query("select id from public.okuma_hikayeleri where slug = 'crud-taslak'")).rows[0].id;
  await db.exec(`insert into public.okuma_hikaye_fisleri (fis_kodu, baslik, sinif, sinif_bandi, tur, kurgu_cekirdegi, telif_sinifi, kaynak_sinifi, durum, hikaye_slug)
    values ('HR-901', 'Test fişi', 4, '2-4', 'gizem', 'Kayıp bir defterin izini süren iki arkadaşın hikayesi.', 'O', 'Özgün', 'metin_taslak', 'crud-taslak')`);
  const silH = await ok(A1, 'public.okuma_hikaye_sil($1)', [hB]);
  const fis = (await db.query("select hikaye_slug, durum from public.okuma_hikaye_fisleri where fis_kodu = 'HR-901'")).rows[0];
  k('oturumsuz taslak hikâye silinir (2 sürüm); fiş bağlantısı boşalır ve brief_draft olur',
    silH.silindi === true && silH.silinen_surum === 2 && silH.bosaltilan_fis === 1
      && (await say('okuma_hikayeleri', `id = '${hB}'`)) === 0 && (await say('okuma_hikaye_surumleri', `hikaye_id = '${hB}'`)) === 0
      && fis.hikaye_slug === null && fis.durum === 'brief_draft', JSON.stringify({ silH, fis }));
  k('silinen hikâyenin ilk sürümü de gitti', (await say('okuma_hikaye_surumleri', `id = '${rb1.surum_id}'`)) === 0);

  // --- Oturumsuz arşiv sürüm silinir ------------------------------------
  const rc = await ice(A1, paket('crud-arsiv'));
  await durum(A1, rc.surum_id, 'arsiv');
  const silArsiv = await ok(A1, 'public.okuma_surum_sil($1)', [rc.surum_id]);
  k('oturumsuz arşiv sürüm silinir', silArsiv.silindi === true && (await say('okuma_hikaye_surumleri', `id = '${rc.surum_id}'`)) === 0);

  // --- incelemede sürüm silinemez ---------------------------------------
  const rd = await ice(A1, paket('crud-inceleme'));
  await durum(A1, rd.surum_id, 'incelemede');
  const hD = (await db.query("select id from public.okuma_hikayeleri where slug = 'crud-inceleme'")).rows[0].id;
  const silInc = await cagri(A1, 'public.okuma_surum_sil($1)', [rd.surum_id]);
  const silIncH = await cagri(A1, 'public.okuma_hikaye_sil($1)', [hD]);
  k('incelemedeki sürüm / hikâye silinemez (SURUM_SILINEMEZ)', hataIcerir(silInc, 'SURUM_SILINEMEZ', '55000') && hataIcerir(silIncH, 'SURUM_SILINEMEZ', '55000'), JSON.stringify([silInc, silIncH]));

  // --- Toplu işlem (20261079): arşive al / sil, kuru çalıştırma, atlanan nedenleri ----
  const toplu = (uid, idler, islem, kuru) => cagri(uid, 'public.okuma_toplu_islem($1::uuid[], $2, $3)', [`{${idler.join(',')}}`, islem, kuru]);
  const bul = (r, id) => r.veri.sonuclar.find((x) => x.hikaye_id === id);
  const tOgr = await toplu(O1, [hA], 'arsiv', true);
  const tAnon = await toplu(null, [hA], 'arsiv', true);
  k('toplu: öğrenci 42501, anon reddedilir', tOgr.hata?.kod === '42501' && !!tAnon.hata, JSON.stringify([tOgr, tAnon]));
  const tBos = await toplu(A1, [], 'arsiv', true);
  const tKotu = await toplu(A1, [hA], 'yoket', true);
  k('toplu: boş liste ve geçersiz işlem BAD_LISTE / BAD_ISLEM (22023)', hataIcerir(tBos, 'BAD_LISTE', '22023') && hataIcerir(tKotu, 'BAD_ISLEM', '22023'), JSON.stringify([tBos, tKotu]));

  const re = await ice(A1, paket('toplu-yayinda')); await yayinla(re.surum_id);
  const hE = (await db.query("select id from public.okuma_hikayeleri where slug = 'toplu-yayinda'")).rows[0].id;
  const rf = await ice(A1, paket('toplu-taslak'));
  const hF = (await db.query("select id from public.okuma_hikayeleri where slug = 'toplu-taslak'")).rows[0].id;
  const yokId = '00000000-0000-4000-8000-0000000000fe';

  // kuru çalıştırma: hiçbir şey değişmez, sonuç gerçeği yansıtır
  const kSil = await toplu(A1, [hE, hF, hA, hD, yokId], 'sil', true);
  k('toplu sil (kuru): yayında=SURUM_YAYINDA, taslak=başarılı, oturumlu=OTURUM_VAR, incelemede=SURUM_SILINEMEZ, olmayan=HIKAYE_BULUNAMADI',
    !kSil.hata && kSil.veri.kuru === true && bul(kSil, hE).neden === 'SURUM_YAYINDA' && bul(kSil, hF).sonuc === 'basarili'
      && bul(kSil, hA).neden === 'OTURUM_VAR' && bul(kSil, hD).neden === 'SURUM_SILINEMEZ' && bul(kSil, yokId).neden === 'HIKAYE_BULUNAMADI'
      && kSil.veri.basarili === 1 && kSil.veri.atlanan === 4, JSON.stringify(kSil));
  k('toplu sil (kuru): hiçbir kayıt silinmedi',
    (await say('okuma_hikayeleri', `id in ('${hE}','${hF}','${hA}','${hD}')`)) === 4 && (await say('okuma_hikaye_surumleri', `hikaye_id = '${hF}'`)) === 1);

  // gerçek toplu sil: yalnız kurala uyan (taslak) gider
  const gSil = await toplu(A1, [hE, hF, hA, hD], 'sil', false);
  k('toplu sil (gerçek): yalnız oturumsuz taslak hikâye silinir; yayında / oturumlu / incelemede yerinde',
    !gSil.hata && gSil.veri.basarili === 1 && bul(gSil, hF).etkilenen_surum === 1
      && (await say('okuma_hikayeleri', `id = '${hF}'`)) === 0 && (await say('okuma_hikayeleri', `id in ('${hE}','${hA}','${hD}')`)) === 3, JSON.stringify(gSil));

  // toplu arşiv: kuru -> gerçek
  const kArs = await toplu(A1, [hE, hA, hD], 'arsiv', true);
  k('toplu arşiv (kuru): yayında ve incelemede başarılı, zaten arşivdeki ZATEN_ARSIV; durum değişmez',
    !kArs.hata && bul(kArs, hE).sonuc === 'basarili' && bul(kArs, hD).sonuc === 'basarili' && bul(kArs, hA).neden === 'ZATEN_ARSIV'
      && (await say('okuma_hikaye_surumleri', `hikaye_id = '${hE}' and durum = 'yayinda'`)) === 1
      && (await say('okuma_hikaye_surumleri', `hikaye_id = '${hD}' and durum = 'incelemede'`)) === 1, JSON.stringify(kArs));
  const gArs = await toplu(A1, [hE, hA, hD], 'arsiv', false);
  k('toplu arşiv (gerçek): yayında + incelemede sürümler arşive geçti, arsiv_at dolu; oturumlar korunur',
    !gArs.hata && gArs.veri.basarili === 2 && gArs.veri.atlanan === 1
      && (await say('okuma_hikaye_surumleri', `hikaye_id in ('${hE}','${hD}') and durum = 'arsiv' and arsiv_at is not null`)) === 2
      && (await say('okuma_oturumlari', `hikaye_id = '${hA}'`)) === 2, JSON.stringify(gArs));

  // arşivlenen oturumsuz hikâye artık toplu silinebilir; oturumlu hâlâ silinemez
  const gSil2 = await toplu(A1, [hE, hA], 'sil', false);
  k('toplu sil: arşivdeki oturumsuz hikâye silinir, oturumlu atlanır', gSil2.veri?.basarili === 1 && bul(gSil2, hA).neden === 'OTURUM_VAR'
    && (await say('okuma_hikayeleri', `id = '${hE}'`)) === 0, JSON.stringify(gSil2));
  k('toplu: yanıtta öğrenci kimliği yok', !JSON.stringify([kSil, gSil, kArs, gArs, gSil2]).includes(O1));

  // --- Denetim günlüğü --------------------------------------------------
  const eksik = ['okuma_surum_silindi', 'okuma_hikaye_silindi', 'okuma_yonetim_istatistik', 'okuma_toplu_islem'].filter(() => false);
  for (const i of ['okuma_surum_silindi', 'okuma_hikaye_silindi', 'okuma_yonetim_istatistik', 'okuma_toplu_islem']) {
    if ((await say('admin_audit_log', `islem = '${i}'`)) === 0) eksik.push(i);
  }
  k('log_admin_action kayıtları yazıldı', eksik.length === 0, eksik.join(','));

  // --- Envanter ---------------------------------------------------------
  const bilgi = (await db.query(`select p.proname, p.prosecdef, has_function_privilege('anon', p.oid, 'execute') as anon,
      has_function_privilege('authenticated', p.oid, 'execute') as auth, p.proconfig::text as cfg
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.proname in ('okuma_surum_sil', 'okuma_hikaye_sil', 'okuma_yonetim_istatistik')`)).rows;
  k('yeni RPC\'ler: SECURITY DEFINER, search_path sabit, authenticated açık, anon kapalı',
    bilgi.length === 3 && bilgi.every((r) => r.prosecdef && !r.anon && r.auth && /search_path=/.test(r.cfg)), JSON.stringify(bilgi));
} catch (e) {
  console.log('BEKLENMEYEN HATA:', e.message);
  sonuc.push(false);
}

const gecen = sonuc.filter(Boolean).length;
console.log(`\nSONUÇ: ${gecen}/${sonuc.length} senaryo geçti`);
process.exit(gecen === sonuc.length && sonuc.length > 0 ? 0 : 1);
