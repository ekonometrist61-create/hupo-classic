"use client";

// Kelime Evreni inceleme kuyruğu: incelemedeki soruları cevap anahtarı ve model denetimleriyle gösterir,
// toplu kontrol (kuru çalıştırma) ve toplu yayın sunar. Kural RPC'dedir (kelime_soru_durum_degistir):
// iki farklı model ailesinden "pass" yoksa soru yayınlanmaz. Yayın düğmesi insan kontrolüdür.

import { useCallback, useEffect, useMemo, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, outlineBtn, primaryBtn } from "./styles";
import { hataAnahtari, type KelimeIliskiTuru } from "./kelimeEvreni";

interface Denetim {
  model: string;
  aile: string;
  karar: "pass" | "review_needed" | "fail";
  not: string | null;
  tarih: string;
}

interface KuyrukSatiri {
  id: string;
  kelime: string;
  anlam: string;
  iliski_turu: KelimeIliskiTuru;
  sinif: number;
  zorluk: number;
  kazanim_kodu: string | null;
  kanit_duzeyi: string;
  soru_metni: string;
  secenekler: string[];
  dogru_indeks: number;
  ipucu: string | null;
  aciklama: string;
  kapi: boolean;
  denetimler: Denetim[];
}

interface TopluSonuc {
  kuru: boolean;
  yayinlanan: number;
  atlanan: { id: string; neden: string }[];
}

const TURLER: KelimeIliskiTuru[] = [
  "es_anlamli",
  "zit_anlamli",
  "es_sesli",
  "deyim",
  "atasozu",
  "sozcuk_turu",
  "baglamda_anlam",
];
const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8];

export default function KelimeIncelemeKuyrugu({ onChanged }: { onChanged: () => void }) {
  const t = useTranslations("yonetim.kelimeEvreni");
  const tk = useTranslations("yonetim.kelimeEvreni.kuyruk");
  const [sinif, setSinif] = useState("");
  const [tur, setTur] = useState("");
  const [satirlar, setSatirlar] = useState<KuyrukSatiri[]>([]);
  const [toplam, setToplam] = useState(0);
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [mesaj, setMesaj] = useState<string | null>(null);
  const [islemde, setIslemde] = useState(false);
  const [yenile, setYenile] = useState(0);

  useEffect(() => {
    let iptal = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("kelime_inceleme_kuyrugu", {
        p_sinif: sinif ? Number(sinif) : null,
        p_tur: tur || null,
        p_limit: 100,
      });
      if (iptal) return;
      if (err) {
        setError(t(`hatalar.${hataAnahtari(err.message)}`));
      } else {
        const veri = data as { toplam: number; satirlar: KuyrukSatiri[] };
        setError(null);
        setToplam(veri.toplam);
        setSatirlar(veri.satirlar ?? []);
        setSecili(new Set());
      }
      setLoading(false);
    };
    void run();
    return () => {
      iptal = true;
    };
    // t sabit çeviri fonksiyonu; süzgeç ve yenileme anahtarı veri çekmeyi tetikler
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sinif, tur, yenile]);

  const gecenSayisi = useMemo(() => satirlar.filter((s) => s.kapi).length, [satirlar]);

  const sec = (id: string, var_: boolean) =>
    setSecili((onceki) => {
      const yeni = new Set(onceki);
      if (var_) yeni.add(id);
      else yeni.delete(id);
      return yeni;
    });

  const toplu = useCallback(
    async (kuru: boolean) => {
      const ids = [...secili];
      if (ids.length === 0) return;
      if (!kuru && !window.confirm(tk("yayinOnay", { sayi: ids.length }))) return;
      setIslemde(true);
      const { data, error: err } = await createClient().rpc("kelime_toplu_yayinla", { p_ids: ids, p_kuru: kuru });
      setIslemde(false);
      if (err) {
        setMesaj(null);
        return setError(t(`hatalar.${hataAnahtari(err.message)}`));
      }
      const s = data as TopluSonuc;
      setError(null);
      if (kuru) {
        setMesaj(tk("kontrolSonuc", { yayinlanir: s.yayinlanan, atlanir: s.atlanan.length }));
      } else {
        setMesaj(tk("yayinSonuc", { yayinlanan: s.yayinlanan, atlanan: s.atlanan.length }));
        setYenile((k) => k + 1);
        onChanged();
      }
    },
    [secili, t, tk, onChanged],
  );

  const taslagaAl = async (id: string) => {
    setIslemde(true);
    const { error: err } = await createClient().rpc("kelime_soru_durum_degistir", { p_id: id, p_hedef: "taslak" });
    setIslemde(false);
    if (err) return setError(t(`hatalar.${hataAnahtari(err.message)}`));
    setError(null);
    setYenile((k) => k + 1);
    onChanged();
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{tk("baslik")}</h3>
      <p className="mt-1 mb-4 text-sm text-gray-500 dark:text-gray-400">{tk("aciklama")}</p>

      <ErrorNote message={error} />
      {mesaj && (
        <p role="status" className="mb-3 rounded-lg bg-blue-50 px-3 py-2 text-sm text-blue-800 dark:bg-blue-500/10 dark:text-blue-300">
          {mesaj}
        </p>
      )}

      <div className="mb-3 flex flex-wrap items-end gap-3">
        <div>
          <label className="mb-1 block text-xs text-gray-500 dark:text-gray-400" htmlFor="kuyruk-sinif">{tk("sinif")}</label>
          <select id="kuyruk-sinif" className={`${inputClass} w-full sm:w-32`} value={sinif} onChange={(e) => setSinif(e.target.value)}>
            <option value="">{tk("tumu")}</option>
            {SINIFLAR.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="mb-1 block text-xs text-gray-500 dark:text-gray-400" htmlFor="kuyruk-tur">{tk("tur")}</label>
          <select id="kuyruk-tur" className={`${inputClass} w-full sm:w-64`} value={tur} onChange={(e) => setTur(e.target.value)}>
            <option value="">{tk("tumu")}</option>
            {TURLER.map((x) => (
              <option key={x} value={x}>{t(`turler.${x}`)}</option>
            ))}
          </select>
        </div>
        <span className="pb-2 text-sm text-gray-500 dark:text-gray-400">{tk("toplam", { sayi: toplam })}</span>
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-2">
        <button type="button" className={outlineBtn} onClick={() => setSecili(new Set(satirlar.filter((s) => s.kapi).map((s) => s.id)))} disabled={islemde || gecenSayisi === 0}>
          {tk("gecenleriSec")} ({gecenSayisi})
        </button>
        <button type="button" className={outlineBtn} onClick={() => setSecili(new Set())} disabled={islemde || secili.size === 0}>{tk("temizle")}</button>
        <span className="text-sm text-gray-600 dark:text-gray-300">{tk("seciliSayi", { sayi: secili.size })}</span>
        <button type="button" className={outlineBtn} onClick={() => void toplu(true)} disabled={islemde || secili.size === 0}>{tk("kontrolEt")}</button>
        <button type="button" className={primaryBtn} onClick={() => void toplu(false)} disabled={islemde || secili.size === 0}>{tk("yayinla")}</button>
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">{t("loading")}</p>
      ) : satirlar.length === 0 ? (
        <p className="text-sm text-gray-500">{tk("bos")}</p>
      ) : (
        <ul className="space-y-3">
          {satirlar.map((s) => (
            <li key={s.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
              <div className="flex items-start gap-3">
                <input
                  type="checkbox"
                  className="mt-1 size-5 shrink-0"
                  checked={secili.has(s.id)}
                  onChange={(e) => sec(s.id, e.target.checked)}
                  aria-label={s.soru_metni}
                />
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-theme-xs text-gray-500 dark:text-gray-400">
                    <span>{s.sinif}. {t("sinifKisa")}</span>
                    <span>{t(`turler.${s.iliski_turu}`)}</span>
                    <span>{s.kelime}</span>
                    <span className={s.kapi ? "font-medium text-green-700 dark:text-green-400" : "font-medium text-amber-700 dark:text-amber-400"}>
                      {s.kapi ? tk("kapiAcik") : tk("kapiKapali")}
                    </span>
                  </div>
                  <p className="mt-1 text-sm wrap-break-word text-gray-800 dark:text-white/90">{s.soru_metni}</p>
                  <ol className="mt-2 space-y-1 text-sm text-gray-700 dark:text-gray-300">
                    {s.secenekler.map((o, i) => (
                      <li key={i} className={i === s.dogru_indeks ? "font-medium text-green-700 dark:text-green-400" : ""}>
                        {String.fromCharCode(65 + i)}) {o}
                        {i === s.dogru_indeks ? ` (${tk("dogru")})` : ""}
                      </li>
                    ))}
                  </ol>
                  <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{s.aciklama}</p>
                  <ul className="mt-2 flex flex-wrap gap-2">
                    {s.denetimler.length === 0 ? (
                      <li className="text-theme-xs text-gray-500">{tk("denetimYok")}</li>
                    ) : (
                      s.denetimler.map((d) => (
                        <li
                          key={d.model}
                          title={d.not ?? undefined}
                          className={`rounded-full border px-2 py-0.5 text-theme-xs ${
                            d.karar === "pass"
                              ? "border-green-300 text-green-800 dark:border-green-700 dark:text-green-300"
                              : "border-amber-300 text-amber-800 dark:border-amber-700 dark:text-amber-300"
                          }`}
                        >
                          {d.model} · {d.aile} · {d.karar}
                        </li>
                      ))
                    )}
                  </ul>
                  <button type="button" className="mt-2 min-h-11 text-sm text-brand-500 hover:underline disabled:opacity-50" onClick={() => void taslagaAl(s.id)} disabled={islemde}>
                    {tk("taslagaAl")}
                  </button>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
