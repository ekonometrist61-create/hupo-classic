// Growth kökenli e-posta satırları için saf yardımcılar (W9).
// Ağ, DB ve Deno API yok: hem Deno hem Node (node --test) ile test edilebilir.
// eposta-gonder/index.ts: outbox satırı growth_household_id taşıyorsa bu modülü kullanır.
//
// GÜVENLİK (çocuk verisi):
//   * Şablon değişkenleri yalnız veli verisinden üretilir: veli_adi (tam adın ilk kelimesi)
//     ve iptal_baglantisi. Çocuğun adı, konumu, fotoğrafı bu modüle GİRMEZ.
//   * Bir şablon çocuk değişkeni (ör. {{cocuk_adi}}) içerirse yer tutucu eksik kalır ve
//     growthMesajiHazirla ok=false döner; gönderim yapılmaz.
//   * Dönen hata metni yalnız değişken ADLARINI taşır, değerlerini değil.
import { sablonDoldur } from "./sablon.ts";

export const IPTAL_YOLU = "/ticari-ileti-izni";
export const VARSAYILAN_VELI_ADI = "değerli veli";
export const VARSAYILAN_KONU = "Hupolingo";

export type GrowthSablon = { subject: string | null; body: string };
export type GrowthMesaj = { konu: string; metin: string };
export type GrowthHazirlik =
  | { ok: true; mesaj: GrowthMesaj }
  | { ok: false; hata: string };

/** Tam addan yalnız ilk kelime. Boşsa varsayılan hitap. */
export function veliAdi(tamAd: string | null | undefined): string {
  const ilk = (tamAd ?? "").trim().split(/\s+/)[0] ?? "";
  return ilk === "" ? VARSAYILAN_VELI_ADI : ilk;
}

/** Şablonda kullanılabilen tek değişken kümesi. Yalnız veli verisi. */
export function growthDegiskenleri(
  parentName: string | null | undefined,
  panelTaban: string,
): Record<string, string> {
  const taban = panelTaban.replace(/\/+$/, "");
  return {
    veli_adi: veliAdi(parentName),
    iptal_baglantisi: `${taban}${IPTAL_YOLU}`,
  };
}

/** Şablonu değişkenlerle doldurur. Eksik değişken varsa gönderim reddedilir. */
export function growthMesajiHazirla(
  sablon: GrowthSablon,
  degiskenler: Record<string, string>,
): GrowthHazirlik {
  const govde = sablonDoldur(sablon.body ?? "", degiskenler);
  const konu = sablonDoldur((sablon.subject ?? "").trim() || VARSAYILAN_KONU, degiskenler);

  const eksik = [...new Set([...govde.eksikDegiskenler, ...konu.eksikDegiskenler])];
  if (eksik.length > 0) {
    return { ok: false, hata: `eksik değişken: ${eksik.join(",")}` };
  }
  if (govde.metin.trim() === "" || konu.metin.trim() === "") {
    return { ok: false, hata: "boş içerik" };
  }
  return { ok: true, mesaj: { konu: konu.metin, metin: govde.metin } };
}
