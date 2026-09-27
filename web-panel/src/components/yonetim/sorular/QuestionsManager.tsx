"use client";

import { Link } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import Pager from "../Pager";
import type { AdminQuestion, Paged, QuestionStatus } from "../types";
import DeleteConfirmModal from "./DeleteConfirmModal";
import QuestionFormModal from "./QuestionFormModal";
import QuestionsTable from "./QuestionsTable";

const PAGE_SIZE = 25;

interface LoadedList {
  key: string;
  data: Paged<AdminQuestion> | null;
  error: string | null;
}

type FormState = { question: AdminQuestion | null } | null;

const fieldClass =
  "h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 text-sm text-gray-800 shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:ring-3 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30 dark:focus:border-brand-800";

export default function QuestionsManager() {
  const t = useTranslations("yonetim.sorular");

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
  ]);

  useEffect(() => {
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
  }, [requestKey, debounced, durum, zorluk, page]);

  const isLoading = !loaded || loaded.key !== requestKey;
  const list = loaded?.data ?? null;
  const rows = useMemo(() => list?.satirlar ?? [], [list]);
  const total = list?.toplam ?? 0;
  const loadError = !isLoading ? loaded?.error : null;

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
      rows.every((r) => prev.has(r.id))
        ? new Set()
        : new Set(rows.map((r) => r.id))
    );

  const setStatus = async (status: QuestionStatus) => {
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

  const from = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const to = Math.min(total, (page + 1) * PAGE_SIZE);
  const bulkButton =
    "rounded-lg border px-3.5 py-2 text-sm font-medium disabled:cursor-not-allowed disabled:opacity-50";

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
          <Link
            href="/yonetim/sorular/toplu-ekle"
            className="rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
          >
            {t("bulkImport")}
          </Link>
          <button
            type="button"
            onClick={() => setForm({ question: null })}
            className="rounded-lg bg-brand-500 px-4 py-2.5 text-sm font-medium text-white shadow-theme-xs hover:bg-brand-600"
          >
            {t("newQuestion")}
          </button>
        </div>
      </div>

      <div className="mb-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
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
            onClick={() => setStatus("onaylandi")}
            className={`${bulkButton} border-success-300 text-success-700 hover:bg-success-50 dark:border-success-500/40 dark:text-success-500 dark:hover:bg-success-500/10`}
          >
            {t("bulk.approve")}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => setStatus("reddedildi")}
            className={`${bulkButton} border-warning-300 text-warning-700 hover:bg-warning-50 dark:border-warning-500/40 dark:text-orange-400 dark:hover:bg-warning-500/10`}
          >
            {t("bulk.reject")}
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => setStatus("beklemede")}
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
        </div>
      )}

      {isLoading ? (
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
            className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-white/5"
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
