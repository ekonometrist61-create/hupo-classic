"use client";

import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { useState } from "react";

const KVKK_SURUM = "deneme-kayit-kvkk-2026-10-v1";
const IZIN_SURUM = "deneme-kayit-izin-2026-10-v1";

const fieldClass =
  "mt-1.5 block h-12 w-full rounded-xl border border-gray-300 bg-white px-4 text-base text-navy placeholder:text-gray-400 focus:border-brand-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-50";

const SINIFLAR = [3, 4, 5, 6, 7, 8];

interface Props {
  examId: string;
  examAd: string;
  siniflar: number[]; // sınavın desteklediği sınıflar
}

export default function DenemeKayitForm({ examId, examAd, siniflar }: Props) {
  const t = useTranslations("landing.denemeKayit");

  const [veliAd, setVeliAd] = useState("");
  const [cocukAd, setCocukAd] = useState("");
  const [sinif, setSinif] = useState("");
  const [eposta, setEposta] = useState("");
  const [telefon, setTelefon] = useState("");
  const [kvkk, setKvkk] = useState(false);
  const [izinEposta, setIzinEposta] = useState(false);
  const [izinSms, setIzinSms] = useState(false);
  const [izinTelefon, setIzinTelefon] = useState(false);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const desteklenenSiniflar = SINIFLAR.filter((s) => siniflar.includes(s));

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);

    if (!veliAd.trim() || !cocukAd.trim() || !sinif || !eposta.trim() || !telefon.trim()) {
      setError(t("errRequired"));
      return;
    }
    if (!kvkk) {
      setError(t("errKvkk"));
      return;
    }

    setLoading(true);

    try {
      const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
      const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
      const functionUrl = `${supabaseUrl}/functions/v1/deneme-on-kayit`;

      const res = await fetch(functionUrl, {
        method: "POST",
        headers: {
          "content-type": "application/json",
          apikey: anonKey,
        },
        body: JSON.stringify({
          exam_id: examId,
          veli_ad: veliAd.trim(),
          cocuk_ad: cocukAd.trim(),
          sinif: parseInt(sinif, 10),
          eposta: eposta.trim().toLowerCase(),
          telefon: telefon.trim(),
          kvkk_onay: kvkk,
          kvkk_surum: KVKK_SURUM,
          izin_surum: IZIN_SURUM,
          izin_eposta: izinEposta,
          izin_sms: izinSms,
          izin_telefon: izinTelefon,
        }),
      });

      const data = await res.json() as { on_kayit_id?: string; hata?: string };

      if (!res.ok) {
        setError(data.hata ?? t("errGeneric"));
        return;
      }

      setSuccess(true);
    } catch {
      setError(t("errGeneric"));
    } finally {
      setLoading(false);
    }
  }

  if (success) {
    return (
      <div className="text-center">
        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
          <svg className="h-8 w-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 className="text-2xl font-extrabold text-navy">{t("successTitle")}</h2>
        <p className="mt-2 text-base leading-relaxed text-gray-600">{t("successDesc")}</p>
        <Link
          href="/"
          className="mt-6 inline-flex items-center justify-center rounded-xl bg-brand-500 px-6 py-3 text-base font-extrabold text-white shadow-sm hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("successBack")}
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-5">
      <p className="rounded-xl bg-brand-50 px-4 py-3 text-sm font-semibold text-brand-700">
        {t("examLabel")}: <span className="font-extrabold">{examAd}</span>
      </p>

      <div className="grid gap-5 sm:grid-cols-2">
        <div>
          <label htmlFor="veli-ad" className="block text-sm font-semibold text-navy">
            {t("veliAd")} <span aria-hidden="true" className="text-red-500">*</span>
          </label>
          <input
            id="veli-ad"
            type="text"
            autoComplete="name"
            required
            value={veliAd}
            onChange={(e) => setVeliAd(e.target.value)}
            className={fieldClass}
            disabled={loading}
          />
        </div>
        <div>
          <label htmlFor="cocuk-ad" className="block text-sm font-semibold text-navy">
            {t("cocukAd")} <span aria-hidden="true" className="text-red-500">*</span>
          </label>
          <input
            id="cocuk-ad"
            type="text"
            autoComplete="off"
            required
            value={cocukAd}
            onChange={(e) => setCocukAd(e.target.value)}
            className={fieldClass}
            disabled={loading}
          />
        </div>
      </div>

      <div>
        <label htmlFor="sinif" className="block text-sm font-semibold text-navy">
          {t("sinif")} <span aria-hidden="true" className="text-red-500">*</span>
        </label>
        <select
          id="sinif"
          required
          value={sinif}
          onChange={(e) => setSinif(e.target.value)}
          className={`${fieldClass} cursor-pointer`}
          disabled={loading}
        >
          <option value="">{t("sinifSec")}</option>
          {desteklenenSiniflar.map((s) => (
            <option key={s} value={s}>
              {s}. Sınıf
            </option>
          ))}
        </select>
      </div>

      <div className="grid gap-5 sm:grid-cols-2">
        <div>
          <label htmlFor="eposta" className="block text-sm font-semibold text-navy">
            {t("eposta")} <span aria-hidden="true" className="text-red-500">*</span>
          </label>
          <input
            id="eposta"
            type="email"
            autoComplete="email"
            required
            value={eposta}
            onChange={(e) => setEposta(e.target.value)}
            className={fieldClass}
            disabled={loading}
          />
        </div>
        <div>
          <label htmlFor="telefon" className="block text-sm font-semibold text-navy">
            {t("telefon")} <span aria-hidden="true" className="text-red-500">*</span>
          </label>
          <input
            id="telefon"
            type="tel"
            autoComplete="tel"
            required
            placeholder={t("telefonHint")}
            value={telefon}
            onChange={(e) => setTelefon(e.target.value)}
            className={fieldClass}
            disabled={loading}
          />
        </div>
      </div>

      {/* Onay kutuları */}
      <div className="space-y-3 rounded-xl border border-gray-200 bg-gray-50 p-4">
        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={kvkk}
            onChange={(e) => setKvkk(e.target.checked)}
            className="mt-0.5 h-4 w-4 shrink-0 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
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
          </span>
        </label>

        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={izinEposta}
            onChange={(e) => setIzinEposta(e.target.checked)}
            className="mt-0.5 h-4 w-4 shrink-0 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
            disabled={loading}
          />
          <span className="text-sm leading-snug text-gray-600">{t("izinEposta")}</span>
        </label>

        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={izinSms}
            onChange={(e) => setIzinSms(e.target.checked)}
            className="mt-0.5 h-4 w-4 shrink-0 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
            disabled={loading}
          />
          <span className="text-sm leading-snug text-gray-600">{t("izinSms")}</span>
        </label>

        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={izinTelefon}
            onChange={(e) => setIzinTelefon(e.target.checked)}
            className="mt-0.5 h-4 w-4 shrink-0 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
            disabled={loading}
          />
          <span className="text-sm leading-snug text-gray-600">{t("izinTelefon")}</span>
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

      {error && (
        <p role="alert" className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </p>
      )}

      <button
        type="submit"
        disabled={loading}
        className="flex min-h-12 w-full items-center justify-center rounded-xl bg-brand-500 px-6 py-3 text-base font-extrabold text-white shadow-sm transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-60 motion-reduce:transition-none"
      >
        {loading ? t("submitting") : t("submit")}
      </button>
    </form>
  );
}
