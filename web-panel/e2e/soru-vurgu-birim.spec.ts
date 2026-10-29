// Akıllı soru vurgulama: birim + bileşen testleri (tarayıcı açmaz, Node'da çalışır).
// Çalıştırma (PowerShell, sunucu gerekmez):
//   $env:E2E_BASE_URL="http://127.0.0.1:9"; npx playwright test e2e/soru-vurgu-birim.spec.ts --project=masaustu
import { expect, test } from "@playwright/test";
import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";

import QuestionRichText from "../src/components/ogrenci/QuestionRichText";
import { vurguParcalari } from "../src/lib/soru-vurgu";

const birlestir = (m: string, h: unknown) => vurguParcalari(m, h).map((p) => p.metin).join("");
const render = (metin: string, highlights?: unknown) =>
  renderToStaticMarkup(createElement(QuestionRichText, { metin, highlights }));

test.describe("vurguParcalari", () => {
  const M = "Aşağıdakilerden hangisi çift sayıdır?";

  test("geçerli aralık vurgulu parça üretir, birleşim özgün metne eşittir", () => {
    const p = vurguParcalari(M, [{ start: 16, end: 23 }]);
    expect(p.filter((x) => x.vurgulu).map((x) => x.metin)).toEqual(["hangisi"]);
    expect(p.map((x) => x.metin).join("")).toBe(M);
  });

  test("kod noktası ofseti: emoji (UTF-16 çift) sonrası kayma olmaz", () => {
    const m = "😀 Hangi sayı büyük?"; // 😀 = 1 kod noktası, 2 UTF-16 birimi
    const p = vurguParcalari(m, [{ start: 2, end: 7 }]);
    expect(p.find((x) => x.vurgulu)?.metin).toBe("Hangi");
    expect(birlestir(m, [{ start: 2, end: 7 }])).toBe(m);
  });

  test("Türkçe karakterler (İ, ı, ş, ğ) doğru kesilir", () => {
    const m = "İSTANBUL ışığı";
    expect(vurguParcalari(m, [{ start: 9, end: 14 }]).find((x) => x.vurgulu)?.metin).toBe("ışığı");
  });

  test("birden çok aralık ve metnin başı/sonu", () => {
    const m = "abcdef";
    const p = vurguParcalari(m, [{ start: 0, end: 2 }, { start: 4, end: 6 }]);
    expect(p.map((x) => [x.metin, x.vurgulu])).toEqual([
      ["ab", true],
      ["cd", false],
      ["ef", true],
    ]);
  });

  test("bitişik aralıklar (end == sonraki start) geçerlidir", () => {
    expect(vurguParcalari("abcd", [{ start: 0, end: 2 }, { start: 2, end: 4 }]).every((x) => x.vurgulu)).toBe(true);
  });

  const gecersizler: [string, unknown][] = [
    ["null", null],
    ["boş dizi", []],
    ["dizi değil", { start: 0, end: 2 }],
    ["end > uzunluk", [{ start: 0, end: 99 }]],
    ["start negatif", [{ start: -1, end: 2 }]],
    ["start == end", [{ start: 2, end: 2 }]],
    ["start > end", [{ start: 3, end: 1 }]],
    ["ondalık", [{ start: 0.5, end: 2 }]],
    ["metin sayı", [{ start: "0", end: 2 }]],
    ["eksik alan", [{ start: 0 }]],
    ["çakışan", [{ start: 0, end: 3 }, { start: 2, end: 4 }]],
    ["sırasız", [{ start: 4, end: 6 }, { start: 0, end: 2 }]],
    ["bir geçerli + bir geçersiz (tümü düşer)", [{ start: 0, end: 2 }, { start: 5, end: 99 }]],
    ["öğe null", [null]],
  ];
  for (const [ad, h] of gecersizler) {
    test(`geçersiz (${ad}) -> düz metin`, () => {
      const p = vurguParcalari("abcdef", h);
      expect(p).toEqual([{ metin: "abcdef", vurgulu: false }]);
    });
  }

  test("boş metin hata atmaz", () => {
    expect(vurguParcalari("", [{ start: 0, end: 1 }])).toEqual([{ metin: "", vurgulu: false }]);
  });
});

test.describe("QuestionRichText", () => {
  test("geçerli vurgu <strong class=soru-vurgu> üretir; metin aynen korunur", () => {
    const html = render("Altı çizili sözcüğü bul", [{ start: 0, end: 4 }]);
    expect(html).toContain('<strong class="soru-vurgu" data-soru-vurgu="">Altı</strong>');
    expect(html.replace(/<[^>]+>/g, "")).toBe("Altı çizili sözcüğü bul");
  });

  test("highlights yok veya geçersiz -> düz metin, vurgu öğesi yok", () => {
    expect(render("Düz soru")).toBe("Düz soru");
    expect(render("Düz soru", [{ start: 5, end: 99 }])).toBe("Düz soru");
    expect(render("Düz soru", "bozuk")).toBe("Düz soru");
  });

  test("HTML kaçışı: metin içindeki < > & güvenle yazılır", () => {
    const html = render("a < b & c", [{ start: 0, end: 1 }]);
    expect(html).toContain("&lt;");
    expect(html).toContain("&amp;");
    expect(html).not.toContain("<b ");
  });
});
