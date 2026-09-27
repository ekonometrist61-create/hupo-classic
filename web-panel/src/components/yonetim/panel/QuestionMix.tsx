"use client";

import { useTranslations } from "next-intl";

import ChartCard from "@/components/veli-paneli/ChartCard";
import type { DashboardSummary } from "../types";

export default function QuestionMix({
  data,
}: {
  data: DashboardSummary["sorular"];
}) {
  const t = useTranslations("yonetim.panel.mix");
  const max = Math.max(1, ...data.ders_dagilimi.map((d) => d.adet));
  const counts = [
    { key: "approved", value: data.onayli, cls: "text-success-600 dark:text-success-500" },
    { key: "pending", value: data.bekleyen, cls: "text-warning-600 dark:text-orange-400" },
    { key: "rejected", value: data.reddedilen, cls: "text-error-600 dark:text-error-500" },
  ] as const;

  return (
    <ChartCard title={t("title")} desc={t("desc", { count: data.toplam })}>
      <div className="mb-4 grid grid-cols-3 gap-3">
        {counts.map((c) => (
          <div
            key={c.key}
            className="rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/5"
          >
            <p className="text-theme-xs text-gray-500 dark:text-gray-400">
              {t(c.key)}
            </p>
            <p className={`text-lg font-semibold ${c.cls}`}>
              {c.value.toLocaleString("tr-TR")}
            </p>
          </div>
        ))}
      </div>
      {data.ders_dagilimi.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <ul className="space-y-3">
          {data.ders_dagilimi.map((d) => (
            <li key={d.ders}>
              <div className="mb-1 flex justify-between text-theme-sm">
                <span className="text-gray-700 dark:text-gray-300">
                  {d.ders}
                </span>
                <span className="font-medium text-gray-800 dark:text-white/90">
                  {d.adet.toLocaleString("tr-TR")}
                </span>
              </div>
              <div className="h-2 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div
                  className="h-full rounded-full bg-brand-500"
                  style={{ width: `${(d.adet / max) * 100}%` }}
                />
              </div>
            </li>
          ))}
        </ul>
      )}
    </ChartCard>
  );
}
