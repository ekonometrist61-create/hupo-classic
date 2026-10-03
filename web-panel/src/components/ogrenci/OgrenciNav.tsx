"use client";

import { Link } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/client";
import { useRouter } from "@/i18n/navigation";
import { useEffect, useState } from "react";

interface OgrenciProfil {
  ad: string | null;
  xp: number;
  level: number;
  streak_count: number;
}

export default function OgrenciNav() {
  const router = useRouter();
  const [profil, setProfil] = useState<OgrenciProfil | null>(null);

  useEffect(() => {
    const yukle = async () => {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const [{ data: p }, { data: s }] = await Promise.all([
        supabase.from("profiles").select("full_name").eq("id", user.id).maybeSingle(),
        supabase.from("student_stats").select("xp, level, streak_count").eq("student_id", user.id).maybeSingle(),
      ]);

      setProfil({
        ad: p?.full_name ?? null,
        xp: s?.xp ?? 0,
        level: s?.level ?? 1,
        streak_count: s?.streak_count ?? 0,
      });
    };
    void yukle();
  }, []);

  const cikisYap = async () => {
    await createClient().auth.signOut();
    router.replace("/signin");
  };

  return (
    <header className="sticky top-0 z-40 border-b border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3 sm:px-6">
        <Link href="/ogrenci" className="flex items-center gap-2">
          <span className="text-xl font-bold text-brand-600 dark:text-brand-400">Hupo</span>
        </Link>

        {profil && (
          <div className="flex items-center gap-4 text-sm">
            <span className="hidden items-center gap-1 font-medium text-orange-500 sm:flex">
              {/* seri */}
              <svg className="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
                <path d="M13.5 2C10 6 12 11 9 14c-.5-2-2-3.5-2-3.5C5 14 3 17 3 20a9 9 0 0018 0C21 12 15 7 13.5 2z" />
              </svg>
              {profil.streak_count}
            </span>
            <span className="hidden items-center gap-1 font-medium text-yellow-500 sm:flex">
              {/* xp */}
              <svg className="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
                <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26" />
              </svg>
              {profil.xp} XP
            </span>
            <span className="rounded-full bg-brand-100 px-2.5 py-0.5 text-xs font-semibold text-brand-700 dark:bg-brand-900/40 dark:text-brand-300">
              Sv. {profil.level}
            </span>
            <button
              type="button"
              onClick={cikisYap}
              className="rounded-lg border border-gray-200 px-3 py-1.5 text-xs font-medium text-gray-600 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              Çıkış
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
