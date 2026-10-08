"use client";

import Badge from "@/components/ui/badge/Badge";
import { useTranslations } from "next-intl";
import { useState } from "react";

import ChildScope from "./ChildScope";
import ReviewTopicsList from "./ReviewTopicsList";
import type { ReviewTopic, Student, SubjectSuccess } from "./types";

// Basari oranı bu sayıdan az soruda güvenilir değil (SubjectSuccessChart ile aynı eşik).
const MIN_EVIDENCE = 6;

interface SubjectsViewProps {
  students: Student[];
}

// Dersler & Konular: ders seçilir, o dersin başarısı ve tekrar konuları listelenir.
export default function SubjectsView({ students }: SubjectsViewProps) {
  return (
    <ChildScope
      students={students}
      render={(_, data) => (
        <SubjectsContent
          subjects={data.ders_basari}
          topics={data.tekrar_konulari}
        />
      )}
    />
  );
}

function SubjectsContent({
  subjects,
  topics,
}: {
  subjects: SubjectSuccess[];
  topics: ReviewTopic[];
}) {
  const t = useTranslations("veliPaneli");
  const tp = useTranslations("veliPaneli.subjectsPage");

  const ordered = [...subjects].sort((a, b) => a.ders.localeCompare(b.ders, "tr"));
  const [picked, setPicked] = useState<string | null>(null);

  if (ordered.length === 0) {
    return (
      <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
        {tp("empty")}
      </p>
    );
  }

  // Seçim yoksa ya da seçilen ders artık listede değilse ilk ders gösterilir.
  const selected =
    ordered.find((s) => s.ders === picked) ?? ordered[0];
  const selectedTopics = topics.filter((x) => x.ders === selected.ders);
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
                className={`rounded-full border px-4 py-1.5 text-sm font-medium transition-colors ${
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
          <Badge size="sm" color={successBadgeColor(selected.oran)}>
            {`%${selected.oran}`}
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

      <ReviewTopicsList
        topics={selectedTopics}
        labels={{
          title: tp("topicsTitle"),
          desc: tp("topicsDesc", { ders: selected.ders }),
          empty: tp("topicsEmpty"),
          topic: t("review.topic"),
          subject: t("review.subject"),
          wrong: t("review.wrong"),
          due: t("review.due"),
          success: t("review.success"),
        }}
      />

      <p className="text-theme-xs text-gray-500 dark:text-gray-400">
        {tp("topicsNote")}
      </p>
    </div>
  );
}

function successBadgeColor(percent: number) {
  if (percent >= 70) return "success" as const;
  if (percent >= 40) return "warning" as const;
  return "error" as const;
}
