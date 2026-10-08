"use client";

import { useEffect, useState } from "react";

import { Link } from "@/i18n/navigation";
import { formatDate, formatDateTime } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import type { ProspectDetay } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import {
  CONSENT_CHANNELS,
  CONSENT_CHIP,
  CONSENT_LABEL,
  Chip,
  KIND_LABEL,
  ProspectFormModal,
  STATUS_CHIP,
  STATUS_LABEL,
  prospectToForm,
  scoreTextClass,
} from "./prospectShared";
import { cardClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

const SCORE_BARS = [
  { key: "fit_score", label: "Uygunluk (fit)", max: 35 },
  { key: "intent_score", label: "Niyet (intent)", max: 35 },
  { key: "engagement_score", label: "Etkileşim (engagement)", max: 20 },
  { key: "data_quality_score", label: "Veri kalitesi (data quality)", max: 10 },
] as const;

const SECTION = `${cardClass} p-5 sm:p-6`;
const SECTION_TITLE = "mb-4 text-base font-semibold text-gray-800 dark:text-white/90";
const LIST_BACK = "/yonetim/potansiyel-adaylar";

function toPercent(confidence: number): number {
  return Math.round(confidence <= 1 ? confidence * 100 : confidence);
}

export default function PotansiyelAdayDetayManager({ prospectId }: { prospectId: string }) {
  const [detay, setDetay] = useState<ProspectDetay | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const [editing, setEditing] = useState(false);
  const [converting, setConverting] = useState(false);
  const [saving, setSaving] = useState(false);
  const [actionErr, setActionErr] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_prospect_detay", {
        p_prospect_id: prospectId,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setDetay(null);
      } else {
        setError(null);
        setDetay((data as ProspectDetay | null) ?? null);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [prospectId, reloadKey]);

  const reload = () => {
    setLoading(true);
    setReloadKey((k) => k + 1);
  };

  const convert = async () => {
    setSaving(true);
    setActionErr(null);
    const { error: err } = await createClient().rpc("admin_prospect_lead_donustur", {
      p_prospect_id: prospectId,
    });
    setSaving(false);
    if (err) return setActionErr(err.message);
    setConverting(false);
    reload();
  };

  if (loading) {
    return <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">Yükleniyor...</p>;
  }

  if (error) {
    return (
      <div className="space-y-4">
        <BackLink />
        <section className={`${SECTION} py-8 text-center`}>
          <ErrorNote message={error} />
          <button type="button" className={`${primaryBtn} mt-3`} onClick={reload}>
            Tekrar dene
          </button>
        </section>
      </div>
    );
  }

  if (!detay) {
    return (
      <div className="space-y-4">
        <BackLink />
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">Aday bulunamadı.</p>
      </div>
    );
  }

  const p = detay.prospect;
  const consents = detay.consents ?? [];
  const events = [...(detay.events ?? [])].sort((a, b) => b.created_at.localeCompare(a.created_at));
  const provenance = detay.provenance ?? [];
  const scoreHistory = [...(detay.score_history ?? [])].sort((a, b) => b.computed_at.localeCompare(a.computed_at));
  const alreadyConverted = p.status === "converted" || Boolean(p.converted_lead_id);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <BackLink />
        <div className="flex flex-wrap gap-3">
          <button type="button" className={outlineBtn} onClick={() => setEditing(true)}>
            Düzenle
          </button>
          <button
            type="button"
            className={primaryBtn}
            disabled={alreadyConverted}
            onClick={() => { setActionErr(null); setConverting(true); }}
          >
            {"Lead'e Dönüştür"}
          </button>
        </div>
      </div>

      <section className={SECTION}>
        <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
          <div className="min-w-0 flex-1 space-y-4">
            <div>
              <h2 className="text-xl font-semibold text-gray-800 dark:text-white/90">{p.display_name}</h2>
              <div className="mt-2 flex flex-wrap gap-2">
                <Chip className={STATUS_CHIP[p.status] ?? STATUS_CHIP.suppressed}>
                  {STATUS_LABEL[p.status] ?? p.status}
                </Chip>
                <Chip className="bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-white/80">
                  {KIND_LABEL[p.kind] ?? p.kind}
                </Chip>
              </div>
            </div>
            <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-2 text-theme-sm">
              <dt className="text-gray-500 dark:text-gray-400">E-posta</dt>
              <dd className="text-gray-800 dark:text-white/90">{p.email ?? "-"}</dd>
              <dt className="text-gray-500 dark:text-gray-400">Telefon</dt>
              <dd className="text-gray-800 dark:text-white/90">{p.phone ?? "-"}</dd>
              <dt className="text-gray-500 dark:text-gray-400">Kaynak</dt>
              <dd className="text-gray-800 dark:text-white/90">
                {p.source_type ?? "-"}
                {p.source_detail ? ` · ${p.source_detail}` : ""}
              </dd>
              <dt className="text-gray-500 dark:text-gray-400">UTM</dt>
              <dd className="text-gray-800 dark:text-white/90">
                {`kaynak: ${p.utm_source ?? "-"} · ortam: ${p.utm_medium ?? "-"} · kampanya: ${p.utm_campaign ?? "-"}`}
              </dd>
              <dt className="text-gray-500 dark:text-gray-400">Oluşturma</dt>
              <dd className="text-gray-800 dark:text-white/90">{formatDate(new Date(p.created_at))}</dd>
            </dl>
            {p.tags.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {p.tags.map((tag) => (
                  <Chip key={tag} className="bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-white/80">{tag}</Chip>
                ))}
              </div>
            )}
            {p.notes && (
              <p className="whitespace-pre-line rounded-lg bg-gray-50 px-3 py-2 text-theme-sm text-gray-700 dark:bg-white/5 dark:text-gray-300">
                {p.notes}
              </p>
            )}
          </div>

          <div className="w-full shrink-0 space-y-4 lg:w-80">
            <div className="text-center">
              <p className="text-theme-xs font-semibold tracking-wide text-gray-500 uppercase dark:text-gray-400">Toplam skor</p>
              <p className={`text-5xl font-bold ${scoreTextClass(p.total_score)}`}>{p.total_score}</p>
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">/ 100</p>
            </div>
            {SCORE_BARS.map((b) => {
              const value = p[b.key];
              const pct = Math.min(100, Math.max(0, (value / b.max) * 100));
              return (
                <div key={b.key}>
                  <div className="mb-1 flex justify-between text-theme-sm">
                    <span className="text-gray-600 dark:text-gray-400">{b.label}</span>
                    <span className="font-medium text-gray-800 dark:text-white/90">{`${value} / ${b.max}`}</span>
                  </div>
                  <div className="h-2 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-white/5">
                    <div className="h-full rounded-full bg-brand-500" style={{ width: `${pct}%` }} />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      <section className={SECTION}>
        <h3 className={SECTION_TITLE}>İzinler</h3>
        <p className="mb-4 text-theme-sm text-gray-600 dark:text-gray-400">
          Kanal izni olmayan, reddedilmiş veya süresi dolmuş kanallara iletişim gönderilmez.
        </p>
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
          {CONSENT_CHANNELS.map((ch) => {
            const c = consents.find((x) => x.channel === ch.key);
            const status = c?.status ?? "none";
            const blocked = status === "denied" || status === "expired";
            return (
              <div
                key={ch.key}
                className={`rounded-xl border p-4 ${
                  blocked
                    ? "border-red-200 bg-red-50/50 dark:border-red-500/30 dark:bg-red-500/5"
                    : "border-gray-200 dark:border-gray-800"
                }`}
              >
                <div className="flex items-center justify-between gap-2">
                  <span className="font-medium text-gray-800 dark:text-white/90">{ch.label}</span>
                  <Chip className={CONSENT_CHIP[status] ?? CONSENT_CHIP.none}>
                    {CONSENT_LABEL[status] ?? status}
                  </Chip>
                </div>
                <dl className="mt-3 space-y-1 text-theme-xs text-gray-600 dark:text-gray-400">
                  <div>{`Yasal dayanak: ${c?.legal_basis ?? "-"}`}</div>
                  <div>{`Verilme: ${c?.granted_at ? formatDate(new Date(c.granted_at)) : "-"}`}</div>
                  <div>{`Bitiş: ${c?.expires_at ? formatDate(new Date(c.expires_at)) : "-"}`}</div>
                </dl>
              </div>
            );
          })}
        </div>
      </section>

      <section className={SECTION}>
        <h3 className={SECTION_TITLE}>Olay Geçmişi</h3>
        {events.length === 0 ? (
          <p className="text-theme-sm text-gray-500 dark:text-gray-400">Henüz olay yok.</p>
        ) : (
          <ol className="space-y-3">
            {events.map((ev) => (
              <li key={ev.id} className="rounded-lg bg-gray-50 px-4 py-3 dark:bg-white/5">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div className="flex flex-wrap items-center gap-2">
                    <Chip className="bg-blue-50 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400">{ev.event_type}</Chip>
                    <span className="text-theme-sm font-medium text-gray-800 dark:text-white/90">{ev.event_name}</span>
                    {ev.channel && <span className="text-theme-xs text-gray-500 dark:text-gray-400">{ev.channel}</span>}
                  </div>
                  <span className="text-theme-xs text-gray-500 dark:text-gray-400">{formatDateTime(ev.created_at)}</span>
                </div>
                {Object.keys(ev.metadata ?? {}).length > 0 && (
                  <details className="mt-2">
                    <summary className="cursor-pointer text-theme-xs text-brand-500 dark:text-brand-400">Metadata</summary>
                    <pre className="mt-2 overflow-x-auto rounded-md bg-white p-2 text-theme-xs text-gray-700 dark:bg-gray-900 dark:text-gray-300">
                      {JSON.stringify(ev.metadata, null, 2)}
                    </pre>
                  </details>
                )}
              </li>
            ))}
          </ol>
        )}
      </section>

      <section className={SECTION}>
        <h3 className={SECTION_TITLE}>Kaynak Kanıtı (Provenance)</h3>
        {provenance.length === 0 ? (
          <p className="text-theme-sm text-gray-500 dark:text-gray-400">Kaynak kanıtı kaydı yok.</p>
        ) : (
          <div className="grid gap-4 md:grid-cols-2">
            {provenance.map((pv) => (
              <div key={pv.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <span className="font-medium text-gray-800 dark:text-white/90">{pv.provider}</span>
                  <Chip className="bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-white/80">{pv.match_type}</Chip>
                </div>
                <dl className="mt-3 space-y-1 text-theme-sm text-gray-600 dark:text-gray-400">
                  <div>{`Güven: %${toPercent(pv.confidence)}`}</div>
                  <div>{`Çekilme: ${formatDate(new Date(pv.fetched_at))}`}</div>
                </dl>
                <details className="mt-3">
                  <summary className="cursor-pointer text-theme-xs text-brand-500 dark:text-brand-400">Ham veri</summary>
                  <pre className="mt-2 overflow-x-auto rounded-md bg-gray-50 p-2 text-theme-xs text-gray-700 dark:bg-white/5 dark:text-gray-300">
                    {JSON.stringify(pv.raw_payload, null, 2)}
                  </pre>
                </details>
              </div>
            ))}
          </div>
        )}
      </section>

      <section className={SECTION}>
        <h3 className={SECTION_TITLE}>Skor Geçmişi</h3>
        {scoreHistory.length === 0 ? (
          <p className="text-theme-sm text-gray-500 dark:text-gray-400">Skor geçmişi yok.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>Tarih</th>
                  <th className={thClass}>Toplam</th>
                  <th className={thClass}>Fit</th>
                  <th className={thClass}>Intent</th>
                  <th className={thClass}>Engagement</th>
                  <th className={thClass}>Veri Kalitesi</th>
                  <th className={thClass}>Neden</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {scoreHistory.map((s) => (
                  <tr key={s.id}>
                    <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(s.computed_at)}</td>
                    <td className={`${tdClass} font-semibold ${scoreTextClass(s.total_score)}`}>{s.total_score}</td>
                    <td className={tdClass}>{s.fit_score}</td>
                    <td className={tdClass}>{s.intent_score}</td>
                    <td className={tdClass}>{s.engagement_score}</td>
                    <td className={tdClass}>{s.data_quality_score}</td>
                    <td className={tdClass}>{s.reason ?? "-"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {editing && (
        <ProspectFormModal
          prospectId={prospectId}
          initial={prospectToForm(p)}
          onClose={() => setEditing(false)}
          onSaved={() => { setEditing(false); reload(); }}
        />
      )}

      {converting && (
        <ModalShell isOpen onClose={() => setConverting(false)} title={"Lead'e dönüştür"}>
          <div className="space-y-4">
            <p className="text-theme-sm text-gray-600 dark:text-gray-400">
              Bu potansiyel aday satış lead kaydına dönüştürülecek. Devam edilsin mi?
            </p>
            <ErrorNote message={actionErr} />
            <div className="flex justify-end gap-3">
              <button type="button" className={outlineBtn} onClick={() => setConverting(false)}>Vazgeç</button>
              <button type="button" className={primaryBtn} disabled={saving} onClick={convert}>
                {saving ? "Dönüştürülüyor..." : "Dönüştür"}
              </button>
            </div>
          </div>
        </ModalShell>
      )}
    </div>
  );
}

function BackLink() {
  return (
    <Link href={LIST_BACK} className="text-theme-sm font-medium text-brand-500 hover:text-brand-600 dark:text-brand-400">
      ← Adaylara dön
    </Link>
  );
}
