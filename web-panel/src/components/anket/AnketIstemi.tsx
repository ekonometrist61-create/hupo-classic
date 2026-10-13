"use client";

import { useEffect, useRef, useState } from "react";
import { useTranslations } from "next-intl";
import { createClient } from "@/utils/supabase/client";
import { Modal } from "@/components/ui/modal";
import AnketDiyalog from "./AnketDiyalog";
import {
  anketGecerliMi,
  ertele,
  ertelenmisMi,
  type Anket,
  type Yuzey,
} from "./anketMantik";

interface AnketIstemiProps {
  yuzey: Yuzey;
}

// Giriş yapmış velinin, bu mecrada yayınlanan ve henüz yanıtlamadığı anketi gösteren kart.
// Oturum yoksa (ziyaretçi) ya da hesap veli değilse hiçbir şey çizmez ve sunucuya istek atmaz/
// hata göstermez: anket yardımcı bir özelliktir, sayfanın geri kalanı bundan etkilenmemeli.
export default function AnketIstemi({ yuzey }: AnketIstemiProps) {
  const t = useTranslations("anket");
  const [anketler, setAnketler] = useState<Anket[]>([]);
  const [modalAcik, setModalAcik] = useState(false);
  const [mesaj, setMesaj] = useState<"tesekkur" | "zaten" | null>(null);
  const tetikRef = useRef<HTMLButtonElement>(null);
  const mesajRef = useRef<HTMLParagraphElement>(null);

  useEffect(() => {
    let iptal = false;

    async function yukle() {
      try {
        const supabase = createClient();
        const {
          data: { session },
        } = await supabase.auth.getSession();
        if (!session) return;

        const { data, error } = await supabase.rpc("anket_aktif_listem", {
          p_yuzey: yuzey,
        });
        if (iptal || error || !Array.isArray(data)) return;

        setAnketler(
          (data as unknown[]).filter(anketGecerliMi).filter((a) => !ertelenmisMi(a))
        );
      } catch {
        // Anket yüklenemezse sayfa anketsiz çizilir; kullanıcıya hata gösterilmez.
      }
    }

    void yukle();
    return () => {
      iptal = true;
    };
  }, [yuzey]);

  // Durum mesajı (teşekkür / zaten katıldınız) çıkınca odağı ona taşı: ekran okuyucu duyar.
  useEffect(() => {
    if (mesaj) mesajRef.current?.focus();
  }, [mesaj]);

  const aktif = anketler[0];

  function vazgec() {
    setModalAcik(false);
    // Modal kapanınca odak "Ankete katıl" düğmesine dönsün.
    requestAnimationFrame(() => tetikRef.current?.focus());
  }

  function sonraYap() {
    if (!aktif) return;
    ertele(aktif);
    setAnketler((onceki) => onceki.filter((a) => a.id !== aktif.id));
  }

  function bitti(durum: "tesekkur" | "zaten") {
    if (!aktif) return;
    const kapanan = aktif.id;
    setModalAcik(false);
    setAnketler((onceki) => onceki.filter((a) => a.id !== kapanan));
    setMesaj(durum);
  }

  if (!aktif && !mesaj) return null;

  const sarmal =
    yuzey === "web_sitesi"
      ? "mx-auto w-full max-w-6xl px-4 py-6 sm:px-6 lg:px-8"
      : "mb-6";

  return (
    <section aria-label={t("bolumEtiketi")} className={sarmal}>
      {mesaj && (
        <p
          ref={mesajRef}
          tabIndex={-1}
          role="status"
          className="mb-3 rounded-2xl border border-brand-100 bg-brand-25 px-4 py-3 text-sm text-brand-700 outline-none dark:border-brand-900 dark:bg-brand-950/40 dark:text-brand-200"
        >
          {mesaj === "tesekkur" ? t("tesekkurKisa") : t("zatenKatildi")}
        </p>
      )}

      {aktif && (
        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-theme-xs dark:border-gray-800 dark:bg-white/[0.03]">
          <p className="text-xs font-semibold uppercase tracking-wide text-gold-800 dark:text-gold-400">
            {t("kartEtiketi")}
          </p>
          <h2 className="mt-1 text-base font-semibold text-gray-900 dark:text-white/90">
            {aktif.ad}
          </h2>
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
            {t("kartMetni")}
          </p>
          <div className="mt-4 flex flex-wrap items-center gap-2">
            <button
              ref={tetikRef}
              type="button"
              onClick={() => setModalAcik(true)}
              className="inline-flex min-h-11 items-center justify-center rounded-xl bg-brand-500 px-5 text-sm font-semibold text-white transition-colors hover:bg-brand-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-900"
            >
              {t("katil")}
            </button>
            <button
              type="button"
              onClick={sonraYap}
              className="inline-flex min-h-11 items-center justify-center rounded-xl px-4 text-sm font-medium text-gray-600 transition-colors hover:bg-gray-100 hover:text-gray-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
            >
              {t("sonra")}
            </button>
          </div>
        </div>
      )}

      {aktif && modalAcik && (
        <Modal isOpen onClose={vazgec} className="max-w-lg">
          <AnketDiyalog anket={aktif} yuzey={yuzey} onBitti={bitti} />
        </Modal>
      )}
    </section>
  );
}
