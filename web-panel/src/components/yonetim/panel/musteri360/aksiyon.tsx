"use client";

import { useState, type ReactNode } from "react";
import { useTranslations } from "next-intl";

import { useCurrentRole } from "@/hooks/useCurrentRole";
import { adminCall } from "../../useAdminRpc";
import ErrorNote from "../ErrorNote";
import { cardClass, inputClass } from "../styles";

// Çok satırlı alanlar: inputClass'taki sabit yükseklik (h-11) kaldırılır.
export const metinAlaniClass = inputClass.replace("h-11 ", "");

/** Arayüz yetki kapısı (sunucu zaten require_admin ile korur). */
export function useYonetici(): boolean {
  return useCurrentRole() === "admin";
}

/** Yazma eylemi: yükleniyor, hata ve başarı durumlarını tutar. Hata metni çeviriden gelir. */
export function useAdminAksiyon() {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const [busy, setBusy] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [basari, setBasari] = useState<string | null>(null);

  const calistir = async (fn: string, args: Record<string, unknown>): Promise<{ data: unknown } | null> => {
    setBusy(true);
    setHata(null);
    setBasari(null);
    const sonuc = await adminCall(fn, args);
    setBusy(false);
    if (sonuc.error !== null) {
      // Aboneli hane reddi Türkçe metinle gösterilir; diğer sunucu mesajları olduğu gibi eklenir.
      const anahtar = sonuc.missing
        ? "eksik"
        : sonuc.error === "DEMO"
          ? "demo"
          : /abone|subscri/i.test(sonuc.error)
            ? "abonelik"
            : "genel";
      setHata(anahtar === "genel" ? `${t("hata.genel")} ${sonuc.error}` : t(`hata.${anahtar}`));
      return null;
    }
    return { data: sonuc.data };
  };

  return { busy, hata, basari, setHata, setBasari, calistir };
}

export function Kart({ baslik, aciklama, children }: { baslik: string; aciklama?: string; children: ReactNode }) {
  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h3 className="mb-2 text-base font-semibold text-gray-800 dark:text-white/90">{baslik}</h3>
      {aciklama && <p className="mb-4 text-theme-sm text-gray-500 dark:text-gray-400">{aciklama}</p>}
      {children}
    </section>
  );
}

export function AksiyonBildirim({ hata, basari }: { hata: string | null; basari: string | null }) {
  return (
    <div className="space-y-3">
      <ErrorNote message={hata} />
      {basari && (
        <p
          role="status"
          className="rounded-lg bg-success-50 px-3 py-2 text-theme-sm text-success-600 dark:bg-success-500/15 dark:text-success-500"
        >
          {basari}
        </p>
      )}
    </div>
  );
}

/** Dışa aktarılan veriyi tarayıcıda JSON dosyası olarak indirir. Veri konsola yazılmaz. */
export function jsonIndir(veri: unknown, dosyaAdi: string): void {
  const blob = new Blob([JSON.stringify(veri, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = dosyaAdi;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
