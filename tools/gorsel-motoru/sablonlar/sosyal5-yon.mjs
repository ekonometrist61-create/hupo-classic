// 5. sınıf Sosyal Bilgiler — haritada ana ve ara yönler (göreceli konum).
const MUFREDAT = 'Maarif Modeli SB DÖP (tymm 2026-09-02)';
const YERLER = ['Okul', 'Park', 'Hastane', 'Market', 'Fırın', 'Banka', 'Stadyum', 'Postane', 'Belediye', 'Terminal', 'Kütüphane', 'Müze'];
const SON = { kuzey: 'kuzeyinde', güney: 'güneyinde', doğu: 'doğusunda', batı: 'batısında', kuzeydoğu: 'kuzeydoğusunda', kuzeybatı: 'kuzeybatısında', güneydoğu: 'güneydoğusunda', güneybatı: 'güneybatısında' };
const ANA = ['kuzey', 'güney', 'doğu', 'batı'];
const ARA = ['kuzeydoğu', 'kuzeybatı', 'güneydoğu', 'güneybatı'];
const VEC = { kuzey: [0, -1], güney: [0, 1], doğu: [1, 0], batı: [-1, 0], kuzeydoğu: [1, -1], kuzeybatı: [-1, -1], güneydoğu: [1, 1], güneybatı: [-1, 1] };

export function kur({ R, sec, karistir, ekle }) {
  function yonSorusu(ara) {
    const en = sec([3, 4]), boy = 3, n = sec([5, 6]);
    const ad = karistir(YERLER.filter((x) => x.length <= 8)).slice(0, n);
    const hucre = karistir(Array.from({ length: en * boy }, (_, i) => i)).slice(0, n);
    const yerler = ad.map((a, i) => ({ ad: a, x: hucre[i] % en, y: Math.floor(hucre[i] / en) }));
    const yon = sec(ara ? ARA : ANA), X = sec(yerler), [vx, vy] = VEC[yon];
    const aday = yerler.filter((p) => p !== X && (p.x - X.x) * vy === (p.y - X.y) * vx && Math.sign(p.x - X.x) === vx && Math.sign(p.y - X.y) === vy && (vx === 0 || vy === 0 || Math.abs(p.x - X.x) === Math.abs(p.y - X.y)));
    if (aday.length !== 1) throw new Error('tek_aday_degil');
    const Y = aday[0], cel = karistir(yerler.filter((p) => p !== X && p !== Y)).slice(0, 3);
    if (cel.length < 3) throw new Error('yetersiz_yer');
    const spec = { tip_id: 'yer-haritasi', parametreler: { en, boy, yerler } };
    ekle({ kod: 'SB.5.2.1', konu: 'Yaşadığım Yer', alt_konu: ara ? 'Ara yönler' : 'Ana yönler', zorluk: ara ? 3 : 2, spec, dogru: Y.ad, celdirici: cel.map((c) => c.ad),
      gerekce: cel.map((c) => { const dx = c.x - X.x, dy = c.y - X.y; const ayni = dx === 0 || dy === 0 || Math.abs(dx) === Math.abs(dy); const y2 = ayni ? Object.entries(VEC).find(([, v]) => v[0] === Math.sign(dx) && v[1] === Math.sign(dy))?.[0] : null; return y2 ? `${c.ad}, ${X.ad} yerinin ${SON[y2]} bulunur; istenen yön ${yon} yönüdür.` : `${c.ad}, ${X.ad} yeri ile aynı doğrultuda değildir.`; }),
      kok: `Yukarıdaki haritada ${X.ad} yerinin ${SON[yon]} bulunan yer aşağıdakilerden hangisidir?`,
      ipucu: 'Haritanın yukarısı kuzeydir. Pusulaya bakarak yönü bul ve o yönde ilerle.',
      cozum: ['Pusulaya göre haritanın üstü kuzey, altı güney, sağı doğu, solu batıdır.', `${X.ad} yerinden ${yon} yönüne gidildiğinde ${Y.ad} yerine ulaşılır.`],
      dogrulama: [{ yol: ['yonler', `${X.ad}|${Y.ad}`], beklenen: yon }] });
  }
  return { yonSorusu };
}

export const KAYIT = [
  { id: 'sb5-ana-yon', ders: 'Sosyal Bilgiler', sinif: 5, idOnek: 'SB5-YON', mufredat_surum: MUFREDAT, kodlar: ['SB.5.2.1'], fabrika: kur, uret: (f) => f.yonSorusu(false) },
  { id: 'sb5-ara-yon', ders: 'Sosyal Bilgiler', sinif: 5, idOnek: 'SB5-YON', mufredat_surum: MUFREDAT, kodlar: ['SB.5.2.1'], fabrika: kur, uret: (f) => f.yonSorusu(true) },
];

