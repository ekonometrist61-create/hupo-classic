"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import DesktopOnly from "@/components/ui/DesktopOnly";
import { cardClass, inputClass, primaryBtn } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { DEMO_SETTINGS } from "./demoData";
import PazarlamaPushKapisi from "./PazarlamaPushKapisi";
import type { IletisimAyarlari } from "./types";

const CONNECTIONS = ["email", "push", "sms", "inapp"] as const;

export default function ChannelSettings() {
  const t = useTranslations("yonetim.merkez.channels");
  const state = useAdminRpc<IletisimAyarlari>("admin_iletisim_ayarlari_getir", undefined, { demo: DEMO_SETTINGS });

  return (
    <div className="space-y-6">
      <RpcBoundary state={state}>
        {(s) => <Form key={s.updated_at} initial={s} onSaved={state.reload} t={t} />}
      </RpcBoundary>
      <PazarlamaPushKapisi />
    </div>
  );
}

function Form({
  initial,
  onSaved,
  t,
}: {
  initial: IletisimAyarlari;
  onSaved: () => void;
  t: ReturnType<typeof useTranslations>;
}) {
  const [limit, setLimit] = useState(initial.haftalik_limit);
  const [from, setFrom] = useState(initial.sessiz_baslangic);
  const [to, setTo] = useState(initial.sessiz_bitis);
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);
  const [busy, setBusy] = useState(false);

  const save = async () => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_iletisim_ayarlari_kaydet", {
      p_haftalik_limit: limit,
      p_sessiz_baslangic: from,
      p_sessiz_bitis: to,
    });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("saved") });
    onSaved();
  };

  const row = "flex flex-wrap items-center justify-between gap-4 border-b border-gray-100 py-4 last:border-0 dark:border-gray-800";
  const readRow = "flex items-center justify-between gap-4 py-3";

  return (
    <div className="grid gap-6 md:grid-cols-2">
      <section className={`${cardClass} min-w-0 p-5 sm:p-6`}>
        <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("policyTitle")}</h2>

        {/* Telefonda salt okunur özet (K3: okuma açık, yazma masaüstünde). */}
        <dl className="mt-2 divide-y divide-gray-100 text-theme-sm md:hidden dark:divide-gray-800">
          <div className={readRow}>
            <dt>{t("limit")}</dt>
            <dd className="font-semibold">{limit}</dd>
          </div>
          <div className={readRow}>
            <dt>{t("quietFrom")}</dt>
            <dd className="text-end">
              <span className="font-semibold">{from}</span>
              <span className="block text-theme-xs text-gray-500">{t("tz", { tz: initial.zaman_dilimi })}</span>
            </dd>
          </div>
          <div className={readRow}>
            <dt>{t("quietTo")}</dt>
            <dd className="font-semibold">{to}</dd>
          </div>
          <div className={readRow}>
            <dt>{t("consentCheck")}</dt>
            <dd><Badge size="sm" color="success">{t("always")}</Badge></dd>
          </div>
          <div className={readRow}>
            <dt>{t("children")}</dt>
            <dd><Badge size="sm" color="light">{t("off")}</Badge></dd>
          </div>
        </dl>

        <DesktopOnly>
          <div>
            <div className={row}>
              <label htmlFor="cs-limit">
                <b className="block text-theme-sm">{t("limit")}</b>
                <span className="text-theme-xs text-gray-500">{t("limitDesc")}</span>
              </label>
              <input id="cs-limit" type="number" min={0} max={20} className={`${inputClass} w-24!`} value={limit} onChange={(e) => setLimit(Number(e.target.value))} />
            </div>
            <div className={row}>
              <label htmlFor="cs-from">
                <b className="block text-theme-sm">{t("quietFrom")}</b>
                <span className="text-theme-xs text-gray-500">{t("tz", { tz: initial.zaman_dilimi })}</span>
              </label>
              <input id="cs-from" type="time" className={`${inputClass} w-32!`} value={from} onChange={(e) => setFrom(e.target.value)} />
            </div>
            <div className={row}>
              <label htmlFor="cs-to"><b className="block text-theme-sm">{t("quietTo")}</b></label>
              <input id="cs-to" type="time" className={`${inputClass} w-32!`} value={to} onChange={(e) => setTo(e.target.value)} />
            </div>
            <div className={row}>
              <div>
                <b className="block text-theme-sm">{t("consentCheck")}</b>
                <span className="text-theme-xs text-gray-500">{t("consentCheckDesc")}</span>
              </div>
              <Badge size="sm" color="success">{t("always")}</Badge>
            </div>
            <div className={row}>
              <b className="text-theme-sm">{t("children")}</b>
              <Badge size="sm" color="light">{t("off")}</Badge>
            </div>
            <div className="mt-4 flex items-center gap-3">
              <button type="button" className={primaryBtn} disabled={busy} onClick={save}>{t("save")}</button>
            </div>
            <div className="mt-3"><Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} /></div>
          </div>
        </DesktopOnly>
        <p className="mt-3 text-theme-xs text-gray-500">{t("policyNote")}</p>
      </section>

      <section className={`${cardClass} min-w-0 p-5 sm:p-6`}>
        <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("connectionsTitle")}</h2>
        {CONNECTIONS.map((c) => (
          <div key={c} className={row}>
            <div className="min-w-0">
              <b className="block text-theme-sm">{t(`conn.${c}.name`)}</b>
              <span className="text-theme-xs text-gray-500">{t(`conn.${c}.desc`)}</span>
            </div>
            <Badge size="sm" color="light">{t("notConnected")}</Badge>
          </div>
        ))}
        <p className="mt-3 rounded-xl bg-[#eef5f2] px-4 py-3 text-theme-xs text-[#3d6654] dark:bg-brand-500/10 dark:text-brand-300">
          {t("statesNote")}
        </p>
      </section>
    </div>
  );
}
