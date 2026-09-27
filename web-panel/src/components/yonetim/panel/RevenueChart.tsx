"use client";

import { useLocale, useTranslations } from "next-intl";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import ChartCard from "@/components/veli-paneli/ChartCard";
import { CHART_COLORS } from "@/components/veli-paneli/chartTheme";
import { formatKurus } from "@/utils/format";
import type { DashboardSummary } from "../types";
import { MONTHS_EN, MONTHS_TR, monthLabel } from "./helpers";

export default function RevenueChart({
  data,
}: {
  data: DashboardSummary["odemeler"]["aylik"];
}) {
  const t = useTranslations("yonetim.panel.revenue");
  const locale = useLocale();
  const months = locale === "en" ? MONTHS_EN : MONTHS_TR;
  const rows = data.map((d) => ({ ...d, label: monthLabel(d.ay, months) }));
  const hasRevenue = rows.some((r) => r.tutar_kurus > 0);

  return (
    <ChartCard title={t("title")} desc={t("desc")}>
      {!hasRevenue ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={rows}
              margin={{ top: 8, right: 8, bottom: 0, left: 8 }}
            >
              <CartesianGrid
                vertical={false}
                stroke={CHART_COLORS.axis}
                strokeOpacity={0.25}
              />
              <XAxis
                dataKey="label"
                tick={{ fill: CHART_COLORS.axis, fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                width={80}
                tickFormatter={(v: number) => formatKurus(v)}
                tick={{ fill: CHART_COLORS.axis, fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <Tooltip
                cursor={{ fill: CHART_COLORS.axis, fillOpacity: 0.12 }}
                content={({ active, payload }) => {
                  const row = payload?.[0]?.payload as
                    | (typeof rows)[number]
                    | undefined;
                  if (!active || !row) return null;
                  return (
                    <div className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-theme-sm shadow-theme-md dark:border-gray-700 dark:bg-gray-800">
                      <p className="font-medium text-gray-800 dark:text-white/90">
                        {row.label}
                      </p>
                      <p className="text-gray-500 dark:text-gray-400">
                        {t("amount")}: {formatKurus(row.tutar_kurus)}
                      </p>
                      <p className="text-gray-500 dark:text-gray-400">
                        {t("count")}: {row.adet}
                      </p>
                    </div>
                  );
                }}
              />
              <Bar
                dataKey="tutar_kurus"
                fill={CHART_COLORS.brand}
                radius={[6, 6, 0, 0]}
                maxBarSize={48}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
    </ChartCard>
  );
}
