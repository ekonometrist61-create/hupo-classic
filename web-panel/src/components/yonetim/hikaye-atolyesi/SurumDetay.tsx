"use client";

// Seçili sürümün denetimi, durum akışı ve önizlemesi.
// Dört göz ve yayın kapısı sunucuda zorlanır; burada yalnızca gösterilir, hata nazikçe iletilir.
import { useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import type { DenetimDurumu, OkumaDurum } from "@/lib/okuma/okuma";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni, VeriDurumu } from "./ortak";
import SurumOnizleme from "./SurumOnizleme";
import type { IcerikYaniti, SurumSatiri } from "./tipler";

const AJAN_DEGERLERI = ["pending", "pass", "fail", "review_needed"] as const;
const INSAN_DEGERLERI = ["pending", "approved", "rejected"] as const;

// Sözleşmedeki geçiş tablosu.
const GECISLER: Record<OkumaDurum, OkumaDurum[]> = {
  taslak: ["incelemede", "arsiv"],
  incelemede: ["taslak", "yayinda", "arsiv"],
  yayinda: ["arsiv"],
  arsiv: ["taslak"],
};

const kisalt = (id: string | null) => (id ? id.slice(0, 8) : "-");

interface Props {
  satir: SurumSatiri;
  onKapat: () => void;
  /** Durum/denetim değişince liste yenilensin. */
  onDegisti: () => void;
}

export default function SurumDetay({ satir, onKapat, onDegisti }: Props) {
  const t = useTranslations("yonetim.hikayeAtolyesi");
  const hata = useHataMetni();
  const icerik = useAdminRpc<IcerikYaniti>("okuma_surum_icerik_getir", { p_surum_id: satir.surum_id });
  const [islemde, setIslemde] = useState(false);
  const [mesaj, setMesaj] = useState<string | null>(null);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);
  // Denetim taslağı: kullanıcı değiştirene kadar sunucudaki değer gösterilir.
  const [duzenleme, setDuzenleme] = useState<DenetimDurumu | null>(null);

  const sunucuDenetim: DenetimDurumu = icerik.data?.denetim ?? satir.denetim ?? {};
  const denetim: DenetimDurumu = { ajan_a: "pending", ajan_b: "pending", insan: "pending", ...sunucuDenetim, ...(duzenleme ?? {}) };
  const durum: OkumaDurum = icerik.data?.durum ?? satir.durum;
  const denetimDuzenlenebilir = durum === "taslak" || durum === "incelemede";
  const yayinaHazir = denetim.ajan_a === "pass" && denetim.ajan_b === "pass" && denetim.insan === "approved";

  const calistir = async (hedef: OkumaDurum, denetimGonder: DenetimDurumu | null, basari: string) => {
    setIslemde(true);
    setMesaj(null);
    setHataMesaji(null);
    const { error } = await adminCall("okuma_surum_durum_degistir", {
      p_surum_id: satir.surum_id,
      p_durum: hedef,
      p_denetim: denetimGonder,
    });
    setIslemde(false);
    if (error) {
      setHataMesaji(hata(error));
      return;
    }
    setMesaj(basari);
    setDuzenleme(null);
    icerik.reload();
    onDegisti();
  };

  const denetimiKaydet = () => {
    const govde: DenetimDurumu = { ajan_a: denetim.ajan_a, ajan_b: denetim.ajan_b, insan: denetim.insan };
    void calistir(durum, govde, t("detay.denetimKaydedildi"));
  };

  const gec = (hedef: OkumaDurum) => {
    // Yayın öğrencilere görünür olabilir (bayrak açıksa) ve değişmez; onay istenir.
    if (hedef === "yayinda" && !window.confirm(t("detay.yayinOnay", { baslik: satir.baslik }))) return;
    if (hedef === "arsiv" && durum === "yayinda" && !window.confirm(t("detay.arsivOnay"))) return;
    void calistir(hedef, null, t("detay.durumDegisti", { durum: t(`durumlar.${hedef}`) }));
  };

  return (
    <section aria-label={t("detay.baslik", { baslik: satir.baslik })} className="mt-6 rounded-2xl border border-brand-200 p-5 sm:p-6 dark:border-brand-800">
      <div className="mb-4 flex flex-wrap items-start justify-between gap-3">
        <div className="min-w-0">
          <h4 className="text-base font-semibold wrap-break-word text-gray-800 dark:text-white/90">{satir.baslik}</h4>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">
            {satir.slug} · {t("detay.surum", { no: satir.surum_no })} · {t(`durumlar.${durum}`)}
          </p>
        </div>
        <button type="button" className={outlineBtn} onClick={onKapat}>
          {t("detay.kapat")}
        </button>
      </div>

      <VeriDurumu loading={icerik.loading} error={icerik.error} missing={icerik.missing} onRetry={icerik.reload} />

      {!icerik.loading && !icerik.error && !icerik.missing && icerik.data && (
        <div className="space-y-6">
          {/* Denetim */}
          <div>
            <h5 className="mb-1 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("detay.denetimBaslik")}</h5>
            <p className="mb-3 text-theme-xs text-gray-500 dark:text-gray-400">
              {t("detay.dortGoz", { olusturan: kisalt(icerik.data.olusturan_id), inceleyen: kisalt(icerik.data.inceleyen_id) })}
            </p>
            <div className="grid gap-3 sm:grid-cols-3">
              {(["ajan_a", "ajan_b", "insan"] as const).map((anahtar) => (
                <div key={anahtar}>
                  <label className={labelClass} htmlFor={`denetim-${anahtar}`}>
                    {t(`denetim.${anahtar}`)}
                  </label>
                  <select
                    id={`denetim-${anahtar}`}
                    className={inputClass}
                    value={denetim[anahtar] ?? "pending"}
                    disabled={!denetimDuzenlenebilir || islemde}
                    onChange={(e) => setDuzenleme((d) => ({ ...(d ?? {}), [anahtar]: e.target.value }) as DenetimDurumu)}
                  >
                    {(anahtar === "insan" ? INSAN_DEGERLERI : AJAN_DEGERLERI).map((d) => (
                      <option key={d} value={d}>
                        {t(`denetimDegerleri.${d}`)}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
            <p className="mt-3 text-sm text-gray-700 dark:text-gray-300" role="status">
              {yayinaHazir ? t("detay.yayinaHazir") : t("detay.yayinaHazirDegil")}
            </p>
            {denetimDuzenlenebilir ? (
              <div className="mt-3">
                <button type="button" className={outlineBtn} disabled={islemde || duzenleme === null} onClick={denetimiKaydet}>
                  {t("detay.denetimiKaydet")}
                </button>
              </div>
            ) : (
              <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("detay.denetimKilitli")}</p>
            )}
          </div>

          {/* Durum akışı */}
          <div>
            <h5 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("detay.durumBaslik")}</h5>
            <div className="flex flex-wrap gap-3">
              {GECISLER[durum].map((hedef) => (
                <button
                  key={hedef}
                  type="button"
                  className={hedef === "yayinda" ? primaryBtn : outlineBtn}
                  disabled={islemde || (hedef === "yayinda" && duzenleme !== null)}
                  onClick={() => gec(hedef)}
                >
                  {t(`gecis.${durum}.${hedef}`)}
                </button>
              ))}
            </div>
            {durum === "incelemede" && duzenleme !== null && (
              <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("detay.onceKaydet")}</p>
            )}
            <div aria-live="polite" className="mt-3 space-y-2">
              {mesaj && <p className="text-sm text-success-700 dark:text-success-400">{mesaj}</p>}
              <ErrorNote message={hataMesaji} />
            </div>
          </div>

          {/* Önizleme */}
          <details className="group">
            <summary className="min-h-11 cursor-pointer text-sm font-semibold text-gray-700 dark:text-gray-300">
              {t("detay.onizlemeBaslik")}
            </summary>
            <div className="mt-3">
              <SurumOnizleme paket={icerik.data.paket} />
            </div>
          </details>
        </div>
      )}
    </section>
  );
}
