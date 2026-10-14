import { defineConfig, devices } from "@playwright/test";

// Yerel dev sunucusu (varsayılan 3000). Geliştiricinin zaten çalışan bir
// sunucusu varsa (reuseExistingServer) onu kullanır, kapatmaz.
const PORT = Number(process.env.E2E_PORT ?? 3000);
// E2E_BASE_URL verilirse (örn. Vercel önizleme) yerel sunucu başlatılmaz.
const BASE_URL = process.env.E2E_BASE_URL ?? `http://localhost:${PORT}`;
// E2E_DEMO=1: sunucu NEXT_PUBLIC_DEMO_MODE=1 ile dev modunda açılır; oturum ve rol
// kontrolü kapanır, admin/veli ekranları örnek veriyle görülür. Dev modu çok yavaştır
// (ilk sayfa derlemesi onlarca saniye sürer), yalnızca görsel kontrol için.
const DEMO = process.env.E2E_DEMO === "1";
// Varsayılan: üretim derlemesi (`next build` + `next start`). Gerçek davranışı ve
// hızı verir. Derleme zaten varsa E2E_SKIP_BUILD=1 ile derleme adımı atlanır.
const SKIP_BUILD = process.env.E2E_SKIP_BUILD === "1";

function sunucuKomutu(): string {
  if (DEMO) return "npm run dev";
  return SKIP_BUILD
    ? `npm run start -- -p ${PORT}`
    : `npm run build && npm run start -- -p ${PORT}`;
}

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: [["list"], ["html", { open: "never" }]],
  timeout: 30_000,
  use: {
    baseURL: BASE_URL,
    // Uygulama Türkçe varsayılanlıdır; tarayıcı dili (en-US) çeviri seçimini değiştirmesin.
    locale: "tr-TR",
    timezoneId: "Europe/Istanbul",
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  projects: [
    {
      name: "masaustu",
      use: { ...devices["Desktop Chrome"] },
      // Telefon düzeni ayrı projede (aşağıda) test edilir.
      testIgnore: /mobile\.spec\.ts/,
    },
    {
      name: "mobil",
      use: { ...devices["Pixel 7"] },
      testMatch: /(home|login|mobile|student-app|crawl)\.spec\.ts/,
    },
  ],
  webServer: process.env.E2E_BASE_URL
    ? undefined
    : {
        command: sunucuKomutu(),
        url: BASE_URL,
        reuseExistingServer: true,
        timeout: 300_000,
        env: {
          ...process.env,
          NEXT_PUBLIC_DEMO_MODE: DEMO ? "1" : "",
        } as Record<string, string>,
      },
});
