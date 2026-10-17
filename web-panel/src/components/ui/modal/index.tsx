"use client";

import { useTranslations } from "next-intl";
import { useEffect, useRef } from "react";

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  className?: string;
  children: React.ReactNode;
  showCloseButton?: boolean; // New prop to control close button visibility
  isFullscreen?: boolean; // Default to false for backwards compatibility
}

/**
 * Yerel <dialog> ile açılır: odak tuzağı, Escape ve ekran okuyucu rolü tarayıcıdan gelir.
 * İçerik kapsayıcı içinde ortalanır ve taşarsa dialog kayar; üst kısım kırpılmaz (TASKS §20).
 */
export const Modal: React.FC<ModalProps> = ({
  isOpen,
  onClose,
  children,
  className,
  showCloseButton = true, // Default to true for backwards compatibility
  isFullscreen = false,
}) => {
  const t = useTranslations("yonetim.shell");
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (isOpen && !dialog.open) dialog.showModal();
    if (!isOpen && dialog.open) dialog.close();
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) return;
    const oncekiTasma = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = oncekiTasma;
    };
  }, [isOpen]);

  const contentClasses = isFullscreen
    ? "min-h-full w-full"
    : "relative m-4 w-full rounded-3xl bg-white dark:bg-gray-900";

  return (
    <dialog
      ref={dialogRef}
      // Escape: tarayıcı olayı; kapatma ebeveyn durumundan yönetilir.
      onCancel={(e) => {
        e.preventDefault();
        onClose();
      }}
      className="inset-0 m-0 h-dvh max-h-none w-screen max-w-none overflow-y-auto bg-transparent p-0 backdrop:bg-gray-400/50 backdrop:backdrop-blur-[32px]"
    >
      {isOpen && (
        <div
          className="flex min-h-full items-center justify-center"
          onClick={(e) => {
            // Kart dışındaki alana (perde) tıklanınca kapanır.
            if (!isFullscreen && e.target === e.currentTarget) onClose();
          }}
        >
          <div className={`${contentClasses} ${className ?? ""}`}>
            {showCloseButton && (
              <button
                type="button"
                onClick={onClose}
                aria-label={t("closeModal")}
                className="inset-e-3 sm:inset-e-6 absolute top-3 z-999 flex h-11 w-11 items-center justify-center rounded-full bg-gray-100 text-gray-500 transition-colors hover:bg-gray-200 hover:text-gray-700 sm:top-6 dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
              >
                <svg
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  aria-hidden
                >
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M6.04289 16.5413C5.65237 16.9318 5.65237 17.565 6.04289 17.9555C6.43342 18.346 7.06658 18.346 7.45711 17.9555L11.9987 13.4139L16.5408 17.956C16.9313 18.3466 17.5645 18.3466 17.955 17.956C18.3455 17.5655 18.3455 16.9323 17.955 16.5418L13.4129 11.9997L17.955 7.4576C18.3455 7.06707 18.3455 6.43391 17.955 6.04338C17.5645 5.65286 16.9313 5.65286 16.5408 6.04338L11.9987 10.5855L7.45711 6.0439C7.06658 5.65338 6.43342 5.65338 6.04289 6.0439C5.65237 6.43442 5.65237 7.06759 6.04289 7.45811L10.5845 11.9997L6.04289 16.5413Z"
                    fill="currentColor"
                  />
                </svg>
              </button>
            )}
            <div>{children}</div>
          </div>
        </div>
      )}
    </dialog>
  );
};
