"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDateTime } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import Pager from "../Pager";
import type { GrowthMessageLog, GrowthMessageLogList } from "../types";
import { cardClass, inputClass, labelClass, primaryBtn, tdClass, thClass } from "./styles";

const PAGE_SIZE = 50;

// Tablo kendi kapsayıcısında kayar; ilk sütun kaydırmada sabit kalır (MesajSablonlari ile aynı desen).
const TH_STICKY =
  "sticky start-0 z-10 bg-[#f8fafb] px-4 py-3 text-start text-[11px] font-semibold tracking-wide whitespace-nowrap text-gray-500 uppercase dark:bg-gray-900 dark:text-gray-400";
const TD_STICKY = `${tdClass} sticky start-0 z-10 bg-white dark:bg-gray-900`;

const CHANNELS = ["email", "sms", "push", "in_app", "whatsapp"] as const;
type Channel = (typeof CHANNELS)[number];

// growth_message_log.status değerleri (20261100000000_growth_mesaj_gunlugu.sql CHECK ile aynı) + motorun yazdığı kanal_kapali.
const STATUSES = [
  "kuyrukta",
  "gonderildi",
  "teslim_edildi",
  "acildi",
  "tiklandi",
  "donustu",
  "basarisiz",
  "izin_yok",
  "kanal_kapali",
] as const;
type MessageStatus = (typeof STATUSES)[number];
const STATUS_COLOR: Record<MessageStatus, "info" | "success" | "error" | "warning"> = {
  kuyrukta: "info",
  gonderildi: "success",
  teslim_edildi: "success",
  acildi: "success",
  tiklandi: "success",
  donustu: "success",
  basarisiz: "error",
  izin_yok: "warning",
  kanal_kapali: "warning",
};

export default function MesajGunluguManager() {
  const t = useTranslations("yonetim.mesajGunlugu");
  const [kanal, setKanal] = useState<"" | Channel>("");
  const [durum, setDurum] = useState<"" | MessageStatus>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<GrowthMessageLogList | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_mesaj_gunlugu_listele", {
        p_kanal: kanal || null,
        p_durum: durum || null,
        p_kampanya_id: null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as GrowthMessageLogList);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [kanal, durum, page, reloadKey]);

  const rows = list?.rows ?? [];
  const total = list?.total ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);
  const filtered = kanal !== "" || durum !== "";

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">{t("readOnlyNote")}</p>

        <div className="mb-4 flex flex-col gap-4 sm:flex-row sm:flex-wrap sm:items-end">
          <div className="w-full sm:w-auto sm:min-w-40">
            <label className={labelClass} htmlFor="g-kanal">{t("filters.channel")}</label>
            <select
              id="g-kanal"
              className={inputClass}
              value={kanal}
              onChange={(e) => { setKanal(e.target.value as "" | Channel); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allChannels")}</option>
              {CHANNELS.map((c) => (
                <option key={c} value={c}>{t(`channels.${c}`)}</option>
              ))}
            </select>
          </div>
          <div className="w-full sm:w-auto sm:min-w-40">
            <label className={labelClass} htmlFor="g-durum">{t("filters.status")}</label>
            <select
              id="g-durum"
              className={inputClass}
              value={durum}
              onChange={(e) => { setDurum(e.target.value as "" | MessageStatus); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allStatus")}</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{t(`statuses.${s}`)}</option>
              ))}
            </select>
          </div>
        </div>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{t("loadError")}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); setReloadKey((k) => k + 1); }}>
              {t("retry")}
            </button>
          </div>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
            {filtered ? t("emptyFiltered") : t("empty")}
          </p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <caption className="sr-only">{t("title")}</caption>
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th scope="col" className={TH_STICKY}>{t("cols.time")}</th>
                  <th scope="col" className={thClass}>{t("cols.channel")}</th>
                  <th scope="col" className={thClass}>{t("cols.status")}</th>
                  <th scope="col" className={thClass}>{t("cols.source")}</th>
                  <th scope="col" className={thClass}>{t("cols.recipient")}</th>
                  <th scope="col" className={thClass}>{t("cols.consent")}</th>
                  <th scope="col" className={thClass}>{t("cols.error")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((m) => (
                  <LogRow key={m.id} row={m} />
                ))}
              </tbody>
            </table>
          </div>
        )}

        {!loading && !error && total > 0 && (
          <Pager
            page={page}
            pageSize={PAGE_SIZE}
            total={total}
            onPage={(p) => { setLoading(true); setPage(p); }}
            labels={{ prev: t("pager.prev"), next: t("pager.next"), summary: `${start}–${end} / ${total}` }}
          />
        )}
      </section>
    </div>
  );
}

function LogRow({ row: m }: { row: GrowthMessageLog }) {
  const t = useTranslations("yonetim.mesajGunlugu");
  const status = (STATUSES as readonly string[]).includes(m.status) ? (m.status as MessageStatus) : null;
  const channelKnown = (CHANNELS as readonly string[]).includes(m.channel);
  const sourceName = m.kampanya_adi ?? m.journey_adi;
  const sourceLabel = m.campaign_id ? t("source.campaign") : m.journey_id ? t("source.journey") : null;
  const consentLabel =
    m.izin_verildi === true ? t("consent.yes") : m.izin_verildi === false ? t("consent.no") : t("consent.unknown");
  const consentColor = m.izin_verildi === true ? "success" : m.izin_verildi === false ? "error" : "light";

  return (
    <tr>
      <td className={`${TD_STICKY} whitespace-nowrap`}>{formatDateTime(m.zaman)}</td>
      <td className={tdClass}>{channelKnown ? t(`channels.${m.channel as Channel}`) : m.channel}</td>
      <td className={tdClass}>
        {status ? (
          <Badge size="sm" color={STATUS_COLOR[status]}>{t(`statuses.${status}`)}</Badge>
        ) : (
          <Badge size="sm" color="light">{m.status}</Badge>
        )}
      </td>
      <td className={tdClass}>
        {sourceName ? (
          <>
            {sourceLabel && <span className="block text-theme-xs text-gray-500 dark:text-gray-400">{sourceLabel}</span>}
            <span className="font-medium text-gray-800 dark:text-white/90">{sourceName}</span>
          </>
        ) : (
          "-"
        )}
      </td>
      <td className={tdClass}>
        {m.hane_eposta_maskeli || m.hane_telefon_maskeli ? (
          <>
            <span className="block">{m.hane_eposta_maskeli ?? "-"}</span>
            {m.hane_telefon_maskeli && (
              <span className="block text-theme-xs text-gray-500 dark:text-gray-400">{m.hane_telefon_maskeli}</span>
            )}
          </>
        ) : (
          "-"
        )}
      </td>
      <td className={tdClass}>
        <Badge size="sm" color={consentColor}>{consentLabel}</Badge>
      </td>
      <td className={`${tdClass} max-w-xs break-words`}>{m.error ?? "-"}</td>
    </tr>
  );
}
