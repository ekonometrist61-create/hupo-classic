import test from 'node:test';
import assert from 'node:assert/strict';
import { gorselUret } from './motor.mjs';

const hatalar = (r) => r.bulgular.filter((b) => b.ciddiyet === 'hata');

test('sütun grafiği: değerler, en çok/en az, toplam hesaplanır', () => {
  const r = gorselUret({ tip_id: 'sutun-grafigi', parametreler: { baslik: 'Sevilen Meyveler', max: 10, adim: 2,
    kategoriler: [{ ad: 'Elma', deger: 8 }, { ad: 'Armut', deger: 4 }, { ad: 'Muz', deger: 6 }, { ad: 'Kiraz', deger: 3 }] } }, 5);
  assert.equal(r.olgular.en_cok, 'Elma'); assert.equal(r.olgular.en_az, 'Kiraz'); assert.equal(r.olgular.toplam, 21);
  assert.deepEqual(hatalar(r), []);
});

test('sütun grafiği: ızgaraya uymayan değer RED', () => {
  assert.throws(() => gorselUret({ tip_id: 'sutun-grafigi', parametreler: { baslik: 'x', max: 10, adim: 2,
    kategoriler: [{ ad: 'A', deger: 3.3 }, { ad: 'B', deger: 4 }] } }, 5), /deger_adim_yarisina_uymuyor/);
});

test('çubuk örüntüsü: kare 3n+1, üçgen 2n+1', () => {
  const k = gorselUret({ tip_id: 'cubuk-oruntusu', parametreler: { tur: 'kare' } }, 5);
  const u = gorselUret({ tip_id: 'cubuk-oruntusu', parametreler: { tur: 'ucgen' } }, 5);
  assert.equal(k.olgular.cubuk[10], 31); assert.equal(u.olgular.cubuk[10], 21);
  assert.equal((k.svg.match(/<line/g) ?? []).length, 4 + 7 + 10); // çizilen çubuk sayısı = kuralla uyumlu
  assert.equal((u.svg.match(/<line/g) ?? []).length, 3 + 5 + 7);
  assert.deepEqual(hatalar(k), []); assert.deepEqual(hatalar(u), []);
});

test('çubuk örüntüsü: altıgen 5n+1 (altıgen sırası)', () => {
  const a = gorselUret({ tip_id: 'cubuk-oruntusu', parametreler: { tur: 'altigen' } }, 5);
  assert.equal(a.olgular.cubuk[1], 6); assert.equal(a.olgular.cubuk[10], 51);
  assert.equal((a.svg.match(/<polygon/g) ?? []).length, 1 + 2 + 3); // üç adım: 1, 2, 3 altıgen
  assert.deepEqual(hatalar(a), []);
});

test('kavşak trafik ışığı: iki yol, renkler olgu olarak çıkar; iki yol birden yeşil/sarı olamaz', () => {
  const r = gorselUret({ tip_id: 'trafik-kavsak', parametreler: { ana: 'yesil', yan: 'kirmizi', bicim: 'yatay', sira: 'yan_ilk' } }, 5);
  assert.equal(r.olgular.ana, 'yesil'); assert.equal(r.olgular.yan, 'kirmizi');
  assert.equal((r.svg.match(/<circle/g) ?? []).length, 6); // iki ışık × üç lamba
  assert.deepEqual(hatalar(r), []);
  assert.throws(() => gorselUret({ tip_id: 'trafik-kavsak', parametreler: { ana: 'yesil', yan: 'sari', bicim: 'dikey', sira: 'ana_ilk' } }, 5), /kavsak_cakisma/);
});

test('nesne sayma: şekil sayıları ve çizilen nesne sayısı eşleşir', () => {
  const r = gorselUret({ tip_id: 'nesne-sayma', parametreler: { sekiller: [{ sekil: 'daire', sayi: 5 }, { sekil: 'kare', sayi: 3 }, { sekil: 'ucgen', sayi: 6 }], tohum: 7 } }, 1);
  assert.equal(r.olgular.toplam, 14); assert.equal(r.olgular.en_cok, 'ucgen');
  assert.equal((r.svg.match(/<circle/g) ?? []).length, 5); assert.equal((r.svg.match(/<polygon/g) ?? []).length, 6);
  assert.deepEqual(hatalar(r), []);
});

test('yer haritası: yönler ana ve ara yön olarak hesaplanır, aynı doğrultuda olmayan yok', () => {
  const r = gorselUret({ tip_id: 'yer-haritasi', parametreler: { en: 3, boy: 3, yerler: [
    { ad: 'Okul', x: 1, y: 1 }, { ad: 'Park', x: 2, y: 1 }, { ad: 'Market', x: 0, y: 0 }, { ad: 'Banka', x: 1, y: 0 }, { ad: 'Fırın', x: 2, y: 0 }] } }, 5);
  const y = r.olgular.yonler;
  assert.equal(y['Okul|Park'], 'doğu'); assert.equal(y['Okul|Banka'], 'kuzey');
  assert.equal(y['Okul|Market'], 'kuzeybatı'); assert.equal(y['Okul|Fırın'], 'kuzeydoğu');
  assert.equal(y['Market|Park'], undefined); // aynı doğrultuda değil
  assert.deepEqual(hatalar(r), []);
});

test('trafik ışığı: yanan lamba ve konum; koyu zeminde renk kapısı geçer', () => {
  for (const [yanan, konum] of [['kirmizi', 'ust'], ['sari', 'orta'], ['yesil', 'alt']]) {
    const r = gorselUret({ tip_id: 'trafik-isigi', parametreler: { yanan } }, 1);
    assert.equal(r.olgular.konum, konum); assert.deepEqual(hatalar(r), []);
  }
  assert.throws(() => gorselUret({ tip_id: 'trafik-isigi', parametreler: { yanan: 'mor' } }, 1), /isik_bilinmiyor/);
});

test('belge kartı: alanlar okunur, değerler alt metinde yok', () => {
  const r = gorselUret({ tip_id: 'belge-kart', parametreler: { tur: 'Duyuru', baslik: 'Kitap Fuarı', satirlar: [{ etiket: 'Gün', deger: 'Cuma' }, { etiket: 'Saat', deger: '10.30' }, { etiket: 'Yer', deger: 'Kütüphane' }] } }, 5);
  assert.equal(r.olgular.alanlar['Saat'], '10.30'); assert.ok(!r.alt.includes('10.30') && !r.alt.includes('Cuma'));
  assert.deepEqual(hatalar(r), []);
});

test('kesir modeli: şerit ve pasta, taralı ve taralı olmayan kesir', () => {
  for (const tur of ['serit', 'pasta']) {
    const r = gorselUret({ tip_id: 'kesir-modeli', parametreler: { tur, payda: 8, pay: 3 } }, 5);
    assert.equal(r.olgular.tarali, '3/8'); assert.equal(r.olgular.tarali_olmayan, '5/8'); assert.deepEqual(hatalar(r), []);
    const taral = (r.svg.match(/fill="#E69F00"/g) ?? []).length; assert.equal(taral, 3); // çizilen taralı parça sayısı
  }
  assert.throws(() => gorselUret({ tip_id: 'kesir-modeli', parametreler: { tur: 'serit', payda: 4, pay: 4 } }, 5), /kesir_gecersiz/);
});

test('örüntü dizisi: sıradaki şekil ve birim uzunluğu doğrulanır; belirsiz örüntü RED', () => {
  const r = gorselUret({ tip_id: 'oruntu-dizisi', parametreler: { dizi: ['daire', 'kare', 'daire', 'kare', 'daire'], siradaki: 'kare' } }, 1);
  assert.equal(r.olgular.birim_uzunlugu, 2); assert.deepEqual(hatalar(r), []);
  assert.throws(() => gorselUret({ tip_id: 'oruntu-dizisi', parametreler: { dizi: ['daire', 'kare', 'ucgen', 'daire'], siradaki: 'kare' } }, 1), /oruntu_belirsiz/);
});
