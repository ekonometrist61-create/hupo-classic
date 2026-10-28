// Kelime Evreni içeriğini Gemini ile denetler: ilişkiler ve taslak sorular.
// Çalıştırma: node docs/kelime-evreni/veritabani/gemini-teyit.mjs
// Anahtar ve model "Soru-Cevap Hazırlama Programı\.env" dosyasından okunur; çıktıya yazılmaz.
// Sonuç: teyit-gemini.json
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const klasor = dirname(fileURLToPath(import.meta.url));
const ENV = "C:/Dev/Soru-Cevap Hazırlama Programı/.env";

const satirlar = readFileSync(ENV, "utf8").split(/\r?\n/);
const oku = (ad) => {
  const satir = satirlar.find((s) => s.startsWith(`${ad}=`));
  return satir ? satir.slice(ad.length + 1).trim().replace(/^["']|["']$/g, "") : null;
};
const ANAHTAR = oku("GEMINI_API_KEY");
const MODEL = oku("GEMINI_MODEL");
if (!ANAHTAR || !MODEL) throw new Error("GEMINI_API_KEY / GEMINI_MODEL okunamadı");
const URL_ = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

async function gemini(istem) {
  for (let deneme = 1; deneme <= 3; deneme++) {
    try {
      const yanit = await fetch(URL_, {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": ANAHTAR },
        body: JSON.stringify({
          contents: [{ parts: [{ text: istem }] }],
          generationConfig: { responseMimeType: "application/json", temperature: 0.1 },
        }),
      });
      if (!yanit.ok) throw new Error(`HTTP ${yanit.status}`);
      const govde = await yanit.json();
      const metin = govde.candidates?.[0]?.content?.parts?.map((p) => p.text ?? "").join("") ?? "";
      return JSON.parse(metin);
    } catch (e) {
      if (deneme === 3) throw e;
      await new Promise((r) => setTimeout(r, 2000 * deneme));
    }
  }
}

const parcala = (dizi, boyut) => {
  const sonuc = [];
  for (let i = 0; i < dizi.length; i += boyut) sonuc.push(dizi.slice(i, i + boyut));
  return sonuc;
};

const ILISKI_ISTEM = `Sen Türkçe dil uzmanısın ve 6–14 yaş çocuk içeriği denetçisisin. İçerik 1–8. sınıf Türkçe söz varlığı oyunu için (eş anlamlı, zıt anlamlı, eş sesli sözcükler). Her kaydı TDK sözlük anlamlarına ve MEB Türkçe programına göre denetle.

Her kayıt: id, tur (es_anlamli | zit_anlamli | es_sesli), a ve b ({kelime, anlam, sozcuk_turu}), ornek (örnek cümle), hatirlatici (çocuk için hafıza ipucu), teknik.

Kontroller:
1. Dil: a.anlam ve b.anlam doğru ve sade mi? tur doğru mu? eş anlamlı çiftler gerçekten anlamdaş mı; zıt anlamlı çiftler gerçekten karşıt mı; eş sesli çiftler yazılışı aynı ama anlamları birbirinden bağımsız iki sözcük mü (aynı sözcüğün ilgili anlamları ise bunu sorun olarak yaz).
2. ornek: dilbilgisi doğru mu, hedef sözcük(ler) doğru anlamda mı kullanılmış?
3. hatirlatici: yanlış bilgi (köken, anlam, doğa bilgisi) ya da çocuğu yanıltacak bir ifade var mı?
4. Çocuk güvenliği: içerik 6–14 yaş için uygun mu (şiddet, cinsellik, küfür, korku, ayrımcılık, kişisel veri yok mu)?

Çıktı: yalnızca bir JSON dizisi. Her kayıt için:
{"id": "...", "durum": "tamam" | "duzelt" | "sorunlu", "guvenli": true | false, "sorunlar": ["..."], "duzeltme": {"alan": "ornek" | "hatirlatici" | "a.anlam" | "b.anlam" | "yok", "yeni": "..."}}
- tamam: sorun yok.
- duzelt: küçük metin düzeltmesi yeterli; duzeltme alanını ve yeni metni yaz.
- sorunlu: tür veya anlam kökten yanlış; duzeltme alanı "yok" olsun ve sorunu açıkla.
Kayıtlar:
`;

const SORU_ISTEM = `Sen Türkçe dil uzmanısın ve 6–14 yaş çocuk içeriği denetçisisin. Aşağıdaki çoktan seçmeli sorular 1–8. sınıf Türkçe söz varlığı (eş anlamlı, zıt anlamlı, eş sesli) için. Her soru: iliski_id, sinif, tur, soru, secenekler (dizi), dogru_indeks (secenekler içinde doğru şıkkın sıfır tabanlı indeksi), aciklama.

Kontroller:
1. dogru_indeks gerçekten doğru cevabı mı gösteriyor?
2. Diğer şıklardan biri de doğru cevap olabilir mi (ör. çeldirici bir eş anlamlı ya da zıt anlamlı ise sorun)?
3. Soru ve şıklar Türkçe doğru mu? Şıklar aynı türden mi?
4. aciklama doğru mu?
5. Çocuk güvenliği: uygun mu?

Çıktı: yalnızca bir JSON dizisi. Her soru için:
{"iliski_id": "...", "durum": "tamam" | "duzelt" | "sorunlu", "guvenli": true | false, "sorunlar": ["..."], "dogru_indeks_onerisi": null | sayı}
Sorular:
`;

const iliskiler = [];
for (let sinif = 1; sinif <= 8; sinif++) {
  const veri = JSON.parse(readFileSync(join(klasor, `sinif-${sinif}.json`), "utf8"));
  for (const r of veri.iliskiler) {
    iliskiler.push({ id: r.id, sinif, tur: r.tur, a: r.a, b: r.b, ornek: r.ornek, hatirlatici: r.hatirlatici, teknik: r.teknik });
  }
}
const sorular = JSON.parse(readFileSync(join(klasor, "sorular-taslak.json"), "utf8"));

console.log(`İlişki: ${iliskiler.length}, soru: ${sorular.length}`);
const ilisSonuc = [];
for (const [i, grup] of parcala(iliskiler, 20).entries()) {
  console.log(`ilişki grubu ${i + 1}/${Math.ceil(iliskiler.length / 20)}`);
  const cevap = await gemini(ILISKI_ISTEM + JSON.stringify(grup, null, 1));
  if (!Array.isArray(cevap)) throw new Error("ilişki yanıtı dizi değil");
  ilisSonuc.push(...cevap);
}
const soruSonuc = [];
for (const [i, grup] of parcala(sorular, 30).entries()) {
  console.log(`soru grubu ${i + 1}/${Math.ceil(sorular.length / 30)}`);
  const cevap = await gemini(SORU_ISTEM + JSON.stringify(grup, null, 1));
  if (!Array.isArray(cevap)) throw new Error("soru yanıtı dizi değil");
  soruSonuc.push(...cevap);
}

const ozet = (dizi) => {
  const sayim = { tamam: 0, duzelt: 0, sorunlu: 0, guvenli_degil: 0 };
  for (const x of dizi) {
    sayim[x.durum] = (sayim[x.durum] ?? 0) + 1;
    if (x.guvenli === false) sayim.guvenli_degil++;
  }
  return sayim;
};

writeFileSync(
  join(klasor, "teyit-gemini.json"),
  JSON.stringify({ model: MODEL, tarih: "2026-10-21", iliskiler: ilisSonuc, sorular: soruSonuc }, null, 2),
  "utf8",
);
console.log("İlişki özeti:", ozet(ilisSonuc));
console.log("Soru özeti:", ozet(soruSonuc));
