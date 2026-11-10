// HupoRead kahraman türü kapsam denetimi (model çağrısı yok).
// Kullanım: node tools/okuma-kahraman-kapsam.mjs [--esik 3]
// Her kahraman türü için icerik/okuma/paket/*.paket.json içindeki hikaye.izinli_turler
// üzerinden hikâye sayısını yazar. 'hazir' her hikâyeye uygun olduğu için denetlenmez.
// YAKINDA_IZINLI türleri (henüz hikâyesi olmayan türler) eşik dışıdır.
// Eşiğin altında kalan denetimli bir tür varsa 1 ile çıkar; okunamayan paket varsa 2 ile çıkar.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const KOK = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const DIZIN = path.join(KOK, "icerik", "okuma", "paket");

// Sunucudaki (izinli_turler) kodları ve uygulamadaki KahramanTuru.kod değerleri.
const TURLER = ["ben", "anne", "baba", "kardes", "arkadas", "baska_biri", "hayvan", "arac", "hayali"];
const HER_HIKAYEDE = "hazir";
const YAKINDA_IZINLI = new Set(["anne", "baba", "arac"]);

const esikIdx = process.argv.indexOf("--esik");
const ESIK = esikIdx === -1 ? 3 : Number(process.argv[esikIdx + 1]);
if (!Number.isInteger(ESIK) || ESIK < 0) {
  console.error("HATA: --esik negatif olmayan tam sayı olmalı.");
  process.exit(2);
}

const dosyalar = fs
  .readdirSync(DIZIN)
  .filter((ad) => ad.endsWith(".paket.json"))
  .sort();

const sayac = Object.fromEntries(TURLER.map((t) => [t, 0]));
const hatalar = [];
let hikayeSayisi = 0;

for (const ad of dosyalar) {
  let hikaye;
  try {
    hikaye = JSON.parse(fs.readFileSync(path.join(DIZIN, ad), "utf8")).hikaye;
  } catch (e) {
    hatalar.push(`${ad}: okunamadı (${e.message})`);
    continue;
  }
  const turler = hikaye?.izinli_turler;
  if (!Array.isArray(turler)) {
    hatalar.push(`${ad}: hikaye.izinli_turler dizi değil`);
    continue;
  }
  hikayeSayisi++;
  for (const t of new Set(turler)) {
    if (t === HER_HIKAYEDE) continue;
    if (!(t in sayac)) {
      hatalar.push(`${ad}: bilinmeyen tür kodu '${t}'`);
      continue;
    }
    sayac[t]++;
  }
}

if (hatalar.length) {
  console.error("HATA: paket dosyaları denetlenemedi (sayılar güvenilir değil):");
  for (const h of hatalar) console.error(`  - ${h}`);
  process.exit(2);
}

console.log(`Kahraman türü kapsamı: ${hikayeSayisi} paket, eşik ${ESIK}`);
console.log("tür            hikâye  durum");
const altinda = [];
for (const t of TURLER) {
  const n = sayac[t];
  let durum;
  if (YAKINDA_IZINLI.has(t)) {
    durum = "yakında izinli (denetim dışı)";
  } else if (n < ESIK) {
    durum = `EKSİK (en az ${ESIK} gerekli)`;
    altinda.push(t);
  } else {
    durum = "tamam";
  }
  console.log(`${t.padEnd(14)} ${String(n).padStart(6)}  ${durum}`);
}
console.log(`${HER_HIKAYEDE.padEnd(14)} ${"-".padStart(6)}  her hikâyede açık (denetim dışı)`);

if (altinda.length) {
  console.error(`\nSONUÇ: eşiğin altında ${altinda.length} tür: ${altinda.join(", ")}`);
  process.exit(1);
}
console.log("\nSONUÇ: denetimli tüm türler eşiğin üstünde.");
