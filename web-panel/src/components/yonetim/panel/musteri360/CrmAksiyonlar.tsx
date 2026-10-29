"use client";

import { useId, useState, type FormEvent, type ReactNode } from "react";
import { useTranslations } from "next-intl";

import { formatDateTime } from "@/utils/format";
import type { GrowthTaskList } from "../../types";
import { useAdminRpc, type RpcState } from "../../useAdminRpc";
import ErrorNote from "../ErrorNote";
import { inputClass, labelClass, primaryBtn, tdClass, thClass } from "../styles";
import { AksiyonBildirim, Kart, metinAlaniClass, useAdminAksiyon } from "./aksiyon";

const NOT_TURLERI = ["note", "call", "meeting", "support"] as const;
const GOREV_TURLERI = ["call", "email", "meeting", "follow_up", "demo", "proposal", "other"] as const;
const GOREV_ONCELIKLERI = ["low", "normal", "high", "urgent"] as const;
const DESTEK_KATEGORILERI = ["billing", "technical", "account", "content", "subscription", "other"] as const;
const DESTEK_ONCELIKLERI = ["low", "normal", "high", "critical"] as const;

type NotTuru = (typeof NOT_TURLERI)[number];
type GorevTuru = (typeof GOREV_TURLERI)[number];
type GorevOncelik = (typeof GOREV_ONCELIKLERI)[number];
type DestekKategori = (typeof DESTEK_KATEGORILERI)[number];
type DestekOncelik = (typeof DESTEK_ONCELIKLERI)[number];

/** Müşteri 360 CRM sekmesi: not, görev ve destek kaydı. Her kayıttan sonra sekme yenilenir. */
export default function CrmAksiyonlar({ householdId, onChanged }: { householdId: string; onChanged: () => void }) {
  const gorevler = useAdminRpc<GrowthTaskList>("admin_crm_gorev_listele", {
    p_household_id: householdId,
    p_lead_id: null,
    p_status: null,
    p_limit: 25,
    p_offset: 0,
  });

  const gorevKaydedildi = () => {
    gorevler.reload();
    onChanged();
  };

  return (
    <>
      <NotFormu householdId={householdId} onKaydedildi={onChanged} />
      <GorevFormu householdId={householdId} onKaydedildi={gorevKaydedildi} />
      <GorevListesi gorevler={gorevler} />
      <DestekFormu householdId={householdId} onKaydedildi={onChanged} />
    </>
  );
}

function NotFormu({ householdId, onKaydedildi }: { householdId: string; onKaydedildi: () => void }) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const { busy, hata, basari, setHata, setBasari, calistir } = useAdminAksiyon();
  const alanId = useId();
  const [tur, setTur] = useState<NotTuru>("note");
  const [icerik, setIcerik] = useState("");

  const gonder = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const metin = icerik.trim();
    if (metin.length < 1 || metin.length > 4000) {
      setBasari(null);
      setHata(t("not.hataIcerik"));
      return;
    }
    const sonuc = await calistir("admin_ekip_akisi_ekle", {
      p_data: { household_id: householdId, entry_type: tur, content: metin },
    });
    if (!sonuc) return;
    setIcerik("");
    setBasari(t("not.basarili"));
    onKaydedildi();
  };

  return (
    <Kart baslik={t("not.baslik")}>
      <form onSubmit={gonder} noValidate className="space-y-4">
        <div>
          <label htmlFor={`${alanId}-tur`} className={labelClass}>{t("not.tur")}</label>
          <select
            id={`${alanId}-tur`}
            className={inputClass}
            value={tur}
            disabled={busy}
            onChange={(e) => setTur(e.target.value as NotTuru)}
          >
            {NOT_TURLERI.map((v) => (
              <option key={v} value={v}>{t(`not.tipler.${v}`)}</option>
            ))}
          </select>
        </div>
        <div>
          <label htmlFor={`${alanId}-icerik`} className={labelClass}>{t("not.icerik")}</label>
          <textarea
            id={`${alanId}-icerik`}
            rows={3}
            maxLength={4000}
            className={metinAlaniClass}
            value={icerik}
            disabled={busy}
            onChange={(e) => setIcerik(e.target.value)}
          />
        </div>
        <AksiyonBildirim hata={hata} basari={basari} />
        <div>
          <button type="submit" className={primaryBtn} disabled={busy}>
            {busy ? t("kaydediliyor") : t("not.ekle")}
          </button>
        </div>
      </form>
    </Kart>
  );
}

function GorevFormu({ householdId, onKaydedildi }: { householdId: string; onKaydedildi: () => void }) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const tGorev = useTranslations("yonetim.crmGorevler");
  const { busy, hata, basari, setHata, setBasari, calistir } = useAdminAksiyon();
  const alanId = useId();
  const [baslik, setBaslik] = useState("");
  const [tur, setTur] = useState<GorevTuru>("follow_up");
  const [oncelik, setOncelik] = useState<GorevOncelik>("normal");
  const [bitis, setBitis] = useState("");

  const gonder = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const metin = baslik.trim();
    if (metin.length < 1 || metin.length > 200) {
      setBasari(null);
      setHata(t("gorev.hataBaslik"));
      return;
    }
    const bitisTarihi = new Date(bitis);
    if (!bitis || Number.isNaN(bitisTarihi.getTime())) {
      setBasari(null);
      setHata(t("gorev.hataBitis"));
      return;
    }
    const sonuc = await calistir("admin_crm_gorev_kaydet", {
      p_data: {
        title: metin,
        task_type: tur,
        priority: oncelik,
        status: "open",
        due_at: bitisTarihi.toISOString(),
        household_id: householdId,
      },
    });
    if (!sonuc) return;
    setBaslik("");
    setBitis("");
    setBasari(t("gorev.basarili"));
    onKaydedildi();
  };

  return (
    <Kart baslik={t("gorev.baslik")}>
      <form onSubmit={gonder} noValidate className="space-y-4">
        <div>
          <label htmlFor={`${alanId}-baslik`} className={labelClass}>{t("gorev.gorevBaslik")}</label>
          <input
            id={`${alanId}-baslik`}
            type="text"
            maxLength={200}
            className={inputClass}
            value={baslik}
            disabled={busy}
            onChange={(e) => setBaslik(e.target.value)}
          />
        </div>
        <div className="grid gap-4 sm:grid-cols-3">
          <div>
            <label htmlFor={`${alanId}-tur`} className={labelClass}>{t("gorev.tur")}</label>
            <select id={`${alanId}-tur`} className={inputClass} value={tur} disabled={busy} onChange={(e) => setTur(e.target.value as GorevTuru)}>
              {GOREV_TURLERI.map((v) => (
                <option key={v} value={v}>{tGorev(`types.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor={`${alanId}-oncelik`} className={labelClass}>{t("gorev.oncelik")}</label>
            <select id={`${alanId}-oncelik`} className={inputClass} value={oncelik} disabled={busy} onChange={(e) => setOncelik(e.target.value as GorevOncelik)}>
              {GOREV_ONCELIKLERI.map((v) => (
                <option key={v} value={v}>{tGorev(`priorities.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor={`${alanId}-bitis`} className={labelClass}>{t("gorev.bitis")}</label>
            <input
              id={`${alanId}-bitis`}
              type="datetime-local"
              className={inputClass}
              value={bitis}
              disabled={busy}
              onChange={(e) => setBitis(e.target.value)}
            />
          </div>
        </div>
        <AksiyonBildirim hata={hata} basari={basari} />
        <div>
          <button type="submit" className={primaryBtn} disabled={busy}>
            {busy ? t("kaydediliyor") : t("gorev.ekle")}
          </button>
        </div>
      </form>
    </Kart>
  );
}

function GorevListesi({ gorevler }: { gorevler: RpcState<GrowthTaskList> }) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const tGorev = useTranslations("yonetim.crmGorevler");
  const satirlar = gorevler.data?.rows ?? [];

  let icerik: ReactNode;
  if (gorevler.loading) {
    icerik = <p className="py-6 text-center text-theme-sm text-gray-500 dark:text-gray-400">{t("yukleniyor")}</p>;
  } else if (gorevler.error) {
    icerik = (
      <ErrorNote message={gorevler.missing ? t("hata.eksik") : `${t("hata.genel")} ${gorevler.error}`} />
    );
  } else if (satirlar.length === 0) {
    icerik = <p className="py-6 text-center text-theme-sm text-gray-500 dark:text-gray-400">{t("gorev.bos")}</p>;
  } else {
    icerik = (
      <div className="overflow-x-auto">
        <table className="min-w-full">
          <thead className="border-b border-gray-100 dark:border-gray-800">
            <tr>
              <th scope="col" className={thClass}>{tGorev("cols.title")}</th>
              <th scope="col" className={thClass}>{tGorev("cols.type")}</th>
              <th scope="col" className={thClass}>{tGorev("cols.priority")}</th>
              <th scope="col" className={thClass}>{tGorev("cols.status")}</th>
              <th scope="col" className={thClass}>{tGorev("cols.dueAt")}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
            {satirlar.map((r) => (
              <tr key={r.id}>
                <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>{r.title}</td>
                <td className={`${tdClass} whitespace-nowrap`}>{tGorev(`types.${r.task_type}`)}</td>
                <td className={`${tdClass} whitespace-nowrap`}>{tGorev(`priorities.${r.priority}`)}</td>
                <td className={`${tdClass} whitespace-nowrap`}>{tGorev(`statuses.${r.status}`)}</td>
                <td className={`${tdClass} whitespace-nowrap`}>{formatDateTime(r.due_at)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  }

  return <Kart baslik={t("gorev.listeBaslik")}>{icerik}</Kart>;
}

function DestekFormu({ householdId, onKaydedildi }: { householdId: string; onKaydedildi: () => void }) {
  const t = useTranslations("yonetim.musteri360.aksiyon");
  const tDestek = useTranslations("yonetim.destekMasasi");
  const { busy, hata, basari, setHata, setBasari, calistir } = useAdminAksiyon();
  const alanId = useId();
  const [konu, setKonu] = useState("");
  const [kategori, setKategori] = useState<DestekKategori>("other");
  const [oncelik, setOncelik] = useState<DestekOncelik>("normal");

  const gonder = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const metin = konu.trim();
    if (metin.length < 1 || metin.length > 200) {
      setBasari(null);
      setHata(t("destek.hataKonu"));
      return;
    }
    const sonuc = await calistir("admin_destek_kaydet", {
      p_data: { subject: metin, category: kategori, priority: oncelik, household_id: householdId },
    });
    if (!sonuc) return;
    setKonu("");
    setKategori("other");
    setOncelik("normal");
    setBasari(t("destek.basarili"));
    onKaydedildi();
  };

  return (
    <Kart baslik={t("destek.baslik")}>
      <form onSubmit={gonder} noValidate className="space-y-4">
        <div>
          <label htmlFor={`${alanId}-konu`} className={labelClass}>{t("destek.konu")}</label>
          <input
            id={`${alanId}-konu`}
            type="text"
            maxLength={200}
            className={inputClass}
            value={konu}
            disabled={busy}
            onChange={(e) => setKonu(e.target.value)}
          />
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <label htmlFor={`${alanId}-kategori`} className={labelClass}>{t("destek.kategori")}</label>
            <select id={`${alanId}-kategori`} className={inputClass} value={kategori} disabled={busy} onChange={(e) => setKategori(e.target.value as DestekKategori)}>
              {DESTEK_KATEGORILERI.map((v) => (
                <option key={v} value={v}>{tDestek(`categories.${v}`)}</option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor={`${alanId}-oncelik`} className={labelClass}>{t("destek.oncelik")}</label>
            <select id={`${alanId}-oncelik`} className={inputClass} value={oncelik} disabled={busy} onChange={(e) => setOncelik(e.target.value as DestekOncelik)}>
              {DESTEK_ONCELIKLERI.map((v) => (
                <option key={v} value={v}>{tDestek(`priorities.${v}`)}</option>
              ))}
            </select>
          </div>
        </div>
        <AksiyonBildirim hata={hata} basari={basari} />
        <div>
          <button type="submit" className={primaryBtn} disabled={busy}>
            {busy ? t("kaydediliyor") : t("destek.ekle")}
          </button>
        </div>
      </form>
    </Kart>
  );
}
