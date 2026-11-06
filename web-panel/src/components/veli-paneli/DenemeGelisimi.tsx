"use client";

import { useLocale, useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import IstemciyeOzel from "@/components/common/IstemciyeOzel";
import { createClient } from "@/utils/supabase/client";

import ChartCard from "./ChartCard";
import { CHART_COLORS } from "./chartTheme";

// Deneme ve Gelişim (F4-b). Veri: get_child_exam_history (1–4. sınıfta puan ve sıra NULL, migration 20261138)
// ve get_upcoming_mock_exams_for_child (yalnız okunur; kayıt DenemeKaydiKarti'nda kalır).
// Kural: 1–4. sınıfta puan/sıra gösterilmez; sonuç doğru/yanlış/boş sayılarıyla anlatılır.
// Tanı, yeterlilik, sınıf kıyası ve sınav garantisi yoktur. Eşikler öneridir; pilot veriyle kalibre edilir.

interface DenemeSatiri {
  sinav_id: string;
  sinav_ad: string;
  tarih: string;
  sinif: number | null;
  puan: number | null;
  dogru: number;
  yanlis: number;
  bos: number | null;
}

interface YaklasanSinav {
  id: string;
  ad: string;
  baslangic_zamani: string;
  sure_dakika: number;
  kayitli: boolean;
}

interface ChartRow {
  label: string;
  ad: string;
  puan?: number;
  dogru?: number;
  yanlis?: number;
  bos?: number;
}

type YaklasanDurum = { durum: "yukleniyor" | "hata" | "bos" | "var"; sinav: YaklasanSinav | null };

// Öneri eşikleri (kalibre edilecek): son 3 denemede ortalama boş oranı.
const BOS_MIN_DENEME = 3;
const BOS_NOTU_ESIK = 0.2;
const BOS_IYI_ESIK = 0.1;

interface Props {
  cocukId: string;
}

export default function DenemeGelisimi({ cocukId }: Props) {
  const t = useTranslations("veliPaneli.denemeGelisim");
  const locale = useLocale();
  const numLocale = locale === "en" ? "en-US" : "tr-TR";

  const [satirlar, setSatirlar] = useState<DenemeSatiri[] | null>(null);
  const [hata, setHata] = useState(false);
  const [yaklasan, setYaklasan] = useState<YaklasanDurum>({ durum: "yukleniyor", sinav: null });

  useEffect(() => {
    let cancelled = false;
    const sb = createClient();

    sb.rpc("get_child_exam_history", { p_cocuk_id: cocukId }).then(
      ({ data, error }) => {
        if (cancelled) return;
        if (error || !Array.isArray(data)) {
          setHata(true);
          return;
        }
        setSatirlar(data as DenemeSatiri[]);
      },
      () => {
        if (!cancelled) setHata(true);
      },
    );

    sb.rpc("get_upcoming_mock_exams_for_child", { p_cocuk_id: cocukId }).then(
      ({ data, error }) => {
        if (cancelled) return;
        if (error || !Array.isArray(data)) {
          setYaklasan({ durum: "hata", sinav: null });
          return;
        }
        const simdi = Date.now();
        const gelecek = (data as YaklasanSinav[])
          .filter((s) => new Date(s.baslangic_zamani).getTime() > simdi)
          .sort((a, b) => new Date(a.baslangic_zamani).getTime() - new Date(b.baslangic_zamani).getTime());
        const ilk = gelecek[0] ?? null;
        setYaklasan(ilk ? { durum: "var", sinav: ilk } : { durum: "bos", sinav: null });
      },
      () => {
        if (!cancelled) setYaklasan({ durum: "hata", sinav: null });
      },
    );

    return () => {
      cancelled = true;
    };
  }, [cocukId]);

  const analiz = useMemo(() => {
    if (!satirlar) return null;
    const sirali = [...satirlar].sort(
      (a, b) => new Date(a.tarih).getTime() - new Date(b.tarih).getTime(),
    );
    const son = sirali[sirali.length - 1];
    // Puan modu yalnız son denemede puan geldiyse açılır (5+). Aksi halde sayı modu; puan hiç gösterilmez.
    const puanModu = son !== undefined && son.puan !== null;
    const seri = puanModu ? sirali.filter((r) => r.puan !== null) : sirali;

    const bosOranlari = sirali.flatMap((r) => {
      if (r.bos === null) return [];
      const toplam = r.dogru + r.yanlis + r.bos;
      return toplam > 0 ? [r.bos / toplam] : [];
    });
    const son3 = bosOranlari.slice(-BOS_MIN_DENEME);
    const bosOrtalama =
      son3.length >= BOS_MIN_DENEME ? son3.reduce((a, b) => a + b, 0) / son3.length : null;

    const chartRows: ChartRow[] = seri.map((r) => ({
      label: new Date(r.tarih).toLocaleDateString(numLocale, { day: "numeric", month: "short" }),
      ad: r.sinav_ad,
      ...(puanModu
        ? { puan: Number(r.puan) }
        : { dogru: r.dogru, yanlis: r.yanlis, bos: r.bos ?? 0 }),
    }));

    return { sirali, seri, puanModu, bosOrtalama, chartRows };
  }, [satirlar, numLocale]);

  const sayi = (n: number, digits = 0) => n.toLocaleString(numLocale, { maximumFractionDigits: digits });
  const fark = (n: number, digits = 0) =>
    n.toLocaleString(numLocale, { signDisplay: "exceptZero", maximumFractionDigits: digits });

  return (
    <section aria-labelledby="deneme-gelisim-baslik" className="min-w-0 space-y-4 md:space-y-6">
      <div>
        <h3 id="deneme-gelisim-baslik" className="text-lg font-semibold text-gray-800 dark:text-white/90">
          {t("title")}
        </h3>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{t("desc")}</p>
      </div>

      {/* 1. Deneme trendi */}
      {hata || analiz === null ? (
        <div className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 dark:border-gray-800 dark:bg-white/3">
          <p className={`text-sm ${hata ? "text-error-500" : "text-gray-500 dark:text-gray-400"}`} role={hata ? "alert" : undefined}>
            {hata ? t("error") : t("loading")}
          </p>
        </div>
      ) : (
        <ChartCard
          title={t("trend.title")}
          desc={analiz.puanModu ? t("trend.puanDesc") : t("trend.sayiDesc")}
          kaynak={t("kaynak")}
        >
          {analiz.sirali.length === 0 ? (
            <div className="rounded-xl bg-gray-50 px-4 py-8 text-center dark:bg-white/5">
              <p className="text-sm font-medium text-gray-800 dark:text-white/90">{t("trend.empty")}</p>
              <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">{t("trend.emptyNot")}</p>
            </div>
          ) : (
            <>
              <div aria-hidden="true" className="h-64 md:h-72">
                <IstemciyeOzel>
                  <ResponsiveContainer width="100%" height="100%" initialDimension={{ width: 640, height: 288 }}>
                    {analiz.puanModu ? (
                      <LineChart data={analiz.chartRows} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
                        <CartesianGrid vertical={false} stroke={CHART_COLORS.axis} strokeOpacity={0.25} />
                        <XAxis dataKey="label" tick={{ fill: CHART_COLORS.axis, fontSize: 12 }} axisLine={false} tickLine={false} />
                        <YAxis
                          domain={[0, 100]}
                          tick={{ fill: CHART_COLORS.axis, fontSize: 12 }}
                          axisLine={false}
                          tickLine={false}
                        />
                        <Tooltip content={<GelisimTooltip t={t} puanModu />} />
                        <Line
                          type="monotone"
                          dataKey="puan"
                          stroke={CHART_COLORS.brand}
                          strokeWidth={2.5}
                          dot={{ r: 4, fill: CHART_COLORS.brand }}
                          isAnimationActive={false}
                        />
                      </LineChart>
                    ) : (
                      <BarChart data={analiz.chartRows} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
                        <CartesianGrid vertical={false} stroke={CHART_COLORS.axis} strokeOpacity={0.25} />
                        <XAxis dataKey="label" tick={{ fill: CHART_COLORS.axis, fontSize: 12 }} axisLine={false} tickLine={false} />
                        <YAxis allowDecimals={false} tick={{ fill: CHART_COLORS.axis, fontSize: 12 }} axisLine={false} tickLine={false} />
                        <Tooltip
                          cursor={{ fill: CHART_COLORS.axis, fillOpacity: 0.12 }}
                          content={<GelisimTooltip t={t} puanModu={false} />}
                        />
                        <Legend wrapperStyle={{ fontSize: 12 }} />
                        <Bar dataKey="dogru" name={t("trend.dogru")} fill={CHART_COLORS.brand} radius={[4, 4, 0, 0]} maxBarSize={28} isAnimationActive={false} />
                        <Bar dataKey="yanlis" name={t("trend.yanlis")} fill={CHART_COLORS.warning} radius={[4, 4, 0, 0]} maxBarSize={28} isAnimationActive={false} />
                        <Bar dataKey="bos" name={t("trend.bos")} fill={CHART_COLORS.axis} radius={[4, 4, 0, 0]} maxBarSize={28} isAnimationActive={false} />
                      </BarChart>
                    )}
                  </ResponsiveContainer>
                </IstemciyeOzel>
              </div>

              {/* Grafiğin metinsel karşılığı: ekran okuyucu her denemeyi okur. */}
              <ul className="sr-only">
                {analiz.seri.map((r) => {
                  const tarih = new Date(r.tarih).toLocaleDateString(numLocale, { day: "numeric", month: "long", year: "numeric" });
                  return (
                    <li key={r.sinav_id}>
                      {analiz.puanModu
                        ? t("trend.srPuan", { ad: r.sinav_ad, tarih, puan: sayi(Number(r.puan), 1) })
                        : t("trend.srSayi", { ad: r.sinav_ad, tarih, dogru: r.dogru, yanlis: r.yanlis, bos: r.bos ?? 0 })}
                    </li>
                  );
                })}
              </ul>

              <p className="mt-3 text-theme-sm text-gray-600 dark:text-gray-300">
                {t("trend.ozet", { sayi: analiz.seri.length })}
                {analiz.seri.length < 2 && <> {t("trend.tekDeneme")}</>}
              </p>
            </>
          )}
        </ChartCard>
      )}

      <div className="grid gap-4 md:grid-cols-2 md:gap-6">
        {/* 2. İlk denemeden bugüne */}
        <Kart baslik={t("fark.title")}>
          {hata ? (
            <p role="alert" className="text-sm text-error-500">{t("error")}</p>
          ) : analiz === null ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
          ) : analiz.seri.length < 2 ? (
            <p className="text-sm text-gray-700 dark:text-gray-300">{t("fark.yetersiz")}</p>
          ) : (
            <FarkMetni analiz={analiz} t={t} fark={fark} sayi={sayi} />
          )}
        </Kart>

        {/* 3. Yanıtsız bırakma: tanı koymayan kısa not */}
        <Kart baslik={t("bos.title")}>
          {hata ? (
            <p role="alert" className="text-sm text-error-500">{t("error")}</p>
          ) : analiz === null ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
          ) : analiz.bosOrtalama === null ? (
            <p className="text-sm text-gray-700 dark:text-gray-300">{t("bos.yetersiz")}</p>
          ) : analiz.bosOrtalama >= BOS_NOTU_ESIK ? (
            <div className="space-y-2 text-sm text-gray-700 dark:text-gray-300">
              <p>{t("bos.notu", { oran: Math.round(analiz.bosOrtalama * 100) })}</p>
              <p className="text-gray-500 dark:text-gray-400">{t("bos.oneri")}</p>
            </div>
          ) : analiz.bosOrtalama < BOS_IYI_ESIK ? (
            <p className="text-sm text-gray-700 dark:text-gray-300">
              {t("bos.iyi", { oran: Math.round(analiz.bosOrtalama * 100) })}
            </p>
          ) : (
            <p className="text-sm text-gray-700 dark:text-gray-300">
              {t("bos.orta", { oran: Math.round(analiz.bosOrtalama * 100) })}
            </p>
          )}
        </Kart>

        {/* 4. Sonraki deneme (yalnız okunur) */}
        <Kart baslik={t("sonraki.title")}>
          {yaklasan.durum === "yukleniyor" ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("sonraki.yukleniyor")}</p>
          ) : yaklasan.durum === "hata" ? (
            <p role="alert" className="text-sm text-error-500">{t("sonraki.hata")}</p>
          ) : yaklasan.sinav === null ? (
            <p className="text-sm text-gray-700 dark:text-gray-300">{t("sonraki.yok")}</p>
          ) : (
            <div className="space-y-2 text-sm text-gray-700 dark:text-gray-300">
              <p className="font-medium text-gray-900 dark:text-white">{yaklasan.sinav.ad}</p>
              <p>
                {new Date(yaklasan.sinav.baslangic_zamani).toLocaleString(numLocale, {
                  dateStyle: "medium",
                  timeStyle: "short",
                })}{" "}
                · {t("sonraki.sure", { dk: yaklasan.sinav.sure_dakika })}
              </p>
              <p>{yaklasan.sinav.kayitli ? t("sonraki.kayitli") : t("sonraki.kayitsiz")}</p>
              <a
                href="#deneme-kaydi-baslik"
                className="inline-flex min-h-11 items-center text-sm font-medium text-brand-600 underline-offset-2 hover:underline dark:text-brand-400"
              >
                {t("sonraki.git")}
              </a>
              <p className="text-xs text-gray-500 dark:text-gray-400">{t("sonraki.not")}</p>
            </div>
          )}
        </Kart>
      </div>
    </section>
  );
}

function Kart({ baslik, children }: { baslik: string; children: React.ReactNode }) {
  return (
    <div className="min-w-0 rounded-2xl border border-gray-200 bg-white p-5 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <h4 className="mb-3 text-base font-semibold text-gray-800 dark:text-white/90">{baslik}</h4>
      {children}
    </div>
  );
}

interface Analiz {
  seri: DenemeSatiri[];
  puanModu: boolean;
}

function FarkMetni({
  analiz,
  t,
  fark,
  sayi,
}: {
  analiz: Analiz;
  t: ReturnType<typeof useTranslations>;
  fark: (n: number, digits?: number) => string;
  sayi: (n: number, digits?: number) => string;
}) {
  const { seri, puanModu } = analiz;
  const ilk = seri[0];
  const son = seri[seri.length - 1];
  const onceki = seri[seri.length - 2];
  const iki = seri.length === 2;

  return (
    <div className="space-y-2 text-sm text-gray-700 dark:text-gray-300">
      {puanModu ? (
        <p>
          {t("fark.puan", {
            ilk: sayi(Number(ilk.puan), 1),
            son: sayi(Number(son.puan), 1),
            fark: fark(Number(son.puan) - Number(ilk.puan), 1),
          })}
        </p>
      ) : (
        <>
          <p>
            {t("fark.sayi", {
              ilk: ilk.dogru,
              son: son.dogru,
              fark: fark(son.dogru - ilk.dogru),
            })}
          </p>
          <p>
            {son.dogru > onceki.dogru
              ? t("fark.artti")
              : son.dogru === onceki.dogru
                ? t("fark.ayni")
                : t("fark.azaldi")}
          </p>
        </>
      )}
      {iki && <p className="text-gray-500 dark:text-gray-400">{t("fark.iki")}</p>}
      <p className="text-gray-500 dark:text-gray-400">{t("fark.gozlem")}</p>
    </div>
  );
}

function GelisimTooltip({
  active,
  payload,
  t,
  puanModu,
}: {
  active?: boolean;
  payload?: { payload?: ChartRow }[];
  t: ReturnType<typeof useTranslations>;
  puanModu: boolean;
}) {
  const row = payload?.[0]?.payload;
  if (!active || !row) return null;
  return (
    <div className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-theme-sm shadow-theme-md dark:border-gray-700 dark:bg-gray-800">
      <p className="font-medium text-gray-800 dark:text-white/90">
        {row.ad} · {row.label}
      </p>
      {puanModu ? (
        <p className="text-gray-500 dark:text-gray-400">
          {t("trend.puan")}: {row.puan}
        </p>
      ) : (
        <p className="text-gray-500 dark:text-gray-400">
          {t("trend.dogru")}: {row.dogru} · {t("trend.yanlis")}: {row.yanlis} · {t("trend.bos")}: {row.bos}
        </p>
      )}
    </div>
  );
}
