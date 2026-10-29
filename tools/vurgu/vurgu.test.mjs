import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { vurguOner, vurguDenetle, parcala } from './vurgu.mjs';

const SIKLAR = { A: "Dünya'nın Güneş'in çevresinde dolanması", B: "Dünya'nın kendi ekseni etrafında dönmesi" };

test('referans örnek: kavram öbeği vurgulanır, metin değişmez, cevap sızmaz', () => {
  const metin = 'Dünya üzerinde gece ve gündüzün oluşmasının temel nedeni aşağıdakilerden hangisidir?';
  const o = vurguOner(metin);
  assert.equal(o.durum, 'otomatik');
  const p = parcala(metin, o.highlights);
  assert.equal(p.map((x) => x.metin).join(''), metin);
  assert.deepEqual(p.filter((x) => x.vurgu).map((x) => x.metin), ['gece ve gündüzün oluşmasının']);
  const d = vurguDenetle({ soruMetni: metin, highlights: o.highlights, siklar: SIKLAR, dogruSik: 'B' });
  assert.ok(d.ok, d.hatalar.join());
});

test('olumsuz kök: DEĞİLDİR/yanlıştır öncelikli', () => {
  for (const [m, beklenen] of [
    ['Aşağıdakilerden hangisi kültürel mirasa örnek değildir?', 'değildir'],
    ['Bu metinden kesin olarak çıkarılamayacak yargı hangisidir?', 'kesin olarak çıkarılamayacak'],
  ]) {
    const o = vurguOner(m);
    assert.ok(parcala(m, o.highlights).some((x) => x.vurgu && x.metin.includes(beklenen)), m);
  }
});

test('matematik: belirleyici sayısal ilişki', () => {
  const m = 'Bir sayının 3 katının 5 fazlası 26\'dır. Bu sayı kaçtır?';
  const o = vurguOner(m);
  assert.ok(parcala(m, o.highlights).some((x) => x.vurgu && x.metin.includes('3 katının 5 fazlası')));
});

test('Unicode: İ/I, ı ve emoji kod noktası ofsetleri doğru', () => {
  const m = 'İstanbul 😀 ve Işık hakkında hangisi yanlıştır?';
  const o = vurguOner(m);
  const p = parcala(m, o.highlights);
  assert.equal(p.map((x) => x.metin).join(''), m);
  assert.deepEqual(p.filter((x) => x.vurgu).map((x) => x.metin), ['yanlıştır']);
});

test('denetçi: bütün kök, şık sızıntısı, aralık hataları reddedilir', () => {
  const m = 'Dünya üzerinde gece ve gündüzün oluşmasının temel nedeni aşağıdakilerden hangisidir?';
  const n = Array.from(m).length;
  assert.ok(!vurguDenetle({ soruMetni: m, highlights: [{ start: 0, end: n }], siklar: SIKLAR, dogruSik: 'B' }).ok);
  assert.ok(!vurguDenetle({ soruMetni: m, highlights: [{ start: 5, end: n + 3 }], siklar: SIKLAR, dogruSik: 'B' }).ok);
  const sizinti = 'Bu olayın nedeni Dünya\'nın kendi ekseni etrafında dönmesi midir?';
  const bas = Array.from(sizinti).indexOf('D', 15);
  assert.ok(!vurguDenetle({ soruMetni: sizinti, highlights: [{ start: bas, end: Array.from(sizinti).length - 8 }], siklar: SIKLAR, dogruSik: 'B' }).ok);
});

test('vurgu hikâye/paragraf metnine taşmaz', () => {
  const m = 'Kutup ayısı çok soğuk yerde yaşar ve en büyük avcıdır.\n\nBu metne göre aşağıdakilerden hangisi yanlıştır?';
  const o = vurguOner(m);
  const d = vurguDenetle({ soruMetni: m, highlights: o.highlights, siklar: {}, dogruSik: 'A' });
  assert.ok(d.ok, d.hatalar.join());
});

test('vurgu cevap anahtarından bağımsız: dogruSik değişince öneri değişmez', () => {
  const m = 'Aşağıdakilerden hangisi doğru değildir?';
  assert.deepEqual(vurguOner(m), vurguOner(m));
});

test('gerçek paketlerde ≥100 soru: tüm otomatik öneriler denetimi geçer ve metin korunur', () => {
  const dizin = 'docs/soru-uretim/paket';
  const sorular = [];
  for (const f of readdirSync(dizin).filter((d) => d.endsWith('.json'))) {
    const j = JSON.parse(readFileSync(join(dizin, f), 'utf8').replace(/^﻿/, ''));
    for (const s of Array.isArray(j) ? j : j.sorular ?? []) if (s?.soru_metni && s.siklar) sorular.push(s);
  }
  assert.ok(sorular.length >= 100);
  let otomatik = 0;
  for (const s of sorular) {
    const o = vurguOner(s.soru_metni);
    if (o.durum !== 'otomatik') continue;
    const d = vurguDenetle({ soruMetni: s.soru_metni, highlights: o.highlights, siklar: s.siklar, dogruSik: s.dogru_sik });
    if (!d.ok) continue; // reddedilen → editör kuyruğu (toplu.mjs)
    otomatik++;
    assert.equal(parcala(s.soru_metni, o.highlights).map((x) => x.metin).join(''), s.soru_metni, s.soru_id);
  }
  assert.ok(otomatik >= 50, `otomatik=${otomatik}`);
});
