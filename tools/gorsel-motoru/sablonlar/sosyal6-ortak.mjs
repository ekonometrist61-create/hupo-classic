// Ortak yardımcılar (A6): zaman şeridi ve çizgi grafiği soru üreticileri, Türkçe ilgi eki, sayısal şık penceresi.
// Bu dosya KAYIT içermez; sablonlar/sosyal*-, inkilap8-* dosyaları içe aktarır.
import { yilMetni } from '../tipler-a6.mjs';

// Türkçe ilgi eki: "Efe'nin", "Zeynep'in", "Umut'un", "Gül'ün", "Arda'nın".
export function ilgi(ad) {
  const k = String(ad).toLocaleLowerCase('tr-TR'), ses = 'aeıioöuü';
  let son = ''; for (const c of k) if (ses.includes(c)) son = c;
  const h = 'aı'.includes(son) ? 'ı' : 'ei'.includes(son) ? 'i' : 'ou'.includes(son) ? 'u' : 'ü';
  return `${ad}'${ses.includes(k[k.length - 1]) ? 'n' : ''}${h}n`;
}

// dogru değerini k. sıraya koyan, artan sıralı 4 sayı: k tane küçük, 3-k tane büyük çeldirici. Yoksa null.
export function sayisalSik({ dogru, havuz, k, karistir }) {
  const u = [...new Set(havuz)].filter((v) => v !== dogru);
  const kucuk = karistir(u.filter((v) => v < dogru)), buyuk = karistir(u.filter((v) => v > dogru));
  if (kucuk.length < k || buyuk.length < 3 - k) return null;
  return [...kucuk.slice(0, k).sort((a, b) => a - b), dogru, ...buyuk.slice(0, 3 - k).sort((a, b) => a - b)];
}

const HARFLER = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

// cfg: { kod, konu, alt_konu, havuz:[{ad,yil,ay?}] | uret(n)->olaylar, n:[5,6], birim:'yil'|'ay', bc?, turler? }
export function zamanKur({ R, sec, karistir, ekle: ekleOrj, konum }, cfg) {
  const ekle = (o) => ekleOrj(cfg.baglam ? { ...o, kok: `${cfg.baglam} ${o.kok}`} : o);
  const birim = cfg.birim ?? 'yil', bc = !!cfg.bc, BR = birim === 'ay' ? 'ay' : 'yıl';
  const t = (e) => (birim === 'ay' ? e.yil * 12 + (e.ay - 1) : e.yil), yt = (e) => yilMetni(e, bc);
  const TURLER = cfg.turler ?? ['fark', 'once', 'sonra', 'arada', 'sayi', 'uzun', 'yil', 'sirala'];

  function zamanSorusu() {
    const n = sec(cfg.n ?? [5, 6]);
    let ham = cfg.uret ? cfg.uret(n) : karistir(cfg.havuz).slice(0, n);
    ham = [...ham].sort((a, b) => t(a) - t(b));
    for (let i = 1; i < ham.length; i++) if (t(ham[i]) === t(ham[i - 1])) throw new Error('ayni_tarih');
    const hf = karistir(HARFLER).slice(0, n);
    const ev = ham.map((e, i) => ({ ad: e.ad, yil: e.yil, ...(e.ay ? { ay: e.ay } : {}), harf: hf[i] }));
    const spec = { tip_id: 'a6-zaman-seridi', parametreler: { olaylar: ev, birim, bc } };
    const k = konum(), tur = sec(TURLER), L = (i) => ev[i].harf, tx = (i) => yt(ev[i]);
    const ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec };
    const sira = { yol: ['sira'], beklenen: ev.map((e) => e.harf) };
    const cift = (i, j) => (R() < 0.5 ? [L(i), L(j)] : [L(j), L(i)]);
    const gunAd = birim === 'ay' ? 'ay ve yılda' : 'yılda';

    if (tur === 'fark') {
      const i = Math.floor(R() * n), j = (i + 1 + Math.floor(R() * (n - 1))) % n, D = Math.abs(t(ev[i]) - t(ev[j])), par = new Map();
      for (let a = 0; a < n; a++) for (let c = a + 1; c < n; c++) { const d = t(ev[c]) - t(ev[a]); if (!par.has(d)) par.set(d, [L(a), L(c)]); }
      const sik = sayisalSik({ dogru: D, havuz: [...par.keys()], k, karistir }); if (!sik) throw new Error('fark_sik_yok');
      const [x, y] = cift(i, j), a = i < j ? i : j, c = i < j ? j : i;
      return ekle({ ...ortak, zorluk: 2, sirali: sik.map((v) => `${v} ${BR}`), dogru: `${D} ${BR}`,
        gerekce: sik.map((v) => (v === D ? '' : `${v} ${BR}, ${par.get(v).join(' ile ')} olayları arasındaki farktır; sorulan ${x} ile ${y} arasındaki farktır.`)),
        kok: `Yukarıdaki zaman şeridinde ${x} ve ${y} harfleriyle gösterilen olaylar arasında kaç ${BR} vardır?`,
        ipucu: 'İki olayın tarihlerini şeritten oku ve büyük tarihten küçük tarihi çıkar.',
        cozum: [`${L(a)} olayı ${tx(a)}, ${L(c)} olayı ${tx(c)} tarihindedir.`, birim === 'ay' ? `Tarihler arasındaki fark ${D} aydır.` : `${bc ? 'Eski tarih büyük sayıyla yazıldığı için ' : ''}fark ${Math.max(Math.abs(ev[a].yil), Math.abs(ev[c].yil))} ile ${Math.min(Math.abs(ev[a].yil), Math.abs(ev[c].yil))} sayılarının farkıdır: ${D} yıl.`],
        dogrulama: [{ yol: ['fark', `${L(i)}|${L(j)}`], beklenen: D }, sira] });
    }
    if (tur === 'once' || tur === 'sonra') {
      const once = tur === 'once', i = once ? 1 + Math.floor(R() * (n - 1)) : Math.floor(R() * (n - 1)), a = once ? i - 1 : i + 1;
      const cel = karistir(ev.map((_, m) => m).filter((m) => m !== i && m !== a)).slice(0, 3);
      const g = (m) => (m === i ? `${ev[m].ad}, ${L(i)} ile gösterilen olayın kendisidir.` : once ? (m < a ? `${ev[m].ad}, ${L(i)} olayından önce gerçekleşmiştir ancak hemen önce değildir.` : `${ev[m].ad}, ${L(i)} olayından sonra gerçekleşmiştir.`) : (m > a ? `${ev[m].ad}, ${L(i)} olayından sonra gerçekleşmiştir ancak hemen sonra değildir.` : `${ev[m].ad}, ${L(i)} olayından önce gerçekleşmiştir.`));
      return ekle({ ...ortak, zorluk: 1, dogru: ev[a].ad, celdirici: cel.map((m) => ev[m].ad), gerekce: cel.map(g),
        kok: `Yukarıdaki zaman şeridine göre ${L(i)} ile gösterilen olaydan hemen ${once ? 'önce' : 'sonra'} gerçekleşen olay hangisidir?`,
        ipucu: 'Şerit eskiden yeniye doğru soldan sağa ilerler. Harfi bul, yanındaki olaya bak.',
        cozum: [`Şeritte ${L(i)} olayı ${tx(i)} tarihindedir.`, `Hemen ${once ? 'önceki' : 'sonraki'} olay ${L(a)} harfli olaydır: ${ev[a].ad}.`], dogrulama: [{ yol: ['ad', L(a)], beklenen: ev[a].ad }, sira] });
    }
    if (tur === 'arada') {
      const i = Math.floor(R() * (n - 2)), j = i + 2, a = i + 1, [x, y] = cift(i, j);
      const cel = karistir(ev.map((_, m) => m).filter((m) => m !== a)).slice(0, 3);
      const g = (m) => (m === i || m === j ? `${ev[m].ad}, ${m === i ? L(i) : L(j)} ile gösterilen olaylardan biridir; arasında değildir.` : m < i ? `${ev[m].ad}, ${L(i)} olayından önce gerçekleşmiştir.` : `${ev[m].ad}, ${L(j)} olayından sonra gerçekleşmiştir.`);
      return ekle({ ...ortak, zorluk: 2, dogru: ev[a].ad, celdirici: cel.map((m) => ev[m].ad), gerekce: cel.map(g),
        kok: `Yukarıdaki zaman şeridinde ${x} ile ${y} harfleriyle gösterilen olayların arasında gerçekleşen olay hangisidir?`,
        ipucu: 'İki harfin şeritteki yerini bul; ikisinin ortasındaki olaya bak.',
        cozum: [`${L(i)} olayı ${tx(i)}, ${L(j)} olayı ${tx(j)} tarihindedir.`, `Bu iki tarih arasındaki tek olay ${L(a)} harfli olaydır: ${ev[a].ad}.`], dogrulama: [{ yol: ['ad', L(a)], beklenen: ev[a].ad }, sira] });
    }
    if (tur === 'sayi') {
      const lo = k, hi = n - 5 + k; if (hi < lo) throw new Error('sayi_sik_yok');
      const c = lo + Math.floor(R() * (hi - lo + 1)), i = Math.floor(R() * (n - 1 - c)), j = i + c + 1;
      const sik = sayisalSik({ dogru: c, havuz: Array.from({ length: n - 1 }, (_, q) => q), k, karistir }); if (!sik) throw new Error('sayi_sik_yok');
      const [x, y] = cift(i, j);
      return ekle({ ...ortak, zorluk: 2, sirali: sik.map(String), dogru: String(c), gerekce: sik.map((v) => (v === c ? '' : `${x} ile ${y} arasında ${v} olay yoktur; arada ${c} olay vardır.`)),
        kok: `Yukarıdaki zaman şeridinde ${x} ile ${y} harfleriyle gösterilen olayların arasında (bu ikisi hariç) kaç olay gerçekleşmiştir?`,
        ipucu: 'İki harfin şeritteki yerini bul. Yalnız aradaki daireleri say.',
        cozum: [`${L(i)} olayı ile ${L(j)} olayı şeritte ${c + 1} adım arayla durur.`, `Aralarında ${c} olay vardır.`], dogrulama: [{ yol: ['ad', L(i)], beklenen: ev[i].ad }, sira] });
    }
    if (tur === 'uzun') {
      const gap = ev.slice(1).map((e, m) => t(e) - t(ev[m])), uzun = R() < 0.5, h = uzun ? Math.max(...gap) : Math.min(...gap);
      if (gap.filter((d) => d === h).length !== 1) throw new Error('uc_deger_tekil_degil');
      const e = gap.indexOf(h), cel = karistir(gap.map((_, m) => m).filter((m) => m !== e)).slice(0, 3), ad = (m) => `${L(m)} – ${L(m + 1)}`;
      return ekle({ ...ortak, zorluk: 3, dogru: ad(e), celdirici: cel.map(ad), gerekce: cel.map((m) => `${ad(m)} arasında ${gap[m]} ${BR} vardır; bu süre en ${uzun ? 'uzun' : 'kısa'} değildir.`),
        kok: `Yukarıdaki zaman şeridinde art arda gelen iki olay arasındaki süre en ${uzun ? 'uzun' : 'kısa'} olan, aşağıdaki harf çiftlerinden hangisidir?`,
        ipucu: 'Art arda gelen her iki olayın tarihleri arasındaki farkı bul, sonra karşılaştır.',
        cozum: ['Art arda gelen olayların tarihleri arasındaki farklar bulunur.', `En ${uzun ? 'uzun' : 'kısa'} süre ${ad(e)} arasındadır: ${h} ${BR}.`], dogrulama: [{ yol: ['fark', `${L(e)}|${L(e + 1)}`], beklenen: h }, sira] });
    }
    if (tur === 'yil') {
      const lo = k, hi = n - 4 + k; if (hi < lo) throw new Error('yil_sik_yok');
      const i = lo + Math.floor(R() * (hi - lo + 1)), onc = karistir(ev.map((_, m) => m).filter((m) => m < i)).slice(0, k), son = karistir(ev.map((_, m) => m).filter((m) => m > i)).slice(0, 3 - k);
      if (onc.length < k || son.length < 3 - k) throw new Error('yil_sik_yok');
      const sirali = [...onc.sort((a, b) => a - b), i, ...son.sort((a, b) => a - b)];
      return ekle({ ...ortak, zorluk: 1, sirali: sirali.map(tx), dogru: tx(i), gerekce: sirali.map((m) => (m === i ? '' : `${tx(m)}, ${L(m)} ile gösterilen olayın tarihidir.`)),
        kok: `Yukarıdaki zaman şeridinde ${L(i)} ile gösterilen olay hangi ${gunAd} gerçekleşmiştir?`, ipucu: 'Harfi bul; olayın altındaki ya da üstündeki tarihi oku.',
        cozum: [`Şeritte ${L(i)} harfli olayın tarihi ${tx(i)} olarak yazılmıştır.`], dogrulama: [{ yol: ['yil', L(i)], beklenen: tx(i) }, sira] });
    }
    // sirala: dört harften en önce / en sonra olan
    const secili = karistir(ev.map((_, m) => m)).slice(0, 4), enOnce = R() < 0.5, e = enOnce ? Math.min(...secili) : Math.max(...secili), cel = secili.filter((m) => m !== e);
    const harfSirali = [...secili].sort((a, b) => L(a).localeCompare(L(b))).map(L).join(', ');
    return ekle({ ...ortak, zorluk: bc || birim === 'ay' ? 3 : 2, dogru: L(e), celdirici: cel.map(L), gerekce: cel.map((m) => `${L(m)} olayı ${tx(m)} tarihindedir; ${L(e)} olayı ondan daha ${enOnce ? 'önce' : 'sonra'} gerçekleşmiştir.`),
      kok: `Yukarıdaki zaman şeridinde ${harfSirali} harfleriyle gösterilen olaylardan hangisi en ${enOnce ? 'önce' : 'sonra'} gerçekleşmiştir?`,
      ipucu: bc ? 'M.Ö. tarihlerde sayı büyüdükçe olay daha eskidir.' : 'Şeritte olaylar soldan sağa, eskiden yeniye dizilidir.',
      cozum: ['Dört olayın tarihleri şeritten okunur ve karşılaştırılır.', `${L(e)} olayı ${tx(e)} tarihindedir ve en ${enOnce ? 'önce' : 'sonra'} gerçekleşendir.`], dogrulama: [{ yol: ['yil', L(e)], beklenen: tx(e) }, sira] });
  }
  return { zamanSorusu };
}

// cfg: { kod, konu, alt_konu, baslik, etiketler(): string[], olcekler:[{max,adim}], konuAd, artti, degerMetni(v), okuSoru(l), farkSoru(a,b), farkMetni(d), turler? }
export function cizgiKur({ R, sec, karistir, ekle: ekleOrj, konum }, cfg) {
  const ekle = (o) => ekleOrj(cfg.baglam ? { ...o, kok: `${cfg.baglam} ${o.kok}`} : o);
  function cizgiSorusu() {
    const e = cfg.etiketler(), n = e.length, o = sec(cfg.olcekler), { max, adim } = o, adet = Math.floor(max / adim);
    const tur = sec(cfg.turler ?? ['en_cok', 'en_az', 'azalis', 'oku', 'fark']), k = konum();
    const uret = (kosul) => { for (let g = 0; g < 300; g++) { const v = Array.from({ length: n }, () => adim * (1 + Math.floor(R() * adet))); const d = v.slice(1).map((x, i) => x - v[i]); if (kosul(d, v)) return v; } throw new Error('veri_uretilemedi'); };
    const tekil = (d) => new Set(d).size === d.length;
    const kosul = tur === 'azalis' ? (d) => d.filter((x) => x < 0).length === 1 && d.every((x) => x !== 0) : (d) => d.every((x) => x > 0) && tekil(d);
    const v = uret(kosul), d = v.slice(1).map((x, i) => x - v[i]), spec = { tip_id: 'a6-cizgi-grafigi', parametreler: { baslik: cfg.baslik, etiketler: e, degerler: v, max, adim } };
    const ortak = { kod: cfg.kod, konu: cfg.konu, alt_konu: cfg.alt_konu, spec }, per = (i) => `${e[i]} – ${e[i + 1]}`;
    if (tur === 'en_cok' || tur === 'en_az' || tur === 'azalis') {
      const hedef = tur === 'azalis' ? d.findIndex((x) => x < 0) : tur === 'en_cok' ? d.indexOf(Math.max(...d)) : d.indexOf(Math.min(...d));
      const cel = karistir(d.map((_, i) => i).filter((i) => i !== hedef)).slice(0, 3);
      const gerekce = cel.map((i) => (tur === 'azalis' ? `${per(i)} arasında değer ${d[i] > 0 ? 'artmıştır' : 'değişmemiştir'}; azalış yoktur.` : `${per(i)} arasındaki artış ${d[i]}; en ${tur === 'en_cok' ? 'çok' : 'az'} artış ${per(hedef)} arasındadır (${d[hedef]}).`));
      const olgu = tur === 'azalis' ? { yol: ['azalis'], beklenen: [`${e[hedef]}|${e[hedef + 1]}`] } : { yol: [tur === 'en_cok' ? 'en_cok_artis' : 'en_az_artis'], beklenen: `${e[hedef]}|${e[hedef + 1]}` };
      return ekle({ ...ortak, zorluk: 2, dogru: per(hedef), celdirici: cel.map(per), gerekce,
        kok: tur === 'azalis' ? `Yukarıdaki grafiğe göre ${cfg.konuAd} hangi iki dönem arasında azalmıştır?` : `Yukarıdaki grafiğe göre ${cfg.konuAd} hangi iki dönem arasında en ${tur === 'en_cok' ? 'çok' : 'az'} ${cfg.artti}?`,
        ipucu: tur === 'azalis' ? 'Çizginin aşağı doğru indiği bölümü bul.' : 'Her iki nokta arasındaki yükselmeyi karşılaştır.',
        cozum: ['Art arda gelen noktalar arasındaki değişim bulunur.', `Doğru dönem ${per(hedef)} olur.`], dogrulama: [olgu] });
    }
    if (tur === 'oku') {
      const i = Math.floor(R() * n), baslangic = v[i] - k * adim; if (baslangic < adim) throw new Error('pencere_negatif');
      const sirali = [0, 1, 2, 3].map((q) => baslangic + q * adim); if (sirali[3] > max) throw new Error('pencere_asiyor');
      return ekle({ ...ortak, zorluk: 1, sirali: sirali.map(cfg.degerMetni), dogru: cfg.degerMetni(v[i]), gerekce: sirali.map((x) => (x === v[i] ? '' : `${cfg.degerMetni(x)}, ${e[i]} noktasının ${Math.abs(x - v[i]) / adim} çizgi ${x > v[i] ? 'üstündeki' : 'altındaki'} değerdir.`)),
        kok: cfg.okuSoru(e[i]), ipucu: 'Noktanın hangi yatay çizgiyle aynı hizada olduğuna bak.', cozum: [`${e[i]} noktası dikey eksende ${v[i]} değerine karşılık gelir.`], dogrulama: [{ yol: ['degerler', String(e[i])], beklenen: v[i] }] });
    }
    // fark: iki nokta arasında artış (araya en az bir dönem girer)
    const a = Math.floor(R() * (n - 2)), c = a + 2 + Math.floor(R() * (n - a - 2)), D = v[c] - v[a];
    if (D <= 0) throw new Error('fark_pozitif_degil');
    const baslangic = D - k * adim; if (baslangic < adim) throw new Error('pencere_negatif');
    const sirali = [0, 1, 2, 3].map((q) => baslangic + q * adim);
    return ekle({ ...ortak, zorluk: 2, sirali: sirali.map(cfg.farkMetni), dogru: cfg.farkMetni(D), gerekce: sirali.map((x) => (x === D ? '' : `${cfg.farkMetni(x)}, ${Math.abs(x - D) / adim} çizgi ${x > D ? 'fazla' : 'eksik'} okumadır.`)),
      kok: cfg.farkSoru(e[a], e[c]), ipucu: 'İki dönemin değerlerini dikey eksenden oku, büyükten küçüğü çıkar.',
      cozum: [`${e[a]} değeri ${v[a]}, ${e[c]} değeri ${v[c]} olarak okunur.`, `Fark ${v[c]} − ${v[a]} = ${D} bulunur.`], dogrulama: [{ yol: ['artis', `${e[a]}|${e[c]}`], beklenen: D }] });
  }
  return { cizgiSorusu };
}
