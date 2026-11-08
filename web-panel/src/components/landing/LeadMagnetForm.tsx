"use client";

import { TurnstileWidget } from "@/components/guvenlik/TurnstileWidget";
import { Link } from "@/i18n/navigation";
import { IZIN_SURUM, KVKK_SURUM } from "@/lib/lead-magnet";
import { useTranslations } from "next-intl";
import { useState } from "react";

// Veli rehberi (lead magnet) formu: yalnız e-posta + sınıf. Çocuk adı, telefon, SMS kutusu yok.
// Pazarlama izni kutusu işaretsiz başlar ve içeriğe erişimin şartı değildir.

const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-300 bg-white px-4 text-base text-navy placeholder:text-gray-500 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-50";

const SINIFLAR = [3, 4, 5, 6, 7];
const EPOSTA_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

interface Props {
  magnet: string;
  onSuccess: (sonuc: { leadId: string; sinif: number }) => void;
}

export default function LeadMagnetForm({ magnet, onSuccess }: Props) {
  const t = useTranslations("landing.rehber.form");

  const [eposta, setEposta] = useState("");
  const [sinif, setSinif] = useState("");
  const [kvkk, setKvkk] = useState(false);
  const [izinEposta, setIzinEposta] = useState(false);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const [captchaKey, setCaptchaKey] = useState(0);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);

    if (!eposta.trim() || !sinif) {
      setError(t("hataZorunlu"));
      return;
    }
    if (!EPOSTA_RE.test(eposta.trim())) {
      setError(t("hataEposta"));
      return;
    }
    if (!kvkk) {
      setError(t("hataKvkk"));
      return;
    }
    if (!captchaToken) {
      setError(t("hataDogrulama"));
      return;
    }

    setLoading(true);
    try {
      const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
      const anonKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!;
      const sinifSayi = parseInt(sinif, 10);


      const res = await fetch(`${supabaseUrl}/functions/v1/lead-magnet-kayit`, {
        method: "POST",
        headers: { "content-type": "application/json", apikey: anonKey },
        body: JSON.stringify({
          magnet,
          eposta: eposta.trim().toLowerCase(),
          sinif: sinifSayi,
          kvkk_onay: true,
          kvkk_surum: KVKK_SURUM,
          izin_surum: IZIN_SURUM,
          izin_eposta: izinEposta,
          captcha_token: captchaToken,
        }),
      });

      const data = (await res.json().catch(() => ({}))) as { lead_id?: string; hata?: string };

      if (!res.ok || !data.lead_id) {
        setError(data.hata ?? t("hataGenel"));
        return;
      }
      onSuccess({ leadId: data.lead_id, sinif: sinifSayi });
    } catch {
      setError(t("hataGenel"));
    } finally {
      // Turnstile token'ı tek kullanımlıktır; her gönderimden sonra widget yenilenir.
      setCaptchaToken(null);
      setCaptchaKey((k) => k + 1);
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-5">
      <div>
        <label htmlFor="lm-eposta" className="block text-sm font-semibold text-navy">
          {t("eposta")} <span aria-hidden="true" className="text-red-500">*</span>
          <span className="sr-only"> ({t("zorunlu")})</span>
        </label>
        <input
          id="lm-eposta"
          type="email"
          autoComplete="email"
          inputMode="email"
          required
          value={eposta}
          onChange={(e) => setEposta(e.target.value)}
          className={fieldClass}
          disabled={loading}
        />
      </div>

      <div>
        <label htmlFor="lm-sinif" className="block text-sm font-semibold text-navy">
          {t("sinif")} <span aria-hidden="true" className="text-red-500">*</span>
          <span className="sr-only"> ({t("zorunlu")})</span>
        </label>
        <select
          id="lm-sinif"
          required
          value={sinif}
          onChange={(e) => setSinif(e.target.value)}
          className={`${fieldClass} cursor-pointer`}
          disabled={loading}
        >
          <option value="">{t("sinifSec")}</option>
          {SINIFLAR.map((s) => (
            <option key={s} value={s}>
              {t("sinifEtiket", { sinif: s })}
            </option>
          ))}
        </select>
      </div>

      <div className="space-y-3 rounded-xl border border-gray-200 bg-gray-50 p-4">
        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={kvkk}
            onChange={(e) => setKvkk(e.target.checked)}
            className="mt-0.5 h-5 w-5 shrink-0 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
            disabled={loading}
          />
          <span className="text-sm leading-snug text-gray-700">
            {t.rich("kvkk", {
              gizlilik: (chunks) => (
                <Link href="/gizlilik" className="font-semibold text-brand-600 underline hover:text-brand-700" target="_blank">
                  {chunks}
                </Link>
              ),
            })}
            <span aria-hidden="true" className="ml-1 text-red-500">*</span>
            <span className="sr-only"> ({t("zorunlu")})</span>
          </span>
        </label>

        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={izinEposta}
            onChange={(e) => setIzinEposta(e.target.checked)}
            className="mt-0.5 h-5 w-5 shrink-0 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
            disabled={loading}
          />
          <span className="text-sm leading-snug text-gray-600">{t("izinEposta")}</span>
        </label>

        <p className="pt-1 text-xs leading-snug text-gray-500">
          {t.rich("izinKabul", {
            link: (chunks) => (
              <Link href="/ticari-ileti-izni" className="underline hover:text-brand-600" target="_blank">
                {chunks}
              </Link>
            ),
          })}
        </p>
      </div>

      <TurnstileWidget onToken={setCaptchaToken} resetKey={captchaKey} />

      {error && (
        <p role="alert" className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-error-700">
          {error}
        </p>
      )}

      <button
        type="submit"
        disabled={loading}
        className="flex min-h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 py-3 text-base font-extrabold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-60 motion-reduce:transition-none"
      >
        {loading ? t("gonderiliyor") : t("gonder")}
      </button>
    </form>
  );
}
