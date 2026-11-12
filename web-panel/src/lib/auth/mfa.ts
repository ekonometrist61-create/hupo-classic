// Yönetim (admin + öğretmen) için iki adımlı doğrulama (TOTP) kuralları. GÖR-106 ilk aşama.
//
// Zorunluluk bayrağı TEK DOĞRULUK KAYNAĞI: `NEXT_PUBLIC_YONETIM_MFA_ZORUNLU=1` (Vercel ortam
// değişkeni). Varsayılan KAPALI: faktörü olmayan yetkiliye kayıt ekranı "önerilir" olarak
// gösterilir ve atlanabilir. Açıkken aal2 olmayan oturum yönetim sayfalarına giremez
// (yönetim layout'unda sunucu kontrolü). NEXT_PUBLIC_ değeri derleme anında gömülür;
// değiştirildiğinde yeniden dağıtım gerekir.
//
// Doğrulanmış faktörü olan hesap, bayraktan bağımsız olarak kodu girmeden yönetim alanına
// giremez (aksi halde faktör kaydı adres çubuğundan atlanabilirdi).
//
// Asıl yetki veritabanındadır: aal2 zorunluluğu yöneticiler kayıt olduktan sonra is_admin()
// içine migration ile eklenecek; bu dosya yalnızca arayüz yönlendirmesini yönetir.

import type { SupabaseClient } from "@supabase/supabase-js";

export const YONETIM_MFA_ZORUNLU = process.env.NEXT_PUBLIC_YONETIM_MFA_ZORUNLU === "1";

/** Kod doğrulama ve faktör kayıt sayfası (yönetim alanının dışında; layout döngüsü olmaz). */
export const YONETIM_DOGRULAMA = "/yonetim-dogrulama";

/** Kimlik doğrulayıcı uygulamada görünen hesap etiketi ve faktör adı. */
export const MFA_YAYINCI = "Hupolingo Yönetim";

/**
 * Oturumun MFA durumu.
 * - tamam:  devam edilebilir (aal2 ya da zorunluluk kapalıyken faktörsüz hesap)
 * - dogrula: doğrulanmış faktör var, oturum aal1 → 6 haneli kod istenir
 * - kayit:  faktör yok → kayıt ekranı (zorunlu değilse atlanabilir)
 */
export type MfaDurumu = "tamam" | "dogrula" | "kayit";

export type AalBilgisi ={ currentLevel: string | null; nextLevel: string | null } | null | undefined;

/**
 * getAuthenticatorAssuranceLevel() sonucundan yönetim kapısının durumunu çıkarır. Saf fonksiyon.
 * `kayitOner`: faktörsüz hesap için kayıt ekranı gösterilsin mi (girişten hemen sonra true;
 * layout'ta yalnız zorunluluk açıkken true).
 */
export function mfaDurumuCoz(aal: AalBilgisi, kayitOner: boolean): MfaDurumu {
  if (aal?.currentLevel === "aal2") return "tamam";
  // Supabase tablosu: aal1 → aal2 = faktör kayıtlı ama bu oturumda doğrulanmadı.
  if (aal?.nextLevel === "aal2") return "dogrula";
  return kayitOner ? "kayit" : "tamam";
}

/**
 * Sunucuda (layout, sayfa) AAL okuması. Cookie'deki oturum doğrulanmadan kullanılmaz:
 * access token açıkça verilir, Supabase onu getUser(jwt) ile Auth sunucusunda doğrular ve
 * faktör listesini oradan okur. Hata ya da oturum yoksa null döner (çağıran kapalı davranır).
 */
export async function sunucuAalOku(supabase: SupabaseClient): Promise<AalBilgisi> {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session?.access_token) return null;
  const { data, error } = await supabase.auth.mfa.getAuthenticatorAssuranceLevel(session.access_token);
  if (error || !data) return null;
  return { currentLevel: data.currentLevel, nextLevel: data.nextLevel };
}
