// İnsan onayı için kontak sayfası: soru + şekil + şıklar + (işaretli) anahtar + çözüm, tek HTML.
// Kullanım: node kontak.mjs <sorular.json> <cikti.html>
import fs from 'node:fs';

const [, , girdi, cikti] = process.argv;
if (!girdi || !cikti) { console.error('Kullanım: node kontak.mjs <sorular.json> <cikti.html>'); process.exit(2); }
const e = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const sorular = JSON.parse(fs.readFileSync(girdi, 'utf8'));

const kart = (q) => `<article>
<h2>${e(q.id)} <small>${e(q.kazanim_kodu)} · zorluk ${q.zorluk}${q.gorsel?.olcekli === false ? ' · ölçekli değil' : ''}</small></h2>
<div class="gorsel">${q.gorsel?.svg ?? ''}</div>
<p>${e(q.soru_metni)}</p>
<ol type="A">${Object.entries(q.siklar).map(([h, m]) => `<li${h === q.dogru_sik ? ' class="dogru"' : ''}>${e(m)}</li>`).join('')}</ol>
<details><summary>Çözüm ve çeldirici gerekçeleri</summary><p><b>İpucu:</b> ${e(q.ipucu)}</p><ul>${q.cozum_adimlari.map((c) => `<li>${e(c)}</li>`).join('')}</ul>
<ul>${Object.entries(q.celdirici_gerekce).map(([h, g]) => `<li><b>${h}</b> ${e(g)}</li>`).join('')}</ul></details>
</article>`;

fs.writeFileSync(cikti, `<!doctype html><html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Kontak sayfası</title><style>
:root{--bg:#f6f7f9;--kart:#fff;--yazi:#1f2937;--soluk:#6b7280;--ok:#0a7d4f;--cizgi:#e5e7eb}
@media(prefers-color-scheme:dark){:root{--bg:#111827;--kart:#1f2937;--yazi:#f3f4f6;--soluk:#9ca3af;--ok:#34d399;--cizgi:#374151}}
body{margin:0;padding:16px;background:var(--bg);color:var(--yazi);font:16px/1.5 system-ui,sans-serif}
main{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:16px;max-width:1300px;margin:auto}
article{background:var(--kart);border:1px solid var(--cizgi);border-radius:12px;padding:16px}
h2{font-size:1rem;margin:0 0 8px}small{color:var(--soluk);font-weight:400}
.gorsel svg{width:100%;max-width:360px;height:auto;display:block;margin:0 auto 8px;border:1px solid var(--cizgi);border-radius:8px}
ol{padding-left:1.6em}li.dogru{color:var(--ok);font-weight:700}details{font-size:.9rem;color:var(--soluk)}
</style></head><body><h1>Kontak sayfası — ${sorular.length} soru</h1><main>${sorular.map(kart).join('')}</main></body></html>`, 'utf8');
console.error(`${sorular.length} kart yazıldı: ${cikti}`);
