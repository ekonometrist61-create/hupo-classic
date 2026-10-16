"use client";

import { TurnstileWidget } from "@/components/guvenlik/TurnstileWidget";
import { useTranslations } from "next-intl";
import { type FormEvent, useEffect, useState } from "react";
import { erkenErisimSonrasiIzleme, ilkTemasUtm } from "./erkenErisimIzleme";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
// Vercel'de tanımlı olan publishable anahtar (ANON_KEY adı tanımlı değil → 401).
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

const inputClass =
  "w-full rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-800 dark:text-white dark:placeholder:text-gray-500";

export function ErkenErisimSection() {
  const t = useTranslations("landing.erkenErisim");
  const [ad, setAd] = useState("");
  const [email, setEmail] = useState("");
  const [telefon, setTelefon] = useState("");
  const [izin, setIzin] = useState(false);
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [errorMsg, setErrorMsg] = useState("");
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const [captchaKey, setCaptchaKey] = useState(0);

  // İlk temas UTM'si sayfa açılışında kaydedilir; form gönderilmese de kaybolmaz.
  useEffect(() => {
    ilkTemasUtm();
  }, []);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const trimmedAd = ad.trim();
    const trimmedEmail = email.trim().toLowerCase();

    if (!trimmedAd || !trimmedEmail) {
      setErrorMsg(t("errorRequired"));
      setStatus("error");
      return;
    }
    if (!trimmedEmail.includes("@") || !trimmedEmail.includes(".")) {
      setErrorMsg(t("errorEmail"));
      setStatus("error");
      return;
    }

    if (!captchaToken) {
      setErrorMsg(t("errorGeneric"));
      setStatus("error");
      return;
    }

    setStatus("loading");
    setErrorMsg("");

    // Captcha + IP sınırı Edge Function'da; doğrudan RPC çağrısı artık kapalı.
    let ok = false;
    let sunucuHata = "";
    try {
      const res = await fetch(`${SUPABASE_URL}/functions/v1/veli-adayi-kayit`, {
        method: "POST",
        headers: { "content-type": "application/json", apikey: SUPABASE_KEY ?? "" },
        body: JSON.stringify({
          email: trimmedEmail,
          ad: trimmedAd,
          telefon: telefon.trim() || null,
          kaynak: "landing_erken_erisim",
          pazarlama_izni: izin,
          captcha_token: captchaToken,
        }),
      });
      ok = res.ok;
      if (!ok) {
        const data = (await res.json().catch(() => ({}))) as { hata?: string };
        sunucuHata = data.hata ?? "";
      }
    } catch {
      ok = false;
    }

    // Turnstile token'ı tek kullanımlıktır; her denemede yeni token alınır.
    setCaptchaToken(null);
    setCaptchaKey((k) => k + 1);

    if (ok) {
      setStatus("success");
      void erkenErisimSonrasiIzleme(trimmedEmail);
    } else {
      setErrorMsg(sunucuHata || t("errorGeneric"));
      setStatus("error");
    }
  };

  return (
    <section className="bg-white py-14 sm:py-20 dark:bg-gray-900">
      <div className="mx-auto max-w-xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <p className="text-sm font-semibold uppercase tracking-widest text-brand-500">
            {t("eyebrow")}
          </p>
          <h2 className="mt-2 text-3xl font-extrabold tracking-tight text-navy sm:text-4xl dark:text-white">
            {t("title")}
          </h2>
          <p className="mt-3 text-base text-gray-500 dark:text-gray-400">{t("desc")}</p>
        </div>

        {status === "success" ? (
          <div className="mt-8 rounded-2xl bg-success-50 px-6 py-8 text-center dark:bg-success-500/15">
            <p className="text-lg font-semibold text-success-700 dark:text-success-400">
              {t("success")}
            </p>
          </div>
        ) : (
          <form onSubmit={(e) => { void handleSubmit(e); }} className="mt-8 space-y-4" noValidate>
            <div>
              <label htmlFor="ee-ad" className="sr-only">
                {t("namePlaceholder")}
              </label>
              <input
                id="ee-ad"
                type="text"
                required
                autoComplete="name"
                className={inputClass}
                placeholder={t("namePlaceholder")}
                value={ad}
                onChange={(e) => setAd(e.target.value)}
              />
            </div>
            <div>
              <label htmlFor="ee-email" className="sr-only">
                {t("emailPlaceholder")}
              </label>
              <input
                id="ee-email"
                type="email"
                required
                autoComplete="email"
                className={inputClass}
                placeholder={t("emailPlaceholder")}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div>
              <label htmlFor="ee-tel" className="sr-only">
                {t("phonePlaceholder")}
              </label>
              <input
                id="ee-tel"
                type="tel"
                autoComplete="tel"
                className={inputClass}
                placeholder={t("phonePlaceholder")}
                value={telefon}
                onChange={(e) => setTelefon(e.target.value)}
              />
            </div>
            <TurnstileWidget onToken={setCaptchaToken} resetKey={captchaKey} />

            <label className="flex cursor-pointer items-start gap-3">
              <input
                type="checkbox"
                className="mt-0.5 h-4 w-4 shrink-0 cursor-pointer rounded border-gray-300 accent-brand-500"
                checked={izin}
                onChange={(e) => setIzin(e.target.checked)}
              />
              <span className="text-sm text-gray-600 dark:text-gray-400">{t("marketingLabel")}</span>
            </label>

            {status === "error" && (
              <p role="alert" className="text-sm font-medium text-error-700">
                {errorMsg}
              </p>
            )}

            <button
              type="submit"
              disabled={status === "loading"}
              className="w-full rounded-xl bg-brand-500 py-3 text-sm font-bold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-60"
            >
              {status === "loading" ? t("submitting") : t("submit")}
            </button>
          </form>
        )}
      </div>
    </section>
  );
}
