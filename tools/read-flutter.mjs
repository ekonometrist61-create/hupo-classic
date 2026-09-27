// Flutter web uygulamasini headless tarayicida ac ve canvas uzerindeki
// metni okumaya calis. Flutter metni DOM'a degil, Canvas'a cizer; bu yuzden
// oncelikle semantics agacini (erişilebilirlik) acip oradan okuyoruz.
export default async function run(page, ui) {
  // Flutter, semantik agaci ancak erisilebilirlik acikken DOM'a yazar.
  await page.waitForSelector("flutter-view", { timeout: 90000 });
  await page.waitForTimeout(4000);

  // "Semantics" dugmesi ya da erisilebilirlik anahtari: Flutter bunu
  // bir <flt-semantics-placeholder> uzerinden sunar.
  await page.evaluate(() => {
    const ph = document.querySelector("flt-semantics-placeholder");
    if (ph) ph.click();
  });
  await page.waitForTimeout(3000);

  const info = await page.evaluate(() => {
    const host = document.querySelector("flt-semantics-host");
    const root = host || document.body;
    const nodes = Array.from(root.querySelectorAll("flt-semantics"))
      .map((n) => (n.getAttribute("aria-label") || n.textContent || "").trim())
      .filter((s) => s.length > 0);
    return {
      title: document.title,
      lang: document.documentElement.lang,
      semantikDugum: nodes.length,
      ornek: nodes.slice(0, 40),
      canvas: document.querySelectorAll("canvas").length,
    };
  });

  return info;
}
