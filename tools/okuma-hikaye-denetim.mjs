// HupoRead hikâye kaynak denetimi (model çağrısı yok).
// Kullanım: node tools/okuma-hikaye-denetim.mjs [--json] [--ayrinti]
// Ölçer: cevap harfi dağılımı, sorusuz hikâye, soru kökünde metinde olmayan ad,
// art arda yinelenen cümle.
import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";

const KOK = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const yaml = createRequire(path.join(KOK, "web-panel", "package.json"))("js-yaml");
const DIZIN = path.join(KOK, "icerik", "okuma", "hikaye");

export function hikayeOku(dosya) {
  const t = fs.readFileSync(dosya, "utf8").replace(/\r\n/g, "\n");
  const son = t.indexOf("\n---\n", 4);
  return { on: yaml.load(t.slice(4, son)), govde: t.slice(son + 5) };
}

// Kişi adı sözlüğü: soru kökünde geçip gövdede (kahraman/yoldaş yer tutucuları dışında) olmayan adlar.
const ADLAR = ["Ömer","Ece","Selin","Emir","Kerem","Baran","Ada","Nisan","Leyla","İpek","Nil","Ekin","İrem","Defne","Bora","Nehir","Elif","İdil","Sena","Deniz","Faruk","Mert","Kaan","Mina","Ayçın","Suna","Lalin","Yağız","Alin","Banu","Asya","Zeynep","Mustafa","Ayşe","Ahmet","Can","Ali","Ayşe","Cem","Eda","Efe"];

function stemAdlari(metin, govde) {
  return ADLAR.filter((a) => new RegExp(`(^|[^\\p{L}])${a}(?![\\p{L}])`, "u").test(metin) && !new RegExp(`(^|[^\\p{L}])${a}(?![\\p{L}])`, "u").test(govde));
}
export function denetle() {
  const dagilim = { A: 0, B: 0, C: 0, D: 0 };
  const sonuc = { hikaye: 0, soru: 0, sorusuz: [], karsiliksizAd: {}, tekrar: [], dagilim, hikayeHarfDagilimi: {} };
  for (const ad of fs.readdirSync(DIZIN).filter((a) => a.endsWith(".hikaye.md")).sort()) {
    const kod = ad.slice(0, 5).toUpperCase().replace("HR", "HR-");
    const { on, govde } = hikayeOku(path.join(DIZIN, ad));
    sonuc.hikaye++;
    const sorular = on.sorular || [];
    if (!sorular.length) sonuc.sorusuz.push(kod);
    const h = { A: 0, B: 0, C: 0, D: 0 };
    for (const s of sorular) {
      sonuc.soru++;
      dagilim[s.dogru]++;
      h[s.dogru]++;
      const adlar = stemAdlari(s.metin, govde);
      if (adlar.length) (sonuc.karsiliksizAd[kod] ||= []).push(...adlar);
    }
    sonuc.hikayeHarfDagilimi[kod] = h;
    const cumleler = govde.split(/(?<=[.!?”])\s+/).map((c) => c.trim());
    if (cumleler.some((c, i) => i && c.length > 25 && c === cumleler[i - 1])) sonuc.tekrar.push(kod);
  }
  return sonuc;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const s = denetle();
  if (process.argv.includes("--json")) {
    console.log(JSON.stringify(s, null, 2));
  } else {
    const d = s.dagilim, n = s.soru;
    const yuzde = (x) => ((100 * x) / n).toFixed(1) + "%";
    console.log(`Hikâye: ${s.hikaye}, soru: ${n}, sorusuz: ${s.sorusuz.length ? s.sorusuz.join(",") : "yok"}`);
    console.log(`Cevap dağılımı: A=${d.A} (${yuzde(d.A)}) B=${d.B} (${yuzde(d.B)}) C=${d.C} (${yuzde(d.C)}) D=${d.D} (${yuzde(d.D)})`);
    const kotu = Object.entries(s.hikayeHarfDagilimi).filter(([, h]) => Math.max(...Object.values(h)) >= 3 && Object.values(h).reduce((a, b) => a + b) <= 5).length;
    console.log(`Tek harfi 3+ kez olan kısa (<=5 soru) hikâye: ${kotu}`);
    console.log(`Soru kökünde karşılıksız ad olan hikâye: ${Object.keys(s.karsiliksizAd).length}`);
    console.log(`Art arda tekrar eden cümle: ${s.tekrar.join(",") || "yok"}`);
    if (process.argv.includes("--ayrinti")) console.log(JSON.stringify(s.karsiliksizAd));
  }
}

