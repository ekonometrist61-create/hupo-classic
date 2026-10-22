"use client";

// Genel istatistik panosu (yönetici verisi): yayındaki hikâye, oturum, tamamlama, doğruluk, okunan kelime,
// sınıf ve tür dağılımı. Öğrenci kimliği gelmez; min-N uygulanmaz (toplamlar yöneticiye açıktır).
import { useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { OKUMA_DURUMLARI } from "@/lib/okuma/okuma";
import { turEtiketi } from "@/lib/okuma/turler";
import { outlineBtn, tdClass, thClass } from "../panel/styles";
import { VeriDurumu } from "./ortak";
import type { DagilimSatiri, IstatistikYaniti } from "./tipler";

const sayi = new Intl.NumberFormat("tr-TR");
const yuzdeMetni = (d: number | null) => (d === null || d === undefined ? null : `%${new Intl.NumberFormat("tr-TR", { maximumFractionDigits: 1 }).format(d)}`);

function Olcu({ etiket, deger, not }: { etiket: string; deger: string; not?: string }) {
  return (
    <div className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{etiket}</dt>
      <dd className="mt-1 text-2xl font-semibold text-gray-800 dark:text-white/90">{deger}</dd>
      {not && <p className="mt-1 text-theme-xs text-gray-500 dark:text-gray-400">{not}</p>}
    </div>
  );
}

function Tablo({ baslik, ilkKolon, satirlar, ikinci, ucuncu }: {
  baslik: string;
  ilkKolon: string;
  satirlar: { ad: string; a: number; b?: number }[];
  ikinci: string;
  ucuncu?: string;
}) {
  const t = useTranslations("yonetim.hikayeAtolyesi.istatistik");
  return (
    <div>
      <h5 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">{baslik}</h5>
      {satirlar.length === 0 ? (
        <p className="text-sm text-gray-600 dark:text-gray-300">{t("veriYok")}</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm">
            <thead>
              <tr>
                <th className={thClass}>{ilkKolon}</th>
                <th className={thClass}>{ikinci}</th>
                {ucuncu && <th className={thClass}>{ucuncu}</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {satirlar.map((s) => (
                <tr key={s.ad}>
                  <td className={tdClass}>{s.ad}</td>
                  <td className={tdClass}>{sayi.format(s.a)}</td>
                  {ucuncu && <td className={tdClass}>{sayi.format(s.b ?? 0)}</td>}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default function IstatistikSekmesi() {
  const t = useTranslations("yonetim.hikayeAtolyesi");
  const ist = useAdminRpc<IstatistikYaniti>("okuma_yonetim_istatistik");
  const d = ist.data;

  const sinifAdi = (s: DagilimSatiri) => {
    const n = s.ana_sinif ?? s.sinif;
    return n === null || n === undefined ? t("istatistik.sinifBilinmiyor") : t("liste.sinifDeger", { n });
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="max-w-3xl text-sm text-gray-600 dark:text-gray-300">{t("istatistik.aciklama")}</p>
        <button type="button" className={outlineBtn} onClick={ist.reload}>
          {t("istatistik.yenile")}
        </button>
      </div>
      <VeriDurumu loading={ist.loading} error={ist.error} missing={ist.missing} onRetry={ist.reload} />
      {!ist.loading && !ist.error && !ist.missing && d && (
        <>
          <dl className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            <Olcu etiket={t("istatistik.yayindaHikaye")} deger={sayi.format(d.yayinda_hikaye)} />
            <Olcu etiket={t("istatistik.toplamOturum")} deger={sayi.format(d.toplam_oturum)} />
            <Olcu etiket={t("istatistik.tamamlananOturum")} deger={sayi.format(d.tamamlanan_oturum)} />
            <Olcu etiket={t("istatistik.tamamlamaOrani")} deger={yuzdeMetni(d.tamamlama_orani) ?? t("istatistik.gozlemYok")} not={t("istatistik.tamamlamaNotu")} />
            <Olcu etiket={t("istatistik.ortalamaDogruluk")} deger={yuzdeMetni(d.ortalama_dogruluk) ?? t("istatistik.gozlemYok")} not={t("istatistik.dogrulukNotu")} />
            <Olcu etiket={t("istatistik.okunanKelime")} deger={sayi.format(d.okunan_kelime)} not={t("istatistik.kelimeNotu")} />
          </dl>

          <div>
            <h5 className="mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">{t("istatistik.surumDurumlari")}</h5>
            <ul className="flex flex-wrap gap-2">
              {OKUMA_DURUMLARI.map((x) => (
                <li key={x} className="rounded-full border border-gray-200 px-3 py-1 text-theme-sm text-gray-700 dark:border-gray-800 dark:text-gray-300">
                  {t(`durumlar.${x}`)}: {sayi.format(d.surum_durumlari[x] ?? 0)}
                </li>
              ))}
            </ul>
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <Tablo
              baslik={t("istatistik.yayindaSinif")}
              ilkKolon={t("liste.sinif")}
              ikinci={t("istatistik.hikaye")}
              satirlar={d.yayinda_sinif_dagilimi.map((s) => ({ ad: sinifAdi(s), a: s.hikaye ?? 0 }))}
            />
            <Tablo
              baslik={t("istatistik.yayindaTur")}
              ilkKolon={t("istatistik.tur")}
              ikinci={t("istatistik.hikaye")}
              satirlar={d.yayinda_tur_dagilimi.map((s) => ({ ad: turEtiketi(s.tur), a: s.hikaye ?? 0 }))}
            />
            <Tablo
              baslik={t("istatistik.oturumSinif")}
              ilkKolon={t("liste.sinif")}
              ikinci={t("istatistik.oturum")}
              ucuncu={t("istatistik.tamamlanan")}
              satirlar={d.oturum_sinif_dagilimi.map((s) => ({ ad: sinifAdi(s), a: s.oturum ?? 0, b: s.tamamlanan ?? 0 }))}
            />
            <Tablo
              baslik={t("istatistik.oturumTur")}
              ilkKolon={t("istatistik.tur")}
              ikinci={t("istatistik.oturum")}
              ucuncu={t("istatistik.tamamlanan")}
              satirlar={d.oturum_tur_dagilimi.map((s) => ({ ad: turEtiketi(s.tur), a: s.oturum ?? 0, b: s.tamamlanan ?? 0 }))}
            />
          </div>
        </>
      )}
    </div>
  );
}