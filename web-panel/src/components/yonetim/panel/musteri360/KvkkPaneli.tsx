"use client";

import { useId, useState } from "react";
import { useTranslations } from "next-intl";

import ModalShell from "../ModalShell";
import { dangerBtn, labelClass, outlineBtn } from "../styles";
import { AksiyonBildirim, Kart, jsonIndir, metinAlaniClass, useAdminAksiyon, useYonetici } from "./aksiyon";

/** KVKK işlemleri: yalnız yönetici görür. Anonimleştirme geri alınamaz; onay modalı ile çalışır. */
export default function KvkkPaneli({ householdId, onChanged }: { householdId: string; onChanged: () => void }) {
  const yonetici = useYonetici();
  if (!yonetici) return null;
  return <KvkkIc householdId={householdId} onChanged={onChanged} />;
}

function KvkkIc({ householdId, onChanged }: { householdId: string; onChanged: () => void }) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const disa = useAdminAksiyon();
  const anon = useAdminAksiyon();
  const alanId = useId();
  const [onayAcik, setOnayAcik] = useState(false);
  const [neden, setNeden] = useState("");
  const [nedenHata, setNedenHata] = useState<string | null>(null);
  const [anonimlesti, setAnonimlesti] = useState(false);

  const verileriAktar = async () => {
    const sonuc = await disa.calistir("admin_growth_hane_disa_aktar", { p_household_id: householdId });
    if (!sonuc) return;
    const tarih = new Date().toISOString().slice(0, 10);
    jsonIndir(sonuc.data, `hane-veri-${householdId.slice(0, 8)}-${tarih}.json`);
    disa.setBasari(t("kvkk.aktarBasarili"));
  };

  const onayiAc = () => {
    anon.setHata(null);
    setNedenHata(null);
    setOnayAcik(true);
  };

  const anonimlestir = async () => {
    const metin = neden.trim();
    if (metin.length < 3 || metin.length > 500) {
      setNedenHata(t("kvkk.hataNeden"));
      return;
    }
    setNedenHata(null);
    const sonuc = await anon.calistir("admin_growth_hane_anonimlestir", {
      p_household_id: householdId,
      p_neden: metin,
    });
    if (!sonuc) return;
    setOnayAcik(false);
    setNeden("");
    setAnonimlesti(true);
    onChanged();
  };

  return (
    <Kart baslik={t("kvkk.baslik")} aciklama={t("kvkk.aciklama")}>
      <div className="space-y-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="min-w-0">
            <p className="font-medium text-gray-800 dark:text-white/90">{t("kvkk.aktar")}</p>
            <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("kvkk.aktarAciklama")}</p>
          </div>
          <button type="button" className={outlineBtn} disabled={disa.busy} onClick={verileriAktar}>
            {disa.busy ? t("yukleniyor") : t("kvkk.aktar")}
          </button>
        </div>

        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="min-w-0">
            <p className="font-medium text-gray-800 dark:text-white/90">{t("kvkk.anonim")}</p>
            <p className="text-theme-sm text-error-600 dark:text-error-500">{t("kvkk.anonimAciklama")}</p>
          </div>
          <button type="button" className={dangerBtn} onClick={onayiAc}>
            {t("kvkk.anonim")}
          </button>
        </div>

        <AksiyonBildirim hata={disa.hata} basari={disa.basari} />
        {anonimlesti && <AksiyonBildirim hata={null} basari={t("kvkk.basarili")} />}
      </div>

      {onayAcik && (
        <ModalShell isOpen onClose={() => setOnayAcik(false)} title={t("kvkk.onayBaslik")}>
          <div className="space-y-4">
            <p className="rounded-lg bg-error-50 px-3 py-2 text-theme-sm text-error-600 dark:bg-error-500/15 dark:text-error-500">
              {t("kvkk.uyari")}
            </p>
            <div>
              <label htmlFor={`${alanId}-neden`} className={labelClass}>{t("kvkk.neden")}</label>
              <textarea
                id={`${alanId}-neden`}
                rows={3}
                maxLength={500}
                className={metinAlaniClass}
                value={neden}
                disabled={anon.busy}
                onChange={(e) => setNeden(e.target.value)}
              />
            </div>
            <AksiyonBildirim hata={nedenHata ?? anon.hata} basari={null} />
            <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
              <button type="button" className={outlineBtn} disabled={anon.busy} onClick={() => setOnayAcik(false)}>
                {t("vazgec")}
              </button>
              <button type="button" className={dangerBtn} disabled={anon.busy} onClick={anonimlestir}>
                {anon.busy ? t("kaydediliyor") : t("kvkk.onayBtn")}
              </button>
            </div>
          </div>
        </ModalShell>
      )}
    </Kart>
  );
}
