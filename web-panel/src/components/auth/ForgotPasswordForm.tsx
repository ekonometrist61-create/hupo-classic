"use client";

import { Link } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useState } from "react";

// Parola sıfırlama isteği. Bağlantı web'de başlatılır ve web'e döner; mobil
// uygulama PKCE doğrulayıcısını kendi tuttuğu için isteği oradan göndermek
// bağlantıyı kullanılamaz hale getirir.
const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-500 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

export default function ForgotPasswordForm() {
  const t = useTranslations("forgot");
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    const supabase = createClient();
    const { error: authError } = await supabase.auth.resetPasswordForEmail(
      email.trim(),
      { redirectTo: `${window.location.origin}/sifre-yeni` }
    );
    setLoading(false);

    if (authError) {
      setError(t("errorGeneric"));
      return;
    }
    // Hesabın var olup olmadığı bilgisi bilerek gösterilmez.
    setSent(true);
  }

  if (sent) {
    return (
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-navy">
          {t("sentTitle")}
        </h1>
        <div className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-navy/10 sm:p-8">
          <p role="status" className="text-base text-navy">
            {t("sentBody")}
          </p>
          <Link
            href="/signin"
            className="mt-6 inline-flex h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-semibold text-white transition-colors hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("backToSignin")}
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

          {error && (
            <p
              id="forgot-error"
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
        <Link
          href="/signin"
          className="font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("backToSignin")}
        </Link>
      </p>
    </div>
  );
}
