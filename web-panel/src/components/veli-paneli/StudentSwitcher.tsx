"use client";

import { useTranslations } from "next-intl";

import type { Student } from "./types";

interface StudentSwitcherProps {
  students: Student[];
  selectedId: string;
  onChange: (id: string) => void;
}

const studentName = (s: Student) =>
  s.full_name || s.username || s.id.slice(0, 8);

// Birden çok çocuk varsa seçici, tek çocukta yalnızca ad gösterilir.
export default function StudentSwitcher({
  students,
  selectedId,
  onChange,
}: StudentSwitcherProps) {
  const t = useTranslations("veliPaneli");

  if (students.length <= 1) {
    return (
      <p className="text-sm text-gray-500 dark:text-gray-400">
        {t("childLabel")}:{" "}
        <span className="font-medium text-gray-800 dark:text-white/90">
          {students[0] ? studentName(students[0]) : "—"}
        </span>
      </p>
    );
  }

  return (
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
        onChange={(e) => onChange(e.target.value)}
        className="h-11 rounded-lg border border-gray-300 bg-transparent px-4 text-sm text-gray-800 shadow-theme-xs focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90"
      >
        {students.map((s) => (
          <option key={s.id} value={s.id}>
            {studentName(s)}
          </option>
        ))}
      </select>
    </div>
  );
}
