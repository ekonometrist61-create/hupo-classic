"use client";

import { useId, useState, type ReactNode } from "react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { useAdminRpc } from "../../useAdminRpc";
import ErrorNote from "../ErrorNote";
import ModalShell from "../ModalShell";
import useDebounced from "../useDebounced";
import { dangerBtn, inputClass, labelClass, linkBtn, outlineBtn } from "../styles";
import { AksiyonBildirim, Kart, useAdminAksiyon, useYonetici } from "./aksiyon";

type AramaSatiri = { id: string; customer_no: string | null; parent_name: string; email: string | null };
type AramaSonucu = { rows: AramaSatiri[]; total: number };
type Hedef = { id: string; parent_name: string; customer_no: string | null };

/** Yalnızca yöneticiye görünür. Sunucu tarafında da require_admin korur. */
export default function HaneBirlestir({ householdId }: { householdId: string }) {
  const yonetici = useYonetici();
  if (!yonetici) return null;
  return <BirlestirFormu householdId={householdId} />;
}

function BirlestirFormu({ householdId }: { householdId: string }) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const onay = useAdminAksiyon();
  const alanId = useId();
  const [arama, setArama] = useState("");
  const aranan = useDebounced(arama).trim();
  const [hedef, setHedef] = useState<Hedef | null>(null);
  const [onayAcik, setOnayAcik] = useState(false);
  const [birlesenHedef, setBirlesenHedef] = useState<string | null>(null);

  const sonuclar = useAdminRpc<AramaSonucu>(
    "admin_musteri_360_listele",
    {
      p_arama: aranan,
      p_lifecycle: null,
      p_plan: null,
      p_limit: 10,
      p_offset: 0,
      p_kaynak: null,
      p_izin_kanal: null,
    },
    { enabled: aranan.length >= 2 },
  );
  const liste = (sonuclar.data?.rows ?? []).filter((r) => r.id !== householdId);

  const birlestir = async () => {
    if (!hedef) return;
    const sonuc = await onay.calistir("admin_growth_hane_birlestir", {
      p_kaynak: householdId,
      p_hedef: hedef.id,
    });
    if (!sonuc) return;
    setOnayAcik(false);
    setBirlesenHedef(hedef.id);
  };

  let icerik: ReactNode;
  if (birlesenHedef) {
    icerik = (
      <div role="status" className="space-y-2 rounded-lg bg-success-50 px-3 py-2 dark:bg-success-500/15">
        <p className="text-theme-sm text-success-600 dark:text-success-500">{t("birlestir.basarili")}</p>
        <Link href={`/yonetim/musteri-360/${birlesenHedef}`} className={`${linkBtn} inline-flex min-h-11 items-center`}>
          {t("birlestir.hedefGit")}
        </Link>
      </div>
    );
  } else {
    let sonucAlani: ReactNode;
    if (aranan.length < 2) {
      sonucAlani = <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("birlestir.enAz")}</p>;
    } else if (sonuclar.loading) {
      sonucAlani = <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>;
    } else if (sonuclar.error) {
      sonucAlani = (
        <ErrorNote message={sonuclar.missing ? t("hata.eksik") : `${t("hata.genel")} ${sonuclar.error}`} />
      );
    } else if (liste.length === 0) {
      sonucAlani = <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("birlestir.sonuc")}</p>;
    } else {
      sonucAlani = (
        <ul className="divide-y divide-gray-100 dark:divide-gray-800">
          {liste.map((r) => (
            <li key={r.id} className="flex items-center justify-between gap-3 py-3">
              <div className="min-w-0">
                <p className="truncate text-theme-sm font-medium text-gray-800 dark:text-white/90">{r.parent_name}</p>
                <p className="text-theme-xs text-gray-500 dark:text-gray-400">{r.customer_no ?? "-"}</p>
              </div>
              <button
                type="button"
                className={`${outlineBtn} shrink-0`}
                onClick={() => setHedef({ id: r.id, parent_name: r.parent_name, customer_no: r.customer_no })}
              >
                {t("birlestir.sec")}
                <span className="sr-only"> {r.parent_name}</span>
              </button>
            </li>
          ))}
        </ul>
      );
    }

    icerik = (
      <div className="space-y-4">
        <div>
          <label htmlFor={`${alanId}-ara`} className={labelClass}>{t("birlestir.ara")}</label>
          <input
            id={`${alanId}-ara`}
            type="search"
            className={inputClass}
            placeholder={t("birlestir.araYer")}
            value={arama}
            onChange={(e) => setArama(e.target.value)}
          />
        </div>
        {sonucAlani}
        {hedef && (
          <p className="text-theme-sm text-gray-700 dark:text-gray-300">
            <span className="text-gray-500 dark:text-gray-400">{t("birlestir.secili")}: </span>
            <b className="text-gray-800 dark:text-white/90">{hedef.parent_name}</b>
          </p>
        )}
        <div>
          <button type="button" className={dangerBtn} disabled={!hedef} onClick={() => setOnayAcik(true)}>
            {t("birlestir.birlestirBtn")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <Kart baslik={t("birlestir.baslik")} aciklama={t("birlestir.aciklama")}>
      {icerik}
      {onayAcik && hedef && (
        <ModalShell isOpen onClose={() => setOnayAcik(false)} title={t("birlestir.onayBaslik")}>
          <div className="space-y-4">
            <p className="rounded-lg bg-error-50 px-3 py-2 text-theme-sm text-error-600 dark:bg-error-500/15 dark:text-error-500">
              {t("birlestir.uyari")}
            </p>
            <p className="text-theme-sm text-gray-700 dark:text-gray-300">
              <span className="text-gray-500 dark:text-gray-400">{t("birlestir.secili")}: </span>
              <b className="text-gray-800 dark:text-white/90">{hedef.parent_name}</b>
            </p>
            <AksiyonBildirim hata={onay.hata} basari={null} />
            <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
              <button type="button" className={outlineBtn} disabled={onay.busy} onClick={() => setOnayAcik(false)}>
                {t("vazgec")}
              </button>
              <button type="button" className={dangerBtn} disabled={onay.busy} onClick={birlestir}>
                {onay.busy ? t("kaydediliyor") : t("birlestir.onayBtn")}
              </button>
            </div>
          </div>
        </ModalShell>
      )}
    </Kart>
  );
}
