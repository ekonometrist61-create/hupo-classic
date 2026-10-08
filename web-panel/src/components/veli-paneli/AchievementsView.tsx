"use client";

import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import ChartCard from "./ChartCard";
import ChildScope from "./ChildScope";
import type { Student, StudentSummary } from "./types";

// get_student_badges() satırı: katalog + öğrencinin ilerlemesi.
// ders_basari için ilerleme = başarı yüzdesi, deneme = çözülen soru sayısı.
export interface BadgeItem {
  kod: string;
  ad: string;
  aciklama: string;
  kosul_turu: "soru_sayisi" | "streak" | "seviye" | "xp" | "ders_basari";
  esik: number;
  ders: string | null;
  min_deneme: number;
  kazanildi: boolean;
  kazanma_tarihi: string | null;
  ilerleme: number;
  deneme: number;
}

interface AchievementsViewProps {
  students: Student[];
}

export default function AchievementsView({ students }: AchievementsViewProps) {
  return (
    <ChildScope
      students={students}
      render={(studentId, data) => (
        <AchievementsContent studentId={studentId} summary={data.ozet} />
      )}
    />
  );
}

function AchievementsContent({
  studentId,
  summary,
}: {
  studentId: string;
  summary: StudentSummary | null;
}) {
  const t = useTranslations("veliPaneli");
  const tb = useTranslations("veliPaneli.achievements");
  const [loaded, setLoaded] = useState<{
    studentId: string;
    badges: BadgeItem[] | null;
  } | null>(null);

  useEffect(() => {
    let cancelled = false;
    createClient()
      .rpc("get_student_badges", { p_student_id: studentId })
      .then(({ data, error }) => {
        if (cancelled) return;
        setLoaded({
          studentId,
          badges: error ? null : (data as BadgeItem[]),
        });
      });
    return () => {
      cancelled = true;
    };
  }, [studentId]);

  const current = loaded?.studentId === studentId ? loaded : null;
  const badges = current?.badges ?? null;
  const earnedCount = badges?.filter((b) => b.kazanildi).length ?? 0;

  const stats = [
    { label: t("stats.xp"), value: String(summary?.xp ?? 0) },
    {
      label: t("stats.level"),
      value: String(summary?.level ?? 1),
    },
    {
      label: t("stats.streak"),
      value: `${summary?.streak_count ?? 0} ${t("stats.streakUnit")}`,
    },
  ];

  return (
    <div className="space-y-4 md:space-y-6">
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

      <ChartCard
        title={tb("title")}
        desc={
          badges
            ? tb("earnedCount", { kazanildi: earnedCount, toplam: badges.length })
            : tb("desc")
        }
      >
        {!current && (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
            {t("loading")}
          </p>
        )}

        {current && !badges && (
          <p role="alert" className="py-10 text-center text-sm text-error-500">
            {t("error")}
          </p>
        )}

        {badges && badges.length === 0 && (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
            {tb("empty")}
          </p>
        )}

        {badges && badges.length > 0 && (
          <ul className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
            {badges.map((b) => (
              <BadgeCard key={b.kod} badge={b} />
            ))}
          </ul>
        )}
      </ChartCard>
    </div>
  );
}

function BadgeCard({ badge }: { badge: BadgeItem }) {
  const tb = useTranslations("veliPaneli.achievements");

  const isSubject = badge.kosul_turu === "ders_basari";
  const ratio = isSubject
    ? Math.min(
        badge.ilerleme / badge.esik,
        badge.deneme / badge.min_deneme,
      )
    : badge.ilerleme / badge.esik;
  const percent = badge.kazanildi ? 100 : Math.min(100, Math.round(ratio * 100));

  const progressText = isSubject
    ? tb("progressSubject", {
        ilerleme: badge.ilerleme,
        esik: badge.esik,
        deneme: Math.min(badge.deneme, badge.min_deneme),
        min: badge.min_deneme,
      })
    : tb("progressCount", { ilerleme: badge.ilerleme, esik: badge.esik });

  return (
    <li className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="font-semibold text-gray-800 dark:text-white/90">
            {badge.ad}
          </p>
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
            {badge.aciklama}
          </p>
        </div>
        <Badge size="sm" color={badge.kazanildi ? "success" : "light"}>
          {badge.kazanildi ? tb("earned") : tb("locked")}
        </Badge>
      </div>

      <div
        className="mt-3 h-2 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-white/5"
        role="progressbar"
        aria-valuenow={percent}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={badge.ad}
      >
        <div
          className={`h-full rounded-full ${badge.kazanildi ? "bg-success-500" : "bg-brand-500"}`}
          style={{ width: `${percent}%` }}
        />
      </div>

      <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">
        {badge.kazanildi && badge.kazanma_tarihi
          ? tb("earnedOn", {
              tarih: new Date(badge.kazanma_tarihi).toLocaleDateString("tr-TR", {
                day: "2-digit",
                month: "long",
                year: "numeric",
              }),
            })
          : progressText}
      </p>
    </li>
  );
}
