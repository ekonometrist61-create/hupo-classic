import SoruEkrani from "@/components/ogrenci/SoruEkrani";
import { createClient } from "@/utils/supabase/server";
import { Link } from "@/i18n/navigation";
import { redirect } from "next/navigation";
import { setRequestLocale } from "next-intl/server";

export const metadata = { title: "Soru Çöz — Hupo" };

export default async function SoruSayfasi({
  params,
  searchParams,
}: {
  params: Promise<{ locale: string }>;
  searchParams: Promise<{ ders?: string }>;
}) {
  const [{ locale }, { ders }] = await Promise.all([params, searchParams]);
  setRequestLocale(locale);

  if (!ders) redirect("/ogrenci");

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

  if (!profil || profil.role !== "ogrenci") redirect("/signin");

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <Link
          href="/ogrenci"
          className="text-sm text-gray-500 hover:text-brand-600 dark:text-gray-400 dark:hover:text-brand-400"
        >
          ← Ana Sayfa
        </Link>
        <span className="text-gray-300 dark:text-gray-600">/</span>
        <span className="text-sm font-medium text-gray-800 dark:text-white">{ders}</span>
      </div>

      <SoruEkrani ders={ders} />
    </div>
  );
}
