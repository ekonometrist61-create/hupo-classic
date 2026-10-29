// Giriş, kayıt ve parola akışlarının kullanıcıya gösterdiği metinler.
// Supabase Auth hata kodu (error.code) öncelikli eşlenir; kod yoksa mesaj metninden
// tahmin edilir. Ham İngilizce Supabase metni arayüze hiçbir koşulda çıkmaz.
// Kayıt çakışması (hesap var/yok) bilerek nötr metinle gösterilir; hesap varlığı sızmaz.

export type AuthDil = "tr" | "en";

export type AuthMetinAnahtari =
  | "invalid_credentials"
  | "email_not_confirmed"
  | "over_request_rate_limit"
  | "weak_password"
  | "same_password"
  | "otp_expired"
  | "kayitNotr"
  | "kayitBaslik"
  | "rolUyusmazlik"
  | "genel";

export type AuthHataGirdisi = { code?: string | null; message?: string | null } | null | undefined;

const METINLER: Record<AuthMetinAnahtari, Record<AuthDil, string>> = {
  invalid_credentials: {
    tr: "E-posta veya parola hatalı. Bilgileri kontrol edip yeniden dene.",
    en: "Email or password is incorrect. Check your details and try again.",
  },
  email_not_confirmed: {
    tr: "E-posta adresin henüz doğrulanmamış. Gelen kutundaki bağlantıya tıkla, sonra tekrar dene.",
    en: "Your email address is not verified yet. Open the link in your inbox, then try again.",
  },
  over_request_rate_limit: {
    tr: "Çok fazla deneme yapıldı. Birkaç dakika bekleyip tekrar dene.",
    en: "Too many attempts. Wait a few minutes and try again.",
  },
  weak_password: {
    tr: "Bu parola yeterince güçlü değil. Daha uzun ve tahmin edilmesi zor bir parola seç.",
    en: "This password is not strong enough. Choose a longer, harder-to-guess password.",
  },
  same_password: {
    tr: "Yeni parolan eskisiyle aynı olamaz.",
    en: "Your new password must be different from the old one.",
  },
  otp_expired: {
    tr: "Bağlantının süresi dolmuş ya da daha önce kullanılmış. Yeni bir bağlantı iste.",
    en: "This link has expired or was already used. Request a new one.",
  },
  // Hesap var ya da yok: aynı metin, aynı ekran.
  kayitNotr: {
    tr: "Kayıt isteğin alındı; e-postanı kontrol et. Hesabın varsa giriş yapabilir veya şifreni sıfırlayabilirsin",
    en: "We received your sign-up request. Check your email. If you already have an account, you can sign in or reset your password.",
  },
  kayitBaslik: {
    tr: "Kayıt isteğin alındı",
    en: "Sign-up request received",
  },
  // Rol uyuşmazlığında hesabın hangi role ait olduğu söylenmez.
  rolUyusmazlik: {
    tr: "Bu hesapla bu giriş ekranından devam edilemiyor. Doğru giriş ekranını kullanmayı dene.",
    en: "This account cannot continue from this sign-in page. Try the correct sign-in page.",
  },
  genel: {
    tr: "İşlem tamamlanamadı. Birazdan tekrar dene.",
    en: "Something went wrong. Please try again shortly.",
  },
};

// Supabase hata kodu -> metin anahtarı. Kod listesi GoTrue sürümüne göre değişebilir;
// bilinmeyen kodlar mesaj eşlemesine, o da yoksa "genel" metne düşer.
const KOD_ESLEME: Record<string, AuthMetinAnahtari> = {
  invalid_credentials: "invalid_credentials",
  email_not_confirmed: "email_not_confirmed",
  over_request_rate_limit: "over_request_rate_limit",
  over_email_send_rate_limit: "over_request_rate_limit",
  over_sms_send_rate_limit: "over_request_rate_limit",
  user_already_exists: "kayitNotr",
  email_exists: "kayitNotr",
  weak_password: "weak_password",
  same_password: "same_password",
  otp_expired: "otp_expired",
};

// Kod yoksa (eski istemci sürümleri) İngilizce mesaj metninden eşleme.
const MESAJ_ESLEME: Array<[RegExp, AuthMetinAnahtari]> = [
  [/invalid login credentials/i, "invalid_credentials"],
  [/email not confirmed/i, "email_not_confirmed"],
  [/rate limit|too many requests/i, "over_request_rate_limit"],
  [/already (been )?registered|already exists/i, "kayitNotr"],
  [/password should be at least|weak password/i, "weak_password"],
  [/different from the old password|should be different/i, "same_password"],
  [/token has expired|otp.*expired|expired or is invalid/i, "otp_expired"],
];

/** Hata nesnesinden metin anahtarını bulur. Eşleşme yoksa "genel" döner. */
export function authHataAnahtari(hata: AuthHataGirdisi): AuthMetinAnahtari {
  if (!hata) return "genel";
  const kod = hata.code ?? "";
  if (kod && Object.prototype.hasOwnProperty.call(KOD_ESLEME, kod)) {
    return KOD_ESLEME[kod];
  }
  const mesaj = hata.message ?? "";
  for (const [desen, anahtar] of MESAJ_ESLEME) {
    if (desen.test(mesaj)) return anahtar;
  }
  return "genel";
}

/** Metin anahtarının seçilen dildeki kullanıcı metni. */
export function authMetni(anahtar: AuthMetinAnahtari, dil: AuthDil): string {
  return METINLER[anahtar][dil];
}

/** Supabase hatasını kullanıcı metnine çevirir. Ham İngilizce metin döndürmez. */
export function authHataMetni(hata: AuthHataGirdisi, dil: AuthDil): string {
  return authMetni(authHataAnahtari(hata), dil);
}

/** next-intl yerel kodunu (tr | en) güvenli biçimde iki dile indirger. */
export function authDilCevir(yerel: string | null | undefined): AuthDil {
  return yerel === "en" ? "en" : "tr";
}
