// Tüm görselli üretim testlerini çalıştırır: node tools/gorsel-motoru/testler.mjs
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const BURASI = path.dirname(fileURLToPath(import.meta.url));
const dosyalar = fs.readdirSync(BURASI).filter((f) => f.endsWith('.test.mjs')).sort().map((f) => path.join(BURASI, f));
const r = spawnSync(process.execPath, ['--test', ...dosyalar], { stdio: 'inherit' });
process.exit(r.status ?? 1);
