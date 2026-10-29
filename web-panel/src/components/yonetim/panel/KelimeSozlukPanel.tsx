"use client";

// Kelime Evreni sözlüğü: anlam ekleme ve sözcük ilişkisi önerme/onaylama.
// Onay ilişkiyi kuran kişi tarafından yapılamaz (dört göz); bu kural sunucuda da uygulanır.

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, labelClass, linkBtn, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";
import { hataAnahtari, type AnlamSecenegi, type KelimeIliskiTuru } from "./kelimeEvreni";

interface IliskiSatiri {
  id: string;
  iliski_turu: KelimeIliskiTuru;
  kaynak_kelime: string;
  kaynak_anlam: string;
  hedef_kelime: string;
  hedef_anlam: string;
  onay_tarihi: string | null;
}

const SOZCUK_TURLERI = ["isim", "sifat", "fiil", "zarf", "baglac", "diger"] as const;
const ILISKILER: KelimeIliskiTuru[] = ["es_anlamli", "zit_anlamli", "es_sesli"];

interface Props {
  anlamlar: AnlamSecenegi[];
  onDegisti: () => void;
}

export default function KelimeSozlukPanel({ anlamlar, onDegisti }: Props) {
  const t = useTranslations("yonetim.kelimeEvreni");
  const [iliskiler, setIliskiler] = useState<IliskiSatiri[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [mesaj, setMesaj] = useState<string | null>(null);
  const [yenile, setYenile] = useState(0);

  const [kelime, setKelime] = useState("");
  const [anlam, setAnlam] = useState("");
  const [sozcukTuru, setSozcukTuru] = useState<string>("isim");
  const [anlamKaydediliyor, setAnlamKaydediliyor] = useState(false);

  const [kaynak, setKaynak] = useState("");
  const [hedef, setHedef] = useState("");
  const [iliskiTuru, setIliskiTuru] = useState<KelimeIliskiTuru>("es_anlamli");
  const [iliskiKaydediliyor, setIliskiKaydediliyor] = useState(false);
  const [onaylanan, setOnaylanan] = useState<string | null>(null);
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const [topluIslemde, setTopluIslemde] = useState(false);

  const reload = useCallback(() => setYenile((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("kelime_yonetim_iliskiler");
      if (cancelled) return;
      if (err) {
        setError(t(`hatalar.${hataAnahtari(err.message)}`));
      } else {
        setError(null);
        setIliskiler((data ?? []) as IliskiSatiri[]);
        setSecili(new Set());
      }
    };
    void run();
    return () => {
      cancelled = true;
    };
    // t sabit çeviri fonksiyonu; yalnızca yenileme anahtarı veri çekmeyi tetikler
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [yenile]);

  const anlamKaydet = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setMesaj(null);
    if (kelime.trim().length < 1 || anlam.trim().length < 2) return setError(t("sozluk.eksik"));
    setAnlamKaydediliyor(true);
    const { error: err } = await createClient().rpc("kelime_anlam_kaydet", {
      p_kelime: kelime.trim(),
      p_anlam: anlam.trim(),
      p_sozcuk_turu: sozcukTuru,
      p_id: null,
    });
    setAnlamKaydediliyor(false);
    if (err) return setError(t(`hatalar.${hataAnahtari(err.message)}`));
    setKelime("");
    setAnlam("");
    setMesaj(t("sozluk.anlamEklendi"));
    onDegisti();
  };

  const iliskiOner = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setMesaj(null);
    if (!kaynak || !hedef || kaynak === hedef) return setError(t("sozluk.iliskiEksik"));
    setIliskiKaydediliyor(true);
    const { error: err } = await createClient().rpc("kelime_iliski_kaydet", {
      p_kaynak_anlam_id: kaynak,
      p_hedef_anlam_id: hedef,
      p_iliski_turu: iliskiTuru,
    });
    setIliskiKaydediliyor(false);
    if (err) return setError(t(`hatalar.${hataAnahtari(err.message)}`));
    setMesaj(t("sozluk.iliskiEklendi"));
    reload();
  };

  const onayla = async (id: string) => {
    setOnaylanan(id);
    setError(null);
    setMesaj(null);
    const { error: err } = await createClient().rpc("kelime_iliski_onayla", { p_iliski_id: id });
    setOnaylanan(null);
    if (err) return setError(t(`hatalar.${hataAnahtari(err.message)}`));
    setMesaj(t("sozluk.iliskiOnaylandi"));
    reload();
    onDegisti();
  };

  const secimDegistir = (id: string, secildi: boolean) =>
    setSecili((onceki) => {
      const yeni = new Set(onceki);
      if (secildi) yeni.add(id);
      else yeni.delete(id);
      return yeni;
    });

  const tumunuSecili = iliskiler.length > 0 && iliskiler.every((r) => secili.has(r.id));

  const tumunuSecDegistir = (secildi: boolean) =>
    setSecili(secildi ? new Set(iliskiler.map((r) => r.id)) : new Set());

  // Onay kuralı sunucudadır (iki model ailesi "geçti" + dört göz); reddedilen kayıt atlanır, işlem durmaz.
  const topluOnayla = async () => {
    const hedefler = iliskiler.filter((r) => secili.has(r.id) && !r.onay_tarihi).map((r) => r.id);
    setError(null);
    setMesaj(null);
    if (hedefler.length === 0) return setMesaj(t("sozluk.toplu.onaylaYok"));
    if (!window.confirm(t("sozluk.toplu.onaylaOnay", { sayi: hedefler.length }))) return;
    setTopluIslemde(true);
    const supabase = createClient();
    let onaylandi = 0;
    let atlandi = 0;
    for (let i = 0; i < hedefler.length; i += 10) {
      const sonuclar = await Promise.allSettled(
        hedefler.slice(i, i + 10).map((id) => supabase.rpc("kelime_iliski_onayla", { p_iliski_id: id })),
      );
      for (const r of sonuclar) {
        if (r.status === "fulfilled" && !r.value.error) onaylandi++;
        else atlandi++;
      }
    }
    setTopluIslemde(false);
    setMesaj(t("sozluk.toplu.onaylaSonuc", { onaylandi, atlandi: atlandi + secili.size - hedefler.length }));
    reload();
    onDegisti();
  };

  const topluKaldir = async () => {
    const hedefler = iliskiler.filter((r) => secili.has(r.id) && r.onay_tarihi).map((r) => r.id);
    setError(null);
    setMesaj(null);
    if (hedefler.length === 0) return setMesaj(t("sozluk.toplu.kaldirYok"));
    if (hedefler.length > 200) return setError(t("sozluk.toplu.limit"));
    if (!window.confirm(t("sozluk.toplu.kaldirOnay", { sayi: hedefler.length }))) return;
    setTopluIslemde(true);
    const { data, error: err } = await createClient().rpc("kelime_iliski_onay_kaldir", { p_ids: hedefler });
    setTopluIslemde(false);
    if (err) {
      // Sunucu fonksiyonu henüz uygulanmadıysa (migration bekliyor) genel hata yerine açık uyarı
      const kurulu = !/kelime_iliski_onay_kaldir|PGRST202/.test(`${err.code ?? ""} ${err.message}`);
      return setError(kurulu ? t(`hatalar.${hataAnahtari(err.message)}`) : t("sozluk.toplu.kurulmadi"));
    }
    const s = data as { kaldirilan: number; atlanan: unknown[] };
    setMesaj(t("sozluk.toplu.kaldirSonuc", { kaldirilan: s.kaldirilan, atlandi: s.atlanan.length + secili.size - hedefler.length }));
    reload();
    onDegisti();
  };

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">{t("sozluk.baslik")}</h3>
      <ErrorNote message={error} />
      {mesaj && <p className="mb-3 text-sm text-green-700 dark:text-green-400">{mesaj}</p>}

      <div className="grid gap-6 md:grid-cols-2">
        <form className="space-y-3" onSubmit={anlamKaydet}>
          <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-200">{t("sozluk.anlamBaslik")}</h4>
          <div>
            <label className={labelClass} htmlFor="sozluk-kelime">{t("sozluk.kelime")}</label>
            <input id="sozluk-kelime" className={inputClass} maxLength={60} value={kelime} onChange={(e) => setKelime(e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="sozluk-anlam">{t("sozluk.anlam")}</label>
            <input id="sozluk-anlam" className={inputClass} maxLength={300} value={anlam} onChange={(e) => setAnlam(e.target.value)} />
          </div>
          <div>
            <label className={labelClass} htmlFor="sozluk-tur">{t("sozluk.sozcukTuru")}</label>
            <select id="sozluk-tur" className={inputClass} value={sozcukTuru} onChange={(e) => setSozcukTuru(e.target.value)}>
              {SOZCUK_TURLERI.map((s) => (
                <option key={s} value={s}>{t(`sozluk.turler.${s}`)}</option>
              ))}
            </select>
          </div>
          <button type="submit" className={primaryBtn} disabled={anlamKaydediliyor}>{t("sozluk.anlamEkle")}</button>
        </form>

        <form className="space-y-3" onSubmit={iliskiOner}>
          <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-200">{t("sozluk.iliskiBaslik")}</h4>
          <div>
            <label className={labelClass} htmlFor="sozluk-kaynak">{t("sozluk.kaynak")}</label>
            <select id="sozluk-kaynak" className={inputClass} value={kaynak} onChange={(e) => setKaynak(e.target.value)}>
              <option value="">{t("sozluk.seciniz")}</option>
              {anlamlar.map((a) => (
                <option key={a.id} value={a.id}>{a.kelime} — {a.anlam}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="sozluk-hedef">{t("sozluk.hedef")}</label>
            <select id="sozluk-hedef" className={inputClass} value={hedef} onChange={(e) => setHedef(e.target.value)}>
              <option value="">{t("sozluk.seciniz")}</option>
              {anlamlar.map((a) => (
                <option key={a.id} value={a.id}>{a.kelime} — {a.anlam}</option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass} htmlFor="sozluk-iliski">{t("sozluk.iliskiTuru")}</label>
            <select id="sozluk-iliski" className={inputClass} value={iliskiTuru} onChange={(e) => setIliskiTuru(e.target.value as KelimeIliskiTuru)}>
              {ILISKILER.map((i) => (
                <option key={i} value={i}>{t(`turler.${i}`)}</option>
              ))}
            </select>
          </div>
          <button type="submit" className={primaryBtn} disabled={iliskiKaydediliyor}>{t("sozluk.iliskiOner")}</button>
        </form>
      </div>

      {secili.size > 0 && (
        <div className="mt-6 flex flex-wrap items-center gap-2 rounded-lg bg-gray-50 p-3 dark:bg-white/3">
          <span className="text-sm font-medium text-gray-800 dark:text-white/90">{t("sozluk.toplu.seciliSayi", { sayi: secili.size })}</span>
          <button type="button" className={primaryBtn} onClick={() => void topluOnayla()} disabled={topluIslemde}>
            {t("sozluk.toplu.onayla")}
          </button>
          <button type="button" className={outlineBtn} onClick={() => void topluKaldir()} disabled={topluIslemde}>
            {t("sozluk.toplu.kaldir")}
          </button>
          <button type="button" className={outlineBtn} onClick={() => setSecili(new Set())} disabled={topluIslemde}>
            {t("sozluk.toplu.temizle")}
          </button>
        </div>
      )}

      <div className="mt-6 overflow-x-auto [&_tr>*:first-child]:sticky [&_tr>*:first-child]:inset-s-0 [&_tr>*:first-child]:z-1 [&_tr>*:first-child]:bg-white dark:[&_tr>*:first-child]:bg-gray-900">
        <table className="min-w-full text-left text-sm">
          <thead>
            <tr>
              <th className={thClass}>
                <span className="inline-flex min-h-11 min-w-11 items-center justify-center">
                  <input
                    type="checkbox"
                    className="size-5"
                    checked={tumunuSecili}
                    onChange={(e) => tumunuSecDegistir(e.target.checked)}
                    disabled={topluIslemde || iliskiler.length === 0}
                    aria-label={t("sozluk.toplu.sayfaTumu")}
                  />
                </span>
              </th>
              <th className={thClass}>{t("sozluk.tablo.iliski")}</th>
              <th className={thClass}>{t("sozluk.tablo.tur")}</th>
              <th className={thClass}>{t("sozluk.tablo.durum")}</th>
              <th className={thClass}>{t("sozluk.tablo.islem")}</th>
            </tr>
          </thead>
          <tbody>
            {iliskiler.length === 0 ? (
              <tr>
                <td className={tdClass} colSpan={5}>{t("sozluk.iliskiYok")}</td>
              </tr>
            ) : (
              iliskiler.map((r) => (
                <tr key={r.id}>
                  <td className={tdClass}>
                    <span className="inline-flex min-h-11 min-w-11 items-center justify-center">
                      <input
                        type="checkbox"
                        className="size-5"
                        checked={secili.has(r.id)}
                        onChange={(e) => secimDegistir(r.id, e.target.checked)}
                        disabled={topluIslemde}
                        aria-label={t("sozluk.toplu.satirSec", { kaynak: r.kaynak_kelime, hedef: r.hedef_kelime })}
                      />
                    </span>
                  </td>
                  <td className={tdClass}>
                    {r.kaynak_kelime} ↔ {r.hedef_kelime}
                    <span className="block text-xs text-gray-500">{r.kaynak_anlam} · {r.hedef_anlam}</span>
                  </td>
                  <td className={tdClass}>{t(`turler.${r.iliski_turu}`)}</td>
                  <td className={tdClass}>{r.onay_tarihi ? t("sozluk.onayli") : t("sozluk.onayBekliyor")}</td>
                  <td className={tdClass}>
                    {!r.onay_tarihi && (
                      <button
                        type="button"
                        className={`${linkBtn} inline-flex min-h-11 items-center disabled:opacity-50`}
                        onClick={() => onayla(r.id)}
                        disabled={onaylanan === r.id}
                      >
                        {t("sozluk.onayla")}
                      </button>
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </section>
  );
}
