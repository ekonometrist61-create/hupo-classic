// 4. sınıf Sosyal Bilgiler ek şablonları (kurgusal içerik):
//  - SB.4.5.3 üretim-dağıtım-tüketim süreci: akış şemasında aşamaların sırası (a7-akis).
//  - SB.4.6.2 çocukluk dönemi ile bugünkü koşulların karşılaştırılması: çizelge (a7-cizelge).
// Ürünler, koşullar ve kişiler kurgusaldır. Doğru cevap şekilden kodla hesaplanır.
import { sayisalSik } from './sosyal6-ortak.mjs';

const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';

// ---------- SB.4.5.3: süreç akışı ----------
const SURECLER = [
  { baslik: 'Kavanoz balı', adimlar: ['Petek toplanır', 'Bal süzülür', 'Kavanoza konur', 'Depoya gönderilir', 'Sofrada tüketilir'] },
  { baslik: 'Yün battaniye', adimlar: ['Yün kırkılır', 'İplik eğrilir', 'Battaniye dokunur', 'Mağazaya gönderilir', 'Evde kullanılır'] },
  { baslik: 'Tahta oyuncak', adimlar: ['Ağaç kesilir', 'Parçalar biçilir', 'Oyuncak boyanır', 'Oyuncakçıya gider', 'Çocuk oynar'] },
  { baslik: 'Zeytinyağı', adimlar: ['Zeytin toplanır', 'Ezilip sıkılır', 'Şişelenir', 'Markete taşınır', 'Mutfakta kullanılır'] },
  { baslik: 'Defter', adimlar: ['Kağıt üretilir', 'Sayfalar kesilir', 'Cilt yapılır', 'Kırtasiyeye gider', 'Okulda kullanılır'] },
  { baslik: 'Ekmek', adimlar: ['Un öğütülür', 'Hamur yoğrulur', 'Fırında pişer', 'Markete taşınır', 'Sofrada yenir'] },
];

export function surecKur({ R, karistir, sec, konum, ekle }) {
  function surecSorusu() {
    const s = sec(SURECLER), A = s.adimlar, n = A.length;
    const spec = { tip_id: 'a7-akis', parametreler: { baslik: s.baslik, adimlar: A } };
    const ortak = { kod: 'SB.4.5.3', konu: 'Üretim, Dağıtım ve Tüketim', alt_konu: 'Bir ürünün üretimden tüketime kadar süreçleri', spec };
    const tur = sec(['sonraki', 'onceki', 'son']);

    if (tur === 'sonraki' || tur === 'onceki') {
      // sonraki: i ∈ [0, n-2], doğru A[i+1]; onceki: i ∈ [1, n-1], doğru A[i-1]
      const i = tur === 'sonraki' ? Math.floor(R() * (n - 1)) : 1 + Math.floor(R() * (n - 1));
      const j = tur === 'sonraki' ? i + 1 : i - 1;
      const ad = A[i];
      const kalan = karistir(A.map((_, x) => x).filter((x) => x !== i && x !== j)).slice(0, 3);
      const gerekce = kalan.map((x) => {
        if (tur === 'sonraki') {
          return x < i ? `${A[x]} aşaması "${ad}" aşamasından önce gelir.`
            : `${A[x]} aşaması "${ad}" aşamasından sonra gelir; ancak hemen sonraki aşama değildir.`;
        }
        return x > i ? `${A[x]} aşaması "${ad}" aşamasından sonra gelir.`
          : `${A[x]} aşaması "${ad}" aşamasından önce gelir; ancak hemen önceki aşama değildir.`;
      });
      const kok = tur === 'sonraki'
        ? `Yukarıdaki akış şemasına göre "${ad}" aşamasından hemen sonra hangi aşama gelir?`
        : `Yukarıdaki akış şemasına göre "${ad}" aşamasından hemen önce hangi aşama gelir?`;
      return ekle({ ...ortak, zorluk: 1, dogru: A[j], celdirici: kalan.map((x) => A[x]), gerekce, kok,
        ipucu: tur === 'sonraki' ? 'Okun gittiği numaralı kutuya bak.' : 'Okun geldiği numaralı kutuya bak.',
        cozum: [`Şemada "${ad}" aşaması ${i + 1}. sırada yer alır.`, `${tur === 'sonraki' ? 'Hemen sonra' : 'Hemen önce'} gelen aşama ${j + 1}. sırada olan "${A[j]}" aşamasıdır.`],
        dogrulama: [{ yol: ['sira', ad], beklenen: i + 1 }, { yol: ['sira', A[j]], beklenen: j + 1 }] });
    }

    // son: en son aşama (n. sıra) doğru; diğer üç aşama önceki sıralarda
    const diger = karistir(A.slice(0, n - 1)).slice(0, 3);
    const idx = (t) => A.indexOf(t);
    return ekle({ ...ortak, zorluk: 1, dogru: A[n - 1], celdirici: diger, gerekce: diger.map((t) => `${t} akışta ${idx(t) + 1}. sırada yer alır; son aşama değildir.`),
      kok: 'Yukarıdaki akış şemasında en son hangi aşama yer alır?',
      ipucu: 'Okların bittiği numaralı kutuya bak.',
      cozum: [`Akış "${A[0]}" aşamasıyla başlar ve ok zinciriyle ilerler.`, `En son, ${n}. sırada yer alan "${A[n - 1]}" aşamasıdır.`],
      dogrulama: [{ yol: ['sira', A[n - 1]], beklenen: n }] });
  }
  return { surecSorusu };
}

// ---------- SB.4.6.2: çocukluk dönemi ve bugün koşulları (çizelge) ----------
const KOSULLAR = [
  { ad: 'Haberleşme', eski: 'Mektup', yeni: 'Mesaj' },
  { ad: 'Ulaşım', eski: 'At arabası', yeni: 'Otobüs' },
  { ad: 'Aydınlatma', eski: 'Gaz lambası', yeni: 'Elektrik' },
  { ad: 'Alışveriş', eski: 'Pazar yeri', yeni: 'Market' },
  { ad: 'Eğitim', eski: 'Tahta kara', yeni: 'Akıllı tahta' },
  { ad: 'Eğlence', eski: 'Radyo', yeni: 'İnternet' },
];
const SABIT = [
  { ad: 'Oyun', deger: 'Sokakta oyun' },
  { ad: 'Yemek', deger: 'Ev yapımı' },
  { ad: 'Bayram', deger: 'Aile ziyareti' },
  { ad: 'Komşuluk', deger: 'Yardımlaşma' },
];

export function tabloKur({ R, karistir, sec, konum, ekle }) {
  function tabloSorusu() {
    const tur = sec(['degismeyen', 'degisen', 'bugun', 'eski']);
    // degismeyen: 1 sabit + 3 değişen satır; degisen: 3 sabit + 1 değişen satır; bugun/eski: hedef değişen satır
    const c = tur === 'degisen' ? 1 : 3;
    const degisenler = karistir(KOSULLAR).slice(0, c).map((r) => ({ etiket: r.ad, eski: r.eski, yeni: r.yeni, degisti: true }));
    const sabitler = karistir(SABIT).slice(0, 4 - c).map((r) => ({ etiket: r.ad, eski: r.deger, yeni: r.deger, degisti: false }));
    const satirlar = karistir([...degisenler, ...sabitler]);
    const spec = { tip_id: 'a7-cizelge', parametreler: {
      baslik: 'Çocukluk dönemi ve bugünkü koşullar', ilkSutun: 'Koşul', sutunlar: ['Çocukluk dönemi', 'Bugün'],
      satirlar: satirlar.map((r) => ({ etiket: r.etiket, hucreler: [r.eski, r.yeni] })), etiketGen: 110, hucreGen: 130 } };
    const ortak = { kod: 'SB.4.6.2', konu: 'Bilim İnsanları ve Tarihsel Bağlam', alt_konu: 'Çocukluk dönemi koşullarını günümüz koşullarıyla karşılaştırma', spec };
    const dogrulamaSatir = (r) => [{ yol: ['hucre', r.etiket, 'Çocukluk dönemi'], beklenen: r.eski }, { yol: ['hucre', r.etiket, 'Bugün'], beklenen: r.yeni }];

    if (tur === 'degismeyen') {
      const h = satirlar.find((r) => !r.degisti), d = satirlar.filter((r) => r.degisti);
      return ekle({ ...ortak, zorluk: 1, dogru: h.etiket, celdirici: d.map((r) => r.etiket),
        gerekce: d.map((r) => `${r.etiket} koşulunda çocukluk döneminde "${r.eski}", bugün "${r.yeni}" vardır; değişmiştir.`),
        kok: 'Tabloya göre kurgusal bir bilim insanının çocukluk dönemi ile bugünkü koşulları arasında değişmeyen koşul hangisidir?',
        ipucu: 'Her satırdaki iki hücreyi karşılaştır. İki hücresi aynı olan satırı bul.',
        cozum: [`Tabloda "${h.etiket}" satırında iki hücre de "${h.eski}" olarak yazılmıştır.`, 'Diğer satırların iki hücresi farklıdır.'],
        dogrulama: dogrulamaSatir(h) });
    }
    if (tur === 'degisen') {
      const h = satirlar.find((r) => r.degisti), s = satirlar.filter((r) => !r.degisti);
      return ekle({ ...ortak, zorluk: 1, dogru: h.etiket, celdirici: s.map((r) => r.etiket),
        gerekce: s.map((r) => `${r.etiket} koşulunda çocukluk döneminde ve bugün aynı durum ("${r.eski}") vardır; değişmemiştir.`),
        kok: 'Tabloya göre kurgusal bir bilim insanının çocukluk döneminden bugüne değişen tek koşul hangisidir?',
        ipucu: 'Her satırdaki iki hücreyi karşılaştır. İki hücresi farklı olan satırı bul.',
        cozum: [`Tabloda "${h.etiket}" satırında "${h.eski}" değeri "${h.yeni}" değerine dönüşmüştür.`, 'Diğer satırların iki hücresi aynıdır.'],
        dogrulama: dogrulamaSatir(h) });
    }

    // bugun / eski: değişen satırın bugünkü ya da çocukluk dönemi değeri
    const t = satirlar.find((r) => r.degisti);
    const digerler = karistir(satirlar.filter((r) => r !== t)).slice(0, 2);
    const bugun = tur === 'bugun';
    const dogru = bugun ? t.yeni : t.eski;
    const kendi = bugun ? t.eski : t.yeni;
    const kok = bugun
      ? `Tabloya göre "${t.etiket}" koşulunun bugünkü durumu aşağıdakilerden hangisidir?`
      : `Tabloya göre "${t.etiket}" koşulunun çocukluk dönemindeki durumu aşağıdakilerden hangisidir?`;
    const celdirici = [kendi, ...digerler.map((r) => (bugun ? r.yeni : r.eski))];
    const gerekce = [
      bugun ? `Bu değer "${t.etiket}" koşulunun çocukluk dönemindeki durumudur; bugünkü durum değildir.` : `Bu değer "${t.etiket}" koşulunun bugünkü durumudur; çocukluk döneminde değildir.`,
      ...digerler.map((r) => `Bu değer "${r.etiket}" koşuluna aittir; "${t.etiket}" koşulunun değeri değildir.`),
    ];
    return ekle({ ...ortak, zorluk: 1, dogru, celdirici, gerekce, kok,
      ipucu: 'Soruda istenen koşulun satırını bul ve doğru sütundaki hücreye bak.',
      cozum: [`"${t.etiket}" satırında çocukluk dönemi "${t.eski}", bugün "${t.yeni}" olarak yazılmıştır.`, `İstenen sütundaki değer "${dogru}" olur.`],
      dogrulama: dogrulamaSatir(t) });
  }
  return { tabloSorusu };
}

export const KAYIT = [
  { id: 'sb4-surec-akis', ders: 'Sosyal Bilgiler', sinif: 4, idOnek: 'SB4-SRC', mufredat_surum: MUFREDAT, kodlar: ['SB.4.5.3'], fabrika: surecKur, uret: (f) => f.surecSorusu() },
  { id: 'sb4-kosul-cizelge', ders: 'Sosyal Bilgiler', sinif: 4, idOnek: 'SB4-KSL', mufredat_surum: MUFREDAT, kodlar: ['SB.4.6.2'], fabrika: tabloKur, uret: (f) => f.tabloSorusu() },
];
