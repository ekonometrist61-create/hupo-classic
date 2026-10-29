"use client";

import Badge from "@/components/ui/badge/Badge";
import { oturumuBekle } from "@/hooks/useCurrentRole";
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

// Ödeme geçmişi: 768 px altında kart listesi, md ve üzerinde tablo (R4).
export default function OdemeGecmisi() {
  const t = useTranslations("veliPaneli.odeme");
  const [odemeler, setOdemeler] = useState<Odeme[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const supabase = createClient();
      // Kullanıcı kimliği paylaşılan oturum bilgisinden gelir (ayrı getUser çağrısı yapılmaz).
      const { kullaniciId } = await oturumuBekle();
      if (!kullaniciId) { setOdemeler([]); return; }

      const { data, error } = await supabase
        .from("payments")
        .select("id, tutar_kurus, para_birimi, durum, created_at")
        .eq("veli_id", kullaniciId)
        .order("created_at", { ascending: false })
        .limit(20);

      if (cancelled) return;
      if (error) { setHata(error.message); setOdemeler([]); return; }
      setOdemeler((data as Odeme[]) ?? []);
    };
    void run();
    return () => { cancelled = true; };
  }, []);

  const tarihMetni = (iso: string) =>
    new Date(iso).toLocaleDateString("tr-TR", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });

  return (
    <div className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>

      {odemeler === null && !hata && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      )}

      {hata && (
        <p role="alert" className="text-sm text-error-500">{hata}</p>
      )}

      {odemeler !== null && odemeler.length === 0 && !hata && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
      )}

      {odemeler && odemeler.length > 0 && (
        <>
          <ul className="space-y-3 md:hidden">
            {odemeler.map((o) => (
              <li
                key={o.id}
                className="flex items-center justify-between gap-3 rounded-xl border border-gray-100 p-4 dark:border-gray-800"
              >
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-gray-800 dark:text-white/90">
                    {formatTL(o.tutar_kurus)}
                  </p>
                  <p className="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                    {tarihMetni(o.created_at)}
                  </p>
                </div>
                <Badge size="sm" color={DURUM_RENK[o.durum] ?? "warning"}>
                  {t(`durum.${o.durum}` as Parameters<typeof t>[0])}
                </Badge>
              </li>
            ))}
          </ul>

          <div className="hidden overflow-x-auto md:block">
            <table className="min-w-full text-sm">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th scope="col" className="pb-2 pr-4 text-left text-xs font-medium uppercase text-gray-500 dark:text-gray-400">
                    {t("tarih")}
                  </th>
                  <th scope="col" className="pb-2 pr-4 text-left text-xs font-medium uppercase text-gray-500 dark:text-gray-400">
                    {t("tutar")}
                  </th>
                  <th scope="col" className="pb-2 text-left text-xs font-medium uppercase text-gray-500 dark:text-gray-400">
                    {t("durumBaslik")}
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {odemeler.map((o) => (
                  <tr key={o.id}>
                    <td className="py-2.5 pr-4 whitespace-nowrap text-gray-700 dark:text-gray-300">
                      {tarihMetni(o.created_at)}
                    </td>
                    <td className="py-2.5 pr-4 font-medium whitespace-nowrap text-gray-800 dark:text-white/90">
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
        </>
      )}
    </div>
  );
}
