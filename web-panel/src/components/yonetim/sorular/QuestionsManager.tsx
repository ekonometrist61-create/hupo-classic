"use client";

import { Link } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import DesktopOnly from "@/components/ui/DesktopOnly";
import Pager from "../Pager";
import type { AdminQuestion, Paged, QuestionStatus } from "../types";
import { dokunmaHedefi } from "../ui/responsive";
import KazanimAtaModal from "../kazanim/KazanimAtaModal";
import KazanimsizTable, { type KazanimsizSoru } from "../kazanim/KazanimsizTable";
import { fetchDersler } from "../kazanim/kazanimVeri";
import DeleteConfirmModal from "./DeleteConfirmModal";
import QuestionFormModal from "./QuestionFormModal";
import QuestionsTable from "./QuestionsTable";

const PAGE_SIZE = 25;
const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8] as const;

interface LoadedList {
  key: string;
  data: Paged<AdminQuestion> | null;
  error: string | null;
}

interface LoadedKazanimsiz {
  key: string;
  rows: KazanimsizSoru[];
  error: string | null;
}

interface LoadedDersler {
  key: string;
  data: string[];
  error: string | null;
}

type FormState = { question: AdminQuestion | null } | null;

// Mobilde 16 px: iOS odakta yakınlaştırmaz (R3).
const fieldClass =
  "h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 text-base text-gray-800 shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden md:text-sm dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30 dark:focus:border-brand-800";

export default function QuestionsManager() {
  const t = useTranslations("yonetim.sorular");
  const tk = useTranslations("yonetim.sorular.kazanim");

  const [searchInput, setSearchInput] = useState("");
  const [dersInput, setDersInput] = useState("");
  const [debounced, setDebounced] = useState({ arama: "", ders: "" });
  const [durum, setDurum] = useState("");
  const [zorluk, setZorluk] = useState("");
  const [page, setPage] = useState(0);
  const [reloadCounter, setReloadCounter] = useState(0);
  const [loaded, setLoaded] = useState<LoadedList | null>(null);
  const [knownDers, setKnownDers] = useState<string[]>([]);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [form, setForm] = useState<FormState>(null);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  // Kazanımsız filtre: sınıf ve ders zorunludur (admin_kazanimsiz_sorular).
  const [kazanimsiz, setKazanimsiz] = useState(false);
  const [kSinif, setKSinif] = useState<number | null>(null);
  const [kDers, setKDers] = useState("");
  const [kDersler, setKDersler] = useState<LoadedDersler | null>(null);
  const [kLoaded, setKLoaded] = useState<LoadedKazanimsiz | null>(null);
  const [assignOpen, setAssignOpen] = useState(false);

  // Arama kutuları için ~400ms gecikme
  useEffect(() => {
    const id = setTimeout(() => {
      const next = { arama: searchInput.trim(), ders: dersInput.trim() };
      setDebounced((prev) =>
        prev.arama === next.arama && prev.ders === next.ders ? prev : next
      );
      setPage(0);
    }, 400);
    return () => clearTimeout(id);
  }, [searchInput, dersInput]);

  const requestKey = JSON.stringify([
    debounced,
    durum,
    zorluk,
    page,
    reloadCounter,
    kazanimsiz,
    kSinif,
    kDers,
  ]);

  useEffect(() => {
    if (kazanimsiz) return;
    let cancelled = false;
    createClient()
      .rpc("admin_list_questions", {
        p_ders: debounced.ders || null,
        p_durum: durum || null,
        p_zorluk: zorluk ? Number(zorluk) : null,
        p_arama: debounced.arama || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      })
      .then(({ data, error }) => {
        if (cancelled) return;
        if (error) {
          setLoaded({ key: requestKey, data: null, error: error.message });
          return;
        }
        const result = data as Paged<AdminQuestion>;
        setLoaded({ key: requestKey, data: result, error: null });
        setSelected(new Set());
        setKnownDers((prev) => {
          const next = new Set(prev);
          result.satirlar.forEach((q) => next.add(q.ders));
          return next.size === prev.length ? prev : [...next].sort();
        });
      });
    return () => {
      cancelled = true;
    };
  }, [requestKey, debounced, durum, zorluk, page, kazanimsiz]);

  // Kazanımsız liste: sınıf ve ders seçilmeden istek atılmaz.
  const kAktif = kazanimsiz && kSinif !== null && kDers !== "";
  useEffect(() => {
    if (!kAktif || kSinif === null) return;
    let cancelled = false;
    createClient()
      .rpc("admin_kazanimsiz_sorular", {
        p_ders: kDers,
        p_sinif: kSinif,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      })
      .then(({ data, error }) => {
        if (cancelled) return;
        if (error) {
          setKLoaded({ key: requestKey, rows: [], error: error.message });
          return;
        }
        setKLoaded({
          key: requestKey,
          rows: (data ?? []) as KazanimsizSoru[],
          error: null,
        });
        setSelected(new Set());
      });
    return () => {
      cancelled = true;
    };
  }, [requestKey, kAktif, kSinif, kDers, page]);

  // Kazanımsız modda müfredat derslerini sınıfa göre doldur.
  useEffect(() => {
    if (!kazanimsiz || kSinif === null) return;
    let cancelled = false;
    const key = String(kSinif);
    fetchDersler(kSinif).then(
      (data) => {
        if (!cancelled) setKDersler({ key, data, error: null });
      },
      (e: Error) => {
        if (!cancelled) setKDersler({ key, data: [], error: e.message });
      }
    );
    return () => {
      cancelled = true;
    };
  }, [kazanimsiz, kSinif]);

  const isLoading = !kazanimsiz && (!loaded || loaded.key !== requestKey);
  const list = loaded?.data ?? null;
  const rows = useMemo(() => list?.satirlar ?? [], [list]);
  const total = list?.toplam ?? 0;
  const loadError = !isLoading ? loaded?.error : null;

  const kLoading = kAktif && kLoaded?.key !== requestKey;
  const kRows = useMemo(
    () => (kAktif && kLoaded?.key === requestKey ? kLoaded.rows : []),
    [kAktif, kLoaded, requestKey]
  );
  const kError = kAktif && !kLoading ? kLoaded?.error ?? null : null;
  const kDerslerListe =
    kDersler?.key === String(kSinif) ? kDersler.data : [];
  const kDerslerYukleniyor =
    kSinif !== null && kDersler?.key !== String(kSinif);

  const activeRows: { id: string }[] = kazanimsiz ? kRows : rows;

  const reload = () => setReloadCounter((c) => c + 1);

  const toggle = (id: string) =>
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  const toggleAll = () =>
    setSelected((prev) =>
      activeRows.every((r) => prev.has(r.id))
        ? new Set()
        : new Set(activeRows.map((r) => r.id))
    );

  const toggleKazanimsiz = (checked: boolean) => {
    setKazanimsiz(checked);
    setPage(0);
    setSelected(new Set());
    setNotice(null);
    setActionError(null);
  };

  const setStatus = async (status: QuestionStatus, label: string) => {
    if (
      selected.size > 1 &&
      !window.confirm(t("bulk.statusConfirm", { action: label, count: selected.size }))
    )
      return;
    setBusy(true);
    setActionError(null);
    setNotice(null);
    const { data, error } = await createClient().rpc(
      "admin_set_question_status",
      { p_ids: [...selected], p_durum: status }
    );
    setBusy(false);
    if (error) {
      setActionError(error.message);
      return;
    }
    setNotice(t("success.status", { count: Number(data ?? 0) }));
    reload();
  };

  const deleteSelected = async () => {
    setBusy(true);
    setActionError(null);
    setNotice(null);
    const { data, error } = await createClient().rpc("admin_delete_questions", {
      p_ids: [...selected],
    });
    setBusy(false);
    setConfirmDelete(false);
    if (error) {
      setActionError(error.message);
      return;
    }
    setNotice(t("success.deleted", { count: Number(data ?? 0) }));
    reload();
  };

  // Filtredeki tüm bekleyen sorular: sayfa sayfa id toplanır, sonra 500'lük parçalarla onaylanır.
  const approveAllFiltered = async () => {
    if (!window.confirm(t("bulk.approveAllConfirm", { count: total }))) return;
    setBusy(true);
    setActionError(null);
    setNotice(null);
    try {
      const supabase = createClient();
      const ids: string[] = [];
      for (let offset = 0; ; offset += 100) {
        const { data, error } = await supabase.rpc("admin_list_questions", {
          p_ders: debounced.ders || null,
          p_durum: "beklemede",
          p_zorluk: zorluk ? Number(zorluk) : null,
          p_arama: debounced.arama || null,
          p_limit: 100,
          p_offset: offset,
        });
        if (error) throw new Error(error.message);
        const pageData = data as Paged<AdminQuestion>;
        ids.push(...pageData.satirlar.map((q) => q.id));
        if (pageData.satirlar.length < 100) break;
      }
      let onaylanan = 0;
      for (let i = 0; i < ids.length; i += 500) {
        const { data, error } = await supabase.rpc("admin_set_question_status", {
          p_ids: ids.slice(i, i + 500),
          p_durum: "onaylandi",
        });
        if (error) throw new Error(error.message);
        onaylanan += Number(data ?? 0);
      }
      setNotice(t("success.status", { count: onaylanan }));
    } catch (e) {
      setActionError(e instanceof Error ? e.message : String(e));
    }
    setBusy(false);
    reload();
  };

  // Filtredeki tüm sorular (sayfalar ötesi dahil) seçilir; yalnızca id toplanır.
  const selectAllFiltered = async () => {
    setBusy(true);
    setActionError(null);
    setNotice(null);
    try {
      const supabase = createClient();
      const ids: string[] = [];
      for (let offset = 0; ; offset += 100) {
        const { data, error } = await supabase.rpc("admin_list_questions", {
          p_ders: debounced.ders || null,
          p_durum: durum || null,
          p_zorluk: zorluk ? Number(zorluk) : null,
          p_arama: debounced.arama || null,
          p_limit: 100,
          p_offset: offset,
        });
        if (error) throw new Error(error.message);
        const pageData = data as Paged<AdminQuestion>;
        ids.push(...pageData.satirlar.map((q) => q.id));
        if (pageData.satirlar.length < 100) break;
      }
      setSelected(new Set(ids));
    } catch (e) {
      setActionError(e instanceof Error ? e.message : String(e));
    }
    setBusy(false);
  };

  const from = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const to = Math.min(total, (page + 1) * PAGE_SIZE);
  const bulkButton =
    `${dokunmaHedefi} justify-center rounded-lg border px-3.5 text-sm font-medium disabled:cursor-not-allowed disabled:opacity-50`;
  const pagerButton =
    `${dokunmaHedefi} justify-center rounded-lg border border-gray-300 px-3 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`;

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-4 sm:p-6 dark:border-gray-800 dark:bg-white/3">
      <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
            {t("listTitle")}
          </h3>
          <p className="text-theme-sm text-gray-500 dark:text-gray-400">
            {t("total", { count: total })}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {!kazanimsiz && (
            <button
              type="button"
              disabled={busy || total === 0}
              onClick={() => void selectAllFiltered()}
              className={`${dokunmaHedefi} justify-center rounded-lg border border-brand-300 px-4 text-sm font-medium text-brand-600 hover:bg-brand-25 disabled:cursor-not-allowed disabled:opacity-50 dark:border-brand-500/40 dark:text-brand-400 dark:hover:bg-brand-500/10`}
            >
              {busy ? t("bulk.selectAllProgress") : t("bulk.selectAllFiltered", { count: total })}
            </button>
          )}
          {!kazanimsiz && (
            <button
              type="button"
              disabled={busy || durum !== "beklemede" || total === 0}
              onClick={() => void approveAllFiltered()}
              title={durum !== "beklemede" ? t("bulk.approveAllHint") : undefined}
              className={`${dokunmaHedefi} justify-center rounded-lg border border-success-300 px-4 text-sm font-medium text-success-700 hover:bg-success-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-success-500/40 dark:text-success-500 dark:hover:bg-success-500/10`}
            >
              {busy ? t("bulk.approveAllProgress") : t("bulk.approveAll", { count: total })}
            </button>
          )}
          <button
            type="button"
            disabled={selected.size === 0 || busy}
            onClick={() => setAssignOpen(true)}
            title={selected.size === 0 ? tk("bulk.none") : undefined}
            className={`${dokunmaHedefi} justify-center rounded-lg border border-brand-300 px-4 text-sm font-medium text-brand-600 hover:bg-brand-25 disabled:cursor-not-allowed disabled:opacity-50 dark:border-brand-500/40 dark:text-brand-400 dark:hover:bg-brand-500/10`}
          >
            {tk("bulk.assign")}
          </button>
          {/* K3: toplu içe aktarma yalnızca masaüstünde; telefonda bilgi notu görünür. */}
          <DesktopOnly>
            <Link
              href="/yonetim/sorular/toplu-ekle"
              className={`${dokunmaHedefi} justify-center rounded-lg border border-gray-300 px-4 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`}
            >
              {t("bulkImport")}
            </Link>
          </DesktopOnly>
          <button
            type="button"
            onClick={() => setForm({ question: null })}
            className={`${dokunmaHedefi} justify-center rounded-lg bg-brand-500 px-4 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600`}
          >
            {t("newQuestion")}
          </button>
        </div>
      </div>

      <label className="mb-3 flex min-h-11 items-center gap-2 text-sm font-medium text-gray-700 dark:text-gray-300">
        <input
          type="checkbox"
          checked={kazanimsiz}
          onChange={(e) => toggleKazanimsiz(e.target.checked)}
          className="h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/20 dark:border-gray-700 dark:bg-gray-900"
        />
        {tk("filter.kazanimsiz")}
      </label>

      <div className="mb-4 grid gap-3 md:grid-cols-2 lg:grid-cols-4">
        {kazanimsiz ? (
          <>
            <select
              value={kSinif ?? ""}
              onChange={(e) => {
                setKSinif(e.target.value ? Number(e.target.value) : null);
                setKDers("");
                setPage(0);
              }}
              aria-label={tk("filter.sinif")}
              className={fieldClass}
            >
              <option value="">{tk("filter.selectSinif")}</option>
              {SINIFLAR.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <select
              value={kDers}
              disabled={kSinif === null || kDerslerYukleniyor}
              onChange={(e) => {
                setKDers(e.target.value);
                setPage(0);
              }}
              aria-label={tk("filter.ders")}
              className={fieldClass}
            >
              <option value="">
                {kDerslerYukleniyor ? tk("filter.loadingDers") : tk("filter.selectDers")}
              </option>
              {kDerslerListe.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
            <p className="text-theme-xs text-gray-500 dark:text-gray-400 md:col-span-2 lg:col-span-2">
              {tk("filter.note")}
            </p>
          </>
        ) : (
          <>
            <input
              type="search"
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              placeholder={t("filters.searchPlaceholder")}
              aria-label={t("filters.search")}
              className={fieldClass}
            />
            <div>
              <input
                type="text"
                list="yonetim-ders-list"
                value={dersInput}
                onChange={(e) => setDersInput(e.target.value)}
                placeholder={t("filters.dersPlaceholder")}
                aria-label={t("filters.ders")}
                className={fieldClass}
              />
              <datalist id="yonetim-ders-list">
                {knownDers.map((d) => (
                  <option key={d} value={d} />
                ))}
              </datalist>
            </div>
            <select
              value={durum}
              onChange={(e) => {
                setDurum(e.target.value);
                setPage(0);
              }}
              aria-label={t("filters.durum")}
              className={fieldClass}
            >
              <option value="">{t("filters.allStatuses")}</option>
              <option value="beklemede">{t("status.beklemede")}</option>
              <option value="onaylandi">{t("status.onaylandi")}</option>
              <option value="reddedildi">{t("status.reddedildi")}</option>
            </select>
            <select
              value={zorluk}
              onChange={(e) => {
                setZorluk(e.target.value);
                setPage(0);
              }}
              aria-label={t("filters.zorluk")}
              className={fieldClass}
            >
              <option value="">{t("filters.allDifficulties")}</option>
              <option value="1">{t("difficulty.1")}</option>
              <option value="2">{t("difficulty.2")}</option>
              <option value="3">{t("difficulty.3")}</option>
            </select>
          </>
        )}
      </div>

      {notice && (
        <div
          role="status"
          className="mb-4 rounded-lg border border-success-200 bg-success-50 px-4 py-3 text-sm text-success-700 dark:border-success-500/30 dark:bg-success-500/10 dark:text-success-500"
        >
          {notice}
        </div>
      )}
      {actionError && (
        <div
          role="alert"
          className="mb-4 rounded-lg border border-error-200 bg-error-50 px-4 py-3 text-sm text-error-700 dark:border-error-500/30 dark:bg-error-500/10 dark:text-error-400"
        >
          {actionError}
        </div>
      )}

      {selected.size > 0 && (
        <div className="mb-4 flex flex-wrap items-center gap-2 rounded-lg border border-brand-200 bg-brand-25 px-4 py-3 dark:border-brand-500/30 dark:bg-brand-500/10">
          <span className="me-2 text-sm font-medium text-gray-800 dark:text-white/90">
            {t("bulk.selected", { count: selected.size })}
          </span>
          <button
            type="button"
            disabled={busy}
            onClick={() => setStatus("onaylandi", t("bulk.approve"))}
            className={`${bulkButton} border-success-300 text-success-700 hover:bg-success-50 dark:border-success-500/40 dark:text-success-500 dark:hover:bg-success-500/10`}
          >
            {t("bulk.approve")}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => setStatus("reddedildi", t("bulk.reject"))}
            className={`${bulkButton} border-warning-300 text-warning-700 hover:bg-warning-50 dark:border-warning-500/40 dark:text-orange-400 dark:hover:bg-warning-500/10`}
          >
            {t("bulk.reject")}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => setStatus("beklemede", t("bulk.pending"))}
            className={`${bulkButton} border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`}
          >
            {t("bulk.pending")}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => setConfirmDelete(true)}
            className={`${bulkButton} border-error-300 text-error-700 hover:bg-error-50 dark:border-error-500/40 dark:text-error-400 dark:hover:bg-error-500/10`}
          >
            {t("bulk.delete")}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => setSelected(new Set())}
            className={`${bulkButton} border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`}
          >
            {t("bulk.clearSelection")}
          </button>
        </div>
      )}

      {kazanimsiz ? (
        kSinif === null || kDers === "" ? (
          <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">
            {tk("filter.pickFirst")}
          </p>
        ) : kLoading ? (
          <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">
            {t("loading")}
          </p>
        ) : kError ? (
          <div className="py-8 text-center">
            <p role="alert" className="mb-3 text-sm text-error-600 dark:text-error-400">
              {t("loadError")}: {kError}
            </p>
            <button
              type="button"
              onClick={reload}
              className={`${dokunmaHedefi} rounded-lg border border-gray-300 px-4 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`}
            >
              {t("retry")}
            </button>
          </div>
        ) : kRows.length === 0 && page === 0 ? (
          <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">
            {tk("filter.empty")}
          </p>
        ) : (
          <>
            <KazanimsizTable
              rows={kRows}
              selected={selected}
              disabled={busy}
              onToggle={toggle}
              onToggleAll={toggleAll}
            />
            <div className="flex flex-wrap items-center justify-between gap-3 pt-4">
              <span className="text-theme-sm text-gray-500 dark:text-gray-400">
                {tk("filter.page", { sayfa: page + 1 })}
              </span>
              <div className="flex gap-2">
                <button
                  type="button"
                  disabled={page <= 0}
                  onClick={() => setPage(page - 1)}
                  className={pagerButton}
                >
                  {t("pager.prev")}
                </button>
                <button
                  type="button"
                  disabled={kRows.length < PAGE_SIZE}
                  onClick={() => setPage(page + 1)}
                  className={pagerButton}
                >
                  {t("pager.next")}
                </button>
              </div>
            </div>
          </>
        )
      ) : isLoading ? (
        <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("loading")}
        </p>
      ) : loadError ? (
        <div className="py-8 text-center">
          <p
            role="alert"
            className="mb-3 text-sm text-error-600 dark:text-error-400"
          >
            {t("loadError")}: {loadError}
          </p>
          <button
            type="button"
            onClick={reload}
            className={`${dokunmaHedefi} rounded-lg border border-gray-300 px-4 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5`}
          >
            {t("retry")}
          </button>
        </div>
      ) : rows.length === 0 ? (
        <p className="py-12 text-center text-sm text-gray-500 dark:text-gray-400">
          {t("empty")}
        </p>
      ) : (
        <>
          <QuestionsTable
            rows={rows}
            selected={selected}
            disabled={busy}
            onToggle={toggle}
            onToggleAll={toggleAll}
            onEdit={(question) => setForm({ question })}
          />
          <Pager
            page={page}
            pageSize={PAGE_SIZE}
            total={total}
            onPage={setPage}
            labels={{
              prev: t("pager.prev"),
              next: t("pager.next"),
              summary: t("pager.summary", { from, to, total }),
            }}
          />
        </>
      )}

      {form && (
        <QuestionFormModal
          question={form.question}
          onClose={() => setForm(null)}
          onSaved={() => {
            setForm(null);
            setActionError(null);
            setNotice(t("success.saved"));
            reload();
          }}
        />
      )}
      {assignOpen && (
        <KazanimAtaModal
          ids={[...selected]}
          onClose={() => setAssignOpen(false)}
          onDone={(mesaj) => {
            setAssignOpen(false);
            setActionError(null);
            setNotice(mesaj);
            reload();
          }}
        />
      )}
      {confirmDelete && (
        <DeleteConfirmModal
          count={selected.size}
          busy={busy}
          onConfirm={deleteSelected}
          onClose={() => setConfirmDelete(false)}
        />
      )}
    </div>
  );
}
