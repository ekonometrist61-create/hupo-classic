"use client";

// Hikâye Atölyesi sekmeleri için ortak durum gösterimi ve hata metni.
import { useTranslations } from "next-intl";

import { hataAnahtari, hataAyrinti } from "@/lib/okuma/okuma";
import ErrorNote from "../panel/ErrorNote";
import { outlineBtn } from "../panel/styles";

/** Sunucu hata iletisini Türkçe, nazik bir cümleye çevirir (teknik günlük göstermez). */
export function useHataMetni() {
  const t = useTranslations("yonetim.hikayeAtolyesi");
  return (mesaj: string): string => {
    const ayrinti = hataAyrinti(mesaj);
    return `${t(`hatalar.${hataAnahtari(mesaj)}`)}${ayrinti ? ` ${ayrinti}` : ""}`;
  };
}

interface DurumProps {
  loading: boolean;
  error: string | null;
  /** RPC veritabanında yok (migration uygulanmamış). */
  missing: boolean;
  onRetry: () => void;
}

/** Yükleniyor / kurulum yok / hata durumları; hiçbiri yoksa null döner. */
export function VeriDurumu({ loading, error, missing, onRetry }: DurumProps) {
  const t = useTranslations("yonetim.hikayeAtolyesi");
  const hata = useHataMetni();
  if (loading) {
    return (
      <p role="status" className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">
        {t("loading")}
      </p>
    );
  }
  if (missing) {
    return (
      <p
        role="status"
        className="rounded-lg bg-warning-50 px-3 py-2 text-theme-sm text-warning-700 dark:bg-warning-500/15 dark:text-warning-400"
      >
        {t("kurulumYok")}
      </p>
    );
  }
  if (error) {
    return (
      <div className="space-y-3">
        <ErrorNote message={hata(error)} />
        <button type="button" className={outlineBtn} onClick={onRetry}>
          {t("tekrarDene")}
        </button>
      </div>
    );
  }
  return null;
}

export const kartAlt = "rounded-xl border border-gray-200 p-4 dark:border-gray-800";
