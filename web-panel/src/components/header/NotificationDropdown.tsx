"use client";

import { Link } from "@/i18n/navigation";
import { cn } from "@/utils";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";
import { Dropdown } from "../ui/dropdown/Dropdown";
import { DropdownItem } from "../ui/dropdown/DropdownItem";

interface Bildirim {
  id: string;
  baslik: string;
  mesaj: string;
  okundu: boolean;
  created_at: string;
}

function zaman(iso: string) {
  const diff = Math.floor((Date.now() - new Date(iso).getTime()) / 60000);
  if (diff < 1) return "şimdi";
  if (diff < 60) return `${diff} dk önce`;
  const saat = Math.floor(diff / 60);
  if (saat < 24) return `${saat} sa önce`;
  return `${Math.floor(saat / 24)} gün önce`;
}

export default function NotificationDropdown() {
  const t = useTranslations("header.notifications");
  const [isOpen, setIsOpen] = useState(false);
  const [bildirimler, setBildirimler] = useState<Bildirim[]>([]);
  const [okunmamis, setOkunmamis] = useState(0);

  useEffect(() => {
    const supabase = createClient();
    const run = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;
      const { data } = await supabase
        .from("notifications")
        .select("id, baslik, mesaj, okundu, created_at")
        .eq("alici_id", user.id)
        .order("created_at", { ascending: false })
        .limit(10);
      if (data) {
        setBildirimler(data as Bildirim[]);
        setOkunmamis(data.filter((b) => !b.okundu).length);
      }
    };
    void run();
  }, []);

  const markRead = async (id: string) => {
    await createClient()
      .from("notifications")
      .update({ okundu: true })
      .eq("id", id);
    setBildirimler((prev) =>
      prev.map((b) => (b.id === id ? { ...b, okundu: true } : b)),
    );
    setOkunmamis((n) => Math.max(0, n - 1));
  };

  return (
    <div className="relative">
      <button
        className="dropdown-toggle relative flex h-11 w-11 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-500 transition-colors hover:bg-gray-100 hover:text-gray-700 dark:border-gray-800 dark:bg-gray-900 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-white"
        onClick={() => setIsOpen((v) => !v)}
        aria-label={t("title")}
      >
        {okunmamis > 0 && (
          <span className="absolute top-0.5 right-0 z-10 h-2 w-2 rounded-full bg-orange-400">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-orange-400 opacity-75" />
          </span>
        )}
        <svg className="fill-current" width="20" height="20" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path fillRule="evenodd" clipRule="evenodd" d="M10.75 2.29248C10.75 1.87827 10.4143 1.54248 10 1.54248C9.58583 1.54248 9.25004 1.87827 9.25004 2.29248V2.83613C6.08266 3.20733 3.62504 5.9004 3.62504 9.16748V14.4591H3.33337C2.91916 14.4591 2.58337 14.7949 2.58337 15.2091C2.58337 15.6234 2.91916 15.9591 3.33337 15.9591H4.37504H15.625H16.6667C17.0809 15.9591 17.4167 15.6234 17.4167 15.2091C17.4167 14.7949 17.0809 14.4591 16.6667 14.4591H16.375V9.16748C16.375 5.9004 13.9174 3.20733 10.75 2.83613V2.29248ZM14.875 14.4591V9.16748C14.875 6.47509 12.6924 4.29248 10 4.29248C7.30765 4.29248 5.12504 6.47509 5.12504 9.16748V14.4591H14.875ZM8.00004 17.7085C8.00004 18.1228 8.33583 18.4585 8.75004 18.4585H11.25C11.6643 18.4585 12 18.1228 12 17.7085C12 17.2943 11.6643 16.9585 11.25 16.9585H8.75004C8.33583 16.9585 8.00004 17.2943 8.00004 17.7085Z" fill="currentColor" />
        </svg>
      </button>

      <Dropdown
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        className="absolute -left-13.5 mt-4.25 flex w-80 flex-col rounded-2xl border border-gray-200 bg-white p-3 shadow-theme-lg sm:w-90 xl:right-0 xl:left-auto dark:border-gray-800 dark:bg-gray-dark"
      >
        <div className="mb-3 flex items-center justify-between border-b border-gray-100 pb-3 dark:border-gray-700">
          <h5 className="text-lg font-semibold text-gray-800 dark:text-gray-200">
            {t("title")}
            {okunmamis > 0 && (
              <span className="ms-2 rounded-full bg-orange-100 px-2 py-0.5 text-xs font-medium text-orange-700 dark:bg-orange-900/30 dark:text-orange-400">
                {okunmamis}
              </span>
            )}
          </h5>
          <button
            onClick={() => setIsOpen(false)}
            className="text-gray-500 transition hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
          >
            <svg className="fill-current" width="20" height="20" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path fillRule="evenodd" clipRule="evenodd" d="M6.21967 7.28131C5.92678 6.98841 5.92678 6.51354 6.21967 6.22065C6.51256 5.92775 6.98744 5.92775 7.28033 6.22065L11.999 10.9393L16.7176 6.22078C17.0105 5.92789 17.4854 5.92788 17.7782 6.22078C18.0711 6.51367 18.0711 6.98855 17.7782 7.28144L13.0597 12L17.7782 16.7186C18.0711 17.0115 18.0711 17.4863 17.7782 17.7792C17.4854 18.0721 17.0105 18.0721 16.7176 17.7792L11.999 13.0607L7.28033 17.7794C6.98744 18.0722 6.51256 18.0722 6.21967 17.7794C5.92678 17.4865 5.92678 17.0116 6.21967 16.7187L10.9384 12L6.21967 7.28131Z" fill="currentColor" />
            </svg>
          </button>
        </div>

        <ul className={cn("custom-scrollbar flex flex-col overflow-y-auto", bildirimler.length > 5 ? "max-h-96" : "")}>
          {bildirimler.length === 0 ? (
            <li className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">
              Henüz bildirim yok.
            </li>
          ) : (
            bildirimler.map((b) => (
              <li key={b.id}>
                <DropdownItem
                  onItemClick={() => { if (!b.okundu) void markRead(b.id); }}
                  className={cn(
                    "flex flex-col gap-1 rounded-lg border-b border-gray-100 px-3 py-3 hover:bg-gray-50 dark:border-gray-800 dark:hover:bg-white/5",
                    !b.okundu && "bg-brand-50/60 dark:bg-brand-500/5",
                  )}
                >
                  <div className="flex items-start justify-between gap-2">
                    <p className={cn("text-theme-sm", b.okundu ? "text-gray-700 dark:text-gray-300" : "font-semibold text-gray-800 dark:text-white/90")}>
                      {b.baslik}
                    </p>
                    {!b.okundu && (
                      <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
                    )}
                  </div>
                  <p className="line-clamp-2 text-theme-xs text-gray-500 dark:text-gray-400">
                    {b.mesaj}
                  </p>
                  <span className="text-theme-xs text-gray-400 dark:text-gray-500">
                    {zaman(b.created_at)}
                  </span>
                </DropdownItem>
              </li>
            ))
          )}
        </ul>

        <Link
          href="/veli-paneli"
          className="mt-3 block rounded-lg border border-gray-300 bg-white px-4 py-2 text-center text-sm font-medium text-gray-700 hover:bg-gray-100 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-gray-700"
        >
          {t("viewAll")}
        </Link>
      </Dropdown>
    </div>
  );
}
