// Görselli soru üretim programı (komut satırı). Ayrıntı: tools/gorsel-motoru/README.md
//   --liste                              şablonları ve kayıt sözleşmesi sorunlarını göster
//   --dogrula                            kayıt sözleşmesini denetle (sorun varsa çıkış 2)
//   --ders <ad> --sinif <n> [--kod K]    tek seçim üret → --klasor
//   --hepsi                              her (ders, sınıf, kazanım kodu) grubunu üret → --klasor/<grup>/ ve ozet.json
//   --kor-sonuc <klasor>                 kör çözüm cevaplarını uygula, kararı rapora yaz
// Ortak: --adet (varsayılan 20, 1–200), --tohum (varsayılan 1), --klasor, --png-yok
// Çıkış kodu: 0 tamam/uyarı · 1 kapı reddi veya kör çözüm başarısız · 2 kullanım/kayıt hatası · 3 eksik üretim
import fs from 'node:fs';
import path from 'node:path';
import { kayitlariYukle, kayitlariDogrula, secKayitlar, grupla, uretKayitlar, ascii } from './uretici.mjs';
import { yazPaket, korSonucuUygula, cikisKodu, enKotuCikis } from './paket.mjs';

const YARDIM = `Kullanım:
  node tools/gorsel-motoru/uret.mjs --liste
  node tools/gorsel-motoru/uret.mjs --dogrula
  node tools/gorsel-motoru/uret.mjs --ders matematik --sinif 5 [--kod MAT.5.5.1] --adet 20 --tohum 1 --klasor <dizin>
  node tools/gorsel-motoru/uret.mjs --hepsi --adet 20 --tohum 1 --klasor <dizin>
  node tools/gorsel-motoru/uret.mjs --kor-sonuc <klasor>
Çıkış kodları: 0 tamam · 1 kapı reddi / kör çözüm başarısız · 2 kullanım veya kayıt hatası · 3 eksik üretim`;

const hata = (mesaj, kod = 2) => { console.error(mesaj); process.exit(kod); };

const argv = process.argv.slice(2);
const a = {};
for (let i = 0; i < argv.length; i++) {
  const ad = argv[i];
  if (!ad.startsWith('--')) hata(`beklenmeyen argüman: ${ad}\n${YARDIM}`);
  const sonraki = argv[i + 1];
  if (sonraki === undefined || sonraki.startsWith('--')) a[ad.slice(2)] = true;
  else { a[ad.slice(2)] = sonraki; i++; }
}
if (!argv.length || a.yardim) { console.log(YARDIM); process.exit(0); }

function sayi(ad, varsayilan, min, max) {
  if (a[ad] === undefined) return varsayilan;
  const v = typeof a[ad] === 'string' ? Number(a[ad]) : NaN;
  if (!Number.isInteger(v) || v < min || v > max) hata(`--${ad} ${min}–${max} arasında tam sayı olmalı`);
  return v;
}
const adet = sayi('adet', 20, 1, 200);
const tohum = sayi('tohum', 1, 0, 2147483647);

const tum = await kayitlariYukle();
const kayitSorun = kayitlariDogrula(tum);

if (a.liste || a.dogrula) {
  if (a.liste) for (const k of tum) console.log(`${k.id.padEnd(22)} ${k.ders.padEnd(17)} ${k.sinif}. sınıf  ${k.kodlar.join(',').padEnd(12)} ${k.dosya}`);
  if (kayitSorun.length) hata(`KAYIT SORUNLARI (${kayitSorun.length}):\n  ${kayitSorun.join('\n  ')}`);
  console.log(`kayıt sözleşmesi tamam (${tum.length} şablon)`);
  process.exit(0);
}
if (kayitSorun.length) hata(`kayıt sözleşmesi bozuk, üretim durduruldu:\n  ${kayitSorun.join('\n  ')}`);

if (typeof a['kor-sonuc'] === 'string') {
  const r = korSonucuUygula(a['kor-sonuc']);
  console.log(`karar: ${r.karar}  (görselli %${Math.round(r.kor.gorselli.oran * 100)}, görselsiz %${Math.round(r.kor.gorselsiz.oran * 100)}, n=${r.kor.n})`);
  if (!r.kor.n_yeterli) console.log(`uyarı: n=${r.kor.n} < ${r.kor.esik.n_min}; bu sonuç ön bilgidir, karar için örneği büyütün.`);
  process.exit(cikisKodu(r.karar));
}

if (typeof a.klasor !== 'string') hata(`--klasor <dizin> gerekli\n${YARDIM}`);
const png = !a['png-yok'];

if (a.hepsi) {
  const ozet = [];
  for (const g of grupla(tum)) {
    const klasor = path.join(a.klasor, `${g.sinif}-${ascii(g.ders)}-${g.kod.replace(/\./g, '_')}`);
    const { sorular, istatistik } = uretKayitlar(g.kayitlar, { adet, tohum });
    const r = yazPaket(sorular, { istatistik, ders: g.ders, sinif: g.sinif, kod: g.kod }, klasor, { png });
    console.log(`${path.basename(klasor).padEnd(30)} üretilen ${String(r.uretim.uretilen).padStart(2)}/${adet}  karar ${r.karar}`);
    ozet.push({ klasor: path.basename(klasor), ders: g.ders, sinif: g.sinif, kod: g.kod, istenen: adet, uretilen: r.uretim.uretilen, karar: r.karar });
  }
  fs.mkdirSync(a.klasor, { recursive: true });
  fs.writeFileSync(path.join(a.klasor, 'ozet.json'), JSON.stringify(ozet, null, 1));
  process.exit(enKotuCikis(ozet.map((o) => cikisKodu(o.karar))));
}

const secilen = secKayitlar(tum, { ders: a.ders, sinif: a.sinif, kod: a.kod });
if (!secilen.length) hata(`şablon yok: ders=${a.ders ?? '*'} sinif=${a.sinif ?? '*'} kod=${a.kod ?? '*'} (bkz. --liste)`);
const dersSinif = new Set(secilen.map((k) => `${ascii(k.ders)}|${k.sinif}`));
if (dersSinif.size > 1) hata('seçim birden çok ders/sınıf içeriyor; --ders ve --sinif ile tek seçim yapın ya da --hepsi kullanın');

const { sorular, istatistik } = uretKayitlar(secilen, { adet, tohum });
const ilk = secilen[0];
const kodlar = [...new Set(secilen.flatMap((k) => k.kodlar))].join(',');
const r = yazPaket(sorular, { istatistik, ders: ilk.ders, sinif: ilk.sinif, kod: kodlar }, a.klasor, { png });
console.log(`üretilen ${r.uretim.uretilen}/${adet} (eksik ${r.uretim.eksik}) · kapı: kazanım RED ${r.kapi.kazanim.red.length}, görsel RED ${r.kapi.gorsel.red.length} · denge ${JSON.stringify(r.denge.harf)}`);
for (const x of [...r.kapi.kazanim.red, ...r.kapi.gorsel.red].slice(0, 5)) console.log(`  RED ${x.id}: ${x.sorunlar.join('; ')}`);
console.log(`karar: ${r.karar}   çıktı: ${a.klasor}`);
process.exit(cikisKodu(r.karar));
