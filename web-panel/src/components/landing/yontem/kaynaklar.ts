// Kanıt paketi §2 (HUPOLINGO_Bilimsel_Kanitlar_Web_Pazarlama_2026.md) kaynak listesi. Sıra ve DOI'ler paketten birebir alındı.
// Bulgu ve sınır metinleri messages/{tr,en}.json içinde yontem.kutuphane.items.<id> altındadır; sayılar oraya birebir yazılır.
// Yazar/dergi adları çevrilmez.

export type Kaynak = {
  id: string;
  atif: string;
  doi: string;
  // Zayıf veya farklı kanıt (küçük örneklem, kontrol grubu yok, farklı ders/platform). Sayfada görünür etiketlenir.
  zayif?: boolean;
};

export const KAYNAKLAR: Kaynak[] = [
  { id: "zeng2024", atif: "Zeng vd. (2024), British Journal of Educational Technology", doi: "10.1111/bjet.13471" },
  { id: "kurnaz2025", atif: "Kurnaz & Koçtürk (2025), Psychology in the Schools", doi: "10.1002/pits.70056" },
  { id: "yao2026", atif: "Yao (2026), British Educational Research Journal", doi: "10.1002/berj.70144" },
  { id: "ruitenburg2026", atif: "Ruitenburg vd. (2026), Educational Psychology Review", doi: "10.1007/s10648-026-10225-5" },
  { id: "palikot2026", atif: "Palikot vd. (2026), Quantitative Marketing and Economics", doi: "10.1007/s11129-026-09311-3" },
  { id: "aulagnon2025", atif: "Aulagnon vd. (2025), Economics of Education Review", doi: "10.1016/j.econedurev.2025.102721" },
  { id: "mawson2025", atif: "Mawson & Kang (2025), Behavioral Sciences", doi: "10.3390/bs15060771" },
  { id: "ratinho2026", atif: "Ratinho vd. (2026), Educational Psychology Review", doi: "10.1007/s10648-025-10108-1" },
  { id: "mohammed2024", atif: "Mohammed, Fatemah & Hassan (2024), Simulation & Gaming", doi: "10.1177/10468781241237389", zayif: true },
  { id: "pan2026", atif: "Pan vd. (2026), Education and Information Technologies", doi: "10.1007/s10639-025-13866-1" },
  { id: "gonzalez2025", atif: "González-Fernández & de la Viña (2025), Language Learning & Technology", doi: "10.64152/10125/73656", zayif: true },
  { id: "romero2024", atif: "Romero-Rodríguez vd. (2024), International Journal of Educational Research", doi: "10.1016/j.ijer.2024.102481" },
];

export function kaynakDoi(id: string): string | undefined {
  return KAYNAKLAR.find((k) => k.id === id)?.doi;
}
