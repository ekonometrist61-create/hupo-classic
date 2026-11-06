// 4. sınıf Sosyal Bilgiler — aile ağacından kişiler arasındaki yakınlığı okuma (SB.4.3.2, aile tarihine ilişkin kanıtlara dayalı çıkarım).
// Aile ağacındaki isimler kurgusaldır. Doğru cevap ağacın parametrelerinden kodla hesaplanır.
import { ilgi } from './sosyal6-ortak.mjs';

const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
// Adlar cinsiyetsiz (kurgusal) havuzdan seçilir: yakınlık yalnız ağaçtaki bağlantılardan okunur.
const AD = ['Deniz', 'Ege', 'Derin', 'Ada', 'Umut', 'Evren', 'Doğa', 'Yağmur', 'Ayaz', 'Su', 'Işık', 'Gün', 'Toprak', 'Yıldız', 'Bilge', 'Barış', 'Rüzgar', 'Kıvanç'];
// Ağaçta cinsiyet gösterilmez: yalnız çizgilerle belirlenen cinsiyetsiz terimler sorulur.
const TERIM = ['ebeveyni', 'kardeşi', 'ebeveyninin kardeşi', 'ebeveyninin ebeveyni'];
const NOTR = (g) => (g === 'babası' || g === 'annesi' ? 'ebeveyni' : g === 'kardeşi' ? 'kardeşi' : /^(amcası|halası|dayısı|teyzesi)$/.test(g) ? 'ebeveyninin kardeşi' : 'ebeveyninin ebeveyni');

export function kur({ R, karistir, sec, ekle }) {
  function aileSorusu() {
    const e = karistir(AD), k = e, dd = e.splice(0, 2), nn = e.splice(0, 2), ck = e.splice(0, 3);
    const baba = e.pop(), anne = e.pop();
    const babaSib = Array.from({ length: 1 + Math.floor(R() * 2) }, () => (R() < 0.5 ? { rol: 'amca', ad: e.pop() } : { rol: 'hala', ad: k.pop() }));
    const anneSib = Array.from({ length: 1 + Math.floor(R() * 2) }, () => (R() < 0.5 ? { rol: 'dayi', ad: e.pop() } : { rol: 'teyze', ad: k.pop() }));
    const cocuklar = ck.slice(0, 1 + Math.floor(R() * 3));
    const p = { babaTarafi: { dede: dd[0], nine: nn[0] }, anneTarafi: { dede: dd[1], nine: nn[1] }, babaSib, baba, anne, anneSib, cocuklar };
    const spec = { tip_id: 'a6-aile-agaci', parametreler: p };
    const c = sec(cocuklar);
    // c çocuğunun gözünden herkesin yakınlığı (doğrulayıcı tipin cinsiyetli terimleri; metinde cinsiyetsiz karşılığı kullanılır)
    const iliski = new Map([[baba, 'babası'], [anne, 'annesi'], [p.babaTarafi.dede, 'baba tarafındaki dedesi'], [p.babaTarafi.nine, 'babaannesi'], [p.anneTarafi.dede, 'anne tarafındaki dedesi'], [p.anneTarafi.nine, 'anneannesi']]);
    for (const s of babaSib) iliski.set(s.ad, s.rol === 'amca' ? 'amcası' : 'halası');
    for (const s of anneSib) iliski.set(s.ad, s.rol === 'dayi' ? 'dayısı' : 'teyzesi');
    for (const x of cocuklar) if (x !== c) iliski.set(x, 'kardeşi');
    const ortak = { kod: 'SB.4.3.2', konu: 'Aile Tarihi', alt_konu: 'Aile ağacından yakınlık çıkarımı', spec };
    const kisiler = [...iliski.keys()];
    const nt = (x) => NOTR(iliski.get(x));
    const terimKume = (t) => kisiler.filter((x) => nt(x) === t);

    if (R() < 0.5) {
      // "X kişisi c'nin nesi olur?" (yalnız cinsiyetsiz terimler)
      const kisi = sec(kisiler.filter((x) => x !== c)), dogru = nt(kisi);
      const cel = karistir(TERIM.filter((t) => t !== dogru));
      return ekle({ ...ortak, zorluk: 2, dogru, celdirici: cel,
        gerekce: cel.map((t) => `Ağaçtaki çizgilere göre ${c} kutusundan ${kisi} kutusuna giden yol ${t} ilişkisine uymaz.`),
        kok: `Yukarıdaki aile ağacına göre ${kisi} adlı kişi, ${c} adlı çocuğun nesi olur?`,
        ipucu: `Önce ${c} adlı çocuğun kutusundan çizgilerle yukarı çık. Sonra ${kisi} adlı kutuya hangi çizgilerle ulaştığına bak.`,
        cozum: [`${c} çocuğunun ağaçtaki yeri bulunur.`, `Çizgiler izlenerek ${kisi} kutusuna ulaşan yol, yakınlık terimiyle eşleştirilir.`],
        dogrulama: [{ yol: ['iliski', `${c}|${kisi}`], beklenen: iliski.get(kisi) }] });
    }
    // "c'nin T olan kişilerden hangisi?" — çizgilerle belirlenen cinsiyetsiz terim
    const t = sec(TERIM.filter((x) => terimKume(x).length > 0)), dogru = sec(terimKume(t));
    const cel = karistir(kisiler.filter((x) => nt(x) !== t && x !== c)).slice(0, 3);
    return ekle({ ...ortak, zorluk: 2, dogru, celdirici: cel,
      gerekce: cel.map((x) => `Ağaçtaki çizgilere göre ${c} kutusundan ${x} kutusuna giden yol ${t} ilişkisine uymaz.`),
      kok: `Yukarıdaki aile ağacına göre aşağıdakilerden hangisi ${ilgi(c)} ${t} olan kişidir?`,
      ipucu: `${c} adlı çocuğun kutusundan başla; çizgileri izleyerek ${t} olan kutuyu bul.`,
      cozum: [`${c} çocuğunun ağaçtaki yeri bulunur.`, `Çizgiler izlenerek ${t} ilişkisine uyan kutu bulunur.`],
      dogrulama: [{ yol: ['iliski', `${c}|${dogru}`], beklenen: iliski.get(dogru) }] });
  }
  return { aileSorusu };
}

export const KAYIT = [
  { id: 'sb4-aile-agaci', ders: 'Sosyal Bilgiler', sinif: 4, idOnek: 'SB4-AIL', mufredat_surum: MUFREDAT, kodlar: ['SB.4.3.2'], fabrika: kur, uret: (f) => f.aileSorusu() },
];
