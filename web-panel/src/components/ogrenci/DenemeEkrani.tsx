"use client";

import { createClient } from "@/utils/supabase/client";
import Image from "next/image";
import { useCallback, useEffect, useReducer, useRef, useState } from "react";

// ─── Tipler ────────────────────────────────────────────────────────────────────

interface Sik {
  harf: string;
  metin: string;
}

interface SinavSoru {
  sira: number;
  id: string;
  ders: string;
  konu: string;
  zorluk: number;
  soru_metni: string;
  siklar: Sik[];
}

interface SinavBaslat {
  deneme_id: string;
  bitis_zamani: string;
  sure_dakika: number;
  sorular: SinavSoru[];
}

interface SinavSonuc {
  dogru_sayisi: number;
  yanlis_sayisi: number;
  bos_sayisi: number;
  puan: number;
}

// ─── State makinesi ────────────────────────────────────────────────────────────

type Phase = "loading" | "exam" | "submitting" | "done" | "error";

interface ExamState {
  phase: Phase;
  veri: SinavBaslat | null;
  sonuc: SinavSonuc | null;
  secimler: Record<string, string>; // question_id → seçilen harf
  flagged: Set<string>;
  index: number;
  errorMsg: string | null;
}

type ExamAction =
  | { type: "started"; veri: SinavBaslat }
  | { type: "select"; questionId: string; harf: string }
  | { type: "navigate"; index: number }
  | { type: "flag"; questionId: string }
  | { type: "submitting" }
  | { type: "done"; sonuc: SinavSonuc }
  | { type: "error"; msg: string };

const INIT: ExamState = {
  phase: "loading",
  veri: null,
  sonuc: null,
  secimler: {},
  flagged: new Set(),
  index: 0,
  errorMsg: null,
};

function reducer(state: ExamState, action: ExamAction): ExamState {
  switch (action.type) {
    case "started":
      return { ...state, phase: "exam", veri: action.veri };
    case "select":
      return {
        ...state,
        secimler: { ...state.secimler, [action.questionId]: action.harf },
      };
    case "navigate":
      return { ...state, index: action.index };
    case "flag": {
      const next = new Set(state.flagged);
      if (next.has(action.questionId)) next.delete(action.questionId);
      else next.add(action.questionId);
      return { ...state, flagged: next };
    }
    case "submitting":
      return { ...state, phase: "submitting" };
    case "done":
      return { ...state, phase: "done", sonuc: action.sonuc };
    case "error":
      return { ...state, phase: "error", errorMsg: action.msg };
  }
}

// ─── Sayaç ──────────────────────────────────────────────────────────────────────

function useCountdown(bitisTarihi: string | null, onExpire: () => void) {
  const [kalan, setKalan] = useState<number | null>(null);
  const fired = useRef(false);

  useEffect(() => {
    if (!bitisTarihi) return;
    const bitis = new Date(bitisTarihi).getTime();

    function tick() {
      const diff = Math.max(0, Math.floor((bitis - Date.now()) / 1000));
      setKalan(diff);
      if (diff === 0 && !fired.current) {
        fired.current = true;
        onExpire();
      }
    }

    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, [bitisTarihi, onExpire]);

  return kalan;
}

function formatSure(saniye: number) {
  const dk = Math.floor(saniye / 60);
  const sn = saniye % 60;
  return `${String(dk).padStart(2, "0")}:${String(sn).padStart(2, "0")}`;
}

// ─── Ana bileşen ───────────────────────────────────────────────────────────────

interface Props {
  examId: string;
}

export default function DenemeEkrani({ examId }: Props) {
  const [state, dispatch] = useReducer(reducer, INIT);
  const submitRef = useRef(false);

  const submit = useCallback(
    async (secimler: Record<string, string>) => {
      if (submitRef.current || !state.veri) return;
      submitRef.current = true;
      dispatch({ type: "submitting" });
      const sb = createClient();

      // finish_mock_exam_attempt zaten DB'deki kayıtlı cevaplara bakıyor;
      // anlık gönderimde kaçırılanlar için burada toplu fallback yok —
      // cevaplar zaten "select" anında submit edilmiş olmalı (bkz. handleSelect).
      const { data, error } = await sb.rpc("finish_mock_exam_attempt", {
        p_deneme_id: state.veri.deneme_id,
      });

      if (error || !data) {
        dispatch({ type: "error", msg: "Sınav tamamlanamadı. Lütfen tekrar dene." });
        return;
      }
      dispatch({ type: "done", sonuc: data as SinavSonuc });
    },
    [state.veri]
  );

  const handleExpire = useCallback(() => {
    if (state.phase === "exam") submit(state.secimler);
  }, [state.phase, state.secimler, submit]);

  const kalan = useCountdown(
    state.veri?.bitis_zamani ?? null,
    handleExpire
  );

  // Şık seçiminde anlık sunucuya gönder (bağlantı kopukluğu koruması)
  const handleSelect = useCallback(
    async (questionId: string, harf: string, denemeId: string) => {
      dispatch({ type: "select", questionId, harf });
      await createClient().rpc("submit_mock_exam_answer", {
        p_deneme_id: denemeId,
        p_question_id: questionId,
        p_secilen_sik: harf,
      });
    },
    []
  );

  // Sınavı başlat
  useEffect(() => {
    let cancelled = false;
    createClient()
      .rpc("start_mock_exam_attempt", { p_exam_id: examId })
      .then(({ data, error }) => {
        if (cancelled) return;
        if (error || !data) {
          dispatch({
            type: "error",
            msg: error?.message ?? "Sınav başlatılamadı.",
          });
          return;
        }
        dispatch({ type: "started", veri: data as SinavBaslat });
      });
    return () => { cancelled = true; };
  }, [examId]);

  // ─── Yükleniyor ──────────────────────────────────────────────────────────────
  if (state.phase === "loading") {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <p className="text-sm text-gray-400">Sınav yükleniyor...</p>
      </div>
    );
  }

  // ─── Hata ────────────────────────────────────────────────────────────────────
  if (state.phase === "error") {
    return (
      <div className="mx-auto mt-12 max-w-md rounded-2xl border border-red-200 bg-red-50 p-8 text-center dark:border-red-900/30 dark:bg-red-900/10">
        <p className="text-base font-semibold text-red-700 dark:text-red-400">
          {state.errorMsg}
        </p>
        <p className="mt-2 text-sm text-gray-500">
          Bu sınava girmek için önce velinin veli panelinden seni kaydetmesi gerekiyor.
        </p>
      </div>
    );
  }

  // ─── Bitiş ───────────────────────────────────────────────────────────────────
  if (state.phase === "done" && state.sonuc) {
    const puan = state.sonuc.puan;
    const pose =
      puan >= 80 ? "tamamlandi" : puan >= 50 ? "dusunuyor" : "bir-daha-dene";
    const mesaj =
      puan >= 80
        ? "Harika gitti! Sonuçlarını veliye gönderdik."
        : puan >= 50
        ? "İyi bir denemeydi. Zayıf konular sana gösterilecek."
        : "Bu kez zordu. Tekrar et, bir sonrakinde daha iyi olacak.";

    return (
      <div className="mx-auto mt-8 max-w-md rounded-3xl border border-gray-200 bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-800">
        <Image
          src={`/images/poses/${pose}.webp`}
          alt={mesaj}
          width={160}
          height={160}
          className="mx-auto"
          priority
        />
        <h1 className="mt-4 text-2xl font-extrabold text-gray-900 dark:text-white">
          {puan >= 80 ? "Müthişsin!" : puan >= 50 ? "Güzel çaba!" : "Hadi tekrar dene!"}
        </h1>
        <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">{mesaj}</p>

        <div className="mt-6 grid grid-cols-3 gap-3 text-center">
          <div className="rounded-xl bg-green-50 p-3 dark:bg-green-900/20">
            <p className="text-xl font-bold text-green-600 dark:text-green-400">
              {state.sonuc.dogru_sayisi}
            </p>
            <p className="text-xs text-green-700 dark:text-green-500">Doğru</p>
          </div>
          <div className="rounded-xl bg-red-50 p-3 dark:bg-red-900/20">
            <p className="text-xl font-bold text-red-600 dark:text-red-400">
              {state.sonuc.yanlis_sayisi}
            </p>
            <p className="text-xs text-red-700 dark:text-red-500">Yanlış</p>
          </div>
          <div className="rounded-xl bg-gray-50 p-3 dark:bg-gray-700">
            <p className="text-xl font-bold text-gray-600 dark:text-gray-300">
              {state.sonuc.bos_sayisi}
            </p>
            <p className="text-xs text-gray-500 dark:text-gray-400">Boş</p>
          </div>
        </div>

        <p className="mt-4 text-3xl font-extrabold text-brand-600 dark:text-brand-400">
          {puan.toFixed(1)}
        </p>
        <p className="text-xs text-gray-400">puan (100 üzerinden)</p>

        <div className="mt-6 flex flex-col gap-3 sm:flex-row sm:justify-center">
          <a
            href={`/deneme-sonuclari/${examId}`}
            className="rounded-xl bg-brand-500 px-6 py-3 text-sm font-bold text-white hover:bg-brand-600"
          >
            Sonuçları Gör →
          </a>
          <a
            href="/ogrenci"
            className="rounded-xl border border-gray-200 px-6 py-3 text-sm font-medium text-gray-600 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
          >
            Ana Sayfaya Dön
          </a>
        </div>
      </div>
    );
  }

  // ─── Sınav ekranı ─────────────────────────────────────────────────────────────
  const { veri, secimler, flagged, index } = state;
  if (!veri) return null;

  const sorular = veri.sorular;
  const soru = sorular[index];
  const toplam = sorular.length;
  const cevaplanmis = Object.keys(secimler).length;
  const isSubmitting = state.phase === "submitting";

  // Sayaç rengi
  const sayacRenk =
    kalan === null
      ? "text-gray-500"
      : kalan <= 60
      ? "text-red-600 dark:text-red-400"
      : kalan <= 300
      ? "text-yellow-600 dark:text-yellow-400"
      : "text-gray-600 dark:text-gray-400";

  return (
    <div className="flex min-h-screen flex-col bg-gray-50 dark:bg-gray-950">
      {/* Üst çubuk: sayaç + ilerleme */}
      <div className="sticky top-0 z-20 border-b border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
        <div className="mx-auto flex max-w-2xl items-center justify-between px-4 py-3">
          <p className="text-sm text-gray-500 dark:text-gray-400">
            Soru <span className="font-bold">{index + 1}</span> / {toplam}
          </p>
          {kalan !== null && (
            <p
              className={`text-sm font-bold tabular-nums ${sayacRenk} ${kalan <= 60 ? "animate-pulse" : ""}`}
              aria-live="polite"
              aria-label={`Kalan süre: ${formatSure(kalan)}`}
            >
              ⏱ {formatSure(kalan)}
            </p>
          )}
          <p className="text-sm text-gray-400">
            {cevaplanmis}/{toplam} cevaplandı
          </p>
        </div>
        {/* İlerleme çubuğu */}
        <div className="h-1 w-full bg-gray-100 dark:bg-gray-800">
          <div
            className="h-full bg-brand-500 transition-all duration-300"
            style={{ width: `${((index + 1) / toplam) * 100}%` }}
          />
        </div>
      </div>

      {/* Soru kartı */}
      <div className="flex-1 px-4 py-6">
        <div className="mx-auto max-w-2xl">
          {/* Ders / konu etiketi */}
          <div className="mb-3 flex items-center gap-2">
            <span className="rounded-full bg-brand-100 px-2.5 py-0.5 text-xs font-medium text-brand-700 dark:bg-brand-900/30 dark:text-brand-400">
              {soru.ders}
            </span>
            <span className="text-xs text-gray-400">{soru.konu}</span>
          </div>

          {/* Soru metni */}
          <div className="mb-6 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-700 dark:bg-gray-800">
            <p className="text-base leading-relaxed text-gray-900 dark:text-white">
              {soru.soru_metni}
            </p>
          </div>

          {/* Şıklar */}
          <div className="space-y-2.5">
            {soru.siklar.map((sik) => {
              const secili = secimler[soru.id] === sik.harf;
              return (
                <button
                  key={sik.harf}
                  disabled={isSubmitting}
                  onClick={() => {
                    if (veri) handleSelect(soru.id, sik.harf, veri.deneme_id);
                  }}
                  className={[
                    "flex w-full items-start gap-3 rounded-xl border px-4 py-3 text-left text-sm transition-colors",
                    secili
                      ? "border-brand-500 bg-brand-50 dark:border-brand-400 dark:bg-brand-900/20"
                      : "border-gray-200 bg-white hover:border-brand-300 hover:bg-brand-50/50 dark:border-gray-700 dark:bg-gray-800 dark:hover:border-brand-700",
                    isSubmitting ? "cursor-not-allowed opacity-50" : "",
                  ].join(" ")}
                >
                  <span
                    className={[
                      "flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-xs font-bold",
                      secili
                        ? "bg-brand-500 text-white"
                        : "bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300",
                    ].join(" ")}
                  >
                    {sik.harf}
                  </span>
                  <span className="text-gray-800 dark:text-gray-200">{sik.metin}</span>
                </button>
              );
            })}
          </div>

          {/* Navigasyon düğmeleri */}
          <div className="mt-6 flex items-center justify-between">
            <button
              disabled={index === 0 || isSubmitting}
              onClick={() => dispatch({ type: "navigate", index: index - 1 })}
              className="rounded-xl border border-gray-200 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 disabled:opacity-30 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800"
            >
              ← Önceki
            </button>

            <button
              onClick={() =>
                dispatch({ type: "flag", questionId: soru.id })
              }
              className={[
                "rounded-xl px-3 py-2 text-xs font-medium",
                flagged.has(soru.id)
                  ? "bg-yellow-400 text-yellow-900"
                  : "border border-gray-200 text-gray-400 hover:bg-gray-50 dark:border-gray-700 dark:hover:bg-gray-800",
              ].join(" ")}
              title="Sonra bak"
            >
              {flagged.has(soru.id) ? "★ İşaretlendi" : "☆ İşaretle"}
            </button>

            {index < toplam - 1 ? (
              <button
                disabled={isSubmitting}
                onClick={() => dispatch({ type: "navigate", index: index + 1 })}
                className="rounded-xl bg-brand-500 px-4 py-2 text-sm font-medium text-white hover:bg-brand-600 disabled:opacity-50"
              >
                Sonraki →
              </button>
            ) : (
              <button
                disabled={isSubmitting}
                onClick={() => submit(secimler)}
                className="rounded-xl bg-green-600 px-4 py-2 text-sm font-bold text-white hover:bg-green-700 disabled:opacity-50"
              >
                {isSubmitting ? "Gönderiliyor..." : "Sınavı Tamamla ✓"}
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Alt gezinme şeridi (mobil) */}
      <div className="sticky bottom-0 z-20 border-t border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
        <div className="flex items-center gap-1 overflow-x-auto px-4 py-3">
          {sorular.map((s, i) => {
            const isCevaplandi = !!secimler[s.id];
            const isIsaretli = flagged.has(s.id);
            const isAktif = i === index;
            return (
              <button
                key={s.id}
                onClick={() => dispatch({ type: "navigate", index: i })}
                className={[
                  "flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-xs font-bold transition-colors",
                  isAktif
                    ? "ring-2 ring-brand-500 ring-offset-1"
                    : "",
                  isIsaretli
                    ? "bg-yellow-400 text-yellow-900"
                    : isCevaplandi
                    ? "bg-brand-500 text-white"
                    : "bg-gray-100 text-gray-500 dark:bg-gray-700 dark:text-gray-400",
                ].join(" ")}
                title={`Soru ${i + 1}${isIsaretli ? " (işaretli)" : isCevaplandi ? " (cevaplandı)" : ""}`}
              >
                {i + 1}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
