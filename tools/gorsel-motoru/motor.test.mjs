import test from 'node:test';
import assert from 'node:assert/strict';
import { gorselUret, olguDogrula } from './motor.mjs';
import { renkAyirt, gorselLint } from './lint.mjs';
import { Sahne, profilBul } from './cekirdek.mjs';

const hatalar = (r) => r.bulgular.filter((b) => b.ciddiyet === 'hata');

test('doğru modelleri: sembol ve tür çözülür', () => {
  const r = gorselUret({ tip_id: 'dogru-modelleri', parametreler: {
    noktalar: [{ ad: 'A', x: 60, y: 100 }, { ad: 'B', x: 160, y: 100 }],
    nesneler: [{ tur: 'isin', a: 'A', b: 'B' }] } }, 5);
  assert.equal(r.olgular.semboller.AB, '[AB');
  assert.deepEqual(hatalar(r), []);
});

test('çember: çap ve kiriş ayrımı', () => {
  const r = gorselUret({ tip_id: 'cember-elemanlari', parametreler: { merkez: 'O',
    noktalar: [{ ad: 'A', aci: 100 }, { ad: 'C', aci: 280 }, { ad: 'B', aci: 30 }],
    cizimler: [{ tur: 'cap', a: 'A', b: 'C' }, { tur: 'kiris', a: 'A', b: 'B' }] } }, 5);
  assert.equal(r.olgular.siniflar['[AC]'], 'cap');
  assert.equal(r.olgular.siniflar['[AB]'], 'kiris');
  assert.deepEqual(hatalar(r), []);
});

test('çember: çap iddiası yanlışsa RED', () => {
  assert.throws(() => gorselUret({ tip_id: 'cember-elemanlari', parametreler: { merkez: 'O',
    noktalar: [{ ad: 'A', aci: 100 }, { ad: 'B', aci: 30 }], cizimler: [{ tur: 'cap', a: 'A', b: 'B' }] } }, 5), /cap_degil/);
});

test('kesişen doğrular: ters ve komşu açılar', () => {
  const r = gorselUret({ tip_id: 'kesisen-dogrular', parametreler: { dogrular: ['d', 'e'], theta: 130,
    isaretler: [{ bolge: 0, goster: 'deger' }, { bolge: 1, goster: 'sembol', sembol: '■' }] } }, 5);
  assert.deepEqual(r.olgular.bolge_degerleri, [130, 50, 130, 50]);
  assert.deepEqual(olguDogrula(r.olgular, [{ yol: ['bolge_degerleri', 1], beklenen: 50 }]), []);
  assert.ok(olguDogrula(r.olgular, [{ yol: ['bolge_degerleri', 1], beklenen: 40 }]).length === 1);
  assert.deepEqual(hatalar(r), []);
});

test('kareli zemin: paralel, dik, kesişir', () => {
  const r = gorselUret({ tip_id: 'kareli-dogrular', parametreler: { en: 10, boy: 7, dogrular: [
    { ad: 'k', p1: [1, 1], p2: [4, 4] }, { ad: 'm', p1: [2, 4], p2: [5, 7] },
    { ad: 'n', p1: [6, 1], p2: [9, 2] }, { ad: 'p', p1: [1, 6], p2: [3, 4] }] } }, 5);
  assert.equal(r.olgular.iliskiler['k|m'], 'paralel');
  assert.equal(r.olgular.iliskiler['k|p'], 'dik');
  assert.equal(r.olgular.iliskiler['k|n'], 'kesisir');
  assert.deepEqual(hatalar(r), []);
});

test('kareli zemin: anlamlı renk kayıtlıysa renk körlüğü kapısı çalışır', () => {
  const r = gorselUret({ tip_id: 'kareli-dogrular', parametreler: { en: 10, boy: 7, renk_anlamli: true, dogrular: [
    { ad: 'k', p1: [1, 1], p2: [4, 4], renk: 'mavi' }, { ad: 'm', p1: [2, 4], p2: [5, 7], renk: 'yesil' }] } }, 5);
  assert.ok(r.bulgular.some((b) => b.kural === 'renk_ayirt_edilemez'));
});

test('sayı doğrusu', () => {
  const r = gorselUret({ tip_id: 'sayi-dogrusu', parametreler: { min: 0, max: 10, adim: 1,
    isaretler: [{ deger: 7, etiket: 'A' }] } }, 3);
  assert.equal(r.olgular.konumlar.A, 7);
  assert.deepEqual(hatalar(r), []);
});

test('lint: çakışan yazı ve çizgiye binen yazı yakalanır', () => {
  const s = new Sahne(200, 100, profilBul(5));
  s.cizgi(10, 50, 190, 50);
  s.metin(100, 54, 'AB'); s.metin(104, 54, 'CD');
  const kurallar = gorselLint(s, s.svg('x')).map((b) => b.kural);
  assert.ok(kurallar.includes('yazi_cakisma'));
  assert.ok(kurallar.includes('yazi_cizgi_cakisma'));
});

test('yerleştirme: çizgiyle çakışmayan boş yer seçilir', () => {
  const s = new Sahne(200, 100, profilBul(5));
  s.cizgi(10, 50, 190, 50);
  s.metinYerlestir([[100, 54], [100, 30]], 'k');
  assert.deepEqual(gorselLint(s, s.svg('x')).filter((b) => b.ciddiyet === 'hata'), []);
});

test('renk körlüğü: kırmızı/yeşil karışık çift ayırt edilemez, Okabe-Ito mavi/turuncu edilir', () => {
  const kotu = renkAyirt('#FF0000', '#00AA00');
  assert.ok(Math.min(kotu.protan, kotu.deutan) < 20);
  const iyi = renkAyirt('#0072B2', '#E69F00');
  assert.ok(Math.min(...Object.values(iyi)) >= 20);
});
