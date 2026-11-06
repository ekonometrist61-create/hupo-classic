// 3. sınıf İngilizce — yemek listesi ve fiyatlar (siparişte yiyecek/içecek). Şekil: b4-tablo.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 3. sınıf; program: TYMM)';
const URUNLER = ['Pizza', 'Burger', 'Salad', 'Soup', 'Pasta', 'Sandwich', 'Juice', 'Milk', 'Tea', 'Cake', 'Ice cream', 'Water'];

export function kur({ R, sec, karistir, ekle }) {
  function menuSorusu() {
    const urun = karistir(URUNLER).slice(0, 5), fiyat = karistir(Array.from({ length: 16 }, (_, i) => i + 5)).slice(0, 5);
    const satirlar = urun.map((u, i) => ({ ad: u, hucreler: [`${fiyat[i]} TL`] }));
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: 'Menu', sutunlar: ['Price'], satirlar } };
    const i = Math.floor(R() * 5), X = urun[i], ortak = { kod: 'ENG.3.6.V1', konu: 'Food and ordering', spec };
    const dogrulama = urun.map((u, j) => ({ yol: ['hucre', `${u}|Price`], beklenen: `${fiyat[j]} TL` }));
    const digerleri = urun.map((_, j) => j).filter((j) => j !== i);
    if (sec(['fiyat', 'hangi']) === 'fiyat') {
      const cel = karistir(digerleri).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Fiyat okuma', zorluk: 1, kok: `Look at the menu. How much is the ${X.toLowerCase()}?`, dogru: `It's ${fiyat[i]} TL.`, celdirici: cel.map((j) => `It's ${fiyat[j]} TL.`),
        gerekce: cel.map((j) => `${fiyat[j]} TL, ${urun[j].toLowerCase()} fiyatıdır; ${X.toLowerCase()} ${fiyat[i]} TL.`), ipucu: `Menüde ${X} satırını bul ve fiyatına bak.`, cozum: [`${X} satırında fiyat ${fiyat[i]} TL yazar.`], dogrulama });
    } else {
      const cel = karistir(digerleri).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Fiyattan ürünü bulma', zorluk: 2, kok: `Look at the menu. Which one costs ${fiyat[i]} TL?`, dogru: `The ${X.toLowerCase()}.`, celdirici: cel.map((j) => `The ${urun[j].toLowerCase()}.`),
        gerekce: cel.map((j) => `${urun[j]} ${fiyat[j]} TL'dir; sorulan fiyat ${fiyat[i]} TL.`), ipucu: `Fiyat sütununda ${fiyat[i]} TL yazan satırı bul.`, cozum: [`${fiyat[i]} TL yazan satır ${X} satırıdır.`], dogrulama });
    }
  }
  return { menuSorusu };
}

export const KAYIT = [
  { id: 'eng3-menu', ders: 'İngilizce', sinif: 3, idOnek: 'ENG3-MEN', mufredat_surum: MUFREDAT, kodlar: ['ENG.3.6.V1'], fabrika: kur, uret: (f) => f.menuSorusu() },
];

