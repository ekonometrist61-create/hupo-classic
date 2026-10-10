"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

const SINAV_PAZARLAMA_SURUM = "sinav-kayit-kvkk-2026-10-v1";

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
  const [kvkk, setKvkk] = useState(false);
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

  async function kayitOl(sinavId: string) {
    setError(null);
    setSaving(true);
    const sb = createClient();

    // 1. Önce KVKK onayını kaydet
    const { error: consentErr } = await sb.rpc("set_exam_marketing_consent", {
      p_cocuk_id: cocukId,
      p_surum: SINAV_PAZARLAMA_SURUM,
    });
    if (consentErr) {
      setError(t("consentError"));
      setSaving(false);
      return;
    }

    // 2. Sınava kayıt
    const { error: regErr } = await sb.rpc("register_for_mock_exam", {
      p_exam_id: sinavId,
      p_cocuk_id: cocukId,
      p_telefon: telefon.trim(),
      p_surum: SINAV_PAZARLAMA_SURUM,
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
  }

  if (loading) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900">
        <p className="text-sm text-gray-400">{t("loading")}</p>
      </div>
    );
  }

  if (!sinavlar || sinavlar.length === 0) return null;

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900 md:p-6">
      <h2 className="mb-3 text-base font-semibold text-gray-900 dark:text-white">
        {t("title")}
      </h2>
      <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
        {t("desc", { ad: cocukAd ?? "" })}
      </p>

      <div className="space-y-3">
        {sinavlar.map((sinav) => (
          <div
            key={sinav.id}
            className="flex flex-col gap-3 rounded-xl border border-gray-100 p-3 dark:border-gray-800 sm:flex-row sm:items-center sm:justify-between"
          >
            <div>
              <p className="font-medium text-gray-900 dark:text-white">{sinav.ad}</p>
              <p className="mt-0.5 text-xs text-gray-500">
                {new Date(sinav.baslangic_zamani).toLocaleString("tr-TR", {
                  dateStyle: "medium",
                  timeStyle: "short",
                })}{" "}
                · {sinav.sure_dakika} dk
              </p>
            </div>

            {sinav.kayitli ? (
              <span className="inline-flex items-center gap-1 rounded-full bg-green-100 px-3 py-1 text-xs font-medium text-green-700 dark:bg-green-900/30 dark:text-green-400">
                ✓ {t("registered")}
              </span>
            ) : (
              <button
                onClick={() =>
                  setFormSinavId(formSinavId === sinav.id ? null : sinav.id)
                }
                className="shrink-0 rounded-lg bg-brand-500 px-4 py-2 text-sm font-medium text-white hover:bg-brand-600 focus:outline-none focus:ring-2 focus:ring-brand-400"
              >
                {t("register")}
              </button>
            )}
          </div>
        ))}
      </div>

      {/* Kayıt formu */}
      {formSinavId && !sinavlar.find((s) => s.id === formSinavId)?.kayitli && (
        <div className="mt-4 rounded-xl border border-brand-100 bg-brand-50 p-4 dark:border-brand-900/30 dark:bg-brand-900/10">
          <p className="mb-3 text-sm font-medium text-gray-900 dark:text-white">
            {t("formTitle")}
          </p>

          <div className="space-y-3">
            <div>
              <label className="mb-1 block text-xs font-medium text-gray-700 dark:text-gray-300">
                {t("phoneLabel")}
              </label>
              <input
                type="tel"
                value={telefon}
                onChange={(e) => setTelefon(e.target.value)}
                placeholder="+90 5xx xxx xx xx"
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none dark:border-gray-700 dark:bg-gray-900 dark:text-white"
              />
              <p className="mt-1 text-xs text-gray-400">{t("phoneDesc")}</p>
            </div>

            <label className="flex items-start gap-2 text-xs text-gray-600 dark:text-gray-400">
              <input
                type="checkbox"
                checked={kvkk}
                onChange={(e) => setKvkk(e.target.checked)}
                className="mt-0.5 shrink-0"
              />
              {t("kvkkLabel")}
            </label>

            {error && (
              <p className="text-xs text-red-600 dark:text-red-400">{error}</p>
            )}

            <div className="flex gap-2">
              <button
                onClick={() => kayitOl(formSinavId)}
                disabled={saving || !kvkk || telefon.trim().length < 7}
                className="flex-1 rounded-lg bg-brand-500 px-4 py-2 text-sm font-medium text-white hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-50"
              >
                {saving ? t("saving") : t("confirmRegister")}
              </button>
              <button
                onClick={() => { setFormSinavId(null); setError(null); }}
                className="rounded-lg border border-gray-200 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-400"
              >
                {t("cancel")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
