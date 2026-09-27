"use client";

import Input from "@/components/form/input/InputField";
import TextArea from "@/components/form/input/TextArea";
import Label from "@/components/form/Label";
import { Modal } from "@/components/ui/modal";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useState } from "react";

import type { AdminQuestion, QuestionInput, QuestionStatus } from "../types";
import { OPTION_KEYS, splitSteps, validateQuestion } from "./csv";

interface QuestionFormModalProps {
  /** null = yeni soru */
  question: AdminQuestion | null;
  onClose: () => void;
  onSaved: () => void;
}

const selectClass =
  "h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 text-sm text-gray-800 shadow-theme-xs focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:focus:border-brand-800";

export default function QuestionFormModal({
  question,
  onClose,
  onSaved,
}: QuestionFormModalProps) {
  const t = useTranslations("yonetim.sorular");

  const [okul, setOkul] = useState(question?.okul ?? "");
  const [ders, setDers] = useState(question?.ders ?? "");
  const [konu, setKonu] = useState(question?.konu ?? "");
  const [altKonu, setAltKonu] = useState(question?.alt_konu ?? "");
  const [zorluk, setZorluk] = useState(String(question?.zorluk ?? 1));
  const [soru, setSoru] = useState(question?.soru_metni ?? "");
  const [siklar, setSiklar] = useState<Record<string, string>>(() => {
    const init: Record<string, string> = {};
    for (const k of OPTION_KEYS) init[k] = question?.siklar?.[k] ?? "";
    return init;
  });
  const [dogru, setDogru] = useState(question?.dogru_sik ?? "");
  const [adimlar, setAdimlar] = useState(
    (question?.cozum_adimlari ?? []).join("\n")
  );
  const [durum, setDurum] = useState<QuestionStatus>(
    question?.onay_durumu ?? "beklemede"
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const filledKeys = OPTION_KEYS.filter((k) => siklar[k].trim() !== "");
  const dogruValue = filledKeys.includes(dogru as (typeof OPTION_KEYS)[number])
    ? dogru
    : "";

  const save = async () => {
    const filled: Record<string, string> = {};
    for (const k of filledKeys) filled[k] = siklar[k].trim();

    const payload: QuestionInput = {
      okul: okul.trim(),
      ders: ders.trim(),
      konu: konu.trim(),
      alt_konu: altKonu.trim() === "" ? null : altKonu.trim(),
      zorluk: Number(zorluk),
      soru_metni: soru.trim(),
      siklar: filled,
      dogru_sik: dogruValue,
      cozum_adimlari: splitSteps(adimlar),
      onay_durumu: durum,
    };

    const clientError = validateQuestion(payload);
    if (clientError) {
      setError(clientError);
      return;
    }

    setSaving(true);
    setError(null);
    const { error: rpcError } = await createClient().rpc(
      "admin_upsert_question",
      { p_id: question?.id ?? null, p_soru: payload }
    );
    setSaving(false);
    if (rpcError) {
      setError(rpcError.message);
      return;
    }
    onSaved();
  };

  return (
    <Modal
      isOpen
      onClose={saving ? () => undefined : onClose}
      className="m-4 max-w-3xl p-6 sm:p-8"
      showCloseButton={!saving}
    >
      <h3 className="mb-6 text-lg font-semibold text-gray-800 dark:text-white/90">
        {question ? t("form.editTitle") : t("form.newTitle")}
      </h3>

      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <Label htmlFor="q-okul">{t("form.okul")}</Label>
          <Input
            id="q-okul"
            value={okul}
            disabled={saving}
            onChange={(e) => setOkul(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="q-ders">{t("form.ders")}</Label>
          <Input
            id="q-ders"
            value={ders}
            disabled={saving}
            onChange={(e) => setDers(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="q-konu">{t("form.konu")}</Label>
          <Input
            id="q-konu"
            value={konu}
            disabled={saving}
            onChange={(e) => setKonu(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="q-alt">{t("form.altKonu")}</Label>
          <Input
            id="q-alt"
            value={altKonu}
            disabled={saving}
            onChange={(e) => setAltKonu(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="q-zorluk">{t("form.zorluk")}</Label>
          <select
            id="q-zorluk"
            className={selectClass}
            value={zorluk}
            disabled={saving}
            onChange={(e) => setZorluk(e.target.value)}
          >
            <option value="1">{t("difficulty.1")}</option>
            <option value="2">{t("difficulty.2")}</option>
            <option value="3">{t("difficulty.3")}</option>
          </select>
        </div>
        <div>
          <Label htmlFor="q-durum">{t("form.durum")}</Label>
          <select
            id="q-durum"
            className={selectClass}
            value={durum}
            disabled={saving}
            onChange={(e) => setDurum(e.target.value as QuestionStatus)}
          >
            <option value="beklemede">{t("status.beklemede")}</option>
            <option value="onaylandi">{t("status.onaylandi")}</option>
            <option value="reddedildi">{t("status.reddedildi")}</option>
          </select>
        </div>
      </div>

      <div className="mt-4">
        <Label>{t("form.soruMetni")}</Label>
        <TextArea
          rows={4}
          value={soru}
          disabled={saving}
          onChange={setSoru}
          placeholder={t("form.soruMetniPlaceholder")}
        />
      </div>

      <div className="mt-4">
        <Label>{t("form.siklar")}</Label>
        <p className="mb-2 text-theme-xs text-gray-500 dark:text-gray-400">
          {t("form.siklarHint")}
        </p>
        <div className="grid gap-3 sm:grid-cols-2">
          {OPTION_KEYS.map((k) => (
            <div key={k} className="flex items-center gap-2">
              <span className="w-5 text-sm font-semibold text-gray-700 dark:text-gray-300">
                {k}
              </span>
              <div className="flex-1">
                <Input
                  aria-label={t("form.sik", { key: k })}
                  value={siklar[k]}
                  disabled={saving}
                  placeholder={
                    k === "A" || k === "B"
                      ? t("form.required")
                      : t("form.optional")
                  }
                  onChange={(e) =>
                    setSiklar((prev) => ({ ...prev, [k]: e.target.value }))
                  }
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="mt-4 grid gap-4 sm:grid-cols-2">
        <div>
          <Label htmlFor="q-dogru">{t("form.dogruSik")}</Label>
          <select
            id="q-dogru"
            className={selectClass}
            value={dogruValue}
            disabled={saving}
            onChange={(e) => setDogru(e.target.value)}
          >
            <option value="">{t("form.dogruSikPlaceholder")}</option>
            {filledKeys.map((k) => (
              <option key={k} value={k}>
                {k}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="mt-4">
        <Label>{t("form.cozum")}</Label>
        <TextArea
          rows={4}
          value={adimlar}
          disabled={saving}
          onChange={setAdimlar}
          placeholder={t("form.cozumPlaceholder")}
          hint={t("form.cozumHint")}
        />
      </div>

      {error && (
        <div
          role="alert"
          className="mt-4 rounded-lg border border-error-200 bg-error-50 px-4 py-3 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400"
        >
          {error}
        </div>
      )}

      <div className="mt-6 flex justify-end gap-3">
        <button
          type="button"
          disabled={saving}
          onClick={onClose}
          className="rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
        >
          {t("form.cancel")}
        </button>
        <button
          type="button"
          disabled={saving}
          onClick={save}
          className="rounded-lg bg-brand-500 px-5 py-2.5 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600 disabled:opacity-50"
        >
          {saving ? t("form.saving") : t("form.save")}
        </button>
      </div>
    </Modal>
  );
}
