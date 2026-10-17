"use client";

import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

interface Abonelik {
  id: string;
  plan_kod: string | null;
  plan_ad: string | null;
  durum: "aktif" | "iptal" | "suresi_doldu" | "trial";
  baslangic: string;
  bitis: string | null;
  saglayici: string;
}

const DURUM_RENK: Record<string, "success" | "warning" | "error" | "info"> = {
  aktif: "success",
  trial: "info",
  iptal: "warning",
  suresi_doldu: "error",
};

function tarihFormatla(iso: string) {
  return new Date(iso).toLocaleDateString("tr-TR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

export default function AbonelikKarti() {
  const t = useTranslations("veliPaneli.abonelik");
  const [abonelik, setAbonelik] = useState<Abonelik | null | "yukleniyor">("yukleniyor");
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) { setAbonelik(null); return; }

      const { data, error } = await supabase
        .from("subscriptions")
        .select("id, plan_kod, durum, baslangic, bitis, saglayici, plans(ad)")
        .eq("veli_id", user.id)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (cancelled) return;
      if (error) { setHata(error.message); setAbonelik(null); return; }
      if (!data) { setAbonelik(null); return; }

      setAbonelik({
        id: data.id,
        plan_kod: data.plan_kod,
        plan_ad: (data.plans as unknown as { ad: string } | null)?.ad ?? data.plan_kod,
        durum: data.durum as Abonelik["durum"],
        baslangic: data.baslangic,
        bitis: data.bitis,
        saglayici: data.saglayici,
      });
    };
    void run();
    return () => { cancelled = true; };
  }, []);

  const durumEtiket = (d: string) => {
    const key = d as keyof typeof DURUM_RENK;
    return {
      renk: DURUM_RENK[key] ?? "warning",
      metin: t(`status.${key}` as Parameters<typeof t>[0]),
    };
  };

  return (
    <div className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>

      {abonelik === "yukleniyor" && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      )}

      {hata && (
        <p role="alert" className="text-sm text-error-500">{hata}</p>
      )}

      {abonelik === null && !hata && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("noSub")}</p>
      )}

      {abonelik && abonelik !== "yukleniyor" && (
        <div className="space-y-4">
          <div className="flex flex-wrap items-center gap-3">
            <span className="text-base font-semibold text-gray-800 dark:text-white/90">
              {abonelik.plan_ad ?? abonelik.plan_kod ?? t("bilinmiyor")}
            </span>
            <Badge size="sm" color={durumEtiket(abonelik.durum).renk}>
              {durumEtiket(abonelik.durum).metin}
            </Badge>
          </div>
          <dl className="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
            <div>
              <dt className="text-xs text-gray-500 dark:text-gray-400">{t("baslangic")}</dt>
              <dd className="font-medium text-gray-800 dark:text-white/80">
                {tarihFormatla(abonelik.baslangic)}
              </dd>
            </div>
            <div>
              <dt className="text-xs text-gray-500 dark:text-gray-400">{t("bitis")}</dt>
              <dd className="font-medium text-gray-800 dark:text-white/80">
                {abonelik.bitis ? tarihFormatla(abonelik.bitis) : t("bilinmiyor")}
              </dd>
            </div>
            <div>
              <dt className="text-xs text-gray-500 dark:text-gray-400">{t("saglayici")}</dt>
              <dd className="font-medium text-gray-800 dark:text-white/80">
                {abonelik.saglayici || t("bilinmiyor")}
              </dd>
            </div>
          </dl>

          {/* Yenileme ve iptal: yalnızca veritabanında olan bilgi gösterilir; eksik olan "bilinmiyor" olur. */}
          <div className="border-t border-gray-100 pt-4 dark:border-gray-800">
            <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">
              {t("yenilemeBaslik")}
            </h4>
            <dl className="mt-2 space-y-1 text-sm text-gray-700 dark:text-gray-300">
              <div>
                <dt className="inline font-medium">{t("yenileme")}: </dt>
                <dd className="inline">{t("bilinmiyor")}</dd>
              </div>
            </dl>
            <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">
              {t("iptalNot")}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
