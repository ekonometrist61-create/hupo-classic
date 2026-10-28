import OgrenciNav from "@/components/ogrenci/OgrenciNav";
import { ReactNode } from "react";

export default function OgrenciLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950">
      <OgrenciNav />
      <main className="mx-auto max-w-5xl px-4 py-6 sm:px-6">{children}</main>
    </div>
  );
}
