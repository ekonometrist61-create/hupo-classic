"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import { formatKurus } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import type { AdminPayment, PaymentStatus } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import { PAYMENT_STATUSES } from "./PaymentFormModal";
import { dangerBtn, inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

interface Props {
  payment: AdminPayment | null;
  onClose: () => void;
  onSaved: () => void;
}

/** payment değiştiğinde yeniden bağlanması için üst bileşen key={payment.id} vermelidir. */
export default function PaymentStatusModal({ payment, onClose, onSaved }: Props) {
  const t = useTranslations("yonetim.odemeler.statusModal");
  const tStatus = useTranslations("yonetim.odemeler.durum");
  const [durum, setDurum] = useState<PaymentStatus>(payment?.durum ?? "basarili");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!payment) return null;
  const isRefund = durum === "iade";
  const unchanged = durum === payment.durum;

  const submit = async () => {
    setSaving(true);
    setError(null);
    const { error: err } = await createClient().rpc("admin_set_payment_status", {
      p_id: payment.id,
      p_durum: durum,
    });
    setSaving(false);
    if (err) return setError(err.message);
    onSaved();
    onClose();
  };

  return (
    <ModalShell isOpen onClose={onClose} title={t("title")}>
      <div className="space-y-4">
        <p className="text-theme-sm text-gray-500 dark:text-gray-400">
          {payment.veli_ad ?? "-"} · {formatKurus(payment.tutar_kurus)}
        </p>
        <div>
          <label className={labelClass} htmlFor="new-status">
            {t("newStatus")}
          </label>
          <select
            id="new-status"
            className={inputClass}
            value={durum}
            onChange={(e) => setDurum(e.target.value as PaymentStatus)}
          >
            {PAYMENT_STATUSES.map((s) => (
              <option key={s} value={s}>
                {tStatus(s)}
              </option>
            ))}
          </select>
        </div>
        {isRefund && !unchanged && (
          <div className="rounded-lg bg-warning-50 px-3 py-2 text-theme-sm text-warning-700 dark:bg-warning-500/15 dark:text-orange-400">
            {t("refundWarning")}
          </div>
        )}
        <ErrorNote message={error} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("cancel")}
          </button>
          <button
            type="button"
            className={isRefund ? dangerBtn : primaryBtn}
            disabled={saving || unchanged}
            onClick={submit}
          >
            {saving ? t("saving") : isRefund ? t("confirmRefund") : t("save")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}
