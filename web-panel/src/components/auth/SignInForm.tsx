"use client";

import { Link, useRouter } from "@/i18n/navigation";
import { EyeCloseIcon } from "@/icons";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useState } from "react";

// Veliler ve adminler bu ekrandan Supabase Auth ile giris yapar.
// Rol denetimi veritabaninda da zorunludur (public.profiles.role ve RLS);
// buradaki kontrol yalnizca kullaniciyi dogru panele yonlendirir.
const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-500 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

export default function SignInForm() {
  const t = useTranslations("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const router = useRouter();

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    const supabase = createClient();
    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) {
      setError(
        authError.message === "Invalid login credentials"
          ? t("errorInvalid")
          : authError.message
      );
      setLoading(false);
      return;
    }

    // Rolu okuyup dogru panele yonlendir.
    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", data.user.id)
      .maybeSingle();

    setLoading(false);
    const hedef =
      profile?.role === "admin" || profile?.role === "ogretmen"
        ? "/yonetim"
        : profile?.role === "ogrenci"
          ? "/ogrenci"
          : "/veli-paneli";
    router.replace(hedef);
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
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder={t("passwordPlaceholder")}
                className={`${fieldClass} pe-14`}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? t("hidePassword") : t("showPassword")}
                className="absolute end-1 top-1/2 grid size-11 -translate-y-1/2 cursor-pointer place-items-center rounded-lg text-gray-600 hover:bg-gray-100 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
              >
                <EyeCloseIcon className="size-5 fill-gray-600" aria-hidden="true" />
              </button>
            </div>
          </div>

          <div className="-mt-2 text-end">
            <Link
              href="/sifre-unuttum"
              className="inline-flex min-h-11 items-center text-sm font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
            >
              {t("forgotLink")}
            </Link>
          </div>

          {error && (
            <p
              id="signin-error"
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
        {t("noAccount")}{" "}
        <Link
          href="/signup"
          className="font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("signupLink")}
        </Link>
      </p>
    </div>
  );
}
