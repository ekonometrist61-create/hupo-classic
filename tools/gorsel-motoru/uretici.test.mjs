import test from 'node:test';
import assert from 'node:assert/strict';
import { kayitlariYukle, kayitlariDogrula, secKayitlar, uret, uretKayitlar, dengeOzeti, ascii, kazanimDosyasi } from './uretici.mjs';

// ---- kayıt sözleşmesi ----
test('kayıt sözleşmesi: alanlar tam, id benzersiz, tek kod, kod kaynak kazanım dosyasında', async () => {
  const k = await kayitlariYukle();
  assert.ok(k.length >= 17, `şablon sayısı ${k.length}`);
  assert.deepEqual(kayitlariDogrula(k), []);
});

test('kayıt doğrulaması bozuk kaydı yakalar (kod yok, kaynak yok, id tekrarı)', () => {
  const iyi = { id: 'a', ders: 'Matematik', sinif: 5, idOnek: 'A', mufredat_surum: 'x', kodlar: ['MAT.5.5.1'], fabrika: () => 0, uret: () => 0, dosya: 'x' };
  const kotu = [
    { ...iyi, id: 'b', kodlar: ['MAT.5.9.9'] },
    { ...iyi, id: 'c', ders: 'İngilizce', kodlar: ['EN.5.1'] },
    { ...iyi, id: 'a' },
    { ...iyi, id: 'a' },
  ];
  const sorun = kayitlariDogrula(kotu).join('\n');
  assert.match(sorun, /MAT\.5\.9\.9 kaynak dosyada yok/);
  assert.match(sorun, /"İngilizce" için kazanım kaynağı tanımlı değil/);
  assert.match(sorun, /id tekrarı/);
});

// ---- ders eşleşmesi ----
test('ders eşleşmesi Türkçe karakterden bağımsız (turkce = Türkçe, fen = Fen Bilimleri)', async () => {
  const k = await kayitlariYukle();
  const ids = (ders, sinif) => secKayitlar(k, { ders, sinif }).map((x) => x.id);
  assert.ok(ids('turkce', 5).includes('tr5-duyuru'));
  assert.deepEqual(ids('turkce', 5), ids('Türkçe', 5));
  assert.ok(ids('fen', 5).includes('fen5-dinamometre'));
  assert.ok(ids('Sosyal Bilgiler', 5).includes('sb5-ana-yon'));
  assert.ok(ids('hayat', 1).includes('hb1-trafik-isigi'));
  assert.equal(ascii('Türkçe'), 'turkce');
  assert.equal(ascii('Fen Bilimleri'), 'fenbilimleri');
});

test('kaynağı olmayan ders (İngilizce, Din) üretilmez ve açık hata verir', async () => {
  await assert.rejects(() => uret({ ders: 'İngilizce', sinif: 5, adet: 1 }), /şablon_yok/);
  assert.equal(kazanimDosyasi('Din Kültürü', 5), null);
});

// ---- üretim sözleşmesi ----
test('üretim sözleşmesi: adet, benzersiz id, beklemede, görsel, çözüm son satırı, gerekçeler', async () => {
  const { sorular, istatistik } = await uret({ ders: 'matematik', sinif: 5, adet: 24, tohum: 3 });
  assert.equal(sorular.length, 24);
  assert.equal(istatistik.eksik, 0);
  assert.equal(new Set(sorular.map((q) => q.id)).size, 24);
  for (const q of sorular) {
    assert.equal(q.durum, 'beklemede');
    assert.equal(q.insan_onayi, null);
    assert.ok(q.gorsel.svg.startsWith('<svg'));
    assert.ok(q.gorsel.alt_metin);
    assert.ok(q.gorsel_dogrulama.length > 0);
    assert.equal(Object.keys(q.siklar).join(''), 'ABCD');
    assert.equal(q.cozum_adimlari.at(-1), `Doğru cevap ${q.dogru_sik} seçeneğidir.`);
    for (const [h, g] of Object.entries(q.celdirici_gerekce)) {
      if (h === q.dogru_sik) assert.equal(g, 'Doğru.');
      else assert.ok(String(g).trim().length > 3, `${q.id} ${h} gerekçesi boş`);
    }
  }
});

// ---- konum sözleşmesi (G3) ----
const iskelet = { ders: 'Matematik', sinif: 5, idOnek: 'TST', mufredat_surum: 'test', kodlar: ['MAT.5.5.1'], fabrika: (c) => c };
const spec = { tip_id: 'sayi-dogrusu', parametreler: { min: 0, max: 10, adim: 1, isaretler: [{ deger: 3, etiket: 'A' }] } };
const soru = (c, sirali, dogru) => c.ekle({
  kod: 'MAT.5.5.1', konu: 'Test', alt_konu: 'Test', kok: `Test sorusu ${Math.floor(c.R() * 1e9)}?`,
  dogru, sirali, gerekce: ['g1', 'g2', 'g3', 'g4'], ipucu: 'ipucu', cozum: ['adım'], zorluk: 1, spec, dogrulama: [],
});
const kotu = { ...iskelet, id: 'test-kotu', uret: (f, c) => { const k = c.konum(); const s = ['0', '1', '2', '3']; s[(k + 1) % 4] = '9'; soru(c, s, '9'); } };
const iyi = { ...iskelet, id: 'test-iyi', uret: (f, c) => { const k = c.konum(); const s = ['0', '1', '2', '3']; s[k] = '9'; soru(c, s, '9'); } };

test('konum sözleşmesi: doğru şık rezerve konuma yazılmazsa her deneme reddedilir', () => {
  const r = uretKayitlar([kotu], { adet: 4, tohum: 2 });
  assert.equal(r.sorular.length, 0);
  assert.equal(r.istatistik.atilan.konum_uyumsuz, r.istatistik.denenen);
});

test('konum sözleşmesi: doğru şık rezerve konuma yazılırsa üretim tamam ve denge korunur', () => {
  const r = uretKayitlar([iyi], { adet: 8, tohum: 2 });
  assert.equal(r.sorular.length, 8);
  assert.deepEqual(dengeOzeti(r.sorular).bozuk_blok, []);
});

// ---- tekrar (G4) içerik bazlıdır ----
test('tekrar (G4): aynı soru farklı harf sırasıyla çıkmaz', async () => {
  const { sorular } = await uret({ ders: 'hayat', sinif: 1, adet: 6, tohum: 7 });
  // Anahtar: kök + görsel tanımı + doğru metin. (Sarı ve yeşil ışıkta doğru metin aynıdır; görsel farkı onları ayırır.)
  assert.equal(new Set(sorular.map((q) => `${q.soru_metni}|${JSON.stringify(q.gorsel_spec)}|${q.siklar[q.dogru_sik]}`)).size, sorular.length);
});

// ---- denge (G2) ----
test("denge: her 4'lü blokta A–D birer kez; blok sıraları birbirinden farklı", async () => {
  const { sorular } = await uret({ ders: 'matematik', sinif: 1, adet: 40, tohum: 5 });
  const d = dengeOzeti(sorular);
  assert.deepEqual(d.bozuk_blok, []);
  assert.equal(d.dengeli_blok, 10);
  const bloklar = new Set();
  for (let b = 0; b < 40; b += 4) bloklar.add(sorular.slice(b, b + 4).map((q) => q.dogru_sik).join(''));
  assert.ok(bloklar.size >= 3, `blok sırası çeşitliliği: ${[...bloklar].join(' ')}`);
});

// ---- determinizm (G1) ----
test('determinizm: aynı tohum aynı çıktı', async () => {
  const a = await uret({ ders: 'fen', sinif: 5, adet: 6, tohum: 9 });
  const b = await uret({ ders: 'fen', sinif: 5, adet: 6, tohum: 9 });
  assert.equal(JSON.stringify(a.sorular), JSON.stringify(b.sorular));
});

// ---- her şablon tek başına üretebilmeli (duman) ----
test('duman: her şablon tek başına 4 soru üretir (iki tohum)', async () => {
  const k = await kayitlariYukle();
  for (const s of k) for (const tohum of [1, 2]) {
    const r = uretKayitlar([s], { adet: 4, tohum });
    assert.equal(r.sorular.length, 4, `${s.id} tohum ${tohum}: ${JSON.stringify(r.istatistik.atilan)}`);
  }
});
