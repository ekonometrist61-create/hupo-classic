"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import ConsentCard from "./ConsentCard";
import StudentSwitcher from "./StudentSwitcher";
import type { DashboardData, Student } from "./types";
import VeliMessage from "./VeliMessage";

interface ChildScopeProps {
  students: Student[];
  /** Seçili çocuk ve verisi onaylıysa çağrılır; değilse onay yönlendirmesi gösterilir. */
  render: (studentId: string, data: DashboardData) => React.ReactNode;
}

interface LoadedResult {
  studentId: string;
  data: DashboardData | null; // null = hata
}

// Veli sayfalarının ortak kabuğu: çocuk seçimi, dashboard verisi ve veli onayı kapısı.
// Öğrenci verisi yalnızca riza = "verildi" iken gösterilir (AGENTS.md §5.3).
export default function ChildScope({ students, render }: ChildScopeProps) {
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

  if (students.length === 0) {
    return (
      <VeliMessage
        title={t("noChildren.title")}
        text={t("noChildren.text")}
      />
    );
  }

  const isLoading = !result || result.studentId !== selectedId;
  const data = isLoading ? null : result.data;
  const consentGiven = data?.riza === "verildi";

  return (
    <div className="space-y-4 md:space-y-6">
      <StudentSwitcher
        students={students}
        selectedId={selectedId}
        onChange={setSelectedId}
      />

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

      {data && !consentGiven && (
        <p className="rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 text-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-warning-400">
          {t("consent.gate")}
        </p>
      )}

      {data && consentGiven && render(selectedId, data)}

      {selectedId && <ConsentCard studentId={selectedId} />}
    </div>
  );
}
