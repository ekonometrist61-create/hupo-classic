"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import BildirimManager from "./BildirimManager";
import SegmentliBildirim from "./SegmentliBildirim";

type Sekme = "segment" | "hizli";

/** Bildirim sayfasının iki yolu: segmente push kampanyası ve veliye hızlı bildirim. */
export default function BildirimSekmeleri() {
  const t = useTranslations("yonetim.bildirimler.tabs");
  const [sekme, setSekme] = useState<Sekme>("segment");

  const sekmeClass = (aktif: boolean) =>
    `min-h-11 rounded-xl px-4 text-theme-sm font-medium transition-colors ${
      aktif
        ? "bg-brand-500 text-white"
        : "border border-gray-200 text-gray-600 hover:bg-gray-50 dark:border-gray-800 dark:text-gray-300 dark:hover:bg-white/5"
    }`;

  return (
    <div className="space-y-6">
      <div role="tablist" aria-label={t("label")} className="flex flex-wrap gap-2">
        <button
          type="button"
          role="tab"
          id="bildirim-tab-segment"
          aria-selected={sekme === "segment"}
          aria-controls="bildirim-panel"
          className={sekmeClass(sekme === "segment")}
          onClick={() => setSekme("segment")}
        >
          {t("segment")}
        </button>
        <button
          type="button"
          role="tab"
          id="bildirim-tab-hizli"
          aria-selected={sekme === "hizli"}
          aria-controls="bildirim-panel"
          className={sekmeClass(sekme === "hizli")}
          onClick={() => setSekme("hizli")}
        >
          {t("quick")}
        </button>
      </div>

      <div role="tabpanel" id="bildirim-panel" aria-labelledby={sekme === "segment" ? "bildirim-tab-segment" : "bildirim-tab-hizli"}>
        {sekme === "segment" ? <SegmentliBildirim /> : <BildirimManager />}
      </div>
    </div>
  );
}
