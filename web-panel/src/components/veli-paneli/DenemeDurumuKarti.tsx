"use client";

import { useLocale, useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import { createClient } from "@/utils/supabase/client";

// Veli: her çocuğun ücretsiz deneme durumu ve deneme sırasındaki sınırları.
// Veriyi deneme_hak_durumu RPC'si verir; yalnız bu hanenin çocukları için çalışır.
interface OzellikDurum {
  ozellik: string;
  sinir: number;
  pencere: "gunluk" | "deneme";
  kullanilan: number;
  kalan: number;
}

interface HakDurumu {
  deneme: boolean;
  premium: boolean;
  bitis: string | null;
  son_bitis: string | null;
  kalan_gun: number | null;
  ozellikler: OzellikDurum[];
}

type Satir = HakDurumu | "hata" | "yukleniyor";

export default function DenemeDurumuKarti({
  students,
}: {
  students: { id: string; full_name: string | null }[];
}) {
  const t = useTranslations("veliPaneli.membership.trial");
  const locale = useLocale();
  const [satirlar, setSatirlar] = useState<Record<string, Satir>>({});

  useEffect(() => {
    let iptal = false;
    const supabase = createClient();
    void (async () => {
      const sonuclar = await Promise.all(
        students.map(async (s) => {
          const { data, error } = await supabase.rpc("deneme_hak_durumu", { p_ogrenci: s.id });
          const satir: Satir = error || !data ? "hata" : (data as HakDurumu);
          return [s.id, satir] as const;
        }),
      );
      if (!iptal) setSatirlar(Object.fromEntries(sonuclar));
    })();
    return () => {
      iptal = true;
    };
  }, [students]);

  // Bilgi yoksa (eski hesap, deneme hiç açılmamış) kart gösterilmez.
  const gosterilecek = students.filter((s) => {
    const d = satirlar[s.id];
    return d === undefined || d === "yukleniyor" || d === "hata" || d.deneme || d.son_bitis || d.premium;
  });
  if (students.length === 0 || gosterilecek.length === 0) return null;

  const tarih = (iso: string | null) =>
    iso ? new Date(iso).toLocaleDateString(locale === "en" ? "en-US" : "tr-TR") : "";

  const sinirBul = (d: HakDurumu, ozellik: string) => d.ozellikler.find((o) => o.ozellik === ozellik)?.sinir ?? "—";

  return (
    <div className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h3>

      <ul className="space-y-4">
        {gosterilecek.map((s) => {
          const d = satirlar[s.id];
          const ad = s.full_name ?? t("cocuk");
          return (
            <li key={s.id} className="min-w-0 rounded-xl border border-gray-200 p-4 text-sm dark:border-gray-700">
              <p className="font-semibold text-gray-800 dark:text-white/90">{ad}</p>

              {d === undefined || d === "yukleniyor" ? (
                <p className="mt-2 text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>
              ) : d === "hata" ? (
                <p role="alert" className="mt-2 text-error-500">{t("hata")}</p>
              ) : d.premium ? (
                <p className="mt-2 text-gray-700 dark:text-gray-300">{t("premium")}</p>
              ) : d.deneme ? (
                <div className="mt-2 space-y-2 text-gray-700 dark:text-gray-300">
                  <p>{t("aktif", { bitis: tarih(d.bitis), kalan: d.kalan_gun ?? 0 })}</p>
                  <p>
                    {t("limitler", {
                      soru: sinirBul(d, "soru"),
                      okuma: sinirBul(d, "okuma_hikayesi"),
                      kelime: sinirBul(d, "kelime_evreni"),
                      carpim: sinirBul(d, "carpim_sifresi"),
                      sinav: sinirBul(d, "deneme_sinavi"),
                    })}
                  </p>
                  <p className="text-gray-500 dark:text-gray-400">{t("otomatik")}</p>
                  {(d.kalan_gun ?? 99) <= 3 && (
                    <p role="status" className="rounded-lg bg-warning-50 p-3 text-warning-700 dark:bg-warning-900/20 dark:text-warning-300">
                      {t("t3", { bitis: tarih(d.bitis) })}
                    </p>
                  )}
                </div>
              ) : (
                <div className="mt-2 space-y-2 text-gray-700 dark:text-gray-300">
                  <p>{t("bitti", { bitis: tarih(d.son_bitis) })}</p>
                  <p>{t("ilerleme")}</p>
                </div>
              )}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
