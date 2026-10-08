"use client";

import { useEffect, useState, type ReactNode } from "react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { formatDate, formatDateTime, formatTry } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import type { Musteri360Detay } from "../types";
import ErrorNote from "./ErrorNote";
import { HealthBar, LifecycleBadge, asPlan } from "./Musteri360Manager";
import { cardClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

const TABS = ["genel", "kimlik", "hane", "abonelik", "islem", "pazarlama", "kullanim", "crm", "zaman"] as const;
type TabId = (typeof TABS)[number];

const STATUS_CLASS = {
  ok: "bg-success-50 text-success-600 dark:bg-success-500/15 dark:text-success-500",
  bad: "bg-gray-100 text-gray-700 dark:bg-white/5 dark:text-white/80",
};

function orDash(v: string | number | null | undefined): string | number {
  return v === null || v === undefined || v === "" ? "-" : v;
}

function dateTime(v: string | null | undefined): string {
  return formatDateTime(v ?? null);
}

function dateOnly(v: string | null | undefined): string {
  if (!v) return "-";
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? v : formatDate(d);
}

function money(amount: number, currency: string): string {
  if (!/^[A-Z]{3}$/.test(currency)) return String(amount);
  return new Intl.NumberFormat("tr-TR", { style: "currency", currency }).format(amount);
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h3 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">{title}</h3>
      {children}
    </section>
  );
}

function Fields({ items }: { items: Array<[string, ReactNode]> }) {
  return (
    <dl className="grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-2 xl:grid-cols-3">
      {items.map(([label, value]) => (
        <div key={label}>
          <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{label}</dt>
          <dd className="text-theme-sm font-medium text-gray-800 dark:text-white/90">{value ?? "-"}</dd>
        </div>
      ))}
    </dl>
  );
}

function Table({ head, children }: { head: string[]; children: ReactNode }) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full">
        <thead className="border-b border-gray-100 dark:border-gray-800">
          <tr>
            {head.map((h) => (
              <th key={h} className={thClass}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100 dark:divide-gray-800">{children}</tbody>
      </table>
    </div>
  );
}

function Empty({ text }: { text: string }) {
  return <p className="py-6 text-center text-theme-sm text-gray-500 dark:text-gray-400">{text}</p>;
}

function StatusPill({ ok, label }: { ok: boolean; label: string }) {
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-theme-xs font-medium ${
        ok ? STATUS_CLASS.ok : STATUS_CLASS.bad
      }`}
    >
      {label}
    </span>
  );
}

export default function Musteri360DetayManager({ householdId }: { householdId: string }) {
  const t = useTranslations("yonetim.musteri360");
  const [detay, setDetay] = useState<Musteri360Detay | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<TabId>("genel");
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_musteri_360_detay", {
        p_household_id: householdId,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setDetay(null);
      } else {
        setError(null);
        setDetay((data as Musteri360Detay | null) ?? null);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [householdId, reloadKey]);

  const backLink = (
    <Link href="/yonetim/musteri-360" className={outlineBtn}>
      {t("back")}
    </Link>
  );

  if (loading) {
    return (
      <div className="space-y-6">
        {backLink}
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        {backLink}
        <div className="py-8 text-center">
          <ErrorNote message={error} />
          <button
            type="button"
            className={`${primaryBtn} mt-3`}
            onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}
          >
            {t("retry")}
          </button>
        </div>
      </div>
    );
  }

  if (!detay) {
    return (
      <div className="space-y-6">
        {backLink}
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("notFound")}</p>
      </div>
    );
  }

  const h = detay.musteri;
  const plan = asPlan(h.plan);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        {backLink}
        <span className="text-theme-sm text-gray-500 dark:text-gray-400">
          {t("fields.customerNo")}: <b className="text-gray-800 dark:text-white/90">{orDash(h.customer_no)}</b>
        </span>
      </div>

      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="min-w-0">
            <h2 className="text-xl font-bold text-gray-800 dark:text-white/90">{h.parent_name}</h2>
            <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">
              {orDash(h.email)} · {orDash(h.phone)}
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <LifecycleBadge stage={h.lifecycle} />
            {plan && (
              <span className="inline-flex items-center rounded-full bg-brand-50 px-2.5 py-0.5 text-theme-xs font-medium text-brand-500 dark:bg-brand-500/15 dark:text-brand-400">
                {t(`plans.${plan}`)}
              </span>
            )}
          </div>
        </div>
      </section>

      <div role="tablist" className="flex gap-1 overflow-x-auto border-b border-gray-200 dark:border-gray-800">
        {TABS.map((id) => (
          <button
            key={id}
            type="button"
            role="tab"
            aria-selected={tab === id}
            onClick={() => setTab(id)}
            className={`whitespace-nowrap border-b-2 px-4 py-2.5 text-theme-sm font-medium transition ${
              tab === id
                ? "border-brand-500 text-brand-500 dark:text-brand-400"
                : "border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300"
            }`}
          >
            {t(`tabs.${id}`)}
          </button>
        ))}
      </div>

      {tab === "genel" && <GenelTab d={detay} />}
      {tab === "kimlik" && <KimlikTab d={detay} />}
      {tab === "hane" && <HaneTab d={detay} />}
      {tab === "abonelik" && <AbonelikTab d={detay} />}
      {tab === "islem" && <IslemTab d={detay} />}
      {tab === "pazarlama" && <PazarlamaTab d={detay} />}
      {tab === "kullanim" && <KullanimTab d={detay} />}
      {tab === "crm" && <CrmTab d={detay} />}
      {tab === "zaman" && <ZamanTab d={detay} />}
    </div>
  );
}

type TabProps = { d: Musteri360Detay };

function GenelTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const h = d.musteri;
  const plan = asPlan(h.plan);
  return (
    <div className="space-y-6">
      <Section title={t("sections.summary")}>
        <Fields
          items={[
            [t("fields.customerNo"), orDash(h.customer_no)],
            [t("fields.email"), orDash(h.email)],
            [t("fields.phone"), orDash(h.phone)],
            [t("fields.lifecycle"), <LifecycleBadge key="lc" stage={h.lifecycle} />],
            [t("fields.plan"), plan ? t(`plans.${plan}`) : orDash(h.plan)],
            [t("fields.totalRevenue"), formatTry(h.total_revenue_try ?? 0)],
            [t("fields.lastActivity"), dateTime(h.last_seen_at)],
            [t("fields.createdAt"), dateTime(h.created_at)],
          ]}
        />
      </Section>

      <Section title={t("sections.health")}>
        <div className="mb-5 max-w-md">
          <p className="mb-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("health.label")}</p>
          <HealthBar score={h.lead_score} />
        </div>
        <Fields
          items={[
            [t("fields.churnRisk"), orDash(h.churn_score)],
          ]}
        />
      </Section>

      <Section title={t("sections.tags")}>
        {h.tags && h.tags.length > 0 ? (
          <div className="flex flex-wrap gap-2">
            {h.tags.map((tag) => (
              <span
                key={tag}
                className="rounded-full bg-gray-100 px-2.5 py-0.5 text-theme-xs font-medium text-gray-700 dark:bg-white/5 dark:text-white/80"
              >
                {tag}
              </span>
            ))}
          </div>
        ) : (
          <Empty text={t("empty.tags")} />
        )}
        {h.notes && (
          <div className="mt-5">
            <p className="mb-1 text-theme-xs text-gray-500 dark:text-gray-400">{t("fields.notes")}</p>
            <p className="whitespace-pre-line text-theme-sm text-gray-700 dark:text-gray-300">{h.notes}</p>
          </div>
        )}
      </Section>
    </div>
  );
}

function KimlikTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const h = d.musteri;
  return (
    <div className="space-y-6">
      <Section title={t("sections.contact")}>
        <Fields
          items={[
            [t("fields.email"), orDash(h.email)],
            [t("fields.phone"), orDash(h.phone)],
            [t("fields.preferredChannel"), orDash(h.preferred_contact_channel)],
          ]}
        />
      </Section>

      <Section title={t("sections.people")}>
        {d.kisiler.length === 0 ? (
          <Empty text={t("empty.people")} />
        ) : (
          <Table head={[t("cols.role"), t("cols.name"), t("cols.email"), t("cols.phone")]}>
            {d.kisiler.map((p) => (
              <tr key={p.id}>
                <td className={tdClass}>{p.person_role}</td>
                <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>
                  {`${p.first_name} ${p.last_name}`.trim() || "-"}
                </td>
                <td className={tdClass}>{orDash(p.email)}</td>
                <td className={`${tdClass} whitespace-nowrap`}>{orDash(p.phone)}</td>
              </tr>
            ))}
          </Table>
        )}
      </Section>

      <Section title={t("sections.addresses")}>
        {d.adresler.length === 0 ? (
          <Empty text={t("empty.addresses")} />
        ) : (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            {d.adresler.map((a) => (
              <div key={a.id} className="rounded-lg bg-gray-50 p-4 dark:bg-white/5">
                <p className="text-theme-sm font-medium text-gray-800 dark:text-white/90">{a.label ?? "-"}</p>
                <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-400">{orDash(a.address_line)}</p>
                <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                  {[a.district, a.city].filter(Boolean).join(" / ") || "-"}
                </p>
              </div>
            ))}
          </div>
        )}
      </Section>
    </div>
  );
}

function HaneTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const cocuklar = (d.cocuklar ?? []) as Array<Record<string, unknown>>;
  return (
    <Section title={t("sections.children")}>
      {cocuklar.length === 0 ? (
        <Empty text={t("empty.children")} />
      ) : (
        <Table
          head={[
            t("cols.name"),
            t("cols.grade"),
            t("cols.xp"),
            t("cols.level"),
            t("cols.streak"),
            t("cols.activeDays"),
            t("cols.lastActive"),
          ]}
        >
          {cocuklar.map((c, i) => (
            <tr key={String(c.id ?? i)}>
              <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{String(c.ad ?? c.display_name ?? "-")}</td>
              <td className={tdClass}>{orDash(c.grade as string | null)}</td>
              <td className={tdClass}>{String(c.xp ?? 0)}</td>
              <td className={tdClass}>{String(c.level ?? 0)}</td>
              <td className={tdClass}>{String(c.streak_count ?? 0)}</td>
              <td className={tdClass}>{String(c.active_days ?? 0)}</td>
              <td className={`${tdClass} whitespace-nowrap`}>{dateOnly(c.last_active_date as string | null)}</td>
            </tr>
          ))}
        </Table>
      )}
    </Section>
  );
}

function AbonelikTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const s = d.abonelik as Record<string, unknown> | null;
  return (
    <Section title={t("sections.subscription")}>
      {!s ? (
        <Empty text={t("empty.subscription")} />
      ) : (
        <Fields
          items={[
            [t("fields.planName"), orDash(s.plan as string | null)],
            [t("fields.status"), orDash(s.status as string | null)],
            [t("fields.startedAt"), dateTime(s.started_at as string | null)],
            [t("fields.expiresAt"), dateTime(s.expires_at as string | null)],
          ]}
        />
      )}
    </Section>
  );
}

function IslemTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  return (
    <Section title={t("sections.transactions")}>
      {d.islemler.length === 0 ? (
        <Empty text={t("empty.transactions")} />
      ) : (
        <Table
          head={[
            t("cols.type"),
            t("cols.amount"),
            t("cols.status"),
            t("cols.date"),
            t("cols.description"),
          ]}
        >
          {d.islemler.map((x) => (
            <tr key={x.id}>
              <td className={tdClass}>{x.transaction_type}</td>
              <td className={`${tdClass} whitespace-nowrap font-medium text-gray-800 dark:text-white/90`}>
                {money(x.amount_try, x.currency)}
              </td>
              <td className={tdClass}>{x.status}</td>
              <td className={`${tdClass} whitespace-nowrap`}>{dateTime(x.occurred_at)}</td>
              <td className={tdClass}>{orDash(x.description)}</td>
            </tr>
          ))}
        </Table>
      )}
    </Section>
  );
}

function PazarlamaTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const h = d.musteri;
  return (
    <div className="space-y-6">
      <Section title={t("sections.marketing")}>
        <Fields
          items={[
            [t("fields.preferredChannel"), orDash(h.preferred_contact_channel)],
            [t("fields.utmSource"), orDash(h.utm_source)],
            [t("fields.utmMedium"), orDash(h.utm_medium)],
            [t("fields.utmCampaign"), orDash(h.utm_campaign)],
          ]}
        />
      </Section>

      <Section title={t("sections.consents")}>
        {d.iletisim_izinleri.length === 0 ? (
          <Empty text={t("empty.consents")} />
        ) : (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {d.iletisim_izinleri.map((c) => (
              <div key={c.kanal} className="rounded-lg bg-gray-50 p-4 dark:bg-white/5">
                <p className="text-theme-sm font-medium text-gray-800 dark:text-white/90">{c.kanal}</p>
                <div className="mt-2 flex items-center justify-between gap-2">
                  <StatusPill ok={c.izin} label={c.izin ? t("consent.granted") : t("consent.denied")} />
                  <span className="text-theme-xs text-gray-500 dark:text-gray-400">{dateTime(c.degisim)}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </Section>
    </div>
  );
}

function KullanimTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const cocuklar = (d.cocuklar ?? []) as Array<Record<string, unknown>>;
  return (
    <Section title={t("sections.usage")}>
      {cocuklar.length === 0 ? (
        <Empty text={t("empty.children")} />
      ) : (
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          {cocuklar.map((c, i) => (
            <div key={String(c.id ?? i)} className="rounded-lg border border-gray-200 p-4 dark:border-gray-800">
              <p className="mb-4 text-theme-sm font-semibold text-gray-800 dark:text-white/90">
                {String(c.ad ?? c.display_name ?? "-")}
                {c.grade ? ` · ${String(c.grade)}` : ""}
              </p>
              <dl className="grid grid-cols-2 gap-x-6 gap-y-4 sm:grid-cols-3">
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.activeDays")}</dt>
                  <dd className="text-lg font-semibold text-gray-800 dark:text-white/90">{String(c.active_days ?? 0)}</dd>
                </div>
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.xp")}</dt>
                  <dd className="text-lg font-semibold text-gray-800 dark:text-white/90">{String(c.xp ?? 0)}</dd>
                </div>
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.level")}</dt>
                  <dd className="text-lg font-semibold text-gray-800 dark:text-white/90">{String(c.level ?? 0)}</dd>
                </div>
                <div>
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.streak")}</dt>
                  <dd className="text-lg font-semibold text-gray-800 dark:text-white/90">{String(c.streak_count ?? 0)}</dd>
                </div>
                <div className="col-span-2">
                  <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.lastActive")}</dt>
                  <dd className="text-theme-sm font-medium text-gray-800 dark:text-white/90">
                    {dateOnly(c.last_active_date as string | null)}
                  </dd>
                </div>
              </dl>
            </div>
          ))}
        </div>
      )}
    </Section>
  );
}

function CrmTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  return (
    <div className="space-y-6">
      <Section title={t("sections.tickets")}>
        {d.destek_talepleri.length === 0 ? (
          <Empty text={t("empty.tickets")} />
        ) : (
          <Table head={[t("cols.subject"), t("cols.status"), t("cols.priority"), t("cols.date")]}>
            {d.destek_talepleri.map((x) => (
              <tr key={x.id}>
                <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{x.subject}</td>
                <td className={tdClass}>{x.status}</td>
                <td className={tdClass}>{x.priority}</td>
                <td className={`${tdClass} whitespace-nowrap`}>{dateTime(x.created_at)}</td>
              </tr>
            ))}
          </Table>
        )}
      </Section>

      <Section title={t("sections.feed")}>
        {d.ekip_akisi.length === 0 ? (
          <Empty text={t("empty.feed")} />
        ) : (
          <ul className="space-y-3">
            {d.ekip_akisi.map((f) => (
              <li key={f.id} className="rounded-lg bg-gray-50 p-4 dark:bg-white/5">
                <div className="mb-1 flex flex-wrap items-center gap-2 text-theme-xs text-gray-500 dark:text-gray-400">
                  <span className="rounded-full bg-white px-2 py-0.5 font-medium text-gray-700 dark:bg-white/10 dark:text-white/80">
                    {f.feed_type}
                  </span>
                  <span>·</span>
                  <span>{dateTime(f.created_at)}</span>
                </div>
                <p className="whitespace-pre-line text-theme-sm text-gray-700 dark:text-gray-300">{f.body ?? "-"}</p>
              </li>
            ))}
          </ul>
        )}
      </Section>
    </div>
  );
}

function ZamanTab({ d }: TabProps) {
  const t = useTranslations("yonetim.musteri360");
  const olaylar = [...d.olaylar].sort(
    (a, b) => new Date(b.occurred_at).getTime() - new Date(a.occurred_at).getTime()
  );
  return (
    <Section title={t("sections.timeline")}>
      {olaylar.length === 0 ? (
        <Empty text={t("empty.events")} />
      ) : (
        <ul className="space-y-3">
          {olaylar.map((e) => {
            const keys = Object.keys(e.properties ?? {});
            const preview = keys.length > 0 ? JSON.stringify(e.properties) : null;
            return (
              <li key={e.id} className="flex flex-col gap-1 rounded-lg bg-gray-50 px-4 py-3 dark:bg-white/5 sm:flex-row sm:items-start sm:justify-between sm:gap-4">
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="rounded-full bg-white px-2 py-0.5 text-theme-xs font-medium text-gray-700 dark:bg-white/10 dark:text-white/80">
                      {e.source ?? "-"}
                    </span>
                    <span className="text-theme-sm font-medium text-gray-800 dark:text-white/90">{e.event_name}</span>
                  </div>
                  {preview && (
                    <p className="mt-1 truncate font-mono text-theme-xs text-gray-500 dark:text-gray-400">
                      {preview.length > 160 ? `${preview.slice(0, 160)}…` : preview}
                    </p>
                  )}
                </div>
                <span className="shrink-0 whitespace-nowrap text-theme-xs text-gray-500 dark:text-gray-400">
                  {dateTime(e.occurred_at)}
                </span>
              </li>
            );
          })}
        </ul>
      )}
    </Section>
  );
}
