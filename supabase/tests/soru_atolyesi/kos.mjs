// Soru Atölyesi paket içe aktarma doğrulaması: PGlite (Postgres WASM). Docker gerekmez.
// Kullanım (proje kökünden): node supabase/tests/soru_atolyesi/kos.mjs
// Sıra: kelime_evreni taklitleri → ek taklitler → migration → test.sql.
// PGlite, kelime_evreni klasöründeki kurulu bağımlılıktan yüklenir.
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { pathToFileURL, fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(path.join(here, '..', 'kelime_evreni', 'package.json'));
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite')).href);

const adimlar = [
  ['kelime taklitleri', path.join(here, '..', 'kelime_evreni', 'stubs.sql')],
  ['ek taklitler', path.join(here, 'ek-stubs.sql')],
  ['migration 20261047000000', path.join(here, '..', '..', 'migrations', '20261047000000_soru_paketi_ice_aktarma.sql')],
  ['testler', path.join(here, 'test.sql')],
];

const db = new PGlite();
for (const [ad, dosya] of adimlar) {
  try {
    await db.exec(fs.readFileSync(dosya, 'utf8'));
    console.log(`tamam: ${ad}`);
  } catch (e) {
    console.log(`HATA [${ad}]: ${e.message}`);
    if (e.position) console.log(`  konum: ${e.position}`);
    process.exit(1);
  }
}
console.log('SONUÇ: Soru Atölyesi içe aktarma testleri geçti.');
