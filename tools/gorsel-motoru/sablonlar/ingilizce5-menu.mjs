// 5. sınıf İngilizce — restoran menüsü: tür, fiyat, en ucuz / en pahalı. Şekil: b4-tablo.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 5. sınıf; program: TYMM)';
const YEMEK = ['Burger', 'Pizza', 'Pasta', 'Salad', 'Soup', 'Cake'];
const ICECEK = ['Juice', 'Tea', 'Milk', 'Water', 'Lemonade', 'Coffee'];

export function kur({ R, sec, karistir, ekle }) {
  function menuSorusu() {
    const y = karistir(YEMEK).slice(0, 4), ic = karistir(ICECEK).slice(0, 4), fiyat = karistir(Array.from({ length: 17 }, (_, i) => 10 + i * 5)).slice(0, 8);
    const ad = karistir([...y.map((a) => [a, 'food']), ...ic.map((a) => [a, 'drink'])]);
    const satirlar = ad.map(([a, t], i) => ({ ad: a, hucreler: [t, `${fiyat[i]} TL`] }));
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: 'Restaurant menu', ilkSutun: 'Item', sutunlar: ['Type', 'Price'], satirlar } };
    const ortak = { kod: 'ENG.5.6.V1', konu: 'Ordering in a restaurant', spec };
    const dogrulama = ad.map(([a, t], i) => ({ yol: ['hucre', `${a}|Price`], beklenen: `${fiyat[i]} TL` }));
    const kind = sec(['fiyat', 'hangi', 'ucuz', 'pahali']), i = Math.floor(R() * 8), [Xa] = ad[i];
    const digerleri = ad.map((_, j) => j).filter((j) => j !== i);
    if (kind === 'fiyat' || kind === 'hangi') {
      const cel = karistir(digerleri).slice(0, 3);
      if (kind === 'fiyat') ekle({ ...ortak, alt_konu: 'Fiyat okuma', zorluk: 1, kok: `Look at the menu. How much is the ${Xa.toLowerCase()}?`, dogru: `It's ${fiyat[i]} TL.`, celdirici: cel.map((j) => `It's ${fiyat[j]} TL.`),
        gerekce: cel.map((j) => `${fiyat[j]} TL, ${ad[j][0].toLowerCase()} fiyatıdır.`), ipucu: `Menüde ${Xa} satırını bul, Price sütununa bak.`, cozum: [`${Xa} satırında fiyat ${fiyat[i]} TL'dir.`], dogrulama });
      else ekle({ ...ortak, alt_konu: 'Fiyattan ürünü bulma', zorluk: 2, kok: `Look at the menu. Which one costs ${fiyat[i]} TL?`, dogru: `The ${Xa.toLowerCase()}.`, celdirici: cel.map((j) => `The ${ad[j][0].toLowerCase()}.`),
        gerekce: cel.map((j) => `${ad[j][0]} ${fiyat[j]} TL'dir.`), ipucu: `Price sütununda ${fiyat[i]} TL yazan satırı bul.`, cozum: [`${fiyat[i]} TL yazan satır ${Xa} satırıdır.`], dogrulama });
      return;
    }
    const tur = sec(['food', 'drink']), grup = ad.map((a, j) => j).filter((j) => ad[j][1] === tur);
    const sirali = [...grup].sort((a, b) => fiyat[a] - fiyat[b]), hedef = kind === 'ucuz' ? sirali[0] : sirali[sirali.length - 1];
    const cel = grup.filter((j) => j !== hedef);
    ekle({ ...ortak, alt_konu: 'En ucuz / en pahalı', zorluk: 3, kok: `Look at the menu. What is the ${kind === 'ucuz' ? 'cheapest' : 'most expensive'} ${tur}?`, dogru: `The ${ad[hedef][0].toLowerCase()}.`, celdirici: cel.map((j) => `The ${ad[j][0].toLowerCase()}.`),
      gerekce: cel.map((j) => (ad[j][1] === tur ? `${ad[j][0]} (${fiyat[j]} TL), ${tur} grubunda ${kind === 'ucuz' ? 'en ucuz' : 'en pahalı'} değildir.` : `${ad[j][0]} bir ${ad[j][1]}; soru ${tur} sorar.`)),
      ipucu: `Önce Type sütununda ${tur} yazan satırları seç, sonra fiyatlarını karşılaştır.`,
      cozum: [`${tur} olan ürünler: ${grup.map((j) => `${ad[j][0]} ${fiyat[j]} TL`).join(', ')}.`, `${kind === 'ucuz' ? 'En ucuz' : 'En pahalı'}: ${ad[hedef][0]}.`], dogrulama });
  }
  return { menuSorusu };
}

export const KAYIT = [
  { id: 'eng5-menu', ders: 'İngilizce', sinif: 5, idOnek: 'ENG5-MEN', mufredat_surum: MUFREDAT, kodlar: ['ENG.5.6.V1'], fabrika: kur, uret: (f) => f.menuSorusu() },
];


