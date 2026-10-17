"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import Badge from "@/components/ui/badge/Badge";
import { createClient } from "@/utils/supabase/client";
import ErrorNote from "./ErrorNote";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";

interface Bildirim {
  id: string;
  baslik: string;
  mesaj: string;
  ikon: string;
  okundu: boolean;
  created_at: string;
  alici_ad: string | null;
  alici_rol: string;
}

interface FormState {
  baslik: string;
  mesaj: string;
  hedef: "veli" | "ogrenci" | "tumu";
}

const EMPTY_FORM: FormState = { baslik: "", mesaj: "", hedef: "veli" };
const HEDEFLER = ["veli", "ogrenci", "tumu"] as const;
const PAGE_SIZE = 25;

// Tablo kendi kapsayıcısında kayar (md ve üzeri); kart görünümü md altında.
export default function BildirimManager() {
  const t = useTranslations("yonetim.bildirimler");
  const [bildirimler, setBildirimler] = useState<Bildirim[]>([]);
  const [toplam, setToplam] = useState(0);
  const [page, setPage] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  const [form, setForm] = useState<FormState | null>(null);
  const [sending, setSending] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [gonderildi, setGonderildi] = useState<number | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_list_notifications", {
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) { setError(err.message); }
      else {
        setError(null);
        const d = data as { toplam: number; satirlar: Bildirim[] };
        setBildirimler(d.satirlar ?? []);
        setToplam(d.toplam ?? 0);
      }
      setLoading(false);
    };
    void run();
    return () => { cancelled = true; };
  }, [page, reloadKey]);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  const setF = <K extends keyof FormState>(k: K, v: FormState[K]) =>
    setForm((f) => (f ? { ...f, [k]: v } : f));

  const gonder = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form) return;
    if (!form.baslik.trim()) return setFormError(t("form.errTitle"));
    if (!form.mesaj.trim()) return setFormError(t("form.errMessage"));
    setFormError(null);
    setSending(true);
    const { data, error: err } = await createClient().rpc("admin_send_notification", {
      p_baslik: form.baslik.trim(),
      p_mesaj: form.mesaj.trim(),
      p_ikon: "bell",
      p_alici_id: null,
      p_hedef_rol: form.hedef,
    });
    setSending(false);
    if (err) return setFormError(err.message);
    setGonderildi(data as number);
    setForm(null);
    reload();
  };

  const start = toplam === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(toplam, page * PAGE_SIZE + bildirimler.length);

  const tarih = (iso: string) =>
    new Date(iso).toLocaleString("tr-TR", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" });

  return (
    <div className="space-y-6">
      {/* Gönderim formu */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex items-center justify-between gap-3">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">{t("sendTitle")}</h3>
          {!form && (
            <button type="button" className={primaryBtn} onClick={() => { setForm(EMPTY_FORM); setGonderildi(null); }}>
              {t("newNotification")}
            </button>
          )}
        </div>

        {gonderildi !== null && !form && (
          <div className="rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-400">
            {t("sentNotice", { count: gonderildi })}
          </div>
        )}

        {form && (
          <form onSubmit={gonder} className="space-y-4">
            <div>
              <label className={labelClass} htmlFor="b-hedef">{t("form.audience")}</label>
              <select
                id="b-hedef"
                className={inputClass}
                value={form.hedef}
                onChange={(e) => setF("hedef", e.target.value as FormState["hedef"])}
              >
                {HEDEFLER.map((v) => (
                  <option key={v} value={v}>{t(`audience.${v}`)}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="b-baslik">{t("form.title")} *</label>
              <input
                id="b-baslik"
                className={inputClass}
                maxLength={100}
                value={form.baslik}
                onChange={(e) => setF("baslik", e.target.value)}
                placeholder={t("form.titlePlaceholder")}
              />
            </div>
            <div>
              <label className={labelClass} htmlFor="b-mesaj">{t("form.message")} *</label>
              <textarea
                id="b-mesaj"
                className={`${inputClass} min-h-20 resize-y`}
                maxLength={500}
                value={form.mesaj}
                onChange={(e) => setF("mesaj", e.target.value)}
                placeholder={t("form.messagePlaceholder")}
              />
              <p className="mt-1 text-xs text-gray-400">{form.mesaj.length}/500</p>
            </div>
            <ErrorNote message={formError} />
            <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
              <button type="button" className={outlineBtn} onClick={() => setForm(null)}>{t("form.cancel")}</button>
              <button type="submit" className={primaryBtn} disabled={sending}>
                {sending ? t("form.sending") : t("form.send")}
              </button>
            </div>
          </form>
        )}
      </section>

      {/* Gönderilen bildirimler */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">{t("listTitle")}</h3>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600">{error}</p>
            <button type="button" className={primaryBtn} onClick={reload}>{t("retry")}</button>
          </div>
        ) : bildirimler.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500">{t("empty")}</p>
        ) : (
          <>
            {/* Telefon ve küçük tablet (md altı): kart görünümü */}
            <ul className="space-y-3 md:hidden">
              {bildirimler.map((b) => (
                <li key={b.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
                  <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">{b.baslik}</p>
                  <p className="mt-1 text-xs wrap-break-word text-gray-500 dark:text-gray-400">{b.mesaj}</p>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-3 text-theme-sm">
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.recipient")}</dt>
                      <dd>
                        <p className="text-gray-700 dark:text-gray-300">{b.alici_ad ?? "—"}</p>
                        <Badge size="sm" color={b.alici_rol === "veli" ? "info" : "primary"}>{b.alici_rol}</Badge>
                      </dd>
                    </div>
                    <div>
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.read")}</dt>
                      <dd>
                        <Badge size="sm" color={b.okundu ? "success" : "warning"}>
                          {b.okundu ? t("readStatus.read") : t("readStatus.unread")}
                        </Badge>
                      </dd>
                    </div>
                    <div className="col-span-2">
                      <dt className="text-theme-xs text-gray-500 dark:text-gray-400">{t("cols.date")}</dt>
                      <dd className="text-xs text-gray-500 dark:text-gray-400">{tarih(b.created_at)}</dd>
                    </div>
                  </dl>
                </li>
              ))}
            </ul>

            {/* Tablet ve masaüstü (md ve üzeri): tablo; kapsayıcısı kayar */}
            <div className="hidden overflow-x-auto md:block">
              <table className="min-w-full">
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th className={thClass}>{t("cols.titleMessage")}</th>
                    <th className={thClass}>{t("cols.recipient")}</th>
                    <th className={thClass}>{t("cols.read")}</th>
                    <th className={thClass}>{t("cols.date")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {bildirimler.map((b) => (
                    <tr key={b.id}>
                      <td className={tdClass}>
                        <p className="font-medium text-gray-800 dark:text-white/90">{b.baslik}</p>
                        <p className="mt-0.5 text-xs text-gray-500 dark:text-gray-400 line-clamp-1">{b.mesaj}</p>
                      </td>
                      <td className={tdClass}>
                        <p className="text-sm text-gray-700 dark:text-gray-300">{b.alici_ad ?? "—"}</p>
                        <Badge size="sm" color={b.alici_rol === "veli" ? "info" : "primary"}>
                          {b.alici_rol}
                        </Badge>
                      </td>
                      <td className={tdClass}>
                        <Badge size="sm" color={b.okundu ? "success" : "warning"}>
                          {b.okundu ? t("readStatus.read") : t("readStatus.unread")}
                        </Badge>
                      </td>
                      <td className={`${tdClass} whitespace-nowrap text-xs text-gray-500`}>{tarih(b.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}

        {!loading && !error && toplam > PAGE_SIZE && (
          <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-theme-sm text-gray-500">
            <span>{start}–{end} / {toplam}</span>
            <div className="flex gap-2">
              <button
                type="button"
                disabled={page === 0}
                className={outlineBtn}
                aria-label={t("pager.prevLabel")}
                onClick={() => setPage((p) => p - 1)}
              >
                ←
              </button>
              <button
                type="button"
                disabled={end >= toplam}
                className={outlineBtn}
                aria-label={t("pager.nextLabel")}
                onClick={() => setPage((p) => p + 1)}
              >
                →
              </button>
            </div>
          </div>
        )}
      </section>
    </div>
  );
}
