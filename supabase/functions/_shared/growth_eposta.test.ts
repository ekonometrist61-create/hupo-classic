// Çalıştırma (Node 24): node --test supabase/functions/_shared/growth_eposta.test.ts
// Çalıştırma (Deno):    deno test supabase/functions/_shared/growth_eposta.test.ts
import test from "node:test";
import assert from "node:assert/strict";
import { growthDegiskenleri, growthMesajiHazirla, veliAdi } from "./growth_eposta.ts";

const PANEL = "https://hupolingo.com/";

test("veli adı: tam addan yalnız ilk kelime; boşsa varsayılan hitap", () => {
  assert.equal(veliAdi("Ayşe Yılmaz"), "Ayşe");
  assert.equal(veliAdi("  Can  "), "Can");
  assert.equal(veliAdi(""), "değerli veli");
  assert.equal(veliAdi(null), "değerli veli");
  assert.equal(veliAdi(undefined), "değerli veli");
});

test("değişken kümesi tam olarak veli_adi ve iptal_baglantisi (çocuk verisi yok)", () => {
  const d = growthDegiskenleri("Ayşe Yılmaz", PANEL);
  assert.deepEqual(Object.keys(d).sort(), ["iptal_baglantisi", "veli_adi"]);
  assert.equal(d.veli_adi, "Ayşe");
});

test("iptal bağlantısı panel tabanına eklenir; sondaki eğik çizgi tekilleşir", () => {
  assert.equal(
    growthDegiskenleri("A", "https://hupolingo.com//").iptal_baglantisi,
    "https://hupolingo.com/ticari-ileti-izni",
  );
});

test("şablon doldurulur: konu ve gövde değişkenlerle yazılır, yer tutucu kalmaz", () => {
  const r = growthMesajiHazirla(
    { subject: "Merhaba {{veli_adi}}", body: "Sevgiler {{veli_adi}}. İptal: {{iptal_baglantisi}}" },
    growthDegiskenleri("Ayşe Yılmaz", PANEL),
  );
  assert.equal(r.ok, true);
  if (!r.ok) return;
  assert.equal(r.mesaj.konu, "Merhaba Ayşe");
  assert.equal(r.mesaj.metin, "Sevgiler Ayşe. İptal: https://hupolingo.com/ticari-ileti-izni");
});

test("konu boşsa varsayılan konu kullanılır", () => {
  const r = growthMesajiHazirla({ subject: null, body: "Merhaba {{veli_adi}}" }, growthDegiskenleri(null, PANEL));
  assert.equal(r.ok, true);
  if (r.ok) assert.equal(r.mesaj.konu, "Hupolingo");
});

test("çocuk değişkeni içeren şablon eksik değişkenle reddedilir (çocuk verisi üretilmez)", () => {
  const r = growthMesajiHazirla(
    { subject: "Konu", body: "{{cocuk_adi}} bugün çalıştı. {{iptal_baglantisi}}" },
    growthDegiskenleri("Ayşe", PANEL),
  );
  assert.equal(r.ok, false);
  if (!r.ok) {
    assert.match(r.hata, /cocuk_adi/);
    assert.doesNotMatch(r.hata, /Ayşe/);
  }
});

test("konu ve gövdedeki eksik değişkenler tekil listelenir", () => {
  const r = growthMesajiHazirla(
    { subject: "{{konum}}", body: "{{konum}} {{foto}}" },
    growthDegiskenleri("A", PANEL),
  );
  assert.equal(r.ok, false);
  if (!r.ok) assert.equal(r.hata, "eksik değişken: konum,foto");
});

test("boş gövde reddedilir", () => {
  const r = growthMesajiHazirla({ subject: "Konu", body: "   " }, growthDegiskenleri("A", PANEL));
  assert.equal(r.ok, false);
  if (!r.ok) assert.equal(r.hata, "boş içerik");
});
