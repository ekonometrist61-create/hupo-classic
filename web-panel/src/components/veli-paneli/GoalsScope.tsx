"use client";

import ChildScope from "./ChildScope";
import GoalsView from "./GoalsView";
import type { Student } from "./types";

// Hedefler sayfası: render fonksiyonu sunucu sayfasından geçirilemez (Next.js), bu yüzden istemci tarafında kurulur.
export default function GoalsScope({ students }: { students: Student[] }) {
  return (
    <ChildScope
      students={students}
      render={(studentId, data) => (
        <GoalsView studentId={studentId} haftalik={data.haftalik} />
      )}
    />
  );
}
