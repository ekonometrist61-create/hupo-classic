// 3. sınıf Hayat Bilgisi — krokiyi kullanarak bulunduğu yerin konumunu belirleme (HB.3.5.2). Sokak ya da okul koridoru krokisi; "Buradasın" işaretine göre konum sorulur.
import { MUF, gerekceSabit } from './hayat2-ortak.mjs';

const HAVUZ = {
  sokak: ['Market', 'Fırın', 'Eczane', 'Park', 'Okul', 'Kütüphane', 'Hastane', 'Postane', 'Bakkal', 'Çiçekçi', 'Kırtasiye', 'Kafe'],
  okul: ['Müdür odası', 'Kütüphane', 'Sınıf', 'Kantin', 'Spor salonu', 'Müzik odası', 'Revir', 'Laboratuvar', 'Rehberlik', 'Fen odası'],
};
const TUR = { sokak: ['Bir sokağın', 'yolun'], okul: ['Bir okulun', 'koridorun'] };

export function kur({ R, sec, karistir, ekle, konum }) {
  function duzen() {
    const tur = R() < 0.5 ? 'sokak' : 'okul', alti = karistir(HAVUZ[tur]).slice(0, 6);
    const taraf = R() < 0.5 ? 'ust' : 'alt', indeks = Math.floor(R() * 3);
    return { tur, ust: alti.slice(0, 3), alt: alti.slice(3), alti, taraf, indeks };
  }
  const karsi = (t) => (t === 'ust' ? 'alt' : 'ust');
  const sp = (d) => ({ tip_id: 'a2-kroki', parametreler: { tur: d.tur, ust: d.ust, alt: d.alt, burasi: { taraf: d.taraf, indeks: d.indeks } } });
  const cerceve = (d) => (d.tur === 'okul' ? 'Resimde bir okul koridorunun krokisi var.' : 'Resimde bir sokağın krokisi var.');

  // "Buradasın" işaretinin bulunduğu yer.
  function buradasin() {
    const d = duzen(), b = (d.taraf === 'ust' ? d.ust : d.alt)[d.indeks];
    const cel = karistir(d.alti.filter((x) => x !== b)).slice(0, 3);
    ekle({ kod: 'HB.3.5.2', konu: 'Doğa ve Çevre', alt_konu: 'Kroki okuma', zorluk: 1,
      spec: sp(d),
      kok: `${cerceve(d)} Kırmızı noktayla gösterilen “Buradasın” işareti hangi yerin önündedir?`,
      dogru: b, celdirici: cel,
      gerekce: cel.map((c) => `${c} krokide “Buradasın” işaretinin önünde değildir; işaret ${b.toLowerCase()} yerinin önündedir.`),
      ipucu: 'Kırmızı noktanın tam karşısındaki kutunun adını oku.',
      cozum: ['Kırmızı noktanın bulunduğu yeri krokide bul.', `İşaret ${b.toLowerCase()} yerinin önündedir.`],
      dogrulama: [{ yol: ['burasi'], beklenen: b }] });
  }

  // Yolun karşı tarafındaki yer.
  function karsisi() {
    const d = duzen(), b = (d.taraf === 'ust' ? d.ust : d.alt)[d.indeks], k = (d.taraf === 'ust' ? d.alt : d.ust)[d.indeks];
    const cel = karistir(d.alti.filter((x) => x !== k)).slice(0, 3);
    ekle({ kod: 'HB.3.5.2', konu: 'Doğa ve Çevre', alt_konu: 'Kroki okuma', zorluk: 2,
      spec: sp(d),
      kok: `${cerceve(d)} “Buradasın” işaretinin bulunduğu yerin tam karşısında, ${TUR[d.tur][1]} diğer tarafında hangi yer vardır?`,
      dogru: k, celdirici: cel,
      gerekce: cel.map((c) => `${c} ${b.toLowerCase()} yerinin karşısında değildir; karşısında ${k.toLowerCase()} vardır.`),
      ipucu: 'Önce işaretin hangi yerin önünde olduğunu bul, sonra yolun karşı tarafına aynı hizadan bak.',
      cozum: [`İşaret ${b.toLowerCase()} yerinin önündedir.`, `Yolun karşı tarafında, aynı hizada ${k.toLowerCase()} vardır.`],
      dogrulama: [{ yol: ['karsisi'], beklenen: k }] });
  }

  // "Buradasın" ile aynı sırada, en soldaki yer (işaret ortadaki yerin önünde).
  function ayniSira() {
    const d = duzen(); d.indeks = 1;
    const sira = d.taraf === 'ust' ? d.ust : d.alt, sol = sira[0], b = sira[1];
    const cel = karistir(d.alti.filter((x) => x !== sol)).slice(0, 3);
    ekle({ kod: 'HB.3.5.2', konu: 'Doğa ve Çevre', alt_konu: 'Kroki okuma', zorluk: 2,
      spec: sp(d),
      kok: `${cerceve(d)} “Buradasın” işaretinin bulunduğu taraftaki yerlerden hangisi en soldadır?`,
      dogru: sol, celdirici: cel,
      gerekce: cel.map((c) => `${c} işaretin bulunduğu taraftaki en soldaki yer değildir; en solda ${sol.toLowerCase()} vardır.`),
      ipucu: 'İşaretin hangi tarafta olduğunu bul, sonra o taraftaki üç yeri soldan sağa oku.',
      cozum: [`İşaret ${b.toLowerCase()} yerinin önündedir; bu taraftaki üç yer soldan sağa okunur.`, `En soldaki yer ${sol.toLowerCase()} yeridir.`],
      dogrulama: [{ yol: [d.taraf, '0'], beklenen: sol }] });
  }
  return { buradasin, karsisi, ayniSira };
}

export const KAYIT = [
  { id: 'hb3-kroki-konum', ders: 'Hayat Bilgisi', sinif: 3, idOnek: 'HB3-KRK', mufredat_surum: MUF.hb3, kodlar: ['HB.3.5.2'], fabrika: kur, uret: (f, c) => { const x = c.R(); return x < 0.34 ? f.buradasin() : x < 0.7 ? f.karsisi() : f.ayniSira(); } },
];
