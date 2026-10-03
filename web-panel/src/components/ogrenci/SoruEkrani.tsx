"use client";

import { createClient } from "@/utils/supabase/client";
import { useEffect, useRef, useState } from "react";

interface Soru {
  id: string;
  soru_metni: string;
  siklar: Record<string, string>;
  ders: string;
  konu: string;
  alt_konu: string | null;
  zorluk: 1 | 2 | 3;
}

interface CevapSonucu {
  dogru_mu: boolean;
  dogru_sik: string;
  cozum_adimlari: string[];
  kazanilan_xp: number;
  xp: number;
  level: number;
  streak_count: number;
}

const ZORLUK_ETIKET: Record<number, string> = { 1: "Kolay", 2: "Orta", 3: "Zor" };
const ZORLUK_RENK: Record<number, string> = {
  1: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400",
  2: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400",
  3: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400",
};

export default function SoruEkrani({ ders }: { ders: string }) {
  const [sorular, setSorular] = useState<Soru[]>([]);
  const [indeks, setIndeks] = useState(0);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);

  const [secilen, setSecilen] = useState<string | null>(null);
  const [sonuc, setSonuc] = useState<CevapSonucu | null>(null);
  const [gonderiliyor, setGonderiliyor] = useState(false);

  const [oturumDogru, setOturumDogru] = useState(0);
  const [oturumYanlis, setOturumYanlis] = useState(0);

  const baslangicRef = useRef<number>(Date.now());

  useEffect(() => {
    const yukle = async () => {
      setYukleniyor(true);
      setHata(null);
      const { data, error } = await createClient()
        .from("questions")
        .select("id, soru_metni, siklar, ders, konu, alt_konu, zorluk")
        .eq("onay_durumu", "onaylandi")
        .eq("ders", ders)
        .order("created_at")
        .limit(20);

      if (error) {
        setHata("Sorular yüklenemedi, lütfen tekrar dene.");
      } else {
        setSorular((data ?? []) as Soru[]);
      }
      setYukleniyor(false);
    };
    void yukle();
  }, [ders]);

  const mevcutSoru = sorular[indeks];

  const sikCevapla = async (sik: string) => {
    if (secilen || !mevcutSoru || gonderiliyor) return;
    setSecilen(sik);
    setGonderiliyor(true);
    const sureMsn = Date.now() - baslangicRef.current;

    const { data, error } = await createClient().rpc("submit_answer", {
      p_question_id: mevcutSoru.id,
      p_secilen_sik: sik,
      p_sure_ms: sureMsn,
    });

    setGonderiliyor(false);
    if (error) {
      setHata("Cevap kaydedilemedi: " + error.message);
      return;
    }
    const s = data as CevapSonucu;
    setSonuc(s);
    if (s.dogru_mu) setOturumDogru((n) => n + 1);
    else setOturumYanlis((n) => n + 1);
  };

  const sonrakiSoru = () => {
    setSecilen(null);
    setSonuc(null);
    setHata(null);
    baslangicRef.current = Date.now();
    setIndeks((i) => i + 1);
  };

  const yenidenBasla = () => {
    setIndeks(0);
    setSecilen(null);
    setSonuc(null);
    setHata(null);
    setOturumDogru(0);
    setOturumYanlis((0));
    baslangicRef.current = Date.now();
  };

  if (yukleniyor) {
    return (
      <div className="flex items-center justify-center py-24">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-brand-300 border-t-brand-600" />
      </div>
    );
  }

  if (hata) {
    return (
      <div className="rounded-2xl border border-red-200 bg-red-50 p-8 text-center dark:border-red-900 dark:bg-red-900/20">
        <p className="mb-4 text-sm text-red-600 dark:text-red-400">{hata}</p>
        <button
          type="button"
          onClick={() => window.location.reload()}
          className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
        >
          Tekrar Dene
        </button>
      </div>
    );
  }

  if (sorular.length === 0) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-12 text-center dark:border-gray-800 dark:bg-gray-900">
        <p className="text-gray-500 dark:text-gray-400">Bu ders için henüz soru yok.</p>
      </div>
    );
  }

  /* Tüm sorular bitti */
  if (indeks >= sorular.length) {
    return (
      <div className="rounded-2xl border border-gray-200 bg-white p-10 text-center dark:border-gray-800 dark:bg-gray-900">
        <div className="mb-6 text-5xl font-bold text-brand-600 dark:text-brand-400">
          Tebrikler!
        </div>
        <p className="mb-1 text-xl font-semibold text-gray-800 dark:text-white">
          {sorular.length} soruyu bitirdin
        </p>
        <p className="mb-6 text-gray-500 dark:text-gray-400">
          Doğru: {oturumDogru} &middot; Yanlış: {oturumYanlis}
        </p>
        <div className="mb-6 flex justify-center gap-4">
          <div className="rounded-xl bg-green-50 px-6 py-3 dark:bg-green-900/20">
            <p className="text-2xl font-bold text-green-600 dark:text-green-400">{oturumDogru}</p>
            <p className="text-xs text-green-700 dark:text-green-500">Doğru</p>
          </div>
          <div className="rounded-xl bg-red-50 px-6 py-3 dark:bg-red-900/20">
            <p className="text-2xl font-bold text-red-600 dark:text-red-400">{oturumYanlis}</p>
            <p className="text-xs text-red-700 dark:text-red-500">Yanlış</p>
          </div>
        </div>
        <button
          type="button"
          onClick={yenidenBasla}
          className="rounded-xl bg-brand-600 px-8 py-3 font-medium text-white hover:bg-brand-700"
        >
          Tekrar Çöz
        </button>
      </div>
    );
  }

  const soru = mevcutSoru;
  const sikAnahtarlari = Object.keys(soru.siklar).sort();

  const sikRenk = (sik: string) => {
    if (!sonuc) {
      if (sik === secilen) return "border-brand-400 bg-brand-50 dark:border-brand-600 dark:bg-brand-900/30";
      return "border-gray-200 bg-white hover:border-brand-300 hover:bg-brand-50/40 dark:border-gray-700 dark:bg-gray-900 dark:hover:border-brand-700";
    }
    if (sik === sonuc.dogru_sik) return "border-green-400 bg-green-50 dark:border-green-600 dark:bg-green-900/20";
    if (sik === secilen && !sonuc.dogru_mu) return "border-red-400 bg-red-50 dark:border-red-600 dark:bg-red-900/20";
    return "border-gray-200 bg-white opacity-60 dark:border-gray-700 dark:bg-gray-900";
  };

  return (
    <div className="space-y-5">
      {/* İlerleme + istatistik satırı */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-sm text-gray-500 dark:text-gray-400">
            {indeks + 1} / {sorular.length}
          </span>
          <div className="h-2 w-32 overflow-hidden rounded-full bg-gray-200 dark:bg-gray-700">
            <div
              className="h-full rounded-full bg-brand-500 transition-all"
              style={{ width: `${((indeks + 1) / sorular.length) * 100}%` }}
            />
          </div>
        </div>
        <div className="flex items-center gap-3 text-sm">
          <span className="text-green-600 dark:text-green-400">{oturumDogru} D</span>
          <span className="text-red-500 dark:text-red-400">{oturumYanlis} Y</span>
        </div>
      </div>

      {/* Soru kartı */}
      <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-800 dark:bg-gray-900 sm:p-8">
        <div className="mb-4 flex flex-wrap items-center gap-2">
          <span className="text-xs font-medium text-gray-500 dark:text-gray-400">{soru.konu}</span>
          {soru.alt_konu && (
            <>
              <span className="text-gray-300 dark:text-gray-600">/</span>
              <span className="text-xs text-gray-400 dark:text-gray-500">{soru.alt_konu}</span>
            </>
          )}
          <span className={`ms-auto rounded-full px-2.5 py-0.5 text-xs font-medium ${ZORLUK_RENK[soru.zorluk]}`}>
            {ZORLUK_ETIKET[soru.zorluk]}
          </span>
        </div>

        <p className="mb-6 text-base leading-relaxed text-gray-800 dark:text-white sm:text-lg">
          {soru.soru_metni}
        </p>

        <div className="space-y-3">
          {sikAnahtarlari.map((sik) => (
            <button
              key={sik}
              type="button"
              disabled={!!secilen}
              onClick={() => sikCevapla(sik)}
              className={`flex w-full items-start gap-3 rounded-xl border-2 px-4 py-3 text-start transition-all ${sikRenk(sik)}`}
            >
              <span className="mt-0.5 flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full bg-gray-100 text-xs font-bold text-gray-600 dark:bg-gray-700 dark:text-gray-300">
                {sik}
              </span>
              <span className="text-sm text-gray-800 dark:text-gray-200">
                {soru.siklar[sik]}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Sonuç paneli */}
      {sonuc && (
        <div
          className={`rounded-2xl border p-5 ${
            sonuc.dogru_mu
              ? "border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-900/20"
              : "border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20"
          }`}
        >
          <div className="mb-3 flex items-center gap-3">
            <span
              className={`text-xl font-bold ${
                sonuc.dogru_mu ? "text-green-600 dark:text-green-400" : "text-red-600 dark:text-red-400"
              }`}
            >
              {sonuc.dogru_mu ? "Doğru!" : "Yanlış"}
            </span>
            {sonuc.kazanilan_xp > 0 && (
              <span className="rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-bold text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400">
                +{sonuc.kazanilan_xp} XP
              </span>
            )}
          </div>

          {sonuc.cozum_adimlari && sonuc.cozum_adimlari.length > 0 && (
            <div className="mb-4">
              <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400">
                Çözüm
              </p>
              <ol className="space-y-1.5">
                {sonuc.cozum_adimlari.map((adim, i) => (
                  <li key={i} className="flex gap-2 text-sm text-gray-700 dark:text-gray-300">
                    <span className="flex h-5 w-5 flex-shrink-0 items-center justify-center rounded-full bg-white text-xs font-bold text-gray-500 dark:bg-gray-800">
                      {i + 1}
                    </span>
                    {adim}
                  </li>
                ))}
              </ol>
            </div>
          )}

          <button
            type="button"
            onClick={sonrakiSoru}
            className="mt-2 rounded-xl bg-brand-600 px-6 py-2.5 font-medium text-white hover:bg-brand-700"
          >
            Sonraki Soru →
          </button>
        </div>
      )}
    </div>
  );
}
