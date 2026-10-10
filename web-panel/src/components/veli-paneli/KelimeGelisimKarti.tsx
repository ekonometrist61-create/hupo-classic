"use client";

// Veli: çocuğun Kelime Evreni gelişim özeti. Yalnızca toplu sonuçlar gösterilir (tek tek cevap yok).
// Öneriler sunucudan kod olarak gelir; metinleri burada çevrilir.

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";

type KelimeIliski = "es_anlamli" | "zit_anlamli" | "es_sesli";

interface ZorlanilanKelime {
  kelime: string;
  anlam: string;
  iliski_turu: KelimeIliski;
  yanlis_sayisi: number;
}

interface KelimeOzet {
  deneme_sayisi: number;
  dogru_orani: number | null;
  ipucusuz_dogru_orani: number | null;
  ipucu_kullanim_orani: number | null;
  tekrar_bekleyen: number;
  son_7_gun_deneme: number;
  zorlanilan: ZorlanilanKelime[];
  oneriler: string[];
}

interface Props {
  cocukId: string;
  cocukAd: string | null;
}

const BILINEN_ONERILER = ["tekrar_bekleyen", "zorlanilan_tekrar", "haftalik_calisma_yok", "devam"] as const;

export default function KelimeGelisimKarti({ cocukId, cocukAd }: Props) {
  const t = useTranslations("veliPaneli.kelime");
  const [ozet, setOzet] = useState<KelimeOzet | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    let cancelled = false;
    createClient()
      .rpc("kelime_veli_ozeti", { p_cocuk_id: cocukId })
      .then(({ data, error: err }) => {
        if (cancelled) return;
        setLoading(false);
        if (err) {
          setError(true);
          setOzet(null);
          return;
        }
        setError(false);
        setOzet(data as KelimeOzet);
      });
    return () => {
      cancelled = true;
    };
  }, [cocukId]);

  const oneriMetni = (kod: string, tekrar: number) => {
    const bilinen = (BILINEN_ONERILER as readonly string[]).includes(kod) ? kod : "devam";
    return t(`oneri.${bilinen}`, { sayi: tekrar });
  };

  return (
    <section className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <div className="mb-4">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
          {t("baslik")}
          {cocukAd ? <span className="ml-2 text-sm font-normal text-gray-500">{cocukAd}</span> : null}
        </h3>
      </div>

      {loading && <p className="text-sm text-gray-500">{t("yukleniyor")}</p>}
      {!loading && error && <p className="text-sm text-red-600 dark:text-red-400">{t("hata")}</p>}
      {!loading && !error && ozet && ozet.deneme_sayisi === 0 && (
        <p className="text-sm text-gray-600 dark:text-gray-300">{t("bos")}</p>
      )}

      {!loading && !error && ozet && ozet.deneme_sayisi > 0 && (
        <div className="space-y-5">
          <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
            <Metrik etiket={t("denemeSayisi")} deger={String(ozet.deneme_sayisi)} />
            <Metrik etiket={t("dogruOrani")} deger={ozet.dogru_orani === null ? "–" : `%${ozet.dogru_orani}`} />
            <Metrik etiket={t("ipucusuzDogru")} deger={ozet.ipucusuz_dogru_orani === null ? "–" : `%${ozet.ipucusuz_dogru_orani}`} />
            <Metrik etiket={t("tekrarBekleyen")} deger={String(ozet.tekrar_bekleyen)} />
          </div>

          <div>
            <h4 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-200">{t("oneriBaslik")}</h4>
            <ul className="list-disc space-y-1 pl-5 text-sm text-gray-700 dark:text-gray-300">
              {ozet.oneriler.map((kod) => (
                <li key={kod}>{oneriMetni(kod, ozet.tekrar_bekleyen)}</li>
              ))}
            </ul>
          </div>

          {ozet.zorlanilan.length > 0 && (
            <div>
              <h4 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-200">{t("zorlanilanBaslik")}</h4>
              <ul className="divide-y divide-gray-100 text-sm dark:divide-gray-800">
                {ozet.zorlanilan.map((z) => (
                  <li key={`${z.kelime}-${z.anlam}-${z.iliski_turu}`} className="flex flex-wrap items-center justify-between gap-2 py-2">
                    <span>
                      <span className="font-medium text-gray-800 dark:text-white/90">{z.kelime}</span>
                      <span className="ml-2 text-gray-500">{z.anlam}</span>
                    </span>
                    <span className="text-xs text-gray-500">
                      {t(`iliski.${z.iliski_turu}`)} · {t("yanlis", { sayi: z.yanlis_sayisi })}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          <p className="text-xs text-gray-500 dark:text-gray-400">{t("gizlilik")}</p>
        </div>
      )}
    </section>
  );
}

function Metrik({ etiket, deger }: { etiket: string; deger: string }) {
  return (
    <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
      <p className="text-xs text-gray-500 dark:text-gray-400">{etiket}</p>
      <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{deger}</p>
    </div>
  );
}
