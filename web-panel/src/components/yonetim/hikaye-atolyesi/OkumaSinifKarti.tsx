"use client";

// Öğretmen sınıf raporuna okuma kartı: (1) sınıf toplamı, çocuk adı/kimliği yok; asgari 3 öğrenci altında değer
// gösterilmez ("gözlem yok"). (2) Öğrenci seçilince bireysel özet; sınıf bağı ve veli rızası sunucuda zorunludur,
// rıza yoksa özet gelmez. Min-N yalnız sınıf toplamlarında uygulanır.
import { useState } from "react";
import { useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import OkumaGelisimKartlari from "@/components/veli-paneli/okuma/OkumaGelisimKartlari";
import type { HedefSatiri, OkumaOzet } from "@/components/veli-paneli/okuma/okumaTipleri";
import { BECERILER } from "@/lib/okuma/okuma";
import { turEtiketi } from "@/lib/okuma/turler";
import { cardClass, inputClass, labelClass } from "../panel/styles";

interface Ozet {
  sinif: { id: string; ad: string; sinif_seviyesi: number };
  gun: number;
  ogrenci_sayisi: number;
  okuyan_ogrenci: number;
  yeterli: boolean;
  min_n: number;
  ozet: null | {
    oturum_sayisi: number;
    tamamlama_orani: number | null;
    soru_dogrulugu: Record<string, { yeterli: boolean; soru?: number; oran?: number }>;
    zorlanilan_hedefler: { hedef_id: string; etiket: string; yanlis_orani: number; ogrenci_sayisi: number }[];
    tema_ilgisi: { tema: string; ad: string | null; ogrenci_sayisi: number; hikaye_sayisi: number }[];
    okunan_kelime?: number;
    toplam_sure_dk?: number;
    tur_dagilimi?: { tur: string; ogrenci_sayisi: number; hikaye_sayisi: number; oturum: number }[];
    okunan_hikayeler?: { hikaye_id: string; baslik: string; tur: string; ogrenci_sayisi: number; oturum: number; dogru_orani: number | null }[];
    deger_dagilimi?: { deger: string; ad: string | null; ogrenci_sayisi: number; hikaye_sayisi: number }[];
    olcme_turu_dogrulugu?: Record<string, { yeterli: boolean; soru?: number; oran?: number }>;
    kavramlar?: SinifHedef[];
    atasozleri?: SinifHedef[];
    kelimeler?: SinifHedef[];
  };
}

interface SinifHedef extends Pick<HedefSatiri, "hedef_id" | "etiket" | "tur"> {
  ogrenci_sayisi: number;
  ogrenen_sayisi: number | null;
}

interface OgrenciListesi {
  ogrenciler: { id: string; ad: string; riza: boolean }[];
}

interface OgrenciYaniti {
  riza: boolean;
  riza_durumu: "yok" | "geri_cekildi" | "verildi";
  ogrenci?: { id: string; ad: string };
  ozet: OkumaOzet | null;
}

export default function OkumaSinifKarti({ siniflar }: { siniflar: { id: string; ad: string }[] }) {
  const [secili, setSecili] = useState(siniflar[0]?.id ?? "");
  if (siniflar.length === 0) return null;
  return <KartGovdesi siniflar={siniflar} secili={secili} onSec={setSecili} />;
}

function KartGovdesi({ siniflar, secili, onSec }: { siniflar: { id: string; ad: string }[]; secili: string; onSec: (id: string) => void }) {
  const t = useTranslations("yonetim.okumaSinif");
  const veri = useAdminRpc<Ozet>("okuma_ogretmen_sinif_ozeti", { p_sinif_id: secili, p_gun: 30 }, { enabled: secili !== "" });

  // Okuma modülü bu veritabanında kurulu değilse kart hiç görünmez (öğretmeni boş modülle şaşırtma).
  if (veri.missing) return null;

  return (
    <section aria-labelledby="okuma-sinif-b" className={`${cardClass} mt-6 p-5 sm:p-6`}>
      <h3 id="okuma-sinif-b" className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("baslik")}</h3>
      <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>

      {siniflar.length > 1 && (
        <div className="mt-4 max-w-sm">
          <label className={labelClass} htmlFor="okuma-sinif-sec">{t("sinif")}</label>
          <select id="okuma-sinif-sec" className={inputClass} value={secili} onChange={(e) => onSec(e.target.value)}>
            {siniflar.map((s) => (
              <option key={s.id} value={s.id}>{s.ad}</option>
            ))}
          </select>
        </div>
      )}

      {veri.loading && <p role="status" className="py-6 text-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>}
      {!veri.loading && veri.error && (
        <div className="py-4">
          <p role="alert" className="text-sm text-error-600 dark:text-error-500">{t("hata")}</p>
          <button type="button" className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400" onClick={veri.reload}>
            {t("tekrar")}
          </button>
        </div>
      )}

      {!veri.loading && !veri.error && veri.data && !veri.data.yeterli && (
        <p role="status" className="mt-4 rounded-lg bg-gray-50 px-3 py-2 text-sm text-gray-700 dark:bg-white/5 dark:text-gray-300">
          {t("yetersiz", { min: veri.data.min_n })}
        </p>
      )}

      {!veri.loading && !veri.error && veri.data?.yeterli && veri.data.ozet && <Govde d={veri.data} />}

      {!veri.loading && !veri.error && veri.data && <OgrenciBolumu key={secili} sinifId={secili} gun={veri.data.gun} />}
    </section>
  );
}

function Govde({ d }: { d: Ozet }) {
  const t = useTranslations("yonetim.okumaSinif");
  const tb = useTranslations("veliPaneli.okuma.beceri");
  const o = d.ozet!;
  return (
    <div className="mt-4 space-y-5">
      <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("aralik", { gun: d.gun })}</p>
      <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
        <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
          <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("oturum")}</p>
          <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{o.oturum_sayisi}</p>
        </div>
        <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
          <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("tamamlama")}</p>
          <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{o.tamamlama_orani === null ? t("gozlemYok") : `%${o.tamamlama_orani}`}</p>
        </div>
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("dogruluk")}</h4>
        <ul className="mt-2 grid gap-2 sm:grid-cols-2">
          {BECERILER.map((b) => {
            const x = o.soru_dogrulugu?.[b];
            return (
              <li key={b} className="flex items-baseline justify-between gap-3 rounded-lg border border-gray-200 px-3 py-2 text-sm dark:border-gray-800">
                <span className="text-gray-700 dark:text-gray-300">{tb(b)}</span>
                <span className="font-semibold text-gray-800 dark:text-white/90">{x?.yeterli && x.oran !== undefined ? `%${x.oran}` : t("gozlemYok")}</span>
              </li>
            );
          })}
        </ul>
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("zorlanilan")}</h4>
        {o.zorlanilan_hedefler.length === 0 ? (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("zorlanilanYok", { min: d.min_n })}</p>
        ) : (
          <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
            {o.zorlanilan_hedefler.map((h) => (
              <li key={h.hedef_id} className="flex flex-wrap items-baseline justify-between gap-2 py-2">
                <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">{h.etiket}</span>
                <span className="text-theme-xs text-gray-600 dark:text-gray-400">{t("hedefDeger", { oran: h.yanlis_orani, ogrenci: h.ogrenci_sayisi })}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("tema")}</h4>
        {o.tema_ilgisi.length === 0 ? (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("temaYok", { min: d.min_n })}</p>
        ) : (
          <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
            {o.tema_ilgisi.map((x) => (
              <li key={x.tema} className="flex flex-wrap items-baseline justify-between gap-2 py-2">
                <span className="text-gray-800 dark:text-gray-100">{x.ad ?? x.tema}</span>
                <span className="text-theme-xs text-gray-600 dark:text-gray-400">{t("temaDeger", { ogrenci: x.ogrenci_sayisi, hikaye: x.hikaye_sayisi })}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <SinifGelisim o={o} minN={d.min_n} />

      <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("not", { min: d.min_n })}</p>
    </div>
  );
}

function SinifHedefListesi({ baslik, bos, satirlar }: { baslik: string; bos: string; satirlar: SinifHedef[] | undefined }) {
  const t = useTranslations("yonetim.okumaSinif");
  const liste = satirlar ?? [];
  return (
    <div>
      <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{baslik}</h4>
      {liste.length === 0 ? (
        <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{bos}</p>
      ) : (
        <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
          {liste.map((h) => (
            <li key={h.hedef_id} className="flex flex-wrap items-baseline justify-between gap-2 py-2">
              <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">{h.etiket}</span>
              <span className="text-theme-xs text-gray-600 dark:text-gray-400">
                {h.ogrenen_sayisi === null ? t("hedefGorenSayisi", { ogrenci: h.ogrenci_sayisi }) : t("hedefOgrenenSayisi", { ogrenci: h.ogrenci_sayisi, ogrenen: h.ogrenen_sayisi })}
              </span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

// Sınıf toplamı: kelime sayısı, okunan hikâyeler, tür dağılımı, kavram/atasözü/sözcük, soru türü (hepsi min-N altında gizli)
function SinifGelisim({ o, minN }: { o: NonNullable<Ozet["ozet"]>; minN: number }) {
  const t = useTranslations("yonetim.okumaSinif");
  const tv = useTranslations("veliPaneli.okuma.yeni");
  const turler = o.tur_dagilimi ?? [];
  const hikayeler = o.okunan_hikayeler ?? [];
  const enTur = Math.max(1, ...turler.map((x) => x.oturum));
  return (
    <>
      {o.okunan_kelime !== undefined && (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
          <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
            <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("kelimeSayisi")}</p>
            <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{o.okunan_kelime.toLocaleString("tr-TR")}</p>
          </div>
          <div className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
            <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("toplamSure")}</p>
            <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{t("dk", { dk: o.toplam_sure_dk ?? 0 })}</p>
          </div>
        </div>
      )}

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("okunanHikayeler")}</h4>
        {hikayeler.length === 0 ? (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("okunanHikayelerYok", { min: minN })}</p>
        ) : (
          <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
            {hikayeler.map((h) => (
              <li key={h.hikaye_id} className="flex flex-wrap items-baseline justify-between gap-2 py-2">
                <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">
                  {h.baslik} <span className="text-theme-xs text-gray-600 dark:text-gray-400">{turEtiketi(h.tur)}</span>
                </span>
                <span className="text-theme-xs text-gray-600 dark:text-gray-400">
                  {t("hikayeDeger", { ogrenci: h.ogrenci_sayisi, oturum: h.oturum })}
                  {h.dogru_orani !== null ? ` · ${t("dogruOrani", { oran: h.dogru_orani })}` : ""}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("turDagilimi")}</h4>
        {turler.length === 0 ? (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{t("turYok", { min: minN })}</p>
        ) : (
          <ul className="mt-2 space-y-2">
            {turler.map((x) => (
              <li key={x.tur}>
                <div className="flex items-baseline justify-between gap-3 text-sm">
                  <span className="text-gray-800 dark:text-gray-100">{turEtiketi(x.tur)}</span>
                  <span className="text-theme-xs text-gray-600 dark:text-gray-400">{t("turDeger", { ogrenci: x.ogrenci_sayisi, oturum: x.oturum })}</span>
                </div>
                <div className="mt-1 h-1.5 rounded-full bg-gray-100 dark:bg-white/10" aria-hidden="true">
                  <div className="h-1.5 rounded-full bg-brand-500" style={{ width: `${(x.oturum / enTur) * 100}%` }} />
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div>
        <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{tv("olcmeBaslik")}</h4>
        <ul className="mt-2 grid gap-2 sm:grid-cols-3">
          {(["metin_kaniti", "kavram_dogrulugu", "transfer"] as const).map((k) => {
            const x = o.olcme_turu_dogrulugu?.[k];
            return (
              <li key={k} className="flex items-baseline justify-between gap-3 rounded-lg border border-gray-200 px-3 py-2 text-sm dark:border-gray-800">
                <span className="text-gray-700 dark:text-gray-300">{tv(`olcme.${k}`)}</span>
                <span className="font-semibold text-gray-800 dark:text-white/90">{x?.yeterli && x.oran !== undefined ? `%${x.oran}` : t("gozlemYok")}</span>
              </li>
            );
          })}
        </ul>
      </div>

      <SinifHedefListesi baslik={t("kavramlar")} bos={t("hedefYok", { min: minN })} satirlar={o.kavramlar} />
      <SinifHedefListesi baslik={t("atasozleri")} bos={t("hedefYok", { min: minN })} satirlar={o.atasozleri} />
      <SinifHedefListesi baslik={t("kelimeler")} bos={t("hedefYok", { min: minN })} satirlar={o.kelimeler} />
    </>
  );
}

// Öğrenci seçici + bireysel özet. Rıza ve sınıf bağı sunucuda zorunlu; rıza yoksa özet gelmez.
function OgrenciBolumu({ sinifId, gun }: { sinifId: string; gun: number }) {
  const t = useTranslations("yonetim.okumaSinif");
  const tb = useTranslations("veliPaneli.okuma.beceri");
  const tv = useTranslations("veliPaneli.okuma");
  const [ogrenciId, setOgrenciId] = useState("");
  const liste = useAdminRpc<OgrenciListesi>("okuma_ogretmen_sinif_ogrencileri", { p_sinif_id: sinifId });
  const ozet = useAdminRpc<OgrenciYaniti>(
    "okuma_ogretmen_ogrenci_ozeti",
    { p_sinif_id: sinifId, p_ogrenci_id: ogrenciId, p_gun: gun },
    { enabled: ogrenciId !== "" },
  );

  if (liste.missing || liste.loading) return null;
  const ogrenciler = liste.data?.ogrenciler ?? [];
  if (liste.error || ogrenciler.length === 0) return null;
  const o = ozet.data?.ozet ?? null;

  return (
    <div className="mt-8 border-t border-gray-100 pt-5 dark:border-gray-800">
      <h4 className="text-base font-semibold text-gray-800 dark:text-white/90">{t("ogrenciBaslik")}</h4>
      <p className="mt-1 text-theme-sm text-gray-600 dark:text-gray-300">{t("ogrenciAciklama")}</p>
      <div className="mt-3 max-w-sm">
        <label className={labelClass} htmlFor="okuma-ogrenci-sec">{t("ogrenciSec")}</label>
        <select id="okuma-ogrenci-sec" className={inputClass} value={ogrenciId} onChange={(e) => setOgrenciId(e.target.value)}>
          <option value="">{t("ogrenciSecin")}</option>
          {ogrenciler.map((x) => (
            <option key={x.id} value={x.id}>{x.ad || t("adsiz")}{x.riza ? "" : ` (${t("rizaYokKisa")})`}</option>
          ))}
        </select>
      </div>

      {ogrenciId !== "" && ozet.loading && <p role="status" className="py-4 text-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>}
      {ogrenciId !== "" && !ozet.loading && ozet.error && (
        <div className="py-3">
          <p role="alert" className="text-sm text-error-600 dark:text-error-500">{/FORBIDDEN/.test(ozet.error) ? t("ogrenciYetkisiz") : t("hata")}</p>
          <button type="button" className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-brand-600 hover:underline dark:text-brand-400" onClick={ozet.reload}>
            {t("tekrar")}
          </button>
        </div>
      )}
      {ogrenciId !== "" && !ozet.loading && !ozet.error && ozet.data && !ozet.data.riza && (
        <p role="status" className="mt-4 rounded-lg bg-warning-50 px-3 py-2 text-sm text-warning-800 dark:bg-warning-500/10 dark:text-warning-300">
          {ozet.data.riza_durumu === "geri_cekildi" ? t("rizaGeriCekildi") : t("rizaYok")}
        </p>
      )}
      {ogrenciId !== "" && !ozet.loading && !ozet.error && ozet.data?.riza && o && (
        <div className="mt-4 space-y-5">
          <p className="text-theme-xs text-gray-600 dark:text-gray-400">{t("aralik", { gun: o.gun })}</p>
          <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
            {[
              [t("okunanHikaye"), String(o.okunan_hikaye)],
              [t("tamamlananHikaye"), String(o.tamamlanan_hikaye)],
              [t("kelimeSayisi"), (o.okunan_kelime ?? 0).toLocaleString("tr-TR")],
              [t("toplamSure"), t("dk", { dk: o.toplam_sure_dk ?? 0 })],
            ].map(([etiket, deger]) => (
              <div key={etiket} className="rounded-xl border border-gray-200 p-3 dark:border-gray-800">
                <p className="text-theme-xs text-gray-600 dark:text-gray-400">{etiket}</p>
                <p className="text-xl font-semibold text-gray-800 dark:text-white/90">{deger}</p>
              </div>
            ))}
          </div>

          <div>
            <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{t("dogruluk")}</h4>
            <ul className="mt-2 grid gap-2 sm:grid-cols-2">
              {BECERILER.map((b) => {
                const x = o.soru_dogrulugu?.[b];
                return (
                  <li key={b} className="flex items-baseline justify-between gap-3 rounded-lg border border-gray-200 px-3 py-2 text-sm dark:border-gray-800">
                    <span className="text-gray-700 dark:text-gray-300">{tb(b)}</span>
                    <span className="font-semibold text-gray-800 dark:text-white/90">{x?.yeterli && x.oran !== undefined ? `%${x.oran}` : t("gozlemYok")}</span>
                  </li>
                );
              })}
            </ul>
          </div>

          <OkumaGelisimKartlari ozet={o} />

          <div className="grid gap-4 md:grid-cols-2">
            {(
              [
                ["deger_dagilimi", tv("deger.baslik"), "deger"],
                ["tema_dagilimi", tv("tema.baslik"), "tema"],
              ] as const
            ).map(([alan, baslik, anahtar]) => {
              const kalemler = (o[alan] ?? []) as { ad: string | null; hikaye: number; deger?: string; tema?: string }[];
              return (
                <div key={alan}>
                  <h4 className="text-sm font-semibold text-gray-800 dark:text-gray-100">{baslik}</h4>
                  {kalemler.length === 0 ? (
                    <p className="mt-1 text-sm text-gray-600 dark:text-gray-300">{tv(`${anahtar}.bos`)}</p>
                  ) : (
                    <ul className="mt-2 divide-y divide-gray-100 text-sm dark:divide-gray-800">
                      {kalemler.slice(0, 8).map((x) => (
                        <li key={x.ad ?? x.deger ?? x.tema} className="flex items-baseline justify-between gap-3 py-1.5">
                          <span className="min-w-0 wrap-break-word text-gray-800 dark:text-gray-100">{x.ad ?? x.deger ?? x.tema}</span>
                          <span className="shrink-0 text-theme-xs text-gray-600 dark:text-gray-400">{tv("hikayeAdedi", { sayi: x.hikaye })}</span>
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
