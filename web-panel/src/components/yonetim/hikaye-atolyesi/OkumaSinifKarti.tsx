"use client";

// Öğretmen sınıf raporuna okuma kartı: sınıf düzeyinde toplulaştırma, çocuk adı/kimliği yok.
// Asgari 3 öğrenci altında değer gösterilmez ("gözlem yok"); sıfır sayılmaz.
import { useState } from "react";
import { useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { BECERILER } from "@/lib/okuma/okuma";
import { cardClass, inputClass, labelClass } from "../panel/styles";

interface Ozet {
  sinif: { id: string; ad: string; sinif_seviyesi: number };
  gun: number;
  ogrenci_sayisi: number;
  okuyan_ogrenci: number;
  yeterli: boolean;
  min_n: number;
  ozet: null | {
    oturum_sayisi: number;
    tamamlama_orani: number | null;
    soru_dogrulugu: Record<string, { yeterli: boolean; soru?: number; oran?: number }>;
    zorlanilan_hedefler: { hedef_id: string; etiket: string; yanlis_orani: number; ogrenci_sayisi: number }[];
    tema_ilgisi: { tema: string; ad: string | null; ogrenci_sayisi: number; hikaye_sayisi: number }[];
  };
}

export default function OkumaSinifKarti({ siniflar }: { siniflar: { id: string; ad: string }[] }) {
  const [secili, setSecili] = useState(siniflar[0]?.id ?? "");
  if (siniflar.length === 0) return null;
  return <KartGovdesi siniflar={siniflar} secili={secili} onSec={setSecili} />;
}

function KartGovdesi({ siniflar, secili, onSec }: { siniflar: { id: string; ad: string }[]; secili: string; onSec: (id: string) => void }) {
  const t = useTranslations("yonetim.okumaSinif");
  const veri = useAdminRpc<Ozet>("okuma_ogretmen_sinif_ozeti", { p_sinif_id: secili, p_gun: 30 }, { enabled: secili !== "" });

  // Okuma modülü bu veritabanında kurulu değilse kart hiç görünmez (öğretmeni boş modülle şaşırtma).
  if (veri.missing) return null;

  return (
    <section aria-labelledby="okuma-sinif-b" className={`${cardClass} mt-6 p-5 sm:p-6`}>
      <h3 id="okuma-sinif-b" className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h3>
      <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>

      {siniflar.length > 1 && (
        <div className="mt-4 max-w-sm">
          <label className={labelClass} htmlFor="okuma-sinif-sec">{t("sinif")}</label>
          <select id="okuma-sinif-sec" className={inputClass} value={secili} onChange={(e) => onSec(e.target.value)}>
            {siniflar.map((s) => (
              <option key={s.id} value={s.id}>{s.ad}</option>
            ))}
          </select>
        </div>
      )}

      {veri.loading && <p role="status" className="py-6 text-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>}
      {!veri.loading && veri.error && (
        <div className="py-4">
          <p role="alert" className="text-sm text-error-600 dark:text-error-500">{t("hata")}</p>
          <button type="button" className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400" onClick={veri.reload}>
            {t("tekrar")}
          </button>
        </div>
      )}

      {!veri.loading && !veri.error && veri.data && !veri.data.yeterli && (
        <p role="status" className="mt-4 rounded-lg bg-gray-50 px-3 py-2 text-sm text-gray-700 dark:bg-white/5 dark:text-gray-300">
          {t("yetersiz", { min: veri.data.min_n })}
        </p>
      )}

      {!veri.loading && !veri.error && veri.data?.yeterli && veri.data.ozet && <Govde d={veri.data} />}
    </section>
  );
}

function Govde({ d }: { d: Ozet }) {
  const t = useTranslations("yonetim.okumaSinif");
  const tb = useTranslations("veliPaneli.okuma.beceri");
  const o = d.ozet!;
  return (
    <div className="mt-4 space-y-5">
      <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("aralik", { gun: d.gun })}</p>
      <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
        <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
          <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("oturum")}</p>
          <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{o.oturum_sayisi}</p>
        </div>
        <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
          <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("tamamlama")}</p>
          <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{o.tamamlama_orani === null ? t("gozlemYok") : `%${o.tamamlama_orani}`}</p>
        </div>
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("dogruluk")}</h4>
        <ul className="mt-2 grid gap-2 sm:grid-cols-2">
          {BECERILER.map((b) => {
            const x = o.soru_dogrulugu?.[b];
            return (
              <li key={b} className="flex items-baseline justify-between gap-3 rounded-lg border border-gray-200 px-3 py-2 text-sm dark:border-gray-800">
                <span className="text-gray-700 dark:text-gray-300">{tb(b)}</span>
                <span className="font-semibold text-gray-800 dark:text-white/90">{x?.yeterli && x.oran !== undefined ? `%${x.oran}` : t("gozlemYok")}</span>
              </li>
            );
          })}
        </ul>
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("zorlanilan")}</h4>
        {o.zorlanilan_hedefler.length === 0 ? (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("zorlanilanYok", { min: d.min_n })}</p>
        ) : (
          <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
            {o.zorlanilan_hedefler.map((h) => (
              <li key={h.hedef_id} className="flex flex-wrap items-baseline justify-between gap-2 py-2">
                <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">{h.etiket}</span>
                <span className="text-theme-xs text-gray-600 dark:text-gray-400">{t("hedefDeger", { oran: h.yanlis_orani, ogrenci: h.ogrenci_sayisi })}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("tema")}</h4>
        {o.tema_ilgisi.length === 0 ? (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("temaYok", { min: d.min_n })}</p>
        ) : (
          <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
            {o.tema_ilgisi.map((x) => (
              <li key={x.tema} className="flex flex-wrap items-baseline justify-between gap-2 py-2">
                <span className="text-gray-800 dark:text-gray-100">{x.ad ?? x.tema}</span>
                <span className="text-theme-xs text-gray-600 dark:text-gray-400">{t("temaDeger", { ogrenci: x.ogrenci_sayisi, hikaye: x.hikaye_sayisi })}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("not", { min: d.min_n })}</p>
    </div>
  );
}
