"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import { cardClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

interface OgrenciOzet {
  id: string;
  ad: string;
  sinif: number;
  username: string;
}

interface MergeCandidate {
  id: string;
  reason: string;
  confidence: number;
  created_at: string;
  ogrenci_a: OgrenciOzet;
  ogrenci_b: OgrenciOzet;
}

// Bilinen eşleşme sebepleri çevrilir; bilinmeyen sebep ham değeriyle gösterilir.
const BILINEN_SEBEPLER = ["same_name_grade", "same_household"] as const;

const CONFIDENCE_COLOR = (c: number) =>
  c >= 0.8 ? "text-red-600 dark:text-red-400" : c >= 0.6 ? "text-yellow-600 dark:text-yellow-400" : "text-gray-500";

// Tablo kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır.
const ILK_SUTUN_SABIT =
  "[&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900";

export default function KimlikEslestirmeManager() {
  const t = useTranslations("yonetim.kimlikEslestirme");
  const [adaylar, setAdaylar] = useState<MergeCandidate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState<string | null>(null); // candidate id

  useEffect(() => {
    createClient()
      .rpc("admin_list_merge_candidates")
      .then(({ data, error: rpcErr }) => {
        setLoading(false);
        if (rpcErr || !Array.isArray(data)) {
          setError(t("loadError"));
          return;
        }
        setAdaylar(data as MergeCandidate[]);
      });
    // t sabit çeviri fonksiyonu; veri yalnızca bileşen açılışında yüklenir
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function resolve(id: string, action: "merged" | "distinct" | "ignored") {
    if (action === "merged" && !window.confirm(t("mergeConfirm"))) return;
    setSaving(id);
    const { error: rpcErr } = await createClient().rpc("admin_resolve_merge_candidate", {
      p_candidate_id: id,
      p_action: action,
    });
    setSaving(null);
    if (rpcErr) {
      setError(rpcErr.message);
      return;
    }
    setAdaylar((prev) => prev.filter((c) => c.id !== id));
  }

  const sebep = (kod: string) =>
    (BILINEN_SEBEPLER as readonly string[]).includes(kod) ? t(`reasons.${kod}`) : kod;

  // Birleştir / farklı / atla düğmeleri: kart ve tabloda aynı. Dokunma hedefi en az 44 px.
  const kararDugmeleri = (aday: MergeCandidate) => (
    <>
      <button
        type="button"
        disabled={saving === aday.id}
        onClick={() => resolve(aday.id, "merged")}
        className={primaryBtn}
        title={t("mergeTitle")}
      >
        {t("merge")}
      </button>
      <button
        type="button"
        disabled={saving === aday.id}
        onClick={() => resolve(aday.id, "distinct")}
        className={outlineBtn}
      >
        {t("distinct")}
      </button>
      <button
        type="button"
        disabled={saving === aday.id}
        onClick={() => resolve(aday.id, "ignored")}
        className="inline-flex min-h-11 items-center px-2 text-sm text-gray-400 hover:text-gray-600 disabled:opacity-50"
      >
        {t("skip")}
      </button>
    </>
  );

  if (loading) {
    return (
      <div className={`${cardClass} p-5 sm:p-6`}>
        <p className="text-sm text-gray-400">{t("loading")}</p>
      </div>
    );
  }

  return (
    <div className={`${cardClass} p-5 sm:p-6`}>
      {error && (
        <div className="mb-4 flex items-start justify-between gap-2">
          <ErrorNote message={error} />
          <button
            type="button"
            onClick={() => setError(null)}
            aria-label={t("dismissError")}
            className="inline-flex min-h-11 min-w-11 shrink-0 items-center justify-center text-xs text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>
      )}

      {adaylar.length === 0 ? (
        <p className="py-8 text-center text-sm text-gray-400">{t("empty")}</p>
      ) : (
        <>
          <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("countNote", { count: adaylar.length })}</p>

          {/* Telefon ve küçük tablet (md altı): kart görünümü */}
          <ul className="space-y-3 md:hidden">
            {adaylar.map((aday) => (
              <li key={aday.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                <div className="grid grid-cols-2 gap-3">
                  <div className="min-w-0">
                    <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.a")}</p>
                    <p className="font-medium wrap-break-word">{aday.ogrenci_a.ad}</p>
                    <p className="text-xs text-gray-400">
                      {t("grade", { sinif: aday.ogrenci_a.sinif, username: aday.ogrenci_a.username })}
                    </p>
                  </div>
                  <div className="min-w-0">
                    <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.b")}</p>
                    <p className="font-medium wrap-break-word">{aday.ogrenci_b.ad}</p>
                    <p className="text-xs text-gray-400">
                      {t("grade", { sinif: aday.ogrenci_b.sinif, username: aday.ogrenci_b.username })}
                    </p>
                  </div>
                </div>
                <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm">
                  <div>
                    <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.reason")}</dt>
                    <dd className="text-gray-800 dark:text-white/90">{sebep(aday.reason)}</dd>
                  </div>
                  <div>
                    <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.confidence")}</dt>
                    <dd className={`font-bold ${CONFIDENCE_COLOR(aday.confidence)}`}>%{Math.round(aday.confidence * 100)}</dd>
                  </div>
                </dl>
                <div className="mt-3 flex flex-wrap gap-2 border-t border-gray-100 pt-3 dark:border-gray-800">
                  {kararDugmeleri(aday)}
                </div>
              </li>
            ))}
          </ul>

          {/* Tablet ve masaüstü (md ve üzeri): tablo; kapsayıcısı kayar */}
          <div className={`hidden overflow-x-auto md:block ${ILK_SUTUN_SABIT}`}>
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>{t("cols.a")}</th>
                  <th className={thClass}>{t("cols.b")}</th>
                  <th className={thClass}>{t("cols.reason")}</th>
                  <th className={thClass}>{t("cols.confidence")}</th>
                  <th className={thClass}>{t("cols.decision")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {adaylar.map((aday) => (
                  <tr key={aday.id}>
                    <td className={tdClass}>
                      <p className="font-medium">{aday.ogrenci_a.ad}</p>
                      <p className="text-xs text-gray-400">
                        {t("grade", { sinif: aday.ogrenci_a.sinif, username: aday.ogrenci_a.username })}
                      </p>
                    </td>
                    <td className={tdClass}>
                      <p className="font-medium">{aday.ogrenci_b.ad}</p>
                      <p className="text-xs text-gray-400">
                        {t("grade", { sinif: aday.ogrenci_b.sinif, username: aday.ogrenci_b.username })}
                      </p>
                    </td>
                    <td className={tdClass}>{sebep(aday.reason)}</td>
                    <td className={`${tdClass} ${CONFIDENCE_COLOR(aday.confidence)} font-bold`}>
                      %{Math.round(aday.confidence * 100)}
                    </td>
                    <td className={tdClass}>
                      <div className="flex flex-wrap gap-2">
                        {kararDugmeleri(aday)}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}

