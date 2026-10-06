"use client";

import { useState } from "react";
import { useSearchParams } from "next/navigation";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { Modal } from "@/components/ui/modal";
import { Link } from "@/i18n/navigation";
import { formatDateTime } from "@/utils/format";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn, tdClass, thClass } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { DEMO_CAMPAIGNS, DEMO_SEGMENTS, DEMO_SETTINGS } from "./demoData";
import type {
  CampaignStatus,
  Channel,
  IletisimAyarlari,
  IletisimKampanya,
  PreflightResult,
  Segment,
} from "./types";
import { CHANNELS } from "./types";

const STATUS_COLOR: Record<CampaignStatus, "light" | "info" | "success" | "error"> = {
  taslak: "light",
  kontrol_edildi: "info",
  planlandi: "success",
  iptal: "error",
};

/** `datetime-local` değeri (cihaz saati) → ISO. */
function toIso(local: string): string | null {
  const d = new Date(local);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function defaultLocalTime(): string {
  const d = new Date(Date.now() + 24 * 3600 * 1000);
  d.setHours(12, 0, 0, 0);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export default function CampaignsManager() {
  const t = useTranslations("yonetim.merkez.campaigns");
  const params = useSearchParams();
  const preSegment = params.get("segment");

  const list = useAdminRpc<IletisimKampanya[]>("admin_kampanya_listele", undefined, { demo: DEMO_CAMPAIGNS });
  const segments = useAdminRpc<Segment[]>("admin_segment_listele", undefined, { demo: DEMO_SEGMENTS });
  const settings = useAdminRpc<IletisimAyarlari>("admin_iletisim_ayarlari_getir", undefined, { demo: DEMO_SETTINGS });

  const [composeFor, setComposeFor] = useState<IletisimKampanya | "new" | null>(preSegment ? "new" : null);
  const [preflightFor, setPreflightFor] = useState<IletisimKampanya | null>(null);
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);

  const cancel = async (c: IletisimKampanya) => {
    const r = await adminCall("admin_kampanya_iptal", { p_id: c.id });
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("cancelled") });
    list.reload();
  };

  return (
    <div className="space-y-6">
      <div className="rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 text-theme-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-orange-400">
        <b>{t("workerTitle")}</b> {t("workerText")}
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <section className={`${cardClass} p-5 sm:p-6`}>
          <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("rhythmTitle")}</h2>
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("rhythmDesc")}</p>
          <div className="mt-3 flex flex-wrap gap-2">
            {CHANNELS.map((c) => (
              <Badge key={c} size="sm" color={c === "eposta" ? "info" : c === "push" ? "primary" : "light"}>
                {t(`channels.${c}`)}
              </Badge>
            ))}
          </div>
        </section>
        <section className={`${cardClass} p-5 sm:p-6`}>
          <div className="flex items-start justify-between gap-3">
            <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("policyTitle")}</h2>
            <Link href="/yonetim/kanal-ayarlari" className="text-theme-xs font-medium text-brand-500 hover:text-brand-600">
              {t("policyEdit")}
            </Link>
          </div>
          <RpcBoundary state={settings}>
            {(s) => (
              <dl className="mt-2 divide-y divide-gray-100 text-theme-sm dark:divide-gray-800">
                <div className="flex justify-between py-2"><dt>{t("weeklyLimit")}</dt><dd className="font-semibold">{s.haftalik_limit}</dd></div>
                <div className="flex justify-between py-2"><dt>{t("quietHours")}</dt><dd className="font-semibold">{s.sessiz_baslangic}–{s.sessiz_bitis}</dd></div>
              </dl>
            )}
          </RpcBoundary>
        </section>
      </div>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
          <h2 className="text-lg font-semibold text-navy dark:text-white/90">{t("listTitle")}</h2>
          <button type="button" className={primaryBtn} onClick={() => setComposeFor("new")}>
            {t("create")}
          </button>
        </div>
        <Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} />
        <RpcBoundary state={list}>
          {(rows) =>
            rows.length === 0 ? (
              <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <thead>
                    <tr>
                      <th className={thClass}>{t("cols.name")}</th>
                      <th className={thClass}>{t("cols.channel")}</th>
                      <th className={thClass}>{t("cols.segment")}</th>
                      <th className={thClass}>{t("cols.status")}</th>
                      <th className={thClass}>{t("cols.time")}</th>
                      <th className={thClass} />
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {rows.map((c) => (
                      <tr key={c.id}>
                        <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{c.ad}</td>
                        <td className={tdClass}>{t(`channels.${c.kanal}`)}</td>
                        <td className={tdClass}>{c.segment_ad}</td>
                        <td className={tdClass}>
                          <Badge size="sm" color={STATUS_COLOR[c.durum]}>{t(`status.${c.durum}`)}</Badge>
                        </td>
                        <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(c.planlanan_at)}</td>
                        <td className={`${tdClass} whitespace-nowrap text-end`}>
                          <span className="flex justify-end gap-3 text-theme-sm font-medium">
                            {(c.durum === "taslak" || c.durum === "kontrol_edildi") && (
                              <>
                                <button type="button" className="text-brand-500 hover:text-brand-600" onClick={() => setComposeFor(c)}>
                                  {t("edit")}
                                </button>
                                <button type="button" className="text-brand-500 hover:text-brand-600" onClick={() => setPreflightFor(c)}>
                                  {t("preflight")}
                                </button>
                              </>
                            )}
                            {c.durum !== "iptal" && (
                              <button type="button" className="text-error-600 hover:text-error-700" onClick={() => cancel(c)}>
                                {t("cancel")}
                              </button>
                            )}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )
          }
        </RpcBoundary>
      </section>

      {composeFor && (
        <Compose
          key={composeFor === "new" ? "new" : composeFor.id}
          initial={composeFor === "new" ? null : composeFor}
          segments={segments.data ?? []}
          presetSegment={preSegment}
          onClose={() => setComposeFor(null)}
          onSaved={() => {
            setComposeFor(null);
            list.reload();
          }}
        />
      )}
      {preflightFor && (
        <Preflight
          key={preflightFor.id}
          campaign={preflightFor}
          onClose={() => setPreflightFor(null)}
          onChanged={() => list.reload()}
        />
      )}
    </div>
  );
}

function Compose({
  initial,
  segments,
  presetSegment,
  onClose,
  onSaved,
}: {
  initial: IletisimKampanya | null;
  segments: Segment[];
  presetSegment: string | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const t = useTranslations("yonetim.merkez.campaigns");
  const [ad, setAd] = useState(initial?.ad ?? "");
  const [kanal, setKanal] = useState<Channel>(initial?.kanal ?? "eposta");
  const [segmentId, setSegmentId] = useState(initial?.segment_id ?? presetSegment ?? segments[0]?.id ?? "");
  const [baslik, setBaslik] = useState(initial?.baslik ?? "");
  const [mesaj, setMesaj] = useState(initial?.mesaj ?? "");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const save = async () => {
    setBusy(true);
    setError(null);
    const r = await adminCall("admin_kampanya_kaydet", {
      p_id: initial?.id ?? null,
      p_ad: ad,
      p_kanal: kanal,
      p_segment_id: segmentId,
      p_baslik: baslik,
      p_mesaj: mesaj,
    });
    setBusy(false);
    if (r.error) return setError(r.error === "DEMO" ? t("demo") : r.error);
    onSaved();
  };

  return (
    <Modal isOpen onClose={onClose} className="m-4 max-w-4xl p-6 sm:p-8">
      <h3 className="mb-5 pe-12 text-lg font-semibold text-gray-800 dark:text-white/90">
        {initial ? t("editTitle") : t("newTitle")}
      </h3>
      <div className="grid gap-6 md:grid-cols-[1.25fr_1fr]">
        <div className="space-y-4">
          <div>
            <label className={labelClass} htmlFor="c-ad">{t("form.name")}</label>
            <input id="c-ad" className={inputClass} value={ad} maxLength={80} onChange={(e) => setAd(e.target.value)} />
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className={labelClass} htmlFor="c-kanal">{t("form.channel")}</label>
              <select id="c-kanal" className={inputClass} value={kanal} onChange={(e) => setKanal(e.target.value as Channel)}>
                {CHANNELS.map((c) => <option key={c} value={c}>{t(`channels.${c}`)}</option>)}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="c-seg">{t("form.segment")}</label>
              <select id="c-seg" className={inputClass} value={segmentId} onChange={(e) => setSegmentId(e.target.value)}>
                {segments.length === 0 && <option value="">{t("form.noSegment")}</option>}
                {segments.map((s) => <option key={s.id} value={s.id}>{s.ad}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className={labelClass} htmlFor="c-baslik">{t("form.title")}</label>
            <input id="c-baslik" className={inputClass} value={baslik} maxLength={100} onChange={(e) => setBaslik(e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="c-mesaj">{t("form.message")}</label>
            <textarea id="c-mesaj" className={`${inputClass} h-28 py-2.5`} value={mesaj} maxLength={1000} onChange={(e) => setMesaj(e.target.value)} />
          </div>
          {error && <Feedback kind="error" message={error} />}
          <div className="flex gap-3">
            <button type="button" className={primaryBtn} disabled={busy || !ad.trim() || !baslik.trim() || !mesaj.trim() || !segmentId} onClick={save}>
              {t("form.save")}
            </button>
            <button type="button" className={outlineBtn} onClick={onClose}>{t("form.close")}</button>
          </div>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("form.draftNote")}</p>
        </div>

        <div>
          <div className="mx-auto min-h-72 w-64 rounded-[34px] border-[7px] border-navy bg-[#eaf0ec] px-4 py-6 dark:bg-gray-800" aria-label={t("form.previewLabel")}>
            <div className="mx-auto -mt-3 mb-6 h-2 w-16 rounded-full bg-navy" />
            <div className="rounded-2xl bg-white p-4 shadow-theme-md dark:bg-gray-900">
              <small className="text-[10px] font-semibold text-brand-500">HUPOLINGO · {t(`channels.${kanal}`).toLocaleUpperCase("tr")}</small>
              <h4 className="mt-2 mb-1 text-theme-sm font-semibold break-words">{baslik || t("form.titleSample")}</h4>
              <p className="text-theme-xs break-words text-gray-600 dark:text-gray-400">{mesaj || t("form.messageSample")}</p>
            </div>
            <p className="mt-10 text-center text-[11px] text-gray-500">{t("form.previewFooter")}</p>
          </div>
        </div>
      </div>
    </Modal>
  );
}

function Preflight({
  campaign,
  onClose,
  onChanged,
}: {
  campaign: IletisimKampanya;
  onClose: () => void;
  onChanged: () => void;
}) {
  const t = useTranslations("yonetim.merkez.campaigns");
  const [when, setWhen] = useState(defaultLocalTime());
  const [result, setResult] = useState<PreflightResult | null>(campaign.onkontrol);
  const [busy, setBusy] = useState(false);
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);
  const [planned, setPlanned] = useState(false);

  const run = async () => {
    const iso = toIso(when);
    if (!iso) return;
    setBusy(true);
    setFb(null);
    const r = await adminCall<PreflightResult>("admin_kampanya_on_kontrol", {
      p_id: campaign.id,
      p_planlanan_at: iso,
    });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setResult(r.data);
    onChanged();
  };

  const plan = async () => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_kampanya_planla", { p_id: campaign.id });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setPlanned(true);
    setFb({ kind: "ok", msg: t("preflightPlanned") });
    onChanged();
  };

  const canPlan = result && !result.sessiz_saat && result.gonderilecek > 0 && !planned;

  return (
    <Modal isOpen onClose={onClose} className="m-4 max-w-lg p-6 sm:p-8">
      <h3 className="mb-1 pe-12 text-lg font-semibold text-gray-800 dark:text-white/90">{t("preflightTitle")}</h3>
      <p className="mb-4 text-theme-sm text-gray-500">{campaign.ad}</p>
      <div className="space-y-4">
        <div>
          <label className={labelClass} htmlFor="pf-when">{t("preflightWhen")}</label>
          <input id="pf-when" type="datetime-local" className={inputClass} value={when} onChange={(e) => setWhen(e.target.value)} />
        </div>
        <button type="button" className={outlineBtn} disabled={busy} onClick={run}>
          {result ? t("preflightRerun") : t("preflightRun")}
        </button>

        {result && (
          <dl className="divide-y divide-gray-100 rounded-xl border border-gray-200 text-theme-sm dark:divide-gray-800 dark:border-gray-800">
            {[
              [t("pf.target"), result.hedef],
              [t("pf.consented"), result.izinli],
              [t("pf.noConsent"), result.izin_haric],
              [t("pf.limit", { n: result.haftalik_limit }), result.sinir_haric],
              [t("pf.willSend"), result.gonderilecek],
            ].map(([k, v]) => (
              <div key={String(k)} className="flex justify-between px-4 py-3">
                <dt>{k}</dt>
                <dd className="font-semibold">{Number(v).toLocaleString("tr-TR")}</dd>
              </div>
            ))}
            <div className="flex justify-between px-4 py-3">
              <dt>{t("pf.quiet")}</dt>
              <dd>
                <Badge size="sm" color={result.sessiz_saat ? "error" : "success"}>
                  {result.sessiz_saat ? t("pf.quietYes") : t("pf.quietNo")}
                </Badge>
              </dd>
            </div>
          </dl>
        )}
        <Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} />
        <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("preflightNote")}</p>
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>{t("form.close")}</button>
          <button type="button" className={primaryBtn} disabled={busy || !canPlan} onClick={plan}>
            {t("preflightPlan")}
          </button>
        </div>
      </div>
    </Modal>
  );
}
