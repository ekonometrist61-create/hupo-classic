"use client";

// Hikâye karnesi. min-N altında "gözlem yok" yazılır; sıfır sayılmaz (yetersiz veri ≠ 0).
import { useMemo, useState } from "react";
import { useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { yuzde } from "@/lib/okuma/okuma";
import { inputClass, labelClass } from "../panel/styles";
import { VeriDurumu } from "./ortak";
import { KARNE_ESIKLERI, type KarneSurumu, type KarneYaniti, type ListeYaniti } from "./tipler";

export default function KarneSekmesi() {
  const t = useTranslations("yonetim.hikayeAtolyesi.karne");
  const [hikayeId, setHikayeId] = useState("");
  const liste = useAdminRpc<ListeYaniti>("okuma_yonetim_liste", { p_durum: null, p_ana_sinif: null, p_limit: 200, p_offset: 0 });
  const karne = useAdminRpc<KarneYaniti>("okuma_hikaye_karnesi", { p_hikaye_id: hikayeId }, { enabled: hikayeId !== "" });

  const hikayeler = useMemo(() => {
    const harita = new Map<string, string>();
    for (const s of liste.data?.satirlar ?? []) if (!harita.has(s.hikaye_id)) harita.set(s.hikaye_id, s.baslik);
    return [...harita.entries()].sort((a, b) => a[1].localeCompare(b[1], "tr"));
  }, [liste.data]);

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>
      <p className="text-theme-xs text-gray-500 dark:text-gray-400">
        {t("esikNot", { tamamlama: KARNE_ESIKLERI.tamamlamaMin, anlama: KARNE_ESIKLERI.anlamaMin })}
      </p>
      <VeriDurumu loading={liste.loading} error={liste.error} missing={liste.missing} onRetry={liste.reload} />
      {!liste.loading && !liste.error && !liste.missing && (
        <>
          {hikayeler.length === 0 ? (
            <p className="text-sm text-gray-600 dark:text-gray-300">{t("hikayeYok")}</p>
          ) : (
            <div className="max-w-xl">
              <label className={labelClass} htmlFor="ha-karne-hikaye">{t("hikaye")}</label>
              <select id="ha-karne-hikaye" className={inputClass} value={hikayeId} onChange={(e) => setHikayeId(e.target.value)}>
                <option value="">{t("sec")}</option>
                {hikayeler.map(([id, baslik]) => (
                  <option key={id} value={id}>{baslik}</option>
                ))}
              </select>
            </div>
          )}
          {hikayeId && <VeriDurumu loading={karne.loading} error={karne.error} missing={karne.missing} onRetry={karne.reload} />}
          {hikayeId && karne.data && !karne.error && (
            <div className="space-y-4">
              {karne.data.surumler.map((s) => (
                <SurumKarnesi key={s.surum_id} s={s} />
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}

/** Uyarı rozeti: renge ek olarak simge ve metin taşır (yalnız renkle anlatılmaz). */
function UyariRozeti({ metin }: { metin: string }) {
  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-warning-50 px-2 py-0.5 text-theme-xs font-medium text-warning-700 dark:bg-warning-500/15 dark:text-warning-400">
      <svg aria-hidden="true" viewBox="0 0 16 16" className="size-3.5 shrink-0" fill="currentColor">
        <path d="M8 1.5 15 14H1L8 1.5Zm-.75 5v3.5h1.5V6.5h-1.5Zm0 4.5v1.5h1.5V11h-1.5Z" />
      </svg>
      {metin}
    </span>
  );
}

function Olcu({ etiket, deger, uyari }: { etiket: string; deger: string; uyari?: string | null }) {
  return (
    <div className={`rounded-lg border p-3 ${uyari ? "border-warning-300 dark:border-warning-500/50" : "border-gray-200 dark:border-gray-800"}`}>
      <p className="text-theme-xs text-gray-500 dark:text-gray-400">{etiket}</p>
      <p className="text-lg font-semibold text-gray-800 dark:text-white/90">{deger}</p>
      {uyari && <UyariRozeti metin={uyari} />}
    </div>
  );
}

/** Sürüm düzeyi anlama (doğruluk): yeterli sorularda cevap sayısıyla ağırlıklı doğru oranı; veri yoksa null. */
function surumDogrulugu(s: KarneSurumu): number | null {
  let cevap = 0;
  let dogru = 0;
  for (const q of s.sorular ?? []) {
    if (!q.yeterli || q.dogru_orani === null || q.dogru_orani === undefined || !q.cevap_sayisi) continue;
    cevap += q.cevap_sayisi;
    dogru += (q.dogru_orani * q.cevap_sayisi) / 100;
  }
  return cevap > 0 ? (dogru * 100) / cevap : null;
}

function SurumKarnesi({ s }: { s: KarneSurumu }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.karne");
  const td = useTranslations("yonetim.hikayeAtolyesi");
  const yok = t("gozlemYok");
  const dogruluk = s.yeterli ? surumDogrulugu(s) : null;
  const tamamlamaUyari =
    s.tamamlama_orani !== null && s.tamamlama_orani !== undefined && s.tamamlama_orani < KARNE_ESIKLERI.tamamlamaMin
      ? t("tamamlamaUyari", { esik: KARNE_ESIKLERI.tamamlamaMin })
      : null;
  const anlamaUyari = dogruluk !== null && dogruluk < KARNE_ESIKLERI.anlamaMin ? t("anlamaUyari", { esik: KARNE_ESIKLERI.anlamaMin }) : null;
  return (
    <section className="rounded-xl border border-gray-200 p-4 sm:p-5 dark:border-gray-800">
      <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">
        {td("detay.surum", { no: s.surum_no })} · {td(`durumlar.${s.durum}`)}
      </h4>
      {!s.yeterli ? (
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-300" role="status">
          {t("yetersiz", { baslatan: s.baslatan_ogrenci, min: s.min_n })}
        </p>
      ) : (
        <div className="mt-3 space-y-4">
          <div className="grid grid-cols-2 gap-3 md:grid-cols-3 lg:grid-cols-5">
            <Olcu etiket={t("baslatan")} deger={String(s.baslatan_ogrenci)} />
            <Olcu etiket={t("oturum")} deger={String(s.oturum_sayisi ?? 0)} />
            <Olcu etiket={t("tamamlama")} deger={yuzde(s.tamamlama_orani) ?? yok} uyari={tamamlamaUyari} />
            <Olcu etiket={t("anlama")} deger={yuzde(dogruluk) ?? yok} uyari={anlamaUyari} />
            <Olcu etiket={t("yildiz")} deger={s.ort_yildiz === null || s.ort_yildiz === undefined ? yok : `${s.ort_yildiz} / 5 (${s.oy_sayisi ?? 0})`} />
          </div>

          <div>
            <h5 className="mb-1 text-theme-sm font-semibold text-gray-700 dark:text-gray-300">{t("sorunKodlari")}</h5>
            {s.sorun_kodlari && Object.keys(s.sorun_kodlari).length > 0 ? (
              <ul className="flex flex-wrap gap-2 text-theme-sm">
                {Object.entries(s.sorun_kodlari).map(([kod, adet]) => (
                  <li key={kod} className="rounded-full bg-gray-100 px-3 py-1 text-gray-700 dark:bg-white/10 dark:text-gray-300">
                    {kod}: {adet}
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-theme-sm text-gray-600 dark:text-gray-300">{s.sorun_kodlari ? t("sorunYok") : yok}</p>
            )}
          </div>

          <div>
            <h5 className="mb-1 text-theme-sm font-semibold text-gray-700 dark:text-gray-300">{t("birakilan")}</h5>
            {s.birakilan_sayfa && Object.keys(s.birakilan_sayfa).length > 0 ? (
              <p className="text-theme-sm text-gray-700 dark:text-gray-300">
                {Object.entries(s.birakilan_sayfa)
                  .sort((a, b) => Number(a[0]) - Number(b[0]))
                  .map(([sayfa, adet]) => t("sayfaAdet", { sayfa, adet }))
                  .join(" · ")}
              </p>
            ) : (
              <p className="text-theme-sm text-gray-600 dark:text-gray-300">{yok}</p>
            )}
          </div>

          <div>
            <h5 className="mb-1 text-theme-sm font-semibold text-gray-700 dark:text-gray-300">{t("maddeAnalizi")}</h5>
            <div className="overflow-x-auto">
              <table className="min-w-full text-left text-theme-sm">
                <thead>
                  <tr className="text-theme-xs text-gray-500 dark:text-gray-400">
                    <th scope="col" className="py-1 pe-4 font-medium">{t("soru")}</th>
                    <th scope="col" className="py-1 pe-4 font-medium">{t("cevap")}</th>
                    <th scope="col" className="py-1 pe-4 font-medium">{t("dogruOrani")}</th>
                    <th scope="col" className="py-1 font-medium">{t("secenekler")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700 dark:divide-gray-800 dark:text-gray-300">
                  {(s.sorular ?? []).map((q) => (
                    <tr key={q.soru_id}>
                      <td className="py-2 pe-4 font-medium">{q.soru_id}</td>
                      {q.yeterli ? (
                        <>
                          <td className="py-2 pe-4">{q.cevap_sayisi ?? 0}</td>
                          <td className="py-2 pe-4">
                            {yuzde(q.dogru_orani) ?? yok}
                            {q.dogru_orani !== null && q.dogru_orani !== undefined && q.dogru_orani < KARNE_ESIKLERI.anlamaMin && (
                              <span className="ms-2 align-middle">
                                <UyariRozeti metin={t("soruUyari")} />
                              </span>
                            )}
                          </td>
                          <td className="py-2">
                            {q.secenek_dagilimi ? Object.entries(q.secenek_dagilimi).map(([k, v]) => `${k}: ${v}`).join(" · ") : yok}
                          </td>
                        </>
                      ) : (
                        <td colSpan={3} className="py-2 text-gray-600 dark:text-gray-300">{yok}</td>
                      )}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
