"use client";

import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

interface Odeme {
  id: string;
  tutar_kurus: number;
  para_birimi: string;
  durum: "bekliyor" | "basarili" | "basarisiz" | "iade";
  created_at: string;
}

const DURUM_RENK: Record<string, "success" | "warning" | "error" | "info"> = {
  basarili: "success",
  bekliyor: "warning",
  basarisiz: "error",
  iade: "info",
};

function formatTL(kurus: number) {
  return (kurus / 100).toLocaleString("tr-TR", {
    style: "currency",
    currency: "TRY",
    minimumFractionDigits: 2,
  });
}

export default function OdemeGecmisi() {
  const t = useTranslations("veliPaneli.odeme");
  const [odemeler, setOdemeler] = useState<Odeme[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) { setOdemeler([]); return; }

      const { data, error } = await supabase
        .from("payments")
        .select("id, tutar_kurus, para_birimi, durum, created_at")
        .eq("veli_id", user.id)
        .order("created_at", { ascending: false })
        .limit(20);

      if (cancelled) return;
      if (error) { setHata(error.message); setOdemeler([]); return; }
      setOdemeler((data as Odeme[]) ?? []);
    };
    void run();
    return () => { cancelled = true; };
  }, []);

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>

      {odemeler === null && !hata && (
        <p className="text-sm text-gray-500 dark:text-gray-400">Yükleniyor...</p>
      )}

      {hata && (
        <p role="alert" className="text-sm text-error-500">{hata}</p>
      )}

      {odemeler !== null && odemeler.length === 0 && !hata && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
      )}

      {odemeler && odemeler.length > 0 && (
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead className="border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th className="pb-2 pr-4 text-left text-xs font-medium uppercase text-gray-500 dark:text-gray-400">
                  {t("tarih")}
                </th>
                <th className="pb-2 pr-4 text-left text-xs font-medium uppercase text-gray-500 dark:text-gray-400">
                  {t("tutar")}
                </th>
                <th className="pb-2 text-left text-xs font-medium uppercase text-gray-500 dark:text-gray-400">
                  Durum
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {odemeler.map((o) => (
                <tr key={o.id}>
                  <td className="py-2.5 pr-4 text-gray-700 dark:text-gray-300 whitespace-nowrap">
                    {new Date(o.created_at).toLocaleDateString("tr-TR", {
                      day: "2-digit",
                      month: "short",
                      year: "numeric",
                    })}
                  </td>
                  <td className="py-2.5 pr-4 font-medium text-gray-800 dark:text-white/90 whitespace-nowrap">
                    {formatTL(o.tutar_kurus)}
                  </td>
                  <td className="py-2.5">
                    <Badge size="sm" color={DURUM_RENK[o.durum] ?? "warning"}>
                      {t(`durum.${o.durum}` as Parameters<typeof t>[0])}
                    </Badge>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
