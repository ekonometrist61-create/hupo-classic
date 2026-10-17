"use client";

import Button from "@/components/ui/button/Button";
import { Link } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/client";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";

import CocukEkleKarti from "./CocukEkleKarti";

type RizaDurumu = "verildi" | "bekliyor" | "geri_cekildi";

interface BagliCocuk {
  id: string;
  ad: string;
  kullanici_adi: string | null;
  baglandi_at: string | null;
  riza: RizaDurumu;
}

// Rozet renkleri: durum tek bakışta okunsun diye yalnızca ton değişir, metin her zaman yazılır.
const RIZA_ROZET: Record<RizaDurumu, string> = {
  verildi: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-400",
  bekliyor: "bg-warning-50 text-warning-700 dark:bg-warning-500/15 dark:text-warning-400",
  geri_cekildi: "bg-gray-100 text-gray-700 dark:bg-white/10 dark:text-gray-300",
};

// Veli için bağlı çocukların listesi: kim bağlı, ne zaman bağlandı, veri paylaşımı açık mı.
// E-posta ve telefon gösterilmez; yalnızca ad, kullanıcı adı ve durum.
export default function CocuklarimView() {
  const t = useTranslations("veliPaneli.cocuklarim");
  const locale = useLocale();
  const [liste, setListe] = useState<BagliCocuk[] | null>(null);
  const [hata, setHata] = useState(false);
  const [kaldirilacak, setKaldirilacak] = useState<string | null>(null);
  const [islemde, setIslemde] = useState<string | null>(null);
  const [mesaj, setMesaj] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    const { data, error } = await createClient().rpc("veli_bagli_cocuklar");
    if (error || !Array.isArray(data)) {
      setHata(true);
      return;
    }
    setHata(false);
    setListe(data as BagliCocuk[]);
  }, []);

  // İlk yükleme: yanıt geri çağrıda işlenir (effect gövdesinde senkron setState yok).
  useEffect(() => {
    let iptal = false;
    createClient()
      .rpc("veli_bagli_cocuklar")
      .then(({ data, error }) => {
        if (iptal) return;
        if (error || !Array.isArray(data)) {
          setHata(true);
          return;
        }
        setListe(data as BagliCocuk[]);
      });
    return () => {
      iptal = true;
    };
  }, []);

  async function bagliligiKaldir(cocuk: BagliCocuk) {
    setIslemde(cocuk.id);
    setMesaj(null);
    const { error } = await createClient().rpc("veli_cocuk_baglantisini_kaldir", {
      p_cocuk_id: cocuk.id,
    });
    setIslemde(null);
    setKaldirilacak(null);
    if (error) {
      setMesaj(t("hata"));
      return;
    }
    setMesaj(t("kaldirildi"));
    await yukle();
  }

  const tarihBicimi = (iso: string) =>
    new Date(iso).toLocaleDateString(locale === "en" ? "en-GB" : "tr-TR", {
      day: "2-digit",
      month: "long",
      year: "numeric",
    });

  return (
    <div className="space-y-4 md:space-y-6">
      <section className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
        <h2 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("title")}</h2>
        <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">{t("desc")}</p>

        <p role="status" aria-live="polite" className="mt-3 text-theme-sm text-success-700 dark:text-success-400">
          {mesaj}
        </p>

        {hata && (
          <p role="alert" className="mt-4 text-theme-sm text-error-500">
            {t("hata")}
          </p>
        )}

        {!hata && liste === null && (
          <p className="mt-4 text-theme-sm text-gray-500">{t("yukleniyor")}</p>
        )}

        {!hata && liste !== null && liste.length === 0 && (
          <div className="mt-5 rounded-xl bg-gray-50 p-5 dark:bg-white/5">
            <p className="font-semibold text-gray-800 dark:text-white/90">{t("empty.title")}</p>
            <p className="mt-2 text-theme-sm text-gray-600 dark:text-gray-400">{t("empty.text")}</p>
          </div>
        )}

        {!hata && liste !== null && liste.length > 0 && (
          <ul className="mt-5 space-y-3">
            {liste.map((cocuk) => {
              const bekleniyor = kaldirilacak === cocuk.id;
              const isleniyor = islemde === cocuk.id;
              return (
                <li
                  key={cocuk.id}
                  className="rounded-xl border border-gray-200 p-4 dark:border-gray-800"
                >
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="font-semibold text-gray-800 dark:text-white/90">{cocuk.ad}</p>
                      {cocuk.kullanici_adi && (
                        <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                          @{cocuk.kullanici_adi}
                        </p>
                      )}
                      <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                        {cocuk.baglandi_at
                          ? t("bagliTarih", { tarih: tarihBicimi(cocuk.baglandi_at) })
                          : t("bagliTarihYok")}
                      </p>
                    </div>
                    <span
                      className={`inline-flex items-center rounded-full px-3 py-1 text-theme-xs font-semibold ${RIZA_ROZET[cocuk.riza]}`}
                    >
                      {t(`riza.${cocuk.riza}`)}
                    </span>
                  </div>

                  <p className="mt-3 text-theme-sm text-gray-600 dark:text-gray-400">
                    {t(`rizaYardim.${cocuk.riza}`)}
                  </p>

                  {bekleniyor ? (
                    <div className="mt-4 rounded-xl bg-error-50 p-4 dark:bg-error-500/10">
                      <p className="font-semibold text-gray-800 dark:text-white/90">
                        {t("kaldirOnay.baslik", { ad: cocuk.ad })}
                      </p>
                      <p className="mt-2 text-theme-sm text-gray-600 dark:text-gray-400">
                        {t("kaldirOnay.metin")}
                      </p>
                      <div className="mt-4 flex flex-wrap gap-3">
                        <Button
                          size="sm"
                          className="min-h-11 min-w-11 bg-error-500 hover:bg-error-600"
                          disabled={isleniyor}
                          onClick={() => bagliligiKaldir(cocuk)}
                        >
                          {t("kaldirOnay.onayla")}
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="min-h-11 min-w-11"
                          disabled={isleniyor}
                          onClick={() => setKaldirilacak(null)}
                        >
                          {t("kaldirOnay.vazgec")}
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <div className="mt-4 flex flex-wrap gap-3">
                      {cocuk.riza === "verildi" && (
                        <Link
                          href="/veli-paneli"
                          className="inline-flex min-h-11 items-center rounded-lg border border-gray-300 px-4 text-theme-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
                        >
                          {t("panel")}
                        </Link>
                      )}
                      <Button
                        size="sm"
                        variant="outline"
                        className="min-h-11 min-w-11 text-error-600"
                        disabled={isleniyor}
                        onClick={() => setKaldirilacak(cocuk.id)}
                      >
                        {t("kaldir")}
                      </Button>
                    </div>
                  )}
                </li>
              );
            })}
          </ul>
        )}
      </section>

      <div>
        <h3 className="mb-3 text-base font-semibold text-gray-800 dark:text-white/90">{t("yeniEkle")}</h3>
        <CocukEkleKarti />
      </div>
    </div>
  );
}
