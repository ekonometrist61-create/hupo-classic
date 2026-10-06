"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import { downloadCsv, toCsv } from "@/utils/csv";
import { formatDate } from "@/utils/format";
import ErrorNote from "../panel/ErrorNote";
import ModalShell from "../panel/ModalShell";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import { adminCall } from "../useAdminRpc";

interface ExportRow {
  ad: string | null;
  email: string | null;
  plan: string;
  cocuk_sayisi: number;
  uyelik_tarihi: string;
}

/** Veli listesini CSV'ye aktarır. Gerekçe zorunlu; adet + gerekçe sunucuda denetim izine yazılır. */
export default function ExportDialog({
  search,
  onClose,
}: {
  search: string;
  onClose: () => void;
}) {
  const t = useTranslations("yonetim.merkez.export");
  const [reason, setReason] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const run = async () => {
    setBusy(true);
    setError(null);
    const r = await adminCall<ExportRow[]>("admin_export_aileler", {
      p_arama: search.trim() || null,
      p_gerekce: reason,
    });
    setBusy(false);
    if (r.error) return setError(r.error === "DEMO" ? t("demo") : r.error);
    const rows = r.data ?? [];
    const csv = toCsv([
      [t("cols.name"), t("cols.email"), t("cols.plan"), t("cols.children"), t("cols.joined")],
      ...rows.map((x) => [
        x.ad,
        x.email,
        x.plan,
        x.cocuk_sayisi,
        formatDate(new Date(x.uyelik_tarihi)),
      ]),
    ]);
    downloadCsv(`hupo-aileler-${new Date().toISOString().slice(0, 10)}.csv`, csv);
    onClose();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("title")}>
      <div className="space-y-4">
        <p className="text-theme-sm text-gray-600 dark:text-gray-400">{t("text")}</p>
        <div>
          <label className={labelClass} htmlFor="exp-reason">{t("reason")}</label>
          <input
            id="exp-reason"
            className={inputClass}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder={t("reasonPlaceholder")}
          />
        </div>
        <ErrorNote message={error} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>{t("cancel")}</button>
          <button
            type="button"
            className={primaryBtn}
            disabled={busy || reason.trim().length < 10}
            onClick={run}
          >
            {busy ? t("working") : t("download")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}
