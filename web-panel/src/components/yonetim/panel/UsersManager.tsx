"use client";

import { useCallback, useEffect, useState } from "react";
import { useTranslations } from "next-intl";

import Badge from "@/components/ui/badge/Badge";
import { formatDate } from "@/utils/format";
import { createClient } from "@/utils/supabase/client";
import ExportDialog from "../merkez/ExportDialog";
import VeliProfilePanel from "../merkez/VeliProfilePanel";
import Drawer from "../ui/Drawer";
import Pager from "../Pager";
import type { AdminUser, Paged, UserRole } from "../types";
import ErrorNote from "./ErrorNote";
import LinkChildModal from "./LinkChildModal";
import ModalShell from "./ModalShell";
import {
  cardClass,
  dangerBtn,
  inputClass,
  labelClass,
  linkBtn,
  outlineBtn,
  primaryBtn,
  tdClass,
  thClass,
} from "./styles";
import useDebounced from "./useDebounced";

const PAGE_SIZE = 25;
const ROLES: UserRole[] = ["veli", "ogrenci", "admin", "ogretmen"];
const ROLE_COLOR = { veli: "info", ogrenci: "primary", admin: "warning", ogretmen: "success" } as const;

export default function UsersManager() {
  const t = useTranslations("yonetim.kullanicilar");
  const [search, setSearch] = useState("");
  const debounced = useDebounced(search);
  const [rol, setRol] = useState<"" | UserRole>("");
  const [page, setPage] = useState(0);
  const [reloadKey, setReloadKey] = useState(0);

  const [list, setList] = useState<Paged<AdminUser> | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [profileUser, setProfileUser] = useState<AdminUser | null>(null);
  const [exportOpen, setExportOpen] = useState(false);
  const [linkTarget, setLinkTarget] = useState<AdminUser | null>(null);
  const [unlinkTarget, setUnlinkTarget] = useState<AdminUser | null>(null);
  const [unlinking, setUnlinking] = useState(false);
  const [unlinkError, setUnlinkError] = useState<string | null>(null);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data, error: err } = await createClient().rpc("admin_list_users", {
        p_rol: rol || null,
        p_arama: debounced.trim() || null,
        p_limit: PAGE_SIZE,
        p_offset: page * PAGE_SIZE,
      });
      if (cancelled) return;
      if (err) {
        setError(err.message);
        setList(null);
      } else {
        setError(null);
        setList(data as Paged<AdminUser>);
      }
      setLoading(false);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [debounced, rol, page, reloadKey]);

  const doUnlink = async () => {
    if (!unlinkTarget) return;
    setUnlinking(true);
    setUnlinkError(null);
    const { error: err } = await createClient().rpc("admin_link_child", {
      p_cocuk_id: unlinkTarget.id,
      p_veli_id: null,
    });
    setUnlinking(false);
    if (err) return setUnlinkError(err.message);
    setUnlinkTarget(null);
    reload();
  };

  const rows = list?.satirlar ?? [];
  const total = list?.toplam ?? 0;
  const start = total === 0 ? 0 : page * PAGE_SIZE + 1;
  const end = Math.min(total, page * PAGE_SIZE + rows.length);

  return (
    <div className="space-y-6">
      <section className={`${cardClass} p-5 sm:p-6`}>
        <div className="mb-4 flex flex-wrap items-end gap-4">
          <div className="min-w-60 flex-1">
            <label className={labelClass} htmlFor="u-search">{t("search")}</label>
            <input
              id="u-search"
              type="search"
              className={inputClass}
              placeholder={t("searchPlaceholder")}
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(0); setLoading(true); }}
            />
          </div>
          <div className="min-w-40">
            <label className={labelClass} htmlFor="u-role">{t("role")}</label>
            <select
              id="u-role"
              className={inputClass}
              value={rol}
              onChange={(e) => { setRol(e.target.value as "" | UserRole); setPage(0); setLoading(true); }}
            >
              <option value="">{t("allRoles")}</option>
              {ROLES.map((r) => (
                <option key={r} value={r}>{t(`roles.${r}`)}</option>
              ))}
            </select>
          </div>
          <button type="button" className={outlineBtn} onClick={() => setExportOpen(true)}>
            {t("export.open")}
          </button>
        </div>

        {loading ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("loading")}</p>
        ) : error ? (
          <div className="py-8 text-center">
            <p className="mb-3 text-sm text-error-600 dark:text-error-500">{error}</p>
            <button type="button" className={primaryBtn} onClick={() => { setLoading(true); reload(); }}>
              {t("retry")}
            </button>
          </div>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">{t("empty")}</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th className={thClass}>{t("cols.name")}</th>
                  <th className={thClass}>{t("cols.email")}</th>
                  <th className={thClass}>{t("cols.role")}</th>
                  <th className={thClass}>{t("cols.grade")}</th>
                  <th className={thClass}>{t("cols.parent")}</th>
                  <th className={thClass}>{t("cols.children")}</th>
                  <th className={thClass}>{t("cols.joined")}</th>
                  <th className={thClass} />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {rows.map((u) => (
                  <tr key={u.id}>
                    <td className={`${tdClass} font-medium text-gray-800 dark:text-white/90`}>
                      <button
                        type="button"
                        className="text-start font-medium hover:text-brand-500 focus-visible:outline-3 focus-visible:outline-offset-2 focus-visible:outline-blue-light-400"
                        onClick={() => setProfileUser(u)}
                        aria-label={`${t("profile.open")}: ${u.ad ?? u.email ?? ""}`}
                      >
                        {u.ad ?? "-"}
                      </button>
                    </td>
                    <td className={tdClass}>{u.email ?? "-"}</td>
                    <td className={tdClass}>
                      <Badge size="sm" color={ROLE_COLOR[u.rol] ?? "light"}>{t(`roles.${u.rol}`)}</Badge>
                    </td>
                    <td className={tdClass}>{u.sinif ?? "-"}</td>
                    <td className={tdClass}>{u.rol === "ogrenci" ? (u.veli_ad ?? t("unlinked")) : "-"}</td>
                    <td className={tdClass}>{u.rol === "veli" ? u.cocuk_sayisi : "-"}</td>
                    <td className={`${tdClass} whitespace-nowrap`}>
                      {u.uyelik_tarihi ? formatDate(new Date(u.uyelik_tarihi)) : "-"}
                    </td>
                    <td className={`${tdClass} whitespace-nowrap text-end`}>
                      {u.rol === "ogrenci" && (
                        <span className="flex justify-end gap-3">
                          <button type="button" className={linkBtn} onClick={() => setLinkTarget(u)}>
                            {u.veli_id ? t("changeParent") : t("linkParent")}
                          </button>
                          {u.veli_id && (
                            <button
                              type="button"
                              className="text-theme-sm font-medium text-error-600 hover:text-error-700 dark:text-error-500"
                              onClick={() => { setUnlinkError(null); setUnlinkTarget(u); }}
                            >
                              {t("unlink")}
                            </button>
                          )}
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {!loading && !error && total > 0 && (
          <Pager
            page={page}
            pageSize={PAGE_SIZE}
            total={total}
            onPage={(p) => { setLoading(true); setPage(p); }}
            labels={{ prev: t("pager.prev"), next: t("pager.next"), summary: `${start}–${end} / ${total}` }}
          />
        )}
      </section>

      <Drawer
        open={profileUser !== null}
        onClose={() => setProfileUser(null)}
        title={t("profile.title")}
        closeLabel={t("profile.close")}
      >
        {profileUser && profileUser.rol === "veli" && (
          <VeliProfilePanel key={profileUser.id} veliId={profileUser.id} />
        )}
        {profileUser && profileUser.rol !== "veli" && (
          <div className="space-y-5">
            <div className="flex items-center gap-3">
              <span className="grid size-14 place-items-center rounded-full bg-brand-50 text-lg font-bold text-brand-600 dark:bg-brand-500/15">
                {(profileUser.ad ?? profileUser.email ?? "?").slice(0, 2).toLocaleUpperCase("tr")}
              </span>
              <div className="min-w-0">
                <h3 className="truncate text-lg font-semibold text-navy dark:text-white/90">
                  {profileUser.ad ?? "-"}
                </h3>
                <p className="truncate text-theme-sm text-gray-500 dark:text-gray-400">
                  {profileUser.email ?? "-"}
                </p>
              </div>
            </div>
            <div className="flex flex-wrap gap-2">
              <Badge size="sm" color={ROLE_COLOR[profileUser.rol] ?? "light"}>
                {t(`roles.${profileUser.rol}`)}
              </Badge>
              {profileUser.sinif && (
                <Badge size="sm" color="light">{profileUser.sinif}</Badge>
              )}
            </div>

            <div>
              <h4 className="mb-2 text-theme-sm font-semibold text-gray-800 dark:text-white/90">
                {t("profile.learning")}
              </h4>
              <dl className="divide-y divide-gray-100 rounded-xl border border-gray-200 text-theme-sm dark:divide-gray-800 dark:border-gray-800">
                {profileUser.rol === "ogrenci" && (
                  <div className="flex justify-between gap-4 px-4 py-3">
                    <dt className="text-gray-500 dark:text-gray-400">{t("profile.parent")}</dt>
                    <dd className="font-medium">{profileUser.veli_ad ?? t("unlinked")}</dd>
                  </div>
                )}
                <div className="flex justify-between gap-4 px-4 py-3">
                  <dt className="text-gray-500 dark:text-gray-400">{t("cols.joined")}</dt>
                  <dd className="font-medium">
                    {profileUser.uyelik_tarihi
                      ? formatDate(new Date(profileUser.uyelik_tarihi))
                      : "-"}
                  </dd>
                </div>
              </dl>
            </div>

            {profileUser.rol === "ogrenci" && (
              <div>
                <h4 className="mb-2 text-theme-sm font-semibold text-gray-800 dark:text-white/90">
                  {t("profile.actions")}
                </h4>
                <div className="flex flex-wrap gap-3">
                  <button
                    type="button"
                    className={outlineBtn}
                    onClick={() => {
                      setLinkTarget(profileUser);
                      setProfileUser(null);
                    }}
                  >
                    {profileUser.veli_id ? t("changeParent") : t("linkParent")}
                  </button>
                  {profileUser.veli_id && (
                    <button
                      type="button"
                      className={dangerBtn}
                      onClick={() => {
                        setUnlinkError(null);
                        setUnlinkTarget(profileUser);
                        setProfileUser(null);
                      }}
                    >
                      {t("unlink")}
                    </button>
                  )}
                </div>
              </div>
            )}

            <p className="rounded-xl bg-[#eef5f2] px-4 py-3 text-theme-xs text-[#3d6654] dark:bg-brand-500/10 dark:text-brand-300">
              {t("profile.scopeNote")}
            </p>
          </div>
        )}
      </Drawer>

      {exportOpen && <ExportDialog search={debounced} onClose={() => setExportOpen(false)} />}

      {linkTarget && (
        <LinkChildModal
          key={linkTarget.id}
          child={linkTarget}
          onClose={() => setLinkTarget(null)}
          onSaved={reload}
        />
      )}

      {unlinkTarget && (
        <ModalShell isOpen onClose={() => setUnlinkTarget(null)} title={t("unlinkConfirm.title")}>
          <div className="space-y-4">
            <p className="text-theme-sm text-gray-600 dark:text-gray-400">
              {t("unlinkConfirm.text", { student: unlinkTarget.ad ?? unlinkTarget.email ?? "", parent: unlinkTarget.veli_ad ?? "" })}
            </p>
            <ErrorNote message={unlinkError} />
            <div className="flex justify-end gap-3">
              <button type="button" className={outlineBtn} onClick={() => setUnlinkTarget(null)}>
                {t("unlinkConfirm.cancel")}
              </button>
              <button type="button" className={dangerBtn} disabled={unlinking} onClick={doUnlink}>
                {unlinking ? t("unlinkConfirm.saving") : t("unlinkConfirm.confirm")}
              </button>
            </div>
          </div>
        </ModalShell>
      )}
    </div>
  );
}
