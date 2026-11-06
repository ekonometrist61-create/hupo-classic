// 4. sınıf Sosyal Bilgiler — aile ağacından kişiler arasındaki yakınlığı okuma (SB.4.3.2, aile tarihine ilişkin kanıtlara dayalı çıkarım).
// Aile ağacındaki isimler kurgusaldır. Doğru cevap ağacın parametrelerinden kodla hesaplanır.
import { ilgi } from './sosyal6-ortak.mjs';

const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const ERKEK = ['Cem', 'Kaan', 'Tuna', 'Arda', 'Mert', 'Can', 'Eren', 'Umut'];
const KADIN = ['Seda', 'Mina', 'Naz', 'Ela', 'Eda', 'Ece', 'Asya', 'Defne'];
const DEDE = ['Ali', 'Veli', 'Hasan', 'Ahmet', 'Salih', 'Orhan'];
const NINE = ['Ayşe', 'Emine', 'Fatma', 'Hacer', 'Gül', 'Sema'];
const COCUK = ['Efe', 'Deniz', 'Kerem', 'Yaren', 'Derin', 'Ada'];
const TERIM = ['babası', 'annesi', 'amcası', 'halası', 'dayısı', 'teyzesi', 'babaannesi', 'anneannesi', 'baba tarafındaki dedesi', 'anne tarafındaki dedesi', 'kardeşi'];

export function kur({ R, karistir, sec, ekle }) {
  function aileSorusu() {
    const e = karistir(ERKEK), k = karistir(KADIN), dd = karistir(DEDE), nn = karistir(NINE), ck = karistir(COCUK);
    const baba = e.pop(), anne = k.pop();
    const babaSib = Array.from({ length: 1 + Math.floor(R() * 2) }, () => (R() < 0.5 ? { rol: 'amca', ad: e.pop() } : { rol: 'hala', ad: k.pop() }));
    const anneSib = Array.from({ length: 1 + Math.floor(R() * 2) }, () => (R() < 0.5 ? { rol: 'dayi', ad: e.pop() } : { rol: 'teyze', ad: k.pop() }));
    const cocuklar = ck.slice(0, 1 + Math.floor(R() * 3));
    const p = { babaTarafi: { dede: dd[0], nine: nn[0] }, anneTarafi: { dede: dd[1], nine: nn[1] }, babaSib, baba, anne, anneSib, cocuklar };
    const spec = { tip_id: 'a6-aile-agaci', parametreler: p };
    const c = sec(cocuklar);
    // c çocuğunun gözünden herkesin yakınlığı (şekilden bağımsız, parametrelerden)
    const iliski = new Map([[baba, 'babası'], [anne, 'annesi'], [p.babaTarafi.dede, 'baba tarafındaki dedesi'], [p.babaTarafi.nine, 'babaannesi'], [p.anneTarafi.dede, 'anne tarafındaki dedesi'], [p.anneTarafi.nine, 'anneannesi']]);
    for (const s of babaSib) iliski.set(s.ad, s.rol === 'amca' ? 'amcası' : 'halası');
    for (const s of anneSib) iliski.set(s.ad, s.rol === 'dayi' ? 'dayısı' : 'teyzesi');
    for (const x of cocuklar) if (x !== c) iliski.set(x, 'kardeşi');
    const ortak = { kod: 'SB.4.3.2', konu: 'Aile Tarihi', alt_konu: 'Aile ağacından yakınlık çıkarımı', spec };
    const kisiler = [...iliski.keys()];
    const terimKume = (t) => kisiler.filter((x) => iliski.get(x) === t);

    if (R() < 0.5) {
      // "X kişisi c'nin nesi olur?"
      const kisi = sec(kisiler.filter((x) => x !== c)), dogru = iliski.get(kisi);
      const cel = karistir(TERIM.filter((t) => t !== dogru)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 2, dogru, celdirici: cel,
        gerekce: cel.map((t) => `${kisi}, ${ilgi(c)} ${t} değildir; aile ağacındaki bağlantı çizgileri ${kisi} adlı kişinin ${ilgi(c)} ${dogru} olduğunu gösterir.`),
        kok: `Yukarıdaki aile ağacına göre ${kisi} adlı kişi, ${c} adlı çocuğun nesi olur?`,
        ipucu: `Önce ${c} adlı çocuğun kutusundan çizgilerle yukarı çık. Sonra ${kisi} adlı kutuya hangi çizgilerle ulaştığına bak.`,
        cozum: [`${c} çocuğunun ağaçtaki yeri bulunur.`, `Çizgiler izlenince ${kisi} adlı kişinin ${ilgi(c)} ${dogru} olduğu görülür.`],
        dogrulama: [{ yol: ['iliski', `${c}|${kisi}`], beklenen: dogru }] });
    }
    // "c'nin T kimdir?" — yalnız ağaçta tek kişiye karşılık gelen terimler
    const tekil = TERIM.filter((t) => terimKume(t).length === 1);
    const t = sec(tekil), dogru = terimKume(t)[0];
    const cel = karistir(kisiler.filter((x) => x !== dogru && x !== c)).slice(0, 3);
    return ekle({ ...ortak, zorluk: 2, dogru, celdirici: cel,
      gerekce: cel.map((x) => `${x}, ${ilgi(c)} ${iliski.get(x)} olur; ${t} değildir.`),
      kok: `Yukarıdaki aile ağacına göre ${ilgi(c)} ${t} kimdir?`,
      ipucu: `${c} adlı çocuğun kutusundan başla; çizgileri izleyerek ${t} olan kutuyu bul.`,
      cozum: [`${c} çocuğunun ağaçtaki yeri bulunur.`, `Çizgiler izlenince ${ilgi(c)} ${t} olan kişinin ${dogru} olduğu görülür.`],
      dogrulama: [{ yol: ['iliski', `${c}|${dogru}`], beklenen: t }] });
  }
  return { aileSorusu };
}

export const KAYIT = [
  { id: 'sb4-aile-agaci', ders: 'Sosyal Bilgiler', sinif: 4, idOnek: 'SB4-AIL', mufredat_surum: MUFREDAT, kodlar: ['SB.4.3.2'], fabrika: kur, uret: (f) => f.aileSorusu() },
];
