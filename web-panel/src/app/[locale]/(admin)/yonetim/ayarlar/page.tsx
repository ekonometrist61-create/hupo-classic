"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import DesktopOnly from "@/components/ui/DesktopOnly";
import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import {
  cardClass,
  inputClass,
  primaryBtn,
} from "@/components/yonetim/panel/styles";
import DenemeSinirlariKarti from "@/components/yonetim/ayarlar/DenemeSinirlariKarti";
import { dokunmaHedefi } from "@/components/yonetim/ui/responsive";
import {
  isoToTurkiyeInput,
  turkiyeInputToIso,
} from "@/components/yonetim/turkiyeTarih";

type BakimYuzeyleri = { site: boolean; veli: boolean; yonetim: boolean };
type BakimModu = { aktif: boolean; mesaj: string; yuzeyler?: BakimYuzeyleri };
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
type Deneme = { gun: number; gunluk_soru: number };

type AppSettings = {
  bakim_modu?: BakimModu;
  min_surum?: MinSurum;
  reklamlar?: Reklamlar;
  premium_gating?: PremiumGating;
  deneme?: Deneme;
  desteklenen_siniflar?: DesteklenenSiniflar;
  deneme_sinavi_tarihi?: string;
};

/** Açık/kapalı anahtar. Dokunma hedefi 44 px; ekran okuyucuya satır başlığı verilir. */
function Toggle({
  id,
  label,
  checked,
  onChange,
}: {
  id: string;
  label: string;
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <label
      htmlFor={id}
      className={`${dokunmaHedefi} relative min-w-11 cursor-pointer justify-center`}
    >
      <input
        id={id}
        type="checkbox"
        className="sr-only"
        aria-label={label}
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

/** Bir ayar satırı: hem salt okunur (mobil) hem düzenlenebilir (masaüstü) hâli. */
interface Satir {
  id: string;
  baslik: string;
  aciklama: string;
  /** Telefonda gösterilen salt okunur değer. */
  deger: React.ReactNode;
  /** Masaüstünde gösterilen denetim (yazma). */
  kontrol: React.ReactNode;
}

export default function AyarlarPage() {
  const t = useTranslations("yonetim.ayarlar");
  const state = useAdminRpc<AppSettings>("admin_get_settings");

  const [bakimModu, setBakimModu] = useState(false);
  const [bakimYuzeyler, setBakimYuzeyler] = useState<BakimYuzeyleri>({
    site: false,
    veli: false,
    yonetim: false,
  });
  const [minSurum, setMinSurum] = useState("1.0.0");
  const [reklamlar, setReklamlar] = useState(false);
  const [premiumGating, setPremiumGating] = useState(false);
  const [desteklenenSiniflar, setDesteklenenSiniflar] = useState("3,4,5,6,7");
  const [denemeSinaviTarihi, setDenemeSinaviTarihi] = useState("");
  const [denemeGun, setDenemeGun] = useState("14");
  const [denemeGunlukSoru, setDenemeGunlukSoru] = useState("20");

  const [saving, setSaving] = useState(false);
  const [feedback, setFeedback] = useState<{
    kind: "ok" | "error";
    msg: string;
  } | null>(null);

  useEffect(() => {
    const s = state.data;
    if (!s) return;
    if (s.bakim_modu) {
      setBakimModu(s.bakim_modu.aktif);
      if (s.bakim_modu.yuzeyler) setBakimYuzeyler(s.bakim_modu.yuzeyler);
    }
    if (s.min_surum) setMinSurum(s.min_surum.android);
    if (s.reklamlar) setReklamlar(s.reklamlar.ogrenci_acik);
    if (s.premium_gating) setPremiumGating(s.premium_gating.aktif);
    if (s.desteklenen_siniflar)
      setDesteklenenSiniflar(s.desteklenen_siniflar.siniflar.join(","));
    if (s.deneme_sinavi_tarihi)
      setDenemeSinaviTarihi(isoToTurkiyeInput(s.deneme_sinavi_tarihi));
    if (s.deneme) {
      setDenemeGun(String(s.deneme.gun));
      setDenemeGunlukSoru(String(s.deneme.gunluk_soru));
    }
  }, [state.data]);

  const save = async () => {
    setSaving(true);
    setFeedback(null);

    const siniflar = desteklenenSiniflar
      .split(",")
      .map((x) => parseInt(x.trim(), 10))
      .filter((n) => !isNaN(n) && n >= 1 && n <= 12);

    if (siniflar.length === 0) {
      setFeedback({ kind: "error", msg: t("validation.grades") });
      setSaving(false);
      return;
    }

    // Deneme: gün 1-90, günlük soru 0-9999 tam sayı olmalı.
    const gun = Number(denemeGun);
    const gunluk = Number(denemeGunlukSoru);
    if (!Number.isInteger(gun) || gun < 1 || gun > 90) {
      setFeedback({ kind: "error", msg: t("validation.trialDays") });
      setSaving(false);
      return;
    }
    if (!Number.isInteger(gunluk) || gunluk < 0 || gunluk > 9999) {
      setFeedback({ kind: "error", msg: t("validation.trialQuota") });
      setSaving(false);
      return;
    }

    // Tarih boşsa mevcut değer korunur; doluysa geçerli olmalı.
    const denemeIso = denemeSinaviTarihi ? turkiyeInputToIso(denemeSinaviTarihi) : null;
    if (denemeSinaviTarihi && !denemeIso) {
      setFeedback({ kind: "error", msg: t("validation.examDate") });
      setSaving(false);
      return;
    }

    const ex = state.data ?? {};

    const results = await Promise.all([
      adminCall("admin_set_setting", {
        p_key: "bakim_modu",
        p_value: { aktif: bakimModu, mesaj: ex.bakim_modu?.mesaj ?? "", yuzeyler: bakimYuzeyler },
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
      adminCall("admin_set_setting", {
        p_key: "deneme",
        p_value: { gun, gunluk_soru: gunluk },
      }),
      ...(denemeIso
        ? [
            adminCall("admin_set_setting", {
              p_key: "deneme_sinavi_tarihi",
              p_value: denemeIso,
            }),
          ]
        : []),
    ]);

    setSaving(false);

    const hatalar = results.filter((r) => r.error);
    if (hatalar.length > 0) {
      const ilk = hatalar[0].error!;
      setFeedback({
        kind: "error",
        msg: ilk === "DEMO" ? t("demo") : ilk,
      });
      return;
    }

    setFeedback({ kind: "ok", msg: t("saved") });
    state.reload();
  };

  const durumRozeti = (acik: boolean) => (
    <Badge size="sm" color={acik ? "success" : "light"}>
      {acik ? t("on") : t("off")}
    </Badge>
  );
  const deger = (x: React.ReactNode) => (
    <span className="text-sm font-semibold break-words text-gray-800 dark:text-white/90">{x}</span>
  );

  const satirlar: Satir[] = [
    {
      id: "bakim-app",
      baslik: t("maintenanceApp"),
      aciklama: t("maintenanceAppDesc"),
      deger: durumRozeti(bakimModu),
      kontrol: <Toggle id="bakim-modu" label={t("maintenanceApp")} checked={bakimModu} onChange={setBakimModu} />,
    },
    {
      id: "bakim-site",
      baslik: t("maintenanceSite"),
      aciklama: t("maintenanceSiteDesc"),
      deger: durumRozeti(bakimYuzeyler.site),
      kontrol: (
        <Toggle
          id="bakim-site"
          label={t("maintenanceSite")}
          checked={bakimYuzeyler.site}
          onChange={(v) => setBakimYuzeyler((y) => ({ ...y, site: v }))}
        />
      ),
    },
    {
      id: "bakim-veli",
      baslik: t("maintenanceParent"),
      aciklama: t("maintenanceParentDesc"),
      deger: durumRozeti(bakimYuzeyler.veli),
      kontrol: (
        <Toggle
          id="bakim-veli"
          label={t("maintenanceParent")}
          checked={bakimYuzeyler.veli}
          onChange={(v) => setBakimYuzeyler((y) => ({ ...y, veli: v }))}
        />
      ),
    },
    {
      id: "bakim-yonetim",
      baslik: t("maintenanceAdmin"),
      aciklama: t("maintenanceAdminDesc"),
      deger: durumRozeti(bakimYuzeyler.yonetim),
      kontrol: (
        <Toggle
          id="bakim-yonetim"
          label={t("maintenanceAdmin")}
          checked={bakimYuzeyler.yonetim}
          onChange={(v) => setBakimYuzeyler((y) => ({ ...y, yonetim: v }))}
        />
      ),
    },
    {
      id: "min-surum",
      baslik: t("minVersion"),
      aciklama: t("minVersionDesc"),
      deger: deger(minSurum),
      kontrol: (
        <input
          type="text"
          aria-label={t("minVersion")}
          className={`${inputClass} w-36`}
          value={minSurum}
          onChange={(e) => setMinSurum(e.target.value)}
          placeholder="1.0.0"
        />
      ),
    },
    {
      id: "reklamlar",
      baslik: t("ads"),
      aciklama: t("adsDesc"),
      deger: durumRozeti(reklamlar),
      kontrol: <Toggle id="reklamlar" label={t("ads")} checked={reklamlar} onChange={setReklamlar} />,
    },
    {
      id: "premium",
      baslik: t("premium"),
      aciklama: t("premiumDesc"),
      deger: durumRozeti(premiumGating),
      kontrol: (
        <Toggle id="premium-gating" label={t("premium")} checked={premiumGating} onChange={setPremiumGating} />
      ),
    },
    {
      id: "siniflar",
      baslik: t("grades"),
      aciklama: t("gradesDesc"),
      deger: deger(desteklenenSiniflar),
      kontrol: (
        <input
          type="text"
          aria-label={t("grades")}
          className={`${inputClass} w-48`}
          value={desteklenenSiniflar}
          onChange={(e) => setDesteklenenSiniflar(e.target.value)}
          placeholder="3,4,5,6,7"
        />
      ),
    },
    {
      id: "deneme-gun",
      baslik: t("trialDays"),
      aciklama: t("trialDaysDesc"),
      deger: deger(t("trialDaysValue", { n: denemeGun })),
      kontrol: (
        <input
          type="number"
          min={1}
          max={90}
          aria-label={t("trialDays")}
          className={`${inputClass} w-28`}
          value={denemeGun}
          onChange={(e) => setDenemeGun(e.target.value)}
        />
      ),
    },
    {
      id: "deneme-kota",
      baslik: t("trialQuota"),
      aciklama: t("trialQuotaDesc"),
      deger: deger(denemeGunlukSoru),
      kontrol: (
        <input
          type="number"
          min={0}
          max={9999}
          aria-label={t("trialQuota")}
          className={`${inputClass} w-28`}
          value={denemeGunlukSoru}
          onChange={(e) => setDenemeGunlukSoru(e.target.value)}
        />
      ),
    },
    {
      id: "deneme-tarih",
      baslik: t("examDate"),
      aciklama: t("examDateDesc"),
      deger: deger(denemeSinaviTarihi ? denemeSinaviTarihi.replace("T", " ") : t("examDateEmpty")),
      kontrol: (
        <input
          type="datetime-local"
          aria-label={t("examDate")}
          className={`${inputClass} w-56`}
          value={denemeSinaviTarihi}
          onChange={(e) => setDenemeSinaviTarihi(e.target.value)}
        />
      ),
    },
  ];

  const satirGoster = (s: Satir, duzenlenebilir: boolean) => (
    <div key={s.id} className={row}>
      <div className="min-w-0">
        <p className="text-sm font-medium text-gray-800 dark:text-white/90">{s.baslik}</p>
        <p className="text-xs text-gray-500 dark:text-gray-400">{s.aciklama}</p>
      </div>
      {duzenlenebilir ? s.kontrol : s.deger}
    </div>
  );

  return (
    <div>
      <PageBreadcrumb pageTitle={t("title")} description={t("desc")} />

      {feedback && (
        <div
          role="status"
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
          {t("loading")}
        </div>
      )}

      {!state.loading && state.error && (
        <div className={`${cardClass} p-6 text-sm text-error-600 dark:text-error-400`} role="alert">
          {state.error}
        </div>
      )}

      {!state.loading && !state.error && (
        <>
          {/* K3: kayıt ve yazma yalnızca masaüstünde. Telefonda aynı ayarlar salt okunur görünür. */}
          <DesktopOnly>
            <div className={cardClass}>
              {satirlar.map((s) => satirGoster(s, true))}
              <div className="flex justify-end px-6 py-4">
                <button
                  type="button"
                  className={primaryBtn}
                  onClick={save}
                  disabled={saving || state.loading}
                >
                  {saving ? t("saving") : t("save")}
                </button>
              </div>
            </div>
          </DesktopOnly>

          <div className={`${cardClass} md:hidden`}>
            {satirlar.map((s) => satirGoster(s, false))}
          </div>

          <DenemeSinirlariKarti />
        </>
      )}
    </div>
  );
}
