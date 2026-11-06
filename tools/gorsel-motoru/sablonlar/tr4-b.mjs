// 4. sınıf Türkçe (önceki program) — T.4.3.25 Yönergeleri kavrar.
// Yönerge adımları şekilde numaralı ve okla gösterilir; adımların sırası mantıkla değil şekille bilinir
// (görev sırası keyfi/karışık verilir). Soru metni yalnız adımı sorar, cevap şekildeki numara/sıra/ok bilgisinden bulunur.
import { surum } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_4_turkce_onceki');
const GOREV = [
  { baslik: 'Oyun Parkuru Yönergesi', adim: ['Halkanın içinden geç.', 'Kırmızı konilerin etrafında dön.', 'Denge tahtasında yürü.', 'Topu sepete at.', 'İpin altından eğilerek geç.', 'Zili çal.'] },
  { baslik: 'Okul Gezisi Yönergesi', adim: ['Kütüphanede kitap incele.', 'Bahçede fidanları gez.', 'Laboratuvarı ziyaret et.', 'Müzik odasında şarkı söyle.', 'Spor salonunda ısınma yap.', 'Resim atölyesine uğra.'] },
  { baslik: 'Kamp Etkinliği Yönergesi', adim: ['Gölde kayık turu yap.', 'Çadırları kur.', 'Ormanda yürüyüş yap.', 'Kamp ateşi etrafında toplan.', 'Yıldızları gözlemle.', 'Bayrağı göndere çek.'] },
  { baslik: 'Bilim Şenliği Yönergesi', adim: ['Mıknatıs standını gez.', 'Sera maketini incele.', 'Teleskopla gökyüzüne bak.', 'Su deneyini izle.', 'Mikroskopla yaprağa bak.', 'Robot gösterisini seyret.'] },
  { baslik: 'Sınıf Nöbet Yönergesi', adim: ['Tahtayı sil.', 'Çiçekleri sula.', 'Pencereleri aç.', 'Sıraları düzelt.', 'Çöp kutusunu boşalt.', 'Panoya duyuruyu as.'] },
  { baslik: 'Hazine Avı Yönergesi', adim: ['Eski çınar ağacına git.', 'Kuyunun yanından geç.', 'Mavi kapıyı bul.', 'Taş köprüyü geç.', 'Kırmızı bayrağın altını kaz.', 'Rüzgâr gülünü say.'] },
  { baslik: 'Şenlik Hazırlığı Yönergesi', adim: ['Balonları şişir.', 'Afişi duvara as.', 'Masalara örtü ser.', 'Müziği hazırla.', 'Davetiyeleri dağıt.', 'Pastayı masaya getir.'] },
  { baslik: 'Köy Ziyareti Yönergesi', adim: ['Değirmeni gez.', 'Süt çiftliğinde inek sağımını izle.', 'Fırında ekmek pişirmeyi gör.', 'Bostanda sebze topla.', 'Kuş yuvalarını incele.', 'Köy çeşmesinden su iç.'] },
];

export function kur({ R, sec, karistir, ekle }) {
  function adimSorusu() {
    const g = sec(GOREV), tur = sec(['sonra', 'once', 'numara', 'sira']);
    const ogeler = karistir(g.adim.slice()).slice(0, sec([5, 6]));
    const n = ogeler.length;
    const ad = (k) => ogeler[k];
    let kok, dogru, cel, gerekce, cozum, dogrulama, ipucu, alt = 'Yönergedeki adımların sırasını kavrama';
    if (tur === 'sonra' || tur === 'once') {
      const i = tur === 'sonra' ? sec([...Array(n - 1).keys()]) : sec([...Array(n - 1).keys()].map((k) => k + 1));
      const hedef = tur === 'sonra' ? i + 1 : i - 1;
      dogru = ad(hedef);
      const havuz = ogeler.map((_, k) => k).filter((k) => k !== i && k !== hedef);
      const ks = karistir(havuz).slice(0, 3);
      cel = ks.map(ad);
      kok = `Şekildeki yönergeye göre "${ad(i)}" adımından hemen ${tur === 'sonra' ? 'sonra' : 'önce'} ne yapılmalıdır?`;
      gerekce = ks.map((k) => `"${ad(k)}" adımı şekilde ${k + 1}. sıradadır; sorulan adımın hemen ${tur === 'sonra' ? 'sonrasında' : 'öncesinde'} değildir.`);
      cozum = [`Şekilde "${ad(i)}" adımının numarasını bul.`, `Okun yönünü izleyerek ${tur === 'sonra' ? 'hemen sonraki' : 'hemen önceki'} numaralı adımı oku.`];
      dogrulama = [{ yol: ['ogeler', String(hedef + 1)], beklenen: dogru }];
      ipucu = 'Şekildeki numaralara ve okların gösterdiği yöne bak.';
    } else if (tur === 'numara') {
      const k = sec([...Array(n).keys()]);
      const no = k + 1;
      dogru = ad(k);
      const ks = karistir(ogeler.map((_, x) => x).filter((x) => x !== k)).slice(0, 3);
      cel = ks.map(ad);
      kok = `Şekildeki yönergede ${no} numaralı adım hangisidir?`;
      gerekce = ks.map((x) => `"${ad(x)}" adımı şekilde ${x + 1}. sıradadır, ${no}. sırada değildir.`);
      cozum = [`Şekilde ${no} numaralı kutuyu bul.`, 'Kutuya yazılmış adımı oku.'];
      dogrulama = [{ yol: ['ogeler', String(no)], beklenen: dogru }];
      ipucu = 'Şekildeki numaraları sırayla izle.';
    } else {
      const k = sec([...Array(n).keys()]);
      dogru = `${k + 1}. adım`;
      const ks = karistir(ogeler.map((_, x) => x).filter((x) => x !== k)).slice(0, 3);
      cel = ks.map((x) => `${x + 1}. adım`);
      kok = `Şekildeki yönergede "${ad(k)}" adımı kaçıncı adımdır?`;
      gerekce = ks.map((x) => `${x + 1}. numaralı kutuda başka bir adım yazar.`);
      cozum = [`Şekilde "${ad(k)}" yazan kutuyu bul.`, 'Kutunun numarasını oku.'];
      dogrulama = [{ yol: ['ogeler', String(k + 1)], beklenen: ad(k) }];
      ipucu = 'Sorulan adımı şekilde bul ve numarasına bak.';
    }
    ekle({ kod: 'T.4.3.25', konu: 'Yönergeler', alt_konu: alt, zorluk: 1,
      spec: { tip_id: 'b3-numarali', parametreler: { baslik: g.baslik, ogeler, ok: true } },
      kok, dogru, celdirici: cel, gerekce, ipucu, cozum, dogrulama });
  }
  return { adimSorusu };
}

export const KAYIT = [
  { id: 'tr4-yonerge', ders: 'Türkçe', sinif: 4, idOnek: 'TR4-YON', mufredat_surum: MUFREDAT, kodlar: ['T.4.3.25'], fabrika: kur, uret: (f) => f.adimSorusu() },
];