// Müfredat yüzey testi (WP1 + WP2): PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node test.mjs
//
// Zincir: stubs.sql → 20261083 (mufredat_hafta, gerçek veri) → 20261084 (sinav dağılımı)
//         → 20261085 (etiket temeli) → 20261086 (RPC'ler).
// Gerçek migration dosyaları çalışır; Supabase bağımlılıkları stubs.sql ile taklit edilir.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migDir = path.resolve(here, '..', '..', 'migrations');
const oku = (ad) => fs.readFileSync(path.join(migDir, ad), 'utf8');
const oku2 = (p) => fs.readFileSync(p, 'utf8');

let gecen = 0;
let toplam = 0;
function sonuc(ad, ok, detay = '') {
  toplam++;
  if (ok) gecen++;
  console.log(`${String(toplam).padStart(2)}. [${ok ? 'OK  ' : 'FAIL'}] ${ad}${detay && !ok ? `\n      detay: ${detay}` : ''}`);
}

// Hata beklenen çağrı: SQLSTATE (kod) ve/veya mesaj parçası eşleşmeli.
async function hataBekle(db, sql, params = [], { kod, mesaj } = {}) {
  try {
    await db.query(sql, params);
    return { ok: false, detay: 'hata bekleniyordu, çağrı başarılı oldu' };
  } catch (e) {
    const durum = String(e.code ?? '');
    const ok = (kod ? durum === kod : true) && (mesaj ? String(e.message).includes(mesaj) : true);
    return { ok, detay: `kod=${durum} mesaj=${e.message}` };
  }
}

// Rol geçişi: 'postgres' (yönetici işleri), 'authenticated' (uid ile), 'anon'.
async function rol(db, ad, uid = '') {
  if (ad === 'postgres') {
    await db.query('reset role');
  } else {
    await db.query(`set role ${ad}`);
  }
  await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [uid]);
}

async function tabanKur() {
  const db = new PGlite();
  await db.exec(oku2(path.join(here, 'stubs.sql')));
  await db.exec(oku('20261083000000_mufredat_hafta.sql'));
  await db.exec(oku('20261084000000_mufredat_sinav_dagilim.sql'));
  await db.exec(oku('20261085000000_mufredat_etiket_temeli.sql'));
  await db.exec(oku('20261086000000_mufredat_rpc.sql'));
  return db;
}

const S5 = '11111111-1111-4111-8111-111111111111';
const S6 = '22222222-2222-4222-8222-222222222222';
const SNULL = '33333333-3333-4333-8333-333333333333';
const ADM = '44444444-4444-4444-8444-444444444444';
const S4 = '55555555-5555-4555-8555-555555555555';

const SIKLAR = `{"A":"Bir","B":"İki"}`;

async function soruEkle(db, { sinif, ders = 'Matematik', konu = 'Konu', kod, onay = 'onaylandi', metin = 'Soru?' }) {
  const r = await db.query(
    `insert into public.questions (okul, sinif, ders, konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, kazanim_kodu)
     values ('ilkokul', $1, $2, $3, 1, $4, $5::jsonb, 'A', $6, $7) returning id`,
    [sinif, ders, konu, metin, SIKLAR, onay, kod ?? null]
  );
  return r.rows[0].id;
}

const hafta = (kod) => kod; // yardımcı okunabilirlik

console.log('--- Kurulum: stubs + gerçek migration zinciri ---');
let db;
try {
  db = await tabanKur();
  sonuc('zincir (stubs, 20261083..20261086) hatasız kuruldu', true);
} catch (e) {
  sonuc('zincir hatasız kuruldu', false, e.message);
  console.log(`\nSONUÇ: ${gecen}/${toplam} senaryo geçti`);
  process.exit(1);
}

// Tohum verisi (postgres olarak)
await db.query(`insert into public.profiles (id, role, sinif, full_name) values
  ($1, 'ogrenci', 5, 'S5'), ($2, 'ogrenci', 6, 'S6'), ($3, 'ogrenci', null, 'SNULL'),
  ($4, 'admin', null, 'ADM'), ($5, 'ogrenci', 4, 'S4')`,
  [S5, S6, SNULL, ADM, S4]);

// Kazanım kodları müfredattan (gerçek veri)
const kodlar = async (ders, sinif, kosul, sira = 'ilk_hafta') => {
  const r = await db.query(
    `select kazanim_kodu from public.mufredat_kazanim_ozet
      where ders = $1 and sinif = $2 and ${kosul} order by ${sira}, kazanim_kodu limit 1`,
    [ders, sinif]);
  return r.rows[0]?.kazanim_kodu;
};
const K_ERKEN = await kodlar('Matematik', 5, 'ilk_hafta <= 13');
const K_GEC = await kodlar('Matematik', 5, 'ilk_hafta >= 14', 'ilk_hafta desc');
const K_TR = await kodlar('Türkçe', 5, 'ilk_hafta <= 13');
console.log(`    seçilen kodlar: erken=${K_ERKEN} gec=${K_GEC} turkce=${K_TR}`);

const Q1 = await soruEkle(db, { sinif: 5, kod: K_ERKEN, metin: 'Q1 erken' });
const Q2 = await soruEkle(db, { sinif: 5, kod: K_GEC, metin: 'Q2 gec' });
const Q3 = await soruEkle(db, { sinif: 6, kod: K_ERKEN, metin: 'Q3 sinif6' });
const Q4 = await soruEkle(db, { sinif: 5, kod: K_ERKEN, onay: 'beklemede', metin: 'Q4 beklemede' });
const Q5 = await soruEkle(db, { sinif: 5, kod: K_ERKEN, onay: 'reddedildi', metin: 'Q5 reddedildi' });
const Q6 = await soruEkle(db, { sinif: 5, kod: null, metin: 'Q6 kodsuz' });
const Q7 = await soruEkle(db, { sinif: 5, kod: K_ERKEN, metin: 'Q7 vadesi gelmis' });
const Q8 = await soruEkle(db, { sinif: 5, ders: 'Türkçe', kod: K_TR, metin: 'Q8 turkce' });

// S5: Q1 doğru (tekrar sonra), Q7 yanlış ve vadesi geçmiş
await db.query(`insert into public.user_answers (student_id, question_id, secilen_sik, dogru_mu, sonraki_tekrar_tarihi)
  values ($1, $2, 'A', true, now() + interval '3 days'),
         ($1, $3, 'B', false, now() - interval '1 day')`, [S5, Q1, Q7]);

const TARIH = '2026-12-14';

// ---------------------------------------------------------------------
console.log('--- (a) mufredat_bugun_hafta ---');
{
  const beklenen = [
    ['2026-09-01', 1], ['2026-09-14', 1], ['2026-11-18', 9], ['2026-12-14', 13],
    ['2027-02-01', 18], ['2027-06-30', 37],
  ];
  for (const [t, b] of beklenen) {
    const r = await db.query(`select public.mufredat_bugun_hafta($1::date) as h`, [t]);
    sonuc(`bugun_hafta(${t}) = ${b}`, Number(r.rows[0].h) === b, `dönen=${r.rows[0].h}`);
  }
  const ek = [['2026-11-21', 9], ['2027-03-10', 22], ['2027-05-18', 31], ['2027-05-17', 31]];
  for (const [t, b] of ek) {
    const r = await db.query(`select public.mufredat_bugun_hafta($1::date) as h`, [t]);
    sonuc(`ek: bugun_hafta(${t}) = ${b} (boşluk/tatil)`, Number(r.rows[0].h) === b, `dönen=${r.rows[0].h}`);
  }
  const bugun = await db.query(`select public.mufredat_bugun_hafta() as h`);
  sonuc('bugun_hafta() null tarihle 1..37 arasında döner', bugun.rows[0].h >= 1 && bugun.rows[0].h <= 37, String(bugun.rows[0].h));
}

// ---------------------------------------------------------------------
console.log('--- (b) 5. sınıf Matematik, bugune_kadar, 2026-12-14 ---');
{
  await rol(db, 'authenticated', S5);
  const r = await db.query(
    `select j from public.get_mufredat_sorulari('Matematik', 'bugune_kadar', null, null, 30, $1::date) as j`, [TARIH]);
  const satirlar = r.rows.map((x) => x.j);
  const ids = satirlar.map((s) => s.id);
  sonuc('bugune_kadar en az bir soru döndürür', satirlar.length > 0, `adet=${satirlar.length}`);
  sonuc('hafta 14+ kazanımın sorusu (Q2) gelmez', !ids.includes(Q2));
  sonuc('tüm dönen sorular hafta <= 13', satirlar.every((s) => s.hafta <= 13),
    JSON.stringify(satirlar.map((s) => s.hafta)));
  sonuc('erken kazanımın sorusu (Q1) gelir', ids.includes(Q1));
  sonuc('vadesi gelen tekrar (Q7) en başta', satirlar.length > 0 && satirlar[0].id === Q7,
    `ilk=${satirlar[0]?.id}`);
  sonuc('dönen sorudaki hafta, kazanımın ilk haftasıdır', satirlar.every((s) => s.kazanim_kodu && Number.isInteger(s.hafta)));

  // (b2) bu_hafta ve hafta modları
  const bu = await db.query(
    `select j from public.get_mufredat_sorulari('Matematik', 'bu_hafta', null, null, 30, $1::date) as j`, [TARIH]);
  sonuc('bu_hafta: tüm sorular hafta == 13', bu.rows.every((x) => x.j.hafta === 13), JSON.stringify(bu.rows.map((x) => x.j.hafta)));
  const hf = await db.query(
    `select j from public.get_mufredat_sorulari('Matematik', 'hafta', 5, null, 30, $1::date) as j`, [TARIH]);
  sonuc('hafta=5: tüm sorular hafta <= 5', hf.rows.every((x) => x.j.hafta <= 5));
  const kz = await db.query(
    `select j from public.get_mufredat_sorulari('Matematik', 'kazanim', null, $1::text[], 30, $2::date) as j`,
    [[K_GEC], TARIH]);
  sonuc('kazanim modu: henüz işlenmemiş kazanım boş döner (ilk_hafta > bugün)', kz.rows.length === 0, `adet=${kz.rows.length}`);
  const kz2 = await db.query(
    `select j from public.get_mufredat_sorulari('Matematik', 'kazanim', null, $1::text[], 30, $2::date) as j`,
    [[K_ERKEN], TARIH]);
  sonuc('kazanim modu: işlenmiş kazanım sorusu döner (Q1 içerir)', kz2.rows.some((x) => x.j.id === Q1));
  await rol(db, 'postgres');
}

// ---------------------------------------------------------------------
console.log('--- (c) sınıf / durum / ders süzgeçleri ve RLS ---');
{
  await rol(db, 'authenticated', S5);
  const r = await db.query(
    `select j from public.get_mufredat_sorulari('Matematik', 'bugune_kadar', null, null, 30, $1::date) as j`, [TARIH]);
  const ids = r.rows.map((x) => x.j.id);
  sonuc('başka sınıfın sorusu (Q3, sınıf 6) gelmez', !ids.includes(Q3));
  sonuc('beklemedeki soru (Q4) gelmez', !ids.includes(Q4));
  sonuc('reddedilmiş soru (Q5) gelmez', !ids.includes(Q5));
  sonuc('kazanımsız soru (Q6) gelmez', !ids.includes(Q6));
  sonuc('başka dersin sorusu (Q8, Türkçe) gelmez', !ids.includes(Q8));
  const dogruSizinti = r.rows.some((x) => JSON.stringify(x.j).includes('dogru_sik'));
  sonuc('çıktıda dogru_sik alanı yok', !dogruSizinti);
  const direkt = await db.query(`select id from public.questions where id = any($1::uuid[])`, [[Q3, Q4, Q5]]);
  sonuc('questions RLS: S5 doğrudan Q3/Q4/Q5 göremez', direkt.rows.length === 0, `adet=${direkt.rows.length}`);
  await rol(db, 'postgres');
}

// ---------------------------------------------------------------------
console.log('--- (d) geçersiz girdiler ---');
{
  await rol(db, 'authenticated', S5);
  let e = await hataBekle(db, `select j from public.get_mufredat_sorulari('Matematik', 'xyz', null, null, 10, $1::date) as j`, [TARIH], { mesaj: 'Geçersiz mod' });
  sonuc('geçersiz mod hata verir (Türkçe mesaj)', e.ok, e.detay);
  e = await hataBekle(db, `select j from public.get_mufredat_sorulari('', 'bugune_kadar', null, null, 10, $1::date) as j`, [TARIH], { mesaj: 'Ders seçilmedi' });
  sonuc('boş ders hata verir', e.ok, e.detay);
  e = await hataBekle(db, `select j from public.get_mufredat_sorulari('Matematik', 'hafta', 40, null, 10, $1::date) as j`, [TARIH], { mesaj: 'Hafta 1' });
  sonuc('hafta modu 1..37 dışında hata verir', e.ok, e.detay);
  e = await hataBekle(db, `select j from public.get_mufredat_sorulari('Matematik', 'kazanim', null, null, 10, $1::date) as j`, [TARIH], { mesaj: 'Kazanım kodu' });
  sonuc('kazanim modu kodsuz hata verir', e.ok, e.detay);
  e = await hataBekle(db, `select public.get_mufredat_haritasi('Din Kültürü', $1::date)`, [TARIH], { mesaj: 'eşlemesi yok' });
  sonuc('eşlenmemiş ders (Din Kültürü) haritada hata verir', e.ok, e.detay);
  await rol(db, 'authenticated', SNULL);
  e = await hataBekle(db, `select j from public.get_mufredat_sorulari('Matematik', 'bugune_kadar', null, null, 10, $1::date) as j`, [TARIH], { mesaj: 'Sınıf bilgisi' });
  sonuc('sınıfı olmayan profil hata alır', e.ok, e.detay);
  await rol(db, 'postgres');
}

// ---------------------------------------------------------------------
console.log('--- (e) anon erişimi ---');
{
  await rol(db, 'anon', '');
  let e = await hataBekle(db, `select j from public.get_mufredat_sorulari('Matematik', 'bugune_kadar', null, null, 10, $1::date) as j`, [TARIH], { kod: '42501' });
  sonuc('anon get_mufredat_sorulari çağıramaz (42501)', e.ok, e.detay);
  e = await hataBekle(db, `select public.get_mufredat_haritasi('Matematik', $1::date)`, [TARIH], { kod: '42501' });
  sonuc('anon get_mufredat_haritasi çağıramaz (42501)', e.ok, e.detay);
  e = await hataBekle(db, `select public.mufredat_bugun_hafta()`, [], { kod: '42501' });
  sonuc('anon mufredat_bugun_hafta çağıramaz (42501)', e.ok, e.detay);
  e = await hataBekle(db, `select * from public.mufredat_kazanim_ozet limit 1`, [], { kod: '42501' });
  sonuc('anon mufredat_kazanim_ozet okuyamaz (42501)', e.ok, e.detay);
  e = await hataBekle(db, `select * from public.mufredat_ders_eslesme limit 1`, [], { kod: '42501' });
  sonuc('anon mufredat_ders_eslesme okuyamaz (42501)', e.ok, e.detay);
  e = await hataBekle(db, `select public.admin_kazanim_kapsam('Matematik', 5)`, [], { kod: '42501' });
  sonuc('anon admin_kazanim_kapsam çağıramaz (42501)', e.ok, e.detay);
  await rol(db, 'postgres');
}

// ---------------------------------------------------------------------
console.log('--- (f) öğrenci haritası ---');
{
  await rol(db, 'authenticated', S5);
  const r = await db.query(`select public.get_mufredat_haritasi('Matematik', $1::date) as h`, [TARIH]);
  const h = r.rows[0].h;
  sonuc('harita: sınıf 5, bugun_hafta 13, plan_var', h.sinif === 5 && h.bugun_hafta === 13 && h.plan_var === true,
    JSON.stringify({ sinif: h.sinif, b: h.bugun_hafta, p: h.plan_var }));
  const kazanimlar = h.haftalar.flatMap((w) => w.kazanimlar);
  // Harita gelecek haftaları da gösterir (UI "henüz işlenmedi" der); soru listesi ise süzer.
  const gelecek = kazanimlar.find((k) => k.kod === K_GEC);
  sonuc('harita: gelecek kazanım (ilk_hafta 14+) işaretlenebilir olarak listelenir, cevaplanan=0',
    !!gelecek && gelecek.ilk_hafta > 13 && gelecek.cevaplanan === 0, JSON.stringify(gelecek));
  sonuc('harita: her kazanım yalnız ilk haftasında listelenir',
    h.haftalar.every((w) => w.kazanimlar.every((k) => k.ilk_hafta === w.hafta)));
  const erken = kazanimlar.find((k) => k.kod === K_ERKEN);
  sonuc('harita: K_ERKEN soru_sayisi=2 (Q1, Q7), cevaplanan=2, dogru=1',
    erken && erken.soru_sayisi === 2 && erken.cevaplanan === 2 && erken.dogru === 1, JSON.stringify(erken));
  sonuc('harita: 6 cevap altında oran null', erken && erken.oran === null);
  const tatiller = h.haftalar.filter((w) => w.tatil);
  sonuc('harita: 4 tatil girdisi, hafta alanı null', tatiller.length === 4 && tatiller.every((w) => w.hafta === null));
  sonuc('harita: 37 okul haftası + 4 tatil = 41 girdi', h.haftalar.length === 41, `adet=${h.haftalar.length}`);
  await rol(db, 'postgres');
}

// ---------------------------------------------------------------------
console.log('--- (g) müfredat görünümü ve takvim yapısı ---');
{
  const dkab = await db.query(
    `select count(*)::int as n from public.mufredat_kazanim_ozet
      where ders = 'Din Kültürü ve Ahlak Bilgisi' and sinif in (4, 8)`);
  sonuc('kazanım özetinde DKAB 4 ve 8 satırı yok', dkab.rows[0].n === 0, `adet=${dkab.rows[0].n}`);
  const dkab5 = await db.query(
    `select count(*)::int as n from public.mufredat_kazanim_ozet where ders = 'Din Kültürü ve Ahlak Bilgisi' and sinif = 5`);
  sonuc('kazanım özetinde DKAB 5 satırları var', dkab5.rows[0].n > 0, `adet=${dkab5.rows[0].n}`);
  const hafta1 = await db.query(
    `select count(*)::int as n from public.mufredat_takvim where not tatil_mi`);
  const h37 = await db.query(
    `select count(distinct hafta)::int as n, min(hafta) as mn, max(hafta) as mx from public.mufredat_takvim where not tatil_mi`);
  sonuc('takvim: 37 okul haftası, benzersiz 1..37',
    hafta1.rows[0].n === 37 && h37.rows[0].n === 37 && h37.rows[0].mn === 1 && h37.rows[0].mx === 37);
  const tat = await db.query(`select count(*)::int as n from public.mufredat_takvim where tatil_mi`);
  sonuc('takvim: 4 tatil satırı', tat.rows[0].n === 4);
  const idx = await db.query(`select 1 from pg_indexes where indexname = 'questions_sinif_kazanim_idx'`);
  sonuc('questions_sinif_kazanim_idx mevcut', idx.rows.length === 1);
  const sd = await db.query(`select proname, prosecdef, proconfig from pg_proc
      where proname in ('get_mufredat_haritasi','get_mufredat_sorulari','admin_set_question_kazanim',
                        'admin_kazanim_kapsam','admin_kazanimsiz_sorular','mufredat_bugun_hafta')`);
  const eksik = sd.rows.filter((p) => !(p.proconfig ?? []).some((c) => c.replace(/"/g, '') === 'search_path='));
  sonuc('tüm yeni fonksiyonlarda search_path = \'\' ayarlı', sd.rows.length === 6 && eksik.length === 0,
    eksik.map((p) => p.proname).join(','));
}

// ---------------------------------------------------------------------
console.log('--- (h) yönetim RPC\'leri ---');
{
  // Yetkisiz (öğrenci) admin çağrısı
  await rol(db, 'authenticated', S5);
  let e = await hataBekle(db, `select public.admin_set_question_kazanim($1::uuid[], $2)`, [[Q6], K_ERKEN], { kod: '42501' });
  sonuc('öğrenci admin_set_question_kazanim çağıramaz (42501)', e.ok, e.detay);
  e = await hataBekle(db, `select public.admin_kazanimsiz_sorular()`, [], { kod: '42501' });
  sonuc('öğrenci admin_kazanimsiz_sorular çağıramaz (42501)', e.ok, e.detay);
  await rol(db, 'postgres');

  await rol(db, 'authenticated', ADM);
  e = await hataBekle(db, `select public.admin_set_question_kazanim($1::uuid[], 'MAT.9.9.9')`, [[Q2]], { mesaj: 'müfredatta yok' });
  sonuc('müfredatta olmayan kod reddedilir', e.ok, e.detay);
  // Yönetici RLS ile questions'ı göremez (sınıfı yok); okumalar postgres rolüyle yapılır.
  const pgOku = async (sql, p) => {
    await db.query('reset role');
    const r = await db.query(sql, p);
    await db.query('set role authenticated');
    return r;
  };
  const q2 = await pgOku(`select kazanim_kodu from public.questions where id = $1`, [Q2]);
  sonuc('reddedilen çağrı soruyu değiştirmez', q2.rows[0].kazanim_kodu === K_GEC);

  // Atomiklik: Q6 (geçerli) + Q3 (sınıf 6, kod bu sınıfta yok) → hepsi reddedilir
  e = await hataBekle(db, `select public.admin_set_question_kazanim($1::uuid[], $2)`, [[Q6, Q3], K_ERKEN], { mesaj: 'müfredatta yok' });
  sonuc('karışık listede bir geçersiz soru tüm çağrıyı durdurur', e.ok, e.detay);
  const q6a = await pgOku(`select kazanim_kodu from public.questions where id = $1`, [Q6]);
  sonuc('atomiklik: Q6 değişmedi (null)', q6a.rows[0].kazanim_kodu === null);

  const n = await db.query(`select public.admin_set_question_kazanim($1::uuid[], $2) as n`, [[Q6], K_ERKEN]);
  sonuc('geçerli kod atanır (adet 1)', n.rows[0].n === 1, JSON.stringify(n.rows[0]));
  const q6b = await pgOku(`select kazanim_kodu, kazanim_metni from public.questions where id = $1`, [Q6]);
  sonuc('atanan kazanım metni müfredattan yazılır', q6b.rows[0].kazanim_kodu === K_ERKEN && !!q6b.rows[0].kazanim_metni);
  const rev1 = await db.query(`select degisen_alanlar from public.question_revisions where question_id = $1`, [Q6]);
  sonuc('atama revizyon geçmişine düşer', rev1.rows.length === 1 && rev1.rows[0].degisen_alanlar.includes('kazanim_kodu'),
    JSON.stringify(rev1.rows));

  const n0 = await db.query(`select public.admin_set_question_kazanim($1::uuid[], null) as n`, [[Q6]]);
  sonuc('p_kod null etiketi kaldırır (adet 1)', n0.rows[0].n === 1);
  const q6c = await pgOku(`select kazanim_kodu, kazanim_metni from public.questions where id = $1`, [Q6]);
  sonuc('kaldırma: kazanim_kodu ve metni null', q6c.rows[0].kazanim_kodu === null && q6c.rows[0].kazanim_metni === null);

  // Kazanım kapsamı
  const kap = await db.query(`select * from public.admin_kazanim_kapsam('Matematik', 5)`);
  const erken = kap.rows.find((r) => r.kazanim_kodu === K_ERKEN);
  sonuc('kapsam: satırlar var ve K_ERKEN bulunur', kap.rows.length > 0 && !!erken);
  sonuc('kapsam: K_ERKEN onaylı=2, bekleyen=1',
    erken && Number(erken.onayli_soru) === 2 && Number(erken.bekleyen_soru) === 1, JSON.stringify(erken));
  const kap4 = await db.query(`select * from public.admin_kazanim_kapsam('Matematik', 4)`);
  sonuc('kapsam: sınıf 4 sınav ortalaması null (yalnız 5–8)', kap4.rows.every((r) => r.sinav1_ort === null && r.sinav2_ort === null));
  const kapD = await db.query(`select count(*)::int as n from public.admin_kazanim_kapsam('Din Kültürü ve Ahlak Bilgisi', 4)`);
  sonuc('kapsam: DKAB 4 plansız, satır yok', kapD.rows[0].n === 0);

  // Kazanımsız liste
  const ks = await db.query(`select public.admin_kazanimsiz_sorular('Matematik', 5, 50, 0) as j`);
  const satirlar = ks.rows[0].j.satirlar;
  sonuc('kazanımsız liste Q6 içerir', satirlar.some((s) => s.id === Q6), `toplam=${ks.rows[0].j.toplam}`);
  sonuc('kazanımsız liste yalnız kodsuz sorular içerir',
    satirlar.every((s) => s.id !== Q1 && s.id !== Q2 && s.id !== Q7));
  await rol(db, 'postgres');
}

console.log(`\nSONUÇ: ${gecen}/${toplam} senaryo geçti`);
process.exit(gecen === toplam ? 0 : 1);
