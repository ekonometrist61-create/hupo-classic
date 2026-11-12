"use client";

import { useTranslations } from "next-intl";
import { useState } from "react";

// TOTP kaydının ilk adımı: QR kod ve elle girilecek gizli anahtar (GÖR-106).
// QR, Supabase enroll yanıtındaki SVG data URI'dir (`totp.qr_code`); ek QR kütüphanesi kullanılmaz.
// Gizli anahtar yalnız bu ekranda gösterilir; hiçbir yere kaydedilmez ve loglanmaz.
type Props = {
  qrKod: string | null;
  anahtar: string | null;
  kurulumHatasi: boolean;
  onYeniden: () => void;
};

// Uygulamaya elle yazmayı kolaylaştırmak için 4'lü gruplar (kopyalanan değer boşluksuzdur).
function grupla(anahtar: string): string {
  return anahtar.replace(/(.{4})/g, "$1 ").trim();
}

export default function MfaKayitPaneli({ qrKod, anahtar, kurulumHatasi, onYeniden }: Props) {
  const t = useTranslations("yonetimMfa");
  const [kopyalandi, setKopyalandi] = useState(false);

  async function kopyala() {
    if (!anahtar) return;
    try {
      await navigator.clipboard.writeText(anahtar);
      setKopyalandi(true);
    } catch {
      // Pano izni yoksa anahtar ekranda seçilebilir durumda kalır; ayrıca hata gösterilmez.
      setKopyalandi(false);
    }
  }

  if (kurulumHatasi) {
    return (
      <div className="space-y-4">
        <div role="alert" className="rounded-xl border border-error-200 bg-error-50 px-4 py-3 text-sm font-medium text-error-700">
          <p>{t("hataKurulum")}</p>
        </div>
        <button
          type="button"
          onClick={onYeniden}
          className="inline-flex h-11 w-full cursor-pointer items-center justify-center rounded-lg bg-navy px-6 text-sm font-semibold text-white transition-colors hover:bg-navy-light focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("yeniden")}
        </button>
      </div>
    );
  }

  if (!qrKod || !anahtar) {
    return (
      <p role="status" className="py-8 text-center text-sm text-navy-muted">
        {t("hazirlaniyor")}
      </p>
    );
  }

  return (
    <div>
      <p className="text-sm text-navy">{t("adim1")}</p>
      <div className="mt-4 flex justify-center">
        {/* SVG data URI; next/image optimizasyonu gerekmez ve uzak alan adı içermez. */}
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={qrKod}
          alt={t("qrAlt")}
          width={184}
          height={184}
          className="size-46 rounded-lg bg-white p-2 ring-1 ring-navy/10"
        />
      </div>

      <p id="mfa-anahtar-etiket" className="mt-5 text-sm text-navy-muted">
        {t("anahtarEtiket")}
      </p>
      <div className="mt-2 flex items-stretch gap-2">
        <code
          aria-labelledby="mfa-anahtar-etiket"
          className="flex min-h-11 flex-1 items-center rounded-lg border border-gray-300 bg-gray-50 px-3.5 font-mono text-sm break-all text-navy select-all"
        >
          {grupla(anahtar)}
        </code>
        <button
          type="button"
          onClick={kopyala}
          className="inline-flex min-h-11 shrink-0 cursor-pointer items-center rounded-lg border border-gray-300 bg-white px-3.5 text-sm font-semibold text-navy transition-colors hover:bg-gray-50 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500"
        >
          {t("kopyala")}
        </button>
      </div>
      <p role="status" aria-live="polite" className="mt-1.5 min-h-5 text-xs text-success-700">
        {kopyalandi ? t("kopyalandi") : ""}
      </p>
    </div>
  );
}
