"use client";

import { useEffect, useMemo, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { Link } from "@/i18n/navigation";
import { DEMO_MODE } from "@/lib/demo-mode";
import { createClient } from "@/utils/supabase/client";
import useDebounced from "../panel/useDebounced";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { DEMO_SEGMENT_PREVIEW, DEMO_SEGMENTS } from "./demoData";
import type { Channel, Segment, SegmentCriteria, SegmentPreview } from "./types";
import { CHANNELS } from "./types";

const GRADES = [1, 2, 3, 4, 5, 6, 7, 8];
type PlanOpt = { kod: string; ad: string };

function usePlanOptions(): PlanOpt[] {
  const [plans, setPlans] = useState<PlanOpt[]>(
    DEMO_MODE ? [{ kod: "premium", ad: "Premium" }, { kod: "family", ad: "Family" }] : [],
  );
  useEffect(() => {
    if (DEMO_MODE) return;
    let cancelled = false;
    void createClient()
      .from("plans")
      .select("kod, ad")
      .order("sira", { ascending: true })
      .then(({ data }) => {
        if (!cancelled && data) setPlans(data as PlanOpt[]);
      });
    return () => {
      cancelled = true;
    };
  }, []);
  return plans;
}

function toggle<T>(list: T[] | undefined, v: T): T[] {
  const a = list ?? [];
  return a.includes(v) ? a.filter((x) => x !== v) : [...a, v];
}

/** Kriterleri API'ye göndermeden önce boş alanları temizler. */
function clean(c: SegmentCriteria): SegmentCriteria {
  const out: SegmentCriteria = {};
  if (c.plan?.length) out.plan = c.plan;
  if (c.sinif?.length) out.sinif = c.sinif;
  if (c.aktiflik) out.aktiflik = c.aktiflik;
  if (c.ilk_gorev_bekleyen) out.ilk_gorev_bekleyen = true;
  if (c.yenileme_yaklasan) out.yenileme_yaklasan = true;
  return out;
}

export function describeCriteria(
  c: SegmentCriteria,
  t: ReturnType<typeof useTranslations>,
  planName: (kod: string) => string,
): string[] {
  const out: string[] = [];
  if (c.plan?.length) out.push(t("chips.plan", { v: c.plan.map(planName).join(", ") }));
  if (c.sinif?.length) out.push(t("chips.grade", { v: c.sinif.join(", ") }));
  if (c.aktiflik) out.push(t(`activity.${c.aktiflik}`));
  if (c.ilk_gorev_bekleyen) out.push(t("firstTask"));
  if (c.yenileme_yaklasan) out.push(t("renewal"));
  return out;
}

export default function SegmentsManager() {
  const t = useTranslations("yonetim.merkez.segments");
  const plans = usePlanOptions();
  const planName = (kod: string) =>
    kod === "free" ? t("planFree") : (plans.find((p) => p.kod === kod)?.ad ?? kod);

  const [crit, setCrit] = useState<SegmentCriteria>({});
  const [channel, setChannel] = useState<Channel>("eposta");
  const [name, setName] = useState("");
  const [desc, setDesc] = useState("");
  const [editId, setEditId] = useState<string | null>(null);
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);
  const [busy, setBusy] = useState(false);

  const cleaned = useMemo(() => clean(crit), [crit]);
  const debounced = useDebounced(cleaned, 400);

  const preview = useAdminRpc<SegmentPreview>(
    "admin_segment_onizle",
    { p_kriterler: debounced, p_kanal: channel },
    { demo: DEMO_SEGMENT_PREVIEW },
  );
  const list = useAdminRpc<Segment[]>("admin_segment_listele", undefined, { demo: DEMO_SEGMENTS });

  const save = async () => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_segment_kaydet", {
      p_id: editId,
      p_ad: name,
      p_aciklama: desc || null,
      p_kriterler: cleaned,
    });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("saved") });
    setName("");
    setDesc("");
    setEditId(null);
    list.reload();
  };

  const archive = async (id: string) => {
    const r = await adminCall("admin_segment_arsivle", { p_id: id });
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("archived") });
    list.reload();
  };

  const edit = (s: Segment) => {
    setEditId(s.id);
    setName(s.ad);
    setDesc(s.aciklama ?? "");
    setCrit(s.kriterler);
    setFb(null);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const check = "size-4 accent-brand-500";

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-[minmax(0,1.8fr)_minmax(300px,1fr)]">
        <section className={`${cardClass} p-5 sm:p-6`}>
          <div className="mb-4 flex items-start justify-between gap-3">
            <div>
              <h2 className="text-lg font-semibold text-navy dark:text-white/90">
                {editId ? t("editTitle") : t("builderTitle")}
              </h2>
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("builderDesc")}</p>
            </div>
            <Badge size="sm" color="info">{t("live")}</Badge>
          </div>

          <div className="space-y-5 rounded-xl border border-gray-200 bg-gray-50/60 p-4 dark:border-gray-800 dark:bg-white/3">
            <fieldset>
              <legend className="mb-2 text-theme-sm font-semibold">{t("plan")}</legend>
              <div className="flex flex-wrap gap-4">
                {[{ kod: "free", ad: t("planFree") }, ...plans].map((p) => (
                  <label key={p.kod} className="flex items-center gap-2 text-theme-sm">
                    <input
                      type="checkbox"
                      className={check}
                      checked={crit.plan?.includes(p.kod) ?? false}
                      onChange={() => setCrit({ ...crit, plan: toggle(crit.plan, p.kod) })}
                    />
                    {p.ad}
                  </label>
                ))}
              </div>
            </fieldset>

            <fieldset>
              <legend className="mb-2 text-theme-sm font-semibold">{t("grade")}</legend>
              <div className="flex flex-wrap gap-4">
                {GRADES.map((g) => (
                  <label key={g} className="flex items-center gap-2 text-theme-sm">
                    <input
                      type="checkbox"
                      className={check}
                      checked={crit.sinif?.includes(g) ?? false}
                      onChange={() => setCrit({ ...crit, sinif: toggle(crit.sinif, g) })}
                    />
                    {g}
                  </label>
                ))}
              </div>
            </fieldset>

            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className={labelClass} htmlFor="seg-act">{t("activityLabel")}</label>
                <select
                  id="seg-act"
                  className={inputClass}
                  value={crit.aktiflik ?? ""}
                  onChange={(e) =>
                    setCrit({ ...crit, aktiflik: (e.target.value || undefined) as SegmentCriteria["aktiflik"] })
                  }
                >
                  <option value="">{t("activity.any")}</option>
                  <option value="aktif_7">{t("activity.aktif_7")}</option>
                  <option value="pasif_7">{t("activity.pasif_7")}</option>
                  <option value="pasif_30">{t("activity.pasif_30")}</option>
                </select>
              </div>
              <div>
                <label className={labelClass} htmlFor="seg-ch">{t("previewChannel")}</label>
                <select
                  id="seg-ch"
                  className={inputClass}
                  value={channel}
                  onChange={(e) => setChannel(e.target.value as Channel)}
                >
                  {CHANNELS.map((c) => (
                    <option key={c} value={c}>{t(`channels.${c}`)}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="flex flex-wrap gap-5">
              <label className="flex items-center gap-2 text-theme-sm">
                <input
                  type="checkbox"
                  className={check}
                  checked={crit.ilk_gorev_bekleyen ?? false}
                  onChange={(e) => setCrit({ ...crit, ilk_gorev_bekleyen: e.target.checked })}
                />
                {t("firstTask")}
              </label>
              <label className="flex items-center gap-2 text-theme-sm">
                <input
                  type="checkbox"
                  className={check}
                  checked={crit.yenileme_yaklasan ?? false}
                  onChange={(e) => setCrit({ ...crit, yenileme_yaklasan: e.target.checked })}
                />
                {t("renewal")}
              </label>
            </div>
          </div>

          <p className="mt-4 rounded-xl bg-[#eef5f2] px-4 py-3 text-theme-xs text-[#3d6654] dark:bg-brand-500/10 dark:text-brand-300">
            {t("rules")}
          </p>

          <div className="mt-5 grid gap-4 sm:grid-cols-2">
            <div>
              <label className={labelClass} htmlFor="seg-name">{t("name")}</label>
              <input id="seg-name" className={inputClass} value={name} maxLength={80} onChange={(e) => setName(e.target.value)} />
            </div>
            <div>
              <label className={labelClass} htmlFor="seg-desc">{t("description")}</label>
              <input id="seg-desc" className={inputClass} value={desc} onChange={(e) => setDesc(e.target.value)} />
            </div>
          </div>
          <div className="mt-4 flex flex-wrap items-center gap-3">
            <button type="button" className={primaryBtn} disabled={busy || name.trim().length < 2} onClick={save}>
              {editId ? t("update") : t("save")}
            </button>
            {editId && (
              <button
                type="button"
                className={outlineBtn}
                onClick={() => {
                  setEditId(null);
                  setName("");
                  setDesc("");
                  setCrit({});
                }}
              >
                {t("cancelEdit")}
              </button>
            )}
          </div>
          <div className="mt-3"><Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} /></div>
        </section>

        <aside className="space-y-6">
          <section className={`${cardClass} p-5 sm:p-6`} aria-live="polite">
            <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("summary")}</h2>
            <RpcBoundary state={preview}>
              {(p) => (
                <>
                  <div className="mt-2 text-[44px] leading-none font-semibold tracking-tight text-brand-500">
                    {p.toplam.toLocaleString("tr-TR")}
                  </div>
                  <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("matching")}</p>
                  <dl className="mt-3 divide-y divide-gray-100 text-theme-sm dark:divide-gray-800">
                    <div className="flex justify-between py-2.5">
                      <dt>{t("consented", { channel: t(`channels.${channel}`) })}</dt>
                      <dd className="font-semibold">{p.izinli.toLocaleString("tr-TR")}</dd>
                    </div>
                    <div className="flex justify-between py-2.5">
                      <dt>{t("excluded")}</dt>
                      <dd className="font-semibold">{p.haric.toLocaleString("tr-TR")}</dd>
                    </div>
                  </dl>
                  {p.ornek.length > 0 && (
                    <ul className="mt-3 space-y-1.5 text-theme-xs">
                      {p.ornek.map((o) => (
                        <li key={o.veli_id} className="flex items-center justify-between gap-2">
                          <span className="truncate">{o.ad ?? "—"}</span>
                          <Badge size="sm" color={o.izinli ? "success" : "light"}>
                            {o.izinli ? t("allowed") : t("notAllowed")}
                          </Badge>
                        </li>
                      ))}
                    </ul>
                  )}
                </>
              )}
            </RpcBoundary>
          </section>
          <section className={`${cardClass} p-5 text-theme-xs text-gray-500 dark:text-gray-400`}>
            <h3 className="mb-1 text-theme-sm font-semibold text-gray-800 dark:text-white/90">{t("starterTitle")}</h3>
            {t("starterText")}
          </section>
        </aside>
      </div>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h2 className="mb-4 text-lg font-semibold text-navy dark:text-white/90">{t("savedTitle")}</h2>
        <RpcBoundary state={list}>
          {(rows) =>
            rows.length === 0 ? (
              <p className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">{t("savedEmpty")}</p>
            ) : (
              <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((s) => (
                  <li key={s.id} className="flex flex-wrap items-center justify-between gap-3 py-4">
                    <div className="min-w-0">
                      <b className="block text-theme-sm text-gray-800 dark:text-white/90">{s.ad}</b>
                      {s.aciklama && <span className="text-theme-xs text-gray-500">{s.aciklama}</span>}
                      <div className="mt-1.5 flex flex-wrap gap-1.5">
                        {describeCriteria(s.kriterler, t, planName).map((c) => (
                          <Badge key={c} size="sm" color="light">{c}</Badge>
                        ))}
                      </div>
                    </div>
                    <div className="flex items-center gap-4 text-theme-sm">
                      <span>
                        <b>{s.veli_sayisi.toLocaleString("tr-TR")}</b>{" "}
                        <span className="text-gray-500">{t("families")}</span>
                        <span className="text-gray-400"> · {t("emailConsented", { n: s.izinli_eposta })}</span>
                      </span>
                      <button type="button" className="font-medium text-brand-500 hover:text-brand-600" onClick={() => edit(s)}>
                        {t("edit")}
                      </button>
                      <Link
                        href={`/yonetim/kampanyalar?segment=${s.id}`}
                        className="font-medium text-brand-500 hover:text-brand-600"
                      >
                        {t("toCampaign")}
                      </Link>
                      <button type="button" className="font-medium text-error-600 hover:text-error-700" onClick={() => archive(s.id)}>
                        {t("archive")}
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            )
          }
        </RpcBoundary>
      </section>
    </div>
  );
}
