"use client";

import { useEffect, useMemo, useState } from "react";

import DesktopOnly from "@/components/ui/DesktopOnly";
import {
  CMS_AD_ALANLARI,
  METIN_MAKS_UZUNLUK,
  type MetinYaprak,
} from "@/lib/cms/icerik";
import { siteIcerikSatirlariniOku } from "@/lib/cms/icerik-veri";
import { createClient } from "@/utils/supabase/client";

import { cardClass, inputClass, labelClass, linkBtn, outlineBtn, primaryBtn } from "./styles";

type Dil = "tr" | "en";

const DILLER: { kod: Dil; etiket: string }[] = [
  { kod: "tr", etiket: "Türkçe" },
  { kod: "en", etiket: "English" },
];

const GOSTERIM_ADIMI = 60;

// Görseller: Supabase Storage'da herkese açık kova; yönetim dışından yazma RLS ile kapalı.
const GORSEL_KOVASI = "site-gorselleri";
const GORSEL_MAKS_BAYT = 2 * 1024 * 1024;
const GORSEL_TIPLERI: Record<string, string> = {
  "image/webp": "webp",
  "image/png": "png",
  "image/jpeg": "jpg",
  "image/svg+xml": "svg",
};

const textareaClass =
  "w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-base leading-relaxed text-gray-800 md:text-sm shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-3 focus:ring-brand-500/10 dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:focus:border-brand-800";

type Bildirim = { tip: "ok" | "hata"; metin: string } | null;

/** Sayfa, dil değişince yeniden açılır (key ile); böylece yükleme durumu her dil için temiz başlar. */
export default function SiteIcerikManager({
  varsayilanlar,
}: {
  varsayilanlar: Record<Dil, MetinYaprak[]>;
}) {
  const [dil, setDil] = useState<Dil>("tr");
  // Site metinleri yazma ekranıdır; telefonda yalnızca bilgi notu görünür (TASKS §20, K3).
  return (
    <DesktopOnly>
      <div className="space-y-5">
        <div className="flex flex-wrap gap-2">
          {DILLER.map((d) => (
            <button
              key={d.kod}
              type="button"
              onClick={() => setDil(d.kod)}
              className={
                dil === d.kod
                  ? "inline-flex min-h-11 items-center rounded-lg bg-brand-500 px-4 py-2 text-sm font-medium text-white"
                  : "inline-flex min-h-11 items-center rounded-lg px-4 py-2 text-sm font-medium text-gray-700 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:text-gray-400 dark:ring-gray-700"
              }
            >
              {d.etiket}
            </button>
          ))}
        </div>
        <Editor key={dil} dil={dil} varsayilanlar={varsayilanlar[dil]} />
      </div>
    </DesktopOnly>
  );
}

function Editor({ dil, varsayilanlar }: { dil: Dil; varsayilanlar: MetinYaprak[] }) {
  const [ad, setAd] = useState<string>(CMS_AD_ALANLARI[0]);
  const [arama, setArama] = useState("");
  const [yalnizOzel, setYalnizOzel] = useState(false);
  const [gosterilen, setGosterilen] = useState(GOSTERIM_ADIMI);

  // Veritabanındaki özel metinler: anahtar → metin. null = henüz yüklenmedi.
  const [ozel, setOzel] = useState<Record<string, string> | null>(null);
  const [yuklemeHatasi, setYuklemeHatasi] = useState<string | null>(null);
  // Kaydedilmemiş taslaklar: anahtar → metin.
  const [taslak, setTaslak] = useState<Record<string, string>>({});
  const [mesgul, setMesgul] = useState<string | null>(null);
  const [bildirim, setBildirim] = useState<Bildirim>(null);

  useEffect(() => {
    let iptal = false;
    siteIcerikSatirlariniOku(createClient(), dil)
      .then((satirlar) => {
        if (iptal) return;
        setOzel(Object.fromEntries(satirlar.map((s) => [s.anahtar, s.deger])));
      })
      .catch((hata: unknown) => {
        if (iptal) return;
        setYuklemeHatasi(hata instanceof Error ? hata.message : "Metinler yüklenemedi.");
      });
    return () => {
      iptal = true;
    };
  }, [dil]);

  const adSayilari = useMemo(() => {
    const sayac: Record<string, number> = {};
    for (const y of varsayilanlar) {
      const n = y.anahtar.split(".")[0];
      sayac[n] = (sayac[n] ?? 0) + 1;
    }
    return sayac;
  }, [varsayilanlar]);

  const ozelSayisi = ozel ? Object.keys(ozel).length : 0;

  const liste = useMemo(() => {
    const q = arama.trim().toLocaleLowerCase("tr-TR");
    return varsayilanlar.filter((y) => {
      if (!y.anahtar.startsWith(ad + ".")) return false;
      const ozelMi = ozel?.[y.anahtar] !== undefined;
      if (yalnizOzel && !ozelMi) return false;
      if (!q) return true;
      const aktif = (ozel?.[y.anahtar] ?? y.varsayilan).toLocaleLowerCase("tr-TR");
      return (
        y.anahtar.toLocaleLowerCase("tr-TR").includes(q) ||
        y.varsayilan.toLocaleLowerCase("tr-TR").includes(q) ||
        aktif.includes(q)
      );
    });
  }, [varsayilanlar, ad, arama, yalnizOzel, ozel]);

  const kaydet = (y: MetinYaprak) => kaydetDeger(y, taslak[y.anahtar] ?? "");

  /** Görsel yükler; yayın adresi değer olarak kaydedilir. Dosya Supabase Storage'a (site-gorselleri) gider. */
  const gorselYukle = async (y: MetinYaprak, dosya: File, damga: number) => {
    const uzanti = GORSEL_TIPLERI[dosya.type];
    if (!uzanti) {
      setBildirim({ tip: "hata", metin: "Yalnızca WebP, PNG, JPG veya SVG yükleyebilirsiniz." });
      return;
    }
    if (dosya.size > GORSEL_MAKS_BAYT) {
      setBildirim({ tip: "hata", metin: "Görsel en fazla 2 MB olabilir." });
      return;
    }
    setMesgul(y.anahtar);
    setBildirim(null);
    const istemci = createClient();
    const yol = `${dil}/${y.anahtar.replaceAll(".", "/")}-${damga}.${uzanti}`;
    const yukleme = await istemci.storage
      .from(GORSEL_KOVASI)
      .upload(yol, dosya, { contentType: dosya.type, cacheControl: "31536000" });
    if (yukleme.error) {
      setMesgul(null);
      setBildirim({ tip: "hata", metin: `Görsel yüklenemedi (${yukleme.error.message}).` });
      return;
    }
    const adres = istemci.storage.from(GORSEL_KOVASI).getPublicUrl(yol).data.publicUrl;
    setMesgul(null);
    await kaydetDeger(y, adres);
  };

  const kaydetDeger = async (y: MetinYaprak, ham: string) => {
    const metin = ham.trim();
    if (metin === "") {
      setBildirim({ tip: "hata", metin: "Metin boş olamaz. Varsayılan metne dönmek için 'Varsayılana dön' kullanın." });
      return;
    }
    if (metin.length > METIN_MAKS_UZUNLUK) {
      setBildirim({ tip: "hata", metin: `Metin en fazla ${METIN_MAKS_UZUNLUK} karakter olabilir.` });
      return;
    }

    setMesgul(y.anahtar);
    setBildirim(null);
    const istemci = createClient();
    // Varsayılanla aynı metin: özel satır tutmaya gerek yok, satırı kaldır.
    const sonuc =
      metin === y.varsayilan.trim()
        ? await istemci.from("site_icerik").delete().eq("anahtar", y.anahtar).eq("dil", dil)
        : await istemci
            .from("site_icerik")
            .upsert({ anahtar: y.anahtar, dil, deger: metin }, { onConflict: "anahtar,dil" });
    setMesgul(null);

    if (sonuc.error) {
      setBildirim({ tip: "hata", metin: `Kaydedilemedi (${sonuc.error.code ?? "hata"}). Tekrar deneyin.` });
      return;
    }
    setOzel((onceki) => {
      const sonraki = { ...(onceki ?? {}) };
      if (metin === y.varsayilan.trim()) delete sonraki[y.anahtar];
      else sonraki[y.anahtar] = metin;
      return sonraki;
    });
    setTaslak((onceki) => {
      const sonraki = { ...onceki };
      delete sonraki[y.anahtar];
      return sonraki;
    });
    setBildirim({ tip: "ok", metin: "Kaydedildi. Site en geç bir dakika içinde güncellenir." });
  };

  const varsayilanaDon = async (y: MetinYaprak) => {
    setMesgul(y.anahtar);
    setBildirim(null);
    const sonuc = await createClient()
      .from("site_icerik")
      .delete()
      .eq("anahtar", y.anahtar)
      .eq("dil", dil);
    setMesgul(null);
    if (sonuc.error) {
      setBildirim({ tip: "hata", metin: `Geri alınamadı (${sonuc.error.code ?? "hata"}).` });
      return;
    }
    setOzel((onceki) => {
      const sonraki = { ...(onceki ?? {}) };
      delete sonraki[y.anahtar];
      return sonraki;
    });
    setTaslak((onceki) => {
      const sonraki = { ...onceki };
      delete sonraki[y.anahtar];
      return sonraki;
    });
    setBildirim({ tip: "ok", metin: "Varsayılan metne dönüldü." });
  };

  if (yuklemeHatasi) {
    return (
      <div className="rounded-lg border border-error-200 bg-error-50 p-4 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400">
        Site metinleri yüklenemedi: {yuklemeHatasi}
      </div>
    );
  }

  const gosterilecek = liste.slice(0, gosterilen);

  return (
    <div className="space-y-5">
      <div className={`${cardClass} space-y-2 p-4 text-sm text-gray-600 dark:text-gray-400`}>
        <p>
          Herkese açık sitedeki metinler burada düzenlenir. Değiştirdiğiniz metin, satır bazında
          varsayılan metnin yerine geçer. Yayın gecikmesi en fazla bir dakikadır.
        </p>
        <p>
          Bu dil için {ozel === null ? "…" : ozelSayisi} metin özelleştirildi.
          {" "}Yönetim paneli metinleri bu ekranın kapsamında değildir.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-[minmax(0,220px)_1fr_auto] md:items-end">
        <div>
          <label className={labelClass} htmlFor="cms-ad-alani">Bölüm</label>
          <select
            id="cms-ad-alani"
            className={inputClass}
            value={ad}
            onChange={(e) => {
              setAd(e.target.value);
              setGosterilen(GOSTERIM_ADIMI);
            }}
          >
            {CMS_AD_ALANLARI.map((n) => (
              <option key={n} value={n}>
                {n} ({adSayilari[n] ?? 0})
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className={labelClass} htmlFor="cms-arama">Ara</label>
          <input
            id="cms-arama"
            className={inputClass}
            placeholder="Anahtar veya metin ara…"
            value={arama}
            onChange={(e) => {
              setArama(e.target.value);
              setGosterilen(GOSTERIM_ADIMI);
            }}
          />
        </div>
        <label className="flex h-11 items-center gap-2 text-sm text-gray-700 dark:text-gray-400">
          <input
            type="checkbox"
            checked={yalnizOzel}
            onChange={(e) => setYalnizOzel(e.target.checked)}
          />
          Yalnızca özelleştirilenler
        </label>
      </div>

      {bildirim && (
        <div
          role="status"
          className={
            bildirim.tip === "ok"
              ? "rounded-lg border border-success-200 bg-success-50 p-3 text-sm text-success-700 dark:border-success-500/30 dark:bg-success-500/10 dark:text-success-400"
              : "rounded-lg border border-error-200 bg-error-50 p-3 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400"
          }
        >
          {bildirim.metin}
        </div>
      )}

      {ozel === null ? (
        <p className="text-sm text-gray-500">Metinler yükleniyor…</p>
      ) : liste.length === 0 ? (
        <p className="text-sm text-gray-500">Bu filtreyle eşleşen metin yok.</p>
      ) : (
        <div className="space-y-3">
          {gosterilecek.map((y) => {
            const ozelMi = ozel[y.anahtar] !== undefined;
            const kayitli = ozel[y.anahtar] ?? y.varsayilan;
            const deger = taslak[y.anahtar] ?? kayitli;
            const degisti = taslak[y.anahtar] !== undefined && deger !== kayitli;
            const mesgulMu = mesgul === y.anahtar;
            return (
              <div key={y.anahtar} className={`${cardClass} p-4`}>
                <div className="mb-2 flex flex-wrap items-center justify-between gap-2">
                  <code className="text-xs break-all text-gray-500 dark:text-gray-400">{y.anahtar}</code>
                  <span
                    className={
                      ozelMi
                        ? "rounded-full bg-brand-50 px-2.5 py-0.5 text-xs font-medium text-brand-600 dark:bg-brand-500/15 dark:text-brand-400"
                        : "rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-500 dark:bg-white/5 dark:text-gray-400"
                    }
                  >
                    {ozelMi ? "Özel metin" : "Varsayılan"}
                  </span>
                </div>
                <textarea
                  className={textareaClass}
                  rows={Math.min(6, Math.max(2, Math.ceil(deger.length / 90)))}
                  maxLength={METIN_MAKS_UZUNLUK}
                  aria-label={y.anahtar}
                  value={deger}
                  disabled={mesgulMu}
                  onChange={(e) =>
                    setTaslak((onceki) => ({ ...onceki, [y.anahtar]: e.target.value }))
                  }
                />
                {ad === "gorseller" && (
                  <div className="mt-3 flex flex-wrap items-center gap-3">
                    {/* eslint-disable-next-line @next/next/no-img-element -- yönetim önizlemesi; URL çalışma anında belirlenir */}
                    <img src={deger} alt="" className="h-16 w-16 rounded-lg border border-gray-200 bg-gray-50 object-contain dark:border-gray-700 dark:bg-white/5" />
                    <label className={`${outlineBtn} cursor-pointer ${mesgulMu ? "pointer-events-none opacity-50" : ""}`}>
                      Görsel yükle
                      <input
                        type="file"
                        accept="image/webp,image/png,image/jpeg,image/svg+xml"
                        className="sr-only"
                        disabled={mesgulMu}
                        onChange={(e) => {
                          const dosya = e.target.files?.[0];
                          e.target.value = "";
                          if (dosya) void gorselYukle(y, dosya, Date.now());
                        }}
                      />
                    </label>
                    <span className="text-xs text-gray-400">En fazla 2 MB · Görseller dile göre ayrı kaydedilir.</span>
                  </div>
                )}
                {(ozelMi || degisti) && (
                  <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                    Varsayılan: <span className="italic">{y.varsayilan}</span>
                  </p>
                )}
                <div className="mt-3 flex flex-wrap items-center gap-3">
                  <button
                    type="button"
                    className={primaryBtn}
                    disabled={!degisti || mesgulMu}
                    onClick={() => kaydet(y)}
                  >
                    {mesgulMu ? "Kaydediliyor…" : "Kaydet"}
                  </button>
                  {ozelMi && (
                    <button
                      type="button"
                      className={outlineBtn}
                      disabled={mesgulMu}
                      onClick={() => varsayilanaDon(y)}
                    >
                      Varsayılana dön
                    </button>
                  )}
                  {degisti && (
                    <button
                      type="button"
                      className={`${linkBtn} inline-flex min-h-11 items-center`}
                      onClick={() =>
                        setTaslak((onceki) => {
                          const sonraki = { ...onceki };
                          delete sonraki[y.anahtar];
                          return sonraki;
                        })
                      }
                    >
                      Vazgeç
                    </button>
                  )}
                  <span className="ms-auto text-xs text-gray-400">
                    {deger.length} / {METIN_MAKS_UZUNLUK}
                  </span>
                </div>
              </div>
            );
          })}
          {gosterilen < liste.length && (
            <button
              type="button"
              className={outlineBtn}
              onClick={() => setGosterilen((g) => g + GOSTERIM_ADIMI)}
            >
              Daha fazla göster ({liste.length - gosterilen} kaldı)
            </button>
          )}
        </div>
      )}
    </div>
  );
}
