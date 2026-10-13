"use client";

import { useTranslations } from "next-intl";

import type { DailyStudy } from "./types";

interface Props {
  haftalik: DailyStudy[];
}

function formatSure(sure: number | string): string {
  const dk = typeof sure === "string" ? parseFloat(sure) : sure;
  if (isNaN(dk) || dk <= 0) return "—";
  if (dk < 1) return `${Math.round(dk * 60)} sn`;
  return `${Math.round(dk)} dk`;
}

export default function ActivityView({ haftalik }: Props) {
  const t = useTranslations("veliPaneli.activityPage");

  const sorted = [...haftalik].sort((a, b) => b.gun.localeCompare(a.gun));
  const hasActivity = sorted.some(
    (d) => typeof d.soru_sayisi === "number" && d.soru_sayisi > 0
  );

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="mb-1 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>
      <p className="mb-5 text-sm text-gray-500 dark:text-gray-400">{t("desc")}</p>

      {!hasActivity ? (
        <p className="py-6 text-center text-sm text-gray-400">{t("empty")}</p>
      ) : (
        <ol className="space-y-3">
          {sorted.map((d) => {
            const sorular = typeof d.soru_sayisi === "number" ? d.soru_sayisi : 0;
            const dogru = typeof d.dogru_sayisi === "number" ? d.dogru_sayisi : 0;
            const aktif = sorular > 0;
            const tarih = new Date(d.gun).toLocaleDateString("tr-TR", {
              weekday: "long",
              day: "numeric",
              month: "long",
            });

            return (
              <li
                key={d.gun}
                className={[
                  "flex items-center gap-4 rounded-xl border p-4",
                  aktif
                    ? "border-brand-200 bg-brand-50 dark:border-brand-900/30 dark:bg-brand-900/10"
                    : "border-gray-100 bg-gray-50 dark:border-gray-700 dark:bg-gray-800/50",
                ].join(" ")}
              >
                {/* Gün ikonu */}
                <span
                  className={[
                    "flex h-10 w-10 shrink-0 items-center justify-center rounded-xl text-lg",
                    aktif
                      ? "bg-brand-500 text-white"
                      : "bg-gray-200 text-gray-400 dark:bg-gray-700",
                  ].join(" ")}
                  aria-hidden
                >
                  {aktif ? "📚" : "·"}
                </span>

                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold text-gray-800 dark:text-white/90">
                    {tarih}
                  </p>
                  {aktif ? (
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      {sorular} {t("questions")} · {dogru} {t("correct")} ·{" "}
                      {formatSure(d.sure_dk)} {t("study")}
                    </p>
                  ) : (
                    <p className="text-xs text-gray-400">{t("noActivity")}</p>
                  )}
                </div>

                {aktif && (
                  <div className="shrink-0 text-right">
                    <p className="text-sm font-bold text-brand-600 dark:text-brand-400">
                      {sorular > 0
                        ? `%${Math.round((dogru / sorular) * 100)}`
                        : "—"}
                    </p>
                    <p className="text-xs text-gray-400">{t("accuracy")}</p>
                  </div>
                )}
              </li>
            );
          })}
        </ol>
      )}
    </div>
  );
}
