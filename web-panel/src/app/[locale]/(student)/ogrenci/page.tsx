import { createClient } from "@/utils/supabase/server";
import { Link } from "@/i18n/navigation";
import { redirect } from "next/navigation";
import { setRequestLocale } from "next-intl/server";

export const metadata = { title: "Ana Sayfa — Hupo" };

const DERS_RENK: Record<string, string> = {
  Matematik: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
  Türkçe: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300",
  "Fen Bilimleri": "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
  "Sosyal Bilgiler": "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300",
  "İnkılap Tarihi": "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
  İngilizce: "bg-teal-100 text-teal-700 dark:bg-teal-900/30 dark:text-teal-300",
  "Din Kültürü": "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
};

const DERS_HARF: Record<string, string> = {
  Matematik: "M",
  Türkçe: "T",
  "Fen Bilimleri": "F",
  "Sosyal Bilgiler": "S",
  "İnkılap Tarihi": "İ",
  İngilizce: "E",
  "Din Kültürü": "D",
};

export default async function OgrenciAnaSayfa({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/signin");

  const { data: profil } = await supabase
    .from("profiles")
    .select("full_name, sinif, role")
    .eq("id", user.id)
    .maybeSingle();

  if (!profil || profil.role !== "ogrenci") redirect("/signin");

  const { data: istatistik } = await supabase
    .from("student_stats")
    .select("xp, level, streak_count")
    .eq("student_id", user.id)
    .maybeSingle();

  /* Kullanılabilir dersler — onaylı sorulardan */
  const { data: soruRows } = await supabase
    .from("questions")
    .select("ders")
    .eq("onay_durumu", "onaylandi");

  const dersler = [...new Set((soruRows ?? []).map((r) => r.ders as string))].sort();

  const ad = profil.full_name ? profil.full_name.split(" ")[0] : "Öğrenci";
  const xp = istatistik?.xp ?? 0;
  const level = istatistik?.level ?? 1;
  const streak = istatistik?.streak_count ?? 0;
  return (
    <div className="space-y-8">
      {/* Karşılama + istatistik */}
      <div className="rounded-2xl border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900">
        <h1 className="mb-1 text-2xl font-bold text-gray-900 dark:text-white">
          Merhaba, {ad}!
        </h1>
        <p className="mb-5 text-sm text-gray-500 dark:text-gray-400">
          {profil.sinif ? `${profil.sinif}. sınıf` : "Sınıf belirtilmemiş"} &middot; Bugün ne öğreneceksin?
        </p>

        <div className="grid grid-cols-3 gap-4">
          <div className="rounded-xl bg-yellow-50 p-4 text-center dark:bg-yellow-900/20">
            <p className="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{xp}</p>
            <p className="mt-0.5 text-xs text-yellow-700 dark:text-yellow-500">XP</p>
          </div>
          <div className="rounded-xl bg-brand-50 p-4 text-center dark:bg-brand-900/20">
            <p className="text-2xl font-bold text-brand-600 dark:text-brand-400">{level}</p>
            <p className="mt-0.5 text-xs text-brand-700 dark:text-brand-500">Seviye</p>
          </div>
          <div className="rounded-xl bg-orange-50 p-4 text-center dark:bg-orange-900/20">
            <p className="text-2xl font-bold text-orange-600 dark:text-orange-400">{streak}</p>
            <p className="mt-0.5 text-xs text-orange-700 dark:text-orange-500">Günlük Seri</p>
          </div>
        </div>

        {/* Seviye ilerleme çubuğu */}
        <div className="mt-4">
          <div className="mb-1 flex justify-between text-xs text-gray-500 dark:text-gray-400">
            <span>Seviye {level}</span>
            <span>{xp % 100} / 100 XP</span>
          </div>
          <div className="h-2.5 w-full overflow-hidden rounded-full bg-gray-200 dark:bg-gray-700">
            <div
              className="h-full rounded-full bg-brand-500 transition-all duration-500"
              style={{ width: `${Math.min(100, (xp % 100))}%` }}
            />
          </div>
        </div>
      </div>

      {/* Dersler */}
      <div>
        <h2 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white">
          Dersler
        </h2>
        {dersler.length === 0 ? (
          <p className="rounded-xl border border-gray-200 bg-white p-8 text-center text-sm text-gray-500 dark:border-gray-800 dark:bg-gray-900">
            Henüz soru eklenmemiş.
          </p>
        ) : (
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3">
            {dersler.map((ders) => {
              const renk = DERS_RENK[ders] ?? "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300";
              const harf = DERS_HARF[ders] ?? ders[0].toUpperCase();
              return (
                <Link
                  key={ders}
                  href={`/ogrenci/soru?ders=${encodeURIComponent(ders)}`}
                  className="group flex flex-col items-center gap-3 rounded-2xl border border-gray-200 bg-white p-6 text-center shadow-sm transition-all hover:border-brand-300 hover:shadow-md dark:border-gray-800 dark:bg-gray-900 dark:hover:border-brand-700"
                >
                  <div
                    className={`flex h-14 w-14 items-center justify-center rounded-2xl text-2xl font-bold ${renk}`}
                  >
                    {harf}
                  </div>
                  <span className="text-sm font-semibold text-gray-800 group-hover:text-brand-600 dark:text-white dark:group-hover:text-brand-400">
                    {ders}
                  </span>
                  <span className="rounded-full bg-brand-50 px-3 py-0.5 text-xs font-medium text-brand-600 dark:bg-brand-900/30 dark:text-brand-400">
                    Soru Çöz
                  </span>
                </Link>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
