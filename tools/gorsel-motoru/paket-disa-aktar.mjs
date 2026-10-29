// Görselli üretim klasöründen içe aktarma paketi (sürüm 2, admin_import_questions_v3) üretir.
// Kullanım: node tools/gorsel-motoru/paket-disa-aktar.mjs <klasor>
// Çıktı: <klasor>/paket.json. Kapı reddi olan sorular dışarıda kalır. Veritabanına hiçbir şey yazmaz;
// içe aktarma admin panelinden (PaketImport) yapılır ve yayın kararı insana aittir.
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

// sorular.json kayıtlarını v3 satırına çevirir. Görsel varsa gorsel ve gorsel_spec eklenir.
function satirDonustur(q) {
  const satir = {
    soru_id: String(q.id).toLowerCase(),
    okul: q.sinif <= 4 ? 'ilkokul' : 'ortaokul',
    sinif: q.sinif,
    ders: q.ders,
    konu: q.konu,
    alt_konu: q.alt_konu ?? null,
    soru_metni: q.soru_metni,
    siklar: q.siklar,
    dogru_sik: q.dogru_sik,
    zorluk: q.zorluk,
    cozum_adimlari: q.cozum_adimlari,
    ipuclari: q.ipucu ? [q.ipucu] : [],
    yanlis_sik_geri_bildirimi: q.celdirici_gerekce ?? null,
    kazanim_kodu: q.kazanim_kodu ?? null,
    kaynak_turu: 'uretilen',
    uretim_yontemi: 'sablon',
    gorsel_gerekli: q.gorsel_gerekli === true,
  };
  if (q.gorsel) {
    satir.gorsel = { svg: q.gorsel.svg, alt_metin: q.gorsel.alt_metin, tip_id: q.gorsel.tip_id };
    satir.gorsel_spec = q.gorsel_spec ?? null;
  }
  return satir;
}

// Kapı reddi olan soruları çıkarır; parti kimliğini kazanım kodundan ve tohumdan türetir.
export function paketeDonustur(sorular, rapor) {
  const reddedilen = new Set([
    ...(rapor.kapi?.kazanim?.red ?? []).map((r) => r.id),
    ...(rapor.kapi?.gorsel?.red ?? []).map((r) => r.id),
  ]);
  const kabul = sorular.filter((q) => !reddedilen.has(q.id));
  const partiId = `gorsel-${String(rapor.kod).toLowerCase().replace(/\./g, '-')}-t${rapor.tohum}`;
  return {
    paket: {
      surum: '2',
      parti: {
        parti_id: partiId,
        aciklama: `${rapor.ders} ${rapor.sinif}. sınıf ${rapor.kod}, görselli üretim (tohum ${rapor.tohum})`,
      },
      kaynaklar: [],
      sorular: kabul.map(satirDonustur),
    },
    dislanan: sorular.length - kabul.length,
  };
}

function main() {
  const klasor = process.argv[2];
  if (!klasor) {
    console.error('Kullanım: node tools/gorsel-motoru/paket-disa-aktar.mjs <klasor>');
    process.exit(2);
  }
  const sorular = JSON.parse(fs.readFileSync(path.join(klasor, 'sorular.json'), 'utf8'));
  const rapor = JSON.parse(fs.readFileSync(path.join(klasor, 'rapor.json'), 'utf8'));
  const { paket, dislanan } = paketeDonustur(sorular, rapor);
  const hedef = path.join(klasor, 'paket.json');
  fs.writeFileSync(hedef, JSON.stringify(paket, null, 1));
  console.log(`paket.json yazıldı: ${paket.sorular.length} soru, ${dislanan} kapı reddi dışarıda, parti ${paket.parti.parti_id}`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  main();
}
