"use client";

import { useEffect, useRef } from "react";

/** Sağdan açılan yan çekmece (yerel <dialog>): Esc ve zemine tıklama ile kapanır, odak tuzağı tarayıcıdan gelir. */
export default function Drawer({
  open,
  onClose,
  title,
  closeLabel,
  children,
}: {
  open: boolean;
  onClose: () => void;
  title: string;
  closeLabel: string;
  children: React.ReactNode;
}) {
  const ref = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (open && !d.open) d.showModal();
    if (!open && d.open) d.close();
  }, [open]);

  return (
    <dialog
      ref={ref}
      aria-label={title}
      onClose={onClose}
      onClick={(e) => e.target === ref.current && onClose()}
      className="m-0 ms-auto h-full max-h-full w-122.5 max-w-[95%] rounded-s-2xl border border-gray-200 bg-white p-6 text-gray-800 shadow-theme-xl backdrop:bg-navy/40 backdrop:backdrop-blur-sm dark:border-gray-800 dark:bg-gray-900 dark:text-white/90"
    >
      {open && (
        <>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-navy dark:text-white/90">{title}</h2>
            <button
              type="button"
              onClick={onClose}
              aria-label={closeLabel}
              className="rounded-lg px-2 py-1 text-gray-500 hover:bg-gray-100 focus-visible:outline-3 focus-visible:outline-blue-light-400 dark:hover:bg-white/5"
            >
              ✕
            </button>
          </div>
          {children}
        </>
      )}
    </dialog>
  );
}
