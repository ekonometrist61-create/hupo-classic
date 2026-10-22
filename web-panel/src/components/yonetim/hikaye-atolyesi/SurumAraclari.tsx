"use client";

// Seçili sürüm için düzenle / sil araçları. Düzenleme yeni taslak sürüm üretir (içerik değişmez kuralı);
// silme yalnız taslak/arşiv sürüm ve oturumsuz hikâye içindir, kuralları sunucu zorlar.
import { useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall } from "@/components/yonetim/useAdminRpc";
import type { OkumaDurum } from "@/lib/okuma/okuma";
import ErrorNote from "../panel/ErrorNote";
import ModalShell from "../panel/ModalShell";
import { dangerBtn, outlineBtn } from "../panel/styles";
import HikayeDuzenle from "./HikayeDuzenle";
import { useHataMetni } from "./ortak";
import type { Paket, SurumSatiri } from "./tipler";

type SilHedefi = "surum" | "hikaye";

interface Props {
  satir: SurumSatiri;
  durum: OkumaDurum;
  paket: Paket;
  /** Yeni taslak yazıldı veya bir şey silindi; liste yenilensin. */
  onDegisti: () => void;
  /** Silinen kayıt artık gösterilemez; ayrıntı kapansın. */
  onSilindi: () => void;
}

export default function SurumAraclari({ satir, durum, paket, onDegisti, onSilindi }: Props) {
  const t = useTranslations("yonetim.hikayeAtolyesi.araclar");
  const hata = useHataMetni();
  const [duzenle, setDuzenle] = useState(false);
  const [onay, setOnay] = useState<SilHedefi | null>(null);
  const [islemde, setIslemde] = useState(false);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);

  const surumSilinebilir = (durum === "taslak" || durum === "arsiv") && !(satir.oturum_sayisi && satir.oturum_sayisi > 0);

  const sil = async () => {
    if (!onay) return;
    setIslemde(true);
    setHataMesaji(null);
    const { error } =
      onay === "surum"
        ? await adminCall("okuma_surum_sil", { p_surum_id: satir.surum_id })
        : await adminCall("okuma_hikaye_sil", { p_hikaye_id: satir.hikaye_id });
    setIslemde(false);
    if (error) {
      setHataMesaji(hata(error));
      setOnay(null);
      return;
    }
    setOnay(null);
    onDegisti();
    onSilindi();
  };

  return (
    <div>
      <h5 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("baslik")}</h5>
      <p className="mb-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("not")}</p>
      <div className="flex flex-wrap gap-3">
        <button type="button" className={outlineBtn} disabled={islemde} onClick={() => setDuzenle((d) => !d)}>
          {duzenle ? t("duzenleKapat") : t("duzenle")}
        </button>
        <button type="button" className={outlineBtn} disabled={islemde || !surumSilinebilir} onClick={() => setOnay("surum")}>
          {t("surumSil")}
        </button>
        <button type="button" className={outlineBtn} disabled={islemde} onClick={() => setOnay("hikaye")}>
          {t("hikayeSil")}
        </button>
      </div>
      {!surumSilinebilir && (
        <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">
          {satir.oturum_sayisi && satir.oturum_sayisi > 0 ? t("oturumluIpucu", { n: satir.oturum_sayisi }) : t("silmeIpucu")}
        </p>
      )}
      <div aria-live="polite" className="mt-3">
        <ErrorNote message={hataMesaji} />
      </div>

      {duzenle && (
        <HikayeDuzenle
          paket={paket}
          slug={satir.slug}
          tur={paket.hikaye.tur}
          onKapat={() => setDuzenle(false)}
          onKaydedildi={onDegisti}
        />
      )}

      <ModalShell isOpen={onay !== null} onClose={() => (islemde ? undefined : setOnay(null))} title={onay === "hikaye" ? t("hikayeSilBaslik") : t("surumSilBaslik")}>
        <p className="mb-2 text-sm text-gray-700 dark:text-gray-300">
          {onay === "hikaye" ? t("hikayeSilMetin", { baslik: satir.baslik }) : t("surumSilMetin", { baslik: satir.baslik, no: satir.surum_no })}
        </p>
        <p className="mb-5 text-theme-sm font-medium text-error-700 dark:text-error-400">{t("geriAlinamaz")}</p>
        <div className="flex flex-wrap justify-end gap-3">
          <button type="button" className={outlineBtn} disabled={islemde} onClick={() => setOnay(null)}>
            {t("vazgec")}
          </button>
          <button type="button" className={dangerBtn} disabled={islemde} onClick={() => void sil()}>
            {onay === "hikaye" ? t("hikayeSilOnayla") : t("surumSilOnayla")}
          </button>
        </div>
      </ModalShell>
    </div>
  );
}