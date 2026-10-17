"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { Link } from "@/i18n/navigation";
import { formatDateTime } from "@/utils/format";
import { DEMO_CAMPAIGNS, DEMO_SEGMENT_PREVIEW, DEMO_SEGMENTS } from "../merkez/demoData";
import type { CampaignStatus, IletisimKampanya, PreflightResult, Segment, SegmentPreview } from "../merkez/types";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

const STATUS_COLOR: Record<CampaignStatus, "light" | "info" | "success" | "error"> = {
  taslak: "light",
  kontrol_edildi: "info",
  planlandi: "success",
  gonderildi: "success",
  iptal: "error",
};

const BASLIK_MAX = 100;
const MESAJ_MAX = 1000;
const AD_MIN = 2;
/** Sunucudaki planlama kuralı: en az 5 dakika sonrası. */
const MIN_DAKIKA = 5;
/** Sunucunun bildiği iptal nedenleri (kampanya_push_gonder). Bilinmeyen neden ham metin gösterilir. */
const IPTAL_NEDENLERI = ["segment_bos_veya_yok", "sessiz_saat", "yasal_kapi_kapali", "dagitim_hatasi"];

interface KapiDurum {
  durum: "kapali" | "onaylandi";
}

type Fb = { kind: "ok" | "error"; msg: string } | null;

/** datetime-local değeri (cihaz saati) → ISO. */
function toIso(local: string): string | null {
  const d = new Date(local);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

/** Verilen anın datetime-local biçimindeki yerel metni. */
function yerelZaman(ms: number): string {
  const d = new Date(ms);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/** Segmente push bildirimi: taslak → ön kontrol → planla. Dağıtımı sunucudaki dakikalık iş yapar. */
export default function SegmentliBildirim() {
  const t = useTranslations("yonetim.bildirimler.segmentli");
  const segments = useAdminRpc<Segment[]>("admin_segment_listele", undefined, { demo: DEMO_SEGMENTS });
  const kapi = useAdminRpc<KapiDurum>("admin_pazarlama_push_kapisi_getir", undefined, { demo: { durum: "kapali" } });
  const campaigns = useAdminRpc<IletisimKampanya[]>("admin_kampanya_listele", undefined, { demo: DEMO_CAMPAIGNS });

  const [segmentId, setSegmentId] = useState("");
  const [ad, setAd] = useState("");
  const [baslik, setBaslik] = useState("");
  const [mesaj, setMesaj] = useState("");
  const [zaman, setZaman] = useState(() => yerelZaman(Date.now() + 30 * 60 * 1000));
  const [enErkenZaman] = useState(() => yerelZaman(Date.now() + (MIN_DAKIKA + 1) * 60 * 1000));
  const [taslakId, setTaslakId] = useState<string | null>(null);
  const [sonuc, setSonuc] = useState<PreflightResult | null>(null);
  const [busy, setBusy] = useState(false);
  const [fb, setFb] = useState<Fb>(null);

  const secili = segments.data?.find((s) => s.id === segmentId) ?? null;
  const preview = useAdminRpc<SegmentPreview>(
    "admin_segment_onizle",
    secili ? { p_kriterler: secili.kriterler, p_kanal: "push" } : undefined,
    { enabled: secili !== null, demo: DEMO_SEGMENT_PREVIEW },
  );

  /** Girdi değişince önceki ön kontrol geçersiz sayılır; planlama yeniden ön kontrol ister. */
  const girdiDegisti = () => {
    setSonuc(null);
    setFb(null);
  };

  const hataMetni = (e: string) => (e === "DEMO" ? t("demo") : e);

  const onKontrol = async () => {
    const iso = toIso(zaman);
    if (!secili) return setFb({ kind: "error", msg: t("errSegment") });
    if (ad.trim().length < AD_MIN) return setFb({ kind: "error", msg: t("errName") });
    if (!baslik.trim() || baslik.length > BASLIK_MAX) return setFb({ kind: "error", msg: t("errTitle") });
    if (!mesaj.trim() || mesaj.length > MESAJ_MAX) return setFb({ kind: "error", msg: t("errMessage") });
    if (!iso) return setFb({ kind: "error", msg: t("errWhen") });

    setBusy(true);
    setFb(null);
    const k = await adminCall<string>("admin_kampanya_kaydet", {
      p_id: taslakId,
      p_ad: ad.trim(),
      p_kanal: "push",
      p_segment_id: secili.id,
      p_baslik: baslik.trim(),
      p_mesaj: mesaj.trim(),
    });
    if (k.error || !k.data) {
      setBusy(false);
      return setFb({ kind: "error", msg: hataMetni(k.error ?? t("errSave")) });
    }
    const r = await adminCall<PreflightResult>("admin_kampanya_on_kontrol", { p_id: k.data, p_planlanan_at: iso });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: hataMetni(r.error) });
    setTaslakId(k.data);
    setSonuc(r.data);
    campaigns.reload();
  };

  const planlanabilir = sonuc !== null && sonuc.kapi_acik === true && !sonuc.sessiz_saat && sonuc.gonderilecek > 0;
  const planEngeli = sonuc === null || planlanabilir
    ? null
    : sonuc.kapi_acik !== true
      ? t("planBlockedGate")
      : sonuc.sessiz_saat
        ? t("planBlockedQuiet")
        : t("planBlockedNone");

  const planla = async () => {
    if (!taslakId) return;
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_kampanya_planla", { p_id: taslakId });
    setBusy(false);
    if (r.error) return setFb({ kind: "error", msg: hataMetni(r.error) });
    setFb({ kind: "ok", msg: t("planned") });
    setTaslakId(null);
    setSonuc(null);
    setAd("");
    setBaslik("");
    setMesaj("");
    campaigns.reload();
  };

  const kampanyaNotu = (c: IletisimKampanya): string | null => {
    const neden = c.onkontrol?.iptal_nedeni;
    if (c.durum === "iptal" && neden) {
      return IPTAL_NEDENLERI.includes(neden) ? t(`iptalNedeni.${neden}`) : neden;
    }
    if (c.durum === "gonderildi" && c.onkontrol?.alici_sayisi !== undefined) {
      return t("recipients", { n: c.onkontrol.alici_sayisi });
    }
    return null;
  };

  return (
    <div className="space-y-6">
      {/* Pazarlama push kapısı: kapalıyken hazırlık yapılır, planlama ve gönderim yapılmaz. */}
      <RpcBoundary state={kapi}>
        {(d) =>
          d.durum === "onaylandi" ? (
            <div role="status" className="rounded-2xl border border-green-200 bg-green-50 px-5 py-4 text-theme-sm text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-400">
              <b>{t("gateOpenTitle")}</b> {t("gateOpenText")}
            </div>
          ) : (
            <div role="status" className="rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 text-theme-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-orange-400">
              <b>{t("gateClosedTitle")}</b> {t("gateClosedText")}
            </div>
          )
        }
      </RpcBoundary>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("segmentTitle")}</h3>
        <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("kuralNotu")}</p>

        {segments.error && <Feedback kind="error" message={segments.error} />}
        <div className="mt-4 grid gap-4 sm:grid-cols-[1fr_auto] sm:items-end">
          <div>
            <label className={labelClass} htmlFor="sb-segment">{t("segment")}</label>
            <select
              id="sb-segment"
              className={inputClass}
              value={segmentId}
              onChange={(e) => {
                setSegmentId(e.target.value);
                girdiDegisti();
              }}
            >
              <option value="">{t("chooseSegment")}</option>
              {(segments.data ?? []).map((s) => (
                <option key={s.id} value={s.id}>{s.ad}</option>
              ))}
            </select>
          </div>
          <Link href="/yonetim/segmentler" className={outlineBtn}>{t("newSegment")}</Link>
        </div>

        {secili && (
          <RpcBoundary state={preview}>
            {(p) => (
              <dl className="mt-4 grid grid-cols-3 gap-3 rounded-xl border border-gray-200 p-4 text-center text-theme-sm dark:border-gray-800">
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("previewTotal")}</dt>
                  <dd className="text-lg font-semibold">{p.toplam.toLocaleString("tr-TR")}</dd>
                </div>
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("previewConsented")}</dt>
                  <dd className="text-lg font-semibold">{p.izinli.toLocaleString("tr-TR")}</dd>
                </div>
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("previewExcluded")}</dt>
                  <dd className="text-lg font-semibold">{p.haric.toLocaleString("tr-TR")}</dd>
                </div>
              </dl>
            )}
          </RpcBoundary>
        )}
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("messageTitle")}</h3>
        <div className="mt-4 space-y-4">
          <div>
            <label className={labelClass} htmlFor="sb-ad">{t("name")}</label>
            <input
              id="sb-ad"
              className={inputClass}
              maxLength={80}
              value={ad}
              onChange={(e) => {
                setAd(e.target.value);
                girdiDegisti();
              }}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="sb-baslik">{t("title")}</label>
            <input
              id="sb-baslik"
              className={inputClass}
              maxLength={BASLIK_MAX}
              value={baslik}
              onChange={(e) => {
                setBaslik(e.target.value);
                girdiDegisti();
              }}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="sb-mesaj">{t("message")}</label>
            <textarea
              id="sb-mesaj"
              className={`${inputClass} h-28 py-2.5`}
              maxLength={MESAJ_MAX}
              value={mesaj}
              onChange={(e) => {
                setMesaj(e.target.value);
                girdiDegisti();
              }}
            />
            <p className="mt-1 text-theme-xs text-gray-500">{mesaj.length}/{MESAJ_MAX}</p>
          </div>
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("channelInfo")}</p>
        </div>
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("timeTitle")}</h3>
        <div className="mt-4 max-w-sm">
          <label className={labelClass} htmlFor="sb-zaman">{t("when")}</label>
          <input
            id="sb-zaman"
            type="datetime-local"
            className={inputClass}
            min={enErkenZaman}
            value={zaman}
            onChange={(e) => {
              setZaman(e.target.value);
              girdiDegisti();
            }}
          />
          <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("whenNote")}</p>
        </div>

        <div className="mt-4 flex flex-wrap gap-3">
          <button type="button" className={primaryBtn} disabled={busy || !secili} onClick={onKontrol}>
            {t("check")}
          </button>
          {taslakId && (
            <button type="button" className={primaryBtn} disabled={busy || !planlanabilir} onClick={planla}>
              {t("plan")}
            </button>
          )}
        </div>
        <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("checkNote")}</p>

        {sonuc && (
          <div className="mt-5">
            <h4 className="mb-2 text-theme-sm font-semibold text-gray-800 dark:text-white/90">{t("resultTitle")}</h4>
            <dl className="divide-y divide-gray-100 rounded-xl border border-gray-200 text-theme-sm dark:divide-gray-800 dark:border-gray-800">
              {[
                [t("res.target"), sonuc.hedef],
                [t("res.consented"), sonuc.izinli],
                [t("res.noConsent"), sonuc.izin_haric],
                [t("res.limit"), sonuc.sinir_haric],
                [t("res.willSend"), sonuc.gonderilecek],
              ].map(([k, v]) => (
                <div key={String(k)} className="flex justify-between px-4 py-3">
                  <dt>{k}</dt>
                  <dd className="font-semibold">{Number(v).toLocaleString("tr-TR")}</dd>
                </div>
              ))}
              <div className="flex justify-between px-4 py-3">
                <dt>{t("res.quiet")}</dt>
                <dd>
                  <Badge size="sm" color={sonuc.sessiz_saat ? "error" : "success"}>
                    {sonuc.sessiz_saat ? t("quietYes") : t("quietNo")}
                  </Badge>
                </dd>
              </div>
              <div className="flex justify-between px-4 py-3">
                <dt>{t("res.gate")}</dt>
                <dd>
                  <Badge size="sm" color={sonuc.kapi_acik === true ? "success" : "error"}>
                    {sonuc.kapi_acik === true ? t("gateOpenBadge") : t("gateClosedBadge")}
                  </Badge>
                </dd>
              </div>
            </dl>
            {planEngeli && <div className="mt-3"><Feedback kind="error" message={planEngeli} /></div>}
          </div>
        )}

        <div className="mt-4"><Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} /></div>
      </section>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">{t("listTitle")}</h3>
        <RpcBoundary state={campaigns}>
          {(rows) => {
            const push = rows.filter((c) => c.kanal === "push");
            if (push.length === 0) {
              return <p className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>;
            }
            return (
              <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                {push.map((c) => (
                  <li key={c.id} className="flex flex-wrap items-start justify-between gap-3 py-4">
                    <div className="min-w-0">
                      <b className="block text-theme-sm wrap-break-word text-gray-800 dark:text-white/90">{c.ad}</b>
                      <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                        {c.segment_ad} · {formatDateTime(c.planlanan_at)}
                      </span>
                      {kampanyaNotu(c) && (
                        <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{kampanyaNotu(c)}</p>
                      )}
                    </div>
                    <Badge size="sm" color={STATUS_COLOR[c.durum]}>{t(`status.${c.durum}`)}</Badge>
                  </li>
                ))}
              </ul>
            );
          }}
        </RpcBoundary>
      </section>
    </div>
  );
}
