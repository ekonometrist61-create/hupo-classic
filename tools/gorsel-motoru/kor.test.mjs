import test from 'node:test';
import assert from 'node:assert/strict';
import { korKarsilastir, ESIK } from './kor.mjs';

const anahtar = (n) => Array.from({ length: n }, (_, i) => ({ id: `Q${i}`, dogru_sik: 'ABCD'[i % 4] }));
// ok(i) doğruysa anahtar cevabı, değilse yanlış harf yazar.
const cevap = (s, ok) => s.map((q, i) => ({ id: q.id, cevap: ok(i) ? q.dogru_sik : 'Z', belirsiz: false }));
const hepsi = () => true;
const yok = () => false;

test('eşikler: görselli ≥ %95, görselsiz ≤ %40, karar için n ≥ 40', () => {
  assert.equal(ESIK.gorselli, 0.95);
  assert.equal(ESIK.gorselsiz, 0.4);
  assert.equal(ESIK.n_min, 40);
});

test('n ≥ 40, görselli %100, görselsiz %25 → KOR_GECTI', () => {
  const s = anahtar(40);
  const r = korKarsilastir(s, cevap(s, hepsi), cevap(s, (i) => i < 10));
  assert.equal(r.karar, 'KOR_GECTI');
  assert.equal(r.gecti, true);
  assert.equal(r.n_yeterli, true);
});

test('görselli %92,5 (< %95) → KOR_GECMEDI', () => {
  const s = anahtar(40);
  const r = korKarsilastir(s, cevap(s, (i) => i >= 3), cevap(s, yok));
  assert.equal(r.karar, 'KOR_GECMEDI');
  assert.equal(r.gorselli.uyum, 37);
});

test('görselsiz %50 (> %40) → KOR_GECMEDI: görsel gerekli değil ya da şıklar ipucu veriyor', () => {
  const s = anahtar(40);
  const r = korKarsilastir(s, cevap(s, hepsi), cevap(s, (i) => i < 20));
  assert.equal(r.karar, 'KOR_GECMEDI');
  assert.equal(r.gorselsiz.uyum, 20);
});

test('n < 40 → yalnız ön bilgi (ON_GECTI), n_yeterli false', () => {
  const s = anahtar(20);
  const r = korKarsilastir(s, cevap(s, hepsi), cevap(s, yok));
  assert.equal(r.karar, 'ON_GECTI');
  assert.equal(r.n_yeterli, false);
});

test('n < 40 ve eşik aşılırsa ON_GECMEDI', () => {
  const s = anahtar(20);
  const r = korKarsilastir(s, cevap(s, (i) => i < 10), cevap(s, yok));
  assert.equal(r.karar, 'ON_GECMEDI');
});

test('eksik görselli cevap yanlış sayılır; 38/40 = %95 sınırda geçer', () => {
  const s = anahtar(40);
  const r = korKarsilastir(s, cevap(s, hepsi).slice(0, 38), cevap(s, yok));
  assert.equal(r.gorselli.eksik, 2);
  assert.equal(r.gorselli.uyum, 38);
  assert.equal(r.gorselli.oran, 0.95);
  assert.equal(r.gecti, true);
});

test('belirsiz görselli cevap doğru olsa da doğrulanmış sayılmaz', () => {
  const s = anahtar(40);
  const g = cevap(s, hepsi);
  g[0].belirsiz = true;
  const r = korKarsilastir(s, g, cevap(s, yok));
  assert.equal(r.gorselli.uyum, 39);
  assert.ok(r.gorselli.sorunlu.some((x) => x.startsWith('Q0: belirsiz')));
});
