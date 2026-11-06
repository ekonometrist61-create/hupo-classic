// A2 şablonları için ortak yardımcılar (KAYIT yok; yükleyici bu dosyadan şablon çıkarmaz).
export const MUF = {
  hb1: 'MEB TYMM taslak çerçeve yıllık plan 2026–2027, 1. sınıf Hayat Bilgisi',
  hb2: 'Maarif Modeli Hayat Bilgisi DÖP (1–3. sınıf, tymm 2026-09-02), 2. sınıf bölümü',
  hb3: 'MEB 2026-2027 çerçeve yıllık plan (Hayat Bilgisi 3. sınıf; program: TYMM)',
  tr1: 'MEB TYMM taslak çerçeve yıllık plan 2026–2027, 1. sınıf Türkçe (kullanıcı kararı 2026-10-24: plan kodları resmî sayılır)',
  tr2: '2026 Maarif Modeli İlkokul Türkçe Dersi Öğretim Programı (2. sınıf bölümü)',
  tr3: 'MEB 2026-2027 çerçeve yıllık plan (Türkçe 3. sınıf; program: TYMM)',
};
// Ad -> tamlayan (-in) hâli
export const ADLAR = {
  'Ayşe': 'Ayşe’nin', 'Efe': 'Efe’nin', 'Ece': 'Ece’nin', 'Deniz': 'Deniz’in', 'Mert': 'Mert’in', 'Zeynep': 'Zeynep’in',
  'Can': 'Can’ın', 'Elif': 'Elif’in', 'Ali': 'Ali’nin', 'Defne': 'Defne’nin', 'Eylül': 'Eylül’ün', 'Kerem': 'Kerem’in',
};
export const ADLISTE = Object.keys(ADLAR);
export const GUNLER = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'];
// 4 şıklı dizi: doğru k. indekste, diğerleri verilen sırayla (üreticideki konum rezervi için).
export function sik4(k, dogru, digerler) {
  const a = digerler.slice(0, 3);
  a.splice(k, 0, dogru);
  return a;
}
// sabit sıralı şık dizisinde gerekçeler: doğru yerine yer tutucu.
export function gerekceSabit(k, uretici, siklar) {
  return siklar.map((s, i) => (i === k ? 'Doğru.' : uretici(s, i)));
}
export const rasgeleAlt = (karistir, havuz, haric, n) => karistir(havuz.filter((x) => !haric.includes(x))).slice(0, n);
