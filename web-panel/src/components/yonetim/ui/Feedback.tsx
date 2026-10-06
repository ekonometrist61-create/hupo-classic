/** Eylem sonrası satır içi geri bildirim (başarı / hata). Ekran okuyucuya duyurulur. */
export default function Feedback({
  kind,
  message,
}: {
  kind: "ok" | "error";
  message: string | null;
}) {
  if (!message) return null;
  return (
    <p
      role={kind === "error" ? "alert" : "status"}
      className={
        kind === "error"
          ? "rounded-lg bg-error-50 px-3 py-2 text-theme-sm text-error-600 dark:bg-error-500/15 dark:text-error-500"
          : "rounded-lg bg-success-50 px-3 py-2 text-theme-sm text-success-700 dark:bg-success-500/15 dark:text-success-500"
      }
    >
      {message}
    </p>
  );
}
