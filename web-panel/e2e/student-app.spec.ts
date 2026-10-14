import { expect, test } from "@playwright/test";

// Öğrenci uygulaması (Flutter web) ayrı origin'de yayında. Varsayılan üretim
// adresi; farklı bir ortam için E2E_OGRENCI_URL ile değiştirilebilir.
const OGRENCI_URL = process.env.E2E_OGRENCI_URL ?? "https://app.hupolingo.com";

test.describe("Öğrenci uygulaması", () => {
  test("/ogrenci öğrenci uygulamasına kalıcı olarak yönlendiriliyor", async ({ request }) => {
    // Yönlendirmeyi takip etmeden yanıtın kendisini okuyoruz.
    const yanit = await request.get("/ogrenci", { maxRedirects: 0 });
    expect([301, 308]).toContain(yanit.status());
    // Sunucu sondaki eğik çizgiyi ekleyebilir; karşılaştırma kökene (origin) göre.
    expect(new URL(yanit.headers()["location"]).origin).toBe(new URL(OGRENCI_URL).origin);
  });

  test("Flutter web uygulaması yükleniyor", async ({ page }) => {
    test.setTimeout(90_000);
    await page.goto(OGRENCI_URL, { waitUntil: "domcontentloaded" });
    // Flutter, derlenmiş uygulamayı başlatınca bu öğelerden birini ekler.
    await expect(page.locator("flutter-view, flt-glass-pane").first()).toBeAttached({
      timeout: 60_000,
    });
  });
});
