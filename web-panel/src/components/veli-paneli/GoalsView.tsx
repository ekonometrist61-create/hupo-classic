"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import type { DailyStudy } from "./types";

interface GoalData {
  hedef: number;
  bugun: number;
  tamamlandi: boolean;
  seri_kalkani: number;
}

interface Props {
  studentId: string;
  haftalik: DailyStudy[];
}

export default function GoalsView({ studentId, haftalik }: Props) {
  const t = useTranslations("veliPaneli.goalsPage");
  const [goal, setGoal] = useState<GoalData | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    let cancelled = false;
    createClient()
      .rpc("get_daily_goal", { p_student_id: studentId })
      .then(({ data, error: e }) => {
        if (cancelled) return;
        if (e || !data) { setError(true); return; }
        setGoal(data as GoalData);
      });
    return () => { cancelled = true; };
  }, [studentId]);

  const tamamlananGun = haftalik.filter(
    (d) => typeof d.soru_sayisi === "number" && d.soru_sayisi > 0
  ).length;

  return (
    <div className="space-y-6">
      {/* Bugünkü hedef */}
      <div className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
        <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">
          {t("title")}
        </h3>
        <p className="mb-5 text-sm text-gray-500 dark:text-gray-400">{t("desc")}</p>

        {error && (
          <p role="alert" className="text-sm text-error-500">{t("loadError")}</p>
        )}

        {!error && !goal && (
          <p className="text-sm text-gray-400">{t("loading")}</p>
        )}

        {goal && (
          <div className="space-y-4">
            {/* İlerleme çubuğu */}
            <div>
              <div className="mb-2 flex items-center justify-between text-sm">
                <span className="font-medium text-gray-700 dark:text-gray-200">
                  {t("todayProgress", { bugun: goal.bugun, hedef: goal.hedef })}
                </span>
                {goal.tamamlandi && (
                  <span className="rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-bold text-green-700 dark:bg-green-900/30 dark:text-green-400">
                    {t("completed")}
                  </span>
                )}
              </div>
              <div className="h-3 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-gray-700">
                <div
                  className="h-full rounded-full bg-brand-500 transition-all duration-500"
                  style={{
                    // Hedef 0 veya tanımsızsa ilerleme sıfır gösterilir (sıfıra bölme olmaz).
                    width: `${goal.hedef > 0 ? Math.min(100, Math.round((goal.bugun / goal.hedef) * 100)) : 0}%`,
                  }}
                />
              </div>
            </div>

            {/* Seri koruyucu */}
            {goal.seri_kalkani > 0 && (
              <p className="text-sm text-amber-600 dark:text-amber-400">
                {t("shield", { sayi: goal.seri_kalkani })}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Haftalık tamamlama */}
      <div className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
        <h3 className="mb-1 text-base font-semibold text-gray-800 dark:text-white/90">
          {t("weeklyTitle")}
        </h3>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
          {t("weeklyDesc", { aktif: tamamlananGun, toplam: haftalik.length })}
        </p>

        {haftalik.length === 0 ? (
          <p className="text-sm text-gray-400">{t("weeklyEmpty")}</p>
        ) : (
          <div className="grid grid-cols-7 gap-1">
            {haftalik.map((d) => {
              const sorular = typeof d.soru_sayisi === "number" ? d.soru_sayisi : 0;
              const aktif = sorular > 0;
              const gunAdi = new Date(d.gun).toLocaleDateString("tr-TR", { weekday: "short" });
              return (
                <div key={d.gun} className="flex flex-col items-center gap-1">
                  <div
                    title={`${d.gun}: ${sorular} soru`}
                    className={[
                      "h-9 w-9 rounded-lg text-xs font-bold flex items-center justify-center",
                      aktif
                        ? "bg-brand-500 text-white"
                        : "bg-gray-100 text-gray-300 dark:bg-gray-700 dark:text-gray-500",
                    ].join(" ")}
                  >
                    {aktif ? sorular : "—"}
                  </div>
                  <span className="text-xs text-gray-500 dark:text-gray-400">{gunAdi}</span>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
