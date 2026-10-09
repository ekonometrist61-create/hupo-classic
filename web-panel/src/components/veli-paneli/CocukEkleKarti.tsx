"use client";

import Button from "@/components/ui/button/Button";
import { STUDENT_APP_URL } from "@/lib/app-url";
import { olusturCocukEslestirmeKodu } from "@/lib/veli-paneli/cocuk-kodu";
import { useLocale, useTranslations } from "next-intl";
import { useState } from "react";

interface AktifKod {
  kod: string;
  sonKullanma: string;
}

// Velinin çocuğunu bağlamak için tek kullanımlık kod ürettiği kart.
// Yeni kod, önceki kodu iptal eder (RPC bunu veritabanında yapar).
export default function CocukEkleKarti() {
  const t = useTranslations("veliPaneli.cocukEkle");
  const locale = useLocale();
  const [aktif, setAktif] = useState<AktifKod | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState(false);
  const [kopyalandi, setKopyalandi] = useState(false);
  const [kopyalamaHatasi, setKopyalamaHatasi] = useState(false);

  async function kodOlustur() {
    setYukleniyor(true);
    setHata(false);
    setKopyalandi(false);
    setKopyalamaHatasi(false);

    const sonuc = await olusturCocukEslestirmeKodu();
    setYukleniyor(false);

    if (sonuc.ok) {
      setAktif({ kod: sonuc.kod, sonKullanma: sonuc.sonKullanma });
    } else {
      // RPC önce eski kodları siler; hata durumunda eski kod artık geçerli olmayabilir.
      setAktif(null);
      setHata(true);
    }
  }

  async function kopyala() {
    if (!aktif) return;
    setKopyalamaHatasi(false);
    try {
      await navigator.clipboard.writeText(aktif.kod);
      setKopyalandi(true);
    } catch {
      setKopyalandi(false);
      setKopyalamaHatasi(true);
    }
  }

  const sonKullanmaMetni = aktif
    ? new Date(aktif.sonKullanma).toLocaleString(
        locale === "en" ? "en-GB" : "tr-TR",
        {
          day: "2-digit",
          month: "long",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        }
      )
    : "";

  return (
    <section className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>
      <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
        {t("desc")}
      </p>

      {aktif && (
        <div className="mt-5 rounded-xl bg-gray-50 p-4 text-center dark:bg-white/5">
          <p className="select-all font-mono text-3xl font-bold tracking-[0.3em] text-gray-800 dark:text-white/90">
            {aktif.kod}
          </p>
          <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
            {t("expires", { tarih: sonKullanmaMetni })}
          </p>
          <div className="mt-3 flex flex-wrap items-center justify-center gap-3">
            <Button size="sm" variant="outline" onClick={kopyala}>
              {kopyalandi ? t("copied") : t("copy")}
            </Button>
            {kopyalamaHatasi && (
              <span role="alert" className="text-theme-sm text-error-500">
                {t("copyError")}
              </span>
            )}
          </div>
        </div>
      )}

      <div className="mt-5">
        <Button size="sm" disabled={yukleniyor} onClick={kodOlustur}>
          {yukleniyor ? t("creating") : aktif ? t("createAgain") : t("create")}
        </Button>
      </div>

      {aktif && (
        <p className="mt-2 text-theme-sm text-gray-500 dark:text-gray-400">
          {t("replaceNote")}
        </p>
      )}

      {hata && (
        <p role="alert" className="mt-3 text-theme-sm text-error-500">
          {t("error")}
        </p>
      )}

      <p className="mt-5 text-theme-sm text-gray-600 dark:text-gray-400">
        {t("webText")}{" "}
        <a
          href={STUDENT_APP_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="font-semibold text-brand-600 underline underline-offset-4 hover:text-brand-700 dark:text-brand-300"
        >
          {t("webLink")}
        </a>
      </p>
    </section>
  );
}
