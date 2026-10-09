"use client";

import { useState } from "react";

import PageBreadcrumb from "@/components/common/PageBreadCrumb";
import { adminCall, useAdminRpc } from "@/components/yonetim/useAdminRpc";
import {
  cardClass,
  inputClass,
  outlineBtn,
  primaryBtn,
  tdClass,
  thClass,
} from "@/components/yonetim/panel/styles";

type VeliArama = {
  id: string;
  ad: string;
  username: string | null;
  email: string | null;
  deneme_aktif: boolean;
};

type AktifDeneme = {
  veli_id: string;
  ad: string;
  username: string | null;
  email: string | null;
  baslangic: string;
  bitis: string;
  kalan_gun: number;
};

type Feedback = { kind: "ok" | "error"; msg: string } | null;

const tarihFormati = new Intl.DateTimeFormat("tr-TR", {
  timeZone: "Europe/Istanbul",
  day: "2-digit",
  month: "2-digit",
  year: "numeric",
});

export default function DenemelerPage() {
  const aktif = useAdminRpc<AktifDeneme[]>("admin_deneme_listele");

  const [arama, setArama] = useState("");
  const [sonuclar, setSonuclar] = useState<VeliArama[] | null>(null);
  const [aramaYukleniyor, setAramaYukleniyor] = useState(false);
  const [gun, setGun] = useState("");
  const [islemde, setIslemde] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<Feedback>(null);

  const ara = async () => {
    setAramaYukleniyor(true);
    setFeedback(null);
    const { data, error } = await adminCall<VeliArama[]>("admin_deneme_veli_ara", {
      p_arama: arama.trim(),
    });
    setAramaYukleniyor(false);
    if (error) {
      setFeedback({ kind: "error", msg: error === "DEMO" ? "Demo modunda işlem yapılamaz." : error });
      return;
    }
    setSonuclar(data ?? []);
  };

  const baslat = async (veli: VeliArama) => {
    const trimmed = gun.trim();
    const gunDegeri = trimmed === "" ? null : Number(trimmed);
    if (gunDegeri !== null && (!Number.isInteger(gunDegeri) || gunDegeri < 1 || gunDegeri > 90)) {
      setFeedback({ kind: "error", msg: "Deneme süresi boş bırakılabilir veya 1-90 gün olmalı." });
      return;
    }
    setIslemde(veli.id);
    setFeedback(null);
    const { error } = await adminCall("admin_deneme_baslat", {
      p_veli_id: veli.id,
      p_gun: gunDegeri,
    });
    setIslemde(null);
    if (error) {
      setFeedback({ kind: "error", msg: error === "DEMO" ? "Demo modunda işlem yapılamaz." : error });
      return;
    }
    setFeedback({ kind: "ok", msg: `${veli.ad || veli.email || "Veli"} için deneme başlatıldı.` });
    setSonuclar((prev) =>
      prev ? prev.map((x) => (x.id === veli.id ? { ...x, deneme_aktif: true } : x)) : prev,
    );
    aktif.reload();
  };

  const bitir = async (d: AktifDeneme) => {
    if (!window.confirm(`${d.ad || d.email || "Bu veli"} için deneme hemen bitirilsin mi?`)) return;
    setIslemde(d.veli_id);
    setFeedback(null);
    const { error } = await adminCall("admin_deneme_bitir", { p_veli_id: d.veli_id });
    setIslemde(null);
    if (error) {
      setFeedback({ kind: "error", msg: error === "DEMO" ? "Demo modunda işlem yapılamaz." : error });
      return;
    }
    setFeedback({ kind: "ok", msg: "Deneme bitirildi." });
    setSonuclar((prev) =>
      prev ? prev.map((x) => (x.id === d.veli_id ? { ...x, deneme_aktif: false } : x)) : prev,
    );
    aktif.reload();
  };

  return (
    <div>
      <PageBreadcrumb
        pageTitle="Denemeler"
        description="Velilere deneme süresi aç, aktif denemeleri izle ve bitir"
      />

      {feedback && (
        <div
          className={`mb-5 rounded-lg px-4 py-3 text-sm font-medium ${
            feedback.kind === "ok"
              ? "bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-400"
              : "bg-error-50 text-error-700 dark:bg-error-500/10 dark:text-error-400"
          }`}
        >
          {feedback.msg}
        </div>
      )}

      <div className={`${cardClass} mb-6 p-6`}>
        <h3 className="mb-4 text-base font-semibold text-gray-800 dark:text-white/90">Veli bul ve deneme aç</h3>
        <div className="flex flex-wrap items-end gap-3">
          <div className="min-w-64 flex-1">
            <label htmlFor="deneme-arama" className="mb-1 block text-sm text-gray-600 dark:text-gray-300">
              Ad, kullanıcı adı veya e-posta
            </label>
            <input
              id="deneme-arama"
              type="text"
              className={inputClass}
              value={arama}
              onChange={(e) => setArama(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") void ara();
              }}
            />
          </div>
          <div className="w-40">
            <label htmlFor="deneme-gun" className="mb-1 block text-sm text-gray-600 dark:text-gray-300">
              Gün (boş = ayar)
            </label>
            <input
              id="deneme-gun"
              type="number"
              min={1}
              max={90}
              className={inputClass}
              value={gun}
              onChange={(e) => setGun(e.target.value)}
            />
          </div>
          <button className={primaryBtn} onClick={ara} disabled={aramaYukleniyor}>
            {aramaYukleniyor ? "Aranıyor…" : "Ara"}
          </button>
        </div>

        {sonuclar && sonuclar.length === 0 && (
          <p className="mt-4 text-sm text-gray-500 dark:text-gray-400">Veli bulunamadı.</p>
        )}

        {sonuclar && sonuclar.length > 0 && (
          <div className="mt-4 overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr>
                  <th className={thClass}>Veli</th>
                  <th className={thClass}>E-posta</th>
                  <th className={thClass}>Durum</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody>
                {sonuclar.map((v) => (
                  <tr key={v.id}>
                    <td className={tdClass}>{v.ad || v.username || "—"}</td>
                    <td className={tdClass}>{v.email ?? "—"}</td>
                    <td className={tdClass}>{v.deneme_aktif ? "Deneme aktif" : "—"}</td>
                    <td className={tdClass}>
                      <button
                        className={outlineBtn}
                        onClick={() => baslat(v)}
                        disabled={v.deneme_aktif || islemde === v.id}
                      >
                        {v.deneme_aktif ? "Aktif" : "Denemeyi başlat"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className={cardClass}>
        <h3 className="px-6 pt-6 text-base font-semibold text-gray-800 dark:text-white/90">Aktif denemeler</h3>
        {aktif.loading && (
          <p className="p-6 text-sm text-gray-500 dark:text-gray-400">Yükleniyor…</p>
        )}
        {!aktif.loading && aktif.error && (
          <p className="p-6 text-sm text-error-600 dark:text-error-400">{aktif.error}</p>
        )}
        {!aktif.loading && !aktif.error && (aktif.data ?? []).length === 0 && (
          <p className="p-6 text-sm text-gray-500 dark:text-gray-400">Aktif deneme yok.</p>
        )}
        {!aktif.loading && !aktif.error && (aktif.data ?? []).length > 0 && (
          <div className="overflow-x-auto p-6 pt-4">
            <table className="w-full text-left">
              <thead>
                <tr>
                  <th className={thClass}>Veli</th>
                  <th className={thClass}>E-posta</th>
                  <th className={thClass}>Bitiş</th>
                  <th className={thClass}>Kalan gün</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody>
                {(aktif.data ?? []).map((d) => (
                  <tr key={d.veli_id}>
                    <td className={tdClass}>{d.ad || d.username || "—"}</td>
                    <td className={tdClass}>{d.email ?? "—"}</td>
                    <td className={tdClass}>{tarihFormati.format(new Date(d.bitis))}</td>
                    <td className={tdClass}>{d.kalan_gun}</td>
                    <td className={tdClass}>
                      <button
                        className={outlineBtn}
                        onClick={() => bitir(d)}
                        disabled={islemde === d.veli_id}
                      >
                        Bitir
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
