// 7. sınıf İngilizce (önceki program) — biyografi zaman çizelgesi: geçmiş olaylar ve yıllar. Şekil: b4-zaman.
import { ERKEK, KADIN } from '../tipler-b4.mjs';

const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (İngilizce 7. sınıf; program: önceki program)';
const OLAY = [['Start school', 'started school'], ['Learn to swim', 'learned to swim'], ['Win a prize', 'won a prize'], ['Move to a new city', 'moved to a new city'], ['Buy a bike', 'bought a bike'],
  ['Join a music club', 'joined a music club'], ['Visit London', 'visited London'], ['Get a dog', 'got a dog'], ['Write a story', 'wrote a story'], ['Play in a concert', 'played in a concert'],
  ['Climb a mountain', 'climbed a mountain'], ['Finish school', 'finished school'], ['Open a shop', 'opened a shop'], ['Make a film', 'made a film']];

export function kur({ R, sec, karistir, ekle }) {
  function zamanSorusu() {
    const o = karistir(OLAY).slice(0, 5), kadin = R() < 0.5, ad = sec(kadin ? KADIN : ERKEK), s = kadin ? 'she' : 'he', S = kadin ? 'She' : 'He';
    const yil = [1985 + Math.floor(R() * 20)]; for (let i = 1; i < 5; i++) yil.push(yil[i - 1] + 2 + Math.floor(R() * 7));
    const spec = { tip_id: 'b4-zaman', parametreler: { baslik: `${ad}'s life`, olaylar: o.map((e, i) => ({ yil: yil[i], etiket: e[0] })) } };
    const ortak = { kod: 'E7.3.R1', konu: 'Biographies: events and dates', spec };
    const dogrulama = o.map((e, i) => ({ yol: ['yil', e[0]], beklenen: yil[i] }));
    const kind = sec(['yil', 'olay', 'once', 'sonra']), i = Math.floor(R() * 5), b = (e) => e[0].toLowerCase(), cumle = (e) => `${S} ${e[1]}.`;
    if (kind === 'yil') {
      const cel = karistir([0, 1, 2, 3, 4].filter((j) => j !== i)).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Olayın yılını bulma', zorluk: 1, kok: `Look at the timeline. When did ${ad} ${b(o[i])}?`, dogru: `In ${yil[i]}.`, celdirici: cel.map((j) => `In ${yil[j]}.`),
        gerekce: cel.map((j) => `${yil[j]} yılında ${o[j][0]} olayı gerçekleşir.`), ipucu: `Çizelgede "${o[i][0]}" yazısını bul ve yanındaki yılı oku.`, cozum: [`"${o[i][0]}" olayının yanında ${yil[i]} yazar.`], dogrulama });
    } else if (kind === 'olay') {
      const cel = karistir([0, 1, 2, 3, 4].filter((j) => j !== i)).slice(0, 3);
      ekle({ ...ortak, alt_konu: 'Yıldan olayı bulma', zorluk: 2, kok: `Look at the timeline. What did ${ad} do in ${yil[i]}?`, dogru: cumle(o[i]), celdirici: cel.map((j) => cumle(o[j])),
        gerekce: cel.map((j) => `Bu olay ${yil[j]} yılındadır.`), ipucu: `${yil[i]} yılını bul ve işaretli olayı oku.`, cozum: [`${yil[i]} yılında "${o[i][0]}" yazar.`, cumle(o[i])], dogrulama });
    } else {
      const k = kind === 'once' ? Math.max(i, 1) : Math.min(i, 3), hedef = kind === 'once' ? k - 1 : k + 1;
      const cel = [0, 1, 2, 3, 4].filter((j) => j !== k && j !== hedef);
      ekle({ ...ortak, alt_konu: kind === 'once' ? 'Öncesindeki olay' : 'Sonrasındaki olay', zorluk: 3,
        kok: `Look at the timeline. What did ${ad} do just ${kind === 'once' ? 'before' : 'after'} ${s} ${o[k][1]}?`, dogru: cumle(o[hedef]), celdirici: cel.map((j) => cumle(o[j])),
        gerekce: cel.map((j) => `Bu olay "${o[k][0]}" olayından hemen ${kind === 'once' ? 'önce' : 'sonra'} gerçekleşmez (${yil[j]}).`), ipucu: 'Olayları yıllara göre soldan sağa sırala.',
        cozum: [`"${o[k][0]}" olayı ${yil[k]} yılındadır.`, `Hemen ${kind === 'once' ? 'önceki' : 'sonraki'} olay: ${o[hedef][0]} (${yil[hedef]}).`], dogrulama });
    }
  }
  return { zamanSorusu };
}

export const KAYIT = [
  { id: 'eng7-zaman-cizelgesi', ders: 'İngilizce', sinif: 7, idOnek: 'ENG7-ZAM', mufredat_surum: MUFREDAT, kodlar: ['E7.3.R1'], fabrika: kur, uret: (f) => f.zamanSorusu() },
];
