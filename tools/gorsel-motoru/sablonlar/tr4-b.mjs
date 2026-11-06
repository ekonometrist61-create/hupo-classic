// 4. sınıf Türkçe (önceki program) — T.4.3.25 Yönergeleri kavrar.
// Numaralı yönerge adımlarından hemen önce/sonra gelen adım sorulur; cevap adım sırasından kodla bulunur.
import { surum } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_4_turkce_onceki');
const GOREV = [
  { baslik: 'Fidan Dikme Yönergesi', adim: ['Toprağı kazarak çukur aç.', 'Fidanı çukura yerleştir.', 'Çukuru toprakla doldur.', 'Fidanın çevresini bastır.', 'Fidanı sula.'] },
  { baslik: 'Ellerini Yıkama Yönergesi', adim: ['Musluğu aç ve ellerini ıslat.', 'Ellerine sabun sür.', 'Ellerini iyice ov.', 'Ellerini suyla durula.', 'Ellerini kurula.'] },
  { baslik: 'Kek Yapma Yönergesi', adim: ['Yumurta ve şekeri çırp.', 'Süt ve yağı ekle.', 'Unu ve kabartma tozunu kat.', 'Hamuru kalıba dök.', 'Kalıbı fırına ver.'] },
  { baslik: 'Mektup Gönderme Yönergesi', adim: ['Mektubunu yaz.', 'Mektubu zarfa koy.', 'Zarfın ağzını yapıştır.', 'Zarfa adresi yaz.', 'Zarfa pul yapıştır.'] },
  { baslik: 'Saksıya Çiçek Dikme Yönergesi', adim: ['Saksının altına çakıl taşı koy.', 'Saksıyı toprakla doldur.', 'Toprakta bir çukur aç.', 'Çiçeğin köklerini çukura yerleştir.', 'Çiçeği sula.'] },
  { baslik: 'Dişlerini Fırçalama Yönergesi', adim: ['Fırçaya macun sık.', 'Üst dişlerini fırçala.', 'Alt dişlerini fırçala.', 'Ağzını suyla çalkala.', 'Fırçanı yıka.'] },
  { baslik: 'Yatak Toplama Yönergesi', adim: ['Yastığı yataktan al.', 'Çarşafı düzelt.', 'Yorganı katla.', 'Yastığı yerine koy.', 'Yatağın üstünü örtüyle kapat.'] },
  { baslik: 'Kitap Ödünç Alma Yönergesi', adim: ['Kütüphaneye git.', 'Kitabı raftan seç.', 'Üye kartını görevliye ver.', 'Kitabın kaydını yaptır.', 'Kitabı teslim tarihine kadar oku.'] },
];

export function kur({ R, sec, karistir, ekle }) {
  function adimSorusu() {
    const g = sec(GOREV), tur = sec(['sonra', 'once']);
    const i = tur === 'sonra' ? sec([0, 1, 2, 3]) : sec([1, 2, 3, 4]);
    const hedef = tur === 'sonra' ? i + 1 : i - 1;
    const dogru = g.adim[hedef];
    const cel = karistir(g.adim.filter((_, k) => k !== i && k !== hedef)).slice(0, 3);
    const kok = tur === 'sonra'
      ? `Yönergeye göre "${g.adim[i]}" adımından hemen sonra ne yapılmalıdır?`
      : `Yönergeye göre "${g.adim[i]}" adımından hemen önce ne yapılmalıdır?`;
    ekle({ kod: 'T.4.3.25', konu: 'Yönergeler', alt_konu: 'Yönergedeki adımların sırasını kavrama', zorluk: 1,
      spec: { tip_id: 'b3-numarali', parametreler: { baslik: g.baslik, ogeler: g.adim, ok: true } },
      kok, dogru, celdirici: cel,
      gerekce: cel.map((c) => `"${c}" adımı sorulan adımın ${tur === 'sonra' ? 'hemen sonrasında' : 'hemen öncesinde'} yer almaz.`),
      ipucu: 'Yönergedeki numaralı adımları sırayla oku ve sorulan adımın numarasını bul.',
      cozum: [`"${g.adim[i]}" adımı ${i + 1}. adımdır.`, `${tur === 'sonra' ? 'Hemen sonraki' : 'Hemen önceki'} adım ${hedef + 1}. adımdır: ${dogru}`],
      dogrulama: [{ yol: ['ogeler', String(hedef + 1)], beklenen: dogru }] });
  }
  return { adimSorusu };
}

export const KAYIT = [
  { id: 'tr4-yonerge', ders: 'Türkçe', sinif: 4, idOnek: 'TR4-YON', mufredat_surum: MUFREDAT, kodlar: ['T.4.3.25'], fabrika: kur, uret: (f) => f.adimSorusu() },
];
