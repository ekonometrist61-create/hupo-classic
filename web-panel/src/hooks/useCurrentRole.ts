"use client";

import { createClient } from "@/utils/supabase/client";
import { useEffect, useState } from "react";

export type AppRole = "veli" | "ogrenci" | "admin" | "ogretmen";

/** Giriş yapmış kullanıcının rolü (yüklenene kadar null). Yetki kontrolü DEĞİL, yalnızca arayüz içindir:
 *  asıl yetki veritabanında (admin fonksiyonları ve RLS) uygulanır. */
export function useCurrentRole(): AppRole | null {
  const [role, setRole] = useState<AppRole | null>(null);

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();

    supabase.auth.getUser().then(async ({ data }) => {
      const user = data.user;
      if (!user || cancelled) return;
      const { data: profile } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .maybeSingle();
      if (!cancelled) setRole((profile?.role as AppRole | undefined) ?? null);
    });

    return () => {
      cancelled = true;
    };
  }, []);

  return role;
}
