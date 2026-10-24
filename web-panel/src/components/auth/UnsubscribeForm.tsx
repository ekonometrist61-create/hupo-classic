"use client";

import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { useState } from "react";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
// Vercel'de tanımlı olan publishable anahtar (ErkenErisimSection ile aynı).
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

// Ticari ileti iznini e-posta adresi üzerinden iptal eder. Hesap olsun olmasın aynı
// sonuç gösterilir; hesabın varlığı bu ekrandan anlaşılamaz.
// İstek Edge Function'a gider (IP hız sınırı); RPC'ye doğrudan erişim kapalı.
const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-500 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export default function UnsubscribeForm() {
  const t = useTranslations("unsubscribe");
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    const adres = email.trim().toLowerCase();
    if (!EMAIL_PATTERN.test(adres)) {
      setError(t("errorEmail"));
      return;
    }

    setLoading(true);
    let ok = false;
    try {
      const res = await fetch(`${SUPABASE_URL}/functions/v1/iletisim-izni-iptal`, {
        method: "POST",
        headers: { "content-type": "application/json", apikey: SUPABASE_KEY ?? "" },
        body: JSON.stringify({ email: adres, kanal: "eposta" }),
      });
      ok = res.ok;
    } catch {
      ok = false;
    }
    setLoading(false);

    if (!ok) {
      setError(t("errorGeneric"));
      return;
    }
    setDone(true);
  }

  if (done) {
    return (
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-navy">
          {t("doneTitle")}
        </h1>
        <div className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-navy/10 sm:p-8">
          <p role="status" className="text-base text-navy">
            {t("doneBody")}
          </p>
          <Link
            href="/"
            className="mt-6 inline-flex h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 text-base font-semibold text-white transition-colors hover:bg-brand-600 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
          >
            Hupolingo
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
              id="unsubscribe-error"
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
