"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import AbonelikKarti from "./AbonelikKarti";
import ConsentCard from "./ConsentCard";
import OdemeGecmisi from "./OdemeGecmisi";
import ReviewTopicsList from "./ReviewTopicsList";
import StatsCards from "./StatsCards";
import SubjectSuccessChart from "./SubjectSuccessChart";
import type { DashboardData, Student } from "./types";
import WeeklyStudyChart from "./WeeklyStudyChart";

interface ParentDashboardProps {
  students: Student[];
}

interface LoadedResult {
  studentId: string;
  data: DashboardData | null; // null = hata
}

const studentName = (s: Student) =>
  s.full_name || s.username || s.id.slice(0, 8);

export default function ParentDashboard({ students }: ParentDashboardProps) {
  const t = useTranslations("veliPaneli");
  const [selectedId, setSelectedId] = useState(students[0]?.id ?? "");
  const [result, setResult] = useState<LoadedResult | null>(null);

  useEffect(() => {
    if (!selectedId) return;
    let cancelled = false;

    createClient()
      .rpc("get_student_dashboard", { p_student_id: selectedId, p_gun: 7 })
      .then(({ data, error }) => {
        if (cancelled) return;
        setResult({
          studentId: selectedId,
          data: error ? null : (data as DashboardData),
        });
      });

    return () => {
      cancelled = true;
    };
  }, [selectedId]);

  const isLoading = !result || result.studentId !== selectedId;
  const data = isLoading ? null : result.data;

  return (
    <div className="space-y-4 md:space-y-6">
      {students.length > 1 ? (
        <div className="flex items-center gap-3">
          <label
            htmlFor="student-select"
            className="text-sm font-medium text-gray-700 dark:text-gray-400"
          >
            {t("childLabel")}
          </label>
          <select
            id="student-select"
            value={selectedId}
            onChange={(e) => setSelectedId(e.target.value)}
            className="h-11 rounded-lg border border-gray-300 bg-transparent px-4 text-sm text-gray-800 shadow-theme-xs focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90"
          >
            {students.map((s) => (
              <option key={s.id} value={s.id}>
                {studentName(s)}
              </option>
            ))}
          </select>
        </div>
      ) : (
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {t("childLabel")}:{" "}
          <span className="font-medium text-gray-800 dark:text-white/90">
            {studentName(students[0])}
          </span>
        </p>
      )}

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-6">
        <AbonelikKarti />
        <OdemeGecmisi />
      </div>

      {selectedId && <ConsentCard studentId={selectedId} />}

      {isLoading && (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("loading")}
        </p>
      )}

      {!isLoading && !data && (
        <p role="alert" className="py-10 text-center text-sm text-error-500">
          {t("error")}
        </p>
      )}

      {data && (
        <>
          <StatsCards
            summary={data.ozet}
            weekly={data.haftalik}
            labels={{
              xp: t("stats.xp"),
              level: t("stats.level"),
              streak: t("stats.streak"),
              streakUnit: t("stats.streakUnit"),
              weeklyTime: t("stats.weeklyTime"),
              minutes: t("stats.minutes"),
              questions: t("stats.questions"),
            }}
          />
          <div className="grid grid-cols-12 gap-4 md:gap-6">
            <div className="col-span-12 xl:col-span-6">
              <SubjectSuccessChart data={data.ders_basari} />
            </div>
            <div className="col-span-12 xl:col-span-6">
              <WeeklyStudyChart data={data.haftalik} />
            </div>
            <div className="col-span-12">
              <ReviewTopicsList
                topics={data.tekrar_konulari}
                labels={{
                  title: t("review.title"),
                  desc: t("review.desc"),
                  empty: t("review.empty"),
                  topic: t("review.topic"),
                  subject: t("review.subject"),
                  wrong: t("review.wrong"),
                  due: t("review.due"),
                  success: t("review.success"),
                }}
              />
            </div>
          </div>
        </>
      )}
    </div>
  );
}
