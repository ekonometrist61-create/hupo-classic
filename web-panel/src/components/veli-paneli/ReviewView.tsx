"use client";

import { useTranslations } from "next-intl";

import ChildScope from "./ChildScope";
import ReviewTopicsList from "./ReviewTopicsList";
import type { Student } from "./types";

interface ReviewViewProps {
  students: Student[];
}

// Yanlışlar & Tekrar: çocuğun tekrar gereken konuları ve özet sayıları.
export default function ReviewView({ students }: ReviewViewProps) {
  return (
    <ChildScope
      students={students}
      render={(_, data) => {
        const topics = data.tekrar_konulari;
        const totalWrong = topics.reduce((sum, x) => sum + x.yanlis, 0);
        const totalDue = topics.reduce((sum, x) => sum + x.bekleyen, 0);
        return (
          <ReviewContent
            topicCount={topics.length}
            totalWrong={totalWrong}
            totalDue={totalDue}
            topics={topics}
          />
        );
      }}
    />
  );
}

function ReviewContent({
  topicCount,
  totalWrong,
  totalDue,
  topics,
}: {
  topicCount: number;
  totalWrong: number;
  totalDue: number;
  topics: Parameters<typeof ReviewTopicsList>[0]["topics"];
}) {
  const t = useTranslations("veliPaneli");
  const tr = useTranslations("veliPaneli.reviewPage");

  const stats = [
    { label: tr("topicCount"), value: String(topicCount) },
    { label: tr("totalWrong"), value: String(totalWrong) },
    { label: tr("totalDue"), value: String(totalDue) },
  ];

  return (
    <div className="space-y-4 md:space-y-6">
      <p className="text-theme-sm text-gray-500 dark:text-gray-400">
        {tr("desc")}
      </p>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3 md:gap-6">
        {stats.map((s) => (
          <div
            key={s.label}
            className="rounded-2xl border border-gray-200 bg-white p-5 md:p-6 dark:border-gray-800 dark:bg-white/3"
          >
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {s.label}
            </span>
            <h4 className="mt-2 text-title-sm font-bold text-gray-800 dark:text-white/90">
              {s.value}
            </h4>
          </div>
        ))}
      </div>

      <ReviewTopicsList
        topics={topics}
        labels={{
          title: t("review.title"),
          desc: tr("listDesc"),
          empty: tr("empty"),
          topic: t("review.topic"),
          subject: t("review.subject"),
          wrong: t("review.wrong"),
          due: t("review.due"),
          success: t("review.success"),
        }}
      />

      <p className="text-theme-xs text-gray-500 dark:text-gray-400">
        {tr("limitNote")}
      </p>
    </div>
  );
}
