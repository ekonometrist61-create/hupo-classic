"use client";

import { Modal } from "@/components/ui/modal";

interface ModalShellProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}

/** Şablon Modal'ı başlık ve iç boşlukla saran ince kabuk. */
export default function ModalShell({ isOpen, onClose, title, children }: ModalShellProps) {
  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      className="m-4 max-w-lg p-6 sm:p-8"
    >
      <h3 className="mb-5 pe-12 text-lg font-semibold text-gray-800 dark:text-white/90">
        {title}
      </h3>
      {children}
    </Modal>
  );
}
