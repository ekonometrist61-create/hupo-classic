"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { DEMO_JOURNEYS } from "./demoData";
import type { Channel, Journey, JourneyStep, JourneyTrigger } from "./types";
import { CHANNELS } from "./types";

const TRIGGERS: JourneyTrigger[] = ["veli_kayit", "ilk_gorev_bekleyen", "yenileme_yaklasan", "pasif_7_gun"];
const CRITERIA = ["ilk_gorev_tamamlandi", "abonelik_aktif", "izin_var"] as const;
const STATUS_COLOR = { taslak: "light", hazir: "success", duraklatildi: "warning" } as const;

const TEMPLATE: JourneyStep[] = [
  { tur: "bekle", saat: 24 },
  { tur: "kosul", olcut: "ilk_gorev_tamamlandi" },
  { tur: "mesaj", kanal: "eposta", baslik: "Başlangıç rehberi" },
];

type Ctx = { ilk_gorev_tamamlandi: boolean; abonelik_aktif: boolean; izin_var: boolean };

/** Kuru çalıştırma: yalnızca tanımı yürütür, hiçbir mesaj üretmez/göndermez.
 *  Kurallar: ilk_gorev_tamamlandi / abonelik_aktif sağlanırsa HEDEF ULAŞILDI → çıkış;
 *  izin_var sağlanmazsa mesaj atlanmaz, akış İZİN YOK nedeniyle çıkar. */
export function dryRun(steps: JourneyStep[], ctx: Ctx): { kind: string; vars?: Record<string, string | number> }[] {
  const out: { kind: string; vars?: Record<string, string | number> }[] = [{ kind: "start" }];
  for (const s of steps) {
    if (s.tur === "bekle") {
      out.push({ kind: "wait", vars: { h: s.saat } });
    } else if (s.tur === "kosul") {
      const ok = ctx[s.olcut];
      if (s.olcut === "izin_var") {
        out.push({ kind: ok ? "consentOk" : "consentNo" });
        if (!ok) return out;
      } else {
        out.push({ kind: ok ? `goal_${s.olcut}` : `nogoal_${s.olcut}` });
        if (ok) return out;
      }
    } else {
      out.push({ kind: "message", vars: { channel: s.kanal, title: s.baslik } });
    }
  }
  out.push({ kind: "end" });
  return out;
}

export default function JourneysManager() {
  const t = useTranslations("yonetim.merkez.journeys");
  const list = useAdminRpc<Journey[]>("admin_otomasyon_listele", undefined, { demo: DEMO_JOURNEYS });
  const [selected, setSelected] = useState<Journey | "new" | null>(null);

  return (
    <div className="space-y-6">
      <div className="rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 text-theme-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-orange-400">
        <b>{t("workerTitle")}</b> {t("workerText")}
      </div>

      <div className="grid gap-6 xl:grid-cols-[minmax(260px,1fr)_minmax(0,2fr)]">
        <section className={`${cardClass} p-5 sm:p-6`}>
          <div className="mb-3 flex items-center justify-between gap-2">
            <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("listTitle")}</h2>
            <button type="button" className={primaryBtn} onClick={() => setSelected("new")}>{t("create")}</button>
          </div>
          <RpcBoundary state={list}>
            {(rows) =>
              rows.length === 0 ? (
                <p className="py-6 text-center text-sm text-gray-500">{t("empty")}</p>
              ) : (
                <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                  {rows.map((j) => (
                    <li key={j.id}>
                      <button
                        type="button"
                        onClick={() => setSelected(j)}
                        aria-current={selected !== "new" && selected?.id === j.id ? "true" : undefined}
                        className="flex w-full items-center justify-between gap-3 py-3 text-start hover:text-brand-500"
                      >
                        <span className="min-w-0">
                          <b className="block truncate text-theme-sm">{j.ad}</b>
                          <span className="text-theme-xs text-gray-500">{t(`triggers.${j.giris_olayi}`)}</span>
                        </span>
                        <Badge size="sm" color={STATUS_COLOR[j.durum]}>{t(`status.${j.durum}`)}</Badge>
                      </button>
                    </li>
                  ))}
                </ul>
              )
            }
          </RpcBoundary>
        </section>

        {selected ? (
          <Builder
            key={selected === "new" ? "new" : `${selected.id}-${selected.surum}`}
            initial={selected === "new" ? null : selected}
            onSaved={() => {
              setSelected(null);
              list.reload();
            }}
            onStatus={() => list.reload()}
          />
        ) : (
          <section className={`${cardClass} flex items-center justify-center p-10 text-center text-sm text-gray-500`}>
            {t("pick")}
          </section>
        )}
      </div>
    </div>
  );
}

function Builder({
  initial,
  onSaved,
  onStatus,
}: {
  initial: Journey | null;
  onSaved: () => void;
  onStatus: () => void;
}) {
  const t = useTranslations("yonetim.merkez.journeys");
  const [ad, setAd] = useState(initial?.ad ?? "");
  const [giris, setGiris] = useState<JourneyTrigger>(initial?.giris_olayi ?? "veli_kayit");
  const [steps, setSteps] = useState<JourneyStep[]>(initial?.adimlar ?? TEMPLATE);
  const [ctx, setCtx] = useState<Ctx>({ ilk_gorev_tamamlandi: false, abonelik_aktif: false, izin_var: true });
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);
  const [busy, setBusy] = useState(false);
  const [simulated, setSimulated] = useState<ReturnType<typeof dryRun> | null>(null);

  const patch = (i: number, p: JourneyStep) => setSteps((s) => s.map((x, k) => (k === i ? p : x)));
  const move = (i: number, d: number) =>
    setSteps((s) => {
      const j = i + d;
      if (j < 0 || j >= s.length) return s;
      const c = [...s];
      [c[i], c[j]] = [c[j], c[i]];
      return c;
    });

  const save = async () => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_otomasyon_kaydet", {
      p_id: initial?.id ?? null,
      p_ad: ad,
      p_giris_olayi: giris,
      p_adimlar: steps,
    });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    onSaved();
  };

  const setStatus = async (durum: "hazir" | "duraklatildi" | "taslak") => {
    if (!initial) return;
    const r = await adminCall("admin_otomasyon_durum", { p_id: initial.id, p_durum: durum });
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("statusSaved") });
    onStatus();
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <div className="mb-4 grid gap-4 sm:grid-cols-2">
        <div>
          <label className={labelClass} htmlFor="j-ad">{t("form.name")}</label>
          <input id="j-ad" className={inputClass} value={ad} maxLength={120} onChange={(e) => setAd(e.target.value)} />
        </div>
        <div>
          <label className={labelClass} htmlFor="j-tr">{t("form.trigger")}</label>
          <select id="j-tr" className={inputClass} value={giris} onChange={(e) => setGiris(e.target.value as JourneyTrigger)}>
            {TRIGGERS.map((x) => <option key={x} value={x}>{t(`triggers.${x}`)}</option>)}
          </select>
        </div>
      </div>

      <ol className="rounded-xl bg-[radial-gradient(#cedbd6_1px,transparent_1px)] bg-size-[18px_18px] bg-[#f9fbfa] p-5 dark:bg-white/3">
        <li className="mx-auto max-w-sm rounded-xl border border-gray-200 border-s-4 border-s-brand-500 bg-white p-4 dark:border-gray-800 dark:bg-gray-900">
          <small className="text-[10px] text-gray-500">{t("form.entry")}</small>
          <b className="block text-theme-sm">{t(`triggers.${giris}`)}</b>
        </li>
        {steps.map((s, i) => (
          <li key={i} className="mx-auto max-w-sm">
            <div className="mx-auto h-5 w-px bg-brand-300" aria-hidden />
            <div className={`rounded-xl border bg-white p-4 dark:bg-gray-900 ${s.tur === "kosul" ? "border-gold-500" : "border-gray-200 dark:border-gray-800"}`}>
              <div className="mb-2 flex items-center justify-between">
                <small className="text-[10px] font-semibold text-gray-500">{t(`stepTypes.${s.tur}`).toLocaleUpperCase("tr")}</small>
                <span className="flex gap-3 text-theme-xs font-medium">
                  <button type="button" className="text-brand-500" onClick={() => move(i, -1)} aria-label={t("form.up")}>↑</button>
                  <button type="button" className="text-brand-500" onClick={() => move(i, 1)} aria-label={t("form.down")}>↓</button>
                  <button type="button" className="text-error-600" onClick={() => setSteps((x) => x.filter((_, k) => k !== i))}>{t("form.remove")}</button>
                </span>
              </div>
              {s.tur === "bekle" && (
                <label className="flex items-center gap-2 text-theme-sm">
                  <input
                    type="number" min={1} max={720} className="h-9 w-20 rounded-lg border border-gray-300 bg-transparent px-2 dark:border-gray-700"
                    value={s.saat} aria-label={t("form.hours")}
                    onChange={(e) => patch(i, { tur: "bekle", saat: Number(e.target.value) })}
                  />
                  {t("form.hoursSuffix")}
                </label>
              )}
              {s.tur === "kosul" && (
                <select
                  className={inputClass} value={s.olcut} aria-label={t("form.criterion")}
                  onChange={(e) => patch(i, { tur: "kosul", olcut: e.target.value as (typeof CRITERIA)[number] })}
                >
                  {CRITERIA.map((c) => <option key={c} value={c}>{t(`criteria.${c}`)}</option>)}
                </select>
              )}
              {s.tur === "mesaj" && (
                <div className="space-y-2">
                  <select
                    className={inputClass} value={s.kanal} aria-label={t("form.channel")}
                    onChange={(e) => patch(i, { ...s, kanal: e.target.value as Channel })}
                  >
                    {CHANNELS.map((c) => <option key={c} value={c}>{t(`channels.${c}`)}</option>)}
                  </select>
                  <input
                    className={inputClass} value={s.baslik} maxLength={100} aria-label={t("form.messageTitle")}
                    placeholder={t("form.messageTitle")}
                    onChange={(e) => patch(i, { ...s, baslik: e.target.value })}
                  />
                </div>
              )}
            </div>
          </li>
        ))}
      </ol>

      <div className="mt-3 flex flex-wrap gap-2">
        <button type="button" className={`${outlineBtn} px-3! py-1.5! text-theme-xs!`} onClick={() => setSteps([...steps, { tur: "bekle", saat: 24 }])}>+ {t("stepTypes.bekle")}</button>
        <button type="button" className={`${outlineBtn} px-3! py-1.5! text-theme-xs!`} onClick={() => setSteps([...steps, { tur: "kosul", olcut: "ilk_gorev_tamamlandi" }])}>+ {t("stepTypes.kosul")}</button>
        <button type="button" className={`${outlineBtn} px-3! py-1.5! text-theme-xs!`} onClick={() => setSteps([...steps, { tur: "mesaj", kanal: "eposta", baslik: "" }])}>+ {t("stepTypes.mesaj")}</button>
      </div>

      <div className="mt-6 rounded-xl border border-gray-200 p-4 dark:border-gray-800">
        <h3 className="mb-2 text-theme-sm font-semibold">{t("dry.title")}</h3>
        <p className="mb-3 text-theme-xs text-gray-500">{t("dry.note")}</p>
        <div className="flex flex-wrap gap-5 text-theme-sm">
          {CRITERIA.map((c) => (
            <label key={c} className="flex items-center gap-2">
              <input
                type="checkbox" className="size-4 accent-brand-500" checked={ctx[c]}
                onChange={(e) => setCtx({ ...ctx, [c]: e.target.checked })}
              />
              {t(`dry.ctx.${c}`)}
            </label>
          ))}
        </div>
        <button type="button" className={`${outlineBtn} mt-3`} onClick={() => setSimulated(dryRun(steps, ctx))}>{t("dry.run")}</button>
        {simulated && (
          <ol className="mt-3 list-decimal space-y-1 ps-5 text-theme-sm" aria-live="polite">
            {simulated.map((l, i) => <li key={i}>{t(`dry.lines.${l.kind}`, l.vars)}</li>)}
          </ol>
        )}
      </div>

      <div className="mt-4"><Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} /></div>
      <div className="mt-4 flex flex-wrap items-center gap-3">
        <button type="button" className={primaryBtn} disabled={busy || ad.trim().length < 2} onClick={save}>{t("form.save")}</button>
        {initial && initial.durum !== "hazir" && (
          <button type="button" className={outlineBtn} onClick={() => setStatus("hazir")}>{t("form.markReady")}</button>
        )}
        {initial && initial.durum === "hazir" && (
          <button type="button" className={outlineBtn} onClick={() => setStatus("duraklatildi")}>{t("form.pause")}</button>
        )}
        {initial && initial.durum === "duraklatildi" && (
          <button type="button" className={outlineBtn} onClick={() => setStatus("taslak")}>{t("form.backToDraft")}</button>
        )}
      </div>
      <p className="mt-3 text-theme-xs text-gray-500">{t("form.saveNote")}</p>
    </section>
  );
}
