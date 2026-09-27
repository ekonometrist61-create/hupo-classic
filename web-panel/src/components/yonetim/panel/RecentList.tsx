"use client";

import { useTranslations } from "next-intl";

import ChartCard from "@/components/veli-paneli/ChartCard";
import { formatDate, formatKurus } from "@/utils/format";
import type { DashboardSummary } from "../types";
import StatusBadge from "./StatusBadge";

const PAY_KEYS = [
  ["basarili_adet", "basarili"],
  ["bekleyen_adet", "beklemede"],
  ["basarisiz_adet", "basarisiz"],
  ["iade_adet", "iade"],
] as const;

export function PaymentStatusCounts({
  data,
}: {
  data: DashboardSummary["odemeler"];
}) {
  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      {PAY_KEYS.map(([field, status]) => (
        <div
          key={status}
          className="rounded-2xl border border-gray-200 bg-white px-4 py-3 dark:border-gray-800 dark:bg-white/3"
        >
          <StatusBadge status={status} />
          <p className="mt-2 text-xl font-semibold text-gray-800 dark:text-white/90">
            {data[field].toLocaleString("tr-TR")}
          </p>
        </div>
      ))}
    </div>
  );
}

export function RecentPayments({
  data,
}: {
  data: DashboardSummary["son_odemeler"];
}) {
  const t = useTranslations("yonetim.panel.recentPayments");
  return (
    <ChartCard title={t("title")}>
      {data.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <ul className="divide-y divide-gray-100 dark:divide-gray-800">
          {data.map((p, i) => (
            <li
              key={`${p.tarih}-${i}`}
              className="flex items-center justify-between gap-3 py-3"
            >
              <div className="min-w-0">
                <p className="truncate text-sm font-medium text-gray-800 dark:text-white/90">
                  {p.veli_ad ?? "-"}
                </p>
                <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                  {formatDate(new Date(p.tarih))}
                </p>
              </div>
              <div className="flex shrink-0 items-center gap-3">
                <StatusBadge status={p.durum} />
                <span className="text-sm font-semibold text-gray-800 dark:text-white/90">
                  {formatKurus(p.tutar_kurus)}
                </span>
              </div>
            </li>
          ))}
        </ul>
      )}
    </ChartCard>
  );
}

export function RecentActions({
  data,
}: {
  data: DashboardSummary["son_islemler"];
}) {
  const t = useTranslations("yonetim.panel.recentActions");
  const codes = useTranslations("yonetim.panel.islem");
  return (
    <ChartCard title={t("title")}>
      {data.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <ul className="divide-y divide-gray-100 dark:divide-gray-800">
          {data.map((a, i) => (
            <li
              key={`${a.tarih}-${i}`}
              className="flex items-center justify-between gap-3 py-3"
            >
              <div className="min-w-0">
                <p className="text-sm font-medium text-gray-800 dark:text-white/90">
                  {codes.has(a.islem) ? codes(a.islem) : a.islem}
                </p>
                <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                  {a.admin_ad ?? "-"}
                </p>
              </div>
              <span className="shrink-0 text-theme-xs text-gray-500 dark:text-gray-400">
                {formatDate(new Date(a.tarih))}
              </span>
            </li>
          ))}
        </ul>
      )}
    </ChartCard>
  );
}
