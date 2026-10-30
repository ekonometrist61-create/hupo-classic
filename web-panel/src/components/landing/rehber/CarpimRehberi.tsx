"use client";

import LeadMagnetForm from "@/components/landing/LeadMagnetForm";
import { Link } from "@/i18n/navigation";
import { trackLandingEvent } from "@/lib/analytics/events";
import { CARPIM_MAGNET } from "@/lib/lead-magnet";
import { useTranslations } from "next-intl";
import { useEffect, useRef, useState } from "react";

// Pilot 1: form → aynı sayfada açılan rehber. Açıldı durumu yalnız bu sekmede (sessionStorage) tutulur;
// e-posta, ad veya kimlik tarayıcıda saklanmaz. Olaylarda kişisel veri yok (icerik, sinif).
const ACILDI_KEY = "hupo_lm_carpim_acildi";

const SATIRLAR = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

type Ornekli = { baslik: string; metin: string; ornek: string };
type ZorSatir = { carpim: string; ipucu: string };
type Soru = { soru: string; cevap: string };

const cardClass = "rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6";
const h2Class = "text-2xl font-extrabold tracking-tight text-navy";
const linkBtn =
  "inline-flex min-h-12 items-center justify-center rounded-xl px-6 py-3 text-base font-bold focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

export default function CarpimRehberi() {
  const t = useTranslations("landing.rehber");
  const [acik, setAcik] = useState(false);
  const [yeniAcildi, setYeniAcildi] = useState(false);
  const baslikRef = useRef<HTMLHeadingElement>(null);

  useEffect(() => {
    void trackLandingEvent("lead_magnet_goruntulendi", { icerik: CARPIM_MAGNET });
    try {
      if (window.sessionStorage.getItem(ACILDI_KEY) === "1") setAcik(true);
    } catch {
      // Depo kapalıysa form yeniden istenir.
    }
  }, []);

  // Yeni açılışta odak ve kaydırma içeriğin başlığına gider (ekran okuyucu için duyuru).
  useEffect(() => {
    if (acik && yeniAcildi) baslikRef.current?.focus();
  }, [acik, yeniAcildi]);

  function basarili({ sinif }: { leadId: string; sinif: number }) {
    try {
      window.sessionStorage.setItem(ACILDI_KEY, "1");
    } catch {
      // Depo yazılamazsa içerik bu görünümde açık kalır.
    }
    void trackLandingEvent("lead_magnet_istendi", { icerik: CARPIM_MAGNET, sinif });
    void trackLandingEvent("lead_magnet_icerik_acildi", { icerik: CARPIM_MAGNET });
    setYeniAcildi(true);
    setAcik(true);
  }

  if (!acik) {
    return (
      <section id="form" aria-labelledby="form-baslik" className={`${cardClass} scroll-mt-20`}>
        <h2 id="form-baslik" className={h2Class}>
          {t("form.baslik")}
        </h2>
        <p className="mt-2 mb-5 text-base leading-relaxed text-gray-600">{t("form.aciklama")}</p>
        <LeadMagnetForm magnet={CARPIM_MAGNET} onSuccess={basarili} />
      </section>
    );
  }

  const kurallar = t.raw("icerik.kurallar.ogeler") as Ornekli[];
  const zorKolonlar = t.raw("icerik.zor.kolonlar") as string[];
  const zorSatirlar = t.raw("icerik.zor.satirlar") as ZorSatir[];
  const sorular = t.raw("icerik.sinama.sorular") as Soru[];
  const gunler = t.raw("icerik.plan.gunler") as string[];
  const adimlar = t.raw("icerik.veliNotu.adimlar") as string[];

  return (
    <div className="space-y-8">
      <style>{`
        @media print {
          body * { visibility: hidden !important; }
          #yazdirilabilir-tablo, #yazdirilabilir-tablo * { visibility: visible !important; }
          #yazdirilabilir-tablo { position: absolute; left: 0; top: 0; width: 100%; padding: 12mm; }
          #yazdirilabilir-tablo table { width: 100%; border-collapse: collapse; font-size: 16pt; }
          #yazdirilabilir-tablo th, #yazdirilabilir-tablo td { border: 1px solid #000; padding: 6pt; text-align: center; }
          .yazdirma-gizle { display: none !important; }
        }
      `}</style>

      <section aria-labelledby="icerik-baslik" className={`${cardClass} border-brand-200`}>
        <h2
          id="icerik-baslik"
          ref={baslikRef}
          tabIndex={-1}
          className="text-2xl font-extrabold tracking-tight text-navy focus:outline-none"
        >
          {t("icerik.baslik")}
        </h2>
        <p role="status" className="mt-3 rounded-xl bg-brand-50 px-4 py-3 text-sm leading-relaxed text-brand-700">
          {t("icerik.durumNotu")}
        </p>
        <h3 className="mt-6 text-lg font-extrabold text-navy">{t("icerik.neden.baslik")}</h3>
        <p className="mt-2 text-base leading-relaxed text-gray-700">{t("icerik.neden.metin")}</p>
      </section>

      <section aria-labelledby="kurallar-baslik" className={cardClass}>
        <h2 id="kurallar-baslik" className={h2Class}>
          {t("icerik.kurallar.baslik")}
        </h2>
        <ul className="mt-4 grid gap-3 sm:grid-cols-2">
          {kurallar.map((k) => (
            <li key={k.baslik} className="rounded-xl bg-cream p-4">
              <p className="text-lg font-extrabold text-navy">{k.baslik}</p>
              <p className="mt-1 text-base leading-relaxed text-gray-700">{k.metin}</p>
              <p className="mt-2 text-sm font-semibold text-brand-700">
                {t("icerik.kurallar.ornek")}: {k.ornek}
              </p>
            </li>
          ))}
        </ul>
      </section>

      <section aria-labelledby="zor-baslik" className={cardClass}>
        <h2 id="zor-baslik" className={h2Class}>
          {t("icerik.zor.baslik")}
        </h2>
        <p className="mt-2 text-base leading-relaxed text-gray-700">{t("icerik.zor.aciklama")}</p>
        <div className="mt-4 overflow-x-auto">
          <table className="w-full min-w-[20rem] border-collapse text-left text-base">
            <thead>
              <tr className="border-b-2 border-gray-300">
                <th scope="col" className="py-2 pe-4 font-extrabold text-navy">{zorKolonlar[0]}</th>
                <th scope="col" className="py-2 font-extrabold text-navy">{zorKolonlar[1]}</th>
              </tr>
            </thead>
            <tbody>
              {zorSatirlar.map((s) => (
                <tr key={s.carpim} className="border-b border-gray-200 align-top">
                  <th scope="row" className="whitespace-nowrap py-2 pe-4 font-bold text-navy">{s.carpim}</th>
                  <td className="py-2 text-gray-700">{s.ipucu}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section aria-labelledby="tablo-baslik" className={cardClass}>
        <h2 id="tablo-baslik" className={h2Class}>
          {t("icerik.tablo.baslik")}
        </h2>
        <p className="mt-2 text-base leading-relaxed text-gray-700">{t("icerik.tablo.aciklama")}</p>
        <div id="yazdirilabilir-tablo" className="mt-4 overflow-x-auto">
          <p className="mb-2 hidden text-lg font-bold print:block">{t("icerik.tablo.baslikKaynak")}</p>
          <table className="w-full min-w-[22rem] border-collapse text-center text-base" aria-label={t("icerik.tablo.etiket")}>
            <thead>
              <tr>
                <th scope="col" className="border border-gray-300 bg-brand-50 p-1.5 text-navy">×</th>
                {SATIRLAR.map((n) => (
                  <th key={n} scope="col" className="border border-gray-300 bg-brand-50 p-1.5 font-extrabold text-navy">{n}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {SATIRLAR.map((a) => (
                <tr key={a}>
                  <th scope="row" className="border border-gray-300 bg-brand-50 p-1.5 font-extrabold text-navy">{a}</th>
                  {SATIRLAR.map((b) => (
                    <td key={b} className="border border-gray-300 p-1.5 tabular-nums text-gray-800">{a * b}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <button
          type="button"
          onClick={() => window.print()}
          className={`${linkBtn} mt-4 border-2 border-brand-500 bg-white text-brand-700 hover:bg-brand-50`}
        >
          {t("icerik.tablo.yazdir")}
        </button>
      </section>

      <section aria-labelledby="sinama-baslik" className={`${cardClass} yazdirma-gizle`}>
        <h2 id="sinama-baslik" className={h2Class}>
          {t("icerik.sinama.baslik")}
        </h2>
        <p className="mt-2 text-base text-gray-700">{t("icerik.sinama.aciklama")}</p>
        <ol className="mt-4 list-decimal space-y-4 ps-6">
          {sorular.map((s) => (
            <li key={s.soru} className="text-base leading-relaxed text-gray-800">
              {s.soru}
              <details className="mt-1">
                <summary className="inline-flex min-h-11 cursor-pointer items-center text-sm font-bold text-brand-700 underline">
                  {t("icerik.sinama.cevap")}
                </summary>
                <p className="mt-1 rounded-lg bg-cream px-3 py-2 text-base font-semibold text-navy">{s.cevap}</p>
              </details>
            </li>
          ))}
        </ol>
      </section>

      <section aria-labelledby="plan-baslik" className={`${cardClass} yazdirma-gizle`}>
        <h2 id="plan-baslik" className={h2Class}>
          {t("icerik.plan.baslik")}
        </h2>
        <p className="mt-2 text-base leading-relaxed text-gray-700">{t("icerik.plan.aciklama")}</p>
        <ol className="mt-4 space-y-3">
          {gunler.map((g, i) => (
            <li key={g} className="flex gap-3 rounded-xl bg-cream p-4">
              <span className="shrink-0 rounded-lg bg-brand-500 px-2.5 py-1 text-sm font-extrabold text-white">
                {t("icerik.plan.gun", { n: i + 1 })}
              </span>
              <span className="text-base leading-relaxed text-gray-800">{g}</span>
            </li>
          ))}
        </ol>
      </section>

      <section aria-labelledby="veli-baslik" className={`${cardClass} yazdirma-gizle`}>
        <h2 id="veli-baslik" className={h2Class}>
          {t("icerik.veliNotu.baslik")}
        </h2>
        <ol className="mt-4 list-decimal space-y-2 ps-6 text-base leading-relaxed text-gray-800">
          {adimlar.map((a) => (
            <li key={a}>{a}</li>
          ))}
        </ol>
      </section>

      <section aria-labelledby="bilim-baslik" className={`${cardClass} yazdirma-gizle`}>
        <h2 id="bilim-baslik" className={h2Class}>
          {t("icerik.bilim.baslik")}
        </h2>
        <p className="mt-2 text-base leading-relaxed text-gray-800">{t("icerik.bilim.metin")}</p>
        <p className="mt-2 text-sm text-gray-600">
          <a
            href="https://doi.org/10.1007/s10648-026-10225-5"
            target="_blank"
            rel="noopener noreferrer"
            className="font-semibold text-brand-700 underline"
          >
            {t("icerik.bilim.kaynak")}
          </a>
        </p>
        <p className="mt-2 text-sm italic text-gray-600">{t("icerik.bilim.dipnot")}</p>
      </section>

      <section aria-labelledby="sonraki-baslik" className={`${cardClass} yazdirma-gizle`}>
        <h2 id="sonraki-baslik" className={h2Class}>
          {t("icerik.sonraki.baslik")}
        </h2>
        <p className="mt-2 text-base leading-relaxed text-gray-700">{t("icerik.sonraki.metin")}</p>
        <div className="mt-4 flex flex-col gap-3 sm:flex-row">
          <Link href="/demo" className={`${linkBtn} bg-brand-500 text-white shadow-sm hover:bg-brand-600`}>
            {t("icerik.sonraki.demo")}
          </Link>
          <Link
            href="/veli-paneli/kayit"
            className={`${linkBtn} border-2 border-gray-300 bg-white text-navy hover:bg-gray-50`}
          >
            {t("icerik.sonraki.kayit")}
          </Link>
        </div>
      </section>
    </div>
  );
}
