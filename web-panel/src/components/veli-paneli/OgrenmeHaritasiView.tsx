"use client";

import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import ChildScope from "./ChildScope";
import type { Student, SubjectSuccess } from "./types";

// Kazanım durumu (public.veli_kazanim_haritasi, durum alanı).
type Durum = "veri_yok" | "gelisiyor" | "pekisiyor" | "guclu";

interface Kazanim {
  kod: string;
  metin: string;
  unite_tema: string | null;
  ilk_hafta: number;
  bu_hafta_mi: boolean;
  islendi_mi: boolean;
  soru_sayisi: number;
  cevap: number;
  farkli_gun: number;
  kalici_dogru: number;
  /** Yüzde 0-100; 1–4. sınıfta ve yetersiz veride null. */
  oran: number | null;
  durum: Durum;
}

interface Harita {
  riza: string;
  sinif: number | null;
  ders?: string;
  bugun_hafta: number | null;
  plan_var?: boolean;
  kazanimlar: Kazanim[];
}

const DURUM_ANAHTAR: Record<Durum, "veriYok" | "gelisiyor" | "pekisiyor" | "guclu"> = {
  veri_yok: "veriYok",
  gelisiyor: "gelisiyor",
  pekisiyor: "pekisiyor",
  guclu: "guclu",
};

// Rozet renkleri yalnız destek; durum her zaman metinle de okunur.
const DURUM_RENK: Record<Durum, string> = {
  veri_yok: "bg-gray-100 text-gray-700 dark:bg-white/10 dark:text-gray-300",
  gelisiyor: "bg-warning-50 text-warning-700 dark:bg-warning-500/15 dark:text-warning-400",
  pekisiyor: "bg-brand-50 text-brand-700 dark:bg-brand-500/15 dark:text-brand-400",
  guclu: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-400",
};

type Filtre = "tum" | "destek";

interface OgrenmeHaritasiViewProps {
  students: Student[];
}

export default function OgrenmeHaritasiView({ students }: OgrenmeHaritasiViewProps) {
  return (
    <ChildScope
      students={students}
      render={(studentId, data) => (
        <HaritaContent
          key={studentId}
          studentId={studentId}
          subjects={data.ders_basari}
        />
      )}
    />
  );
}

function HaritaContent({
  studentId,
  subjects,
}: {
  studentId: string;
  subjects: SubjectSuccess[];
}) {
  const t = useTranslations("veliPaneli");
  const th = useTranslations("veliPaneli.ogrenmeHaritasi");

  // Ders listesi, çocuğun çözdüğü sorulardan gelir (ders_basari). Hiç soru çözmediği dersler listelenmez.
  const ordered = useMemo(
    () => [...subjects].sort((a, b) => a.ders.localeCompare(b.ders, "tr")),
    [subjects],
  );
  const [picked, setPicked] = useState<string | null>(null);
  const [harita, setHarita] = useState<Harita | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);
  const [filtre, setFiltre] = useState<Filtre>("tum");

  const selected = ordered.find((s) => s.ders === picked) ?? ordered[0];
  const selectedDers = selected?.ders ?? null;

  useEffect(() => {
    if (!selectedDers) return;
    let cancelled = false;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setLoading(true);
    setError(false);
    setHarita(null);

    createClient()
      .rpc("veli_kazanim_haritasi", {
        p_cocuk_id: studentId,
        p_ders: selectedDers,
      })
      .then(({ data, error: rpcError }) => {
        if (cancelled) return;
        if (rpcError) {
          setError(true);
        } else {
          setHarita((data as Harita | null) ?? null);
        }
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [studentId, selectedDers]);

  if (ordered.length === 0) {
    return (
      <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
        {th("empty")}
      </p>
    );
  }

  return (
    <div className="space-y-4 md:space-y-6">
      <div>
        <p className="mb-2 text-sm font-medium text-gray-700 dark:text-gray-400">
          {th("pick")}
        </p>
        <div className="flex flex-wrap gap-2">
          {ordered.map((s) => {
            const active = s.ders === selected.ders;
            return (
              <button
                key={s.ders}
                type="button"
                aria-pressed={active}
                onClick={() => {
                  setPicked(s.ders);
                  setFiltre("tum");
                }}
                className={`inline-flex min-h-11 items-center rounded-full border px-4 py-1.5 text-sm font-medium transition-colors ${
                  active
                    ? "border-brand-500 bg-brand-50 text-brand-600 dark:border-brand-400 dark:bg-brand-500/15 dark:text-brand-400"
                    : "border-gray-200 text-gray-600 hover:bg-gray-50 dark:border-gray-800 dark:text-gray-300 dark:hover:bg-white/5"
                }`}
              >
                {s.ders}
              </button>
            );
          })}
        </div>
      </div>

      {loading && (
        <p role="status" className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("loading")}
        </p>
      )}

      {!loading && error && (
        <p role="alert" className="py-10 text-center text-sm text-error-500">
          {t("error")}
        </p>
      )}

      {!loading && !error && harita && (
        <HaritaBody harita={harita} ders={selected.ders} filtre={filtre} onFiltre={setFiltre} />
      )}

      <p className="text-theme-xs text-gray-500 dark:text-gray-400">{th("kaynak")}</p>
    </div>
  );
}

function HaritaBody({
  harita,
  ders,
  filtre,
  onFiltre,
}: {
  harita: Harita;
  ders: string;
  filtre: Filtre;
  onFiltre: (f: Filtre) => void;
}) {
  const t = useTranslations("veliPaneli");
  const th = useTranslations("veliPaneli.ogrenmeHaritasi");

  if (harita.riza !== "verildi") {
    return (
      <p className="rounded-2xl border border-warning-200 bg-warning-50 px-5 py-4 text-sm text-warning-700 dark:border-warning-500/30 dark:bg-warning-500/10 dark:text-warning-400">
        {t("consent.gate")}
      </p>
    );
  }

  if (harita.sinif === null || harita.sinif === undefined) {
    return <VeliBilgi metin={th("sinifYok")} />;
  }

  if (harita.plan_var === false) {
    return <VeliBilgi metin={th("planYok")} />;
  }

  const kazanimlar = harita.kazanimlar ?? [];
  if (kazanimlar.length === 0) {
    return <VeliBilgi metin={th("kazanimYok")} />;
  }

  const sinifKucuk = harita.sinif <= 4;
  const buHaftaSayi = kazanimlar.filter((k) => k.bu_hafta_mi).length;
  const destekSayi = kazanimlar.filter((k) => k.durum === "gelisiyor").length;
  const gosterilen =
    filtre === "destek" ? kazanimlar.filter((k) => k.durum === "gelisiyor") : kazanimlar;

  // Ünite başlığına göre gruplama; sıra RPC'deki ilk_hafta sırasını korur.
  const gruplar = new Map<string, Kazanim[]>();
  for (const k of gosterilen) {
    const anahtar = k.unite_tema?.trim() || th("uniteYok");
    const liste = gruplar.get(anahtar) ?? [];
    liste.push(k);
    gruplar.set(anahtar, liste);
  }

  return (
    <div className="space-y-4 md:space-y-6">
      <div
        className={`rounded-2xl border p-5 sm:p-6 ${
          buHaftaSayi > 0
            ? "border-brand-500 bg-brand-50/60 dark:border-brand-400 dark:bg-brand-500/10"
            : "border-gray-200 bg-white dark:border-gray-800 dark:bg-white/3"
        }`}
      >
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{ders}</h3>
        <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">
          {th("sinifBilgi", { sinif: harita.sinif })}
        </p>
        <p className="mt-3 text-sm text-gray-700 dark:text-gray-300">
          {harita.bugun_hafta === null || harita.bugun_hafta === undefined
            ? th("bugunYok")
            : th("bugunHafta", { hafta: harita.bugun_hafta })}
        </p>
        {buHaftaSayi > 0 && (
          <p className="mt-1 text-sm font-medium text-brand-700 dark:text-brand-400">
            {th("bugunSayi", { sayi: buHaftaSayi })}
          </p>
        )}
        {sinifKucuk && (
          <p className="mt-3 text-theme-xs italic text-gray-500 dark:text-gray-400">
            {th("sinifNot")}
          </p>
        )}
      </div>

      <div role="group" aria-label={th("filtreBaslik")} className="flex flex-wrap gap-2">
        <FiltreButonu
          aktif={filtre === "tum"}
          onClick={() => onFiltre("tum")}
          label={th("filtreTum", { sayi: kazanimlar.length })}
        />
        <FiltreButonu
          aktif={filtre === "destek"}
          onClick={() => onFiltre("destek")}
          label={th("filtreDestek", { sayi: destekSayi })}
        />
      </div>

      {gosterilen.length === 0 && (
        <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">
          {th("filtreBos")}
        </p>
      )}

      {Array.from(gruplar.entries()).map(([unite, liste]) => (
        <section key={unite} aria-label={unite}>
          <h4 className="mb-3 text-sm font-semibold text-gray-700 dark:text-gray-300">
            {unite}
          </h4>
          <ul className="space-y-2">
            {liste.map((k) => (
              <KazanimKarti key={k.kod} kazanim={k} sinifKucuk={sinifKucuk} />
            ))}
          </ul>
        </section>
      ))}
    </div>
  );
}

function KazanimKarti({ kazanim: k, sinifKucuk }: { kazanim: Kazanim; sinifKucuk: boolean }) {
  const th = useTranslations("veliPaneli.ogrenmeHaritasi");
  const durumAnahtar = DURUM_ANAHTAR[k.durum] ?? "veriYok";

  return (
    <li className="rounded-xl border border-gray-100 bg-white p-4 dark:border-gray-800 dark:bg-white/3">
      <div className="flex flex-wrap items-center gap-2">
        <span className="text-theme-xs font-medium text-gray-500 dark:text-gray-400">
          {th("haftaLabel", { hafta: k.ilk_hafta })}
        </span>
        {k.bu_hafta_mi && (
          <span className="rounded-full bg-brand-500 px-2 py-0.5 text-theme-xs font-medium text-white">
            {th("buHaftaEtiket")}
          </span>
        )}
        <span
          className={`ms-auto inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-theme-xs font-semibold ${DURUM_RENK[k.durum] ?? DURUM_RENK.veri_yok}`}
        >
          <span aria-hidden className="size-1.5 rounded-full bg-current" />
          {th(`durum.${durumAnahtar}`)}
        </span>
      </div>

      <p className="mt-2 text-sm font-medium text-gray-800 dark:text-white/90">{k.metin}</p>
      <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">
        <span className="font-mono">{k.kod}</span>
        {" · "}
        {th(`durumAciklama.${durumAnahtar}`)}
      </p>

      <ul className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-theme-xs text-gray-500 dark:text-gray-400">
        <li>{th("soruSayisi", { sayi: k.soru_sayisi })}</li>
        {k.cevap > 0 && (
          <li>{th("cevap", { cevap: k.cevap, gun: k.farkli_gun })}</li>
        )}
        {k.oran !== null && !sinifKucuk && (
          <li>{th("oran", { oran: k.oran })}</li>
        )}
        {k.kalici_dogru > 0 && (
          <li>{th("kalici", { sayi: k.kalici_dogru })}</li>
        )}
      </ul>
    </li>
  );
}

function FiltreButonu({
  aktif,
  onClick,
  label,
}: {
  aktif: boolean;
  onClick: () => void;
  label: string;
}) {
  return (
    <button
      type="button"
      aria-pressed={aktif}
      onClick={onClick}
      className={`inline-flex min-h-11 items-center rounded-full border px-4 py-1.5 text-sm font-medium transition-colors ${
        aktif
          ? "border-brand-500 bg-brand-50 text-brand-600 dark:border-brand-400 dark:bg-brand-500/15 dark:text-brand-400"
          : "border-gray-200 text-gray-600 hover:bg-gray-50 dark:border-gray-800 dark:text-gray-300 dark:hover:bg-white/5"
      }`}
    >
      {label}
    </button>
  );
}

function VeliBilgi({ metin }: { metin: string }) {
  return (
    <p className="rounded-2xl border border-gray-200 bg-white px-5 py-8 text-center text-sm text-gray-500 dark:border-gray-800 dark:bg-white/3 dark:text-gray-400">
      {metin}
    </p>
  );
}
