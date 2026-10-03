"use client";

import { useCallback, useEffect, useState } from "react";
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

const HEDEF_ETIKET: Record<string, string> = {
  veli: "Tüm veliler",
  ogrenci: "Tüm öğrenciler",
  tumu: "Herkes (veli + öğrenci)",
};

export default function BildirimManager() {
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

  const PAGE_SIZE = 25;

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
    if (!form.baslik.trim()) return setFormError("Başlık boş olamaz.");
    if (!form.mesaj.trim()) return setFormError("Mesaj boş olamaz.");
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

  return (
    <div className="space-y-6">
      {/* Gönderim formu */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">Bildirim Gönder</h3>
          {!form && (
            <button type="button" className={primaryBtn} onClick={() => { setForm(EMPTY_FORM); setGonderildi(null); }}>
              + Yeni Bildirim
            </button>
          )}
        </div>

        {gonderildi !== null && !form && (
          <div className="rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-400">
            Bildirim {gonderildi} kişiye gönderildi.
          </div>
        )}

        {form && (
          <form onSubmit={gonder} className="space-y-4">
            <div>
              <label className={labelClass} htmlFor="b-hedef">Hedef Kitle</label>
              <select id="b-hedef" className={inputClass} value={form.hedef}
                onChange={(e) => setF("hedef", e.target.value as FormState["hedef"])}>
                {Object.entries(HEDEF_ETIKET).map(([v, l]) => (
                  <option key={v} value={v}>{l}</option>
                ))}
              </select>
            </div>
            <div>
              <label className={labelClass} htmlFor="b-baslik">Başlık *</label>
              <input id="b-baslik" className={inputClass} maxLength={100} value={form.baslik}
                onChange={(e) => setF("baslik", e.target.value)} placeholder="Duyuru başlığı" />
            </div>
            <div>
              <label className={labelClass} htmlFor="b-mesaj">Mesaj *</label>
              <textarea
                id="b-mesaj"
                className={`${inputClass} min-h-20 resize-y`}
                maxLength={500}
                value={form.mesaj}
                onChange={(e) => setF("mesaj", e.target.value)}
                placeholder="Kullanıcılara gösterilecek mesaj..."
              />
              <p className="mt-1 text-xs text-gray-400">{form.mesaj.length}/500</p>
            </div>
            <ErrorNote message={formError} />
            <div className="flex justify-end gap-3">
              <button type="button" className={outlineBtn} onClick={() => setForm(null)}>Vazgeç</button>
              <button type="submit" className={primaryBtn} disabled={sending}>
                {sending ? "Gönderiliyor..." : "Gönder"}
              </button>
            </div>
          </form>
        )}
      </section>

      {/* Gönderilen bildirimler */}
      <section className={`${cardClass} p-5 sm:p-6`}>
        <h3 className="mb-4 text-lg font-semibold text-gray-800 dark:text-white/90">
          Gönderilen Bildirimler
        </h3>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500">Yükleniyor...</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600">{error}</p>
            <button type="button" className={primaryBtn} onClick={reload}>Tekrar Dene</button>
          </div>
        ) : bildirimler.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500">Henüz bildirim gönderilmemiş.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>Başlık / Mesaj</th>
                  <th className={thClass}>Alıcı</th>
                  <th className={thClass}>Okundu</th>
                  <th className={thClass}>Tarih</th>
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
                        {b.okundu ? "Okundu" : "Okunmadı"}
                      </Badge>
                    </td>
                    <td className={`${tdClass} whitespace-nowrap text-xs text-gray-500`}>
                      {new Date(b.created_at).toLocaleString("tr-TR", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" })}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {!loading && !error && toplam > PAGE_SIZE && (
          <div className="mt-4 flex items-center justify-between text-theme-sm text-gray-500">
            <span>{start}–{end} / {toplam}</span>
            <div className="flex gap-2">
              <button type="button" disabled={page === 0} className={outlineBtn} onClick={() => setPage((p) => p - 1)}>←</button>
              <button type="button" disabled={end >= toplam} className={outlineBtn} onClick={() => setPage((p) => p + 1)}>→</button>
            </div>
          </div>
        )}
      </section>
    </div>
  );
}
