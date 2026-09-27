import type { DailyStudy, StudentSummary } from "./types";

interface StatCardProps {
  label: string;
  value: string;
  hint?: string;
}

function StatCard({ label, value, hint }: StatCardProps) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 md:p-6 dark:border-gray-800 dark:bg-white/3">
      <span className="text-sm text-gray-500 dark:text-gray-400">{label}</span>
      <div className="mt-2 flex items-end gap-2">
        <h4 className="text-title-sm font-bold text-gray-800 dark:text-white/90">
          {value}
        </h4>
        {hint && (
          <span className="pb-1 text-theme-sm text-gray-500 dark:text-gray-400">
            {hint}
          </span>
        )}
      </div>
    </div>
  );
}

interface StatsCardsProps {
  summary: StudentSummary | null;
  weekly: DailyStudy[];
  labels: {
    xp: string;
    level: string;
    streak: string;
    streakUnit: string;
    weeklyTime: string;
    minutes: string;
    questions: string;
  };
}

export default function StatsCards({ summary, weekly, labels }: StatsCardsProps) {
  const totalMinutes = Math.round(
    weekly.reduce((sum, day) => sum + Number(day.sure_dk), 0)
  );
  const totalQuestions = weekly.reduce((sum, day) => sum + day.soru_sayisi, 0);

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:gap-6 xl:grid-cols-4">
      <StatCard
        label={labels.xp}
        value={String(summary?.xp ?? 0)}
        hint={`${labels.level} ${summary?.level ?? 1}`}
      />
      <StatCard
        label={labels.streak}
        value={String(summary?.streak_count ?? 0)}
        hint={labels.streakUnit}
      />
      <StatCard
        label={labels.weeklyTime}
        value={String(totalMinutes)}
        hint={labels.minutes}
      />
      <StatCard label={labels.questions} value={String(totalQuestions)} />
    </div>
  );
}
