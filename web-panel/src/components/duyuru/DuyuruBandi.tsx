"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { createClient } from "@/utils/supabase/client";
import type { SurveySurface } from "@/components/yonetim/merkez/types";

interface AktifDuyuru {
  id: string;
  baslik: string;
  metin: string;
  bitis_at: string | null;
}

interface DuyuruBandiProps {
  yuzey: SurveySurface;
}

const KAPALI_ANAHTAR = "hupo:duyuru-kapali:";

// Kullanıcı kapattıysa aynı duyuru id'si bir daha çıkmaz. Tarayıcı depolaması erişilemezse
// (gizli pencere, engellenmiş site verisi) duyuru yine gösterilir; hata kullanıcıya yansımaz.
function kapaliMi(id: string): boolean {
  try {
    return window.localStorage.getItem(KAPALI_ANAHTAR + id) === "1";
  } catch {
    return false;
  }
}

function kapaliKaydet(id: string): void {
  try {
    window.localStorage.setItem(KAPALI_ANAHTAR + id, "1");
  } catch {
    // Yazılamadıysa bu oturumda yine de gizlenir; bir sonraki ziyarette tekrar çıkabilir.
  }
}

// Verilen mecrada yayınlanan en yeni duyuruyu gösteren şerit. Giriş şartı yoktur (duyuru herkese açık);
// duyuru yoksa veya okuma başarısızsa hiçbir şey çizilmez ve sayfa etkilenmez.
export default function DuyuruBandi({ yuzey }: DuyuruBandiProps) {
  const t = useTranslations("landing.duyuruSeridi");
  const [duyuru, setDuyuru] = useState<AktifDuyuru | null>(null);

  useEffect(() => {
    let iptal = false;

    async function yukle() {
      try {
        const supabase = createClient();
        const { data, error } = await supabase.rpc("get_aktif_duyuru", { p_yuzey: yuzey });
        if (iptal || error || !data) return;

        const d = data as AktifDuyuru;
        if (!d.baslik || kapaliMi(d.id)) return;
        setDuyuru(d);
      } catch {
        // Duyuru yüklenemezse şerit çizilmez.
      }
    }

    void yukle();
    return () => {
      iptal = true;
    };
  }, [yuzey]);

  if (!duyuru) return null;

  const kapat = () => {
    kapaliKaydet(duyuru.id);
    setDuyuru(null);
  };

  return (
    <section
      aria-label={t("etiket")}
      className="mb-6 rounded-2xl bg-success-700 text-white shadow-theme-xs dark:bg-success-800 dark:text-white"
    >
      <div className="flex items-start gap-3 px-4 py-3 text-sm sm:items-center sm:px-5">
        <div className="flex min-w-0 flex-1 flex-col gap-1 sm:flex-row sm:items-center sm:gap-3">
          <span className="inline-flex w-fit shrink-0 rounded-full bg-gold-500 px-2.5 py-0.5 text-xs font-extrabold uppercase tracking-wide text-navy shadow-sm">
            {t("etiket")}
          </span>
          <p className="font-bold">{duyuru.baslik}</p>
          {duyuru.metin && <p className="text-white">{duyuru.metin}</p>}
        </div>
        <button
          type="button"
          onClick={kapat}
          aria-label={t("kapat")}
          className="inline-flex size-11 shrink-0 items-center justify-center rounded-lg text-white transition-colors hover:bg-white/10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white"
        >
          <span aria-hidden="true" className="text-lg leading-none">×</span>
        </button>
      </div>
    </section>
  );
}
