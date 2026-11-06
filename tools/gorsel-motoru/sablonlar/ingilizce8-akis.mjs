// 8. sınıf İngilizce (önceki program) — mutfakta bir işlemin (process) adımlarını sıralama. Şekil: b4-akis.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 8. sınıf; program: önceki program)';
const ISLEMLER = [
  { baslik: 'How to make a smoothie', basta: [], sonda: ['Blend everything', 'Pour it into a glass'], havuz: ['milk', 'banana', 'honey', 'ice', 'strawberries', 'yogurt'] },
  { baslik: 'How to make a sandwich', basta: ['Take two slices of bread'], sonda: ['Close the sandwich'], havuz: ['cheese', 'tomato', 'lettuce', 'egg', 'ham', 'cucumber'] },
  { baslik: 'How to make a fruit salad', basta: [], sonda: ['Mix gently', 'Serve in a bowl'], havuz: ['apple', 'banana', 'grapes', 'orange', 'kiwi', 'melon'] },
];

export function kur({ R, sec, karistir, ekle }) {
  function akisSorusu() {
    const P = sec(ISLEMLER), ic = karistir(P.havuz).slice(0, 5), ekleAdim = (x) => `Add the ${x}`;
    const adimlar = [...P.basta, ...ic.map(ekleAdim), ...P.sonda];
    const spec = { tip_id: 'b4-akis', parametreler: { baslik: P.baslik, adimlar } };
    const ortak = { kod: 'E8.3.R1', konu: 'In the kitchen: processes', spec };
    const dogrulama = [{ yol: ['sira'], beklenen: adimlar }];
    const kind = sec(['sonra', 'once', 'ilk', 'son', 'cumle']), noktali = (t) => `${t}.`;
    if (kind === 'sonra' || kind === 'once') {
      const k = kind === 'sonra' ? Math.floor(R() * 4) : 1 + Math.floor(R() * 4), hedef = kind === 'sonra' ? k + 1 : k - 1;
      const adaylar = ic.filter((x, j) => j !== k && j !== hedef).map(ekleAdim), cel = karistir(adaylar).slice(0, 3);
      ekle({ ...ortak, alt_konu: kind === 'sonra' ? 'Sonraki adım' : 'Önceki adım', zorluk: 2, kok: `Look at the diagram. What do you do ${kind === 'sonra' ? 'after' : 'before'} you add the ${ic[k]}?`, dogru: noktali(ekleAdim(ic[hedef])), celdirici: cel.map(noktali),
        gerekce: cel.map((a) => `"${a}" adımı "${ekleAdim(ic[k])}" adımının hemen ${kind === 'sonra' ? 'sonrasında' : 'öncesinde'} değildir.`), ipucu: 'Okların yönünü izle: oklar yukarıdan aşağıya doğrudur.',
        cozum: [`"${ekleAdim(ic[k])}" kutusunu bul.`, `Hemen ${kind === 'sonra' ? 'sonraki' : 'önceki'} kutu: "${ekleAdim(ic[hedef])}".`], dogrulama });
    } else if (kind === 'ilk' || kind === 'son') {
      const h = kind === 'ilk' ? ic[0] : ic[4], cel = karistir(ic.filter((x) => x !== h)).slice(0, 3);
      ekle({ ...ortak, alt_konu: kind === 'ilk' ? 'İlk malzeme' : 'Son malzeme', zorluk: 1, kok: `Look at the diagram. Which ingredient do you add ${kind === 'ilk' ? 'first' : 'last'}?`, dogru: `The ${h}.`, celdirici: cel.map((x) => `The ${x}.`),
        gerekce: cel.map((x) => `"${ekleAdim(x)}" adımı ${kind === 'ilk' ? 'ilk' : 'son'} malzeme adımı değildir.`), ipucu: `Akışta "Add the ..." kutularını yukarıdan aşağıya sırayla oku.`,
        cozum: [`Malzeme sırası: ${ic.join(', ')}.`, `${kind === 'ilk' ? 'İlk' : 'Son'} malzeme: ${h}.`], dogrulama });
    } else {
      const perm = (a) => a.map((x, i, d) => d[(i + 0) % d.length]), sirali = [ic];
      let g = 0; const gor = new Set([ic.join()]);
      while (sirali.length < 4 && g++ < 200) { const p = karistir(ic); if (!gor.has(p.join())) { gor.add(p.join()); sirali.push(p); } }
      if (sirali.length < 4) throw new Error('permutasyon_yok');
      const metin = (p) => `First, add the ${p[0]}. Then, add the ${p[1]}. Next, add the ${p[2]}. After that, add the ${p[3]}. Finally, add the ${p[4]}.`;
      ekle({ ...ortak, alt_konu: 'Sıralamayı cümleyle anlatma', zorluk: 3, kok: 'Look at the diagram. Which sentence describes the order of the ingredients?', dogru: metin(ic), celdirici: sirali.slice(1).map(metin),
        gerekce: sirali.slice(1).map((p) => `Bu cümledeki malzeme sırası (${p.join(' - ')}) akıştaki sıra ile (${ic.join(' - ')}) aynı değildir.`), ipucu: 'Önce akıştaki malzeme sırasını yaz, sonra cümlelerle karşılaştır.',
        cozum: [`Akıştaki sıra: ${ic.join(' - ')}.`, `First, Then, Next, Finally sözcükleri bu sırayı verir.`], dogrulama });
    }
  }
  return { akisSorusu };
}

export const KAYIT = [
  { id: 'eng8-akis-semasi', ders: 'İngilizce', sinif: 8, idOnek: 'ENG8-AKS', mufredat_surum: MUFREDAT, kodlar: ['E8.3.R1'], fabrika: kur, uret: (f) => f.akisSorusu() },
];
