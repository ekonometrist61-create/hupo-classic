"use client";

import { authDilCevir, authHataAnahtari, authMetni } from "@/lib/auth/hata";
import { Link, useRouter } from "@/i18n/navigation";
import { EyeCloseIcon } from "@/icons";
import { createClient } from "@/utils/supabase/client";
import { useLocale, useTranslations } from "next-intl";
import { useEffect, useState } from "react";

// Veli hesabı oluşturma. Rol "veli" olarak gönderilir; veritabanındaki
// handle_new_user tetikleyicisi yalnızca 'veli' ya da 'ogrenci' kabul eder,
// yönetici rolü bu formdan verilemez.
const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-500 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

const MIN_PASSWORD_LENGTH = 8;

// Ticari ileti onay metni sürümü. Metin değişirse artırılmalı; her kanal kaydına yazılır.
// v2: push kanalı eklendi (metin değişti). Yasal metin onayı ayrıca bekleniyor (TASKS.md §23).
const ILETISIM_METIN_SURUMU = "hupolingo-ticari-ileti-2026-10-v2";

export default function SignUpForm() {
  const t = useTranslations("signup");
  const dil = authDilCevir(useLocale());
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [consent, setConsent] = useState(false);
  // Ticari ileti izinleri: her kanal ayrı, tümü varsayılan İŞARETSİZ (6563 ve KVKK açık rıza).
  const [izinEposta, setIzinEposta] = useState(false);
  const [izinSms, setIzinSms] = useState(false);
  const [izinTelefon, setIzinTelefon] = useState(false);
  const [izinPush, setIzinPush] = useState(false);
  // Push kutusu yalnızca hukuk kapısı açıksa ve bu metin sürümü onaylıysa gösterilir (yönetici kararı).
  const [pushAcik, setPushAcik] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  useEffect(() => {
    const kapiKontrol = async () => {
      const { data, error } = await createClient().rpc("iletisim_push_kullanilabilir", {
        p_metin_surumu: ILETISIM_METIN_SURUMU,
      });
      setPushAcik(!error && data === true);
    };
    void kapiKontrol();
  }, []);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);

    if (password.length < MIN_PASSWORD_LENGTH) {
      setError(t("errorPassword"));
      return;
    }
    if (!consent) {
      setError(t("errorConsent"));
      return;
    }

    setLoading(true);
    const supabase = createClient();
    const { data, error: authError } = await supabase.auth.signUp({
      email: email.trim(),
      password,
      options: {
        data: {
          full_name: fullName.trim(),
          role: "veli",
          // Kanal izinleri e-posta doğrulandığında yazılır (migration 20261020000300).
          iletisim_eposta: izinEposta,
          iletisim_sms: izinSms,
          iletisim_telefon: izinTelefon,
          // Kapı kapalıysa alan hiç gönderilmez: trigger push satırı yazmaz.
          iletisim_push: pushAcik ? izinPush : undefined,
          iletisim_metin_surumu: ILETISIM_METIN_SURUMU,
        },
        emailRedirectTo: `${window.location.origin}/veli-paneli/giris`,
      },
    });
    setLoading(false);

    // Hesap zaten varsa aynı nötr ekran gösterilir: kayıt çakışması dışarıya sızmaz.
    if (authError) {
      if (authHataAnahtari(authError) === "kayitNotr") {
        setSent(true);
        return;
      }
      const anahtar = authHataAnahtari(authError);
      setError(anahtar === "genel" ? t("errorGeneric") : authMetni(anahtar, dil));
      return;
    }

    // Zaten kayıtlı e-postada Supabase boş identities döndürür; yeni hesapla aynı ekrana gidilir.
    if (data.user && data.user.identities?.length === 0) {
      setSent(true);
      return;
    }

    // E-posta onayı kapalıysa oturum hemen açılır; açıksa doğrulama bağlantısı beklenir.
    if (data.session) {
      router.replace("/veli-paneli");
      return;
    }
    setSent(true);
  }

  if (sent) {
    return (
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-navy">
          {authMetni("kayitBaslik", dil)}
        </h1>
        <div className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-navy/10 sm:p-8">
          <p role="status" className="text-base text-navy">
            {authMetni("kayitNotr", dil)}
          </p>
          <Link
            href="/veli-paneli/giris"
            className="mt-6 inline-flex h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-semibold text-white transition-colors hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("signinLink")}
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div>
      <h1 className="text-3xl font-extrabold tracking-tight text-navy">
        {t("title")}
      </h1>
      <p className="mt-2 text-base text-navy-muted">{t("subtitle")}</p>

      <div className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-navy/10 sm:p-8">
        <form onSubmit={handleSubmit} className="space-y-5" aria-busy={loading}>
          <div>
            <label htmlFor="full_name" className="block text-sm font-semibold text-navy">
              {t("fullName")}
            </label>
            <input
              id="full_name"
              name="full_name"
              type="text"
              required
              autoComplete="name"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder={t("fullNamePlaceholder")}
              className={fieldClass}
            />
          </div>

          <div>
            <label htmlFor="email" className="block text-sm font-semibold text-navy">
              {t("email")}
            </label>
            <input
              id="email"
              name="email"
              type="email"
              required
              autoComplete="email"
              inputMode="email"
              autoCapitalize="none"
              spellCheck={false}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder={t("emailPlaceholder")}
              className={fieldClass}
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-semibold text-navy">
              {t("password")}
            </label>
            <div className="relative">
              <input
                id="password"
                name="password"
                type={showPassword ? "text" : "password"}
                required
                minLength={MIN_PASSWORD_LENGTH}
                autoComplete="new-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder={t("passwordPlaceholder")}
                className={`${fieldClass} pe-14`}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? t("hidePassword") : t("showPassword")}
                className="absolute inset-e-1 top-1/2 grid size-11 -translate-y-1/2 cursor-pointer place-items-center rounded-lg text-gray-600 hover:bg-gray-100 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
              >
                <EyeCloseIcon className="size-5 fill-gray-600" aria-hidden="true" />
              </button>
            </div>
          </div>

          <label className="flex min-h-11 items-start gap-3 text-sm text-navy-muted">
            <input
              type="checkbox"
              checked={consent}
              onChange={(e) => setConsent(e.target.checked)}
              required
              className="mt-0.5 size-5 shrink-0 accent-brand-500"
            />
            <span>
              {t("consentPrefix")}{" "}
              <Link
                href="/gizlilik"
                className="font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800"
              >
                {t("consentPrivacy")}
              </Link>{" "}
              {t("consentAnd")}{" "}
              <Link
                href="/kosullar"
                className="font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800"
              >
                {t("consentTerms")}
              </Link>
              {t("consentSuffix")}
            </span>
          </label>

          {/* İletişim tercihleri — 6563 sayılı Kanun, kanal bazlı, tümü başlangıçta boş */}
          <div className="space-y-2 rounded-xl border border-gray-200 bg-gray-50 px-4 py-3">
            <p className="text-sm font-semibold text-navy">{t("marketingTitle")}</p>
            {[
              { id: "izin-eposta", label: t("marketingEposta"), checked: izinEposta, set: setIzinEposta },
              { id: "izin-sms",    label: t("marketingSms"),    checked: izinSms,    set: setIzinSms },
              { id: "izin-tel",    label: t("marketingTelefon"),checked: izinTelefon,set: setIzinTelefon },
              ...(pushAcik
                ? [{ id: "izin-push", label: t("marketingPush"), checked: izinPush, set: setIzinPush }]
                : []),
            ].map(({ id, label, checked, set }) => (
              <label key={id} className="flex cursor-pointer items-start gap-3 text-sm text-navy-muted">
                <input
                  type="checkbox"
                  id={id}
                  checked={checked}
                  onChange={(e) => set(e.target.checked)}
                  className="mt-0.5 size-4 shrink-0 rounded border-gray-300 accent-brand-500"
                />
                <span>{label}</span>
              </label>
            ))}
            <p className="pt-1 text-xs leading-snug text-gray-500">
              {t.rich("marketingKabul", {
                link: (chunks) => (
                  <Link href="/ticari-ileti-izni" className="underline hover:text-brand-600" target="_blank">
                    {chunks}
                  </Link>
                ),
              })}
            </p>
          </div>

          {error && (
            <p
              id="signup-error"
              role="alert"
              className="rounded-xl border border-error-200 bg-error-50 px-4 py-3 text-sm font-medium text-error-700"
            >
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="inline-flex h-12 w-full cursor-pointer items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-semibold text-white transition-colors hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {loading ? t("submitting") : t("submit")}
          </button>
        </form>
      </div>

      <p className="mt-6 text-center text-sm text-navy-muted">
        {t("hasAccount")}{" "}
        <Link
          href="/veli-paneli/giris"
          className="font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("signinLink")}
        </Link>
      </p>
    </div>
  );
}
