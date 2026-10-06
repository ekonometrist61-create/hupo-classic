"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { Modal } from "@/components/ui/modal";
import { formatDateTime } from "@/utils/format";
import { cardClass, inputClass, labelClass, outlineBtn, primaryBtn } from "../panel/styles";
import Feedback from "../ui/Feedback";
import RpcBoundary from "../ui/RpcBoundary";
import { adminCall, useAdminRpc } from "../useAdminRpc";
import { DEMO_SURVEY_RESULT, DEMO_SURVEYS, DEMO_TASKS } from "./demoData";
import type { QuestionType, Survey, SurveyQuestion, SurveyResult, SupportTask } from "./types";

const TYPES: QuestionType[] = ["kisa_metin", "uzun_metin", "tek_secim", "nps", "csat", "onay"];
const STATUS_COLOR = { taslak: "light", yayinda: "success", kapali: "warning" } as const;

function newId(): string {
  return "q" + Math.random().toString(36).slice(2, 8);
}

export default function SurveysManager() {
  const t = useTranslations("yonetim.merkez.surveys");
  const [tab, setTab] = useState<"surveys" | "tasks">("surveys");
  const list = useAdminRpc<Survey[]>("admin_anket_listele", undefined, { demo: DEMO_SURVEYS });
  const tasks = useAdminRpc<SupportTask[]>("admin_destek_gorevleri_listele", { p_durum: "acik" }, { demo: DEMO_TASKS });

  const [editing, setEditing] = useState<Survey | "new" | null>(null);
  const [resultFor, setResultFor] = useState<Survey | null>(null);
  const [fb, setFb] = useState<{ kind: "ok" | "error"; msg: string } | null>(null);

  const setStatus = async (s: Survey, durum: "yayinda" | "kapali") => {
    const r = await adminCall("admin_anket_durum", { p_id: s.id, p_durum: durum });
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t(durum === "yayinda" ? "published" : "closed") });
    list.reload();
  };

  const closeTask = async (id: string, note: string) => {
    const r = await adminCall("admin_destek_gorevi_kapat", { p_id: id, p_not: note });
    if (r.error) return setFb({ kind: "error", msg: r.error === "DEMO" ? t("demo") : r.error });
    setFb({ kind: "ok", msg: t("taskClosed") });
    tasks.reload();
  };

  const tabBtn = (id: "surveys" | "tasks", label: string, count?: number) => (
    <button
      type="button"
      role="tab"
      aria-selected={tab === id}
      onClick={() => setTab(id)}
      className={`rounded-md px-3 py-1.5 text-theme-xs font-medium ${
        tab === id ? "bg-white shadow-theme-xs dark:bg-gray-800" : "text-gray-500"
      }`}
    >
      {label}
      {count ? ` (${count})` : ""}
    </button>
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div role="tablist" className="inline-flex gap-1 rounded-lg bg-gray-100 p-1 dark:bg-white/5">
          {tabBtn("surveys", t("tabSurveys"))}
          {tabBtn("tasks", t("tabTasks"), tasks.data?.length)}
        </div>
        {tab === "surveys" && (
          <button type="button" className={primaryBtn} onClick={() => setEditing("new")}>{t("create")}</button>
        )}
      </div>
      <Feedback kind={fb?.kind ?? "ok"} message={fb?.msg ?? null} />

      {tab === "surveys" ? (
        <RpcBoundary state={list}>
          {(rows) =>
            rows.length === 0 ? (
              <section className={`${cardClass} px-6 py-12 text-center text-sm text-gray-500`}>{t("empty")}</section>
            ) : (
              <div className="grid gap-4 lg:grid-cols-2">
                {rows.map((s) => (
                  <section key={s.id} className={`${cardClass} p-5 sm:p-6`}>
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <h2 className="truncate text-base font-semibold text-navy dark:text-white/90">{s.ad}</h2>
                        <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                          {t("meta", { q: s.sorular.length, v: s.surum })}
                        </p>
                      </div>
                      <Badge size="sm" color={STATUS_COLOR[s.durum]}>{t(`status.${s.durum}`)}</Badge>
                    </div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      <Badge size="sm" color={s.anonim ? "primary" : "info"}>
                        {s.anonim ? t("anonymous") : t("identified")}
                      </Badge>
                      <Badge size="sm" color="light">{t("responses", { n: s.yanit_sayisi })}</Badge>
                    </div>
                    <div className="mt-4 flex flex-wrap gap-3 text-theme-sm font-medium">
                      {s.durum !== "kapali" && (
                        <button type="button" className="text-brand-500 hover:text-brand-600" onClick={() => setEditing(s)}>{t("edit")}</button>
                      )}
                      <button type="button" className="text-brand-500 hover:text-brand-600" onClick={() => setResultFor(s)}>{t("results")}</button>
                      {s.durum === "taslak" && (
                        <button type="button" className="text-brand-500 hover:text-brand-600" onClick={() => setStatus(s, "yayinda")}>{t("publish")}</button>
                      )}
                      {s.durum === "yayinda" && (
                        <button type="button" className="text-error-600 hover:text-error-700" onClick={() => setStatus(s, "kapali")}>{t("close")}</button>
                      )}
                    </div>
                  </section>
                ))}
              </div>
            )
          }
        </RpcBoundary>
      ) : (
        <section className={`${cardClass} p-5 sm:p-6`}>
          <p className="mb-3 text-theme-xs text-gray-500 dark:text-gray-400">{t("tasksNote")}</p>
          <RpcBoundary state={tasks}>
            {(rows) =>
              rows.length === 0 ? (
                <p className="py-8 text-center text-sm text-gray-500">{t("tasksEmpty")}</p>
              ) : (
                <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                  {rows.map((g) => (
                    <TaskRow key={g.id} task={g} onClose={closeTask} />
                  ))}
                </ul>
              )
            }
          </RpcBoundary>
        </section>
      )}

      {editing && (
        <Editor
          key={editing === "new" ? "new" : editing.id}
          initial={editing === "new" ? null : editing}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null);
            list.reload();
          }}
        />
      )}
      {resultFor && <Results survey={resultFor} onClose={() => setResultFor(null)} />}
    </div>
  );
}

function TaskRow({ task, onClose }: { task: SupportTask; onClose: (id: string, note: string) => void }) {
  const t = useTranslations("yonetim.merkez.surveys");
  const [note, setNote] = useState("");
  return (
    <li className="flex flex-wrap items-center justify-between gap-3 py-4">
      <div>
        <b className="block text-theme-sm">{task.veli_ad ?? "—"}</b>
        <span className="text-theme-xs text-gray-500">
          {t("taskMeta", { nps: task.nps ?? "—", d: formatDateTime(task.created_at) })}
        </span>
      </div>
      <div className="flex items-center gap-2">
        <input
          className={`${inputClass} h-10 w-56`}
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder={t("taskNote")}
          aria-label={t("taskNote")}
        />
        <button type="button" className={outlineBtn} onClick={() => onClose(task.id, note)}>{t("taskClose")}</button>
      </div>
    </li>
  );
}

function Editor({
  initial,
  onClose,
  onSaved,
}: {
  initial: Survey | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const t = useTranslations("yonetim.merkez.surveys");
  const [ad, setAd] = useState(initial?.ad ?? "");
  const [anonim, setAnonim] = useState(initial?.anonim ?? false);
  const [gun, setGun] = useState(initial?.tekrar_gosterim_gun ?? 30);
  const [sorular, setSorular] = useState<SurveyQuestion[]>(
    initial?.sorular ?? [{ id: newId(), tur: "nps", baslik: "" }],
  );
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [preview, setPreview] = useState(false);
  const [npsPick, setNpsPick] = useState<Record<string, number | null>>({});

  const lockedAnon = (initial?.yanit_sayisi ?? 0) > 0;

  const patch = (i: number, p: Partial<SurveyQuestion>) =>
    setSorular((s) => s.map((q, k) => (k === i ? { ...q, ...p } : q)));
  const move = (i: number, d: number) =>
    setSorular((s) => {
      const j = i + d;
      if (j < 0 || j >= s.length) return s;
      const c = [...s];
      [c[i], c[j]] = [c[j], c[i]];
      return c;
    });
  const remove = (i: number) =>
    setSorular((s) => {
      const gone = s[i].id;
      // Silinen soruya bağlı koşullar da düşer.
      return s.filter((_, k) => k !== i).map((q) => (q.kosul?.soru_id === gone ? { ...q, kosul: null } : q));
    });

  const add = (tur: QuestionType) =>
    setSorular((s) => [
      ...s,
      { id: newId(), tur, baslik: "", ...(tur === "tek_secim" ? { secenekler: ["", ""] } : {}) },
    ]);

  const save = async () => {
    setBusy(true);
    setError(null);
    const payload = sorular.map((q) => ({
      ...q,
      kosul: q.kosul ?? undefined,
      secenekler: q.tur === "tek_secim" ? (q.secenekler ?? []).map((x) => x.trim()).filter(Boolean) : undefined,
    }));
    const r = await adminCall("admin_anket_kaydet", {
      p_id: initial?.id ?? null,
      p_ad: ad,
      p_anonim: anonim,
      p_sorular: payload,
      p_tekrar_gun: gun,
    });
    setBusy(false);
    if (r.error) return setError(r.error === "DEMO" ? t("demo") : r.error);
    onSaved();
  };

  /** Önizlemede koşullu soru: bağlı olduğu NPS yanıtı koşulu sağlıyorsa görünür. */
  const visible = (q: SurveyQuestion): boolean => {
    if (!q.kosul) return true;
    const v = npsPick[q.kosul.soru_id];
    if (v === null || v === undefined) return false;
    return q.kosul.op === "lte" ? v <= q.kosul.deger : q.kosul.op === "gte" ? v >= q.kosul.deger : v === q.kosul.deger;
  };

  return (
    <Modal isOpen onClose={onClose} className="m-4 max-w-4xl p-6 sm:p-8">
      <h3 className="mb-5 pe-12 text-lg font-semibold text-gray-800 dark:text-white/90">
        {initial ? t("editTitle") : t("newTitle")}
      </h3>

      <div className="grid gap-4 sm:grid-cols-3">
        <div className="sm:col-span-2">
          <label className={labelClass} htmlFor="sv-ad">{t("form.name")}</label>
          <input id="sv-ad" className={inputClass} value={ad} maxLength={120} onChange={(e) => setAd(e.target.value)} />
        </div>
        <div>
          <label className={labelClass} htmlFor="sv-gun">{t("form.repeatDays")}</label>
          <input id="sv-gun" type="number" min={1} max={365} className={inputClass} value={gun} onChange={(e) => setGun(Number(e.target.value))} />
        </div>
      </div>

      <label className="mt-4 flex items-start gap-2 text-theme-sm">
        <input
          type="checkbox"
          className="mt-0.5 size-4 accent-brand-500"
          checked={anonim}
          disabled={lockedAnon}
          onChange={(e) => setAnonim(e.target.checked)}
        />
        <span>
          <b>{t("form.anonymous")}</b>
          <span className="block text-theme-xs text-gray-500 dark:text-gray-400">
            {lockedAnon ? t("form.anonymousLocked") : t("form.anonymousHelp")}
          </span>
        </span>
      </label>

      <div className="mt-5 space-y-3">
        {sorular.map((q, i) => (
          <div key={q.id} className="rounded-xl border border-gray-200 p-4 dark:border-gray-800">
            <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
              <div className="flex items-center gap-2">
                <Badge size="sm" color="light">{i + 1}</Badge>
                <select
                  className="h-9 rounded-lg border border-gray-300 bg-transparent px-2 text-theme-sm dark:border-gray-700"
                  value={q.tur}
                  aria-label={t("form.type")}
                  onChange={(e) =>
                    patch(i, {
                      tur: e.target.value as QuestionType,
                      secenekler: e.target.value === "tek_secim" ? (q.secenekler ?? ["", ""]) : undefined,
                    })
                  }
                >
                  {TYPES.map((x) => <option key={x} value={x}>{t(`types.${x}`)}</option>)}
                </select>
              </div>
              <div className="flex gap-3 text-theme-xs font-medium">
                <button type="button" className="text-brand-500" onClick={() => move(i, -1)} aria-label={t("form.up")}>↑</button>
                <button type="button" className="text-brand-500" onClick={() => move(i, 1)} aria-label={t("form.down")}>↓</button>
                <button type="button" className="text-error-600" onClick={() => remove(i)}>{t("form.remove")}</button>
              </div>
            </div>
            <input
              className={inputClass}
              value={q.baslik}
              maxLength={200}
              aria-label={t("form.questionTitle", { n: i + 1 })}
              placeholder={t("form.questionPlaceholder")}
              onChange={(e) => patch(i, { baslik: e.target.value })}
            />
            {q.tur === "tek_secim" && (
              <input
                className={`${inputClass} mt-2`}
                value={(q.secenekler ?? []).join(", ")}
                aria-label={t("form.options")}
                placeholder={t("form.optionsPlaceholder")}
                onChange={(e) => patch(i, { secenekler: e.target.value.split(",").map((x) => x.trimStart()) })}
              />
            )}
            {i > 0 && (
              <div className="mt-3 flex flex-wrap items-center gap-2 text-theme-xs">
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    className="size-4 accent-brand-500"
                    checked={!!q.kosul}
                    onChange={(e) =>
                      patch(i, {
                        kosul: e.target.checked
                          ? { soru_id: sorular[i - 1].id, op: "lte", deger: 6 }
                          : null,
                      })
                    }
                  />
                  {t("form.conditional")}
                </label>
                {q.kosul && (
                  <>
                    <select
                      className="h-8 rounded-lg border border-gray-300 bg-transparent px-2 dark:border-gray-700"
                      value={q.kosul.soru_id}
                      aria-label={t("form.condQuestion")}
                      onChange={(e) => patch(i, { kosul: { ...q.kosul!, soru_id: e.target.value } })}
                    >
                      {sorular.slice(0, i).map((p, k) => (
                        <option key={p.id} value={p.id}>{k + 1}. {p.baslik || t(`types.${p.tur}`)}</option>
                      ))}
                    </select>
                    <select
                      className="h-8 rounded-lg border border-gray-300 bg-transparent px-2 dark:border-gray-700"
                      value={q.kosul.op}
                      aria-label={t("form.condOp")}
                      onChange={(e) => patch(i, { kosul: { ...q.kosul!, op: e.target.value as "lte" | "gte" | "eq" } })}
                    >
                      <option value="lte">≤</option>
                      <option value="gte">≥</option>
                      <option value="eq">=</option>
                    </select>
                    <input
                      type="number"
                      className="h-8 w-16 rounded-lg border border-gray-300 bg-transparent px-2 dark:border-gray-700"
                      value={q.kosul.deger}
                      aria-label={t("form.condValue")}
                      onChange={(e) => patch(i, { kosul: { ...q.kosul!, deger: Number(e.target.value) } })}
                    />
                  </>
                )}
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="mt-4 flex flex-wrap gap-2">
        {TYPES.map((x) => (
          <button key={x} type="button" className={`${outlineBtn} px-3! py-1.5! text-theme-xs!`} onClick={() => add(x)}>
            + {t(`types.${x}`)}
          </button>
        ))}
      </div>

      <p className="mt-4 rounded-xl bg-[#eef5f2] px-4 py-3 text-theme-xs text-[#3d6654] dark:bg-brand-500/10 dark:text-brand-300">
        {t("form.rules")}
      </p>

      {preview && (
        <div className="mt-4 space-y-3 rounded-xl border border-dashed border-gray-300 p-4 dark:border-gray-700">
          <p className="text-theme-xs text-gray-500">{t("form.previewNote")}</p>
          {sorular.filter(visible).map((q) => (
            <div key={q.id} className="rounded-lg border border-gray-200 p-3 dark:border-gray-800">
              <b className="block text-theme-sm">{q.baslik || t("form.questionPlaceholder")}</b>
              {q.tur === "nps" && (
                <div className="mt-2 flex flex-wrap gap-1.5">
                  {Array.from({ length: 11 }, (_, n) => (
                    <button
                      key={n}
                      type="button"
                      aria-pressed={npsPick[q.id] === n}
                      onClick={() => setNpsPick({ ...npsPick, [q.id]: n })}
                      className={`size-8 rounded-md border text-theme-xs ${
                        npsPick[q.id] === n ? "border-brand-500 bg-brand-500 text-white" : "border-gray-300 dark:border-gray-700"
                      }`}
                    >
                      {n}
                    </button>
                  ))}
                </div>
              )}
              {q.tur === "csat" && <p className="mt-2 text-theme-xs text-gray-500">1 · 2 · 3 · 4 · 5</p>}
              {q.tur === "onay" && <p className="mt-2 text-theme-xs text-gray-500">☐ {t("form.consentSample")}</p>}
              {q.tur === "tek_secim" && <p className="mt-2 text-theme-xs text-gray-500">{(q.secenekler ?? []).filter(Boolean).join(" · ")}</p>}
              {(q.tur === "kisa_metin" || q.tur === "uzun_metin") && <div className="mt-2 h-8 rounded-md bg-gray-100 dark:bg-white/5" />}
            </div>
          ))}
        </div>
      )}

      {error && <div className="mt-4"><Feedback kind="error" message={error} /></div>}
      <div className="mt-5 flex flex-wrap justify-end gap-3">
        <button type="button" className={outlineBtn} onClick={() => setPreview((v) => !v)}>
          {preview ? t("form.hidePreview") : t("form.preview")}
        </button>
        <button type="button" className={outlineBtn} onClick={onClose}>{t("form.close")}</button>
        <button type="button" className={primaryBtn} disabled={busy || ad.trim().length < 2 || sorular.some((q) => !q.baslik.trim())} onClick={save}>
          {t("form.save")}
        </button>
      </div>
    </Modal>
  );
}

function Results({ survey, onClose }: { survey: Survey; onClose: () => void }) {
  const t = useTranslations("yonetim.merkez.surveys");
  const state = useAdminRpc<SurveyResult>("admin_anket_sonuc", { p_id: survey.id }, { demo: DEMO_SURVEY_RESULT });

  return (
    <Modal isOpen onClose={onClose} className="m-4 max-w-2xl p-6 sm:p-8">
      <h3 className="mb-4 pe-12 text-lg font-semibold text-gray-800 dark:text-white/90">{survey.ad}</h3>
      <RpcBoundary state={state}>
        {(r) => (
          <div className="space-y-5">
            <div className="flex items-end gap-4">
              <div className="text-[44px] leading-none font-semibold tracking-tight text-brand-500">
                {r.nps.skor === null ? "—" : r.nps.skor > 0 ? `+${r.nps.skor}` : r.nps.skor}
              </div>
              <p className="text-theme-xs text-gray-500 dark:text-gray-400">
                {t("res.npsNote", { n: r.nps.n })}
              </p>
            </div>
            <table className="min-w-full text-theme-sm">
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                <tr><td className="py-2">{t("res.promoters")}</td><td className="py-2 text-end font-semibold">{r.nps.destekleyen}</td></tr>
                <tr><td className="py-2">{t("res.passives")}</td><td className="py-2 text-end font-semibold">{r.nps.pasif}</td></tr>
                <tr><td className="py-2">{t("res.detractors")}</td><td className="py-2 text-end font-semibold">{r.nps.elestiren}</td></tr>
              </tbody>
            </table>
            <div>
              <h4 className="mb-2 text-theme-sm font-semibold">{t("res.perQuestion")}</h4>
              <ul className="divide-y divide-gray-100 text-theme-sm dark:divide-gray-800">
                {r.sorular.map((q) => (
                  <li key={q.soru_id} className="flex justify-between gap-3 py-2">
                    <span className="min-w-0 truncate">{q.baslik}</span>
                    <span className="shrink-0 text-gray-500">
                      {t("res.answers", { n: q.yanit })}
                      {q.ortalama !== null ? ` · ${t("res.avg", { v: q.ortalama })}` : ""}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
            {r.metinler.length > 0 && (
              <div>
                <h4 className="mb-2 text-theme-sm font-semibold">{t("res.texts")}</h4>
                <ul className="space-y-2">
                  {r.metinler.map((m, i) => (
                    <li key={i} className="rounded-xl bg-gray-50 px-4 py-3 text-theme-sm dark:bg-white/3">{m.metin}</li>
                  ))}
                </ul>
                <p className="mt-2 text-theme-xs text-gray-500">{t("res.textsNote")}</p>
              </div>
            )}
          </div>
        )}
      </RpcBoundary>
    </Modal>
  );
}
