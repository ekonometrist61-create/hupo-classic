"use client";

// Liste: sınıf/tema/değer/durum süzgeçleri. Sınıf ve durum sunucuda, tema ve değer yüklenen sayfada süzülür.
import { useMemo, useState } from "react";
import { useTranslations } from "next-intl";

import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { OKUMA_DURUMLARI, type DenetimDurumu, type OkumaDurum } from "@/lib/okuma/okuma";
import ErrorNote from "../panel/ErrorNote";
import { inputClass, labelClass, linkBtn, outlineBtn, primaryBtn, tdClass, thClass } from "../panel/styles";
import { useHataMetni, VeriDurumu } from "./ortak";
import SurumDetay from "./SurumDetay";
import TopluIslemModal, { type TopluHikaye } from "./TopluIslemModal";
import type { ListeYaniti, SurumSatiri, TopluIslem } from "./tipler";

const LIMIT = 200;
const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8];
const EYLEM_BTN = `${linkBtn} inline-flex min-h-11 items-center`;

const DENETIM_SUZGECLERI = ["ajanlarGecti", "ajanBekliyor", "insanOnayli", "insanBekliyor", "yayinaHazir"] as const;
type DenetimSuzgeci = (typeof DENETIM_SUZGECLERI)[number];

// Denetim alanları boşsa "bekliyor" sayılır (SurumDetay ile aynı varsayılan).
const tamDenetim = (d: DenetimDurumu | null): Required<DenetimDurumu> => ({ ajan_a: "pending", ajan_b: "pending", insan: "pending", ...(d ?? {}) });
const ajanlarGecti = (d: DenetimDurumu | null) => {
  const x = tamDenetim(d);
  return x.ajan_a === "pass" && x.ajan_b === "pass";
};
const denetimUyar = (d: DenetimDurumu | null, f: DenetimSuzgeci) => {
  const x = tamDenetim(d);
  if (f === "ajanlarGecti") return ajanlarGecti(d);
  if (f === "ajanBekliyor") return !ajanlarGecti(d);
  if (f === "insanOnayli") return x.insan === "approved";
  if (f === "insanBekliyor") return x.insan !== "approved";
  return ajanlarGecti(d) && x.insan === "approved";
};
// Yalnız taslak/incelemedeki sürümün denetimi değişebilir (sunucu da böyle zorlar).
const denetimDuzenlenebilir = (s: SurumSatiri) => s.durum === "taslak" || s.durum === "incelemede";

const ROZET: Record<string, string> = {
  pass: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-400",
  approved: "bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-400",
  fail: "bg-error-50 text-error-700 dark:bg-error-500/15 dark:text-error-400",
  rejected: "bg-error-50 text-error-700 dark:bg-error-500/15 dark:text-error-400",
  review_needed: "bg-warning-50 text-warning-700 dark:bg-warning-500/15 dark:text-warning-400",
  pending: "bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-300",
};

export default function ListeSekmesi() {
  const t = useTranslations("yonetim.hikayeAtolyesi");
  const hata = useHataMetni();
  const [denetimSuzgeci, setDenetimSuzgeci] = useState<DenetimSuzgeci | "">("");
  const [onayIslemde, setOnayIslemde] = useState(false);
  const [onayMesaji, setOnayMesaji] = useState<string | null>(null);
  const [onayHatalari, setOnayHatalari] = useState<string | null>(null);
  const [durum, setDurum] = useState<OkumaDurum | "">("");
  const [sinif, setSinif] = useState("");
  const [tema, setTema] = useState("");
  const [deger, setDeger] = useState("");
  const [secili, setSecili] = useState<SurumSatiri | null>(null);
  // Toplu işlem: seçim hikâye kimliğiyle tutulur (aynı hikâyenin birden çok sürüm satırı tek seçimdir).
  const [isaretli, setIsaretli] = useState<Set<string>>(new Set());
  const [toplu, setToplu] = useState<TopluIslem | null>(null);

  const liste = useAdminRpc<ListeYaniti>("okuma_yonetim_liste", {
    p_durum: durum || null,
    p_ana_sinif: sinif ? Number(sinif) : null,
    p_limit: LIMIT,
    p_offset: 0,
  });

  const satirlar = useMemo(() => liste.data?.satirlar ?? [], [liste.data]);
  const temaSecenekleri = useMemo(() => [...new Set(satirlar.flatMap((s) => s.temalar ?? []))].sort(), [satirlar]);
  const degerSecenekleri = useMemo(
    () => [...new Set(satirlar.flatMap((s) => [s.ana_deger, s.yardimci_deger]).filter((d): d is string => !!d))].sort((a, b) => a.length - b.length || a.localeCompare(b)),
    [satirlar],
  );
  const gorunen = satirlar.filter(
    (s) =>
      (!tema || (s.temalar ?? []).includes(tema)) &&
      (!deger || s.ana_deger === deger || s.yardimci_deger === deger) &&
      (!denetimSuzgeci || denetimUyar(s.denetim, denetimSuzgeci)),
  );
  const toplam = liste.data?.toplam ?? 0;

  const gorunenHikayeler = useMemo(() => {
    const harita = new Map<string, TopluHikaye>();
    for (const s of gorunen) if (!harita.has(s.hikaye_id)) harita.set(s.hikaye_id, { id: s.hikaye_id, baslik: s.baslik, slug: s.slug });
    return [...harita.values()];
  }, [gorunen]);
  // Süzgeç değişince görünmeyen hikâyeler seçimden düşer; kullanıcının görmediği şey işlenmez.
  const gecerliSecim = gorunenHikayeler.filter((h) => isaretli.has(h.id));
  const hepsiSecili = gorunenHikayeler.length > 0 && gecerliSecim.length === gorunenHikayeler.length;
  const degistirSecim = (id: string) =>
    setIsaretli((onceki) => {
      const yeni = new Set(onceki);
      if (yeni.has(id)) yeni.delete(id);
      else yeni.add(id);
      return yeni;
    });
  const tumunuSec = () => setIsaretli(hepsiSecili ? new Set() : new Set(gorunenHikayeler.map((h) => h.id)));
  const secimKutusu = (s: SurumSatiri) => (
    <label className="inline-flex min-h-11 min-w-11 cursor-pointer items-center justify-center">
      <input
        type="checkbox"
        className="size-4"
        checked={isaretli.has(s.hikaye_id)}
        onChange={() => degistirSecim(s.hikaye_id)}
        aria-label={t("toplu.sec", { baslik: s.baslik })}
      />
    </label>
  );

  // Toplu insan onayı: seçili hikâyelerin taslak/incelemedeki sürümlerinde yalnız "insan" kararı değişir;
  // ajan sonuçları olduğu gibi gönderilir. Dört göz ve kapılar sunucuda zorlanır, hata sürüm başına gösterilir.
  const topluOnay = async (onayla: boolean) => {
    const secimIdleri = new Set(gecerliSecim.map((h) => h.id));
    const adaylar = gorunen.filter(
      (s) =>
        secimIdleri.has(s.hikaye_id) &&
        denetimDuzenlenebilir(s) &&
        (onayla ? ajanlarGecti(s.denetim) && tamDenetim(s.denetim).insan !== "approved" : tamDenetim(s.denetim).insan !== "pending"),
    );
    setOnayMesaji(null);
    setOnayHatalari(null);
    if (adaylar.length === 0) return setOnayMesaji(t("toplu.onayYok"));
    if (!window.confirm(t(onayla ? "toplu.onayliSoru" : "toplu.onayKaldirSoru", { n: adaylar.length }))) return;
    setOnayIslemde(true);
    let yapilan = 0;
    const hatalar: string[] = [];
    for (const s of adaylar) {
      const d = tamDenetim(s.denetim);
      const { error } = await adminCall("okuma_surum_durum_degistir", {
        p_surum_id: s.surum_id,
        p_durum: s.durum,
        p_denetim: { ajan_a: d.ajan_a, ajan_b: d.ajan_b, insan: onayla ? "approved" : "pending" },
      });
      if (error) hatalar.push(t("toplu.onayHata", { baslik: s.baslik, hata: hata(error) }));
      else yapilan += 1;
    }
    setOnayIslemde(false);
    setOnayMesaji(t("toplu.onaySonuc", { yapilan, atlanan: gecerliSecim.length - yapilan }));
    setOnayHatalari(hatalar.length ? hatalar.join("\n") : null);
    if (yapilan > 0) liste.reload();
  };

  const denetimRozetleri = (s: SurumSatiri) => {
    const d = tamDenetim(s.denetim);
    return (
      <div className="flex flex-wrap gap-1">
        {(["ajan_a", "ajan_b", "insan"] as const).map((k) => (
          <span key={k} className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-theme-xs font-medium ${ROZET[d[k]]}`}>
            {t(`liste.denetimKisa.${k}`)}: {t(`denetimDegerleri.${d[k]}`)}
          </span>
        ))}
      </div>
    );
  };

  const etiketler = (s: SurumSatiri) => (s.temalar ?? []).join(", ") || "-";
  const degerler = (s: SurumSatiri) => [s.ana_deger, s.yardimci_deger].filter(Boolean).join(" · ") || "-";

  return (
    <div>
      <div className="mb-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        <div>
          <label className={labelClass} htmlFor="ha-f-denetim">{t("liste.denetim")}</label>
          <select id="ha-f-denetim" className={inputClass} value={denetimSuzgeci} onChange={(e) => setDenetimSuzgeci(e.target.value as DenetimSuzgeci | "")}>
            <option value="">{t("liste.tumu")}</option>
            {DENETIM_SUZGECLERI.map((f) => (
              <option key={f} value={f}>{t(`liste.denetimSuzgec.${f}`)}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="ha-f-durum">{t("liste.durum")}</label>
          <select id="ha-f-durum" className={inputClass} value={durum} onChange={(e) => setDurum(e.target.value as OkumaDurum | "")}>
            <option value="">{t("liste.tumu")}</option>
            {OKUMA_DURUMLARI.map((d) => (
              <option key={d} value={d}>{t(`durumlar.${d}`)}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="ha-f-sinif">{t("liste.sinif")}</label>
          <select id="ha-f-sinif" className={inputClass} value={sinif} onChange={(e) => setSinif(e.target.value)}>
            <option value="">{t("liste.tumu")}</option>
            {SINIFLAR.map((n) => (
              <option key={n} value={n}>{t("liste.sinifDeger", { n })}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="ha-f-tema">{t("liste.tema")}</label>
          <select id="ha-f-tema" className={inputClass} value={tema} onChange={(e) => setTema(e.target.value)}>
            <option value="">{t("liste.tumu")}</option>
            {temaSecenekleri.map((x) => (
              <option key={x} value={x}>{x}</option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="ha-f-deger">{t("liste.deger")}</label>
          <select id="ha-f-deger" className={inputClass} value={deger} onChange={(e) => setDeger(e.target.value)}>
            <option value="">{t("liste.tumu")}</option>
            {degerSecenekleri.map((x) => (
              <option key={x} value={x}>{x}</option>
            ))}
          </select>
        </div>
      </div>

      <VeriDurumu loading={liste.loading} error={liste.error} missing={liste.missing} onRetry={liste.reload} />

      {!liste.loading && !liste.error && !liste.missing && (
        <>
          <p className="mb-3 text-sm text-gray-500 dark:text-gray-400" aria-live="polite">
            {t("liste.sayi", { gorunen: gorunen.length, toplam })}
          </p>
          {toplam > satirlar.length && (
            <p className="mb-3 text-sm text-warning-700 dark:text-warning-400">{t("liste.sinirUyari", { limit: satirlar.length })}</p>
          )}
          {gorunen.length > 0 && (
            <div className="mb-3 flex flex-wrap items-center gap-3 rounded-xl border border-gray-200 p-3 dark:border-gray-800">
              <label className="inline-flex min-h-11 cursor-pointer items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                <input type="checkbox" className="size-4" checked={hepsiSecili} onChange={tumunuSec} />
                {t("toplu.hepsi")}
              </label>
              <span className="text-sm text-gray-600 dark:text-gray-300" aria-live="polite">
                {t("toplu.secilen", { n: gecerliSecim.length })}
              </span>
              <div className="flex flex-wrap gap-3 sm:ms-auto">
                <button type="button" className={outlineBtn} disabled={gecerliSecim.length === 0 || onayIslemde} onClick={() => void topluOnay(true)}>
                  {t("toplu.onaylaDugme")}
                </button>
                <button type="button" className={outlineBtn} disabled={gecerliSecim.length === 0 || onayIslemde} onClick={() => void topluOnay(false)}>
                  {t("toplu.onayKaldirDugme")}
                </button>
                <button type="button" className={primaryBtn} disabled={gecerliSecim.length === 0} onClick={() => setToplu("yayina_al")}>
                  {t("toplu.yayinaAlDugme")}
                </button>
                <button type="button" className={outlineBtn} disabled={gecerliSecim.length === 0} onClick={() => setToplu("yayindan_cek")}>
                  {t("toplu.yayindanCekDugme")}
                </button>
                <button type="button" className={outlineBtn} disabled={gecerliSecim.length === 0} onClick={() => setToplu("arsiv")}>
                  {t("toplu.arsivDugme")}
                </button>
                <button type="button" className={outlineBtn} disabled={gecerliSecim.length === 0} onClick={() => setToplu("sil")}>
                  {t("toplu.silDugme")}
                </button>
              </div>
              <div aria-live="polite" className="basis-full space-y-1">
                {onayMesaji && <p className="text-sm text-gray-700 dark:text-gray-300">{onayMesaji}</p>}
                <ErrorNote message={onayHatalari} />
              </div>
              <p className="basis-full text-theme-xs text-gray-500 dark:text-gray-400">{t("toplu.kural")}</p>
            </div>
          )}
          {gorunen.length === 0 ? (
            <p className="py-6 text-sm text-gray-600 dark:text-gray-300">{satirlar.length === 0 ? t("liste.bos") : t("liste.suzgecBos")}</p>
          ) : (
            <>
              {/* md altı: kart görünümü */}
              <ul className="space-y-3 md:hidden">
                {gorunen.map((s) => (
                  <li key={s.surum_id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                      <div className="flex min-w-0 items-start gap-1">
                        {secimKutusu(s)}
                        <p className="min-w-0 pt-3 font-medium wrap-break-word text-gray-800 dark:text-white/90">{s.baslik}</p>
                      </div>
                      <span className="text-theme-xs font-medium text-gray-700 dark:text-gray-300">{t(`durumlar.${s.durum}`)}</span>
                    </div>
                    <p className="text-theme-xs wrap-break-word text-gray-500 dark:text-gray-400">
                      {s.slug} · {t("detay.surum", { no: s.surum_no })}
                    </p>
                    <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-theme-sm">
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("liste.sinif")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{s.ana_sinif ?? "-"}</dd>
                      </div>
                      <div>
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("liste.deger")}</dt>
                        <dd className="text-gray-800 dark:text-white/90">{degerler(s)}</dd>
                      </div>
                      <div className="col-span-2">
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("liste.denetim")}</dt>
                        <dd>{denetimRozetleri(s)}</dd>
                      </div>
                      <div className="col-span-2">
                        <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("liste.tema")}</dt>
                        <dd className="wrap-break-word text-gray-800 dark:text-white/90">{etiketler(s)}</dd>
                      </div>
                    </dl>
                    <div className="mt-3 border-t border-gray-100 pt-2 dark:border-gray-800">
                      <button type="button" className={EYLEM_BTN} onClick={() => setSecili(s)}>
                        {t("liste.ac")}
                      </button>
                    </div>
                  </li>
                ))}
              </ul>

              {/* md ve üzeri: tablo kendi kapsayıcısında kayar */}
              <div className="hidden overflow-x-auto md:block">
                <table className="min-w-full text-left text-sm">
                  <thead>
                    <tr>
                      <th className={thClass}><span className="sr-only">{t("toplu.secKolon")}</span></th>
                      <th className={thClass}>{t("liste.kolonBaslik")}</th>
                      <th className={thClass}>{t("liste.durum")}</th>
                      <th className={thClass}>{t("liste.denetim")}</th>
                      <th className={thClass}>{t("liste.sinif")}</th>
                      <th className={thClass}>{t("liste.tema")}</th>
                      <th className={thClass}>{t("liste.deger")}</th>
                      <th className={thClass}>{t("liste.soru")}</th>
                      <th className={thClass}>{t("liste.oturum")}</th>
                      <th className={thClass}><span className="sr-only">{t("liste.islem")}</span></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {gorunen.map((s) => (
                      <tr key={s.surum_id}>
                        <td className={tdClass}>{secimKutusu(s)}</td>
                        <td className={`${tdClass} max-w-xs`}>
                          <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">{s.baslik}</p>
                          <p className="text-theme-xs text-gray-500 dark:text-gray-400">{s.slug} · {t("detay.surum", { no: s.surum_no })}</p>
                        </td>
                        <td className={tdClass}>{t(`durumlar.${s.durum}`)}</td>
                        <td className={`${tdClass} min-w-40`}>{denetimRozetleri(s)}</td>
                        <td className={tdClass}>{s.ana_sinif ?? "-"}</td>
                        <td className={`${tdClass} max-w-48 wrap-break-word`}>{etiketler(s)}</td>
                        <td className={tdClass}>{degerler(s)}</td>
                        <td className={tdClass}>{s.soru_sayisi ?? "-"}</td>
                        <td className={tdClass}>{s.oturum_sayisi ?? 0}</td>
                        <td className={tdClass}>
                          <button type="button" className={EYLEM_BTN} onClick={() => setSecili(s)}>
                            {t("liste.ac")}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </>
      )}

      {toplu && gecerliSecim.length > 0 && (
        <TopluIslemModal
          islem={toplu}
          hikayeler={gecerliSecim}
          onKapat={(degisti) => {
            setToplu(null);
            if (degisti) {
              setIsaretli(new Set());
              setSecili(null);
              liste.reload();
            }
          }}
        />
      )}

      {secili && (
        <SurumDetay key={secili.surum_id} satir={secili} onKapat={() => setSecili(null)} onDegisti={liste.reload} />
      )}
    </div>
  );
}
