import { expect, test, type TestInfo } from "@playwright/test";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname } from "node:path";

import { tara, type TaramaSonucu } from "./support/crawler";
import { DEMO, karsilamaAtla } from "./helpers";

// Ortam değişkenleriyle ayarlanabilir: E2E_CRAWL_SAYFA, E2E_CRAWL_EYLEM, E2E_SEED, E2E_SKIP_EXTERNAL.
const MAKS_SAYFA = Number(process.env.E2E_CRAWL_SAYFA ?? 25);
const MAKS_EYLEM = Number(process.env.E2E_CRAWL_EYLEM ?? 8);
const DIS_LINK_KONTROL = process.env.E2E_SKIP_EXTERNAL !== "1";

// Oturum gerektirmeyen, veri değiştirmeyen herkese açık sayfalar.
const KAMU_TOHUMLAR = [
  "/",
  "/veli-paneli/giris",
  "/veli-paneli/kayit",
  "/yonetim-giris",
  "/demo",
  "/sifre-unuttum",
  "/gizlilik",
  "/kosullar",
  "/ticari-ileti-izni",
  "/iletisim-izni",
  "/deneme-sinavi-kayit",
  "/sifre-yeni",
];

/** Tohum: E2E_SEED verilirse onu kullanır; yoksa rastgele. Raporda yazılır, böylece tekrar üretilebilir. */
function tohumSec(): number {
  return process.env.E2E_SEED ? Number(process.env.E2E_SEED) : Math.floor(Math.random() * 1_000_000_000);
}

async function raporuKaydet(testInfo: TestInfo, sonuc: TaramaSonucu, tohum: number, tohumlar: string[]) {
  const rapor = {
    tohum,
    tekrarKomutu: `E2E_SEED=${tohum} npx playwright test e2e/crawl.spec.ts --project=${testInfo.project.name}`,
    tohumlar,
    ziyaretEdilenSayfa: sonuc.ziyaretEdilen.length,
    eylemSayisi: sonuc.eylemSayisi,
    sureSiniriDoldu: sonuc.sureSiniriDoldu,
    tiklanamayanEylem: sonuc.eylemHatasi,
    engellenenYazmaIstegi: sonuc.engellenenYazmalar.length,
    bulguSayisi: sonuc.bulgular.length,
    bulgular: sonuc.bulgular,
    ziyaretEdilenYollar: sonuc.ziyaretEdilen,
  };
  const json = JSON.stringify(rapor, null, 2);
  await testInfo.attach("tarama-raporu.json", { body: json, contentType: "application/json" });
  // Tam rapor test-results altında da durur (ekran görüntüsü ve iz dosyalarıyla birlikte).
  await mkdir(dirname(testInfo.outputPath("x")), { recursive: true });
  await writeFile(testInfo.outputPath("tarama-raporu.json"), json, "utf8");
  console.log(
    `[tarayici] tohum=${tohum} sayfa=${sonuc.ziyaretEdilen.length} eylem=${sonuc.eylemSayisi} bulgu=${sonuc.bulgular.length}`,
  );
}

function bulguMetni(sonuc: TaramaSonucu): string {
  if (sonuc.bulgular.length === 0) return "Bulgu yok.";
  return sonuc.bulgular
    .map((b, i) => {
      const izler = b.eylemler.map((e) => `      ${e}`).join("\n");
      return `${i + 1}. [${b.tur}] ${b.sayfa}\n     ${b.mesaj}\n${izler}`;
    })
    .join("\n\n");
}

test.describe("Tarayıcı gezgini (monkey test)", () => {
  test.setTimeout(20 * 60_000);

  test("herkese açık sayfalar: bağlantılar, düğmeler, alanlar; 404 ve konsol hatalarını yakalar", async ({
    page,
    request,
    baseURL,
  }, testInfo) => {
    await karsilamaAtla(page);
    const tohum = tohumSec();

    const sonuc = await tara(page, request, baseURL!, {
      tohumlar: KAMU_TOHUMLAR,
      maksSayfa: MAKS_SAYFA,
      maksEylem: MAKS_EYLEM,
      tohum,
      disLinkKontrol: DIS_LINK_KONTROL,
    });

    await raporuKaydet(testInfo, sonuc, tohum, KAMU_TOHUMLAR);
    expect(sonuc.bulgular, bulguMetni(sonuc)).toHaveLength(0);
  });

  test("yönetim ve veli panelleri: yalnızca demo modunda (yerel, sahte veri)", async ({
    page,
    request,
    baseURL,
  }, testInfo) => {
    // Üretim verisine karşı rastgele tıklama yapılmaz. Panel taraması yalnızca demo
    // modunda (sahte veri, dev sunucusu) ve masaüstü projesinde çalışır.
    test.skip(!DEMO, "Panel taraması yalnızca E2E_DEMO=1 ile (yerel, sahte veri) çalışır.");
    test.skip(testInfo.project.name !== "masaustu", "Panel taraması masaüstü projesinde çalışır.");

    await karsilamaAtla(page);
    const tohum = tohumSec();
    const tohumlar = ["/yonetim", "/veli-paneli"];

    const sonuc = await tara(page, request, baseURL!, {
      tohumlar,
      maksSayfa: Number(process.env.E2E_CRAWL_PANEL_SAYFA ?? 60),
      maksEylem: MAKS_EYLEM,
      tohum,
      disLinkKontrol: false,
    });

    await raporuKaydet(testInfo, sonuc, tohum, tohumlar);
    expect(sonuc.bulgular, bulguMetni(sonuc)).toHaveLength(0);
  });
});
