"use client";

import { Modal } from "@/components/ui/modal";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useState } from "react";

import { dokunmaHedefi } from "../ui/responsive";
import KazanimSecici from "./KazanimSecici";

interface KazanimAtaModalProps {
  ids: string[];
  onClose: () => void;
  onDone: (mesaj: string) => void;
}

const outlineButton = `${dokunmaHedefi} justify-center rounded-lg border border-gray-300 px-4 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`;
const primaryButton = `${dokunmaHedefi} justify-center rounded-lg bg-brand-500 px-5 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600 disabled:cursor-not-allowed disabled:opacity-50`;

/** Seçili sorulara tek kazanım atar veya etiketi kaldırır (admin_set_question_kazanim). */
export default function KazanimAtaModal({ ids, onClose, onDone }: KazanimAtaModalProps) {
  const t = useTranslations("yonetim.sorular.kazanim.bulk");

  const [secili, setSecili] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const uygula = async (kod: string | null) => {
    if (ids.length === 0) return;
    setBusy(true);
    setError(null);
    const { data, error: rpcError } = await createClient().rpc(
      "admin_set_question_kazanim",
      { p_ids: ids, p_kod: kod },
    );
    setBusy(false);
    if (rpcError) {
      setError(t("error", { hata: rpcError.message }));
      return;
    }
    const adet = Number(data ?? 0);
    onDone(
      kod === null
        ? t("removed", { count: adet })
        : t("assigned", { count: adet, kod }),
    );
  };

  return (
    <Modal
      isOpen
      onClose={busy ? () => undefined : onClose}
      className="m-4 max-w-2xl p-6 sm:p-8"
      showCloseButton={!busy}
    >
      <h3 className="mb-1 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>
      <p className="mb-5 text-theme-sm text-gray-500 dark:text-gray-400">
        {t("desc", { count: ids.length })}
      </p>

      <KazanimSecici
        secili={secili}
        onSec={setSecili}
        disabled={busy}
      />

      {error && (
        <div
          role="alert"
          className="mt-4 rounded-lg border border-error-200 bg-error-50 px-4 py-3 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400"
        >
          {error}
        </div>
      )}

      <div className="mt-6 flex flex-wrap items-center justify-between gap-3">
        <button
          type="button"
          disabled={busy || ids.length === 0}
          onClick={() => uygula(null)}
          className={`${dokunmaHedefi} justify-center rounded-lg border border-error-300 px-4 text-sm font-medium text-error-700 hover:bg-error-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-error-500/40 dark:text-error-400 dark:hover:bg-error-500/10`}
        >
          {t("remove")}
        </button>
        <div className="flex flex-wrap gap-3">
          <button type="button" disabled={busy} onClick={onClose} className={outlineButton}>
            {t("cancel")}
          </button>
          <button
            type="button"
            disabled={busy || !secili || ids.length === 0}
            onClick={() => secili && uygula(secili)}
            className={primaryButton}
          >
            {busy ? t("applying") : t("apply")}
          </button>
        </div>
      </div>
    </Modal>
  );
}
