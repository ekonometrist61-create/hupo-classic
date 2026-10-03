"use client";

import {
  AnimatePresence,
  motion,
  useReducedMotion,
  type Transition,
} from "framer-motion";
import { useTranslations } from "next-intl";
import Image from "next/image";
import { useCallback, useEffect, useState } from "react";

// Karşılama ekranı yalnızca tarayıcı oturumu başına bir kez gösterilir;
// böylece sayfa geçişlerinde kullanıcıyı tekrar tekrar rahatsız etmez.
const OTURUM_ANAHTARI = "hupo-karsilama-gosterildi";
// Ekranda kalma süresi (ms). İlerleme çubuğu bu süreyle senkron ilerler.
const GORUNME_SURESI = 2400;

/**
 * Uygulama ilk açıldığında gösterilen kısa karşılama animasyonu.
 * Logo, başlık ve alt yazı sırayla belirir; ardından ekran yumuşakça kaybolur.
 */
export default function WelcomeSplash() {
  const t = useTranslations("welcome");
  const azHareket = useReducedMotion();
  const [gorunur, setGorunur] = useState(false);

  const kapat = useCallback(() => setGorunur(false), []);

  useEffect(() => {
    // Depolama erişilemezse (gizli mod vb.) karşılama her açılışta gösterilir,
    // bu yüzden burada hata kullanıcıya gösterilmez — bilinçli olarak yok sayılır.
    let dahaOnceGosterildi = false;
    try {
      dahaOnceGosterildi =
        window.sessionStorage.getItem(OTURUM_ANAHTARI) === "1";
      if (!dahaOnceGosterildi) {
        window.sessionStorage.setItem(OTURUM_ANAHTARI, "1");
      }
    } catch {
      dahaOnceGosterildi = false;
    }

    if (dahaOnceGosterildi) return;

    setGorunur(true);
    const zaman = window.setTimeout(() => setGorunur(false), GORUNME_SURESI);
    return () => window.clearTimeout(zaman);
  }, []);

  // Kullanıcı klavyeyle karşılamayı erken geçmek isterse ekranı kapat.
  useEffect(() => {
    if (!gorunur) return;
    const klavye = (e: KeyboardEvent) => {
      if (e.key === "Escape" || e.key === "Enter" || e.key === " ") {
        kapat();
      }
    };
    window.addEventListener("keydown", klavye);
    return () => window.removeEventListener("keydown", klavye);
  }, [gorunur, kapat]);

  const yumusak = (gecikme = 0): Transition =>
    azHareket ? { duration: 0 } : { duration: 0.5, delay: gecikme, ease: "easeOut" };

  return (
    <AnimatePresence>
      {gorunur && (
        <motion.div
          key="hupo-karsilama"
          role="status"
          aria-live="polite"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={azHareket ? { duration: 0 } : { duration: 0.35 }}
          className="fixed inset-0 z-[9999] flex flex-col items-center justify-center gap-8 overflow-hidden bg-white dark:bg-gray-950"
        >
          {/* Marka parıltısı */}
          <motion.div
            aria-hidden
            initial={{ opacity: 0, scale: 0.6 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={yumusak(0.1)}
            className="pointer-events-none absolute h-72 w-72 rounded-full bg-brand-500/20 blur-3xl"
          />

          {/* Logo — açık/koyu tema için ayrı varyant */}
          <motion.div
            initial={azHareket ? false : { opacity: 0, y: 18, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={
              azHareket
                ? { duration: 0 }
                : { type: "spring", stiffness: 220, damping: 18, delay: 0.15 }
            }
          >
            <Image
              src="/images/logo/logo.svg"
              alt={t("brand")}
              width={154}
              height={32}
              priority
              className="h-8 w-auto dark:hidden"
            />
            <Image
              src="/images/logo/logo-dark.svg"
              alt={t("brand")}
              width={154}
              height={32}
              priority
              className="hidden h-8 w-auto dark:block"
            />
          </motion.div>

          {/* Metinler */}
          <div className="flex flex-col items-center gap-2 px-6 text-center">
            <motion.h1
              initial={azHareket ? false : { opacity: 0, y: 14 }}
              animate={{ opacity: 1, y: 0 }}
              transition={yumusak(0.35)}
              className="text-2xl font-semibold text-gray-800 sm:text-3xl dark:text-white"
            >
              {t("title")}
            </motion.h1>
            <motion.p
              initial={azHareket ? false : { opacity: 0, y: 14 }}
              animate={{ opacity: 1, y: 0 }}
              transition={yumusak(0.5)}
              className="text-theme-sm text-gray-500 dark:text-gray-400"
            >
              {t("subtitle")}
            </motion.p>
          </div>

          {/* Erken geçmek için — klavye ve dokunma erişimi */}
          <motion.button
            type="button"
            onClick={kapat}
            initial={azHareket ? false : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={yumusak(0.7)}
            className="absolute bottom-6 text-theme-sm font-medium text-gray-400 underline-offset-4 transition-colors hover:text-brand-500 hover:underline dark:text-gray-500 dark:hover:text-brand-400"
          >
            {t("skip")}
          </motion.button>

          {/* İlerleme çubuğu — görünme süresiyle senkron */}
          <motion.div
            aria-hidden
            initial={{ width: "0%" }}
            animate={{ width: "100%" }}
            transition={
              azHareket
                ? { duration: 0 }
                : { duration: GORUNME_SURESI / 1000, ease: "linear" }
            }
            className="absolute bottom-0 start-0 h-1 bg-brand-500"
          />
        </motion.div>
      )}
    </AnimatePresence>
  );
}
