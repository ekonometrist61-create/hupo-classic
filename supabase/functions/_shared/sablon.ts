// Mesaj şablonu render katmanı (saf fonksiyon: ağ, DB ve Deno API yok).
//
// Biçim: {{ad}} veya {{ ad }}. Değişken adı harf veya _ ile başlar, ardından
// harf/rakam/_ gelir. Panel (MesajSablonlariManager.tsx) aynı deseni kullanır.
//
// Kurallar:
//   * Değeri olmayan değişken (anahtar yok, null, undefined, nesne) BOŞ YERE
//     çevrilmez: yer tutucu olduğu gibi kalır ve adı eksikDegiskenler listesine
//     yazılır. Çağıran bu listeye göre göndermeyi reddedebilir.
//   * Değer boş string ise bilerek boş yazılır ve eksik sayılmaz.
//   * Tek geçişte değiştirilir; bir değerin içindeki {{x}} tekrar genişletilmez.
//   * htmlKacis: true ise yalnızca DEĞERLER HTML için kaçışlanır (& < > " ').
//     Şablon gövdesi olduğu gibi kalır; gövde HTML'i admin tarafından yazılır.

export type SablonSecenek = {
  htmlKacis?: boolean;
};

export type SablonSonuc = {
  metin: string;
  eksikDegiskenler: string[];
};

const YER_TUTUCU_KALIBI = "\\{\\{\\s*([A-Za-z_]\\w*)\\s*\\}\\}";

const HTML_KACIS: Record<string, string> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#39;",
};

// Değeri metne çevirir. Desteklenmeyen tür için null döner (eksik sayılır).
function degeriMetne(deger: unknown, htmlKacis: boolean): string | null {
  let metin: string;
  if (typeof deger === "string") {
    metin = deger;
  } else if (typeof deger === "number" || typeof deger === "boolean" || typeof deger === "bigint") {
    metin = String(deger);
  } else {
    return null;
  }
  return htmlKacis ? metin.replace(/[&<>"']/g, (c) => HTML_KACIS[c]) : metin;
}

export function sablonDoldur(
  metin: string,
  degiskenler: Record<string, unknown>,
  secenek: SablonSecenek = {},
): SablonSonuc {
  const htmlKacis = secenek.htmlKacis === true;
  const eksik: string[] = [];

  const cikti = metin.replace(new RegExp(YER_TUTUCU_KALIBI, "g"), (tam: string, ad: string) => {
    const deger = Object.prototype.hasOwnProperty.call(degiskenler, ad)
      ? degeriMetne(degiskenler[ad], htmlKacis)
      : null;
    if (deger === null) {
      if (!eksik.includes(ad)) eksik.push(ad);
      return tam;
    }
    return deger;
  });

  return { metin: cikti, eksikDegiskenler: eksik };
}
