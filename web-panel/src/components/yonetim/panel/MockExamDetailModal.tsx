"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import { createClient } from "@/utils/supabase/client";
import type { MockExam, MockExamQuestion, MockExamResult } from "../types";
import ErrorNote from "./ErrorNote";
import ModalShell from "./ModalShell";
import { inputClass, outlineBtn, primaryBtn, tdClass, thClass } from "./styles";
import useDebounced from "./useDebounced";

type Tab = "questions" | "results";

interface PickerRow {
  id: string;
  soru_metni: string;
  ders: string;
  konu: string;
  zorluk: number;
}

export default function MockExamDetailModal({
  exam,
  onClose,
  onChanged,
}: {
  exam: MockExam;
  onClose: () => void;
  onChanged: () => void;
}) {
  const t = useTranslations("yonetim.mockExams.detail");
  const [tab, setTab] = useState<Tab>("questions");

  return (
    <ModalShell isOpen onClose={onClose} title={exam.ad}>
      <div className="mb-4 flex gap-2">
        <button
          type="button"
          className={tab === "questions" ? primaryBtn : outlineBtn}
          onClick={() => setTab("questions")}
        >
          {t("tabQuestions")}
        </button>
        <button
          type="button"
          className={tab === "results" ? primaryBtn : outlineBtn}
          onClick={() => setTab("results")}
        >
          {t("tabResults")}
        </button>
      </div>

      {tab === "questions" ? (
        <div className="space-y-6">
          {exam.siniflar.length === 0 && (
            <p className="text-sm text-gray-500 dark:text-gray-400">{t("noGrades")}</p>
          )}
          {exam.siniflar.map((s) => (
            <GradeQuestions key={s} examId={exam.id} sinif={s} onChanged={onChanged} />
          ))}
        </div>
      ) : (
        <ResultsTab examId={exam.id} />
      )}
    </ModalShell>
  );
}

function GradeQuestions({
  examId,
  sinif,
  onChanged,
}: {
  examId: string;
  sinif: number;
  onChanged: () => void;
}) {
  const t = useTranslations("yonetim.mockExams.detail");
  const [items, setItems] = useState<MockExamQuestion[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_get_mock_exam_questions", {
        p_exam_id: examId,
        p_sinif: sinif,
      });
      if (cancelled) return;
      if (err) setError(err.message);
      else setItems((data ?? []) as MockExamQuestion[]);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [examId, sinif, reloadKey]);

  const onSaved = () => {
    setEditing(false);
    setReloadKey((k) => k + 1);
    onChanged();
  };

  return (
    <div className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
      <div className="mb-3 flex items-center justify-between gap-3">
        <h4 className="text-sm font-semibold text-gray-800 dark:text-white/90">
          {t("gradeTitle", { sinif, count: items?.length ?? 0 })}
        </h4>
        {!editing && (
          <button type="button" className={outlineBtn} onClick={() => setEditing(true)}>
            {t("editQuestions")}
          </button>
        )}
      </div>

      <ErrorNote message={error} />

      {editing && items ? (
        <QuestionPicker
          examId={examId}
          sinif={sinif}
          initial={items.map((i) => i.id)}
          onSaved={onSaved}
          onCancel={() => setEditing(false)}
        />
      ) : items === null ? (
        <p className="py-4 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : items.length === 0 ? (
        <p className="py-4 text-center text-sm text-gray-500 dark:text-gray-400">{t("noQuestions")}</p>
      ) : (
        <ol className="max-h-72 space-y-2 overflow-y-auto">
          {items.map((q) => (
            <li key={q.id} className="flex gap-3 text-sm">
              <span className="w-6 shrink-0 font-semibold text-gray-500">{q.sira}.</span>
              <span className="min-w-0 flex-1">
                <span className="line-clamp-2 text-gray-800 dark:text-white/90">{q.soru_metni}</span>
                <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                  {q.ders} · {q.konu} · {t("zorluk", { zorluk: q.zorluk })}
                </span>
              </span>
            </li>
          ))}
        </ol>
      )}
    </div>
  );
}

function QuestionPicker({
  examId,
  sinif,
  initial,
  onSaved,
  onCancel,
}: {
  examId: string;
  sinif: number;
  initial: string[];
  onSaved: () => void;
  onCancel: () => void;
}) {
  const t = useTranslations("yonetim.mockExams.detail");
  const [selected, setSelected] = useState<string[]>(initial);
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [rows, setRows] = useState<PickerRow[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_list_questions", {
        p_durum: "onaylandi",
        p_sinif: sinif,
        p_arama: debounced.trim() || null,
        p_limit: 50,
        p_offset: 0,
      });
      if (cancelled) return;
      if (err) setError(err.message);
      else setRows(((data as { satirlar?: PickerRow[] } | null)?.satirlar ?? []));
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, sinif]);

  const toggle = (id: string) =>
    setSelected((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));

  const save = async () => {
    setSaving(true);
    setError(null);
    const { error: err } = await createClient().rpc("admin_set_mock_exam_questions", {
      p_exam_id: examId,
      p_sinif: sinif,
      p_question_ids: selected,
    });
    setSaving(false);
    if (err) return setError(err.message);
    onSaved();
  };

  return (
    <div className="space-y-3">
      <input
        type="search"
        className={inputClass}
        placeholder={t("picker.search")}
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      <p className="text-theme-xs text-gray-500 dark:text-gray-400">
        {t("picker.selected", { count: selected.length })}
      </p>
      <ErrorNote message={error} />
      {rows === null ? (
        <p className="py-4 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
      ) : rows.length === 0 ? (
        <p className="py-4 text-center text-sm text-gray-500 dark:text-gray-400">{t("picker.empty")}</p>
      ) : (
        <ul className="max-h-80 divide-y divide-gray-100 overflow-y-auto dark:divide-gray-800">
          {rows.map((r) => (
            <li key={r.id}>
              <label className="flex cursor-pointer gap-3 py-2 text-sm">
                <input
                  type="checkbox"
                  className="mt-1"
                  checked={selected.includes(r.id)}
                  onChange={() => toggle(r.id)}
                />
                <span className="min-w-0 flex-1">
                  <span className="line-clamp-2 text-gray-800 dark:text-white/90">{r.soru_metni}</span>
                  <span className="text-theme-xs text-gray-500 dark:text-gray-400">
                    {r.ders} · {r.konu} · {t("zorluk", { zorluk: r.zorluk })}
                  </span>
                </span>
              </label>
            </li>
          ))}
        </ul>
      )}
      <div className="flex justify-end gap-3">
        <button type="button" className={outlineBtn} onClick={onCancel}>
          {t("picker.cancel")}
        </button>
        <button type="button" className={primaryBtn} onClick={save} disabled={saving}>
          {saving ? t("picker.saving") : t("picker.save")}
        </button>
      </div>
    </div>
  );
}

function ResultsTab({ examId }: { examId: string }) {
  const t = useTranslations("yonetim.mockExams.detail");
  const [rows, setRows] = useState<MockExamResult[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_get_mock_exam_results", {
        p_exam_id: examId,
      });
      if (cancelled) return;
      if (err) setError(err.message);
      else setRows((data ?? []) as MockExamResult[]);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [examId]);

  if (error) return <ErrorNote message={error} />;
  if (rows === null) {
    return <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>;
  }
  if (rows.length === 0) {
    return <p className="py-6 text-center text-sm text-gray-500 dark:text-gray-400">{t("resultsEmpty")}</p>;
  }

  const siniflar = [...new Set(rows.map((r) => r.sinif))].sort((a, b) => a - b);

  return (
    <div className="space-y-6">
      {siniflar.map((s) => {
        const grup = rows.filter((r) => r.sinif === s);
        const ortalama = grup.reduce((a, r) => a + Number(r.puan), 0) / grup.length;
        return (
          <div key={s}>
            <h4 className="mb-2 text-sm font-semibold text-gray-800 dark:text-white/90">
              {t("resultsGrade", { sinif: s, count: grup.length, ortalama: ortalama.toLocaleString("tr-TR", { maximumFractionDigits: 1 }) })}
            </h4>
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead className="border-b border-gray-100 dark:border-gray-800">
                  <tr>
                    <th className={thClass}>{t("resultCols.sira")}</th>
                    <th className={thClass}>{t("resultCols.ogrenci")}</th>
                    <th className={thClass}>{t("resultCols.puan")}</th>
                    <th className={thClass}>{t("resultCols.dogru")}</th>
                    <th className={thClass}>{t("resultCols.yanlis")}</th>
                    <th className={thClass}>{t("resultCols.bos")}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {grup.map((r) => (
                    <tr key={r.student_id}>
                      <td className={tdClass}>{r.sira}</td>
                      <td className={tdClass}>{r.ad_soyad || "-"}</td>
                      <td className={`${tdClass} font-semibold`}>{Number(r.puan)}</td>
                      <td className={tdClass}>{r.dogru_sayisi}</td>
                      <td className={tdClass}>{r.yanlis_sayisi}</td>
                      <td className={tdClass}>{r.bos_sayisi}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        );
      })}
    </div>
  );
}
