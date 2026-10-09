"use client";

import { Link, useRouter } from "@/i18n/navigation";
import { EyeCloseIcon } from "@/icons";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

// E-posta bağlantısından gelen kullanıcı için yeni parola ekranı.
// PKCE ("code") ve eski hash tabanlı bağlantılar ikisi de desteklenir.
const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-500 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

const MIN_PASSWORD_LENGTH = 8;

type Durum = "yukleniyor" | "hazir" | "gecersiz" | "tamam";

export default function ResetPasswordForm() {
  const t = useTranslations("reset");
  const tCommon = useTranslations("common");
  const router = useRouter();
  const [durum, setDurum] = useState<Durum>("yukleniyor");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const supabase = createClient();
    let aktif = true;

    async function oturumuHazirla() {
      const code = new URLSearchParams(window.location.search).get("code");
      if (code) {
        const { error: exchangeError } =
          await supabase.auth.exchangeCodeForSession(code);
        if (!aktif) return;
        if (exchangeError) {
          setDurum("gecersiz");
          return;
        }
      }
      const { data } = await supabase.auth.getSession();
      if (!aktif) return;
      setDurum(data.session ? "hazir" : "gecersiz");
    }

    oturumuHazirla();
    return () => {
      aktif = false;
    };
  }, []);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);

    if (password.length < MIN_PASSWORD_LENGTH) {
      setError(t("errorPassword"));
      return;
    }
    if (password !== confirm) {
      setError(t("mismatch"));
      return;
    }

    setLoading(true);
    const supabase = createClient();
    const { error: updateError } = await supabase.auth.updateUser({ password });
    if (updateError) {
      setLoading(false);
      setError(t("errorGeneric"));
      return;
    }
    // Sıfırlama oturumu kapatılır; kullanıcı yeni parolasıyla giriş yapar.
    await supabase.auth.signOut();
    setLoading(false);
    setDurum("tamam");
  }

  if (durum === "yukleniyor") {
    return (
      <p role="status" className="text-base text-navy-muted">
        {tCommon("loading")}
      </p>
    );
  }

  if (durum === "gecersiz") {
    return (
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-navy">
          {t("invalidTitle")}
        </h1>
        <div className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-navy/10 sm:p-8">
          <p className="text-base text-navy">{t("invalidBody")}</p>
          <Link
            href="/sifre-unuttum"
            className="mt-6 inline-flex h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-semibold text-white transition-colors hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("requestNew")}
          </Link>
        </div>
      </div>
    );
  }

  if (durum === "tamam") {
    return (
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-navy">
          {t("successTitle")}
        </h1>
        <div className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-navy/10 sm:p-8">
          <p role="status" className="text-base text-navy">
            {t("successBody")}
          </p>
          <button
            type="button"
            onClick={() => router.replace("/signin")}
            className="mt-6 inline-flex h-12 w-full cursor-pointer items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-semibold text-white transition-colors hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            {t("backToSignin")}
          </button>
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

          <div>
            <label htmlFor="confirm" className="block text-sm font-semibold text-navy">
              {t("confirm")}
            </label>
            <input
              id="confirm"
              name="confirm"
              type={showPassword ? "text" : "password"}
              required
              minLength={MIN_PASSWORD_LENGTH}
              autoComplete="new-password"
              value={confirm}
              onChange={(e) => setConfirm(e.target.value)}
              placeholder={t("confirmPlaceholder")}
              className={fieldClass}
            />
          </div>

          {error && (
            <p
              id="reset-error"
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
    </div>
  );
}
