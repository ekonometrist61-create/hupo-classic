"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import DesktopOnly from "@/components/ui/DesktopOnly";
import { cardClass, inputClass, labelClass, primaryBtn } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";

interface KapiDurum {
  durum: "kapali" | "onaylandi";
  metin_surumu: string | null;
  iys_karari: "bilinmiyor" | "gerekli_degil" | "gerekli_kayit_tamam";
  onay_notu: string | null;
  updated_at: string;
}

/** Toplam gösterim 10'un altındaysa sunucu sayıları ve oranları null döner (küçük hücre kuralı). */
interface OlcumOzeti {
  gun: number;
  yetersiz_veri: boolean;
  gosterildi: number | null;
  evet: number | null;
  ertele: number | null;
  sistem_verildi: number | null;
  sistem_reddedildi: number | null;
  evet_orani: number | null;
  sistem_verildi_orani: number | null;
}

const DEMO_KAPI: KapiDurum = {
  durum: "kapali",
  metin_surumu: null,
  iys_karari: "bilinmiyor",
  onay_notu: null,
  updated_at: new Date(0).toISOString(),
};

const DEMO_OZET: OlcumOzeti = {
  gun: 30,
  yetersiz_veri: true,
  gosterildi: null,
  evet: null,
  ertele: null,
  sistem_verildi: null,
  sistem_reddedildi: null,
  evet_orani: null,
  sistem_verildi_orani: null,
};

/**
 * Pazarlama push hukuk kapısı ve ön izin ölçümü.
 * Kapı kararını hukuk görüşüne dayanarak yönetici verir; kod yalnızca kapıyı uygular.
 * Kapı kapalıyken pazarlama push'u gönderilmez ve kayıt formunda push kutusu görünmez.
 */
export default function PazarlamaPushKapisi() {
  const t = useTranslations("yonetim.merkez.channels.legal");
  const kapi = useAdminRpc<KapiDurum>("admin_pazarlama_push_kapisi_getir", undefined, { demo: DEMO_KAPI });
  const ozet = useAdminRpc<OlcumOzeti>("admin_push_on_izin_ozeti", { p_gun: 30 }, { demo: DEMO_OZET });

  return (
    <div className="grid gap-6 md:grid-cols-2">
      <RpcBoundary state={kapi}>
        {(k) => <KapiForm key={k.updated_at} initial={k} onSaved={kapi.reload} t={t} />}
      </RpcBoundary>
      <RpcBoundary state={ozet}>
        {(o) => <OlcumKarti ozet={o} t={t} />}
      </RpcBoundary>
    </div>
  );
}

function KapiForm({
  initial,
  onSaved,
  t,
}: {
  initial: KapiDurum;
  onSaved: () => void;
  t: ReturnType<typeof useTranslations>;
}) {
  const [durum, setDurum] = useState<KapiDurum["durum"]>(initial.durum);
  const [metin, setMetin] = useState(initial.metin_surumu ?? "");
  const [iys, setIys] = useState<KapiDurum["iys_karari"]>(initial.iys_karari);
  const [not, setNot] = useState(initial.onay_notu ?? "");
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);
  const [busy, setBusy] = useState(false);

  const save = async () => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_pazarlama_push_kapisi_guncelle", {
      p_durum: durum,
      p_metin_surumu: metin.trim() || null,
      p_iys_karari: iys,
      p_onay_notu: not.trim() || null,
    });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("saved") });
    onSaved();
  };

  const row = "flex flex-col gap-2 border-b border-gray-100 py-4 last:border-0 dark:border-gray-800";

  const iysEtiket = {
    bilinmiyor: t("iysUnknown"),
    gerekli_degil: t("iysNotRequired"),
    gerekli_kayit_tamam: t("iysDone"),
  }[initial.iys_karari];

  return (
    <section className={`${cardClass} min-w-0 p-5 sm:p-6`}>
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("title")}</h2>
          <p className="mt-1 text-theme-xs text-gray-500">{t("desc")}</p>
        </div>
        <Badge size="sm" color={initial.durum === "onaylandi" ? "success" : "light"}>
          {initial.durum === "onaylandi" ? t("statusOn") : t("statusOff")}
        </Badge>
      </div>

      {/* Telefonda salt okunur özet (K3: yasal kapı yazma işlemi masaüstünde). */}
      <dl className="mt-4 divide-y divide-gray-100 text-theme-sm md:hidden dark:divide-gray-800">
        <div className="flex items-start justify-between gap-4 py-3">
          <dt className="font-semibold">{t("status")}</dt>
          <dd>{initial.durum === "onaylandi" ? t("statusOn") : t("statusOff")}</dd>
        </div>
        <div className="flex items-start justify-between gap-4 py-3">
          <dt className="font-semibold">{t("version")}</dt>
          <dd className="wrap-break-word text-end">{initial.metin_surumu || "—"}</dd>
        </div>
        <div className="flex items-start justify-between gap-4 py-3">
          <dt className="font-semibold">{t("iys")}</dt>
          <dd className="text-end">{iysEtiket}</dd>
        </div>
        <div className="flex items-start justify-between gap-4 py-3">
          <dt className="font-semibold">{t("note")}</dt>
          <dd className="wrap-break-word text-end">{initial.onay_notu || "—"}</dd>
        </div>
      </dl>

      <DesktopOnly>
        <div>
          <div className={`${row} mt-4`}>
            <label htmlFor="pk-durum" className="text-theme-sm font-semibold">{t("status")}</label>
            <select id="pk-durum" className={inputClass} value={durum} onChange={(e) => setDurum(e.target.value as KapiDurum["durum"])}>
              <option value="kapali">{t("statusOff")}</option>
              <option value="onaylandi">{t("statusOn")}</option>
            </select>
          </div>

          <div className={row}>
            <label htmlFor="pk-metin" className="text-theme-sm font-semibold">{t("version")}</label>
            <input id="pk-metin" className={inputClass} value={metin} maxLength={60} placeholder={t("versionHint")} onChange={(e) => setMetin(e.target.value)} />
          </div>

          <div className={row}>
            <label htmlFor="pk-iys" className={labelClass}>{t("iys")}</label>
            <select id="pk-iys" className={inputClass} value={iys} onChange={(e) => setIys(e.target.value as KapiDurum["iys_karari"])}>
              <option value="bilinmiyor">{t("iysUnknown")}</option>
              <option value="gerekli_degil">{t("iysNotRequired")}</option>
              <option value="gerekli_kayit_tamam">{t("iysDone")}</option>
            </select>
          </div>

          <div className={row}>
            <label htmlFor="pk-not" className={labelClass}>{t("note")}</label>
            <textarea id="pk-not" className={`${inputClass} h-auto min-h-20 py-2.5`} value={not} maxLength={1000} placeholder={t("noteHint")} onChange={(e) => setNot(e.target.value)} />
          </div>

          <div className="mt-4 flex items-center gap-3">
            <button type="button" className={primaryBtn} disabled={busy} onClick={save}>{t("save")}</button>
          </div>
          <div className="mt-3"><Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} /></div>
        </div>
      </DesktopOnly>
    </section>
  );
}

function yuzde(oran: number | null, bos: string) {
  return oran === null ? bos : `%${oran.toLocaleString("tr-TR", { maximumFractionDigits: 1 })}`;
}

function sayi(n: number | null, bos: string) {
  return n === null ? bos : n;
}

function OlcumKarti({ ozet, t }: { ozet: OlcumOzeti; t: ReturnType<typeof useTranslations> }) {
  const row = "flex items-center justify-between gap-4 border-b border-gray-100 py-3 last:border-0 dark:border-gray-800";
  const bos = t("noData");

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("measureTitle")}</h2>
      <p className="mt-1 text-theme-xs text-gray-500">{t("measureDesc")}</p>

      {ozet.yetersiz_veri ? (
        <p className="mt-4 rounded-xl bg-gray-50 px-4 py-3 text-theme-sm text-gray-600 dark:bg-white/5 dark:text-gray-300">
          {t("insufficient")}
        </p>
      ) : (
        <div className="mt-4">
          <div className={row}><span className="text-theme-sm">{t("shown")}</span><b>{sayi(ozet.gosterildi, bos)}</b></div>
          <div className={row}><span className="text-theme-sm">{t("yes")}</span><b>{sayi(ozet.evet, bos)}</b></div>
          <div className={row}><span className="text-theme-sm">{t("later")}</span><b>{sayi(ozet.ertele, bos)}</b></div>
          <div className={row}><span className="text-theme-sm">{t("systemYes")}</span><b>{sayi(ozet.sistem_verildi, bos)}</b></div>
          <div className={row}><span className="text-theme-sm">{t("systemNo")}</span><b>{sayi(ozet.sistem_reddedildi, bos)}</b></div>
          <div className={row}><span className="text-theme-sm">{t("yesRate")}</span><b>{yuzde(ozet.evet_orani, bos)}</b></div>
          <div className={row}><span className="text-theme-sm">{t("systemRate")}</span><b>{yuzde(ozet.sistem_verildi_orani, bos)}</b></div>
        </div>
      )}
      <p className="mt-3 text-theme-xs text-gray-500">{t("footer")}</p>
    </section>
  );
}
