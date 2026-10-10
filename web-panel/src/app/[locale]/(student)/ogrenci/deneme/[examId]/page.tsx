import DenemeEkrani from "@/components/ogrenci/DenemeEkrani";
import { createClient } from "@/utils/supabase/server";
import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { setRequestLocale } from "next-intl/server";

export async function generateMetadata(): Promise<Metadata> {
  return { title: "Deneme Sınavı — Hupo" };
}

export default async function DenemeEkraniPage({
  params,
}: {
  params: Promise<{ locale: string; examId: string }>;
}) {
  const { locale, examId } = await params;
  setRequestLocale(locale);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/signin");

  const { data: profil } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  // Yalnızca öğrenci rolüne izin ver
  if (!profil || profil.role !== "ogrenci") redirect("/ogrenci");

  return <DenemeEkrani examId={examId} />;
}
