"use client";

import ActivityView from "./ActivityView";
import ChildScope from "./ChildScope";
import type { Student } from "./types";

// Aktivite sayfası: render fonksiyonu sunucu sayfasından geçirilemez (Next.js), bu yüzden istemci tarafında kurulur.
export default function ActivityScope({ students }: { students: Student[] }) {
  return (
    <ChildScope
      students={students}
      render={(_studentId, data) => <ActivityView haftalik={data.haftalik} />}
    />
  );
}
