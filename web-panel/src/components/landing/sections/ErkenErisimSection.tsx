"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { type FormEvent, useState } from "react";

const inputClass =
  "w-full rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm text-navy placeholder:text-gray-400 focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-800 dark:text-white dark:placeholder:text-gray-500";

export function ErkenErisimSection() {
  const t = useTranslations("landing.erkenErisim");
  const [ad, setAd] = useState("");
  const [email, setEmail] = useState("");
  const [telefon, setTelefon] = useState("");
  const [izin, setIzin] = useState(false);
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [errorMsg, setErrorMsg] = useState("");

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

    setStatus("loading");
    setErrorMsg("");

    const { error } = await createClient().rpc("veli_adayi_olustur", {
      p_email: trimmedEmail,
      p_ad: trimmedAd,
      p_telefon: telefon.trim() || null,
      p_kaynak: "landing_erken_erisim",
      p_pazarlama_izni: izin,
    });

    if (error) {
      setErrorMsg(t("errorGeneric"));
      setStatus("error");
    } else {
      setStatus("success");
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
              <p role="alert" className="text-sm font-medium text-error-500">
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
