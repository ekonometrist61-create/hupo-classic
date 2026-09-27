"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import type { AdminUser } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import ParentPicker from "./ParentPicker";
import { outlineBtn, primaryBtn } from "./styles";

interface Props {
  child: AdminUser;
  onClose: () => void;
  onSaved: () => void;
}

/** Üst bileşen key={child.id} ile bağlamalıdır. */
export default function LinkChildModal({ child, onClose, onSaved }: Props) {
  const t = useTranslations("yonetim.kullanicilar.link");
  const [parent, setParent] = useState<AdminUser | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = async () => {
    if (!parent) return setError(t("errParent"));
    setSaving(true);
    setError(null);
    const { error: err } = await createClient().rpc("admin_link_child", {
      p_cocuk_id: child.id,
      p_veli_id: parent.id,
    });
    setSaving(false);
    if (err) return setError(err.message);
    onSaved();
    onClose();
  };

  return (
    <ModalShell
      isOpen
      onClose={onClose}
      title={child.veli_id ? t("titleChange") : t("title")}
    >
      <div className="space-y-4">
        <p className="text-theme-sm text-gray-500 dark:text-gray-400">
          {t("student")}: <b className="text-gray-800 dark:text-white/90">{child.ad ?? child.email}</b>
          {child.veli_ad && <> · {t("current")}: {child.veli_ad}</>}
        </p>
        <ParentPicker selected={parent} onSelect={setParent} />
        <ErrorNote message={error} />
        <div className="flex justify-end gap-3">
          <button type="button" className={outlineBtn} onClick={onClose}>
            {t("cancel")}
          </button>
          <button type="button" className={primaryBtn} disabled={saving || !parent} onClick={submit}>
            {saving ? t("saving") : t("save")}
          </button>
        </div>
      </div>
    </ModalShell>
  );
}
