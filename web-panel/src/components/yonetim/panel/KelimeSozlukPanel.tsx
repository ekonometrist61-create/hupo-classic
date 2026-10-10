"use client";

// Kelime Evreni sözlüğü: anlam ekleme ve sözcük ilişkisi önerme/onaylama.
// Onay ilişkiyi kuran kişi tarafından yapılamaz (dört göz); bu kural sunucuda da uygulanır.

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, labelClass, linkBtn, primaryBtn, tdClass, thClass } from "./styles";
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

  return (
    <section className={`${cardClass} p-5 sm:p-6`}>
      <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">{t("sozluk.baslik")}</h3>
      <ErrorNote message={error} />
      {mesaj && <p className="mb-3 text-sm text-green-700 dark:text-green-400">{mesaj}</p>}

      <div className="grid gap-6 lg:grid-cols-2">
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

      <div className="mt-6 overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead>
            <tr>
              <th className={thClass}>{t("sozluk.tablo.iliski")}</th>
              <th className={thClass}>{t("sozluk.tablo.tur")}</th>
              <th className={thClass}>{t("sozluk.tablo.durum")}</th>
              <th className={thClass}>{t("sozluk.tablo.islem")}</th>
            </tr>
          </thead>
          <tbody>
            {iliskiler.length === 0 ? (
              <tr>
                <td className={tdClass} colSpan={4}>{t("sozluk.iliskiYok")}</td>
              </tr>
            ) : (
              iliskiler.map((r) => (
                <tr key={r.id}>
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
                        className={`${linkBtn} disabled:opacity-50`}
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
