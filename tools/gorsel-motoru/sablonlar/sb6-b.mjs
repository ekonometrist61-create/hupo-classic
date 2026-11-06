// 6. sınıf Sosyal Bilgiler — ekonomik faaliyetin (turizm, üretim) yıllara göre değişimini çizgi grafiğinden okuma (SB.6.5.1).
// Veriler kurgusaldır (gerçek il verisi değildir); soru yalnız grafik okuma becerisini ölçer.
// v2: kökte değer ya da sonuç yoktur; şıklar grafikteki başka yıl/dönem değerlerinden hesaplanır, cevap yalnız şekilden okunur.
const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const KONULAR = [
  { baslik: 'Turist Sayısı (bin kişi)', ad: 'turist sayısı', artti: 'artmıştır' },
  { baslik: 'Fındık Üretimi (bin ton)', ad: 'fındık üretimi', artti: 'artmıştır' },
  { baslik: 'Balık Üretimi (bin ton)', ad: 'balık üretimi', artti: 'artmıştır' },
  { baslik: 'İhracat Yapan Firma Sayısı (bin)', ad: 'ihracat yapan firma sayısı', artti: 'artmıştır' },
];
const OLCEKLER = [{ max: 100, adim: 10 }, { max: 80, adim: 10 }, { max: 120, adim: 20 }, { max: 200, adim: 20 }, { max: 150, adim: 15 }];
const TURLER = ['oku', 'en_cok', 'en_az', 'fark', 'toplam', 'esit', 'azalis', 'en_cok_artis'];
const bin = (v) => `${v} bin`;

export function kur({ R, sec, karistir, ekle }) {
  const ASIL = 'SB.6.5.1', KONU = 'Ekonomik Faaliyetler', ALT = 'Kaynaklar ve ekonomik faaliyet verisini grafikten okuma';
  const kokOnek = (ad) => `Yukarıdaki grafiğe göre bu ilde`;

  // k tane farklı düzey seç (artan sıralı)
  const dizi = (adet, n) => karistir(Array.from({ length: adet }, (_, i) => i + 1)).slice(0, n).sort((a, b) => a - b);
  // en yakın 3 çeldiriciyi (değere göre) seç: havuzdan, dogru hariç, benzersiz
  const yakin = (havuz, dogru, adim) => {
    const u = [...new Set(havuz)].filter((x) => x !== dogru && x > 0);
    if (u.length < 3) return null;
    const s = u.sort((a, b) => Math.abs(a - dogru) - Math.abs(b - dogru) || a - b).slice(0, Math.min(u.length, 5));
    return karistir(s).slice(0, 3);
  };

  function cizgiSorusu() {
    const konu = sec(KONULAR), { max, adim } = sec(OLCEKLER), adet = Math.floor(max / adim);
    const n = sec([5, 6, 6, 7]), bas = 2012 + Math.floor(R() * 11), e = Array.from({ length: n }, (_, i) => String(bas + i));
    const tur = sec(TURLER);
    const per = (i) => `${e[i]} – ${e[i + 1]}`;
    let v;
    if (tur === 'azalis') {
      const s = dizi(adet, n).map((q) => q * adim), p = Math.floor(R() * (n - 1));
      [s[p], s[p + 1]] = [s[p + 1], s[p]]; v = s;
    } else if (tur === 'en_cok_artis') {
      for (let g = 0; ; g++) {
        const s = dizi(adet, n).map((q) => q * adim), d = s.slice(1).map((x, i) => x - s[i]), mx = Math.max(...d);
        if (d.filter((x) => x === mx).length === 1 && g < 500) { v = s; break; }
        if (g >= 500) throw new Error('veri_uretilemedi');
      }
    } else {
      v = karistir(Array.from({ length: adet }, (_, i) => (i + 1) * adim)).slice(0, n);
      if (tur === 'fark' || tur === 'toplam' || tur === 'oku' || tur === 'esit' || tur === 'en_cok' || tur === 'en_az') { /* serbest sıra */ }
    }
    const d = v.slice(1).map((x, i) => x - v[i]);
    const spec = { tip_id: 'a6-cizgi-grafigi', parametreler: { baslik: konu.baslik, etiketler: e, degerler: v, max, adim } };
    const ortak = { kod: ASIL, konu: KONU, alt_konu: ALT, spec };
    const on = kokOnek(konu.ad);
    const sirala = (secenekler, dogru, gerekceFn) => {
      const sirali = [...secenekler, dogru].sort((a, b) => a - b);
      return { sirali: sirali.map(bin), dogru: bin(dogru), gerekce: sirali.map((x) => (x === dogru ? '' : gerekceFn(x))) };
    };

    if (tur === 'oku') {
      const i = Math.floor(R() * n), cel = yakin(v.filter((_, q) => q !== i), v[i], adim);
      if (!cel) throw new Error('cel_yok');
      const o = sirala(cel, v[i], () => 'Bu değer, sorulan yılın değil, grafikteki başka bir yılın noktasının değeridir.');
      return ekle({ ...ortak, zorluk: 1, ...o, kok: `${on} ${e[i]} yılındaki ${konu.ad} kaç bindir?`,
        ipucu: 'Sorulan yılın noktasını bul; noktanın hangi yatay çizgiyle aynı hizada olduğuna bak.',
        cozum: [`${e[i]} yılının noktasından yatay eksene paralel gidilip dikey eksendeki değer okunur.`], dogrulama: [{ yol: ['degerler', e[i]], beklenen: v[i] }] });
    }
    if (tur === 'en_cok' || tur === 'en_az') {
      const en = tur === 'en_cok', h = en ? Math.max(...v) : Math.min(...v), i = v.indexOf(h);
      const sirali = [...v.keys()].filter((q) => q !== i).sort((a, b) => (en ? v[b] - v[a] : v[a] - v[b]));
      const cel = karistir(sirali.slice(0, 4)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 1, dogru: e[i], celdirici: cel.map((q) => e[q]),
        gerekce: cel.map((q) => `${e[q]} yılının noktası, grafikte en ${en ? 'yüksek' : 'alçak'} nokta değildir.`),
        kok: `${on} ${konu.ad} hangi yılda en ${en ? 'fazladır' : 'azdır'}?`,
        ipucu: `Grafikteki noktaları karşılaştır; çizginin en ${en ? 'yukarıda' : 'aşağıda'} olduğu noktaya bak.`,
        cozum: [`Noktalar dikey eksendeki yüksekliklerine göre karşılaştırılır.`, `En ${en ? 'yüksek' : 'alçak'} nokta hangi yıla aitse doğru cevap odur.`],
        dogrulama: [{ yol: ['degerler', e[i]], beklenen: h }] });
    }
    if (tur === 'fark' || tur === 'toplam') {
      const idx = [...v.keys()];
      let a, c, D;
      for (let g = 0; g < 100; g++) {
        const ik = karistir(idx).slice(0, 2); a = ik[0]; c = ik[1];
        if (tur === 'fark' && v[c] < v[a]) [a, c] = [c, a];
        D = tur === 'fark' ? v[c] - v[a] : v[a] + v[c];
        const hv = [];
        for (let p = 0; p < n; p++) for (let q = p + 1; q < n; q++) if (!((p === a && q === c) || (p === c && q === a))) hv.push(tur === 'fark' ? Math.abs(v[p] - v[q]) : v[p] + v[q]);
        const cel = yakin(hv, D, adim);
        if (cel && D > 0) {
          if (tur === 'fark') {
            const o = sirala(cel, D, () => 'Bu değer, sorulan iki yılın değil, grafikteki başka iki yılın noktaları arasındaki farktır.');
            return ekle({ ...ortak, zorluk: 2, ...o, kok: `${on} ${e[c]} yılındaki ${konu.ad}, ${e[a]} yılındakinden kaç bin fazladır?`,
              ipucu: 'İki yılın noktalarının değerlerini dikey eksenden oku; büyük olandan küçük olanı çıkar.',
              cozum: [`${e[c]} ve ${e[a]} yıllarının noktaları dikey eksenden okunur.`, 'İki değerin farkı alınır.'],
              dogrulama: [{ yol: ['degerler', e[c]], beklenen: v[c] }, { yol: ['degerler', e[a]], beklenen: v[a] }, { yol: ['artis', `${e[a]}|${e[c]}`], beklenen: D }] });
          }
          const o = sirala(cel, D, () => 'Bu değer, sorulan iki yılın değil, grafikteki başka iki yılın noktalarının toplamıdır.');
          return ekle({ ...ortak, zorluk: 2, ...o, kok: `${on} ${e[a]} ve ${e[c]} yıllarındaki ${konu.ad} toplamı kaç bindir?`,
            ipucu: 'İki yılın noktalarının değerlerini dikey eksenden oku ve topla.',
            cozum: [`${e[a]} ve ${e[c]} yıllarının noktaları dikey eksenden okunur.`, 'İki değer toplanır.'],
            dogrulama: [{ yol: ['degerler', e[a]], beklenen: v[a] }, { yol: ['degerler', e[c]], beklenen: v[c] }] });
        }
      }
      throw new Error('fark_uretilemedi');
    }
    if (tur === 'esit') {
      const ik = karistir([...v.keys()]).slice(0, 2), i = ik[0], j = ik[1];
      const w = [...v]; w[j] = w[i];
      const cel = karistir([...w.keys()].filter((q) => q !== i && q !== j)).slice(0, 3);
      if (cel.length < 3) throw new Error('cel_yok');
      const sp = { ...spec, parametreler: { ...spec.parametreler, degerler: w } };
      return ekle({ ...ortak, spec: sp, zorluk: 2, dogru: e[j], celdirici: cel.map((q) => e[q]),
        gerekce: cel.map((q) => `${e[q]} yılının noktası, ${e[i]} yılının noktasıyla aynı yatay çizgide değildir.`),
        kok: `${on} ${e[i]} yılındaki ${konu.ad} ile aynı olan başka yıl hangisidir?`,
        ipucu: `${e[i]} yılının noktasından yatay bir çizgi çiz; aynı yükseklikteki diğer noktaya bak.`,
        cozum: [`${e[i]} yılının noktasının yüksekliği belirlenir.`, 'Aynı yatay çizgiyle hizalı olan diğer nokta aranır.'],
        dogrulama: [{ yol: ['degerler', e[i]], beklenen: w[i] }, { yol: ['degerler', e[j]], beklenen: w[i] }] });
    }
    if (tur === 'azalis') {
      const hedef = d.findIndex((x) => x < 0);
      const cel = karistir(d.map((_, i) => i).filter((i) => i !== hedef)).slice(0, 3);
      return ekle({ ...ortak, zorluk: 1, dogru: per(hedef), celdirici: cel.map(per),
        gerekce: cel.map((i) => `${per(i)} döneminde çizgi aşağı inmemiştir; bu dönemde azalış görülmez.`),
        kok: `${on} ${konu.ad} hangi iki yıl arasında azalmıştır?`,
        ipucu: 'Çizginin aşağı doğru indiği bölümü bul.', cozum: ['Art arda gelen noktalar arasında çizginin yönüne bakılır.', 'Çizginin aşağı indiği dönem doğru cevaptır.'],
        dogrulama: [{ yol: ['azalis'], beklenen: [`${e[hedef]}|${e[hedef + 1]}`] }] });
    }
    // en_cok_artis
    const hedef = d.indexOf(Math.max(...d)), cel = karistir(d.map((_, i) => i).filter((i) => i !== hedef)).slice(0, 3);
    return ekle({ ...ortak, zorluk: 2, dogru: per(hedef), celdirici: cel.map(per),
      gerekce: cel.map((i) => `${per(i)} döneminde çizgi, en dik yükselen dönemdeki kadar yükselmemiştir.`),
      kok: `${on} ${konu.ad} hangi iki yıl arasında en çok ${konu.artti.replace('mıştır', 'mıştır')}?`,
      ipucu: 'Çizginin en dik çıktığı bölümü bul; iki noktanın dikey eksendeki farkını karşılaştır.',
      cozum: ['Art arda gelen noktaların dikey eksendeki farkları karşılaştırılır.', 'En dik yükselen dönem doğru cevaptır.'],
      dogrulama: [{ yol: ['en_cok_artis'], beklenen: `${e[hedef]}|${e[hedef + 1]}` }] });
  }
  return { cizgiSorusu };
}
export const KAYIT = [
  { id: 'sb6-ekonomi-cizgi', ders: 'Sosyal Bilgiler', sinif: 6, idOnek: 'SB6-EKO', mufredat_surum: MUFREDAT, kodlar: ['SB.6.5.1'], fabrika: kur, uret: (f) => f.cizgiSorusu() },
];
