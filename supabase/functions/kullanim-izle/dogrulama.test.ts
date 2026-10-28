// Çalıştırma (proje kökünden, Node 24):  node --experimental-strip-types --test supabase/functions/kullanim-izle/dogrulama.test.ts
// Deno ile:                              deno test supabase/functions/kullanim-izle/dogrulama.test.ts
import test from "node:test";
import assert from "node:assert/strict";
import { EN_COK_OLAY, govdeBoyutuUygun, olaylariDogrula } from "./dogrulama.ts";

const SIMDI = Date.parse("2026-10-27T12:00:00.000Z");
const DAKIKA = 60 * 1000;
const GUN = 24 * 60 * DAKIKA;

function olay(ek: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    yuzey: "mobil",
    ekran: "/ogrenci/ana",
    sure_sn: 30,
    baslangic: new Date(SIMDI - DAKIKA).toISOString(),
    oturum_anahtari: "oturum_anahtari_0001",
    rol: "ogrenci",
    ...ek,
  };
}

function gecerliMi(olaylar: unknown[]) {
  return olaylariDogrula({ olaylar }, SIMDI);
}

test("geçerli toplu gönderim kabul edilir, bilinmeyen alanlar atılır, baslangic UTC ISO olur", () => {
  const r = gecerliMi([olay({ kullanici_id: "x", not: "serbest" })]);
  assert.equal(r.ok, true);
  if (!r.ok) return;
  assert.deepEqual(Object.keys(r.olaylar[0]).sort(), [
    "baslangic",
    "ekran",
    "oturum_anahtari",
    "rol",
    "sure_sn",
    "yuzey",
  ]);
  assert.equal(r.olaylar[0].baslangic, new Date(SIMDI - DAKIKA).toISOString());
});

test("boş dizi geçerlidir (sonuç 0 olay)", () => {
  const r = gecerliMi([]);
  assert.deepEqual(r, { ok: true, olaylar: [] });
});

test("50 olay kabul, 51 olay reddedilir", () => {
  assert.equal(gecerliMi(Array.from({ length: EN_COK_OLAY }, () => olay())).ok, true);
  const r = gecerliMi(Array.from({ length: EN_COK_OLAY + 1 }, () => olay()));
  assert.equal(r.ok, false);
});

test("gövde nesne değilse ya da olaylar dizi değilse reddedilir", () => {
  assert.equal(olaylariDogrula(null, SIMDI).ok, false);
  assert.equal(olaylariDogrula([], SIMDI).ok, false);
  assert.equal(olaylariDogrula({ olaylar: "x" }, SIMDI).ok, false);
  assert.equal(olaylariDogrula({}, SIMDI).ok, false);
});

test("olay nesne değilse reddedilir", () => {
  assert.equal(gecerliMi([null]).ok, false);
  assert.equal(gecerliMi(["metin"]).ok, false);
  assert.equal(gecerliMi([[1, 2]]).ok, false);
});

test("sure_sn sınırları: 1 ve 14400 kabul; 0, 14401, ondalık, metin reddedilir", () => {
  assert.equal(gecerliMi([olay({ sure_sn: 1 })]).ok, true);
  assert.equal(gecerliMi([olay({ sure_sn: 14400 })]).ok, true);
  assert.equal(gecerliMi([olay({ sure_sn: 0 })]).ok, false);
  assert.equal(gecerliMi([olay({ sure_sn: 14401 })]).ok, false);
  assert.equal(gecerliMi([olay({ sure_sn: 1.5 })]).ok, false);
  assert.equal(gecerliMi([olay({ sure_sn: "30" })]).ok, false);
  assert.equal(gecerliMi([olay({ sure_sn: undefined })]).ok, false);
});

test("yuzey ve rol allowlist dışındaysa reddedilir", () => {
  assert.equal(gecerliMi([olay({ yuzey: "bilinmeyen" })]).ok, false);
  assert.equal(gecerliMi([olay({ yuzey: "admin_panel" })]).ok, false);
  assert.equal(gecerliMi([olay({ rol: "superadmin" })]).ok, false);
  assert.equal(gecerliMi([olay({ rol: 5 })]).ok, false);
});

test("ekran adı: geçerli yol kabul; boş, 61 karakter, boşluk, sorgu, HTML reddedilir", () => {
  assert.equal(gecerliMi([olay({ ekran: "/ogrenci/:id" })]).ok, true);
  assert.equal(gecerliMi([olay({ ekran: "sekme/ana" })]).ok, true);
  assert.equal(gecerliMi([olay({ ekran: "" })]).ok, false);
  assert.equal(gecerliMi([olay({ ekran: "a".repeat(60) })]).ok, true);
  assert.equal(gecerliMi([olay({ ekran: "a".repeat(61) })]).ok, false);
  assert.equal(gecerliMi([olay({ ekran: "/ana ekran" })]).ok, false);
  assert.equal(gecerliMi([olay({ ekran: "/ogrenci?ad=ali" })]).ok, false);
  assert.equal(gecerliMi([olay({ ekran: "<script>" })]).ok, false);
  assert.equal(gecerliMi([olay({ ekran: 12 })]).ok, false);
});

test("oturum anahtarı: 16-64 karakter, [A-Za-z0-9_-]; diğerleri reddedilir", () => {
  assert.equal(gecerliMi([olay({ oturum_anahtari: "a".repeat(16) })]).ok, true);
  assert.equal(gecerliMi([olay({ oturum_anahtari: "a".repeat(64) })]).ok, true);
  assert.equal(gecerliMi([olay({ oturum_anahtari: "a".repeat(15) })]).ok, false);
  assert.equal(gecerliMi([olay({ oturum_anahtari: "a".repeat(65) })]).ok, false);
  assert.equal(gecerliMi([olay({ oturum_anahtari: "abc def ghi jkl mno" })]).ok, false);
  assert.equal(gecerliMi([olay({ oturum_anahtari: "ab@cdefghijklmnop" })]).ok, false);
});

test("baslangic: 2 gün geçmiş ve 5 dk gelecek sınırı; geçersiz metin reddedilir", () => {
  assert.equal(gecerliMi([olay({ baslangic: new Date(SIMDI - 2 * GUN + DAKIKA).toISOString() })]).ok, true);
  assert.equal(gecerliMi([olay({ baslangic: new Date(SIMDI - 2 * GUN - DAKIKA).toISOString() })]).ok, false);
  assert.equal(gecerliMi([olay({ baslangic: new Date(SIMDI + 4 * DAKIKA).toISOString() })]).ok, true);
  assert.equal(gecerliMi([olay({ baslangic: new Date(SIMDI + 6 * DAKIKA).toISOString() })]).ok, false);
  assert.equal(gecerliMi([olay({ baslangic: "bugün" })]).ok, false);
  assert.equal(gecerliMi([olay({ baslangic: 1700000000000 })]).ok, false);
});

test("hata mesajı hangi olayın reddedildiğini söyler", () => {
  const r = gecerliMi([olay(), olay({ sure_sn: 0 })]);
  assert.equal(r.ok, false);
  if (r.ok) return;
  assert.match(r.hata, /sure_sn/);
});

test("gövde boyutu: 32 KB'a kadar kabul, üstü reddedilir", () => {
  assert.equal(govdeBoyutuUygun(0), true);
  assert.equal(govdeBoyutuUygun(32 * 1024), true);
  assert.equal(govdeBoyutuUygun(32 * 1024 + 1), false);
  assert.equal(govdeBoyutuUygun(-1), false);
  assert.equal(govdeBoyutuUygun(1.5), false);
});
