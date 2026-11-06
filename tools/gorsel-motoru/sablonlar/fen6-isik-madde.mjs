// 6. sınıf Fen Bilimleri — ışığın yansıması (FB.6.4.2, iki şablon); devrede ampul parlaklığı (FB.6.6.2); yoğunluk hesabı (FB.6.5.3); erime/kaynama noktası grafiği (FB.6.5.2).
// Not: kazanim_6_fen.json içindeki program_surumu alanı "5. sınıf DÖP" yazıyor; kural gereği kaynak dosyadaki değer aynen kullanıldı.
import { sayiSik } from '../tipler-b2.mjs';
const MUFREDAT = 'Maarif Modeli 5. sınıf DÖP (FB)';
const HARF = ['K', 'L', 'M', 'N'];

// ---- yansıma ----
export function kurYansimaAday({ R, sec, karistir, ekle, konum }) {
  function adaySorusu() {
    const k = konum(), th = sec([25, 30, 35, 40, 45, 50, 55, 60, 65]);
    const havuz = karistir([90 - th, th + 15, th - 15, th + 25, th - 25, th + 35, th - 30].filter((a) => a !== th && a >= 8 && a <= 78));
    const secilen = [];
    for (const a of havuz) if (secilen.length < 3 && [th, ...secilen].every((b) => Math.abs(b - a) >= 12)) secilen.push(a);
    if (secilen.length < 3) throw new Error('aday_yetersiz');
    const acilar = [...secilen]; acilar.splice(k, 0, th);
    ekle({ kod: 'FB.6.4.2', konu: 'Işık', alt_konu: 'Yansıma kanunu: gelen açı ve yansıma açısı', zorluk: 2,
      spec: { tip_id: 'b2-yansima', parametreler: { mod: 'aday', gelen: th, adaylar: acilar.map((aci, i) => ({ ad: HARF[i], aci })) } }, sirali: HARF, dogru: HARF[k],
      kok: sec(['Şekilde düz bir aynaya gelen ışın ve aynadan çıkabilecek K, L, M, N ışınları gösterilmiştir. Yansıma kanununa göre yansıyan ışın hangisidir?', 'Düz aynaya şekildeki gibi bir ışık ışını gelmektedir. Bu ışının yansıdıktan sonra izleyeceği yol hangi harfle gösterilen ışındır?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : acilar[i] === 90 - th ? `${h} ışını normalle ${acilar[i]}° yapar; bu açı ışının aynanın yüzeyiyle yaptığı açıdır. Yansıma açısı, yüzeyle değil normalle ölçülür ve gelen açıya (${th}°) eşit olmalıdır.` : `${h} ışını normalle ${acilar[i]}° yapar; yansıma açısı gelen açıya eşit (${th}°) olmalıdır.`)),
      ipucu: 'Yansıma açısı, yansıyan ışın ile normal arasındaki açıdır ve gelen açıya eşittir.',
      cozum: ['Yansımada gelen açı ile yansıma açısı eşittir; iki açı da normalden ölçülür.', `Gelen açı ${th}° olduğundan yansıyan ışın, normalle ${th}° yapan ${HARF[k]} ışınıdır.`],
      dogrulama: [{ yol: ['yansiyan'], beklenen: HARF[k] }] });
  }
  return { adaySorusu };
}
export function kurYansimaAci({ R, sec, ekle, konum }) {
  function aciSorusu() {
    const k = konum(), th = sec([20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70]), x = 90 - th;
    const s = sayiSik(th, k, R, { min: 5, max: 85, adim: 5, tercih: [x, Math.min(2 * th, 85), 2 * x] });
    ekle({ kod: 'FB.6.4.2', konu: 'Işık', alt_konu: 'Yansıma açısını bulma', zorluk: 3,
      spec: { tip_id: 'b2-yansima', parametreler: { mod: 'aci', gelen: th } }, sirali: s.sirali.map((v) => `${v}°`), dogru: `${th}°`,
      kok: sec(['Şekilde düz bir aynaya gelen ışının ayna yüzeyi ile yaptığı açı gösterilmiştir. Bu ışının yansıma açısı kaç derecedir?', 'Düz aynaya gelen bir ışının, ayna yüzeyiyle yaptığı açı şekilde verilmiştir. Yansıma açısı kaç derece olur?']),
      gerekce: s.degerler.map((v) => (v === th ? '' : v === x ? `${v}°, ışının ayna yüzeyiyle yaptığı açıdır; yansıma açısı normalden ölçülür.` : v === 2 * th ? `${v}°, gelen açı ile yansıma açısının toplamıdır; yansıma açısı tek başına gelen açıya eşittir.` : `${v}° yanlıştır; önce normal ile gelen ışın arasındaki açı (90° − ${x}° = ${th}°) bulunmalı, yansıma açısı ona eşit alınmalıdır.`)),
      ipucu: 'Normal, yüzeye diktir. Gelen açıyı normalden ölçmek için yüzeyle yapılan açıyı 90°’den çıkar.',
      cozum: [`Gelen ışının yüzeyle yaptığı açı ${x}°; normal yüzeye dik olduğundan gelen açı 90° − ${x}° = ${th}°’dir.`, `Yansıma açısı gelen açıya eşittir: ${th}°.`],
      dogrulama: [{ yol: ['yansima'], beklenen: th }, { yol: ['yuzeyle_aci'], beklenen: x }] });
  }
  return { aciSorusu };
}

// ---- ampul parlaklığı ----
const COMBO = [[1, 1], [2, 1], [3, 1], [2, 2], [3, 2], [1, 2]];
const oran = ([p, a]) => Math.round((p / a) * 10) / 10;
export function kurParlaklik({ R, sec, karistir, ekle, konum }) {
  function parlaklikSorusu() {
    const k = konum(), parlak = R() < 0.5;
    const oranlar = karistir([0.5, 1, 1.5, 2, 3]).slice(0, 4), sirali = [...oranlar].sort((a, b) => a - b);
    const hedef = parlak ? sirali[3] : sirali[0], dig = oranlar.filter((o) => o !== hedef);
    const sira = [...dig]; sira.splice(k, 0, hedef);
    const paneller = sira.map((o, i) => { const [pil, ampul] = sec(COMBO.filter((c) => oran(c) === o)); return { ad: HARF[i], pil, ampul, anahtar: sec([null, 'kapali']) }; });
    ekle({ kod: 'FB.6.6.2', konu: 'Elektrik', alt_konu: 'Ampulün parlaklığını etkileyen değişkenler', zorluk: 3,
      spec: { tip_id: 'a5-devre', parametreler: { paneller } }, sirali: HARF, dogru: HARF[k],
      kok: parlak ? sec(['Şekilde özdeş pil ve ampullerle kurulmuş dört seri devre gösterilmiştir. Hangi devredeki ampuller en parlak yanar?', 'Aşağıdaki devrelerde kullanılan pil ve ampuller özdeştir. Hangi devrede ampul en parlak ışık verir?']) : sec(['Şekilde özdeş pil ve ampullerle kurulmuş dört seri devre gösterilmiştir. Hangi devredeki ampuller en sönük yanar?', 'Aşağıdaki devrelerde kullanılan pil ve ampuller özdeştir. Hangi devrede ampul en sönük ışık verir?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : `${h} devresinde ${paneller[i].pil} pil ve ${paneller[i].ampul} ampul vardır; bu devrede ampul başına düşen pil sayısı ${parlak ? 'daha az' : 'daha fazla'} olduğundan ampul ${parlak ? 'daha sönük' : 'daha parlak'} yanar.`)),
      ipucu: 'Pil sayısı arttıkça ampul parlaklaşır, ampul sayısı arttıkça ampuller sönükleşir. Her devrede pil sayısını ampul sayısına oranla.',
      cozum: ['Ampulün parlaklığı, pil sayısı arttıkça artar; seri bağlı ampul sayısı arttıkça azalır.', `${HARF[k]} devresinde ${paneller[k].pil} pil ve ${paneller[k].ampul} ampul vardır; ampul başına düşen pil sayısı ${parlak ? 'en fazla' : 'en az'} olan devre budur.`],
      dogrulama: HARF.map((h, i) => ({ yol: ['paneller', h, 'parlaklik'], beklenen: sira[i] })) });
  }
  return { parlaklikSorusu };
}

// ---- yoğunluk ----
const RHO = [1.5, 2, 2.5, 3, 4, 5, 6, 8];
const gcm = (v) => `${String(Math.round(v * 100) / 100).replace('.', ',')} g/cm³`;
export function kurYogunluk({ R, sec, ekle, konum }) {
  function yogunlukSorusu() {
    const k = konum(), rho = sec(RHO), V = 10 * (1 + Math.floor(R() * 5)), a = 10 * (3 + Math.floor(R() * 4)), b = a + V, m = rho * V;
    if (b > 90) throw new Error('tasma');
    const s = sayiSik(rho, k, R, { min: 0.5, max: 12, adim: 0.5, tercih: [m / b, m / a, V / m], bicim: gcm });
    ekle({ kod: 'FB.6.5.3', konu: 'Madde ve Isı', alt_konu: 'Yoğunluk hesabı', zorluk: 3,
      spec: { tip_id: 'a5-silindir', parametreler: { max: 100, bolme: 10, buyuk: 20, silindirler: [{ ad: 'I', seviye: a }, { ad: 'II', seviye: b, cisim: true }] } }, sirali: s.sirali, dogru: gcm(rho),
      kok: sec([`Kütlesi ${m} g olan bir cisim, I numaralı silindirdeki suyun içine bırakıldığında su seviyesi II numaralı silindirdeki gibi olmuştur. Cismin yoğunluğu kaç g/cm³’tür? (1 mL = 1 cm³)`, `Kütlesi ${m} g olan metal bir cisim, şekildeki ölçüm silindirinin içindeki suya bırakılıyor (I: bırakmadan önce, II: bıraktıktan sonra). Cismin yoğunluğu kaç g/cm³’tür? (1 mL = 1 cm³)`]),
      gerekce: s.degerler.map((v) => (v === rho ? '' : Math.abs(v - m / b) < 0.3 ? `${gcm(v)}, kütlenin son su seviyesine (${b} mL) bölünmesiyle bulunur; yoğunluk için cismin hacmi (${V} mL) kullanılmalıdır.` : Math.abs(v - m / a) < 0.3 ? `${gcm(v)}, kütlenin ilk su hacmine (${a} mL) bölünmesiyle bulunur; yoğunluk için cismin hacmi (${V} mL) kullanılmalıdır.` : `${gcm(v)} yanlıştır; yoğunluk, kütlenin cismin hacmine bölünmesiyle bulunur (${m} ÷ ${V}).`)),
      ipucu: 'Cismin hacmi, suyun yükselme miktarına eşittir. Yoğunluk = kütle ÷ hacim.',
      cozum: [`Cismin hacmi: ${b} − ${a} = ${V} mL = ${V} cm³.`, `Yoğunluk: ${m} ÷ ${V} = ${gcm(rho).replace(' g/cm³', '')} g/cm³.`],
      dogrulama: [{ yol: ['hacim', 'II'], beklenen: V }] });
  }
  return { yogunlukSorusu };
}

// ---- erime / kaynama grafiği ----
const sicak = (v) => `${String(v).replace('-', '−')} °C`;
export function kurHalGrafik({ R, sec, ekle, konum }) {
  const kod = { kod: 'FB.6.5.2', konu: 'Madde ve Isı', alt_konu: 'Erime, donma ve kaynama noktası' };
  function halSorusu() {
    const k = konum(), tur = sec(['erime', 'kaynama', 'baslangic', 'sure']);
    const T0 = sec([-20, -10, 0, 10, 20]), Te = sec([0, 10, 20, 30, 40, 50, 60].filter((t) => t >= T0 + 20)), Tk = sec([60, 70, 80, 90, 100, 110, 120].filter((t) => t >= Te + 30));
    const d1 = sec([2, 3, 4]), d2 = sec([2, 3, 4]), d3 = sec([3, 4, 5]), d4 = sec([2, 3, 4]);
    const spec = { tip_id: 'b2-hal-grafigi', parametreler: { T0, Te, Tk, d1, d2, d3, d4 } };
    const kok0 = 'Sabit ısı veren bir kaynakla ısıtılan saf bir maddenin sıcaklık–zaman grafiği şekilde verilmiştir.';
    if (tur === 'sure') {
      const t = d1 + d2 + d3, s = sayiSik(t, k, R, { min: 1, max: 17, tercih: [d1 + d2, d1, d1 + d2 + d3 + d4] });
      ekle({ ...kod, zorluk: 3, spec, sirali: s.sirali.map((v) => `${v} dakika`), dogru: `${t} dakika`,
        kok: `${kok0} Madde ısıtılmaya başladıktan kaç dakika sonra kaynamaya başlamıştır?`,
        gerekce: s.degerler.map((v) => (v === t ? '' : v === d1 + d2 ? `${v}. dakika erimenin bittiği andır; kaynama bu andan sonra, sıvı hâl ısındıktan sonra başlar.` : `${v}. dakikada sıcaklık kaynama noktasına ulaşmış ya da sabitlenmiş değildir; kaynama sıcaklığın sabitlendiği ilk anda başlar.`)),
        ipucu: 'Sıcaklığın ikinci kez sabitlendiği yer kaynamanın başladığı yerdir; bu noktanın zaman eksenindeki değerine bak.',
        cozum: ['Kaynama, sıcaklığın ikinci kez sabit kaldığı bölümün başlangıcında başlar.', `Bu bölüm ${t}. dakikada başlar.`],
        dogrulama: [{ yol: ['kaynama_baslangic_dk'], beklenen: t }] });
      return;
    }
    const dogru = tur === 'erime' ? Te : tur === 'kaynama' ? Tk : T0;
    const tercih = tur === 'erime' ? [Tk, T0] : tur === 'kaynama' ? [Te, Te + 10] : [Te, 0];
    const s = sayiSik(dogru, k, R, { min: -30, max: 130, adim: 10, tercih, bicim: sicak });
    const soru = tur === 'erime' ? 'Bu maddenin erime sıcaklığı kaç °C’dir?' : tur === 'kaynama' ? 'Bu maddenin kaynama sıcaklığı kaç °C’dir?' : 'Madde ısıtılmaya başlandığında sıcaklığı kaç °C’dir?';
    ekle({ ...kod, zorluk: 2, spec, sirali: s.sirali, dogru: sicak(dogru),
      kok: `${kok0} ${soru}`,
      gerekce: s.degerler.map((v) => (v === dogru ? '' : tur === 'baslangic' ? `${sicak(v)}, grafikte başka bir noktanın sıcaklığıdır; ısıtmanın başladığı an zaman ekseninde 0. dakikadır.` : v === (tur === 'erime' ? Tk : Te) ? `${sicak(v)}, ${tur === 'erime' ? 'kaynama' : 'erime'} sıcaklığıdır; ${tur === 'erime' ? 'erime' : 'kaynama'} sıcaklığı ${tur === 'erime' ? 'ilk' : 'ikinci'} sabit bölümdeki değerdir.` : `${sicak(v)}, sıcaklığın sabit kaldığı bölümdeki değerle uyuşmuyor; ${tur === 'erime' ? 'erime' : 'kaynama'} sırasında sıcaklık değişmez.`)),
      ipucu: tur === 'baslangic' ? 'Eğrinin zaman ekseni üzerindeki 0. dakikadaki noktasına bak.' : `Saf maddelerde hâl değişimi sırasında sıcaklık sabit kalır; ${tur === 'erime' ? 'ilk' : 'ikinci'} yatay bölümün sıcaklığını oku.`,
      cozum: tur === 'baslangic' ? ['Isıtmaya başlandığı an 0. dakikadır.', `Grafikte bu andaki sıcaklık ${sicak(T0)}’dir.`.replace('°C’dir', '°C’dir')] : [`Hâl değişimi sırasında sıcaklık sabit kalır: ${tur === 'erime' ? 'ilk' : 'ikinci'} yatay bölüm ${tur === 'erime' ? 'erime' : 'kaynama'} bölümüdür.`, `Bu bölümde sıcaklık ${sicak(dogru)}’dir.`],
      dogrulama: [{ yol: [tur === 'baslangic' ? 'baslangic' : tur], beklenen: dogru }] });
  }
  return { halSorusu };
}

export const KAYIT = [
  { id: 'b2-fen6-yansima-isin', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-YIS', mufredat_surum: MUFREDAT, kodlar: ['FB.6.4.2'], fabrika: kurYansimaAday, uret: (f) => f.adaySorusu() },
  { id: 'b2-fen6-yansima-aci', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-YAC', mufredat_surum: MUFREDAT, kodlar: ['FB.6.4.2'], fabrika: kurYansimaAci, uret: (f) => f.aciSorusu() },
  { id: 'b2-fen6-devre-parlaklik', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-PAR', mufredat_surum: MUFREDAT, kodlar: ['FB.6.6.2'], fabrika: kurParlaklik, uret: (f) => f.parlaklikSorusu() },
  { id: 'b2-fen6-yogunluk', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-YOG', mufredat_surum: MUFREDAT, kodlar: ['FB.6.5.3'], fabrika: kurYogunluk, uret: (f) => f.yogunlukSorusu() },
  { id: 'b2-fen6-erime-grafik', ders: 'Fen Bilimleri', sinif: 6, idOnek: 'FEN6-ERI', mufredat_surum: MUFREDAT, kodlar: ['FB.6.5.2'], fabrika: kurHalGrafik, uret: (f) => f.halSorusu() },
];
