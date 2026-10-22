"use client";

// Anonim kullanım süresi raporu (yalnız admin). Veri kimliğe bağlı değildir; 5'ten az oturumlu satırlar
// sunucuda bastırılır. Kaynak: kullanim_raporu(p_gun, p_yuzey) — migration 20261066000000.
import { useState } from "react";
import { useLocale, useTranslations } from "next-intl";

import { useAdminRpc } from "@/components/yonetim/useAdminRpc";
import { cardClass, inputClass, labelClass, outlineBtn, tdClass, thClass } from "../panel/styles";

type Satir = { yuzey: string; ekran: string; toplam_sn: number; oturum: number; ortalama_sn: number };
type TrendSatiri = { gun: string; yuzey: string; toplam_sn: number; oturum: number };
type Rapor = { gun: number; yuzey: string | null; satirlar: Satir[]; trend: TrendSatiri[] };

const YUZEYLER = ["mobil", "flutter_web", "site", "yonetim", "veli", "ogretmen"] as const;
const GUNLER = [7, 30, 90, 300] as const;

export function sureMetni(sn: number): string {
  const toplam = Math.round(sn);
  if (toplam < 60) return `${toplam} sn`;
  const dk = Math.floor(toplam / 60);
  if (dk < 60) return `${dk} dk ${toplam % 60} sn`;
  return `${Math.floor(dk / 60)} sa ${dk % 60} dk`;
}

export default function KullanimRaporu() {
  const t = useTranslations("yonetim.kullanim");
  const locale = useLocale();
  const [gun, setGun] = useState<number>(30);
  const [yuzey, setYuzey] = useState<string>("");
  const rapor = useAdminRpc<Rapor>("kullanim_raporu", { p_gun: gun, p_yuzey: yuzey || null });
  const sayi = new Intl.NumberFormat(locale);
  const d = rapor.data;

  // Günlük trend: yüzeyler günde toplanır (yüzey bazında bastırılmış günler dışarıda kalır).
  const gunluk = new Map<string, number>();
  for (const x of d?.trend ?? []) gunluk.set(x.gun, (gunluk.get(x.gun) ?? 0) + x.toplam_sn);
  const gunler = [...gunluk.entries()].sort((a, b) => a[0].localeCompare(b[0]));
  const enCok = Math.max(1, ...gunler.map(([, v]) => v));

  return (
    <div className="space-y-6">
      <p className="max-w-3xl text-sm text-gray-600 dark:text-gray-300">{t("aciklama")}</p>

      <div className="flex flex-wrap items-end gap-4">
        <div>
          <label htmlFor="kullanim-gun" className={labelClass}>{t("donem")}</label>
          <select id="kullanim-gun" className={inputClass} value={gun} onChange={(e) => setGun(Number(e.target.value))}>
            {GUNLER.map((g) => (
              <option key={g} value={g}>{t("gunSecenek", { n: g })}</option>
            ))}
          </select>
        </div>
        <div>
          <label htmlFor="kullanim-yuzey" className={labelClass}>{t("yuzey")}</label>
          <select id="kullanim-yuzey" className={inputClass} value={yuzey} onChange={(e) => setYuzey(e.target.value)}>
            <option value="">{t("tumYuzeyler")}</option>
            {YUZEYLER.map((y) => (
              <option key={y} value={y}>{t(`yuzeyler.${y}`)}</option>
            ))}
          </select>
        </div>
        <button type="button" className={outlineBtn} onClick={rapor.reload}>{t("yenile")}</button>
      </div>

      {rapor.loading && <p className="text-sm text-gray-600 dark:text-gray-300" role="status">{t("yukleniyor")}</p>}
      {rapor.missing && <p className="text-sm text-gray-600 dark:text-gray-300">{t("kurulumYok")}</p>}
      {rapor.error && !rapor.missing && (
        <p className="text-sm text-error-600 dark:text-error-400" role="alert">{t("hata")}</p>
      )}

      {!rapor.loading && !rapor.error && !rapor.missing && d && (
        <>
          <section className={`${cardClass} p-4`}>
            <h2 className="mb-3 text-base font-semibold text-gray-800 dark:text-white/90">{t("trendBaslik")}</h2>
            {gunler.length === 0 ? (
              <p className="text-sm text-gray-600 dark:text-gray-300">{t("veriYok")}</p>
            ) : (
              <ul className="space-y-1.5">
                {gunler.map(([g, sn]) => (
                  <li key={g} className="flex items-center gap-3 text-theme-sm text-gray-700 dark:text-gray-300">
                    <span className="w-24 shrink-0 tabular-nums">{g}</span>
                    <span className="h-3 grow rounded bg-gray-100 dark:bg-white/5" aria-hidden="true">
                      <span className="block h-3 rounded bg-brand-500" style={{ width: `${Math.max(2, (sn / enCok) * 100)}%` }} />
                    </span>
                    <span className="w-28 shrink-0 text-end tabular-nums">{sureMetni(sn)}</span>
                  </li>
                ))}
              </ul>
            )}
          </section>

          <section className={`${cardClass} p-4`}>
            <h2 className="mb-3 text-base font-semibold text-gray-800 dark:text-white/90">{t("tabloBaslik")}</h2>
            {d.satirlar.length === 0 ? (
              <p className="text-sm text-gray-600 dark:text-gray-300">{t("veriYok")}</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full text-left text-sm">
                  <thead>
                    <tr>
                      <th className={thClass}>{t("yuzey")}</th>
                      <th className={thClass}>{t("ekran")}</th>
                      <th className={thClass}>{t("toplamSure")}</th>
                      <th className={thClass}>{t("oturum")}</th>
                      <th className={thClass}>{t("ortalamaSure")}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                    {d.satirlar.map((s) => (
                      <tr key={`${s.yuzey}|${s.ekran}`}>
                        <td className={tdClass}>{t(`yuzeyler.${s.yuzey}`)}</td>
                        <td className={`${tdClass} font-mono`}>{s.ekran}</td>
                        <td className={tdClass}>{sureMetni(s.toplam_sn)}</td>
                        <td className={tdClass}>{sayi.format(s.oturum)}</td>
                        <td className={tdClass}>{sureMetni(Number(s.ortalama_sn))}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
            <p className="mt-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("bastirmaNotu")}</p>
          </section>
        </>
      )}
    </div>
  );
}