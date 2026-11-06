"use client";

import { createClient } from "@/utils/supabase/client";
import { useLocale, useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import {
  KART_LIMITI,
  destekOnerisiOlustur,
  kazanimOnerisiKodu,
  tekrarOnerisiKodu,
  type DestekOnerisi,
  type Dil,
  type OneriTuru,
} from "@/lib/veli-paneli/destek-onerileri";

import ChildScope from "./ChildScope";
import type { ReviewTopic, Student, SubjectSuccess } from "./types";

// En fazla bu kadar ders için kazanım haritası çağrılır (en düşük doğru oranlı dersler önce).
const MAX_DERS = 3;

// Öğrenme Haritası RPC'sinin (veli_kazanim_haritasi) kullandığımız alanları.
type Durum = "veri_yok" | "gelisiyor" | "pekisiyor" | "guclu";

interface Kazanim {
  kod: string;
  metin: string;
  ilk_hafta: number;
  bu_hafta_mi: boolean;
  islendi_mi: boolean;
  durum: Durum;
}

interface Harita {
  riza: string;
  sinif: number | null;
  plan_var?: boolean;
  kazanimlar: Kazanim[];
}

// veli_destek_isaretleri_listele dönüşü.
interface Isaret {
  hafta: string;
  yapilanlar: string[];
  son_4_hafta: number;
}

interface Yuklu {
  rizaVar: boolean;
  kartlar: DestekOnerisi[];
  isaret: Isaret;
}

interface Sonuc {
  anahtar: string;
  /** null = yükleme hatası. */
  veri: Yuklu | null;
}

interface DestekPlaniViewProps {
  students: Student[];
}

export default function DestekPlaniView({ students }: DestekPlaniViewProps) {
  return (
    <ChildScope
      students={students}
      render={(studentId, data) => (
        <DestekContent
          key={studentId}
          studentId={studentId}
          subjects={data.ders_basari ?? []}
          tekrarlar={data.tekrar_konulari ?? []}
        />
      )}
    />
  );
}

// Dersleri en düşük doğru oranlıdan başlayarak seçer; en fazla MAX_DERS.
function dersleriSec(subjects: SubjectSuccess[]): string[] {
  return [...subjects]
    .sort((a, b) => a.oran - b.oran || a.ders.localeCompare(b.ders, "tr"))
    .slice(0, MAX_DERS)
    .map((s) => s.ders);
}

// Öncelik: 1) işlenmiş ama gelişiyor kazanım, 2) bu hafta işlenen ve pekişiyor kazanım, 3) tekrar konusu.
function kartlariSec(
  haritalar: { ders: string; harita: Harita }[],
  tekrarlar: ReviewTopic[],
  dil: Dil,
): DestekOnerisi[] {
  const adaylar: { oncelik: number; oneri: DestekOnerisi }[] = [];

  for (const { ders, harita } of haritalar) {
    for (const k of harita.kazanimlar ?? []) {
      let tur: OneriTuru | null = null;
      let oncelik = 0;
      if (k.islendi_mi && k.durum === "gelisiyor") {
        tur = "kazanim_gelisiyor";
        oncelik = 1;
      } else if (k.bu_hafta_mi && k.durum === "pekisiyor") {
        tur = "kazanim_bu_hafta";
        oncelik = 2;
      }
      if (!tur) continue;
      const kod = kazanimOnerisiKodu(k.kod);
      if (!kod) continue;
      adaylar.push({
        oncelik,
        oneri: destekOnerisiOlustur(tur, dil, {
          kod,
          ders,
          kazanimKodu: k.kod,
          kazanimMetni: k.metin,
        }),
      });
    }
  }

  for (const t of tekrarlar) {
    const kod = tekrarOnerisiKodu(t.ders, t.konu);
    if (!kod) continue;
    adaylar.push({
      oncelik: 3,
      oneri: destekOnerisiOlustur("tekrar_konu", dil, { kod, ders: t.ders, konu: t.konu }),
    });
  }

  adaylar.sort((a, b) => a.oncelik - b.oncelik);

  const gorulen = new Set<string>();
  const sonuc: DestekOnerisi[] = [];
  for (const { oneri } of adaylar) {
    if (gorulen.has(oneri.kod)) continue;
    gorulen.add(oneri.kod);
    sonuc.push(oneri);
    if (sonuc.length === KART_LIMITI) break;
  }
  return sonuc;
}

// Tüm kazanım çağrıları başarısızsa veya işaret listesi okunamazsa hata sayılır.
async function yukle(
  cocukId: string,
  dil: Dil,
  dersler: string[],
  tekrarlar: ReviewTopic[],
): Promise<Yuklu> {
  const supabase = createClient();

  const haritaIstekleri = dersler.map((ders) =>
    supabase
      .rpc("veli_kazanim_haritasi", { p_cocuk_id: cocukId, p_ders: ders })
      .then(({ data, error }) => ({ ders, error, harita: (data as Harita | null) ?? null })),
  );

  const [isaretSonuc, haritaSonuclari] = await Promise.all([
    supabase.rpc("veli_destek_isaretleri_listele", { p_cocuk_id: cocukId }),
    Promise.all(haritaIstekleri),
  ]);

  if (isaretSonuc.error || !isaretSonuc.data) throw new Error("isaret");

  const haritalar = haritaSonuclari
    .filter((r): r is { ders: string; error: null; harita: Harita } => !r.error && r.harita !== null)
    .map((r) => ({ ders: r.ders, harita: r.harita }));

  if (dersler.length > 0 && haritalar.length === 0) throw new Error("harita");

  return {
    rizaVar: haritalar.every((h) => h.harita.riza === "verildi"),
    kartlar: kartlariSec(haritalar, tekrarlar, dil),
    isaret: isaretSonuc.data as Isaret,
  };
}

function DestekContent({
  studentId,
  subjects,
  tekrarlar,
}: {
  studentId: string;
  subjects: SubjectSuccess[];
  tekrarlar: ReviewTopic[];
}) {
  const t = useTranslations("veliPaneli");
  const th = useTranslations("veliPaneli.destekPlani");
  const locale = useLocale();
  const dil: Dil = locale === "en" ? "en" : "tr";

  const dersler = useMemo(() => dersleriSec(subjects), [subjects]);
  const anahtar = JSON.stringify([
    studentId,
    dil,
    dersler,
    tekrarlar.map((k) => [k.ders, k.konu]),
  ]);

  const [sonuc, setSonuc] = useState<Sonuc | null>(null);
  const [bekleyen, setBekleyen] = useState<string | null>(null);
  const [isaretHata, setIsaretHata] = useState(false);
  const [yenilemeHata, setYenilemeHata] = useState(false);

  useEffect(() => {
    let iptal = false;
    yukle(studentId, dil, dersler, tekrarlar)
      .then((veri) => {
        if (!iptal) setSonuc({ anahtar, veri });
      })
      .catch(() => {
        if (!iptal) setSonuc({ anahtar, veri: null });
      });
    return () => {
      iptal = true;
    };
  }, [anahtar, studentId, dil, dersler, tekrarlar]);

  async function isaretDegistir(kod: string, yapildi: boolean) {
    if (bekleyen) return;
    setBekleyen(kod);
    setIsaretHata(false);
    setYenilemeHata(false);

    const supabase = createClient();
    const { error } = await supabase.rpc("veli_destek_isaret_degistir", {
      p_cocuk_id: studentId,
      p_oneri_kod: kod,
      p_yapildi: yapildi,
    });

    if (error) {
      setIsaretHata(true);
      setBekleyen(null);
      return;
    }

    // Sunucudaki güncel haftalık işaretleri ve son 4 hafta sayısını yeniden oku.
    const { data, error: listeHata } = await supabase.rpc("veli_destek_isaretleri_listele", {
      p_cocuk_id: studentId,
    });
    if (listeHata) setYenilemeHata(true);
    else if (data) {
      setSonuc((prev) =>
        prev && prev.anahtar === anahtar && prev.veri
          ? { ...prev, veri: { ...prev.veri, isaret: data as Isaret } }
          : prev,
      );
    }
    setBekleyen(null);
  }

  if (!sonuc || sonuc.anahtar !== anahtar) {
    return (
      <p role="status" className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
        {t("loading")}
      </p>
    );
  }

  if (!sonuc.veri) {
    return (
      <p role="alert" className="py-10 text-center text-sm text-error-500">
        {t("error")}
      </p>
    );
  }

  const { veri } = sonuc;

  if (!veri.rizaVar) {
    return (
      <p className="rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 text-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-warning-400">
        {t("consent.gate")}
      </p>
    );
  }

  const son4 = veri.isaret.son_4_hafta;

  return (
    <div className="space-y-4 md:space-y-6">
      <p className="text-sm text-gray-600 dark:text-gray-400">{th("desc")}</p>

      {son4 > 0 && (
        <p className="rounded-2xl border border-brand-200 bg-brand-50/60 px-5 py-4 text-sm font-medium text-brand-700 dark:border-brand-500/30 dark:bg-brand-500/10 dark:text-brand-400">
          {th("sonDortHafta", { sayi: son4 })}
        </p>
      )}

      {isaretHata && (
        <p role="alert" className="text-sm text-error-500">
          {th("isaretHata")}
        </p>
      )}
      {yenilemeHata && (
        <p role="alert" className="text-sm text-error-500">
          {th("isaretYenilenemedi")}
        </p>
      )}

      {veri.kartlar.length === 0 ? (
        <p className="rounded-2xl border border-gray-200 bg-white px-5 py-8 text-center text-sm text-gray-500 dark:border-gray-800 dark:bg-white/3 dark:text-gray-400">
          {th("empty")}
        </p>
      ) : (
        <ul className="space-y-4">
          {veri.kartlar.map((oneri) => (
            <DestekKarti
              key={oneri.kod}
              oneri={oneri}
              yapildi={veri.isaret.yapilanlar.includes(oneri.kod)}
              bekleyen={bekleyen === oneri.kod}
              pasif={bekleyen !== null}
              onToggle={(yapildiYeni) => isaretDegistir(oneri.kod, yapildiYeni)}
            />
          ))}
        </ul>
      )}

      <p className="text-theme-xs text-gray-500 dark:text-gray-400">{th("kaynak")}</p>
    </div>
  );
}

function DestekKarti({
  oneri,
  yapildi,
  bekleyen,
  pasif,
  onToggle,
}: {
  oneri: DestekOnerisi;
  yapildi: boolean;
  bekleyen: boolean;
  pasif: boolean;
  onToggle: (yapildi: boolean) => void;
}) {
  const th = useTranslations("veliPaneli.destekPlani");

  const turEtiket: Record<OneriTuru, string> = {
    kazanim_gelisiyor: th("kart.gelisiyor"),
    kazanim_bu_hafta: th("kart.buHafta"),
    tekrar_konu: th("kart.tekrar"),
  };

  return (
    <li className="rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <div className="flex flex-wrap items-center gap-2">
        <span className="rounded-full bg-gray-100 px-2.5 py-0.5 text-theme-xs font-semibold text-gray-700 dark:bg-white/10 dark:text-gray-300">
          {turEtiket[oneri.tur]}
        </span>
        <span className="text-theme-xs text-gray-500 dark:text-gray-400">{oneri.ders}</span>
      </div>

      <h3 className="mt-3 text-base font-semibold text-gray-800 dark:text-white/90">
        {oneri.baslik}
      </h3>

      {oneri.kazanimKodu && oneri.kazanimMetni && (
        <p className="mt-2 text-sm text-gray-700 dark:text-gray-300">
          <span className="font-mono text-theme-xs text-gray-500 dark:text-gray-400">
            {oneri.kazanimKodu}
          </span>
          <span className="block">{oneri.kazanimMetni}</span>
        </p>
      )}

      <p className="mt-3 text-theme-xs font-medium text-brand-700 dark:text-brand-400">
        {th("kart.sure")}
      </p>
      <h4 className="mt-1 text-sm font-semibold text-gray-700 dark:text-gray-300">
        {th("kart.adimlar")}
      </h4>
      <ol className="mt-2 list-decimal space-y-1.5 ps-5 text-sm text-gray-700 dark:text-gray-300">
        {oneri.adimlar.map((adim) => (
          <li key={adim}>{adim}</li>
        ))}
      </ol>

      <div className="mt-4 rounded-xl bg-gray-50 p-4 dark:bg-white/5">
        <p className="text-theme-xs font-semibold text-gray-600 dark:text-gray-400">
          {th("kart.konusma")}
        </p>
        <p className="mt-1 text-sm text-gray-800 dark:text-white/90">{oneri.konusmaSorusu}</p>
      </div>

      <p className="mt-3 text-theme-xs text-gray-500 dark:text-gray-400">
        <span className="font-semibold">{th("kart.birak")}: </span>
        {oneri.birakma}
      </p>

      <div className="mt-4">
        <button
          type="button"
          aria-pressed={yapildi}
          disabled={pasif}
          onClick={() => onToggle(!yapildi)}
          className={`inline-flex min-h-11 items-center rounded-full border px-4 py-2 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:opacity-60 ${
            yapildi
              ? "border-success-500 bg-success-50 text-success-700 dark:border-success-500/40 dark:bg-success-500/15 dark:text-success-400"
              : "border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
          }`}
        >
          {bekleyen ? th("kart.kaydediliyor") : yapildi ? th("kart.yapildi") : th("kart.yaptik")}
        </button>
      </div>
    </li>
  );
}
