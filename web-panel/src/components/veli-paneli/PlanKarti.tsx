"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

interface PlanSatir {
  kod: string;
  ad: string;
  aciklama: string | null;
  fiyat_kurus: number;
  sure_gun: number;
  /** null: deneme bilgisi tanımlı değil (bilinmiyor); 0: ücretsiz deneme yok. */
  deneme_gun: number | null;
}

type Durum = "yukleniyor" | "hata" | "hazirlik" | PlanSatir[];

// Paket listesi list_active_plans RPC'sinden gelir (yalnızca aktif planlar).
// Satın alma veli oturumuyla payments-checkout fonksiyonunu çağırır; tutar istemciden alınmaz.
// Ödeme iyzico sayfasında 3D Secure ile tamamlanır; kart bilgisi bu uygulamada istenmez.
// K7: koşullar (ücret, süre, deneme, yenileme) CTA'nın hemen üstünde yazılır; veri yoksa "bilinmiyor".
export default function PlanKarti() {
  const t = useTranslations("veliPaneli.membership.plans");
  const [durum, setDurum] = useState<Durum>("yukleniyor");
  const [odemeKod, setOdemeKod] = useState<string | null>(null);
  const [odemeHata, setOdemeHata] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const supabase = createClient();
      const { data, error } = await supabase.rpc("list_active_plans");
      if (cancelled) return;
      if (error) { setDurum("hata"); return; }
      if (!Array.isArray(data) || data.length === 0) { setDurum("hazirlik"); return; }
      setDurum(data as PlanSatir[]);
    };
    void run();
    return () => { cancelled = true; };
  }, []);

  const fiyatMetni = (kurus: number) =>
    new Intl.NumberFormat("tr-TR", { style: "currency", currency: "TRY" }).format(kurus / 100);

  const denemeMetni = (gun: number | null) => {
    if (gun === null) return t("bilinmiyor");
    return gun > 0 ? t("trial", { gun }) : t("noTrial");
  };

  const satinAl = async (kod: string) => {
    if (odemeKod) return; // çift tıklama koruması
    setOdemeKod(kod);
    setOdemeHata(null);
    try {
      const supabase = createClient();
      const { data, error } = await supabase.functions.invoke("payments-checkout", {
        body: { plan_kod: kod },
      });
      const url = (data as { odeme_url?: string } | null)?.odeme_url;
      if (error || !url) {
        setOdemeHata(t("checkoutError"));
        setOdemeKod(null);
        return;
      }
      window.location.assign(url);
    } catch {
      setOdemeHata(t("checkoutError"));
      setOdemeKod(null);
    }
  };

  return (
    <div className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">
        {t("title")}
      </h3>

      {durum === "yukleniyor" && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      )}

      {durum === "hata" && (
        <p role="alert" className="text-sm text-error-500">{t("error")}</p>
      )}

      {durum === "hazirlik" && (
        <p className="text-sm text-gray-600 dark:text-gray-300">{t("preparing")}</p>
      )}

      {Array.isArray(durum) && (
        <ul className="space-y-3">
          {durum.map((p) => (
            <li
              key={p.kod}
              className="min-w-0 rounded-xl border border-gray-200 p-4 dark:border-gray-700"
            >
              <p className="font-semibold text-gray-800 dark:text-white/90">{p.ad}</p>
              {p.aciklama && (
                <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{p.aciklama}</p>
              )}

              <dl className="mt-3 grid grid-cols-1 gap-3 text-sm sm:grid-cols-2">
                <div>
                  <dt className="text-xs text-gray-500 dark:text-gray-400">{t("priceLabel")}</dt>
                  <dd className="font-semibold text-gray-800 dark:text-white/80">
                    {fiyatMetni(p.fiyat_kurus)}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs text-gray-500 dark:text-gray-400">{t("periodLabel")}</dt>
                  <dd className="font-medium text-gray-800 dark:text-white/80">
                    {t("duration", { gun: p.sure_gun })}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs text-gray-500 dark:text-gray-400">{t("trialLabel")}</dt>
                  <dd className="font-medium text-gray-800 dark:text-white/80">
                    {denemeMetni(p.deneme_gun)}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs text-gray-500 dark:text-gray-400">{t("renewalLabel")}</dt>
                  <dd className="font-medium text-gray-800 dark:text-white/80">{t("bilinmiyor")}</dd>
                </div>
              </dl>

              <button
                type="button"
                onClick={() => void satinAl(p.kod)}
                disabled={odemeKod !== null}
                aria-busy={odemeKod === p.kod}
                className="mt-4 inline-flex min-h-11 w-full items-center justify-center rounded-xl bg-brand-500 px-5 text-sm font-bold text-white transition-colors hover:bg-brand-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto"
              >
                {odemeKod === p.kod ? t("checkoutLoading") : t("buy")}
              </button>
            </li>
          ))}
          {odemeHata && (
            <li role="alert" className="text-sm text-error-500">{odemeHata}</li>
          )}
          <li className="text-sm text-gray-500 dark:text-gray-400">{t("paymentNote")}</li>
          <li className="text-sm text-gray-500 dark:text-gray-400">{t("cancelNote")}</li>
        </ul>
      )}
    </div>
  );
}
