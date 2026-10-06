"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDateTime, formatKurus } from "@/utils/format";
import { inputClass, outlineBtn, primaryBtn } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { DEMO_PROFILE } from "./demoData";
import type { Channel, VeliProfile } from "./types";

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section>
      <h4 className="mb-2 text-theme-sm font-semibold text-gray-800 dark:text-white/90">{title}</h4>
      {children}
    </section>
  );
}

/** Aile profili: çocuklar, abonelik, kanal bazlı izinler (gerekçeli değişiklik), notlar, zaman çizelgesi. */
export default function VeliProfilePanel({ veliId }: { veliId: string }) {
  const t = useTranslations("yonetim.merkez.profile");
  const state = useAdminRpc<VeliProfile>(
    "admin_veli_profil",
    { p_veli_id: veliId },
    { demo: DEMO_PROFILE },
  );

  return (
    <RpcBoundary state={state}>
      {(p) => <Body p={p} reload={state.reload} t={t} />}
    </RpcBoundary>
  );
}

function Body({
  p,
  reload,
  t,
}: {
  p: VeliProfile;
  reload: () => void;
  t: ReturnType<typeof useTranslations>;
}) {
  const [editing, setEditing] = useState<Channel | null>(null);
  const [reason, setReason] = useState("");
  const [note, setNote] = useState("");
  const [busy, setBusy] = useState(false);
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);

  const done = (error: string | null, okMsg: string) => {
    setBusy(false);
    if (error) {
      setFb({ kind: "error", msg: error === "DEMO" ? t("demoNote") : error });
      return;
    }
    setFb({ kind: "ok", msg: okMsg });
    reload();
  };

  const changeConsent = async (kanal: Channel, izin: boolean) => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_veli_tercih_ayarla", {
      p_veli_id: p.veli.id,
      p_kanal: kanal,
      p_izin: izin,
      p_gerekce: reason,
    });
    if (!r.error) {
      setEditing(null);
      setReason("");
    }
    done(r.error, t("consentSaved"));
  };

  const addNote = async () => {
    setBusy(true);
    setFb(null);
    const r = await adminCall("admin_veli_not_ekle", { p_veli_id: p.veli.id, p_metin: note });
    if (!r.error) setNote("");
    done(r.error, t("noteSaved"));
  };

  const timelineText = (z: VeliProfile["zaman_cizelgesi"][number]) => {
    const d = z.detay as Record<string, string | number | boolean>;
    switch (z.tur) {
      case "kayit":
        return t("tl.kayit");
      case "odeme":
        return t("tl.odeme", {
          durum: t(`payStatus.${String(d.durum)}`),
          tutar: formatKurus(Number(d.tutar_kurus ?? 0)),
        });
      case "tercih":
        return t("tl.tercih", {
          kanal: t(`channels.${String(d.kanal)}`),
          izin: d.izin ? t("allowed") : t("notAllowed"),
        });
      default:
        return t("tl.islem", { islem: String(d.islem ?? "") });
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-3">
        <span className="grid size-14 place-items-center rounded-full bg-brand-50 text-lg font-bold text-brand-600 dark:bg-brand-500/15">
          {(p.veli.ad ?? p.veli.email ?? "?").slice(0, 2).toLocaleUpperCase("tr")}
        </span>
        <div className="min-w-0">
          <h3 className="truncate text-lg font-semibold text-navy dark:text-white/90">{p.veli.ad ?? "—"}</h3>
          <p className="truncate text-theme-sm text-gray-500 dark:text-gray-400">{p.veli.email ?? "—"}</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-2">
        <Badge size="sm" color="info">{t("parent")}</Badge>
        {p.abonelik ? (
          <Badge size="sm" color={p.abonelik.durum === "aktif" ? "success" : "warning"}>
            {p.abonelik.plan_ad} · {p.abonelik.durum}
          </Badge>
        ) : (
          <Badge size="sm" color="light">{t("noPlan")}</Badge>
        )}
      </div>

      <Section title={t("children")}>
        {p.cocuklar.length === 0 ? (
          <p className="text-theme-sm text-gray-500 dark:text-gray-400">{t("noChildren")}</p>
        ) : (
          <ul className="divide-y divide-gray-100 rounded-xl border border-gray-200 text-theme-sm dark:divide-gray-800 dark:border-gray-800">
            {p.cocuklar.map((c) => (
              <li key={c.id} className="flex items-center justify-between gap-3 px-4 py-3">
                <span className="font-medium">{c.ad ?? "—"}</span>
                <span className="text-gray-500 dark:text-gray-400">
                  {c.sinif ? t("grade", { n: c.sinif }) : "—"}
                  {c.son_aktif ? ` · ${t("lastActive", { d: c.son_aktif })}` : ""}
                </span>
              </li>
            ))}
          </ul>
        )}
      </Section>

      <Section title={t("consent")}>
        <p className="mb-2 text-theme-xs text-gray-500 dark:text-gray-400">{t("consentHint")}</p>
        <ul className="divide-y divide-gray-100 rounded-xl border border-gray-200 dark:divide-gray-800 dark:border-gray-800">
          {p.tercihler.map((c) => (
            <li key={c.kanal} className="px-4 py-3 text-theme-sm">
              <div className="flex items-center justify-between gap-3">
                <span className="font-medium">{t(`channels.${c.kanal}`)}</span>
                <span className="flex items-center gap-3">
                  <Badge size="sm" color={c.izin ? "success" : "light"}>
                    {c.izin ? t("allowed") : t("notAllowed")}
                  </Badge>
                  <button
                    type="button"
                    className="text-theme-xs font-medium text-brand-500 hover:text-brand-600 dark:text-brand-400"
                    onClick={() => {
                      setEditing(editing === c.kanal ? null : c.kanal);
                      setReason("");
                      setFb(null);
                    }}
                    aria-expanded={editing === c.kanal}
                  >
                    {t("change")}
                  </button>
                </span>
              </div>
              {editing === c.kanal && (
                <div className="mt-3 space-y-2">
                  <label className="block text-theme-xs font-medium text-gray-700 dark:text-gray-400" htmlFor={`r-${c.kanal}`}>
                    {t("reason")}
                  </label>
                  <input
                    id={`r-${c.kanal}`}
                    className={inputClass}
                    value={reason}
                    onChange={(e) => setReason(e.target.value)}
                    placeholder={t("reasonPlaceholder")}
                  />
                  <div className="flex gap-2">
                    <button
                      type="button"
                      className={primaryBtn}
                      disabled={busy || reason.trim().length < 5}
                      onClick={() => changeConsent(c.kanal, !c.izin)}
                    >
                      {c.izin ? t("withdraw") : t("recordConsent")}
                    </button>
                    <button type="button" className={outlineBtn} onClick={() => setEditing(null)}>
                      {t("cancel")}
                    </button>
                  </div>
                </div>
              )}
            </li>
          ))}
        </ul>
      </Section>

      <Section title={t("notes")}>
        <textarea
          className={`${inputClass} h-24 py-2.5`}
          value={note}
          maxLength={2000}
          onChange={(e) => setNote(e.target.value)}
          placeholder={t("notePlaceholder")}
          aria-label={t("notes")}
        />
        <div className="mt-2">
          <button type="button" className={primaryBtn} disabled={busy || !note.trim()} onClick={addNote}>
            {t("addNote")}
          </button>
        </div>
        <ul className="mt-3 space-y-2">
          {p.notlar.map((n) => (
            <li key={n.id} className="rounded-xl bg-gray-50 px-4 py-3 text-theme-sm dark:bg-white/3">
              <p className="whitespace-pre-wrap">{n.metin}</p>
              <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
                {n.yazar ?? "—"} · {formatDateTime(n.tarih)}
              </p>
            </li>
          ))}
        </ul>
      </Section>

      <Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} />

      <Section title={t("timeline")}>
        <ol className="ms-2 border-s-2 border-brand-100 ps-5 dark:border-brand-500/30">
          {p.zaman_cizelgesi.map((z, i) => (
            <li key={i} className="relative pb-5 text-theme-sm">
              <span className="absolute -start-6.75 top-1.5 size-2 rounded-full bg-brand-500" aria-hidden />
              <b className="font-medium">{timelineText(z)}</b>
              <br />
              <span className="text-theme-xs text-gray-500 dark:text-gray-400">{formatDateTime(z.zaman)}</span>
            </li>
          ))}
        </ol>
      </Section>
    </div>
  );
}
