// Soru üretim kapıları: şema, kazanım eşleşmesi, sayısal doğrulama, yapısal ipucu.
// Kullanım: node tools/soru-uretim/kapi.cjs <sorular.json> <kazanim.json>
// Çıktı: her soru için durum (RED | KONTROL) ve sorunların listesi.
const fs = require('fs');

const [, , sorularYolu, kazanimYolu] = process.argv;
if (!sorularYolu || !kazanimYolu) {
  console.error('Kullanım: node kapi.cjs <sorular.json> <kazanim.json>');
  process.exit(2);
}

const sorular = JSON.parse(fs.readFileSync(sorularYolu, 'utf8'));
const kazanimDosya = JSON.parse(fs.readFileSync(kazanimYolu, 'utf8'));
const kazanimlar = kazanimDosya.kazanimlar ?? kazanimDosya.ciktilar;
const kazanimKodlari = new Set(kazanimlar.map((k) => k.kod));

const ZORUNLU = ['id', 'sinif', 'ders', 'kazanim_kodu', 'soru_metni', 'siklar', 'dogru_sik', 'ipucu',
  'cozum_adimlari', 'celdirici_gerekce', 'zorluk', 'soru_tipi', 'gorsel_gerekli', 'kaynak_turu'];

// Yalnızca + - * / ( ) ve rakam/nokta kabul eder; eval kullanmaz.
function guvenliHesap(ifade) {
  if (!/^[0-9+\-*/().\s]+$/.test(ifade)) throw new Error('güvensiz ifade');
  const tokens = ifade.match(/\d+(\.\d+)?|[+\-*/()]/g);
  let i = 0;
  const peek = () => tokens[i];
  const eat = () => tokens[i++];
  function faktor() {
    if (peek() === '-') { eat(); return -faktor(); }
    if (peek() === '(') { eat(); const v = toplam(); eat(); return v; }
    return parseFloat(eat());
  }
  function terim() {
    let v = faktor();
    while (peek() === '*' || peek() === '/') { const op = eat(); const r = faktor(); v = op === '*' ? v * r : v / r; }
    return v;
  }
  function toplam() {
    let v = terim();
    while (peek() === '+' || peek() === '-') { const op = eat(); const r = terim(); v = op === '+' ? v + r : v - r; }
    return v;
  }
  const sonuc = toplam();
  if (i !== tokens.length) throw new Error('ifade tam ayrıştırılamadı');
  return sonuc;
}

function kontrol(q, uyarilar = []) {
  const sorunlar = [];
  for (const alan of ZORUNLU) if (q[alan] === undefined || q[alan] === '') sorunlar.push(`eksik_alan:${alan}`);
  if (sorunlar.length) return sorunlar;

  const harfler = Object.keys(q.siklar);
  if (harfler.join('') !== 'ABCD') sorunlar.push('siklar_A_B_C_D_olmali');
  if (!harfler.includes(q.dogru_sik)) sorunlar.push('dogru_sik_siklarda_yok');
  const normalize = (s) => String(s).trim().toLocaleLowerCase('tr-TR').replace(/\s+/g, ' ');
  if (new Set(Object.values(q.siklar).map(normalize)).size !== harfler.length) sorunlar.push('tekrar_eden_sik');

  if (!kazanimKodlari.has(q.kazanim_kodu)) sorunlar.push(`kazanim_kodu_yok:${q.kazanim_kodu}`);
  if (!Array.isArray(q.cozum_adimlari) || !q.cozum_adimlari.length
      || q.cozum_adimlari[q.cozum_adimlari.length - 1] !== `Doğru cevap ${q.dogru_sik} seçeneğidir.`) {
    sorunlar.push('cozum_son_satiri_yanlis');
  }
  if (![1, 2, 3].includes(q.zorluk)) sorunlar.push('zorluk_1_2_3_degil');
  if (typeof q.gorsel_gerekli !== 'boolean') sorunlar.push('gorsel_gerekli_bool_degil');
  if (q.gorsel_gerekli === true) sorunlar.push('gorselli_soru_pilotta_yasak');

  // Sayısal doğrulama: ifade varsa hesaplanır, doğru şık sayısına eşit olmalı.
  if (q.sayisal_dogrulama) {
    try {
      const v = guvenliHesap(q.sayisal_dogrulama.ifade);
      if (Math.abs(v - Number(q.sayisal_dogrulama.beklenen_sonuc)) > 1e-9) sorunlar.push('sayisal_beklenen_tutmuyor');
      const dogruMetin = q.siklar[q.dogru_sik] ?? '';
      const dogruSayi = Number(String(dogruMetin).replace(/\s/g, '').replace(',', '.'));
      if (!Number.isNaN(dogruSayi) && Math.abs(dogruSayi - v) > 1e-9) sorunlar.push('dogru_sik_hesapla_uyusmuyor');
    } catch (e) {
      sorunlar.push(`sayisal_ifade_hatali:${e.message}`);
    }
  }

  // Yapısal ipucu: doğru şık en uzun şık olamaz; uzunluk ortalama çeldiriciden ±%30 içinde.
  const uzunluk = Object.fromEntries(harfler.map((h) => [h, String(q.siklar[h]).length]));
  const celdirici = harfler.filter((h) => h !== q.dogru_sik);
  const celdiriciOrt = celdirici.reduce((t, h) => t + uzunluk[h], 0) / celdirici.length;
  // Kullanıcı ilkesi (feedback_onay_kurali_uzunluk): soru ve cevap doğruysa uzunluk tek başına red sebebi değildir.
  // Uzunluk bulguları uyarı olarak raporlanır (sorunlar değil), durumu RED'e çevirmez.
  if (uzunluk[q.dogru_sik] > Math.max(...celdirici.map((h) => uzunluk[h]))) uyarilar.push('dogru_sik_en_uzun');
  if (Math.abs(uzunluk[q.dogru_sik] / celdiriciOrt - 1) > 0.3) uyarilar.push('dogru_sik_uzunluk_orani_disi');

  // MEB Bağlam Temelli Çoktan Seçmeli Soru Yazım Kılavuzu 2.5.2–2.5.3: kapsayıcı şık, öznel kök, çift olumsuzluk
  for (const h of harfler) {
    if (/\b(hepsi|hiçbiri|hiçbir ikisi)\b/i.test(String(q.siklar[h])) || /^[A-D]\s+ve\s+[A-D]$/i.test(String(q.siklar[h]).trim())) {
      sorunlar.push(`kapsayici_secenek:${h}`);
    }
  }
  if (/\b(sizce|bence|sence)\b/i.test(q.soru_metni)) sorunlar.push('oznel_kok');
  if (/söylenemez/i.test(q.soru_metni) && /olmadığ/i.test(q.soru_metni)) sorunlar.push('cift_olumsuzluk');

  // Bağlam kökte olmalı (2026-10-25 dersi): öğrenci yalnız soru_metni ve şıkları görür. Dayanakta geçen sayı ve özel adlar
  // kökte ya da şıklarda yoksa soru bağlamsızdır (ör. "Ali'nin geriye kaç bilyesi kaldı?").
  if (q.dayanak && !q.soru_metni.includes(q.dayanak)) {
    const gorunen = normalize(`${q.soru_metni} ${Object.values(q.siklar).join(' ')}`);
    const eksik = [...new Set([...(q.dayanak.match(/\d+/g) ?? []), ...(q.dayanak.match(/(?<!^)(?<![.!?]\s)\b\p{Lu}\p{Ll}{2,}/gu) ?? []).map(normalize)])]
      .filter((t) => !new RegExp(`(^|[^\\p{L}\\d])${t}`, 'u').test(gorunen));
    if (eksik.length >= 2) sorunlar.push(`baglam_kokte_yok:${eksik.slice(0, 4).join(',')}`);
    else uyarilar.push('dayanak_kokte_yok');
  }

  for (const h of celdirici) {
    if (!q.celdirici_gerekce || !q.celdirici_gerekce[h]) sorunlar.push(`celdirici_gerekcesi_yok:${h}`);
  }
  return sorunlar;
}

const rapor = sorular.map((q) => {
  const uyarilar = [];
  const sorunlar = kontrol(q, uyarilar);
  return { id: q.id, durum: sorunlar.length ? 'RED' : 'KONTROL', sorunlar, uyarilar };
});

console.log(JSON.stringify(rapor, null, 1));
const red = rapor.filter((r) => r.durum === 'RED').length;
console.error(`toplam ${rapor.length}, RED ${red}, KONTROL ${rapor.length - red}`);
