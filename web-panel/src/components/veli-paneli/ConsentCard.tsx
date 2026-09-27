"use client";

import Badge from "@/components/ui/badge/Badge";
import Button from "@/components/ui/button/Button";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import { PRIVACY_NOTICE_VERSION, type ParentConsent } from "./privacy";

interface ConsentCardProps {
  studentId: string;
}

interface Loaded {
  studentId: string;
  status: ParentConsent | "error";
}

// Çocuk için veri işleme açık rızasını verme / geri çekme kartı.
// Geri çekmek vermek kadar kolaydır (tek tık).
export default function ConsentCard({ studentId }: ConsentCardProps) {
  const t = useTranslations("veliPaneli.consent");
  const [loaded, setLoaded] = useState<Loaded | null>(null);
  const [saving, setSaving] = useState(false);
  const [saveFailed, setSaveFailed] = useState(false);

  useEffect(() => {
    let cancelled = false;

    createClient()
      .rpc("get_consent_status", {
        p_cocuk_id: studentId,
        p_surum: PRIVACY_NOTICE_VERSION,
      })
      .then(({ data, error }) => {
        if (cancelled) return;
        const status = (data as { veli_riza?: ParentConsent } | null)?.veli_riza;
        setLoaded({ studentId, status: error || !status ? "error" : status });
      });

    return () => {
      cancelled = true;
    };
  }, [studentId]);

  const status = loaded?.studentId === studentId ? loaded.status : null;

  async function update(giving: boolean) {
    setSaving(true);
    setSaveFailed(false);
    const { error } = await createClient().rpc("set_parental_consent", {
      p_cocuk_id: studentId,
      p_surum: PRIVACY_NOTICE_VERSION,
      p_veriyor: giving,
    });
    if (error) {
      setSaveFailed(true);
    } else {
      setLoaded({ studentId, status: giving ? "verildi" : "geri_cekildi" });
    }
    setSaving(false);
  }

  const badge =
    status === "verildi"
      ? { color: "success" as const, text: t("status.given") }
      : status === "geri_cekildi"
        ? { color: "warning" as const, text: t("status.withdrawn") }
        : { color: "warning" as const, text: t("status.none") };

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
          {t("title")}
        </h3>
        {status && status !== "error" && (
          <Badge size="sm" color={badge.color}>
            {badge.text}
          </Badge>
        )}
      </div>

      <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
        {t("desc")}
      </p>
      <p className="mt-3 rounded-xl bg-gray-50 p-4 text-theme-sm text-gray-700 dark:bg-white/5 dark:text-gray-300">
        {t("notice")}
      </p>

      {status === null && (
        <p className="mt-4 text-theme-sm text-gray-500 dark:text-gray-400">
          {t("loading")}
        </p>
      )}
      {status === "error" && (
        <p role="alert" className="mt-4 text-theme-sm text-error-500">
          {t("error")}
        </p>
      )}

      {status && status !== "error" && (
        <div className="mt-4 flex flex-wrap items-center gap-3">
          {status === "verildi" ? (
            <Button
              size="sm"
              variant="outline"
              disabled={saving}
              onClick={() => update(false)}
            >
              {t("withdraw")}
            </Button>
          ) : (
            <Button size="sm" disabled={saving} onClick={() => update(true)}>
              {t("give")}
            </Button>
          )}
          {saveFailed && (
            <span role="alert" className="text-theme-sm text-error-500">
              {t("saveError")}
            </span>
          )}
        </div>
      )}
    </div>
  );
}
