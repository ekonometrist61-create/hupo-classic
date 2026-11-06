// 3. sınıf Türkçe — noktalama (kesme, virgül, iki nokta ...), olay sırası, içindekiler tablosu, yazım hatası bulma.
// Kazanım: T.Y.3.3 (yazma kuralları), T.O.3.2 (olayların sırası), T.O.3.1 (başlık/içindekiler inceleme), T.Y.3.5 (yazılarında hata bulur).
import { cumleKur, kartKur, yazimKur, OLAY4, havuzSik, pencere, surum, tekilEkle } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_3_turkce');
const BOLUM = ['Mevsimler', 'Hayvanlar Alemi', 'Uzay Yolculuğu', 'Sağlıklı Beslenme', 'Ormanın Sesi', 'Deniz Altı', 'Su ve Hayat', 'Bayram Sevinci', 'Kitap Kurdu', 'Oyun Zamanı',
  'Renkler Dünyası', 'Minik Bilim', 'Doğayı Koruyalım', 'Müzik Sesleri', 'Dostluk Bahçesi', 'Eski Oyunlar'];

export function icindekiKur({ R, sec, karistir, ekle: ekleOrj, konum }) {
  const ekle = tekilEkle(ekleOrj);
  function icindekiler() {
    const n = sec([5, 6]), k = konum(), adlar = karistir(BOLUM).slice(0, n); let sayfa = 3 + Math.floor(R() * 6); const sa = [];
    for (let i = 0; i < n; i++) { sa.push(sayfa); sayfa += 6 + Math.floor(R() * 14); }
    const satirlar = adlar.map((a, i) => [a, sa[i]]), spec = { tip_id: 'b3-tablo', parametreler: { baslik: 'İçindekiler', sutunlar: ['Bölüm', 'Sayfa'], satirlar } };
    const ortak = { kod: 'T.O.3.1', konu: 'Başlık ve içindekiler', alt_konu: 'İçindekiler tablosundan bilgi bulma', spec, zorluk: 1 };
    const tur = sec(['sayfa', 'bolum', 'onceki', 'fark']), i = Math.floor(R() * n);
    if (tur === 'sayfa') {
      const sik = havuzSik({ dogru: sa[i], havuz: sa, k, karistir }); if (!sik) throw new Error('sik_yok');
      return ekle({ ...ortak, sirali: sik.map(String), dogru: String(sa[i]), kok: `Tabloya göre "${adlar[i]}" bölümü kaçıncı sayfada başlar?`,
        gerekce: sik.map((v) => (v === sa[i] ? '' : `${v}. sayfa, "${satirlar[sa.indexOf(v)][0]}" bölümünün başladığı sayfadır; "${adlar[i]}" değildir.`)),
        ipucu: 'Bölümün adını bul, yanındaki sayfa numarasını oku.', cozum: [`Tabloda "${adlar[i]}" satırı bulunur.`, `Yanında ${sa[i]} yazılıdır.`], dogrulama: [{ yol: ['hucre', adlar[i], 'Sayfa'], beklenen: sa[i] }] });
    }
    if (tur === 'bolum') {
      const cel = karistir(adlar.filter((_, j) => j !== i)).slice(0, 3);
      return ekle({ ...ortak, dogru: adlar[i], celdirici: cel, kok: `Tabloya göre ${sa[i]}. sayfada hangi bölüm başlar?`,
        gerekce: cel.map((a) => `"${a}" bölümü ${sa[adlar.indexOf(a)]}. sayfada başlar; ${sa[i]}. sayfada değil.`),
        ipucu: 'Sayfa sütununda numarayı bul, aynı satırdaki bölüm adını oku.', cozum: [`Sayfa sütununda ${sa[i]} aranır.`, `Aynı satırda "${adlar[i]}" yazılıdır.`], dogrulama: [{ yol: ['hucre', adlar[i], 'Sayfa'], beklenen: sa[i] }] });
    }
    if (tur === 'onceki') {
      if (i === 0) throw new Error('ilk_bolum');
      const cel = karistir(adlar.filter((_, j) => j !== i - 1)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 2, dogru: adlar[i - 1], celdirici: cel, kok: `Tabloya göre "${adlar[i]}" bölümünden hemen önce hangi bölüm gelir?`,
        gerekce: cel.map((a) => `"${a}" bölümü "${adlar[i]}" bölümünden hemen önce gelmez; tabloda ${sa[adlar.indexOf(a)]}. sayfadadır.`),
        ipucu: 'Bölümlerin sayfa sırasına bak; sorulan bölümün hemen üstündeki satırı bul.', cozum: [`"${adlar[i]}" satırı bulunur.`, `Hemen üstündeki satır "${adlar[i - 1]}" bölümüdür.`], dogrulama: [{ yol: ['hucre', adlar[i - 1], 'Sayfa'], beklenen: sa[i - 1] }, { yol: ['hucre', adlar[i], 'Sayfa'], beklenen: sa[i] }] });
    }
    const j = (i + 1 + Math.floor(R() * (n - 1))) % n, a = Math.min(i, j), b = Math.max(i, j), D = sa[b] - sa[a], s = pencere(D, k, 1); if (!s) throw new Error('pencere');
    return ekle({ ...ortak, zorluk: 2, sirali: s.map(String), dogru: String(D), kok: `Tabloya göre "${adlar[a]}" ile "${adlar[b]}" bölümlerinin başladığı sayfalar arasında kaç sayfa fark vardır?`,
      gerekce: s.map((v) => (v === D ? '' : `${v}, iki sayfa numarasının farkı değildir; ${sa[b]} − ${sa[a]} = ${D} olur.`)),
      ipucu: 'İki bölümün sayfa numaralarını oku; büyük numaradan küçüğünü çıkar.', cozum: [`"${adlar[a]}" ${sa[a]}. sayfada, "${adlar[b]}" ${sa[b]}. sayfada başlar.`, `${sa[b]} − ${sa[a]} = ${D}.`], dogrulama: [{ yol: ['hucre', adlar[a], 'Sayfa'], beklenen: sa[a] }, { yol: ['hucre', adlar[b], 'Sayfa'], beklenen: sa[b] }] });
  }
  return { icindekiler };
}

export const KAYIT = [
  { id: 'b3-tr3-noktalama', ders: 'Türkçe', sinif: 3, idOnek: 'B3TR3-NKT', mufredat_surum: MUFREDAT, kodlar: ['T.Y.3.3'],
    fabrika: (c) => cumleKur(c, { kod: 'T.Y.3.3', konu: 'Yazım kuralları', alt_konu: 'Noktalama işaretlerini kuralına uygun kullanma', turler: ['nokta', 'soru', 'unlem', 'virgul', 'kesme', 'ikinokta'], secenek: ['nokta', 'soru', 'unlem', 'virgul', 'kesme', 'ikinokta'], buyuk: true, buyukOran: 0.2, zorluk: 2 }), uret: (f) => f.soru() },
  { id: 'b3-tr3-olay', ders: 'Türkçe', sinif: 3, idOnek: 'B3TR3-OLY', mufredat_surum: MUFREDAT, kodlar: ['T.O.3.2'],
    fabrika: (c) => kartKur(c, { kod: 'T.O.3.2', konu: 'Olayların sırası', alt_konu: 'Metindeki olayların oluş sırasını belirleme', tur: 'olay', banka: OLAY4, duzen: 'liste', zorluk: 2 }), uret: (f) => f.sirala() },
  { id: 'b3-tr3-icindekiler', ders: 'Türkçe', sinif: 3, idOnek: 'B3TR3-ICN', mufredat_surum: MUFREDAT, kodlar: ['T.O.3.1'], fabrika: icindekiKur, uret: (f) => f.icindekiler() },
  { id: 'b3-tr3-yazim', ders: 'Türkçe', sinif: 3, idOnek: 'B3TR3-YZM', mufredat_surum: MUFREDAT, kodlar: ['T.Y.3.5'],
    fabrika: (c) => yazimKur(c, { kod: 'T.Y.3.5', konu: 'Yazım hatası bulma', alt_konu: 'Yazdığı cümledeki yazım hatasını bulma', siniflar: [3], tur: false, zorluk: 2 }), uret: (f) => f.yazim() },
];
