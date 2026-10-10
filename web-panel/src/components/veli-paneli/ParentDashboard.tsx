"use client";

import { useTranslations } from "next-intl";

import ChildScope from "./ChildScope";
import DenemeKaydiKarti from "./DenemeKaydiKarti";
import ReviewTopicsList from "./ReviewTopicsList";
import StatsCards from "./StatsCards";
import SubjectSuccessChart from "./SubjectSuccessChart";
import type { Student } from "./types";
import WeeklyStudyChart from "./WeeklyStudyChart";

interface ParentDashboardProps {
  students: Student[];
}

// Genel Bakış: seçili çocuğun özet istatistikleri ve grafikleri.
export default function ParentDashboard({ students }: ParentDashboardProps) {
  const t = useTranslations("veliPaneli");

  return (
    <ChildScope
      students={students}
      render={(studentId, data) => {
        const ogrenci = students.find((s) => s.id === studentId) ?? null;
        return (
          <>
            <DenemeKaydiKarti
              cocukId={studentId}
              cocukAd={ogrenci?.full_name ?? ogrenci?.username ?? null}
            />
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
        );
      }}
    />
  );
}
