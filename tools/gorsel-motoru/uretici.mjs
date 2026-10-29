// Görselli soru üreticisi (çekirdek). Seçilen şablonlardan adet kadar soru üretir.
// Garantiler (plan §11.5): G1 aynı tohum → aynı çıktı · G2 her 4'lü blokta A–D birer kez ·
// G3 doğru şık şablonun rezerve ettiği konuma yazılır · G4 tekrar yok · G5 tek kazanım kodu, kaynak dosyada var ·
// G6 görsel kapısı · G7 her kayıt durum="beklemede" ile çıkar.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { gorselUret, olguDogrula } from './motor.mjs';

export const SURUM = '1.1.0';
export const HARF = 'ABCD';
const BURASI = path.dirname(fileURLToPath(import.meta.url));
const SABLON_KLASORU = path.join(BURASI, 'sablonlar');
export const DEPO = path.resolve(BURASI, '..', '..');
export const KAZANIM_KLASORU = path.join(DEPO, 'docs', 'soru-uretim', 'pilot');

// Türkçe karakterleri sadeleştirip yalnız a–z0–9 bırakır: "Türkçe" → "turkce", "Fen Bilimleri" → "fenbilimleri".
export function ascii(s) {
  return String(s).toLocaleLowerCase('tr-TR')
    .replace(/ç/g, 'c').replace(/ğ/g, 'g').replace(/ı/g, 'i').replace(/ö/g, 'o').replace(/ş/g, 's').replace(/ü/g, 'u')
    .replace(/[^a-z0-9]/g, '');
}

// Ders (ascii) → kazanım dosyası eki. Burada olmayan ders için kaynak yoktur, üretilmez.
const DERS_EKI = { matematik: 'matematik', fenbilimleri: 'fen', sosyalbilgiler: 'sosyal', hayatbilgisi: 'hayat_bilgisi', turkce: 'turkce' };

export function kazanimDosyasi(ders, sinif) {
  const ek = DERS_EKI[ascii(ders)];
  return ek ? path.join(KAZANIM_KLASORU, `kazanim_${sinif}_${ek}.json`) : null;
}

export function kazanimKodlari(dosya) {
  const j = JSON.parse(fs.readFileSync(dosya, 'utf8'));
  return new Set((j.kazanimlar ?? j.ciktilar).map((k) => k.kod));
}

export function rng(t) {
  return () => { t = (t + 0x6d2b79f5) | 0; let x = Math.imul(t ^ (t >>> 15), 1 | t); x = (x + Math.imul(x ^ (x >>> 7), 61 | x)) ^ x; return ((x ^ (x >>> 14)) >>> 0) / 4294967296; };
}

export async function kayitlariYukle() {
  const liste = [];
  for (const d of fs.readdirSync(SABLON_KLASORU).filter((x) => x.endsWith('.mjs')).sort()) {
    const m = await import(pathToFileURL(path.join(SABLON_KLASORU, d)).href);
    for (const k of m.KAYIT ?? []) liste.push({ ...k, dosya: d });
  }
  return liste;
}

// Kayıt sözleşmesi: alanlar tam, id benzersiz, tam bir kazanım kodu, kod kaynak kazanım dosyasında.
// Boş dönüş = sağlıklı. Sorun varsa üretim başlamaz.
export function kayitlariDogrula(liste) {
  const sorunlar = [], idler = new Set();
  for (const k of liste) {
    const ad = k.id ?? `(id yok: ${k.dosya})`;
    for (const alan of ['id', 'ders', 'sinif', 'idOnek', 'mufredat_surum']) if (!k[alan]) sorunlar.push(`${ad}: ${alan} eksik`);
    if (idler.has(k.id)) sorunlar.push(`${ad}: id tekrarı`);
    idler.add(k.id);
    if (!Number.isInteger(k.sinif) || k.sinif < 1 || k.sinif > 8) sorunlar.push(`${ad}: sınıf 1–8 olmalı`);
    if (!Array.isArray(k.kodlar) || k.kodlar.length !== 1) sorunlar.push(`${ad}: tam bir kazanım kodu olmalı`);
    if (typeof k.fabrika !== 'function' || typeof k.uret !== 'function') sorunlar.push(`${ad}: fabrika/uret işlevi yok`);
    const dosya = kazanimDosyasi(k.ders, k.sinif);
    if (!dosya) { sorunlar.push(`${ad}: "${k.ders}" için kazanım kaynağı tanımlı değil`); continue; }
    if (!fs.existsSync(dosya)) { sorunlar.push(`${ad}: kazanım dosyası yok (${path.basename(dosya)})`); continue; }
    const kodlar = kazanimKodlari(dosya);
    for (const kod of k.kodlar ?? []) if (!kodlar.has(kod)) sorunlar.push(`${ad}: ${kod} kaynak dosyada yok`);
  }
  return sorunlar;
}

// Ders/sınıf/kod filtresi. Ders adı ascii ön eki ile eşleşir ("turkce", "Türkçe", "fen" çalışır).
export function secKayitlar(tum, { ders, sinif, kod } = {}) {
  const d = ders ? ascii(ders) : '';
  return tum.filter((k) => (!d || ascii(k.ders).startsWith(d)) && (!sinif || k.sinif === Number(sinif)) && (!kod || k.kodlar.includes(kod)));
}

// Her (ders, sınıf, kazanım kodu) üçlüsü bir gruptur; --hepsi çıktısında bir klasöre karşılık gelir.
export function grupla(tum) {
  const m = new Map();
  for (const k of tum) for (const kod of k.kodlar) {
    const anahtar = `${ascii(k.ders)}|${k.sinif}|${kod}`;
    if (!m.has(anahtar)) m.set(anahtar, { ders: k.ders, sinif: k.sinif, kod, kayitlar: [] });
    m.get(anahtar).kayitlar.push(k);
  }
  return [...m.values()].sort((x, y) => x.sinif - y.sinif || ascii(x.ders).localeCompare(ascii(y.ders)) || x.kod.localeCompare(y.kod));
}

// Doğru şık dengesi: harf sayıları ve her tam 4'lü blokta A–D'nin birer kez geçip geçmediği.
export function dengeOzeti(sorular) {
  const harf = { A: 0, B: 0, C: 0, D: 0 };
  for (const q of sorular) harf[q.dogru_sik] += 1;
  const bozuk = [];
  let dengeli = 0;
  const tam = Math.floor(sorular.length / 4);
  for (let b = 0; b < tam; b++) {
    const blok = new Set(sorular.slice(b * 4, b * 4 + 4).map((q) => q.dogru_sik));
    if (blok.size === 4) dengeli++; else bozuk.push(b + 1);
  }
  return { harf, tam_blok: tam, dengeli_blok: dengeli, bozuk_blok: bozuk };
}

// Üretim çekirdeği. Şablonlar ctx = { R, sec, karistir, ekle, konum } alır.
export function uretKayitlar(secilen, { adet = 20, tohum = 1 } = {}) {
  if (!secilen.length) throw new Error('şablon_yok');
  const R = rng(tohum);
  const sec = (d) => d[Math.floor(R() * d.length)];
  const karistir = (d) => { const a = [...d]; for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(R() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };

  const sorular = [], gorulen = new Set();
  const istatistik = { istenen: adet, tohum, denenen: 0, atilan: {}, sablonlar: secilen.map((s) => s.id) };
  let sayac = 0, aktif = null, bekleyen = null;

  // Blok başına bir kez karıştırılmış A–D sırası: her 4 soruda her harf birer kez, sıra tahmin edilemez.
  const bloklar = new Map();
  const slotAt = (n) => {
    const b = Math.floor(n / 4);
    if (!bloklar.has(b)) bloklar.set(b, karistir([0, 1, 2, 3]));
    return bloklar.get(b)[n % 4];
  };
  // Konum rezervi: ekle() başarılı olana dek aynı konum kalır; başarısız bir deneme dengeyi bozmaz.
  const konum = () => { if (bekleyen === null) bekleyen = slotAt(sayac); return bekleyen; };

  function ekle({ kod: kz, konu, alt_konu, kok, dogru, celdirici, sirali: sabit, gerekce, ipucu, cozum, zorluk, spec, dogrulama, olcekli = true }) {
    if (!aktif.kodlar.includes(kz)) throw new Error('kod_sablonda_yok');
    const k = konum();
    let sirali;
    if (sabit) {
      if (sabit.length !== 4) throw new Error('sik_sayisi_4_olmali');
      if (sabit.map(String).indexOf(String(dogru)) !== k) throw new Error('konum_uyumsuz');
      sirali = sabit.map(String);
    } else {
      if (!celdirici || celdirici.length !== 3) throw new Error('celdirici_3_olmali');
      sirali = celdirici.map(String);
      sirali.splice(k, 0, String(dogru));
    }
    if (new Set(sirali).size !== 4) throw new Error('sik_tekrar');
    const celdiriciGerekce = {};
    let c = 0;
    for (let i = 0; i < 4; i++) {
      if (i === k) { celdiriciGerekce[HARF[i]] = 'Doğru.'; continue; }
      const g = sabit ? gerekce[i] : gerekce[c++];
      if (!g || !String(g).trim()) throw new Error('gerekce_eksik');
      celdiriciGerekce[HARF[i]] = g;
    }
    const g = gorselUret(spec, aktif.sinif);
    const sorun = [...g.bulgular.filter((b) => b.ciddiyet === 'hata').map((b) => `${b.kural}:${b.mesaj}`), ...olguDogrula(g.olgular, dogrulama)];
    if (sorun.length) throw new Error(`gorsel_kapisi:${sorun.join('; ')}`);
    const siklar = Object.fromEntries(sirali.map((m, i) => [HARF[i], m]));
    // Tekrar (G4) içerik bazlıdır: harf sırası değişse de aynı kök, görsel, doğru metin ve şık kümesi aynı sorudur.
    const parmak = [ascii(kok), JSON.stringify(spec), ascii(dogru), [...sirali].map(ascii).sort().join('|')].join('|');
    if (gorulen.has(parmak)) throw new Error('tekrar_soru');
    gorulen.add(parmak);
    const dogru_sik = HARF[k];
    sorular.push({
      id: `${aktif.idOnek}-S${tohum}-${String(sorular.length + 1).padStart(3, '0')}`,
      sinif: aktif.sinif, ders: aktif.ders, mufredat_surum: aktif.mufredat_surum,
      kazanim_kodu: kz, konu, alt_konu, soru_metni: kok, siklar, dogru_sik, ipucu,
      cozum_adimlari: [...cozum, `Doğru cevap ${dogru_sik} seçeneğidir.`],
      celdirici_gerekce: celdiriciGerekce, zorluk, zorluk_kaynagi: 'model_tahmini',
      soru_tipi: 'gorsel_okuma', gorsel_gerekli: true,
      gorsel: { tur: 'svg_spec', tip_id: spec.tip_id, svg: g.svg, alt_metin: g.alt, olcekli },
      gorsel_spec: spec, gorsel_dogrulama: dogrulama, uretim_yontemi: 'sablon', sablon_id: aktif.id,
      kaynak_turu: 'ozgun_sablon', durum: 'beklemede', insan_onayi: null,
    });
    sayac += 1;
    bekleyen = null;
  }

  const ctx = { R, sec, karistir, ekle, konum };
  const fabrikalar = new Map();
  const ustSinir = adet * 60;
  let i = 0;
  while (sorular.length < adet && istatistik.denenen < ustSinir) {
    const t = secilen[i++ % secilen.length];
    istatistik.denenen += 1;
    aktif = t;
    try {
      if (!fabrikalar.has(t.id)) fabrikalar.set(t.id, t.fabrika(ctx));
      t.uret(fabrikalar.get(t.id), ctx);
    } catch (e) {
      const neden = String(e.message).split(':')[0];
      istatistik.atilan[neden] = (istatistik.atilan[neden] ?? 0) + 1;
    }
  }
  const cikti = sorular.slice(0, adet);
  istatistik.uretilen = cikti.length;
  istatistik.eksik = adet - cikti.length;
  return { sorular: cikti, istatistik };
}

// Tek seçim: ders/sınıf/kod filtresiyle kayıtları bulur ve üretir.
export async function uret({ ders, sinif, kod, adet = 20, tohum = 1 } = {}) {
  const secilen = secKayitlar(await kayitlariYukle(), { ders, sinif, kod });
  if (!secilen.length) throw new Error(`şablon_yok: ders=${ders ?? '*'} sinif=${sinif ?? '*'} kod=${kod ?? '*'}`);
  return uretKayitlar(secilen, { adet, tohum });
}
