"use client";

// İçerik boşluğu ısı haritası: sınıf × tema × değer. Yalnız dolu hücreler gelir; boşlukları panel hesaplar.
// Renk tek taşıyıcı değildir: her hücrede sayı, boş hücrede "0" ve ekran okuyucu metni vardır.
import { useMemo, useState } from "react";
import { useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import type { DegerKalemi } from "@/lib/okuma/okuma";
import { inputClass, labelClass } from "../panel/styles";
import { VeriDurumu } from "./ortak";
import type { BoslukYaniti } from "./tipler";

export default function BoslukHaritasi() {
  const t = useTranslations("yonetim.hikayeAtolyesi.bosluk");
  const veri = useAdminRpc<BoslukYaniti>("okuma_icerik_bosluk_haritasi");
  const adlar = useAdminRpc<DegerKalemi[]>("okuma_degerleri_listele");
  const [sinif, setSinif] = useState(4);

  const harita = useMemo(() => {
    const m = new Map<string, { yayinda: number; incelemede: number }>();
    for (const h of veri.data?.hucreler ?? []) {
      if (h.ana_sinif === sinif) m.set(`${h.tema}|${h.deger}`, { yayinda: h.yayinda, incelemede: h.incelemede });
    }
    return m;
  }, [veri.data, sinif]);

  const deger_ad = useMemo(() => new Map((adlar.data ?? []).map((d) => [d.kod, d.ad])), [adlar.data]);
  const temalar = veri.data?.temalar ?? [];
  const degerler = veri.data?.degerler ?? [];
  const toplamHucre = temalar.length * degerler.length;
  const bos = toplamHucre - [...harita.values()].filter((h) => h.yayinda > 0).length;

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>
      <VeriDurumu loading={veri.loading} error={veri.error} missing={veri.missing} onRetry={veri.reload} />
      {veri.data && !veri.error && (
        <>
          <div className="max-w-48">
            <label className={labelClass} htmlFor="ha-bosluk-sinif">{t("sinif")}</label>
            <select id="ha-bosluk-sinif" className={inputClass} value={sinif} onChange={(e) => setSinif(Number(e.target.value))}>
              {(veri.data.siniflar.length ? veri.data.siniflar : [1, 2, 3, 4, 5, 6, 7, 8]).map((n) => (
                <option key={n} value={n}>{t("sinifDeger", { n })}</option>
              ))}
            </select>
          </div>

          {toplamHucre === 0 ? (
            <p className="text-sm text-gray-600 dark:text-gray-300">{t("sozlukBos")}</p>
          ) : (
            <>
              <p className="text-sm text-gray-700 dark:text-gray-300" aria-live="polite">
                {t("ozet", { bos, toplam: toplamHucre })}
              </p>
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("okuma")}</p>
              <div className="relative overflow-x-auto rounded-xl border border-gray-200 dark:border-gray-800">
                <table className="min-w-full border-collapse text-center text-theme-xs">
                  <caption className="sr-only">{t("tabloBaslik", { n: sinif })}</caption>
                  <thead>
                    <tr>
                      <th scope="col" className="sticky inset-s-0 z-1 bg-white px-3 py-2 text-start font-semibold text-gray-600 dark:bg-gray-900 dark:text-gray-300">
                        {t("temaDeger")}
                      </th>
                      {degerler.map((d) => (
                        <th key={d} scope="col" className="px-2 py-2 font-semibold whitespace-nowrap text-gray-600 dark:text-gray-300" title={deger_ad.get(d) ?? d}>
                          {d}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {temalar.map((tm) => (
                      <tr key={tm} className="border-t border-gray-100 dark:border-gray-800">
                        <th scope="row" className="sticky inset-s-0 z-1 bg-white px-3 py-2 text-start font-medium whitespace-nowrap text-gray-700 dark:bg-gray-900 dark:text-gray-300">
                          {tm}
                        </th>
                        {degerler.map((d) => {
                          const h = harita.get(`${tm}|${d}`);
                          const y = h?.yayinda ?? 0;
                          const i = h?.incelemede ?? 0;
                          const durum = y > 0 ? "dolu" : i > 0 ? "yolda" : "bos";
                          const stil =
                            durum === "dolu"
                              ? "bg-success-50 text-success-800 dark:bg-success-500/15 dark:text-success-300"
                              : durum === "yolda"
                                ? "bg-warning-50 text-warning-800 dark:bg-warning-500/15 dark:text-warning-300"
                                : "bg-error-50 text-error-800 dark:bg-error-500/15 dark:text-error-300";
                          return (
                            <td key={d} className={`min-w-11 px-2 py-2 font-medium ${stil}`}>
                              <span aria-hidden="true">{y}{i > 0 ? `+${i}` : ""}</span>
                              <span className="sr-only">{t(`hucre.${durum}`, { tema: tm, deger: deger_ad.get(d) ?? d, yayinda: y, incelemede: i })}</span>
                            </td>
                          );
                        })}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </>
      )}
    </div>
  );
}
