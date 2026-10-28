"use client";

// Ekran hedefi: veli, Hupo'yu çocuğuyla kullanmak için bir sonraki somut adımı görür (ana sayfa, ParentDashboard üstü).
// Ana eylem: sıradaki adımın tek bağlantısı (kod alanı, öğrenci uygulaması ya da planlar).
// Durum ve kabul: yükleniyor / hata (yeniden dene) / boş / hazır. Tüm adımlar tamamsa kart hiç çizilmez.
// Veri: public.veli_sonraki_adim() RPC'si (parametresiz, yalnızca oturumdaki velinin verisi).

import { Link } from "@/i18n/navigation";
import { STUDENT_APP_URL } from "@/lib/app-url";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

const KODLAR = ["cocuk_ekle", "eslestir", "ilk_ders", "deneme_veya_plan"] as const;
type AdimKodu = (typeof KODLAR)[number];
type AdimDurumu = "tamam" | "siradaki" | "bekliyor";
const DURUMLAR: readonly AdimDurumu[] = ["tamam", "siradaki", "bekliyor"];

interface Adim {
  kod: AdimKodu;
  durum: AdimDurumu;
}
interface SonrakiAdimVeri {
  adimlar: Adim[];
  siradaki: AdimKodu | null;
}

type Yuk =
  | { durum: "yukleniyor" }
  | { durum: "hata" }
  | { durum: "hazir"; veri: SonrakiAdimVeri };

// Sunucudan gelen veriyi istemcide de doğrular; beklenmeyen şekil hata sayılır.
function veriGecerliMi(v: unknown): v is SonrakiAdimVeri {
  if (typeof v !== "object" || v === null) return false;
  const o = v as { adimlar?: unknown; siradaki?: unknown };
  if (!Array.isArray(o.adimlar)) return false;
  const adimlarGecerli = o.adimlar.every((a) => {
    const x = a as { kod?: unknown; durum?: unknown };
    return (
      KODLAR.includes(x.kod as AdimKodu) &&
      DURUMLAR.includes(x.durum as AdimDurumu)
    );
  });
  const siradakiGecerli =
    o.siradaki === null || KODLAR.includes(o.siradaki as AdimKodu);
  return adimlarGecerli && siradakiGecerli;
}

const CTA_SINIF =
  "inline-flex min-h-11 items-center justify-center rounded-xl bg-brand-500 px-5 text-sm font-semibold text-white transition-colors hover:bg-brand-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-900";

export default function SonrakiAdimKarti() {
  const t = useTranslations("veliPaneli");
  const [yuk, setYuk] = useState<Yuk>({ durum: "yukleniyor" });
  const [denemeNo, setDenemeNo] = useState(0);

  useEffect(() => {
    let iptal = false;
    async function yukle() {
      try {
        const { data, error } = await createClient().rpc("veli_sonraki_adim");
        if (iptal) return;
        if (error || !veriGecerliMi(data)) {
          setYuk({ durum: "hata" });
          return;
        }
        setYuk({ durum: "hazir", veri: data });
      } catch {
        if (!iptal) setYuk({ durum: "hata" });
      }
    }
    void yukle();
    return () => {
      iptal = true;
    };
  }, [denemeNo]);

  function tekrarDene() {
    setYuk({ durum: "yukleniyor" });
    setDenemeNo((n) => n + 1);
  }

  // Tüm adımlar tamamsa kart görünmez (boş adım listesi ayrı, açıklamalı bir durumdur).
  if (
    yuk.durum === "hazir" &&
    yuk.veri.siradaki === null &&
    yuk.veri.adimlar.length > 0
  ) {
    return null;
  }

  function metin(kod: AdimKodu) {
    switch (kod) {
      case "cocuk_ekle":
        return {
          baslik: t("sonrakiAdim.adim.cocuk_ekle.baslik"),
          aciklama: t("sonrakiAdim.adim.cocuk_ekle.aciklama"),
          cta: t("sonrakiAdim.adim.cocuk_ekle.cta"),
        };
      case "eslestir":
        return {
          baslik: t("sonrakiAdim.adim.eslestir.baslik"),
          aciklama: t("sonrakiAdim.adim.eslestir.aciklama"),
          cta: t("sonrakiAdim.adim.eslestir.cta"),
        };
      case "ilk_ders":
        return {
          baslik: t("sonrakiAdim.adim.ilk_ders.baslik"),
          aciklama: t("sonrakiAdim.adim.ilk_ders.aciklama"),
          cta: t("sonrakiAdim.adim.ilk_ders.cta"),
        };
      case "deneme_veya_plan":
        return {
          baslik: t("sonrakiAdim.adim.deneme_veya_plan.baslik"),
          aciklama: t("sonrakiAdim.adim.deneme_veya_plan.aciklama"),
          cta: t("sonrakiAdim.adim.deneme_veya_plan.cta"),
        };
    }
  }

  function durumEtiketi(durum: AdimDurumu) {
    switch (durum) {
      case "tamam":
        return t("sonrakiAdim.durum.tamam");
      case "siradaki":
        return t("sonrakiAdim.durum.siradaki");
      case "bekliyor":
        return t("sonrakiAdim.durum.bekliyor");
    }
  }

  // Ana eylem: her adımın tek bağlantısı. Kod alanı aynı sayfada (#cocuk-ekle).
  function anaEylem(kod: AdimKodu, etiket: string) {
    if (kod === "ilk_ders") {
      return (
        <a
          href={STUDENT_APP_URL}
          target="_blank"
          rel="noopener noreferrer"
          className={CTA_SINIF}
        >
          {etiket}
        </a>
      );
    }
    if (kod === "deneme_veya_plan") {
      return (
        <Link href="/veli-paneli/uyelik" className={CTA_SINIF}>
          {etiket}
        </Link>
      );
    }
    return (
      <a href="#cocuk-ekle" className={CTA_SINIF}>
        {etiket}
      </a>
    );
  }

  return (
    <section
      aria-labelledby="sonraki-adim-baslik"
      className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3"
    >
      <h3
        id="sonraki-adim-baslik"
        className="text-lg font-semibold text-gray-800 dark:text-white/90"
      >
        {t("sonrakiAdim.title")}
      </h3>
      <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
        {t("sonrakiAdim.desc")}
      </p>

      {yuk.durum === "yukleniyor" && (
        <p role="status" className="mt-5 text-theme-sm text-gray-500 dark:text-gray-400">
          {t("sonrakiAdim.loading")}
        </p>
      )}

      {yuk.durum === "hata" && (
        <div className="mt-5 flex flex-wrap items-center gap-3">
          <p role="alert" className="text-theme-sm text-error-500">
            {t("sonrakiAdim.error")}
          </p>
          <button
            type="button"
            onClick={tekrarDene}
            className="inline-flex min-h-11 items-center justify-center rounded-xl px-4 text-sm font-medium text-brand-600 transition-colors hover:bg-gray-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 dark:text-brand-300 dark:hover:bg-white/5"
          >
            {t("sonrakiAdim.retry")}
          </button>
        </div>
      )}

      {yuk.durum === "hazir" && yuk.veri.adimlar.length === 0 && (
        <p className="mt-5 text-theme-sm text-gray-500 dark:text-gray-400">
          {t("sonrakiAdim.empty")}
        </p>
      )}

      {yuk.durum === "hazir" && yuk.veri.adimlar.length > 0 && (
        <>
          <p className="mt-5 text-theme-xs text-gray-500 dark:text-gray-400">
            {t("sonrakiAdim.ilerleme", {
              tamam: yuk.veri.adimlar.filter((a) => a.durum === "tamam").length,
              toplam: yuk.veri.adimlar.length,
            })}
          </p>
          <ol className="mt-3 space-y-3">
            {yuk.veri.adimlar.map((adim, sira) => {
              const m = metin(adim.kod);
              const tamam = adim.durum === "tamam";
              const siradaki = adim.durum === "siradaki";
              return (
                <li
                  key={adim.kod}
                  aria-current={siradaki ? "step" : undefined}
                  className={`rounded-xl border p-4 ${
                    siradaki
                      ? "border-brand-100 bg-brand-25 dark:border-brand-900 dark:bg-brand-950/40"
                      : "border-gray-100 dark:border-gray-800"
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <span
                      aria-hidden="true"
                      className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-semibold ${
                        tamam
                          ? "bg-brand-100 text-brand-700 dark:bg-brand-900 dark:text-brand-200"
                          : siradaki
                            ? "bg-brand-500 text-white"
                            : "bg-gray-100 text-gray-500 dark:bg-white/10 dark:text-gray-400"
                      }`}
                    >
                      {tamam ? (
                        <svg viewBox="0 0 20 20" fill="currentColor" className="h-4 w-4">
                          <path
                            fillRule="evenodd"
                            d="M16.704 5.296a1 1 0 010 1.408l-7.5 7.5a1 1 0 01-1.408 0l-3.5-3.5a1 1 0 111.408-1.408L8.5 11.59l6.796-6.795a1 1 0 011.408 0z"
                            clipRule="evenodd"
                          />
                        </svg>
                      ) : (
                        sira + 1
                      )}
                    </span>
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <p className="text-sm font-semibold text-gray-800 dark:text-white/90">
                          {m.baslik}
                        </p>
                        <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                          {durumEtiketi(adim.durum)}
                        </span>
                      </div>
                      {siradaki && (
                        <>
                          <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-400">
                            {m.aciklama}
                          </p>
                          <div className="mt-3">{anaEylem(adim.kod, m.cta)}</div>
                        </>
                      )}
                    </div>
                  </div>
                </li>
              );
            })}
          </ol>
        </>
      )}
    </section>
  );
}
