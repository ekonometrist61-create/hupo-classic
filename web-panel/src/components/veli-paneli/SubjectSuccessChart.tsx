"use client";

import { useTranslations } from "next-intl";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  LabelList,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import ChartCard from "./ChartCard";
import { CHART_COLORS, successColor } from "./chartTheme";
import type { SubjectSuccess } from "./types";

const ROW_HEIGHT = 48;
const MIN_EVIDENCE = 6;

export default function SubjectSuccessChart({
  data,
}: {
  data: SubjectSuccess[];
}) {
  const t = useTranslations("veliPaneli.subjects");

  const sufficient = data.filter((d) => d.toplam >= MIN_EVIDENCE);
  const insufficient = data.filter((d) => d.toplam < MIN_EVIDENCE);

  return (
    <ChartCard title={t("title")} desc={t("desc")}>
      {data.length === 0 ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <>
          {sufficient.length > 0 && (
            <div
              style={{
                height: Math.max(220, sufficient.length * ROW_HEIGHT + 40),
              }}
            >
              <ResponsiveContainer
                width="100%"
                height="100%"
                initialDimension={{
                  width: 560,
                  height: Math.max(220, sufficient.length * ROW_HEIGHT + 40),
                }}
              >
                <BarChart
                  data={sufficient}
                  layout="vertical"
                  margin={{ top: 4, right: 40, bottom: 4, left: 0 }}
                >
                  <CartesianGrid
                    horizontal={false}
                    stroke={CHART_COLORS.axis}
                    strokeOpacity={0.25}
                  />
                  <XAxis
                    type="number"
                    domain={[0, 100]}
                    tickFormatter={(v: number) => `%${v}`}
                    tick={{ fill: CHART_COLORS.axis, fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis
                    type="category"
                    dataKey="ders"
                    width={110}
                    tick={{ fill: CHART_COLORS.axis, fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <Tooltip
                    cursor={{ fill: CHART_COLORS.axis, fillOpacity: 0.12 }}
                    content={({ active, payload }) => {
                      const row = payload?.[0]?.payload as
                        | SubjectSuccess
                        | undefined;
                      if (!active || !row) return null;
                      return (
                        <div className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-theme-sm shadow-theme-md dark:border-gray-700 dark:bg-gray-800">
                          <p className="font-medium text-gray-800 dark:text-white/90">
                            {row.ders}: %{row.oran}
                          </p>
                          <p className="text-gray-500 dark:text-gray-400">
                            {t("tooltip", {
                              dogru: row.dogru,
                              toplam: row.toplam,
                            })}
                          </p>
                        </div>
                      );
                    }}
                  />
                  <Bar dataKey="oran" radius={[0, 6, 6, 0]} barSize={22}>
                    {sufficient.map((row) => (
                      <Cell key={row.ders} fill={successColor(row.oran)} />
                    ))}
                    <LabelList
                      dataKey="oran"
                      position="right"
                      formatter={(v: number) => `%${v}`}
                      fill={CHART_COLORS.axis}
                      fontSize={12}
                    />
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}

          {insufficient.length > 0 && (
            <div className="mt-3 space-y-1 border-t border-gray-100 pt-3 dark:border-gray-700">
              {insufficient.map((row) => (
                <p
                  key={row.ders}
                  className="text-xs text-gray-500 dark:text-gray-400"
                >
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    {row.ders}
                  </span>{" "}
                  — {t("tooltip", { dogru: row.dogru, toplam: row.toplam })} ·{" "}
                  <span className="italic">{t("insufficient")}</span>
                </p>
              ))}
            </div>
          )}

          {sufficient.length === 0 && (
            <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
              {t("insufficient")}
            </p>
          )}
        </>
      )}
    </ChartCard>
  );
}
