"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

// Velinin kendi ticari ileti iznini görüp değiştirdiği kart. Geri almak tek tıkla
// yapılır; her değişiklik veritabanında iletisim_tercih_gecmisi'ne yazılır.
export default function IletisimIzniCard() {
  const t = useTranslations("veliPaneli.iletisimIzni");
  const [izin, setIzin] = useState<boolean | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    createClient()
      .rpc("veli_tercihlerim")
      .then(({ data, error: rpcError }) => {
        if (cancelled) return;
        if (rpcError || !Array.isArray(data)) {
          setError(t("loadError"));
          return;
        }
        const eposta = (data as { kanal: string; izin: boolean }[]).find(
          (satir) => satir.kanal === "eposta"
        );
        setIzin(eposta?.izin ?? false);
      });

    return () => {
      cancelled = true;
    };
  }, [t]);

  async function degistir(yeniIzin: boolean) {
    setSaving(true);
    setError(null);
    const { error: rpcError } = await createClient().rpc("veli_tercih_ayarla", {
      p_kanal: "eposta",
      p_izin: yeniIzin,
    });
    setSaving(false);
    if (rpcError) {
      setError(t("error"));
      return;
    }
    setIzin(yeniIzin);
  }

  return (
    <section className="rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-800 dark:bg-white/[0.03]">
      <h2 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h2>
      <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">{t("text")}</p>

      <label className="mt-4 flex min-h-11 cursor-pointer items-center justify-between gap-4">
        <span className="text-sm font-medium text-gray-800 dark:text-white/90">{t("emailLabel")}</span>
        <input
          type="checkbox"
          role="switch"
          aria-checked={izin ?? false}
          checked={izin ?? false}
          disabled={izin === null || saving}
          onChange={(e) => degistir(e.target.checked)}
          className="size-5 accent-brand-500"
        />
      </label>

      {saving && <p className="mt-2 text-xs text-gray-500">{t("saving")}</p>}
      {error && (
        <p role="alert" className="mt-2 text-sm text-error-500">
          {error}
        </p>
      )}
    </section>
  );
}
