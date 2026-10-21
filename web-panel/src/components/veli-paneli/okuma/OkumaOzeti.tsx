"use client";

// Veli: çocuğun okuma özeti. Rıza kapısı sunucudadır; `riza:false` yanıtı kilitli kart olarak gösterilir.
// Öğrenme göstergesi soru doğruluğudur (işlem türüne göre); okuma süresi yalnız bilgidir. Cinsiyet kırılımı yoktur.
import { useState } from "react";
import { useLocale, useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { Link } from "@/i18n/navigation";
import { BECERILER } from "@/lib/okuma/okuma";
import ConsentCard from "../ConsentCard";
import { HEDEF_DURUMLARI, type DagilimKalemi, type OkumaOzet, type OkumaOzetYaniti } from "./okumaTipleri";

const DONEMLER = [7, 30, 90] as const;

export default function OkumaOzeti({ cocukId }: { cocukId: string }) {
  const t = useTranslations("veliPaneli.okuma");
  const [gun, setGun] = useState<number>(30);
  const veri = useAdminRpc<OkumaOzetYaniti>("okuma_veli_ozeti", { p_cocuk_id: cocukId, p_gun: gun });

  return (
    <section aria-labelledby="okuma-ozet-b" className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <h3 id="okuma-ozet-b" className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("ozet.baslik")}</h3>
        <div className="flex items-center gap-2">
          <label htmlFor="okuma-donem" className="text-sm text-gray-600 dark:text-gray-300">{t("ozet.donem")}</label>
          <select
            id="okuma-donem"
            value={gun}
            onChange={(e) => setGun(Number(e.target.value))}
            className="min-h-11 rounded-lg border border-gray-300 bg-transparent px-3 text-base text-gray-800 focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden md:text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white/90"
          >
            {DONEMLER.map((d) => (
              <option key={d} value={d}>{t("ozet.sonGun", { gun: d })}</option>
            ))}
          </select>
        </div>
      </div>

      {veri.loading && <p role="status" className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">{t("ozet.yukleniyor")}</p>}

      {!veri.loading && veri.missing && <p role="status" className="py-6 text-sm text-gray-600 dark:text-gray-300">{t("ozet.kapali")}</p>}

      {!veri.loading && !veri.missing && veri.error && (
        <div className="py-4">
          <p role="alert" className="text-sm text-error-600 dark:text-error-500">
            {/FORBIDDEN/.test(veri.error) ? t("ozet.yetkisiz") : t("ozet.hata")}
          </p>
          <button
            type="button"
            className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400"
            onClick={veri.reload}
          >
            {t("ozet.tekrar")}
          </button>
        </div>
      )}

      {!veri.loading && veri.data && !veri.error && !veri.data.riza && (
        <div className="space-y-4">
          <div className="rounded-xl border border-warning-200 bg-warning-50 p-4 dark:border-warning-500/30 dark:bg-warning-500/10">
            <h4 className="text-sm font-semibold text-warning-800 dark:text-warning-300">{t("ozet.rizaBaslik")}</h4>
            <p className="mt-1 text-sm text-warning-800 dark:text-warning-300">
              {veri.data.riza_durumu === "geri_cekildi" ? t("ozet.rizaGeriCekildi") : t("ozet.rizaYok")}
            </p>
            <button
              type="button"
              onClick={veri.reload}
              className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-warning-800 underline dark:text-warning-300"
            >
              {t("ozet.yenile")}
            </button>
          </div>
          <ConsentCard studentId={cocukId} />
        </div>
      )}

      {!veri.loading && veri.data?.riza && veri.data.ozet && !veri.error && <OzetGovdesi ozet={veri.data.ozet} />}
    </section>
  );
}

function Olcu({ etiket, deger, not }: { etiket: string; deger: string; not?: string }) {
  return (
    <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
      <p className="text-xs text-gray-600 dark:text-gray-400">{etiket}</p>
      <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{deger}</p>
      {not && <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{not}</p>}
    </div>
  );
}

function Alt({ baslik, children, aciklama }: { baslik: string; children: React.ReactNode; aciklama?: string }) {
  return (
    <div>
      <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{baslik}</h4>
      {aciklama && <p className="mt-0.5 mb-2 text-theme-xs text-gray-600 dark:text-gray-400">{aciklama}</p>}
      <div className={aciklama ? "" : "mt-2"}>{children}</div>
    </div>
  );
}

function OzetGovdesi({ ozet }: { ozet: OkumaOzet }) {
  const t = useTranslations("veliPaneli.okuma");
  const locale = useLocale();

  return (
    <div className="space-y-6">
      <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("ozet.aralik", { gun: ozet.gun })}</p>

      <div className="grid grid-cols-2 gap-3">
        <Olcu etiket={t("ozet.okunan")} deger={String(ozet.okunan_hikaye)} />
        <Olcu etiket={t("ozet.tamamlanan")} deger={String(ozet.tamamlanan_hikaye)} />
      </div>

      {ozet.okunan_hikaye === 0 && <p className="text-sm text-gray-600 dark:text-gray-300">{t("ozet.bosDonem")}</p>}

      {!ozet.detay && (
        <div className="rounded-xl border border-gray-200 bg-gray-50 p-4 dark:border-gray-800 dark:bg-white/5">
          <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">{t("premium.baslik")}</h4>
          <p className="mt-1 text-sm text-gray-700 dark:text-gray-300">{t("premium.metin")}</p>
          <Link href="/veli-paneli/uyelik" className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400">
            {t("premium.baglanti")}
          </Link>
        </div>
      )}

      {ozet.detay && (
        <>
          <Alt baslik={t("dogruluk.baslik")} aciklama={t("dogruluk.aciklama")}>
            <ul className="space-y-3">
              {BECERILER.map((b) => {
                const d = ozet.soru_dogrulugu?.[b];
                const yeterli = !!d?.yeterli && d.oran !== undefined;
                return (
                  <li key={b}>
                    <div className="flex flex-wrap items-baseline justify-between gap-x-3 text-sm">
                      <span className="font-medium text-gray-800 dark:text-gray-100">{t(`beceri.${b}`)}</span>
                      <span className="text-gray-700 dark:text-gray-300">
                        {yeterli ? t("dogruluk.deger", { oran: d.oran ?? 0, dogru: d.dogru ?? 0, soru: d.soru ?? 0 }) : t("dogruluk.yetersiz")}
                      </span>
                    </div>
                    {yeterli && (
                      <div className="mt-1 h-2 rounded-full bg-gray-100 dark:bg-white/10" aria-hidden="true">
                        <div className="h-2 rounded-full bg-brand-500" style={{ width: `${Math.min(100, Math.max(0, d.oran ?? 0))}%` }} />
                      </div>
                    )}
                  </li>
                );
              })}
            </ul>
            <p className="mt-3 text-theme-xs text-gray-600 dark:text-gray-400">{t("dogruluk.not")}</p>
          </Alt>

          <div className="grid gap-6 md:grid-cols-2">
            <Dagilim baslik={t("tema.baslik")} bos={t("tema.bos")} kalemler={ozet.tema_dagilimi} adAl={(k) => k.ad ?? k.tema ?? ""} />
            <Dagilim baslik={t("deger.baslik")} bos={t("deger.bos")} kalemler={ozet.deger_dagilimi} adAl={(k) => k.ad ?? k.deger ?? ""} />
            <Dagilim baslik={t("ders.baslik")} bos={t("ders.bos")} kalemler={ozet.ders_dagilimi} adAl={(k) => k.ad ?? k.ders ?? ""} />
          </div>

          <Alt baslik={t("hedefler.baslik")} aciklama={t("hedefler.aciklama")}>
            {Object.keys(ozet.hedef_durumlari ?? {}).length === 0 ? (
              <p className="text-sm text-gray-600 dark:text-gray-300">{t("hedefler.bos")}</p>
            ) : (
              <ul className="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
                {HEDEF_DURUMLARI.filter((d) => (ozet.hedef_durumlari?.[d] ?? 0) > 0).map((d) => (
                  <li key={d} className="flex items-baseline justify-between gap-3 rounded-lg border border-gray-200 px-3 py-2 text-sm dark:border-gray-800">
                    <span className="text-gray-700 dark:text-gray-300">{t(`hedefDurum.${d}`)}</span>
                    <span className="font-semibold text-gray-800 dark:text-white/90">{ozet.hedef_durumlari?.[d]}</span>
                  </li>
                ))}
              </ul>
            )}
            {(ozet.pekisen_hedefler?.length ?? 0) > 0 && (
              <div className="mt-3">
                <p className="text-theme-xs font-medium text-gray-700 dark:text-gray-300">{t("hedefler.pekisen")}</p>
                <ul className="mt-1 list-disc space-y-0.5 pl-5 text-sm wrap-break-word text-gray-700 dark:text-gray-300">
                  {ozet.pekisen_hedefler?.map((h) => (
                    <li key={h.hedef_id}>
                      {h.etiket} <span className="text-theme-xs text-gray-600 dark:text-gray-400">({t(`hedefDurum.${h.durum}`)})</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </Alt>

          <Alt baslik={t("zorluk.baslik")} aciklama={t("zorluk.aciklama")}>
            {(ozet.zorluk_seyri?.length ?? 0) === 0 ? (
              <p className="text-sm text-gray-600 dark:text-gray-300">{t("zorluk.bos")}</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full text-left text-sm">
                  <thead>
                    <tr className="text-theme-xs text-gray-600 dark:text-gray-400">
                      <th scope="col" className="py-1 pe-4 font-medium">{t("zorluk.hafta")}</th>
                      <th scope="col" className="py-1 pe-4 font-medium">{t("zorluk.hikaye")}</th>
                      <th scope="col" className="py-1 pe-4 font-medium">{t("zorluk.okuma")}</th>
                      <th scope="col" className="py-1 font-medium">{t("zorluk.kavram")}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 text-gray-700 dark:divide-gray-800 dark:text-gray-300">
                    {ozet.zorluk_seyri?.map((z) => (
                      <tr key={z.hafta}>
                        <td className="py-2 pe-4">{new Intl.DateTimeFormat(locale === "en" ? "en-US" : "tr-TR", { day: "numeric", month: "short" }).format(new Date(z.hafta))}</td>
                        <td className="py-2 pe-4">{z.hikaye}</td>
                        <td className="py-2 pe-4">{z.ort_okuma_zorlugu ?? "-"}</td>
                        <td className="py-2">{z.ort_kavram_zorlugu ?? "-"}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Alt>

          <div className="grid gap-3 sm:grid-cols-2">
            <Olcu
              etiket={t("sure.baslik")}
              deger={ozet.ortalama_sure_dk === null || ozet.ortalama_sure_dk === undefined ? t("sure.yok") : t("sure.deger", { dk: ozet.ortalama_sure_dk })}
              not={t("sure.not")}
            />
            <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
              <p className="text-xs text-gray-600 dark:text-gray-400">{t("puan.baslik")}</p>
              {ozet.cocuk_puani && ozet.cocuk_puani.ortalama !== null ? (
                <>
                  <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{t("puan.deger", { ort: ozet.cocuk_puani.ortalama, oy: ozet.cocuk_puani.oy })}</p>
                  {ozet.cocuk_puani.sevilen_temalar.length > 0 && (
                    <p className="mt-1 text-theme-xs wrap-break-word text-gray-600 dark:text-gray-400">{t("puan.sevilen", { temalar: ozet.cocuk_puani.sevilen_temalar.join(", ") })}</p>
                  )}
                </>
              ) : (
                <p className="mt-1 text-sm text-gray-700 dark:text-gray-300">{t("puan.yetersiz")}</p>
              )}
            </div>
          </div>
        </>
      )}

      <details className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
        <summary className="min-h-11 cursor-pointer text-sm font-semibold text-gray-800 dark:text-gray-100">{t("nasil.baslik")}</summary>
        <ul className="mt-2 list-disc space-y-1.5 pl-5 text-sm text-gray-700 dark:text-gray-300">
          {(["oran", "minN", "ogrenme", "zaman", "cinsiyet"] as const).map((k) => (
            <li key={k}>{t(`nasil.${k}`)}</li>
          ))}
        </ul>
      </details>
    </div>
  );
}

function Dagilim({ baslik, bos, kalemler, adAl }: { baslik: string; bos: string; kalemler: DagilimKalemi[] | undefined; adAl: (k: DagilimKalemi) => string }) {
  const t = useTranslations("veliPaneli.okuma");
  const liste = kalemler ?? [];
  const en = Math.max(1, ...liste.map((k) => k.hikaye));
  return (
    <Alt baslik={baslik}>
      {liste.length === 0 ? (
        <p className="text-sm text-gray-600 dark:text-gray-300">{bos}</p>
      ) : (
        <ul className="space-y-2">
          {liste.slice(0, 6).map((k) => (
            <li key={adAl(k)}>
              <div className="flex items-baseline justify-between gap-3 text-sm">
                <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">{adAl(k)}</span>
                <span className="shrink-0 text-gray-700 dark:text-gray-300">{t("hikayeAdedi", { sayi: k.hikaye })}</span>
              </div>
              <div className="mt-1 h-1.5 rounded-full bg-gray-100 dark:bg-white/10" aria-hidden="true">
                <div className="h-1.5 rounded-full bg-brand-500" style={{ width: `${(k.hikaye / en) * 100}%` }} />
              </div>
            </li>
          ))}
        </ul>
      )}
    </Alt>
  );
}
