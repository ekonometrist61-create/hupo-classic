// Görsel kapısı: her görselli soruyu spec'ten yeniden çizer; saklanan SVG, alt metin, lint ve olgu doğrulamasını denetler.
// Ayrıca ölçek ve cevap sızıntısı kontrolü yapar. CLI: node kapi-gorsel.mjs <sorular.json> (kusur varsa çıkış kodu 1).
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { gorselUret, olguDogrula } from './motor.mjs';

export function gorselKapisi(sorular, { svgKlasor = null } = {}) {
  if (svgKlasor) fs.mkdirSync(svgKlasor, { recursive: true });
  return sorular.filter((q) => q.gorsel_gerekli).map((q) => {
    const sorun = [], uyari = [];
    try {
      const g = gorselUret(q.gorsel_spec, q.sinif);
      if (g.svg !== q.gorsel.svg) sorun.push('saklanan_svg_spec_ile_uyusmuyor');
      if (g.alt !== q.gorsel.alt_metin) sorun.push('alt_metin_uyusmuyor');
      for (const b of g.bulgular) (b.ciddiyet === 'hata' ? sorun : uyari).push(`${b.kural}:${b.mesaj}`);
      sorun.push(...olguDogrula(g.olgular, q.gorsel_dogrulama));
      if (!q.gorsel_dogrulama?.length) sorun.push('gorsel_dogrulama_yok');
      if (q.gorsel.olcekli === false && !/ölçekli çizilmemiştir/i.test(q.soru_metni)) sorun.push('olcekli_degil_ama_kokte_belirtilmemis');
      // Cevap sızıntısı: alt metin doğru şıkkı tek başına öne çıkarıyorsa sorun; birden çok şık birlikte geçiyorsa tarafsızdır.
      const dogruMetin = String(q.siklar[q.dogru_sik]);
      const celdiriciAltta = Object.entries(q.siklar).filter(([h, m]) => h !== q.dogru_sik && String(m).length > 2 && g.alt.includes(String(m))).length;
      if (dogruMetin.length > 2 && g.alt.includes(dogruMetin) && !q.soru_metni.includes(dogruMetin) && celdiriciAltta < 2) sorun.push('alt_metin_cevabi_sizdiriyor');
      if (svgKlasor) fs.writeFileSync(path.join(svgKlasor, `${q.id}.svg`), g.svg);
    } catch (e) {
      sorun.push(`motor_hatasi:${e.message}`);
    }
    return { id: q.id, durum: sorun.length ? 'RED' : 'KONTROL', sorunlar: sorun, uyarilar: uyari };
  });
}

if (import.meta.url === pathToFileURL(path.resolve(process.argv[1] ?? '')).href) {
  const yol = process.argv[2];
  if (!yol) { console.error('Kullanım: node kapi-gorsel.mjs <sorular.json>'); process.exit(2); }
  const rapor = gorselKapisi(JSON.parse(fs.readFileSync(yol, 'utf8')));
  console.log(JSON.stringify(rapor, null, 1));
  const red = rapor.filter((r) => r.durum === 'RED').length;
  console.error(`görselli ${rapor.length}, RED ${red}, KONTROL ${rapor.length - red}`);
  process.exit(red ? 1 : 0);
}
