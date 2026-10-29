"use client";

import { useId, useState, type FormEvent, type ReactNode } from "react";
import { useTranslations } from "next-intl";

import { useAdminRpc } from "../../useAdminRpc";
import ErrorNote from "../ErrorNote";
import { inputClass, labelClass, primaryBtn } from "../styles";
import { AksiyonBildirim, Kart, useAdminAksiyon } from "./aksiyon";

type YoneticiSatiri = { id: string; ad: string | null; email: string | null };
type YoneticiListesi = { toplam: number; satirlar: YoneticiSatiri[] };

/** Hane sahibi atama. Yönetici listesi admin_list_users ile gelir; atama admin_growth_hane_sahip_ata ile yapılır. */
export default function SahipAta({
  householdId,
  mevcutSahip,
  onChanged,
}: {
  householdId: string;
  mevcutSahip: string | null;
  onChanged: () => void;
}) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const yoneticiler = useAdminRpc<YoneticiListesi>("admin_list_users", {
    p_rol: "admin",
    p_arama: null,
    p_limit: 100,
    p_offset: 0,
  });
  const { busy, hata, basari, setHata, setBasari, calistir } = useAdminAksiyon();
  const alanId = useId();
  const [secili, setSecili] = useState("");
  const satirlar = yoneticiler.data?.satirlar ?? [];

  const gonder = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!secili) {
      setBasari(null);
      setHata(t("sahip.hataSec"));
      return;
    }
    const sonuc = await calistir("admin_growth_hane_sahip_ata", {
      p_household_id: householdId,
      p_owner_id: secili,
    });
    if (!sonuc) return;
    setSecili("");
    setBasari(t("sahip.basarili"));
    onChanged();
  };

  let icerik: ReactNode;
  if (yoneticiler.loading) {
    icerik = <p className="py-4 text-theme-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>;
  } else if (yoneticiler.error) {
    icerik = <ErrorNote message={yoneticiler.missing ? t("hata.eksik") : `${t("hata.genel")} ${yoneticiler.error}`} />;
  } else if (satirlar.length === 0) {
    icerik = <p className="py-4 text-theme-sm text-gray-500 dark:text-gray-400">{t("sahip.bos")}</p>;
  } else {
    icerik = (
      <form onSubmit={gonder} noValidate className="space-y-4">
        <div>
          <label htmlFor={`${alanId}-sahip`} className={labelClass}>{t("sahip.sec")}</label>
          <select
            id={`${alanId}-sahip`}
            className={inputClass}
            value={secili}
            disabled={busy}
            onChange={(e) => setSecili(e.target.value)}
          >
            <option value="">{t("sahip.secim")}</option>
            {satirlar.map((s) => (
              <option key={s.id} value={s.id}>{s.ad ?? s.email ?? s.id}</option>
            ))}
          </select>
        </div>
        <AksiyonBildirim hata={hata} basari={basari} />
        <div>
          <button type="submit" className={primaryBtn} disabled={busy}>
            {busy ? t("kaydediliyor") : t("sahip.kaydet")}
          </button>
        </div>
      </form>
    );
  }

  return (
    <Kart baslik={t("sahip.baslik")}>
      <p className="mb-4 text-theme-sm text-gray-700 dark:text-gray-300">
        <span className="text-gray-500 dark:text-gray-400">{t("sahip.mevcut")}: </span>
        {mevcutSahip ?? t("sahip.yok")}
      </p>
      {icerik}
    </Kart>
  );
}
