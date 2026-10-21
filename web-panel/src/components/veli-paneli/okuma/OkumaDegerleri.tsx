"use client";

// Veli: değer önceliği. Yasak değil, öneri önceliğidir; yalnız hikâye sıralamasını etkiler. Rıza gerekmez.
import { useState } from "react";
import { useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { hataAnahtari, type DegerKalemi } from "@/lib/okuma/okuma";
import { createClient } from "@/utils/supabase/client";
import { CATI_DEGERLER } from "./okumaTipleri";

const EN_FAZLA = 5;

export default function OkumaDegerleri({ cocukId }: { cocukId: string }) {
  const t = useTranslations("veliPaneli.okuma.degerler");
  const liste = useAdminRpc<DegerKalemi[]>("okuma_degerleri_listele");
  const mevcut = useAdminRpc<{ degerler: string[] }>("okuma_veli_degerleri_getir", { p_cocuk_id: cocukId });

  const yukleniyor = liste.loading || mevcut.loading;
  const eksik = liste.missing || mevcut.missing;
  const hata = liste.error ?? mevcut.error;

  return (
    <section aria-labelledby="okuma-deger-b" className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 id="okuma-deger-b" className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h3>
      <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>
      <p className="mt-2 rounded-lg bg-gray-50 px-3 py-2 text-theme-sm text-gray-700 dark:bg-white/5 dark:text-gray-300">{t("yasakDegil")}</p>

      {yukleniyor && <p role="status" className="py-6 text-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>}
      {!yukleniyor && eksik && <p role="status" className="py-4 text-sm text-gray-600 dark:text-gray-300">{t("kapali")}</p>}
      {!yukleniyor && !eksik && hata && (
        <div className="py-4">
          <p role="alert" className="text-sm text-error-600 dark:text-error-500">{t("hata")}</p>
          <button
            type="button"
            className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400"
            onClick={() => {
              liste.reload();
              mevcut.reload();
            }}
          >
            {t("tekrar")}
          </button>
        </div>
      )}
      {!yukleniyor && !eksik && !hata && liste.data && mevcut.data && (
        <DegerSecici cocukId={cocukId} kalemler={liste.data} baslangic={mevcut.data.degerler ?? []} />
      )}
    </section>
  );
}

function DegerSecici({ cocukId, kalemler, baslangic }: { cocukId: string; kalemler: DegerKalemi[]; baslangic: string[] }) {
  const t = useTranslations("veliPaneli.okuma.degerler");
  const [secili, setSecili] = useState<string[]>(baslangic);
  const [kayitli, setKayitli] = useState<string[]>(baslangic);
  const [islemde, setIslemde] = useState(false);
  const [mesaj, setMesaj] = useState<{ tur: "ok" | "hata"; metin: string } | null>(null);

  const degisti = secili.length !== kayitli.length || secili.some((d, i) => d !== kayitli[i]);

  const degistir = (kod: string, acik: boolean) => {
    setMesaj(null);
    setSecili((s) => (acik ? (s.length < EN_FAZLA ? [...s, kod] : s) : s.filter((x) => x !== kod)));
  };

  const kaydet = async () => {
    setIslemde(true);
    setMesaj(null);
    const { data, error } = await createClient().rpc("okuma_veli_degerleri_ayarla", { p_cocuk_id: cocukId, p_degerler: secili });
    setIslemde(false);
    if (error) {
      const k = hataAnahtari(error.message);
      setMesaj({ tur: "hata", metin: ["EN_FAZLA_BES", "TEKRARLI_DEGER", "GECERSIZ_DEGER", "FORBIDDEN"].includes(k) ? t(`hatalar.${k}`) : t("hatalar.genel") });
      return;
    }
    const yeni = (data as { degerler?: string[] } | null)?.degerler ?? secili;
    setSecili(yeni);
    setKayitli(yeni);
    setMesaj({ tur: "ok", metin: t("kaydedildi") });
  };

  return (
    <div className="mt-4">
      <fieldset>
        <legend className="text-sm font-medium text-gray-700 dark:text-gray-300">
          {t("secimSayisi", { sayi: secili.length, enFazla: EN_FAZLA })}
        </legend>
        <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("catiNot")}</p>
        <ul className="mt-3 grid gap-2 sm:grid-cols-2 lg:grid-cols-4">
          {kalemler.map((d) => {
            const acik = secili.includes(d.kod);
            const dolu = !acik && secili.length >= EN_FAZLA;
            const cati = (CATI_DEGERLER as readonly string[]).includes(d.kod);
            return (
              <li key={d.kod}>
                <label
                  className={`flex min-h-11 items-center gap-2 rounded-lg px-3 py-2 text-sm ring-1 ring-inset transition ${
                    acik
                      ? "bg-brand-50 text-brand-800 ring-brand-500 dark:bg-brand-500/15 dark:text-brand-200"
                      : cati
                        ? "text-gray-800 ring-gray-400 dark:text-gray-200 dark:ring-gray-500"
                        : "text-gray-700 ring-gray-300 dark:text-gray-300 dark:ring-gray-700"
                  } ${dolu ? "cursor-not-allowed opacity-50" : "cursor-pointer"}`}
                >
                  <input
                    type="checkbox"
                    className="size-4 shrink-0"
                    checked={acik}
                    disabled={dolu || islemde}
                    onChange={(e) => degistir(d.kod, e.target.checked)}
                  />
                  <span className="min-w-0 wrap-break-word">
                    {d.ad}
                    {cati && <span className="ml-1 text-theme-xs font-medium text-gray-600 dark:text-gray-400">({t("cati")})</span>}
                    {acik && <span className="ml-1 text-theme-xs font-semibold">· {secili.indexOf(d.kod) + 1}</span>}
                  </span>
                </label>
              </li>
            );
          })}
        </ul>
      </fieldset>

      <div className="mt-4 flex flex-wrap items-center gap-3">
        <button
          type="button"
          onClick={() => void kaydet()}
          disabled={!degisti || islemde}
          className="inline-flex min-h-11 items-center justify-center rounded-lg bg-brand-500 px-4 text-sm font-medium text-white shadow-theme-xs transition hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {islemde ? t("kaydediliyor") : t("kaydet")}
        </button>
        <div aria-live="polite">
          {mesaj && (
            <p className={`text-sm ${mesaj.tur === "ok" ? "text-success-700 dark:text-success-400" : "text-error-600 dark:text-error-500"}`}>{mesaj.metin}</p>
          )}
        </div>
      </div>
    </div>
  );
}
