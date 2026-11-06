// Destek Planı etkinlik kütüphanesi (sabit, editoryal; docs/veli-ogretmen-paneli/AR-GE_VE_PLAN_2026-10-29.md §6 D, §7 F3).
// Öneriler kural tabanlıdır ve istemcide seçilir. Metinler tanı koymaz, puan veya sınav garantisi vermez,
// çocuğu kıyaslamaz. Yer tutucular: {metin} (kazanım cümlesi), {ders}, {konu}.
// Kod biçimi (public.veli_destek_isaretleri ile aynı): ^[a-z0-9_.:-]{3,80}$

export type Dil = "tr" | "en";
export type OneriTuru = "kazanim_gelisiyor" | "kazanim_bu_hafta" | "tekrar_konu";

/** Bir seferde gösterilen en fazla öneri kartı. */
export const KART_LIMITI = 3;

export const ONERI_KOD_DESENI = /^[a-z0-9_.:-]{3,80}$/;

interface Sablon {
  baslik: string;
  adimlar: string[];
  konusmaSorusu: string;
  birakma: string;
}

const SABLONLAR: Record<Dil, Record<OneriTuru, Sablon>> = {
  tr: {
    kazanim_gelisiyor: {
      baslik: "Bu kazanımda birlikte kısa bir çalışma",
      adimlar: [
        "Kazanım cümlesini birlikte okuyun: “{metin}”",
        "Bu kazanımla ilgili iki kısa soru seçin. Çocuk önce kendi cevabını düşünsün.",
        "Çocuk cevabını sesli anlatsın. Acele etmeyin; cevabı siz söylemeyin.",
        "Birlikte bir örnek çözün. Adımları çocuk söylesin, siz yönlendirin.",
        "Bitirirken çocuk bir cümleyle özetlesin: “Bugün … öğrendim.”",
      ],
      konusmaSorusu:
        "Bu kazanımda hangi kısım sana zor geliyor ve bunu kendi cümlelerinle nasıl anlatırsın?",
      birakma:
        "Çocuk yorulduysa ya da konu anlaşılmıyorsa 10 dakika dolmadan bırakın. Yarın tek bir soru bile yeterli bir başlangıç olur.",
    },
    kazanim_bu_hafta: {
      baslik: "Okulda bu hafta işlenen konuyu evde pekiştirin",
      adimlar: [
        "Kazanım cümlesini birlikte okuyun: “{metin}”",
        "Çocuktan bu hafta derste neyi duyduğunu iki cümleyle anlatmasını isteyin.",
        "Bir soruyu birlikte çözün, ardından benzer bir soruyu çocuk tek başına çözsün.",
        "Cevabını nasıl bulduğunu kısaca anlatmasını isteyin.",
      ],
      konusmaSorusu:
        "Bu hafta derste en çok neyi hatırlıyorsun ve bunu günlük hayatta nerede kullanabiliriz?",
      birakma:
        "Dikkati dağılıyorsa ya da isteksizse bugünlük bırakın. Tek bir soru bile yeterli bir başlangıçtır.",
    },
    tekrar_konu: {
      baslik: "“{konu}” konusunu kısa tekrar edin",
      adimlar: [
        "{ders} dersinde “{konu}” konusunu çocukla birlikte açın.",
        "Çocuktan konuyu üç cümleyle anlatmasını isteyin.",
        "Üç kısa soru birlikte çözün. Yanlış olursa sebebini birlikte konuşun.",
        "Bitirirken en çok hatırladığı şeyi bir cümleyle söyletin.",
      ],
      konusmaSorusu: "“{konu}” ile ilgili seni en çok şaşırtan şey neydi?",
      birakma:
        "Konu çocuğunuzu yoruyorsa bugünlük bırakın. Tekrar bir sonraki haftaya kalabilir.",
    },
  },
  en: {
    kazanim_gelisiyor: {
      baslik: "A short practice on this outcome, together",
      adimlar: [
        "Read the outcome sentence together: “{metin}”",
        "Pick two short questions on it. Let your child think about their own answer first.",
        "Ask your child to explain their answer out loud. Don't rush, and don't give the answer yourself.",
        "Solve one example together. Let your child say the steps while you guide.",
        "Finish with a one-sentence summary from your child: “Today I learned …”",
      ],
      konusmaSorusu:
        "Which part of this outcome feels hardest to you, and how would you explain it in your own words?",
      birakma:
        "If your child is tired or the topic isn't clicking, stop before 10 minutes. One question tomorrow is a good start.",
    },
    kazanim_bu_hafta: {
      baslik: "Reinforce this week's school topic at home",
      adimlar: [
        "Read the outcome together: “{metin}”",
        "Ask your child to tell you in two sentences what they heard in class this week.",
        "Solve one question together, then have your child solve a similar one alone.",
        "Ask them to briefly explain how they found the answer.",
      ],
      konusmaSorusu:
        "What do you remember most from class this week, and where could we use it in everyday life?",
      birakma:
        "If attention drifts or your child seems unwilling, stop for today. Even one question is a good start.",
    },
    tekrar_konu: {
      baslik: "A short review of “{konu}”",
      adimlar: [
        "Open “{konu}” in {ders} together with your child.",
        "Ask your child to explain the topic in three sentences.",
        "Solve three short questions together. If an answer is wrong, talk through why.",
        "Finish by asking what they remember best, in one sentence.",
      ],
      konusmaSorusu: "What surprised you most about “{konu}”?",
      birakma:
        "If the topic is tiring your child, switch for today. The review can wait until next week.",
    },
  },
};

export interface DestekOnerisi {
  /** Velinin "yaptık" işaretinde kullanılan kod (ONERI_KOD_DESENI ile uyumlu). */
  kod: string;
  tur: OneriTuru;
  ders: string;
  kazanimKodu: string | null;
  kazanimMetni: string | null;
  baslik: string;
  adimlar: string[];
  konusmaSorusu: string;
  birakma: string;
}

interface OneriGirdisi {
  kod: string;
  ders: string;
  kazanimKodu?: string | null;
  kazanimMetni?: string | null;
  konu?: string | null;
}

function doldur(metin: string, v: { metin?: string; ders?: string; konu?: string }): string {
  return metin.replace(/\{(metin|ders|konu)\}/g, (_, anahtar: "metin" | "ders" | "konu") => v[anahtar] ?? "");
}

// Türkçe karakterleri ASCII'ye indirip küçük harfe çevirir; kod dışı karakterleri "-" yapar.
function kodTemizle(metin: string, izinliNokta: boolean): string {
  const ascii = metin
    .toLocaleLowerCase("tr-TR")
    .replace(/ı/g, "i")
    .replace(/ğ/g, "g")
    .replace(/ş/g, "s")
    .replace(/ç/g, "c")
    .replace(/ö/g, "o")
    .replace(/ü/g, "u")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "");
  const desen = izinliNokta ? /[^a-z0-9._-]+/g : /[^a-z0-9]+/g;
  return ascii.replace(desen, "-").replace(/^[-._]+|[-._]+$/g, "");
}

/** Kazanım kodu → "kazanim:<kod>". Kodda büyük harf ve nokta olabilir; kod alanı küçük harfe indirilir. */
export function kazanimOnerisiKodu(kazanimKodu: string): string | null {
  const govde = kodTemizle(kazanimKodu, true).slice(0, 80 - "kazanim:".length);
  if (!/[a-z0-9]/.test(govde)) return null;
  const kod = `kazanim:${govde}`;
  return ONERI_KOD_DESENI.test(kod) ? kod : null;
}

/** Tekrar konusu → "tekrar:<ders>.<konu>". */
export function tekrarOnerisiKodu(ders: string, konu: string): string | null {
  const govde = `${kodTemizle(ders, false)}.${kodTemizle(konu, false)}`.slice(0, 80 - "tekrar:".length);
  if (!/[a-z0-9]/.test(govde)) return null;
  const kod = `tekrar:${govde}`;
  return ONERI_KOD_DESENI.test(kod) ? kod : null;
}

/** Öneri kartını seçili dilde üretir. Metin, kazanım ve konu alanlarını şablona yerleştirir. */
export function destekOnerisiOlustur(tur: OneriTuru, dil: Dil, girdi: OneriGirdisi): DestekOnerisi {
  const sablon = SABLONLAR[dil][tur];
  const v = { metin: girdi.kazanimMetni ?? undefined, ders: girdi.ders, konu: girdi.konu ?? undefined };
  return {
    kod: girdi.kod,
    tur,
    ders: girdi.ders,
    kazanimKodu: girdi.kazanimKodu ?? null,
    kazanimMetni: girdi.kazanimMetni ?? null,
    baslik: doldur(sablon.baslik, v),
    adimlar: sablon.adimlar.map((a) => doldur(a, v)),
    konusmaSorusu: doldur(sablon.konusmaSorusu, v),
    birakma: doldur(sablon.birakma, v),
  };
}
