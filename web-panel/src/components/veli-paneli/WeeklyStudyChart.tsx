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

import ChartCard from "./ChartCard";
import { formatDate } from "@/utils/format";
import { CHART_COLORS } from "./chartTheme";
import type { DailyStudy } from "./types";

// "2026-09-20" → yerel tarih (saat dilimi kaymasını önlemek için parçalayarak)
function parseDay(day: string): Date {
  const [y, m, d] = day.split("-").map(Number);
  return new Date(y, m - 1, d);
}

export default function WeeklyStudyChart({ data }: { data: DailyStudy[] }) {
  const t = useTranslations("veliPaneli.weekly");
  const locale = useLocale();

  const rows = data.map((d) => ({
    ...d,
    sure_dk: Number(d.sure_dk),
    label: parseDay(d.gun).toLocaleDateString(locale, { weekday: "short" }),
    // GG.AA.YYYY + gün adı, örn. "20.09.2026 Pazar"
    fullLabel: `${formatDate(parseDay(d.gun))} ${parseDay(d.gun).toLocaleDateString(locale, { weekday: "long" })}`,
  }));
  const hasActivity = rows.some((r) => r.sure_dk > 0);

  return (
    <ChartCard title={t("title")} desc={t("desc")}>
      {!hasActivity ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={rows}
              margin={{ top: 8, right: 8, bottom: 0, left: -16 }}
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
                allowDecimals={false}
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
                        {row.fullLabel}
                      </p>
                      <p className="text-gray-500 dark:text-gray-400">
                        {t("minutesLabel")}: {row.sure_dk}
                      </p>
                      <p className="text-gray-500 dark:text-gray-400">
                        {t("questionsLabel")}: {row.soru_sayisi}
                      </p>
                    </div>
                  );
                }}
              />
              <Bar
                dataKey="sure_dk"
                fill={CHART_COLORS.brand}
                radius={[6, 6, 0, 0]}
                maxBarSize={40}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
    </ChartCard>
  );
}
