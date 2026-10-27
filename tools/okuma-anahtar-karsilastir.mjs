// Bir git sürümüyle şimdiki hikâye dosyaları arasında doğru-seçenek metni ve harfi değişen soruları listeler.
// Kullanım: node tools/okuma-anahtar-karsilastir.mjs <git-sürümü>
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";

const KOK = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const yaml = createRequire(path.join(KOK, "web-panel", "package.json"))("js-yaml");
const surum = process.argv[2];
if (!surum) throw new Error("git sürümü gerekli");
const DIZIN = "icerik/okuma/hikaye/";
const on = (t) => yaml.load(t.replace(/\r\n/g, "\n").slice(4, t.replace(/\r\n/g, "\n").indexOf("\n---\n", 4)));
let degisen = 0;
for (const f of fs.readdirSync(path.join(KOK, DIZIN)).filter((x) => x.endsWith(".hikaye.md")).sort()) {
  let eski;
  try { eski = execFileSync("git", ["show", `${surum}:${DIZIN}${f}`], { cwd: KOK, encoding: "utf8", maxBuffer: 1 << 26 }); } catch { continue; }
  const e = on(eski), y = on(fs.readFileSync(path.join(KOK, DIZIN, f), "utf8"));
  for (const s of y.sorular || []) {
    const es = (e.sorular || []).find((q) => q.id === s.id);
    if (!es) continue;
    const dm = (q) => q.secenekler.find((o) => o.id === q.dogru)?.metin;
    if (es.dogru !== s.dogru || dm(es) !== dm(s)) {
      degisen++;
      console.log(`${f.slice(0, 5)} ${s.id}: ${es.dogru}→${s.dogru}\n   ESKİ: ${dm(es)}\n   YENİ: ${dm(s)}`);
    }
  }
}
console.log(`doğru seçenek/harf değişen soru: ${degisen}`);
