// B3 ortak yardımcılar: sayı penceresi, yazıyla sayı, cümle/kart/yazım/şiir/grafik soru üreticileri ve içerik bankaları.
// Bu dosya KAYIT içermez; sablonlar/turkce*-, sosyal4-, sosyal6-yeni-, sosyal7-, inkilap8- dosyaları içe aktarır.
// İçerik kuralı: Türkçe imla ve noktalama kuralına tam uygun, kısa ve özgün; kesin olmayan bilgi yok.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const KLASOR = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..', '..', 'docs', 'soru-uretim', 'pilot');
export const surum = (ad) => JSON.parse(fs.readFileSync(path.join(KLASOR, `${ad}.json`), 'utf8')).program_surumu;

// ---------- sayı yardımcıları ----------
// Ardışık pencere: doğru değer k. sırada (0 tabanlı), alt sınır min.
export function pencere(dogru, k, min = 1) { const b = dogru - k; return b < min ? null : [0, 1, 2, 3].map((q) => b + q); }
// Havuzdan sıralı dört değer: k tane küçük, 3-k tane büyük; yoksa null.
export function havuzSik({ dogru, havuz, k, karistir }) {
  const u = [...new Set(havuz)].filter((v) => v !== dogru);
  const kucuk = karistir(u.filter((v) => v < dogru)), buyuk = karistir(u.filter((v) => v > dogru));
  if (kucuk.length < k || buyuk.length < 3 - k) return null;
  return [...kucuk.slice(0, k).sort((a, b) => a - b), dogru, ...buyuk.slice(0, 3 - k).sort((a, b) => a - b)];
}
const BIR = ['', 'bir', 'iki', 'üç', 'dört', 'beş', 'altı', 'yedi', 'sekiz', 'dokuz'], ON = ['', 'on', 'yirmi', 'otuz', 'kırk', 'elli', 'altmış', 'yetmiş', 'seksen', 'doksan'];
export function sayiYaziyla(n) { // 1–9999, TDK: sözcükler ayrı yazılır
  const bin = Math.floor(n / 1000), yuz = Math.floor((n % 1000) / 100), on = Math.floor((n % 100) / 10), bir = n % 10, p = [];
  if (bin) p.push(bin === 1 ? 'bin' : `${BIR[bin]} bin`);
  if (yuz) p.push(yuz === 1 ? 'yüz' : `${BIR[yuz]} yüz`);
  if (on) p.push(ON[on]); if (bir) p.push(BIR[bir]);
  return p.join(' ');
}
export const bitisikYaz = (n) => { const s = sayiYaziyla(n).split(' '); return s.length < 3 ? s.join('') : `${s[0]}${s[1]} ${s.slice(2).join(' ')}`; };
export const sayiMetni = (n) => String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ' '); // 12 450

// Aynı şekil bir üretimde iki kez çıkmaz (yalnız başarılı eklemeler sayılır).
export function tekilEkle(ekle) { const g = new Set(); return (o) => { const a = JSON.stringify(o.spec); if (g.has(a)) throw new Error('tekrar_sekil'); const r = ekle(o); g.add(a); return r; }; }

const permler = (n) => { const o = []; const f = (a, kalan) => { if (!kalan.length) { o.push(a); return; } kalan.forEach((x, i) => f([...a, x], [...kalan.slice(0, i), ...kalan.slice(i + 1)])); }; f([], Array.from({ length: n }, (_, i) => i + 1)); return o; };

// =====================================================================================
// CÜMLE: noktalama (boş kutu) ve büyük harf (numaralı sözcük)
// =====================================================================================
export const ISARET_AD = { nokta: 'Nokta ( . )', soru: 'Soru işareti ( ? )', unlem: 'Ünlem ( ! )', virgul: 'Virgül ( , )', kesme: "Kesme işareti ( ' )", ikinokta: 'İki nokta ( : )' };
const KURAL = {
  nokta: 'bilgi veren cümlelerin sonuna konur', soru: 'soru anlamı taşıyan cümlelerin sonuna konur',
  unlem: 'sevinç, şaşkınlık ya da seslenme bildiren cümlelerin sonuna konur', virgul: 'art arda sayılan sözcükleri birbirinden ayırmak için kullanılır',
  kesme: 'özel adlarla onlara gelen ekleri ayırmak için kullanılır', ikinokta: 'sıralanacak şeylerden önce kullanılır',
};
const BU = {
  nokta: 'Bu cümle bilgi veren bir cümledir', soru: 'Bu cümle bir soru cümlesidir', unlem: 'Bu cümle duygu bildiren bir cümledir',
  virgul: 'Cümlede art arda sayılan sözcükler vardır', kesme: 'Cümledeki özel isme bir ek gelmiştir', ikinokta: 'Kutudan sonra sıralanan şeyler gelmektedir',
};
const BANKA = {
  nokta: ['Kedi sütünü içti▢', 'Annem akşam yemeği yaptı▢', 'Ben okula yürüyerek giderim▢', 'Bahçede kırmızı bir çiçek açtı▢', 'Babam bana yeni bir kitap aldı▢',
    'Kuşlar ağacın dalında ötüyor▢', 'Bugün okulda resim dersi var▢', 'Defterim masanın üstünde▢', 'Dedem bahçede fidan dikiyor▢', 'Teneffüste arkadaşlarımla top oynadık▢',
    'Kardeşim saat sekizde uyur▢', 'Balıklar akvaryumda yüzüyor▢', 'Öğretmenimiz bize hikâye okudu▢', 'Sınıfımızda yirmi öğrenci var▢', 'Nine kış için çorap örüyor▢', 'Gökyüzünde bulutlar var▢'],
  soru: ['Adın ne▢', 'Bugün okula kim geldi▢', 'Çantan nerede▢', 'Sen hangi sınıftasın▢', 'Annen nereye gitti▢', 'Kitabını kim aldı▢', 'Okula kaçta gideceksin▢', 'Bu oyuncak kimin▢',
    'Neden ağlıyorsun▢', 'Ödevini yaptın mı▢', 'Yarın bize gelir misin▢', 'Su içmek ister misin▢', 'Kaç kardeşin var▢', 'Sınıfın hangi katta▢', 'Bu kalem kimin▢', 'Yemekte ne var▢'],
  unlem: ['Ne güzel bir resim yapmışsın▢', 'Ne kadar çok kar yağmış▢', 'Ne büyük bir balık yakalamışsın▢', 'Ne tatlı bir yavru kedi▢', 'Ne kadar hızlı koşuyorsun▢', 'Ne güzel şarkı söylüyorsun▢',
    'Ne yüksek bir ağaç bu▢', 'Çok yaşa▢', 'Aferin sana▢', 'Geçmiş olsun▢', 'Hoş geldin▢', 'Güle güle▢', 'Afiyet olsun▢', 'Ne güzel bir gün▢'],
  virgul: ['Sepetimde elma▢ armut ve muz var.', 'Annem pazardan domates▢ biber ve soğan aldı.', 'Çantamda defter▢ kalem ve silgi var.', 'Bahçede gül▢ lale ve papatya açtı.', 'Ali▢ Ayşe ve Efe parka gitti.',
    'Sınıfta Ece▢ Burak ve Mina var.', 'Yazın deniz▢ güneş ve kum severiz.', 'Çiftlikte inek▢ koyun ve tavuk besliyoruz.', 'Mutfakta süt▢ yumurta ve peynir var.', 'Resimde ağaç▢ ev ve güneş çizdim.',
    'Pazar günü Zeynep▢ Mert ve Elif bize geldi.', 'Okulda Türkçe▢ matematik ve müzik dersi gördük.', 'Dolapta çorap▢ eldiven ve atkı var.', 'Kutuda kırmızı▢ sarı ve mavi boya var.'],
  kesme: ['Ayşe Ankara▢ya gitti.', 'Efe Atatürk▢ün resmini çizdi.', 'Kardeşim İzmir▢de yaşıyor.', 'Dedem Bursa▢dan geldi.', 'Zeynep Ali▢nin kalemini aldı.', 'Mert Konya▢ya bayramda gidecek.',
    'Annem Ece▢yi okuldan aldı.', 'Dün Trabzon▢da hava yağmurluydu.', 'Ahmet▢in bisikleti yeşil.', 'Elif Antalya▢dan hediye getirdi.', 'Öğretmenimiz Ayşe▢ye kitap verdi.', 'Biz Adana▢da kebap yedik.',
    'Cem Mersin▢e trenle gitti.', 'Defne Ordu▢da fındık topladı.'],
  ikinokta: ['Annem şunları aldı▢ süt, yumurta ve ekmek.', 'Sepette şu meyveler var▢ elma, armut ve muz.', 'Mevsimler dörttür▢ ilkbahar, yaz, sonbahar ve kış.', 'Bahçemde şu çiçekler var▢ gül, lale ve zambak.',
    'Çantama şunları koydum▢ defter, kalem ve silgi.', 'Yarın şunları getirin▢ boya, makas ve yapıştırıcı.', 'Pazardan şunları aldık▢ domates, biber ve patlıcan.', 'Bu hafta üç ders işledik▢ Türkçe, matematik ve fen.',
    'Ana renkler şunlardır▢ kırmızı, sarı ve mavi.', 'Sınıfta şu araçlar var▢ tahta, sıra ve masa.'],
};
// Büyük harf: tam bir sözcük kurala aykırıdır (cümle başı küçük ya da özel ad küçük). hedef 1 tabanlı.
const BUYUK = [
  [['Dün', 'ayşe', 'bize', 'geldi.'], 2, 'ad'], [['Efe', 'yarın', "izmir'e", 'gidecek.'], 3, 'ad'], [['bugün', 'hava', 'çok', 'güzel.'], 1, 'bas'], [['kardeşim', 'bahçede', 'top', 'oynuyor.'], 1, 'bas'],
  [['öğretmenimiz', 'bize', 'hikâye', 'okudu.'], 1, 'bas'], [['akşam', 'babamla', 'yürüyüşe', 'çıktık.'], 1, 'bas'], [['yarın', 'okulda', 'şenlik', 'var.'], 1, 'bas'], [['Dün', 'mert', 'parka', 'gitti.'], 2, 'ad'],
  [['Sınıfımızda', 'zeynep', 'en', 'hızlı', 'koşuyor.'], 2, 'ad'], [['Bu', 'kitabı', 'ece', 'okudu.'], 3, 'ad'], [['Teneffüste', 'cem', 'ile', 'top', 'oynadım.'], 2, 'ad'], [['Annem', "elif'e", 'bir', 'kazak', 'aldı.'], 2, 'ad'],
  [['Pazar', 'günü', 'defne', 'bize', 'gelecek.'], 3, 'ad'], [['Biz', 'bu', 'yaz', "ankara'ya", 'gideceğiz.'], 4, 'ad'], [['Benim', 'dedem', "bursa'da", 'yaşıyor.'], 3, 'ad'], [['Dün', 'annem', "konya'dan", 'geldi.'], 3, 'ad'],
  [['Yazın', "antalya'da", 'deniz', 'gördük.'], 2, 'ad'], [['Bu', 'uçak', "istanbul'a", 'iniyor.'], 3, 'ad'], [['Benim', 'babam', "trabzon'da", 'doğdu.'], 3, 'ad'], [['Biz', "atatürk'ü", 'çok', 'severiz.'], 2, 'ad'],
  [['Bizim', 'ülkemizin', 'adı', "türkiye'dir."], 4, 'ad'], [['Hafta', 'sonu', 'kaan', 'dedesine', 'gitti.'], 3, 'ad'], [['sabah', 'erkenden', 'okula', 'geldik.'], 1, 'bas'], [['Yarın', 'eylül', 'bize', 'gelecek.'], 2, 'ad'],
  [['Sevgi', 'kitabını', 'sınıfta', 'unuttu.'], 0, null], [['uçurtma', 'gökyüzünde', 'yükseliyor.'], 0, null],
].filter((x) => x[1] > 0);

const KOK_BOSLUK = ['Yukarıdaki cümlede boş bırakılan yere hangi noktalama işareti konmalıdır?', 'Şekildeki cümlede kutunun içine hangi noktalama işareti yazılmalıdır?', 'Cümledeki boş kutuya hangi noktalama işareti getirilmelidir?'];
const KOK_BUYUK = ['Şekildeki cümlede ilk harfi büyük yazılması gereken sözcüğün numarası kaçtır?', 'Yukarıdaki cümlede hangi numaralı sözcük büyük harfle başlamalıdır?'];

// cfg: { kod, konu, alt_konu, turler:[bank anahtarları], secenek:[seçenek olarak kullanılacak türler], buyuk:boolean, buyukOran }
export function cumleKur({ R, sec, karistir, ekle: ekleOrj }, cfg) {
  const ekle = tekilEkle(ekleOrj);
  function bosluk() {
    const tur = sec(cfg.turler), cumle = sec(BANKA[tur]), dogru = ISARET_AD[tur];
    const diger = karistir(cfg.secenek.filter((t) => t !== tur)).slice(0, 3);
    return ekle({ kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, zorluk: cfg.zorluk ?? 1,
      spec: { tip_id: 'b3-cumle', parametreler: { mod: 'bosluk', cumle, isaret: tur } },
      kok: sec(KOK_BOSLUK), dogru, celdirici: diger.map((t) => ISARET_AD[t]),
      gerekce: diger.map((t) => `${ISARET_AD[t]} ${KURAL[t]}; ${BU[tur].toLocaleLowerCase('tr-TR')}, bu yüzden ${dogru} gerekir.`),
      ipucu: 'Cümleyi oku; cümlenin türüne ya da kutudan sonra gelen sözcüklere bak.',
      cozum: [`${BU[tur]}.`, `${dogru} ${KURAL[tur]}.`], dogrulama: [{ yol: ['isaret'], beklenen: tur }] });
  }
  function buyukHarf() {
    const [kel, hedef, neden] = sec(BUYUK), n = kel.length;
    const diger = karistir(Array.from({ length: n }, (_, i) => i + 1).filter((i) => i !== hedef)).slice(0, 3);
    const w = (i) => kel[i - 1].replace(/\.$/, '');
    const duz = kel[hedef - 1].replace(/\.$/, ''), dogruAd = duz.charAt(0).toLocaleUpperCase('tr-TR') + duz.slice(1);
    return ekle({ kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, zorluk: cfg.zorluk ?? 1,
      spec: { tip_id: 'b3-cumle', parametreler: { mod: 'kelime', kelimeler: kel, hedef } },
      kok: sec(KOK_BUYUK), dogru: String(hedef), celdirici: diger.map(String),
      gerekce: diger.map((i) => (i === 1 ? `1. sözcük (${w(1)}) cümlenin ilk sözcüğüdür ve zaten büyük harfle başlıyor.` : `${i}. sözcük (${w(i)}) yazımı doğru olan bir sözcüktür; büyük harf gerektirmez ya da zaten büyük yazılmıştır.`)),
      ipucu: 'Cümlenin ilk sözcüğüne ve özel adlara (kişi, şehir, ülke adları) bak.',
      cozum: [neden === 'bas' ? 'Cümleler büyük harfle başlar.' : 'Özel adlar büyük harfle başlar.', `${hedef}. sözcük "${dogruAd}" biçiminde yazılmalıdır.`], dogrulama: [{ yol: ['hedef'], beklenen: hedef }, { yol: ['kelimeler', String(hedef)], beklenen: kel[hedef - 1] }] });
  }
  return { bosluk, buyukHarf, soru: () => (cfg.buyuk && R() < (cfg.buyukOran ?? 0.4) ? buyukHarf() : bosluk()) };
}

// =====================================================================================
// KART SIRALAMA: olay sırası, sözcük sırası, işlem basamakları
// =====================================================================================
export const OLAY3 = [
  ['Ayşe tohumu toprağa ekti.', 'Tohum filizlendi.', 'Filiz büyüyüp çiçek açtı.'], ['Yağmur yağdı.', 'Yerde su birikintisi oluştu.', 'Güneş çıkınca su kurudu.'],
  ['Mert tavayı ocağa koydu.', 'Mert tavaya yumurta kırdı.', 'Yumurta pişti.'], ['Zeynep kâğıdı katladı.', 'Zeynep kâğıttan kayık yaptı.', 'Kayık suda yüzdü.'],
  ['Tavuk yumurtalarının üstüne yattı.', 'Yumurtadan civciv çıktı.', 'Civciv büyüdü.'], ['Ali ekmeği kesti.', 'Ali ekmeğe peynir koydu.', 'Ali sandviçi yedi.'],
  ['Sabah güneş doğdu.', 'Öğle olunca hava ısındı.', 'Akşam güneş battı.'], ['Bulutlar toplandı.', 'Yağmur yağmaya başladı.', 'Gökyüzünde gökkuşağı belirdi.'],
  ['Baba fidanı toprağa dikti.', 'Baba fidanı suladı.', 'Fidan büyüyüp ağaç oldu.'], ['Cem kitabı raftan aldı.', 'Cem kitabı okudu.', 'Cem kitabı rafa geri koydu.'],
  ['Defne boyayı fırçaya sürdü.', 'Defne kâğıda resim yaptı.', 'Resim kuruyunca duvara asıldı.'], ['Çiftçi buğdayı ekti.', 'Buğday başak verdi.', 'Başaklar biçildi.'],
  ['Efe tahtayı çaldı.', 'Çivi tahtaya çakıldı.', 'Efe resmi çiviye astı.'], ['Elif balonu şişirdi.', 'Balon büyüdü.', 'Balon patladı.'],
];
export const OLAY4 = [
  ['Tohum toprağa ekilir.', 'Tohum su ve güneşle filizlenir.', 'Filiz büyüyerek fidan olur.', 'Fidan zamanla ağaç olur.'], ['Su ısınır.', 'Su buharlaşır.', 'Buhar bulut oluşturur.', 'Bulutlardan yağmur yağar.'],
  ['Kelebek yumurta bırakır.', 'Yumurtadan tırtıl çıkar.', 'Tırtıl koza örer.', 'Kozadan kelebek çıkar.'], ['Ali kumbarasına para attı.', 'Kumbara zamanla doldu.', 'Ali kumbarayı açtı.', 'Ali parayla yeni bir kitap aldı.'],
  ['Elif hamuru açtı.', 'Elif hamurun üstüne peynir koydu.', 'Elif tepsiyi fırına verdi.', 'Börek pişince Elif servis yaptı.'], ['Akşam olunca hava karardı.', 'Gökyüzünde yıldızlar göründü.', 'Gece boyunca herkes uyudu.', 'Sabah güneş yeniden doğdu.'],
  ['Ali kitabı seçti.', 'Ali kitabı kütüphaneden ödünç aldı.', 'Ali kitabı evde okudu.', 'Ali kitabı süresi dolmadan geri verdi.'], ['Çiftçi toprağı sürdü.', 'Çiftçi tohumu ekti.', 'Çiftçi tarlayı suladı.', 'Çiftçi ürünü topladı.'],
  ['Arı çiçekten nektar topladı.', 'Arı nektarı kovana taşıdı.', 'Arılar nektardan bal yaptı.', 'Bal petek gözlerinde saklandı.'], ['Bir kitap yazılır.', 'Kitap matbaada basılır.', 'Kitap kitapçıya dağıtılır.', 'Okuyucu kitabı satın alır.'],
  ['Pamuk tarlada yetişir.', 'Pamuk toplanır.', 'Pamuktan iplik eğrilir.', 'İplikten kumaş dokunur.'], ['Buğday öğütülür.', 'Un elde edilir.', 'Undan hamur yoğrulur.', 'Hamur fırında pişer.'],
];
const SOZ_SIRA = [
  ['Küçük', 'kedi', 'süt', 'içti.'], ['Ayşe', 'büyük', 'elmayı', 'yedi.'], ['Annem', 'sıcak', 'çorba', 'yaptı.'], ['Babam', 'yeni', 'gazeteyi', 'okudu.'], ['Kırmızı', 'balon', 'gökyüzüne', 'uçtu.'],
  ['Sarı', 'civciv', 'yemini', 'yedi.'], ['Dedem', 'eski', 'saatini', 'tamir etti.'], ['Mert', 'yeşil', 'kalemi', 'buldu.'], ['Güzel', 'kuşlar', 'dalda', 'ötüyor.'], ['Siyah', 'kedi', 'çatıya', 'çıktı.'],
  ['Öğretmen', 'tahtayı', 'sildi.'], ['Ece', 'boş', 'sınıfa', 'girdi.'], ['Bahçıvan', 'gülleri', 'suladı.'], ['Kardeşim', 'mavi', 'bisikleti', 'sürdü.'], ['Küçük', 'kuş', 'yuvasına', 'döndü.'],
  ['Zeynep', 'yeni', 'defterini', 'açtı.'],
];
export const BASAMAK4 = [
  ['Toprakta bir çukur kazın.', 'Fidanı çukura yerleştirin.', 'Çukuru toprakla doldurun.', 'Fidanı sulayın.'], ['Kâğıdı ortadan ikiye katlayın.', 'Üst köşeleri ortaya doğru katlayın.', 'Kenarları tekrar içe katlayın.', 'Kanatları açıp uçağı havaya bırakın.'],
  ['Ellerinizi ıslatın.', 'Sabunu avuçlarınıza sürün.', 'Ellerinizi ovuşturun.', 'Ellerinizi durulayıp kurulayın.'], ['Fırçanızı suya batırın.', 'Fırçaya boyayı alın.', 'Boyayı kâğıda sürün.', 'Resim kuruyana kadar bekleyin.'],
  ['Limonları sıkın.', 'Suyu bardağa koyun.', 'Şeker ekleyin.', 'Karıştırıp servis yapın.'], ['Kitabı kâğıdın üstüne koyun.', 'Kâğıdı kitabın boyuna göre kesin.', 'Kâğıdı kitabın etrafına katlayın.', 'Kenarları bantla yapıştırın.'],
  ['Fırçaya macun sıkın.', 'Dişlerinizi yukarıdan aşağıya fırçalayın.', 'Ağzınızı su ile çalkalayın.', 'Fırçanızı yıkayıp yerine koyun.'], ['Saksıya toprak doldurun.', 'Toprağa tohumu bırakın.', 'Tohumun üstünü toprakla kapatın.', 'Saksıyı sulayıp ışıklı yere koyun.'],
  ['Kâğıda bir daire çizin.', 'Daireyi makasla kesin.', 'Dairenin ortasına delik açın.', 'Deliğe ip geçirip düğüm atın.'],
];
export const KILAVUZ8 = [
  ['İlk olarak su haznesini suyla doldurun.', 'Daha sonra kapağı sıkıca kapatın.', 'Ardından fişi prize takın.', 'Son olarak düğmeyi açın.'],
  ['İlk olarak kulaklığın düğmesine basın.', 'Daha sonra telefonda bluetooth ayarını açın.', 'Ardından listeden kulaklığı seçin.', 'Son olarak bağlantı onayını bekleyin.'],
  ['İlk olarak cihazın fişini takın.', 'Daha sonra ekranın açılmasını bekleyin.', 'Ardından ölçülecek yere sensörü yerleştirin.', 'Son olarak ekrandaki değeri okuyun.'],
  ['İlk olarak belgeyi camın üstüne koyun.', 'Daha sonra kopya adedini seçin.', 'Ardından başlat düğmesine basın.', 'Son olarak kopyaları tepsiden alın.'],
  ['İlk olarak kutudan tableti çıkarın.', 'Daha sonra şarj kablosunu bağlayın.', 'Ardından açma düğmesine basılı tutun.', 'Son olarak dil seçeneğini belirleyin.'],
  ['İlk olarak ütünün fişini takın.', 'Daha sonra sıcaklık ayarını kumaşa göre seçin.', 'Ardından ütünün ısınmasını bekleyin.', 'Son olarak kumaşı ütüleyin.'],
  ['İlk olarak ürün kodunu terminale girin.', 'Daha sonra ödeme yöntemini seçin.', 'Ardından kartı cihaza yaklaştırın.', 'Son olarak fişinizi alın.'],
  ['İlk olarak kitabı kütüphane sistemine okutun.', 'Daha sonra ödünç alma tarihini kontrol edin.', 'Ardından kitabı çantanıza yerleştirin.', 'Son olarak süresi dolmadan kitabı iade edin.'],
];
const KOK_KART = {
  olay: ['Kartlardaki olaylar numaralanmıştır. Olaylar gerçekleşme sırasına göre dizilirse numaralar hangi sırayla yazılır?', 'Şekildeki numaralı kartlar olayların oluş sırasına göre dizilirse sıralama aşağıdakilerden hangisi olur?'],
  sozcuk: ['Kartlardaki sözcükler numaralanmıştır. Anlamlı ve kurallı bir cümle oluşturmak için kartlar hangi sırayla dizilmelidir?', 'Şekildeki sözcük kartları doğru sırayla dizilirse kurallı bir cümle oluşur. Kartların sırası hangisidir?'],
  basamak: ['Şekildeki kartlarda bir işin yapılış basamakları karışık verilmiştir. Basamaklar doğru sırayla dizilirse numaralar hangi sırada olur?', 'Kartlardaki işlem basamakları yapılış sırasına göre dizildiğinde numara sıralaması hangisidir?'],
};
// cfg: { kod, konu, alt_konu, tur:'olay'|'sozcuk'|'basamak', banka, duzen:'chip'|'liste', zorluk }
export function kartKur({ R, sec, karistir, ekle: ekleOrj }, cfg) {
  const ekle = tekilEkle(ekleOrj);
  function sirala() {
    const e = sec(cfg.banka), n = e.length, perm = karistir(Array.from({ length: n }, (_, i) => i)); // gösterim sırası → mantıksal indeks
    const kartlar = perm.map((li) => ({ metin: e[li], sira: li + 1 })), seq = e.map((_, li) => perm.indexOf(li) + 1);
    const dogru = seq.join(' - '), tumu = permler(n).filter((p) => p.join(' - ') !== dogru), cel = karistir(tumu).slice(0, 3);
    const gerekce = cel.map((p) => {
      let i = 0; while (p[i] === seq[i]) i += 1;
      const kart = kartlar[p[i] - 1];
      return `${p.join(' - ')} sıralamasında ${p[i]} numaralı kart (${kart.metin}) ${i + 1}. sıraya konuyor; oysa bu kart ${kart.sira}. sırada olmalıdır.`;
    });
    return ekle({ kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, zorluk: cfg.zorluk ?? 2,
      spec: { tip_id: 'b3-kartlar', parametreler: { duzen: cfg.duzen, kartlar } },
      kok: sec(KOK_KART[cfg.tur]), dogru, celdirici: cel.map((p) => p.join(' - ')), gerekce,
      ipucu: cfg.tur === 'sozcuk' ? 'Büyük harfle başlayan kart başa, noktayla biten kart sona gelir.' : cfg.tur === 'olay' ? 'Her olayın ardından hangi olayın geldiğini düşün; ilk ve son olayı bul.' : 'Önce hangi işin yapılması gerektiğini, sonra hangisinin onu izlediğini bul.',
      cozum: [cfg.tur === 'sozcuk' ? 'Cümle büyük harfle başlar ve noktayla biter.' : 'Kartlar okunur ve mantıklı sıra kurulur.', `Doğru sıra: ${seq.map((no) => `${no} (${kartlar[no - 1].metin})`).join(' → ')}.`],
      dogrulama: [{ yol: ['no_sirasi'], beklenen: seq }] });
  }
  return { sirala };
}
export { SOZ_SIRA };

// =====================================================================================
// YAZIM: numaralı cümlelerden yazımı yanlış olanı bulma
// =====================================================================================
export const YAZIM_TUR = { buyuk: 'Büyük harf kullanımı', kesme: 'Kesme işareti kullanımı', de: '"de/da" bağlacının yazımı', ki: '"ki" bağlacının yazımı', mi: '"mi" soru ekinin yazımı', birlesik: 'Bitişik ve ayrı yazılan sözcükler', soz: 'Sözcüğün doğru yazılışı', virgul: 'Virgül kullanımı' };
// [doğru, yanlış, tür, sınıf-düzeyi (3: ilkokul sade, 6, 7)]
export const YAZIM = [
  ['Ali Ankara\'ya gitti.', 'Ali Ankaraya gitti.', 'kesme', 3], ['Ayşe\'nin kalemi kırmızı.', 'Ayşenin kalemi kırmızı.', 'kesme', 3], ['Atatürk\'ü çok severiz.', 'Atatürkü çok severiz.', 'kesme', 3],
  ['Dün Ece bize geldi.', 'Dün ece bize geldi.', 'buyuk', 3], ['Mert İzmir\'de yaşıyor.', 'Mert izmir\'de yaşıyor.', 'buyuk', 3], ['Bugün okula erken gittik.', 'bugün okula erken gittik.', 'buyuk', 3],
  ['Babam İstanbul\'dan döndü.', 'Babam İstanbuldan döndü.', 'kesme', 3], ['Öğretmenimiz Zeynep\'e kitap verdi.', 'Öğretmenimiz Zeynepe kitap verdi.', 'kesme', 3],
  ['Yarın Konya\'ya gideceğiz.', 'Yarın konya\'ya gideceğiz.', 'buyuk', 3], ['Herkes sınıfa girdi.', 'Herkez sınıfa girdi.', 'soz', 3], ['Yanlış cevap verdi.', 'Yalnış cevap verdi.', 'soz', 3],
  ['Şoför yola çıktı.', 'Şöför yola çıktı.', 'soz', 3], ['Dedem Bursa\'da oturuyor.', 'Dedem Bursada oturuyor.', 'kesme', 3], ['Ben de seninle geliyorum.', 'Bende seninle geliyorum.', 'de', 6],
  ['Ali de bizimle geldi.', 'Alide bizimle geldi.', 'de', 6], ['Sen de bu oyunu oyna.', 'Senden bu oyunu oyna.', 'de', 6],
  ['Biliyorum ki sen haklısın.', 'Biliyorumki sen haklısın.', 'ki', 6], ['Bugünkü yemek çok lezzetliydi.', 'Bugün ki yemek çok lezzetliydi.', 'ki', 6], ['Evdeki kitabı getir.', 'Evde ki kitabı getir.', 'ki', 6],
  ['Sen geldin mi?', 'Sen geldinmi?', 'mi', 6], ['Yarın gelecek misin?', 'Yarın gelecekmisin?', 'mi', 6], ['Bu kitabı okudun mu?', 'Bu kitabı okudunmu?', 'mi', 6],
  ['Türkiye\'nin başkenti Ankara\'dır.', 'Türkiyenin başkenti Ankara\'dır.', 'kesme', 6], ['Fırat Nehri çok uzundur.', 'Fırat nehri çok uzundur.', 'buyuk', 6], ['Van Gölü ülkemizin en büyük gölüdür.', 'Van gölü ülkemizin en büyük gölüdür.', 'buyuk', 6],
  ['Ece\'nin çantası masada.', 'Ecenin çantası masada.', 'kesme', 6], ['Türk Dil Kurumu sözlük hazırlar.', 'Türk dil kurumu sözlük hazırlar.', 'buyuk', 6],
  ['Ali, Efe ve Mert geldi.', 'Ali Efe ve Mert geldi.', 'virgul', 6], ['Sepette elma, armut ve muz var.', 'Sepette elma armut ve muz var.', 'virgul', 6], ['Dolapta çorap, eldiven ve atkı var.', 'Dolapta çorap eldiven ve atkı var.', 'virgul', 6],
  ['Hiçbir şey almadım.', 'Hiç bir şey almadım.', 'birlesik', 7], ['Her şey yolunda gitti.', 'Herşey yolunda gitti.', 'birlesik', 7], ['Pek çok kitap okudu.', 'Pekçok kitap okudu.', 'birlesik', 7],
  ['Bir şey söylemedi.', 'Birşey söylemedi.', 'birlesik', 7], ['Her gün erken kalkar.', 'Hergün erken kalkar.', 'birlesik', 7], ['Hiçbir zaman pes etmedi.', 'Hiç bir zaman pes etmedi.', 'birlesik', 7],
  ['Yalnız kalmak istemedi.', 'Yanlız kalmak istemedi.', 'soz', 7], ['Sürpriz bir hediye aldı.', 'Süpriz bir hediye aldı.', 'soz', 7], ['Sabah egzersiz yaptık.', 'Sabah ekzersiz yaptık.', 'soz', 7],
  ['Ece Ankara\'dan geldi.', 'Ece Ankaradan geldi.', 'kesme', 3], ['Biz Antalya\'da tatil yaptık.', 'Biz Antalyada tatil yaptık.', 'kesme', 3], ['Cem Mersin\'e gitti.', 'Cem Mersine gitti.', 'kesme', 3], ['Elif Ordu\'dan döndü.', 'Elif Ordudan döndü.', 'kesme', 3],
  ['Ayşe ile Efe parka gitti.', 'ayşe ile Efe parka gitti.', 'buyuk', 3], ['Biz Türkiye\'de yaşıyoruz.', 'Biz türkiye\'de yaşıyoruz.', 'buyuk', 3], ['Ali ve Mert top oynadı.', 'Ali ve mert top oynadı.', 'buyuk', 3], ['Yarın okula gideceğiz.', 'yarın okula gideceğiz.', 'buyuk', 3],
  ['Defne kitabını okudu.', 'defne kitabını okudu.', 'buyuk', 3], ['Ahmet Bursa\'ya gitti.', 'Ahmet bursa\'ya gitti.', 'buyuk', 3], ['Kitabı yalnız okudum.', 'Kitabı yanlız okudum.', 'soz', 3], ['Sınıfta herkes sustu.', 'Sınıfta herkez sustu.', 'soz', 3],
  ['Herkesin görüşü önemlidir.', 'Herkezin görüşü önemlidir.', 'soz', 7], ['Çocuklar parkta koşuyor, oynuyor ve gülüyordu.', 'Çocuklar parkta koşuyor oynuyor ve gülüyordu.', 'virgul', 7],
  ['Hem çalıştı hem de başardı.', 'Hem çalıştı hemde başardı.', 'de', 7], ['Atatürk 1881\'de doğdu.', 'atatürk 1881\'de doğdu.', 'buyuk', 7], ['Sınıfta hiç kimse yoktu.', 'Sınıfta hiçkimse yoktu.', 'birlesik', 7],
];
const KOK_YAZIM = ['Şekildeki numaralı cümlelerden hangisinde yazım yanlışı vardır?', 'Aşağıda numaralanmış cümlelerden biri yazım ya da noktalama bakımından yanlıştır. Bu cümlenin numarası kaçtır?'];
const KOK_YAZIM_TUR = 'Şekildeki numaralı cümlelerden birinde yazım yanlışı vardır. Bu yanlış aşağıdakilerden hangisiyle ilgilidir?';
// cfg: { kod, konu, alt_konu, siniflar:[3,6,7] (bankada kabul edilen düzeyler), tur:boolean (neden sorusu da sorulur) }
export function yazimKur({ R, sec, karistir, ekle: ekleOrj, konum }, cfg) {
  const ekle = tekilEkle(ekleOrj);
  const havuz = YAZIM.filter((x) => cfg.siniflar.includes(x[3]));
  function yazim() {
    const k = konum(), [d, y, tur] = sec(havuz);
    const baskalari = karistir(havuz.filter((x) => x[0] !== d && x[1] !== y && x[0] !== y)); const secili = [];
    for (const x of baskalari) { if (secili.length < 3 && !secili.some((s) => s[0] === x[0])) secili.push(x); }
    const ogeler = secili.map((x) => x[0]); ogeler.splice(k, 0, y);
    const spec = { tip_id: 'b3-numarali', parametreler: { baslik: 'Cümleler', ogeler } };
    const ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec, zorluk: cfg.zorluk ?? 2 };
    const olgu = [{ yol: ['ogeler', String(k + 1)], beklenen: y }];
    if (cfg.tur && R() < 0.4) {
      const turlar = [...new Set(havuz.map((x) => x[2]))].filter((t) => t !== tur), cel = karistir(turlar).slice(0, 3);
      if (cel.length < 3) throw new Error('tur_az');
      return ekle({ ...ortak, kok: KOK_YAZIM_TUR, dogru: YAZIM_TUR[tur], celdirici: cel.map((t) => YAZIM_TUR[t]),
        gerekce: cel.map((t) => `Yanlış yazılmış cümlede ${YAZIM_TUR[t].toLocaleLowerCase('tr-TR')} ile ilgili bir hata yoktur; hata ${YAZIM_TUR[tur].toLocaleLowerCase('tr-TR')} ile ilgilidir.`),
        ipucu: 'Önce yanlış cümleyi bul, sonra doğru yazılışıyla karşılaştır.', cozum: [`${k + 1}. cümle yanlıştır: "${y}"`, `Doğrusu "${d}" biçimindedir; hata ${YAZIM_TUR[tur].toLocaleLowerCase('tr-TR')} ile ilgilidir.`], dogrulama: olgu });
    }
    return ekle({ ...ortak, kok: sec(KOK_YAZIM), sirali: ['1', '2', '3', '4'], dogru: String(k + 1),
      gerekce: ['1', '2', '3', '4'].map((no, i) => (i === k ? '' : `${no}. cümle yazım ve noktalama bakımından doğrudur.`)),
      ipucu: 'Her cümleyi sırayla oku; ek, kesme işareti, büyük harf ve sözcük yazılışlarını kontrol et.', cozum: [`${k + 1}. cümle yanlıştır: "${y}"`, `Doğrusu "${d}" biçimindedir.`], dogrulama: olgu });
  }
  return { yazim };
}

// =====================================================================================
// ŞİİR: kıta, dize, son sözcük, uyak düzeni
// =====================================================================================
// Her çift 8 heceli, aynı son üç harfle biter (uyak). t: tema.
export const COUPLET = [
  { t: 'doga', a: 'Güneş doğdu dağ başında', b: 'Kuşlar şakır ağacında', key: 'nda' }, { t: 'doga', a: 'Rüzgârla yapraklar uçar', b: 'Kış gelmeden kuşlar kaçar', key: 'çar' },
  { t: 'doga', a: 'Kış gelince kar yağıyor', b: 'Çocuklar kayak yapıyor', key: 'yor' }, { t: 'doga', a: 'Dallarda ilk çiçek açar', b: 'Bahar bize neşe saçar', key: 'çar' },
  { t: 'doga', a: 'Tatilde dağa çıkarız', b: 'Gece ateşi yakarız', key: 'rız' }, { t: 'doga', a: 'Ağaçlar yeşil giyindi', b: 'Kırlar çiçekle süslendi', key: 'ndi' },
  { t: 'cocuk', a: 'Kitap okumak çok güzel', b: 'Her kitap bize çok özel', key: 'zel' }, { t: 'cocuk', a: 'Annem masalı okuyor', b: 'Sesi kulakta doluyor', key: 'yor' },
  { t: 'cocuk', a: 'Teneffüs zili çalınca', b: 'Herkes bahçeye çıkınca', key: 'nca' }, { t: 'cocuk', a: 'Gece gökte yıldız parlar', b: 'Uykuya dalar çocuklar', key: 'lar' },
];
const SEMA = { aabb: [0, 1, 2, 3], abab: [0, 2, 1, 3], abba: [0, 2, 3, 1] }; // [A1,A2,B1,B2] -> dizilişe indeks
const dizelerDuz = (ks) => ks.flat();
function kitaYap(c1, c2, sema) { const h = [c1.a, c1.b, c2.a, c2.b]; return SEMA[sema].map((i) => h[i]); }
const SEMA_SATIR = { aabb: 'aabb', abab: 'abab', abba: 'abba' };
const sonSoz = (d) => d.replace(/[.,;:!?…]+$/u, '').split(' ').pop();
function siirUret({ sec, karistir }, { sema, kitaSayisi, boyut }) {
  const tema = sec(['doga', 'cocuk']), havuz = karistir(COUPLET.filter((c) => c.t === tema));
  let kitalar;
  if (boyut === 2) { kitalar = havuz.slice(0, kitaSayisi).map((c) => [c.a, c.b]); if (kitalar.length < kitaSayisi) throw new Error('cift_yok'); }
  else {
    kitalar = []; const kalan = [...havuz];
    for (let i = 0; i < kitaSayisi; i++) {
      const c1 = kalan.shift(); const j = kalan.findIndex((c) => c.key !== c1?.key);
      if (!c1 || j < 0) throw new Error('cift_yok');
      const [c2] = kalan.splice(j, 1); kitalar.push(kitaYap(c1, c2, sema));
    }
  }
  return kitalar;
}
const KOK_SIIR = {
  kita: ['Şekildeki şiir kaç kıtadan oluşmaktadır?', 'Yukarıdaki şiirde kaç kıta vardır?'],
  dize: ['Şekildeki şiir toplam kaç dizeden (mısradan) oluşmaktadır?', 'Yukarıdaki şiirde toplam kaç dize vardır?'],
  kitadize: ['Şekildeki şiirin her kıtası kaç dizeden oluşmaktadır?', 'Yukarıdaki şiirde bir kıta kaç dizeden oluşur?'],
};
// cfg: { kod, konu, alt_konu, sorular:[tür...] ('kita','dize','kitadize','son','sema','uyakli') }
export function siirKur(ctx, cfg) {
  const { R, sec, karistir, konum } = ctx, ekle = tekilEkle(ctx.ekle);
  function siir() {
    const tur = sec(cfg.sorular), k = konum();
    const sema = tur === 'sema' || tur === 'uyakli' ? sec(['aabb', 'abab', 'abba']) : sec(['aabb', 'abab']);
    const boyut = tur === 'sema' || tur === 'uyakli' ? 4 : sec([2, 4]);
    const kitaSayisi = sec(boyut === 2 ? [3, 4, 5] : [2, 3]);
    const kitalar = siirUret(ctx, { sema, kitaSayisi, boyut });
    const spec = { tip_id: 'b3-siir', parametreler: { kitalar } };
    const ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec, zorluk: cfg.zorluk ?? 2 };
    const dz = dizelerDuz(kitalar), toplam = dz.length;
    if (tur === 'kita') {
      const s = pencere(kitaSayisi, k, 1); if (!s) throw new Error('pencere');
      return ekle({ ...ortak, kok: sec(KOK_SIIR.kita), sirali: s.map(String), dogru: String(kitaSayisi), gerekce: s.map((v) => `Şiirde ${v} kıta yoktur; kıtalar boşluklarla ayrılmış bölümlerdir.`),
        ipucu: 'Kıta, şiirde boşluklarla ayrılmış bölümdür; bölümleri say.', cozum: ['Şiirdeki boşluklarla ayrılmış bölümler sayılır.', `${kitaSayisi} bölüm (kıta) vardır.`], dogrulama: [{ yol: ['kita_sayisi'], beklenen: kitaSayisi }] });
    }
    if (tur === 'dize') {
      const s = pencere(toplam, k, 2); if (!s) throw new Error('pencere');
      return ekle({ ...ortak, kok: sec(KOK_SIIR.dize), sirali: s.map(String), dogru: String(toplam), gerekce: s.map((v) => `Şiirin dize sayısı ${v} değildir; her satır bir dizedir ve satırlar sayılır.`),
        ipucu: 'Dize (mısra) şiirin her bir satırıdır; bütün satırları say.', cozum: ['Şiirin bütün satırları kıtalar ayırt edilmeden sayılır.', `Toplam ${toplam} dize vardır.`], dogrulama: [{ yol: ['dize_sayisi'], beklenen: toplam }] });
    }
    if (tur === 'kitadize') {
      const d = boyut, s = pencere(d, k, 1); if (!s) throw new Error('pencere');
      return ekle({ ...ortak, kok: sec(KOK_SIIR.kitadize), sirali: s.map(String), dogru: String(d), gerekce: s.map((v) => `Her kıtada ${v} dize yoktur; bir kıtadaki satırlar sayılmalıdır.`),
        ipucu: 'Bir kıtayı seç ve yalnız o kıtanın satırlarını say.', cozum: ['Bir kıtadaki satırlar sayılır.', `Her kıtada ${d} dize vardır.`], dogrulama: [{ yol: ['kita_dize'], beklenen: kitalar.map((x) => x.length) }] });
    }
    if (tur === 'son') {
      const ki = Math.floor(R() * kitaSayisi), di = Math.floor(R() * boyut), dogru = sonSoz(kitalar[ki][di]);
      const diger = karistir([...new Set(dz.map(sonSoz))].filter((w) => w !== dogru)).slice(0, 3); if (diger.length < 3) throw new Error('sozcuk_az');
      const ad = `${ki + 1}. kıtanın ${di + 1}. dizesinin`;
      return ekle({ ...ortak, kok: `Şekildeki şiirde ${ad} son sözcüğü hangisidir?`, dogru, celdirici: diger,
        gerekce: diger.map((w) => `"${w}", şiirin başka bir dizesinin son sözcüğüdür; sorulan dize değildir.`),
        ipucu: 'Önce kıtayı, sonra o kıtadaki dizeyi bul; dizenin en sağdaki sözcüğüne bak.', cozum: [`${ki + 1}. kıtanın ${di + 1}. dizesi bulunur.`, `Bu dizenin son sözcüğü "${dogru}" sözcüğüdür.`], dogrulama: [{ yol: ['son_sozcuk', `${ki + 1}.${di + 1}`], beklenen: dogru }] });
    }
    if (tur === 'sema') {
      const dogru = SEMA_SATIR[sema], cel = karistir(['aabb', 'abab', 'abba', 'abcd'].filter((x) => x !== dogru)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 3, kok: 'Şekildeki şiirin kıtalarında uyak (kafiye) düzeni aşağıdakilerden hangisidir?', dogru, celdirici: cel,
        gerekce: cel.map((c) => (c === 'abcd' ? 'abcd düzeninde hiçbir dize başka bir dizeyle uyaklanmaz; bu şiirde ise uyaklı dizeler vardır.' : `Dizelerin uyakları ${c} düzenine uymaz; şiirdeki düzen ${dogru} biçimindedir.`)),
        ipucu: 'Kıtanın dizelerinin son seslerine bak; aynı sesle bitenlere aynı harfi ver.', cozum: ['Her dizenin son sesleri karşılaştırılır.', `Uyaklı dizeler ${dogru} düzenindedir.`], dogrulama: [{ yol: ['sema'], beklenen: dogru }] });
    }
    // uyakli: 1. dizeyle uyaklı olan dize (ilk kıtadan, son sözcük)
    const kt = kitalar[0], idx = sema === 'aabb' ? 1 : sema === 'abab' ? 2 : 3, dogru = sonSoz(kt[idx]);
    const diger = karistir(kt.map((d, i) => [d, i]).filter(([, i]) => i !== idx && i !== 0).map(([d]) => sonSoz(d)).concat(sonSoz(kitalar[1][0]))).slice(0, 3);
    return ekle({ ...ortak, zorluk: 3, kok: 'Şekildeki şiirin ilk kıtasında 1. dizeyle uyaklı olan dizenin son sözcüğü hangisidir?', dogru, celdirici: diger,
      gerekce: diger.map((w) => `"${w}" sözcüğü ilk dizenin sonuyla aynı sesle bitmez; uyak oluşturmaz.`),
      ipucu: '1. dizenin son sözcüğünün son seslerini diğer dizelerin sonlarıyla karşılaştır.', cozum: ['1. dizenin son sesleri belirlenir.', `Aynı sesle biten dize "${dogru}" sözcüğüyle biter.`], dogrulama: [{ yol: ['son_sozcuk', `1.${idx + 1}`], beklenen: dogru }] });
  }
  return { siir };
}
export { sonSoz };

// =====================================================================================
// SÜTUN GRAFİĞİ: okuma ve yorumlama (mevcut 'sutun-grafigi' tipi)
// =====================================================================================
// cfg: { kod, konu, alt_konu, temalar:[{baslik, ad:[..]}], olcekler:[{max,adim}], turler, n:[4,5] }
export function sutunKur({ R, sec, karistir, ekle: ekleOrj, konum }, cfg) {
  const ekle = tekilEkle(ekleOrj);
  function grafik() {
    const t = sec(cfg.temalar), e = sec(cfg.olcekler), yarim = e.adim / 2, n = sec(cfg.n ?? [4, 5]), k = konum();
    const adlar = karistir(t.ad).slice(0, n), adet = Math.floor(e.max / yarim), kume = new Set(); let g = 0;
    while (kume.size < n && g++ < 300) kume.add((1 + Math.floor(R() * (adet - 1))) * yarim);
    if (kume.size < n) throw new Error('deger_cesitliligi_yok');
    const kategoriler = adlar.map((ad, i) => ({ ad, deger: [...kume][i] })), v = Object.fromEntries(kategoriler.map((c) => [c.ad, c.deger]));
    const sirali = [...kategoriler].sort((a, b) => b.deger - a.deger), toplam = kategoriler.reduce((s, c) => s + c.deger, 0);
    const spec = { tip_id: 'sutun-grafigi', parametreler: { baslik: t.baslik, kategoriler, max: e.max, adim: e.adim } };
    const ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec }, ek = cfg.birim ?? '';
    const tur = sec(cfg.turler ?? ['en_cok', 'en_az', 'oku', 'fark', 'toplam']), gb = `Yukarıdaki grafik "${t.baslik}" bilgisini göstermektedir.`;
    if (tur === 'en_cok' || tur === 'en_az') {
      const hedef = tur === 'en_cok' ? sirali[0] : sirali[n - 1];
      const ayni = kategoriler.filter((c) => c.deger === hedef.deger).length; if (ayni !== 1) throw new Error('es_deger');
      const cel = karistir(kategoriler.filter((c) => c !== hedef)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 1, kok: `${gb} Buna göre değeri en ${tur === 'en_cok' ? 'büyük' : 'küçük'} olan hangisidir?`, dogru: hedef.ad, celdirici: cel.map((c) => c.ad),
        gerekce: cel.map((c) => `${c.ad} sütununun değeri ${c.deger}; en ${tur === 'en_cok' ? 'yüksek' : 'kısa'} sütun değildir.`), ipucu: `En ${tur === 'en_cok' ? 'yüksek' : 'kısa'} sütunu bul.`,
        cozum: ['Sütunların yükseklikleri karşılaştırılır.', `En ${tur === 'en_cok' ? 'yüksek' : 'kısa'} sütun ${hedef.ad} sütunudur.`], dogrulama: [{ yol: [tur], beklenen: hedef.ad }] });
    }
    if (tur === 'oku') {
      const X = sec(adlar), c = v[X], start = c - k * e.adim; if (start < 0) throw new Error('pencere_negatif');
      const sk = [0, 1, 2, 3].map((i) => start + i * e.adim);
      return ekle({ ...ortak, zorluk: 1, sirali: sk.map(String), dogru: String(c), gerekce: sk.map((x) => (x === c ? '' : `${x}, ${X} sütununun ${Math.abs(x - c) / e.adim} çizgi ${x > c ? 'üstündeki' : 'altındaki'} değerdir.`)),
        kok: `${gb} Buna göre ${X} değeri kaçtır?`, ipucu: `${X} sütununun üst ucunun hangi çizgiyle aynı hizada olduğuna bak.`, cozum: [`${X} sütununun yüksekliği dikey eksenden okunur.`, `Üst uç ${c} değerindedir.`], dogrulama: [{ yol: ['degerler', X], beklenen: c }] });
    }
    if (tur === 'fark') {
      const [A, B] = karistir(kategoriler).slice(0, 2), D = Math.abs(A.deger - B.deger); if (D === 0) throw new Error('fark_sifir');
      const start = D - k * e.adim; if (start < yarim) throw new Error('pencere_negatif');
      const sk = [0, 1, 2, 3].map((i) => start + i * e.adim), buyuk = A.deger > B.deger ? A : B, kucuk = buyuk === A ? B : A;
      return ekle({ ...ortak, zorluk: 2, sirali: sk.map(String), dogru: String(D), gerekce: sk.map((x) => (x === D ? '' : `${x}, ${A.ad} ile ${B.ad} arasındaki farkın ${Math.abs(x - D) / e.adim} çizgi ${x > D ? 'fazlasıdır' : 'eksiğidir'}.`)),
        kok: `${gb} Buna göre ${A.ad} ile ${B.ad} arasındaki fark kaçtır?`, ipucu: 'İki sütunun değerini okuyup büyükten küçüğü çıkar.', cozum: [`${A.ad} = ${A.deger}, ${B.ad} = ${B.deger} olarak okunur.`, `${buyuk.deger} − ${kucuk.deger} = ${D}.`], dogrulama: [{ yol: ['degerler', A.ad], beklenen: A.deger }, { yol: ['degerler', B.ad], beklenen: B.deger }] });
    }
    if (tur === 'toplam') {
      const start = toplam - k * e.adim; if (start < yarim) throw new Error('pencere_negatif');
      const sk = [0, 1, 2, 3].map((i) => start + i * e.adim);
      return ekle({ ...ortak, zorluk: 2, sirali: sk.map(String), dogru: String(toplam), gerekce: sk.map((x) => (x === toplam ? '' : `${x}, sütun değerlerinin toplamı değildir; toplam ${toplam} olur.`)),
        kok: `${gb} Buna göre bütün sütunların değerlerinin toplamı kaçtır?`, ipucu: 'Her sütunun değerini oku ve hepsini topla.', cozum: [`Değerler: ${kategoriler.map((c) => c.deger).join(' + ')}.`, `Toplam ${toplam} olur.`], dogrulama: [{ yol: ['toplam'], beklenen: toplam }] });
    }
    if (tur === 'ikinci') {
      const hedef = sirali[1]; if (new Set(kategoriler.map((c) => c.deger)).size !== n) throw new Error('es_deger');
      const cel = karistir(kategoriler.filter((c) => c !== hedef)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 2, kok: `${gb} Buna göre değeri en büyük ikinci olan hangisidir?`, dogru: hedef.ad, celdirici: cel.map((c) => c.ad),
        gerekce: cel.map((c) => `${c.ad} sütununun değeri ${c.deger}; sıralamada ikinci değildir.`), ipucu: 'Değerleri büyükten küçüğe sırala.', cozum: ['Değerler büyükten küçüğe sıralanır.', `İkinci sırada ${hedef.ad} (${hedef.deger}) vardır.`], dogrulama: [{ yol: ['degerler', hedef.ad], beklenen: hedef.deger }] });
    }
    // ortalama (kaç katı için tam bölünme gerekir): yalnız toplam n'ye tam bölünüyorsa
    if (toplam % n !== 0) throw new Error('ortalama_tam_degil');
    const o = toplam / n, start = o - k; if (start < 1) throw new Error('pencere_negatif');
    const sk = [0, 1, 2, 3].map((i) => start + i);
    return ekle({ ...ortak, zorluk: 3, sirali: sk.map(String), dogru: String(o), gerekce: sk.map((x) => (x === o ? '' : `${x}, değerlerin aritmetik ortalaması değildir; ortalama ${o} olur.`)),
      kok: `${gb} Buna göre sütun değerlerinin aritmetik ortalaması kaçtır?`, ipucu: 'Önce değerlerin toplamını bul, sonra sütun sayısına böl.', cozum: [`Toplam ${toplam}, sütun sayısı ${n}.`, `${toplam} ÷ ${n} = ${o}.`], dogrulama: [{ yol: ['toplam'], beklenen: toplam }] });
  }
  return { grafik };
}

// =====================================================================================
// VURGULU METİN: koyu, altı çizili, çerçeveli ifadeler
// =====================================================================================
// Köşeli parantez aday ifadedir; üçü rastgele biçimlenir, kalanı düz bırakılır.
export const VURGU4 = [
  ['Arılar', ['Arılar [çiçeklerden nektar] toplar.', 'Nektarı [petek gözlerine] taşırlar.', 'Orada nektardan [bal] yapılır.', 'Bal, [sağlıklı beslenmek] için önemlidir.']],
  ['Su', ['Su, canlıların [yaşaması] için gerekir.', 'Musluğu [gereksiz yere] açık bırakmayalım.', 'Her damla suyu [tasarruflu] kullanalım.', 'Çünkü su [kaynakları] sınırlıdır.']],
  ['Kitap', ['Kitap okumak [kelime hazinemizi] artırır.', 'Her gün [yirmi dakika] okuyabiliriz.', 'Okuduğumuz kitabı [arkadaşlarımıza] anlatalım.', 'Kitaplar [en iyi dostumuzdur].']],
  ['Ağaçlar', ['Ağaçlar havayı [temizler].', 'Gölgeleriyle bizi [güneşten] korur.', 'Kuşlara [yuva] olurlar.', 'Bu yüzden her yıl [fidan dikmeliyiz].']],
  ['Spor', ['Düzenli spor [bedenimizi] güçlendirir.', 'Haftada [üç gün] yürüyüş yapabiliriz.', 'Spordan önce [ısınma hareketleri] yapmalıyız.', 'Bol su içmeyi [unutmayalım].']],
  ['Trafik', ['Yayalar [yaya geçidinden] geçmelidir.', 'Yeşil ışık yanınca [karşıya] geçeriz.', 'Araçlar kırmızıda [durmak zorundadır].', 'Kurallara uymak [hepimizin] görevidir.']],
];
export const VURGU8 = [
  ['Yenilenebilir Enerji', ['[Yenilenebilir enerji] kaynakları tükenmez.', 'Güneş ve rüzgâr [çevreyi kirletmeyen] kaynaklardır.', 'Ülkemiz [güneş enerjisi] bakımından zengindir.', 'Bu enerjiler [uzun vadede] ekonomiye katkı sağlar.', 'Bu nedenle [yatırımlar] artırılmalıdır.']],
  ['Okumanın Önemi', ['Okumak, [düşünme becerisini] geliştirir.', 'Düzenli okuyan kişinin [söz varlığı] zenginleşir.', 'Okuma alışkanlığı [küçük yaşta] kazanılır.', 'Bu alışkanlık [ömür boyu] sürer.', 'Aileler çocuklarına [örnek olmalıdır].']],
  ['Dijital Okuryazarlık', ['İnternette her bilgi [doğru değildir].', 'Bilgiyi kullanmadan önce [kaynağını] kontrol etmeliyiz.', 'Aynı konuyu [birden fazla kaynaktan] araştırmak gerekir.', 'Kişisel bilgilerimizi [kimseyle paylaşmamalıyız].']],
  ['Su Kaynakları', ['Dünyadaki suyun [çok az bir kısmı] tatlı sudur.', 'Tatlı suyun büyük kısmı [buzullarda] bulunur.', 'İçilebilir su kaynakları [her geçen gün] azalmaktadır.', 'Bu yüzden suyu [bilinçli kullanmalıyız].']],
  ['Sağlıklı Uyku', ['Çocukların [düzenli uykuya] ihtiyacı vardır.', 'Yetersiz uyku [dikkati] azaltır.', 'Uyumadan önce [ekran kullanımını] sınırlamak gerekir.', 'Odanın [sessiz ve karanlık] olması uykuyu kolaylaştırır.']],
];
const STIL_AD = { koyu: 'koyu yazılmış', alt: 'altı çizili', cerceve: 'çerçeve içine alınmış' };
// cfg: { kod, konu, alt_konu, metinler, zorluk }
export function vurguluKur({ sec, karistir, ekle: ekleOrj }, cfg) {
  const ekle = tekilEkle(ekleOrj);
  function vurgu() {
    const [baslik, ham] = sec(cfg.metinler), tum = []; const aday = [];
    for (const l of ham) for (const m of l.matchAll(/\[([^\]]+)\]/g)) aday.push(m[1]);
    const stiller = karistir(['koyu', 'alt', 'cerceve']), secili = karistir(aday).slice(0, 3), atama = Object.fromEntries(secili.map((a, i) => [a, stiller[i]]));
    const satirlar = ham.map((l) => l.split(/(\[[^\]]+\])/).filter(Boolean).map((p) => (p.startsWith('[') ? { t: p.slice(1, -1), s: atama[p.slice(1, -1)] } : { t: p })));
    void tum;
    const spec = { tip_id: 'b3-vurgulu', parametreler: { baslik, satirlar } }, ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec, zorluk: cfg.zorluk ?? 2 };
    const duz = aday.filter((a) => !atama[a]);
    if (R_(sec) < 0.25 && duz.length) {
      const dogru = sec(duz);
      return ekle({ ...ortak, kok: 'Yukarıdaki metinde aşağıdaki ifadelerden hangisi herhangi bir biçimde vurgulanmamıştır?', dogru, celdirici: secili,
        gerekce: secili.map((c) => `"${c}" ifadesi metinde ${STIL_AD[atama[c]]} biçimde vurgulanmıştır.`),
        ipucu: 'Her ifadenin metinde koyu, altı çizili ya da çerçeveli olup olmadığına bak.', cozum: ['Üç ifade farklı biçimlerde vurgulanmıştır.', `"${dogru}" ifadesi düz yazılmıştır.`], dogrulama: [{ yol: ['stil', 'koyu'], beklenen: secili.filter((c) => atama[c] === 'koyu') }, { yol: ['stil', 'alt'], beklenen: secili.filter((c) => atama[c] === 'alt') }, { yol: ['stil', 'cerceve'], beklenen: secili.filter((c) => atama[c] === 'cerceve') }] });
    }
    const hedef = sec(secili), stil = atama[hedef], digerler = karistir(aday.filter((a) => a !== hedef)).slice(0, 3);
    return ekle({ ...ortak, kok: `Yukarıdaki metinde ${STIL_AD[stil]} ifade hangisidir?`, dogru: hedef, celdirici: digerler,
      gerekce: digerler.map((c) => (atama[c] ? `"${c}" ifadesi ${STIL_AD[atama[c]]} biçimdedir; hedef değildir.` : `"${c}" ifadesi metinde herhangi bir biçimde vurgulanmamıştır.`)),
      ipucu: stil === 'koyu' ? 'Kalın (koyu) harflerle yazılmış ifadeyi ara.' : stil === 'alt' ? 'Altında çizgi bulunan ifadeyi ara.' : 'Dikdörtgen çerçevenin içine alınmış ifadeyi ara.',
      cozum: ['Metindeki vurgulu ifadeler incelenir.', `"${hedef}" ifadesi ${STIL_AD[stil]} biçimdedir.`],
      dogrulama: [{ yol: ['stil', stil], beklenen: [hedef] }] });
  }
  return { vurgu };
}
const R_ = (sec) => sec([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]); // sec() ile [0,1) dağılımlı sayı