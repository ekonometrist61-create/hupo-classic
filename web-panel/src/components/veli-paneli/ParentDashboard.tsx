"use client";

import { useTranslations } from "next-intl";

import BuHaftaOzeti from "./BuHaftaOzeti";
import ChildScope from "./ChildScope";
import CocukDenemeGecmisi from "./CocukDenemeGecmisi";
import DenemeKaydiKarti from "./DenemeKaydiKarti";
import GenelDurumOzeti from "./GenelDurumOzeti";
import KelimeGelisimKarti from "./KelimeGelisimKarti";
import ReviewTopicsList from "./ReviewTopicsList";
import SonrakiAdimKarti from "./SonrakiAdimKarti";
import SubjectSuccessChart from "./SubjectSuccessChart";
import type { DashboardData, Student } from "./types";
import WeeklyStudyChart from "./WeeklyStudyChart";

interface ParentDashboardProps {
  students: Student[];
  /** Sunucuda okunmuş ilk çocuk panosu; varsa istemci ilk seçimde aynı veriyi ikinci kez istemez. */
  ilkVeri?: { studentId: string; data: DashboardData };
}

// Genel Bakış (K4 sırası): 1) "Bu hafta" özeti, 2) grafikler, 3) tekrar önerileri,
// 4) deneme kaydı, deneme geçmişi ve kelime kartı. XP ve seviye Başarılar sayfasındadır.
export default function ParentDashboard({ students, ilkVeri }: ParentDashboardProps) {
  const t = useTranslations("veliPaneli");

  // Sonraki adım kartı (W10) en üstte; tüm adımlar tamamsa kendi kendine gizlenir.
  return (
    <div className="space-y-4 md:space-y-6">
      <SonrakiAdimKarti />
    <ChildScope
      students={students}
      ilkVeri={ilkVeri}
      render={(studentId, data) => {
        const ogrenci = students.find((s) => s.id === studentId) ?? null;
        const cocukAd = ogrenci?.full_name ?? ogrenci?.username ?? null;
        return (
          <div className="space-y-4 md:space-y-6">
            <GenelDurumOzeti
              haftalik={data.haftalik}
              tekrarKonulari={data.tekrar_konulari}
            />

            <BuHaftaOzeti
              haftalik={data.haftalik}
              tekrarKonulari={data.tekrar_konulari}
            />

            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-6">
              <SubjectSuccessChart data={data.ders_basari} />
              <WeeklyStudyChart data={data.haftalik} />
            </div>

            <ReviewTopicsList
              topics={data.tekrar_konulari}
              labels={{
                title: t("review.title"),
                desc: t("review.desc"),
                kaynak: t("review.kaynak"),
                azVeri: t("review.azVeri"),
                empty: t("review.empty"),
                topic: t("review.topic"),
                subject: t("review.subject"),
                wrong: t("review.wrong"),
                due: t("review.due"),
                success: t("review.success"),
              }}
            />

            <DenemeKaydiKarti cocukId={studentId} cocukAd={cocukAd} />
            <CocukDenemeGecmisi cocukId={studentId} cocukAd={cocukAd} />
            <KelimeGelisimKarti key={studentId} cocukId={studentId} cocukAd={cocukAd} />
          </div>
        );
      }}
    />
    </div>
  );
}
