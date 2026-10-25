"use client";

// Toplu arşive alma / silme. Önce kuru çalıştırma (hiçbir şey değişmez) her hikâye için "yapılır" ya da
// "atlanır + neden" gösterir; yönetici onaylarsa gerçek işlem aynı kurallarla çalışır ve sonuç yine
// hikâye başına gösterilir. Kuralları sunucu zorlar (okuma_toplu_islem); burada yalnız gösterilir.
import { useEffect, useRef, useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall } from "@/components/yonetim/useAdminRpc";
import ErrorNote from "../panel/ErrorNote";
import ModalShell from "../panel/ModalShell";
import { dangerBtn, outlineBtn, primaryBtn } from "../panel/styles";
import { useHataMetni } from "./ortak";
import type { TopluIslem, TopluSonucSatiri, TopluYaniti } from "./tipler";

export interface TopluHikaye {
  id: string;
  baslik: string;
  slug: string;
}

// Her işlemin sunucu fonksiyonu; kurallar (yayın kapısı, dört göz, oturum koruması) orada zorlanır.
const RPC: Record<TopluIslem, string> = {
  arsiv: "okuma_toplu_islem",
  sil: "okuma_toplu_islem",
  yayina_al: "okuma_toplu_yayin",
  yayindan_cek: "okuma_toplu_yayin",
};

interface Props {
  islem: TopluIslem;
  hikayeler: TopluHikaye[];
  /** `degisti`: gerçek işlem yapıldı, liste yenilenmeli. */
  onKapat: (degisti: boolean) => void;
}

export default function TopluIslemModal({ islem, hikayeler, onKapat }: Props) {
  const t = useTranslations("yonetim.hikayeAtolyesi.toplu");
  const hata = useHataMetni();
  const [onizleme, setOnizleme] = useState<TopluYaniti | null>(null);
  const [sonuc, setSonuc] = useState<TopluYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [islemde, setIslemde] = useState(false);
  const [hataMesaji, setHataMesaji] = useState<string | null>(null);
  const idler = hikayeler.map((h) => h.id);
  const idKey = idler.join(",");
  const baslikHaritasi = new Map(hikayeler.map((h) => [h.id, h.baslik]));
  const ilkYuk = useRef(false);

  // Açılışta bir kez kuru çalıştırma.
  useEffect(() => {
    if (ilkYuk.current) return;
    ilkYuk.current = true;
    void (async () => {
      const { data, error, missing } = await adminCall<TopluYaniti>(RPC[islem], {
        p_hikaye_idler: idKey.split(","),
        p_islem: islem,
        p_kuru: true,
      });
      setYukleniyor(false);
      if (missing) return setHataMesaji(t("kurulumYok"));
      if (error || !data) return setHataMesaji(hata(error ?? ""));
      setOnizleme(data);
    })();
    // Yalnız açılışta çalışır.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const onayla = async () => {
    setIslemde(true);
    setHataMesaji(null);
    const { data, error } = await adminCall<TopluYaniti>(RPC[islem], {
      p_hikaye_idler: idler,
      p_islem: islem,
      p_kuru: false,
    });
    setIslemde(false);
    if (error || !data) return setHataMesaji(hata(error ?? ""));
    setSonuc(data);
  };

  const gosterilen = sonuc ?? onizleme;
  const yapilacak = onizleme?.basarili ?? 0;
  const kapat = () => (islemde ? undefined : onKapat(sonuc !== null));

  return (
    <ModalShell isOpen onClose={kapat} title={sonuc ? t("sonucBaslik") : t(`baslik.${islem}`, { n: hikayeler.length })}>
      <div className="space-y-4">
        {!sonuc && <p className="text-sm text-gray-700 dark:text-gray-300">{t(`aciklama.${islem}`)}</p>}

        {yukleniyor && (
          <p role="status" className="text-sm text-gray-500 dark:text-gray-400">{t("denetleniyor")}</p>
        )}
        <div aria-live="polite">
          <ErrorNote message={hataMesaji} />
        </div>

        {gosterilen && (
          <>
            <p className="text-sm font-medium text-gray-800 dark:text-white/90" role="status">
              {sonuc
                ? t("sonucOzet", { basarili: sonuc.basarili, atlanan: sonuc.atlanan })
                : t("onizlemeOzet", { basarili: gosterilen.basarili, atlanan: gosterilen.atlanan })}
            </p>
            <ul className="max-h-72 space-y-2 overflow-y-auto pe-1">
              {gosterilen.sonuclar.map((r) => (
                <SonucSatiri key={r.hikaye_id} r={r} baslik={baslikHaritasi.get(r.hikaye_id) ?? r.slug ?? r.hikaye_id} kesin={sonuc !== null} />
              ))}
            </ul>
          </>
        )}

        {!sonuc && onizleme && (
          <p className="text-theme-sm font-medium text-error-700 dark:text-error-400">{t(`geriAlinamaz.${islem}`)}</p>
        )}

        <div className="flex flex-wrap justify-end gap-3">
          <button type="button" className={outlineBtn} disabled={islemde} onClick={kapat}>
            {sonuc ? t("kapat") : t("vazgec")}
          </button>
          {!sonuc && (
            <button
              type="button"
              className={islem === "sil" ? dangerBtn : primaryBtn}
              disabled={islemde || yukleniyor || yapilacak === 0}
              onClick={() => void onayla()}
            >
              {islemde ? t("calisiyor") : t(`onayla.${islem}`, { n: yapilacak })}
            </button>
          )}
        </div>
        {!sonuc && onizleme && yapilacak === 0 && (
          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("hicbiriUygunDegil")}</p>
        )}
      </div>
    </ModalShell>
  );
}

function SonucSatiri({ r, baslik, kesin }: { r: TopluSonucSatiri; baslik: string; kesin: boolean }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.toplu");
  const hata = useHataMetni();
  const tamam = r.sonuc === "basarili";
  return (
    <li className="flex items-start gap-3 rounded-lg border border-gray-200 p-3 dark:border-gray-800">
      <span
        aria-hidden="true"
        className={`mt-0.5 inline-flex size-5 shrink-0 items-center justify-center rounded-full text-xs font-bold ${
          tamam ? "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-400" : "bg-warning-50 text-warning-700 dark:bg-warning-500/15 dark:text-warning-400"
        }`}
      >
        {tamam ? "✓" : "!"}
      </span>
      <div className="min-w-0">
        <p className="text-sm font-medium wrap-break-word text-gray-800 dark:text-white/90">{baslik}</p>
        <p className="text-theme-xs wrap-break-word text-gray-600 dark:text-gray-300">
          <span className="font-semibold">{tamam ? (kesin ? t("yapildi") : t("yapilacak")) : t("atlandi")}</span>
          {tamam
            ? r.etkilenen_surum !== null
              ? ` · ${t("surumSayisi", { n: r.etkilenen_surum })}`
              : ""
            : ` · ${hata(r.neden ?? "")}`}
        </p>
      </div>
    </li>
  );
}
