// 4. sınıf Sosyal Bilgiler — krokide doğal ve insan yapımı (beşerî) çevre unsurlarını ayırt etme (SB.4.2.2).
// Krokideki unsurlar kurgusaldır. Doğru cevap yerleştirilen unsurlardan kodla hesaplanır.
import { sayisalSik } from './sosyal6-ortak.mjs';

const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const DOGAL = ['gol', 'dag', 'orman', 'nehir'];
const BESERI = ['ev', 'okul', 'kopru', 'fabrika', 'market', 'hastane'];
const AD = { gol: 'Göl', dag: 'Dağ', orman: 'Orman', nehir: 'Nehir', ev: 'Ev', okul: 'Okul', kopru: 'Köprü', fabrika: 'Fabrika', market: 'Market', hastane: 'Hastane' };

export function kur({ R, karistir, sec, konum, ekle }) {
  function krokiSorusu() {
    const tur = sec(['dogal_say', 'besri_say', 'dogal_yok', 'besri_var']);
    // dogal_yok: 3 doğal unsur (1 tanesi eksik); besri_var: 1 beşerî unsur; sayma türlerinde 2-4 / 2-4
    const nd = tur === 'dogal_yok' ? 3 : 2 + Math.floor(R() * 3);
    const nb = tur === 'besri_var' ? 1 : 2 + Math.floor(R() * 3);
    const dogal = karistir(DOGAL).slice(0, nd), beseri = karistir(BESERI).slice(0, nb);
    const hucre = karistir(Array.from({ length: 9 }, (_, i) => i));
    const ogeler = [...dogal, ...beseri].map((t, i) => ({ tur: t, hucre: hucre[i] }));
    const spec = { tip_id: 'a6-kroki', parametreler: { en: 3, boy: 3, ogeler } };
    const ortak = { kod: 'SB.4.2.2', konu: 'Doğa ve İnsan', alt_konu: 'Krokide doğal ve insan yapımı unsurlar', spec };
    const k = konum();

    if (tur === 'dogal_say' || tur === 'besri_say') {
      const d = tur === 'dogal_say' ? nd : nb, diger = tur === 'dogal_say' ? nb : nd, top = nd + nb;
      const sik = sayisalSik({ dogru: d, havuz: Array.from({ length: 8 }, (_, i) => i + 1), k, karistir });
      if (!sik) throw new Error('sayi_sik_yok');
      const ad = tur === 'dogal_say' ? 'doğal çevre' : 'insan yapımı';
      const ornek = (tur === 'dogal_say' ? dogal : beseri).map((t) => AD[t]).join(', ');
      return ekle({ ...ortak, zorluk: 1, sirali: sik.map(String), dogru: String(d),
        gerekce: sik.map((v) => (v === d ? '' : v === diger ? `${v}, ${tur === 'dogal_say' ? 'insan yapımı' : 'doğal çevre'} unsurlarının sayısıdır; sorulan ${ad} unsurlarıdır.` : v === top ? `${v}, krokideki bütün unsurların sayısıdır; yalnız ${ad} unsurları sayılmalıdır.` : `${v}, ${ad} unsurlarının sayısı değildir; krokideki ${ad} unsurları ${v < d ? 'eksik' : 'fazla'} sayılmıştır.`)),
        kok: `Yukarıdaki krokide kaç tane ${ad} unsuru gösterilmiştir?`,
        ipucu: tur === 'dogal_say' ? 'Doğada kendiliğinden bulunan unsurları (göl, dağ, orman, nehir) say.' : 'İnsanların yaptığı unsurları (ev, okul, köprü gibi) say.',
        cozum: [`Krokideki unsurların adları okunur ve ${ad} olanlar ayrılır: ${ornek}.`, `Bunların sayısı ${d} bulunur.`],
        dogrulama: [{ yol: [tur === 'dogal_say' ? 'dogal' : 'besri'], beklenen: d }] });
    }
    if (tur === 'dogal_yok') {
      const yok = DOGAL.find((t) => !dogal.includes(t)), cel = dogal.map((t) => AD[t]);
      return ekle({ ...ortak, zorluk: 2, dogru: AD[yok], celdirici: cel,
        gerekce: dogal.map((t) => `${AD[t]} krokide gösterilmiştir; bu yüzden krokide bulunmayan unsur değildir.`),
        kok: 'Aşağıdaki doğal çevre unsurlarından hangisi yukarıdaki krokide gösterilmemiştir?',
        ipucu: 'Seçeneklerdeki her unsuru krokide ara. Bulamadığın unsur doğru cevaptır.',
        cozum: [`Krokide ${cel.join(', ')} gösterilmiştir.`, `${AD[yok]} krokide yoktur.`],
        dogrulama: [{ yol: ['dogal'], beklenen: 3 }, ...dogal.map((t) => ({ yol: ['sayilar', t], beklenen: 1 }))] });
    }
    // besri_var: krokide tek insan yapımı unsur var, diğer seçenekler krokide yok
    const var1 = beseri[0], cel = karistir(BESERI.filter((t) => t !== var1)).slice(0, 3);
    return ekle({ ...ortak, zorluk: 1, dogru: AD[var1], celdirici: cel.map((t) => AD[t]),
      gerekce: cel.map((t) => `${AD[t]} insan yapımı bir unsurdur ancak krokide gösterilmemiştir.`),
      kok: 'Aşağıdakilerden hangisi yukarıdaki krokide gösterilen insan yapımı unsurdur?',
      ipucu: 'Krokide göl, dağ, orman ve nehir gibi doğal unsurları ayır. Geriye kalan unsura bak.',
      cozum: [`Krokideki doğal unsurlar ayrılır: ${dogal.map((t) => AD[t]).join(', ')}.`, `Geriye kalan insan yapımı unsur ${AD[var1]} olur.`],
      dogrulama: [{ yol: ['besri'], beklenen: 1 }, { yol: ['sayilar', var1], beklenen: 1 }] });
  }
  return { krokiSorusu };
}

export const KAYIT = [
  { id: 'sb4-kroki-dogal-beseri', ders: 'Sosyal Bilgiler', sinif: 4, idOnek: 'SB4-KRO', mufredat_surum: MUFREDAT, kodlar: ['SB.4.2.2'], fabrika: kur, uret: (f) => f.krokiSorusu() },
];
