// Matematik 2 ve 3. sınıf şablonlarının ortak yardımcıları (KAYIT içermez; şablon olarak yüklenmez).
export const MUF2 = '2026 Maarif Modeli İlkokul Matematik DÖP (1-4), 2. sınıf bölümü';
export const MUF3 = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 3. sınıf; program: TYMM)';
export const ADLAR = ['Ayşe', 'Efe', 'Elif', 'Mert', 'Zeynep', 'Ali', 'Defne', 'Kaan', 'Deniz', 'Can', 'Sude', 'Arda'];
export const HARFLER = ['A', 'B', 'C', 'D'];
// c değeri kp. konumda olan, `adim` aralıklı dört ardışık değer; sınır dışıysa deneme atılır.
export const pencere = (c, kp, adim, min = 0, max = Infinity) => {
  const a = [0, 1, 2, 3].map((i) => c + (i - kp) * adim);
  if (a.some((v) => v < min || v > max)) throw new Error('pencere_disi');
  return a;
};
export const wrap12 = (x) => ((((x - 1) % 12) + 12) % 12) + 1;
export const saatYaz = (h, m) => `${h}:${String(m).padStart(2, '0')}`;
// Eş olmayan oranlar: toplam 1, en büyük/en küçük ≥ 1.7, hiçbiri 0,08'den küçük değil (kaç kez denerse denesin R ile deterministik).
export function esitDegilOran(R, n) {
  for (let g = 0; g < 300; g++) {
    const w = Array.from({ length: n }, () => 0.4 + R() * 1.4), t = w.reduce((a, b) => a + b, 0);
    const o = w.map((x) => Math.round((x / t) * 100) / 100); o[n - 1] = Math.round((1 - o.slice(0, -1).reduce((a, b) => a + b, 0)) * 100) / 100;
    if (Math.min(...o) >= 0.08 && Math.max(...o) / Math.min(...o) >= 1.7) return o;
  }
  throw new Error('oran_uretilemedi');
}
