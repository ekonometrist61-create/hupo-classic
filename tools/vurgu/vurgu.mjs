// Soru kökü vurgu önericisi + denetçisi (çevrimdışı, kural tabanlı; çalışma anında AI çağrısı yok).
// Ofsetler soru_metni içinde Unicode KOD NOKTASI cinsindendir: [{ start, end }], end hariç.
// Soru metni asla değiştirilmez; yalnız aralık üretilir.

const HARF = '\\p{L}';
const W = (s) => `(?<!${HARF})(?:${s})(?!${HARF})`;

// Uzunluğu koruyan Türkçe küçük harf (İ→i, I→ı); ofsetler kaymasın.
export function trKucuk(s) {
  return Array.from(s).map((c) => (c === 'İ' ? 'i' : c === 'I' ? 'ı' : c.toLowerCase().length === 1 ? c.toLowerCase() : c)).join('');
}

const OLUMSUZ = new RegExp(
  W('değildir|değil|yanlıştır|yanlış|olamaz|çıkarılamaz|çıkarılamayacak|söylenemez|ulaşılamaz|denemez|yoktur|bulunmaz|yer almaz|kullanılmaz'),
  'gu',
);
const KESIN = new RegExp(`kesin olarak(?:\\s+${HARF}+){1,2}`, 'gu');
const KARSILASTIRMA = new RegExp(
  `(?:${W('en')}\\s+(?:büyük|küçük|az|çok|fazla|uzun|kısa|yüksek|düşük|hızlı|yavaş|geniş|dar|uygun|olası|güvenilir|doğru|yakın)[\\p{L}]*(?:\\s+(?!en(?!\\p{L})|hangi|kaç)${HARF}+)?|${W('daha')}\\s+(?:fazla|az|çok|büyük|küçük|uzun|kısa))`,
  'gu',
);
const MATEMATIK = new RegExp(
  `\\d[\\d.,]*\\s+(?:${HARF}+\\s+)?(?:katının|katı|fazlası|eksiği|yarısı|çeyreği)(?:\\s+\\d[\\d.,]*\\s+(?:fazlası|eksiği))?`,
  'gu',
);
const KAVRAM_ISARETI = new RegExp(
  W('temel nedeni|asıl nedeni|ana nedeni|nedeni|ana fikri|ana düşüncesi|asıl amacı|amacı|sonucu|görevi'),
  'gu',
);
const KAVRAM_DURAK = new Set([
  'üzerinde', 'içinde', 'metne', 'göre', 'bu', 'şu', 'aşağıdakilerden', 'hangisi', 'hangisidir', 'nedir',
  'parçanın', 'metnin', 'hangi', 'hakkında', 'ile', 'da', 'de', 'için', 'en', 'çok', 'ise',
]);

function cumleBul(metin) {
  // Soru kökü: son paragrafın son cümlesi (metin + kök yapısında kök sondadır).
  const paragraf = metin.lastIndexOf('\n') + 1;
  let bas = paragraf;
  const govde = metin.slice(paragraf);
  // Paragraf içinde birden fazla cümle varsa son '?' cümlesini al.
  const m = [...govde.matchAll(/[^.!?]*[.!?]/gu)];
  if (m.length > 2) bas = paragraf + m[m.length - 1].index;
  return { bas, kok: metin.slice(bas) };
}

function kodNoktasiOfseti(metin, utf16Ofset) {
  return Array.from(metin.slice(0, utf16Ofset)).length;
}

function aralik(metin, utf16Bas, utf16Bit) {
  return { start: kodNoktasiOfseti(metin, utf16Bas), end: kodNoktasiOfseti(metin, utf16Bit) };
}

function sonEsleme(re, kucuk) {
  re.lastIndex = 0;
  let son = null;
  for (const m of kucuk.matchAll(re)) son = m;
  return son;
}

function kavramAraligi(kok, kucukKok) {
  const m = sonEsleme(KAVRAM_ISARETI, kucukKok);
  if (!m) return null;
  // İşaretten geriye en çok 4 sözcük; durak sözcükte dur.
  const onceki = kok.slice(0, m.index);
  const sozcukler = [...onceki.matchAll(new RegExp(`${HARF}+`, 'gu'))];
  let basIdx = m.index;
  let sayi = 0;
  for (let i = sozcukler.length - 1; i >= 0 && sayi < 4; i--) {
    const s = sozcukler[i];
    if (KAVRAM_DURAK.has(trKucuk(s[0]))) break;
    basIdx = s.index;
    sayi++;
  }
  if (sayi < 2) return null; // tek sözcük ('işleminin') anlamlı vurgu değil → editör/LLM
  // İşaretin kendisini vurguya katma değil, kavramı vurgula: "gece ve gündüzün oluşmasının | temel nedeni"
  // Referans görselde kavram + 'temel nedeni' ayrı değil; yalnız kavram öbeği vurgulanır.
  return { bas: basIdx, bit: m.index - (kok.slice(basIdx, m.index).match(/\s*$/u)?.[0].length ?? 0) };
}

/** Öneri üretir. durum: 'otomatik' | 'inceleme' (editör) | 'yok' (vurgusuz daha doğal). */
export function vurguOner(soruMetni) {
  const { bas, kok } = cumleBul(soruMetni);
  const kucuk = trKucuk(kok);
  const adaylar = [];
  const ekle = (m, tur, oncelik) => {
    if (m) adaylar.push({ tur, oncelik, bas: bas + m.index, bit: bas + m.index + m[0].length });
  };

  ekle(sonEsleme(OLUMSUZ, kucuk), 'olumsuz', 1);
  ekle(sonEsleme(KESIN, kucuk), 'cikarim', 1);
  ekle(sonEsleme(MATEMATIK, kucuk), 'matematik', 2);
  ekle(sonEsleme(KARSILASTIRMA, kucuk), 'karsilastirma', 2);
  const kav = kavramAraligi(kok, kucuk);
  if (kav) adaylar.push({ tur: 'kavram', oncelik: 3, bas: bas + kav.bas, bit: bas + kav.bit });

  if (adaylar.length === 0) {
    return { highlights: [], durum: 'inceleme', neden: 'kural eşleşmedi' };
  }
  adaylar.sort((a, b) => a.oncelik - b.oncelik || a.bas - b.bas);
  // Birbiriyle çakışmayan en çok 2 kısa ifade.
  const secilen = [];
  for (const a of adaylar) {
    if (secilen.length >= 2) break;
    if (secilen.some((s) => a.bas < s.bit && s.bas < a.bit)) continue;
    secilen.push(a);
  }
  secilen.sort((a, b) => a.bas - b.bas);
  return {
    highlights: secilen.map((s) => aralik(soruMetni, s.bas, s.bit)),
    turler: secilen.map((s) => s.tur),
    durum: 'otomatik',
  };
}

const norm = (s) => trKucuk(String(s)).replace(/[^\p{L}\p{N}]+/gu, ' ').trim();

/**
 * Denetim: metin değişmedi/aralık geçerli mi, oran, bütün kök, cevap sızıntısı.
 * Dönüş: { ok, hatalar[], uyarilar[], oran }
 */
export function vurguDenetle({ soruMetni, highlights, siklar = {}, dogruSik }) {
  const hatalar = [];
  const uyarilar = [];
  const cp = Array.from(soruMetni);
  const { bas: kokBasUtf16, kok } = cumleBul(soruMetni);
  const kokBas = kodNoktasiOfseti(soruMetni, kokBasUtf16);
  const kokUzunluk = Array.from(kok).length;

  if (!Array.isArray(highlights)) return { ok: false, hatalar: ['highlights dizi değil'], uyarilar, oran: 0 };
  if (highlights.length === 0) return { ok: true, hatalar, uyarilar: ['vurgusuz'], oran: 0 };
  if (highlights.length > 2) hatalar.push('en çok 2 ifade');

  let toplam = 0;
  let onceki = -1;
  const parcalar = [];
  for (const h of highlights) {
    if (!Number.isInteger(h?.start) || !Number.isInteger(h?.end) || h.start < 0 || h.end > cp.length || h.start >= h.end) {
      hatalar.push(`geçersiz aralık ${JSON.stringify(h)}`);
      continue;
    }
    if (h.start < onceki) hatalar.push('aralıklar sıralı/çakışmasız değil');
    onceki = h.end;
    if (h.start < kokBas) hatalar.push('vurgu soru kökü dışında (paragraf/hikâye metni)');
    const parca = cp.slice(h.start, h.end).join('');
    if (parca !== parca.trim()) hatalar.push('aralık boşlukla başlıyor/bitiyor');
    parcalar.push(parca);
    toplam += h.end - h.start;
  }
  const oran = kokUzunluk ? toplam / kokUzunluk : 0;
  if (oran >= 0.95) hatalar.push('bütün kök vurgulanmış');
  else if (oran > 0.45) hatalar.push(`oran çok yüksek (%${Math.round(oran * 100)})`);
  else if (oran > 0.35 || oran < 0.15) uyarilar.push(`oran %15–35 dışında (%${Math.round(oran * 100)})`);

  // Cevap sızıntısı: vurgu şık metnini içermemeli; vurgu doğru şıkla özdeş/onun içinde kalmamalı.
  const dogruMetin = dogruSik && siklar[dogruSik] ? norm(siklar[dogruSik]) : '';
  for (const p of parcalar) {
    const pn = norm(p);
    if (!pn) continue;
    for (const [harf, metin] of Object.entries(siklar)) {
      const sn = norm(metin);
      if (sn.length >= 3 && (pn.includes(sn) || (sn === pn))) {
        hatalar.push(`vurgu şık ${harf} metnini içeriyor`);
      }
    }
    if (dogruMetin.length >= 4 && dogruMetin.includes(pn) && pn.split(' ').length >= 2) {
      hatalar.push('vurgu doğru şıkkın içinde geçiyor (olası sızıntı)');
    }
  }
  return { ok: hatalar.length === 0, hatalar, uyarilar, oran };
}

/** Metni değiştirmeden vurguyu parçalara böler (testlerde render doğrulaması için). */
export function parcala(soruMetni, highlights) {
  const cp = Array.from(soruMetni);
  const out = [];
  let i = 0;
  for (const h of highlights) {
    if (h.start > i) out.push({ metin: cp.slice(i, h.start).join(''), vurgu: false });
    out.push({ metin: cp.slice(h.start, h.end).join(''), vurgu: true });
    i = h.end;
  }
  if (i < cp.length) out.push({ metin: cp.slice(i).join(''), vurgu: false });
  return out;
}



