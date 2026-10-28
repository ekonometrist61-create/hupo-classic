// Çalıştırma (Deno):  deno test supabase/functions/_shared/sablon.test.ts
// Çalıştırma (Node):  node --test supabase/functions/_shared/sablon.test.ts
// node:test hem Deno hem Node'da çalışır; dış bağımlılık yoktur.
import test from "node:test";
import assert from "node:assert/strict";
import { sablonDoldur } from "./sablon.ts";

test("değişken yerleştirilir ve eksik listesi boş kalır", () => {
  const r = sablonDoldur("Merhaba {{ad}}!", { ad: "Ayşe" });
  assert.equal(r.metin, "Merhaba Ayşe!");
  assert.deepEqual(r.eksikDegiskenler, []);
});

test("boşluk toleransı: {{ ad }} ve {{  soyad  }} da çalışır", () => {
  const r = sablonDoldur("{{ ad }} {{  soyad  }}", { ad: "Can", soyad: "Yılmaz" });
  assert.equal(r.metin, "Can Yılmaz");
});

test("bilinmeyen değişken boş bırakılmaz: yer tutucu kalır ve listelenir", () => {
  const r = sablonDoldur("{{ad}}, sınıfın {{sinif}}.", { ad: "X" });
  assert.equal(r.metin, "X, sınıfın {{sinif}}.");
  assert.deepEqual(r.eksikDegiskenler, ["sinif"]);
});

test("null ve undefined değer eksik sayılır", () => {
  const r = sablonDoldur("{{a}}-{{b}}", { a: null, b: undefined });
  assert.equal(r.metin, "{{a}}-{{b}}");
  assert.deepEqual(r.eksikDegiskenler, ["a", "b"]);
});

test("boş string bilerek boş yazılır ve eksik sayılmaz", () => {
  const r = sablonDoldur("[{{ad}}]", { ad: "" });
  assert.equal(r.metin, "[]");
  assert.deepEqual(r.eksikDegiskenler, []);
});

test("aynı eksik değişken iki kez geçse de listede bir kez yer alır", () => {
  const r = sablonDoldur("{{x}} {{y}} {{x}}", {});
  assert.deepEqual(r.eksikDegiskenler, ["x", "y"]);
});

test("sayı ve boolean metne çevrilir; nesne eksik sayılır", () => {
  const r = sablonDoldur("{{n}} {{b}} {{o}}", { n: 3, b: false, o: { a: 1 } });
  assert.equal(r.metin, "3 false {{o}}");
  assert.deepEqual(r.eksikDegiskenler, ["o"]);
});

test("tek geçiş: değerin içindeki yer tutucu tekrar genişletilmez", () => {
  const r = sablonDoldur("{{ad}}", { ad: "{{soyad}}", soyad: "Y" });
  assert.equal(r.metin, "{{soyad}}");
  assert.deepEqual(r.eksikDegiskenler, []);
});

test("fazla anahtarlar yok sayılır", () => {
  const r = sablonDoldur("{{ad}}", { ad: "A", kullanilmayan: "B" });
  assert.equal(r.metin, "A");
});

test("prototip zinciri anahtarları (toString gibi) değişken sayılmaz", () => {
  const r = sablonDoldur("{{toString}}", {});
  assert.equal(r.metin, "{{toString}}");
  assert.deepEqual(r.eksikDegiskenler, ["toString"]);
});

test("htmlKacis kapalıyken değer ham yazılır", () => {
  const r = sablonDoldur("<p>{{ad}}</p>", { ad: "<b>A & B</b>" });
  assert.equal(r.metin, "<p><b>A & B</b></p>");
});

test("htmlKacis açıkken değer kaçışlanır, şablon gövdesi kaçışlanmaz", () => {
  const r = sablonDoldur("<p>{{ad}}</p>", { ad: `<b>"A" & 'B'</b>` }, { htmlKacis: true });
  assert.equal(r.metin, "<p>&lt;b&gt;&quot;A&quot; &amp; &#39;B&#39;&lt;/b&gt;</p>");
});

test("htmlKacis açıkken gövdedeki HTML etiketleri korunur", () => {
  const r = sablonDoldur("<strong>Merhaba</strong> {{ad}}", { ad: "Zeynep" }, { htmlKacis: true });
  assert.equal(r.metin, "<strong>Merhaba</strong> Zeynep");
});
