// 6. sınıf Sosyal Bilgiler — ekonomik faaliyet alanlarında çalışan sayısının iki yıl arasındaki değişimini ikili sütun grafiğinden okuma (SB.6.5.2).
// Veriler kurgusaldır (gerçek veri değildir); soru yalnız grafik okuma ve kanıta dayalı çıkarım becerisini ölçer.
import { sayisalSik } from './sosyal6-ortak.mjs';

const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const ALANLAR = ['Tarım', 'Sanayi', 'Hizmet', 'Turizm', 'İnşaat', 'Ticaret', 'Sağlık', 'Bilişim', 'Ulaşım'];
const OLCEKLER = [{ max: 100, adim: 20 }, { max: 60, adim: 10 }, { max: 200, adim: 40 }];

export function kur({ R, karistir, sec, konum, ekle }) {
  function sutunSorusu() {
    const tur = sec(['okuma', 'tek_azalan', 'tek_artan', 'en_cok_artis']), { max, adim } = sec(OLCEKLER), st = adim / 2, n = sec([4, 5]);
    const deger = () => st * (1 + Math.floor(R() * (max / st)));
    const ad = karistir(ALANLAR).slice(0, n);
    // tür başına kısıt: tek_azalan -> yalnız 0. kategori azalır; tek_artan -> yalnız 0. kategori artar
    const kat = [];
    for (let i = 0; i < n; i++) {
      const artis = tur === 'tek_azalan' ? i !== 0 : tur === 'tek_artan' ? i === 0 : tur === 'en_cok_artis' ? true : R() < 0.6;
      let a, b, g = 0; do { a = deger(); b = deger(); g++; } while ((artis ? b <= a : b >= a) && g < 100);
      if (artis ? b <= a : b >= a) throw new Error('veri_uretilemedi');
      kat.push({ ad: ad[i], a, b });
    }
    const fark = kat.map((x) => x.b - x.a);
    if (tur === 'en_cok_artis') { const mx = Math.max(...fark); if (fark.filter((d) => d === mx).length !== 1) throw new Error('en_buyuk_tekil_degil'); }
    const hedef = tur === 'en_cok_artis' ? fark.indexOf(Math.max(...fark)) : 0;
    const karisik = karistir(kat);
    const spec = { tip_id: 'a6-ikili-sutun', parametreler: { baslik: 'Çalışan Sayısı (bin kişi)', kategoriler: karisik, seriA: '2010', seriB: '2020', max, adim } };
    const ortak = { kod: 'SB.6.5.2', konu: 'Ekonomik Faaliyetler', alt_konu: 'Ekonomik faaliyetler ve meslekler arasındaki değişimi grafikten okuma', spec };
    const k = konum();

    if (tur === 'okuma') {
      const c = sec(kat), sik = sayisalSik({ dogru: c.b, havuz: Array.from({ length: max / st }, (_, i) => (i + 1) * st), k, karistir });
      if (!sik) throw new Error('sik_yok');
      return ekle({ ...ortak, zorluk: 1, sirali: sik.map((v) => `${v} bin`), dogru: `${c.b} bin`,
        gerekce: sik.map((v) => (v === c.b ? '' : v === c.a ? `${v} bin, ${c.ad} alanının 2010 yılındaki sütununun değeridir; soru 2020 yılını sorar.` : `${v} bin, ${c.ad} alanındaki 2020 sütununun üst ucuyla aynı hizada değildir.`)),
        kok: `Yukarıdaki grafiğe göre 2020 yılında ${c.ad} alanında çalışan kişi sayısı kaç bindir?`,
        ipucu: 'Göstergeye bak: boş sütun 2020 yılını gösterir. Sütunun üst ucunun hizasını dikey eksenden oku.',
        cozum: [`${c.ad} alanında 2020 yılını gösteren boş sütunun üst ucu bulunur.`, `Bu hizanın dikey eksendeki değeri ${c.b} bindir.`],
        dogrulama: [{ yol: ['b', c.ad], beklenen: c.b }] });
    }
    const kismi = (c) => kat.find((x) => x.ad === c);
    if (tur === 'en_cok_artis') {
      const cel = karistir(kat.filter((_, i) => i !== hedef)).slice(0, 3), D = fark[hedef];
      return ekle({ ...ortak, zorluk: 2, dogru: kat[hedef].ad, celdirici: cel.map((x) => x.ad),
        gerekce: cel.map((x) => `${x.ad} alanında çalışan sayısı ${x.b - x.a} bin artmıştır; en çok artış ${kat[hedef].ad} alanındadır (${D} bin).`),
        kok: 'Yukarıdaki grafiğe göre hangi alanda çalışan kişi sayısı 2010 yılından 2020 yılına en çok artmıştır?',
        ipucu: 'Her alanda iki sütunun yüksekliği arasındaki farka bak. Farkı en büyük olanı bul.',
        cozum: ['Her alanda 2020 sütunundan 2010 sütunu çıkarılır.', `En büyük fark ${kat[hedef].ad} alanındadır: ${D} bin.`],
        dogrulama: [{ yol: ['en_buyuk_fark'], beklenen: kat[hedef].ad }] });
    }
    const azalan = tur === 'tek_azalan', cel = karistir(kat.filter((_, i) => i !== 0)).slice(0, 3), hd = kismi(kat[0].ad);
    return ekle({ ...ortak, zorluk: 2, dogru: hd.ad, celdirici: cel.map((x) => x.ad),
      gerekce: cel.map((x) => `${x.ad} alanında çalışan sayısı ${x.a} binden ${x.b} bine ${azalan ? 'çıkmıştır; azalma yoktur' : 'inmiştir; artış yoktur'}.`),
      kok: `Yukarıdaki grafiğe göre hangi alanda çalışan kişi sayısı 2010 yılından 2020 yılına ${azalan ? 'azalmıştır' : 'artmıştır'}?`,
      ipucu: `Her alanda 2010 ve 2020 sütunlarını karşılaştır. ${azalan ? 'Boş sütunun dolu sütundan kısa olduğu alanı bul.' : 'Boş sütunun dolu sütundan uzun olduğu alanı bul.'}`,
      cozum: ['Her alanda iki sütunun yüksekliği karşılaştırılır.', `Çalışan sayısı yalnız ${hd.ad} alanında ${azalan ? 'azalmıştır' : 'artmıştır'}.`],
      dogrulama: [{ yol: [azalan ? 'a_fazla' : 'b_fazla'], beklenen: [hd.ad] }] });
  }
  return { sutunSorusu };
}

export const KAYIT = [
  { id: 'sb6-meslek-sutun', ders: 'Sosyal Bilgiler', sinif: 6, idOnek: 'SB6-MES', mufredat_surum: MUFREDAT, kodlar: ['SB.6.5.2'], fabrika: kur, uret: (f) => f.sutunSorusu() },
];
