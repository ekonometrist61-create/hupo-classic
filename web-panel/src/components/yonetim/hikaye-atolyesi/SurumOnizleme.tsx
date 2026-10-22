"use client";

// Önizleme: paket örnek adlarla çizilir. Ad, çocuktan gelmez; sabit örnek adlar kullanılır.
// Şablon yer tutucular (kelime yuvası, değer/hareket sahnesi, işaret) görünür etiket olarak gösterilir.
import { useTranslations } from "next-intl";

import type { Paket, Parca, Sahneler } from "./tipler";

// Hâl ekleri örnek adlara göre sabit (ünlü uyumu ve ünsüz benzeşmesi elle verilmiştir).
const KAHRAMAN = { yalin: "Deniz", belirtme: "Deniz'i", yonelme: "Deniz'e", bulunma: "Deniz'de", ayrilma: "Deniz'den", ilgi: "Deniz'in" } as const;
const YOLDAS = { yalin: "Elif", belirtme: "Elif'i", yonelme: "Elif'e", bulunma: "Elif'te", ayrilma: "Elif'ten", ilgi: "Elif'in" } as const;

type Hal = keyof typeof KAHRAMAN;
const halMi = (h: string | undefined): h is Hal => !!h && h in KAHRAMAN;

const YER_TUTUCU =
  "mx-0.5 inline-block rounded border border-dashed border-brand-300 bg-brand-50 px-1.5 text-theme-xs font-medium text-brand-700 dark:border-brand-700 dark:bg-brand-500/10 dark:text-brand-300";
const AD_ROZETI = "font-semibold text-gray-900 dark:text-white";

interface Baglam {
  paket: Paket;
  /** Sonsuz özyinelemeyi önler: sahne içinde sahne açılmaz. */
  derinlik: number;
}

function sahneParcalari(s: Sahneler | undefined, anahtar: string | undefined): Parca[] | null {
  if (!s || !anahtar) return null;
  return s[anahtar]?._default ?? null;
}

function ParcaCiz({ p, b, i }: { p: Parca; b: Baglam; i: number }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.onizleme");
  switch (p.t) {
    case "metin":
      return <>{p.v}</>;
    case "vurgu":
      return <strong className="font-semibold">{p.v}</strong>;
    case "kahraman":
      return <span className={AD_ROZETI}>{halMi(p.hal) ? KAHRAMAN[p.hal] : KAHRAMAN.yalin}</span>;
    case "yoldas":
      return <span className={AD_ROZETI}>{halMi(p.hal) ? YOLDAS[p.hal] : (p.yedek ?? YOLDAS.yalin)}</span>;
    case "ikon":
      return <span aria-hidden="true">{p.v}</span>;
    case "isaret":
      return <span className={YER_TUTUCU}>{t("isaret", { kod: p.kod ?? "" })}</span>;
    case "kelime":
    case "atasozu":
    case "deyim": {
      const cumle = p.t === "deyim" && b.derinlik < 1 ? b.paket.deyim_cumleleri?.[p.yuva ?? ""] : undefined;
      if (cumle) return <PartList parcalar={cumle} b={{ ...b, derinlik: b.derinlik + 1 }} anahtarOn={`d${i}`} />;
      return <span className={YER_TUTUCU}>{t(`yuva.${p.t}`, { yuva: p.yuva ?? "" })}</span>;
    }
    case "deger":
    case "hareket": {
      const kaynak = p.t === "deger" ? b.paket.deger_sahneleri : b.paket.hareket_sahneleri;
      const sahne = b.derinlik < 1 ? sahneParcalari(kaynak, p.anahtar) : null;
      if (sahne) {
        return (
          <span className="block rounded-lg bg-gray-50 px-3 py-2 dark:bg-white/5">
            <span className={YER_TUTUCU}>{t(`sahne.${p.t}`, { anahtar: p.anahtar ?? "" })}</span>{" "}
            <PartList parcalar={sahne} b={{ ...b, derinlik: b.derinlik + 1 }} anahtarOn={`s${i}`} />
          </span>
        );
      }
      return <span className={YER_TUTUCU}>{t(`sahne.${p.t}`, { anahtar: p.anahtar ?? "" })}</span>;
    }
    default:
      return <span className={YER_TUTUCU}>{t("bilinmeyen", { tur: p.t })}</span>;
  }
}

function PartList({ parcalar, b, anahtarOn }: { parcalar: Parca[]; b: Baglam; anahtarOn: string }) {
  return (
    <>
      {parcalar.map((p, i) => (
        <ParcaCiz key={`${anahtarOn}-${i}`} p={p} b={b} i={i} />
      ))}
    </>
  );
}

export default function SurumOnizleme({ paket, slug }: { paket: Paket; slug?: string }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.onizleme");
  const b: Baglam = { paket, derinlik: 0 };
  return (
    <div className="space-y-4">
      <p className="text-theme-xs text-gray-500 dark:text-gray-400">{t("not", { kahraman: KAHRAMAN.yalin, yoldas: YOLDAS.yalin })}</p>
      <h5 className="text-base font-semibold text-gray-800 dark:text-white/90">{paket.hikaye.baslik}</h5>
      <SahneGorseliBilgisi slug={slug ?? paket.hikaye.slug} />
      <ol className="space-y-3">
        {paket.sayfalar.map((s, idx) => (
          <li key={idx} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
            <p className="mb-1 text-theme-xs font-medium text-gray-500 dark:text-gray-400">
              {t("sayfa", { no: idx + 1 })}
              {s.omurga ? "" : ` · ${t("secenek")}`}
            </p>
            <p className="text-sm leading-relaxed wrap-break-word text-gray-800 dark:text-gray-200">
              <PartList parcalar={s.parcalar} b={b} anahtarOn={`p${idx}`} />
            </p>
          </li>
        ))}
      </ol>
      <div>
        <h5 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("sorular")}</h5>
        <ol className="space-y-3">
          {paket.sorular.map((q) => (
            <li key={q.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                {q.id} · {q.beceri} · {t("dayanak", { sayfa: q.dayanak_sayfa })}
              </p>
              <p className="mt-1 text-sm font-medium wrap-break-word text-gray-800 dark:text-white/90">{q.metin}</p>
              <ul className="mt-2 space-y-1 text-sm">
                {q.secenekler.map((o) => (
                  <li key={o.id} className="text-gray-700 dark:text-gray-300">
                    <span className="font-medium">{o.id}.</span> {o.metin}
                    {o.id === q.dogru ? (
                      <span className="ml-2 rounded bg-success-50 px-1.5 text-theme-xs font-medium text-success-700 dark:bg-success-500/15 dark:text-success-400">
                        {t("dogru")}
                      </span>
                    ) : null}
                  </li>
                ))}
              </ul>
              <p className="mt-2 text-theme-xs wrap-break-word text-gray-500 dark:text-gray-400">{q.aciklama}</p>
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
}

/** Yalnız bilgi: sahne görseli uygulama paketinde durur (sunucuda görsel alanı yok), panelden yüklenmez
 *  ve varlığı panelden denetlenemez. Dosya yoksa uygulama tür rengini kullanır. */
function SahneGorseliBilgisi({ slug }: { slug?: string }) {
  const t = useTranslations("yonetim.hikayeAtolyesi.onizleme");
  if (!slug) return null;
  return (
    <p className="rounded-lg bg-gray-50 px-3 py-2 text-theme-xs text-gray-600 dark:bg-white/5 dark:text-gray-300">
      <span className="font-semibold">{t("sahneGorseli")}:</span> <code className="break-all">{`assets/okuma/sahneler/${slug}.jpg`}</code>
      {" · "}
      {t("sahneGorseliNot")}
    </p>
  );
}