// Kelime Evreni veri tabanı yapısal doğrulaması.
// Çalıştırma: node docs/kelime-evreni/veritabani/dogrula.mjs
// Dil kontrolü (anlam, örnek cümle, hatırlatıcı) bu script'in kapsamında değildir; o iş ayrı bir gözden geçirmedir.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const klasor = dirname(fileURLToPath(import.meta.url));
const oku = (dosya) => JSON.parse(readFileSync(join(klasor, dosya), "utf8"));

const TURLER = ["es_anlamli", "zit_anlamli", "es_sesli"];
const SOZCUK_TURLERI = ["isim", "sifat", "fiil", "zarf", "baglac", "diger"];
const KAPSAMLAR = ["program", "hazirlik"];

const hatalar = [];
const uyarilar = [];
const hata = (yer, mesaj) => hatalar.push(`${yer}: ${mesaj}`);
const uyari = (yer, mesaj) => uyarilar.push(`${yer}: ${mesaj}`);
const kucuk = (metin) => metin.toLocaleLowerCase("tr-TR");

const mufredat = oku("mufredat.json");
const sinifDosyalari = [1, 2, 3, 4, 5, 6, 7, 8].map((s) => ({ sinif: s, veri: oku(`sinif-${s}.json`) }));

// Kazanım sözlüğündeki gerçek kayıtlar (meta alanları hariç)
const kazanimAnahtarlari = Object.keys(mufredat).filter((k) => !k.startsWith("_"));
for (const anahtar of kazanimAnahtarlari) {
  const k = mufredat[anahtar];
  if (!k.metin || !k.sinif || !k.kaynak) hata(`mufredat.json ${anahtar}`, "metin, sinif veya kaynak eksik");
}

// Tür ile kazanım metni arasında beklenen anahtar sözcük
const TUR_ANAHTARI = {
  es_anlamli: /eş (ve yakın )?anlamlı/i,
  zit_anlamli: /zıt anlamlı/i,
  es_sesli: /eş sesli/i,
};

const gorulenIdler = new Set();
const senseSozlugu = new Map(); // "kelime|anlam" -> sozcuk_turu
const iliskiAnahtarlari = new Map(); // tür + sıralı çift -> id
const sinifSayilari = {};
const kelimeler = new Set();

for (const { sinif, veri } of sinifDosyalari) {
  const yer = `sinif-${sinif}.json`;
  if (veri.sinif !== sinif) hata(yer, `sinif alanı ${veri.sinif}, dosya adı ${sinif}`);
  if (!KAPSAMLAR.includes(veri.kapsam)) hata(yer, `kapsam geçersiz: ${veri.kapsam}`);
  if (!veri.not) uyari(yer, "not alanı boş");
  if (!Array.isArray(veri.iliskiler) || veri.iliskiler.length === 0) {
    hata(yer, "iliskiler boş ya da dizi değil");
    continue;
  }
  sinifSayilari[sinif] = { toplam: 0 };
  TURLER.forEach((t) => (sinifSayilari[sinif][t] = 0));

  veri.iliskiler.forEach((r, i) => {
    const kimlik = `${yer} #${i + 1} (${r.id ?? "id yok"})`;
    sinifSayilari[sinif].toplam += 1;

    if (!r.id || !r.id.startsWith(`s${sinif}-`)) hata(kimlik, "id, sınıf önekiyle başlamıyor");
    if (gorulenIdler.has(r.id)) hata(kimlik, "id tekrar ediyor");
    gorulenIdler.add(r.id);

    if (!TURLER.includes(r.tur)) hata(kimlik, `tür geçersiz: ${r.tur}`);
    else sinifSayilari[sinif][r.tur] += 1;

    for (const taraf of ["a", "b"]) {
      const s = r[taraf];
      if (!s) {
        hata(kimlik, `${taraf} alanı yok`);
        continue;
      }
      if (!s.kelime || s.kelime !== s.kelime.trim()) hata(kimlik, `${taraf}.kelime boş ya da boşluklu`);
      if (!s.anlam || s.anlam.length < 2 || s.anlam.length > 300) hata(kimlik, `${taraf}.anlam uzunluğu sınır dışı`);
      if (s.anlam && s.anlam !== s.anlam.trim()) hata(kimlik, `${taraf}.anlam başta/sonda boşluk içeriyor`);
      if (!SOZCUK_TURLERI.includes(s.sozcuk_turu)) hata(kimlik, `${taraf}.sozcuk_turu geçersiz: ${s.sozcuk_turu}`);
      if (s.kelime) kelimeler.add(kucuk(s.kelime));

      // Aynı (kelime, anlam) çifti farklı dosyalarda çelişen sözcük türüyle geçemez
      const anahtar = `${s.kelime}|${s.anlam}`;
      if (senseSozlugu.has(anahtar) && senseSozlugu.get(anahtar) !== s.sozcuk_turu) {
        hata(kimlik, `"${s.kelime}" anlamı başka yerde farklı sözcük türüyle tanımlı`);
      }
      senseSozlugu.set(anahtar, s.sozcuk_turu);
    }

    // Tür ile kelime çifti tutarlılığı
    if (r.a && r.b) {
      if (r.tur === "es_sesli") {
        if (r.a.kelime !== r.b.kelime) hata(kimlik, "eş sesli ilişkide iki kelime aynı yazılmalı");
        if (r.a.anlam === r.b.anlam) hata(kimlik, "eş sesli ilişkide anlamlar aynı");
      } else if (r.a.kelime === r.b.kelime) {
        hata(kimlik, "eş anlamlı / zıt anlamlı ilişkide iki kelime aynı");
      }
      if (r.a.anlam === r.b.anlam && r.a.kelime === r.b.kelime) hata(kimlik, "aynı sense iki kez");

      // Çift yönlü tekrar kontrolü
      const sirali = [`${r.a.kelime}|${r.a.anlam}`, `${r.b.kelime}|${r.b.anlam}`].sort().join("##");
      const iliskiAnahtari = `${r.tur}##${sirali}`;
      if (iliskiAnahtarlari.has(iliskiAnahtari)) {
        const onceki = iliskiAnahtarlari.get(iliskiAnahtari);
        uyari(kimlik, `aynı ilişki daha önce ${onceki} kimliğiyle tanımlı`);
      } else {
        iliskiAnahtarlari.set(iliskiAnahtari, r.id);
      }
    }

    if (!r.ornek || r.ornek.trim().length < 5) hata(kimlik, "örnek cümle eksik");
    else if (r.a && r.b) {
      // Fiiller çekimli geçebilir (anlattı, kazandık); ünlü düşmesi ve ünsüz değişimi için (kanat → kanadı, ağız → ağzım)
      // kökün son iki harfi atılır. Bu bir ön kontroldür; asıl dil denetimi ayrı gözden geçirmededir.
      const kok = (s) => {
        const temel = s.sozcuk_turu === "fiil" ? kucuk(s.kelime).replace(/\s*(mak|mek)$/, "") : kucuk(s.kelime);
        return temel.length >= 4 ? temel.slice(0, temel.length - 2) : temel;
      };
      const metin = kucuk(r.ornek);
      if (!metin.includes(kok(r.a)) && !metin.includes(kok(r.b))) {
        hata(kimlik, "örnek cümle hedef kelimelerden hiçbirini (kök eşleşmesiyle) içermiyor");
      }
    }
    if (!r.hatirlatici || r.hatirlatici.trim().length < 5) hata(kimlik, "hatırlatıcı eksik");
    if (!r.teknik) hata(kimlik, "teknik alanı eksik");

    // Kazanım eşleşmesi
    if (veri.kapsam === "hazirlik") {
      if (r.kazanim !== null) hata(kimlik, "hazırlık kaydında kazanim null olmalı");
    } else {
      if (!r.kazanim) {
        hata(kimlik, "program kaydında kazanim boş");
      } else {
        const k = mufredat[r.kazanim];
        if (!k) hata(kimlik, `kazanim sözlükte yok: ${r.kazanim}`);
        else {
          if (k.sinif !== sinif) hata(kimlik, `kazanim ${r.kazanim} ${k.sinif}. sınıfa ait, kayıt ${sinif}. sınıf`);
          if (r.tur && TUR_ANAHTARI[r.tur] && !TUR_ANAHTARI[r.tur].test(k.metin)) {
            hata(kimlik, `kazanim metni "${r.tur}" türünü karşılamıyor: ${r.kazanim}`);
          }
        }
      }
      for (const ek of r.kazanim_ek ?? []) {
        const k = mufredat[ek];
        if (!k) hata(kimlik, `kazanim_ek sözlükte yok: ${ek}`);
        else if (k.sinif !== sinif) hata(kimlik, `kazanim_ek ${ek} ${k.sinif}. sınıfa ait`);
      }
    }
  });

  if (veri.kapsam === "hazirlik") {
    uyari(yer, "bu sınıf için program kazanımı yok; kayıtlar hazırlık amaçlı");
  }
}

const toplam = Object.values(sinifSayilari).reduce((a, s) => a + s.toplam, 0);
console.log("Kelime Evreni veri tabanı — yapısal doğrulama");
console.log("─".repeat(60));
console.log("Sınıf  İlişki  Eş anlamlı  Zıt anlamlı  Eş sesli  Kapsam");
for (const s of Object.keys(sinifSayilari).sort()) {
  const x = sinifSayilari[s];
  const kapsam = sinifDosyalari[Number(s) - 1].veri.kapsam;
  console.log(
    `${String(s).padEnd(7)}${String(x.toplam).padEnd(8)}${String(x.es_anlamli).padEnd(12)}${String(x.zit_anlamli).padEnd(13)}${String(x.es_sesli).padEnd(10)}${kapsam}`,
  );
}
console.log("─".repeat(60));
console.log(`Toplam ilişki: ${toplam}`);
console.log(`Benzersiz kelime (küçük harf): ${kelimeler.size}`);
console.log(`Benzersiz anlam (kelime+anlam): ${senseSozlugu.size}`);
console.log(`Kazanım sözlüğü kaydı: ${kazanimAnahtarlari.length}`);
console.log("─".repeat(60));

if (uyarilar.length) {
  console.log(`UYARI (${uyarilar.length}):`);
  uyarilar.forEach((u) => console.log(`  - ${u}`));
}
if (hatalar.length) {
  console.log(`HATA (${hatalar.length}):`);
  hatalar.forEach((h) => console.log(`  - ${h}`));
  process.exitCode = 1;
} else {
  console.log("HATA: yok");
}
