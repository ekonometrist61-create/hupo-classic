"use client";

import { Modal } from "@/components/ui/modal";
import { useTranslations } from "next-intl";

interface DeleteConfirmModalProps {
  count: number;
  busy: boolean;
  onConfirm: () => void;
  onClose: () => void;
}

export default function DeleteConfirmModal({
  count,
  busy,
  onConfirm,
  onClose,
}: DeleteConfirmModalProps) {
  const t = useTranslations("yonetim.sorular");

  return (
    <Modal
      isOpen
      onClose={busy ? () => undefined : onClose}
      showCloseButton={false}
      className="m-4 max-w-lg p-6 sm:p-8"
    >
      <h3 className="mb-3 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("delete.title", { count })}
      </h3>
      <div className="mb-6 rounded-lg border border-error-200 bg-error-50 p-4 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400">
        <p className="mb-2 font-medium">{t("delete.warningTitle")}</p>
        <p>{t("delete.warning")}</p>
      </div>
      <div className="flex justify-end gap-3">
        <button
          type="button"
          disabled={busy}
          onClick={onClose}
          className="rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
        >
          {t("delete.cancel")}
        </button>
        <button
          type="button"
          disabled={busy}
          onClick={onConfirm}
          className="rounded-lg bg-error-500 px-4 py-2.5 text-sm font-medium text-white hover:bg-error-600 disabled:opacity-50"
        >
          {busy ? t("delete.deleting") : t("delete.confirm", { count })}
        </button>
      </div>
    </Modal>
  );
}
