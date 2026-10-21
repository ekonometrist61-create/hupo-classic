"use client";

// Hikâye Atölyesi (Okuma Dünyası) yönetimi: hikâye yazımı panel dışındadır (atölye hattı);
// panel yalnızca içe aktarma, denetim/yayın, ayar ve izleme yapar. Yetki ve kurallar RPC'de uygulanır.
import { useRef, useState } from "react";
import { useTranslations } from "next-intl";

import { cardClass } from "../panel/styles";
import AyarlarSekmesi from "./AyarlarSekmesi";
import BoslukHaritasi from "./BoslukHaritasi";
import IceAktarSekmesi from "./IceAktarSekmesi";
import KarneSekmesi from "./KarneSekmesi";
import ListeSekmesi from "./ListeSekmesi";
import SozlukHedefSekmesi from "./SozlukHedefSekmesi";

const SEKMELER = ["liste", "iceAktar", "karne", "bosluk", "sozluk", "ayarlar"] as const;
type Sekme = (typeof SEKMELER)[number];

export default function HikayeAtolyesiManager() {
  const t = useTranslations("yonetim.hikayeAtolyesi");
  const [sekme, setSekme] = useState<Sekme>("liste");
  // İçe aktarma yazılınca liste sekmesi yeniden kurulsun (yeni taslak görünsün).
  const [listeAnahtari, setListeAnahtari] = useState(0);
  const refs = useRef<Record<string, HTMLButtonElement | null>>({});

  const klavye = (e: React.KeyboardEvent, i: number) => {
    let hedef = -1;
    if (e.key === "ArrowRight") hedef = (i + 1) % SEKMELER.length;
    else if (e.key === "ArrowLeft") hedef = (i - 1 + SEKMELER.length) % SEKMELER.length;
    else if (e.key === "Home") hedef = 0;
    else if (e.key === "End") hedef = SEKMELER.length - 1;
    if (hedef < 0) return;
    e.preventDefault();
    setSekme(SEKMELER[hedef]);
    refs.current[SEKMELER[hedef]]?.focus();
  };

  return (
    <div className={`${cardClass} p-5 sm:p-6`}>
      <p className="mb-4 text-sm text-gray-600 dark:text-gray-300">{t("giris")}</p>

      <div role="tablist" aria-label={t("sekmeler")} className="mb-5 flex gap-1 overflow-x-auto border-b border-gray-200 dark:border-gray-800">
        {SEKMELER.map((s, i) => (
          <button
            key={s}
            ref={(el) => {
              refs.current[s] = el;
            }}
            id={`ha-tab-${s}`}
            type="button"
            role="tab"
            aria-selected={sekme === s}
            aria-controls={`ha-panel-${s}`}
            tabIndex={sekme === s ? 0 : -1}
            onClick={() => setSekme(s)}
            onKeyDown={(e) => klavye(e, i)}
            className={`min-h-11 shrink-0 border-b-2 px-4 text-sm font-medium whitespace-nowrap transition ${
              sekme === s
                ? "border-brand-500 text-brand-600 dark:border-brand-400 dark:text-brand-400"
                : "border-transparent text-gray-600 hover:text-gray-800 dark:text-gray-400 dark:hover:text-gray-200"
            }`}
          >
            {t(`sekme.${s}`)}
          </button>
        ))}
      </div>

      <div role="tabpanel" id={`ha-panel-${sekme}`} aria-labelledby={`ha-tab-${sekme}`} tabIndex={0} className="focus-visible:outline-2 focus-visible:outline-brand-500">
        {sekme === "liste" && <ListeSekmesi key={listeAnahtari} />}
        {sekme === "iceAktar" && <IceAktarSekmesi onYazildi={() => setListeAnahtari((k) => k + 1)} />}
        {sekme === "karne" && <KarneSekmesi />}
        {sekme === "bosluk" && <BoslukHaritasi />}
        {sekme === "sozluk" && <SozlukHedefSekmesi />}
        {sekme === "ayarlar" && <AyarlarSekmesi />}
      </div>
    </div>
  );
}
