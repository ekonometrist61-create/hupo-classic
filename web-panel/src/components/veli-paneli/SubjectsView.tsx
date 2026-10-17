"use client";

import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import ChildScope from "./ChildScope";
import ReviewTopicsList from "./ReviewTopicsList";
import type { ReviewTopic, Student, SubjectSuccess, TopicProgress } from "./types";

// Başarı oranı bu sayıdan az soruda güvenilir değil (SubjectSuccessChart ile aynı eşik).
const MIN_EVIDENCE = 6;

interface SubjectsViewProps {
  students: Student[];
}

export default function SubjectsView({ students }: SubjectsViewProps) {
  return (
    <ChildScope
      students={students}
      render={(studentId, data) => (
        <SubjectsContent
          studentId={studentId}
          subjects={data.ders_basari}
          reviewTopics={data.tekrar_konulari}
        />
      )}
    />
  );
}

function SubjectsContent({
  studentId,
  subjects,
  reviewTopics,
}: {
  studentId: string;
  subjects: SubjectSuccess[];
  reviewTopics: ReviewTopic[];
}) {
  const t = useTranslations("veliPaneli");
  const tp = useTranslations("veliPaneli.subjectsPage");

  const ordered = [...subjects].sort((a, b) => a.ders.localeCompare(b.ders, "tr"));
  const [picked, setPicked] = useState<string | null>(null);
  const [topicData, setTopicData] = useState<TopicProgress[] | null>(null);
  const [topicLoading, setTopicLoading] = useState(false);
  const [topicError, setTopicError] = useState<string | null>(null);

  const selected = ordered.find((s) => s.ders === picked) ?? ordered[0];

  const selectedDers = selected?.ders ?? null;

  useEffect(() => {
    if (!selectedDers) return;
    let cancelled = false;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setTopicLoading(true);
    setTopicData(null);
    setTopicError(null);

    createClient()
      .rpc("get_child_topic_progress", {
        p_student_id: studentId,
        p_ders: selectedDers,
      })
      .then(({ data, error }) => {
        if (cancelled) return;
        if (error) {
          setTopicError(error.message);
        } else {
          setTopicData((data as TopicProgress[]) ?? []);
        }
        setTopicLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [studentId, selectedDers]);

  if (ordered.length === 0) {
    return (
      <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
        {tp("empty")}
      </p>
    );
  }

  const enough = selected.toplam >= MIN_EVIDENCE;

  return (
    <div className="space-y-4 md:space-y-6">
      <div>
        <p className="mb-2 text-sm font-medium text-gray-700 dark:text-gray-400">
          {tp("pick")}
        </p>
        <div className="flex flex-wrap gap-2">
          {ordered.map((s) => {
            const active = s.ders === selected.ders;
            return (
              <button
                key={s.ders}
                type="button"
                aria-pressed={active}
                onClick={() => setPicked(s.ders)}
                className={`inline-flex min-h-11 items-center rounded-full border px-4 py-1.5 text-sm font-medium transition-colors ${
                  active
                    ? "border-brand-500 bg-brand-50 text-brand-600 dark:border-brand-400 dark:bg-brand-500/15 dark:text-brand-400"
                    : "border-gray-200 text-gray-600 hover:bg-gray-50 dark:border-gray-800 dark:text-gray-300 dark:hover:bg-white/5"
                }`}
              >
                {s.ders}
              </button>
            );
          })}
        </div>
      </div>

      <div className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
        <div className="flex flex-wrap items-center gap-3">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
            {selected.ders}
          </h3>
          <Badge
            size="sm"
            color={enough ? successBadgeColor(selected.oran) : "light"}
          >
            {enough ? `%${selected.oran}` : t("review.azVeri")}
          </Badge>
        </div>
        <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
          {t("subjects.tooltip", {
            dogru: selected.dogru,
            toplam: selected.toplam,
          })}
        </p>
        {!enough && (
          <p className="mt-3 text-theme-xs italic text-gray-500 dark:text-gray-400">
            {t("subjects.insufficient")}
          </p>
        )}
      </div>

      {topicLoading && (
        <p className="py-4 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("loading")}
        </p>
      )}

      {topicError && (
        <p role="alert" className="py-4 text-center text-sm text-error-500">
          {t("error")}
        </p>
      )}

      {!topicLoading && !topicError && topicData !== null && topicData.length > 0 && (
        <TopicProgressList topics={topicData} />
      )}

      {!topicLoading && !topicError && topicData !== null && topicData.length === 0 && (
        <ReviewTopicsList
          topics={reviewTopics.filter((x) => x.ders === selected.ders)}
          labels={{
            title: tp("topicsTitle"),
            desc: tp("topicsDesc", { ders: selected.ders }),
            kaynak: tp("topicsKaynak"),
            azVeri: t("review.azVeri"),
            empty: tp("topicsEmpty"),
            topic: t("review.topic"),
            subject: t("review.subject"),
            wrong: t("review.wrong"),
            due: t("review.due"),
            success: t("review.success"),
          }}
        />
      )}
    </div>
  );
}

function TopicProgressList({ topics }: { topics: TopicProgress[] }) {
  const tp = useTranslations("veliPaneli.subjectsPage");
  const t = useTranslations("veliPaneli");

  return (
    <div>
      <h4 className="mb-3 text-sm font-semibold text-gray-700 dark:text-gray-300">
        {tp("topicsTitle")}
      </h4>
      <p className="mb-3 text-theme-xs text-gray-500 dark:text-gray-400">
        {tp("topicsKaynak")}
      </p>
      <ul className="space-y-2">
        {topics.map((topic) => {
          const needsReview = topic.yanlis > 0 || topic.bekleyen > 0;
          // Oran yoksa ya da en az 6 soru yoksa yüzde gösterilmez; "az veri" yazılır.
          const yeterli = topic.oran !== null && topic.toplam >= MIN_EVIDENCE;
          const pct = topic.oran ?? 0;
          return (
            <li
              key={topic.konu}
              className="rounded-xl border border-gray-100 bg-white p-4 dark:border-gray-800 dark:bg-white/3"
            >
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div className="flex items-center gap-2 min-w-0">
                  <span className="truncate text-sm font-medium text-gray-800 dark:text-white/90">
                    {topic.konu}
                  </span>
                  {needsReview && (
                    <span className="shrink-0 rounded-full bg-warning-50 px-2 py-0.5 text-theme-xs font-medium text-warning-600 dark:bg-warning-500/15 dark:text-warning-400">
                      {t("review.due")}
                    </span>
                  )}
                </div>
                <span className="shrink-0 text-sm font-semibold text-gray-700 dark:text-gray-300">
                  {yeterli ? `%${pct}` : t("review.azVeri")}
                </span>
              </div>
              <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-white/5">
                <div
                  className={`h-full rounded-full transition-all ${progressColor(pct)}`}
                  style={{ width: yeterli ? `${pct}%` : "0%" }}
                  aria-hidden
                />
              </div>
              <p className="mt-1.5 text-theme-xs text-gray-500 dark:text-gray-400">
                {t("subjects.tooltip", { dogru: topic.dogru, toplam: topic.toplam })}
              </p>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

function successBadgeColor(percent: number) {
  if (percent >= 70) return "success" as const;
  if (percent >= 40) return "warning" as const;
  return "error" as const;
}

function progressColor(pct: number) {
  if (pct >= 70) return "bg-success-500";
  if (pct >= 40) return "bg-warning-500";
  return "bg-error-500";
}
