"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import type { AdminUser, PaymentStatus, Plan } from "../types";
import ErrorNote from "./ErrorNote";
import { kurusToInput, parseTryToKurus } from "./helpers";
import ModalShell from "./ModalShell";
import ParentPicker from "./ParentPicker";
import { inputClass, labelClass, outlineBtn, primaryBtn } from "./styles";

export const PAYMENT_STATUSES: PaymentStatus[] = [
  "basarili",
  "beklemede",
  "basarisiz",
  "iade",
];

interface Props {
  isOpen: boolean;
  onClose: () => void;
  plans: Plan[];
  onSaved: () => void;
}

export default function PaymentFormModal({ isOpen, onClose, plans, onSaved }: Props) {
  const t = useTranslations("yonetim.odemeler.form");
  const tStatus = useTranslations("yonetim.odemeler.durum");
  const [parent, setParent] = useState<AdminUser | null>(null);
  const [planKod, setPlanKod] = useState("");
  const [amount, setAmount] = useState("");
  const [durum, setDurum] = useState<PaymentStatus>("basarili");
  const [aciklama, setAciklama] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onPlanChange = (kod: string) => {
    setPlanKod(kod);
    const plan = plans.find((p) => p.kod === kod);
    if (plan) setAmount(kurusToInput(plan.fiyat_kurus));
  };

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!parent) return setError(t("errParent"));
    if (!planKod) return setError(t("errPlan"));
    const kurus = parseTryToKurus(amount);
    if (kurus === null) return setError(t("errAmount"));

    setSaving(true);
    const { error: err } = await createClient().rpc("admin_record_payment", {
      p_veli_id: parent.id,
      p_plan_kod: planKod,
      p_tutar_kurus: kurus,
      p_durum: durum,
      p_aciklama: aciklama.trim() || null,
    });
    setSaving(false);
    if (err) return setError(err.message);
    setParent(null);
    setPlanKod("");
    setAmount("");
    setDurum("basarili");
    setAciklama("");
    onSaved();
    onClose();
  };

  return (
    <ModalShell isOpen={isOpen} onClose={onClose} title={t("title")}>
      <form onSubmit={submit} className="space-y-4">
        <ParentPicker selected={parent} onSelect={setParent} />
        <div>
          <label className={labelClass} htmlFor="pay-plan">
            {t("plan")}
          </label>
          <select
            id="pay-plan"
            className={inputClass}
            value={planKod}
            onChange={(e) => onPlanChange(e.target.value)}
          >
            <option value="">{t("planPlaceholder")}</option>
            {plans.map((p) => (
              <option key={p.kod} value={p.kod}>
                {p.ad} ({p.kod})
              </option>
            ))}
          </select>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label className={labelClass} htmlFor="pay-amount">
              {t("amount")}
            </label>
            <input
              id="pay-amount"
              className={inputClass}
              inputMode="decimal"
              placeholder="149,90"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />
          </div>
          <div>
            <label className={labelClass} htmlFor="pay-status">
              {t("status")}
            </label>
            <select
              id="pay-status"
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
        </div>
        <div>
          <label className={labelClass} htmlFor="pay-note">
            {t("note")}
          </label>
          <textarea
            id="pay-note"
            rows={2}
            className={`${inputClass} h-auto`}
            value={aciklama}
            onChange={(e) => setAciklama(e.target.value)}
          />
        </div>
        <ErrorNote message={error} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("cancel")}
          </button>
          <button type="submit" className={primaryBtn} disabled={saving}>
            {saving ? t("saving") : t("save")}
          </button>
        </div>
      </form>
    </ModalShell>
  );
}
