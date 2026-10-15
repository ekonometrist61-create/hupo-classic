"use client";

import { STUDENT_APP_URL } from "@/lib/app-url";
import { Link, useRouter } from "@/i18n/navigation";
import { EyeCloseIcon } from "@/icons";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useState } from "react";

// Her giriş kapısının kendi rolleri var; giriş sonrası hedef sabittir (rol bazlı yönlendirme yok).
// Veli ve öğretmen aynı kapıyı kullanır. Öğrenci hesapları bu sitedeki kapılarda kullanılmaz,
// app.hupolingo.com üzerinden girer. Asıl yetki veritabanındadır (RLS, admin fonksiyonları).
type Kapi = "veli" | "yonetim";

const KAPI_ROLLERI: Record<Kapi, readonly string[]> = {
  veli: ["veli", "ogretmen"],
  yonetim: ["admin", "ogretmen"],
};

const HEDEF: Record<Kapi, string> = {
  veli: "/veli-paneli",
  yonetim: "/yonetim",
};

type Hata = { mesaj: string; baglanti?: { metin: string; href: string; dis: boolean } };

const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-500 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

// Yönetim girişinde daha sakin kenarlık ve lacivert odak halkası (kurumsal yüzey).
const adminFieldClass =
  "mt-1.5 block h-11 w-full rounded-lg border border-gray-300 bg-white px-3.5 text-sm text-navy placeholder:text-gray-400 focus:border-navy focus:outline-none focus-visible:ring-3 focus-visible:ring-navy/20";

const linkClass =
  "font-semibold underline underline-offset-4 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

export default function SignInForm({ variant = "veli" }: { variant?: Kapi }) {
  const t = useTranslations("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Hata | null>(null);

  const router = useRouter();
  const yonetim = variant === "yonetim";

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
      setError({
        mesaj:
          authError.message === "Invalid login credentials"
            ? t("errorInvalid")
            : authError.message,
      });
      setLoading(false);
      return;
    }

    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", data.user.id)
      .maybeSingle();

    const rol = profile?.role ?? null;

    // Kapının rolüne uyan hesap içeri alınır; diğerleri oturumu kapatılarak reddedilir.
    if (rol && KAPI_ROLLERI[variant].includes(rol)) {
      setLoading(false);
      router.replace(HEDEF[variant]);
      return;
    }

    await supabase.auth.signOut();
    setLoading(false);

    if (rol === "ogrenci") {
      setError({
        mesaj: t("errorStudent"),
        baglanti: { metin: t("errorStudentLink"), href: STUDENT_APP_URL, dis: true },
      });
    } else if (rol === "admin" && !yonetim) {
      setError({
        mesaj: t("errorAdminOnVeli"),
        baglanti: { metin: t("errorAdminOnVeliLink"), href: "/yonetim-giris", dis: false },
      });
    } else if (rol === "veli" && yonetim) {
      setError({
        mesaj: t("adminNotAllowed"),
        baglanti: { metin: t("adminNotAllowedLink"), href: "/veli-paneli/giris", dis: false },
      });
    } else {
      setError({ mesaj: t("errorNoRole") });
    }
  }

  return (
    <div>
      {/* Yönetim girişinin başlığı sayfada (adminSignin) yer alır; burada yalnızca form. */}
      {!yonetim && (
        <>
          <p className="text-sm font-bold tracking-wider text-brand-700 uppercase">{t("eyebrow")}</p>
          <h1 className="mt-2 text-3xl font-extrabold tracking-tight text-navy sm:text-4xl">
            {t("title")}
          </h1>
          <p className="mt-2 text-base text-navy-muted">{t("subtitle")}</p>
        </>
      )}

      <div
        className={
          yonetim
            ? "rounded-xl bg-white p-6 ring-1 ring-navy/10 shadow-[0_1px_2px_rgb(23_50_77/0.06),0_16px_36px_-18px_rgb(23_50_77/0.28)] sm:p-7"
            : "mt-6 rounded-3xl bg-white p-6 shadow-xl shadow-brand-900/10 ring-1 ring-navy/10 sm:p-8"
        }
      >
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
              className={yonetim ? adminFieldClass : fieldClass}
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
                className={`${yonetim ? adminFieldClass : fieldClass} pe-14`}
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
              className={`inline-flex min-h-11 items-center text-sm text-brand-700 hover:text-brand-800 ${linkClass}`}
            >
              {t("forgotLink")}
            </Link>
          </div>

          {error && (
            <div
              id="signin-error"
              role="alert"
              className="rounded-xl border border-error-200 bg-error-50 px-4 py-3 text-sm font-medium text-error-700"
            >
              <p>{error.mesaj}</p>
              {error.baglanti &&
                (error.baglanti.dis ? (
                  <a
                    href={error.baglanti.href}
                    className={`mt-2 inline-block text-error-800 hover:text-error-900 ${linkClass}`}
                  >
                    {error.baglanti.metin}
                  </a>
                ) : (
                  <Link
                    href={error.baglanti.href}
                    className={`mt-2 inline-block text-error-800 hover:text-error-900 ${linkClass}`}
                  >
                    {error.baglanti.metin}
                  </Link>
                ))}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className={`inline-flex w-full cursor-pointer items-center justify-center px-6 font-semibold text-white transition-colors focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-60 ${
              yonetim
                ? "h-11 rounded-lg bg-navy text-sm hover:bg-navy-light"
                : "h-12 rounded-xl bg-brand-500 text-base hover:bg-brand-600"
            }`}
          >
            {loading ? t("submitting") : t("submit")}
          </button>

          {!yonetim && (
            <p className="flex items-start gap-2 text-sm leading-relaxed text-navy-muted">
              <svg aria-hidden="true" viewBox="0 0 24 24" className="mt-0.5 size-4 shrink-0 fill-brand-600">
                <path d="M12 2 4 5v6c0 5 3.4 9.4 8 11 4.6-1.6 8-6 8-11V5l-8-3Zm-1 14-3.5-3.5 1.4-1.4L11 13.2l3.6-3.6 1.4 1.4L11 16Z" />
              </svg>
              {t("trustNote")}
            </p>
          )}
        </form>
      </div>

      {yonetim ? (
        <p className="mt-6 text-center text-sm text-navy-muted">
          {t("parentSwitch")}{" "}
          <Link href="/veli-paneli/giris" className={`text-brand-700 hover:text-brand-800 ${linkClass}`}>
            {t("parentSwitchLink")}
          </Link>
        </p>
      ) : (
        <>
          <p className="mt-6 text-center text-sm text-navy-muted">
            {t("noAccount")}{" "}
            <Link href="/veli-paneli/kayit" className={`text-brand-700 hover:text-brand-800 ${linkClass}`}>
              {t("signupLink")}
            </Link>
          </p>
          <p className="mt-3 text-center text-xs text-navy-muted">
            {t("studentSwitch")}{" "}
            <a href={STUDENT_APP_URL} className={`text-navy hover:text-navy-light ${linkClass}`}>
              {t("studentSwitchLink")}
            </a>
          </p>
          <p className="mt-2 text-center text-xs text-navy-muted">
            {t("adminSwitch")}{" "}
            <Link href="/yonetim-giris" className={`text-navy hover:text-navy-light ${linkClass}`}>
              {t("adminSwitchLink")}
            </Link>
          </p>
        </>
      )}
    </div>
  );
}
