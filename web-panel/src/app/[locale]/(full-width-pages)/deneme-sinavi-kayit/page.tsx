import DenemeKayitForm from "@/components/landing/DenemeKayitForm";
import { createClient } from "@/utils/supabase/server";
import type { Metadata } from "next";
import { getTranslations } from "next-intl/server";
import Link from "next/link";

export async function generateMetadata(): Promise<Metadata> {
  return {
    title: "Deneme Sınavına Kaydol | Hupolingo",
    description:
      "Türkiye geneli Hupolingo deneme sınavına kaydolun. Ücretsiz, giriş gerektirmez.",
  };
}

interface ExamInfo {
  id: string;
  ad: string;
  baslangic_zamani: string;
  siniflar: number[];
}

async function fetchOpenExam(): Promise<ExamInfo | null> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("get_open_exam_for_registration");
    if (error || !data) return null;
    return data as ExamInfo;
  } catch {
    return null;
  }
}

export default async function DenemeKayitPage() {
  const t = await getTranslations("landing.denemeKayit");
  const exam = await fetchOpenExam();

  return (
    <div className="min-h-dvh bg-cream py-12 text-navy">
      <div className="mx-auto max-w-xl px-4 sm:px-6">
        <Link href="/#deneme-sinavi" className="mb-6 inline-flex items-center gap-1 text-sm font-semibold text-brand-600 hover:underline">
          ← Ana sayfaya dön
        </Link>
        <h1 className="text-3xl font-extrabold tracking-tight">{t("title")}</h1>
        <p className="mt-2 text-base leading-relaxed text-gray-600">{t("desc")}</p>

        <div className="mt-8">
          {exam ? (
            <DenemeKayitForm
              examId={exam.id}
              examAd={exam.ad}
              siniflar={exam.siniflar}
            />
          ) : (
            <div className="rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm">
              <p className="text-lg font-extrabold text-navy">{t("noExam")}</p>
              <p className="mt-2 text-sm text-gray-500">{t("noExamDesc")}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
