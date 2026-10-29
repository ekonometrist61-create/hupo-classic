import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { uret } from './uretici.mjs';
import { yazPaket, korSonucuUygula } from './paket.mjs';

const yeniKlasor = () => fs.mkdtempSync(path.join(os.tmpdir(), 'gorsel-paket-test-'));
const pythonVar = spawnSync('python', ['-I', '-c', 'import pymupdf'], { encoding: 'utf8' }).status === 0;
const meta = (istatistik, ders, sinif, kod) => ({ istatistik, ders, sinif, kod });

test('paket: dosya seti üretilir, kapılar geçer, karar KOR_BEKLIYOR, durum beklemede', async () => {
  const { sorular, istatistik } = await uret({ ders: 'matematik', sinif: 5, kod: 'MAT.5.5.1', adet: 8, tohum: 4 });
  const d = yeniKlasor();
  const r = yazPaket(sorular, meta(istatistik, 'Matematik', 5, 'MAT.5.5.1'), d, { png: pythonVar });
  for (const f of ['sorular.json', 'rapor.json', 'kontak.html', path.join('kor', 'kor_gorselli.json'), path.join('kor', 'kor_gorselsiz.json')]) {
    assert.ok(fs.existsSync(path.join(d, f)), f);
  }
  assert.equal(r.kapi.kazanim.red.length, 0, JSON.stringify(r.kapi.kazanim.red));
  assert.equal(r.kapi.gorsel.red.length, 0, JSON.stringify(r.kapi.gorsel.red));
  assert.equal(r.karar, 'KOR_BEKLIYOR');
  assert.equal(r.durum, 'beklemede');
  if (pythonVar) assert.equal(r.kor_png.tamam, true, r.kor_png.hata);
  // Anahtar (dogru_sik) kör çözüm girdilerinde bulunmamalı.
  const kg = fs.readFileSync(path.join(d, 'kor', 'kor_gorselsiz.json'), 'utf8');
  assert.ok(!kg.includes('dogru_sik'));
});

test('kör sonuç: anahtarla birebir cevap → görselli %100; n < 40 → ON_GECTI', async () => {
  const { sorular, istatistik } = await uret({ ders: 'matematik', sinif: 5, kod: 'MAT.5.5.1', adet: 8, tohum: 4 });
  const d = yeniKlasor();
  yazPaket(sorular, meta(istatistik, 'Matematik', 5, 'MAT.5.5.1'), d, { png: false });
  const kor = path.join(d, 'kor');
  fs.writeFileSync(path.join(kor, 'gorselli_cevap.json'), JSON.stringify(sorular.map((q) => ({ id: q.id, cevap: q.dogru_sik, belirsiz: false }))));
  // 8 soru = 2 tam blok; her blokta A bir kez → görselsiz "hep A" %25 çözer (≤ %40).
  fs.writeFileSync(path.join(kor, 'gorselsiz_cevap.json'), JSON.stringify(sorular.map((q) => ({ id: q.id, cevap: 'A', belirsiz: true }))));
  const r = korSonucuUygula(d);
  assert.equal(r.kor.gorselli.oran, 1);
  assert.equal(r.kor.gorselsiz.oran, 0.25);
  assert.equal(r.kor.n_yeterli, false);
  assert.equal(r.karar, 'ON_GECTI');
  assert.equal(JSON.parse(fs.readFileSync(path.join(d, 'rapor.json'), 'utf8')).karar, 'ON_GECTI');
});

test('kör sonuç: cevap dosyası yoksa açık hata verir', async () => {
  const { sorular, istatistik } = await uret({ ders: 'matematik', sinif: 5, kod: 'MAT.5.5.1', adet: 4, tohum: 4 });
  const d = yeniKlasor();
  yazPaket(sorular, meta(istatistik, 'Matematik', 5, 'MAT.5.5.1'), d, { png: false });
  assert.throws(() => korSonucuUygula(d), /kör cevap dosyaları eksik/);
});

test('eksik üretim: trafik kazanımında 46 farklı soru var (6 tek ışık + 40 kavşak) → 50 istenirse EKSIK_URETIM', async () => {
  const { sorular, istatistik } = await uret({ ders: 'hayat', sinif: 1, adet: 50, tohum: 1 });
  const r = yazPaket(sorular, meta(istatistik, 'Hayat Bilgisi', 1, 'HB.1.2.3'), yeniKlasor(), { png: false });
  assert.equal(r.uretim.uretilen, 46);
  assert.equal(r.uretim.eksik, 4);
  assert.equal(r.karar, 'EKSIK_URETIM');
  assert.equal(r.durum, 'beklemede');
});
