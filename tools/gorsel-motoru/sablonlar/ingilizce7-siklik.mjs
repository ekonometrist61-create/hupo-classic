// 7. sınıf İngilizce (önceki program) — sıklık zarfları (always, usually, sometimes, never): haftalık etkinlik çizelgesi. Şekil: b4-tablo (onay işaretli).
import { GUN3, ERKEK, KADIN } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 7. sınıf; program: önceki program)';
const ETK = [['Tennis', 'play tennis', 'plays tennis'], ['Swimming', 'swim', 'swims'], ['Chess', 'play chess', 'plays chess'], ['Running', 'run', 'runs'], ['Cycling', 'ride a bike', 'rides a bike'], ['Volleyball', 'play volleyball', 'plays volleyball'], ['Karate', 'do karate', 'does karate'], ['Basketball', 'play basketball', 'plays basketball']];
const ADV = [['always', [7]], ['usually', [5, 6]], ['sometimes', [2, 3]], ['never', [0]]];

export function kur({ R, sec, karistir, ekle }) {
  function siklikSorusu() {
    const etk = karistir(ETK).slice(0, 4), adv = karistir(ADV), kadin = R() < 0.5, ad = sec(kadin ? KADIN : ERKEK), o = kadin ? 'She' : 'He';
    const sayi = adv.map(([, r]) => sec(r));
    const satirlar = etk.map((e) => ({ ad: e[0], hucreler: [] }));
    // gün seçimi satır başına bir kez yapılsın
    for (let i = 0; i < 4; i++) { const gunler = new Set(karistir([0, 1, 2, 3, 4, 5, 6]).slice(0, sayi[i])); satirlar[i].hucreler = GUN3.map((_, d) => (gunler.has(d) ? 'x' : '')); }
    const spec = { tip_id: 'b4-tablo', parametreler: { baslik: `${ad}'s week`, sutunlar: GUN3, tik: true, satirlar } };
    const ortak = { kod: 'E7.2.R1', konu: 'Sports and frequency adverbs', spec };
    const dogrulama = etk.map((e, i) => ({ yol: ['tik', e[0]], beklenen: sayi[i] }));
    const i = Math.floor(R() * 4), kind = sec(['sik', 'dogru', 'hep', 'hic']);
    const cumle = (j, a) => `${o} ${a} ${etk[j][2]}.`;
    if (kind === 'sik') {
      ekle({ ...ortak, alt_konu: 'Sıklığı söyleme', zorluk: 2, kok: `Look at the table. How often does ${ad} ${etk[i][1]}?`, dogru: cumle(i, adv[i][0]), celdirici: adv.filter((_, j) => j !== i).map(([a]) => cumle(i, a)),
        gerekce: adv.filter((_, j) => j !== i).map(([a]) => `"${a}" bu etkinlik için uygun değil; çizelgede ${sayi[i]} gün işaretlidir.`), ipucu: 'Satırdaki onay işaretlerini say: 7 gün = always, 5-6 = usually, 2-3 = sometimes, 0 = never.',
        cozum: [`${etk[i][0]} satırında ${sayi[i]} işaret vardır.`, `${sayi[i]} gün için uygun zarf "${adv[i][0]}".`], dogrulama });
    } else if (kind === 'dogru') {
      const f = i, dig = [0, 1, 2, 3].filter((j) => j !== f), dr = R() < 0.5 ? [dig[1], dig[2], dig[0]] : [dig[2], dig[0], dig[1]];
      const ata = { [f]: adv[f][0] }; dig.forEach((j, k) => { ata[j] = adv[dr[k]][0]; });
      ekle({ ...ortak, alt_konu: 'Doğru cümleyi seçme', zorluk: 3, kok: 'Look at the table. Which sentence is true?', dogru: cumle(f, ata[f]), celdirici: dig.map((j) => cumle(j, ata[j])),
        gerekce: dig.map((j) => `"${ata[j]}" ${etk[j][0]} için yanlıştır; çizelgede ${sayi[j]} gün işaretlidir ("${adv[j][0]}").`), ipucu: 'Her cümle için ilgili satırdaki işaretleri say.',
        cozum: [`${etk[f][0]} satırında ${sayi[f]} işaret vardır.`, `Doğru cümle: ${cumle(f, ata[f])}`], dogrulama });
    } else {
      const hedef = kind === 'hep' ? adv.findIndex(([a]) => a === 'always') : adv.findIndex(([a]) => a === 'never');
      ekle({ ...ortak, alt_konu: kind === 'hep' ? 'Her gün yapılan etkinlik' : 'Hiç yapılmayan etkinlik', zorluk: 2,
        kok: kind === 'hep' ? `Look at the table. Which activity does ${ad} do every day?` : `Look at the table. Which activity does ${ad} never do?`,
        dogru: etk[hedef][0], celdirici: etk.filter((_, j) => j !== hedef).map((e) => e[0]),
        gerekce: etk.map((e, j) => (j === hedef ? '' : `${e[0]} satırında ${sayi[j]} işaret vardır; ${kind === 'hep' ? '7' : '0'} işaret aranır.`)).filter(Boolean),
        ipucu: kind === 'hep' ? 'Haftanın yedi gününde de onay işareti olan satırı bul.' : 'Hiç onay işareti olmayan satırı bul.', cozum: [`${etk[hedef][0]} satırında ${sayi[hedef]} işaret vardır.`], dogrulama });
    }
  }
  return { siklikSorusu };
}

export const KAYIT = [
  { id: 'eng7-siklik-cizelgesi', ders: 'İngilizce', sinif: 7, idOnek: 'ENG7-SIK', mufredat_surum: MUFREDAT, kodlar: ['E7.2.R1'], fabrika: kur, uret: (f) => f.siklikSorusu() },
];

