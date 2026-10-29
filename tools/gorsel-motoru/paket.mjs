// Üretim çıktı klasörü: sorular, kapı sonuçları, onay sayfası, kör çözüm paketi ve karar raporu.
// Karar yalnız raporlanır. Hiçbir kayıt otomatik yayınlanmaz: durum her zaman "beklemede" kalır (G8).
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { DEPO, SURUM, dengeOzeti, kazanimDosyasi } from './uretici.mjs';
import { gorselKapisi } from './kapi-gorsel.mjs';
import { korKarsilastir } from './kor.mjs';

const BURASI = path.dirname(fileURLToPath(import.meta.url));
const node = process.execPath;

// Metin kapısı (tools/soru-uretim/kapi.cjs): tek bir kazanım kaynak dosyasına karşı şema, kod ve çözüm kuralları.
export function kazanimKapisi(sorular) {
  if (!sorular.length) return { toplam: 0, dosya: null, red: [] };
  const dosyalar = [...new Set(sorular.map((q) => kazanimDosyasi(q.ders, q.sinif)))];
  if (dosyalar.length !== 1 || !dosyalar[0]) throw new Error('tek_kazanim_dosyasi_gerekli');
  const gecici = fs.mkdtempSync(path.join(os.tmpdir(), 'gorsel-kapi-'));
  try {
    const girdi = path.join(gecici, 'sorular.json');
    fs.writeFileSync(girdi, JSON.stringify(sorular));
    const r = spawnSync(node, [path.join(DEPO, 'tools', 'soru-uretim', 'kapi.cjs'), girdi, dosyalar[0]], { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 });
    if (!r.stdout) throw new Error(`kapi.cjs çalışmadı: ${r.stderr || r.error?.message}`);
    const rapor = JSON.parse(r.stdout);
    return {
      toplam: rapor.length,
      dosya: path.basename(dosyalar[0]),
      red: rapor.filter((x) => x.durum === 'RED').map((x) => ({ id: x.id, sorunlar: x.sorunlar })),
    };
  } finally {
    fs.rmSync(gecici, { recursive: true, force: true });
  }
}

// Kör çözüm paketi: anahtarsız girdi dosyaları (görselli: PNG yolu ile; görselsiz: yalnız metin ve şıklar).
// Anahtar (dogru_sik) bu dosyalara yazılmaz.
export function korPaketi(sorular, kor, { png = true } = {}) {
  const svgD = path.join(kor, 'svg'), pngD = path.join(kor, 'png');
  for (const d of [svgD, pngD]) { fs.rmSync(d, { recursive: true, force: true }); fs.mkdirSync(d, { recursive: true }); }
  for (const q of sorular) fs.writeFileSync(path.join(svgD, `${q.id}.svg`), q.gorsel.svg);
  fs.writeFileSync(path.join(kor, 'kor_gorselli.json'), JSON.stringify(sorular.map((q) => ({
    id: q.id, soru_metni: q.soru_metni, siklar: q.siklar, gorsel_png: path.resolve(pngD, `${q.id}.png`),
  })), null, 1));
  fs.writeFileSync(path.join(kor, 'kor_gorselsiz.json'), JSON.stringify(sorular.map((q) => ({
    id: q.id, soru_metni: q.soru_metni, siklar: q.siklar,
  })), null, 1));
  if (!png) return { tamam: false, pngSayi: 0, hata: 'PNG adımı atlandı (--png-yok)' };
  const py = spawnSync('python', ['-I', path.join(BURASI, 'svg2png.py'), svgD, pngD], { encoding: 'utf8' });
  const pngSayi = fs.readdirSync(pngD).filter((x) => x.endsWith('.png')).length;
  const tamam = py.status === 0 && pngSayi === sorular.length;
  return { tamam, pngSayi, hata: tamam ? null : (py.stderr || py.error?.message || 'python/pymupdf çalışmadı').trim().slice(0, 300) };
}

// Karar: kapı reddi > eksik üretim > kör çözüm bekleniyor > kör çözüm sonucu.
export function kararVer(r) {
  if (r.kapi.kazanim.red.length || r.kapi.gorsel.red.length) return 'KAPI_RED';
  if (r.uretim.eksik > 0) return 'EKSIK_URETIM';
  if (!r.kor) return 'KOR_BEKLIYOR';
  return r.kor.karar;
}

const CIKIS = { KAPI_RED: 1, KOR_GECMEDI: 1, EKSIK_URETIM: 3, KOR_BEKLIYOR: 0, KOR_GECTI: 0, ON_GECTI: 0, ON_GECMEDI: 0 };
export const cikisKodu = (karar) => CIKIS[karar] ?? 2;
export function enKotuCikis(kodlar) {
  if (kodlar.includes(1)) return 1;
  if (kodlar.includes(2)) return 2;
  return kodlar.includes(3) ? 3 : 0;
}

// Bir üretim sonucunu çıktı klasörüne yazar ve rapor döndürür.
// meta: { istatistik, ders, sinif, kod }
export function yazPaket(sorular, meta, klasor, { png = true } = {}) {
  const kor = path.join(klasor, 'kor');
  fs.mkdirSync(kor, { recursive: true });
  fs.writeFileSync(path.join(klasor, 'sorular.json'), JSON.stringify(sorular, null, 1));
  const kazanim = kazanimKapisi(sorular);
  const gorsel = gorselKapisi(sorular);
  const korPng = korPaketi(sorular, kor, { png });
  const kontak = spawnSync(node, [path.join(BURASI, 'kontak.mjs'), path.join(klasor, 'sorular.json'), path.join(klasor, 'kontak.html')], { encoding: 'utf8' });
  const ist = meta.istatistik;
  const rapor = {
    surum: SURUM, ders: meta.ders ?? null, sinif: meta.sinif ?? null, kod: meta.kod ?? null,
    tohum: ist.tohum,
    uretim: { istenen: ist.istenen, uretilen: ist.uretilen, eksik: ist.eksik, denenen: ist.denenen, atilan: ist.atilan, sablonlar: ist.sablonlar },
    denge: dengeOzeti(sorular),
    kapi: {
      kazanim: kazanim,
      gorsel: { toplam: gorsel.length, red: gorsel.filter((r) => r.durum === 'RED').map((r) => ({ id: r.id, sorunlar: r.sorunlar })) },
    },
    kor_png: korPng,
    kontak: kontak.status === 0,
    kor: null,
    durum: 'beklemede',
    karar: null,
  };
  rapor.karar = kararVer(rapor);
  fs.writeFileSync(path.join(klasor, 'rapor.json'), JSON.stringify(rapor, null, 1));
  return rapor;
}

// Kör çözüm cevaplarını (kor/gorselli_cevap*.json, kor/gorselsiz_cevap.json) uygular, raporu günceller.
export function korSonucuUygula(klasor) {
  const kor = path.join(klasor, 'kor');
  const sorular = JSON.parse(fs.readFileSync(path.join(klasor, 'sorular.json'), 'utf8'));
  const rapor = JSON.parse(fs.readFileSync(path.join(klasor, 'rapor.json'), 'utf8'));
  const gDosyalar = fs.existsSync(kor) ? fs.readdirSync(kor).filter((f) => /^gorselli_cevap.*\.json$/.test(f)).sort() : [];
  const zYol = path.join(kor, 'gorselsiz_cevap.json');
  if (!gDosyalar.length || !fs.existsSync(zYol)) throw new Error('kör cevap dosyaları eksik: kor/gorselli_cevap*.json ve kor/gorselsiz_cevap.json');
  const gorselli = gDosyalar.flatMap((f) => JSON.parse(fs.readFileSync(path.join(kor, f), 'utf8')));
  const gorselsiz = JSON.parse(fs.readFileSync(zYol, 'utf8'));
  rapor.kor = { ...korKarsilastir(sorular, gorselli, gorselsiz), cevap_dosyalari: [...gDosyalar, 'gorselsiz_cevap.json'] };
  rapor.karar = kararVer(rapor);
  fs.writeFileSync(path.join(klasor, 'rapor.json'), JSON.stringify(rapor, null, 1));
  return rapor;
}
