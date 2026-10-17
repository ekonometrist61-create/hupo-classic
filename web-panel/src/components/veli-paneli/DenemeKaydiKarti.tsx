"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

// K6: katılım (sınav kaydı için zorunlu) ve pazarlama (isteğe bağlı) onayları AYRI sürümlenir.
// Sürüm metinleri veritabanındaki consents.surum ile birebir eşleşir; metin değişirse sürüm artırılır.
const SINAV_KATILIM_SURUM = "sinav-katilim-2026-10-v1";
const SINAV_PAZARLAMA_SURUM = "sinav-pazarlama-2026-10-v1";

interface SinavRow {
  id: string;
  ad: string;
  baslangic_zamani: string;
  sure_dakika: number;
  kayitli: boolean;
  telefon: string;
}

interface Props {
  cocukId: string;
  cocukAd: string | null;
}

export default function DenemeKaydiKarti({ cocukId, cocukAd }: Props) {
  const t = useTranslations("veliPaneli.denemeKaydi");
  const [sinavlar, setSinavlar] = useState<SinavRow[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [formSinavId, setFormSinavId] = useState<string | null>(null);
  const [telefon, setTelefon] = useState("");
  // Katılım onayı zorunlu; pazarlama onayı isteğe bağlıdır. İkisi de işaretsiz başlar.
  const [katilimOnay, setKatilimOnay] = useState(false);
  const [pazarlamaOnay, setPazarlamaOnay] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    createClient()
      .rpc("get_upcoming_mock_exams_for_child", { p_cocuk_id: cocukId })
      .then(({ data, error: rpcErr }) => {
        if (cancelled) return;
        setLoading(false);
        if (rpcErr || !Array.isArray(data)) return;
        setSinavlar(data as SinavRow[]);
        const ilkTelefon = (data as SinavRow[]).find((s) => s.telefon)?.telefon ?? "";
        if (ilkTelefon) setTelefon(ilkTelefon);
      });
    return () => { cancelled = true; };
  }, [cocukId]);

  function formuAc(sinavId: string) {
    // Her açılışta onaylar sıfırlanır: onay bir önceki kayıttan devralınmaz.
    setError(null);
    setKatilimOnay(false);
    setPazarlamaOnay(false);
    setFormSinavId(formSinavId === sinavId ? null : sinavId);
  }

  async function kayitOl(sinavId: string) {
    setError(null);
    setSaving(true);
    const sb = createClient();

    // 1. Katılım onayı (zorunlu): sınav kaydı için gerekli; kendi tür kaydıyla saklanır.
    const { error: katilimErr } = await sb.rpc("set_exam_katilim_onayi", {
      p_cocuk_id: cocukId,
      p_surum: SINAV_KATILIM_SURUM,
    });
    if (katilimErr) {
      setError(t("consentError"));
      setSaving(false);
      return;
    }

    // 2. Pazarlama onayı (isteğe bağlı): yalnızca kutu işaretliyse kaydedilir.
    if (pazarlamaOnay) {
      const { error: pazarlamaErr } = await sb.rpc("set_exam_marketing_consent", {
        p_cocuk_id: cocukId,
        p_surum: SINAV_PAZARLAMA_SURUM,
      });
      if (pazarlamaErr) {
        setError(t("consentError"));
        setSaving(false);
        return;
      }
    }

    // 3. Sınava kayıt
    const { error: regErr } = await sb.rpc("register_for_mock_exam", {
      p_exam_id: sinavId,
      p_cocuk_id: cocukId,
      p_telefon: telefon.trim(),
      p_surum: SINAV_KATILIM_SURUM,
    });
    setSaving(false);
    if (regErr) {
      setError(regErr.message ?? t("registerError"));
      return;
    }

    // Listeyi güncelle
    setSinavlar((prev) =>
      prev ? prev.map((s) => (s.id === sinavId ? { ...s, kayitli: true } : s)) : prev
    );
    setFormSinavId(null);
    setKatilimOnay(false);
    setPazarlamaOnay(false);
  }

  if (loading) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900">
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      </div>
    );
  }

  if (!sinavlar || sinavlar.length === 0) return null;

  const formSinav = sinavlar.find((s) => s.id === formSinavId);
  const formAcik = formSinavId !== null && formSinav !== undefined && !formSinav.kayitli;

  return (
    <section
      aria-labelledby="deneme-kaydi-baslik"
      className="min-w-0 rounded-2xl border border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900 md:p-6"
    >
      <h3 id="deneme-kaydi-baslik" className="mb-3 text-base font-semibold text-gray-900 dark:text-white">
        {t("title")}
      </h3>
      <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
        {t("desc", { ad: cocukAd ?? "" })}
      </p>

      <ul className="space-y-3">
        {sinavlar.map((sinav) => (
          <li
            key={sinav.id}
            className="flex min-w-0 flex-col gap-3 rounded-xl border border-gray-100 p-3 dark:border-gray-800 sm:flex-row sm:items-center sm:justify-between"
          >
            <div className="min-w-0">
              <p className="font-medium wrap-break-word text-gray-900 dark:text-white">{sinav.ad}</p>
              <p className="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                {new Date(sinav.baslangic_zamani).toLocaleString("tr-TR", {
                  dateStyle: "medium",
                  timeStyle: "short",
                })}{" "}
                · {sinav.sure_dakika} dk
              </p>
            </div>

            {sinav.kayitli ? (
              <span className="inline-flex w-fit items-center gap-1 rounded-full bg-green-100 px-3 py-1 text-xs font-medium text-green-700 dark:bg-green-900/30 dark:text-green-400">
                <span aria-hidden>✓</span> {t("registered")}
              </span>
            ) : (
              <button
                type="button"
                onClick={() => formuAc(sinav.id)}
                aria-expanded={formSinavId === sinav.id}
                className="inline-flex min-h-11 w-full shrink-0 items-center justify-center rounded-lg bg-brand-500 px-4 text-sm font-medium text-white hover:bg-brand-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-400 sm:w-auto"
              >
                {t("register")}
              </button>
            )}
          </li>
        ))}
      </ul>

      {/* Kayıt formu: katılım onayı zorunlu, pazarlama onayı isteğe bağlı ve işaretsiz başlar (K6). */}
      {formAcik && (
        <div className="mt-4 rounded-xl border border-brand-100 bg-brand-50 p-4 dark:border-brand-900/30 dark:bg-brand-900/10">
          <p className="mb-3 text-sm font-medium text-gray-900 dark:text-white">
            {t("formTitle")}
          </p>

          <div className="space-y-4">
            <div>
              <label
                htmlFor="deneme-telefon"
                className="mb-1 block text-sm font-medium text-gray-700 dark:text-gray-300"
              >
                {t("phoneLabel")}
              </label>
              <input
                id="deneme-telefon"
                type="tel"
                autoComplete="tel"
                value={telefon}
                onChange={(e) => setTelefon(e.target.value)}
                placeholder="+90 5xx xxx xx xx"
                className="min-h-11 w-full rounded-lg border border-gray-300 px-3 py-2 text-base focus:border-brand-500 focus:outline-none md:text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white"
              />
              <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">{t("phoneDesc")}</p>
            </div>

            <fieldset className="space-y-2">
              <legend className="sr-only">{t("consentLegend")}</legend>

              <label className="flex min-h-11 cursor-pointer items-start gap-3 rounded-lg p-1 text-sm text-gray-700 dark:text-gray-300">
                <input
                  type="checkbox"
                  checked={katilimOnay}
                  onChange={(e) => setKatilimOnay(e.target.checked)}
                  className="mt-0.5 size-5 shrink-0 accent-brand-500"
                />
                <span className="min-w-0">
                  <span className="block font-medium text-gray-800 dark:text-white/90">
                    {t("katilimLabel")}
                  </span>
                  <span className="mt-0.5 block text-xs text-gray-500 dark:text-gray-400">
                    {t("katilimNot")}
                  </span>
                </span>
              </label>

              <label className="flex min-h-11 cursor-pointer items-start gap-3 rounded-lg p-1 text-sm text-gray-700 dark:text-gray-300">
                <input
                  type="checkbox"
                  checked={pazarlamaOnay}
                  onChange={(e) => setPazarlamaOnay(e.target.checked)}
                  className="mt-0.5 size-5 shrink-0 accent-brand-500"
                />
                <span className="min-w-0">
                  <span className="block font-medium text-gray-800 dark:text-white/90">
                    {t("pazarlamaLabel")}
                  </span>
                  <span className="mt-0.5 block text-xs text-gray-500 dark:text-gray-400">
                    {t("pazarlamaNot")}
                  </span>
                </span>
              </label>
            </fieldset>

            {error && (
              <p role="alert" className="text-sm text-error-500">{error}</p>
            )}

            <div className="flex flex-col gap-2 sm:flex-row">
              <button
                type="button"
                onClick={() => {
                  if (formSinavId) void kayitOl(formSinavId);
                }}
                disabled={saving || !katilimOnay || telefon.trim().length < 7}
                className="inline-flex min-h-11 flex-1 items-center justify-center rounded-lg bg-brand-500 px-4 text-sm font-medium text-white hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-50"
              >
                {saving ? t("saving") : t("confirmRegister")}
              </button>
              <button
                type="button"
                onClick={() => { setFormSinavId(null); setError(null); }}
                className="inline-flex min-h-11 items-center justify-center rounded-lg border border-gray-200 px-4 text-sm text-gray-600 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-400"
              >
                {t("cancel")}
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
