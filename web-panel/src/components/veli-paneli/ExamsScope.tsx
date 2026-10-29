"use client";

import ChildScope from "./ChildScope";
import DenemelerView from "./DenemelerView";
import type { Student } from "./types";

// Denemeler sayfası: render fonksiyonu sunucu sayfasından geçirilemez (Next.js), bu yüzden istemci tarafında kurulur.
export default function ExamsScope({ students }: { students: Student[] }) {
  return (
    <ChildScope
      students={students}
      render={(studentId) => {
        const ogrenci = students.find((s) => s.id === studentId) ?? null;
        return (
          <DenemelerView
            cocukId={studentId}
            cocukAd={ogrenci?.full_name ?? ogrenci?.username ?? null}
          />
        );
      }}
    />
  );
}
