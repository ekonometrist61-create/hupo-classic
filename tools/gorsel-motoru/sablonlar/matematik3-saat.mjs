// 3. sınıf Matematik — analog ve dijital saatlerde zamanı okuma ve yazma (MAT.3.1.12). Şekil tipi: b1-saat (tipler-b1.mjs).
// Üç soru türü: analog saati dijital yazma, dijital zamana uyan analog saati seçme, gösterilen saatten belli bir süre sonrasını yazma.
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Matematik 3. sınıf; program: TYMM)';
const yaz = (h, m) => `${h}:${String(m).padStart(2, '0')}`;
const w12 = (x) => ((((x - 1) % 12) + 12) % 12) + 1;

export function kur({ R, sec, karistir, ekle, konum }) {
  const rastgele = () => ({ h: 1 + Math.floor(R() * 12), m: 5 * Math.floor(R() * 12) });
  // Yaygın yanılgılardan yanlış zamanlar (h:m ile aynı olmayanlar)
  function yanlislar(h, m) {
    const a = [
      { h: m / 5 || 12, m: (h % 12) * 5, g: 'akrep ile yelkovan karıştırılmıştır (kısa ve kalın çubuk saati, uzun çubuk dakikayı gösterir)' },
      { h: w12(h + 1), m, g: 'saat bir fazla okunmuştur; akrep henüz o sayıya ulaşmamıştır' },
      { h: w12(h - 1), m, g: 'saat bir eksik okunmuştur' },
      { h, m: (60 - m) % 60, g: 'dakika, yelkovanın gösterdiği sayının tersinden okunmuştur' },
      { h, m: (m + 5) % 60, g: 'yelkovan bir sayı ileri okunmuştur' },
      { h, m: (m + 55) % 60, g: 'yelkovan bir sayı geri okunmuştur' },
    ];
    if (m >= 5 && m < 50) a.push({ h, m: m / 5, g: 'yelkovanın gösterdiği sayı doğrudan dakika sanılmıştır (her sayı 5 dakikadır)' });
    return karistir(a.filter((x) => !(x.h === h && x.m === m)));
  }
  function ayri(liste, h, m, n) {
    const gor = new Set([yaz(h, m)]), c = [];
    for (const x of liste) { const s = yaz(x.h, x.m); if (!gor.has(s)) { gor.add(s); c.push({ ...x, s }); } if (c.length === n) break; }
    if (c.length < n) throw new Error('celdirici_yok');
    return c;
  }
  function okuma() {
    const { h, m } = rastgele(), d = yaz(h, m), c = ayri(yanlislar(h, m), h, m, 3);
    ekle({ kod: 'MAT.3.1.12', konu: 'Zaman', alt_konu: 'Analog saati dijital yazma', zorluk: m % 15 === 0 ? 1 : 2, dogru: d, celdirici: c.map((x) => x.s),
      gerekce: c.map((x) => `${x.s}: ${x.g}.`),
      kok: sec(['Yukarıdaki analog saat hangi zamanı göstermektedir?', 'Yukarıdaki saatin gösterdiği zaman dijital saatte nasıl yazılır?', 'Yukarıdaki saatte akrep ve yelkovan hangi zamanı gösterir?']),
      ipucu: 'Kısa ve kalın çubuk saati, uzun ve ince çubuk dakikayı gösterir. Yelkovan her sayıda 5 dakika ilerler.',
      cozum: [`Akrep (kısa çubuk) ${h} sayısını ${m === 0 ? 'tam olarak gösterir' : 'geçmiştir'}; saat ${h}.`, `Yelkovan (uzun çubuk) ${m / 5 || 12}. sayıyı gösterir: ${m} dakika.`, `Zaman ${d}.`],
      spec: { tip_id: 'b1-saat', parametreler: { saatler: [{ h, m }] } }, dogrulama: [{ yol: ['saat'], beklenen: d }] });
  }
  function eslestir() {
    const { h, m } = rastgele(), d = yaz(h, m), c = ayri(yanlislar(h, m), h, m, 3), kp = konum();
    const saatler = [], gerekce = ['', '', '', ''];
    let j = 0;
    for (let i = 0; i < 4; i++) { if (i === kp) saatler.push({ h, m }); else { saatler.push({ h: c[j].h, m: c[j].m }); gerekce[i] = `${i + 1}. saat ${c[j].s} gösterir: ${c[j].g}.`; j++; } }
    const sirali = ['1. saat', '2. saat', '3. saat', '4. saat'];
    ekle({ kod: 'MAT.3.1.12', konu: 'Zaman', alt_konu: 'Dijital zamanı analog saatte bulma', zorluk: 2, sirali, dogru: sirali[kp], gerekce,
      kok: `Dijital saatte ${d} olarak yazılan zamanı gösteren saat hangisidir?`,
      ipucu: 'Önce yelkovanın hangi sayıyı göstermesi gerektiğini bul (dakikayı 5’e böl), sonra akrebe bak.',
      cozum: [`${d}: saat ${h}, dakika ${m}.`, `Yelkovan ${m / 5 || 12}. sayıyı, akrep ${h}. sayıya yakın bir yeri gösterir.`, `Bu zamanı ${kp + 1}. saat gösterir.`],
      spec: { tip_id: 'b1-saat', parametreler: { saatler } }, dogrulama: saatler.map((t, i) => ({ yol: ['saatler', String(i)], beklenen: yaz(t.h, t.m) })) });
  }
  function sonra() {
    const { h, m } = rastgele(), ekDk = sec([10, 15, 20, 25, 30, 35, 40, 45, 50, 55]), toplam = m + ekDk, h2 = w12(h + Math.floor(toplam / 60)), m2 = toplam % 60, d = yaz(h2, m2);
    const L = [{ h: toplam >= 60 ? h : h2, m: toplam >= 60 ? m2 : (m2 + 10) % 60, g: toplam >= 60 ? 'dakikalar 60’ı geçince saat bir ilerlemelidir; saat değişmemiştir' : 'dakika yanlış toplanmıştır' },
      { h: w12(h2 + 1), m: m2, g: 'saat bir fazla yazılmıştır' }, { h: w12(h2 - 1), m: m2, g: 'saat bir eksik yazılmıştır' },
      { h: h2, m: (m2 + 5) % 60, g: 'dakika 5 fazla yazılmıştır' }, { h: h2, m: (m2 + 55) % 60, g: 'dakika 5 eksik yazılmıştır' }, { h: h, m: m2, g: 'saat hiç ilerlememiştir' }];
    const c = ayri(karistir(L), h2, m2, 3);
    ekle({ kod: 'MAT.3.1.12', konu: 'Zaman', alt_konu: 'Saatte süre ekleme', zorluk: 3, dogru: d, celdirici: c.map((x) => x.s), gerekce: c.map((x) => `${x.s}: ${x.g}.`),
      kok: `Yukarıdaki saatte gösterilen zamandan ${ekDk} dakika sonra saat kaçı gösterir?`,
      ipucu: 'Önce saatin gösterdiği zamanı oku, sonra dakikaları ekle. 60 dakika 1 saattir.',
      cozum: [`Saat ${yaz(h, m)} gösteriyor.`, `${m} + ${ekDk} = ${toplam} dakika${toplam >= 60 ? '; 60 dakika 1 saat olduğundan saat bir ilerler' : ''}.`, `${ekDk} dakika sonra saat ${d} olur.`],
      spec: { tip_id: 'b1-saat', parametreler: { saatler: [{ h, m }] } }, dogrulama: [{ yol: ['saat'], beklenen: yaz(h, m) }] });
  }
  return { okuma, eslestir, sonra, secim: () => sec([okuma, okuma, eslestir, eslestir, sonra])() };
}

export const KAYIT = [
  { id: 'mat3-analog-saat', ders: 'Matematik', sinif: 3, idOnek: 'MAT3-SAT', mufredat_surum: MUFREDAT, kodlar: ['MAT.3.1.12'], fabrika: kur, uret: (f) => f.secim() },
];
