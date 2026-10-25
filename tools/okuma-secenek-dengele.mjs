// HupoRead: hikâye çoktan seçmeli sorularının doğru cevap harfini dengeler (metin düzeyi, YAML yeniden serileştirilmez).
// Kullanım: node tools/okuma-secenek-dengele.mjs [--uygula]
// Varsayılan kuru çalıştırma: dosya yazmaz; önce/sonra dağılımı, atlanan ve değişecek soruları yazdırır.
// Gövde, ön yüzün diğer alanları ve biçim byte düzeyinde korunur; yalnız secenekler metinlerinin sırası ve dogru harfi değişir.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { hikayeOku } from "./okuma-hikaye-denetim.mjs";

const KOK = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const DIZIN = path.join(KOK, "icerik", "okuma", "hikaye");
const UYGULA = process.argv.includes("--uygula");
const HARFLER = ["A", "B", "C", "D"];
const ATLA_SECENEK = /hepsi|hiçbiri|yukarıdaki|aşağıdaki|\b[A-D]\s*(ve|veya)\s*[A-D]\b|\b[A-D]\s*(şıkkı|seçeneği)/i;
const ATLA_ALAN = /\b[A-D]\s*(şıkkı|seçeneği)/i;

// Deterministik eşitlik kırıcı (FNV-1a 32 bit); Math.random kullanılmaz.
function fnv(s) {
  let h = 0x811c9dc5;
  for (const ch of s) {
    h ^= ch.codePointAt(0);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h >>> 0;
}

// Ham satırları (CR korunarak) ve soru konumlarını çıkarır.
function analiz(yol) {
  const ham = fs.readFileSync(yol, "utf8");
  const L = ham.split("\n").map((s) => {
    const cr = s.endsWith("\r") ? "\r" : "";
    return { c: s.slice(0, s.length - cr.length), cr };
  });
  const { on, govde } = hikayeOku(yol);
  const fmEnd = L.findIndex((x, i) => i > 0 && x.c === "---");
  const sStart = L.findIndex((x, i) => i < fmEnd && x.c === "sorular:");
  let sEnd = fmEnd;
  for (let i = sStart + 1; i < fmEnd; i++) if (/^\S/.test(L[i].c)) { sEnd = i; break; }
  const starts = [];
  for (let i = sStart + 1; i < sEnd; i++) if (/^  - /.test(L[i].c)) starts.push(i);
  if (starts.length !== on.sorular.length) throw new Error(`${yol}: soru başlığı sayısı uyuşmuyor`);

  const sorular = starts.map((bas, q) => {
    const son = q + 1 < starts.length ? starts[q + 1] : sEnd;
    const obj = on.sorular[q];
    const n = obj.secenekler.length;
    const opts = [];
    let dogruYer = null;
    const c0 = L[bas].c;
    if (c0.includes("secenekler: [")) {
      // Tek satır biçimi
      const a = c0.indexOf("secenekler: [") + "secenekler: [".length;
      const b = c0.indexOf("], dogru: ", a);
      if (b < 0) throw new Error(`${yol}: ${obj.id} tek satır biçimi beklenmedik`);
      const seg = c0.slice(a, b);
      const re = /(\{id: ([A-D]), metin: )("(?:[^"\\]|\\.)*"|[^}]*?)(\})/g;
      let m;
      while ((m = re.exec(seg))) {
        const s0 = a + m.index + m[1].length;
        opts.push({ li: bas, id: m[2], bas: s0, son: s0 + m[3].length });
      }
      const d0 = b + "], dogru: ".length;
      dogruYer = { li: bas, bas: d0, son: d0 + 1 };
    } else {
      // Blok biçim
      for (let i = bas + 1; i < son; i++) {
        const c = L[i].c;
        const m = /^(\s*-\s*\{id: ([A-D]), metin: )(.*)(\}\s*)$/.exec(c);
        if (m) opts.push({ li: i, id: m[2], bas: m[1].length, son: m[1].length + m[3].length });
        const d = /^(\s*dogru: )([A-D])/.exec(c);
        if (d) dogruYer = { li: i, bas: d[1].length, son: d[1].length + 1 };
      }
    }
    if (opts.length !== n) throw new Error(`${yol}: ${obj.id} seçenek satırı ${opts.length}/${n}`);
    opts.forEach((o, i) => {
      if (o.id !== HARFLER[i]) throw new Error(`${yol}: ${obj.id} seçenek sırası beklenmedik`);
    });
    if (!dogruYer) throw new Error(`${yol}: ${obj.id} dogru satırı yok`);
    const dogruHarf = L[dogruYer.li].c.slice(dogruYer.bas, dogruYer.son);
    if (dogruHarf !== obj.dogru) throw new Error(`${yol}: ${obj.id} dogru konumu uyuşmuyor`);
    return { obj, opts, dogruYer };
  });
  return { L, on, govde, sorular };
}

function satirlarBirlestir(L) {
  return L.map((x) => x.c + x.cr).join("\n");
}

const dosyalar = fs.readdirSync(DIZIN).filter((a) => a.endsWith(".hikaye.md")).sort();
const orijinal = { A: 0, B: 0, C: 0, D: 0 };
const sayim = { A: 0, B: 0, C: 0, D: 0 };
const atlanan = [];
const degisen = [];
const plan = []; // doğrulama için
let toplam = 0;
const dosyaYazilacak = new Map(); // yol -> {L0, L1, beklenen}

for (const ad of dosyalar) {
  const yol = path.join(DIZIN, ad);
  const { L, on, govde, sorular } = analiz(yol);
  const L0 = L.map((x) => ({ ...x }));
  const fis = on.fis_kodu ?? "";
  const dosyaPlan = [];

  for (const q of sorular) {
    toplam++;
    const o = q.obj;
    const n = o.secenekler.length;
    const harfler = HARFLER.slice(0, n);
    const cur = HARFLER.indexOf(o.dogru);
    orijinal[o.dogru]++;

    let sebep = null;
    if (o.secenekler.some((s) => ATLA_SECENEK.test(String(s.metin)))) {
      sebep = "seçenek metni: hepsi/hiçbiri/yukarıdaki/aşağıdaki/A ve B/A şıkkı";
    } else {
      const alanlar = [o.metin, o.aciklama, o.dayanak].map((v) => (v == null ? "" : typeof v === "string" ? v : JSON.stringify(v)));
      if (alanlar.some((v) => ATLA_ALAN.test(v))) sebep = "metin/açıklama/dayanak: X şıkkı/seçeneği";
    }
    if (sebep) {
      atlanan.push(`${ad} ${o.id} (${sebep})`);
      sayim[o.dogru]++;
      continue;
    }

    const min = Math.min(...harfler.map((h) => sayim[h]));
    const adaylar = harfler.filter((h) => sayim[h] === min);
    const hedef = adaylar[fnv(`${fis}|${o.id}`) % adaylar.length];
    const t = HARFLER.indexOf(hedef);
    sayim[hedef]++;
    if (t === cur) continue;

    // Doğru seçenek hedef konuma; diğerleri göreli sırasını korur.
    const diger = [...Array(n).keys()].filter((i) => i !== cur);
    diger.splice(t, 0, cur);
    const eskiTok = q.opts.map((x) => L[x.li].c.slice(x.bas, x.son));
    const yeniTok = diger.map((i) => eskiTok[i]);
    const duzenler = [];
    yeniTok.forEach((tok, j) => {
      if (tok !== eskiTok[j]) duzenler.push({ li: q.opts[j].li, bas: q.opts[j].bas, son: q.opts[j].son, metin: tok });
    });
    duzenler.push({ li: q.dogruYer.li, bas: q.dogruYer.bas, son: q.dogruYer.son, metin: hedef });
    // Satır içi düzenlemeleri sondan başa uygula.
    duzenler.sort((x, y) => (x.li - y.li) || (y.bas - x.bas));
    for (const e of duzenler) {
      const c = L[e.li].c;
      L[e.li].c = c.slice(0, e.bas) + e.metin + c.slice(e.son);
    }
    degisen.push(`${ad} ${o.id}: ${o.dogru} -> ${hedef}`);
    dosyaPlan.push({
      id: o.id,
      eskiDogru: o.dogru,
      yeniDogru: hedef,
      diger,
      eskiSecenekler: o.secenekler,
    });
  }

  if (dosyaPlan.length) {
    // Doğrulama: yalnız seçenek/dogru satırları değişmiş olmalı.
    if (L.length !== L0.length) throw new Error(`${ad}: satır sayısı değişti`);
    for (let i = 0; i < L.length; i++) {
      if (L[i].c !== L0[i].c && !/\{id: |dogru:/.test(L[i].c)) throw new Error(`${ad}: beklenmeyen satır değişimi ${i + 1}`);
    }
    plan.push({ yol, ad, on, govde, L0, L, dosyaPlan });
  }
}

const dagilimStr = (d) => {
  const top = Object.values(d).reduce((a, b) => a + b, 0);
  return HARFLER.map((h) => `${h}=${d[h]} (${((100 * d[h]) / top).toFixed(1)}%)`).join("  ");
};
console.log(`Hikâye dosyası: ${dosyalar.length}, soru: ${toplam}`);
console.log(`ÖNCE  : ${dagilimStr(orijinal)}`);
console.log(`SONRA : ${dagilimStr(sayim)}  (atlananlar dahil; mevcut harfleri)`);
console.log(`Atlanan soru: ${atlanan.length}`);
for (const a of atlanan) console.log(`  - ${a}`);
console.log(`Değişecek soru: ${degisen.length}`);
if (process.argv.includes("--ayrinti")) for (const d of degisen) console.log(`  * ${d}`);

if (!UYGULA) {
  console.log("KURU ÇALIŞTIRMA: dosya yazılmadı. Uygulamak için --uygula.");
  process.exit(0);
}

// Yazma ve yazma sonrası doğrulama.
for (const p of plan) {
  fs.writeFileSync(p.yol, satirlarBirlestir(p.L), "utf8");
}
let hata = 0;
for (const p of plan) {
  const yeni = hikayeOku(p.yol);
  const beklenenOn = JSON.parse(JSON.stringify(p.on));
  for (const d of p.dosyaPlan) {
    const s = beklenenOn.sorular.find((x) => x.id === d.id);
    s.secenekler = d.diger.map((i, j) => ({ ...d.eskiSecenekler[i], id: HARFLER[j] }));
    s.dogru = d.yeniDogru;
  }
  const a = JSON.stringify(beklenenOn);
  const b = JSON.stringify(yeni.on);
  if (a !== b || yeni.govde !== p.govde) {
    hata++;
    console.error(`DOĞRULAMA HATASI: ${p.ad}`);
    continue;
  }
  for (const d of p.dosyaPlan) {
    const s = yeni.on.sorular.find((x) => x.id === d.id);
    const eskiMetin = d.eskiSecenekler.find((x) => x.id === d.eskiDogru).metin;
    const yeniMetin = s.secenekler.find((x) => x.id === s.dogru).metin;
    if (eskiMetin !== yeniMetin || s.dogru !== d.yeniDogru) {
      hata++;
      console.error(`ANAHTAR HATASI: ${p.ad} ${d.id}`);
    }
  }
}
console.log(`Yazılan dosya: ${plan.length}, doğrulama hatası: ${hata}`);
