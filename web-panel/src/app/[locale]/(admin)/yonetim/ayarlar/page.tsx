"use client";

import { useEffect, useState } from "react";

import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import {
  cardClass,
  inputClass,
  primaryBtn,
} from "@/components/yonetim/panel/styles";

type BakimModu = { aktif: boolean; mesaj: string };
type MinSurum = { android: string; ios: string; web: string; mesaj: string };
type Reklamlar = {
  veli_paneli_acik: boolean;
  ogrenci_acik: boolean;
  admob_app_id_android: string | null;
  admob_app_id_ios: string | null;
  admob_banner_id_android: string | null;
  admob_banner_id_ios: string | null;
  adsense_publisher_id: string | null;
  adsense_slot_id: string | null;
};
type PremiumGating = { aktif: boolean; ucretsiz_gunluk_soru: number };
type DesteklenenSiniflar = { siniflar: number[] };

type AppSettings = {
  bakim_modu?: BakimModu;
  min_surum?: MinSurum;
  reklamlar?: Reklamlar;
  premium_gating?: PremiumGating;
  desteklenen_siniflar?: DesteklenenSiniflar;
};

function Toggle({
  id,
  checked,
  onChange,
}: {
  id: string;
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <label htmlFor={id} className="relative inline-flex cursor-pointer items-center">
      <input
        id={id}
        type="checkbox"
        className="sr-only"
        checked={checked}
        onChange={(e) => onChange(e.target.checked)}
      />
      <span
        className={`relative inline-block h-6 w-11 rounded-full transition-colors duration-200 ${
          checked ? "bg-brand-500" : "bg-gray-200 dark:bg-gray-700"
        }`}
      >
        <span
          className={`absolute top-0.5 left-0.5 h-5 w-5 rounded-full bg-white shadow-sm transition-transform duration-200 ${
            checked ? "translate-x-5" : "translate-x-0"
          }`}
        />
      </span>
    </label>
  );
}

const row =
  "flex flex-wrap items-center justify-between gap-4 border-b border-gray-100 py-4 px-6 last:border-0 dark:border-gray-800";

export default function AyarlarPage() {
  const state = useAdminRpc<AppSettings>("admin_get_settings");

  const [bakimModu, setBakimModu] = useState(false);
  const [minSurum, setMinSurum] = useState("1.0.0");
  const [reklamlar, setReklamlar] = useState(false);
  const [premiumGating, setPremiumGating] = useState(false);
  const [desteklenenSiniflar, setDesteklenenSiniflar] = useState("3,4,5,6,7");

  const [saving, setSaving] = useState(false);
  const [feedback, setFeedback] = useState<{
    kind: "ok" | "error";
    msg: string;
  } | null>(null);

  useEffect(() => {
    const s = state.data;
    if (!s) return;
    if (s.bakim_modu) setBakimModu(s.bakim_modu.aktif);
    if (s.min_surum) setMinSurum(s.min_surum.android);
    if (s.reklamlar) setReklamlar(s.reklamlar.ogrenci_acik);
    if (s.premium_gating) setPremiumGating(s.premium_gating.aktif);
    if (s.desteklenen_siniflar)
      setDesteklenenSiniflar(s.desteklenen_siniflar.siniflar.join(","));
  }, [state.data]);

  const save = async () => {
    setSaving(true);
    setFeedback(null);

    const siniflar = desteklenenSiniflar
      .split(",")
      .map((x) => parseInt(x.trim(), 10))
      .filter((n) => !isNaN(n) && n >= 1 && n <= 12);

    if (siniflar.length === 0) {
      setFeedback({ kind: "error", msg: "Desteklenen sınıflar boş olamaz (ör. 3,4,5,6,7)." });
      setSaving(false);
      return;
    }

    const ex = state.data ?? {};

    const results = await Promise.all([
      adminCall("admin_set_setting", {
        p_key: "bakim_modu",
        p_value: { aktif: bakimModu, mesaj: ex.bakim_modu?.mesaj ?? "" },
      }),
      adminCall("admin_set_setting", {
        p_key: "min_surum",
        p_value: {
          android: minSurum,
          ios: ex.min_surum?.ios ?? minSurum,
          web: ex.min_surum?.web ?? minSurum,
          mesaj: ex.min_surum?.mesaj ?? "",
        },
      }),
      adminCall("admin_set_setting", {
        p_key: "reklamlar",
        p_value: {
          veli_paneli_acik: reklamlar,
          ogrenci_acik: reklamlar,
          admob_app_id_android: ex.reklamlar?.admob_app_id_android ?? null,
          admob_app_id_ios: ex.reklamlar?.admob_app_id_ios ?? null,
          admob_banner_id_android: ex.reklamlar?.admob_banner_id_android ?? null,
          admob_banner_id_ios: ex.reklamlar?.admob_banner_id_ios ?? null,
          adsense_publisher_id: ex.reklamlar?.adsense_publisher_id ?? null,
          adsense_slot_id: ex.reklamlar?.adsense_slot_id ?? null,
        },
      }),
      adminCall("admin_set_setting", {
        p_key: "premium_gating",
        p_value: {
          aktif: premiumGating,
          ucretsiz_gunluk_soru: ex.premium_gating?.ucretsiz_gunluk_soru ?? 10,
        },
      }),
      adminCall("admin_set_setting", {
        p_key: "desteklenen_siniflar",
        p_value: { siniflar },
      }),
    ]);

    setSaving(false);

    const hatalar = results.filter((r) => r.error);
    if (hatalar.length > 0) {
      const ilk = hatalar[0].error!;
      setFeedback({
        kind: "error",
        msg: ilk === "DEMO" ? "Demo modunda değişiklik yapılamaz." : ilk,
      });
      return;
    }

    setFeedback({ kind: "ok", msg: "Ayarlar başarıyla kaydedildi." });
    state.reload();
  };

  return (
    <div>
      <PageBreadcrumb
        pageTitle="Uygulama Ayarları"
        description="Bakım modu, minimum sürüm ve özellik anahtarları"
      />

      {feedback && (
        <div
          className={`mb-5 rounded-lg px-4 py-3 text-sm font-medium ${
            feedback.kind === "ok"
              ? "bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-400"
              : "bg-error-50 text-error-700 dark:bg-error-500/10 dark:text-error-400"
          }`}
        >
          {feedback.msg}
        </div>
      )}

      {state.loading && (
        <div className={`${cardClass} p-6 text-sm text-gray-500 dark:text-gray-400`}>
          Yükleniyor…
        </div>
      )}

      {!state.loading && state.error && (
        <div className={`${cardClass} p-6 text-sm text-error-600 dark:text-error-400`}>
          {state.error}
        </div>
      )}

      {!state.loading && !state.error && (
        <div className={cardClass}>
          <div className={row}>
            <div>
              <p className="text-sm font-medium text-gray-800 dark:text-white/90">Bakım Modu</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">Aktif olduğunda uygulama bakım ekranı gösterir</p>
            </div>
            <Toggle id="bakim-modu" checked={bakimModu} onChange={setBakimModu} />
          </div>

          <div className={row}>
            <div>
              <p className="text-sm font-medium text-gray-800 dark:text-white/90">Minimum Sürüm</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">Android zorunlu güncelleme eşiği, ör. 1.5.0</p>
            </div>
            <input
              type="text"
              className={`${inputClass} w-36`}
              value={minSurum}
              onChange={(e) => setMinSurum(e.target.value)}
              placeholder="1.0.0"
            />
          </div>

          <div className={row}>
            <div>
              <p className="text-sm font-medium text-gray-800 dark:text-white/90">Reklamlar</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">Öğrenci ve veli panelinde reklam gösterimi</p>
            </div>
            <Toggle id="reklamlar" checked={reklamlar} onChange={setReklamlar} />
          </div>

          <div className={row}>
            <div>
              <p className="text-sm font-medium text-gray-800 dark:text-white/90">Premium Kısıtlama</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">Ücretsiz günlük soru limitini etkinleştirir</p>
            </div>
            <Toggle id="premium-gating" checked={premiumGating} onChange={setPremiumGating} />
          </div>

          <div className={row}>
            <div>
              <p className="text-sm font-medium text-gray-800 dark:text-white/90">Desteklenen Sınıflar</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">Virgülle ayrılmış sınıf numaraları, ör. 3,4,5,6,7</p>
            </div>
            <input
              type="text"
              className={`${inputClass} w-48`}
              value={desteklenenSiniflar}
              onChange={(e) => setDesteklenenSiniflar(e.target.value)}
              placeholder="3,4,5,6,7"
            />
          </div>

          <div className="flex justify-end px-6 py-4">
            <button
              className={primaryBtn}
              onClick={save}
              disabled={saving || state.loading}
            >
              {saving ? "Kaydediliyor…" : "Kaydet"}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
