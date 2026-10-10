// Karakter görsellerinin TEK KAYNAĞI mobile-app/assets/characters'tır.
// Web paneli bu görselleri /characters/<sınıf>/<kod>.webp yolunda sunar; kopya
// web-panel/public/characters altında üretilir ve git'e girmez (.gitignore).
// npm run dev / npm run build öncesi (predev / prebuild) otomatik çalışır.
import { cpSync, existsSync, readdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const webKok = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const kaynak = resolve(webKok, "..", "mobile-app", "assets", "characters");
const hedef = resolve(webKok, "public", "characters");

if (!existsSync(kaynak)) {
  // Yalnızca web klasörü ayrı alınmışsa: mevcut kopya kullanılır.
  if (existsSync(hedef)) {
    console.warn("UYARI: mobile-app/assets/characters yok; mevcut web kopyası kullanılıyor.");
    process.exit(0);
  }
  console.error("HATA: karakter kaynağı yok (mobile-app/assets/characters) ve web kopyası da yok.");
  process.exit(1);
}

cpSync(kaynak, hedef, { recursive: true });

const adet = readdirSync(hedef, { recursive: true, withFileTypes: true })
  .filter((girdi) => girdi.isFile()).length;
console.log(`Karakter görselleri kopyalandı: ${adet} dosya (kaynak: mobile-app/assets/characters)`);
