// Okuma Dünyası veli/öğretmen dashboard sınaması (20261065): PGlite, uzak veritabanına dokunmaz.
// Kullanım: node dashboard_testleri.mjs
// Senaryolar: yetki, rıza yok, başka sınıf öğretmeni reddi, sınıf üyesi olmayan öğrenci reddi,
// min-N (sınıf toplamı), yeni alanların değerleri, geriye uyumlu anahtarlar, envanter.
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
  mig('20261065000000_okuma_dashboard_veli_ogretmen.sql'),
];

const db = new PGlite();
await db.exec(oku(path.join(here, 'stubs.sql')));
for (const m of migrasyonlar) await db.exec(oku(m));

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const A1 = id(0xa1), A2 = id(0xa2);
const T1 = id(0xc1), T2 = id(0xc2);
const V1 = id(0xd1), V2 = id(0xd2);
const S = [0, 1, 2, 3, 4, 5].map((i) => id(0xe0 + i)); // S[1..5]
const C1 = id(0xf1), C2 = id(0xf2), C3 = id(0xf3);

const tumu = [A1, A2, T1, T2, V1, V2, ...S.slice(1)];
await db.exec(`insert into auth.users (id, email) select x, x::text || '@example.test' from unnest(array[${tumu.map((x) => `'${x}'`).join(',')}]::uuid[]) x`);
await db.exec(`insert into public.profiles (id, role, full_name, parent_id, sinif) values
  ('${A1}','admin','Yonetici Bir',null,null), ('${A2}','admin','Yonetici Iki',null,null),
  ('${T1}','ogretmen','Ogretmen Bir',null,null), ('${T2}','ogretmen','Ogretmen Iki',null,null),
  ('${V1}','veli','Veli Bir',null,null), ('${V2}','veli','Veli Iki',null,null)`);
for (let i = 1; i <= 5; i++) {
  await db.exec(`insert into public.profiles (id, role, full_name, parent_id, sinif) values ('${S[i]}','ogrenci','Ogrenci ${i}', ${i === 1 ? `'${V1}'` : 'null'}, 4)`);
}
await db.exec(`insert into public.siniflar (id, ad, sinif_seviyesi, ogretmen_id) values
  ('${C1}','4-A',4,'${T1}'), ('${C2}','4-B',4,'${T2}'), ('${C3}','4-C',4,'${T1}')`);
await db.exec(`insert into public.sinif_uyelikleri (sinif_id, ogrenci_id) values
  ('${C1}','${S[1]}'), ('${C1}','${S[2]}'), ('${C1}','${S[3]}'), ('${C1}','${S[4]}'),
  ('${C2}','${S[5]}'),
  ('${C3}','${S[1]}'), ('${C3}','${S[2]}')`);
// Rıza: S1, S3 verildi; S2 yok; S4 geri çekildi
await db.exec(`insert into public.consents (cocuk_id, tur, created_at) values
  ('${S[1]}','veli_acik_riza', now() - interval '2 day'),
  ('${S[3]}','veli_acik_riza', now() - interval '2 day'),
  ('${S[4]}','veli_acik_riza', now() - interval '2 day'),
  ('${S[4]}','veli_riza_geri_cekildi', now() - interval '1 day')`);
await db.exec(`insert into public.deneme_donemleri (veli_id, bitis) values ('${V1}', now() + interval '1 day')`);

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

// Yayında bir hikâye (kayip-defter, kelime_sayisi 321)
const temel = JSON.parse(oku(path.join(here, 'fixtures', 'kayip-defter.paket.json')));
temel.hikaye.slug = 'dash-hikaye';
temel.hikaye.etiketler.olculen = { kelime_sayisi: 321, tahmini_sure_dk: 3 };
const ra = await ok(A1, 'public.okuma_paket_ice_aktar($1::jsonb, false)', [JSON.stringify(temel)]);
const durum = (uid, sid, d, den) => ok(uid, 'public.okuma_surum_durum_degistir($1, $2, $3::jsonb)', [sid, d, den ? JSON.stringify(den) : null]);
await durum(A1, ra.surum_id, 'incelemede');
await durum(A2, ra.surum_id, 'incelemede', { ajan_a: 'pass', ajan_b: 'pass', insan: 'approved' });
await durum(A2, ra.surum_id, 'yayinda');
const hid = (await db.query("select id from public.okuma_hikayeleri where slug = 'dash-hikaye'")).rows[0].id;
const tur = (await db.query('select tur, baslik from public.okuma_hikaye_surumleri where id = $1', [ra.surum_id])).rows[0];

// Oturumlar: S1..S4 birer tamamlanmış (S1'in ilki 10 dk sürmüş); S1 ikinci tamamlanmamış; S5 (başka sınıf) bir tane
const oturum = async (ogr, anahtar, { bitti = true, dk = 0, soru = 3, dogru = 2 } = {}) => (await db.query(
  `insert into public.okuma_oturumlari (ogrenci_id, hikaye_id, surum_id, istemci_anahtari, kahraman_turu, sinif, gun,
      baslangic_at, tamamlandi_at, soru_sayisi, dogru_sayisi)
   values ($1,$2,$3,$4,'ben',4,current_date, now() - make_interval(mins => $5), ${bitti ? 'now()' : 'null'}, $6, $7) returning id`,
  [ogr, hid, ra.surum_id, anahtar, dk, soru, dogru])).rows[0].id;
const o1 = await oturum(S[1], 'dash-anahtar-s1a', { dk: 10 });
await oturum(S[1], 'dash-anahtar-s1b', { bitti: false, dogru: 0 });
const o2 = await oturum(S[2], 'dash-anahtar-s2a');
const o3 = await oturum(S[3], 'dash-anahtar-s3a');
const o4 = await oturum(S[4], 'dash-anahtar-s4a');
const o5 = await oturum(S[5], 'dash-anahtar-s5a');
// C3 sınıfı için: S1 ve S2 (yalnız 2 öğrenci) zaten oturumlu → min-N altı
for (const [o, ogr] of [[o1, S[1]], [o2, S[2]], [o3, S[3]], [o4, S[4]], [o5, S[5]]]) {
  await db.query(`insert into public.okuma_cevaplari (oturum_id, soru_id, secenek_id, dogru, beceri, olcme_turu)
    values ($1,'s1','A',true,'hatirlama','metin_kaniti'), ($1,'s2','A',$2,'cikarim','kavram_dogrulugu')`, [o, ogr !== S[4]]);
}

// Hedefler: kavram (4 öğrenci, 3'ü öğrendi), atasözü (2 öğrenci), sözcük (yalnız S1)
await db.exec(`insert into public.okuma_ogrenme_hedefleri (id, tur, etiket) values
  ('kav_gunes','concept','Güneş enerjisi'), ('ata_damla','proverb','Damlaya damlaya göl olur'), ('soz_hasat','lexeme','hasat')`);
for (const h of ['kav_gunes', 'ata_damla', 'soz_hasat']) {
  await db.query("insert into public.okuma_hikaye_hedefleri (surum_id, hedef_id, islev) values ($1,$2,'first_hint')", [ra.surum_id, h]);
}
await db.exec(`insert into public.okuma_ogrenci_hedef_durumu (ogrenci_id, hedef_id, durum) values
  ('${S[1]}','kav_gunes','retrieved'), ('${S[2]}','kav_gunes','recognized'), ('${S[3]}','kav_gunes','recognized'), ('${S[4]}','kav_gunes','introduced'),
  ('${S[1]}','ata_damla','introduced'), ('${S[2]}','ata_damla','introduced'),
  ('${S[1]}','soz_hasat','recognized')`);

const sonuc = [];
const k = (ad, gecti, detay = '') => { sonuc.push(gecti); console.log(`${String(sonuc.length).padStart(2)}. [${gecti ? 'OK  ' : 'FAIL'}] ${ad}${gecti ? '' : ' :: ' + detay}`); };
const j = (x) => JSON.stringify(x);

try {
  // --- Veli özeti -------------------------------------------------------
  const veli = await ok(V1, 'public.okuma_veli_ozeti($1, 30)', [S[1]]);
  const vo = veli.ozet;
  k('veli: geriye uyumlu anahtarlar korunur', veli.riza === true && ['gun', 'detay', 'okunan_hikaye', 'tamamlanan_hikaye', 'ortalama_sure_dk', 'soru_dogrulugu',
    'tema_dagilimi', 'deger_dagilimi', 'ders_dagilimi', 'zorluk_seyri', 'hedef_durumlari', 'pekisen_hedefler', 'cocuk_puani'].every((a) => a in vo), j(vo));
  k('veli: okunan_hikaye=1, tamamlanan=1, okunan_kelime=321 (yalnız tamamlanan oturum), süre=10 dk',
    vo.okunan_hikaye === 1 && vo.tamamlanan_hikaye === 1 && vo.okunan_kelime === 321 && Number(vo.toplam_sure_dk) === 10, j(vo));
  k('veli: son_hikayeler (başlık, tür, tamamlandı, doğru/soru) en yeni önce',
    vo.son_hikayeler.length === 2 && vo.son_hikayeler[0].baslik === tur.baslik && vo.son_hikayeler[0].tur === tur.tur
      && vo.son_hikayeler.some((x) => x.tamamlandi === true && x.dogru === 2 && x.soru === 3) && vo.son_hikayeler[0].tarih, j(vo.son_hikayeler));
  k('veli: tür dağılımı (1 hikâye, 2 oturum)', vo.tur_dagilimi.length === 1 && vo.tur_dagilimi[0].tur === tur.tur && vo.tur_dagilimi[0].hikaye === 1 && vo.tur_dagilimi[0].oturum === 2, j(vo.tur_dagilimi));
  k('veli: kavram adı + durum + hikâye', vo.kavramlar.length === 1 && vo.kavramlar[0].etiket === 'Güneş enerjisi' && vo.kavramlar[0].durum === 'retrieved' && vo.kavramlar[0].hikaye === tur.baslik, j(vo.kavramlar));
  k('veli: atasözü ve kelime listeleri', vo.atasozleri.length === 1 && vo.atasozleri[0].tur === 'proverb' && vo.kelimeler.length === 1 && vo.kelimeler[0].etiket === 'hasat', j([vo.atasozleri, vo.kelimeler]));
  k('veli: soru türü doğruluğu (2 soru → yeterli değil) ve beceri', vo.olcme_turu_dogrulugu.metin_kaniti.yeterli === false && vo.soru_dogrulugu.hatirlama.yeterli === false, j(vo.olcme_turu_dogrulugu));
  k('veli: değer ve tema dağılımı dolu', vo.deger_dagilimi.length >= 1 && vo.tema_dagilimi.length >= 1, j([vo.deger_dagilimi, vo.tema_dagilimi]));
  const veliOtherParent = await cagri(V2, 'public.okuma_veli_ozeti($1, 30)', [S[1]]);
  k('veli: bağlı olmayan veli 42501', veliOtherParent.hata?.kod === '42501', j(veliOtherParent));
  const veliTemel = await (async () => {
    await db.exec(`delete from public.deneme_donemleri where veli_id = '${V1}'`);
    const r = await ok(V1, 'public.okuma_veli_ozeti($1, 30)', [S[1]]);
    await db.exec(`insert into public.deneme_donemleri (veli_id, bitis) values ('${V1}', now() + interval '1 day')`);
    return r;
  })();
  k('veli: premium/deneme yoksa temel (detay=false) ama okunan_kelime var, hedef listeleri yok',
    veliTemel.ozet.detay === false && veliTemel.ozet.okunan_kelime === 321 && !('kavramlar' in veliTemel.ozet) && !('son_hikayeler' in veliTemel.ozet), j(veliTemel));

  // --- Öğretmen: sınıf özeti -------------------------------------------
  const sinif = await ok(T1, 'public.okuma_ogretmen_sinif_ozeti($1, 30)', [C1]);
  const so = sinif.ozet;
  k('sınıf: geriye uyumlu anahtarlar (yeterli, min_n, oturum_sayisi, tamamlama_orani, soru_dogrulugu, tema_ilgisi)',
    sinif.yeterli === true && sinif.min_n === 3 && ['oturum_sayisi', 'tamamlama_orani', 'soru_dogrulugu', 'zorlanilan_hedefler', 'tema_ilgisi'].every((a) => a in so), j(sinif));
  k('sınıf: okunan_kelime = 4 tamamlanan × 321, tur_dagilimi 4 öğrenci',
    so.okunan_kelime === 4 * 321 && so.tur_dagilimi.length === 1 && so.tur_dagilimi[0].ogrenci_sayisi === 4, j(so.tur_dagilimi));
  k('sınıf: okunan_hikayeler (4 öğrenci, doğru oranı)', so.okunan_hikayeler.length === 1 && so.okunan_hikayeler[0].ogrenci_sayisi === 4 && so.okunan_hikayeler[0].baslik === tur.baslik, j(so.okunan_hikayeler));
  k('sınıf: kavram 4 öğrenci / 3 öğrenen; atasözü (2 öğrenci) min-N altında gizli; kelime (1 öğrenci) gizli',
    so.kavramlar.length === 1 && so.kavramlar[0].ogrenci_sayisi === 4 && so.kavramlar[0].ogrenen_sayisi === 3
      && so.atasozleri.length === 0 && so.kelimeler.length === 0, j([so.kavramlar, so.atasozleri, so.kelimeler]));
  k('sınıf: soru türü doğruluğu yeterli (4 soru, 4 öğrenci)', so.olcme_turu_dogrulugu.metin_kaniti.yeterli === true && so.olcme_turu_dogrulugu.metin_kaniti.soru === 4, j(so.olcme_turu_dogrulugu));
  k('sınıf: yanıtta öğrenci kimliği/adı yok', S.slice(1).every((s) => !j(sinif).includes(s)) && !j(sinif).includes('Ogrenci 1'));
  const kucuk = await ok(T1, 'public.okuma_ogretmen_sinif_ozeti($1, 30)', [C3]);
  k('min-N: 2 okuyan öğrenci → yeterli=false, ozet=null', kucuk.yeterli === false && kucuk.ozet === null && kucuk.okuyan_ogrenci === 2, j(kucuk));
  const baskaSinif = await cagri(T2, 'public.okuma_ogretmen_sinif_ozeti($1, 30)', [C1]);
  k('sınıf: başka sınıfın öğretmeni 42501', baskaSinif.hata?.kod === '42501', j(baskaSinif));

  // --- Öğretmen: bireysel özet -----------------------------------------
  const bir = await ok(T1, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2, 30)', [C1, S[1]]);
  k('bireysel: rıza var → ozet dolu; ad, kavram, atasözü, kelime, tür, kelime sayısı',
    bir.riza === true && bir.ogrenci.ad === 'Ogrenci 1' && bir.ozet.okunan_kelime === 321 && bir.ozet.kavramlar.length === 1
      && bir.ozet.atasozleri.length === 1 && bir.ozet.kelimeler.length === 1 && bir.ozet.tur_dagilimi.length === 1 && bir.ozet.son_hikayeler.length === 2, j(bir));
  const iki = await ok(T1, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[2]]);
  k('bireysel: rıza yok → {riza:false, ozet:null}', iki.riza === false && iki.ozet === null && iki.riza_durumu === 'yok' && !('ogrenci' in iki), j(iki));
  const dort = await ok(T1, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[4]]);
  k('bireysel: rıza geri çekilmiş → ozet:null', dort.riza === false && dort.ozet === null && dort.riza_durumu === 'geri_cekildi', j(dort));
  const uc = await ok(T1, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[3]]);
  k('bireysel: min-N uygulanmaz (3. öğrenci rızalı, tek başına görülür)', uc.riza === true && uc.ozet.okunan_hikaye === 1, j(uc));
  const baskaOgretmen = await cagri(T2, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[1]]);
  k('bireysel: başka sınıfın öğretmeni 42501', baskaOgretmen.hata?.kod === '42501', j(baskaOgretmen));
  const uyeDegil = await cagri(T1, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[5]]);
  k('bireysel: sınıf üyesi olmayan öğrenci 42501', uyeDegil.hata?.kod === '42501', j(uyeDegil));
  const veliCagri = await cagri(V1, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[1]]);
  const ogrCagri = await cagri(S[1], 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[1]]);
  const anon = await cagri(null, 'public.okuma_ogretmen_ogrenci_ozeti($1, $2)', [C1, S[1]]);
  k('bireysel: veli ve öğrenci rolü 42501, anon reddedilir', veliCagri.hata?.kod === '42501' && ogrCagri.hata?.kod === '42501' && !!anon.hata, j([veliCagri, ogrCagri, anon]));
  const nullOgr = await cagri(T1, 'public.okuma_ogretmen_ogrenci_ozeti($1, null)', [C1]);
  k('bireysel: null öğrenci 42501', nullOgr.hata?.kod === '42501', j(nullOgr));

  // --- Sınıf öğrenci listesi -------------------------------------------
  const liste = await ok(T1, 'public.okuma_ogretmen_sinif_ogrencileri($1)', [C1]);
  k('liste: 4 öğrenci, rıza bayrağı doğru (S1,S3 true; S2,S4 false), okuma verisi yok',
    liste.ogrenciler.length === 4 && liste.ogrenciler.find((x) => x.id === S[1]).riza === true && liste.ogrenciler.find((x) => x.id === S[3]).riza === true
      && liste.ogrenciler.find((x) => x.id === S[2]).riza === false && liste.ogrenciler.find((x) => x.id === S[4]).riza === false
      && Object.keys(liste.ogrenciler[0]).sort().join() === 'ad,id,riza', j(liste));
  const listeBaska = await cagri(T2, 'public.okuma_ogretmen_sinif_ogrencileri($1)', [C1]);
  const listeVeli = await cagri(V1, 'public.okuma_ogretmen_sinif_ogrencileri($1)', [C1]);
  const listeAnon = await cagri(null, 'public.okuma_ogretmen_sinif_ogrencileri($1)', [C1]);
  k('liste: başka sınıfın öğretmeni ve veli 42501, anon reddedilir', listeBaska.hata?.kod === '42501' && listeVeli.hata?.kod === '42501' && !!listeAnon.hata, j([listeBaska, listeVeli, listeAnon]));

  // --- Envanter ---------------------------------------------------------
  const bilgi = (await db.query(`select p.proname, p.prosecdef, has_function_privilege('anon', p.oid, 'execute') as anon,
      has_function_privilege('authenticated', p.oid, 'execute') as auth, p.proconfig::text as cfg
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.proname in ('okuma_veli_ozeti', 'okuma_ogretmen_sinif_ozeti', 'okuma_ogretmen_ogrenci_ozeti', 'okuma_ogretmen_sinif_ogrencileri',
     '_okuma_cocuk_ozet', '_okuma_cocuk_hedef_listesi', '_okuma_sinif_hedef_listesi')`)).rows;
  const ac = bilgi.filter((r) => !r.proname.startsWith('_'));
  const ic = bilgi.filter((r) => r.proname.startsWith('_'));
  k('RPC\'ler: SECURITY DEFINER, search_path sabit, authenticated açık, anon kapalı',
    ac.length === 4 && ac.every((r) => r.prosecdef && !r.anon && r.auth && /search_path=/.test(r.cfg)), j(ac));
  k('iç yardımcılar istemciye kapalı', ic.length === 3 && ic.every((r) => r.prosecdef && !r.anon && !r.auth), j(ic));
} catch (e) {
  console.log('BEKLENMEYEN HATA:', e.message);
  sonuc.push(false);
}

const gecen = sonuc.filter(Boolean).length;
console.log(`\nSONUÇ: ${gecen}/${sonuc.length} senaryo geçti`);
process.exit(gecen === sonuc.length && sonuc.length > 0 ? 0 : 1);
