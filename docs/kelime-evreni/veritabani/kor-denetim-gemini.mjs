// Kör denetim (Gemini): soruyu anahtarsız çözer ve kalite bayrakları ister. Sonuç: denetim-gemini-<dosya>.json
// Kullanım: node kor-denetim-gemini.mjs pilot-deyim-atasozu.json
// Anahtar/model "Soru-Cevap Hazırlama Programı\.env" dosyasından okunur; çıktıya yazılmaz.
import { readFileSync, writeFileSync } from "node:fs";
const dosya = process.argv[2];
const satirlar = readFileSync("C:/Dev/Soru-Cevap Hazırlama Programı/.env", "utf8").split(/\r?\n/);
const oku = (ad) => { const s = satirlar.find((x) => x.startsWith(`${ad}=`)); return s ? s.slice(ad.length + 1).trim().replace(/^["']|["']$/g, "") : null; };
const ANAHTAR = oku("GEMINI_API_KEY"), MODEL = oku("GEMINI_MODEL");
if (!ANAHTAR || !MODEL) throw new Error("GEMINI_API_KEY / GEMINI_MODEL okunamadı");
const sorular = JSON.parse(readFileSync(dosya, "utf8"));
const liste = sorular.map((x, i) => ({ no: i + 1, sinif: x.s, soru: x.q, secenekler: x.o }));
const istem = `Sen bir Türkçe öğretmeni ve soru denetçisisin. Aşağıdaki çoktan seçmeli soruları KÖR çöz (cevap anahtarı sende yok).
Her soru için JSON dizisi döndür: [{"no":1,"cevap":0,"tek_dogru":true,"sinif_uygun":true,"sorun":""}]
- cevap: seçtiğin şıkkın 0 tabanlı indeksi.
- tek_dogru: yalnız tek şık doğruysa true; ikinci bir kabul edilebilir şık varsa false.
- sinif_uygun: sınıf düzeyine uygunsa true.
- sorun: sözlük/TDK anlamına aykırılık, yanlış deyim/atasözü biçimi, ipucu sızması, şık dengesizliği varsa kısaca yaz; yoksa boş.
Sorular:\n${JSON.stringify(liste)}`;
const yanit = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`, {
  method: "POST", headers: { "Content-Type": "application/json", "x-goog-api-key": ANAHTAR },
  body: JSON.stringify({ contents: [{ parts: [{ text: istem }] }], generationConfig: { responseMimeType: "application/json", temperature: 0.1 } }),
});
if (!yanit.ok) throw new Error(`Gemini ${yanit.status}`);
const metin = (await yanit.json()).candidates?.[0]?.content?.parts?.[0]?.text ?? "[]";
const sonuc = JSON.parse(metin);
writeFileSync(`denetim-gemini-${dosya}`, JSON.stringify({ model: MODEL, sonuc }, null, 1), "utf8");
let uyusan = 0;
for (const r of sonuc) { const x = sorular[r.no - 1]; const ok = r.cevap === x.d && r.tek_dogru && r.sinif_uygun && !r.sorun; if (ok) uyusan++; else console.log(r.no, x.k, JSON.stringify(r)); }
console.log(`Gemini (${MODEL}): ${uyusan}/${sorular.length} temiz`);
