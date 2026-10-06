"use client";

import { useTranslations } from "next-intl";

import { cardClass, primaryBtn } from "../panel/styles";
import type { RpcState } from "../useAdminRpc";

/** Yükleniyor / hata / "migration uygulanmadı" durumlarını tek yerde gösterir. */
export default function RpcBoundary<T>({
  state,
  children,
}: {
  state: RpcState<T>;
  children: (data: T) => React.ReactNode;
}) {
  const t = useTranslations("yonetim.merkez.common");

  if (state.loading) {
    return (
      <div className={`${cardClass} px-6 py-14 text-center text-sm text-gray-500 dark:text-gray-400`}>
        {t("loading")}
      </div>
    );
  }
  if (state.error || state.data === null) {
    return (
      <div className={`${cardClass} px-6 py-10 text-center`} role="alert">
        <p className="mb-1 text-sm font-semibold text-error-600 dark:text-error-500">
          {state.missing ? t("notDeployedTitle") : t("errorTitle")}
        </p>
        <p className="mx-auto mb-4 max-w-lg text-theme-sm text-gray-500 dark:text-gray-400">
          {state.missing ? t("notDeployedText") : (state.error ?? t("errorTitle"))}
        </p>
        <button type="button" className={primaryBtn} onClick={state.reload}>
          {t("retry")}
        </button>
      </div>
    );
  }
  return <>{children(state.data)}</>;
}
